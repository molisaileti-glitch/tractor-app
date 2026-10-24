// Historical pre-fix audit probes: these assert the old defective behaviour.
// The repaired implementation intentionally no longer satisfies these probes.
// Current regression coverage: flutter test test/mechanization_flow_test.dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tractor/src/core/network/kwanza_track_mobile_api_client.dart';
import 'package:tractor/src/features/manager/data/repositories/union_operations_repository.dart';
import 'package:tractor/src/features/manager/domain/entities/operations_models.dart';
import 'package:tractor/src/features/operator/data/repositories/operator_local_repository.dart';

void main() {
  test('reproduces: documented data.path produces no trail points', () async {
    final repository = await _operator(_Api());
    addTearDown(repository.dispose);
    expect(repository.jobs.single.trackPoints, isEmpty);
    // Desired: two points from {data: {path: [...]}}.
  });

  test('reproduces: brief accept erases full plot and farmer', () async {
    final repository = await _operator(_Api());
    addTearDown(repository.dispose);
    expect(repository.jobs.single.plot.boundaryPoints, hasLength(3));
    expect(repository.jobs.single.farmerName, 'Audit Farmer');
    expect(await repository.acceptAssignment('audit-job'), isTrue);
    expect(repository.jobs.single.plot.boundaryPoints, isEmpty);
    expect(repository.jobs.single.farmerName, 'Farmer');
    // Desired: merge the brief action response into the detailed job.
  });

  test('reproduces: completed active job disappears from history', () async {
    final repository = await _operator(_Api());
    addTearDown(repository.dispose);
    expect(repository.jobs, hasLength(1));
    expect(
      await repository.completeJob(
        jobId: 'audit-job',
        reportedAcres: 2,
        notes: '',
      ),
      isTrue,
    );
    expect(repository.jobs, isEmpty);
    expect(repository.history, isEmpty);
    // Active job absent from today/calendar, e.g. an overdue assignment.
  });

  test('reproduces: approved override never reaches start endpoint', () async {
    final api = _Api();
    final repository = await _operator(api);
    addTearDown(repository.dispose);
    expect(
      await repository.startJob('audit-job', overrideId: 'approved-override'),
      isFalse,
    );
    expect(api.startCalls, 0);
    // Location pre-check fails; start must be allowed to send override_id.
  });

  test('reproduces: in-flight refresh restores data after logout', () async {
    final gate = Completer<Map<String, Object?>>();
    final repository = OperatorLocalRepository.seeded(
      mobileApiClient: _Api(meGate: gate),
    );
    addTearDown(repository.dispose);
    repository.setMechanizationAccessToken('old-account');
    repository.setMechanizationAccessToken(null);
    expect(repository.jobs, isEmpty);
    gate.complete({'data': <String, Object?>{}});
    await _wait(() => repository.isSyncingMechanization);
    expect(repository.jobs, hasLength(1));
    // Desired: invalidate all in-flight requests when the token changes.
  });

  test('reproduces: restricted/working tractors become schedulable', () async {
    final repository = UnionOperationsRepository.seeded(
      mobileApiClient: _Api(),
    );
    addTearDown(repository.dispose);
    repository.setMechanizationAccessToken('audit-token');
    await _wait(() => repository.isSyncingMechanization);
    expect(repository.mechanizationSyncError, isNull);
    expect(repository.tractors, hasLength(4));
    expect(repository.tractors.every((t) => t.status.canSchedule), isTrue);
    // Inputs: working, suspended, unavailable, decommissioned.
  });

  test('reproduces: completed/closed requests become pending', () async {
    final repository = UnionOperationsRepository.seeded(
      mobileApiClient: _Api(),
    );
    addTearDown(repository.dispose);
    repository.setMechanizationAccessToken('audit-token');
    await _wait(() => repository.isSyncingMechanization);
    expect(repository.requests, hasLength(2));
    expect(
      repository.requests.every(
        (r) => r.status == OperationsRequestStatus.pending,
      ),
      isTrue,
    );
    // Desired: preserve the actual completed/closed states.
  });
}

Future<OperatorLocalRepository> _operator(_Api api) async {
  final repository = OperatorLocalRepository.seeded(mobileApiClient: api);
  repository.setMechanizationAccessToken('audit-token');
  await _wait(() => repository.isSyncingMechanization);
  expect(repository.mechanizationSyncError, isNull);
  return repository;
}

Future<void> _wait(bool Function() busy) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (busy()) {
    if (DateTime.now().isAfter(deadline)) fail('Audit fixture timed out');
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}

class _Api implements KwanzaTrackMobileApiClient {
  _Api({this.meGate});
  final Completer<Map<String, Object?>>? meGate;
  int startCalls = 0;

  static Map<String, Object?> _job(String status, {bool full = true}) => {
    'id': 'audit-job',
    'reference': 'JOB-AUDIT',
    'status': status,
    'scheduled_date': '2026-10-23',
    'window_start': '07:00',
    'window_end': '12:00',
    'tractor': {'id': 'audit-tractor', 'asset_no': 'T-AUDIT'},
    'operator': {'id': 'audit-operator', 'name': 'Audit Operator'},
    if (full) ...{
      'farmer': {'id': 'audit-farmer', 'name': 'Audit Farmer'},
      'plot': {
        'id': 'audit-plot',
        'name': 'Audit Plot',
        'area_ha': 2,
        'mapped': true,
        'boundary': [
          {'latitude': -6.17, 'longitude': 35.74},
          {'latitude': -6.17, 'longitude': 35.75},
          {'latitude': -6.18, 'longitude': 35.75},
        ],
      },
      'service_type': {'code': 'PLOUGH', 'name': 'Ploughing'},
    },
  };

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = invocation.memberName;
    if (name == #me && meGate != null) return meGate!.future;
    Object? data;
    if (name == #me || name == #dashboard) {
      data = <String, Object?>{};
    } else if (name == #calendar) {
      data = {'events': <Object?>[]};
    } else if (name == #jobs) {
      data = [_job('dispatched')];
    } else if (name == #jobPath) {
      data = {
        'path': [
          {
            't': '2026-10-23T07:00:00+03:00',
            'lat': -6.17,
            'lng': 35.74,
            'in': true,
          },
          {
            't': '2026-10-23T07:01:00+03:00',
            'lat': -6.18,
            'lng': 35.75,
            'in': false,
          },
        ],
        'live': null,
      };
    } else if (name == #acceptJob) {
      data = _job('dispatched', full: false);
    } else if (name == #completeJob) {
      data = _job('completed', full: false);
    } else if (name == #startCheck) {
      data = {
        'can_start': false,
        'override_allowed': true,
        'failed': ['tractor_on_plot'],
      };
    } else if (name == #startJob) {
      startCalls++;
      data = {'job': _job('in_progress')};
    } else if (name == #tractors) {
      data = [
        for (final state in [
          'working',
          'suspended',
          'unavailable',
          'decommissioned',
        ])
          {'id': 'tractor-$state', 'asset_no': 'T-$state', 'status': state},
      ];
    } else if (name == #requests) {
      data = [
        for (final state in ['completed', 'closed'])
          {'id': 'request-$state', 'status': state},
      ];
    } else if (name == #job) {
      data = _job('dispatched');
    } else if ([
      #calendarBacklog,
      #operators,
      #overrides,
      #exceptions,
      #farmers,
    ].contains(name)) {
      data = <Object?>[];
    } else {
      throw StateError('Unexpected API call: $name');
    }
    return Future<Map<String, Object?>>.value({'success': true, 'data': data});
  }
}



