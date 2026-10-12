// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get settings => 'Mipangilio';

  @override
  String get account => 'Akaunti';

  @override
  String get appearance => 'Mwonekano';

  @override
  String get darkMode => 'Mandhari meusi';

  @override
  String get darkModeDescription => 'Tumia mandhari meusi ya KwanzaTrack';

  @override
  String get language => 'Lugha';

  @override
  String get english => 'Kiingereza';

  @override
  String get swahili => 'Kiswahili';

  @override
  String get profile => 'Wasifu';

  @override
  String get assignedJobs => 'Kazi ulizopangiwa';

  @override
  String activeAndCompleted(int active, int completed) {
    return '$active zinaendelea, $completed zimekamilika';
  }

  @override
  String get dataStatus => 'Hali ya taarifa';

  @override
  String get updatingInformation => 'Taarifa zako zinasasishwa...';

  @override
  String get informationUpToDate => 'Taarifa zako zimesasishwa.';

  @override
  String get operator => 'Mwendeshaji wa trekta';

  @override
  String get unionStaff => 'Afisa wa chama';
}
