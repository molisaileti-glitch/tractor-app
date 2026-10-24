import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../components/components.dart';
import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../../domain/entities/operator_job.dart';
import '../widgets/operator_widgets.dart';
import 'operator_complete_job_screen.dart';

class OperatorProgressScreen extends StatefulWidget {
  const OperatorProgressScreen({
    super.key,
    required this.repository,
    required this.jobId,
  });

  final OperatorLocalRepository repository;
  final String jobId;

  @override
  State<OperatorProgressScreen> createState() => _OperatorProgressScreenState();
}

class _OperatorProgressScreenState extends State<OperatorProgressScreen>
    with WidgetsBindingObserver {
  OperatorLocalRepository get repository => widget.repository;
  String get jobId => widget.jobId;
  Timer? _clock;
  Timer? _refresh;
  bool _refreshing = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    repository.addListener(_changed);
    _startTimers();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  void _startTimers() {
    _clock ??= Timer.periodic(const Duration(seconds: 1), (_) => _changed());
    _refresh ??= Timer.periodic(
      const Duration(seconds: 12),
      (_) => unawaited(_refreshWork()),
    );
    unawaited(_refreshWork());
  }

  Future<void> _refreshWork() async {
    if (_refreshing || _busy) return;
    _refreshing = true;
    try {
      await repository.refreshWorkProgress(jobId);
    } finally {
      _refreshing = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTimers();
    } else {
      _clock?.cancel();
      _refresh?.cancel();
      _clock = null;
      _refresh = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    repository.removeListener(_changed);
    _clock?.cancel();
    _refresh?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final job = repository.maybeJobById(jobId);
    if (job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job unavailable')),
        body: const Center(
          child: Text('This assignment is no longer available.'),
        ),
      );
    }
    final duration = job.workDuration;
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
                      Expanded(
                        child: _Metric(
                          label: 'Duration',
                          value: duration == null
                              ? 'Pending'
                              : _formatDuration(duration),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                OperatorMapCard(job: job, showTrack: true, label: 'WORK TRACK'),
                const SizedBox(height: 14),
                OperatorCard(
                  child: Row(
                    children: [
                      const Icon(Icons.gps_fixed),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          job.geofenceVerified
                              ? 'Start location verified'
                              : 'Start location was not geofence verified',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (job.status == OperatorJobStatus.inProgress) ...[
                  OutlinedButton.icon(
                    onPressed: _busy ? null : () => _pause(context, job),
                    icon: const Icon(Icons.pause_circle_outline),
                    label: const Text('Pause'),
                  ),
                  const SizedBox(height: 10),
                ],
                if (job.status == OperatorJobStatus.paused) ...[
                  OutlinedButton.icon(
                    onPressed: _busy ? null : () => _resume(context, job),
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Resume'),
                  ),
                  const SizedBox(height: 10),
                ],
                OutlinedButton.icon(
                  onPressed: () => _showProblemDialog(context, job),
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Report Problem'),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed:
                      _busy ||
                          (job.status != OperatorJobStatus.inProgress &&
                              job.status != OperatorJobStatus.paused)
                      ? null
                      : () => Navigator.of(context).push(
                          appPageRoute(
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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Future<void> _pause(BuildContext context, OperatorJob job) async {
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Pause work?',
      message: 'Work time for this job will be paused until you resume.',
      confirmLabel: 'Pause',
    );
    if (!confirmed || !context.mounted) return;
    setState(() => _busy = true);
    final phone = await repository.captureFieldLocation();
    final ok = await repository.pauseJob(
      jobId: job.id,
      reason: 'Paused',
      phone: phone,
    );
    if (mounted) setState(() => _busy = false);
    if (!context.mounted) return;
    showAppSnackBar(
      context,
      message: ok
          ? 'Work paused. Use Resume when you are ready to continue.'
          : repository.lastActionError ?? 'Pause failed.',
      type: ok ? AppSnackType.success : AppSnackType.error,
    );
  }

  Future<void> _resume(BuildContext context, OperatorJob job) async {
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Resume work?',
      message: 'Work time will continue for this job.',
      confirmLabel: 'Resume',
    );
    if (!confirmed || !context.mounted) return;
    setState(() => _busy = true);
    final phone = await repository.captureFieldLocation();
    final ok = await repository.resumeJob(job.id, phone: phone);
    if (mounted) setState(() => _busy = false);
    if (!context.mounted) return;
    showAppSnackBar(
      context,
      message: ok
          ? 'Work resumed. Continue the service and end the job when complete.'
          : repository.lastActionError ?? 'Resume failed.',
      type: ok ? AppSnackType.success : AppSnackType.error,
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
                final ok = await repository.reportProblem(
                  jobId: job.id,
                  reason: reason,
                  notes: notesController.text.trim(),
                );
                if (!screenContext.mounted) return;
                Navigator.of(context).pop();
                showAppSnackBar(
                  screenContext,
                  message: ok
                      ? 'Problem sent to operations for review.'
                      : repository.lastActionError ??
                            'Could not report problem.',
                  type: ok ? AppSnackType.success : AppSnackType.error,
                );
              },
            ),
          ],
        ),
      ),
    ).whenComplete(() => disposeAppDialogController(notesController));
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
