import '../../../farmer/domain/entities/farm_plot.dart';
import '../../../farmer/domain/entities/service_request.dart';

enum OperationsRequestStatus {
  pending('Pending'),
  approved('Approved'),
  rejected('Rejected'),
  scheduled('Scheduled'),
  cancelled('Cancelled');

  const OperationsRequestStatus(this.label);
  final String label;
}

enum TractorStatus {
  available('Available'),
  scheduled('Scheduled'),
  underMaintenance('Under Maintenance'),
  outOfService('Out of Service');

  const TractorStatus(this.label);
  final String label;

  bool get canSchedule => this == TractorStatus.available;
}

enum OperatorStatus {
  available('Available'),
  assigned('Assigned'),
  unavailable('Unavailable');

  const OperatorStatus(this.label);
  final String label;

  bool get canSchedule => this == OperatorStatus.available;
}

enum JobStatus {
  scheduled('Scheduled'),
  dispatched('Dispatched'),
  enRoute('En route'),
  inProgress('Work in progress'),
  completedPendingConfirmation('Awaiting verification'),
  closed('Closed'),
  cancelled('Cancelled');

  const JobStatus(this.label);
  final String label;
}

enum JobCancellationReason {
  tractorUnavailable('Tractor unavailable'),
  operatorUnavailable('Operator unavailable'),
  weatherConditions('Weather conditions'),
  farmerUnavailable('Farmer unavailable'),
  farmInaccessible('Farm inaccessible'),
  duplicateRequest('Duplicate request'),
  other('Other');

  const JobCancellationReason(this.label);
  final String label;
}

enum JobRescheduleReason {
  tractorBreakdown('Tractor breakdown'),
  weather('Weather'),
  operatorUnavailable('Operator unavailable'),
  farmerRequest('Farmer request'),
  schedulingConflict('Scheduling conflict'),
  other('Other');

  const JobRescheduleReason(this.label);
  final String label;
}

enum JobHistoryAction {
  scheduled('Scheduled'),
  dispatched('Dispatched'),
  cancelled('Cancelled'),
  rescheduled('Rescheduled'),
  operatorProblemReported('Operator problem reported'),
  closed('Closed');

  const JobHistoryAction(this.label);
  final String label;
}

class JobHistoryEntry {
  const JobHistoryEntry({
    required this.id,
    required this.action,
    required this.changedBy,
    required this.changedAt,
    this.previousStatus,
    this.reason,
    this.notes,
    this.previousScheduledAt,
    this.newScheduledAt,
    this.previousTractorId,
    this.newTractorId,
    this.previousOperatorName,
    this.newOperatorName,
  });

  final String id;
  final JobHistoryAction action;
  final String changedBy;
  final DateTime changedAt;
  final JobStatus? previousStatus;
  final String? reason;
  final String? notes;
  final DateTime? previousScheduledAt;
  final DateTime? newScheduledAt;
  final String? previousTractorId;
  final String? newTractorId;
  final String? previousOperatorName;
  final String? newOperatorName;
}

class OperationsServiceRequest {
  const OperationsServiceRequest({
    required this.id,
    required this.farmerName,
    required this.serviceType,
    required this.plot,
    required this.preferredDate,
    required this.status,
    this.notes,
    this.rejectionReason,
    this.rejectionNotes,
  });

  final String id;
  final String farmerName;
  final ServiceType serviceType;
  final FarmPlot plot;
  final DateTime preferredDate;
  final OperationsRequestStatus status;
  final String? notes;
  final String? rejectionReason;
  final String? rejectionNotes;

  OperationsServiceRequest copyWith({
    OperationsRequestStatus? status,
    String? rejectionReason,
    String? rejectionNotes,
  }) {
    return OperationsServiceRequest(
      id: id,
      farmerName: farmerName,
      serviceType: serviceType,
      plot: plot,
      preferredDate: preferredDate,
      status: status ?? this.status,
      notes: notes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      rejectionNotes: rejectionNotes ?? this.rejectionNotes,
    );
  }
}

class TractorAsset {
  const TractorAsset({
    required this.id,
    required this.model,
    required this.status,
    required this.operatingHours,
    this.note,
  });

  final String id;
  final String model;
  final TractorStatus status;
  final int operatingHours;
  final String? note;

  TractorAsset copyWith({
    TractorStatus? status,
    int? operatingHours,
    String? note,
  }) {
    return TractorAsset(
      id: id,
      model: model,
      status: status ?? this.status,
      operatingHours: operatingHours ?? this.operatingHours,
      note: note ?? this.note,
    );
  }
}

class OperatorProfile {
  const OperatorProfile({
    required this.id,
    required this.name,
    required this.status,
    this.note,
  });

  final String id;
  final String name;
  final OperatorStatus status;
  final String? note;
}

class OperationsJob {
  const OperationsJob({
    required this.id,
    required this.requestId,
    required this.farmerName,
    required this.serviceType,
    required this.plot,
    required this.tractor,
    required this.operator,
    required this.scheduledAt,
    required this.estimatedHours,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.alert,
    this.history = const [],
  });

  final String id;
  final String requestId;
  final String farmerName;
  final ServiceType serviceType;
  final FarmPlot plot;
  final TractorAsset tractor;
  final OperatorProfile operator;
  final DateTime scheduledAt;
  final int estimatedHours;
  final JobStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? alert;
  final List<JobHistoryEntry> history;

  OperationsJob copyWith({
    TractorAsset? tractor,
    OperatorProfile? operator,
    DateTime? scheduledAt,
    JobStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    String? alert,
    List<JobHistoryEntry>? history,
  }) {
    return OperationsJob(
      id: id,
      requestId: requestId,
      farmerName: farmerName,
      serviceType: serviceType,
      plot: plot,
      tractor: tractor ?? this.tractor,
      operator: operator ?? this.operator,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      estimatedHours: estimatedHours,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      alert: alert ?? this.alert,
      history: history ?? this.history,
    );
  }
}
