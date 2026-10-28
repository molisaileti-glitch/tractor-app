import 'package:flutter_test/flutter_test.dart';
import 'package:tractor/src/core/network/mechanization_mobile_api_client.dart';
import 'package:tractor/src/features/operator/data/repositories/operator_local_repository.dart';

void main() {
  test('restores assignments returned only by me.today', () async {
    final repository = OperatorLocalRepository.seeded(
      mobileApiClient: _OperatorApiClient(),
    );

    repository.setMechanizationAccessToken('test-token');
    await _waitForSync(repository);

    expect(repository.jobs, hasLength(1));
    expect(repository.jobs.single.reference, 'JOB-000014');
    expect(repository.jobs.single.plot.name, 'testing testing farms');
  });

  test('keeps calendar planning separate from actionable jobs', () async {
    final repository = OperatorLocalRepository.seeded(
      mobileApiClient: const _OperatorApiClient(
        includeToday: false,
        includeCalendar: true,
      ),
    );

    repository.setMechanizationAccessToken('test-token');
    await _waitForSync(repository);

    expect(repository.dashboardJobs, isEmpty);
    await repository.refreshScreen(OperatorDataScreen.schedule);
    expect(repository.scheduleJobs, hasLength(1));
    expect(repository.scheduleJobs.single.reference, 'JOB-CALENDAR');
  });

  test('shows a me.today assignment with a detail access warning', () async {
    final repository = OperatorLocalRepository.seeded(
      mobileApiClient: const _OperatorApiClient(validTodayDetail: false),
    );

    repository.setMechanizationAccessToken('test-token');
    await _waitForSync(repository);

    expect(repository.dashboardJobs.single.reference, 'JOB-000014');
    expect(repository.mechanizationSyncError, contains('(404)'));
    expect(repository.scheduleJobs, isEmpty);
  });
}

Future<void> _waitForSync(OperatorLocalRepository repository) async {
  while (repository.isSyncingMechanization) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

class _OperatorApiClient extends MechanizationMobileApiClient {
  const _OperatorApiClient({
    this.includeToday = true,
    this.includeCalendar = false,
    this.validTodayDetail = true,
  });

  final bool includeToday;
  final bool includeCalendar;
  final bool validTodayDetail;

  @override
  Future<Map<String, Object?>> me({required String token}) async {
    return {
      'data': {
        'user': {'id': 'user-1', 'name': 'prince mchau'},
        'operator': {'id': 'operator-1', 'name': 'prince mchau'},
        'today': includeToday
            ? [
                {
                  'id': 'job-14',
                  'reference': 'JOB-000014',
                  'status': 'dispatched',
                  'scheduled_date': '2026-10-23',
                  'window_start': '10:45',
                  'window_end': '12:45',
                  'window': '10:45-12:45',
                  'tractor': {'id': 'tractor-1', 'asset_no': 'SB-TR-2026-001'},
                  'operator': {'id': 'operator-1', 'name': 'prince mchau'},
                  'planned_acres': 5,
                  'farmer': null,
                  'plot': 'testing testing farms',
                  'service_type': 'ploughing',
                },
              ]
            : <Object?>[],
      },
    };
  }

  @override
  Future<Map<String, Object?>> calendar({
    required String token,
    String? from,
    String? to,
    bool? mine,
    String? status,
    String? tractorId,
    String? operatorId,
  }) async {
    return {
      'data': {
        'events': includeCalendar
            ? [
                {
                  'id': 'calendar-job',
                  'reference': 'JOB-CALENDAR',
                  'status': 'scheduled',
                  'start': '2026-10-28T07:00:00+03:00',
                  'end': '2026-10-28T12:00:00+03:00',
                  'farmer': 'Calendar Farmer',
                  'plot': 'Calendar Farm',
                  'service_type': 'ploughing',
                },
              ]
            : <Object?>[],
      },
    };
  }

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
  }) async {
    return {'data': <Object?>[]};
  }

  @override
  Future<Map<String, Object?>> job({
    required String token,
    required String jobId,
  }) async {
    if (!validTodayDetail) {
      throw const MechanizationApiException('Job not found', statusCode: 404);
    }
    return {
      'data': {
        'id': jobId,
        'reference': 'JOB-000014',
        'status': 'dispatched',
        'scheduled_date': '2026-10-23',
        'window_start': '10:45',
        'window_end': '12:45',
        'tractor': {'id': 'tractor-1', 'asset_no': 'SB-TR-2026-001'},
        'plot': {'id': 'plot-14', 'name': 'testing testing farms'},
        'service_type': {'code': 'PLOUGH'},
      },
    };
  }

  @override
  Future<Map<String, Object?>> tractors({
    required String token,
    bool? mine,
    bool? live,
  }) async {
    return {'data': <Object?>[]};
  }

  @override
  Future<Map<String, Object?>> jobPath({
    required String token,
    required String jobId,
  }) async {
    return {
      'data': {'points': <Object?>[]},
    };
  }
}
