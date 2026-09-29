import 'package:flutter/material.dart';

import '../../domain/entities/farm_plot.dart';
import 'farmer_scaffold.dart';

class PlotCard extends StatelessWidget {
  const PlotCard({super.key, required this.plot, this.onTap});

  final FarmPlot plot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InfoCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.12,
                ),
                child: Icon(Icons.grass, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  plot.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
          const SizedBox(height: 14),
          Text('Area: ${plot.areaHectares.toStringAsFixed(1)} hectares'),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18),
              const SizedBox(width: 6),
              Expanded(child: Text(plot.location)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                plot.boundaryRegistered
                    ? Icons.check_circle
                    : Icons.pending_actions,
                size: 18,
                color: plot.boundaryRegistered
                    ? theme.colorScheme.primary
                    : theme.colorScheme.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                plot.boundaryRegistered
                    ? 'Boundary registered'
                    : 'Boundary pending',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
