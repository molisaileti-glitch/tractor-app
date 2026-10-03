import 'package:flutter/material.dart';
import 'core/presentation/app_welcome_screen.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_local_repository.dart';
import 'features/auth/domain/entities/auth_session.dart';
import 'features/auth/presentation/screens/farmer_registration_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/farmer/data/repositories/farmer_local_repository.dart';
import 'features/farmer/presentation/screens/farmer_shell.dart';
import 'features/manager/data/repositories/union_operations_repository.dart';
import 'features/manager/presentation/screens/operations_shell.dart';
import 'features/operator/data/repositories/operator_local_repository.dart';
import 'features/operator/presentation/screens/operator_shell.dart';
import 'features/technician/data/repositories/technician_local_repository.dart';
import 'features/technician/presentation/screens/technician_shell.dart';

enum _Workspace {
  welcome,
  login,
  registerFarmer,
  farmer,
  operations,
  operator,
  technician,
}

class TractorApp extends StatefulWidget {
  const TractorApp({super.key});

  @override
  State<TractorApp> createState() => _TractorAppState();
}

class _TractorAppState extends State<TractorApp> {
  final AuthLocalRepository authRepository = AuthLocalRepository();
  final FarmerLocalRepository farmerRepository = FarmerLocalRepository.seeded();
  final UnionOperationsRepository operationsRepository =
      UnionOperationsRepository.seeded();
  final OperatorLocalRepository operatorRepository =
      OperatorLocalRepository.seeded();
  final TechnicianLocalRepository technicianRepository =
      TechnicianLocalRepository.seeded();
  _Workspace _workspace = _Workspace.welcome;

  @override
  void initState() {
    super.initState();
    _restoreSavedSession();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shamba Bora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: switch (_workspace) {
        _Workspace.welcome => AppWelcomeScreen(
          onContinue: () => setState(() => _workspace = _Workspace.login),
        ),
        _Workspace.login => LoginScreen(
          repository: authRepository,
          onBack: () => setState(() => _workspace = _Workspace.welcome),
          onOpenFarmer: () => setState(() => _workspace = _Workspace.farmer),
          onOpenOperations: _openOperations,
          onOpenOperator: _openOperator,
          onOpenTechnician: _openTechnician,
          onCreateFarmerAccount: () =>
              setState(() => _workspace = _Workspace.registerFarmer),
        ),
        _Workspace.registerFarmer => FarmerRegistrationScreen(
          repository: authRepository,
          onBack: () => setState(() => _workspace = _Workspace.login),
          onRegistered: () => setState(() => _workspace = _Workspace.farmer),
        ),
        _Workspace.farmer => FarmerShell(
          repository: farmerRepository,
          onLogout: _logout,
        ),
        _Workspace.operations => OperationsShell(
          repository: operationsRepository,
          onLogout: _logout,
        ),
        _Workspace.operator => OperatorShell(
          repository: operatorRepository,
          onLogout: _logout,
        ),
        _Workspace.technician => TechnicianShell(
          operationsRepository: operationsRepository,
          technicianRepository: technicianRepository,
          onLogout: _logout,
        ),
      },
    );
  }

  void _logout() {
    operationsRepository.setMechanizationAccessToken(null);
    operatorRepository.setMechanizationAccessToken(null);
    authRepository.signOut();
    setState(() => _workspace = _Workspace.login);
  }

  void _openOperations() {
    operationsRepository.setMechanizationAccessToken(
      authRepository.currentSession.accessToken,
    );
    setState(() => _workspace = _Workspace.operations);
  }

  void _openOperator() {
    operatorRepository.setMechanizationAccessToken(
      authRepository.currentSession.accessToken,
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
    final session = await authRepository.restoreSavedSession();
    if (!mounted || !session.isSignedIn) return;
    _openWorkspaceForSession(session);
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
    if (role.contains('farmer')) {
      setState(() => _workspace = _Workspace.farmer);
      return;
    }
    _openOperations();
  }
}
