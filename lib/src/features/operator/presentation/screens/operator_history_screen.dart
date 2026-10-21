import 'package:flutter/material.dart';

import '../../../../components/components.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../widgets/operator_widgets.dart';

class OperatorHistoryScreen extends StatelessWidget {
  const OperatorHistoryScreen({super.key, required this.repository});

  final OperatorLocalRepository repository;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final history = repository.pastAssignments;
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
                          OperatorStatusPill(status: job.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('${job.farmerName} - ${job.plot.name}'),
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
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
