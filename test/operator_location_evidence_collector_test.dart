import 'package:flutter_test/flutter_test.dart';
import 'package:tractor/src/additional_data/location/domain/entities/device_location.dart';
import 'package:tractor/src/features/operator/presentation/widgets/operator_location_evidence_collector.dart';

void main() {
  group('operator field evidence', () {
    test('requires three independent consistent raw fixes', () {
      final collector = _collector();
      final first = _location(-6.170000, 35.740000, second: 0);
      final duplicate = _location(-6.170000, 35.740000, second: 0);
      final second = _location(-6.170010, 35.740010, second: 3);
      final third = _location(-6.170015, 35.740015, second: 6);

      expect(
        _add(collector, first).decision,
        OperatorEvidenceDecision.collecting,
      );
      expect(
        _add(collector, duplicate).decision,
        OperatorEvidenceDecision.rejectedDuplicate,
      );
      expect(_add(collector, second).acceptedSamples, 2);
      final result = _add(collector, third);

      expect(result.isReady, isTrue);
      expect(result.location, isNotNull);
      expect([
        first.latitude,
        second.latitude,
        third.latitude,
      ], contains(result.location!.latitude));
    });

    test('does not submit an averaged or synthetic coordinate', () {
      final collector = _collector();
      final samples = [
        _location(-6.170000, 35.740000, second: 0, accuracy: 14),
        _location(-6.170020, 35.740020, second: 3, accuracy: 6),
        _location(-6.170040, 35.740040, second: 6, accuracy: 10),
      ];
      OperatorEvidenceUpdate? result;
      for (final sample in samples) {
        result = _add(collector, sample);
      }
      expect(result!.isReady, isTrue);
      expect(samples, contains(result.location));
    });

    test('recovers when an accurate-looking first fix is far away', () {
      final collector = _collector();
      _add(collector, _location(-6.719370, 39.229917, second: 0));
      final firstTrue = _add(
        collector,
        _location(-6.722590, 39.230630, second: 3),
      );
      expect(firstTrue.decision, OperatorEvidenceDecision.rejectedImplausible);
      final confirmed = _add(
        collector,
        _location(-6.722600, 39.230640, second: 6),
      );
      expect(confirmed.acceptedSamples, 2);
      final result = _add(
        collector,
        _location(-6.722610, 39.230650, second: 9),
      );
      expect(result.isReady, isTrue);
      expect(result.location!.latitude, closeTo(-6.7226, 0.00003));
    });

    test('rejects stale poor and mocked fixes', () {
      final collector = _collector();
      expect(
        collector
            .add(
              _location(-6.17, 35.74, second: 0, accuracy: 80),
              now: _time(1),
            )
            .decision,
        OperatorEvidenceDecision.rejectedPoorAccuracy,
      );
      expect(
        collector
            .add(
              DeviceLocation(
                latitude: -6.17,
                longitude: 35.74,
                accuracyMeters: 5,
                recordedAt: _time(0),
                isMocked: true,
              ),
              now: _time(1),
            )
            .decision,
        OperatorEvidenceDecision.rejectedMocked,
      );
      expect(
        collector
            .add(_location(-6.17, 35.74, second: 0), now: _time(40))
            .decision,
        OperatorEvidenceDecision.rejectedStale,
      );
    });
  });
}

OperatorLocationEvidenceCollector _collector() =>
    OperatorLocationEvidenceCollector(
      maximumAccuracyMeters: 50,
      maximumFixAge: const Duration(seconds: 15),
    );

OperatorEvidenceUpdate _add(
  OperatorLocationEvidenceCollector collector,
  DeviceLocation sample,
) => collector.add(
  sample,
  now: sample.recordedAt.add(const Duration(seconds: 1)),
);

DeviceLocation _location(
  double latitude,
  double longitude, {
  required int second,
  double accuracy = 10,
}) => DeviceLocation(
  latitude: latitude,
  longitude: longitude,
  accuracyMeters: accuracy,
  recordedAt: _time(second),
);

DateTime _time(int second) => DateTime.utc(2026, 10, 28, 8, 0, second);
