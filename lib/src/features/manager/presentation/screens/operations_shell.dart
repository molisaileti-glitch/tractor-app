import 'package:flutter/material.dart';

import '../../data/repositories/union_operations_repository.dart';
import 'operations_dashboard_view.dart';
import 'operations_directory_views.dart';
import 'operations_jobs_view.dart';
import 'operations_requests_view.dart';
import 'operations_schedule_view.dart';

enum OperationsSection {
  dashboard('Dashboard', Icons.dashboard_outlined),
  requests('Service Requests', Icons.fact_check_outlined),
  schedule('Schedule', Icons.calendar_month_outlined),
  jobs('Jobs', Icons.route_outlined),
  tractors('Tractors', Icons.agriculture_outlined),
  operators('Operators', Icons.engineering_outlined),
  farmers('Farmers', Icons.groups_outlined),
  maintenance('Maintenance', Icons.build_outlined),
  reports('Reports', Icons.bar_chart_outlined);

  const OperationsSection(this.label, this.icon);
  final String label;
  final IconData icon;
}

class OperationsShell extends StatefulWidget {
  const OperationsShell({
    super.key,
    required this.repository,
    required this.onSwitchWorkspace,
  });

  final UnionOperationsRepository repository;
  final VoidCallback onSwitchWorkspace;

  @override
  State<OperationsShell> createState() => _OperationsShellState();
}

class _OperationsShellState extends State<OperationsShell> {
  OperationsSection _section = OperationsSection.dashboard;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.repository,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 880;
            return Scaffold(
              appBar: AppBar(
                title: const Text('Union Operations'),
                actions: [
                  IconButton(
                    tooltip: 'Notifications',
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Center(child: Text('Manager: Asha')),
                  ),
                ],
              ),
              drawer: compact ? _OperationsDrawer(child: _navList()) : null,
              body: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!compact)
                    SizedBox(
                      width: 230,
                      child: Material(
                        color: Colors.white,
                        child: SafeArea(
                          top: false,
                          child: Column(
                            children: [
                              Expanded(child: _navList()),
                              _SwitchWorkspaceButton(
                                onPressed: widget.onSwitchWorkspace,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1180),
                          child: _currentView(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: compact
                  ? SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                        child: OutlinedButton.icon(
                          onPressed: widget.onSwitchWorkspace,
                          icon: const Icon(Icons.switch_account_outlined),
                          label: const Text('Switch Workspace'),
                        ),
                      ),
                    )
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _navList() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      children: [
        for (final section in OperationsSection.values)
          ListTile(
            selected: _section == section,
            leading: Icon(section.icon),
            title: Text(section.label),
            onTap: () {
              setState(() => _section = section);
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
        onOpenRequests: () =>
            setState(() => _section = OperationsSection.requests),
        onOpenJobs: () => setState(() => _section = OperationsSection.jobs),
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
      OperationsSection.tractors => TractorsView(repository: widget.repository),
      OperationsSection.operators => OperatorsView(
        repository: widget.repository,
      ),
      OperationsSection.farmers => FarmersView(repository: widget.repository),
      OperationsSection.maintenance => MaintenanceView(
        repository: widget.repository,
      ),
      OperationsSection.reports => ReportsView(repository: widget.repository),
    };
  }
}

class _OperationsDrawer extends StatelessWidget {
  const _OperationsDrawer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const ListTile(
              title: Text('Union Operations'),
              subtitle: Text('Manager: Asha'),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _SwitchWorkspaceButton extends StatelessWidget {
  const _SwitchWorkspaceButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.switch_account_outlined),
        label: const Text('Switch Workspace'),
      ),
    );
  }
}
