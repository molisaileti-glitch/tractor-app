import 'package:flutter/material.dart';

import '../../domain/entities/operations_models.dart';

class OperationsCard extends StatelessWidget {
  const OperationsCard({super.key, required this.child, this.onTap});

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

class MetricCard extends StatelessWidget {
  const MetricCard({
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
    return OperationsCard(
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

class OperationsSectionTitle extends StatelessWidget {
  const OperationsSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class OperationsStatusChip extends StatelessWidget {
  const OperationsStatusChip.request({super.key, required this.requestStatus})
    : tractorStatus = null,
      operatorStatus = null,
      jobStatus = null;

  const OperationsStatusChip.tractor({super.key, required this.tractorStatus})
    : requestStatus = null,
      operatorStatus = null,
      jobStatus = null;

  const OperationsStatusChip.operator({super.key, required this.operatorStatus})
    : requestStatus = null,
      tractorStatus = null,
      jobStatus = null;

  const OperationsStatusChip.job({super.key, required this.jobStatus})
    : requestStatus = null,
      tractorStatus = null,
      operatorStatus = null;

  final OperationsRequestStatus? requestStatus;
  final TractorStatus? tractorStatus;
  final OperatorStatus? operatorStatus;
  final JobStatus? jobStatus;

  @override
  Widget build(BuildContext context) {
    final label =
        requestStatus?.label ??
        tractorStatus?.label ??
        operatorStatus?.label ??
        jobStatus?.label ??
        '';
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Color _color(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (requestStatus != null) {
      return switch (requestStatus!) {
        OperationsRequestStatus.pending => const Color(0xFF9A6B00),
        OperationsRequestStatus.approved => scheme.primary,
        OperationsRequestStatus.rejected => scheme.error,
        OperationsRequestStatus.scheduled => scheme.tertiary,
        OperationsRequestStatus.cancelled => scheme.error,
      };
    }
    if (tractorStatus != null) {
      return switch (tractorStatus!) {
        TractorStatus.available => scheme.primary,
        TractorStatus.scheduled => const Color(0xFF9A6B00),
        TractorStatus.underMaintenance => scheme.secondary,
        TractorStatus.outOfService => scheme.error,
      };
    }
    if (operatorStatus != null) {
      return switch (operatorStatus!) {
        OperatorStatus.available => scheme.primary,
        OperatorStatus.assigned => const Color(0xFF9A6B00),
        OperatorStatus.unavailable => scheme.error,
      };
    }
    return switch (jobStatus!) {
      JobStatus.scheduled => scheme.tertiary,
      JobStatus.dispatched => const Color(0xFF7B4BD2),
      JobStatus.enRoute => const Color(0xFF7B4BD2),
      JobStatus.inProgress => const Color(0xFF7B4BD2),
      JobStatus.completedPendingConfirmation => const Color(0xFF9A6B00),
      JobStatus.closed => scheme.primary,
      JobStatus.cancelled => scheme.error,
    };
  }
}
