import 'dart:math' as math;

import '../../../../additional_data/location/domain/entities/device_location.dart';

enum OperatorEvidenceDecision {
  collecting,
  ready,
  rejectedInvalid,
  rejectedPoorAccuracy,
  rejectedStale,
  rejectedMocked,
  rejectedDuplicate,
  rejectedImplausible,
}

class OperatorEvidenceUpdate {
  const OperatorEvidenceUpdate({
    required this.decision,
    required this.acceptedSamples,
    required this.requiredSamples,
    this.location,
    this.message,
  });

  final OperatorEvidenceDecision decision;
  final int acceptedSamples;
  final int requiredSamples;
  final DeviceLocation? location;
  final String? message;

  bool get isReady => decision == OperatorEvidenceDecision.ready;
}

/// Builds confidence from independent raw GPS fixes. It uses a median only to
/// measure agreement; the returned API evidence is always one real device fix.
class OperatorLocationEvidenceCollector {
  OperatorLocationEvidenceCollector({
    required this.maximumAccuracyMeters,
    required this.maximumFixAge,
    this.requiredSamples = 3,
    this.collectionWindow = const Duration(seconds: 30),
    this.maximumSpeedMetersPerSecond = 55,
  });

  final double maximumAccuracyMeters;
  final Duration maximumFixAge;
  final int requiredSamples;
  final Duration collectionWindow;
  final double maximumSpeedMetersPerSecond;

  final List<DeviceLocation> _samples = [];
  DeviceLocation? _pendingRelocation;

  List<DeviceLocation> get samples => List.unmodifiable(_samples);

  OperatorEvidenceUpdate add(DeviceLocation sample, {DateTime? now}) {
    final checkedAt = (now ?? DateTime.now()).toUtc();
    final recordedAt = sample.recordedAt.toUtc();
    final age = checkedAt.difference(recordedAt);
    if (!_validCoordinate(sample)) {
      return _rejected(
        OperatorEvidenceDecision.rejectedInvalid,
        'Android returned invalid GPS coordinates.',
      );
    }
    if (!sample.accuracyMeters.isFinite ||
        sample.accuracyMeters < 0 ||
        sample.accuracyMeters > maximumAccuracyMeters) {
      return _rejected(
        OperatorEvidenceDecision.rejectedPoorAccuracy,
        'GPS accuracy is ${sample.accuracyMeters.toStringAsFixed(0)} m; '
        'waiting for ${maximumAccuracyMeters.toStringAsFixed(0)} m or better.',
      );
    }
    if (age > maximumFixAge || age < const Duration(seconds: -30)) {
      return _rejected(
        OperatorEvidenceDecision.rejectedStale,
        'The GPS reading is not current.',
      );
    }
    if (sample.isMocked) {
      return _rejected(
        OperatorEvidenceDecision.rejectedMocked,
        'Mock locations cannot be used as field evidence.',
      );
    }
    if (_samples.any((item) => item.recordedAt == sample.recordedAt)) {
      return _rejected(
        OperatorEvidenceDecision.rejectedDuplicate,
        'Waiting for a newer independent GPS reading.',
      );
    }

    final previous = _samples.isEmpty ? null : _samples.last;
    if (previous != null) {
      final elapsed =
          sample.recordedAt.difference(previous.recordedAt).inMilliseconds /
          1000;
      final distance = distanceBetween(previous, sample);
      if (elapsed <= 0 || distance / elapsed > maximumSpeedMetersPerSecond) {
        final pending = _pendingRelocation;
        final confirmationRadius = pending == null
            ? 15.0
            : math.max(
                15.0,
                math.min(35.0, pending.accuracyMeters + sample.accuracyMeters),
              );
        final confirmsRelocation =
            pending != null &&
            sample.recordedAt.isAfter(pending.recordedAt) &&
            distanceBetween(pending, sample) <= confirmationRadius;
        if (confirmsRelocation) {
          _samples
            ..clear()
            ..add(pending);
          _pendingRelocation = null;
        } else {
          if (pending == null ||
              sample.recordedAt.isAfter(pending.recordedAt)) {
            _pendingRelocation = sample;
          }
          return _rejected(
            OperatorEvidenceDecision.rejectedImplausible,
            'GPS reported an impossible position change; waiting for another fix.',
          );
        }
      }
    }

    _samples.add(sample);
    _pendingRelocation = null;
    _samples.removeWhere(
      (item) =>
          checkedAt.difference(item.recordedAt.toUtc()) > collectionWindow,
    );
    if (_samples.length < requiredSamples) {
      return OperatorEvidenceUpdate(
        decision: OperatorEvidenceDecision.collecting,
        acceptedSamples: _samples.length,
        requiredSamples: requiredSamples,
        message: 'Reliable GPS readings: ${_samples.length}/$requiredSamples.',
      );
    }

    final recent = _samples.sublist(_samples.length - requiredSamples);
    final medianLatitude = _median(recent.map((item) => item.latitude));
    final medianLongitude = _median(recent.map((item) => item.longitude));
    final medianAccuracy = _median(recent.map((item) => item.accuracyMeters));
    final centre = DeviceLocation(
      latitude: medianLatitude,
      longitude: medianLongitude,
      accuracyMeters: medianAccuracy,
      recordedAt: recent.last.recordedAt,
    );
    final agreementRadius = math.max(
      15.0,
      math.min(35.0, medianAccuracy * 1.5),
    );
    final agrees = recent.every(
      (item) => distanceBetween(item, centre) <= agreementRadius,
    );
    if (!agrees) {
      _samples.removeAt(0);
      return OperatorEvidenceUpdate(
        decision: OperatorEvidenceDecision.collecting,
        acceptedSamples: _samples.length,
        requiredSamples: requiredSamples,
        message: 'GPS readings are still moving. Keep the tablet in open sky.',
      );
    }

    recent.sort((first, second) {
      final firstScore =
          distanceBetween(first, centre) + first.accuracyMeters * 0.5;
      final secondScore =
          distanceBetween(second, centre) + second.accuracyMeters * 0.5;
      return firstScore.compareTo(secondScore);
    });
    final selected = recent.first;
    return OperatorEvidenceUpdate(
      decision: OperatorEvidenceDecision.ready,
      acceptedSamples: requiredSamples,
      requiredSamples: requiredSamples,
      location: selected,
      message:
          'GPS verified from $requiredSamples consistent readings '
          '(accuracy ${selected.accuracyMeters.toStringAsFixed(0)} m).',
    );
  }

  OperatorEvidenceUpdate _rejected(
    OperatorEvidenceDecision decision,
    String message,
  ) => OperatorEvidenceUpdate(
    decision: decision,
    acceptedSamples: _samples.length,
    requiredSamples: requiredSamples,
    message: message,
  );

  bool _validCoordinate(DeviceLocation location) =>
      location.latitude.isFinite &&
      location.longitude.isFinite &&
      location.latitude.abs() <= 90 &&
      location.longitude.abs() <= 180;

  double _median(Iterable<double> values) {
    final sorted = values.toList()..sort();
    final middle = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[middle]
        : (sorted[middle - 1] + sorted[middle]) / 2;
  }

  static double distanceBetween(DeviceLocation first, DeviceLocation second) {
    const earthRadiusMeters = 6371000.0;
    const radians = math.pi / 180;
    final latitudeDelta = (second.latitude - first.latitude) * radians;
    final longitudeDelta = (second.longitude - first.longitude) * radians;
    final a =
        math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
        math.cos(first.latitude * radians) *
            math.cos(second.latitude * radians) *
            math.sin(longitudeDelta / 2) *
            math.sin(longitudeDelta / 2);
    return earthRadiusMeters * 2 * math.asin(math.sqrt(a.clamp(0.0, 1.0)));
  }
}
