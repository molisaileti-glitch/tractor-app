import 'package:flutter/material.dart';

import '../../../../components/components.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../../domain/entities/operator_job.dart';
import '../widgets/operator_widgets.dart';
import 'operator_farmer_confirmation_screen.dart';
import 'operator_job_photos_screen.dart';

class OperatorHistoryScreen extends StatelessWidget {
  const OperatorHistoryScreen({super.key, required this.repository});

  final OperatorLocalRepository repository;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final history = repository.pastAssignments;
    return RefreshIndicator(
      onRefresh: () => repository.refreshScreen(OperatorDataScreen.history),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (repository.screenError(OperatorDataScreen.history)
                    case final String error)
                  AppMessage(message: error, type: AppMessageType.warning),
                Text(
                  strings.pastAssignments,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                if (history.isEmpty)
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.55,
                    child: AppEmptyState(
                      icon: Icons.history_toggle_off_outlined,
                      title: strings.noPastAssignments,
                      message: strings.completedJobsAppearHere,
                    ),
                  ),
                for (final job in history) ...[
                  OperatorCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.task_alt),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                job.serviceType.label,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
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
                        const SizedBox(height: 12),
                        Text('${job.farmerName} - ${job.plot.name}'),
                        if (job.status ==
                            OperatorJobStatus.completedPendingConfirmation)
                          Text(
                            job.farmerConfirmedAt == null
                                ? 'Awaiting farmer PIN/SMS confirmation or confirmation from Shamba Bora.'
                                : 'Farmer confirmed. Awaiting union verification.',
                          ),
                        Text(
                          strings.scheduledAt(formatDateTime(job.scheduledAt)),
                        ),
                        if (job.finishedAt != null)
                          Text(strings.finishedAt(formatTime(job.finishedAt!))),
                        if (job.areaServicedHectares != null)
                          Text(
                            strings.areaServiced(
                              job.areaServicedHectares!.toStringAsFixed(1),
                            ),
                          ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            if (job.status ==
                                    OperatorJobStatus
                                        .completedPendingConfirmation &&
                                job.farmerConfirmedAt == null)
                              FilledButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  appPageRoute(
                                    builder: (_) =>
                                        OperatorFarmerConfirmationScreen(
                                          repository: repository,
                                          jobId: job.id,
                                        ),
                                  ),
                                ),
                                icon: const Icon(Icons.verified_user_outlined),
                                label: const Text('Farmer confirmation'),
                              ),
                            if (repository.canAddJobPhotos(job) ||
                                job.photos.isNotEmpty)
                              OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  appPageRoute(
                                    builder: (_) => OperatorJobPhotosScreen(
                                      repository: repository,
                                      jobId: job.id,
                                      initialKind: 'after',
                                    ),
                                  ),
                                ),
                                icon: const Icon(Icons.photo_library_outlined),
                                label: const Text('Job photos'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
