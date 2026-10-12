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
    if (plot.boundaryPoints.length < 3) {
      return PlotGeofenceResult(
        isInside: false,
        distanceFromPlotMeters: double.infinity,
        location: location,
      );
    }

    final isInside = _containsPoint(plot.boundaryPoints, location);
    return PlotGeofenceResult(
      isInside: isInside,
      distanceFromPlotMeters: isInside
          ? 0
          : _nearestBoundaryDistance(plot.boundaryPoints, location),
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
    return boundary
        .map(
          (point) => _distanceMeters(
            location.latitude,
            location.longitude,
            point.latitude,
            point.longitude,
          ),
        )
        .reduce(math.min);
  }

  double _distanceMeters(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const earthRadiusMeters = 6371000.0;
    final startLatRadians = _toRadians(startLatitude);
    final endLatRadians = _toRadians(endLatitude);
    final deltaLatRadians = _toRadians(endLatitude - startLatitude);
    final deltaLongRadians = _toRadians(endLongitude - startLongitude);
    final a =
        math.sin(deltaLatRadians / 2) * math.sin(deltaLatRadians / 2) +
        math.cos(startLatRadians) *
            math.cos(endLatRadians) *
            math.sin(deltaLongRadians / 2) *
            math.sin(deltaLongRadians / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  double _toRadians(double value) {
    return value * math.pi / 180;
  }
}
