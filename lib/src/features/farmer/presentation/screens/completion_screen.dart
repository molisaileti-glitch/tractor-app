import 'package:flutter/material.dart';

import '../../data/repositories/farmer_local_repository.dart';
import '../widgets/farmer_formatters.dart';
import '../widgets/farmer_scaffold.dart';
import 'dispute_screen.dart';

class CompletionScreen extends StatelessWidget {
  const CompletionScreen({
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
      title: 'Service Completed',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.check, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 18),
          Text(
            request.serviceType.label,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(plot.name),
          const SizedBox(height: 18),
          InfoCard(
            child: Column(
              children: [
                _Fact(
                  label: 'Operator',
                  value: request.operatorName ?? 'Pending',
                ),
                _Fact(
                  label: 'Started',
                  value: request.startedAt == null
                      ? 'Pending'
                      : formatTime(request.startedAt!),
                ),
                _Fact(
                  label: 'Finished',
                  value: request.finishedAt == null
                      ? 'Pending'
                      : formatTime(request.finishedAt!),
                ),
                _Fact(
                  label: 'Area serviced',
                  value: request.areaServicedHectares == null
                      ? 'Pending'
                      : '${request.areaServicedHectares!.toStringAsFixed(1)} hectares',
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Was the work completed correctly?'),
          FilledButton.icon(
            onPressed: () {
              final messenger = ScaffoldMessenger.of(context);
              repository.confirmWork(requestId);
              Navigator.of(context).popUntil((route) => route.isFirst);
              messenger.showSnackBar(
                const SnackBar(content: Text('Work confirmed')),
              );
            },
            icon: const Icon(Icons.check),
            label: const Text('Confirm Work'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) =>
                    DisputeScreen(repository: repository, requestId: requestId),
              ),
            ),
            icon: const Icon(Icons.report_problem_outlined),
            label: const Text('Dispute Work'),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.black.withValues(alpha: 0.60)),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
