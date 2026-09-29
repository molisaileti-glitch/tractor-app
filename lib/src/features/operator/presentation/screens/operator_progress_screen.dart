import 'package:flutter/material.dart';

import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../../domain/entities/operator_job.dart';
import '../widgets/operator_widgets.dart';
import 'operator_complete_job_screen.dart';

class OperatorProgressScreen extends StatelessWidget {
  const OperatorProgressScreen({
    super.key,
    required this.repository,
    required this.jobId,
  });

  final OperatorLocalRepository repository;
  final String jobId;

  @override
  Widget build(BuildContext context) {
    final job = repository.jobById(jobId);
    return Scaffold(
      appBar: AppBar(title: Text(job.serviceType.label.toUpperCase())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OperatorStatusPill(status: job.status),
                const SizedBox(height: 16),
                OperatorCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: _Metric(
                          label: 'Started',
                          value: job.startedAt == null
                              ? 'Pending'
                              : formatTime(job.startedAt!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: _Metric(label: 'Duration', value: '02:14:32'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const OperatorMapCard(showTrack: true, label: 'WORK TRACK'),
                const SizedBox(height: 14),
                const OperatorCard(
                  child: Row(
                    children: [
                      Icon(Icons.gps_fixed),
                      SizedBox(width: 12),
                      Expanded(child: Text('Current location verified')),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.note_add_outlined),
                  label: const Text('Add Note'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _showProblemDialog(context, job),
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Report Problem'),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OperatorCompleteJobScreen(
                        repository: repository,
                        jobId: job.id,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('End Job'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProblemDialog(BuildContext context, OperatorJob job) {
    final screenContext = context;
    var reason = OperatorProblemReason.tractorBreakdown;
    final notesController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Unable to Perform Job'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<OperatorProblemReason>(
                  initialValue: reason,
                  decoration: const InputDecoration(labelText: 'Reason'),
                  items: [
                    for (final item in OperatorProblemReason.values)
                      DropdownMenuItem(value: item, child: Text(item.label)),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => reason = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                repository.reportProblem(
                  jobId: job.id,
                  reason: reason,
                  notes: notesController.text.trim(),
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(screenContext).showSnackBar(
                  const SnackBar(
                    content: Text('Problem sent to dispatcher for review.'),
                  ),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    ).whenComplete(notesController.dispose);
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
