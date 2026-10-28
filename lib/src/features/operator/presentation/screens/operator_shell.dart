import 'dart:async';

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
  OperatorDataScreen get _screen => OperatorDataScreen.values[_selectedIndex];

  void _selectScreen(int index) {
    setState(() => _selectedIndex = index);
    unawaited(widget.repository.ensureScreenLoaded(_screen));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: widget.repository,
      builder: (context, _) {
        // Create the current screens on each repository notification so the
        // dashboard, history and profile receive refreshed job data.
        final screens = [
          OperatorJobsScreen(
            repository: widget.repository,
            onOpenSchedule: () => _selectScreen(1),
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

        return Scaffold(
          appBar: AppBar(
            title: Text(_titleForIndex(_selectedIndex, strings)),
            actions: [
              IconButton(
                tooltip: strings.refresh,
                onPressed: widget.repository.isRefreshingScreen(_screen)
                    ? null
                    : _refreshData,
                icon: widget.repository.isRefreshingScreen(_screen)
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
              child: widget.repository.isInitialScreenLoad(_screen)
                  ? _initialLoading()
                  : KeyedSubtree(
                      key: ValueKey(_selectedIndex),
                      child: screens[_selectedIndex],
                    ),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _selectScreen,
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

  Widget _initialLoading() {
    if (_screen == OperatorDataScreen.dashboard) {
      return const AppScreenSkeleton(key: ValueKey('loading-dashboard'));
    }
    final layout = switch (_screen) {
      OperatorDataScreen.dashboard => AppSectionSkeletonLayout.list,
      OperatorDataScreen.schedule => AppSectionSkeletonLayout.calendar,
      OperatorDataScreen.history => AppSectionSkeletonLayout.list,
      OperatorDataScreen.profile => AppSectionSkeletonLayout.profile,
    };
    return AppSectionSkeleton(
      key: ValueKey('loading-${_screen.name}'),
      layout: layout,
    );
  }

  Future<void> _refreshData() async {
    final screen = _screen;
    await widget.repository.refreshScreen(screen);
    if (!mounted) return;
    if (screen != _screen) return;
    final error = widget.repository.screenError(screen);
    showAppSnackBar(
      context,
      message: error ?? AppLocalizations.of(context)!.assignmentsRefreshed,
      type: error == null ? AppSnackType.success : AppSnackType.error,
    );
  }
}
