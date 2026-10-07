import 'package:flutter/material.dart';

import '../../../../core/presentation/components/components.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/operator_local_repository.dart';
import 'operator_history_screen.dart';
import 'operator_jobs_screen.dart';
import 'operator_profile_screen.dart';
import 'operator_schedule_screen.dart';

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
      OperatorJobsScreen(
        repository: widget.repository,
        onOpenSchedule: () => setState(() => _selectedIndex = 1),
      ),
      OperatorScheduleScreen(repository: widget.repository),
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
            onLogout: widget.onLogout,
          ),
          body: SafeArea(
            top: false,
            child: widget.repository.isSyncingMechanization
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
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'Schedule',
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
      1 => 'Schedule',
      2 => 'Job History',
      _ => 'Profile',
    };
  }
}

class _OperatorDrawer extends StatelessWidget {
  const _OperatorDrawer({
    required this.repository,
    required this.onLogout,
  });

  final OperatorLocalRepository repository;
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
            const Spacer(),
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
