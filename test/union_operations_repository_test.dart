// File purpose: Provides regression coverage for Union Operations Repository behavior and its important failure cases.

import 'package:flutter_test/flutter_test.dart';
import 'package:tractor/src/core/network/mechanization_mobile_api_client.dart';
import 'package:tractor/src/features/manager/data/repositories/union_operations_repository.dart';

void main() {
  test(
    'keeps union jobs and calendar planning in separate collections',
    () async {
      final repository = UnionOperationsRepository.seeded(
        mobileApiClient: _UnionApiClient(),
      );

      repository.setMechanizationAccessToken('test-token');
      await _waitForSync(repository);
      await repository.refreshScreen(UnionDataScreen.schedule);

      expect(repository.jobs, hasLength(1));
      expect(repository.jobs.single.id, 'active-job');
      expect(repository.scheduleJobs, hasLength(1));
      expect(repository.scheduleJobs.single.id, 'calendar-job');
    },
  );

  test('loads the documented job path for union trail review', () async {
    final repository = UnionOperationsRepository.seeded(
      mobileApiClient: _UnionApiClient(),
    );
    addTearDown(repository.dispose);

    repository.setMechanizationAccessToken('test-token');
    await _waitForSync(repository);

    expect(await repository.refreshJobTrail('active-job'), isTrue);
    final trail = repository.trailForJob('active-job');
    expect(trail, hasLength(3));
    expect(trail.first.latitude, -6.1709);
    expect(trail.first.longitude, 35.7409);
    expect(trail.first.inside, isTrue);
    expect(trail[1].inside, isFalse);
    expect(trail.last.inside, isNull);
    expect(trail.first.speedKph, 7.5);
    expect(trail.first.recordedAt, isNotNull);
    final liveTractor = repository.liveTractorForJob('active-job');
    expect(liveTractor, isNotNull);
    expect(liveTractor!.latitude, -6.1712);
    expect(liveTractor.longitude, 35.7412);
    expect(liveTractor.online, isTrue);
    expect(liveTractor.speedKph, 5.5);
    expect(liveTractor.ageSeconds, 8);
    expect(liveTractor.fixTime, isNotNull);
    expect(
      liveTractor.isLiveAt(DateTime.parse('2026-10-28T08:00:45+03:00')),
      isTrue,
    );
    expect(
      liveTractor.isLiveAt(DateTime.parse('2026-10-28T08:04:00+03:00')),
      isFalse,
    );
  });
}

Future<void> _waitForSync(UnionOperationsRepository repository) async {
  while (repository.isSyncingMechanization) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

class _UnionApiClient extends MechanizationMobileApiClient {
  _UnionApiClient();

  @override
  Future<Map<String, Object?>> me({required String token}) async => {
    'data': {
      'user': {'name': 'Union Officer', 'role': 'Union Officer'},
    },
  };

  @override
  Future<Map<String, Object?>> dashboard({
    required String token,
    int days = 30,
  }) async => {'data': <String, Object?>{}};

  @override
  Future<Map<String, Object?>> jobs({
    required String token,
    String? status,
    String? date,
    String? from,
    String? to,
    bool? mine,
    String? tractorId,
    int? page,
    int? perPage,
  }) async => {
    'data': [_job('active-job', 'JOB-ACTIVE', 'dispatched')],
  };

  @override
  Future<Map<String, Object?>> calendar({
    required String token,
    String? from,
    String? to,
    bool? mine,
    String? status,
    String? tractorId,
    String? operatorId,
  }) async => {
    'data': {
      'events': [
        {
          'id': 'calendar-job',
          'reference': 'JOB-CALENDAR',
          'status': 'scheduled',
          'start': '2026-10-28T07:00:00+03:00',
          'end': '2026-10-28T12:00:00+03:00',
          'farmer': 'Calendar Farmer',
          'plot': 'Calendar Farm',
          'tractor': 'TR-2',
          'operator': 'Calendar Operator',
        },
      ],
    },
  };

  @override
  Future<Map<String, Object?>> calendarBacklog({required String token}) async =>
      {'data': <Object?>[]};

  @override
  Future<Map<String, Object?>> jobPath({
    required String token,
    required String jobId,
  }) async => {
    'data': {
      'path': [
        {
          't': '2026-10-28T08:00:00+03:00',
          'lat': -6.1709,
          'lng': 35.7409,
          'speed': 7.5,
          'in': true,
        },
        {
          't': '2026-10-28T08:00:15+03:00',
          'lat': -6.1710,
          'lng': 35.7410,
          'speed': 6,
          'in': false,
        },
        {
          't': '2026-10-28T08:00:30+03:00',
          'lat': -6.1711,
          'lng': 35.7411,
          'speed': 0,
          'in': null,
        },
      ],
      'live': {
        'online': true,
        'position': {
          'latitude': -6.1712,
          'longitude': 35.7412,
          'speed_kph': 5.5,
          'fix_time': '2026-10-28T08:00:38+03:00',
          'age_s': 8,
        },
      },
    },
  };

  @override
  Future<Map<String, Object?>> requests({
    required String token,
    String? status,
    String? farmerId,
    String? queryText,
    int? page,
  }) async => {'data': <Object?>[]};

  @override
  Future<Map<String, Object?>> tractors({
    required String token,
    bool? mine,
    bool? live,
  }) async => {'data': <Object?>[]};

  @override
  Future<Map<String, Object?>> operators({required String token}) async => {
    'data': <Object?>[],
  };

  @override
  Future<Map<String, Object?>> overrides({
    required String token,
    String? status,
  }) async => {'data': <Object?>[]};

  @override
  Future<Map<String, Object?>> exceptions({
    required String token,
    String? status,
    String? severity,
    String? tractorId,
    int? page,
  }) async => {'data': <Object?>[]};

  @override
  Future<Map<String, Object?>> farmers({
    required String token,
    String? queryText,
    int? page,
  }) async => {'data': <Object?>[]};

  static Map<String, Object?> _job(
    String id,
    String reference,
    String status,
  ) => {
    'id': id,
    'reference': reference,
    'status': status,
    'scheduled_date': '2026-10-28',
    'window_start': '07:00',
    'window_end': '12:00',
    'farmer': {'name': 'Active Farmer'},
    'plot': {'id': 'plot-1', 'name': 'Active Farm'},
    'tractor': {'id': 'tractor-1', 'asset_no': 'TR-1'},
    'operator': {'id': 'operator-1', 'name': 'Active Operator'},
    'service_type': {'code': 'PLOUGH'},
  };
}
