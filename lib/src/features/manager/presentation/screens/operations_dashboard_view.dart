import 'package:flutter/material.dart';

import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/union_operations_repository.dart';
import '../../domain/entities/operations_models.dart';
import '../widgets/operations_widgets.dart';

class OperationsDashboardView extends StatelessWidget {
  const OperationsDashboardView({
    super.key,
    required this.repository,
    required this.onOpenRequests,
    required this.onOpenJobs,
    required this.onOpenOversight,
  });

  final UnionOperationsRepository repository;
  final VoidCallback onOpenRequests;
  final VoidCallback onOpenJobs;
  final VoidCallback onOpenOversight;

  @override
  Widget build(BuildContext context) {
    final jobs = repository.jobs.take(3).toList();
    final awaitingVerification = repository.jobs
        .where((job) => job.status == JobStatus.completedPendingConfirmation)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageTitle(
          title: "Today's Overview",
          subtitle: 'Requests, resources and field activity',
        ),
        if (repository.isSyncingMechanization) ...[
          const LinearProgressIndicator(minHeight: 3),
          const SizedBox(height: 14),
        ] else if (repository.mechanizationSyncError != null) ...[
          _SyncNotice(
            message: repository.mechanizationSyncError!,
            onRetry: repository.refreshMechanizationData,
          ),
          const SizedBox(height: 14),
        ],
        _MetricWrap(
          children: [
            _CompactMetricCard(
              value: '${repository.pendingRequestCount}',
              label: 'Pending',
              icon: Icons.pending_actions,
              color: const Color(0xFFC8872B),
            ),
            _CompactMetricCard(
              value: '${repository.activeJobs.length}',
              label: 'Active',
              icon: Icons.route,
              color: const Color(0xFF277DA1),
            ),
            _CompactMetricCard(
              value: '${repository.completedTodayCount}',
              label: 'Completed',
              icon: Icons.task_alt,
              color: const Color(0xFF2F6F4E),
            ),
            _CompactMetricCard(
              value: '${repository.pendingOverrideCount}',
              label: 'Overrides',
              icon: Icons.rule_folder_outlined,
              color: const Color(0xFFB45309),
            ),
            _CompactMetricCard(
              value: '${repository.openExceptionCount}',
              label: 'Exceptions',
              icon: Icons.report_problem_outlined,
              color: const Color(0xFFE11D48),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _DashboardSectionHeader(
          title: 'Attention Needed',
          icon: Icons.priority_high_rounded,
        ),
        const SizedBox(height: 10),
        _AttentionCard(
          icon: Icons.warning_amber_outlined,
          text: '${repository.pendingRequestCount} requests awaiting approval',
          onTap: onOpenRequests,
        ),
        const SizedBox(height: 10),
        _AttentionCard(
          icon: Icons.build_outlined,
          text: '${repository.maintenanceCount} tractor under maintenance',
        ),
        const SizedBox(height: 10),
        _AttentionCard(
          icon: Icons.fact_check_outlined,
          text: '$awaitingVerification completed jobs awaiting verification',
          onTap: onOpenJobs,
        ),
        const SizedBox(height: 10),
        _AttentionCard(
          icon: Icons.rule_folder_outlined,
          text:
              '${repository.pendingOverrideCount} start override requests pending',
          onTap: onOpenOversight,
        ),
        const SizedBox(height: 10),
        _AttentionCard(
          icon: Icons.report_problem_outlined,
          text: '${repository.openExceptionCount} open exceptions',
          onTap: onOpenOversight,
        ),
        const SizedBox(height: 18),
        _DashboardSectionHeader(
          title: "Today's Jobs",
          icon: Icons.event_note_outlined,
        ),
        const SizedBox(height: 10),
        if (jobs.isEmpty)
          const OperationsCard(child: Text('No jobs loaded yet.'))
        else
          for (final job in jobs) ...[
            _TodayJobCard(job: job),
            if (job != jobs.last) const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _SyncNotice extends StatelessWidget {
  const _SyncNotice({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return OperationsCard(
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

class _DashboardSectionHeader extends StatelessWidget {
  const _DashboardSectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _MetricWrap extends StatelessWidget {
  const _MetricWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 420 ? 1 : 3;
        final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: children
              .map((child) => SizedBox(width: width, child: child))
              .toList(),
        );
      },
    );
  }
}

class _CompactMetricCard extends StatelessWidget {
  const _CompactMetricCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return OperationsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({required this.icon, required this.text, this.onTap});

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OperationsCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          if (onTap != null) const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _TodayJobCard extends StatelessWidget {
  const _TodayJobCard({required this.job});

  final OperationsJob job;

  @override
  Widget build(BuildContext context) {
    return OperationsCard(
      child: Row(
        children: [
          Container(
            width: 58,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              formatTime(job.scheduledAt),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${job.serviceType.label} - ${job.tractor.id}',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          OperationsStatusChip.job(jobStatus: job.status),
        ],
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(subtitle),
        ],
      ),
    );
  }
}
