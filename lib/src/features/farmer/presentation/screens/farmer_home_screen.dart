import 'package:flutter/material.dart';

import '../../data/repositories/farmer_local_repository.dart';
import '../widgets/farmer_formatters.dart';
import '../widgets/farmer_scaffold.dart';
import '../widgets/request_card.dart';
import 'request_details_screen.dart';
import 'request_service_flow.dart';

class FarmerHomeScreen extends StatelessWidget {
  const FarmerHomeScreen({
    super.key,
    required this.repository,
    required this.onOpenPlots,
  });

  final FarmerLocalRepository repository;
  final VoidCallback onOpenPlots;

  @override
  Widget build(BuildContext context) {
    final featured = repository.featuredRequest;
    return FarmerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning, Juma',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    const Text('Manage your tractor services'),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Notifications',
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
              ),
            ],
          ),
          const SizedBox(height: 24),
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.16),
                  child: const Icon(Icons.agriculture, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  'Need tractor service?',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Request ploughing, harrowing or another farm service.',
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          RequestServiceFlow(repository: repository),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Request Service'),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'ACTIVE REQUEST'),
          if (featured == null)
            const InfoCard(child: Text('No active requests right now.'))
          else
            Column(
              children: [
                RequestCard(
                  item: featured,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RequestDetailsScreen(
                        repository: repository,
                        requestId: featured.request.id,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    featured.request.scheduledAt == null
                        ? 'Waiting for union approval'
                        : 'Scheduled: ${formatDateTime(featured.request.scheduledAt!)}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          SectionHeader(
            title: 'My Plots',
            actionLabel: 'View all',
            onAction: onOpenPlots,
          ),
          InfoCard(
            onTap: onOpenPlots,
            child: Row(
              children: [
                const Icon(Icons.map_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${repository.plots.length} registered plots',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
