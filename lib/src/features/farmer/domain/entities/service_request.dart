import 'farm_plot.dart';

enum ServiceType {
  ploughing('Ploughing'),
  harrowing('Harrowing'),
  planting('Planting');

  const ServiceType(this.label);
  final String label;
}

enum RequestStatus {
  awaitingApproval('Awaiting Approval'),
  approved('Approved'),
  tractorScheduled('Tractor scheduled'),
  operatorDispatched('Operator dispatched'),
  workStarted('Work in progress'),
  completed('Completed'),
  confirmed('Confirmed'),
  disputed('Disputed');

  const RequestStatus(this.label);
  final String label;
}

class ServiceRequest {
  const ServiceRequest({
    required this.id,
    required this.serviceType,
    required this.plotId,
    required this.requestedOn,
    required this.preferredDate,
    required this.status,
    this.alternativeDate,
    this.notes,
    this.scheduledAt,
    this.tractorCode,
    this.operatorName,
    this.startedAt,
    this.finishedAt,
    this.areaServicedHectares,
    this.disputeReason,
    this.disputeDescription,
  });

  final String id;
  final ServiceType serviceType;
  final String plotId;
  final DateTime requestedOn;
  final DateTime preferredDate;
  final RequestStatus status;
  final DateTime? alternativeDate;
  final String? notes;
  final DateTime? scheduledAt;
  final String? tractorCode;
  final String? operatorName;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final double? areaServicedHectares;
  final String? disputeReason;
  final String? disputeDescription;

  bool get hasAssignment =>
      tractorCode != null && operatorName != null && scheduledAt != null;

  bool get isCompleted =>
      status == RequestStatus.completed ||
      status == RequestStatus.confirmed ||
      status == RequestStatus.disputed;

  ServiceRequest copyWith({
    RequestStatus? status,
    String? disputeReason,
    String? disputeDescription,
  }) {
    return ServiceRequest(
      id: id,
      serviceType: serviceType,
      plotId: plotId,
      requestedOn: requestedOn,
      preferredDate: preferredDate,
      status: status ?? this.status,
      alternativeDate: alternativeDate,
      notes: notes,
      scheduledAt: scheduledAt,
      tractorCode: tractorCode,
      operatorName: operatorName,
      startedAt: startedAt,
      finishedAt: finishedAt,
      areaServicedHectares: areaServicedHectares,
      disputeReason: disputeReason ?? this.disputeReason,
      disputeDescription: disputeDescription ?? this.disputeDescription,
    );
  }
}

class RequestWithPlot {
  const RequestWithPlot({required this.request, required this.plot});

  final ServiceRequest request;
  final FarmPlot plot;
}
