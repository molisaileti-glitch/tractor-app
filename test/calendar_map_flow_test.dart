import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:tractor/src/components/job_schedule_calendar.dart';
import 'package:tractor/src/core/network/kwanza_track_mobile_api_client.dart';
import 'package:tractor/src/features/manager/data/repositories/union_operations_repository.dart';
import 'package:tractor/src/features/manager/presentation/screens/operations_jobs_view.dart';
import 'package:tractor/src/features/manager/presentation/screens/operations_schedule_view.dart';
import 'package:tractor/src/features/operator/data/repositories/operator_local_repository.dart';
import 'package:tractor/src/features/operator/domain/entities/operator_job.dart';
import 'package:tractor/src/features/operator/presentation/screens/operator_schedule_screen.dart';
import 'package:tractor/src/features/operator/presentation/widgets/operator_widgets.dart';
import 'package:tractor/src/features/operator/presentation/widgets/map_position_grouping.dart';
import 'package:tractor/src/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('union job status stays at the right edge with a long label', (
    tester,
  ) async {
    final api = _CalendarApi()..jobStatus = 'completed';
    final repo = UnionOperationsRepository.seeded(mobileApiClient: api);
    addTearDown(repo.dispose);
    await tester.runAsync(() async {
      repo.setMechanizationAccessToken('manager');
      await _settle(() => repo.isSyncingMechanization);
    });
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    for (final width in [320.0, 1000.0]) {
      tester.view.physicalSize = Size(width, 1000);
      await tester.pumpWidget(
        _app(
          SingleChildScrollView(child: OperationsJobsView(repository: repo)),
          scale: 1.5,
        ),
      );
      await tester.pumpAndSettle();
      final status = find.byKey(const ValueKey('union-job-status-job-0'));
      final header = find
          .ancestor(of: find.text('Ploughing'), matching: find.byType(Row))
          .first;
      expect(
        tester.getRect(status).right,
        closeTo(tester.getRect(header).right, .1),
      );
      expect(
        tester.getRect(status).top,
        closeTo(tester.getRect(header).top, .1),
      );
      expect(find.byTooltip('Job actions'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('calendar keeps its Swahili job label without a legend', (
    tester,
  ) async {
    final day = DateTime(2026, 10, 25);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sw'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: JobScheduleCalendar(
              initialDate: day,
              assignments: [
                ScheduleAssignment(
                  id: 'complete',
                  reference: 'JOB-COMPLETE',
                  start: day.add(const Duration(hours: 8)),
                  end: day.add(const Duration(hours: 10)),
                  title: 'Kazi',
                  details: [],
                  status: 'Completed pending confirmation',
                  statusKey: 'completedPendingConfirmation',
                  color: const Color(0xFF10B981),
                  onOpen: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Rangi za hali ya kazi'), findsNothing);
    expect(find.byKey(const ValueKey('calendar-status-legend')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('calendar-job-status-complete')),
        matching: find.text('Imekamilika'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('map shows real phone and tractor fixes without a mapped farm', (
    tester,
  ) async {
    final previous = GoogleMapsFlutterPlatform.instance;
    GoogleMapsFlutterPlatform.instance = _MapPlatform();
    addTearDown(() => GoogleMapsFlutterPlatform.instance = previous);
    await tester.pumpWidget(
      _app(
        OperatorMapCard(
          routeEnabled: false,
          routeFromLatitude: -6.15,
          routeFromLongitude: 35.7,
          phoneRecordedAt: DateTime.now(),
          tractorPosition: TractorTrackerPosition(
            tractorId: 'gps-only',
            latitude: -6.2,
            longitude: 35.8,
            online: true,
            fixTime: DateTime.now(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final map = tester.widget<GoogleMap>(find.byType(GoogleMap));
    expect(
      map.markers.map((m) => m.position),
      containsAll([const LatLng(-6.15, 35.7), const LatLng(-6.2, 35.8)]),
    );
    expect(map.polygons, isEmpty);
    expect(map.polylines, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('overnight assignments appear on both days with an exclusive end', () {
    final entry = ScheduleAssignment(
      id: 'night',
      reference: 'NIGHT',
      start: DateTime(2026, 10, 25, 23),
      end: DateTime(2026, 10, 26, 1),
      title: 'Night work',
      details: [],
      status: 'Dispatched',
      color: Colors.orange,
      onOpen: () {},
    );
    expect(entry.occursOn(DateTime(2026, 10, 25)), isTrue);
    expect(entry.occursOn(DateTime(2026, 10, 26)), isTrue);
    expect(entry.occursOn(DateTime(2026, 10, 27)), isFalse);
  });

  test(
    'short neighbouring jobs share readable lanes without moving later jobs',
    () {
      final day = DateTime(2026, 10, 25);
      ScheduleAssignment entry(String id, int minute) => ScheduleAssignment(
        id: id,
        reference: id,
        start: day.add(Duration(hours: 8, minutes: minute)),
        end: day.add(Duration(hours: 8, minutes: minute + 15)),
        title: id,
        details: [],
        status: 'Dispatched',
        color: Colors.orange,
        onOpen: () {},
      );
      final groups = calendarCollisionGroups(
        [entry('A', 0), entry('B', 20), entry('C', 120)],
        day,
        minimumMinutes: 44,
      );
      expect(groups, hasLength(2));
      expect(groups.first.entries.map((e) => e.id), ['A', 'B']);
      expect(groups.last.entries.single.start.hour, 10);
      expect(groups.first.displayEnd.isBefore(groups.last.start), isTrue);
    },
  );

  for (final operator in [true, false]) {
    testWidgets(
      '${operator ? 'operator' : 'manager'} calendar scrolls overlapping short jobs at large text',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final api = _CalendarApi();
        final operatorRepo = OperatorLocalRepository.seeded(
          mobileApiClient: api,
        );
        final managerRepo = UnionOperationsRepository.seeded(
          mobileApiClient: api,
        );
        addTearDown(operatorRepo.dispose);
        addTearDown(managerRepo.dispose);
        await tester.runAsync(() async {
          if (operator) {
            operatorRepo.setMechanizationAccessToken('operator');
            await _settle(() => operatorRepo.isSyncingMechanization);
            await operatorRepo.refreshScreen(OperatorDataScreen.schedule);
          } else {
            managerRepo.setMechanizationAccessToken('manager');
            await _settle(() => managerRepo.isSyncingMechanization);
            await managerRepo.refreshScreen(UnionDataScreen.schedule);
          }
        });
        await tester.pumpWidget(
          _app(
            operator
                ? OperatorScheduleScreen(repository: operatorRepo)
                : SingleChildScrollView(
                    child: OperationsScheduleView(repository: managerRepo),
                  ),
            scale: 2,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('schedule-assignment-job-0')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('schedule-assignment-job-11')),
          findsNothing,
        );
        expect(find.text('+10\nmore'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('calendar-status-legend')),
          findsNothing,
        );
        final status = find.byKey(const ValueKey('calendar-job-status-job-0'));
        expect(
          find.descendant(of: status, matching: find.text('Dispatched')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        final first = tester.getRect(
          find.byKey(const ValueKey('schedule-assignment-job-0')),
        );
        final second = tester.getRect(
          find.byKey(const ValueKey('schedule-assignment-job-1')),
        );
        expect(first.right, lessThanOrEqualTo(second.left));
        final more = find.text('+10\nmore');
        await tester.ensureVisible(more);
        await tester.tap(more);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('expanded-calendar-jobs')),
          findsOneWidget,
        );
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('expanded-assignment-job-9')),
          300,
          scrollable: find.descendant(
            of: find.byKey(const ValueKey('expanded-calendar-jobs')),
            matching: find.byType(Scrollable),
          ),
        );
        expect(tester.takeException(), isNull);
        Navigator.of(
          tester.element(find.byKey(const ValueKey('expanded-calendar-jobs'))),
        ).pop();
        await tester.pumpAndSettle();
        // The view reuses the same calendar component on a tablet as well.
        tester.view.physicalSize = const Size(1200, 1920);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('manager calendar opens the selected full job and its actions', (
    tester,
  ) async {
    final api = _CalendarApi();
    final repo = UnionOperationsRepository.seeded(mobileApiClient: api);
    addTearDown(repo.dispose);
    await tester.runAsync(() async {
      repo.setMechanizationAccessToken('manager');
      await _settle(() => repo.isSyncingMechanization);
      await repo.refreshScreen(UnionDataScreen.schedule);
    });
    await tester.pumpWidget(
      _app(
        SingleChildScrollView(child: OperationsScheduleView(repository: repo)),
      ),
    );
    await tester.pumpAndSettle();
    final card = find.byKey(const ValueKey('schedule-assignment-job-0'));
    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(api.opened, 'job-0');
    expect(find.byType(OperationsJobDetailScreen), findsOneWidget);
    expect(find.text('Calendar Farmer'), findsOneWidget);
    expect(find.text('Review work evidence'), findsOneWidget);
    expect(tester.takeException(), isNull);
    Navigator.of(tester.element(find.byType(OperationsJobDetailScreen))).pop();
    await tester.pumpAndSettle();
    final more = find.text('+10\nmore');
    await tester.ensureVisible(more);
    await tester.tap(more);
    await tester.pumpAndSettle();
    final hidden = find.byKey(const ValueKey('expanded-assignment-job-11'));
    await tester.scrollUntilVisible(
      hidden,
      250,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('expanded-calendar-jobs')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(hidden);
    await tester.pumpAndSettle();
    expect(api.opened, 'job-11');
    expect(find.byType(OperationsJobDetailScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test(
    'trail live position stays tied to the job tractor, with invalid fixes ignored',
    () async {
      final api = _CalendarApi();
      final repo = OperatorLocalRepository.seeded(mobileApiClient: api);
      addTearDown(repo.dispose);
      repo.setMechanizationAccessToken('operator');
      await _settle(() => repo.isSyncingMechanization);
      await repo.refreshWorkProgress('job-0');
      final tractor = repo.trackerPositionFor('tractor-0')!;
      expect(tractor.latitude, -6.20);
      expect(tractor.longitude, 35.80);
      expect(tractor.isLive, isTrue);
      expect(repo.jobById('job-0').trackPoints, hasLength(2));
      api.invalidFix = true;
      await repo.refreshWorkProgress('job-0');
      expect(repo.trackerPositionFor('tractor-0')!.latitude, -6.20);
      expect(repo.jobById('job-0').trackPoints, hasLength(2));
    },
  );

  test('online tractor with an old fix is last known, not live', () {
    final old = TractorTrackerPosition(
      tractorId: 't',
      latitude: -6,
      longitude: 35,
      online: true,
      fixTime: DateTime.now().subtract(const Duration(hours: 1)),
    );
    expect(old.isLive, isFalse);
    expect(
      const TractorTrackerPosition(
        tractorId: 't',
        latitude: -6,
        longitude: 35,
        online: true,
      ).isLive,
      isFalse,
    );
  });

  test(
    'nearby location grouping requires accurate GPS and a fresh tractor fix',
    () {
      bool grouped({
        double accuracy = 8,
        bool live = true,
        double lat = -6.2,
      }) => canGroupOperatorAndTractor(
        phoneLatitude: lat,
        phoneLongitude: 35.8,
        tractorLatitude: -6.2,
        tractorLongitude: 35.8,
        phoneAccuracyMeters: accuracy,
        tractorIsLive: live,
      );
      expect(grouped(), isTrue);
      expect(grouped(accuracy: 100), isFalse);
      expect(grouped(live: false), isFalse);
      expect(grouped(lat: -6.21), isFalse);
    },
  );

  testWidgets(
    'map uses separate phone and tractor coordinates and a person icon',
    (tester) async {
      final previous = GoogleMapsFlutterPlatform.instance;
      GoogleMapsFlutterPlatform.instance = _MapPlatform();
      addTearDown(() => GoogleMapsFlutterPlatform.instance = previous);
      final repo = OperatorLocalRepository.seeded(
        mobileApiClient: _CalendarApi(),
      );
      addTearDown(repo.dispose);
      await tester.runAsync(() async {
        repo.setMechanizationAccessToken('operator');
        await _settle(() => repo.isSyncingMechanization);
        await repo.refreshWorkProgress('job-0');
      });
      final job = repo.jobById('job-0');
      await tester.pumpWidget(
        _app(
          OperatorMapCard(
            job: job,
            showTrack: true,
            tractorPosition: repo.trackerPositionFor('tractor-0'),
            routeFromLatitude: -6.15,
            routeFromLongitude: 35.70,
            phoneRecordedAt: DateTime.now(),
          ),
        ),
      );
      // Marker image rasterisation happens outside the fake widget clock.
      for (var i = 0; i < 30; i++) {
        await tester.runAsync(
          () async => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump();
        final current = tester.widget<GoogleMap>(find.byType(GoogleMap));
        if (current.markers.any(
          (m) =>
              m.markerId.value == 'operator-phone-location' &&
              m.icon is BytesMapBitmap,
        )) {
          break;
        }
      }
      await tester.pumpAndSettle();
      final map = tester.widget<GoogleMap>(find.byType(GoogleMap));
      final phone = map.markers.singleWhere(
        (m) => m.markerId.value == 'operator-phone-location',
      );
      final tractor = map.markers.singleWhere(
        (m) => m.markerId.value == 'tractor-tracker-location',
      );
      expect(phone.position, const LatLng(-6.15, 35.70));
      expect(tractor.position, const LatLng(-6.20, 35.80));
      expect(phone.icon, isA<BytesMapBitmap>());
      expect(phone.infoWindow.title, contains('phone'));
      expect(map.polylines, hasLength(1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        _app(
          OperatorMapCard(
            job: job,
            tractorPosition: repo.trackerPositionFor('tractor-0'),
            routeFromLatitude: -6.20,
            routeFromLongitude: 35.80001,
            phoneRecordedAt: DateTime.now(),
            phoneAccuracyMeters: 8,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final grouped = tester.widget<GoogleMap>(find.byType(GoogleMap));
      expect(
        grouped.markers.where(
          (m) => m.markerId.value == 'operator-phone-location',
        ),
        isEmpty,
      );
      expect(
        grouped.markers.where(
          (m) => m.markerId.value == 'tractor-tracker-location',
        ),
        isEmpty,
      );
      final combined = grouped.markers.singleWhere(
        (m) => m.markerId.value == 'operator-and-tractor',
      );
      expect(combined.position, const LatLng(-6.20, 35.80));
      combined.onTap!();
      await tester.pumpAndSettle();
      expect(find.text('Operator - phone GPS'), findsOneWidget);
      expect(find.text('Tractor - tracker GPS'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _app(Widget child, {double scale = 1}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: Scaffold(body: child),
);

Future<void> _settle(bool Function() busy) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (busy()) {
    if (DateTime.now().isAfter(deadline)) fail('Calendar fixture timed out');
    await Future<void>.delayed(const Duration(milliseconds: 1));
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

class _CalendarApi implements KwanzaTrackMobileApiClient {
  String? opened;
  bool invalidFix = false;
  String jobStatus = 'dispatched';
  final DateTime day = DateUtils.dateOnly(DateTime.now());
  String get date =>
      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  Map<String, Object?> live() => {
    'online': true,
    'position': {
      'latitude': invalidFix ? 200 : -6.20,
      'longitude': 35.80,
      'fix_time': DateTime.now().toUtc().toIso8601String(),
      'age_s': 0,
    },
  };
  Map<String, Object?> _job(String id) => {
    'id': id,
    'reference': 'JOB-${id.split('-').last}',
    'status': jobStatus,
    'scheduled_date': date,
    'window_start': '08:00',
    'window_end': '08:15',
    'tractor': {'id': 'tractor-0', 'asset_no': 'T-001'},
    'operator': {'id': 'operator-0', 'name': 'Calendar Operator'},
    'farmer': {'id': 'f', 'name': 'Calendar Farmer'},
    'plot': {
      'id': 'p',
      'name': 'A long named calendar plot',
      'mapped': true,
      'boundary': [
        {'latitude': -6.18, 'longitude': 35.75},
        {'latitude': -6.19, 'longitude': 35.75},
        {'latitude': -6.19, 'longitude': 35.76},
      ],
    },
    'service_type': {'code': 'PLOUGH', 'name': 'Ploughing'},
    'tractor_live': live(),
  };

  @override
  dynamic noSuchMethod(Invocation call) => _handle(call);

  Future<Map<String, Object?>> _handle(Invocation call) async {
    final args = call.namedArguments;
    Object? data;
    switch (call.memberName) {
      case #me:
        data = {
          'user': {'name': 'Calendar user'},
        };
      case #calendar:
        data = {
          'events': [
            for (var i = 0; i < 12; i++)
              {
                'id': 'job-$i',
                'reference': 'JOB-$i',
                'status': 'dispatched',
                'start': '${date}T08:00:00',
                'end': '${date}T08:15:00',
                'farmer': 'Calendar Farmer',
                'plot': 'A long named calendar plot',
                'tractor': 'T-001',
                'operator': 'Calendar Operator',
                'service_type': 'ploughing',
              },
          ],
        };
      case #jobs:
        data = args[#status] == 'completed,verified,closed,cancelled'
            ? <Object?>[]
            : [_job('job-0')];
      case #job:
        opened = args[#jobId] as String;
        data = _job(opened!);
      case #jobPath:
        data = {
          'live': live(),
          'path': [
            {'lat': -6.18, 'lng': 35.75, 'in': true},
            {'lat': -6.19, 'lng': 35.76, 'in': false},
            if (invalidFix) {'lat': 200, 'lng': 35, 'in': false},
          ],
        };
      case #dashboard:
        data = <String, Object?>{};
      default:
        data = <Object?>[];
    }
    return <String, Object?>{'data': data};
  }
}
