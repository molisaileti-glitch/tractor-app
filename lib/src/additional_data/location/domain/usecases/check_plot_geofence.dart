import 'dart:math' as math;

import '../../../../features/farmer/domain/entities/farm_plot.dart';
import '../entities/device_location.dart';

class PlotGeofenceResult {
  const PlotGeofenceResult({
    required this.isInside,
    required this.distanceFromPlotMeters,
    required this.location,
  });

  final bool isInside;
  final double distanceFromPlotMeters;
  final DeviceLocation location;
}

class CheckPlotGeofence {
  const CheckPlotGeofence();

  PlotGeofenceResult call({
    required FarmPlot plot,
    required DeviceLocation location,
  }) {
    bool valid(double latitude, double longitude) =>
        latitude.isFinite &&
        longitude.isFinite &&
        latitude.abs() <= 90 &&
        longitude.abs() <= 180;
    final age = DateTime.now().difference(location.recordedAt).inSeconds;
    if (plot.boundaryPoints.length < 3 ||
        !valid(location.latitude, location.longitude) ||
        age < -30 ||
        age > 180 ||
        plot.boundaryPoints.any(
          (point) => !valid(point.latitude, point.longitude),
        )) {
      return PlotGeofenceResult(
        isInside: false,
        distanceFromPlotMeters: double.infinity,
        location: location,
      );
    }

    final distance = _nearestBoundaryDistance(plot.boundaryPoints, location);
    // Points on an edge belong to the farm. The small numerical epsilon here
    // is not the backend's configured geofence tolerance.
    final isInside =
        distance <= 0.05 || _containsPoint(plot.boundaryPoints, location);
    return PlotGeofenceResult(
      isInside: isInside,
      distanceFromPlotMeters: isInside ? 0 : distance,
      location: location,
    );
  }

  bool _containsPoint(List<BoundaryPoint> polygon, DeviceLocation point) {
    var inside = false;
    var previousIndex = polygon.length - 1;

    for (var index = 0; index < polygon.length; index++) {
      final current = polygon[index];
      final previous = polygon[previousIndex];
      final crossesLatitude =
          (current.latitude > point.latitude) !=
          (previous.latitude > point.latitude);

      if (crossesLatitude) {
        final intersectionLongitude =
            (previous.longitude - current.longitude) *
                (point.latitude - current.latitude) /
                (previous.latitude - current.latitude) +
            current.longitude;
        if (point.longitude < intersectionLongitude) {
          inside = !inside;
        }
      }
      previousIndex = index;
    }

    return inside;
  }

  double _nearestBoundaryDistance(
    List<BoundaryPoint> boundary,
    DeviceLocation location,
  ) {
    const earthRadiusMeters = 6371000.0;
    final longitudeScale = math.cos(_toRadians(location.latitude));
    double x(BoundaryPoint point) =>
        earthRadiusMeters *
        _toRadians(point.longitude - location.longitude) *
        longitudeScale;
    double y(BoundaryPoint point) =>
        earthRadiusMeters * _toRadians(point.latitude - location.latitude);
    var nearest = double.infinity;
    for (var index = 0; index < boundary.length; index++) {
      final start = boundary[index];
      final end = boundary[(index + 1) % boundary.length];
      final ax = x(start), ay = y(start);
      final dx = x(end) - ax, dy = y(end) - ay;
      final lengthSquared = dx * dx + dy * dy;
      final fraction = lengthSquared == 0
          ? 0.0
          : (-(ax * dx + ay * dy) / lengthSquared).clamp(0.0, 1.0);
      final px = ax + fraction * dx, py = ay + fraction * dy;
      nearest = math.min(nearest, math.sqrt(px * px + py * py));
    }
    return nearest;
  }

  double _toRadians(double value) {
    return value * math.pi / 180;
  }
}
