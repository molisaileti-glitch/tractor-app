import '../../../farmer/domain/entities/farm_plot.dart';
import '../../../farmer/domain/entities/service_request.dart';

enum OperatorJobStatus {
  scheduled('Scheduled'),
  dispatched('Dispatched'),
  enRoute('En route'),
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
    required this.status,
    this.journeyStartedAt,
    this.startedAt,
    this.finishedAt,
    this.areaServicedHectares,
    this.completionNotes,
    this.problemReports = const [],
  });

  final String id;
  final String farmerName;
  final ServiceType serviceType;
  final FarmPlot plot;
  final String tractorId;
  final DateTime scheduledAt;
  final OperatorJobStatus status;
  final DateTime? journeyStartedAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final double? areaServicedHectares;
  final String? completionNotes;
  final List<OperatorProblemReport> problemReports;

  bool get isComplete =>
      status == OperatorJobStatus.completedPendingConfirmation;

  OperatorJob copyWith({
    OperatorJobStatus? status,
    DateTime? journeyStartedAt,
    DateTime? startedAt,
    DateTime? finishedAt,
    double? areaServicedHectares,
    String? completionNotes,
    List<OperatorProblemReport>? problemReports,
  }) {
    return OperatorJob(
      id: id,
      farmerName: farmerName,
      serviceType: serviceType,
      plot: plot,
      tractorId: tractorId,
      scheduledAt: scheduledAt,
      status: status ?? this.status,
      journeyStartedAt: journeyStartedAt ?? this.journeyStartedAt,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      areaServicedHectares: areaServicedHectares ?? this.areaServicedHectares,
      completionNotes: completionNotes ?? this.completionNotes,
      problemReports: problemReports ?? this.problemReports,
    );
  }
}
