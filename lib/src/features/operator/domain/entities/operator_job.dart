import '../../../farmer/domain/entities/farm_plot.dart';
import '../../../farmer/domain/entities/service_request.dart';

enum OperatorJobStatus {
  scheduled('Scheduled'),
  assigned('Assigned'),
  dispatched('Dispatched'),
  enRoute('En route'),
  arrived('Arrived'),
  inProgress('Job in progress'),
  completedPendingConfirmation('Completed pending confirmation');

  const OperatorJobStatus(this.label);
  final String label;
}

enum OperatorProblemReason {
  tractorBreakdown('Tractor breakdown'),
  farmInaccessible('Farm inaccessible'),
  farmerUnavailable('Farmer unavailable'),
  weatherConditions('Weather conditions'),
  safetyIssue('Safety issue'),
  wrongFarmLocation('Wrong farm/location'),
  other('Other');

  const OperatorProblemReason(this.label);
  final String label;
}

class OperatorProblemReport {
  const OperatorProblemReport({
    required this.id,
    required this.reason,
    required this.notes,
    required this.reportedAt,
  });

  final String id;
  final OperatorProblemReason reason;
  final String notes;
  final DateTime reportedAt;
}

class OperatorJob {
  const OperatorJob({
    required this.id,
    required this.farmerName,
    required this.serviceType,
    required this.plot,
    required this.tractorId,
    required this.scheduledAt,
    this.scheduledEndAt,
    required this.status,
    this.reference,
    this.farmerPhone,
    this.tractorLabel,
    this.timeWindow,
    this.plannedAcres,
    this.amount,
    this.currency,
    this.acceptedByOperator = false,
    this.journeyStartedAt,
    this.startedAt,
    this.finishedAt,
    this.areaServicedHectares,
    this.completionNotes,
    this.trackPoints = const [],
    this.problemReports = const [],
  });

  final String id;
  final String farmerName;
  final ServiceType serviceType;
  final FarmPlot plot;
  final String tractorId;
  final String? reference;
  final String? farmerPhone;
  final String? tractorLabel;
  final String? timeWindow;
  final double? plannedAcres;
  final num? amount;
  final String? currency;
  final bool acceptedByOperator;
  final DateTime scheduledAt;
  final DateTime? scheduledEndAt;
  final OperatorJobStatus status;
  final DateTime? journeyStartedAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final double? areaServicedHectares;
  final String? completionNotes;
  final List<BoundaryPoint> trackPoints;
  final List<OperatorProblemReport> problemReports;

  bool get isComplete =>
      status == OperatorJobStatus.completedPendingConfirmation;

  OperatorJob copyWith({
    OperatorJobStatus? status,
    String? reference,
    String? farmerPhone,
    String? tractorLabel,
    String? timeWindow,
    double? plannedAcres,
    num? amount,
    String? currency,
    bool? acceptedByOperator,
    DateTime? scheduledEndAt,
    DateTime? journeyStartedAt,
    DateTime? startedAt,
    DateTime? finishedAt,
    double? areaServicedHectares,
    String? completionNotes,
    List<BoundaryPoint>? trackPoints,
    List<OperatorProblemReport>? problemReports,
  }) {
    return OperatorJob(
      id: id,
      farmerName: farmerName,
      serviceType: serviceType,
      plot: plot,
      tractorId: tractorId,
      reference: reference ?? this.reference,
      farmerPhone: farmerPhone ?? this.farmerPhone,
      tractorLabel: tractorLabel ?? this.tractorLabel,
      timeWindow: timeWindow ?? this.timeWindow,
      plannedAcres: plannedAcres ?? this.plannedAcres,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      acceptedByOperator: acceptedByOperator ?? this.acceptedByOperator,
      scheduledAt: scheduledAt,
      scheduledEndAt: scheduledEndAt ?? this.scheduledEndAt,
      status: status ?? this.status,
      journeyStartedAt: journeyStartedAt ?? this.journeyStartedAt,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      areaServicedHectares: areaServicedHectares ?? this.areaServicedHectares,
      completionNotes: completionNotes ?? this.completionNotes,
      trackPoints: trackPoints ?? this.trackPoints,
      problemReports: problemReports ?? this.problemReports,
    );
  }
}

class OperatorStartCheckResult {
  const OperatorStartCheckResult({
    required this.canStart,
    required this.overrideAllowed,
    required this.failed,
    required this.checks,
  });

  final bool canStart;
  final bool overrideAllowed;
  final List<String> failed;
  final List<OperatorStartCheckItem> checks;
}

class OperatorStartCheckItem {
  const OperatorStartCheckItem({
    required this.key,
    required this.label,
    required this.passed,
    this.detail,
  });

  final String key;
  final String label;
  final bool passed;
  final String? detail;
}
