import 'package:flutter/material.dart';

import '../../data/repositories/operator_local_repository.dart';
import '../widgets/operator_widgets.dart';

class OperatorProfileScreen extends StatelessWidget {
  const OperatorProfileScreen({
    super.key,
    required this.repository,
  });

  final OperatorLocalRepository repository;

  @override
  Widget build(BuildContext context) {
    final name = repository.operatorName ?? 'Operator';
    final role = repository.operatorRole ?? 'Mechanization operator';
    final email = repository.operatorEmail;
    final activeJobs = repository.jobs.where((job) => !job.isComplete).length;
    final completedJobs = repository.history.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 14),
              OperatorCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      child: const Icon(Icons.person),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(email == null || email.isEmpty
                              ? role
                              : '$role - $email'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              OperatorCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileLine(
                      icon: Icons.assignment_outlined,
                      title: 'Assigned jobs',
                      subtitle: '$activeJobs active, $completedJobs completed',
                    ),
                    const Divider(height: 28),
                    _ProfileLine(
                      icon: Icons.sync_outlined,
                      title: 'Backend sync',
                      subtitle: repository.isSyncingMechanization
                          ? 'Refreshing operator data...'
                          : repository.mechanizationSyncError ??
                                'Using authenticated mechanization API data.',
                    ),
                  ],
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
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(subtitle),
            ],
          ),
        ),
      ],
    );
  }
}
