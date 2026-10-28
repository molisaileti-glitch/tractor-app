import 'package:flutter_test/flutter_test.dart';
import 'package:tractor/src/additional_data/location/domain/entities/device_location.dart';
import 'package:tractor/src/features/operator/presentation/widgets/operator_phone_location_stabilizer.dart';

void main() {
  group('OperatorPhoneLocationStabilizer', () {
    test('holds ordinary stationary GPS jitter but verifies the raw fix', () {
      final stabilizer = OperatorPhoneLocationStabilizer();
      final first = location(
        latitude: -6.7230383,
        longitude: 39.2308433,
        accuracy: 3.3,
        second: 0,
      );
      final jitter = location(
        latitude: -6.7230183,
        longitude: 39.2308467,
        accuracy: 4.8,
        second: 12,
      );

      add(stabilizer, first);
      final update = add(stabilizer, jitter);

      expect(update.decision, OperatorLocationDecision.smoothed);
      expect(update.displayLocation!.latitude, jitter.latitude);
      expect(update.displayLocation!.longitude, jitter.longitude);
      expect(update.displayLocation!.recordedAt, jitter.recordedAt);
      expect(update.verifiedLocation, same(jitter));
    });

    test('holds the degraded 54 metre jump seen in the tablet log', () {
      final stabilizer = OperatorPhoneLocationStabilizer();
      final reliable = location(
        latitude: -6.723,
        longitude: 39.2308817,
        accuracy: 5.2,
        second: 0,
      );
      final outlier = location(
        latitude: -6.722885,
        longitude: 39.23041,
        accuracy: 20.9,
        second: 41,
      );

      final established = establish(stabilizer, reliable);
      final update = add(stabilizer, outlier);

      expect(update.distanceMeters, closeTo(53.6, 0.6));
      expect(update.decision, OperatorLocationDecision.awaitingBetterFix);
      expect(
        OperatorPhoneLocationStabilizer.distanceBetween(
          established,
          update.displayLocation!,
        ),
        lessThan(5),
      );
      expect(update.verifiedLocation, isNull);
    });

    test('does not let a cached duplicate confirm a degraded jump', () {
      final stabilizer = OperatorPhoneLocationStabilizer();
      final reliable = location(
        latitude: -6.723,
        longitude: 39.2308817,
        accuracy: 5.2,
        second: 0,
      );
      final outlier = location(
        latitude: -6.722885,
        longitude: 39.23041,
        accuracy: 20.9,
        second: 41,
      );

      establish(stabilizer, reliable);
      add(stabilizer, outlier);
      final duplicate = add(stabilizer, outlier);

      expect(duplicate.decision, OperatorLocationDecision.awaitingBetterFix);
      expect(duplicate.verifiedLocation, isNull);
    });

    test('accepts a newer fix that confirms genuine movement', () {
      final stabilizer = OperatorPhoneLocationStabilizer();
      final reliable = location(
        latitude: -6.723,
        longitude: 39.2308817,
        accuracy: 5.2,
        second: 0,
      );
      final moved = location(
        latitude: -6.722885,
        longitude: 39.23041,
        accuracy: 20.9,
        second: 41,
      );
      final confirmation = location(
        latitude: -6.72289,
        longitude: 39.23042,
        accuracy: 12,
        second: 53,
      );

      establish(stabilizer, reliable);
      add(stabilizer, moved);
      final update = add(stabilizer, confirmation);

      expect(update.verifiedLocation, same(confirmation));
    });

    test('accepts a large movement when accuracy remains strong', () {
      final stabilizer = OperatorPhoneLocationStabilizer();
      final first = location(
        latitude: -6.723,
        longitude: 39.2308817,
        accuracy: 5,
        second: 0,
      );
      final moved = location(
        latitude: -6.7225,
        longitude: 39.2304,
        accuracy: 6,
        second: 12,
        speed: 8,
      );

      establish(stabilizer, first);
      final update = add(stabilizer, moved);

      expect(update.distanceMeters, greaterThan(25));
      expect(update.verifiedLocation, same(moved));
    });

    test('rejects a poor initial fix instead of anchoring the map to it', () {
      final stabilizer = OperatorPhoneLocationStabilizer();
      final poor = location(
        latitude: -6.72,
        longitude: 39.20,
        accuracy: 80,
        second: 0,
      );

      final update = add(stabilizer, poor);

      expect(update.decision, OperatorLocationDecision.rejectedPoorAccuracy);
      expect(update.displayLocation, isNull);
      expect(update.verifiedLocation, isNull);
    });

    test('rejects a stale fix and an impossible teleport', () {
      final stabilizer = OperatorPhoneLocationStabilizer();
      final first = location(
        latitude: -6.723,
        longitude: 39.2308,
        accuracy: 5,
        second: 0,
      );
      final teleport = location(
        latitude: -6.718,
        longitude: 39.2308,
        accuracy: 5,
        second: 5,
      );

      final stale = stabilizer.add(
        first,
        now: first.recordedAt.add(const Duration(seconds: 20)),
      );
      expect(stale.decision, OperatorLocationDecision.rejectedStale);

      establish(stabilizer, first);
      final jump = add(stabilizer, teleport);
      expect(jump.decision, OperatorLocationDecision.rejectedImplausible);
      expect(jump.verifiedLocation, isNull);
    });
  });
}

OperatorLocationUpdate add(
  OperatorPhoneLocationStabilizer stabilizer,
  DeviceLocation sample,
) => stabilizer.add(
  sample,
  now: sample.recordedAt.add(const Duration(seconds: 1)),
);

DeviceLocation establish(
  OperatorPhoneLocationStabilizer stabilizer,
  DeviceLocation first,
) {
  add(stabilizer, first);
  final confirmation = DeviceLocation(
    latitude: first.latitude + 0.000005,
    longitude: first.longitude + 0.000005,
    accuracyMeters: first.accuracyMeters,
    recordedAt: first.recordedAt.add(const Duration(seconds: 3)),
    speedMetersPerSecond: first.speedMetersPerSecond,
  );
  add(stabilizer, confirmation);
  return confirmation;
}

DeviceLocation location({
  required double latitude,
  required double longitude,
  required double accuracy,
  required int second,
  double speed = 0,
}) => DeviceLocation(
  latitude: latitude,
  longitude: longitude,
  accuracyMeters: accuracy,
  recordedAt: DateTime.utc(2026, 10, 28, 5, 25, second),
  speedMetersPerSecond: speed,
);
