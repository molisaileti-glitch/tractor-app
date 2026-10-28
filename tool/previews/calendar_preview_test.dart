import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tractor/src/components/job_schedule_calendar.dart';
import 'package:tractor/src/core/theme/app_theme.dart';
import 'package:tractor/src/l10n/generated/app_localizations.dart';

/// Render the actual widget with sample data for design review:
/// flutter test --dart-define=CALENDAR_PREVIEW=true tool/previews/calendar_preview_test.dart
void main() {
  testWidgets(
    'render calendar and expanded jobs for review',
    (tester) async {
      await tester.runAsync(() async {
        final fontFile = File(
          Platform.isWindows
              ? 'C:/Windows/Fonts/segoeui.ttf'
              : '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
        );
        final font = FontLoader('ReviewFont')
          ..addFont(
            Future.value(ByteData.sublistView(fontFile.readAsBytesSync())),
          );
        await font.load();
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await icons.load();
      });
      tester.view.physicalSize = const Size(1200, 1300);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final boundary = GlobalKey();
      final day = DateTime(2026, 10, 25);
      final entries = <ScheduleAssignment>[];
      for (var i = 0; i < 5; i++) {
        entries.add(
          ScheduleAssignment(
            id: 'demo-$i',
            reference: 'JOB-0000${i + 1}',
            start: day.add(Duration(hours: i < 4 ? 8 : 14)),
            end: day.add(Duration(hours: i < 4 ? 12 : 16)),
            title: [
              'Ploughing - Asha',
              'Harrowing - Juma',
              'Planting - Rehema',
              'Ploughing - Baraka',
              'Ploughing - Neema',
            ][i],
            details: [
              '${i + 2} acres - Plot ${i + 1}',
              'Tractor T-00${i + 1}',
              'Operator ${i + 1}',
            ],
            status: i == 4
                ? 'Completed pending confirmation'
                : i == 1
                ? 'En route'
                : 'Dispatched',
            statusKey: i == 4
                ? 'completedPendingConfirmation'
                : i == 1
                ? 'enRoute'
                : 'dispatched',
            color: i == 4
                ? const Color(0xFF10B981)
                : i == 1
                ? const Color(0xFFF97316)
                : const Color(0xFFF59E0B),
            onOpen: () {},
          ),
        );
      }
      entries.add(
        ScheduleAssignment(
          id: 'tomorrow',
          reference: 'JOB-000006',
          start: day.add(const Duration(days: 1, hours: 9)),
          end: day.add(const Duration(days: 1, hours: 13)),
          title: 'Ploughing - Halima',
          details: ['4 acres - East field', 'Tractor T-006'],
          status: 'Scheduled',
          statusKey: 'scheduled',
          color: const Color(0xFF64748B),
          onOpen: () {},
        ),
      );
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: MaterialApp(
            theme: AppTheme.light().copyWith(
              appBarTheme: AppTheme.light().appBarTheme.copyWith(
                titleTextStyle: const TextStyle(
                  fontFamily: 'ReviewFont',
                  fontSize: 20,
                  color: Color(0xFF182235),
                ),
              ),
              textTheme: AppTheme.light().textTheme.apply(
                fontFamily: 'ReviewFont',
              ),
              primaryTextTheme: AppTheme.light().primaryTextTheme.apply(
                fontFamily: 'ReviewFont',
              ),
            ),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Schedule - design preview (sample jobs)'),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: JobScheduleCalendar(
                  initialDate: day,
                  assignments: entries,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _capture(tester, boundary, 'calendar-tablet.png');
      final more = find.text('+2\nmore');
      await tester.ensureVisible(more);
      await tester.tap(more);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('expanded-calendar-jobs')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await _capture(tester, boundary, 'calendar-expanded.png');
    },
    skip: !const bool.fromEnvironment('CALENDAR_PREVIEW'),
  );
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final folder = Directory('build/review')..createSync(recursive: true);
    File('${folder.path}/$name').writeAsBytesSync(data!.buffer.asUint8List());
    image.dispose();
  });
}
