import 'package:flutter/material.dart';

import '../../../manager/domain/entities/operations_models.dart';

class TechnicianCard extends StatelessWidget {
  const TechnicianCard({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: card,
    );
  }
}

class TractorStatusPill extends StatelessWidget {
  const TractorStatusPill({super.key, required this.status});

  final TractorStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      TractorStatus.available => Theme.of(context).colorScheme.primary,
      TractorStatus.scheduled => const Color(0xFF9A6B00),
      TractorStatus.underMaintenance => Theme.of(context).colorScheme.secondary,
      TractorStatus.outOfService => Theme.of(context).colorScheme.error,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class TechnicianMetricCard extends StatelessWidget {
  const TechnicianMetricCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TechnicianCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.12),
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(label),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
