import 'package:flutter/foundation.dart';

import '../../domain/entities/farm_plot.dart';
import '../../domain/entities/service_request.dart';

class FarmerLocalRepository extends ChangeNotifier {
  FarmerLocalRepository.seeded()
    : _plots = [
        const FarmPlot(
          id: 'plot-kibaha',
          name: 'Kibaha Farm',
          areaHectares: 4.2,
          location: 'Kibaha, Pwani',
          boundaryRegistered: true,
          boundaryPoints: [
            BoundaryPoint(
              label: 'North west',
              latitude: -6.8001,
              longitude: 38.9112,
            ),
            BoundaryPoint(
              label: 'North east',
              latitude: -6.7998,
              longitude: 38.9189,
            ),
            BoundaryPoint(
              label: 'South east',
              latitude: -6.8063,
              longitude: 38.9201,
            ),
            BoundaryPoint(
              label: 'South west',
              latitude: -6.8071,
              longitude: 38.9120,
            ),
          ],
        ),
        const FarmPlot(
          id: 'plot-mlandizi',
          name: 'Mlandizi Farm',
          areaHectares: 2.8,
          location: 'Mlandizi',
          boundaryRegistered: false,
          boundaryPoints: [],
        ),
      ],
      _requests = [
        ServiceRequest(
          id: 'SR-1024',
          serviceType: ServiceType.ploughing,
          plotId: 'plot-kibaha',
          requestedOn: DateTime(2026, 9, 24),
          preferredDate: DateTime(2026, 9, 28),
          alternativeDate: DateTime(2026, 9, 29),
          status: RequestStatus.tractorScheduled,
          scheduledAt: DateTime(2026, 9, 28, 8),
          tractorCode: 'TFC-TR-024',
          operatorName: 'John M.',
        ),
        ServiceRequest(
          id: 'SR-1025',
          serviceType: ServiceType.harrowing,
          plotId: 'plot-mlandizi',
          requestedOn: DateTime(2026, 9, 24),
          preferredDate: DateTime(2026, 9, 30),
          status: RequestStatus.awaitingApproval,
        ),
        ServiceRequest(
          id: 'SR-1021',
          serviceType: ServiceType.ploughing,
          plotId: 'plot-kibaha',
          requestedOn: DateTime(2026, 9, 20),
          preferredDate: DateTime(2026, 9, 25),
          status: RequestStatus.workStarted,
          scheduledAt: DateTime(2026, 9, 25, 8),
          tractorCode: 'TFC-TR-019',
          operatorName: 'Asha K.',
          startedAt: DateTime(2026, 9, 25, 9, 4),
        ),
        ServiceRequest(
          id: 'SR-1019',
          serviceType: ServiceType.harrowing,
          plotId: 'plot-kibaha',
          requestedOn: DateTime(2026, 9, 18),
          preferredDate: DateTime(2026, 9, 21),
          status: RequestStatus.completed,
          scheduledAt: DateTime(2026, 9, 21, 8),
          tractorCode: 'TFC-TR-011',
          operatorName: 'John M.',
          startedAt: DateTime(2026, 9, 21, 9, 4),
          finishedAt: DateTime(2026, 9, 21, 12, 36),
          areaServicedHectares: 4.1,
        ),
      ];

  final List<FarmPlot> _plots;
  final List<ServiceRequest> _requests;

  List<FarmPlot> get plots => List.unmodifiable(_plots);

  List<RequestWithPlot> get requests {
    return _requests
        .map(
          (request) =>
              RequestWithPlot(request: request, plot: plotById(request.plotId)),
        )
        .toList(growable: false);
  }

  List<RequestWithPlot> get activeRequests {
    return requests.where((item) => !item.request.isCompleted).toList();
  }

  List<RequestWithPlot> get completedRequests {
    return requests.where((item) => item.request.isCompleted).toList();
  }

  RequestWithPlot? get featuredRequest {
    if (activeRequests.isEmpty) return null;
    return activeRequests.first;
  }

  FarmPlot plotById(String id) {
    return _plots.firstWhere((plot) => plot.id == id);
  }

  ServiceRequest requestById(String id) {
    return _requests.firstWhere((request) => request.id == id);
  }

  String addPlot({
    required String name,
    required String location,
    required double areaHectares,
    required List<BoundaryPoint> boundaryPoints,
  }) {
    final id = 'plot-${DateTime.now().microsecondsSinceEpoch}';
    _plots.add(
      FarmPlot(
        id: id,
        name: name,
        areaHectares: areaHectares,
        location: location,
        boundaryRegistered: boundaryPoints.length >= 4,
        boundaryPoints: List.unmodifiable(boundaryPoints),
      ),
    );
    notifyListeners();
    return id;
  }

  String submitRequest({
    required String plotId,
    required ServiceType serviceType,
    required DateTime preferredDate,
    DateTime? alternativeDate,
    String? notes,
  }) {
    final nextNumber = 1026 + _requests.length;
    final id = 'SR-$nextNumber';
    _requests.insert(
      0,
      ServiceRequest(
        id: id,
        serviceType: serviceType,
        plotId: plotId,
        requestedOn: DateTime(2026, 9, 24),
        preferredDate: preferredDate,
        alternativeDate: alternativeDate,
        notes: notes,
        status: RequestStatus.awaitingApproval,
      ),
    );
    notifyListeners();
    return id;
  }

  void confirmWork(String requestId) {
    _replaceRequest(
      requestId,
      requestById(requestId).copyWith(status: RequestStatus.confirmed),
    );
  }

  void disputeWork({
    required String requestId,
    required String reason,
    required String description,
  }) {
    _replaceRequest(
      requestId,
      requestById(requestId).copyWith(
        status: RequestStatus.disputed,
        disputeReason: reason,
        disputeDescription: description,
      ),
    );
  }

  void _replaceRequest(String id, ServiceRequest updated) {
    final index = _requests.indexWhere((request) => request.id == id);
    if (index == -1) return;
    _requests[index] = updated;
    notifyListeners();
  }
}
