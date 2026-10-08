import 'package:flutter/material.dart';

import '../../../../core/presentation/components/components.dart';
import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../../domain/entities/operator_job.dart';
import '../widgets/operator_widgets.dart';
import 'operator_arrival_screen.dart';
import 'operator_progress_screen.dart';

class OperatorJobDetailScreen extends StatelessWidget {
  const OperatorJobDetailScreen({
    super.key,
    required this.repository,
    required this.jobId,
  });

  final OperatorLocalRepository repository;
  final String jobId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        final job = repository.jobById(jobId);
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: OperatorMapCard(
                  job: job,
                  label: 'JOB LOCATION',
                  fill: true,
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            '${job.tractorLabel ?? job.tractorId} - ${job.plot.name}',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 330),
                  child: _JobActionSheet(
                    job: job,
                    onStartJourney: () => _advance(context, job),
                    onReportProblem: () => _showProblemDialog(context, job),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _advance(BuildContext context, OperatorJob job) {
    if ((job.status == OperatorJobStatus.dispatched ||
            job.status == OperatorJobStatus.assigned) &&
        !job.acceptedByOperator) {
      _acceptAssignment(context, job);
      return;
    }
    if (job.status == OperatorJobStatus.inProgress) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              OperatorProgressScreen(repository: repository, jobId: job.id),
        ),
      );
      return;
    }
    if (job.status == OperatorJobStatus.enRoute ||
        job.status == OperatorJobStatus.arrived) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              OperatorArrivalScreen(repository: repository, jobId: job.id),
        ),
      );
      return;
    }
    _startJourney(context, job);
  }

  Future<void> _acceptAssignment(BuildContext context, OperatorJob job) async {
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Accept assignment?',
      message:
          'Confirm that you are available to operate ${job.tractorLabel ?? 'the assigned tractor'} for this job.',
      confirmLabel: 'Accept',
    );
    if (!confirmed || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await repository.acceptAssignment(job.id);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Assignment accepted. You can start the journey when ready.'
              : repository.lastActionError ?? 'Accept failed.',
        ),
      ),
    );
  }

  Future<void> _startJourney(BuildContext context, OperatorJob job) async {
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Start journey?',
      message:
          'Your assignment will be marked en route and navigation to the farm will begin.',
      confirmLabel: 'Start Journey',
    );
    if (!confirmed || !context.mounted) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await repository.startJourney(job.id);
    if (!ok) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(repository.lastActionError ?? 'Could not go en route.'),
        ),
      );
      return;
    }
    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            OperatorArrivalScreen(repository: repository, jobId: job.id),
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
          actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          actions: [
            AppDialogActions(
              onCancel: () => Navigator.of(context).pop(),
              onConfirm: () async {
                final messenger = ScaffoldMessenger.of(screenContext);
                final ok = await repository.reportProblem(
                  jobId: job.id,
                  reason: reason,
                  notes: notesController.text.trim(),
                );
                Navigator.of(context).pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Problem sent to dispatcher for review.'
                          : repository.lastActionError ??
                                'Could not report problem.',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ).whenComplete(notesController.dispose);
  }
}

class _JobActionSheet extends StatelessWidget {
  const _JobActionSheet({
    required this.job,
    required this.onStartJourney,
    required this.onReportProblem,
  });

  final OperatorJob job;
  final VoidCallback onStartJourney;
  final VoidCallback onReportProblem;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              OperatorCard(
                child: Row(
                  children: [
                    const Icon(Icons.agriculture),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.reference ?? job.id,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          Text(
                            job.serviceType.label.toUpperCase(),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            job.timeWindow == null
                                ? '${formatDate(job.scheduledAt)} - ${formatTime(job.scheduledAt)}'
                                : '${formatDate(job.scheduledAt)} - ${job.timeWindow}',
                          ),
                          Text('${job.farmerName} - ${job.plot.name}'),
                          if (job.plannedAcres != null)
                            Text(
                              '${job.plannedAcres!.toStringAsFixed(1)} planned acres',
                            ),
                        ],
                      ),
                    ),
                    OperatorStatusPill(status: job.status),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onStartJourney,
                      icon: const Icon(Icons.route_outlined),
                      label: Text(_primaryActionLabel(job)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    tooltip: 'Report Problem',
                    onPressed: onReportProblem,
                    icon: const Icon(Icons.report_problem_outlined),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _primaryActionLabel(OperatorJob job) {
    return switch (job.status) {
      OperatorJobStatus.dispatched || OperatorJobStatus.assigned =>
        job.acceptedByOperator ? 'Start Journey' : 'Accept Assignment',
      OperatorJobStatus.enRoute => 'Record Arrival',
      OperatorJobStatus.arrived => 'Start Work',
      OperatorJobStatus.inProgress => 'Continue Work',
      OperatorJobStatus.scheduled => 'Open Job',
      OperatorJobStatus.completedPendingConfirmation => 'View Job',
    };
  }
}
