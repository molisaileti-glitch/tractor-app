import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../../domain/entities/operator_job.dart';
import '../widgets/operator_widgets.dart';
import 'operator_job_detail_screen.dart';

class OperatorJobsScreen extends StatelessWidget {
  const OperatorJobsScreen({
    super.key,
    required this.repository,
    required this.onOpenSchedule,
  });

  final OperatorLocalRepository repository;
  final VoidCallback onOpenSchedule;

  @override
  Widget build(BuildContext context) {
    final displayName = repository.operatorName?.split(' ').first ?? 'Operator';
    final now = DateTime.now();
    final currentJobs = repository.jobs.where((job) {
      if (job.isComplete) return false;
      final activelyUnderway =
          job.status == OperatorJobStatus.enRoute ||
          job.status == OperatorJobStatus.arrived ||
          job.status == OperatorJobStatus.inProgress;
      return activelyUnderway || _sameDate(job.scheduledAt, now);
    }).toList()..sort(_sortJobs);
    final focusJob = currentJobs.firstOrNull;
    final totalTodayJobs = repository.jobs
        .where((job) => _sameDate(job.scheduledAt, DateTime.now()))
        .length;
    final activeCount = repository.jobs.where((job) => !job.isComplete).length;
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
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              if (repository.mechanizationSyncError != null) ...[
                const SizedBox(height: 12),
                _SyncNotice(
                  message: repository.mechanizationSyncError!,
                  onRetry: repository.refreshMechanizationData,
                ),
              ],
              const SizedBox(height: 18),
              _DashboardToolGrid(
                children: [
                  _DashboardToolCard(
                    value: '${repository.jobs.length}',
                    label: 'Assigned jobs',
                    detail: 'All backend assignments',
                    icon: Icons.assignment_outlined,
                    tint: const Color(0xFFEAF2FF),
                    iconColor: const Color(0xFF2563EB),
                  ),
                  _DashboardToolCard(
                    value: '$totalTodayJobs',
                    label: 'Today',
                    detail: 'Scheduled for this date',
                    icon: Icons.today_outlined,
                    tint: AppColors.mint,
                    iconColor: AppColors.fieldGreen,
                  ),
                  _DashboardToolCard(
                    value: '$activeCount',
                    label: 'Active',
                    detail: 'Not yet closed',
                    icon: Icons.route_outlined,
                    tint: const Color(0xFFFFF4E6),
                    iconColor: AppColors.tractorOrange,
                  ),
                  _DashboardToolCard(
                    value: '${repository.history.length}',
                    label: 'Completed',
                    detail: 'Finished jobs',
                    icon: Icons.task_alt_outlined,
                    tint: const Color(0xFFF0ECFF),
                    iconColor: AppColors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Text(
                    'FOCUS JOB',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onOpenSchedule,
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
              style: const TextStyle(fontWeight: FontWeight.w600),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 34,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 10),
            Text(
              'No current assignment',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Your active job will appear here when it is ready.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardToolGrid extends StatelessWidget {
  const _DashboardToolGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = constraints.maxWidth < 380 ? 10.0 : 12.0;
        final width = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class _DashboardToolCard extends StatelessWidget {
  const _DashboardToolCard({
    required this.value,
    required this.label,
    required this.detail,
    required this.icon,
    required this.tint,
    required this.iconColor,
  });

  final String value;
  final String label;
  final String detail;
  final IconData icon;
  final Color tint;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 172,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.74)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.mutedText,
            ),
          ),
        ],
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
    return Container(
      padding: EdgeInsets.all(emphasis ? 20 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: emphasis
              ? AppColors.fieldGreen.withValues(alpha: 0.22)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: emphasis
                ? AppColors.fieldGreen.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: emphasis ? 24 : 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: emphasis ? 26 : 22,
                backgroundColor: AppColors.fieldGreen.withValues(alpha: 0.12),
                child: const Icon(
                  Icons.agriculture,
                  color: AppColors.fieldGreen,
                ),
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      job.serviceType.label.toUpperCase(),
                      style: (emphasis
                              ? theme.textTheme.titleLarge
                              : theme.textTheme.titleMedium)
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              OperatorStatusPill(status: job.status),
            ],
          ),
          SizedBox(height: emphasis ? 18 : 14),
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
              style: const TextStyle(fontWeight: FontWeight.w600),
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
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
