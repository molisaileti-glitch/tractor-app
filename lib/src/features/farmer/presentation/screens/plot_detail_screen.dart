import 'package:flutter/material.dart';

import '../../data/repositories/farmer_local_repository.dart';
import '../widgets/farm_map_card.dart';
import '../widgets/farmer_scaffold.dart';
import 'request_service_flow.dart';

class PlotDetailScreen extends StatelessWidget {
  const PlotDetailScreen({
    super.key,
    required this.repository,
    required this.plotId,
  });

  final FarmerLocalRepository repository;
  final String plotId;

  @override
  Widget build(BuildContext context) {
    final plot = repository.plotById(plotId);
    return FarmerPage(
      title: plot.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FarmMapCard(pointCount: plot.boundaryPoints.length),
          const SizedBox(height: 22),
          _DetailRow(label: 'Area', value: '${plot.areaHectares} hectares'),
          _DetailRow(label: 'Location', value: plot.location),
          _DetailRow(
            label: 'Coordinates',
            value: plot.boundaryRegistered
                ? 'Registered'
                : 'Boundary not registered',
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RequestServiceFlow(
                  repository: repository,
                  initialPlotId: plot.id,
                ),
              ),
            ),
            icon: const Icon(Icons.agriculture),
            label: const Text('Request Service for this Plot'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.black.withValues(alpha: 0.58),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
