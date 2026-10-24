import 'package:flutter/material.dart';

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
          'Jobs',
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
          const SizedBox(
            height: 420,
            child: AppEmptyState(
              icon: Icons.route_outlined,
              title: 'No jobs available',
              message: 'Scheduled and active jobs will appear here.',
            ),
          ),
        for (final job in repository.jobs) ...[
          _JobCard(repository: repository, job: job),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
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

class _JobCard extends StatelessWidget {
  const _JobCard({required this.repository, required this.job});

  final UnionOperationsRepository repository;
  final OperationsJob job;

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
                OperationsStatusChip.job(jobStatus: job.status),
                if (_canManage)
                  IconButton(
                    tooltip: 'Job actions',
                    onPressed: () => _showActions(context),
                    icon: const Icon(Icons.more_vert),
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
                  label: 'Farmer',
                  value: job.farmerName,
                ),
                _JobFact(
                  icon: Icons.engineering_outlined,
                  label: 'Operator',
                  value: job.operator.name,
                ),
                _JobFact(
                  icon: Icons.agriculture_outlined,
                  label: 'Tractor',
                  value: tractorLabel,
                ),
                _JobFact(
                  icon: Icons.location_on_outlined,
                  label: 'Plot',
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
                    ? 'Awaiting farmer confirmation from Shamba Bora.'
                    : 'Ready for union verification.',
              ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _showEvidence(context),
              icon: const Icon(Icons.insights_outlined),
              label: const Text('Review work evidence'),
            ),
            if (_canDispatch) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _confirmDispatch(context),
                icon: const Icon(Icons.north_east),
                label: const Text('Dispatch Job'),
              ),
            ],
            if (repository.can('mech.jobs.manage') &&
                job.status == JobStatus.completedPendingConfirmation) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _showVerifyDialog(context),
                icon: const Icon(Icons.verified_outlined),
                label: const Text('Verify completed work'),
              ),
            ],
            if (repository.can('mech.jobs.manage') &&
                job.status == JobStatus.verified) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _confirmClose(context),
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Close verified job'),
              ),
            ],
          ],
        ),
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
                  title: const Text('Reschedule'),
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
                  title: const Text('Dispatch'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmDispatch(context);
                  },
                ),
              if (job.status == JobStatus.completedPendingConfirmation ||
                  job.status == JobStatus.verified)
                ListTile(
                  leading: const Icon(Icons.insights_outlined),
                  title: const Text('Refresh verification'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await repository.refreshJobVerification(job.id);
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
                  title: const Text('Manual farmer confirm'),
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
                  title: const Text('Close job'),
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
                    'Cancel Job',
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
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Dispatch job?',
      message:
          'This will send the assignment to ${job.operator.name} using ${job.tractor.assetNo ?? job.tractor.label ?? job.tractor.model}.',
      confirmLabel: 'Dispatch',
    );
    if (!confirmed) return;
    await repository.dispatchJob(job.id);
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
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, update) => AlertDialog(
          title: const Text('Close verified job'),
          content: DropdownButtonFormField<String>(
            initialValue: payment,
            decoration: const InputDecoration(
              labelText: 'Actual payment status',
            ),
            items: [
              for (final value in ['unpaid', 'deposit', 'paid', 'waived'])
                DropdownMenuItem(value: value, child: Text(value)),
            ],
            onChanged: (value) {
              if (value != null) update(() => payment = value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, payment),
              child: const Text('Close job'),
            ),
          ],
        ),
      ),
    );
    if (selected == null || !context.mounted) return;
    await repository.closeJob(job.id, paymentStatus: selected);
    if (!context.mounted) return;
    await _showActionResult(
      context,
      successTitle: 'Job closed',
      successMessage: 'Job finalised with payment status: $selected.',
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Cancel this job?',
      message:
          'The assignment will be cancelled and the operator will no longer continue this job.',
      confirmLabel: 'Cancel Job',
      danger: true,
    );
    if (confirmed) {
      await repository.cancelJob(
        jobId: job.id,
        reason: JobCancellationReason.other,
        notes: '',
      );
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
        title: const Text('Flag Job'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Reason',
            hintText: 'Acreage looks inflated',
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
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Flag this job?',
      message:
          'The job will be marked for review and the reason will be visible to operations staff.',
      confirmLabel: 'Flag Job',
      danger: true,
    );
    if (confirmed) {
      await repository.flagJob(jobId: job.id, reason: reason);
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
        title: const Text('Clear Flag'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Note',
            hintText: 'Re-measured with the farmer',
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
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Clear job flag?',
      message:
          'Confirm that the flagged concern has been reviewed and resolved.',
      confirmLabel: 'Clear Flag',
    );
    if (confirmed) {
      await repository.unflagJob(jobId: job.id, note: note);
      if (!context.mounted) return;
      await _showActionResult(
        context,
        successTitle: 'Flag cleared',
        successMessage: 'The review concern has been marked as resolved.',
      );
    }
  }

  Future<void> _showEvidence(BuildContext context) async {
    await repository.refreshJobDetail(job.id);
    if (!context.mounted) return;
    final detail = repository.maybeJobById(job.id);
    if (detail == null) return;
    if (repository.mechanizationActionError != null) {
      await showAppErrorDialog(
        context,
        title: 'Could not load job',
        message: repository.mechanizationActionError!,
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Work evidence'),
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
                const Text('No tracker analysis is available yet.'),
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
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showVerifyDialog(BuildContext context) async {
    await repository.refreshJobDetail(job.id);
    if (!context.mounted) return;
    if (repository.mechanizationActionError != null) {
      await showAppErrorDialog(
        context,
        title: 'Could not load evidence',
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
        title: 'Farmer confirmation required',
        message:
            'Wait for the farmer to confirm in Shamba Bora, then refresh this job. An authorised union officer may also record a confirmation received by phone or at the office.',
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
        title: const Text('Verify Job'),
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
                decoration: const InputDecoration(
                  labelText: 'Verified acres',
                  hintText: '4.5',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Add verification note',
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
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Verify completed work?',
      message:
          'Confirm ${input.verifiedAcres} verified acres. This value will be used for the final job record and charge.',
      confirmLabel: 'Verify',
    );
    if (!confirmed) return;
    await repository.verifyJob(
      jobId: job.id,
      verifiedAcres: input.verifiedAcres,
      note: input.note.isEmpty ? null : input.note,
    );
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
          title: const Text('Manual Farmer Confirm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: rating,
                decoration: const InputDecoration(labelText: 'Rating'),
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
                title: const Text('Farmer disputes this job'),
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
    final confirmed = await showAppConfirmationDialog(
      context,
      title: input.dispute ? 'Record farmer dispute?' : 'Confirm for farmer?',
      message: input.dispute
          ? 'This will record that the farmer disputes the completed work.'
          : 'Confirm that the farmer approved the completed work by phone.',
      confirmLabel: input.dispute ? 'Record Dispute' : 'Confirm',
      danger: input.dispute,
    );
    if (!confirmed) return;
    await repository.confirmJob(
      jobId: job.id,
      rating: input.rating,
      note: input.note.isEmpty ? null : input.note,
      dispute: input.dispute,
    );
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
        title: 'Action not completed',
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
        appBar: AppBar(title: const Text('Job unavailable')),
        body: const Center(
          child: Text('This assignment is no longer available.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reschedule Job'),
        actions: [
          IconButton(
            tooltip: 'Save',
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
                'Date & Time',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _SettingRow(
                    icon: Icons.calendar_month_outlined,
                    title: 'Date',
                    value: formatDate(_selectedAt),
                    onTap: _pickDate,
                  ),
                  const Divider(height: 1),
                  _SettingRow(
                    icon: Icons.schedule,
                    title: 'Time',
                    value: formatTime(_selectedAt),
                    onTap: _pickTime,
                  ),
                  const Divider(height: 1),
                  _SettingRow(
                    icon: Icons.event_note_outlined,
                    title: 'Reason for reschedule',
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
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Reschedule job?',
      message:
          'Move this job to ${formatDate(_selectedAt)} at ${formatTime(_selectedAt)} for ${_reason.label.toLowerCase()}?',
      confirmLabel: 'Reschedule',
    );
    if (!confirmed || !mounted) return;
    await widget.repository.rescheduleJob(
      jobId: job.id,
      newScheduledAt: _selectedAt,
      tractorId: job.tractor.id,
      operatorId: job.operator.id,
      reason: _reason,
      notes: '',
    );
    if (!mounted) return;
    final error = widget.repository.mechanizationActionError;
    if (error != null) {
      await showAppErrorDialog(
        context,
        title: 'Job not rescheduled',
        message: error,
      );
      return;
    }
    await showAppSuccessDialog(
      context,
      title: 'Job rescheduled',
      message:
          'The updated date and time are now shown under Jobs and Schedule.',
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
