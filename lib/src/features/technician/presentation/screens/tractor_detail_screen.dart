import 'package:flutter/material.dart';

import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../../manager/data/repositories/union_operations_repository.dart';
import '../../data/repositories/technician_local_repository.dart';
import '../widgets/technician_widgets.dart';
import 'log_maintenance_screen.dart';

class TractorDetailScreen extends StatelessWidget {
  const TractorDetailScreen({
    super.key,
    required this.operationsRepository,
    required this.technicianRepository,
    required this.tractorId,
  });

  final UnionOperationsRepository operationsRepository;
  final TechnicianLocalRepository technicianRepository;
  final String tractorId;

  @override
  Widget build(BuildContext context) {
    final tractor = operationsRepository.tractors.firstWhere(
      (item) => item.id == tractorId,
    );
    final records = technicianRepository.recordsForTractor(tractorId);

    return Scaffold(
      appBar: AppBar(title: Text(tractor.id)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TechnicianCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tractor.model,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _DetailRow(
                        label: 'Status',
                        valueWidget: TractorStatusPill(status: tractor.status),
                      ),
                      _DetailRow(
                        label: 'Operating hours',
                        value: '${tractor.operatingHours} hrs',
                      ),
                      _DetailRow(
                        label: 'Last service',
                        value: formatDate(DateTime(2026, 8, 10)),
                      ),
                      const _DetailRow(
                        label: 'Next service',
                        value: '2,000 hrs',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Maintenance History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                TechnicianCard(
                  child: Column(
                    children: [
                      for (final record in records) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 58,
                              child: Text(
                                record.dateLabel,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(record.workPerformed),
                                  Text(
                                    record.type.label,
                                    style: TextStyle(
                                      color: Colors.black.withValues(
                                        alpha: 0.62,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (record != records.last) const Divider(height: 26),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LogMaintenanceScreen(
                        operationsRepository: operationsRepository,
                        technicianRepository: technicianRepository,
                        tractorId: tractor.id,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.edit_note_outlined),
                  label: const Text('Log Maintenance'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, this.value, this.valueWidget});

  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.black.withValues(alpha: 0.62)),
            ),
          ),
          valueWidget ??
              Text(value!, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
