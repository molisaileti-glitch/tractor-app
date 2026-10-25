import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tractor/src/core/network/kwanza_track_mobile_api_client.dart';
import 'package:tractor/src/features/operator/data/repositories/operator_local_repository.dart';
import 'package:tractor/src/features/operator/domain/entities/operator_job.dart';
import 'package:tractor/src/features/operator/presentation/screens/operator_farmer_confirmation_screen.dart';
import 'package:tractor/src/features/operator/presentation/screens/operator_job_photos_screen.dart';
import 'package:tractor/src/features/operator/presentation/screens/operator_arrival_screen.dart';
import 'package:tractor/src/features/operator/presentation/screens/operator_complete_job_screen.dart';
import 'package:tractor/src/additional_data/location/domain/entities/device_location.dart';
import 'package:tractor/src/additional_data/location/domain/repositories/location_repository.dart';
import 'package:tractor/src/l10n/generated/app_localizations.dart';

void main() {
  test(
    'an older inspection read cannot relock photos after a new passed inspection',
    () async {
      final api = _EvidenceApi()..record['status'] = 'arrived';
      final repo = await _repository(api);
      addTearDown(repo.dispose);
      api.inspectionGate = Completer<Map<String, Object?>>();
      final oldRead = repo.refreshInspection('tractor-1');
      expect(
        await repo.recordInspection(
          tractorId: 'tractor-1',
          jobId: 'job-1',
          checklist: {'engine_oil': true},
          isFit: true,
        ),
        isTrue,
      );
      api.inspectionGate!.complete({
        'data': {'id': 'old-inspection', 'is_fit': false},
      });
      await oldRead;
      expect(repo.inspectedToday('tractor-1'), isTrue);
      expect(repo.canAddJobPhotos(repo.jobById('job-1')), isTrue);
    },
  );
  testWidgets(
    'before photos unlock after a fit inspection and zero photos do not block work',
    (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      final api = _EvidenceApi()..record['status'] = 'arrived';
      final repo = (await tester.runAsync(() => _repository(api)))!;
      addTearDown(repo.dispose);
      await tester.pumpWidget(
        _localized(
          OperatorArrivalScreen(
            repository: repo,
            jobId: 'job-1',
            locationRepository: _NoLocation(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final photos = find.byKey(
        const ValueKey('optional-before-service-photos'),
      );
      expect(photos, findsNothing);
      expect(repo.canAddJobPhotos(repo.jobById('job-1')), isFalse);
      await tester.runAsync(
        () => repo.recordInspection(
          tractorId: 'tractor-1',
          jobId: 'job-1',
          checklist: {'engine_oil': false},
          isFit: false,
        ),
      );
      await tester.pumpAndSettle();
      expect(photos, findsNothing);
      await tester.runAsync(
        () => repo.recordInspection(
          tractorId: 'tractor-1',
          jobId: 'job-1',
          checklist: {'engine_oil': true},
          isFit: true,
        ),
      );
      await tester.pumpAndSettle();
      expect(photos, findsOneWidget);
      expect(repo.canAddJobPhotos(repo.jobById('job-1')), isTrue);
      await tester.ensureVisible(photos);
      await tester.tap(photos);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('photo-kind-before')), findsOneWidget);
      Navigator.of(tester.element(find.byType(OperatorJobPhotosScreen))).pop();
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        expect(await repo.startJob('job-1'), isTrue);
        expect(
          await repo.completeJob(jobId: 'job-1', reportedAcres: 2, notes: ''),
          isTrue,
        );
      });
      expect(repo.jobById('job-1').photos, isEmpty);
      expect(api.uploads, 0);
      expect(
        repo.jobById('job-1').status,
        OperatorJobStatus.completedPendingConfirmation,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'completion offers optional after photos and submits without an upload',
    (tester) async {
      final api = _EvidenceApi()..record['status'] = 'in_progress';
      final repo = (await tester.runAsync(() => _repository(api)))!;
      addTearDown(repo.dispose);
      await tester.pumpWidget(
        _localized(OperatorCompleteJobScreen(repository: repo, jobId: 'job-1')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('optional-after-service-photos')),
        findsOneWidget,
      );
      expect(
        find.text(
          'Add after-service photos if useful, or finish the job without photos.',
        ),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField).first, '2');
      final finish = find.text('Finish Job');
      await tester.ensureVisible(finish);
      await tester.tap(finish);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(
        repo.jobById('job-1').status,
        OperatorJobStatus.completedPendingConfirmation,
      );
      expect(find.text('Work submitted'), findsOneWidget);
      expect(api.uploads, 0);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'selected photo remains available after a failed upload and retries successfully',
    (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      final api = _EvidenceApi()..failUpload = true;
      final repo = (await tester.runAsync(() => _repository(api)))!;
      addTearDown(repo.dispose);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OperatorJobPhotosScreen(
            repository: repo,
            jobId: 'job-1',
            initialKind: 'after',
            picker: _TestPicker(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose photo'));
      await tester.pumpAndSettle();
      final upload = find.text('Upload photo');
      await tester.scrollUntilVisible(
        upload,
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(upload);
      await tester.pumpAndSettle();
      expect(find.text('Upload photo'), findsOneWidget);
      expect(repo.jobs.single.photos, isEmpty);
      api.failUpload = false;
      await tester.ensureVisible(find.text('Upload photo'));
      await tester.tap(find.text('Upload photo'));
      await tester.pumpAndSettle();
      expect(repo.jobs.single.photos.single.kind, 'after');
      expect(find.text('Photo uploaded to this job.'), findsOneWidget);
      expect(find.text('Upload photo'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  test(
    'wrong PIN cannot confirm; correct PIN preserves completed state and records server timestamp',
    () async {
      final api = _EvidenceApi();
      final repo = await _repository(api);
      addTearDown(repo.dispose);
      expect(
        await repo.confirmFarmerService(
          jobId: 'job-1',
          method: 'pin',
          credential: '9999',
        ),
        isFalse,
      );
      expect(repo.jobById('job-1').farmerConfirmedAt, isNull);
      expect(
        await repo.confirmFarmerService(
          jobId: 'job-1',
          method: 'pin',
          credential: '0123',
          rating: 4,
        ),
        isTrue,
      );
      expect(repo.jobById('job-1').farmerConfirmedAt, isNotNull);
      expect(
        repo.jobById('job-1').status,
        OperatorJobStatus.completedPendingConfirmation,
      );
      expect(api.lastConfirmation!['pin'], '0123');
      expect(
        await repo.confirmFarmerService(
          jobId: 'job-1',
          method: 'pin',
          credential: '0123',
        ),
        isFalse,
      );
      expect(api.confirmations, 2);
    },
  );

  test(
    'dispute sends the note and flags the work without satisfaction confirmation',
    () async {
      final api = _EvidenceApi();
      final repo = await _repository(api);
      addTearDown(repo.dispose);
      expect(
        await repo.confirmFarmerService(
          jobId: 'job-1',
          method: 'pin',
          credential: '0123',
          dispute: true,
          note: 'Half the plot is unfinished',
        ),
        isTrue,
      );
      expect(api.lastConfirmation!['dispute'], isTrue);
      expect(repo.jobById('job-1').status, OperatorJobStatus.flagged);
      expect(repo.jobById('job-1').farmerConfirmedAt, isNull);
    },
  );

  test(
    'unsent SMS reports failure and OTP confirmation uses code instead of pin',
    () async {
      final api = _EvidenceApi()..sent = false;
      final repo = await _repository(api);
      addTearDown(repo.dispose);
      expect(await repo.sendFarmerOtp('job-1'), isFalse);
      expect(repo.lastActionError, contains('not sent'));
      api.sent = true;
      expect(await repo.sendFarmerOtp('job-1'), isTrue);
      expect(
        await repo.confirmFarmerService(
          jobId: 'job-1',
          method: 'otp',
          credential: '123456',
        ),
        isTrue,
      );
      expect(api.lastConfirmation!['code'], '123456');
      expect(api.lastConfirmation!.containsKey('pin'), isFalse);
    },
  );

  test(
    'photo response stays on its job and does not create a job with the photo ID',
    () async {
      final api = _EvidenceApi();
      final repo = await _repository(api);
      addTearDown(repo.dispose);
      final bytes = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=',
      );
      expect(
        await repo.uploadJobPhoto(
          jobId: 'job-1',
          bytes: bytes,
          fileName: 'after.png',
          kind: 'after',
          caption: 'Completed rows',
        ),
        isTrue,
      );
      expect(repo.jobs.single.id, 'job-1');
      expect(repo.jobs.single.photos.single.kind, 'after');
      expect(repo.jobs.single.photos.single.caption, 'Completed rows');
      expect(repo.jobs.single.farmerConfirmedAt, isNull);
    },
  );

  testWidgets(
    'farmer screen submits the farmer PIN and refreshes confirmation state',
    (tester) async {
      final api = _EvidenceApi();
      final repo = (await tester.runAsync(() => _repository(api)))!;
      addTearDown(repo.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: OperatorFarmerConfirmationScreen(
            repository: repo,
            jobId: 'job-1',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Farmer four-digit PIN'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('farmer-credential')),
        '0123',
      );
      final confirm = find.text('Farmer: confirm satisfaction');
      await tester.ensureVisible(confirm);
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(api.lastConfirmation!['pin'], '0123');
      expect(
        find.text('The farmer has already confirmed this service.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

Future<OperatorLocalRepository> _repository(_EvidenceApi api) async {
  final repo = OperatorLocalRepository.seeded(
    mobileApiClient: api,
    locationRepository: _NoLocation(),
  );
  repo.setMechanizationAccessToken(
    'operator',
    permissions: ['mech.view', 'mech.operate'],
  );
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (repo.isSyncingMechanization) {
    if (DateTime.now().isAfter(deadline)) fail('Evidence fixture timed out');
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  await repo.refreshScreen(OperatorDataScreen.history);
  return repo;
}

class _EvidenceApi implements KwanzaTrackMobileApiClient {
  bool failUpload = false;
  bool sent = true;
  bool? inspectionFit;
  Completer<Map<String, Object?>>? inspectionGate;
  int uploads = 0;
  int confirmations = 0;
  Map<String, Object?>? lastConfirmation;
  final record = <String, Object?>{
    'id': 'job-1',
    'reference': 'JOB-000001',
    'status': 'completed',
    'scheduled_date': '2026-10-25',
    'window_start': '08:00',
    'window_end': '12:00',
    'farmer': {'id': 'farmer-1', 'name': 'Test Farmer', 'has_pin': true},
    'tractor': {'id': 'tractor-1'},
    'plot': {'id': 'plot-1', 'name': 'Test plot'},
    'photos': <Object?>[],
  };
  @override
  dynamic noSuchMethod(Invocation invocation) => _handle(invocation);
  Future<Map<String, Object?>> _handle(Invocation call) async {
    Object? data;
    switch (call.memberName) {
      case #me:
        data = <String, Object?>{};
      case #calendar:
        data = {'events': <Object?>[]};
      case #jobs:
        data =
            call.namedArguments[#status] == 'active' &&
                record['status'] == 'completed'
            ? <Object?>[]
            : [Map<String, Object?>.from(record)];
      case #inspectionToday:
        if (inspectionGate != null) return inspectionGate!.future;
        data = inspectionFit == null
            ? <String, Object?>{}
            : {'id': 'inspection-1', 'is_fit': inspectionFit};
      case #createInspection:
        inspectionFit = call.namedArguments[#isFit] as bool?;
        data = {'id': 'inspection-1', 'is_fit': inspectionFit};
      case #startCheck:
        data = {
          'can_start': true,
          'override_allowed': false,
          'failed': [],
          'checks': [],
        };
      case #startJob:
        record['status'] = 'in_progress';
        data = Map<String, Object?>.from(record);
      case #completeJob:
        record['status'] = 'completed';
        data = Map<String, Object?>.from(record);
      case #job:
        data = Map<String, Object?>.from(record);
      case #farmerOtp:
        data = {'sent': sent, 'expires_in_s': 600};
      case #farmerConfirm:
        confirmations++;
        lastConfirmation = Map<String, Object?>.from(
          call.namedArguments[#body] as Map,
        );
        if (lastConfirmation!['pin'] != '0123' &&
            lastConfirmation!['code'] != '123456') {
          throw const KwanzaTrackApiException(
            'Invalid farmer PIN',
            statusCode: 422,
          );
        }
        if (lastConfirmation!['dispute'] == true) {
          record['status'] = 'flagged';
        } else {
          record['farmer_confirmed_at'] = DateTime.now()
              .toUtc()
              .toIso8601String();
        }
        data = Map<String, Object?>.from(record);
      case #uploadJobPhoto:
        uploads++;
        if (failUpload) {
          throw const KwanzaTrackApiException('Upload failed', statusCode: 503);
        }
        final photo = {
          'id': 'photo-1',
          'kind': call.namedArguments[#kind],
          'caption': call.namedArguments[#caption],
          'url': '/photos/1.png',
        };
        record['photos'] = [photo];
        data = photo;
      default:
        data = <Object?>[];
    }
    return {'data': data};
  }
}

Widget _localized(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

class _NoLocation implements LocationRepository {
  @override
  Future<LocationResult> getCurrentLocation() async =>
      const LocationUnavailable(
        LocationFailure('Phone GPS unavailable in this test.'),
      );
  @override
  Stream<DeviceLocation> watchLocation() => const Stream.empty();
}

class _TestPicker extends ImagePicker {
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async => XFile.fromData(
    base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=',
    ),
    name: 'after.png',
    mimeType: 'image/png',
  );
}
