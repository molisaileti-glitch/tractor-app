// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get darkModeDescription => 'Use the dark KwanzaTrack theme';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get swahili => 'Kiswahili';

  @override
  String get profile => 'Profile';

  @override
  String get assignedJobs => 'Assigned jobs';

  @override
  String activeAndCompleted(int active, int completed) {
    return '$active active, $completed completed';
  }

  @override
  String get dataStatus => 'Data status';

  @override
  String get updatingInformation => 'Updating your information...';

  @override
  String get informationUpToDate => 'Your information is up to date.';

  @override
  String get operator => 'Tractor operator';

  @override
  String get unionStaff => 'Union staff';
}
