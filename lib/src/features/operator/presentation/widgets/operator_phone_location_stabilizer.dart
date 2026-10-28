import 'dart:math' as math;

import '../../../../additional_data/location/domain/entities/device_location.dart';

enum OperatorLocationDecision {
  accepted,
  smoothed,
  jitterHeld,
  awaitingBetterFix,
  rejectedPoorAccuracy,
  rejectedStale,
  rejectedImplausible,
}

class OperatorLocationUpdate {
  const OperatorLocationUpdate({
    required this.displayLocation,
    required this.verifiedLocation,
    required this.decision,
    required this.distanceMeters,
    this.message,
  });

  /// Accuracy-weighted point used only for the map marker and route preview.
  final DeviceLocation? displayLocation;

  /// Fresh, unsmoothed fix used by automatic geofence/readiness checks.
  /// It is null when the measurement fails a quality or outlier gate.
  final DeviceLocation? verifiedLocation;
  final OperatorLocationDecision decision;
  final double distanceMeters;
  final String? message;
}

/// Filters raw phone fixes and produces a stable map position.
///
/// The raw fix is never replaced with the smoothed coordinate for job evidence.
/// Poor, stale and physically implausible readings are excluded. Remaining
/// measurements update an accuracy-weighted Kalman estimate. A degraded jump
/// is not trusted for automatic checks until a newer nearby fix confirms it.
class OperatorPhoneLocationStabilizer {
  OperatorPhoneLocationStabilizer({
    this.maximumAccuracyMeters = 50,
    this.maximumFixAge = const Duration(seconds: 15),
    this.maximumFutureSkew = const Duration(seconds: 30),
    this.maximumSpeedMetersPerSecond = 55,
    this.displayDeadbandMeters = 5,
    this.largeJumpMeters = 25,
    this.confirmationRadiusMeters = 15,
  });

  final double maximumAccuracyMeters;
  final Duration maximumFixAge;
  final Duration maximumFutureSkew;
  final double maximumSpeedMetersPerSecond;
  final double displayDeadbandMeters;
  final double largeJumpMeters;
  final double confirmationRadiusMeters;

  DeviceLocation? _displayLocation;
  DeviceLocation? _lastUsableRaw;
  DeviceLocation? _lastVerifiedRaw;
  DeviceLocation? _pendingJump;
  double? _filteredLatitude;
  double? _filteredLongitude;
  double? _varianceMetersSquared;
  DateTime? _filterTimestamp;

  void reset() {
    _displayLocation = null;
    _lastUsableRaw = null;
    _lastVerifiedRaw = null;
    _pendingJump = null;
    _filteredLatitude = null;
    _filteredLongitude = null;
    _varianceMetersSquared = null;
    _filterTimestamp = null;
  }

  OperatorLocationUpdate add(DeviceLocation rawLocation, {DateTime? now}) {
    final checkedAt = (now ?? DateTime.now()).toUtc();
    final recordedAt = rawLocation.recordedAt.toUtc();
    final age = checkedAt.difference(recordedAt);

    if (!_validCoordinate(rawLocation) ||
        !rawLocation.accuracyMeters.isFinite ||
        rawLocation.accuracyMeters < 0 ||
        rawLocation.accuracyMeters > maximumAccuracyMeters) {
      return _reject(
        OperatorLocationDecision.rejectedPoorAccuracy,
        'Weak GPS signal (${_accuracyLabel(rawLocation)}). Keeping the last '
        'reliable operator position while accuracy improves.',
      );
    }
    if (age > maximumFixAge || age < -maximumFutureSkew) {
      return _reject(
        OperatorLocationDecision.rejectedStale,
        'The latest GPS reading is not current. Keeping the last reliable '
        'operator position while a fresh fix is requested.',
      );
    }

    final previousRaw = _lastUsableRaw;
    var movementMeters = 0.0;
    if (previousRaw != null) {
      movementMeters = distanceBetween(previousRaw, rawLocation);
      final elapsedSeconds =
          rawLocation.recordedAt
              .difference(previousRaw.recordedAt)
              .inMilliseconds /
          1000;
      if (elapsedSeconds > 0 &&
          movementMeters / elapsedSeconds > maximumSpeedMetersPerSecond) {
        return _reject(
          OperatorLocationDecision.rejectedImplausible,
          'GPS reported an impossible position jump. Keeping the last '
          'reliable operator position while it checks again.',
          distanceMeters: movementMeters,
        );
      }
      if (elapsedSeconds <= 0 && movementMeters <= displayDeadbandMeters / 2) {
        return OperatorLocationUpdate(
          displayLocation: _displayLocation,
          verifiedLocation: _pendingJump == null ? _lastVerifiedRaw : null,
          decision: OperatorLocationDecision.jitterHeld,
          distanceMeters: movementMeters,
          message: _pendingJump == null
              ? null
              : 'Waiting for a newer GPS reading to confirm the position.',
        );
      }
    }

    final hadPendingFix = _pendingJump != null;
    final evidenceDecision = _validateForEvidence(rawLocation);
    if (evidenceDecision == OperatorLocationDecision.awaitingBetterFix) {
      return OperatorLocationUpdate(
        displayLocation: _displayLocation,
        verifiedLocation: null,
        decision: evidenceDecision,
        distanceMeters: movementMeters,
        message: _displayLocation == null
            ? 'Establishing a reliable GPS position. Waiting for a second '
                  'consistent reading.'
            : 'GPS reported a large position change while the device appears '
                  'stationary. Keeping the last reliable position while a '
                  'newer fix confirms it.',
      );
    }

    if (hadPendingFix) _resetDisplayFilter();
    _lastUsableRaw = rawLocation;
    final smoothed = _updateKalman(rawLocation);
    final stableDisplay = _applyDisplayDeadband(smoothed);
    final displayWasHeld =
        stableDisplay.latitude != smoothed.latitude ||
        stableDisplay.longitude != smoothed.longitude;
    final decision = displayWasHeld
        ? OperatorLocationDecision.jitterHeld
        : OperatorLocationDecision.smoothed;

    return OperatorLocationUpdate(
      displayLocation: stableDisplay,
      verifiedLocation: rawLocation,
      decision: decision,
      distanceMeters: movementMeters,
    );
  }

  OperatorLocationDecision _validateForEvidence(DeviceLocation rawLocation) {
    final lastVerified = _lastVerifiedRaw;
    if (lastVerified == null) {
      final pending = _pendingJump;
      final isNewer =
          pending != null && rawLocation.recordedAt.isAfter(pending.recordedAt);
      final radius = pending == null
          ? confirmationRadiusMeters
          : math.max(
              confirmationRadiusMeters,
              _safeAccuracy(pending) + _safeAccuracy(rawLocation),
            );
      if (isNewer && distanceBetween(pending, rawLocation) <= radius) {
        _lastVerifiedRaw = rawLocation;
        _pendingJump = null;
        return OperatorLocationDecision.accepted;
      }
      if (pending == null ||
          rawLocation.recordedAt.isAfter(pending.recordedAt)) {
        _pendingJump = rawLocation;
      }
      return OperatorLocationDecision.awaitingBetterFix;
    }

    final distance = distanceBetween(lastVerified, rawLocation);
    final combinedAccuracy =
        _safeAccuracy(lastVerified) + _safeAccuracy(rawLocation);
    final reportsStationary = rawLocation.speedMetersPerSecond <= 1;
    final suspiciousJump =
        reportsStationary &&
        distance > math.max(largeJumpMeters, combinedAccuracy * 1.5);

    if (!suspiciousJump) {
      _lastVerifiedRaw = rawLocation;
      _pendingJump = null;
      return OperatorLocationDecision.accepted;
    }

    final pending = _pendingJump;
    final isNewer =
        pending != null && rawLocation.recordedAt.isAfter(pending.recordedAt);
    final radius = pending == null
        ? confirmationRadiusMeters
        : math.max(
            confirmationRadiusMeters,
            _safeAccuracy(pending) + _safeAccuracy(rawLocation),
          );
    final confirms = isNewer && distanceBetween(pending, rawLocation) <= radius;
    if (confirms) {
      _lastVerifiedRaw = rawLocation;
      _pendingJump = null;
      return OperatorLocationDecision.accepted;
    }

    if (pending == null || rawLocation.recordedAt.isAfter(pending.recordedAt)) {
      _pendingJump = rawLocation;
    }
    return OperatorLocationDecision.awaitingBetterFix;
  }

  void _resetDisplayFilter() {
    _displayLocation = null;
    _filteredLatitude = null;
    _filteredLongitude = null;
    _varianceMetersSquared = null;
    _filterTimestamp = null;
  }

  DeviceLocation _updateKalman(DeviceLocation rawLocation) {
    final measurementAccuracy = math.max(1.0, rawLocation.accuracyMeters);
    final measurementVariance = measurementAccuracy * measurementAccuracy;
    if (_filteredLatitude == null ||
        _filteredLongitude == null ||
        _varianceMetersSquared == null ||
        _filterTimestamp == null) {
      _filteredLatitude = rawLocation.latitude;
      _filteredLongitude = rawLocation.longitude;
      _varianceMetersSquared = measurementVariance;
      _filterTimestamp = rawLocation.recordedAt;
      return rawLocation;
    }

    final elapsedSeconds =
        rawLocation.recordedAt.difference(_filterTimestamp!).inMilliseconds /
        1000;
    if (elapsedSeconds > 0) {
      final reportedSpeed = rawLocation.speedMetersPerSecond.isFinite
          ? math.max(0.0, rawLocation.speedMetersPerSecond)
          : 0.0;
      final processNoiseMetersPerSecond = reportedSpeed > 1
          ? math.max(1.0, reportedSpeed * 0.75)
          : 0.5;
      _varianceMetersSquared =
          _varianceMetersSquared! +
          math.min(elapsedSeconds, 30) *
              processNoiseMetersPerSecond *
              processNoiseMetersPerSecond;
      _filterTimestamp = rawLocation.recordedAt;
    }

    final gain =
        _varianceMetersSquared! /
        (_varianceMetersSquared! + measurementVariance);
    _filteredLatitude =
        _filteredLatitude! + gain * (rawLocation.latitude - _filteredLatitude!);
    _filteredLongitude =
        _filteredLongitude! +
        gain * (rawLocation.longitude - _filteredLongitude!);
    _varianceMetersSquared = (1 - gain) * _varianceMetersSquared!;
    return DeviceLocation(
      latitude: _filteredLatitude!,
      longitude: _filteredLongitude!,
      accuracyMeters: math.sqrt(_varianceMetersSquared!),
      recordedAt: rawLocation.recordedAt,
      speedMetersPerSecond: rawLocation.speedMetersPerSecond,
      isMocked: rawLocation.isMocked,
    );
  }

  DeviceLocation _applyDisplayDeadband(DeviceLocation smoothed) {
    final display = _displayLocation;
    if (display == null) {
      _displayLocation = smoothed;
      return smoothed;
    }
    if (distanceBetween(display, smoothed) < displayDeadbandMeters) {
      final held = DeviceLocation(
        latitude: display.latitude,
        longitude: display.longitude,
        accuracyMeters: smoothed.accuracyMeters,
        recordedAt: smoothed.recordedAt,
        speedMetersPerSecond: smoothed.speedMetersPerSecond,
        isMocked: smoothed.isMocked,
      );
      _displayLocation = held;
      return held;
    }
    _displayLocation = smoothed;
    return smoothed;
  }

  OperatorLocationUpdate _reject(
    OperatorLocationDecision decision,
    String message, {
    double distanceMeters = 0,
  }) => OperatorLocationUpdate(
    displayLocation: _displayLocation,
    verifiedLocation: null,
    decision: decision,
    distanceMeters: distanceMeters,
    message: message,
  );

  bool _validCoordinate(DeviceLocation location) =>
      location.latitude.isFinite &&
      location.longitude.isFinite &&
      location.latitude.abs() <= 90 &&
      location.longitude.abs() <= 180;

  String _accuracyLabel(DeviceLocation location) =>
      location.accuracyMeters.isFinite
      ? '${location.accuracyMeters.toStringAsFixed(0)} m accuracy'
      : 'unknown accuracy';

  double _safeAccuracy(DeviceLocation location) {
    final accuracy = location.accuracyMeters;
    return accuracy.isFinite && accuracy >= 0
        ? accuracy
        : maximumAccuracyMeters;
  }

  static double distanceBetween(DeviceLocation first, DeviceLocation second) {
    const earthRadiusMeters = 6371000.0;
    final latitude1 = _radians(first.latitude);
    final latitude2 = _radians(second.latitude);
    final latitudeDelta = _radians(second.latitude - first.latitude);
    final longitudeDelta = _radians(second.longitude - first.longitude);
    final haversine =
        math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
        math.cos(latitude1) *
            math.cos(latitude2) *
            math.sin(longitudeDelta / 2) *
            math.sin(longitudeDelta / 2);
    return 2 *
        earthRadiusMeters *
        math.asin(math.sqrt(haversine.clamp(0.0, 1.0)));
  }

  static double _radians(double degrees) => degrees * math.pi / 180;
}
