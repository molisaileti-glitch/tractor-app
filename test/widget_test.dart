import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tractor/src/app.dart';

void main() {
  testWidgets('shows farmer home and navigates to plots', (tester) async {
    await tester.pumpWidget(const TractorApp());
    await _openLogin(tester);

    await _verifyOtp(tester, '101652');

    expect(find.text('Good morning, Juma'), findsOneWidget);
    expect(find.text('Request Service'), findsOneWidget);

    await tester.tap(find.text('Plots'));
    await tester.pumpAndSettle();

    expect(find.text('My Plots'), findsOneWidget);
    expect(find.text('Kibaha Farm'), findsOneWidget);
    expect(find.text('Add New Plot'), findsOneWidget);
  });

  testWidgets('opens union operations dashboard', (tester) async {
    await tester.pumpWidget(const TractorApp());
    await _openLogin(tester);

    await _verifyOtp(tester, '101650');

    expect(find.text("Today's Overview"), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Manager: Asha'), findsOneWidget);
  });

  testWidgets('opens operator workspace', (tester) async {
    await tester.pumpWidget(const TractorApp());
    await _openLogin(tester);

    await _verifyOtp(tester, '101651');

    expect(find.text('Good morning, John'), findsOneWidget);
    expect(find.text("TODAY'S JOB"), findsOneWidget);
    expect(find.text('Open Job Map'), findsOneWidget);
  });

  testWidgets('opens technician workspace', (tester) async {
    await tester.pumpWidget(const TractorApp());
    await _openLogin(tester);

    await _verifyOtp(tester, '101653');

    expect(find.text('Technician'), findsOneWidget);
    expect(find.text('TRACTOR STATUS'), findsOneWidget);
    expect(find.text('ATTENTION REQUIRED'), findsOneWidget);
  });

  testWidgets('shows phone login and opens OTP screen', (tester) async {
    await tester.pumpWidget(const TractorApp());
    await _openLogin(tester);

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Phone number / Email'), findsOneWidget);
    expect(find.byTooltip('Send OTP'), findsOneWidget);

    await _tapSendOtp(tester);
    await tester.pumpAndSettle();

    expect(find.text('OTP'), findsOneWidget);
    expect(
      find.text('Enter the 6-digit code sent to your phone'),
      findsOneWidget,
    );
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Resend code'), findsOneWidget);
  });

  testWidgets('otp code 101650 opens union operations dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(const TractorApp());
    await _openLogin(tester);

    await _verifyOtp(tester, '101650');

    expect(find.text("Today's Overview"), findsOneWidget);
    expect(find.text('Manager: Asha'), findsOneWidget);
  });
}

Future<void> _openLogin(WidgetTester tester) async {
  expect(find.text('Shamba Bora'), findsOneWidget);
  expect(find.text('Get started'), findsOneWidget);
  await tester.tap(find.text('Get started'));
  await tester.pumpAndSettle();
}

Future<void> _verifyOtp(WidgetTester tester, String code) async {
  await _tapSendOtp(tester);
  await tester.pumpAndSettle();

  for (var index = 0; index < code.length; index++) {
    await tester.enterText(
      find.byKey(ValueKey('otp-digit-$index')),
      code[index],
    );
    await tester.pump();
  }

  await tester.ensureVisible(find.text('Continue'));
  await tester.pump();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

Future<void> _tapSendOtp(WidgetTester tester) async {
  await tester.ensureVisible(find.byTooltip('Send OTP'));
  await tester.pump();
  await tester.tap(find.byTooltip('Send OTP'));
}
