import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tractor/src/components/time_aware_greeting.dart';
import 'package:tractor/src/l10n/generated/app_localizations.dart';

void main() {
  for (final fixture in <({int hour, String expected})>[
    (hour: 8, expected: 'Good morning, Asha'),
    (hour: 14, expected: 'Good afternoon, Asha'),
    (hour: 19, expected: 'Good evening, Asha'),
  ]) {
    testWidgets('dashboard greeting reflects hour ${fixture.hour}', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          TimeAwareGreeting(
            name: 'Asha',
            clock: () => DateTime(2026, 10, 28, fixture.hour),
          ),
        ),
      );
      expect(find.text(fixture.expected), findsOneWidget);
    });
  }

  testWidgets('dashboard evening greeting is localized', (tester) async {
    await tester.pumpWidget(
      _app(
        TimeAwareGreeting(
          name: 'Asha',
          clock: () => DateTime(2026, 10, 28, 19),
        ),
        locale: const Locale('sw'),
      ),
    );
    expect(find.text('Habari za jioni, Asha'), findsOneWidget);
  });
}

Widget _app(Widget home, {Locale locale = const Locale('en')}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: home),
);
