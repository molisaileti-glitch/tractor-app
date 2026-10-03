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
    final job = repository.todayJob;
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
                showTrack: job.status == OperatorJobStatus.inProgress,
                label: job.status == OperatorJobStatus.inProgress
                    ? 'WORK TRACK'
                    : 'FARM LOCATION',
              ),
              const SizedBox(height: 14),
              OperatorCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.plot.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('${job.serviceType.label} for ${job.farmerName}'),
                    const SizedBox(height: 12),
                    OperatorStatusPill(status: job.status),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () => _openRelevantScreen(context, job),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Job'),
              ),
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
}
