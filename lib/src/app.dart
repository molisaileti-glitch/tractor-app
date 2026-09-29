import 'package:flutter/material.dart';
import 'core/presentation/app_welcome_screen.dart';
import 'core/presentation/workspace_selector_screen.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_local_repository.dart';
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
  selector,
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
          onBack: () => setState(() => _workspace = _Workspace.selector),
          onOpenFarmer: () => setState(() => _workspace = _Workspace.farmer),
          onOpenOperations: () =>
              setState(() => _workspace = _Workspace.operations),
          onOpenOperator: () =>
              setState(() => _workspace = _Workspace.operator),
          onOpenTechnician: () =>
              setState(() => _workspace = _Workspace.technician),
          onCreateFarmerAccount: () =>
              setState(() => _workspace = _Workspace.registerFarmer),
        ),
        _Workspace.registerFarmer => FarmerRegistrationScreen(
          repository: authRepository,
          onBack: () => setState(() => _workspace = _Workspace.login),
          onRegistered: () => setState(() => _workspace = _Workspace.farmer),
        ),
        _Workspace.selector => WorkspaceSelectorScreen(
          onOpenFarmer: () => setState(() => _workspace = _Workspace.farmer),
          onOpenOperations: () =>
              setState(() => _workspace = _Workspace.operations),
          onOpenOperator: () =>
              setState(() => _workspace = _Workspace.operator),
          onOpenTechnician: () =>
              setState(() => _workspace = _Workspace.technician),
        ),
        _Workspace.farmer => FarmerShell(
          repository: farmerRepository,
          onSwitchWorkspace: () =>
              setState(() => _workspace = _Workspace.selector),
        ),
        _Workspace.operations => OperationsShell(
          repository: operationsRepository,
          onSwitchWorkspace: () =>
              setState(() => _workspace = _Workspace.selector),
        ),
        _Workspace.operator => OperatorShell(
          repository: operatorRepository,
          onSwitchWorkspace: () =>
              setState(() => _workspace = _Workspace.selector),
        ),
        _Workspace.technician => TechnicianShell(
          operationsRepository: operationsRepository,
          technicianRepository: technicianRepository,
          onSwitchWorkspace: () =>
              setState(() => _workspace = _Workspace.selector),
        ),
      },
    );
  }
}
