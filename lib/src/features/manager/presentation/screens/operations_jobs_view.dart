// File purpose: Implements the union manager operations jobs screen and connects user actions to feature state.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../components/components.dart';
import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/union_operations_repository.dart';
import '../../domain/entities/operations_models.dart';
import '../widgets/operations_widgets.dart';

class OperationsJobsView extends StatelessWidget {
  const OperationsJobsView({super.key, required this.repository});

  final UnionOperationsRepository repository;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.appText('Jobs'),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),
        if (repository.mechanizationActionError != null) ...[
          OperationsCard(
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    repository.mechanizationActionError!,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (repository.jobs.isEmpty)
          SizedBox(
            height: 420,
            child: AppEmptyState(
              icon: Icons.route_outlined,
              title: context.appText('No jobs available'),
              message: context.appText(
                'Scheduled and active jobs will appear here.',
              ),
            ),
          ),
        for (final job in repository.jobs) ...[
          _JobCard(
            key: ValueKey('union-job-${job.id}'),
            repository: repository,
            job: job,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class OperationsJobDetailScreen extends StatelessWidget {
  const OperationsJobDetailScreen({
    super.key,
    required this.repository,
    required this.jobId,
  });

  final UnionOperationsRepository repository;
  final String jobId;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: repository,
    builder: (context, _) {
      final job = repository.maybeJobById(jobId);
      return Scaffold(
        appBar: AppBar(title: Text(job?.reference ?? 'Job details')),
        body: RefreshIndicator(
          onRefresh: () => repository.refreshJobDetail(jobId),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (repository.mechanizationActionError != null)
                  AppMessage(
                    message: repository.mechanizationActionError!,
                    type: AppMessageType.error,
                  ),
                if (job == null)
                  Text(
                    context.appText(
                      'This job is no longer available. Refresh the schedule.',
                    ),
                  )
                else
                  _JobCard(
                    key: ValueKey('union-job-${job.id}'),
                    repository: repository,
                    job: job,
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _JobFact extends StatelessWidget {
  const _JobFact({
    required this.icon,
    required this.label,
    required this.value,
  });

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
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 9),
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

class _JobCard extends StatefulWidget {
  const _JobCard({super.key, required this.repository, required this.job});

  final UnionOperationsRepository repository;
  final OperationsJob job;

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
  bool _loadingEvidence = false;
  bool _preparingVerification = false;
  bool _refreshingVerification = false;

  UnionOperationsRepository get repository => widget.repository;
  OperationsJob get job => widget.job;

  bool get _canDispatch =>
      repository.can('mech.jobs.manage') && job.status == JobStatus.scheduled;
  bool get _canManage =>
      repository.can('mech.jobs.manage') &&
      (job.status == JobStatus.scheduled ||
          job.status == JobStatus.dispatched ||
          job.status == JobStatus.enRoute ||
          job.status == JobStatus.arrived ||
          job.status == JobStatus.inProgress ||
          job.status == JobStatus.paused ||
          job.status == JobStatus.completedPendingConfirmation ||
          job.status == JobStatus.verified ||
          job.status == JobStatus.flagged);
  bool get _hasTrailStage =>
      job.status == JobStatus.inProgress ||
      job.status == JobStatus.paused ||
      job.status == JobStatus.completedPendingConfirmation ||
      job.status == JobStatus.verified ||
      job.status == JobStatus.flagged ||
      job.status == JobStatus.closed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tractorLabel =
        job.tractor.assetNo ?? job.tractor.label ?? job.tractor.model;
    return OperationsCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.10,
                  ),
                  child: Icon(
                    Icons.route_outlined,
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
                      const SizedBox(height: 4),
                      Text(
                        '${formatDate(job.scheduledAt)} at ${formatTime(job.scheduledAt)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        OperationsStatusChip.job(
                          key: ValueKey('union-job-status-${job.id}'),
                          jobStatus: job.status,
                        ),
                        if (_canManage)
                          IconButton(
                            tooltip: context.appText('Job actions'),
                            onPressed: () => _showActions(context),
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.more_vert),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(
              color: theme.dividerColor.withValues(alpha: 0.55),
              height: 1,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 18,
              runSpacing: 12,
              children: [
                _JobFact(
                  icon: Icons.person_outline,
                  label: context.appText('Farmer'),
                  value: job.farmerName,
                ),
                _JobFact(
                  icon: Icons.engineering_outlined,
                  label: context.appText('Operator'),
                  value: job.operator.name,
                ),
                _JobFact(
                  icon: Icons.agriculture_outlined,
                  label: context.appText('Tractor'),
                  value: tractorLabel,
                ),
                _JobFact(
                  icon: Icons.location_on_outlined,
                  label: context.appText('Plot'),
                  value: job.plot.name,
                ),
              ],
            ),
            if (job.alert != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  job.alert!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
            if (job.status == JobStatus.completedPendingConfirmation)
              Text(
                repository.requiresFarmerConfirmation &&
                        job.farmerConfirmedAt == null
                    ? 'Awaiting farmer confirmation by PIN/SMS with the operator or through Shamba Bora.'
                    : 'Ready for union verification.',
              ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _loadingEvidence ? null : () => _showEvidence(context),
              child: AppButtonContent(
                label: context.appText('Review work evidence'),
                loadingLabel: context.appText('Loading evidence...'),
                loading: _loadingEvidence,
                icon: Icons.insights_outlined,
              ),
            ),
            if (_refreshingVerification) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(context.appText('Refreshing verification...')),
                  ),
                ],
              ),
            ],
            if (_hasTrailStage) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _openTrail(context),
                icon: const Icon(Icons.map_outlined),
                label: Text(context.appText('View tractor trail')),
              ),
            ],
            if (_canDispatch) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _confirmDispatch(context),
                icon: const Icon(Icons.north_east),
                label: Text(context.appText('Dispatch Job')),
              ),
            ],
            if (repository.can('mech.jobs.manage') &&
                job.status == JobStatus.completedPendingConfirmation) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _preparingVerification
                    ? null
                    : () => _showVerifyDialog(context),
                child: AppButtonContent(
                  label: context.appText('Verify completed work'),
                  loadingLabel: context.appText('Loading evidence...'),
                  loading: _preparingVerification,
                  icon: Icons.verified_outlined,
                ),
              ),
            ],
            if (repository.can('mech.jobs.manage') &&
                job.status == JobStatus.verified) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _confirmClose(context),
                icon: const Icon(Icons.fact_check_outlined),
                label: Text(context.appText('Close verified job')),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openTrail(BuildContext context) {
    Navigator.of(context).push(
      appPageRoute(
        builder: (_) =>
            UnionJobTrailScreen(repository: repository, jobId: job.id),
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (job.status == JobStatus.scheduled ||
                  job.status == JobStatus.dispatched)
                ListTile(
                  leading: const Icon(Icons.event_repeat_outlined),
                  title: Text(context.appText('Reschedule')),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      appPageRoute(
                        builder: (_) => RescheduleJobScreen(
                          repository: repository,
                          jobId: job.id,
                        ),
                      ),
                    );
                  },
                ),
              if (job.status == JobStatus.scheduled)
                ListTile(
                  leading: const Icon(Icons.north_east),
                  title: Text(context.appText('Dispatch')),
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmDispatch(context);
                  },
                ),
              if (job.status == JobStatus.completedPendingConfirmation ||
                  job.status == JobStatus.verified)
                ListTile(
                  leading: const Icon(Icons.insights_outlined),
                  title: Text(context.appText('Refresh verification')),
                  onTap: _refreshingVerification
                      ? null
                      : () async {
                          Navigator.of(context).pop();
                          setState(() => _refreshingVerification = true);
                          try {
                            await repository.refreshJobVerification(job.id);
                          } finally {
                            if (mounted) {
                              setState(() => _refreshingVerification = false);
                            }
                          }
                          if (!context.mounted) return;
                          await _showActionResult(
                            context,
                            successTitle: 'Verification refreshed',
                            successMessage:
                                'The latest verification details are now shown on this job.',
                          );
                        },
                ),
              if (job.status == JobStatus.completedPendingConfirmation ||
                  job.status == JobStatus.verified)
                ListTile(
                  leading: const Icon(Icons.phone_in_talk_outlined),
                  title: Text(context.appText('Manual farmer confirm')),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showConfirmDialog(context);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text(
                  job.status == JobStatus.flagged ? 'Clear flag' : 'Flag job',
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  if (job.status == JobStatus.flagged) {
                    _showUnflagDialog(context);
                  } else {
                    _showFlagDialog(context);
                  }
                },
              ),
              if (job.status == JobStatus.verified)
                ListTile(
                  leading: const Icon(Icons.task_alt_outlined),
                  title: Text(context.appText('Close job')),
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmClose(context);
                  },
                ),
              if (job.status == JobStatus.scheduled ||
                  job.status == JobStatus.dispatched ||
                  job.status == JobStatus.enRoute ||
                  job.status == JobStatus.arrived ||
                  job.status == JobStatus.inProgress ||
                  job.status == JobStatus.paused ||
                  job.status == JobStatus.completedPendingConfirmation)
                ListTile(
                  leading: Icon(
                    Icons.cancel_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    context.appText('Cancel Job'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmCancel(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDispatch(BuildContext context) async {
    final confirmed = await showAppAsyncConfirmationDialog(
      context,
      title: context.appText('Dispatch job?'),
      message:
          'This will send the assignment to ${job.operator.name} using ${job.tractor.assetNo ?? job.tractor.label ?? job.tractor.model}.',
      onConfirm: () => repository.dispatchJob(job.id),
      confirmLabel: 'Dispatch',
      workingLabel: 'Dispatching...',
    );
    if (!confirmed) return;
    if (!context.mounted) return;
    await _showActionResult(
      context,
      successTitle: 'Job dispatched',
      successMessage:
          'The assignment was sent to ${job.operator.name}. You can continue tracking it under Jobs or Schedule.',
    );
  }

  Future<void> _confirmClose(BuildContext context) async {
    var payment =
        ['unpaid', 'deposit', 'paid', 'waived'].contains(job.paymentStatus)
        ? job.paymentStatus!
        : 'unpaid';
    var submitting = false;
    final selected = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, update) => PopScope(
          canPop: !submitting,
          child: AlertDialog(
            title: Text(context.appText('Close verified job')),
            content: DropdownButtonFormField<String>(
              initialValue: payment,
              decoration: InputDecoration(
                labelText: context.appText('Actual payment status'),
              ),
              items: [
                for (final value in ['unpaid', 'deposit', 'paid', 'waived'])
                  DropdownMenuItem(value: value, child: Text(value)),
              ],
              onChanged: submitting
                  ? null
                  : (value) {
                      if (value != null) update(() => payment = value);
                    },
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            actions: [
              AppDialogActions(
                onCancel: () => Navigator.pop(dialogContext),
                onConfirm: () async {
                  if (submitting) return;
                  update(() => submitting = true);
                  await repository.closeJob(job.id, paymentStatus: payment);
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext, payment);
                },
                confirmLabel: submitting ? 'Closing job...' : 'Close job',
                loading: submitting,
              ),
            ],
          ),
        ),
      ),
    );
    if (selected == null || !context.mounted) return;
    await _showActionResult(
      context,
      successTitle: 'Job closed',
      successMessage: 'Job finalised with payment status: $selected.',
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showAppAsyncConfirmationDialog(
      context,
      title: context.appText('Cancel this job?'),
      message: context.appText(
        'The assignment will be cancelled and the operator will no longer continue this job.',
      ),
      onConfirm: () => repository.cancelJob(
        jobId: job.id,
        reason: JobCancellationReason.other,
        notes: '',
      ),
      confirmLabel: 'Cancel Job',
      workingLabel: 'Cancelling job...',
      danger: true,
    );
    if (confirmed) {
      if (!context.mounted) return;
      await _showActionResult(
        context,
        successTitle: 'Job cancelled',
        successMessage:
            'The assignment has been cancelled and the operator should no longer continue it.',
      );
    }
  }

  Future<void> _showFlagDialog(BuildContext context) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.appText('Flag Job')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: context.appText('Reason'),
            hintText: context.appText('Acreage looks inflated'),
          ),
          minLines: 2,
          maxLines: 3,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        actions: [
          AppDialogActions(
            onCancel: () => Navigator.of(context).pop(),
            onConfirm: () => Navigator.of(context).pop(controller.text.trim()),
            confirmLabel: 'Flag',
            danger: true,
          ),
        ],
      ),
    );
    disposeAppDialogController(controller);
    if (reason == null || reason.isEmpty) return;
    if (!context.mounted) return;
    final confirmed = await showAppAsyncConfirmationDialog(
      context,
      title: context.appText('Flag this job?'),
      message: context.appText(
        'The job will be marked for review and the reason will be visible to operations staff.',
      ),
      onConfirm: () => repository.flagJob(jobId: job.id, reason: reason),
      confirmLabel: 'Flag Job',
      workingLabel: 'Flagging job...',
      danger: true,
    );
    if (confirmed) {
      if (!context.mounted) return;
      await _showActionResult(
        context,
        successTitle: 'Job flagged',
        successMessage:
            'The concern is recorded and the job is now marked for operations review.',
      );
    }
  }

  Future<void> _showUnflagDialog(BuildContext context) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.appText('Clear Flag')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: context.appText('Note'),
            hintText: context.appText('Re-measured with the farmer'),
          ),
          minLines: 2,
          maxLines: 3,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        actions: [
          AppDialogActions(
            onCancel: () => Navigator.of(context).pop(),
            onConfirm: () => Navigator.of(context).pop(controller.text.trim()),
            confirmLabel: 'Clear',
          ),
        ],
      ),
    );
    disposeAppDialogController(controller);
    if (note == null || note.isEmpty) return;
    if (!context.mounted) return;
    final confirmed = await showAppAsyncConfirmationDialog(
      context,
      title: context.appText('Clear job flag?'),
      message: context.appText(
        'Confirm that the flagged concern has been reviewed and resolved.',
      ),
      onConfirm: () => repository.unflagJob(jobId: job.id, note: note),
      confirmLabel: 'Clear Flag',
      workingLabel: 'Clearing flag...',
    );
    if (confirmed) {
      if (!context.mounted) return;
      await _showActionResult(
        context,
        successTitle: 'Flag cleared',
        successMessage: 'The review concern has been marked as resolved.',
      );
    }
  }

  Future<void> _showEvidence(BuildContext context) async {
    if (_loadingEvidence) return;
    setState(() => _loadingEvidence = true);
    try {
      await repository.refreshJobDetail(job.id);
    } finally {
      if (mounted) setState(() => _loadingEvidence = false);
    }
    if (!context.mounted) return;
    final detail = repository.maybeJobById(job.id);
    if (detail == null) return;
    if (repository.mechanizationActionError != null) {
      await showAppErrorDialog(
        context,
        title: context.appText('Could not load job'),
        message: repository.mechanizationActionError!,
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.appText('Work evidence')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reported acres: ${detail.reportedAcres ?? 'Not supplied'}'),
              Text('Verified acres: ${detail.verifiedAcres ?? 'Not verified'}'),
              Text(
                'Farmer: ${detail.farmerConfirmedAt == null ? 'Awaiting confirmation' : 'Confirmed'}',
              ),
              Text('Payment: ${detail.paymentStatus ?? 'Not supplied'}'),
              if (detail.amount != null)
                Text('Amount: ${detail.currency ?? ''} ${detail.amount}'),
              const Divider(),
              if (detail.verification.isEmpty)
                Text(context.appText('No tracker analysis is available yet.')),
              Text(
                'Tracker estimate: ${detail.verification['est_acres'] ?? 'Not available'} acres',
              ),
              Text(
                'Work inside plot: ${detail.verification['inside_pct'] ?? 'Not available'}%',
              ),
              Text(
                'Trail samples: ${detail.verification['points'] ?? 'Not available'}',
              ),
              if (detail.verification['work_seconds'] is num)
                Text(
                  'Recorded work: ${((detail.verification['work_seconds'] as num) / 60).toStringAsFixed(0)} minutes',
                ),
              if (detail.verification['inside_distance_m'] is num)
                Text(
                  'Distance worked inside plot: ${((detail.verification['inside_distance_m'] as num) / 1000).toStringAsFixed(2)} km',
                ),
              Text(
                'Evidence score: ${detail.verification['score'] ?? 'Not available'}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.appText('Close')),
          ),
        ],
      ),
    );
  }

  Future<void> _showVerifyDialog(BuildContext context) async {
    if (_preparingVerification) return;
    setState(() => _preparingVerification = true);
    try {
      await repository.refreshJobDetail(job.id);
    } finally {
      if (mounted) setState(() => _preparingVerification = false);
    }
    if (!context.mounted) return;
    if (repository.mechanizationActionError != null) {
      await showAppErrorDialog(
        context,
        title: context.appText('Could not load evidence'),
        message: repository.mechanizationActionError!,
      );
      return;
    }
    final detail = repository.maybeJobById(job.id);
    if (detail == null) return;
    if (repository.requiresFarmerConfirmation &&
        detail.farmerConfirmedAt == null) {
      await showAppErrorDialog(
        context,
        title: context.appText('Farmer confirmation required'),
        message: context.appText(
          'Ask the operator to record the farmer\'s PIN/SMS confirmation, or wait for confirmation through Shamba Bora, then refresh this job. An authorised union officer may also record a confirmation received by phone or at the office.',
        ),
      );
      return;
    }
    final acresController = TextEditingController(
      text:
          (detail.reportedAcres ??
                  detail.verification['est_acres'] as num? ??
                  0)
              .toStringAsFixed(2),
    );
    final noteController = TextEditingController();
    final input = await showDialog<_VerifyJobInput>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.appText('Verify Job')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reported: ${detail.reportedAcres ?? 'Not supplied'} acres'),
              Text(
                'Tracker estimate: ${detail.verification['est_acres'] ?? 'Not available'} acres',
              ),
              Text(
                'Inside plot: ${detail.verification['inside_pct'] ?? 'Not available'}%',
              ),
              Text(
                'Farmer confirmation: ${detail.farmerConfirmedAt == null ? 'Not recorded' : formatDateTime(detail.farmerConfirmedAt!)}',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: acresController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: context.appText('Verified acres'),
                  hintText: context.appText('4.5'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: context.appText('Note'),
                  hintText: context.appText('Add verification note'),
                ),
                minLines: 2,
                maxLines: 3,
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        actions: [
          AppDialogActions(
            onCancel: () => Navigator.of(context).pop(),
            onConfirm: () {
              final acres = num.tryParse(acresController.text.trim());
              if (acres == null || !acres.isFinite || acres <= 0) return;
              Navigator.of(context).pop(
                _VerifyJobInput(
                  verifiedAcres: acres,
                  note: noteController.text.trim(),
                ),
              );
            },
            confirmLabel: 'Verify',
          ),
        ],
      ),
    );
    disposeAppDialogController(acresController);
    disposeAppDialogController(noteController);
    if (input == null) return;
    if (!context.mounted) return;
    final confirmed = await showAppAsyncConfirmationDialog(
      context,
      title: context.appText('Verify completed work?'),
      message:
          'Confirm ${input.verifiedAcres} verified acres. This value will be used for the final job record and charge.',
      onConfirm: () => repository.verifyJob(
        jobId: job.id,
        verifiedAcres: input.verifiedAcres,
        note: input.note.isEmpty ? null : input.note,
      ),
      confirmLabel: 'Verify',
      workingLabel: 'Verifying...',
    );
    if (!confirmed) return;
    if (!context.mounted) return;
    await _showActionResult(
      context,
      successTitle: 'Job verified',
      successMessage:
          'The verified acreage has been saved. The job can now be closed with its actual payment status.',
    );
  }

  Future<void> _showConfirmDialog(BuildContext context) async {
    var rating = 5;
    var dispute = false;
    final noteController = TextEditingController();
    final input = await showDialog<_ConfirmJobInput>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.appText('Manual Farmer Confirm')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: rating,
                decoration: InputDecoration(
                  labelText: context.appText('Rating'),
                ),
                items: [1, 2, 3, 4, 5]
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text('$value')),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => rating = value);
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: dispute,
                title: Text(context.appText('Farmer disputes this job')),
                onChanged: (value) => setState(() => dispute = value),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: dispute ? 'Dispute note' : 'Confirmation note',
                ),
                minLines: 2,
                maxLines: 3,
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          actions: [
            AppDialogActions(
              onCancel: () => Navigator.of(context).pop(),
              onConfirm: () {
                final note = noteController.text.trim();
                if (dispute && note.isEmpty) return;
                Navigator.of(context).pop(
                  _ConfirmJobInput(
                    rating: rating,
                    note: note,
                    dispute: dispute,
                  ),
                );
              },
              confirmLabel: 'Submit',
            ),
          ],
        ),
      ),
    );
    disposeAppDialogController(noteController);
    if (input == null) return;
    if (!context.mounted) return;
    final confirmed = await showAppAsyncConfirmationDialog(
      context,
      title: input.dispute ? 'Record farmer dispute?' : 'Confirm for farmer?',
      message: input.dispute
          ? 'This will record that the farmer disputes the completed work.'
          : 'Confirm that the farmer approved the completed work by phone.',
      onConfirm: () => repository.confirmJob(
        jobId: job.id,
        rating: input.rating,
        note: input.note.isEmpty ? null : input.note,
        dispute: input.dispute,
      ),
      confirmLabel: input.dispute ? 'Record Dispute' : 'Confirm',
      workingLabel: input.dispute ? 'Recording dispute...' : 'Confirming...',
      danger: input.dispute,
    );
    if (!confirmed) return;
    if (!context.mounted) return;
    await _showActionResult(
      context,
      successTitle: input.dispute
          ? 'Dispute recorded'
          : 'Confirmation recorded',
      successMessage: input.dispute
          ? 'The farmer dispute has been saved for operations review.'
          : 'The manual farmer confirmation has been saved on this job.',
    );
  }

  Future<void> _showActionResult(
    BuildContext context, {
    required String successTitle,
    required String successMessage,
  }) async {
    final error = repository.mechanizationActionError;
    if (error != null) {
      await showAppErrorDialog(
        context,
        title: context.appText('Action not completed'),
        message: error,
      );
      return;
    }
    await showAppSuccessDialog(
      context,
      title: successTitle,
      message: successMessage,
    );
  }
}

class _VerifyJobInput {
  const _VerifyJobInput({required this.verifiedAcres, required this.note});

  final num verifiedAcres;
  final String note;
}

class _ConfirmJobInput {
  const _ConfirmJobInput({
    required this.rating,
    required this.note,
    required this.dispute,
  });

  final int rating;
  final String note;
  final bool dispute;
}

/// Union review surface for the documented GET /jobs/{id}/path payload.
/// Active jobs poll only while this route is visible; completed trails load
/// once and can be refreshed manually.
class UnionJobTrailScreen extends StatefulWidget {
  const UnionJobTrailScreen({
    super.key,
    required this.repository,
    required this.jobId,
  });

  final UnionOperationsRepository repository;
  final String jobId;

  @override
  State<UnionJobTrailScreen> createState() => _UnionJobTrailScreenState();
}

class _UnionJobTrailScreenState extends State<UnionJobTrailScreen>
    with WidgetsBindingObserver {
  Timer? _pollTimer;
  bool _loading = false;
  String? _error;
  int _pollTicks = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_refresh());
      _syncPolling();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refresh());
      _syncPolling();
    } else {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  void _syncPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    final status = widget.repository.maybeJobById(widget.jobId)?.status;
    if (status != JobStatus.inProgress && status != JobStatus.paused) return;
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
        _pollTicks++;
        unawaited(_refresh(showSpinner: false, reloadJob: _pollTicks % 4 == 0));
      }
    });
  }

  Future<void> _refresh({
    bool showSpinner = true,
    bool reloadJob = true,
  }) async {
    if (_loading) return;
    if (showSpinner && mounted) setState(() => _loading = true);
    _loading = true;
    if (reloadJob) await widget.repository.refreshJobDetail(widget.jobId);
    final loaded = await widget.repository.refreshJobTrail(widget.jobId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = loaded ? null : widget.repository.mechanizationActionError;
    });
    _syncPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.repository,
      builder: (context, _) {
        final job = widget.repository.maybeJobById(widget.jobId);
        final trail = widget.repository.trailForJob(widget.jobId);
        final liveTractor = widget.repository.liveTractorForJob(widget.jobId);
        return Scaffold(
          appBar: AppBar(
            title: Text(
              job?.reference == null
                  ? context.appText('Tractor trail')
                  : '${job!.reference} · ${context.appText('Tractor trail')}',
            ),
            actions: [
              IconButton(
                tooltip: context.appText('Refresh trail'),
                onPressed: _loading ? null : _refresh,
                icon: _loading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              children: [
                if (_error != null) ...[
                  AppMessage(
                    type: AppMessageType.error,
                    title: context.appText('Trail unavailable'),
                    message: _error!,
                  ),
                  const SizedBox(height: 12),
                ],
                if (job == null)
                  SizedBox(
                    height: 360,
                    child: AppEmptyState(
                      icon: Icons.route_outlined,
                      title: context.appText('Job unavailable'),
                      message: context.appText(
                        'Refresh the job and try opening its trail again.',
                      ),
                    ),
                  )
                else ...[
                  _UnionTrailSummary(
                    job: job,
                    sampleCount: trail.length,
                    liveTractor: liveTractor,
                  ),
                  const SizedBox(height: 12),
                  if (trail.isEmpty && liveTractor == null)
                    Column(
                      children: [
                        SizedBox(
                          height: 300,
                          child: AppEmptyState(
                            icon: Icons.wrong_location_outlined,
                            title: context.appText('No tractor trail yet'),
                            message: context.appText(
                              'The backend has not returned tracker samples for this job. Refresh after the tracker sends positions.',
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _loading ? null : _refresh,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(context.appText('Refresh trail')),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      height: 480,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _UnionTrailMap(
                          job: job,
                          trail: trail,
                          liveTractor: liveTractor,
                        ),
                      ),
                    ),
                  if (trail.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const _TrailColourGuide(),
                  ],
                  if (job.status == JobStatus.completedPendingConfirmation) ...[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.verified_outlined),
                      label: Text(context.appText('Return to verification')),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UnionTrailSummary extends StatelessWidget {
  const _UnionTrailSummary({
    required this.job,
    required this.sampleCount,
    required this.liveTractor,
  });

  final OperationsJob job;
  final int sampleCount;
  final OperationsLiveTractorPosition? liveTractor;

  @override
  Widget build(BuildContext context) {
    final verificationPoints = job.verification['points'];
    final insidePercentage = job.verification['inside_pct'];
    final estimatedAcres = job.verification['est_acres'];
    final notCalculated = context.appText('Not calculated');
    final insideText = insidePercentage == null
        ? notCalculated
        : '$insidePercentage%';
    final estimateText = estimatedAcres == null
        ? notCalculated
        : '$estimatedAcres ${context.appText('acres')}';
    final fixAge = liveTractor?.ageAt(DateTime.now());
    final tractorIsLive = liveTractor?.isLiveAt(DateTime.now()) ?? false;
    final locationStatus = liveTractor == null
        ? context.appText('Waiting for tractor location')
        : tractorIsLive
        ? context.appText('Online')
        : context.appText('Last known location');
    return OperationsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.appText('Tracker evidence'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text('${context.appText('Tractor location')}: $locationStatus'),
          if (fixAge != null)
            Text(
              '${context.appText('Fix age')}: ${_compactFixAge(context, fixAge)}',
            ),
          Text('${context.appText('Map samples returned')}: $sampleCount'),
          Text(
            '${context.appText('Verification samples')}: ${verificationPoints ?? notCalculated}',
          ),
          Text('${context.appText('Inside plot')}: $insideText'),
          Text('${context.appText('Tracker estimate')}: $estimateText'),
        ],
      ),
    );
  }
}

class _UnionTrailMap extends StatelessWidget {
  const _UnionTrailMap({
    required this.job,
    required this.trail,
    required this.liveTractor,
  });

  final OperationsJob job;
  final List<OperationsTrailPoint> trail;
  final OperationsLiveTractorPosition? liveTractor;

  @override
  Widget build(BuildContext context) {
    final boundary = job.plot.boundaryPoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList(growable: false);
    final path = trail
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList(growable: false);
    final livePoint = liveTractor == null
        ? null
        : LatLng(liveTractor!.latitude, liveTractor!.longitude);
    final allPoints = [...boundary, ...path, ?livePoint];
    final initial = allPoints.first;
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initial, zoom: 17),
      onMapCreated: (controller) {
        if (allPoints.length < 2) return;
        controller.moveCamera(
          CameraUpdate.newLatLngBounds(_trailBounds(allPoints), 48),
        );
      },
      mapType: MapType.hybrid,
      markers: {
        if (path.isNotEmpty)
          Marker(
            markerId: const MarkerId('trail-start'),
            position: path.first,
            infoWindow: InfoWindow(title: context.appText('Trail start')),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
        if (livePoint == null && path.length > 1)
          Marker(
            markerId: const MarkerId('trail-latest'),
            position: path.last,
            infoWindow: InfoWindow(
              title: context.appText('Latest tracker sample'),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
          ),
        if (livePoint != null)
          Marker(
            markerId: const MarkerId('live-tractor'),
            position: livePoint,
            infoWindow: InfoWindow(
              title: context.appText('Tractor location'),
              snippet: _liveTractorSnippet(context, liveTractor!),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
          ),
      },
      polygons: {
        if (boundary.length >= 3)
          Polygon(
            polygonId: const PolygonId('job-plot-boundary'),
            points: boundary,
            fillColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.12),
            strokeColor: Theme.of(context).colorScheme.primary,
            strokeWidth: 3,
          ),
      },
      polylines: {
        for (var index = 1; index < trail.length; index++)
          Polyline(
            polylineId: PolylineId('trail-segment-$index'),
            points: [path[index - 1], path[index]],
            width: 5,
            color: switch (trail[index].inside) {
              true => const Color(0xFF16A34A),
              false => const Color(0xFFDC2626),
              null => const Color(0xFF64748B),
            },
          ),
      },
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
      compassEnabled: true,
    );
  }
}

String _liveTractorSnippet(
  BuildContext context,
  OperationsLiveTractorPosition position,
) {
  final status = position.isLiveAt(DateTime.now())
      ? context.appText('Online')
      : context.appText('Last known location');
  final age = position.ageAt(DateTime.now());
  if (age == null) return status;
  return '$status · ${context.appText('Fix age')}: ${_compactFixAge(context, age)}';
}

String _compactFixAge(BuildContext context, int seconds) {
  if (seconds < 60) return '$seconds ${context.appText('seconds')}';
  final minutes = seconds ~/ 60;
  if (minutes < 60) return '$minutes ${context.appText('minutes')}';
  return '${minutes ~/ 60} ${context.appText('hours')}';
}

class _TrailColourGuide extends StatelessWidget {
  const _TrailColourGuide();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        _TrailGuideItem(
          color: const Color(0xFF16A34A),
          label: context.appText('Inside plot'),
        ),
        _TrailGuideItem(
          color: const Color(0xFFDC2626),
          label: context.appText('Outside plot'),
        ),
        _TrailGuideItem(
          color: const Color(0xFF64748B),
          label: context.appText('Unknown'),
        ),
      ],
    );
  }
}

class _TrailGuideItem extends StatelessWidget {
  const _TrailGuideItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

LatLngBounds _trailBounds(List<LatLng> points) {
  var minLat = points.first.latitude;
  var maxLat = points.first.latitude;
  var minLng = points.first.longitude;
  var maxLng = points.first.longitude;
  for (final point in points.skip(1)) {
    if (point.latitude < minLat) minLat = point.latitude;
    if (point.latitude > maxLat) maxLat = point.latitude;
    if (point.longitude < minLng) minLng = point.longitude;
    if (point.longitude > maxLng) maxLng = point.longitude;
  }
  const padding = 0.00005;
  if (minLat == maxLat) {
    minLat -= padding;
    maxLat += padding;
  }
  if (minLng == maxLng) {
    minLng -= padding;
    maxLng += padding;
  }
  return LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );
}

class RescheduleJobScreen extends StatefulWidget {
  const RescheduleJobScreen({
    super.key,
    required this.repository,
    required this.jobId,
  });

  final UnionOperationsRepository repository;
  final String jobId;

  @override
  State<RescheduleJobScreen> createState() => _RescheduleJobScreenState();
}

class _RescheduleJobScreenState extends State<RescheduleJobScreen> {
  late DateTime _selectedAt;
  JobRescheduleReason _reason = JobRescheduleReason.tractorBreakdown;

  @override
  void initState() {
    super.initState();
    _selectedAt =
        widget.repository.maybeJobById(widget.jobId)?.scheduledAt ??
        DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.repository.maybeJobById(widget.jobId);
    if (job == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.appText('Job unavailable'))),
        body: Center(
          child: Text(
            context.appText('This assignment is no longer available.'),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(context.appText('Reschedule Job')),
        actions: [
          IconButton(
            tooltip: context.appText('Save'),
            onPressed: () => _save(job),
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.appText('Date & Time'),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _SettingRow(
                    icon: Icons.calendar_month_outlined,
                    title: context.appText('Date'),
                    value: formatDate(_selectedAt),
                    onTap: _pickDate,
                  ),
                  const Divider(height: 1),
                  _SettingRow(
                    icon: Icons.schedule,
                    title: context.appText('Time'),
                    value: formatTime(_selectedAt),
                    onTap: _pickTime,
                  ),
                  const Divider(height: 1),
                  _SettingRow(
                    icon: Icons.event_note_outlined,
                    title: context.appText('Reason for reschedule'),
                    value: _reason.label,
                    onTap: _pickReason,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                '${job.id} - ${job.farmerName} - ${job.serviceType.label}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _selectedAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _selectedAt.hour,
        _selectedAt.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedAt),
    );
    if (picked == null) return;
    setState(() {
      _selectedAt = DateTime(
        _selectedAt.year,
        _selectedAt.month,
        _selectedAt.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  void _pickReason() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final reason in JobRescheduleReason.values)
              ListTile(
                leading: Icon(
                  _reason == reason
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(reason.label),
                onTap: () {
                  setState(() => _reason = reason);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(OperationsJob job) async {
    final confirmed = await showAppAsyncConfirmationDialog(
      context,
      title: context.appText('Reschedule job?'),
      message:
          'Move this job to ${formatDate(_selectedAt)} at ${formatTime(_selectedAt)} for ${_reason.label.toLowerCase()}?',
      onConfirm: () => widget.repository.rescheduleJob(
        jobId: job.id,
        newScheduledAt: _selectedAt,
        tractorId: job.tractor.id,
        operatorId: job.operator.id,
        reason: _reason,
        notes: '',
      ),
      confirmLabel: 'Reschedule',
      workingLabel: 'Rescheduling...',
    );
    if (!confirmed || !mounted) return;
    final error = widget.repository.mechanizationActionError;
    if (error != null) {
      await showAppErrorDialog(
        context,
        title: context.appText('Job not rescheduled'),
        message: error,
      );
      return;
    }
    await showAppSuccessDialog(
      context,
      title: context.appText('Job rescheduled'),
      message: context.appText(
        'The updated date and time are now shown under Jobs and Schedule.',
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
