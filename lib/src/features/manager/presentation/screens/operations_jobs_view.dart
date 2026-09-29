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
        for (final job in repository.jobs) ...[
          _JobCard(repository: repository, job: job),
          const SizedBox(height: 12),
        ],
      ],
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
      job.status == JobStatus.inProgress;

  @override
  Widget build(BuildContext context) {
    return OperationsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.12),
                child: const Icon(Icons.agriculture),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  job.tractor.id,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (_canManage)
                IconButton(
                  tooltip: 'Job actions',
                  onPressed: () => _showActions(context),
                  icon: const Icon(Icons.more_vert),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text('${job.farmerName} · ${job.serviceType.label}')),
              OperationsStatusChip.job(jobStatus: job.status),
            ],
          ),
          const SizedBox(height: 8),
          Text('${job.plot.name} · ${formatDateTime(job.scheduledAt)}'),
          if (job.alert != null) ...[
            const SizedBox(height: 8),
            Text(
              job.alert!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w800,
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
            OutlinedButton.icon(
              onPressed: () => repository.closeJob(job.id),
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Close Job'),
            ),
          ],
        ],
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
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
      backgroundColor: const Color(0xFFF4F4F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                  const Spacer(),
                  Text(
                    'Date & Time',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  IconButton.filled(
                    onPressed: () => _save(job),
                    icon: const Icon(Icons.check),
                  ),
                ],
              ),
              const SizedBox(height: 34),
              Text(
                'Date & Time',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.black45,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
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
                '${job.id} · ${job.farmerName} · ${job.serviceType.label}',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w800,
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
      firstDate: DateTime(2026, 9),
      lastDate: DateTime(2027, 12, 31),
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
        borderRadius: BorderRadius.circular(24),
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
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
