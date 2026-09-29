import 'package:flutter/material.dart';

import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../widgets/operator_widgets.dart';

class OperatorHistoryScreen extends StatelessWidget {
  const OperatorHistoryScreen({super.key, required this.repository});

  final OperatorLocalRepository repository;

  @override
  Widget build(BuildContext context) {
    final history = repository.history;
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
                'History',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
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
                      if (job.finishedAt != null)
                        Text('Finished ${formatTime(job.finishedAt!)}'),
                      if (job.areaServicedHectares != null)
                        Text(
                          'Area serviced ${job.areaServicedHectares!.toStringAsFixed(1)} ha',
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
