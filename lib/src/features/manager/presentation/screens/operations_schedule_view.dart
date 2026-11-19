// File purpose: Implements the union manager operations schedule screen and connects user actions to feature state.

import 'package:flutter/material.dart';

import '../../../../components/components.dart';
import '../../../../components/job_schedule_calendar.dart';
import '../../data/repositories/union_operations_repository.dart';
import '../widgets/operations_widgets.dart';
import 'operations_jobs_view.dart';

class OperationsScheduleView extends StatelessWidget {
  const OperationsScheduleView({super.key, required this.repository});

  final UnionOperationsRepository repository;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) => JobScheduleCalendar(
        assignments: [
          for (final job in repository.scheduleJobs)
            ScheduleAssignment(
              id: job.id,
              reference: operationsDisplayLabel(
                job.reference,
                fallback: context.appText('Job'),
              ),
              start: job.scheduledAt,
              end:
                  job.scheduledEndAt ??
                  job.scheduledAt.add(
                    Duration(hours: job.estimatedHours.clamp(1, 24)),
                  ),
              title:
                  '${job.serviceType.label} - ${operationsDisplayLabel(job.farmerName, fallback: context.appText('Farmer'))}',
              details: [
                operationsDisplayLabel(
                  job.plot.name,
                  fallback: context.appText('Farm plot'),
                ),
                operationsDisplayLabel(
                  job.tractor.assetNo ?? job.tractor.label ?? job.tractor.model,
                  fallback: context.appText('Tractor'),
                ),
                operationsDisplayLabel(
                  job.operator.name,
                  fallback: context.appText('Operator'),
                ),
              ],
              status: job.status.label,
              statusKey: job.status.name,
              color: scheduleStatusColor(
                job.status.name,
                Theme.of(context).colorScheme,
              ),
              onOpen: () => _openJob(context, job.id),
            ),
        ],
      ),
    );
  }

  Future<void> _openJob(BuildContext context, String id) async {
    await repository.refreshJobDetail(id);
    if (!context.mounted) return;
    if (repository.mechanizationActionError != null ||
        repository.maybeJobById(id) == null) {
      showAppSnackBar(
        context,
        message:
            repository.mechanizationActionError ??
            'This job is no longer available. Refresh the schedule.',
        type: AppSnackType.error,
      );
      return;
    }
    Navigator.of(context).push(
      appPageRoute(
        builder: (_) =>
            OperationsJobDetailScreen(repository: repository, jobId: id),
      ),
    );
  }
}
