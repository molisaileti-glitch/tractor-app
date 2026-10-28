import 'package:flutter/material.dart';

import '../../../../components/components.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
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
    required this.onRefresh,
  });

  final OperatorLocalRepository repository;
  final VoidCallback onOpenSchedule;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final displayName = repository.operatorName?.split(' ').first ?? 'Operator';
    final dashboardJobs = repository.dashboardJobs;
    final currentJobs = dashboardJobs.where((job) => !job.isComplete).toList()
      ..sort(_sortJobs);
    final focusJob = currentJobs.firstOrNull;
    final totalTodayJobs = dashboardJobs
        .where((job) => _sameDate(job.scheduledAt, DateTime.now()))
        .length;
    final activeCount = dashboardJobs.where((job) => !job.isComplete).length;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                      child: TimeAwareGreeting(
                        name: displayName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                if (repository.screenError(OperatorDataScreen.dashboard) !=
                    null) ...[
                  const SizedBox(height: 12),
                  _SyncNotice(
                    message: repository.screenError(
                      OperatorDataScreen.dashboard,
                    )!,
                    onRetry: () =>
                        repository.refreshScreen(OperatorDataScreen.dashboard),
                  ),
                ],
                const SizedBox(height: 18),
                _DashboardToolGrid(
                  children: [
                    _DashboardToolCard(
                      value: '${dashboardJobs.length}',
                      label: strings.assignedJobs,
                      detail: strings.allAssignments,
                      icon: Icons.assignment_outlined,
                      tint: const Color(0xFFEAF2FF),
                      iconColor: const Color(0xFF2563EB),
                    ),
                    _DashboardToolCard(
                      value: '$totalTodayJobs',
                      label: strings.today,
                      detail: strings.scheduledForDate,
                      icon: Icons.today_outlined,
                      tint: AppColors.mint,
                      iconColor: AppColors.fieldGreen,
                    ),
                    _DashboardToolCard(
                      value: '$activeCount',
                      label: strings.active,
                      detail: strings.notYetClosed,
                      icon: Icons.route_outlined,
                      tint: const Color(0xFFFFF4E6),
                      iconColor: AppColors.tractorOrange,
                    ),
                    _DashboardToolCard(
                      value: '${repository.completedJobs.length}',
                      label: strings.completed,
                      detail: strings.finishedJobs,
                      icon: Icons.task_alt_outlined,
                      tint: const Color(0xFFF0ECFF),
                      iconColor: AppColors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        strings.focusJob.toUpperCase(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: onOpenSchedule,
                          icon: const Icon(Icons.calendar_month_outlined),
                          label: Text(strings.viewSchedule),
                        ),
                      ),
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
                if (currentJobs.length > 1) ...[
                  const SizedBox(height: 22),
                  Text(
                    strings.allAssignments.toUpperCase(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  for (final job in currentJobs.skip(1)) ...[
                    const SizedBox(height: 12),
                    _OperatorJobCard(
                      job: job,
                      onView: () => _openJob(context, job),
                    ),
                  ],
                ],
              ],
            ),
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
      OperatorJobStatus.paused => 1,
      OperatorJobStatus.arrived => 2,
      OperatorJobStatus.enRoute => 3,
      OperatorJobStatus.dispatched => 4,
      OperatorJobStatus.assigned => 5,
      OperatorJobStatus.scheduled => 6,
      OperatorJobStatus.flagged => 7,
      OperatorJobStatus.completedPendingConfirmation ||
      OperatorJobStatus.verified ||
      OperatorJobStatus.closed ||
      OperatorJobStatus.cancelled => 8,
    };
  }

  Future<void> _openJob(BuildContext context, OperatorJob job) async {
    final loaded = await repository.refreshJobDetail(job.id);
    if (!context.mounted) return;
    if (!loaded) {
      showAppSnackBar(
        context,
        message:
            repository.lastActionError ??
            'This assignment is no longer available. Refresh your jobs.',
        type: AppSnackType.error,
      );
      return;
    }
    Navigator.of(context).push(
      appPageRoute(
        builder: (_) =>
            OperatorJobDetailScreen(repository: repository, jobId: job.id),
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
            tooltip: AppLocalizations.of(context)!.retry,
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
              AppLocalizations.of(context)!.noCurrentAssignment,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.activeJobAppearsHere,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.adaptiveMutedText(context),
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
        return Column(
          children: [
            for (var index = 0; index < children.length; index += 2) ...[
              if (index > 0) SizedBox(height: spacing),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: children[index]),
                    SizedBox(width: spacing),
                    if (index + 1 < children.length)
                      Expanded(child: children[index + 1])
                    else
                      const Spacer(),
                  ],
                ),
              ),
            ],
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
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(minHeight: 172),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark
            ? Color.alphaBlend(tint.withValues(alpha: 0.12), scheme.surface)
            : tint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
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
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
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
    final strings = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(emphasis ? 20 : 18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: emphasis
              ? AppColors.fieldGreen.withValues(alpha: 0.22)
              : theme.colorScheme.outlineVariant,
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      style:
                          (emphasis
                                  ? theme.textTheme.titleLarge
                                  : theme.textTheme.titleMedium)
                              ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Align(
                  alignment: Alignment.topRight,
                  child: OperatorStatusPill(
                    key: ValueKey('operator-job-status-${job.id}'),
                    status: job.status,
                  ),
                ),
              ),
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
                  label: strings.acresValue(
                    job.plannedAcres!.toStringAsFixed(1),
                  ),
                ),
              _MiniChip(
                icon: Icons.agriculture,
                label: job.tractorLabel ?? job.tractorId,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Line(label: strings.farmer, value: _farmerText(job)),
          _Line(label: strings.plot, value: job.plot.name),
          if (job.amount != null)
            _Line(
              label: strings.amount,
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
                  label: Text(_actionLabel(job.status, strings)),
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

  String _actionLabel(OperatorJobStatus status, AppLocalizations strings) {
    return switch (status) {
      OperatorJobStatus.arrived => strings.openArrival,
      OperatorJobStatus.inProgress => strings.continueWork,
      OperatorJobStatus.paused => 'Resume work',
      OperatorJobStatus.enRoute => strings.navigate,
      OperatorJobStatus.dispatched ||
      OperatorJobStatus.assigned ||
      OperatorJobStatus.scheduled => strings.openJob,
      OperatorJobStatus.completedPendingConfirmation ||
      OperatorJobStatus.verified ||
      OperatorJobStatus.closed ||
      OperatorJobStatus.cancelled ||
      OperatorJobStatus.flagged => strings.view,
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
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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
