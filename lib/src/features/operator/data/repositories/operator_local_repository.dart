import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../additional_data/location/domain/entities/device_location.dart';
import '../../../../core/network/kwanza_track_mobile_api_client.dart';
import '../../../farmer/domain/entities/farm_plot.dart';
import '../../../farmer/domain/entities/service_request.dart';
import '../../domain/entities/operator_job.dart';

class OperatorLocalRepository extends ChangeNotifier {
  OperatorLocalRepository.seeded({KwanzaTrackMobileApiClient? mobileApiClient})
    : mobileApiClient = mobileApiClient ?? const KwanzaTrackMobileApiClient(),
      _jobs = [];

  final KwanzaTrackMobileApiClient mobileApiClient;
  final List<OperatorJob> _jobs;
  final Map<String, TractorTrackerPosition> _trackerPositions = {};
  final Map<String, List<String>> _tractorImplements = {};
  String? _accessToken;
  bool _isSyncingMechanization = false;
  String? _mechanizationSyncError;
  String? _lastActionError;
  String? _operatorName;
  String? _operatorEmail;
  String? _operatorRole;
  int _syncGeneration = 0;
  Timer? _trackerPollTimer;
  bool _isRefreshingTrackerPositions = false;

  List<OperatorJob> get jobs => List.unmodifiable(_jobs);
  Map<String, TractorTrackerPosition> get trackerPositions =>
      Map.unmodifiable(_trackerPositions);
  bool get isSyncingMechanization => _isSyncingMechanization;
  String? get mechanizationSyncError => _mechanizationSyncError;
  String? get lastActionError => _lastActionError;
  String? get operatorName => _operatorName;
  String? get operatorEmail => _operatorEmail;
  String? get operatorRole => _operatorRole;

  TractorTrackerPosition? trackerPositionFor(String tractorId) =>
      _trackerPositions[tractorId];

  List<String> implementNamesFor(String tractorId) =>
      List.unmodifiable(_tractorImplements[tractorId] ?? const <String>[]);

  OperatorJob? get todayJob {
    for (final job in _jobs) {
      if (!job.isComplete) return job;
    }
    return _jobs.firstOrNull;
  }

  List<OperatorJob> get history {
    return _jobs.where((job) => job.isComplete).toList(growable: false);
  }

  List<OperatorJob> get pastAssignments {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final items =
        _jobs.where((job) {
          if (job.isComplete) return true;
          final stillUnderway =
              job.status == OperatorJobStatus.enRoute ||
              job.status == OperatorJobStatus.arrived ||
              job.status == OperatorJobStatus.inProgress;
          return job.scheduledAt.isBefore(today) && !stillUnderway;
        }).toList()..sort(
          (first, second) => second.scheduledAt.compareTo(first.scheduledAt),
        );
    return List.unmodifiable(items);
  }

  void setMechanizationAccessToken(String? token) {
    final normalized = token?.trim();
    if (_accessToken == normalized) return;
    stopTrackerPolling();
    _accessToken = normalized?.isEmpty == true ? null : normalized;
    _mechanizationSyncError = null;
    _lastActionError = null;
    if (_accessToken == null) {
      stopTrackerPolling();
      _operatorName = null;
      _operatorEmail = null;
      _operatorRole = null;
      _jobs.clear();
      _trackerPositions.clear();
      _tractorImplements.clear();
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
    notifyListeners();

    try {
      final today = DateTime.now();
      final from = _dateOnly(today.subtract(const Duration(days: 90)));
      final to = _dateOnly(today.add(const Duration(days: 365)));
      final responses = await Future.wait<Map<String, Object?>>([
        mobileApiClient.me(token: token),
        mobileApiClient.calendar(token: token, from: from, to: to, mine: true),
        mobileApiClient.jobs(
          token: token,
          status: 'active',
          mine: true,
        ),
        mobileApiClient.tractors(token: token, mine: true, live: true),
      ]);
      if (generation != _syncGeneration) return;

      _applyMeResponse(responses[0]);
      _applyCalendarResponse(responses[1]);
      _applyJobsResponse(responses[2]);
      _applyTrackerPositionsResponse(responses[3]);
      await _refreshJobPaths(token);
      _mechanizationSyncError = null;
    } on KwanzaTrackApiException catch (error) {
      if (generation == _syncGeneration) {
        _mechanizationSyncError = error.message;
      }
    } catch (error) {
      if (generation == _syncGeneration) {
        _mechanizationSyncError = 'Could not refresh operator jobs: $error';
      }
    } finally {
      if (generation == _syncGeneration) {
        _isSyncingMechanization = false;
        notifyListeners();
      }
    }
  }

  void startTrackerPolling() {
    if (_trackerPollTimer != null || _accessToken == null) return;
    unawaited(refreshTrackerPositions());
    _trackerPollTimer = Timer.periodic(
      const Duration(seconds: 12),
      (_) => unawaited(refreshTrackerPositions()),
    );
  }

  void stopTrackerPolling() {
    _trackerPollTimer?.cancel();
    _trackerPollTimer = null;
  }

  Future<void> refreshTrackerPositions() async {
    final token = _accessToken;
    if (token == null || token.isEmpty || _isRefreshingTrackerPositions) {
      return;
    }
    _isRefreshingTrackerPositions = true;
    try {
      final response = await mobileApiClient.tractors(
        token: token,
        mine: true,
        live: true,
      );
      _applyTrackerPositionsResponse(response);
      notifyListeners();
    } on KwanzaTrackApiException catch (error) {
      if (kDebugMode) {
        debugPrint('[Tracker Poll] ${error.message}');
      }
    } catch (error) {
      if (kDebugMode) debugPrint('[Tracker Poll] $error');
    } finally {
      _isRefreshingTrackerPositions = false;
    }
  }

  OperatorJob jobById(String id) {
    return _jobs.firstWhere((job) => job.id == id);
  }

  OperatorJob? maybeJobById(String id) {
    for (final job in _jobs) {
      if (job.id == id) return job;
    }
    return null;
  }

  Future<bool> acceptAssignment(String jobId, {DeviceLocation? phone}) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) {
      _lastActionError = 'Your session has expired. Please sign in again.';
      notifyListeners();
      return false;
    }

    try {
      _lastActionError = null;
      final response = await mobileApiClient.acceptJob(
        token: token,
        jobId: jobId,
        clientEventId: _eventId(),
        phone: _phonePayload(phone),
      );
      _applyJobResponse(response, acceptedByOperator: true);
      notifyListeners();
      return true;
    } on KwanzaTrackApiException catch (error) {
      _lastActionError = error.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> startJourney(String jobId, {DeviceLocation? phone}) async {
    return _runJobAction(
      offline: () => jobById(jobId),
      remote: (token) => mobileApiClient.markEnRoute(
        token: token,
        jobId: jobId,
        clientEventId: _eventId(),
        phone: _phonePayload(phone),
      ),
    );
  }

  Future<bool> arriveJob(String jobId, {DeviceLocation? phone}) async {
    return _runJobAction(
      offline: () => jobById(jobId),
      remote: (token) => mobileApiClient.arriveJob(
        token: token,
        jobId: jobId,
        clientEventId: _eventId(),
        phone: _phonePayload(phone),
      ),
    );
  }

  Future<bool> recordInspection({
    required String tractorId,
    required String jobId,
    required Map<String, Object?> checklist,
    int? fuelLevelPct,
    num? hourMeter,
    String? defects,
    bool? isFit,
    DeviceLocation? phone,
  }) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) {
      _lastActionError = 'Your session has expired. Please sign in again.';
      notifyListeners();
      return false;
    }

    try {
      _lastActionError = null;
      await mobileApiClient.createInspection(
        token: token,
        tractorId: tractorId,
        checklist: checklist,
        fuelLevelPct: fuelLevelPct,
        hourMeter: hourMeter,
        defects: defects,
        isFit: isFit,
        jobId: jobId,
        phone: _phonePayload(phone),
      );
      notifyListeners();
      return true;
    } on KwanzaTrackApiException catch (error) {
      _lastActionError = error.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> startJob(
    String jobId, {
    DeviceLocation? phone,
    num? hourMeter,
    String? implement,
    String? overrideId,
  }) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) {
      _lastActionError = 'Your session has expired. Please sign in again.';
      notifyListeners();
      return false;
    }
    try {
      _lastActionError = null;
      final check = await mobileApiClient.startCheck(
        token: token,
        jobId: jobId,
        phone: _phonePayload(phone),
      );
      final checkData = _map(check['data']);
      if (checkData['can_start'] == false) {
        _lastActionError =
            check['message']?.toString() ?? 'The start check did not pass.';
        notifyListeners();
        return false;
      }
      final response = await mobileApiClient.startJob(
        token: token,
        jobId: jobId,
        clientEventId: _eventId(),
        hourMeter: hourMeter,
        implement: implement,
        overrideId: overrideId,
        phone: _phonePayload(phone),
      );
      _applyJobResponse(response);
      _lastActionError = null;
      notifyListeners();
      return true;
    } on KwanzaTrackApiException catch (error) {
      _lastActionError = error.message;
      notifyListeners();
      return false;
    }
  }

  Future<OperatorStartCheckResult?> runStartCheck({
    required String jobId,
    DeviceLocation? phone,
  }) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) {
      _lastActionError = 'Your session has expired. Please sign in again.';
      notifyListeners();
      return const OperatorStartCheckResult(
        canStart: false,
        overrideAllowed: false,
        failed: ['session'],
        checks: [
          OperatorStartCheckItem(
            key: 'session',
            label: 'Signed in with a valid session',
            passed: false,
            detail: 'Please sign in again to continue.',
          ),
        ],
      );
    }

    try {
      _lastActionError = null;
      final response = await mobileApiClient.startCheck(
        token: token,
        jobId: jobId,
        phone: _phonePayload(phone),
      );
      return _startCheckFromJson(_map(response['data']));
    } on KwanzaTrackApiException catch (error) {
      _lastActionError = error.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> requestStartOverride({
    required String jobId,
    required String reason,
    DeviceLocation? phone,
  }) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) {
      _lastActionError = 'Your session has expired. Please sign in again.';
      notifyListeners();
      return false;
    }

    try {
      _lastActionError = null;
      await mobileApiClient.requestOverride(
        token: token,
        jobId: jobId,
        reason: reason,
        phone: _phonePayload(phone),
      );
      notifyListeners();
      return true;
    } on KwanzaTrackApiException catch (error) {
      _lastActionError = error.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> pauseJob({
    required String jobId,
    required String reason,
    DeviceLocation? phone,
  }) async {
    return _runJobAction(
      offline: () => jobById(jobId),
      remote: (token) => mobileApiClient.pauseJob(
        token: token,
        jobId: jobId,
        clientEventId: _eventId(),
        reason: reason,
        phone: _phonePayload(phone),
      ),
    );
  }

  Future<bool> resumeJob(String jobId, {DeviceLocation? phone}) async {
    return _runJobAction(
      offline: () => jobById(jobId),
      remote: (token) => mobileApiClient.resumeJob(
        token: token,
        jobId: jobId,
        clientEventId: _eventId(),
        phone: _phonePayload(phone),
      ),
    );
  }

  Future<bool> completeJob({
    required String jobId,
    required double reportedAcres,
    required String notes,
    num? endHourMeter,
    num? fuelUsedLitres,
    DeviceLocation? phone,
  }) async {
    return _runJobAction(
      offline: () => jobById(jobId),
      remote: (token) => mobileApiClient.completeJob(
        token: token,
        jobId: jobId,
        reportedAcres: reportedAcres,
        clientEventId: _eventId(),
        endHourMeter: endHourMeter,
        fuelUsedLitres: fuelUsedLitres,
        notes: notes,
        phone: _phonePayload(phone),
      ),
    );
  }

  Future<bool> reportProblem({
    required String jobId,
    required OperatorProblemReason reason,
    required String notes,
    DeviceLocation? phone,
  }) async {
    return _runPlainAction(
      (token) => mobileApiClient.reportIssue(
        token: token,
        jobId: jobId,
        text: notes.isEmpty ? reason.label : notes,
        severity: 'warning',
        openTicket: true,
        phone: _phonePayload(phone),
      ),
    );
  }

  void _applyMeResponse(Map<String, Object?> response) {
    final data = _map(response['data']);
    final nestedUser = _map(data['user']);
    final operator = _map(data['operator']);
    final user = nestedUser.isEmpty ? data : nestedUser;
    _operatorName = operator['name']?.toString() ?? user['name']?.toString();
    _operatorEmail = user['email']?.toString();
    _operatorRole = user['role']?.toString();
    if (kDebugMode) {
      debugPrint(
        '[Operator Sync] signed in as name=$_operatorName '
        'email=$_operatorEmail role=$_operatorRole '
        'user_id=${user['id']} operator_id=${operator['id']}',
      );
    }
  }

  void _applyCalendarResponse(Map<String, Object?> response) {
    final data = response['data'];
    final dataMap = _map(data);
    final events = data is List
        ? data
        : dataMap['events'] ?? dataMap['data'] ?? dataMap['items'];
    if (events is! List) {
      if (kDebugMode) {
        debugPrint(
          '[Operator Sync] calendar response has no event list; '
          'data_type=${data.runtimeType} data_keys=${dataMap.keys.toList()}',
        );
      }
      return;
    }
    final remoteJobs = events
        .whereType<Map>()
        .map((event) => _jobFromCalendarEvent(_stringKeyedMap(event)))
        .whereType<OperatorJob>()
        .toList();
    _jobs
      ..clear()
      ..addAll(remoteJobs);
    if (kDebugMode) {
      debugPrint('[Operator Sync] calendar assignments=${remoteJobs.length}');
    }
  }

  void _applyJobsResponse(Map<String, Object?> response) {
    final remoteJobs = _dataList(response)
        .whereType<Map>()
        .map((item) => _jobFromApiJson(_stringKeyedMap(item)))
        .whereType<OperatorJob>()
        .map((job) {
          final existing = maybeJobById(job.id);
          return existing == null
              ? job
              : job.copyWith(
                  acceptedByOperator: existing.acceptedByOperator,
                  trackPoints: existing.trackPoints,
                );
        })
        .toList();
    final merged = <String, OperatorJob>{
      for (final job in _jobs) job.id: job,
      for (final job in remoteJobs) job.id: job,
    };
    _jobs
      ..clear()
      ..addAll(merged.values);
    if (kDebugMode) {
      final meta = _map(response['meta']);
      debugPrint(
        '[Operator Sync] jobs endpoint=${remoteJobs.length} '
        'merged assignments=${_jobs.length} '
        'server_total=${meta['total'] ?? meta['count'] ?? 'unknown'} '
        'mine=${meta['mine'] ?? 'unknown'}',
      );
      for (final job in _jobs) {
        debugPrint(
          '[Operator Sync] job=${job.reference ?? job.id} '
          'tractor=${job.tractorLabel ?? job.tractorId} '
          'status=${job.status.name} scheduled=${job.scheduledAt.toIso8601String()}',
        );
      }
    }
  }

  void _applyTrackerPositionsResponse(Map<String, Object?> response) {
    final updated = <String, TractorTrackerPosition>{};
    final implementsByTractor = <String, List<String>>{};
    for (final item in _dataList(response).whereType<Map>()) {
      final tractor = _stringKeyedMap(item);
      final tractorId = _text(tractor, const ['id']);
      if (tractorId == null) continue;
      implementsByTractor[tractorId] = _stringList(tractor['implements']);
      final live = _map(tractor['live']);
      final position = _map(live['position']);
      final latitude = _asDouble(position['latitude'] ?? position['lat']);
      final longitude = _asDouble(
        position['longitude'] ?? position['lng'] ?? position['lon'],
      );
      if (latitude == null || longitude == null) continue;

      updated[tractorId] = TractorTrackerPosition(
        tractorId: tractorId,
        trackerImei: _text(tractor, const ['tracker_imei']),
        latitude: latitude,
        longitude: longitude,
        speedKph: _asDouble(position['speed_kph']),
        course: _asDouble(position['course']),
        online: _asBool(live['online']) ?? _asBool(tractor['online']) ?? false,
        fixTime: _dateTime(position['fix_time']),
        ageSeconds: _asInt(position['age_s']),
      );
      if (kDebugMode) {
        final tracker = updated[tractorId]!;
        debugPrint(
          '[Tracker Poll] tractor=$tractorId online=${tracker.online} '
          'age_s=${tracker.ageSeconds} '
          'lat=${tracker.latitude} lng=${tracker.longitude}',
        );
      }
    }

    _trackerPositions
      ..clear()
      ..addAll(updated);
    _tractorImplements
      ..clear()
      ..addAll(implementsByTractor);
    if (kDebugMode) {
      debugPrint(
        '[Tracker Poll] received ${updated.length} tractor position(s)',
      );
    }
  }

  Future<void> _refreshJobPaths(String token) async {
    for (final job in List<OperatorJob>.from(_jobs)) {
      try {
        final response = await mobileApiClient.jobPath(
          token: token,
          jobId: job.id,
        );
        final points = _pathPointsFromResponse(response);
        if (points.isEmpty) continue;
        _replace(job.id, job.copyWith(trackPoints: points), notify: false);
      } on KwanzaTrackApiException {
        // Some jobs have no tracker/path yet; the job list should still load.
      }
    }
  }

  void _applyJobResponse(
    Map<String, Object?> response, {
    bool? acceptedByOperator,
  }) {
    final parsedJob = _jobFromApiJson(_map(response['data']));
    if (parsedJob == null) return;
    var job = parsedJob;
    final index = _jobs.indexWhere((item) => item.id == job.id);
    if (index == -1) {
      if (acceptedByOperator != null) {
        job = job.copyWith(acceptedByOperator: acceptedByOperator);
      }
      _jobs.insert(0, job);
    } else {
      job = job.copyWith(
        acceptedByOperator:
            acceptedByOperator ?? _jobs[index].acceptedByOperator,
        trackPoints: _jobs[index].trackPoints,
      );
      _jobs[index] = job;
    }
  }

  OperatorJob? _jobFromCalendarEvent(Map<String, Object?> event) {
    final id = _text(event, const ['id', 'job_id', 'reference']);
    if (id == null || id.isEmpty) return null;

    final start = _dateTime(event['start']) ?? DateTime.now();
    final end = _dateTime(event['end']);
    final acres = _number(event, const ['planned_acres', 'acres']);
    final plotLat = _number(event, const ['plot_lat', 'latitude']);
    final plotLng = _number(event, const ['plot_lng', 'longitude']);
    return OperatorJob(
      id: id,
      reference: _text(event, const ['reference', 'job_reference']) ?? id,
      farmerName: _text(event, const ['farmer', 'farmer_name']) ?? 'Farmer',
      farmerPhone: _text(event, const ['farmer_phone', 'phone']),
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
      tractorId:
          _text(event, const ['tractor_id', 'tractor', 'tractor_code']) ??
          'Unassigned',
      tractorLabel: _text(event, const ['tractor', 'tractor_code']),
      timeWindow: _text(event, const ['window']),
      plannedAcres: acres?.toDouble(),
      scheduledAt: start,
      scheduledEndAt: end,
      status: _jobStatus(event['status']?.toString()),
    );
  }

  OperatorJob? _jobFromApiJson(Map<String, Object?> json) {
    final id = _text(json, const ['id', 'job_id', 'reference']);
    if (id == null || id.isEmpty) return null;

    final start = _scheduledAt(json);
    final end = _scheduledEndAt(json, start);
    final plot = _plotFromJson(_map(json['plot']), id);
    final serviceType = _serviceType(
      _text(_map(json['service_type']), const ['code', 'name']) ??
          _text(json, const ['service_type_code', 'service_type']),
    );
    return OperatorJob(
      id: id,
      reference: _text(json, const ['reference']) ?? id,
      farmerName:
          _text(_map(json['farmer']), const ['name']) ??
          _text(json, const ['farmer', 'farmer_name']) ??
          'Farmer',
      farmerPhone:
          _text(_map(json['farmer']), const ['phone']) ??
          _text(json, const ['farmer_phone', 'phone']),
      serviceType: serviceType,
      plot: plot,
      tractorId:
          _text(_map(json['tractor']), const ['id']) ??
          _text(json, const ['tractor', 'tractor_code', 'tractor_id']) ??
          'Unassigned',
      tractorLabel:
          _text(_map(json['tractor']), const ['label', 'asset_no']) ??
          _text(json, const ['tractor', 'tractor_code']),
      timeWindow: _text(json, const ['window']),
      plannedAcres: _number(json, const ['planned_acres'])?.toDouble(),
      amount: _number(json, const ['amount']),
      currency: _text(json, const ['currency']),
      scheduledAt: start,
      scheduledEndAt: end,
      status: _jobStatus(json['status']?.toString()),
      journeyStartedAt: _dateTime(json['dispatched_at']),
      startedAt: _dateTime(json['started_at']),
      finishedAt: _dateTime(json['completed_at']),
      areaServicedHectares: _number(json, const ['reported_acres'])?.toDouble(),
      completionNotes: _text(json, const ['notes']),
    );
  }

  FarmPlot _plotFromJson(Map<String, Object?> plot, String jobId) {
    final boundaryPoints = _plotBoundaryPoints(plot);
    final areaHa =
        _asDouble(plot['area_ha']) ??
        ((_asDouble(plot['area_acres']) ?? 0) * 0.404686);
    return FarmPlot(
      id: _text(plot, const ['id', 'external_ref']) ?? 'plot-$jobId',
      name: _text(plot, const ['name']) ?? 'Farm plot',
      areaHectares: areaHa,
      location: _text(plot, const ['village', 'ward', 'district']) ?? '',
      boundaryRegistered: boundaryPoints.length >= 3 || plot['mapped'] == true,
      boundaryPoints: boundaryPoints,
    );
  }

  List<BoundaryPoint> _plotBoundaryPoints(Map<String, Object?> plot) {
    final boundary = plot['boundary'];
    if (boundary is List) {
      final points = boundary.indexed
          .map((entry) {
            final point = _map(entry.$2);
            final latitude = _asDouble(point['latitude'] ?? point['lat']);
            final longitude = _asDouble(
              point['longitude'] ?? point['lng'] ?? point['lon'],
            );
            if (latitude == null || longitude == null) return null;
            return BoundaryPoint(
              label: 'Boundary ${entry.$1 + 1}',
              latitude: latitude,
              longitude: longitude,
            );
          })
          .whereType<BoundaryPoint>()
          .toList(growable: false);
      if (points.length >= 3) return points;
    }

    final centroid = _map(plot['centroid']);
    final latitude = _asDouble(centroid['latitude'] ?? centroid['lat']);
    final longitude = _asDouble(
      centroid['longitude'] ?? centroid['lng'] ?? centroid['lon'],
    );
    if (latitude == null || longitude == null) return const [];
    return [
      BoundaryPoint(
        label: 'Plot center',
        latitude: latitude,
        longitude: longitude,
      ),
    ];
  }

  Future<bool> _runJobAction({
    required OperatorJob Function() offline,
    required Future<Map<String, Object?>> Function(String token) remote,
  }) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) {
      _lastActionError = 'Your session has expired. Please sign in again.';
      notifyListeners();
      return false;
    }

    try {
      _lastActionError = null;
      final response = await remote(token);
      _applyJobResponse(response);
      notifyListeners();
      return true;
    } on KwanzaTrackApiException catch (error) {
      _lastActionError = error.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> _runPlainAction(
    Future<Map<String, Object?>> Function(String token) action,
  ) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) {
      _lastActionError = 'Your session has expired. Please sign in again.';
      notifyListeners();
      return false;
    }
    try {
      _lastActionError = null;
      await action(token);
      notifyListeners();
      return true;
    } on KwanzaTrackApiException catch (error) {
      _lastActionError = error.message;
      notifyListeners();
      return false;
    }
  }

  Map<String, Object?> _map(Object? value) {
    if (value is Map) return _stringKeyedMap(value);
    return const {};
  }

  List<Object?> _dataList(Map<String, Object?> response) {
    final data = response['data'];
    if (data is List) return data.cast<Object?>();
    if (data is Map) {
      final nested = _stringKeyedMap(data)['data'];
      if (nested is List) return nested.cast<Object?>();
    }
    return const [];
  }

  List<BoundaryPoint> _pathPointsFromResponse(Map<String, Object?> response) {
    final data = response['data'];
    final points = data is List
        ? data
        : data is Map
        ? _stringKeyedMap(data)['points']
        : null;
    if (points is! List) return const [];

    return points
        .whereType<Map>()
        .map((item) {
          final map = _stringKeyedMap(item);
          final latitude = _asDouble(map['latitude'] ?? map['lat'] ?? map['y']);
          final longitude = _asDouble(
            map['longitude'] ?? map['lng'] ?? map['lon'] ?? map['x'],
          );
          if (latitude == null || longitude == null) return null;
          return BoundaryPoint(
            label:
                _text(map, const ['recorded_at', 'time', 'timestamp']) ?? 'Fix',
            latitude: latitude,
            longitude: longitude,
          );
        })
        .whereType<BoundaryPoint>()
        .toList(growable: false);
  }

  OperatorStartCheckResult _startCheckFromJson(Map<String, Object?> json) {
    final checks = json['checks'] is List
        ? (json['checks'] as List)
              .whereType<Map>()
              .map((item) {
                final map = _stringKeyedMap(item);
                return OperatorStartCheckItem(
                  key: _text(map, const ['key']) ?? '',
                  label: _text(map, const ['label']) ?? 'Check',
                  passed: map['passed'] == true,
                  detail: _text(map, const ['detail']),
                );
              })
              .toList(growable: false)
        : const <OperatorStartCheckItem>[];
    final failed = json['failed'] is List
        ? (json['failed'] as List)
              .map((item) => item.toString())
              .toList(growable: false)
        : const <String>[];
    return OperatorStartCheckResult(
      canStart: json['can_start'] == true,
      overrideAllowed: json['override_allowed'] == true,
      failed: failed,
      checks: checks,
    );
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

  DateTime? _dateTime(Object? value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  DateTime _scheduledAt(Map<String, Object?> json) {
    final date = json['scheduled_date']?.toString();
    final start = json['window_start']?.toString();
    if (date != null && start != null) {
      return DateTime.tryParse('${date}T$start:00') ?? DateTime.now();
    }
    return _dateTime(json['start']) ?? DateTime.now();
  }

  DateTime? _scheduledEndAt(Map<String, Object?> json, DateTime start) {
    final date = json['scheduled_date']?.toString();
    final end = json['window_end']?.toString();
    if (date != null && end != null) {
      final parsed = DateTime.tryParse('${date}T$end:00');
      if (parsed != null) return parsed;
    }
    return _dateTime(json['end']);
  }

  double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  bool? _asBool(Object? value) {
    if (value is bool) return value;
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return null;
  }

  List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return value
        .map((item) => item?.toString().trim())
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  ServiceType _serviceType(String? value) {
    final normalized = value?.toLowerCase() ?? '';
    if (normalized.contains('harrow')) return ServiceType.harrowing;
    if (normalized.contains('plant')) return ServiceType.planting;
    return ServiceType.ploughing;
  }

  OperatorJobStatus _jobStatus(String? value) {
    final normalized = value?.toLowerCase().replaceAll('-', '_') ?? '';
    return switch (normalized) {
      'scheduled' => OperatorJobStatus.scheduled,
      'assigned' => OperatorJobStatus.assigned,
      'dispatched' => OperatorJobStatus.dispatched,
      'en_route' => OperatorJobStatus.enRoute,
      'accepted' => OperatorJobStatus.assigned,
      'arrived' => OperatorJobStatus.arrived,
      'in_progress' || 'started' || 'working' => OperatorJobStatus.inProgress,
      'completed' ||
      'awaiting_verification' ||
      'verified' ||
      'closed' => OperatorJobStatus.completedPendingConfirmation,
      _ => OperatorJobStatus.scheduled,
    };
  }

  String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  String _eventId() => const Uuid().v4();

  Map<String, Object?>? _phonePayload(DeviceLocation? location) {
    if (location == null) return null;
    return {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'accuracy_m': location.accuracyMeters,
    };
  }

  @override
  void dispose() {
    stopTrackerPolling();
    super.dispose();
  }

  void _replace(String jobId, OperatorJob updated, {bool notify = true}) {
    final index = _jobs.indexWhere((job) => job.id == jobId);
    if (index == -1) return;
    _jobs[index] = updated;
    if (notify) notifyListeners();
  }
}
