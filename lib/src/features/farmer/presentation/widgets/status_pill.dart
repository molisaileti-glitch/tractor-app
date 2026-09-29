import 'package:flutter/material.dart';

import '../../domain/entities/service_request.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  IconData get _icon {
    return switch (status) {
      RequestStatus.awaitingApproval => Icons.hourglass_bottom,
      RequestStatus.approved => Icons.check_circle_outline,
      RequestStatus.tractorScheduled => Icons.event_available,
      RequestStatus.operatorDispatched => Icons.navigation,
      RequestStatus.workStarted => Icons.play_circle_outline,
      RequestStatus.completed => Icons.task_alt,
      RequestStatus.confirmed => Icons.verified,
      RequestStatus.disputed => Icons.report_problem_outlined,
    };
  }

  Color _color(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (status) {
      RequestStatus.awaitingApproval => const Color(0xFF9A6B00),
      RequestStatus.approved => scheme.primary,
      RequestStatus.tractorScheduled => scheme.tertiary,
      RequestStatus.operatorDispatched => scheme.tertiary,
      RequestStatus.workStarted => const Color(0xFF7B4BD2),
      RequestStatus.completed => scheme.primary,
      RequestStatus.confirmed => scheme.primary,
      RequestStatus.disputed => scheme.error,
    };
  }
}
