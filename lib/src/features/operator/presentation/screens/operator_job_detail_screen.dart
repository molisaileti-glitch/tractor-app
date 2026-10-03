import 'package:flutter/material.dart';

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
    final job = repository.jobById(jobId);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color(0xFFDCE9DF),
              child: CustomPaint(painter: _OperatorMapPainter()),
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
          DraggableScrollableSheet(
            initialChildSize: 0.34,
            minChildSize: 0.20,
            maxChildSize: 0.72,
            snap: true,
            snapSizes: const [0.20, 0.34, 0.72],
            builder: (context, scrollController) {
              return _JobActionSheet(
                job: job,
                scrollController: scrollController,
                onStartJourney: () => _advance(context, job),
                onReportProblem: () => _showProblemDialog(context, job),
              );
            },
          ),
        ],
      ),
    );
  }

  void _advance(BuildContext context, OperatorJob job) {
    if (job.status == OperatorJobStatus.inProgress) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              OperatorProgressScreen(repository: repository, jobId: job.id),
        ),
      );
      return;
    }
    _startJourney(context, job);
  }

  Future<void> _startJourney(BuildContext context, OperatorJob job) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final accepted = job.status == OperatorJobStatus.dispatched
        ? await repository.acceptAssignment(job.id)
        : true;
    if (!accepted) {
      messenger.showSnackBar(
        SnackBar(content: Text(repository.lastActionError ?? 'Accept failed.')),
      );
      return;
    }
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
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
              child: const Text('Submit'),
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
    required this.scrollController,
    required this.onStartJourney,
    required this.onReportProblem,
  });

  final OperatorJob job;
  final ScrollController scrollController;
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
          controller: scrollController,
          child: Column(
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
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
                            job.serviceType.label,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            '${job.farmerName} - ${formatTime(job.scheduledAt)}',
                          ),
                          Text(job.plot.name),
                        ],
                      ),
                    ),
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
                      label: const Text('Start Journey'),
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
}

class _OperatorMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final y = size.height * (0.12 + i * 0.14);
      canvas.drawLine(
        Offset(size.width * 0.05, y),
        Offset(size.width * 0.95, y + size.height * 0.08),
        road,
      );
    }
    final route = Paint()
      ..color = const Color(0xFF2F6F4E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.24)
      ..lineTo(size.width * 0.42, size.height * 0.36)
      ..lineTo(size.width * 0.55, size.height * 0.52)
      ..lineTo(size.width * 0.76, size.height * 0.60);
    canvas.drawPath(path, route);
    final marker = Paint()..color = const Color(0xFF2F6F4E);
    canvas.drawCircle(
      Offset(size.width * 0.76, size.height * 0.60),
      12,
      marker,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
