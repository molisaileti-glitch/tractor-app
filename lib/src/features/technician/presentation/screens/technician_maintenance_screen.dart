import 'package:flutter/material.dart';

import '../../../manager/data/repositories/union_operations_repository.dart';
import '../../data/repositories/technician_local_repository.dart';
import '../widgets/technician_widgets.dart';

class TechnicianMaintenanceScreen extends StatelessWidget {
  const TechnicianMaintenanceScreen({
    super.key,
    required this.operationsRepository,
    required this.technicianRepository,
  });

  final UnionOperationsRepository operationsRepository;
  final TechnicianLocalRepository technicianRepository;

  @override
  Widget build(BuildContext context) {
    final records = technicianRepository.records;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Maintenance',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              for (final record in records) ...[
                TechnicianCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.build_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${record.tractorId} - ${record.type.label}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            Text(record.workPerformed),
                            Text(record.dateLabel),
                          ],
                        ),
                      ),
                      Text(
                        record.status.label,
                        style: const TextStyle(fontWeight: FontWeight.w900),
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
