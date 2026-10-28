import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:tractor/src/additional_data/location/domain/entities/device_location.dart';
import 'package:tractor/src/additional_data/location/domain/repositories/location_repository.dart';
import 'package:tractor/src/additional_data/location/domain/usecases/check_plot_geofence.dart';
import 'package:tractor/src/core/network/mechanization_mobile_api_client.dart';
import 'package:tractor/src/features/farmer/domain/entities/farm_plot.dart';
import 'package:tractor/src/features/manager/data/repositories/union_operations_repository.dart';
import 'package:tractor/src/features/manager/presentation/screens/operations_shell.dart';
import 'package:tractor/src/features/operator/data/repositories/operator_local_repository.dart';
import 'package:tractor/src/features/operator/presentation/screens/operator_shell.dart';
import 'package:tractor/src/features/operator/presentation/widgets/operator_live_job_map.dart';
import 'package:tractor/src/l10n/generated/app_localizations.dart';
import 'package:tractor/src/shared/application/app_preferences_controller.dart';

void main() {
  test('operator loads and refreshes only the requested screen', () async {
    final api = _ScreenApi();
    final repo = OperatorLocalRepository.seeded(mobileApiClient: api);
    addTearDown(repo.dispose);
    repo.setMechanizationAccessToken('operator');
    await _settle(() => repo.isSyncingMechanization);
    expect(api.names, [#me, #jobs]);
    expect(api.calls.last.namedArguments[#status], 'active');
    api.calls.clear();
    await repo.ensureScreenLoaded(OperatorDataScreen.dashboard);
    expect(api.calls, isEmpty);
    await repo.refreshScreen(OperatorDataScreen.schedule);
    expect(api.names, [#calendar]);
    api.calls.clear();
    await repo.refreshScreen(OperatorDataScreen.history);
    expect(api.names, [#jobs]);
    expect(
      api.calls.single.namedArguments[#status],
      'completed,verified,closed,cancelled',
    );
    api.calls.clear();
    await repo.refreshScreen(OperatorDataScreen.profile);
    expect(api.names, [#me]);
  });

  test(
    'concurrent refreshes share a request and keep errors on that screen',
    () async {
      final api = _ScreenApi();
      final repo = OperatorLocalRepository.seeded(mobileApiClient: api);
      addTearDown(repo.dispose);
      repo.setMechanizationAccessToken('operator');
      await _settle(() => repo.isSyncingMechanization);
      api.calls.clear();
      api.calendarGate = Completer<Map<String, Object?>>();
      final first = repo.refreshScreen(OperatorDataScreen.schedule);
      final second = repo.refreshScreen(OperatorDataScreen.schedule);
      expect(api.names, [#calendar]);
      expect(repo.isRefreshingScreen(OperatorDataScreen.dashboard), isFalse);
      api.calendarGate!.completeError(
        const MechanizationApiException('Calendar unavailable'),
      );
      await Future.wait([first, second]);
      expect(
        repo.screenError(OperatorDataScreen.schedule),
        'Calendar unavailable',
      );
      expect(repo.screenError(OperatorDataScreen.dashboard), isNull);
      api.calendarGate = null;
      await repo.refreshScreen(OperatorDataScreen.schedule);
      expect(repo.screenError(OperatorDataScreen.schedule), isNull);
    },
  );

  test('union pages do not reload unrelated modules', () async {
    final api = _ScreenApi();
    final repo = UnionOperationsRepository.seeded(mobileApiClient: api);
    addTearDown(repo.dispose);
    repo.setMechanizationAccessToken('manager');
    await _settle(() => repo.isSyncingMechanization);
    expect(api.names, [#me, #dashboard, #jobs, #overrides, #exceptions]);
    for (final entry in <UnionDataScreen, List<Symbol>>{
      UnionDataScreen.schedule: [#calendar],
      UnionDataScreen.jobs: [#jobs],
      UnionDataScreen.requests: [#requests],
      UnionDataScreen.oversight: [#overrides, #exceptions],
      UnionDataScreen.tractors: [#tractors, #tractors],
      UnionDataScreen.operators: [#operators],
      UnionDataScreen.farmers: [#farmers],
      UnionDataScreen.maintenance: [#tractors],
      UnionDataScreen.settings: [#me],
    }.entries) {
      api.calls.clear();
      await repo.refreshScreen(entry.key);
      expect(api.names, entry.value, reason: entry.key.name);
      expect(repo.screenError(entry.key), isNull);
    }
  });

  for (final operator in [true, false]) {
    testWidgets(
      '${operator ? 'operator' : 'union'} dashboard stays idle and tabs load once',
      (tester) async {
        final api = _ScreenApi();
        final operatorRepo = OperatorLocalRepository.seeded(
          mobileApiClient: api,
        );
        final managerRepo = UnionOperationsRepository.seeded(
          mobileApiClient: api,
        );
        final preferences = AppPreferencesController();
        addTearDown(operatorRepo.dispose);
        addTearDown(managerRepo.dispose);
        addTearDown(preferences.dispose);
        await tester.runAsync(() async {
          if (operator) {
            operatorRepo.setMechanizationAccessToken('operator');
            await _settle(() => operatorRepo.isSyncingMechanization);
          } else {
            managerRepo.setMechanizationAccessToken('manager');
            await _settle(() => managerRepo.isSyncingMechanization);
          }
        });
        await tester.pumpWidget(
          _app(
            operator
                ? OperatorShell(
                    repository: operatorRepo,
                    preferences: preferences,
                    onLogout: () {},
                  )
                : OperationsShell(
                    repository: managerRepo,
                    preferences: preferences,
                    onLogout: () {},
                  ),
          ),
        );
        await tester.pumpAndSettle();
        api.calls.clear();
        await tester.pump(const Duration(minutes: 3));
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();
        expect(api.calls, isEmpty);
        await tester.tap(find.byIcon(Icons.calendar_month_outlined).last);
        await tester.pumpAndSettle();
        expect(api.names, [#calendar]);
        api.calls.clear();
        await tester.tap(find.byIcon(Icons.dashboard_outlined).last);
        await tester.pumpAndSettle();
        expect(api.calls, isEmpty);
        await tester.tap(find.byIcon(Icons.refresh_rounded).last);
        await tester.pumpAndSettle();
        expect(
          api.names,
          operator
              ? [#me, #jobs]
              : [#me, #dashboard, #jobs, #overrides, #exceptions],
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets(
    'one job refresh cycle stops under another route and in background',
    (tester) async {
      final previous = GoogleMapsFlutterPlatform.instance;
      GoogleMapsFlutterPlatform.instance = _MapPlatform();
      addTearDown(() => GoogleMapsFlutterPlatform.instance = previous);
      final api = _ScreenApi();
      final repo = OperatorLocalRepository.seeded(mobileApiClient: api);
      addTearDown(repo.dispose);
      await tester.runAsync(() async {
        repo.setMechanizationAccessToken('operator');
        await _settle(() => repo.isSyncingMechanization);
      });
      api.calls.clear();
      final key = GlobalKey<OperatorLiveJobMapState>();
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: OperatorLiveJobMap(
              key: key,
              repository: repo,
              jobId: 'job-1',
              fill: true,
              routeEnabled: false,
              locationRepository: _PhoneLocation(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(api.names, [#job, #jobPath]);
      api.calls.clear();
      await tester.pump(const Duration(seconds: 12));
      await tester.pumpAndSettle();
      expect(api.names, [#job, #jobPath]);
      final navigator = Navigator.of(
        tester.element(find.byType(OperatorLiveJobMap)),
      );
      unawaited(
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('Photos')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      api.calls.clear();
      await tester.pump(const Duration(seconds: 36));
      expect(api.calls, isEmpty);
      navigator.pop();
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 36));
      expect(api.calls, isEmpty);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(seconds: 12));
      await tester.pumpAndSettle();
      expect(api.names, [#job, #jobPath]);
      api.calls.clear();
      final refreshes = Future.wait([
        key.currentState!.refresh(),
        key.currentState!.refresh(),
      ]);
      await tester.pumpAndSettle();
      await refreshes;
      expect(api.names, [#job, #jobPath]);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('field evidence uses three raw verification fixes', (
    tester,
  ) async {
    final previous = GoogleMapsFlutterPlatform.instance;
    GoogleMapsFlutterPlatform.instance = _MapPlatform();
    addTearDown(() => GoogleMapsFlutterPlatform.instance = previous);
    final api = _ScreenApi();
    final repo = OperatorLocalRepository.seeded(mobileApiClient: api);
    final location = _VerificationPhoneLocation();
    addTearDown(repo.dispose);
    await tester.runAsync(() async {
      repo.setMechanizationAccessToken('operator');
      await _settle(() => repo.isSyncingMechanization);
    });
    final key = GlobalKey<OperatorLiveJobMapState>();
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: OperatorLiveJobMap(
            key: key,
            repository: repo,
            jobId: 'job-1',
            fill: true,
            routeEnabled: false,
            refreshOnOpen: false,
            pollingEnabled: false,
            locationRepository: location,
          ),
        ),
      ),
    );
    await tester.pump();
    final result = await tester.runAsync(
      () => key.currentState!.acquireFieldEvidence(
        maximumAccuracyMeters: 50,
        maximumFixAge: const Duration(seconds: 15),
      ),
    );
    await tester.pump();

    expect(result!.isReady, isTrue);
    expect(location.verificationSubscriptions, 1);
    expect(location.nativeFallbackSubscriptions, 0);
    expect(location.normalSubscriptions, 2);
    expect(location.samples, contains(result.location));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test(
    'server boundary/proximity failures and missing permission never start work',
    () async {
      final api = _ScreenApi();
      final repo = OperatorLocalRepository.seeded(mobileApiClient: api);
      addTearDown(repo.dispose);
      repo.setMechanizationAccessToken('operator');
      await _settle(() => repo.isSyncingMechanization);
      for (final failure in [
        'tractor_on_plot',
        'phone_on_plot',
        'phone_near_tractor',
        'tractor_fix_fresh',
      ]) {
        api.checkResponse = {
          'can_start': false,
          'override_allowed': true,
          'failed': [failure],
          'checks': [],
        };
        expect(await repo.startJob('job-1'), isFalse, reason: failure);
        expect(repo.startCheckFor('job-1')!.failed, [failure]);
      }
      api.checkResponse = {};
      expect(await repo.startJob('job-1'), isFalse);
      api.checkResponse = {
        'can_start': false,
        'override_allowed': false,
        'failed': ['inspection_today'],
      };
      expect(
        await repo.startJob('job-1', overrideId: 'approved-location-override'),
        isFalse,
      );
      expect(api.names.where((name) => name == #startJob), isEmpty);
    },
  );

  test(
    'start check and start action reuse the same raw evidence fix',
    () async {
      final api = _ScreenApi();
      final repo = OperatorLocalRepository.seeded(mobileApiClient: api);
      addTearDown(repo.dispose);
      repo.setMechanizationAccessToken('operator');
      await _settle(() => repo.isSyncingMechanization);
      api.calls.clear();
      final evidence = _location(-6.05, 35.05);

      expect(await repo.startJob('job-1', phone: evidence), isTrue);

      final checkCall = api.calls.singleWhere(
        (call) => call.memberName == #startCheck,
      );
      final startCall = api.calls.singleWhere(
        (call) => call.memberName == #startJob,
      );
      expect(
        checkCall.namedArguments[#phone],
        startCall.namedArguments[#phone],
      );
      expect(startCall.namedArguments[#phone], {
        'latitude': evidence.latitude,
        'longitude': evidence.longitude,
        'accuracy_m': evidence.accuracyMeters,
      });
    },
  );

  test(
    'positions near opposite farm edges are inside without using the centre',
    () {
      for (final longitude in [35.0001, 35.0999]) {
        final result = const CheckPlotGeofence()(
          plot: _plot,
          location: _location(-6.05, longitude),
        );
        expect(result.isInside, isTrue);
        expect(result.distanceFromPlotMeters, 0);
      }
      expect(
        const CheckPlotGeofence()(
          plot: _plot,
          location: _location(-6.05, 35.1005),
        ).isInside,
        isFalse,
      );
    },
  );

  test(
    'expired phone readings are not sent as current field evidence',
    () async {
      final api = _ScreenApi();
      final repo = OperatorLocalRepository.seeded(mobileApiClient: api);
      addTearDown(repo.dispose);
      repo.setMechanizationAccessToken('operator');
      await _settle(() => repo.isSyncingMechanization);
      await repo.runStartCheck(
        jobId: 'job-1',
        phone: DeviceLocation(
          latitude: -6.05,
          longitude: 35.05,
          accuracyMeters: 5,
          recordedAt: DateTime.now().subtract(const Duration(minutes: 4)),
        ),
      );
      expect(api.calls.last.namedArguments[#phone], isNull);
      await repo.runStartCheck(jobId: 'job-1', phone: _location(-6.05, 35.05));
      expect(api.calls.last.namedArguments[#phone], {
        'latitude': -6.05,
        'longitude': 35.05,
        'accuracy_m': 5,
      });
    },
  );

  test(
    'operator preserves server GPS policy plot tolerance and check evidence',
    () async {
      final api = _ScreenApi();
      final repo = OperatorLocalRepository.seeded(mobileApiClient: api);
      addTearDown(repo.dispose);
      repo.setMechanizationAccessToken('operator');
      await _settle(() => repo.isSyncingMechanization);

      expect(repo.phoneAccuracyMaxMeters, 75);
      expect(repo.phoneFixMaximumAge, const Duration(seconds: 120));
      expect(repo.maybeJobById('job-1')!.plot.toleranceMeters, 50);

      api.checkResponse = {
        'can_start': false,
        'override_allowed': true,
        'failed': ['phone_near_tractor'],
        'checks': [],
        'tolerance_m': 50,
        'checked_at': '2026-10-28T08:00:00Z',
        'phone': {
          'latitude': -6.05,
          'longitude': 35.05,
          'accuracy_m': 8,
          'distance_to_plot_m': 0,
          'distance_to_tractor_m': 1183,
        },
        'tractor': {
          'latitude': -6.06,
          'longitude': 35.06,
          'age_s': 4,
          'distance_to_plot_m': 1180,
          'online': true,
        },
      };
      final result = await repo.runStartCheck(
        jobId: 'job-1',
        phone: _location(-6.05, 35.05),
      );

      expect(result!.toleranceMeters, 50);
      expect(result.phone!.accuracyMeters, 8);
      expect(result.phone!.distanceToTractorMeters, 1183);
      expect(result.tractor!.ageSeconds, 4);
      expect(result.tractor!.distanceToPlotMeters, 1180);
      expect(
        result.checkedAt,
        DateTime.parse('2026-10-28T08:00:00Z').toLocal(),
      );
    },
  );

  test(
    'edge positions count as inside and outside distance measures the nearest edge',
    () {
      expect(
        const CheckPlotGeofence()(
          plot: _plot,
          location: _location(-6.05, 35.1),
        ).isInside,
        isTrue,
      );
      final outside = const CheckPlotGeofence()(
        plot: _plot,
        location: _location(-6.05, 35.1001),
      );
      expect(outside.isInside, isFalse);
      expect(outside.distanceFromPlotMeters, inInclusiveRange(10, 12));
    },
  );

  test('geofence distinguishes boundary tolerance uncertainty and outside', () {
    const tolerantPlot = FarmPlot(
      id: 'small',
      name: 'Small farm',
      areaHectares: 1,
      location: 'Field',
      boundaryRegistered: true,
      toleranceMeters: 20,
      boundaryPoints: [
        BoundaryPoint(label: 'A', latitude: -6, longitude: 35),
        BoundaryPoint(label: 'B', latitude: -6, longitude: 35.001),
        BoundaryPoint(label: 'C', latitude: -6.001, longitude: 35.001),
        BoundaryPoint(label: 'D', latitude: -6.001, longitude: 35),
      ],
    );
    DeviceLocation at(double longitude, {double accuracy = 5}) =>
        DeviceLocation(
          latitude: -6.0005,
          longitude: longitude,
          accuracyMeters: accuracy,
          recordedAt: DateTime.now(),
        );

    expect(
      const CheckPlotGeofence()(
        plot: tolerantPlot,
        location: DeviceLocation(
          latitude: -6.0005,
          longitude: 35.0005,
          accuracyMeters: 5,
          recordedAt: _fixedNow,
        ),
      ).state,
      PlotGeofenceState.unavailable,
      reason: 'A deliberately old fixture must not be accepted as live GPS.',
    );
    expect(
      const CheckPlotGeofence()(
        plot: tolerantPlot,
        location: at(35.0011),
      ).state,
      PlotGeofenceState.withinTolerance,
    );
    expect(
      const CheckPlotGeofence()(
        plot: tolerantPlot,
        location: at(35.00125, accuracy: 15),
      ).state,
      PlotGeofenceState.uncertain,
    );
    expect(
      const CheckPlotGeofence()(
        plot: tolerantPlot,
        location: at(35.0015, accuracy: 5),
      ).state,
      PlotGeofenceState.outsideAllowedArea,
    );
  });

  test(
    'stale GPS and a centre without a polygon cannot establish boundary presence',
    () {
      final stale = DeviceLocation(
        latitude: -6.05,
        longitude: 35.05,
        accuracyMeters: 5,
        recordedAt: DateTime.now().subtract(const Duration(minutes: 4)),
      );
      expect(
        const CheckPlotGeofence()(plot: _plot, location: stale).isInside,
        isFalse,
      );
      const centreOnly = FarmPlot(
        id: 'centre',
        name: 'Centre only',
        areaHectares: 1,
        location: '',
        boundaryRegistered: false,
        boundaryPoints: [
          BoundaryPoint(label: 'Centre', latitude: -6.05, longitude: 35.05),
        ],
      );
      expect(
        const CheckPlotGeofence()(
          plot: centreOnly,
          location: _location(-6.05, 35.05),
        ).isInside,
        isFalse,
      );
    },
  );
}

final _fixedNow = DateTime.utc(2026, 1, 1);

DeviceLocation _location(double lat, double lng) => DeviceLocation(
  latitude: lat,
  longitude: lng,
  accuracyMeters: 5,
  recordedAt: DateTime.now(),
);
const _plot = FarmPlot(
  id: 'plot',
  name: 'Farm',
  areaHectares: 10,
  location: 'Field',
  boundaryRegistered: true,
  boundaryPoints: [
    BoundaryPoint(label: 'A', latitude: -6, longitude: 35),
    BoundaryPoint(label: 'B', latitude: -6, longitude: 35.1),
    BoundaryPoint(label: 'C', latitude: -6.1, longitude: 35.1),
    BoundaryPoint(label: 'D', latitude: -6.1, longitude: 35),
  ],
);

Widget _app(Widget home) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);
Future<void> _settle(bool Function() busy) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (busy()) {
    if (DateTime.now().isAfter(deadline)) fail('Screen fixture timed out');
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}

class _PhoneLocation implements LocationRepository {
  @override
  Future<LocationResult> getCurrentLocation() async =>
      LocationSuccess(_location(-6.05, 35.05));
  @override
  Stream<DeviceLocation> watchLocation() => const Stream.empty();
}

class _VerificationPhoneLocation implements VerificationLocationRepository {
  _VerificationPhoneLocation()
    : samples = [
        for (var index = 0; index < 3; index++)
          DeviceLocation(
            latitude: -6.05 + index * 0.000005,
            longitude: 35.05 + index * 0.000005,
            accuracyMeters: 7,
            recordedAt: DateTime.now().add(Duration(seconds: index * 3)),
          ),
      ];

  final List<DeviceLocation> samples;
  int verificationSubscriptions = 0;
  int nativeFallbackSubscriptions = 0;
  int normalSubscriptions = 0;

  @override
  Future<LocationResult> getCurrentLocation() async =>
      LocationSuccess(samples.first);

  @override
  Stream<DeviceLocation> watchLocation() {
    normalSubscriptions += 1;
    return const Stream.empty();
  }

  @override
  Stream<DeviceLocation> watchVerificationLocation({
    bool forceNativeProvider = false,
  }) {
    verificationSubscriptions += 1;
    if (forceNativeProvider) nativeFallbackSubscriptions += 1;
    return Stream.fromIterable(samples);
  }
}

class _MapPlatform extends GoogleMapsFlutterPlatform {
  @override
  Widget buildViewWithConfiguration(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required MapWidgetConfiguration widgetConfiguration,
    MapConfiguration mapConfiguration = const MapConfiguration(),
    MapObjects mapObjects = const MapObjects(),
  }) => const SizedBox.expand();
}

class _ScreenApi implements MechanizationMobileApiClient {
  final calls = <Invocation>[];
  List<Symbol> get names => calls.map((call) => call.memberName).toList();
  Completer<Map<String, Object?>>? calendarGate;
  Map<String, Object?> checkResponse = {
    'can_start': true,
    'override_allowed': false,
    'failed': [],
    'checks': [],
  };
  String get day => DateTime.now().toIso8601String().split('T').first;
  Map<String, Object?> _jobData([String status = 'in_progress']) => {
    'id': 'job-1',
    'reference': 'JOB-1',
    'status': status,
    'scheduled_date': day,
    'window_start': '08:00',
    'window_end': '12:00',
    'tractor': {'id': 'tractor-1', 'asset_no': 'T-1'},
    'operator': {'id': 'operator-1', 'name': 'Operator'},
    'farmer': {'id': 'farmer-1', 'name': 'Farmer'},
    'service_type': {'code': 'PLOUGH', 'name': 'Ploughing'},
    'plot': {
      'id': 'plot-1',
      'name': 'Farm',
      'mapped': true,
      'tolerance_m': 50,
      'boundary': [
        for (final point in _plot.boundaryPoints)
          {'latitude': point.latitude, 'longitude': point.longitude},
      ],
    },
    'tractor_live': {
      'online': true,
      'position': {
        'latitude': -6.05,
        'longitude': 35.05,
        'fix_time': DateTime.now().toUtc().toIso8601String(),
      },
    },
  };
  @override
  dynamic noSuchMethod(Invocation call) {
    calls.add(call);
    return _handle(call);
  }

  Future<Map<String, Object?>> _handle(Invocation call) async {
    Object? data;
    switch (call.memberName) {
      case #me:
        data = {
          'user': {'name': 'Operator'},
          'today': [],
          'policy': {'phone_accuracy_max_m': 75, 'fix_max_age_s': 120},
        };
      case #jobs:
        data = [
          _jobData(
            call.namedArguments[#status] ==
                    'completed,verified,closed,cancelled'
                ? 'completed'
                : 'in_progress',
          ),
        ];
      case #job:
        data = _jobData();
      case #jobPath:
        data = {'path': [], 'live': null};
      case #startCheck:
        data = checkResponse;
      case #startJob:
        data = _jobData();
      case #calendar:
        if (calendarGate != null) return calendarGate!.future;
        data = {
          'events': [
            {
              'id': 'job-1',
              'reference': 'JOB-1',
              'status': 'in_progress',
              'start': '${day}T08:00:00',
              'end': '${day}T12:00:00',
              'farmer': 'Farmer',
              'plot': 'Farm',
              'tractor': 'T-1',
              'operator': 'Operator',
              'service_type': 'ploughing',
            },
          ],
        };
      case #dashboard:
        data = {'pending_requests': 0, 'maintenance_count': 0};
      default:
        data = <Object?>[];
    }
    return {'data': data};
  }
}
