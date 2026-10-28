class FarmPlot {
  const FarmPlot({
    required this.id,
    required this.name,
    required this.areaHectares,
    required this.location,
    required this.boundaryRegistered,
    required this.boundaryPoints,
    this.toleranceMeters = 0,
  });

  final String id;
  final String name;
  final double areaHectares;
  final String location;
  final bool boundaryRegistered;
  final List<BoundaryPoint> boundaryPoints;
  final double toleranceMeters;
}

class BoundaryPoint {
  const BoundaryPoint({
    required this.label,
    required this.latitude,
    required this.longitude,
  });

  final String label;
  final double latitude;
  final double longitude;
}
