import 'package:flutter/material.dart';

import '../../data/repositories/operator_local_repository.dart';
import '../../domain/entities/operator_job.dart';
import '../widgets/operator_widgets.dart';
import 'operator_arrival_screen.dart';
import 'operator_job_detail_screen.dart';
import 'operator_progress_screen.dart';

class OperatorMapScreen extends StatelessWidget {
  const OperatorMapScreen({super.key, required this.repository});

  final OperatorLocalRepository repository;

  @override
  Widget build(BuildContext context) {
    final jobs = repository.dashboardJobs.toList()..sort(_sortJobs);
    final primaryJob = jobs.firstOrNull;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Map',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              OperatorMapCard(
                jobs: jobs,
                showTrack: jobs.any(
                  (job) => job.status == OperatorJobStatus.inProgress,
                ),
                label: 'ASSIGNED JOBS',
              ),
              const SizedBox(height: 14),
              if (primaryJob == null)
                const OperatorCard(
                  child: Text(
                    'No assigned jobs have location information yet.',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                )
              else ...[
                Text(
                  'ASSIGNMENTS ON MAP',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                for (final job in jobs) ...[
                  OperatorCard(
                    onTap: () => _openRelevantScreen(context, job),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.agriculture),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                job.plot.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Align(
                                alignment: Alignment.topRight,
                                child: OperatorStatusPill(
                                  key: ValueKey(
                                    'operator-job-status-${job.id}',
                                  ),
                                  status: job.status,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${job.serviceType.label} for ${job.farmerName}'),
                        const SizedBox(height: 4),
                        Text(job.tractorLabel ?? job.tractorId),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openRelevantScreen(BuildContext context, OperatorJob job) {
    Widget screen = OperatorJobDetailScreen(
      repository: repository,
      jobId: job.id,
    );
    if (job.status == OperatorJobStatus.enRoute ||
        job.status == OperatorJobStatus.arrived) {
      screen = OperatorArrivalScreen(repository: repository, jobId: job.id);
    } else if (job.status == OperatorJobStatus.inProgress) {
      screen = OperatorProgressScreen(repository: repository, jobId: job.id);
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
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
}
