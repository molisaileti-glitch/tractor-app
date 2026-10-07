import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
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
              color: AppColors.fieldGreen,
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
        if (repository.pendingRequestCount > 0) ...[
          _AttentionCard(
            icon: Icons.warning_amber_outlined,
            text: '${repository.pendingRequestCount} requests awaiting approval',
            onTap: onOpenRequests,
          ),
          const SizedBox(height: 10),
        ],
        if (repository.maintenanceCount > 0) ...[
          _AttentionCard(
            icon: Icons.build_outlined,
            text: '${repository.maintenanceCount} tractors under maintenance',
          ),
          const SizedBox(height: 10),
        ],
        if (awaitingVerification > 0) ...[
          _AttentionCard(
            icon: Icons.fact_check_outlined,
            text: '$awaitingVerification completed jobs awaiting verification',
            onTap: onOpenJobs,
          ),
          const SizedBox(height: 10),
        ],
        if (repository.pendingOverrideCount > 0) ...[
          _AttentionCard(
            icon: Icons.rule_folder_outlined,
            text:
                '${repository.pendingOverrideCount} start override requests pending',
            onTap: onOpenOversight,
          ),
          const SizedBox(height: 10),
        ],
        if (repository.openExceptionCount > 0)
          _AttentionCard(
            icon: Icons.report_problem_outlined,
            text: '${repository.openExceptionCount} open exceptions',
            onTap: onOpenOversight,
          ),
        if (repository.pendingRequestCount == 0 &&
            repository.maintenanceCount == 0 &&
            awaitingVerification == 0 &&
            repository.pendingOverrideCount == 0 &&
            repository.openExceptionCount == 0)
          const _AllClearNotice(),
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
        final columns = constraints.maxWidth >= 840 ? 3 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
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
    return Container(
      height: 136,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.74)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
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
            child: Icon(icon, color: color, size: 22),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
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
    final theme = Theme.of(context);
    final tractorLabel = job.tractor.assetNo ?? job.tractor.label ?? job.tractor.model;
    final plotArea = job.plot.areaHectares > 0
        ? '${job.plot.areaHectares.toStringAsFixed(1)} ha'
        : null;
    return OperationsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.agriculture_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.serviceType.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${formatDate(job.scheduledAt)} at ${formatTime(job.scheduledAt)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              OperationsStatusChip.job(jobStatus: job.status),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: theme.dividerColor.withValues(alpha: 0.55), height: 1),
          const SizedBox(height: 14),
          Wrap(
            spacing: 18,
            runSpacing: 12,
            children: [
              _JobFact(icon: Icons.person_outline, label: 'Farmer', value: job.farmerName),
              _JobFact(icon: Icons.engineering_outlined, label: 'Operator', value: job.operator.name),
              _JobFact(icon: Icons.agriculture_outlined, label: 'Tractor', value: tractorLabel),
              _JobFact(
                icon: Icons.location_on_outlined,
                label: 'Plot',
                value: [job.plot.name, plotArea].whereType<String>().join(' - '),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobFact extends StatelessWidget {
  const _JobFact({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 210,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllClearNotice extends StatelessWidget {
  const _AllClearNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text('Nothing needs attention right now.', style: theme.textTheme.bodyLarge),
          ],
        ),
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
