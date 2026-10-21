import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import '../../../../components/components.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/application/app_preferences_controller.dart';
import '../../data/repositories/operator_local_repository.dart';
import 'operator_history_screen.dart';
import 'operator_jobs_screen.dart';
import 'operator_profile_screen.dart';
import 'operator_schedule_screen.dart';

class OperatorShell extends StatefulWidget {
  const OperatorShell({
    super.key,
    required this.repository,
    required this.preferences,
    required this.onLogout,
    this.onThemeChanged,
  });

  final OperatorLocalRepository repository;
  final AppPreferencesController preferences;
  final VoidCallback onLogout;
  final Future<void> Function(BuildContext origin, bool enabled)?
  onThemeChanged;

  @override
  State<OperatorShell> createState() => _OperatorShellState();
}

class _OperatorShellState extends State<OperatorShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final screens = [
      OperatorJobsScreen(
        repository: widget.repository,
        onOpenSchedule: () => setState(() => _selectedIndex = 1),
        onRefresh: _refreshData,
      ),
      OperatorScheduleScreen(repository: widget.repository),
      OperatorHistoryScreen(repository: widget.repository),
      OperatorProfileScreen(
        repository: widget.repository,
        preferences: widget.preferences,
        onLogout: widget.onLogout,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return AnimatedBuilder(
      animation: widget.repository,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_titleForIndex(_selectedIndex, strings)),
            actions: [
              IconButton(
                tooltip: strings.refresh,
                onPressed: widget.repository.isSyncingMechanization
                    ? null
                    : _refreshData,
                icon: widget.repository.isSyncingMechanization
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: PageTransitionSwitcher(
              duration: AppMotion.duration(
                context,
                const Duration(milliseconds: 600),
              ),
              transitionBuilder:
                  (child, primaryAnimation, secondaryAnimation) =>
                      FadeThroughTransition(
                        animation: primaryAnimation,
                        secondaryAnimation: secondaryAnimation,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        child: child,
                      ),
              child: widget.repository.isSyncingMechanization
                  ? const AppScreenSkeleton(key: ValueKey('loading'))
                  : KeyedSubtree(
                      key: ValueKey(_selectedIndex),
                      child: screens[_selectedIndex],
                    ),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard),
                label: strings.dashboard,
              ),
              NavigationDestination(
                icon: const Icon(Icons.calendar_month_outlined),
                selectedIcon: const Icon(Icons.calendar_month),
                label: strings.schedule,
              ),
              NavigationDestination(
                icon: const Icon(Icons.history_outlined),
                selectedIcon: const Icon(Icons.history),
                label: strings.history,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: strings.profile,
              ),
            ],
          ),
        );
      },
    );
  }

  String _titleForIndex(int index, AppLocalizations strings) {
    return switch (index) {
      0 => strings.operatorDashboard,
      1 => strings.schedule,
      2 => strings.jobHistory,
      _ => strings.profile,
    };
  }

  Future<void> _refreshData() async {
    await widget.repository.refreshMechanizationData();
    if (!mounted) return;
    final error = widget.repository.mechanizationSyncError;
    showAppSnackBar(
      context,
      message: error ?? AppLocalizations.of(context)!.assignmentsRefreshed,
      type: error == null ? AppSnackType.success : AppSnackType.error,
    );
  }
}
