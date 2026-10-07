import 'package:flutter/material.dart';

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

  bool get _canDispatch => job.status == JobStatus.scheduled;
  bool get _canManage =>
      job.status == JobStatus.scheduled ||
      job.status == JobStatus.dispatched ||
      job.status == JobStatus.enRoute ||
      job.status == JobStatus.arrived ||
      job.status == JobStatus.inProgress ||
      job.status == JobStatus.flagged;

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
            if (_canDispatch) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => repository.dispatchJob(job.id),
                icon: const Icon(Icons.north_east),
                label: const Text('Dispatch Job'),
              ),
            ],
            if (job.status == JobStatus.completedPendingConfirmation) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showVerifyDialog(context),
                      icon: const Icon(Icons.verified_outlined),
                      label: const Text('Verify'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => repository.closeJob(job.id),
                      icon: const Icon(Icons.fact_check_outlined),
                      label: const Text('Close'),
                    ),
                  ),
                ],
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
              ListTile(
                leading: const Icon(Icons.event_repeat_outlined),
                title: const Text('Reschedule'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RescheduleJobScreen(
                        repository: repository,
                        jobId: job.id,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.north_east),
                title: const Text('Dispatch / reassign'),
                onTap: () {
                  Navigator.of(context).pop();
                  repository.dispatchJob(job.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.insights_outlined),
                title: const Text('Refresh verification'),
                onTap: () {
                  Navigator.of(context).pop();
                  repository.refreshJobVerification(job.id);
                },
              ),
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
              ListTile(
                leading: const Icon(Icons.task_alt_outlined),
                title: const Text('Close as paid'),
                onTap: () {
                  Navigator.of(context).pop();
                  repository.closeJob(job.id);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.cancel_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Cancel Job',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  repository.cancelJob(
                    jobId: job.id,
                    reason: JobCancellationReason.other,
                    notes: '',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Flag'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null || reason.isEmpty) return;
    repository.flagJob(jobId: job.id, reason: reason);
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (note == null || note.isEmpty) return;
    repository.unflagJob(jobId: job.id, note: note);
  }

  Future<void> _showVerifyDialog(BuildContext context) async {
    final acresController = TextEditingController(
      text: (job.plot.areaHectares / 0.404686).toStringAsFixed(2),
    );
    final noteController = TextEditingController();
    final input = await showDialog<_VerifyJobInput>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Verify Job'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final acres = num.tryParse(acresController.text.trim());
              if (acres == null || acres <= 0) return;
              Navigator.of(context).pop(
                _VerifyJobInput(
                  verifiedAcres: acres,
                  note: noteController.text.trim(),
                ),
              );
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
    acresController.dispose();
    noteController.dispose();
    if (input == null) return;
    repository.verifyJob(
      jobId: job.id,
      verifiedAcres: input.verifiedAcres,
      note: input.note.isEmpty ? null : input.note,
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
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text('$value'),
                      ),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
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
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
    noteController.dispose();
    if (input == null) return;
    repository.confirmJob(
      jobId: job.id,
      rating: input.rating,
      note: input.note.isEmpty ? null : input.note,
      dispute: input.dispute,
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
    _selectedAt = widget.repository.jobById(widget.jobId).scheduledAt;
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.repository.jobById(widget.jobId);
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
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
                  color: Colors.black.withValues(alpha: 0.55),
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

  void _save(OperationsJob job) {
    widget.repository.rescheduleJob(
      jobId: job.id,
      newScheduledAt: _selectedAt,
      tractorId: job.tractor.id,
      operatorId: job.operator.id,
      reason: _reason,
      notes: '',
    );
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
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
      leading: Icon(icon, color: Colors.black45),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
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
