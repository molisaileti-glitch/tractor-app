import 'package:flutter/material.dart';

import '../../domain/entities/service_request.dart';
import 'farmer_formatters.dart';
import 'farmer_scaffold.dart';
import 'status_pill.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({super.key, required this.item, this.onTap});

  final RequestWithPlot item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final request = item.request;
    final theme = Theme.of(context);
    return InfoCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.secondary.withValues(
                  alpha: 0.15,
                ),
                child: const Icon(Icons.agriculture),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.serviceType.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(item.plot.name),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          StatusPill(status: request.status),
          const SizedBox(height: 12),
          Text(
            request.scheduledAt == null
                ? 'Requested: ${formatShortDate(request.requestedOn)}'
                : formatDateTime(request.scheduledAt!),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black.withValues(alpha: 0.62),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
