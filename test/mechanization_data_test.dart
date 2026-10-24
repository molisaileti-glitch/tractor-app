import 'package:flutter_test/flutter_test.dart';
import 'package:tractor/src/core/network/mechanization_data.dart';

void main() {
  test(
    'brief responses preserve omitted details but explicit null clears them',
    () {
      final old = <String, Object?>{
        'id': 'job',
        'status': 'dispatched',
        'farmer': {'id': 'farmer', 'name': 'Asha'},
        'plot': {
          'id': 'plot',
          'name': 'Lower field',
          'boundary': [1, 2, 3],
        },
      };
      final brief = mergeMechanizationData(old, {
        'id': 'job',
        'status': 'arrived',
        'farmer': {'id': 'farmer'},
      });
      expect((brief['plot'] as Map)['boundary'], [1, 2, 3]);
      expect((brief['farmer'] as Map)['name'], 'Asha');
      expect(mergeMechanizationData(brief, {'farmer': null})['farmer'], isNull);
    },
  );

  test('reassignment never inherits the previous related record details', () {
    final merged = mergeMechanizationData(
      {
        'tractor': {'id': 'old', 'label': 'Old tractor'},
      },
      {
        'tractor': {'id': 'new'},
      },
    );
    expect(merged['tractor'], {'id': 'new'});
  });

  test(
    'schedule dates accept HH:MM and HH:MM:SS without appending invalid seconds',
    () {
      expect(
        apiScheduleTime('2026-10-23', '07:30'),
        DateTime(2026, 10, 23, 7, 30),
      );
      expect(
        apiScheduleTime('2026-10-23', '07:30:00'),
        DateTime(2026, 10, 23, 7, 30),
      );
      expect(
        localApiTime('2026-10-23T07:30:00+03:00'),
        DateTime.utc(2026, 10, 23, 4, 30).toLocal(),
      );
    },
  );
}
