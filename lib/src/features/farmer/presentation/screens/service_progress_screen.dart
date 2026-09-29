import 'package:flutter/material.dart';

import '../../data/repositories/farmer_local_repository.dart';
import '../widgets/farm_map_card.dart';
import '../widgets/farmer_formatters.dart';
import '../widgets/farmer_scaffold.dart';
import '../widgets/status_pill.dart';

class ServiceProgressScreen extends StatelessWidget {
  const ServiceProgressScreen({
    super.key,
    required this.repository,
    required this.requestId,
  });

  final FarmerLocalRepository repository;
  final String requestId;

  @override
  Widget build(BuildContext context) {
    final request = repository.requestById(requestId);
    final plot = repository.plotById(request.plotId);
    return FarmerPage(
      title: 'Service in Progress',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request.serviceType.label,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(plot.name),
          const SizedBox(height: 18),
          _MetricGrid(
            children: [
              _Metric(
                label: 'Started',
                value: request.startedAt == null
                    ? 'Pending'
                    : formatTime(request.startedAt!),
              ),
              _Metric(
                label: 'Area',
                value: '${plot.areaHectares.toStringAsFixed(1)} hectares',
              ),
              _Metric(
                label: 'Operator',
                value: request.operatorName ?? 'Pending',
              ),
            ],
          ),
          const SizedBox(height: 18),
          FarmMapCard(
            showTractor: true,
            pointCount: plot.boundaryPoints.length,
          ),
          const SizedBox(height: 18),
          StatusPill(status: request.status),
        ],
      ),
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
        final compact = constraints.maxWidth < 520;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: children
              .map(
                (child) => SizedBox(
                  width: compact
                      ? (constraints.maxWidth - 10) / 2
                      : (constraints.maxWidth - 20) / 3,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
