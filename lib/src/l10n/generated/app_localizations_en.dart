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
  String get darkModeDescription => 'Use the dark SB Mechanization theme';

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

  @override
  String get cancel => 'Cancel';

  @override
  String get submit => 'Submit';

  @override
  String get continueLabel => 'Continue';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get refresh => 'Refresh';

  @override
  String get logout => 'Log out';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get overview => 'Overview';

  @override
  String get schedule => 'Schedule';

  @override
  String get history => 'History';

  @override
  String get jobs => 'Jobs';

  @override
  String get requests => 'Requests';

  @override
  String get serviceRequests => 'Service Requests';

  @override
  String get oversight => 'Oversight';

  @override
  String get tractors => 'Tractors';

  @override
  String get operators => 'Operators';

  @override
  String get farmers => 'Farmers';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get reports => 'Reports';

  @override
  String get unionOperations => 'Union Operations';

  @override
  String get operatorDashboard => 'Operator Dashboard';

  @override
  String get jobHistory => 'Job History';

  @override
  String get assignmentsRefreshed => 'Assignments refreshed successfully.';

  @override
  String get selectAppLanguage =>
      'Select the language used throughout the app.';

  @override
  String get overrides => 'Overrides';

  @override
  String get exceptions => 'Exceptions';

  @override
  String get oversightDescription =>
      'Overrides, exceptions and field control decisions';

  @override
  String get noOverridesFound => 'No overrides found.';

  @override
  String get noExceptionsFound => 'No exceptions found.';

  @override
  String requestedBy(String name) {
    return 'Requested by $name';
  }

  @override
  String requestedAt(String date) {
    return 'Requested $date';
  }

  @override
  String expiresAt(String date) {
    return 'Expires $date';
  }

  @override
  String metersFromPlot(int distance) {
    return '$distance m from plot';
  }

  @override
  String get deny => 'Deny';

  @override
  String get approve => 'Approve';

  @override
  String get acknowledge => 'Acknowledge';

  @override
  String get resolve => 'Resolve';

  @override
  String get denyOverride => 'Deny Override';

  @override
  String get approveOverride => 'Approve Override';

  @override
  String get decisionNote => 'Decision note';

  @override
  String get resolveException => 'Resolve Exception';

  @override
  String get resolutionNote => 'Resolution note';

  @override
  String get actionNotCompleted => 'Action not completed';

  @override
  String get pastAssignments => 'Past assignments';

  @override
  String get noPastAssignments => 'No past assignments yet';

  @override
  String get completedJobsAppearHere => 'Completed jobs will appear here.';

  @override
  String scheduledAt(String date) {
    return 'Scheduled $date';
  }

  @override
  String finishedAt(String time) {
    return 'Finished $time';
  }

  @override
  String areaServiced(String area) {
    return 'Area serviced $area ha';
  }

  @override
  String get chooseDate => 'Choose date';

  @override
  String noAssignmentsOn(String date) {
    return 'No assignments on $date.';
  }

  @override
  String assignmentsOn(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count assignments',
      one: '1 assignment',
    );
    return '$_temp0 on $date.';
  }

  @override
  String get farmer => 'Farmer';

  @override
  String get plot => 'Plot';

  @override
  String get amount => 'Amount';

  @override
  String get openArrival => 'Open Arrival';

  @override
  String get continueWork => 'Continue Work';

  @override
  String get navigate => 'Navigate';

  @override
  String get openJob => 'Open Job';

  @override
  String get view => 'View';

  @override
  String goodMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String get allAssignments => 'All assignments';

  @override
  String get today => 'Today';

  @override
  String get scheduledForDate => 'Scheduled for this date';

  @override
  String get active => 'Active';

  @override
  String get notYetClosed => 'Not yet closed';

  @override
  String get completed => 'Completed';

  @override
  String get finishedJobs => 'Finished jobs';

  @override
  String get focusJob => 'Focus job';

  @override
  String get viewSchedule => 'View Schedule';

  @override
  String get retry => 'Retry';

  @override
  String get noCurrentAssignment => 'No current assignment';

  @override
  String get activeJobAppearsHere =>
      'Your active job will appear here when it is ready.';

  @override
  String acresValue(String value) {
    return '$value acres';
  }

  @override
  String get scheduled => 'Scheduled';

  @override
  String get assigned => 'Assigned';

  @override
  String get dispatched => 'Dispatched';

  @override
  String get enRoute => 'En route';

  @override
  String get arrived => 'Arrived';

  @override
  String get jobInProgress => 'Job in progress';

  @override
  String get completedPendingConfirmation => 'Completed pending confirmation';

  @override
  String get ploughing => 'Ploughing';

  @override
  String get harrowing => 'Harrowing';

  @override
  String get planting => 'Planting';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get phoneOrEmail => 'Phone number or email';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get back => 'Back';

  @override
  String get mechanizationOperations => 'Mechanization operations';

  @override
  String get enterOtpCode => 'Enter the 6-digit code sent to your phone';

  @override
  String verificationCodeSent(String destination) {
    return 'We sent a verification code to $destination.';
  }

  @override
  String get verifying => 'Verifying...';

  @override
  String get sending => 'Sending...';

  @override
  String get resendCode => 'Resend code';

  @override
  String get calendarStatusLegendTitle => 'Job status colours';

  @override
  String get calendarStatusLegendHint =>
      'Match the colour and status label to each job.';

  @override
  String get calendarStatusInProgress => 'In progress';

  @override
  String get calendarStatusCompleted => 'Completed';

  @override
  String get calendarStatusPaused => 'Paused';

  @override
  String get calendarStatusVerified => 'Verified';

  @override
  String get calendarStatusClosed => 'Closed';

  @override
  String get calendarStatusCancelled => 'Cancelled';

  @override
  String get calendarStatusFlagged => 'Flagged';

  @override
  String get optionalBeforeServicePhotos => 'Before-service photos (optional)';

  @override
  String get optionalAfterServicePhotos => 'After-service photos (optional)';

  @override
  String get optionalWorkPhotos => 'Work photos (optional)';

  @override
  String get optionalJobPhotosHint =>
      'Photos are optional. You can start or complete work without uploading photos.';

  @override
  String get inspectionBeforePhotos =>
      'Complete the tractor inspection to add optional before-service photos.';

  @override
  String get optionalBeforePhotosHint =>
      'Add before-service photos if useful, or continue to the start check.';

  @override
  String get optionalAfterPhotosHint =>
      'Add after-service photos if useful, or finish the job without photos.';
}
