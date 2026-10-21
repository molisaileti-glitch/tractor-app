import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw'),
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @darkModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the dark KwanzaTrack theme'**
  String get darkModeDescription;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @swahili.
  ///
  /// In en, this message translates to:
  /// **'Kiswahili'**
  String get swahili;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @assignedJobs.
  ///
  /// In en, this message translates to:
  /// **'Assigned jobs'**
  String get assignedJobs;

  /// No description provided for @activeAndCompleted.
  ///
  /// In en, this message translates to:
  /// **'{active} active, {completed} completed'**
  String activeAndCompleted(int active, int completed);

  /// No description provided for @dataStatus.
  ///
  /// In en, this message translates to:
  /// **'Data status'**
  String get dataStatus;

  /// No description provided for @updatingInformation.
  ///
  /// In en, this message translates to:
  /// **'Updating your information...'**
  String get updatingInformation;

  /// No description provided for @informationUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Your information is up to date.'**
  String get informationUpToDate;

  /// No description provided for @operator.
  ///
  /// In en, this message translates to:
  /// **'Tractor operator'**
  String get operator;

  /// No description provided for @unionStaff.
  ///
  /// In en, this message translates to:
  /// **'Union staff'**
  String get unionStaff;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @jobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobs;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @serviceRequests.
  ///
  /// In en, this message translates to:
  /// **'Service Requests'**
  String get serviceRequests;

  /// No description provided for @oversight.
  ///
  /// In en, this message translates to:
  /// **'Oversight'**
  String get oversight;

  /// No description provided for @tractors.
  ///
  /// In en, this message translates to:
  /// **'Tractors'**
  String get tractors;

  /// No description provided for @operators.
  ///
  /// In en, this message translates to:
  /// **'Operators'**
  String get operators;

  /// No description provided for @farmers.
  ///
  /// In en, this message translates to:
  /// **'Farmers'**
  String get farmers;

  /// No description provided for @maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @unionOperations.
  ///
  /// In en, this message translates to:
  /// **'Union Operations'**
  String get unionOperations;

  /// No description provided for @operatorDashboard.
  ///
  /// In en, this message translates to:
  /// **'Operator Dashboard'**
  String get operatorDashboard;

  /// No description provided for @jobHistory.
  ///
  /// In en, this message translates to:
  /// **'Job History'**
  String get jobHistory;

  /// No description provided for @assignmentsRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Assignments refreshed successfully.'**
  String get assignmentsRefreshed;

  /// No description provided for @selectAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select the language used throughout the app.'**
  String get selectAppLanguage;

  /// No description provided for @overrides.
  ///
  /// In en, this message translates to:
  /// **'Overrides'**
  String get overrides;

  /// No description provided for @exceptions.
  ///
  /// In en, this message translates to:
  /// **'Exceptions'**
  String get exceptions;

  /// No description provided for @oversightDescription.
  ///
  /// In en, this message translates to:
  /// **'Overrides, exceptions and field control decisions'**
  String get oversightDescription;

  /// No description provided for @noOverridesFound.
  ///
  /// In en, this message translates to:
  /// **'No overrides found.'**
  String get noOverridesFound;

  /// No description provided for @noExceptionsFound.
  ///
  /// In en, this message translates to:
  /// **'No exceptions found.'**
  String get noExceptionsFound;

  /// No description provided for @requestedBy.
  ///
  /// In en, this message translates to:
  /// **'Requested by {name}'**
  String requestedBy(String name);

  /// No description provided for @requestedAt.
  ///
  /// In en, this message translates to:
  /// **'Requested {date}'**
  String requestedAt(String date);

  /// No description provided for @expiresAt.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String expiresAt(String date);

  /// No description provided for @metersFromPlot.
  ///
  /// In en, this message translates to:
  /// **'{distance} m from plot'**
  String metersFromPlot(int distance);

  /// No description provided for @deny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get deny;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @acknowledge.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge'**
  String get acknowledge;

  /// No description provided for @resolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get resolve;

  /// No description provided for @denyOverride.
  ///
  /// In en, this message translates to:
  /// **'Deny Override'**
  String get denyOverride;

  /// No description provided for @approveOverride.
  ///
  /// In en, this message translates to:
  /// **'Approve Override'**
  String get approveOverride;

  /// No description provided for @decisionNote.
  ///
  /// In en, this message translates to:
  /// **'Decision note'**
  String get decisionNote;

  /// No description provided for @resolveException.
  ///
  /// In en, this message translates to:
  /// **'Resolve Exception'**
  String get resolveException;

  /// No description provided for @resolutionNote.
  ///
  /// In en, this message translates to:
  /// **'Resolution note'**
  String get resolutionNote;

  /// No description provided for @actionNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'Action not completed'**
  String get actionNotCompleted;

  /// No description provided for @pastAssignments.
  ///
  /// In en, this message translates to:
  /// **'Past assignments'**
  String get pastAssignments;

  /// No description provided for @noPastAssignments.
  ///
  /// In en, this message translates to:
  /// **'No past assignments yet'**
  String get noPastAssignments;

  /// No description provided for @completedJobsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Completed jobs will appear here.'**
  String get completedJobsAppearHere;

  /// No description provided for @scheduledAt.
  ///
  /// In en, this message translates to:
  /// **'Scheduled {date}'**
  String scheduledAt(String date);

  /// No description provided for @finishedAt.
  ///
  /// In en, this message translates to:
  /// **'Finished {time}'**
  String finishedAt(String time);

  /// No description provided for @areaServiced.
  ///
  /// In en, this message translates to:
  /// **'Area serviced {area} ha'**
  String areaServiced(String area);

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get chooseDate;

  /// No description provided for @noAssignmentsOn.
  ///
  /// In en, this message translates to:
  /// **'No assignments on {date}.'**
  String noAssignmentsOn(String date);

  /// No description provided for @assignmentsOn.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 assignment} other{{count} assignments}} on {date}.'**
  String assignmentsOn(int count, String date);

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @plot.
  ///
  /// In en, this message translates to:
  /// **'Plot'**
  String get plot;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @openArrival.
  ///
  /// In en, this message translates to:
  /// **'Open Arrival'**
  String get openArrival;

  /// No description provided for @continueWork.
  ///
  /// In en, this message translates to:
  /// **'Continue Work'**
  String get continueWork;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @openJob.
  ///
  /// In en, this message translates to:
  /// **'Open Job'**
  String get openJob;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String goodMorning(String name);

  /// No description provided for @allAssignments.
  ///
  /// In en, this message translates to:
  /// **'All assignments'**
  String get allAssignments;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @scheduledForDate.
  ///
  /// In en, this message translates to:
  /// **'Scheduled for this date'**
  String get scheduledForDate;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @notYetClosed.
  ///
  /// In en, this message translates to:
  /// **'Not yet closed'**
  String get notYetClosed;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @finishedJobs.
  ///
  /// In en, this message translates to:
  /// **'Finished jobs'**
  String get finishedJobs;

  /// No description provided for @focusJob.
  ///
  /// In en, this message translates to:
  /// **'Focus job'**
  String get focusJob;

  /// No description provided for @viewSchedule.
  ///
  /// In en, this message translates to:
  /// **'View Schedule'**
  String get viewSchedule;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noCurrentAssignment.
  ///
  /// In en, this message translates to:
  /// **'No current assignment'**
  String get noCurrentAssignment;

  /// No description provided for @activeJobAppearsHere.
  ///
  /// In en, this message translates to:
  /// **'Your active job will appear here when it is ready.'**
  String get activeJobAppearsHere;

  /// No description provided for @acresValue.
  ///
  /// In en, this message translates to:
  /// **'{value} acres'**
  String acresValue(String value);

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @assigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assigned;

  /// No description provided for @dispatched.
  ///
  /// In en, this message translates to:
  /// **'Dispatched'**
  String get dispatched;

  /// No description provided for @enRoute.
  ///
  /// In en, this message translates to:
  /// **'En route'**
  String get enRoute;

  /// No description provided for @arrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get arrived;

  /// No description provided for @jobInProgress.
  ///
  /// In en, this message translates to:
  /// **'Job in progress'**
  String get jobInProgress;

  /// No description provided for @completedPendingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Completed pending confirmation'**
  String get completedPendingConfirmation;

  /// No description provided for @ploughing.
  ///
  /// In en, this message translates to:
  /// **'Ploughing'**
  String get ploughing;

  /// No description provided for @harrowing.
  ///
  /// In en, this message translates to:
  /// **'Harrowing'**
  String get harrowing;

  /// No description provided for @planting.
  ///
  /// In en, this message translates to:
  /// **'Planting'**
  String get planting;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @phoneOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Phone number or email'**
  String get phoneOrEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @mechanizationOperations.
  ///
  /// In en, this message translates to:
  /// **'Mechanization operations'**
  String get mechanizationOperations;

  /// No description provided for @enterOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to your phone'**
  String get enterOtpCode;

  /// No description provided for @verificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to {destination}.'**
  String verificationCodeSent(String destination);

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifying;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
