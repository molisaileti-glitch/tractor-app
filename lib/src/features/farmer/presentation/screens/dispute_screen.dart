import 'package:flutter/material.dart';

import '../../data/repositories/farmer_local_repository.dart';
import '../widgets/farmer_scaffold.dart';

class DisputeScreen extends StatefulWidget {
  const DisputeScreen({
    super.key,
    required this.repository,
    required this.requestId,
  });

  final FarmerLocalRepository repository;
  final String requestId;

  @override
  State<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends State<DisputeScreen> {
  final _descriptionController = TextEditingController();
  String _reason = 'Work was incomplete';

  static const _reasons = [
    'Work was incomplete',
    'Wrong area was serviced',
    'Tractor did not cover entire plot',
    'Service quality issue',
    'Other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FarmerPage(
      title: 'Report a Problem',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What went wrong?',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          InfoCard(
            child: Column(
              children: _reasons.map((reason) {
                final selected = _reason == reason;
                return InkWell(
                  onTap: () => setState(() => _reason = reason),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black45,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(reason)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _descriptionController,
            minLines: 4,
            maxLines: 6,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Add Photo'),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.send_outlined),
            label: const Text('Submit Dispute'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final messenger = ScaffoldMessenger.of(context);
    widget.repository.disputeWork(
      requestId: widget.requestId,
      reason: _reason,
      description: _descriptionController.text.trim(),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
    messenger.showSnackBar(const SnackBar(content: Text('Dispute submitted')));
  }
}
