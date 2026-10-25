import 'package:flutter/material.dart';

import '../../../../components/components.dart';
import '../../../../components/job_schedule_calendar.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../../domain/entities/operator_job.dart';
import 'operator_job_detail_screen.dart';

class OperatorScheduleScreen extends StatelessWidget {
  const OperatorScheduleScreen({super.key, required this.repository});

  final OperatorLocalRepository repository;

  @override
  Widget build(BuildContext context) {
    final jobs = repository.scheduleJobs.toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final today = DateUtils.dateOnly(DateTime.now());
    final upcoming = jobs.where(
      (job) => !job.isComplete && !job.scheduledAt.isBefore(today),
    );
    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) => RefreshIndicator(
        onRefresh: () => repository.refreshScreen(OperatorDataScreen.schedule),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (repository.screenError(OperatorDataScreen.schedule) !=
                      null) ...[
                    AppMessage(
                      message: repository.screenError(
                        OperatorDataScreen.schedule,
                      )!,
                      type: AppMessageType.warning,
                    ),
                    const SizedBox(height: 12),
                  ],
                  JobScheduleCalendar(
                    initialDate: upcoming.firstOrNull?.scheduledAt ?? today,
                    assignments: [
                      for (final job in repository.scheduleJobs)
                        ScheduleAssignment(
                          id: job.id,
                          reference: job.reference ?? job.id,
                          start: job.scheduledAt,
                          end:
                              job.scheduledEndAt ??
                              job.scheduledAt.add(const Duration(hours: 1)),
                          title: '${job.serviceType.label} - ${job.farmerName}',
                          details: [
                            job.plot.name,
                            job.tractorLabel ?? job.tractorId,
                          ],
                          status: job.status.label,
                          statusKey: job.status.name,
                          color: scheduleStatusColor(
                            job.status.name,
                            Theme.of(context).colorScheme,
                          ),
                          onOpen: () => _openJob(context, job),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openJob(BuildContext context, OperatorJob job) async {
    final loaded = await repository.refreshJobDetail(job.id);
    if (!context.mounted) return;
    if (!loaded) {
      showAppSnackBar(
        context,
        message:
            repository.lastActionError ??
            'This assignment is no longer available. Refresh the schedule.',
        type: AppSnackType.error,
      );
      return;
    }
    Navigator.of(context).push(
      appPageRoute(
        builder: (_) =>
            OperatorJobDetailScreen(repository: repository, jobId: job.id),
      ),
    );
  }
}
