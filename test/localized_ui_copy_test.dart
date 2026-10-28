import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tractor/src/features/auth/data/repositories/auth_local_repository.dart';
import 'package:tractor/src/features/auth/presentation/screens/login_screen.dart';
import 'package:tractor/src/l10n/generated/app_localizations.dart';
import 'package:tractor/src/l10n/generated/app_localizations_sw.dart';
import 'package:tractor/src/l10n/localized_copy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('active UI copy resolves to Kiswahili', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sw'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) => Column(
            children: [
              Text(context.appText('Confirm your location')),
              Text(context.appText('Farmer confirmation')),
              Text(context.appText('No tractors available')),
              Text(context.appText('Approve request?')),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Thibitisha mahali ulipo'), findsOneWidget);
    expect(find.text('Uthibitisho wa mkulima'), findsOneWidget);
    expect(find.text('Hakuna matrekta yanayopatikana'), findsOneWidget);
    expect(find.text('Uidhinishe ombi?'), findsOneWidget);
  });

  test('every literal appText lookup has a Kiswahili translation', () {
    final lookup = RegExp(r"appText\('([^']+)'\)");
    final missing = <String>{};

    for (final entity in Directory('lib/src').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      for (final match in lookup.allMatches(source)) {
        final english = match.group(1)!;
        if (!swahiliCopy.containsKey(english)) missing.add(english);
      }
    }

    expect(missing, isEmpty, reason: 'Missing Kiswahili UI copy: $missing');
  });

  test('generated login version label is localized', () {
    expect(AppLocalizationsSw().appVersion('1.0.0 (1)'), 'Toleo 1.0.0 (1)');
  });

  testWidgets('login shows the installed app version', (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'SB Mechanization',
      packageName: 'com.example.tractor',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sw'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: LoginScreen(
          repository: AuthLocalRepository(),
          onBack: () {},
          onOpenFarmer: () {},
          onOpenOperations: () {},
          onOpenOperator: () {},
          onOpenTechnician: () {},
          onCreateFarmerAccount: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Toleo 1.0.0 (1)'), findsOneWidget);
  });

  test('launcher icon has transparent rounded corners', () async {
    final bytes = await File(
      'assets/images/tractor_launcher_icon.png',
    ).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final pixels = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

    expect(pixels, isNotNull);
    expect(pixels!.getUint8(3), 0);
    final centreAlphaOffset =
        ((image.height ~/ 2) * image.width + image.width ~/ 2) * 4 + 3;
    expect(pixels.getUint8(centreAlphaOffset), greaterThan(0));
  });
}
