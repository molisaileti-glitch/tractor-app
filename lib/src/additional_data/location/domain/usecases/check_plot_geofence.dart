import 'dart:math' as math;

import '../../../../features/farmer/domain/entities/farm_plot.dart';
import '../entities/device_location.dart';

enum PlotGeofenceState {
  insideBoundary,
  withinTolerance,
  uncertain,
  outsideAllowedArea,
  unavailable,
}

class PlotGeofenceResult {
  const PlotGeofenceResult({
    required this.state,
    required this.distanceFromPlotMeters,
    required this.location,
  });

  final PlotGeofenceState state;
  final double distanceFromPlotMeters;
  final DeviceLocation location;

  bool get isInside => state == PlotGeofenceState.insideBoundary;
  bool get isWithinAllowedArea =>
      state == PlotGeofenceState.insideBoundary ||
      state == PlotGeofenceState.withinTolerance;
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
        !location.accuracyMeters.isFinite ||
        location.accuracyMeters < 0 ||
        location.isMocked ||
        age < -30 ||
        age > 180 ||
        plot.boundaryPoints.any(
          (point) => !valid(point.latitude, point.longitude),
        )) {
      return PlotGeofenceResult(
        state: PlotGeofenceState.unavailable,
        distanceFromPlotMeters: double.infinity,
        location: location,
      );
    }

    final distance = _nearestBoundaryDistance(plot.boundaryPoints, location);
    // Points on an edge belong to the farm. The small numerical epsilon here
    // is not the backend's configured geofence tolerance.
    final isInside =
        distance <= 0.05 || _containsPoint(plot.boundaryPoints, location);
    final tolerance = plot.toleranceMeters.isFinite
        ? math.max(0, plot.toleranceMeters)
        : 0.0;
    final accuracy = location.accuracyMeters.isFinite
        ? math.max(0, location.accuracyMeters)
        : 0.0;
    final state = isInside
        ? PlotGeofenceState.insideBoundary
        : distance <= tolerance
        ? PlotGeofenceState.withinTolerance
        : distance <= tolerance + accuracy
        ? PlotGeofenceState.uncertain
        : PlotGeofenceState.outsideAllowedArea;
    return PlotGeofenceResult(
      state: state,
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
