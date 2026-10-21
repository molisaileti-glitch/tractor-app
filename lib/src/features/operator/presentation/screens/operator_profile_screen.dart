import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/application/app_preferences_controller.dart';
import '../../../../shared/presentation/screens/app_settings_screen.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../widgets/operator_widgets.dart';

class OperatorProfileScreen extends StatelessWidget {
  const OperatorProfileScreen({
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
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final name = repository.operatorName ?? strings.operator;
    final role = repository.operatorRole ?? strings.operator;
    final activeJobs = repository.jobs.where((job) => !job.isComplete).length;
    final completedJobs = repository.history.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.profile,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 18),
              AppSettingsScreen(
                preferences: preferences,
                name: name,
                role: role,
                email: repository.operatorEmail,
                showTitle: false,
                onThemeChanged: onThemeChanged,
              ),
              const SizedBox(height: 16),
              OperatorCard(
                child: Column(
                  children: [
                    _ProfileLine(
                      icon: Icons.assignment_outlined,
                      title: strings.assignedJobs,
                      subtitle: strings.activeAndCompleted(
                        activeJobs,
                        completedJobs,
                      ),
                    ),
                    const Divider(height: 28),
                    _ProfileLine(
                      icon: Icons.cloud_done_outlined,
                      title: strings.dataStatus,
                      subtitle: repository.isSyncingMechanization
                          ? strings.updatingInformation
                          : repository.mechanizationSyncError ??
                                strings.informationUpToDate,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(strings.logout),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileLine extends StatelessWidget {
  const _ProfileLine({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(subtitle),
            ],
          ),
        ),
      ],
    );
  }
}
