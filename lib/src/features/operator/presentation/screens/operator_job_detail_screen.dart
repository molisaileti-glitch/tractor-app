import 'package:flutter/material.dart';

import '../../../../components/components.dart';
import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../../domain/entities/operator_job.dart';
import '../widgets/operator_widgets.dart';
import '../widgets/operator_live_job_map.dart';
import 'operator_arrival_screen.dart';
import 'operator_progress_screen.dart';
import 'operator_job_photos_screen.dart';
import 'operator_farmer_confirmation_screen.dart';

class OperatorJobDetailScreen extends StatefulWidget {
  const OperatorJobDetailScreen({
    super.key,
    required this.repository,
    required this.jobId,
  });

  final OperatorLocalRepository repository;
  final String jobId;

  @override
  State<OperatorJobDetailScreen> createState() =>
      _OperatorJobDetailScreenState();
}

class _OperatorJobDetailScreenState extends State<OperatorJobDetailScreen> {
  OperatorLocalRepository get repository => widget.repository;
  String get jobId => widget.jobId;
  final _mapKey = GlobalKey<OperatorLiveJobMapState>();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        final job = repository.maybeJobById(jobId);
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
          body: Stack(
            children: [
              Positioned.fill(
                child: OperatorLiveJobMap(
                  key: _mapKey,
                  repository: repository,
                  jobId: job.id,
                  fill: true,
                  refreshOnOpen: false,
                  refreshPath:
                      job.status == OperatorJobStatus.inProgress ||
                      job.status == OperatorJobStatus.paused,
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
                      IconButton.filledTonal(
                        tooltip: context.appText('Refresh this job'),
                        onPressed: () => _mapKey.currentState?.refresh(),
                        icon: const Icon(Icons.refresh),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
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
                    onPhotos:
                        repository.canAddJobPhotos(job) || job.photos.isNotEmpty
                        ? () => Navigator.of(context).push(
                            appPageRoute(
                              builder: (_) => OperatorJobPhotosScreen(
                                repository: repository,
                                jobId: job.id,
                                initialKind: job.isCompletedWork
                                    ? 'after'
                                    : (job.status ==
                                              OperatorJobStatus.inProgress ||
                                          job.status ==
                                              OperatorJobStatus.paused)
                                    ? 'during'
                                    : 'before',
                              ),
                            ),
                          )
                        : null,
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
    if (job.status == OperatorJobStatus.completedPendingConfirmation &&
        job.farmerConfirmedAt == null) {
      Navigator.of(context).push(
        appPageRoute(
          builder: (_) => OperatorFarmerConfirmationScreen(
            repository: repository,
            jobId: job.id,
          ),
        ),
      );
      return;
    }
    if ((job.status == OperatorJobStatus.dispatched ||
            job.status == OperatorJobStatus.assigned) &&
        !job.acceptedByOperator) {
      _acceptAssignment(context, job);
      return;
    }
    if (job.status == OperatorJobStatus.inProgress ||
        job.status == OperatorJobStatus.paused) {
      Navigator.of(context).push(
        appPageRoute(
          builder: (_) =>
              OperatorProgressScreen(repository: repository, jobId: job.id),
        ),
      );
      return;
    }
    if (job.status == OperatorJobStatus.enRoute ||
        job.status == OperatorJobStatus.arrived) {
      Navigator.of(context).push(
        appPageRoute(
          builder: (_) =>
              OperatorArrivalScreen(repository: repository, jobId: job.id),
        ),
      );
      return;
    }
    if (job.status == OperatorJobStatus.dispatched ||
        job.status == OperatorJobStatus.assigned) {
      _startJourney(context, job);
      return;
    }
    if (job.status == OperatorJobStatus.scheduled) {
      showAppSnackBar(
        context,
        message: context.appText(
          'This job is scheduled but has not been dispatched. It will become actionable after operations dispatches it.',
        ),
        type: AppSnackType.info,
      );
    }
  }

  Future<void> _acceptAssignment(BuildContext context, OperatorJob job) async {
    final confirmed = await showAppConfirmationDialog(
      context,
      title: context.appText('Accept assignment?'),
      message:
          'Confirm that you are available to operate ${job.tractorLabel ?? 'the assigned tractor'} for this job.',
      confirmLabel: 'Accept',
    );
    if (!confirmed || !context.mounted) return;
    final phone = await repository.captureFieldLocation();
    final ok = await repository.acceptAssignment(job.id, phone: phone);
    if (!context.mounted) return;
    showAppSnackBar(
      context,
      message: ok
          ? 'Assignment accepted. Start the journey from this job when ready.'
          : repository.lastActionError ?? 'Accept failed.',
      type: ok ? AppSnackType.success : AppSnackType.error,
    );
  }

  Future<void> _startJourney(BuildContext context, OperatorJob job) async {
    final confirmed = await showAppConfirmationDialog(
      context,
      title: context.appText('Start journey?'),
      message: context.appText(
        'Your assignment will be marked en route and navigation to the farm will begin.',
      ),
      confirmLabel: 'Start Journey',
    );
    if (!confirmed || !context.mounted) return;
    final navigator = Navigator.of(context);
    final phone = await repository.captureFieldLocation();
    final ok = await repository.startJourney(job.id, phone: phone);
    if (!context.mounted) return;
    if (!ok) {
      showAppSnackBar(
        context,
        message: repository.lastActionError ?? 'Could not start the journey.',
        type: AppSnackType.error,
      );
      return;
    }
    navigator.pushReplacement(
      appPageRoute(
        builder: (_) =>
            OperatorArrivalScreen(repository: repository, jobId: job.id),
      ),
    );
  }

  void _showProblemDialog(BuildContext context, OperatorJob job) {
    final screenContext = context;
    var reason = OperatorProblemReason.tractorBreakdown;
    var submitting = false;
    final notesController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.appText('Unable to Perform Job')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<OperatorProblemReason>(
                  initialValue: reason,
                  decoration: InputDecoration(
                    labelText: context.appText('Reason'),
                  ),
                  items: [
                    for (final item in OperatorProblemReason.values)
                      DropdownMenuItem(value: item, child: Text(item.label)),
                  ],
                  onChanged: submitting
                      ? null
                      : (value) {
                          if (value != null) setState(() => reason = value);
                        },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  enabled: !submitting,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: context.appText('Notes'),
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          actions: [
            AppDialogActions(
              onCancel: () => Navigator.of(context).pop(),
              onConfirm: () async {
                if (submitting) return;
                setState(() => submitting = true);
                final ok = await repository.reportProblem(
                  jobId: job.id,
                  reason: reason,
                  notes: notesController.text.trim(),
                );
                if (!screenContext.mounted || !context.mounted) return;
                if (ok) Navigator.of(context).pop();
                showAppSnackBar(
                  screenContext,
                  message: ok
                      ? 'Problem sent to operations for review.'
                      : repository.lastActionError ??
                            'Could not report problem.',
                  type: ok ? AppSnackType.success : AppSnackType.error,
                );
                if (!ok && context.mounted) {
                  setState(() => submitting = false);
                }
              },
              loading: submitting,
              confirmLabel: submitting ? 'Sending...' : 'Submit',
            ),
          ],
        ),
      ),
    ).whenComplete(() => disposeAppDialogController(notesController));
  }
}

class _JobActionSheet extends StatelessWidget {
  const _JobActionSheet({
    required this.job,
    required this.onStartJourney,
    required this.onReportProblem,
    required this.onPhotos,
  });

  final OperatorJob job;
  final VoidCallback onStartJourney;
  final VoidCallback onReportProblem;
  final VoidCallback? onPhotos;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              OperatorCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
              ),
              const SizedBox(height: 14),
              if (job.plot.boundaryPoints.isEmpty)
                Text(
                  context.appText(
                    'Farm coordinates are unavailable. Ask the union to check the plot location.',
                  ),
                ),
              if (onPhotos != null)
                OutlinedButton.icon(
                  onPressed: onPhotos,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(context.appText('Job photos')),
                ),
              const SizedBox(height: 8),
              if (_statusGuidance(job) case final String guidance)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(guidance),
                ),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _statusGuidance(job) == null
                          ? onStartJourney
                          : null,
                      icon: const Icon(Icons.route_outlined),
                      label: Text(_primaryActionLabel(job)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    tooltip: context.appText('Report Problem'),
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
      OperatorJobStatus.paused => 'Resume Work',
      OperatorJobStatus.scheduled => 'Awaiting Dispatch',
      OperatorJobStatus.completedPendingConfirmation =>
        job.farmerConfirmedAt == null
            ? 'Farmer confirmation'
            : 'Awaiting verification',
      OperatorJobStatus.verified => 'Verified',
      OperatorJobStatus.closed => 'Closed',
      OperatorJobStatus.cancelled => 'Cancelled',
      OperatorJobStatus.flagged => 'Under review',
    };
  }

  String? _statusGuidance(OperatorJob job) => switch (job.status) {
    OperatorJobStatus.scheduled =>
      'The union must dispatch this job before you can accept it.',
    OperatorJobStatus.completedPendingConfirmation
        when job.farmerConfirmedAt != null =>
      'Farmer confirmation is recorded. The union will review and verify the work.',
    OperatorJobStatus.verified =>
      'The union has verified the work. Awaiting job closure.',
    OperatorJobStatus.closed =>
      'This job is closed. You can review its photos.',
    OperatorJobStatus.cancelled =>
      'This job was cancelled. Contact the union for another assignment.',
    OperatorJobStatus.flagged =>
      'This job needs review. Contact the union before continuing.',
    _ => null,
  };
}
