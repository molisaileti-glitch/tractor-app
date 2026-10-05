import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
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
      OperatorProfileScreen(repository: widget.repository),
    ];

    return AnimatedBuilder(
      animation: widget.repository,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_titleForIndex(_selectedIndex)),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: widget.repository.isSyncingMechanization
                    ? null
                    : widget.repository.refreshMechanizationData,
                icon: const Icon(Icons.sync),
              ),
            ],
          ),
          drawer: _OperatorDrawer(
            repository: widget.repository,
            selectedIndex: _selectedIndex,
            onSelect: (index) {
              setState(() => _selectedIndex = index);
              Navigator.of(context).pop();
            },
            onLogout: widget.onLogout,
          ),
          body: SafeArea(top: false, child: screens[_selectedIndex]),
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

  String _titleForIndex(int index) {
    return switch (index) {
      0 => 'Operator Dashboard',
      1 => 'Fleet Map',
      2 => 'Job History',
      _ => 'Profile',
    };
  }
}

class _OperatorDrawer extends StatelessWidget {
  const _OperatorDrawer({
    required this.repository,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
  });

  final OperatorLocalRepository repository;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final name = repository.operatorName ?? 'Operator';
    final role = repository.operatorRole ?? 'Mechanization operator';
    final email = repository.operatorEmail;
    final activeJobs = repository.jobs.where((job) => !job.isComplete).length;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.fieldGreen.withValues(
                      alpha: 0.14,
                    ),
                    child: const Icon(
                      Icons.agriculture,
                      color: AppColors.fieldGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          email == null || email.isEmpty ? role : '$role\n$email',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.mutedText),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$activeJobs active assignment${activeJobs == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.fieldGreen),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerDestination(
                    index: 0,
                    selectedIndex: selectedIndex,
                    icon: Icons.agriculture_outlined,
                    selectedIcon: Icons.agriculture,
                    label: 'Jobs',
                    onSelect: onSelect,
                  ),
                  _DrawerDestination(
                    index: 1,
                    selectedIndex: selectedIndex,
                    icon: Icons.location_on_outlined,
                    selectedIcon: Icons.location_on,
                    label: 'Map',
                    onSelect: onSelect,
                  ),
                  _DrawerDestination(
                    index: 2,
                    selectedIndex: selectedIndex,
                    icon: Icons.history_outlined,
                    selectedIcon: Icons.history,
                    label: 'History',
                    onSelect: onSelect,
                  ),
                  _DrawerDestination(
                    index: 3,
                    selectedIndex: selectedIndex,
                    icon: Icons.person_outline,
                    selectedIcon: Icons.person,
                    label: 'Profile',
                    onSelect: onSelect,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerDestination extends StatelessWidget {
  const _DrawerDestination({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onSelect,
  });

  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final selected = index == selectedIndex;
    return ListTile(
      selected: selected,
      leading: Icon(selected ? selectedIcon : icon),
      title: Text(label),
      onTap: () => onSelect(index),
    );
  }
}
