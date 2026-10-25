// Regression tests for the operator and union manager API flow.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tractor/src/l10n/generated/app_localizations.dart';
import 'package:tractor/src/features/operator/presentation/screens/operator_jobs_screen.dart';
import 'package:tractor/src/features/operator/presentation/screens/operator_shell.dart';
import 'package:tractor/src/shared/application/app_preferences_controller.dart';
import 'package:tractor/src/core/network/kwanza_track_mobile_api_client.dart';
import 'package:tractor/src/features/manager/data/repositories/union_operations_repository.dart';
import 'package:tractor/src/features/manager/domain/entities/operations_models.dart';
import 'package:tractor/src/features/operator/data/repositories/operator_local_repository.dart';
import 'package:tractor/src/features/operator/domain/entities/operator_job.dart';

void main() {
  testWidgets('operator dashboard refreshes without switching tabs', (
    tester,
  ) async {
    var reference = 'BEFORE-REFRESH';
    final api = _Api(
      handlers: {
        #jobs: (_) async => {
          'data': [
            {..._Api._job('dispatched'), 'reference': reference},
          ],
        },
        #job: (_) async => {
          'data': {..._Api._job('dispatched'), 'reference': reference},
        },
      },
    );
    final repository = (await tester.runAsync(() => _operator(api)))!;
    final preferences = AppPreferencesController();
    addTearDown(repository.dispose);
    addTearDown(preferences.dispose);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OperatorShell(
          repository: repository,
          preferences: preferences,
          onLogout: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('BEFORE-REFRESH'), findsOneWidget);
    reference = 'AFTER-REFRESH';
    await tester.runAsync(repository.refreshMechanizationData);
    await tester.pumpAndSettle();
    expect(find.text('AFTER-REFRESH'), findsOneWidget);
    expect(find.text('BEFORE-REFRESH'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test(
    'tractor fixes merge across endpoints by capture time and tractor ID',
    () async {
      final now = DateTime.now().toUtc();
      Map<String, Object?> live(
        DateTime time,
        double latitude, {
        bool online = true,
      }) => {
        'online': online,
        'position': {
          'latitude': latitude,
          'longitude': 35.8,
          'fix_time': time.toIso8601String(),
        },
      };
      Object? listLive = live(now.subtract(const Duration(minutes: 10)), -6.1);
      final api = _Api(
        handlers: {
          #job: (_) async => {
            'data': {
              ..._Api._job('dispatched'),
              'tractor_live': live(now, -6.2),
            },
          },
          #tractors: (_) async => {
            'data': [
              {'id': 'audit-tractor', 'live': listLive},
              {'id': 'another-tractor', 'live': live(now, -7.3)},
            ],
          },
        },
      );
      final repository = await _operator(api);
      addTearDown(repository.dispose);
      await repository.refreshJobDetail('audit-job');
      await repository.refreshTrackerPositions();
      expect(repository.trackerPositionFor('audit-tractor')!.latitude, -6.2);
      expect(repository.trackerPositionFor('another-tractor')!.latitude, -7.3);
      listLive = null;
      await repository.refreshTrackerPositions();
      expect(repository.trackerPositionFor('audit-tractor')!.latitude, -6.2);
      listLive = live(now, -6.2, online: false);
      await repository.refreshTrackerPositions();
      expect(repository.trackerPositionFor('audit-tractor')!.isLive, isFalse);
      listLive = live(now.add(const Duration(seconds: 1)), -6.25);
      await repository.refreshTrackerPositions();
      expect(repository.trackerPositionFor('audit-tractor')!.latitude, -6.25);
    },
  );

  test(
    'today assignment survives a conflicting detail 404 until removed by me',
    () async {
      var assigned = true;
      var detailAvailable = false;
      final api = _Api(
        handlers: {
          #me: (_) async => {
            'data': {
              'today': [if (assigned) _Api._job('dispatched')],
            },
          },
          #jobs: (_) async => {'data': <Object?>[]},
          #job: (_) async {
            if (!detailAvailable) {
              throw const KwanzaTrackApiException('Not found', statusCode: 404);
            }
            return {'data': _Api._job('dispatched')};
          },
        },
      );
      final repository = OperatorLocalRepository.seeded(mobileApiClient: api);
      addTearDown(repository.dispose);
      repository.setMechanizationAccessToken('operator');
      await _wait(() => repository.isSyncingMechanization);
      expect(repository.dashboardJobs.single.reference, 'JOB-AUDIT');
      expect(repository.mechanizationSyncError, contains('(404)'));
      expect(await repository.refreshJobDetail('audit-job'), isFalse);
      expect(repository.dashboardJobs, hasLength(1));
      detailAvailable = true;
      expect(await repository.refreshJobDetail('audit-job'), isTrue);
      expect(repository.mechanizationSyncError, isNull);
      assigned = false;
      await repository.refreshMechanizationData();
      expect(repository.dashboardJobs, isEmpty);
      expect(repository.mechanizationSyncError, isNull);
    },
  );

  testWidgets(
    'dashboard shows dispatched assignments below an older focus job',
    (tester) async {
      final api = _Api(
        handlers: {
          #jobs: (call) async => {
            'data': call.namedArguments[#status] == 'active'
                ? [
                    {
                      ..._Api._job('arrived'),
                      'id': 'old',
                      'reference': 'JOB-OLD',
                      'scheduled_date': '2000-01-01',
                    },
                    {
                      ..._Api._job('dispatched'),
                      'id': 'new',
                      'reference': 'JOB-NEW',
                      'scheduled_date': '2000-01-02',
                    },
                  ]
                : <Object?>[],
          },
        },
      );
      final repository = (await tester.runAsync(() => _operator(api)))!;
      addTearDown(repository.dispose);
      expect(repository.pastAssignments, isEmpty);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: OperatorJobsScreen(
              repository: repository,
              onOpenSchedule: () {},
              onRefresh: repository.refreshMechanizationData,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('JOB-OLD'), findsOneWidget);
      expect(find.text('JOB-NEW'), findsOneWidget);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1;
      for (final width in [320.0, 1000.0]) {
        tester.view.physicalSize = Size(width, 1000);
        await tester.pumpAndSettle();
        for (final entry in {'old': 'JOB-OLD', 'new': 'JOB-NEW'}.entries) {
          final status = find.byKey(
            ValueKey('operator-job-status-${entry.key}'),
          );
          final header = find
              .ancestor(of: find.text(entry.value), matching: find.byType(Row))
              .first;
          expect(
            tester.getRect(status).right,
            closeTo(tester.getRect(header).right, .1),
          );
          expect(
            tester.getRect(status).top,
            closeTo(tester.getRect(header).top, .1),
          );
        }
        expect(tester.takeException(), isNull);
      }
      expect(tester.takeException(), isNull);
    },
  );

  test('parses the documented data.path trail', () async {
    final repository = await _operator(_Api());
    addTearDown(repository.dispose);
    await repository.refreshWorkProgress('audit-job');
    expect(repository.jobs.single.trackPoints, hasLength(2));
  });

  test('brief accept preserves full plot and farmer', () async {
    final repository = await _operator(_Api());
    addTearDown(repository.dispose);
    expect(repository.jobs.single.plot.boundaryPoints, hasLength(3));
    expect(repository.jobs.single.farmerName, 'Audit Farmer');
    expect(await repository.acceptAssignment('audit-job'), isTrue);
    expect(repository.jobs.single.plot.boundaryPoints, hasLength(3));
    expect(repository.jobs.single.farmerName, 'Audit Farmer');
  });

  test('completed active job is retained in history', () async {
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
    expect(repository.jobs, hasLength(1));
    expect(repository.history, hasLength(1));
    // Active job absent from today/calendar, e.g. an overdue assignment.
  });

  test('approved override reaches start endpoint', () async {
    final api = _Api();
    final repository = await _operator(api);
    addTearDown(repository.dispose);
    expect(
      await repository.startJob('audit-job', overrideId: 'approved-override'),
      isTrue,
    );
    expect(api.startCalls, 1);
    // Location pre-check fails; start must be allowed to send override_id.
  });

  test('in-flight refresh cannot restore data after logout', () async {
    final gate = Completer<Map<String, Object?>>();
    final repository = OperatorLocalRepository.seeded(
      mobileApiClient: _Api(meGate: gate),
    );
    addTearDown(repository.dispose);
    repository.setMechanizationAccessToken('old-account');
    repository.setMechanizationAccessToken(null);
    expect(repository.jobs, isEmpty);
    gate.complete({'data': <String, Object?>{}});
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(repository.jobs, isEmpty);
  });

  test('restricted and working tractors cannot be scheduled', () async {
    final repository = UnionOperationsRepository.seeded(
      mobileApiClient: _Api(),
    );
    addTearDown(repository.dispose);
    repository.setMechanizationAccessToken('audit-token');
    await _wait(() => repository.isSyncingMechanization);
    expect(repository.mechanizationSyncError, isNull);
    await repository.refreshScreen(UnionDataScreen.tractors);
    expect(repository.tractors, hasLength(4));
    expect(repository.tractors.every((t) => !t.status.canSchedule), isTrue);
    // Inputs: working, suspended, unavailable, decommissioned.
  });

  test('completed and closed requests retain their terminal states', () async {
    final repository = UnionOperationsRepository.seeded(
      mobileApiClient: _Api(),
    );
    addTearDown(repository.dispose);
    repository.setMechanizationAccessToken('audit-token');
    await _wait(() => repository.isSyncingMechanization);
    await repository.refreshScreen(UnionDataScreen.requests);
    expect(repository.requests, hasLength(2));
    expect(repository.requests.map((r) => r.status).toSet(), {
      OperationsRequestStatus.completed,
      OperationsRequestStatus.closed,
    });
  });

  test('operator retries keep the same documented client_event_id', () async {
    var attempts = 0;
    final ids = <String?>[];
    final api = _Api(
      handlers: {
        #markEnRoute: (call) async {
          ids.add(call.namedArguments[#clientEventId] as String?);
          if (++attempts == 1) {
            throw const KwanzaTrackApiException('Request timed out.');
          }
          return {'data': _Api._job('en_route', full: false)};
        },
      },
    );
    final repository = await _operator(api);
    addTearDown(repository.dispose);
    expect(await repository.startJourney('audit-job'), isFalse);
    expect(await repository.startJourney('audit-job'), isTrue);
    expect(ids.first, isNotEmpty);
    expect(ids[0], ids[1]);
  });

  test('late detail response cannot undo an operator action', () async {
    final gate = Completer<Map<String, Object?>>();
    final api = _Api(
      handlers: {
        #job: (_) => gate.future,
        #markEnRoute: (_) async => {'data': _Api._job('en_route', full: false)},
      },
    );
    final repository = await _operator(api);
    addTearDown(repository.dispose);
    final oldRead = repository.refreshJobDetail('audit-job');
    expect(await repository.startJourney('audit-job'), isTrue);
    gate.complete({'data': _Api._job('dispatched')});
    await oldRead;
    expect(repository.jobs.single.status, OperatorJobStatus.enRoute);
  });

  test(
    'manager account switch ignores old reads and loads the new account',
    () async {
      final oldRead = Completer<Map<String, Object?>>();
      final api = _Api(
        handlers: {
          #me: (call) => call.namedArguments[#token] == 'old'
              ? oldRead.future
              : Future.value({
                  'data': {
                    'user': {'name': 'New manager'},
                  },
                }),
          #jobs: (call) async => {
            'data': [
              {
                ..._Api._job('scheduled'),
                'id': '${call.namedArguments[#token]}-job',
              },
            ],
          },
        },
      );
      final repository = UnionOperationsRepository.seeded(mobileApiClient: api);
      addTearDown(repository.dispose);
      repository.setMechanizationAccessToken('old');
      repository.setMechanizationAccessToken('new');
      await _wait(() => repository.isSyncingMechanization);
      expect(repository.jobs.single.id, 'new-job');
      oldRead.complete({
        'data': {
          'user': {'name': 'Old manager'},
        },
      });
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(repository.jobs.single.id, 'new-job');
      expect(repository.mechanizationUserName, 'New manager');
    },
  );

  test(
    'brief manager dispatch preserves job detail and updates calendar',
    () async {
      const tractorId = '10000000-0000-4000-8000-000000000001';
      const operatorId = '20000000-0000-4000-8000-000000000001';
      Map<String, Object?> job(String state, bool full) => {
        ..._Api._job(state, full: full),
        'tractor': {'id': tractorId},
        'operator': {'id': operatorId},
      };
      final api = _Api(
        handlers: {
          #jobs: (_) async => {
            'data': [job('scheduled', true)],
          },
          #dispatchJob: (_) async => {'data': job('dispatched', false)},
        },
      );
      final repository = UnionOperationsRepository.seeded(mobileApiClient: api);
      addTearDown(repository.dispose);
      repository.setMechanizationAccessToken('manager');
      await _wait(() => repository.isSyncingMechanization);
      await repository.dispatchJob('audit-job');
      expect(repository.mechanizationActionError, isNull);
      expect(repository.jobs.single.farmerName, 'Audit Farmer');
      expect(repository.jobs.single.plot.boundaryPoints, hasLength(3));
      expect(repository.scheduleJobs.single.status, JobStatus.dispatched);
    },
  );

  test(
    'availability permits adjacent windows and rejects overlapping windows',
    () async {
      final api = _Api(
        handlers: {
          #availability: (_) async => {
            'data': {
              'tractor': [
                {
                  'id': 'morning',
                  'reference': 'JOB-MORNING',
                  'scheduled_date': '2026-10-23',
                  'window_start': '08:00',
                  'window_end': '10:00',
                },
              ],
              'operator': <Object?>[],
              'load_hours': 2,
            },
          },
        },
      );
      final repository = UnionOperationsRepository.seeded(mobileApiClient: api);
      addTearDown(repository.dispose);
      repository.setMechanizationAccessToken('manager');
      await _wait(() => repository.isSyncingMechanization);
      final free = await repository.checkRequestAvailability(
        date: DateTime(2026, 10, 23),
        tractorId: 'tractor',
        operatorId: 'operator',
        windowStart: DateTime(2026, 10, 23, 10),
        duration: const Duration(hours: 2),
      );
      final busy = await repository.checkRequestAvailability(
        date: DateTime(2026, 10, 23),
        tractorId: 'tractor',
        operatorId: 'operator',
        windowStart: DateTime(2026, 10, 23, 9),
        duration: const Duration(hours: 2),
      );
      expect(free!.isAvailable, isTrue);
      expect(busy!.isAvailable, isFalse);
    },
  );

  test(
    'verification waits for external farmer confirmation and closes with actual payment',
    () async {
      var externallyConfirmed = false;
      final api = _Api(
        handlers: {
          #job: (_) async => {
            'data': {
              ..._Api._job('completed'),
              'farmer_confirmed_at': externallyConfirmed
                  ? '2026-10-23T12:00:00+03:00'
                  : null,
            },
          },
          #verifyJob: (_) async => {
            'data': {
              ..._Api._job('verified', full: false),
              'verified_acres': 2,
            },
          },
          #closeJob: (_) async => {
            'data': {
              ..._Api._job('closed', full: false),
              'payment_status': 'unpaid',
            },
          },
        },
      );
      final repository = UnionOperationsRepository.seeded(mobileApiClient: api);
      addTearDown(repository.dispose);
      repository.setMechanizationAccessToken(
        'manager',
        permissions: ['mech.view', 'mech.jobs.manage'],
      );
      await _wait(() => repository.isSyncingMechanization);
      await repository.verifyJob(jobId: 'audit-job', verifiedAcres: 2);
      expect(repository.mechanizationActionError, contains('confirmation'));
      expect(api.calls.where((c) => c.memberName == #verifyJob), isEmpty);
      externallyConfirmed = true;
      await repository.verifyJob(jobId: 'audit-job', verifiedAcres: 2);
      expect(repository.mechanizationActionError, isNull);
      expect(repository.jobs.single.status, JobStatus.verified);
      await repository.closeJob('audit-job', paymentStatus: 'unpaid');
      final close = api.calls.singleWhere(
        (call) => call.memberName == #closeJob,
      );
      expect(close.namedArguments[#paymentStatus], 'unpaid');
      expect(repository.jobs.single.status, JobStatus.closed);
      expect(
        api.calls.where(
          (call) => [
            #farmerConfirm,
            #farmerOtp,
            #confirmJob,
          ].contains(call.memberName),
        ),
        isEmpty,
      );
    },
  );

  test(
    'restricted staff retain readable modules and cannot mutate jobs',
    () async {
      final api = _Api(
        handlers: {
          #dashboard: (_) async =>
              throw const KwanzaTrackApiException('Forbidden', statusCode: 403),
        },
      );
      final repository = UnionOperationsRepository.seeded(mobileApiClient: api);
      addTearDown(repository.dispose);
      repository.setMechanizationAccessToken(
        'viewer',
        permissions: ['mech.view'],
      );
      await _wait(() => repository.isSyncingMechanization);
      expect(repository.jobs, isNotEmpty);
      expect(
        api.calls.where((call) => call.memberName == #calendarBacklog),
        isEmpty,
      );
      await repository.closeJob('audit-job', paymentStatus: 'paid');
      expect(repository.mechanizationActionError, contains('permission'));
      expect(api.calls.where((call) => call.memberName == #closeJob), isEmpty);
    },
  );

  test('paginated job lists include later pages', () async {
    final api = _Api(
      handlers: {
        #jobs: (call) async {
          final page = call.namedArguments[#page] as int? ?? 1;
          final active = call.namedArguments[#status] == 'active';
          return {
            'data': active
                ? [
                    {..._Api._job('dispatched'), 'id': 'job-$page'},
                  ]
                : <Object?>[],
            'meta': {'last_page': active ? 2 : 1},
          };
        },
      },
    );
    final repository = await _operator(api);
    addTearDown(repository.dispose);
    expect(repository.dashboardJobs.map((j) => j.id).toSet(), {
      'job-1',
      'job-2',
    });
  });
  test(
    'a failed manager module refresh retains already loaded records',
    () async {
      var failRead = false;
      final api = _Api(
        handlers: {
          #jobs: (_) async {
            if (failRead) {
              throw const KwanzaTrackApiException(
                'Jobs temporarily unavailable',
                statusCode: 503,
              );
            }
            return {
              'data': [_Api._job('dispatched')],
            };
          },
        },
      );
      final repository = UnionOperationsRepository.seeded(mobileApiClient: api);
      addTearDown(repository.dispose);
      repository.setMechanizationAccessToken('manager');
      await _wait(() => repository.isSyncingMechanization);
      failRead = true;
      await repository.refreshMechanizationData();
      expect(repository.jobs.single.id, 'audit-job');
      expect(
        repository.mechanizationSyncError,
        contains('temporarily unavailable'),
      );
    },
  );

  test(
    'operator reads an approved override and rejects an expired approval',
    () async {
      var expired = false;
      final api = _Api(
        handlers: {
          #job: (_) async => {
            'data': {
              ..._Api._job('arrived'),
              'pending_override': {
                'id': 'approval-1',
                'status': 'approved',
                'expires_at': DateTime.now()
                    .add(Duration(hours: expired ? -1 : 2))
                    .toIso8601String(),
              },
            },
          },
        },
      );
      final repository = await _operator(api);
      addTearDown(repository.dispose);
      await repository.refreshJobDetail('audit-job');
      expect(repository.jobs.single.usableOverrideId, 'approval-1');
      expired = true;
      await repository.refreshJobDetail('audit-job');
      expect(repository.jobs.single.usableOverrideId, isNull);
    },
  );

  test(
    'start denial updates the checklist even after an approved override',
    () async {
      final api = _Api(
        handlers: {
          #startJob: (_) async => throw const KwanzaTrackApiException(
            'Inspection is missing',
            code: 'start_denied',
            statusCode: 422,
            errors: {
              'can_start': false,
              'override_allowed': false,
              'failed': ['inspection_today'],
              'checks': [],
            },
          ),
        },
      );
      final repository = await _operator(api);
      addTearDown(repository.dispose);
      expect(
        await repository.startJob('audit-job', overrideId: 'approval-1'),
        isFalse,
      );
      expect(repository.startCheckFor('audit-job')!.failed, [
        'inspection_today',
      ]);
      expect(repository.startCheckFor('audit-job')!.overrideAllowed, isFalse);
    },
  );
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
  _Api({this.meGate, this.handlers = const {}});
  final Map<Symbol, Future<Map<String, Object?>> Function(Invocation)> handlers;
  final List<Invocation> calls = [];
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
    calls.add(invocation);
    final custom = handlers[invocation.memberName];
    if (custom != null) return custom(invocation);
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
