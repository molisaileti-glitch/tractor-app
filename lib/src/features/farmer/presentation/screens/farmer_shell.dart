import 'package:flutter/material.dart';

import '../../data/repositories/farmer_local_repository.dart';
import 'farmer_home_screen.dart';
import 'plots_screen.dart';
import 'profile_screen.dart';
import 'requests_screen.dart';

class FarmerShell extends StatefulWidget {
  const FarmerShell({
    super.key,
    required this.repository,
    required this.onSwitchWorkspace,
  });

  final FarmerLocalRepository repository;
  final VoidCallback onSwitchWorkspace;

  @override
  State<FarmerShell> createState() => _FarmerShellState();
}

class _FarmerShellState extends State<FarmerShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      FarmerHomeScreen(repository: widget.repository, onOpenPlots: _openPlots),
      RequestsScreen(repository: widget.repository),
      PlotsScreen(repository: widget.repository),
      ProfileScreen(
        repository: widget.repository,
        onSwitchWorkspace: widget.onSwitchWorkspace,
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
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.agriculture_outlined),
                selectedIcon: Icon(Icons.agriculture),
                label: 'Requests',
              ),
              NavigationDestination(
                icon: Icon(Icons.location_on_outlined),
                selectedIcon: Icon(Icons.location_on),
                label: 'Plots',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Me',
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPlots() {
    setState(() => _selectedIndex = 2);
  }
}
