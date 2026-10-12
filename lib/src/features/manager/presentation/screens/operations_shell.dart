import 'package:flutter/material.dart';

import '../../../../components/components.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/application/app_preferences_controller.dart';
import '../../../../shared/presentation/screens/app_settings_screen.dart';
import '../../data/repositories/union_operations_repository.dart';
import 'operations_dashboard_view.dart';
import 'operations_directory_views.dart';
import 'operations_jobs_view.dart';
import 'operations_oversight_view.dart';
import 'operations_requests_view.dart';
import 'operations_schedule_view.dart';

enum OperationsSection {
  dashboard('Dashboard', Icons.dashboard_outlined),
  requests('Service Requests', Icons.fact_check_outlined),
  schedule('Schedule', Icons.calendar_month_outlined),
  jobs('Jobs', Icons.route_outlined),
  oversight('Oversight', Icons.rule_folder_outlined),
  tractors('Tractors', Icons.agriculture_outlined),
  operators('Operators', Icons.engineering_outlined),
  farmers('Farmers', Icons.groups_outlined),
  maintenance('Maintenance', Icons.build_outlined),
  reports('Reports', Icons.bar_chart_outlined),
  settings('Settings', Icons.settings_outlined);

  const OperationsSection(this.label, this.icon);
  final String label;
  final IconData icon;
}

class OperationsShell extends StatefulWidget {
  const OperationsShell({
    super.key,
    required this.repository,
    required this.preferences,
    required this.onLogout,
  });

  final UnionOperationsRepository repository;
  final AppPreferencesController preferences;
  final VoidCallback onLogout;

  @override
  State<OperationsShell> createState() => _OperationsShellState();
}

class _OperationsShellState extends State<OperationsShell> {
  static const _primarySections = <OperationsSection>[
    OperationsSection.dashboard,
    OperationsSection.requests,
    OperationsSection.schedule,
    OperationsSection.jobs,
    OperationsSection.oversight,
  ];

  static const _secondarySections = <OperationsSection>[
    OperationsSection.tractors,
    OperationsSection.operators,
    OperationsSection.farmers,
    OperationsSection.maintenance,
    OperationsSection.reports,
    OperationsSection.settings,
  ];

  OperationsSection _section = OperationsSection.dashboard;
  int _lastPrimaryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.repository,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 880;
            return Scaffold(
              appBar: AppBar(title: const Text('Union Operations')),
              drawer: compact
                  ? _OperationsDrawer(
                      subtitle:
                          widget.repository.mechanizationUserName ??
                          'Union staff',
                      child: _navList(sections: _secondarySections),
                      onLogout: widget.onLogout,
                    )
                  : null,
              body: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!compact)
                    SizedBox(
                      width: 230,
                      child: Material(
                        color: Theme.of(context).colorScheme.surface,
                        child: SafeArea(
                          top: false,
                          child: Column(
                            children: [
                              Expanded(
                                child: _navList(
                                  sections: OperationsSection.values,
                                ),
                              ),
                              _LogoutButton(onPressed: widget.onLogout),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: widget.repository.isSyncingMechanization
                        ? const AppScreenSkeleton()
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1180,
                                ),
                                child: _currentView(),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
              bottomNavigationBar: compact
                  ? NavigationBar(
                      selectedIndex: _lastPrimaryIndex,
                      onDestinationSelected: (index) {
                        _selectSection(_primarySections[index]);
                      },
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.dashboard_outlined),
                          selectedIcon: Icon(Icons.dashboard),
                          label: 'Overview',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.fact_check_outlined),
                          selectedIcon: Icon(Icons.fact_check),
                          label: 'Requests',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.calendar_month_outlined),
                          selectedIcon: Icon(Icons.calendar_month),
                          label: 'Schedule',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.route_outlined),
                          selectedIcon: Icon(Icons.route),
                          label: 'Jobs',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.rule_folder_outlined),
                          selectedIcon: Icon(Icons.rule_folder),
                          label: 'Oversight',
                        ),
                      ],
                    )
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _navList({required Iterable<OperationsSection> sections}) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      children: [
        for (final section in sections)
          ListTile(
            selected: _section == section,
            leading: Icon(section.icon),
            title: Text(
              section == OperationsSection.settings
                  ? AppLocalizations.of(context)!.settings
                  : section.label,
            ),
            onTap: () {
              _selectSection(section);
              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            },
          ),
      ],
    );
  }

  Widget _currentView() {
    return switch (_section) {
      OperationsSection.dashboard => OperationsDashboardView(
        repository: widget.repository,
        onOpenRequests: () => _selectSection(OperationsSection.requests),
        onOpenJobs: () => _selectSection(OperationsSection.jobs),
        onOpenOversight: () => _selectSection(OperationsSection.oversight),
      ),
      OperationsSection.requests => OperationsRequestsView(
        repository: widget.repository,
      ),
      OperationsSection.schedule => OperationsScheduleView(
        repository: widget.repository,
      ),
      OperationsSection.jobs => OperationsJobsView(
        repository: widget.repository,
      ),
      OperationsSection.oversight => OperationsOversightView(
        repository: widget.repository,
      ),
      OperationsSection.tractors => TractorsView(repository: widget.repository),
      OperationsSection.operators => OperatorsView(
        repository: widget.repository,
      ),
      OperationsSection.farmers => FarmersView(repository: widget.repository),
      OperationsSection.maintenance => MaintenanceView(
        repository: widget.repository,
      ),
      OperationsSection.reports => ReportsView(repository: widget.repository),
      OperationsSection.settings => AppSettingsScreen(
        preferences: widget.preferences,
        name: widget.repository.mechanizationUserName ?? 'Union staff',
        role: widget.repository.mechanizationUserRole ?? 'Union staff',
        email: widget.repository.mechanizationUserEmail,
      ),
    };
  }

  void _selectSection(OperationsSection section) {
    setState(() {
      _section = section;
      final primaryIndex = _primarySections.indexOf(section);
      if (primaryIndex >= 0) _lastPrimaryIndex = primaryIndex;
    });
  }
}

class _OperationsDrawer extends StatelessWidget {
  const _OperationsDrawer({
    required this.subtitle,
    required this.child,
    required this.onLogout,
  });

  final String subtitle;
  final Widget child;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: const Text('Union Operations'),
              subtitle: Text(subtitle),
            ),
            Expanded(child: child),
            const Divider(height: 1),
            _LogoutButton(onPressed: onLogout),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
      ),
    );
  }
}
