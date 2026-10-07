import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/kwanza_track_mobile_api_client.dart';
import '../../../farmer/domain/entities/farm_plot.dart';
import '../../../farmer/domain/entities/service_request.dart';
import '../remote/service_orders_remote_data_source.dart';
import '../../domain/entities/operations_models.dart';

class UnionOperationsRepository extends ChangeNotifier {
  UnionOperationsRepository.seeded({
    ServiceOrdersRemoteDataSource? remoteDataSource,
    KwanzaTrackMobileApiClient? mobileApiClient,
  }) : remoteDataSource =
           remoteDataSource ?? const ServiceOrdersRemoteDataSource(),
       mobileApiClient = mobileApiClient ?? const KwanzaTrackMobileApiClient(),
       _requests = _seedRequests(),
       _tractors = _seedTractors(),
       _operators = _seedOperators(),
       _jobs = _seedJobs();

  final ServiceOrdersRemoteDataSource remoteDataSource;
  final KwanzaTrackMobileApiClient mobileApiClient;
  final List<OperationsServiceRequest> _requests;
  final List<TractorAsset> _tractors;
  final List<OperatorProfile> _operators;
  final List<OperationsJob> _jobs;
  final List<MechanizationOverride> _overrides = [];
  final List<MechanizationException> _exceptions = [];
  String? _accessToken;
  bool _isSyncingMechanization = false;
  String? _mechanizationSyncError;
  String? _mechanizationActionError;
  String? _mechanizationUserName;
  Map<String, Object?> _dashboardData = const {};
  int? _remoteBacklogCount;
  int _syncGeneration = 0;

  List<OperationsServiceRequest> get requests => List.unmodifiable(_requests);
  List<TractorAsset> get tractors => List.unmodifiable(_tractors);
  List<OperatorProfile> get operators => List.unmodifiable(_operators);
  List<OperationsJob> get jobs => List.unmodifiable(_jobs);
  List<MechanizationOverride> get overrides => List.unmodifiable(_overrides);
  List<MechanizationException> get exceptions => List.unmodifiable(_exceptions);
  bool get isSyncingMechanization => _isSyncingMechanization;
  String? get mechanizationSyncError => _mechanizationSyncError;
  String? get mechanizationActionError => _mechanizationActionError;
  String? get mechanizationUserName => _mechanizationUserName;
  bool get hasMechanizationToken =>
      _accessToken != null && _accessToken!.isNotEmpty;

  Future<ServiceOrdersFetchResult> fetchRemoteServiceOrders() {
    return remoteDataSource.fetchServiceOrders();
  }

  void setMechanizationAccessToken(String? token) {
    final normalized = token?.trim();
    if (_accessToken == normalized) return;
    _accessToken = normalized?.isEmpty == true ? null : normalized;
    _mechanizationSyncError = null;
    if (_accessToken == null) {
      _mechanizationUserName = null;
      _dashboardData = const {};
      _remoteBacklogCount = null;
      _overrides.clear();
      _exceptions.clear();
      notifyListeners();
      return;
    }
    refreshMechanizationData();
  }

  Future<void> refreshMechanizationData() async {
    final token = _accessToken;
    if (token == null || token.isEmpty || _isSyncingMechanization) return;

    final generation = ++_syncGeneration;
    _isSyncingMechanization = true;
    _mechanizationSyncError = null;
    _mechanizationActionError = null;
    notifyListeners();

    try {
      final today = DateTime.now();
      final from = _dateOnly(today.subtract(const Duration(days: 2)));
      final to = _dateOnly(today.add(const Duration(days: 7)));
      final responses = await Future.wait<Map<String, Object?>>([
        mobileApiClient.me(token: token),
        mobileApiClient.dashboard(token: token, days: 30),
        mobileApiClient.calendar(
          token: token,
          from: from,
          to: to,
          mine: true,
        ),
        mobileApiClient.calendar(
          token: token,
          from: from,
          to: to,
          mine: false,
          status:
              'scheduled,dispatched,en_route,arrived,in_progress,completed,flagged,closed,cancelled',
        ),
        mobileApiClient.calendarBacklog(token: token),
        mobileApiClient.requests(token: token, status: 'queue'),
        mobileApiClient.tractors(token: token, mine: true, live: true),
        mobileApiClient.tractors(token: token, mine: false),
        mobileApiClient.overrides(token: token),
        mobileApiClient.exceptions(token: token),
      ]);
      if (generation != _syncGeneration) return;

      _applyMeResponse(responses[0]);
      _dashboardData = _dataMap(responses[1]);
      _applyCalendarResponse(responses[3]);
      _remoteBacklogCount =
          _metaCount(responses[4]) ?? _dataList(responses[4]).length;
      _applyRequestsResponse(responses[5], replace: true);
      await _refreshAllRequestBuckets(token);
      _applyTractorsResponse(responses[7]);
      _applyTractorsResponse(responses[6]);
      _applyOverridesResponse(responses[8]);
      _applyExceptionsResponse(responses[9]);
      _mechanizationSyncError = null;
    } on KwanzaTrackApiException catch (error) {
      if (generation == _syncGeneration) {
        _mechanizationSyncError = error.message;
      }
    } catch (error) {
      if (generation == _syncGeneration) {
        _mechanizationSyncError = 'Could not refresh mechanization data: $error';
      }
    } finally {
      if (generation == _syncGeneration) {
        _isSyncingMechanization = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshTractorDetails(String tractorId) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) return;

    try {
      final responses = await Future.wait<Map<String, Object?>>([
        mobileApiClient.tractor(token: token, tractorId: tractorId),
        mobileApiClient.inspectionToday(token: token, tractorId: tractorId),
      ]);
      final tractor = _tractorFromJson(_dataMap(responses[0]));
      if (tractor != null) _upsertTractor(tractor);

      final inspectedToday = responses[1]['success'] == true &&
          _dataMap(responses[1]).isNotEmpty;
      final index = _tractors.indexWhere((item) => item.id == tractorId);
      if (index != -1) {
        _tractors[index] = _tractors[index].copyWith(
          inspectedToday:
              inspectedToday || (_tractors[index].inspectedToday == true),
        );
      }
      notifyListeners();
    } on KwanzaTrackApiException catch (error) {
      _mechanizationSyncError = error.message;
      notifyListeners();
    }
  }

  Future<TractorAsset?> lookupTractorQr(String qrToken) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) return null;

    try {
      final response = await mobileApiClient.tractorQr(
        token: token,
        qrToken: qrToken,
      );
      final tractor = _tractorFromJson(_dataMap(response));
      if (tractor != null) {
        _upsertTractor(tractor);
        notifyListeners();
      }
      return tractor;
    } on KwanzaTrackApiException catch (error) {
      _mechanizationSyncError = error.message;
      notifyListeners();
      return null;
    }
  }

  List<OperationsServiceRequest> requestsByStatus(
    OperationsRequestStatus? status,
  ) {
    if (status == null) return requests;
    return _requests.where((request) => request.status == status).toList();
  }

  List<OperationsJob> get activeJobs {
    return _jobs
        .where(
          (job) =>
              job.status == JobStatus.dispatched ||
              job.status == JobStatus.enRoute ||
              job.status == JobStatus.arrived ||
              job.status == JobStatus.inProgress,
        )
        .toList();
  }

  int get pendingOverrideCount => _overrides
      .where((override) => override.status.toLowerCase() == 'pending')
      .length;

  int get openExceptionCount => _exceptions
      .where((exception) => exception.status.toLowerCase() == 'open')
      .length;

  int get pendingRequestCount {
    final loadedPending = _requests
        .where((request) => request.status == OperationsRequestStatus.pending)
        .length;
    if (_requests.isNotEmpty) return loadedPending;

    final dashboardValue = _dashboardInt(const [
      'pending_requests',
      'pending_request_count',
      'requests_pending',
      'pending',
    ]);
    if (dashboardValue != null) return dashboardValue;
    if (_remoteBacklogCount != null) return _remoteBacklogCount!;
    return loadedPending;
  }

  int get completedTodayCount {
    final dashboardValue = _dashboardInt(const [
      'completed_today',
      'completed_jobs_today',
      'jobs_completed_today',
      'completed',
    ]);
    if (dashboardValue != null) return dashboardValue;
    return _jobs
        .where(
          (job) =>
              job.status == JobStatus.completedPendingConfirmation ||
              job.status == JobStatus.closed,
        )
        .length;
  }

  int get maintenanceCount {
    final dashboardValue = _dashboardInt(const [
      'maintenance',
      'maintenance_count',
      'tractors_under_maintenance',
      'under_maintenance',
    ]);
    if (dashboardValue != null) return dashboardValue;
    return _tractors
        .where((tractor) => tractor.status == TractorStatus.underMaintenance)
        .length;
  }

  OperationsServiceRequest requestById(String id) {
    return _requests.firstWhere((request) => request.id == id);
  }

  OperationsJob jobById(String id) {
    return _jobs.firstWhere((job) => job.id == id);
  }

  Future<void> refreshServiceRequests({String? status}) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) return;
    try {
      _mechanizationActionError = null;
      if (status == null) {
        await _refreshAllRequestBuckets(token);
      } else {
        final response = await mobileApiClient.requests(
          token: token,
          status: status,
        );
        _applyRequestsResponse(response, replace: true);
      }
      notifyListeners();
    } on KwanzaTrackApiException catch (error) {
      _mechanizationActionError = error.message;
      notifyListeners();
    }
  }

  Future<void> refreshRequestDetail(String id) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) return;
    try {
      _mechanizationActionError = null;
      final response = await mobileApiClient.request(
        token: token,
        requestId: id,
      );
      final request = _requestFromJson(_dataMap(response));
      if (request != null) _upsertRequest(request);
      notifyListeners();
    } on KwanzaTrackApiException catch (error) {
      _mechanizationActionError = error.message;
      notifyListeners();
    }
  }

  Future<void> registerRequest({
    required String farmerId,
    required String plotId,
    required String serviceTypeId,
    required num requestedAcres,
    required DateTime preferredDate,
    required String preferredWindow,
    required String priority,
    String? notes,
  }) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) return;
    try {
      _mechanizationActionError = null;
      final response = await mobileApiClient.createRequest(
        token: token,
        farmerId: farmerId,
        plotId: plotId,
        serviceTypeId: serviceTypeId,
        requestedAcres: requestedAcres,
        preferredDate: _dateOnly(preferredDate),
        preferredWindow: preferredWindow,
        priority: priority,
        notes: notes,
      );
      final request = _requestFromJson(_dataMap(response));
      if (request != null) _upsertRequest(request);
      notifyListeners();
    } on KwanzaTrackApiException catch (error) {
      _mechanizationActionError = error.message;
      notifyListeners();
    }
  }

  Future<void> approveRequest({
    required String id,
    required num estimateAmount,
    required String priority,
    String? note,
  }) async {
    if (await _tryRemoteRequestUpdate(
      () => mobileApiClient.approveRequest(
        token: _accessToken!,
        requestId: id,
        estimateAmount: estimateAmount,
        priority: priority,
        note: note,
      ),
    )) {
      return;
    }
    _replaceRequest(
      id,
      requestById(id).copyWith(status: OperationsRequestStatus.approved),
    );
  }

  Future<void> rejectRequest({
    required String id,
    required String reason,
    required String notes,
  }) async {
    if (await _tryRemoteRequestUpdate(
      () => mobileApiClient.rejectRequest(
        token: _accessToken!,
        requestId: id,
        reason: notes.trim().isEmpty ? reason : notes.trim(),
      ),
    )) {
      return;
    }
    _replaceRequest(
      id,
      requestById(id).copyWith(
        status: OperationsRequestStatus.rejected,
        rejectionReason: reason,
        rejectionNotes: notes,
      ),
    );
  }

  Future<void> returnRequest({
    required String id,
    required String reason,
  }) async {
    if (await _tryRemoteRequestUpdate(
      () => mobileApiClient.returnRequest(
        token: _accessToken!,
        requestId: id,
        reason: reason,
      ),
    )) {
      return;
    }
    _replaceRequest(
      id,
      requestById(id).copyWith(
        status: OperationsRequestStatus.returned,
        rejectionReason: reason,
      ),
    );
  }

  Future<void> cancelRequest({
    required String id,
    required String reason,
    required String notes,
  }) async {
    if (await _tryRemoteRequestUpdate(
      () => mobileApiClient.cancelRequest(
        token: _accessToken!,
        requestId: id,
        reason: notes.trim().isEmpty ? reason : notes.trim(),
      ),
    )) {
      return;
    }
    _replaceRequest(
      id,
      requestById(id).copyWith(
        status: OperationsRequestStatus.cancelled,
        rejectionReason: reason,
        rejectionNotes: notes,
      ),
    );
  }

  Future<String> scheduleRequest({
    required String requestId,
    required String tractorId,
    required String operatorId,
    required DateTime scheduledAt,
    required int estimatedHours,
  }) async {
    final request = requestById(requestId);
    if (await _tryRemoteRequestSchedule(
      requestId: requestId,
      tractorId: tractorId,
      operatorId: operatorId,
      scheduledAt: scheduledAt,
      estimatedHours: estimatedHours,
      request: request,
    )) {
      return requestId;
    }
    final tractor = _tractors.firstWhere((item) => item.id == tractorId);
    final operator = _operators.firstWhere((item) => item.id == operatorId);
    if (!tractor.status.canSchedule || !operator.status.canSchedule) {
      throw StateError('Selected resources are not available.');
    }

    final jobId = 'JOB-${210 + _jobs.length}';
    _jobs.insert(
      0,
      OperationsJob(
        id: jobId,
        requestId: request.id,
        farmerName: request.farmerName,
        serviceType: request.serviceType,
        plot: request.plot,
        tractor: tractor,
        operator: operator,
        scheduledAt: scheduledAt,
        estimatedHours: estimatedHours,
        status: JobStatus.scheduled,
        history: [
          _history(
            action: JobHistoryAction.scheduled,
            changedBy: 'Union staff',
            previousStatus: request.status == OperationsRequestStatus.approved
                ? null
                : JobStatus.scheduled,
            newScheduledAt: scheduledAt,
            newTractorId: tractor.id,
            newOperatorName: operator.name,
          ),
        ],
      ),
    );
    _replaceRequest(
      requestId,
      request.copyWith(status: OperationsRequestStatus.scheduled),
      notify: false,
    );
    notifyListeners();
    return jobId;
  }

  Future<RequestAvailabilityResult?> checkRequestAvailability({
    required DateTime date,
    required String tractorId,
    required String operatorId,
  }) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) return null;
    try {
      _mechanizationActionError = null;
      final response = await mobileApiClient.availability(
        token: token,
        date: _dateOnly(date),
        tractorId: tractorId,
        operatorId: operatorId,
      );
      final data = _dataMap(response);
      final tractor = _availabilityItems(data['tractor']);
      final operator = _availabilityItems(data['operator']);
      final result = RequestAvailabilityResult(
        isAvailable: tractor.isEmpty && operator.isEmpty,
        tractorConflicts: tractor,
        operatorConflicts: operator,
        loadHours: _number(data, const ['load_hours']) ?? 0,
      );
      notifyListeners();
      return result;
    } on KwanzaTrackApiException catch (error) {
      _mechanizationActionError = error.message;
      notifyListeners();
      return null;
    }
  }

  Future<void> dispatchJob(String jobId) async {
    final job = jobById(jobId);
    if (await _tryRemoteJobUpdate(
      () => mobileApiClient.dispatchJob(
        token: _accessToken!,
        jobId: jobId,
        tractorId: job.tractor.id,
        operatorId: job.operator.id,
      ),
    )) {
      return;
    }
    _replaceJob(
      jobId,
      job.copyWith(
        status: JobStatus.dispatched,
        history: [
          ...job.history,
          _history(
            action: JobHistoryAction.dispatched,
            changedBy: 'Union staff',
            previousStatus: job.status,
          ),
        ],
      ),
    );
  }

  Future<void> closeJob(String jobId, {String paymentStatus = 'paid'}) async {
    final job = jobById(jobId);
    if (await _tryRemoteJobUpdate(
      () => mobileApiClient.closeJob(
        token: _accessToken!,
        jobId: jobId,
        paymentStatus: paymentStatus,
      ),
    )) {
      return;
    }
    _replaceJob(
      jobId,
      job.copyWith(
        status: JobStatus.closed,
        history: [
          ...job.history,
          _history(
            action: JobHistoryAction.closed,
            changedBy: 'Union staff',
            previousStatus: job.status,
          ),
        ],
      ),
    );
  }

  Future<void> cancelJob({
    required String jobId,
    required JobCancellationReason reason,
    required String notes,
  }) {
    return _cancelJob(jobId: jobId, reason: reason, notes: notes);
  }

  Future<void> _cancelJob({
    required String jobId,
    required JobCancellationReason reason,
    required String notes,
  }) async {
    final job = jobById(jobId);
    if (await _tryRemoteJobUpdate(
      () => mobileApiClient.cancelJob(
        token: _accessToken!,
        jobId: jobId,
        reason: notes.trim().isEmpty ? reason.label : notes.trim(),
        cancelRequest: false,
      ),
    )) {
      return;
    }
    _replaceJob(
      jobId,
      job.copyWith(
        status: JobStatus.cancelled,
        alert: 'Cancelled: ${reason.label}',
        history: [
          ...job.history,
          _history(
            action: JobHistoryAction.cancelled,
            changedBy: 'Union staff',
            previousStatus: job.status,
            reason: reason.label,
            notes: notes,
          ),
        ],
      ),
    );
    final requestIndex = _requests.indexWhere(
      (request) => request.id == job.requestId,
    );
    if (requestIndex != -1) {
      _requests[requestIndex] = _requests[requestIndex].copyWith(
        status: OperationsRequestStatus.cancelled,
        rejectionReason: reason.label,
        rejectionNotes: notes,
      );
    }
  }

  Future<void> rescheduleJob({
    required String jobId,
    required DateTime newScheduledAt,
    required String tractorId,
    required String operatorId,
    required JobRescheduleReason reason,
    required String notes,
  }) async {
    final job = jobById(jobId);
    if (await _tryRemoteJobUpdate(
      () => mobileApiClient.rescheduleJob(
        token: _accessToken!,
        jobId: jobId,
        scheduledDate: _dateOnly(newScheduledAt),
        windowStart: _timeOnly(newScheduledAt),
        windowEnd: _timeOnly(
          newScheduledAt.add(Duration(hours: job.estimatedHours)),
        ),
        reason: notes.trim().isEmpty ? reason.label : notes.trim(),
      ),
    )) {
      return;
    }
    final tractor = _tractors.firstWhere((item) => item.id == tractorId);
    final operator = _operators.firstWhere((item) => item.id == operatorId);
    if (!tractor.status.canSchedule && tractor.id != job.tractor.id) {
      throw StateError('Selected tractor is not available.');
    }
    if (!operator.status.canSchedule && operator.id != job.operator.id) {
      throw StateError('Selected operator is not available.');
    }
    _replaceJob(
      jobId,
      job.copyWith(
        tractor: tractor,
        operator: operator,
        scheduledAt: newScheduledAt,
        status: JobStatus.scheduled,
        alert: 'Rescheduled: ${reason.label}',
        history: [
          ...job.history,
          _history(
            action: JobHistoryAction.rescheduled,
            changedBy: 'Union staff',
            previousStatus: job.status,
            reason: reason.label,
            notes: notes,
            previousScheduledAt: job.scheduledAt,
            newScheduledAt: newScheduledAt,
            previousTractorId: job.tractor.id,
            newTractorId: tractor.id,
            previousOperatorName: job.operator.name,
            newOperatorName: operator.name,
          ),
        ],
      ),
    );
  }

  void recordOperatorProblem({
    required String jobId,
    required String reason,
    required String notes,
  }) {
    final job = jobById(jobId);
    _replaceJob(
      jobId,
      job.copyWith(
        alert: 'Operator reported: $reason',
        history: [
          ...job.history,
          _history(
            action: JobHistoryAction.operatorProblemReported,
            changedBy: job.operator.name,
            previousStatus: job.status,
            reason: reason,
            notes: notes,
          ),
        ],
      ),
    );
  }

  Future<void> flagJob({
    required String jobId,
    required String reason,
  }) async {
    if (await _tryRemoteJobUpdate(
      () => mobileApiClient.flagJob(
        token: _accessToken!,
        jobId: jobId,
        reason: reason,
      ),
    )) {
      return;
    }
    final job = jobById(jobId);
    _replaceJob(jobId, job.copyWith(status: JobStatus.flagged, alert: reason));
  }

  Future<void> unflagJob({
    required String jobId,
    required String note,
  }) async {
    if (await _tryRemoteJobUpdate(
      () => mobileApiClient.unflagJob(
        token: _accessToken!,
        jobId: jobId,
        note: note,
      ),
    )) {
      return;
    }
    final job = jobById(jobId);
    _replaceJob(jobId, job.copyWith(status: JobStatus.dispatched));
  }

  Future<void> refreshJobVerification(String jobId) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) return;
    try {
      _mechanizationActionError = null;
      await mobileApiClient.refreshVerification(token: token, jobId: jobId);
      notifyListeners();
    } on KwanzaTrackApiException catch (error) {
      _mechanizationActionError = error.message;
      notifyListeners();
    }
  }

  Future<void> verifyJob({
    required String jobId,
    required num verifiedAcres,
    String? note,
  }) async {
    await _tryRemoteJobUpdate(
      () => mobileApiClient.verifyJob(
        token: _accessToken!,
        jobId: jobId,
        verifiedAcres: verifiedAcres,
        note: note,
      ),
    );
  }

  Future<void> confirmJob({
    required String jobId,
    int rating = 5,
    String? note,
    bool? dispute,
  }) async {
    await _tryRemoteJobUpdate(
      () => mobileApiClient.confirmJob(
        token: _accessToken!,
        jobId: jobId,
        rating: rating,
        note: note,
        dispute: dispute,
      ),
    );
  }

  Future<void> refreshOversightData() async {
    final token = _accessToken;
    if (token == null || token.isEmpty) return;
    try {
      _mechanizationActionError = null;
      final responses = await Future.wait<Map<String, Object?>>([
        mobileApiClient.overrides(token: token),
        mobileApiClient.exceptions(token: token),
      ]);
      _applyOverridesResponse(responses[0]);
      _applyExceptionsResponse(responses[1]);
      notifyListeners();
    } on KwanzaTrackApiException catch (error) {
      _mechanizationActionError = error.message;
      notifyListeners();
    }
  }

  Future<void> decideOverride({
    required String overrideId,
    required bool approve,
    required String note,
  }) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) return;
    try {
      _mechanizationActionError = null;
      await mobileApiClient.decideOverride(
        token: token,
        overrideId: overrideId,
        approve: approve,
        note: note,
      );
      await refreshOversightData();
    } on KwanzaTrackApiException catch (error) {
      _mechanizationActionError = error.message;
      notifyListeners();
    }
  }

  Future<void> acknowledgeException(String exceptionId) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) return;
    try {
      _mechanizationActionError = null;
      await mobileApiClient.acknowledgeException(
        token: token,
        exceptionId: exceptionId,
      );
      await refreshOversightData();
    } on KwanzaTrackApiException catch (error) {
      _mechanizationActionError = error.message;
      notifyListeners();
    }
  }

  Future<void> resolveException({
    required String exceptionId,
    required String remarks,
    bool dismiss = false,
  }) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) return;
    try {
      _mechanizationActionError = null;
      await mobileApiClient.resolveException(
        token: token,
        exceptionId: exceptionId,
        remarks: remarks,
        dismiss: dismiss,
      );
      await refreshOversightData();
    } on KwanzaTrackApiException catch (error) {
      _mechanizationActionError = error.message;
      notifyListeners();
    }
  }

  void updateTractorStatus({
    required String tractorId,
    required TractorStatus status,
    String? note,
  }) {
    final index = _tractors.indexWhere((tractor) => tractor.id == tractorId);
    if (index == -1) return;
    _tractors[index] = _tractors[index].copyWith(status: status, note: note);
    notifyListeners();
  }

  void _applyMeResponse(Map<String, Object?> response) {
    final data = _dataMap(response);
    final user = _map(data['user']);
    _mechanizationUserName = user['name']?.toString();
  }

  void _applyRequestsResponse(
    Map<String, Object?> response, {
    bool replace = false,
  }) {
    final remoteRequests = _requestsFromResponse(response);
    if (replace) _requests.clear();
    for (final request in remoteRequests) {
      _upsertRequest(request);
    }
  }

  List<OperationsServiceRequest> _requestsFromResponse(
    Map<String, Object?> response,
  ) {
    return _dataList(response)
        .whereType<Map>()
        .map((item) => _requestFromJson(_stringKeyedMap(item)))
        .whereType<OperationsServiceRequest>()
        .toList();
  }

  Future<void> _refreshAllRequestBuckets(String token) async {
    const statuses = <String?>[
      null,
      'queue',
      'pending',
      'approved',
      'rejected',
      'returned',
      'cancelled',
      'canceled',
      'scheduled',
    ];
    final remoteRequests = <OperationsServiceRequest>[];
    KwanzaTrackApiException? firstError;

    for (final status in statuses) {
      try {
        final response = await mobileApiClient.requests(
          token: token,
          status: status,
        );
        remoteRequests.addAll(_requestsFromResponse(response));
      } on KwanzaTrackApiException catch (error) {
        firstError ??= error;
      }
    }

    if (remoteRequests.isEmpty && firstError != null) throw firstError;
    _requests.clear();
    for (final request in remoteRequests) {
      _upsertRequest(request);
    }
  }

  void _applyCalendarResponse(Map<String, Object?> response) {
    final events = _dataMap(response)['events'];
    if (events is! List) return;

    final remoteJobs = events
        .whereType<Map>()
        .map((event) => _jobFromCalendarEvent(_stringKeyedMap(event)))
        .whereType<OperationsJob>()
        .toList();
    if (remoteJobs.isEmpty) return;

    _jobs
      ..clear()
      ..addAll(remoteJobs);
    for (final job in remoteJobs) {
      _upsertOperator(job.operator);
    }
  }

  void _applyTractorsResponse(Map<String, Object?> response) {
    final tractors = _dataList(response)
        .whereType<Map>()
        .map((item) => _tractorFromJson(_stringKeyedMap(item)))
        .whereType<TractorAsset>()
        .toList();
    if (tractors.isEmpty) return;

    for (final tractor in tractors) {
      _removePlaceholderTractorsFor(tractor);
      _upsertTractor(tractor);
    }
  }

  void _applyOverridesResponse(Map<String, Object?> response) {
    final overrides = _dataList(response)
        .whereType<Map>()
        .map((item) => _overrideFromJson(_stringKeyedMap(item)))
        .whereType<MechanizationOverride>()
        .toList();
    _overrides
      ..clear()
      ..addAll(overrides);
  }

  void _applyExceptionsResponse(Map<String, Object?> response) {
    final exceptions = _dataList(response)
        .whereType<Map>()
        .map((item) => _exceptionFromJson(_stringKeyedMap(item)))
        .whereType<MechanizationException>()
        .toList();
    _exceptions
      ..clear()
      ..addAll(exceptions);
  }

  Future<bool> _tryRemoteJobUpdate(
    Future<Map<String, Object?>> Function() request,
  ) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) return false;
    try {
      _mechanizationActionError = null;
      final response = await request();
      final job = _jobFromJson(_dataMap(response));
      if (job != null) _upsertJob(job);
      notifyListeners();
      return true;
    } on KwanzaTrackApiException catch (error) {
      _mechanizationActionError = error.message;
      notifyListeners();
      return true;
    }
  }

  Future<bool> _tryRemoteRequestUpdate(
    Future<Map<String, Object?>> Function() request,
  ) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) return false;
    try {
      _mechanizationActionError = null;
      final response = await request();
      final remoteRequest = _requestFromJson(_dataMap(response));
      if (remoteRequest != null) _upsertRequest(remoteRequest);
      notifyListeners();
      return true;
    } on KwanzaTrackApiException catch (error) {
      _mechanizationActionError = error.message;
      notifyListeners();
      return true;
    }
  }

  Future<bool> _tryRemoteRequestSchedule({
    required String requestId,
    required String tractorId,
    required String operatorId,
    required DateTime scheduledAt,
    required int estimatedHours,
    required OperationsServiceRequest request,
  }) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) return false;
    try {
      _mechanizationActionError = null;
      final response = await mobileApiClient.scheduleRequest(
        token: token,
        requestId: requestId,
        scheduledDate: _dateOnly(scheduledAt),
        windowStart: _timeOnly(scheduledAt),
        windowEnd: _timeOnly(scheduledAt.add(Duration(hours: estimatedHours))),
        tractorId: tractorId,
        operatorId: operatorId,
        plannedAcres: request.plot.areaHectares / 0.404686,
        implement: 'Disc plough 3-furrow',
      );
      final job = _jobFromJson(_dataMap(response));
      if (job != null) _upsertJob(job);
      _replaceRequest(
        requestId,
        request.copyWith(status: OperationsRequestStatus.scheduled),
        notify: false,
      );
      notifyListeners();
      return true;
    } on KwanzaTrackApiException catch (error) {
      _mechanizationActionError = error.message;
      notifyListeners();
      return true;
    }
  }

  OperationsJob? _jobFromCalendarEvent(Map<String, Object?> event) {
    final id = _text(event, const ['id', 'job_id', 'reference']);
    if (id == null || id.isEmpty) return null;

    final start = _dateTime(event['start']) ?? DateTime.now();
    final end = _dateTime(event['end']);
    final estimatedHours = end == null
        ? 1
        : (end.difference(start).inMinutes / 60).ceil().clamp(1, 24).toInt();
    final acres = _number(event, const ['planned_acres', 'acres']);
    final plotLat = _number(event, const ['plot_lat', 'latitude']);
    final plotLng = _number(event, const ['plot_lng', 'longitude']);
    final tractorId =
        _text(event, const ['tractor', 'tractor_code', 'tractor_id']) ??
        'Unassigned';
    final operatorId =
        _text(event, const ['operator_id', 'operator']) ?? 'unassigned';
    final operatorName =
        _text(event, const ['operator', 'operator_name']) ?? 'Unassigned';
    final status = _jobStatus(event['status']?.toString());

    return OperationsJob(
      id: id,
      requestId: _text(event, const ['request_id', 'reference']) ?? id,
      farmerName: _text(event, const ['farmer', 'farmer_name']) ?? 'Farmer',
      serviceType: _serviceType(
        _text(event, const ['service_type_code', 'service_type', 'title']),
      ),
      plot: FarmPlot(
        id: _text(event, const ['plot_id', 'plot']) ?? 'plot-$id',
        name: _text(event, const ['plot', 'plot_name']) ?? 'Farm plot',
        areaHectares: acres == null ? 0 : acres.toDouble() * 0.404686,
        location: _text(event, const ['union', 'location']) ?? '',
        boundaryRegistered: event['geofence_verified'] == true,
        boundaryPoints: plotLat == null || plotLng == null
            ? const []
            : [
                BoundaryPoint(
                  label: 'Plot',
                  latitude: plotLat.toDouble(),
                  longitude: plotLng.toDouble(),
                ),
              ],
      ),
      tractor: TractorAsset(
        id: tractorId,
        model: tractorId,
        status: _tractorStatus(status),
        operatingHours: 0,
      ),
      operator: OperatorProfile(
        id: operatorId,
        name: operatorName,
        status: _operatorStatus(status),
      ),
      scheduledAt: start,
      estimatedHours: estimatedHours,
      status: status,
      startedAt: status == JobStatus.inProgress ? start : null,
      alert: event['geofence_verified'] == false
          ? 'Geofence not verified'
          : null,
    );
  }

  OperationsServiceRequest? _requestFromJson(Map<String, Object?> json) {
    final id = _text(json, const ['id', 'reference', 'external_ref']);
    if (id == null || id.isEmpty) return null;

    final farmerJson = _map(json['farmer']);
    final plotJson = _map(json['plot']);
    final serviceTypeJson = _map(json['service_type']);
    final centroid = _map(plotJson['centroid']);
    final areaHa = _number(plotJson, const ['area_ha']);
    final areaAcres = _number(plotJson, const ['area_acres']);
    final preferredDate =
        _dateTime(json['preferred_date']) ??
        _dateTime(json['scheduled_date']) ??
        DateTime.now();

    return OperationsServiceRequest(
      id: id,
      farmerName:
          _text(farmerJson, const ['name']) ??
          _text(json, const ['farmer_name']) ??
          'Farmer',
      farmerPhone: _text(farmerJson, const ['phone']),
      serviceType: _serviceType(
        _text(serviceTypeJson, const ['code', 'name']) ??
            _text(json, const ['service_type']),
      ),
      plot: FarmPlot(
        id: _text(plotJson, const ['id', 'external_ref']) ?? 'plot-$id',
        name: _text(plotJson, const ['name']) ?? 'Farm plot',
        areaHectares:
            areaHa?.toDouble() ??
            (areaAcres == null ? 0 : (areaAcres * 0.404686).toDouble()),
        location: [
          _text(farmerJson, const ['village']),
          _text(farmerJson, const ['ward']),
          _text(farmerJson, const ['district']),
          _text(farmerJson, const ['region']),
        ].whereType<String>().join(', '),
        boundaryRegistered: _asBool(plotJson['mapped']) ?? false,
        boundaryPoints:
            _number(centroid, const ['latitude']) == null ||
                _number(centroid, const ['longitude']) == null
            ? const []
            : [
                BoundaryPoint(
                  label: 'Centroid',
                  latitude: _number(centroid, const ['latitude'])!.toDouble(),
                  longitude: _number(centroid, const ['longitude'])!.toDouble(),
                ),
              ],
      ),
      preferredDate: preferredDate,
      status: _requestStatus(json['status']?.toString()),
      notes: _text(json, const ['notes', 'note']),
      rejectionReason: _text(json, const [
        'review_note',
        'reject_reason',
        'return_reason',
        'cancel_reason',
        'reason',
      ]),
      rejectionNotes: _text(json, const [
        'review_note',
        'reject_note',
        'return_note',
        'cancel_note',
      ]),
    );
  }

  OperationsJob? _jobFromJson(Map<String, Object?> json) {
    final id = _text(json, const ['id', 'reference']);
    if (id == null || id.isEmpty) return null;

    final tractorJson = _map(json['tractor']);
    final operatorJson = _map(json['operator']);
    final farmerJson = _map(json['farmer']);
    final plotJson = _map(json['plot']);
    final serviceTypeJson = _map(json['service_type']);
    final requestJson = _map(json['request']);
    final status = _jobStatus(json['status']?.toString());
    final scheduledAt = _dateTimeFromParts(
          json['scheduled_date'],
          json['window_start'],
        ) ??
        _dateTime(json['scheduled_at']) ??
        DateTime.now();
    final windowEnd = _dateTimeFromParts(
      json['scheduled_date'],
      json['window_end'],
    );
    final estimatedHours = windowEnd == null
        ? 1
        : windowEnd.difference(scheduledAt).inMinutes ~/ 60;
    final centroid = _map(plotJson['centroid']);
    final areaHa = _number(plotJson, const ['area_ha']);
    final areaAcres = _number(plotJson, const ['area_acres']);

    final tractorId =
        _text(tractorJson, const ['id', 'asset_no', 'label']) ?? 'Unassigned';
    final operatorId =
        _text(operatorJson, const ['id', 'name']) ?? 'unassigned';

    return OperationsJob(
      id: id,
      requestId:
          _text(requestJson, const ['id', 'reference', 'external_ref']) ?? id,
      farmerName:
          _text(farmerJson, const ['name']) ??
          _text(json, const ['farmer_name']) ??
          'Farmer',
      serviceType: _serviceType(
        _text(serviceTypeJson, const ['code', 'name']) ??
            _text(json, const ['service_type']),
      ),
      plot: FarmPlot(
        id: _text(plotJson, const ['id', 'external_ref']) ?? 'plot-$id',
        name: _text(plotJson, const ['name']) ?? 'Farm plot',
        areaHectares:
            areaHa?.toDouble() ??
            (areaAcres == null ? 0 : (areaAcres * 0.404686).toDouble()),
        location: [
          _text(plotJson, const ['village']),
          _text(plotJson, const ['ward']),
          _text(plotJson, const ['district']),
          _text(plotJson, const ['region']),
        ].whereType<String>().join(', '),
        boundaryRegistered: _asBool(plotJson['mapped']) ?? false,
        boundaryPoints:
            _number(centroid, const ['latitude']) == null ||
                _number(centroid, const ['longitude']) == null
            ? const []
            : [
                BoundaryPoint(
                  label: 'Centroid',
                  latitude: _number(centroid, const ['latitude'])!.toDouble(),
                  longitude: _number(centroid, const ['longitude'])!.toDouble(),
                ),
              ],
      ),
      tractor: TractorAsset(
        id: tractorId,
        assetNo: _text(tractorJson, const ['asset_no']),
        label: _text(tractorJson, const ['label']),
        model: _text(tractorJson, const ['label', 'asset_no']) ?? tractorId,
        status: _tractorStatus(status),
        operatingHours: _asInt(json['start_hour_meter']) ??
            _asInt(json['end_hour_meter']) ??
            0,
      ),
      operator: OperatorProfile(
        id: operatorId,
        name: _text(operatorJson, const ['name']) ?? 'Unassigned',
        status: _operatorStatus(status),
        note: _text(operatorJson, const ['phone']),
      ),
      scheduledAt: scheduledAt,
      estimatedHours: estimatedHours.clamp(1, 24).toInt(),
      status: status,
      startedAt: _dateTime(json['started_at']),
      completedAt: _dateTime(json['completed_at']),
      alert:
          _text(json, const ['flag_reason', 'cancel_reason', 'dispute_note']) ??
          (_asBool(json['geofence_verified']) == false
              ? 'Geofence not verified'
              : null),
    );
  }

  MechanizationOverride? _overrideFromJson(Map<String, Object?> json) {
    final id = _text(json, const ['id']);
    if (id == null || id.isEmpty) return null;
    final evidence = _map(json['evidence']);
    final phone = _map(evidence['phone']);
    return MechanizationOverride(
      id: id,
      jobId: _text(json, const ['job_id']) ?? '',
      status: _text(json, const ['status']) ?? 'pending',
      reason: _text(json, const ['reason']) ?? 'Override requested',
      requestedBy: _text(json, const ['requested_by']) ?? 'Operator',
      requestedAt: _dateTime(json['requested_at']),
      decidedBy: _text(json, const ['decided_by']),
      decidedAt: _dateTime(json['decided_at']),
      decisionNote: _text(json, const ['decision_note']),
      expiresAt: _dateTime(json['expires_at']),
      usable: _asBool(json['usable']) ?? false,
      failedChecks: _stringList(evidence['failed']),
      distanceToPlotMeters: _number(phone, const ['distance_to_plot_m']),
      distanceToTractorMeters: _number(phone, const ['distance_to_tractor_m']),
    );
  }

  MechanizationException? _exceptionFromJson(Map<String, Object?> json) {
    final id = _text(json, const ['id']);
    if (id == null || id.isEmpty) return null;
    final job = _map(json['job']);
    final tractor = _map(json['tractor']);
    return MechanizationException(
      id: id,
      title:
          _text(json, const ['title', 'message', 'summary']) ??
          'Mechanization exception',
      status: _text(json, const ['status']) ?? 'open',
      severity: _text(json, const ['severity', 'level']) ?? 'info',
      type: _text(json, const ['type', 'code']),
      jobReference:
          _text(json, const ['job_reference']) ??
          _text(job, const ['reference', 'id']),
      tractorLabel:
          _text(json, const ['tractor_label']) ??
          _text(tractor, const ['label', 'asset_no']),
      detail: _text(json, const ['detail', 'reason', 'note']),
      openedAt: _dateTime(json['opened_at']) ?? _dateTime(json['created_at']),
    );
  }

  TractorAsset? _tractorFromJson(Map<String, Object?> json) {
    final id = _text(json, const ['id']);
    if (id == null || id.isEmpty) return null;

    final assetNo = _text(json, const ['asset_no', 'assetNo']);
    final make = _text(json, const ['make']);
    final model = _text(json, const ['model', 'label']) ?? assetNo ?? id;
    final live = _map(json['live']);
    final operators = json['operators'] is List
        ? (json['operators'] as List)
              .whereType<Map>()
              .map((item) => _text(_stringKeyedMap(item), const ['name', 'id']))
              .whereType<String>()
              .toList()
        : const <String>[];
    final union = _map(json['union']);
    final maintenanceDue = json['maintenance_due'] is List
        ? (json['maintenance_due'] as List)
              .map((item) => item.toString())
              .toList()
        : const <String>[];

    return TractorAsset(
      id: id,
      assetNo: assetNo,
      label: _text(json, const ['label']),
      make: make,
      model: make == null ? model : '$make $model',
      year: _asInt(json['year']),
      horsepower: _asInt(json['horsepower']),
      registrationNo: _text(json, const ['registration_no']),
      ownership: _text(json, const ['ownership']),
      station: _text(json, const ['station']),
      status: _tractorAssetStatus(json['status']?.toString()),
      condition: _text(json, const ['condition']),
      operatingHours: _asInt(json['hour_meter']) ?? 0,
      implementNames: _stringList(json['implements']),
      unionName: union['name']?.toString(),
      online: _asBool(json['online']) ?? _asBool(live['online']),
      qrToken: _text(json, const ['qr_token']),
      inspectedToday: _asBool(json['inspected_today']),
      assignedOperators: operators,
      maintenanceDue: maintenanceDue,
      note: _tractorNote(json),
    );
  }

  void _upsertTractor(TractorAsset tractor) {
    final index = _tractors.indexWhere((item) => item.id == tractor.id);
    if (index == -1) {
      _tractors.add(tractor);
    } else {
      _tractors[index] = _mergeTractor(_tractors[index], tractor);
    }
  }

  void _upsertRequest(OperationsServiceRequest request) {
    final index = _requests.indexWhere((item) => item.id == request.id);
    if (index == -1) {
      _requests.insert(0, request);
    } else {
      _requests[index] = request;
    }
  }

  void _upsertJob(OperationsJob job) {
    final index = _jobs.indexWhere((item) => item.id == job.id);
    if (index == -1) {
      _jobs.insert(0, job);
    } else {
      _jobs[index] = job;
    }
    _upsertOperator(job.operator);
  }

  void _removePlaceholderTractorsFor(TractorAsset tractor) {
    final assetNo = tractor.assetNo?.trim();
    if (assetNo == null || assetNo.isEmpty) return;
    _tractors.removeWhere(
      (item) =>
          item.id != tractor.id &&
          item.id == assetNo &&
          item.assetNo == null &&
          item.label == null &&
          item.registrationNo == null &&
          item.operatingHours == 0,
    );
  }

  TractorAsset _mergeTractor(TractorAsset current, TractorAsset incoming) {
    return current.copyWith(
      id: incoming.id,
      model: incoming.model,
      status: incoming.status,
      operatingHours: incoming.operatingHours,
      assetNo: incoming.assetNo,
      label: incoming.label,
      make: incoming.make,
      year: incoming.year,
      horsepower: incoming.horsepower,
      registrationNo: incoming.registrationNo,
      ownership: incoming.ownership,
      station: incoming.station,
      condition: incoming.condition,
      implementNames: incoming.implementNames,
      unionName: incoming.unionName,
      online: incoming.online,
      qrToken: incoming.qrToken,
      inspectedToday: incoming.inspectedToday,
      assignedOperators: incoming.assignedOperators,
      maintenanceDue: incoming.maintenanceDue,
      note: incoming.note,
    );
  }

  void _upsertOperator(OperatorProfile operator) {
    final index = _operators.indexWhere((item) => item.id == operator.id);
    if (index == -1) {
      _operators.add(operator);
    } else {
      _operators[index] = operator;
    }
  }

  int? _dashboardInt(List<String> keys) {
    for (final key in keys) {
      final value = _findValue(_dashboardData, key);
      final parsed = _asInt(value);
      if (parsed != null) return parsed;
    }
    return null;
  }

  Object? _findValue(Object? value, String key) {
    if (value is Map) {
      if (value.containsKey(key)) return value[key];
      for (final entry in value.entries) {
        final found = _findValue(entry.value, key);
        if (found != null) return found;
      }
    }
    if (value is List) {
      for (final item in value) {
        final found = _findValue(item, key);
        if (found != null) return found;
      }
    }
    return null;
  }

  Map<String, Object?> _dataMap(Map<String, Object?> response) {
    return _map(response['data']);
  }

  List<Object?> _dataList(Map<String, Object?> response) {
    final data = response['data'];
    if (data is List) return data;
    return const [];
  }

  int? _metaCount(Map<String, Object?> response) {
    return _asInt(_map(response['meta'])['count']);
  }

  Map<String, Object?> _map(Object? value) {
    if (value is Map) return _stringKeyedMap(value);
    return const {};
  }

  Map<String, Object?> _stringKeyedMap(Map<dynamic, dynamic> value) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  String? _text(Map<String, Object?> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty && text != 'null') return text;
    }
    return null;
  }

  num? _number(Map<String, Object?> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is num) return value;
      final parsed = num.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
  }

  int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  bool? _asBool(Object? value) {
    if (value is bool) return value;
    final text = value?.toString().toLowerCase();
    if (text == 'true' || text == '1') return true;
    if (text == 'false' || text == '0') return false;
    return null;
  }

  List<String> _stringList(Object? value) {
    if (value is List) return value.map((item) => item.toString()).toList();
    return const [];
  }

  List<String> _availabilityItems(Object? value) {
    if (value is! List) return const [];
    return value.map((item) {
      if (item is Map) {
        final map = _stringKeyedMap(item);
        return _text(map, const [
              'reference',
              'label',
              'name',
              'status',
              'id',
            ]) ??
            item.toString();
      }
      return item.toString();
    }).toList();
  }

  DateTime? _dateTime(Object? value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  ServiceType _serviceType(String? value) {
    final normalized = value?.toLowerCase() ?? '';
    if (normalized.contains('harrow')) return ServiceType.harrowing;
    if (normalized.contains('plant')) return ServiceType.planting;
    return ServiceType.ploughing;
  }

  OperationsRequestStatus _requestStatus(String? value) {
    final normalized = value?.toLowerCase().replaceAll('-', '_') ?? '';
    return switch (normalized) {
      'approved' => OperationsRequestStatus.approved,
      'rejected' || 'declined' => OperationsRequestStatus.rejected,
      'returned' || 'returned_to_farmer' => OperationsRequestStatus.returned,
      'scheduled' || 'dispatched' || 'in_progress' =>
        OperationsRequestStatus.scheduled,
      'cancelled' || 'canceled' => OperationsRequestStatus.cancelled,
      _ => OperationsRequestStatus.pending,
    };
  }

  JobStatus _jobStatus(String? value) {
    final normalized = value?.toLowerCase().replaceAll('-', '_') ?? '';
    return switch (normalized) {
      'scheduled' => JobStatus.scheduled,
      'dispatched' => JobStatus.dispatched,
      'en_route' || 'accepted' => JobStatus.enRoute,
      'arrived' => JobStatus.arrived,
      'in_progress' || 'started' || 'working' => JobStatus.inProgress,
      'completed' || 'awaiting_verification' || 'verified' =>
        JobStatus.completedPendingConfirmation,
      'flagged' => JobStatus.flagged,
      'closed' || 'confirmed' => JobStatus.closed,
      'cancelled' || 'canceled' => JobStatus.cancelled,
      _ => JobStatus.scheduled,
    };
  }

  TractorStatus _tractorStatus(JobStatus status) {
    return switch (status) {
      JobStatus.cancelled || JobStatus.closed => TractorStatus.available,
      _ => TractorStatus.scheduled,
    };
  }

  TractorStatus _tractorAssetStatus(String? value) {
    final normalized = value?.toLowerCase().replaceAll('-', '_') ?? '';
    return switch (normalized) {
      'available' || 'active' || 'ready' => TractorStatus.available,
      'scheduled' || 'assigned' || 'busy' || 'in_use' =>
        TractorStatus.scheduled,
      'maintenance' || 'under_maintenance' || 'repair' =>
        TractorStatus.underMaintenance,
      'out_of_service' || 'inactive' || 'disabled' => TractorStatus.outOfService,
      _ => TractorStatus.available,
    };
  }

  String? _tractorNote(Map<String, Object?> json) {
    final pieces = [
      _text(json, const ['station']),
      _text(json, const ['condition']),
      _asBool(json['online']) == true ? 'Online' : null,
    ].whereType<String>().toList();
    return pieces.isEmpty ? null : pieces.join(' - ');
  }

  OperatorStatus _operatorStatus(JobStatus status) {
    return switch (status) {
      JobStatus.cancelled || JobStatus.closed => OperatorStatus.available,
      _ => OperatorStatus.assigned,
    };
  }

  String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  String _timeOnly(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  DateTime? _dateTimeFromParts(Object? dateValue, Object? timeValue) {
    final date = dateValue?.toString();
    final time = timeValue?.toString();
    if (date == null || date.isEmpty) return null;
    if (time == null || time.isEmpty) return DateTime.tryParse(date);
    return DateTime.tryParse('${date}T$time:00');
  }

  void _replaceRequest(
    String id,
    OperationsServiceRequest updated, {
    bool notify = true,
  }) {
    final index = _requests.indexWhere((request) => request.id == id);
    if (index == -1) return;
    _requests[index] = updated;
    if (notify) notifyListeners();
  }

  void _replaceJob(String id, OperationsJob updated) {
    final index = _jobs.indexWhere((job) => job.id == id);
    if (index == -1) return;
    _jobs[index] = updated;
    notifyListeners();
  }

  static JobHistoryEntry _history({
    required JobHistoryAction action,
    required String changedBy,
    JobStatus? previousStatus,
    String? reason,
    String? notes,
    DateTime? previousScheduledAt,
    DateTime? newScheduledAt,
    String? previousTractorId,
    String? newTractorId,
    String? previousOperatorName,
    String? newOperatorName,
  }) {
    return JobHistoryEntry(
      id: const Uuid().v4(),
      action: action,
      changedBy: changedBy,
      changedAt: DateTime.now(),
      previousStatus: previousStatus,
      reason: reason,
      notes: notes,
      previousScheduledAt: previousScheduledAt,
      newScheduledAt: newScheduledAt,
      previousTractorId: previousTractorId,
      newTractorId: newTractorId,
      previousOperatorName: previousOperatorName,
      newOperatorName: newOperatorName,
    );
  }

  static List<OperationsServiceRequest> _seedRequests() {
    return [];
  }

  static List<TractorAsset> _seedTractors() {
    return [];
  }

  static List<OperatorProfile> _seedOperators() {
    return [];
  }

  static List<OperationsJob> _seedJobs() {
    return [];
  }
}
