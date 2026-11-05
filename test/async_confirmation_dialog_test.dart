// File purpose: Provides regression coverage for Async Confirmation Dialog behavior and its important failure cases.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tractor/src/components/app_dialogs.dart';

void main() {
  testWidgets('async confirmation blocks repeated submits and shows progress', (
    tester,
  ) async {
    final gate = Completer<void>();
    var submissions = 0;
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result = await showAppAsyncConfirmationDialog(
                  context,
                  title: 'Accept assignment?',
                  message: 'Confirm availability.',
                  confirmLabel: 'Accept',
                  workingLabel: 'Accepting...',
                  onConfirm: () async {
                    submissions += 1;
                    await gate.future;
                  },
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accept'));
    await tester.pump();

    expect(submissions, 1);
    expect(find.text('Accepting...'), findsNWidgets(2));
    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    final dialogConfirm = tester.widget<FilledButton>(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(FilledButton),
      ),
    );
    final dialogCancel = tester.widget<OutlinedButton>(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(dialogConfirm.onPressed, isNull);
    expect(dialogCancel.onPressed, isNull);

    gate.complete();
    await tester.pumpAndSettle();
    expect(result, isTrue);
    expect(submissions, 1);
  });
}
