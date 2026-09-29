import 'package:flutter/material.dart';

import '../../data/repositories/farmer_local_repository.dart';
import '../../domain/entities/service_request.dart';
import '../widgets/farmer_scaffold.dart';
import '../widgets/request_card.dart';
import 'request_details_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key, required this.repository});

  final FarmerLocalRepository repository;

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    final items = _showCompleted
        ? widget.repository.completedRequests
        : widget.repository.activeRequests;

    return FarmerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Requests',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Active')),
              ButtonSegment(value: true, label: Text('Completed')),
            ],
            selected: {_showCompleted},
            onSelectionChanged: (value) {
              setState(() => _showCompleted = value.first);
            },
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            InfoCard(
              child: Text(
                _showCompleted
                    ? 'No completed services yet.'
                    : 'No active requests right now.',
              ),
            )
          else
            for (final item in items) ...[
              RequestCard(item: item, onTap: () => _openDetails(item.request)),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }

  void _openDetails(ServiceRequest request) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RequestDetailsScreen(
          repository: widget.repository,
          requestId: request.id,
        ),
      ),
    );
  }
}
