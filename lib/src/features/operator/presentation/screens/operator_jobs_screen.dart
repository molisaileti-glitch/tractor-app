import 'package:flutter/material.dart';

import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../../domain/entities/operator_job.dart';
import '../widgets/operator_widgets.dart';
import 'operator_job_detail_screen.dart';
import 'operator_schedule_screen.dart';

class OperatorJobsScreen extends StatelessWidget {
  const OperatorJobsScreen({super.key, required this.repository});

  final OperatorLocalRepository repository;

  @override
  Widget build(BuildContext context) {
    final job = repository.todayJob;
    final displayName = repository.operatorName?.split(' ').first ?? 'John';
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Good morning, $displayName',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none),
                  ),
                ],
              ),
              if (repository.isSyncingMechanization) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(minHeight: 3),
              ] else if (repository.mechanizationSyncError != null) ...[
                const SizedBox(height: 12),
                _SyncNotice(
                  message: repository.mechanizationSyncError!,
                  onRetry: repository.refreshMechanizationData,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  _MetricTile(
                    value: '${repository.jobs.length}',
                    label: 'Assigned',
                    icon: Icons.assignment_outlined,
                  ),
                  const SizedBox(width: 10),
                  _MetricTile(
                    value: '${repository.history.length}',
                    label: 'Done',
                    icon: Icons.task_alt,
                  ),
                  const SizedBox(width: 10),
                  const _MetricTile(
                    value: '1',
                    label: 'Today',
                    icon: Icons.today_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Text(
                    "TODAY'S JOB",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            OperatorScheduleScreen(repository: repository),
                      ),
                    ),
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: const Text('View Schedule'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _TodayJobCard(
                job: job,
                onView: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OperatorJobDetailScreen(
                      repository: repository,
                      jobId: job.id,
                    ),
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

class _SyncNotice extends StatelessWidget {
  const _SyncNotice({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return OperatorCard(
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            tooltip: 'Retry',
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OperatorCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _TodayJobCard extends StatelessWidget {
  const _TodayJobCard({required this.job, required this.onView});

  final OperatorJob job;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OperatorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.secondary.withValues(
                  alpha: 0.16,
                ),
                child: const Icon(Icons.agriculture),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  job.serviceType.label.toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              OperatorStatusPill(status: job.status),
            ],
          ),
          const SizedBox(height: 18),
          _Line(label: 'Farmer', value: job.farmerName),
          _Line(label: 'Plot', value: job.plot.name),
          _Line(label: 'Scheduled', value: formatTime(job.scheduledAt)),
          _Line(label: 'Tractor', value: job.tractorLabel ?? job.tractorId),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onView,
            icon: const Icon(Icons.map_outlined),
            label: const Text('Open Job Map'),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: TextStyle(color: Colors.black.withValues(alpha: 0.62)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
