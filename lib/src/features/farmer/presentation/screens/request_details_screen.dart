import 'package:flutter/material.dart';

import '../../data/repositories/farmer_local_repository.dart';
import '../../domain/entities/service_request.dart';
import '../widgets/farmer_formatters.dart';
import '../widgets/farmer_scaffold.dart';
import '../widgets/status_pill.dart';
import 'completion_screen.dart';
import 'service_progress_screen.dart';

class RequestDetailsScreen extends StatelessWidget {
  const RequestDetailsScreen({
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
      title: request.serviceType.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plot.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text('Request #${request.id}'),
          const SizedBox(height: 16),
          StatusPill(status: request.status),
          const SizedBox(height: 24),
          InfoCard(
            child: Column(
              children: _timelineItems(
                request.status,
              ).map((item) => _TimelineRow(item: item)).toList(),
            ),
          ),
          if (request.hasAssignment) ...[
            const SectionHeader(title: 'TRACTOR ASSIGNED'),
            InfoCard(
              child: Column(
                children: [
                  _AssignedRow(
                    icon: Icons.agriculture,
                    label: 'Tractor',
                    value: request.tractorCode!,
                  ),
                  _AssignedRow(
                    icon: Icons.engineering_outlined,
                    label: 'Operator',
                    value: request.operatorName!,
                  ),
                  _AssignedRow(
                    icon: Icons.calendar_month_outlined,
                    label: 'Scheduled',
                    value: formatDateTime(request.scheduledAt!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ServiceProgressScreen(
                    repository: repository,
                    requestId: request.id,
                  ),
                ),
              ),
              icon: const Icon(Icons.near_me_outlined),
              label: Text(
                request.status == RequestStatus.workStarted
                    ? 'View Service Progress'
                    : 'View Tractor Location',
              ),
            ),
          ],
          if (request.status == RequestStatus.completed) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CompletionScreen(
                    repository: repository,
                    requestId: request.id,
                  ),
                ),
              ),
              icon: const Icon(Icons.task_alt),
              label: const Text('Confirm Completed Work'),
            ),
          ],
        ],
      ),
    );
  }

  List<_TimelineItem> _timelineItems(RequestStatus status) {
    final statuses = [
      RequestStatus.awaitingApproval,
      RequestStatus.approved,
      RequestStatus.tractorScheduled,
      RequestStatus.operatorDispatched,
      RequestStatus.workStarted,
      RequestStatus.completed,
      RequestStatus.confirmed,
    ];
    final currentIndex = statuses.indexOf(status);
    return [
      _TimelineItem('Request submitted', currentIndex >= 0),
      _TimelineItem('Approved', currentIndex >= 1),
      _TimelineItem('Tractor scheduled', currentIndex >= 2),
      _TimelineItem('Operator dispatched', currentIndex >= 3),
      _TimelineItem('Work started', currentIndex >= 4),
      _TimelineItem('Completed', currentIndex >= 5),
      _TimelineItem(
        status == RequestStatus.disputed ? 'Disputed' : 'Confirmation',
        status == RequestStatus.confirmed || status == RequestStatus.disputed,
        isProblem: status == RequestStatus.disputed,
      ),
    ];
  }
}

class _TimelineItem {
  const _TimelineItem(this.label, this.done, {this.isProblem = false});

  final String label;
  final bool done;
  final bool isProblem;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.item});

  final _TimelineItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.isProblem
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            item.done ? Icons.circle : Icons.radio_button_unchecked,
            size: item.done ? 14 : 18,
            color: item.done ? color : Colors.black38,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item.label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: item.done ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignedRow extends StatelessWidget {
  const _AssignedRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
