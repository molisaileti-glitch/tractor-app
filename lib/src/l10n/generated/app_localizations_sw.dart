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

  @override
  String get cancel => 'Ghairi';

  @override
  String get submit => 'Wasilisha';

  @override
  String get continueLabel => 'Endelea';

  @override
  String get done => 'Imekamilika';

  @override
  String get close => 'Funga';

  @override
  String get ok => 'Sawa';

  @override
  String get refresh => 'Onyesha upya';

  @override
  String get logout => 'Toka';

  @override
  String get dashboard => 'Dashibodi';

  @override
  String get overview => 'Muhtasari';

  @override
  String get schedule => 'Ratiba';

  @override
  String get history => 'Historia';

  @override
  String get jobs => 'Kazi';

  @override
  String get requests => 'Maombi';

  @override
  String get serviceRequests => 'Maombi ya Huduma';

  @override
  String get oversight => 'Usimamizi';

  @override
  String get tractors => 'Matrekta';

  @override
  String get operators => 'Waendeshaji';

  @override
  String get farmers => 'Wakulima';

  @override
  String get maintenance => 'Matengenezo';

  @override
  String get reports => 'Ripoti';

  @override
  String get unionOperations => 'Shughuli za Chama';

  @override
  String get operatorDashboard => 'Dashibodi ya Mwendeshaji';

  @override
  String get jobHistory => 'Historia ya Kazi';

  @override
  String get assignmentsRefreshed => 'Kazi ulizopangiwa zimesasishwa.';

  @override
  String get selectAppLanguage =>
      'Chagua lugha itakayotumika kwenye programu nzima.';

  @override
  String get overrides => 'Ruhusa Maalum';

  @override
  String get exceptions => 'Matukio Maalum';

  @override
  String get oversightDescription =>
      'Ruhusa maalum, matukio na maamuzi ya kazi shambani';

  @override
  String get noOverridesFound => 'Hakuna ruhusa maalum.';

  @override
  String get noExceptionsFound => 'Hakuna matukio maalum.';

  @override
  String requestedBy(String name) {
    return 'Imeombwa na $name';
  }

  @override
  String requestedAt(String date) {
    return 'Imeombwa $date';
  }

  @override
  String expiresAt(String date) {
    return 'Inaisha $date';
  }

  @override
  String metersFromPlot(int distance) {
    return 'mita $distance kutoka shambani';
  }

  @override
  String get deny => 'Kataa';

  @override
  String get approve => 'Idhinisha';

  @override
  String get acknowledge => 'Thibitisha kuona';

  @override
  String get resolve => 'Tatua';

  @override
  String get denyOverride => 'Kataa Ruhusa Maalum';

  @override
  String get approveOverride => 'Idhinisha Ruhusa Maalum';

  @override
  String get decisionNote => 'Maelezo ya uamuzi';

  @override
  String get resolveException => 'Tatua Tukio';

  @override
  String get resolutionNote => 'Maelezo ya utatuzi';

  @override
  String get actionNotCompleted => 'Hatua haikukamilika';

  @override
  String get pastAssignments => 'Kazi zilizopita';

  @override
  String get noPastAssignments => 'Bado hakuna kazi zilizopita';

  @override
  String get completedJobsAppearHere => 'Kazi zilizokamilika zitaonekana hapa.';

  @override
  String scheduledAt(String date) {
    return 'Imepangwa $date';
  }

  @override
  String finishedAt(String time) {
    return 'Imekamilika $time';
  }

  @override
  String areaServiced(String area) {
    return 'Eneo lililohudumiwa hekta $area';
  }

  @override
  String get chooseDate => 'Chagua tarehe';

  @override
  String noAssignmentsOn(String date) {
    return 'Hakuna kazi tarehe $date.';
  }

  @override
  String assignmentsOn(int count, String date) {
    return 'Kazi $count tarehe $date.';
  }

  @override
  String get farmer => 'Mkulima';

  @override
  String get plot => 'Shamba';

  @override
  String get amount => 'Kiasi';

  @override
  String get openArrival => 'Fungua Kuwasili';

  @override
  String get continueWork => 'Endelea na Kazi';

  @override
  String get navigate => 'Elekeza';

  @override
  String get openJob => 'Fungua Kazi';

  @override
  String get view => 'Tazama';

  @override
  String goodMorning(String name) {
    return 'Habari za asubuhi, $name';
  }

  @override
  String get allAssignments => 'Kazi zote ulizopangiwa';

  @override
  String get today => 'Leo';

  @override
  String get scheduledForDate => 'Zilizopangwa tarehe hii';

  @override
  String get active => 'Zinazoendelea';

  @override
  String get notYetClosed => 'Bado hazijafungwa';

  @override
  String get completed => 'Zilizokamilika';

  @override
  String get finishedJobs => 'Kazi zilizomalizika';

  @override
  String get focusJob => 'Kazi ya kuzingatia';

  @override
  String get viewSchedule => 'Tazama Ratiba';

  @override
  String get retry => 'Jaribu tena';

  @override
  String get noCurrentAssignment => 'Hakuna kazi ya sasa';

  @override
  String get activeJobAppearsHere =>
      'Kazi yako itaonekana hapa itakapokuwa tayari.';

  @override
  String acresValue(String value) {
    return 'Ekari $value';
  }

  @override
  String get scheduled => 'Imepangwa';

  @override
  String get assigned => 'Imepangiwa';

  @override
  String get dispatched => 'Imetumwa';

  @override
  String get enRoute => 'Njiani';

  @override
  String get arrived => 'Imefika';

  @override
  String get jobInProgress => 'Kazi inaendelea';

  @override
  String get completedPendingConfirmation =>
      'Imekamilika, inasubiri uthibitisho';

  @override
  String get ploughing => 'Kulima';

  @override
  String get harrowing => 'Kuharua';

  @override
  String get planting => 'Kupanda';

  @override
  String get welcomeBack => 'Karibu Tena';

  @override
  String get signInToContinue => 'Ingia ili kuendelea';

  @override
  String get phoneOrEmail => 'Namba ya simu au barua pepe';

  @override
  String get enterPassword => 'Weka nenosiri';

  @override
  String get showPassword => 'Onyesha nenosiri';

  @override
  String get hidePassword => 'Ficha nenosiri';

  @override
  String get sendOtp => 'Tuma OTP';

  @override
  String get back => 'Rudi';

  @override
  String get mechanizationOperations => 'Shughuli za mitambo';

  @override
  String get enterOtpCode =>
      'Weka nambari ya tarakimu 6 iliyotumwa kwenye simu yako';

  @override
  String verificationCodeSent(String destination) {
    return 'Tumetuma nambari ya uthibitisho kwa $destination.';
  }

  @override
  String get verifying => 'Inathibitisha...';

  @override
  String get sending => 'Inatuma...';

  @override
  String get resendCode => 'Tuma nambari tena';
}
