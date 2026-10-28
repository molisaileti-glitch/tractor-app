import 'dart:async';

import 'package:flutter/material.dart';
import 'core/network/mechanization_mobile_api_client.dart';
import 'components/components.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_local_repository.dart';
import 'features/auth/domain/entities/auth_session.dart';
import 'features/auth/presentation/screens/farmer_registration_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/farmer/data/repositories/farmer_local_repository.dart';
import 'features/farmer/presentation/screens/farmer_shell.dart';
import 'features/manager/data/repositories/union_operations_repository.dart';
import 'features/manager/presentation/screens/operations_shell.dart';
import 'onboarding/presentation/screens/app_welcome_screen.dart';
import 'features/operator/data/repositories/operator_local_repository.dart';
import 'features/operator/presentation/screens/operator_shell.dart';
import 'shared/application/app_preferences_controller.dart';
import 'features/technician/data/repositories/technician_local_repository.dart';
import 'features/technician/presentation/screens/technician_shell.dart';
import 'l10n/generated/app_localizations.dart';

enum _Workspace {
  welcome,
  login,
  registerFarmer,
  farmer,
  operations,
  operator,
  technician,
}

class SBMechanizationApp extends StatefulWidget {
  const SBMechanizationApp({super.key});

  @override
  State<SBMechanizationApp> createState() => _SBMechanizationAppState();
}

class _SBMechanizationAppState extends State<SBMechanizationApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final AuthLocalRepository authRepository = AuthLocalRepository();
  final FarmerLocalRepository farmerRepository = FarmerLocalRepository.seeded();
  final UnionOperationsRepository operationsRepository =
      UnionOperationsRepository.seeded();
  final OperatorLocalRepository operatorRepository =
      OperatorLocalRepository.seeded();
  final TechnicianLocalRepository technicianRepository =
      TechnicianLocalRepository.seeded();
  final AppPreferencesController preferences = AppPreferencesController();
  _Workspace _workspace = _Workspace.welcome;
  bool _restoringSession = true;
  bool _sessionExpiryInProgress = false;

  @override
  void initState() {
    super.initState();
    MechanizationMobileApiClient.onUnauthorized = _handleSessionExpired;
    preferences.load();
    _restoreSavedSession();
  }

  @override
  void dispose() {
    if (MechanizationMobileApiClient.onUnauthorized == _handleSessionExpired) {
      MechanizationMobileApiClient.onUnauthorized = null;
    }
    operationsRepository.dispose();
    operatorRepository.dispose();
    authRepository.dispose();
    farmerRepository.dispose();
    technicianRepository.dispose();
    preferences.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: preferences,
      builder: (context, _) => MaterialApp(
        title: 'SB Mechanization',
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigatorKey,
        scaffoldMessengerKey: _messengerKey,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: preferences.themeMode,
        locale: preferences.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        themeAnimationDuration: const Duration(milliseconds: 1000),
        themeAnimationCurve: Curves.easeInOutCubic,
        builder: (context, child) => MediaQuery.withClampedTextScaling(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.3,
          child: child ?? const SizedBox.shrink(),
        ),
        home: AppFadeThroughSwitcher(
          child: _restoringSession
              ? const Scaffold(
                  key: ValueKey('restoring-session'),
                  body: SafeArea(child: AppScreenSkeleton()),
                )
              : KeyedSubtree(
                  key: ValueKey(_workspace),
                  child: switch (_workspace) {
                    _Workspace.welcome => AppWelcomeScreen(
                      onContinue: () =>
                          setState(() => _workspace = _Workspace.login),
                    ),
                    _Workspace.login => LoginScreen(
                      repository: authRepository,
                      onBack: () =>
                          setState(() => _workspace = _Workspace.welcome),
                      onOpenFarmer: () =>
                          setState(() => _workspace = _Workspace.farmer),
                      onOpenOperations: _openOperations,
                      onOpenOperator: _openOperator,
                      onOpenTechnician: _openTechnician,
                      onCreateFarmerAccount: () => setState(
                        () => _workspace = _Workspace.registerFarmer,
                      ),
                    ),
                    _Workspace.registerFarmer => FarmerRegistrationScreen(
                      repository: authRepository,
                      onBack: () =>
                          setState(() => _workspace = _Workspace.login),
                      onRegistered: () =>
                          setState(() => _workspace = _Workspace.farmer),
                    ),
                    _Workspace.farmer => FarmerShell(
                      repository: farmerRepository,
                      onLogout: _confirmLogout,
                    ),
                    _Workspace.operations => OperationsShell(
                      repository: operationsRepository,
                      preferences: preferences,
                      onLogout: _confirmLogout,
                      onThemeChanged: _changeThemeWithReveal,
                    ),
                    _Workspace.operator => OperatorShell(
                      repository: operatorRepository,
                      preferences: preferences,
                      onLogout: _confirmLogout,
                      onThemeChanged: _changeThemeWithReveal,
                    ),
                    _Workspace.technician => TechnicianShell(
                      operationsRepository: operationsRepository,
                      technicianRepository: technicianRepository,
                      onLogout: _confirmLogout,
                    ),
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final dialogContext = _navigatorKey.currentContext;
    if (dialogContext == null) return;
    await showAppAsyncConfirmationDialog(
      dialogContext,
      title: dialogContext.appText('Log out?'),
      message: dialogContext.appText(
        'You will need to sign in again to continue using the app.',
      ),
      confirmLabel: AppLocalizations.of(dialogContext)!.logout,
      workingLabel: dialogContext.appText('Logging out...'),
      danger: true,
      onConfirm: _logout,
    );
  }

  Future<void> _logout() async {
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    setState(() => _workspace = _Workspace.login);
    operationsRepository.setMechanizationAccessToken(null);
    operatorRepository.setMechanizationAccessToken(null);
    await authRepository.signOut();
    if (!mounted) return;
    setState(() => _workspace = _Workspace.login);
  }

  Future<void> _changeThemeWithReveal(BuildContext origin, bool enabled) async {
    await showAppThemeReveal(
      origin,
      color: enabled ? AppColors.darkBackground : AppColors.pageBackground,
      onCovered: () => preferences.setDarkMode(enabled),
    );
  }

  Future<void> _handleSessionExpired(String token) async {
    if (!mounted ||
        _sessionExpiryInProgress ||
        authRepository.currentSession.accessToken != token) {
      return;
    }
    _sessionExpiryInProgress = true;
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    setState(() => _workspace = _Workspace.login);
    operationsRepository.setMechanizationAccessToken(null);
    operatorRepository.setMechanizationAccessToken(null);
    await authRepository.signOut();
    if (!mounted) return;
    setState(() => _workspace = _Workspace.login);
    _sessionExpiryInProgress = false;
    final appContext = _navigatorKey.currentContext;
    final expiredMessage = appContext?.appText(
      'Your session expired. Please sign in again.',
    );
    _messengerKey.currentState
      ?..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            expiredMessage ?? 'Your session expired. Please sign in again.',
          ),
        ),
      );
  }

  void _openOperations() {
    operationsRepository.setMechanizationAccessToken(
      authRepository.currentSession.accessToken,
      permissions: authRepository.currentSession.permissions,
    );
    setState(() => _workspace = _Workspace.operations);
  }

  void _openOperator() {
    operatorRepository.setMechanizationAccessToken(
      authRepository.currentSession.accessToken,
      permissions: authRepository.currentSession.permissions,
    );
    setState(() => _workspace = _Workspace.operator);
  }

  void _openTechnician() {
    operationsRepository.setMechanizationAccessToken(
      authRepository.currentSession.accessToken,
    );
    setState(() => _workspace = _Workspace.technician);
  }

  Future<void> _restoreSavedSession() async {
    AuthSession session = const AuthSession(
      status: AuthSessionStatus.signedOut,
    );
    try {
      session = await authRepository.restoreSavedSession();
    } catch (_) {
      // Keep the securely stored token after temporary network/server errors.
      // Only an explicit unauthorized response invalidates it.
    }
    if (!mounted) return;
    if (session.isSignedIn) {
      _restoringSession = false;
      _openWorkspaceForSession(session);
      return;
    }
    setState(() => _restoringSession = false);
  }

  void _openWorkspaceForSession(AuthSession session) {
    final role = session.role?.toLowerCase() ?? '';
    final permissions = session.permissions;
    final managesMechanization = permissions.any(
      (permission) =>
          permission == 'mech.requests.manage' ||
          permission == 'mech.jobs.manage' ||
          permission == 'mech.override' ||
          permission == 'mech.exceptions.manage' ||
          permission == 'mech.registry.manage',
    );

    if (managesMechanization ||
        role.contains('dispatcher') ||
        role.contains('officer') ||
        role.contains('manager') ||
        role.contains('owner')) {
      _openOperations();
      return;
    }
    if (role.contains('operator') || permissions.contains('mech.operate')) {
      _openOperator();
      return;
    }
    if (role.contains('technician')) {
      _openTechnician();
      return;
    }
    if (permissions.contains('mech.view')) {
      _openOperations();
      return;
    }
    unawaited(_rejectUnsupportedSession());
  }

  Future<void> _rejectUnsupportedSession() async {
    operationsRepository.setMechanizationAccessToken(null);
    operatorRepository.setMechanizationAccessToken(null);
    await authRepository.signOut();
    if (!mounted) return;
    setState(() => _workspace = _Workspace.login);
    final appContext = _navigatorKey.currentContext;
    _messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          appContext?.appText(
                'This account does not have access to a supported mobile workspace.',
              ) ??
              'This account does not have access to a supported mobile workspace.',
        ),
      ),
    );
  }
}
