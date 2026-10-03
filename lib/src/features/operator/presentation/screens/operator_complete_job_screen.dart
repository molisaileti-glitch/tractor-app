import 'package:flutter/material.dart';

import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../widgets/operator_widgets.dart';

class OperatorCompleteJobScreen extends StatefulWidget {
  const OperatorCompleteJobScreen({
    super.key,
    required this.repository,
    required this.jobId,
  });

  final OperatorLocalRepository repository;
  final String jobId;

  @override
  State<OperatorCompleteJobScreen> createState() =>
      _OperatorCompleteJobScreenState();
}

class _OperatorCompleteJobScreenState extends State<OperatorCompleteJobScreen> {
  final _notesController = TextEditingController();
  final _areaController = TextEditingController(text: '4.1');
  bool _submitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.repository.jobById(widget.jobId);
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Job')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OperatorCard(
                  child: Column(
                    children: [
                      _Fact(
                        label: 'Started',
                        value: job.startedAt == null
                            ? 'Pending'
                            : formatTime(job.startedAt!),
                      ),
                      const _Fact(label: 'Finished', value: '12:36 PM'),
                      const _Fact(label: 'Duration', value: '3h 32m'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _areaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Area serviced'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Add Notes'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text('Add Photo'),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: const Icon(Icons.send_outlined),
                  label: Text(
                    _submitting ? 'Submitting...' : 'Submit Completed Work',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final area = double.tryParse(_areaController.text.trim()) ?? 4.1;
    final ok = await widget.repository.completeJob(
      jobId: widget.jobId,
      areaServicedHectares: area,
      notes: _notesController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!ok) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.repository.lastActionError ??
                'Completed work could not be submitted.',
          ),
        ),
      );
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
    messenger.showSnackBar(
      const SnackBar(content: Text('Completed work submitted')),
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
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.black.withValues(alpha: 0.62)),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
