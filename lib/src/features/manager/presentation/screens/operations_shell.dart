import 'package:flutter/material.dart';

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
  reports('Reports', Icons.bar_chart_outlined);

  const OperationsSection(this.label, this.icon);
  final String label;
  final IconData icon;
}

class OperationsShell extends StatefulWidget {
  const OperationsShell({
    super.key,
    required this.repository,
    required this.onLogout,
  });

  final UnionOperationsRepository repository;
  final VoidCallback onLogout;

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
                    tooltip: 'Refresh',
                    onPressed: widget.repository.isSyncingMechanization
                        ? null
                        : widget.repository.refreshMechanizationData,
                    icon: const Icon(Icons.sync),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Text(
                        widget.repository.mechanizationUserName ??
                            'Union staff',
                      ),
                    ),
                  ),
                ],
              ),
              drawer: compact
                  ? _OperationsDrawer(
                      subtitle:
                          widget.repository.mechanizationUserName ??
                          'Union staff',
                      child: _navList(),
                    )
                  : null,
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
                              _LogoutButton(onPressed: widget.onLogout),
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
                          onPressed: widget.onLogout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
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
        onOpenOversight: () =>
            setState(() => _section = OperationsSection.oversight),
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
    };
  }
}

class _OperationsDrawer extends StatelessWidget {
  const _OperationsDrawer({required this.subtitle, required this.child});

  final String subtitle;
  final Widget child;

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
