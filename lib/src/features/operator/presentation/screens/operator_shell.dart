import 'package:flutter/material.dart';

import '../../data/repositories/operator_local_repository.dart';
import 'operator_history_screen.dart';
import 'operator_jobs_screen.dart';
import 'operator_map_screen.dart';
import 'operator_profile_screen.dart';

class OperatorShell extends StatefulWidget {
  const OperatorShell({
    super.key,
    required this.repository,
    required this.onLogout,
  });

  final OperatorLocalRepository repository;
  final VoidCallback onLogout;

  @override
  State<OperatorShell> createState() => _OperatorShellState();
}

class _OperatorShellState extends State<OperatorShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      OperatorJobsScreen(repository: widget.repository),
      OperatorMapScreen(repository: widget.repository),
      OperatorHistoryScreen(repository: widget.repository),
      OperatorProfileScreen(
        repository: widget.repository,
        onLogout: widget.onLogout,
      ),
    ];

    return AnimatedBuilder(
      animation: widget.repository,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(child: screens[_selectedIndex]),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.agriculture_outlined),
                selectedIcon: Icon(Icons.agriculture),
                label: 'Jobs',
              ),
              NavigationDestination(
                icon: Icon(Icons.location_on_outlined),
                selectedIcon: Icon(Icons.location_on),
                label: 'Map',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: 'History',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
