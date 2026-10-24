import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/kwanza_track_mobile_api_client.dart';
import '../../../../core/network/mechanization_data.dart';
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
       _requests = [],
       _tractors = [],
       _operators = [],
       _jobs = [];

  final ServiceOrdersRemoteDataSource remoteDataSource;
  final KwanzaTrackMobileApiClient mobileApiClient;
  final Map<String, Map<String, Object?>> _jobPayloads = {};
  final Map<String, Map<String, Object?>> _requestPayloads = {};
  Set<String>? _permissions;
  Map<String, Object?> _policy = {};
  int _dataVersion = 0;
  bool _hasLoadedMechanization = false;
  bool _disposed = false;
  int _sessionVersion = 0;
  final List<OperationsServiceRequest> _requests;
  final List<TractorAsset> _tractors;
  final List<OperatorProfile> _operators;
  final List<RegistryFarmer> _farmers = [];
  final List<OperationsJob> _jobs;
  final List<OperationsJob> _calendarJobs = [];
  final List<MechanizationOverride> _overrides = [];
  final List<MechanizationException> _exceptions = [];
  String? _accessToken;
  bool _isSyncingMechanization = false;
  bool _isRefreshingTractors = false;
  bool _isRefreshingOperators = false;
  bool _isRefreshingFarmers = false;
  String? _mechanizationSyncError;
  String? _mechanizationActionError;
  String? _mechanizationUserName;
  String? _mechanizationUserEmail;
  String? _mechanizationUserRole;
  Map<String, Object?> _dashboardData = const {};
  int? _remoteBacklogCount;
  int _syncGeneration = 0;
  String? _lastScheduledJobId;

  bool can(String permission) => _permissions?.contains(permission) ?? true;
  bool get requiresFarmerConfirmation =>
      _policy['require_farmer_confirmation'] != false;
  bool _currentSession(String token, int version) =>
      !_disposed && _accessToken == token && _sessionVersion == version;

  Future<Map<String, Object?>> _loadModule(
    Future<Map<String, Object?>> Function() read, {
    String? permission,
  }) async {
    if (permission != null && !can(permission)) return {'data': <Object?>[]};
    try {
      return await read();
    } on KwanzaTrackApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 419) rethrow;
      return {'data': <Object?>[], '_load_error': error.message};
    }
  }

  List<OperationsServiceRequest> get requests => List.unmodifiable(_requests);
  List<TractorAsset> get tractors => List.unmodifiable(_tractors);
  List<OperatorProfile> get operators => List.unmodifiable(_operators);
  List<RegistryFarmer> get farmers => List.unmodifiable(_farmers);
  List<OperationsJob> get jobs => List.unmodifiable(_jobs);
  List<OperationsJob> get scheduleJobs => List.unmodifiable(_calendarJobs);
  List<MechanizationOverride> get overrides => List.unmodifiable(_overrides);
  List<MechanizationException> get exceptions => List.unmodifiable(_exceptions);
  bool get isInitialMechanizationLoad =>
      _isSyncingMechanization && !_hasLoadedMechanization;
  bool get isSyncingMechanization => _isSyncingMechanization;
  bool get isRefreshingTractors => _isRefreshingTractors;
  bool get isRefreshingOperators => _isRefreshingOperators;
  bool get isRefreshingFarmers => _isRefreshingFarmers;

  OperationsJob? jobForRequest(String requestId) {
    for (final job in _jobs) {
      if (job.requestId == requestId) return job;
    }
    return null;
  }

  String? get mechanizationSyncError => _mechanizationSyncError;
  String? get mechanizationActionError => _mechanizationActionError;
  String? get mechanizationUserName => _mechanizationUserName;
  String? get mechanizationUserEmail => _mechanizationUserEmail;
  String? get mechanizationUserRole => _mechanizationUserRole;
  bool get hasMechanizationToken =>
      _accessToken != null && _accessToken!.isNotEmpty;

  Future<ServiceOrdersFetchResult> fetchRemoteServiceOrders() {
    return remoteDataSource.fetchServiceOrders();
  }

  void setMechanizationAccessToken(String? token, {List<String>? permissions}) {
    final trimmed = token?.trim();
    final normalized = trimmed == null || trimmed.isEmpty ? null : trimmed;
    if (permissions != null) _permissions = permissions.toSet();
    if (_accessToken == normalized) return;
    _sessionVersion++;
    _syncGeneration++;
    _isSyncingMechanization = false;
    _hasLoadedMechanization = false;
    _isRefreshingTractors = false;
    _isRefreshingOperators = false;
    _isRefreshingFarmers = false;
    _mechanizationActionError = null;
    _jobPayloads.clear();
    _dataVersion++;
    _requestPayloads.clear();
    _policy = {};
    _dashboardData = {};
    _remoteBacklogCount = null;
    _accessToken = normalized?.isEmpty == true ? null : normalized;
    _mechanizationSyncError = null;
    _requests.clear();
    _tractors.clear();
    _operators.clear();
    _farmers.clear();
    _jobs.clear();
    _calendarJobs.clear();
    _overrides.clear();
    _exceptions.clear();
    if (_accessToken == null) {
      _permissions = null;
      _mechanizationUserName = null;
      _mechanizationUserEmail = null;
      _mechanizationUserRole = null;
      _dashboardData = const {};
      _remoteBacklogCount = null;
      notifyListeners();
      return;
    }
    refreshMechanizationData();
  }

  Future<void> refreshMechanizationData() async {
    final token = _accessToken;
    final session = _sessionVersion;
    if (token == null || token.isEmpty || _isSyncingMechanization) return;

    final dataVersion = _dataVersion;
    final generation = ++_syncGeneration;
    _isSyncingMechanization = true;
    _mechanizationSyncError = null;
    _mechanizationActionError = null;
    notifyListeners();

    try {
      final today = DateTime.now();
      final from = _dateOnly(today.subtract(const Duration(days: 365)));
      final to = _dateOnly(today.add(const Duration(days: 365)));
      final responses = await Future.wait<Map<String, Object?>>([
        mobileApiClient.me(token: token),
        _loadModule(() => mobileApiClient.dashboard(token: token, days: 30)),
        _loadModule(
          () => allApiPages(
            (page) => mobileApiClient.jobs(
              token: token,
              mine: false,
              perPage: 50,
              page: page,
            ),
            isCurrent: () => _currentSession(token, session),
          ),
        ),
        _loadModule(
          () => mobileApiClient.calendar(
            token: token,
            from: from,
            to: to,
            mine: false,
            status:
                'scheduled,dispatched,en_route,arrived,in_progress,paused,completed,verified,flagged,closed,cancelled',
          ),
        ),
        _loadModule(
          () => mobileApiClient.calendarBacklog(token: token),
          permission: 'mech.jobs.manage',
        ),
        _loadModule(() => _loadAllRequests(token)),
        _loadModule(
          () => mobileApiClient.tractors(token: token, mine: true, live: true),
        ),
        _loadModule(() => mobileApiClient.tractors(token: token, mine: false)),
        _loadModule(() => mobileApiClient.operators(token: token)),
        _loadModule(() => mobileApiClient.overrides(token: token)),
        _loadModule(() => mobileApiClient.exceptions(token: token)),
        _loadModule(
          () => allApiPages(
            (page) => mobileApiClient.farmers(token: token, page: page),
            isCurrent: () => _currentSession(token, session),
          ),
        ),
      ]);
      if (!_currentSession(token, session) || dataVersion != _dataVersion) {
        return;
      }
      if (generation != _syncGeneration) return;

      _applyMeResponse(responses[0]);
      if (!responses[1].containsKey('_load_error')) {
        _dashboardData = _dataMap(responses[1]);
      }
      _applyJobsResponse(responses[2]);
      if (!responses[4].containsKey('_load_error')) {
        _remoteBacklogCount =
            _metaCount(responses[4]) ?? _dataList(responses[4]).length;
      }
      _applyRequestsResponse(responses[5], replace: true);
      // Request list above already includes every status and page;
      await _enrichRequestBoundaries(token);
      if (!_currentSession(token, session) || dataVersion != _dataVersion) {
        return;
      }
      _applyTractorsResponse(responses[7], replace: true, source: 'all');
      _applyTractorsResponse(responses[6]);
      _applyOperatorsResponse(responses[8]);
      _applyCalendarResponse(responses[3]);
      _applyOverridesResponse(responses[9]);
      _applyExceptionsResponse(responses[10]);
      _applyFarmersResponse(responses[11]);
      final moduleErrors = responses
          .map((item) => item['_load_error'])
          .whereType<String>()
          .toSet();
      _mechanizationSyncError = moduleErrors.isEmpty
          ? null
          : moduleErrors.join('\n');
    } on KwanzaTrackApiException catch (error) {
      if (!_currentSession(token, session) || dataVersion != _dataVersion) {
        return;
      }
      if (generation == _syncGeneration) {
        _mechanizationSyncError = error.message;
      }
    } catch (error) {
      if (!_currentSession(token, session) || dataVersion != _dataVersion) {
        return;
      }
      if (generation == _syncGeneration) {
        _mechanizationSyncError =
            'Could not refresh mechanization data: $error';
      }
    } finally {
      if (generation == _syncGeneration) {
        _hasLoadedMechanization = true;
        _isSyncingMechanization = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshTractors() async {
    final token = _accessToken;
    final session = _sessionVersion;
    if (token == null ||
        token.isEmpty ||
        _isSyncingMechanization ||
        _isRefreshingTractors) {
      return;
    }
    _isRefreshingTractors = true;
    _mechanizationSyncError = null;
    notifyListeners();
    try {
      final responses = await Future.wait<Map<String, Object?>>([
        mobileApiClient.tractors(token: token, mine: false),
        mobileApiClient.tractors(token: token, mine: true, live: true),
      ]);
      if (!_currentSession(token, session)) return;
      _applyTractorsResponse(responses[0], replace: true, source: 'all');
      _applyTractorsResponse(responses[1]);
    } on KwanzaTrackApiException catch (error) {
      if (!_currentSession(token, session)) return;
      _mechanizationSyncError = error.message;
    } catch (error) {
      if (!_currentSession(token, session)) return;
      _mechanizationSyncError = 'Could not refresh tractors: $error';
    } finally {
      if (_currentSession(token, session)) {
        _isRefreshingTractors = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshOperators() async {
    final token = _accessToken;
    final session = _sessionVersion;
    if (token == null ||
        token.isEmpty ||
        _isSyncingMechanization ||
        _isRefreshingOperators) {
      return;
    }
    _isRefreshingOperators = true;
    _mechanizationSyncError = null;
    notifyListeners();
    try {
      final response = await mobileApiClient.operators(token: token);
      if (!_currentSession(token, session)) return;
      _applyOperatorsResponse(response);
    } on KwanzaTrackApiException catch (error) {
      if (!_currentSession(token, session)) return;
      _mechanizationSyncError = error.message;
    } catch (error) {
      if (!_currentSession(token, session)) return;
      _mechanizationSyncError = 'Could not refresh operators: $error';
    } finally {
      if (_currentSession(token, session)) {
        _isRefreshingOperators = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshFarmers() async {
    final token = _accessToken;
    final session = _sessionVersion;
    if (token == null ||
        token.isEmpty ||
        _isSyncingMechanization ||
        _isRefreshingFarmers) {
      return;
    }
    _isRefreshingFarmers = true;
    _mechanizationSyncError = null;
    notifyListeners();
    try {
      final response = await allApiPages(
        (page) => mobileApiClient.farmers(token: token, page: page),
        isCurrent: () => _currentSession(token, session),
      );
      if (!_currentSession(token, session)) return;
      _applyFarmersResponse(response);
    } on KwanzaTrackApiException catch (error) {
      if (!_currentSession(token, session)) return;
      _mechanizationSyncError = error.message;
    } catch (error) {
      if (!_currentSession(token, session)) return;
      _mechanizationSyncError = 'Could not refresh farmers: $error';
    } finally {
      if (_currentSession(token, session)) {
        _isRefreshingFarmers = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshTractorDetails(String tractorId) async {
    final token = _accessToken;
    final session = _sessionVersion;
    if (token == null || token.isEmpty) return;

    try {
      final responses = await Future.wait<Map<String, Object?>>([
        mobileApiClient.tractor(token: token, tractorId: tractorId),
        mobileApiClient.inspectionToday(token: token, tractorId: tractorId),
      ]);
      if (!_currentSession(token, session)) return;
      final tractor = _tractorFromJson(_dataMap(responses[0]));
      if (tractor != null) _upsertTractor(tractor);

      final inspectedToday =
          responses[1]['success'] == true && _dataMap(responses[1]).isNotEmpty;
      final index = _tractors.indexWhere((item) => item.id == tractorId);
      if (index != -1) {
        _tractors[index] = _tractors[index].copyWith(
          inspectedToday:
              inspectedToday || (_tractors[index].inspectedToday == true),
        );
      }
      notifyListeners();
    } on KwanzaTrackApiException catch (error) {
      if (!_currentSession(token, session)) return;
      _mechanizationSyncError = error.message;
      notifyListeners();
    }
  }

  Future<TractorAsset?> lookupTractorQr(String qrToken) async {
    final token = _accessToken;
    final session = _sessionVersion;
    if (token == null || token.isEmpty) return null;

    try {
      final response = await mobileApiClient.tractorQr(
        token: token,
        qrToken: qrToken,
      );
      if (!_currentSession(token, session)) return null;
      final tractor = _tractorFromJson(_dataMap(response));
      if (tractor != null) {
        _upsertTractor(tractor);
        notifyListeners();
      }
      return tractor;
    } on KwanzaTrackApiException catch (error) {
      if (!_currentSession(token, session)) return null;
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
              job.status == JobStatus.inProgress ||
              job.status == JobStatus.paused,
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
              job.status == JobStatus.verified ||
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

  OperationsServiceRequest? maybeRequestById(String id) {
    for (final request in _requests) {
      if (request.id == id) return request;
    }
    return null;
  }

  OperationsJob? maybeJobById(String id) {
    for (final job in _jobs) {
      if (job.id == id) return job;
    }
    return null;
  }

  OperationsServiceRequest requestById(String id) {
    return _requests.firstWhere((request) => request.id == id);
  }

  OperationsJob jobById(String id) {
    return _jobs.firstWhere((job) => job.id == id);
  }

  Future<void> refreshServiceRequests({String? status}) async {
    final token = _accessToken;
    final session = _sessionVersion;
    if (token == null || token.isEmpty) return;
    try {
      _mechanizationActionError = null;
      if (status == null) {
        await _refreshAllRequestBuckets(token);
        if (!_currentSession(token, session)) return;
      } else {
        final response = await mobileApiClient.requests(
          token: token,
          status: status,
        );
        if (!_currentSession(token, session)) return;
        _applyRequestsResponse(response, replace: true);
      }
      await _enrichRequestBoundaries(token);
      if (!_currentSession(token, session)) return;
      notifyListeners();
    } on KwanzaTrackApiException catch (error) {
      if (!_currentSession(token, session)) return;
      _mechanizationActionError = error.message;
      notifyListeners();
    }
  }

  Future<void> refreshRequestDetail(String id) async {
    final token = _accessToken;
    final session = _sessionVersion;
    final dataVersion = _dataVersion;
    if (token == null || token.isEmpty) return;
    try {
      _mechanizationActionError = null;
      final response = await mobileApiClient.request(
        token: token,
        requestId: id,
      );
      if (!_currentSession(token, session) || dataVersion != _dataVersion) {
        return;
      }
      final request = _requestFromJson(_dataMap(response));
      if (request != null) {
        _upsertRequest(request);
        await _enrichRequestBoundaries(token, requestIds: {request.id});
        if (!_currentSession(token, session) || dataVersion != _dataVersion) {
          return;
        }
      }
      notifyListeners();
    } on KwanzaTrackApiException catch (error) {
      if (!_currentSession(token, session) || dataVersion != _dataVersion) {
        return;
      }
      _mechanizationActionError = error.message;
      notifyListeners();
    }
  }

  Future<void> refreshJobDetail(String id) async {
    final token = _accessToken;
    final session = _sessionVersion;
    final dataVersion = _dataVersion;
    if (token == null || token.isEmpty) return;
    try {
      _mechanizationActionError = null;
      final response = await mobileApiClient.job(token: token, jobId: id);
      if (!_currentSession(token, session) || dataVersion != _dataVersion) {
        return;
      }
      final job = _jobFromResponse(response);
      if (job != null) _upsertJob(job);
      notifyListeners();
    } on KwanzaTrackApiException catch (error) {
      if (!_currentSession(token, session) || dataVersion != _dataVersion) {
        return;
      }
      _mechanizationActionError = error.message;
      notifyListeners();
    }
  }

  Future<List<Map<String, Object?>>> serviceTypeOptions() async {
    final token = _accessToken;
    final session = _sessionVersion;
    if (token == null) {
      throw const KwanzaTrackApiException('Please sign in again.');
    }
    final response = await mobileApiClient.serviceTypes(token: token);
    if (!_currentSession(token, session)) return [];
    return _dataList(response).whereType<Map>().map(_stringKeyedMap).toList();
  }

  Future<List<Map<String, Object?>>> farmerPlotOptions(String farmerId) async {
    final token = _accessToken;
    final session = _sessionVersion;
    if (token == null) {
      throw const KwanzaTrackApiException('Please sign in again.');
    }
    final response = await mobileApiClient.farmer(
      token: token,
      farmerId: farmerId,
    );
    if (!_currentSession(token, session)) return [];
    final plots = _dataMap(response)['plots'];
    return plots is List
        ? plots.whereType<Map>().map(_stringKeyedMap).toList()
        : [];
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
    if (!can('mech.requests.manage')) {
      _mechanizationActionError =
          'Your account does not have permission for this action.';
      notifyListeners();
      return;
    }
    final token = _accessToken;
    final session = _sessionVersion;
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
      if (!_currentSession(token, session)) return;
      _dataVersion++;
      final request = _requestFromJson(_dataMap(response));
      if (request != null) _upsertRequest(request);
      notifyListeners();
    } on KwanzaTrackApiException catch (error) {
      if (!_currentSession(token, session)) return;
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
    if (!can('mech.requests.manage')) {
      _mechanizationActionError =
          'Your account does not have permission for this action.';
      notifyListeners();
      return;
    }
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
    if (!can('mech.requests.manage')) {
      _mechanizationActionError =
          'Your account does not have permission for this action.';
      notifyListeners();
      return;
    }
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
    if (!can('mech.requests.manage')) {
      _mechanizationActionError =
          'Your account does not have permission for this action.';
      notifyListeners();
      return;
    }
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
    if (!can('mech.requests.manage')) {
      _mechanizationActionError =
          'Your account does not have permission for this action.';
      notifyListeners();
      return;
    }
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
    String? implement,
  }) async {
    if (!can('mech.jobs.manage')) {
      _mechanizationActionError = 'Your account cannot schedule jobs.';
      notifyListeners();
      return requestId;
    }
    final request = maybeRequestById(requestId);
    if (request == null) {
      _mechanizationActionError =
          'This request is no longer available. Refresh requests.';
      notifyListeners();
      return requestId;
    }
    _lastScheduledJobId = null;
    if (await _tryRemoteRequestSchedule(
      requestId: requestId,
      tractorId: tractorId,
      operatorId: operatorId,
      scheduledAt: scheduledAt,
      estimatedHours: estimatedHours,
      request: request,
      implement: implement,
    )) {
      return _lastScheduledJobId ?? requestId;
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
    DateTime? windowStart,
    Duration? duration,
    String? excludeJobId,
  }) async {
    final token = _accessToken;
    final session = _sessionVersion;
    if (token == null || token.isEmpty) return null;
    try {
      _mechanizationActionError = null;
      final response = await mobileApiClient.availability(
        token: token,
        date: _dateOnly(date),
        tractorId: tractorId,
        operatorId: operatorId,
        excludeJobId: excludeJobId,
      );
      if (!_currentSession(token, session)) return null;
      final data = _dataMap(response);
      final tractor = _windowConflicts(
        data['tractor'],
        windowStart,
        duration,
        excludeJobId,
      );
      final operator = _windowConflicts(
        data['operator'],
        windowStart,
        duration,
        excludeJobId,
      );
      final result = RequestAvailabilityResult(
        isAvailable: tractor.isEmpty && operator.isEmpty,
        tractorConflicts: tractor,
        operatorConflicts: operator,
        loadHours: _number(data, const ['load_hours']) ?? 0,
      );
      notifyListeners();
      return result;
    } on KwanzaTrackApiException catch (error) {
      if (!_currentSession(token, session)) return null;
      _mechanizationActionError = error.message;
      notifyListeners();
      return null;
    }
  }

  Future<void> dispatchJob(String jobId) async {
    if (!can('mech.jobs.manage')) {
      _mechanizationActionError =
          'Your account does not have permission for this action.';
      notifyListeners();
      return;
    }
    final job = maybeJobById(jobId);
    if (job == null) {
      _mechanizationActionError =
          'This job is no longer available. Refresh your jobs.';
      notifyListeners();
      return;
    }
    final tractorId = _registryTractorId(job.tractor);
    final operatorId = _registryOperatorId(job.operator);
    if (kDebugMode) {
      debugPrint(
        '[Dispatch] job=$jobId '
        'tractor=${job.tractor.id} resolved_tractor=$tractorId '
        'operator=${job.operator.id} resolved_operator=$operatorId',
      );
    }
    if (!_isUuid(tractorId) || !_isUuid(operatorId)) {
      _mechanizationActionError = !_isUuid(tractorId)
          ? 'The assigned tractor could not be matched to its registry ID. '
                'Refresh Tractors and Jobs, then try dispatching again.'
          : 'The assigned operator could not be matched to their registry ID. '
                'Refresh Operators and Jobs, then try dispatching again.';
      notifyListeners();
      return;
    }
    if (await _tryRemoteJobUpdate(
      () => mobileApiClient.dispatchJob(
        token: _accessToken!,
        jobId: jobId,
        tractorId: tractorId,
        operatorId: operatorId,
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

  String _registryTractorId(TractorAsset assigned) {
    if (_isUuid(assigned.id)) return assigned.id;
    for (final tractor in _tractors) {
      final matches =
          tractor.id == assigned.id ||
          tractor.assetNo == assigned.id ||
          tractor.label == assigned.id ||
          (assigned.assetNo != null && tractor.assetNo == assigned.assetNo) ||
          (assigned.label != null && tractor.label == assigned.label);
      if (matches && _isUuid(tractor.id)) return tractor.id;
    }
    return assigned.id;
  }

  String _registryOperatorId(OperatorProfile assigned) {
    if (_isUuid(assigned.id)) return assigned.id;
    for (final operator in _operators) {
      if ((operator.id == assigned.id || operator.name == assigned.name) &&
          _isUuid(operator.id)) {
        return operator.id;
      }
    }
    return assigned.id;
  }

  bool _isUuid(String value) => RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  ).hasMatch(value);

  Future<void> closeJob(
    String jobId, {
    required String paymentStatus,
    String? note,
  }) async {
    if (!can('mech.jobs.manage')) {
      _mechanizationActionError =
          'Your account does not have permission for this action.';
      notifyListeners();
      return;
    }
    final job = maybeJobById(jobId);
    if (job == null) {
      _mechanizationActionError =
          'This job is no longer available. Refresh your jobs.';
      notifyListeners();
      return;
    }
    if (await _tryRemoteJobUpdate(
      () => mobileApiClient.closeJob(
        token: _accessToken!,
        jobId: jobId,
        paymentStatus: paymentStatus,
        note: note,
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
    if (!can('mech.jobs.manage')) {
      _mechanizationActionError =
          'Your account does not have permission for this action.';
      notifyListeners();
      return;
    }
    final job = maybeJobById(jobId);
    if (job == null) {
      _mechanizationActionError =
          'This job is no longer available. Refresh your jobs.';
      notifyListeners();
      return;
    }
    if (await _tryRemoteJobUpdate(
      () => mobileApiClient.cancelJob(
        token: _accessToken!,
        jobId: jobId,
        reason: notes.trim().isEmpty ? reason.label : notes.trim(),
        cancelRequest: false,
      ),
    )) {
      if (_mechanizationActionError == null && _accessToken != null) {
        final token = _accessToken!;
        final session = _sessionVersion;
        if (job.requestId != job.id) await refreshRequestDetail(job.requestId);
        if (!_currentSession(token, session)) return;
        try {
          final backlog = await mobileApiClient.calendarBacklog(token: token);
          if (!_currentSession(token, session)) return;
          _remoteBacklogCount =
              _metaCount(backlog) ?? _dataList(backlog).length;
          notifyListeners();
        } on KwanzaTrackApiException {
          /* Job cancellation remains successful. */
        }
      }
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
    if (!can('mech.jobs.manage')) {
      _mechanizationActionError =
          'Your account does not have permission for this action.';
      notifyListeners();
      return;
    }
    final job = maybeJobById(jobId);
    if (job == null) {
      _mechanizationActionError =
          'This job is no longer available. Refresh your jobs.';
      notifyListeners();
      return;
    }
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
    final job = maybeJobById(jobId);
    if (job == null) {
      _mechanizationActionError =
          'This job is no longer available. Refresh your jobs.';
      notifyListeners();
      return;
    }
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

  Future<void> flagJob({required String jobId, required String reason}) async {
    if (!can('mech.jobs.manage')) {
      _mechanizationActionError =
          'Your account does not have permission for this action.';
      notifyListeners();
      return;
    }
    if (await _tryRemoteJobUpdate(
      () => mobileApiClient.flagJob(
        token: _accessToken!,
        jobId: jobId,
        reason: reason,
      ),
    )) {
      return;
    }
    final job = maybeJobById(jobId);
    if (job == null) {
      _mechanizationActionError =
          'This job is no longer available. Refresh your jobs.';
      notifyListeners();
      return;
    }
    _replaceJob(jobId, job.copyWith(status: JobStatus.flagged, alert: reason));
  }

  Future<void> unflagJob({required String jobId, required String note}) async {
    if (!can('mech.jobs.manage')) {
      _mechanizationActionError =
          'Your account does not have permission for this action.';
      notifyListeners();
      return;
    }
    if (await _tryRemoteJobUpdate(
      () => mobileApiClient.unflagJob(
        token: _accessToken!,
        jobId: jobId,
        note: note,
      ),
    )) {
      return;
    }
    final job = maybeJobById(jobId);
    if (job == null) {
      _mechanizationActionError =
          'This job is no longer available. Refresh your jobs.';
      notifyListeners();
      return;
    }
    _replaceJob(jobId, job.copyWith(status: JobStatus.dispatched));
  }

  Future<void> refreshJobVerification(String jobId) async {
    if (!can('mech.jobs.manage')) {
      _mechanizationActionError =
          'Your account does not have permission for this action.';
      notifyListeners();
      return;
    }
    await _tryRemoteJobUpdate(
      () => mobileApiClient.refreshVerification(
        token: _accessToken!,
        jobId: jobId,
      ),
    );
  }

  Future<void> verifyJob({
    required String jobId,
    required num verifiedAcres,
    String? note,
  }) async {
    if (!can('mech.jobs.manage')) {
      _mechanizationActionError =
          'Your account does not have permission for this action.';
      notifyListeners();
      return;
    }
    final token = _accessToken;
    final session = _sessionVersion;
    if (token == null) return;
    await refreshJobDetail(jobId);
    if (!_currentSession(token, session) || _mechanizationActionError != null) {
      return;
    }
    final detail = maybeJobById(jobId);
    if (detail == null) return;
    if (requiresFarmerConfirmation && detail.farmerConfirmedAt == null) {
      _mechanizationActionError =
          'Farmer confirmation is required before verification.';
      notifyListeners();
      return;
    }
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
    if (!can('mech.jobs.manage')) {
      _mechanizationActionError =
          'Your account does not have permission for this action.';
      notifyListeners();
      return;
    }
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
    final session = _sessionVersion;
    if (token == null || token.isEmpty) return;
    try {
      _mechanizationActionError = null;
      final responses = await Future.wait<Map<String, Object?>>([
        mobileApiClient.overrides(token: token),
        mobileApiClient.exceptions(token: token),
      ]);
      if (!_currentSession(token, session)) return;
      _applyOverridesResponse(responses[0]);
      _applyExceptionsResponse(responses[1]);
      notifyListeners();
    } on KwanzaTrackApiException catch (error) {
      if (!_currentSession(token, session)) return;
      _mechanizationActionError = error.message;
      notifyListeners();
    }
  }

  Future<void> decideOverride({
    required String overrideId,
    required bool approve,
    required String note,
  }) async {
    if (!can('mech.override')) {
      _mechanizationActionError =
          'Your account does not have permission for this action.';
      notifyListeners();
      return;
    }
    final token = _accessToken;
    final session = _sessionVersion;
    if (token == null || token.isEmpty) return;
    try {
      _mechanizationActionError = null;
      await mobileApiClient.decideOverride(
        token: token,
        overrideId: overrideId,
        approve: approve,
        note: note,
      );
      if (!_currentSession(token, session)) return;
      await refreshOversightData();
      if (!_currentSession(token, session)) return;
    } on KwanzaTrackApiException catch (error) {
      if (!_currentSession(token, session)) return;
      _mechanizationActionError = error.message;
      notifyListeners();
    }
  }

  Future<bool> acknowledgeException(String exceptionId) async {
    if (!can('mech.exceptions.manage')) {
      _mechanizationActionError =
          'Your account does not have permission for this action.';
      notifyListeners();
      return false;
    }
    final token = _accessToken;
    final session = _sessionVersion;
    if (token == null || token.isEmpty) {
      _mechanizationActionError =
          'Your session has expired. Please sign in again.';
      notifyListeners();
      return false;
    }
    try {
      _mechanizationActionError = null;
      await mobileApiClient.acknowledgeException(
        token: token,
        exceptionId: exceptionId,
      );
      if (!_currentSession(token, session)) return false;
      await refreshOversightData();
      if (!_currentSession(token, session)) return false;
      return _mechanizationActionError == null;
    } on KwanzaTrackApiException catch (error) {
      if (!_currentSession(token, session)) return false;
      _mechanizationActionError = error.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> resolveException({
    required String exceptionId,
    required String remarks,
    bool dismiss = false,
  }) async {
    if (!can('mech.exceptions.manage')) {
      _mechanizationActionError =
          'Your account does not have permission for this action.';
      notifyListeners();
      return;
    }
    final token = _accessToken;
    final session = _sessionVersion;
    if (token == null || token.isEmpty) return;
    try {
      _mechanizationActionError = null;
      await mobileApiClient.resolveException(
        token: token,
        exceptionId: exceptionId,
        remarks: remarks,
        dismiss: dismiss,
      );
      if (!_currentSession(token, session)) return;
      await refreshOversightData();
      if (!_currentSession(token, session)) return;
    } on KwanzaTrackApiException catch (error) {
      if (!_currentSession(token, session)) return;
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
    if (user['permissions'] is List) {
      _permissions = (user['permissions'] as List)
          .map((item) => item.toString())
          .toSet();
    }
    _policy = _map(data['policy']);
    _mechanizationUserName = user['name']?.toString();
    _mechanizationUserEmail = user['email']?.toString();
    _mechanizationUserRole = user['role']?.toString();
  }

  void _applyRequestsResponse(
    Map<String, Object?> response, {
    bool replace = false,
  }) {
    if (response.containsKey('_load_error')) return;
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

  Future<Map<String, Object?>> _loadAllRequests(String token) {
    final session = _sessionVersion;
    return allApiPages(
      (page) =>
          mobileApiClient.requests(token: token, status: 'all', page: page),
      isCurrent: () => _currentSession(token, session),
    );
  }

  Future<void> _refreshAllRequestBuckets(String token) async {
    final session = _sessionVersion;
    final response = await _loadAllRequests(token);
    if (!_currentSession(token, session)) return;
    _applyRequestsResponse(response, replace: true);
  }

  void _applyCalendarResponse(Map<String, Object?> response) {
    if (response.containsKey('_load_error')) return;
    final events = _dataMap(response)['events'];
    if (events is! List) return;

    final remoteJobs = events
        .whereType<Map>()
        .map((event) => _jobFromCalendarEvent(_stringKeyedMap(event)))
        .whereType<OperationsJob>()
        .toList();
    _calendarJobs
      ..clear()
      ..addAll(remoteJobs);
  }

  void _applyJobsResponse(Map<String, Object?> response) {
    if (response.containsKey('_load_error')) return;
    final remoteJobs = _dataList(response)
        .whereType<Map>()
        .map((item) => _jobFromJson(_stringKeyedMap(item)))
        .whereType<OperationsJob>()
        .toList();
    _jobs
      ..clear()
      ..addAll(remoteJobs);
  }

  void _applyTractorsResponse(
    Map<String, Object?> response, {
    bool replace = false,
    String source = 'mine/live',
  }) {
    if (response.containsKey('_load_error')) return;
    final tractors = _dataList(response)
        .whereType<Map>()
        .map((item) => _tractorFromJson(_stringKeyedMap(item)))
        .whereType<TractorAsset>()
        .toList();
    if (kDebugMode) {
      final labels = tractors
          .map((tractor) => tractor.assetNo ?? tractor.label ?? tractor.id)
          .join(', ');
      debugPrint(
        '[Mechanization Registry] $source tractors: '
        '${tractors.length}${labels.isEmpty ? '' : ' [$labels]'}',
      );
    }

    if (replace) _tractors.clear();
    if (tractors.isEmpty) return;

    for (final tractor in tractors) {
      _removePlaceholderTractorsFor(tractor);
      _upsertTractor(tractor);
    }
  }

  void _applyOperatorsResponse(Map<String, Object?> response) {
    if (response.containsKey('_load_error')) return;
    final operators = _dataList(response)
        .whereType<Map>()
        .map((item) => _operatorFromJson(_stringKeyedMap(item)))
        .whereType<OperatorProfile>()
        .toList();

    _operators
      ..clear()
      ..addAll(operators);
  }

  void _applyFarmersResponse(Map<String, Object?> response) {
    if (response.containsKey('_load_error')) return;
    final parsed = _dataList(response)
        .whereType<Map>()
        .map((item) => _registryFarmerFromJson(_stringKeyedMap(item)))
        .whereType<RegistryFarmer>()
        .toList();
    final unique = <RegistryFarmer>[];
    final seenKeys = <String>{};
    for (final farmer in parsed) {
      final keys = _farmerIdentityKeys(farmer);
      if (keys.any(seenKeys.contains)) continue;

      unique.add(farmer);
      seenKeys.addAll(keys);
    }
    _farmers
      ..clear()
      ..addAll(unique);
    if (kDebugMode) {
      debugPrint(
        '[Mechanization Registry] farmers: ${unique.length} '
        '(removed ${parsed.length - unique.length} duplicate rows)',
      );
    }
  }

  Set<String> _farmerIdentityKeys(RegistryFarmer farmer) {
    final keys = <String>{'id:${farmer.id.trim().toLowerCase()}'};
    final externalRef = farmer.externalRef?.trim().toLowerCase();
    if (externalRef != null && externalRef.isNotEmpty) {
      keys.add('external:$externalRef');
    }

    return keys;
  }

  RegistryFarmer? _registryFarmerFromJson(Map<String, Object?> json) {
    final id = _text(json, const ['id']);
    final name = _text(json, const ['name', 'full_name']);
    if (id == null || name == null) return null;
    final plots = json['plots'];
    final location = [
      _text(json, const ['village']),
      _text(json, const ['ward']),
      _text(json, const ['district']),
      _text(json, const ['region']),
    ].whereType<String>().where((value) => value.isNotEmpty).join(', ');
    return RegistryFarmer(
      id: id,
      name: name,
      externalRef: _text(json, const ['external_ref']),
      phone: _text(json, const ['phone']),
      location: location.isEmpty ? null : location,
      status: _text(json, const ['status']),
      plotCount: plots is List
          ? plots.length
          : (_asInt(json['plots_count']) ?? _asInt(json['plot_count']) ?? 0),
    );
  }

  void _applyOverridesResponse(Map<String, Object?> response) {
    if (response.containsKey('_load_error')) return;
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
    if (response.containsKey('_load_error')) return;
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
    final session = _sessionVersion;
    if (token == null || token.isEmpty) {
      _mechanizationActionError =
          'Your session has expired. Please sign in again.';
      notifyListeners();
      return true;
    }
    try {
      _mechanizationActionError = null;
      final response = await request();
      if (!_currentSession(token, session)) return true;
      _dataVersion++;
      final job = _jobFromResponse(response);
      if (job != null) {
        _lastScheduledJobId = job.id;
        _upsertJob(job);
      }
      notifyListeners();
      return true;
    } on KwanzaTrackApiException catch (error) {
      if (!_currentSession(token, session)) return true;
      _mechanizationActionError = error.message;
      notifyListeners();
      return true;
    }
  }

  Future<bool> _tryRemoteRequestUpdate(
    Future<Map<String, Object?>> Function() request,
  ) async {
    final token = _accessToken;
    final session = _sessionVersion;
    if (token == null || token.isEmpty) {
      _mechanizationActionError =
          'Your session has expired. Please sign in again.';
      notifyListeners();
      return true;
    }
    try {
      _mechanizationActionError = null;
      final response = await request();
      if (!_currentSession(token, session)) return true;
      _dataVersion++;
      final remoteRequest = _requestFromJson(_dataMap(response));
      if (remoteRequest != null) _upsertRequest(remoteRequest);
      notifyListeners();
      return true;
    } on KwanzaTrackApiException catch (error) {
      if (!_currentSession(token, session)) return true;
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
    String? implement,
  }) async {
    final token = _accessToken;
    final session = _sessionVersion;
    if (token == null || token.isEmpty) {
      _mechanizationActionError =
          'Your session has expired. Please sign in again.';
      notifyListeners();
      return true;
    }
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
        plannedAcres: request.requestedAcres,
        implement: implement,
      );
      if (!_currentSession(token, session)) return true;
      _dataVersion++;
      final job = _jobFromJson(_dataMap(response));
      if (job != null) {
        _lastScheduledJobId = job.id;
        _upsertJob(job);
      }
      _replaceRequest(
        requestId,
        request.copyWith(status: OperationsRequestStatus.scheduled),
        notify: false,
      );
      notifyListeners();
      return true;
    } on KwanzaTrackApiException catch (error) {
      if (!_currentSession(token, session)) return true;
      _mechanizationActionError = error.message;
      notifyListeners();
      return true;
    }
  }

  OperationsJob? _jobFromResponse(Map<String, Object?> response) {
    final data = _dataMap(response);
    final nestedJob = _map(data['job']);
    return _jobFromJson(nestedJob.isEmpty ? data : nestedJob);
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
        _text(event, const ['tractor_id', 'tractor', 'tractor_code']) ??
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
      scheduledEndAt: end,
      status: status,
      startedAt: status == JobStatus.inProgress ? start : null,
      alert: _geofenceAlert(status, _asBool(event['geofence_verified'])),
    );
  }

  OperationsServiceRequest? _requestFromJson(Map<String, Object?> json) {
    final id = _text(json, const ['id', 'reference', 'external_ref']);
    if (id == null || id.isEmpty) return null;

    json = mergeMechanizationData(_requestPayloads[id] ?? {}, json);
    _requestPayloads[id] = json;
    final farmerJson = _map(json['farmer']);
    final plotJson = _map(json['plot']);
    final serviceTypeJson = _map(json['service_type']);
    final boundaryPoints = _plotBoundaryPoints(plotJson);
    _logReceivedPlotBoundary(
      requestId: id,
      requestReference: _text(json, const ['reference', 'external_ref']),
      plot: plotJson,
      parsedPoints: boundaryPoints,
    );
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
      farmerId: _text(farmerJson, const ['id']),
      plotExternalRef: _text(plotJson, const ['external_ref']),
      requestedAcres: _number(json, const ['requested_acres'])?.toDouble(),
      preferredWindow: _text(json, const ['preferred_window']),
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
        boundaryRegistered:
            boundaryPoints.length >= 3 ||
            (_asBool(plotJson['mapped']) ?? false),
        boundaryPoints: boundaryPoints,
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

    json = mergeMechanizationData(_jobPayloads[id] ?? {}, json);
    _jobPayloads[id] = json;
    final tractorJson = _map(json['tractor']);
    final operatorJson = _map(json['operator']);
    final farmerJson = _map(json['farmer']);
    final plotJson = _map(json['plot']);
    final serviceTypeJson = _map(json['service_type']);
    final requestJson = _map(json['request']);
    final status = _jobStatus(json['status']?.toString());
    final scheduledAt =
        _dateTimeFromParts(json['scheduled_date'], json['window_start']) ??
        _dateTime(json['scheduled_at']) ??
        DateTime.now();
    final windowEnd = _dateTimeFromParts(
      json['scheduled_date'],
      json['window_end'],
    );
    final estimatedHours = windowEnd == null
        ? 1
        : windowEnd.difference(scheduledAt).inMinutes ~/ 60;
    final boundaryPoints = _plotBoundaryPoints(plotJson);
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
        boundaryRegistered:
            boundaryPoints.length >= 3 ||
            (_asBool(plotJson['mapped']) ?? false),
        boundaryPoints: boundaryPoints,
      ),
      tractor: TractorAsset(
        id: tractorId,
        assetNo: _text(tractorJson, const ['asset_no']),
        label: _text(tractorJson, const ['label']),
        model: _text(tractorJson, const ['label', 'asset_no']) ?? tractorId,
        status: _tractorStatus(status),
        operatingHours:
            _asInt(json['start_hour_meter']) ??
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
      scheduledEndAt: windowEnd,
      status: status,
      startedAt: _dateTime(json['started_at']),
      completedAt: _dateTime(json['completed_at']),
      reportedAcres: _number(json, const ['reported_acres']),
      verifiedAcres: _number(json, const ['verified_acres']),
      farmerConfirmedAt: _dateTime(json['farmer_confirmed_at']),
      verification: _map(json['verification']),
      paymentStatus: _text(json, const ['payment_status']),
      amount: _number(json, const ['amount']),
      currency: _text(json, const ['currency']),
      alert:
          _text(json, const ['flag_reason', 'cancel_reason', 'dispute_note']) ??
          _geofenceAlert(status, _asBool(json['geofence_verified'])),
    );
  }

  String? _geofenceAlert(JobStatus status, bool? verified) {
    if (verified != false) return null;
    return switch (status) {
      JobStatus.arrived ||
      JobStatus.inProgress ||
      JobStatus.paused => 'Geofence not verified',
      _ => null,
    };
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

  OperatorProfile? _operatorFromJson(Map<String, Object?> json) {
    final user = _map(json['user']);
    final id =
        _text(json, const ['id', 'operator_id', 'user_id']) ??
        _text(user, const ['id']);
    final name =
        _text(json, const ['name', 'operator_name', 'full_name']) ??
        _text(user, const ['name', 'full_name']);
    if (id == null || name == null) return null;

    final status = _text(json, const [
      'availability_status',
      'status',
      'operator_status',
    ]);
    final isActive =
        _asBool(json['is_active']) ??
        _asBool(json['active']) ??
        _asBool(user['is_active']) ??
        _asBool(user['active']);
    final phone =
        _text(json, const ['phone', 'phone_number']) ??
        _text(user, const ['phone', 'phone_number']);
    final licence = _text(json, const [
      'license_number',
      'licence_number',
      'license_no',
      'licence_no',
    ]);
    final noteParts = [
      phone,
      if (licence != null) 'Licence $licence',
    ].whereType<String>().toList();

    return OperatorProfile(
      id: id,
      name: name,
      status: _operatorRegistryStatus(status, isActive: isActive),
      note: noteParts.isEmpty ? null : noteParts.join(' - '),
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
    final calendarIndex = _calendarJobs.indexWhere((item) => item.id == job.id);
    if (calendarIndex == -1) {
      _calendarJobs.add(job);
    } else {
      _calendarJobs[calendarIndex] = job;
    }
    final request = _jobPayloads[job.id]?['request'];
    if (request is Map && _requests.any((item) => item.id == request['id'])) {
      final updated = _requestFromJson(_stringKeyedMap(request));
      if (updated != null) _upsertRequest(updated);
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

  List<BoundaryPoint> _plotBoundaryPoints(Map<String, Object?> plot) {
    final boundary = plot['boundary'];
    if (boundary is List) {
      final points = boundary.indexed
          .map((entry) {
            final point = _map(entry.$2);
            final latitude = _number(point, const ['latitude', 'lat']);
            final longitude = _number(point, const ['longitude', 'lng', 'lon']);
            if (latitude == null || longitude == null) return null;
            return BoundaryPoint(
              label: 'Boundary ${entry.$1 + 1}',
              latitude: latitude.toDouble(),
              longitude: longitude.toDouble(),
            );
          })
          .whereType<BoundaryPoint>()
          .toList(growable: false);
      if (points.length >= 3) return points;
    }

    final centroid = _map(plot['centroid']);
    final latitude = _number(centroid, const ['latitude', 'lat']);
    final longitude = _number(centroid, const ['longitude', 'lng', 'lon']);
    if (latitude == null || longitude == null) return const [];
    return [
      BoundaryPoint(
        label: 'Plot center',
        latitude: latitude.toDouble(),
        longitude: longitude.toDouble(),
      ),
    ];
  }

  Future<void> _enrichRequestBoundaries(
    String token, {
    Set<String>? requestIds,
  }) async {
    final session = _sessionVersion;
    if (!_currentSession(token, session)) return;
    final candidates = _requests.where(
      (request) =>
          request.plot.boundaryPoints.length < 3 &&
          request.farmerId != null &&
          (requestIds == null || requestIds.contains(request.id)),
    );
    final farmerIds = candidates
        .map((request) => request.farmerId!)
        .toSet()
        .toList(growable: false);

    for (final farmerId in farmerIds) {
      try {
        final response = await mobileApiClient.farmer(
          token: token,
          farmerId: farmerId,
        );
        if (!_currentSession(token, session)) return;
        final plots = _dataMap(response)['plots'];
        if (plots is! List) continue;

        final registryPlots = plots
            .whereType<Map>()
            .map(_stringKeyedMap)
            .toList(growable: false);
        for (var index = 0; index < _requests.length; index++) {
          final request = _requests[index];
          if (request.farmerId != farmerId ||
              request.plot.boundaryPoints.length >= 3 ||
              (requestIds != null && !requestIds.contains(request.id))) {
            continue;
          }

          final matchingPlot = registryPlots
              .cast<Map<String, Object?>?>()
              .firstWhere(
                (plot) =>
                    _text(plot!, const ['id']) == request.plot.id ||
                    (_text(plot, const ['external_ref']) != null &&
                        _text(plot, const ['external_ref']) ==
                            request.plotExternalRef),
                orElse: () => null,
              );
          if (matchingPlot == null) continue;

          final boundary = _plotBoundaryPoints(matchingPlot);
          if (boundary.length < 3) continue;
          _requests[index] = request.copyWith(
            plot: FarmPlot(
              id: request.plot.id,
              name: request.plot.name,
              areaHectares: request.plot.areaHectares,
              location: request.plot.location,
              boundaryRegistered: true,
              boundaryPoints: boundary,
            ),
          );
          if (kDebugMode) {
            debugPrint(
              '[Mechanization Request] Enriched ${request.id} from farmer registry: '
              '${boundary.length} boundary points.',
            );
          }
        }
      } on KwanzaTrackApiException catch (error) {
        if (!_currentSession(token, session)) return;
        if (kDebugMode) {
          debugPrint(
            '[Mechanization Request] Could not load farmer $farmerId plots: '
            '${error.message}',
          );
        }
      }
    }
  }

  void _logReceivedPlotBoundary({
    required String requestId,
    required String? requestReference,
    required Map<String, Object?> plot,
    required List<BoundaryPoint> parsedPoints,
  }) {
    if (!kDebugMode) return;

    final rawBoundary = plot['boundary'];
    final rawPointCount = rawBoundary is List ? rawBoundary.length : 0;
    final centroid = _map(plot['centroid']);
    debugPrint(
      '[Mechanization Request] Received '
      '${requestReference ?? requestId}: plot=${plot['name'] ?? plot['id'] ?? 'unknown'}, '
      'mapped=${plot['mapped']}, boundary_field=${rawBoundary == null ? 'missing' : rawBoundary.runtimeType}, '
      'raw_boundary_points=$rawPointCount, parsed_points=${parsedPoints.length}, '
      'centroid=${centroid.isEmpty ? 'missing' : centroid}',
    );

    if (rawPointCount < 3) {
      debugPrint(
        '[Mechanization Request] WARNING ${requestReference ?? requestId}: '
        'KwanzaTrack did not return a drawable plot boundary (minimum 3 points).',
      );
      return;
    }

    for (var index = 0; index < parsedPoints.length; index++) {
      final point = parsedPoints[index];
      debugPrint(
        '[Mechanization Request] Boundary ${index + 1}: '
        'latitude=${point.latitude}, longitude=${point.longitude}',
      );
    }
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

  List<String> _windowConflicts(
    Object? value,
    DateTime? start,
    Duration? duration,
    String? excludeJobId,
  ) {
    if (value is! List || start == null || duration == null) {
      return _availabilityItems(value);
    }
    final end = start.add(duration);
    final conflicts = value.where((item) {
      if (item is! Map) return true;
      if (excludeJobId != null && item['id']?.toString() == excludeJobId) {
        return false;
      }
      if ([
        'cancelled',
        'completed',
        'verified',
        'closed',
      ].contains(item['status'])) {
        return false;
      }
      final day = item['scheduled_date'] ?? _dateOnly(start);
      final existingStart =
          apiScheduleTime(day, item['window_start']) ??
          localApiTime(item['start']);
      var existingEnd =
          apiScheduleTime(day, item['window_end']) ?? localApiTime(item['end']);
      if (existingStart == null || existingEnd == null) return true;
      if (!existingEnd.isAfter(existingStart)) {
        existingEnd = existingEnd.add(const Duration(days: 1));
      }
      return existingStart.isBefore(end) && start.isBefore(existingEnd);
    }).toList();
    return _availabilityItems(conflicts);
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
    return localApiTime(text);
  }

  ServiceType _serviceType(String? value) {
    final normalized = value?.toLowerCase() ?? '';
    if (normalized.contains('harrow')) return ServiceType.harrowing;
    if (normalized.contains('plant')) return ServiceType.planting;
    return ServiceType.ploughing;
  }

  OperationsRequestStatus _requestStatus(String? value) =>
      switch (value?.toLowerCase().replaceAll('-', '_')) {
        'pending' => OperationsRequestStatus.pending,
        'approved' => OperationsRequestStatus.approved,
        'returned' || 'returned_to_farmer' => OperationsRequestStatus.returned,
        'rejected' || 'declined' => OperationsRequestStatus.rejected,
        'scheduled' || 'dispatched' => OperationsRequestStatus.scheduled,
        'en_route' => OperationsRequestStatus.enRoute,
        'arrived' => OperationsRequestStatus.arrived,
        'in_progress' => OperationsRequestStatus.inProgress,
        'paused' => OperationsRequestStatus.paused,
        'completed' => OperationsRequestStatus.completed,
        'verified' => OperationsRequestStatus.verified,
        'closed' => OperationsRequestStatus.closed,
        'flagged' => OperationsRequestStatus.flagged,
        'cancelled' || 'canceled' => OperationsRequestStatus.cancelled,
        _ => OperationsRequestStatus.unknown,
      };

  JobStatus _jobStatus(String? value) {
    final normalized = value?.toLowerCase().replaceAll('-', '_') ?? '';
    return switch (normalized) {
      'scheduled' => JobStatus.scheduled,
      'dispatched' => JobStatus.dispatched,
      'en_route' || 'accepted' => JobStatus.enRoute,
      'arrived' => JobStatus.arrived,
      'in_progress' || 'started' || 'working' => JobStatus.inProgress,
      'paused' => JobStatus.paused,
      'completed' ||
      'awaiting_verification' => JobStatus.completedPendingConfirmation,
      'verified' => JobStatus.verified,
      'flagged' => JobStatus.flagged,
      'closed' || 'confirmed' => JobStatus.closed,
      'cancelled' || 'canceled' => JobStatus.cancelled,
      _ => JobStatus.scheduled,
    };
  }

  TractorStatus _tractorStatus(JobStatus status) {
    return switch (status) {
      JobStatus.cancelled ||
      JobStatus.completedPendingConfirmation ||
      JobStatus.closed ||
      JobStatus.verified => TractorStatus.available,
      _ => TractorStatus.scheduled,
    };
  }

  TractorStatus _tractorAssetStatus(String? value) {
    final normalized = value?.toLowerCase().replaceAll('-', '_') ?? '';
    return switch (normalized) {
      'available' || 'active' || 'ready' => TractorStatus.available,
      'scheduled' ||
      'assigned' ||
      'busy' ||
      'in_use' ||
      'working' => TractorStatus.scheduled,
      'maintenance' ||
      'under_maintenance' ||
      'repair' => TractorStatus.underMaintenance,
      'out_of_service' ||
      'inactive' ||
      'disabled' => TractorStatus.outOfService,
      _ => TractorStatus.outOfService,
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
      JobStatus.cancelled ||
      JobStatus.completedPendingConfirmation ||
      JobStatus.closed ||
      JobStatus.verified => OperatorStatus.available,
      _ => OperatorStatus.assigned,
    };
  }

  OperatorStatus _operatorRegistryStatus(
    String? value, {
    required bool? isActive,
  }) {
    if (isActive == false) return OperatorStatus.unavailable;
    final normalized = value?.toLowerCase().replaceAll('-', '_') ?? '';
    return switch (normalized) {
      'assigned' || 'busy' || 'on_job' || 'in_use' => OperatorStatus.assigned,
      'inactive' ||
      'unavailable' ||
      'suspended' ||
      'expired' ||
      'disabled' => OperatorStatus.unavailable,
      _ => OperatorStatus.available,
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

  DateTime? _dateTimeFromParts(Object? dateValue, Object? timeValue) =>
      apiScheduleTime(dateValue, timeValue);

  @override
  void dispose() {
    _disposed = true;
    _sessionVersion++;
    _syncGeneration++;
    super.dispose();
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
}
