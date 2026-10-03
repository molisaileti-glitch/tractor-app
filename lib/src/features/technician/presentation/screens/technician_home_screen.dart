import 'package:flutter/material.dart';

import '../../../manager/data/repositories/union_operations_repository.dart';
import '../../../manager/domain/entities/operations_models.dart';
import '../../data/repositories/technician_local_repository.dart';
import '../widgets/technician_widgets.dart';

class TechnicianHomeScreen extends StatelessWidget {
  const TechnicianHomeScreen({
    super.key,
    required this.operationsRepository,
    required this.technicianRepository,
  });

  final UnionOperationsRepository operationsRepository;
  final TechnicianLocalRepository technicianRepository;

  @override
  Widget build(BuildContext context) {
    final operational = operationsRepository.tractors
        .where((tractor) => tractor.status == TractorStatus.available)
        .length;
    final maintenance = operationsRepository.maintenanceCount;
    final outOfService = operationsRepository.tractors
        .where((tractor) => tractor.status == TractorStatus.outOfService)
        .length;
    final attention = operationsRepository.tractors
        .where(
          (tractor) =>
              tractor.maintenanceDue.isNotEmpty ||
              tractor.status == TractorStatus.underMaintenance ||
              tractor.status == TractorStatus.outOfService,
        )
        .toList();

    return _TechnicianPage(
      title: 'Technician',
      children: [
        Text(
          'TRACTOR STATUS',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        _MetricGrid(
          children: [
            TechnicianMetricCard(
              value: '$operational',
              label: 'Operational',
              icon: Icons.check_circle_outline,
            ),
            TechnicianMetricCard(
              value: '$maintenance',
              label: 'Maintenance',
              icon: Icons.build_outlined,
            ),
            TechnicianMetricCard(
              value: '$outOfService',
              label: 'Out Service',
              icon: Icons.block,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'ATTENTION REQUIRED',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        TechnicianCard(
          child: Column(
            children: [
              if (attention.isEmpty)
                const _AttentionLine(
                  tractorId: 'All tractors',
                  issue: 'No maintenance due',
                  detail: 'Fleet is ready for dispatch',
                ),
              for (final tractor in attention) ...[
                _AttentionLine(
                  tractorId: tractor.assetNo ?? tractor.id,
                  issue: tractor.maintenanceDue.isEmpty
                      ? tractor.status.label
                      : 'Maintenance due',
                  detail: tractor.maintenanceDue.isEmpty
                      ? tractor.note ?? 'Inspection required before dispatch'
                      : tractor.maintenanceDue.join(', '),
                ),
                if (tractor != attention.last) const Divider(height: 28),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AttentionLine extends StatelessWidget {
  const _AttentionLine({
    required this.tractorId,
    required this.issue,
    required this.detail,
  });

  final String tractorId;
  final String issue;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.warning_amber_outlined,
          color: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tractorId,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              Text(issue),
              Text(
                detail,
                style: TextStyle(color: Colors.black.withValues(alpha: 0.62)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 3 : 1;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class _TechnicianPage extends StatelessWidget {
  const _TechnicianPage({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
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
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
