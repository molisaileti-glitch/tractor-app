import 'package:flutter/material.dart';

import '../../../manager/data/repositories/union_operations_repository.dart';
import '../../../manager/domain/entities/operations_models.dart';
import '../../data/repositories/technician_local_repository.dart';
import '../widgets/technician_widgets.dart';
import 'tractor_detail_screen.dart';

class TechnicianTractorsScreen extends StatefulWidget {
  const TechnicianTractorsScreen({
    super.key,
    required this.operationsRepository,
    required this.technicianRepository,
  });

  final UnionOperationsRepository operationsRepository;
  final TechnicianLocalRepository technicianRepository;

  @override
  State<TechnicianTractorsScreen> createState() =>
      _TechnicianTractorsScreenState();
}

class _TechnicianTractorsScreenState extends State<TechnicianTractorsScreen> {
  TractorStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final tractors = widget.operationsRepository.tractors
        .where((tractor) => _filter == null || tractor.status == _filter)
        .toList();

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
                'Tractors',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                  ChoiceChip(
                    label: const Text('Operational'),
                    selected: _filter == TractorStatus.available,
                    onSelected: (_) =>
                        setState(() => _filter = TractorStatus.available),
                  ),
                  ChoiceChip(
                    label: const Text('Maintenance'),
                    selected: _filter == TractorStatus.underMaintenance,
                    onSelected: (_) => setState(
                      () => _filter = TractorStatus.underMaintenance,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Out of Service'),
                    selected: _filter == TractorStatus.outOfService,
                    onSelected: (_) =>
                        setState(() => _filter = TractorStatus.outOfService),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (final tractor in tractors) ...[
                TechnicianCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TractorDetailScreen(
                        operationsRepository: widget.operationsRepository,
                        technicianRepository: widget.technicianRepository,
                        tractorId: tractor.id,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.agriculture),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tractor.id,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            Text(tractor.model),
                            Text('${tractor.operatingHours} operating hours'),
                            if (tractor.note != null) Text(tractor.note!),
                          ],
                        ),
                      ),
                      TractorStatusPill(status: tractor.status),
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
