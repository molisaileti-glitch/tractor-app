import 'dart:async';

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
    this.onThemeChanged,
  });

  final UnionOperationsRepository repository;
  final AppPreferencesController preferences;
  final VoidCallback onLogout;
  final Future<void> Function(BuildContext origin, bool enabled)?
  onThemeChanged;

  @override
  State<OperationsShell> createState() => _OperationsShellState();
}

class _OperationsShellState extends State<OperationsShell>
    with WidgetsBindingObserver {
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

  Timer? _refreshTimer;
  bool _foreground = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted &&
          _foreground &&
          (ModalRoute.of(context)?.isCurrent ?? false)) {
        unawaited(widget.repository.refreshMechanizationData());
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground && (ModalRoute.of(context)?.isCurrent ?? false)) {
      unawaited(widget.repository.refreshMechanizationData());
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: widget.repository,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 880;
            return Scaffold(
              appBar: AppBar(
                title: Text(strings.unionOperations),
                actions: [
                  IconButton(
                    tooltip:
                        '${strings.refresh} ${_sectionLabel(_section, strings).toLowerCase()}',
                    onPressed: _isRefreshingCurrentSection
                        ? null
                        : _refreshCurrentSection,
                    icon: _isRefreshingCurrentSection
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              drawer: compact
                  ? _OperationsDrawer(
                      subtitle:
                          widget.repository.mechanizationUserName ??
                          'Union staff',
                      onLogout: widget.onLogout,
                      child: _navList(sections: _secondarySections),
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
                    child: AnimatedSwitcher(
                      duration: AppMotion.duration(
                        context,
                        const Duration(milliseconds: 450),
                      ),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: widget.repository.isInitialMechanizationLoad
                          ? const AppScreenSkeleton(key: ValueKey('loading'))
                          : RefreshIndicator(
                              key: ValueKey(_section),
                              onRefresh: _refreshCurrentSection,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  16,
                                  20,
                                  28,
                                ),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 1180,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        if (widget
                                                .repository
                                                .mechanizationSyncError !=
                                            null) ...[
                                          AppMessage(
                                            message: widget
                                                .repository
                                                .mechanizationSyncError!,
                                            type: AppMessageType.warning,
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                        _currentView(),
                                      ],
                                    ),
                                  ),
                                ),
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
                      destinations: [
                        NavigationDestination(
                          icon: const Icon(Icons.dashboard_outlined),
                          selectedIcon: const Icon(Icons.dashboard),
                          label: strings.overview,
                        ),
                        NavigationDestination(
                          icon: const Icon(Icons.fact_check_outlined),
                          selectedIcon: const Icon(Icons.fact_check),
                          label: strings.requests,
                        ),
                        NavigationDestination(
                          icon: const Icon(Icons.calendar_month_outlined),
                          selectedIcon: const Icon(Icons.calendar_month),
                          label: strings.schedule,
                        ),
                        NavigationDestination(
                          icon: const Icon(Icons.route_outlined),
                          selectedIcon: const Icon(Icons.route),
                          label: strings.jobs,
                        ),
                        NavigationDestination(
                          icon: const Icon(Icons.rule_folder_outlined),
                          selectedIcon: const Icon(Icons.rule_folder),
                          label: strings.oversight,
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
            title: Text(_sectionLabel(section, AppLocalizations.of(context)!)),
            onTap: () {
              _selectSection(section);
              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            },
          ),
      ],
    );
  }

  String _sectionLabel(OperationsSection section, AppLocalizations strings) {
    return switch (section) {
      OperationsSection.dashboard => strings.dashboard,
      OperationsSection.requests => strings.serviceRequests,
      OperationsSection.schedule => strings.schedule,
      OperationsSection.jobs => strings.jobs,
      OperationsSection.oversight => strings.oversight,
      OperationsSection.tractors => strings.tractors,
      OperationsSection.operators => strings.operators,
      OperationsSection.farmers => strings.farmers,
      OperationsSection.maintenance => strings.maintenance,
      OperationsSection.reports => strings.reports,
      OperationsSection.settings => strings.settings,
    };
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
        onThemeChanged: widget.onThemeChanged,
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

  bool get _isRefreshingCurrentSection {
    if (widget.repository.isSyncingMechanization) return true;
    return switch (_section) {
      OperationsSection.tractors => widget.repository.isRefreshingTractors,
      OperationsSection.operators => widget.repository.isRefreshingOperators,
      OperationsSection.farmers => widget.repository.isRefreshingFarmers,
      _ => widget.repository.isSyncingMechanization,
    };
  }

  Future<void> _refreshCurrentSection() async {
    final label = _sectionLabel(
      _section,
      AppLocalizations.of(context)!,
    ).toLowerCase();
    switch (_section) {
      case OperationsSection.tractors:
        await widget.repository.refreshTractors();
      case OperationsSection.operators:
        await widget.repository.refreshOperators();
      case OperationsSection.farmers:
        await widget.repository.refreshFarmers();
      default:
        await widget.repository.refreshMechanizationData();
    }
    if (!mounted) return;
    final error = widget.repository.mechanizationSyncError;
    showAppSnackBar(
      context,
      message: error ?? '${_capitalize(label)} refreshed successfully.',
      type: error == null ? AppSnackType.success : AppSnackType.error,
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
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
              title: Text(AppLocalizations.of(context)!.unionOperations),
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
        label: Text(AppLocalizations.of(context)!.logout),
      ),
    );
  }
}
