import 'dart:math' as math;

/// Group only reliable nearby fixes, without interpreting proximity as boarding.
bool canGroupOperatorAndTractor({
  required double phoneLatitude,
  required double phoneLongitude,
  required double tractorLatitude,
  required double tractorLongitude,
  required double? phoneAccuracyMeters,
  required bool tractorIsLive,
}) {
  if (!tractorIsLive ||
      phoneAccuracyMeters == null ||
      !phoneAccuracyMeters.isFinite ||
      phoneAccuracyMeters < 0 ||
      phoneAccuracyMeters > 25) {
    return false;
  }
  if (![
        phoneLatitude,
        phoneLongitude,
        tractorLatitude,
        tractorLongitude,
      ].every((v) => v.isFinite) ||
      phoneLatitude.abs() > 90 ||
      tractorLatitude.abs() > 90 ||
      phoneLongitude.abs() > 180 ||
      tractorLongitude.abs() > 180) {
    return false;
  }
  const radians = math.pi / 180;
  final latDelta = (tractorLatitude - phoneLatitude) * radians;
  final lngDelta = (tractorLongitude - phoneLongitude) * radians;
  final a =
      math.pow(math.sin(latDelta / 2), 2) +
      math.cos(phoneLatitude * radians) *
          math.cos(tractorLatitude * radians) *
          math.pow(math.sin(lngDelta / 2), 2);
  final distance = 6371000 * 2 * math.asin(math.sqrt(a.clamp(0, 1)));
  return distance <= 25;
}
