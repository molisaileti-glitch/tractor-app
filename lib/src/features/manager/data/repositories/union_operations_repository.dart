import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../farmer/domain/entities/farm_plot.dart';
import '../../../farmer/domain/entities/service_request.dart';
import '../remote/service_orders_remote_data_source.dart';
import '../../domain/entities/operations_models.dart';

class UnionOperationsRepository extends ChangeNotifier {
  UnionOperationsRepository.seeded({
    ServiceOrdersRemoteDataSource? remoteDataSource,
  }) : remoteDataSource =
           remoteDataSource ?? const ServiceOrdersRemoteDataSource(),
       _requests = _seedRequests(),
       _tractors = _seedTractors(),
       _operators = _seedOperators(),
       _jobs = _seedJobs();

  final ServiceOrdersRemoteDataSource remoteDataSource;
  final List<OperationsServiceRequest> _requests;
  final List<TractorAsset> _tractors;
  final List<OperatorProfile> _operators;
  final List<OperationsJob> _jobs;

  List<OperationsServiceRequest> get requests => List.unmodifiable(_requests);
  List<TractorAsset> get tractors => List.unmodifiable(_tractors);
  List<OperatorProfile> get operators => List.unmodifiable(_operators);
  List<OperationsJob> get jobs => List.unmodifiable(_jobs);

  Future<ServiceOrdersFetchResult> fetchRemoteServiceOrders() {
    return remoteDataSource.fetchServiceOrders();
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
              job.status == JobStatus.inProgress,
        )
        .toList();
  }

  int get pendingRequestCount {
    return _requests
        .where((request) => request.status == OperationsRequestStatus.pending)
        .length;
  }

  int get completedTodayCount {
    return _jobs
        .where(
          (job) =>
              job.status == JobStatus.completedPendingConfirmation ||
              job.status == JobStatus.closed,
        )
        .length;
  }

  int get maintenanceCount {
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

  void approveRequest(String id) {
    _replaceRequest(
      id,
      requestById(id).copyWith(status: OperationsRequestStatus.approved),
    );
  }

  void rejectRequest({
    required String id,
    required String reason,
    required String notes,
  }) {
    _replaceRequest(
      id,
      requestById(id).copyWith(
        status: OperationsRequestStatus.rejected,
        rejectionReason: reason,
        rejectionNotes: notes,
      ),
    );
  }

  void cancelRequest({
    required String id,
    required String reason,
    required String notes,
  }) {
    _replaceRequest(
      id,
      requestById(id).copyWith(
        status: OperationsRequestStatus.cancelled,
        rejectionReason: reason,
        rejectionNotes: notes,
      ),
    );
  }

  String scheduleRequest({
    required String requestId,
    required String tractorId,
    required String operatorId,
    required DateTime scheduledAt,
    required int estimatedHours,
  }) {
    final request = requestById(requestId);
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
            changedBy: 'Manager: Asha',
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

  void dispatchJob(String jobId) {
    final job = jobById(jobId);
    _replaceJob(
      jobId,
      job.copyWith(
        status: JobStatus.dispatched,
        history: [
          ...job.history,
          _history(
            action: JobHistoryAction.dispatched,
            changedBy: 'Manager: Asha',
            previousStatus: job.status,
          ),
        ],
      ),
    );
  }

  void closeJob(String jobId) {
    final job = jobById(jobId);
    _replaceJob(
      jobId,
      job.copyWith(
        status: JobStatus.closed,
        history: [
          ...job.history,
          _history(
            action: JobHistoryAction.closed,
            changedBy: 'Manager: Asha',
            previousStatus: job.status,
          ),
        ],
      ),
    );
  }

  void cancelJob({
    required String jobId,
    required JobCancellationReason reason,
    required String notes,
  }) {
    final job = jobById(jobId);
    _replaceJob(
      jobId,
      job.copyWith(
        status: JobStatus.cancelled,
        alert: 'Cancelled: ${reason.label}',
        history: [
          ...job.history,
          _history(
            action: JobHistoryAction.cancelled,
            changedBy: 'Manager: Asha',
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

  void rescheduleJob({
    required String jobId,
    required DateTime newScheduledAt,
    required String tractorId,
    required String operatorId,
    required JobRescheduleReason reason,
    required String notes,
  }) {
    final job = jobById(jobId);
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
            changedBy: 'Manager: Asha',
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
      changedAt: DateTime(2026, 9, 28, 7, 20),
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
    return [
      OperationsServiceRequest(
        id: 'SR-1024',
        farmerName: 'Juma Ally',
        serviceType: ServiceType.ploughing,
        plot: _kibahaPlot,
        preferredDate: DateTime(2026, 9, 28),
        status: OperationsRequestStatus.pending,
        notes: 'Please start from the eastern side.',
      ),
      OperationsServiceRequest(
        id: 'SR-1025',
        farmerName: 'Anna John',
        serviceType: ServiceType.harrowing,
        plot: _mlandiziPlot,
        preferredDate: DateTime(2026, 9, 28),
        status: OperationsRequestStatus.pending,
      ),
      OperationsServiceRequest(
        id: 'SR-1026',
        farmerName: 'Musa Said',
        serviceType: ServiceType.ploughing,
        plot: _bagamoyoPlot,
        preferredDate: DateTime(2026, 9, 29),
        status: OperationsRequestStatus.pending,
      ),
      OperationsServiceRequest(
        id: 'SR-1027',
        farmerName: 'Fatma Salum',
        serviceType: ServiceType.planting,
        plot: _kisarawePlot,
        preferredDate: DateTime(2026, 9, 30),
        status: OperationsRequestStatus.approved,
      ),
    ];
  }

  static List<TractorAsset> _seedTractors() {
    return const [
      TractorAsset(
        id: 'TR-001',
        model: 'Massey Ferguson',
        status: TractorStatus.available,
        operatingHours: 1230,
      ),
      TractorAsset(
        id: 'TR-002',
        model: 'John Deere',
        status: TractorStatus.underMaintenance,
        operatingHours: 1845,
        note: 'Engine service',
      ),
      TractorAsset(
        id: 'TR-003',
        model: 'New Holland',
        status: TractorStatus.scheduled,
        operatingHours: 990,
        note: 'Scheduled 08:00-11:00',
      ),
      TractorAsset(
        id: 'TR-004',
        model: 'Kubota M7040',
        status: TractorStatus.available,
        operatingHours: 740,
      ),
    ];
  }

  static List<OperatorProfile> _seedOperators() {
    return const [
      OperatorProfile(
        id: 'op-john',
        name: 'John M.',
        status: OperatorStatus.available,
      ),
      OperatorProfile(
        id: 'op-peter',
        name: 'Peter K.',
        status: OperatorStatus.assigned,
        note: 'Assigned until 11:00',
      ),
      OperatorProfile(
        id: 'op-hassan',
        name: 'Hassan A.',
        status: OperatorStatus.unavailable,
      ),
      OperatorProfile(
        id: 'op-asha',
        name: 'Asha K.',
        status: OperatorStatus.available,
      ),
    ];
  }

  static List<OperationsJob> _seedJobs() {
    final tractors = _seedTractors();
    final operators = _seedOperators();
    return [
      OperationsJob(
        id: 'JOB-201',
        requestId: 'SR-1019',
        farmerName: 'Juma Ally',
        serviceType: ServiceType.ploughing,
        plot: _kibahaPlot,
        tractor: tractors[0],
        operator: operators[0],
        scheduledAt: DateTime(2026, 9, 28, 8),
        estimatedHours: 4,
        status: JobStatus.dispatched,
        startedAt: DateTime(2026, 9, 28, 9, 4),
      ),
      OperationsJob(
        id: 'JOB-202',
        requestId: 'SR-1020',
        farmerName: 'Anna John',
        serviceType: ServiceType.harrowing,
        plot: _mlandiziPlot,
        tractor: tractors[2],
        operator: operators[1],
        scheduledAt: DateTime(2026, 9, 28, 10),
        estimatedHours: 3,
        status: JobStatus.scheduled,
      ),
      OperationsJob(
        id: 'JOB-203',
        requestId: 'SR-1018',
        farmerName: 'Musa Said',
        serviceType: ServiceType.ploughing,
        plot: _bagamoyoPlot,
        tractor: tractors[3],
        operator: operators[3],
        scheduledAt: DateTime(2026, 9, 28, 14),
        estimatedHours: 4,
        status: JobStatus.completedPendingConfirmation,
        alert: 'Completed job awaiting verification',
      ),
      OperationsJob(
        id: 'JOB-204',
        requestId: 'SR-1017',
        farmerName: 'Rehema Issa',
        serviceType: ServiceType.ploughing,
        plot: _kisarawePlot,
        tractor: tractors[3],
        operator: operators[3],
        scheduledAt: DateTime(2026, 9, 28, 9),
        estimatedHours: 4,
        status: JobStatus.inProgress,
        startedAt: DateTime(2026, 9, 28, 9, 4),
        alert: 'Outside assigned plot',
      ),
    ];
  }
}

const _kibahaPlot = FarmPlot(
  id: 'plot-kibaha',
  name: 'Kibaha Farm',
  areaHectares: 4.2,
  location: 'Kibaha, Pwani',
  boundaryRegistered: true,
  boundaryPoints: [
    BoundaryPoint(label: 'North west', latitude: -6.8001, longitude: 38.9112),
    BoundaryPoint(label: 'North east', latitude: -6.7998, longitude: 38.9189),
    BoundaryPoint(label: 'South east', latitude: -6.8063, longitude: 38.9201),
    BoundaryPoint(label: 'South west', latitude: -6.8071, longitude: 38.9120),
  ],
);

const _mlandiziPlot = FarmPlot(
  id: 'plot-mlandizi',
  name: 'Mlandizi Farm',
  areaHectares: 2.8,
  location: 'Mlandizi',
  boundaryRegistered: true,
  boundaryPoints: [
    BoundaryPoint(label: 'North west', latitude: -6.7291, longitude: 38.7420),
    BoundaryPoint(label: 'North east', latitude: -6.7287, longitude: 38.7488),
    BoundaryPoint(label: 'South east', latitude: -6.7336, longitude: 38.7494),
    BoundaryPoint(label: 'South west', latitude: -6.7341, longitude: 38.7424),
  ],
);

const _bagamoyoPlot = FarmPlot(
  id: 'plot-bagamoyo',
  name: 'Bagamoyo Farm',
  areaHectares: 6.1,
  location: 'Bagamoyo',
  boundaryRegistered: true,
  boundaryPoints: [
    BoundaryPoint(label: 'North west', latitude: -6.4301, longitude: 38.9044),
    BoundaryPoint(label: 'North east', latitude: -6.4288, longitude: 38.9141),
    BoundaryPoint(label: 'South east', latitude: -6.4380, longitude: 38.9160),
    BoundaryPoint(label: 'South west', latitude: -6.4391, longitude: 38.9050),
  ],
);

const _kisarawePlot = FarmPlot(
  id: 'plot-kisarawe',
  name: 'Kisarawe Farm',
  areaHectares: 3.7,
  location: 'Kisarawe',
  boundaryRegistered: true,
  boundaryPoints: [
    BoundaryPoint(label: 'North west', latitude: -6.9010, longitude: 39.0601),
    BoundaryPoint(label: 'North east', latitude: -6.9002, longitude: 39.0668),
    BoundaryPoint(label: 'South east', latitude: -6.9060, longitude: 39.0672),
    BoundaryPoint(label: 'South west', latitude: -6.9064, longitude: 39.0608),
  ],
);
