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
    final displayName = repository.operatorName?.split(' ').first ?? 'Operator';
    final activeJobs = repository.jobs.where((job) => !job.isComplete).toList()
      ..sort(_sortJobs);
    final focusJob = activeJobs.firstOrNull;
    final totalTodayJobs = repository.jobs
        .where((job) => _sameDate(job.scheduledAt, DateTime.now()))
        .length;
    final todayJobs = repository.jobs
        .where((job) => _sameDate(job.scheduledAt, DateTime.now()))
        .where((job) => job.id != focusJob?.id)
        .toList()
      ..sort(_sortJobs);
    final otherAssignments = activeJobs
        .where((job) => job.id != focusJob?.id)
        .where((job) => !_sameDate(job.scheduledAt, DateTime.now()))
        .toList();
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
                  _MetricTile(
                    value: '$totalTodayJobs',
                    label: 'Today',
                    icon: Icons.today_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Text(
                    'FOCUS JOB',
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
              if (focusJob == null)
                const _NoAssignedJobsCard()
              else
                _OperatorJobCard(
                  job: focusJob,
                  emphasis: true,
                  onView: () => _openJob(context, focusJob),
                ),
              const SizedBox(height: 18),
              Text(
                "TODAY'S REMAINING SCHEDULE",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              if (todayJobs.isEmpty)
                const _EmptyQueueCard(message: 'No other jobs scheduled today.')
              else
                for (final job in todayJobs) ...[
                  _OperatorJobCard(
                    job: job,
                    onView: () => _openJob(context, job),
                  ),
                  const SizedBox(height: 10),
                ],
              const SizedBox(height: 12),
              Text(
                'OTHER ACTIVE ASSIGNMENTS',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              if (otherAssignments.isEmpty)
                const _EmptyQueueCard(message: 'No other active assignments.')
              else
                for (final job in otherAssignments) ...[
                  _OperatorJobCard(
                    job: job,
                    onView: () => _openJob(context, job),
                  ),
                  const SizedBox(height: 10),
                ],
            ],
          ),
        ),
      ),
    );
  }

  bool _sameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  int _sortJobs(OperatorJob first, OperatorJob second) {
    final firstPriority = _statusPriority(first.status);
    final secondPriority = _statusPriority(second.status);
    if (firstPriority != secondPriority) {
      return firstPriority.compareTo(secondPriority);
    }
    return first.scheduledAt.compareTo(second.scheduledAt);
  }

  int _statusPriority(OperatorJobStatus status) {
    return switch (status) {
      OperatorJobStatus.inProgress => 0,
      OperatorJobStatus.arrived => 1,
      OperatorJobStatus.enRoute => 2,
      OperatorJobStatus.dispatched => 3,
      OperatorJobStatus.assigned => 4,
      OperatorJobStatus.scheduled => 5,
      OperatorJobStatus.completedPendingConfirmation => 6,
    };
  }

  void _openJob(BuildContext context, OperatorJob job) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OperatorJobDetailScreen(
          repository: repository,
          jobId: job.id,
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

class _NoAssignedJobsCard extends StatelessWidget {
  const _NoAssignedJobsCard();

  @override
  Widget build(BuildContext context) {
    return const OperatorCard(
      child: Row(
        children: [
          Icon(Icons.assignment_outlined),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'No assigned mechanization jobs were returned by the API.',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyQueueCard extends StatelessWidget {
  const _EmptyQueueCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return OperatorCard(
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
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

class _OperatorJobCard extends StatelessWidget {
  const _OperatorJobCard({
    required this.job,
    required this.onView,
    this.emphasis = false,
  });

  final OperatorJob job;
  final VoidCallback onView;
  final bool emphasis;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.reference ?? job.id,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      job.serviceType.label.toUpperCase(),
                      style: (emphasis
                              ? theme.textTheme.titleLarge
                              : theme.textTheme.titleMedium)
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              OperatorStatusPill(status: job.status),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniChip(
                icon: Icons.calendar_today_outlined,
                label: _scheduleText(job),
              ),
              if (job.plannedAcres != null)
                _MiniChip(
                  icon: Icons.straighten,
                  label: '${job.plannedAcres!.toStringAsFixed(1)} acres',
                ),
              _MiniChip(
                icon: Icons.agriculture,
                label: job.tractorLabel ?? job.tractorId,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Line(label: 'Farmer', value: _farmerText(job)),
          _Line(label: 'Plot', value: job.plot.name),
          if (job.amount != null)
            _Line(
              label: 'Amount',
              value:
                  '${job.currency ?? ''} ${job.amount!.toStringAsFixed(job.amount! % 1 == 0 ? 0 : 2)}'
                      .trim(),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.open_in_new),
                  label: Text(_actionLabel(job.status)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _scheduleText(OperatorJob job) {
    final window = job.timeWindow;
    if (window != null && window.isNotEmpty) {
      return '${formatShortDate(job.scheduledAt)} $window';
    }
    return formatDateTime(job.scheduledAt);
  }

  String _farmerText(OperatorJob job) {
    final phone = job.farmerPhone;
    if (phone == null || phone.isEmpty) return job.farmerName;
    return '${job.farmerName} - $phone';
  }

  String _actionLabel(OperatorJobStatus status) {
    return switch (status) {
      OperatorJobStatus.arrived => 'Open Arrival',
      OperatorJobStatus.inProgress => 'Continue Work',
      OperatorJobStatus.enRoute => 'Navigate',
      OperatorJobStatus.dispatched ||
      OperatorJobStatus.assigned ||
      OperatorJobStatus.scheduled => 'Open Job',
      OperatorJobStatus.completedPendingConfirmation => 'View',
    };
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black.withValues(alpha: 0.62)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis,
            ),
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
