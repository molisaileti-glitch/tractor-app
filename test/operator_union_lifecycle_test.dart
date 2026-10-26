import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:tractor/src/features/manager/presentation/screens/operations_jobs_view.dart';
import 'package:tractor/src/additional_data/location/domain/entities/device_location.dart';
import 'package:tractor/src/core/network/kwanza_track_mobile_api_client.dart';
import 'package:tractor/src/features/manager/data/repositories/union_operations_repository.dart';
import 'package:tractor/src/features/manager/domain/entities/operations_models.dart';
import 'package:tractor/src/features/operator/data/repositories/operator_local_repository.dart';
import 'package:tractor/src/features/operator/domain/entities/operator_job.dart';

void main() {
  test(
    'manager and operator complete the documented lifecycle around external farmer confirmation',
    () async {
      final server = _MechanizationServer();
      final manager = UnionOperationsRepository.seeded(mobileApiClient: server);
      final operator = OperatorLocalRepository.seeded(mobileApiClient: server);
      addTearDown(manager.dispose);
      addTearDown(operator.dispose);
      manager.setMechanizationAccessToken(
        'manager',
        permissions: _MechanizationServer.staffPermissions,
      );
      await _settle(() => manager.isSyncingMechanization);
      await Future.wait([
        manager.refreshScreen(UnionDataScreen.requests),
        manager.refreshScreen(UnionDataScreen.tractors),
        manager.refreshScreen(UnionDataScreen.operators),
      ]);
      expect(manager.requests.single.status, OperationsRequestStatus.pending);
      await manager.approveRequest(
        id: 'request-1',
        estimateAmount: 180000,
        priority: 'normal',
      );
      expect(manager.requests.single.status, OperationsRequestStatus.approved);
      final slot = DateTime.now();
      final jobId = await manager.scheduleRequest(
        requestId: 'request-1',
        tractorId: _MechanizationServer.tractorId,
        operatorId: _MechanizationServer.operatorId,
        scheduledAt: DateTime(slot.year, slot.month, slot.day, 7),
        estimatedHours: 4,
        implement: 'Disc plough',
      );
      expect(manager.jobs.single.status, JobStatus.scheduled);
      expect(manager.scheduleJobs.single.id, jobId);
      await manager.dispatchJob(jobId);
      expect(manager.jobs.single.status, JobStatus.dispatched);

      operator.setMechanizationAccessToken(
        'operator',
        permissions: ['mech.view', 'mech.operate'],
      );
      await _settle(() => operator.isSyncingMechanization);
      await operator.refreshJobDetail(jobId);
      final phone = DeviceLocation(
        latitude: -6.1705,
        longitude: 35.7405,
        accuracyMeters: 8,
        recordedAt: DateTime.now(),
      );
      expect(await operator.acceptAssignment(jobId, phone: phone), isTrue);
      expect(await operator.startJourney(jobId, phone: phone), isTrue);
      expect(await operator.arriveJob(jobId, phone: phone), isTrue);
      expect(
        await operator.recordInspection(
          tractorId: _MechanizationServer.tractorId,
          jobId: jobId,
          checklist: {'engine_oil': true},
          isFit: true,
          phone: phone,
        ),
        isTrue,
      );
      expect(
        await operator.startJob(
          jobId,
          phone: phone,
          hourMeter: 100,
          implement: 'Disc plough',
        ),
        isTrue,
      );
      expect(operator.jobs.single.status, OperatorJobStatus.inProgress);
      expect(
        await operator.pauseJob(jobId: jobId, reason: 'Rest', phone: phone),
        isTrue,
      );
      expect(operator.jobs.single.status, OperatorJobStatus.paused);
      expect(await operator.resumeJob(jobId, phone: phone), isTrue);
      expect(
        await operator.completeJob(
          jobId: jobId,
          reportedAcres: 3,
          notes: 'Done',
          phone: phone,
        ),
        isTrue,
      );
      expect(
        operator.history.single.status,
        OperatorJobStatus.completedPendingConfirmation,
      );
      expect(operator.history.single.plot.boundaryPoints, hasLength(3));
      expect(operator.history.single.farmerConfirmedAt, isNull);
      expect(
        operator.history.single.areaServicedHectares,
        closeTo(1.21405692672, 0.000001),
      );

      await manager.verifyJob(jobId: jobId, verifiedAcres: 2.95);
      expect(manager.mechanizationActionError, contains('confirmation'));
      expect(server.verificationCalls, 0);
      // This represents the OTHER application's server-to-server confirmation.
      server.confirmFromFarmerApp();
      await manager.verifyJob(
        jobId: jobId,
        verifiedAcres: 2.95,
        note: 'Trail reviewed',
      );
      expect(manager.mechanizationActionError, isNull);
      expect(manager.jobs.single.status, JobStatus.verified);
      await manager.closeJob(jobId, paymentStatus: 'deposit');
      expect(manager.jobs.single.status, JobStatus.closed);
      expect(manager.scheduleJobs.single.status, JobStatus.closed);
      expect(manager.requests.single.status, OperationsRequestStatus.closed);
      expect(manager.jobs.single.paymentStatus, 'deposit');
      expect(server.jobRecord!['status'], 'closed');
    },
  );

  test(
    'cancelling only the job returns its request to the manager backlog',
    () async {
      final server = _MechanizationServer();
      final manager = UnionOperationsRepository.seeded(mobileApiClient: server);
      addTearDown(manager.dispose);
      manager.setMechanizationAccessToken(
        'manager',
        permissions: _MechanizationServer.staffPermissions,
      );
      await _settle(() => manager.isSyncingMechanization);
      await manager.refreshScreen(UnionDataScreen.requests);
      await manager.approveRequest(
        id: 'request-1',
        estimateAmount: 180000,
        priority: 'normal',
      );
      final jobId = await manager.scheduleRequest(
        requestId: 'request-1',
        tractorId: _MechanizationServer.tractorId,
        operatorId: _MechanizationServer.operatorId,
        scheduledAt: DateTime.now(),
        estimatedHours: 4,
        implement: 'Disc plough',
      );
      await manager.cancelJob(
        jobId: jobId,
        reason: JobCancellationReason.tractorUnavailable,
        notes: 'Rebook',
      );
      expect(manager.mechanizationActionError, isNull);
      expect(manager.jobs.single.status, JobStatus.cancelled);
      expect(manager.requests.single.status, OperationsRequestStatus.approved);
      expect(server.lastCancelRequest, isFalse);
      // Cancellation refreshes the affected request, without an unused backlog read.
      expect(server.backlogReads, 0);
    },
  );
  testWidgets('manager payment selection reaches the close endpoint', (
    tester,
  ) async {
    final server = _MechanizationServer();
    final day = DateTime.now().toIso8601String().split('T').first;
    server.requestRecord['status'] = 'verified';
    server.jobRecord = {
      'id': _MechanizationServer.jobId,
      'status': 'verified',
      'scheduled_date': day,
      'window_start': '07:00',
      'window_end': '11:00',
      'farmer': server.requestRecord['farmer'],
      'plot': server.requestRecord['plot'],
      'service_type': server.requestRecord['service_type'],
      'tractor': {'id': _MechanizationServer.tractorId, 'asset_no': 'T-001'},
      'operator': {'id': _MechanizationServer.operatorId, 'name': 'Juma'},
      'request': {'id': 'request-1', 'status': 'verified'},
      'payment_status': 'unpaid',
    };
    final manager = UnionOperationsRepository.seeded(mobileApiClient: server);
    addTearDown(manager.dispose);
    await tester.runAsync(() async {
      manager.setMechanizationAccessToken(
        'manager',
        permissions: _MechanizationServer.staffPermissions,
      );
      await _settle(() => manager.isSyncingMechanization);
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AnimatedBuilder(
              animation: manager,
              builder: (context, _) => OperationsJobsView(repository: manager),
            ),
          ),
        ),
      ),
    );
    await tester.ensureVisible(find.text('Close verified job'));
    await tester.tap(find.text('Close verified job'));
    await tester.pumpAndSettle();
    final cancelButton = find.widgetWithText(OutlinedButton, 'Cancel');
    final closeButton = find.widgetWithText(FilledButton, 'Close job');
    expect(cancelButton, findsOneWidget);
    expect(closeButton, findsOneWidget);
    expect(
      tester.getSize(cancelButton).width,
      closeTo(tester.getSize(closeButton).width, 0.01),
    );
    expect(
      tester.getCenter(cancelButton).dy,
      closeTo(tester.getCenter(closeButton).dy, 0.01),
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('waived').last);
    await tester.pumpAndSettle();
    await tester.tap(closeButton);
    await tester.pumpAndSettle();
    expect(server.jobRecord!['payment_status'], 'waived');
    expect(server.jobRecord!['status'], 'closed');
    expect(tester.takeException(), isNull);
  });
}

Future<void> _settle(bool Function() loading) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (loading()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Repository did not settle');
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}

/// Fake server enforces transitions and deliberately returns brief action jobs.
class _MechanizationServer implements KwanzaTrackMobileApiClient {
  static const tractorId = '10000000-0000-4000-8000-000000000001';
  static const operatorId = '20000000-0000-4000-8000-000000000001';
  static const jobId = '30000000-0000-4000-8000-000000000001';
  static const staffPermissions = [
    'mech.view',
    'mech.requests.manage',
    'mech.jobs.manage',
    'mech.override',
    'mech.exceptions.manage',
  ];
  bool inspected = false;
  int verificationCalls = 0;
  int backlogReads = 0;
  bool? lastCancelRequest;
  Map<String, Object?>? jobRecord;
  final Map<String, Object?> requestRecord = {
    'id': 'request-1',
    'reference': 'SR-000001',
    'external_ref': 'FARMER-APP-ORDER-1',
    'status': 'pending',
    'requested_acres': 3,
    'service_type': {'id': 'service-1', 'code': 'PLOUGH', 'name': 'Ploughing'},
    'farmer': {'id': 'farmer-1', 'name': 'Asha', 'phone': '0712345678'},
    'plot': {
      'id': 'plot-1',
      'name': 'Lower field',
      'mapped': true,
      'area_ha': 1.22,
      'boundary': [
        {'latitude': -6.17, 'longitude': 35.74},
        {'latitude': -6.17, 'longitude': 35.741},
        {'latitude': -6.171, 'longitude': 35.741},
      ],
    },
  };

  void confirmFromFarmerApp() {
    expect(jobRecord!['status'], 'completed');
    jobRecord!['farmer_confirmed_at'] = DateTime.now()
        .toUtc()
        .toIso8601String();
    jobRecord!['farmer_confirmation_method'] = 'integration';
  }

  Map<String, Object?> _brief() => {
    for (final key in [
      'id',
      'reference',
      'status',
      'scheduled_date',
      'window_start',
      'window_end',
      'tractor',
      'operator',
      'planned_acres',
      'reported_acres',
      'verified_acres',
      'geofence_verified',
      'started_at',
      'completed_at',
      'farmer_confirmed_at',
      'payment_status',
    ])
      key: jobRecord![key],
    'request': {'id': requestRecord['id'], 'status': requestRecord['status']},
  };

  void _transition(String expected, String next) {
    expect(jobRecord!['status'], expected);
    jobRecord!['status'] = next;
    requestRecord['status'] = next;
  }

  Map<String, Object?> _response(Object? data) => Map<String, Object?>.from(
    jsonDecode(jsonEncode({'success': true, 'data': data})) as Map,
  );

  @override
  dynamic noSuchMethod(Invocation call) => _handle(call);

  Future<Map<String, Object?>> _handle(Invocation call) async {
    final args = call.namedArguments;
    switch (call.memberName) {
      case #me:
        return _response({
          'user': {
            'name': args[#token] == 'manager' ? 'Union manager' : 'Operator',
            'permissions': args[#token] == 'manager'
                ? staffPermissions
                : ['mech.view', 'mech.operate'],
          },
          'today': jobRecord == null ? [] : [jobRecord],
          'policy': {
            'require_inspection': true,
            'require_farmer_confirmation': true,
          },
          'inspection_checklist': [
            {'key': 'engine_oil', 'label': 'Engine oil'},
          ],
        });
      case #dashboard:
        return _response({});
      case #requests:
        return _response([requestRecord]);
      case #request:
        return _response(requestRecord);
      case #jobs:
        final status = args[#status] as String?;
        final terminal =
            jobRecord != null &&
            [
              'completed',
              'verified',
              'closed',
              'cancelled',
            ].contains(jobRecord!['status']);
        final visible =
            jobRecord != null &&
            (status == null ||
                (status == 'active'
                    ? !terminal
                    : status.split(',').contains(jobRecord!['status'])));
        return _response(visible ? [jobRecord] : []);
      case #calendar:
        return _response({
          'events': jobRecord == null
              ? []
              : [
                  {
                    'id': jobId,
                    'reference': 'JOB-000001',
                    'status': jobRecord!['status'],
                    'start':
                        '${jobRecord!['scheduled_date']}T${jobRecord!['window_start']}',
                    'end':
                        '${jobRecord!['scheduled_date']}T${jobRecord!['window_end']}',
                    'farmer': 'Asha',
                    'plot': 'Lower field',
                    'tractor_id': tractorId,
                    'tractor': 'T-001',
                    'operator_id': operatorId,
                    'operator': 'Juma',
                  },
                ],
        });
      case #calendarBacklog:
        backlogReads++;
        return _response(
          requestRecord['status'] == 'approved'
              ? [
                  {'id': 'request-1'},
                ]
              : [],
        );
      case #tractors:
        return _response([
          {
            'id': tractorId,
            'asset_no': 'T-001',
            'status':
                jobRecord != null &&
                    ['in_progress', 'paused'].contains(jobRecord!['status'])
                ? 'working'
                : 'available',
            'implements': ['Disc plough'],
          },
        ]);
      case #operators:
        return _response([
          {'id': operatorId, 'name': 'Juma', 'status': 'active'},
        ]);
      case #farmers:
        return _response([requestRecord['farmer']]);
      case #overrides:
      case #exceptions:
        return _response([]);
      case #approveRequest:
        expect(requestRecord['status'], 'pending');
        requestRecord['status'] = 'approved';
        return _response(requestRecord);
      case #scheduleRequest:
        expect(requestRecord['status'], 'approved');
        expect(args[#tractorId], tractorId);
        expect(args[#operatorId], operatorId);
        requestRecord['status'] = 'scheduled';
        jobRecord = {
          'id': jobId,
          'reference': 'JOB-000001',
          'status': 'scheduled',
          'request': {'id': requestRecord['id'], 'status': 'scheduled'},
          'farmer': requestRecord['farmer'],
          'plot': requestRecord['plot'],
          'service_type': requestRecord['service_type'],
          'tractor': {'id': tractorId, 'asset_no': 'T-001'},
          'operator': {'id': operatorId, 'name': 'Juma'},
          'scheduled_date': args[#scheduledDate],
          'window_start': args[#windowStart],
          'window_end': args[#windowEnd],
          'planned_acres': args[#plannedAcres],
          'farmer_confirmed_at': null,
        };
        return _response(jobRecord);
      case #dispatchJob:
        _transition('scheduled', 'dispatched');
        return _response(_brief());
      case #job:
        jobRecord!['request'] = {
          'id': requestRecord['id'],
          'status': requestRecord['status'],
        };
        return _response(jobRecord);
      case #jobPath:
        return _response({
          'path': [
            {
              't': '2026-10-23T07:00:00+03:00',
              'lat': -6.17,
              'lng': 35.74,
              'in': true,
            },
            {
              't': '2026-10-23T07:10:00+03:00',
              'lat': -6.1705,
              'lng': 35.7405,
              'in': true,
            },
          ],
          'live': null,
        });
      case #acceptJob:
        expect(jobRecord!['status'], 'dispatched');
        expect(args[#clientEventId], isNotEmpty);
        return _response(_brief());
      case #markEnRoute:
        _transition('dispatched', 'en_route');
        return _response(_brief());
      case #arriveJob:
        _transition('en_route', 'arrived');
        return _response(_brief());
      case #createInspection:
        expect(args[#checklist], {'engine_oil': true});
        inspected = true;
        return _response({'is_fit': true});
      case #inspectionToday:
        return _response(inspected ? {'is_fit': true} : null);
      case #startCheck:
        return _response({
          'can_start': inspected && jobRecord!['status'] == 'arrived',
          'override_allowed': false,
          'failed': inspected ? [] : ['inspection_today'],
          'checks': [],
        });
      case #startJob:
        expect(inspected, isTrue);
        expect(args[#phone], isNotNull);
        _transition('arrived', 'in_progress');
        jobRecord!['started_at'] = DateTime.now().toUtc().toIso8601String();
        jobRecord!['geofence_verified'] = true;
        jobRecord!['work_seconds'] = 0;
        return _response({
          'job': _brief(),
          'start_check': {'can_start': true},
        });
      case #pauseJob:
        _transition('in_progress', 'paused');
        jobRecord!['work_seconds'] = 1800;
        return _response(_brief());
      case #resumeJob:
        _transition('paused', 'in_progress');
        return _response(_brief());
      case #completeJob:
        _transition('in_progress', 'completed');
        jobRecord!['reported_acres'] = args[#reportedAcres];
        jobRecord!['completed_at'] = DateTime.now().toUtc().toIso8601String();
        jobRecord!['verification'] = {
          'est_acres': 2.95,
          'inside_pct': 98,
          'points': 120,
        };
        return _response(_brief());
      case #verifyJob:
        verificationCalls++;
        expect(jobRecord!['farmer_confirmed_at'], isNotNull);
        _transition('completed', 'verified');
        jobRecord!['verified_acres'] = args[#verifiedAcres];
        return _response(_brief());
      case #closeJob:
        _transition('verified', 'closed');
        jobRecord!['payment_status'] = args[#paymentStatus];
        return _response(_brief());
      case #cancelJob:
        lastCancelRequest = args[#cancelRequest] as bool?;
        jobRecord!['status'] = 'cancelled';
        requestRecord['status'] = lastCancelRequest == true
            ? 'cancelled'
            : 'approved';
        return _response(_brief());
      default:
        fail('Unexpected or farmer-owned API call: ${call.memberName}');
    }
  }
}
