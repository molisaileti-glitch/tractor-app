import 'package:flutter/material.dart';

import '../../../../core/presentation/components/components.dart';
import '../../../manager/data/repositories/union_operations_repository.dart';
import '../../data/repositories/technician_local_repository.dart';
import 'technician_home_screen.dart';
import 'technician_maintenance_screen.dart';
import 'technician_parts_screen.dart';
import 'technician_tractors_screen.dart';

class TechnicianShell extends StatefulWidget {
  const TechnicianShell({
    super.key,
    required this.operationsRepository,
    required this.technicianRepository,
    required this.onLogout,
  });

  final UnionOperationsRepository operationsRepository;
  final TechnicianLocalRepository technicianRepository;
  final VoidCallback onLogout;

  @override
  State<TechnicianShell> createState() => _TechnicianShellState();
}

class _TechnicianShellState extends State<TechnicianShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      TechnicianHomeScreen(
        operationsRepository: widget.operationsRepository,
        technicianRepository: widget.technicianRepository,
      ),
      TechnicianTractorsScreen(
        operationsRepository: widget.operationsRepository,
        technicianRepository: widget.technicianRepository,
      ),
      TechnicianMaintenanceScreen(
        operationsRepository: widget.operationsRepository,
        technicianRepository: widget.technicianRepository,
      ),
      TechnicianPartsScreen(
        technicianRepository: widget.technicianRepository,
        onLogout: widget.onLogout,
      ),
    ];

    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.operationsRepository,
        widget.technicianRepository,
      ]),
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: widget.operationsRepository.isSyncingMechanization
                ? const AppScreenSkeleton()
                : screens[_selectedIndex],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_repair_service_outlined),
                selectedIcon: Icon(Icons.home_repair_service),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.agriculture_outlined),
                selectedIcon: Icon(Icons.agriculture),
                label: 'Tractors',
              ),
              NavigationDestination(
                icon: Icon(Icons.build_outlined),
                selectedIcon: Icon(Icons.build),
                label: 'Maintenance',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: 'Parts',
              ),
            ],
          ),
        );
      },
    );
  }
}
