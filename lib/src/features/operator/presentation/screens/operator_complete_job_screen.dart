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
  final _areaController = TextEditingController();
  final _endHourMeterController = TextEditingController();
  final _fuelUsedController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    _areaController.dispose();
    _endHourMeterController.dispose();
    _fuelUsedController.dispose();
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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Reported acres',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _endHourMeterController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'End hour meter',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _fuelUsedController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Fuel used (L)',
                  ),
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
    final messenger = ScaffoldMessenger.of(context);
    final area = double.tryParse(_areaController.text.trim());
    if (area == null || area <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter the reported acres completed.')),
      );
      return;
    }
    final endHourMeter = num.tryParse(_endHourMeterController.text.trim());
    final fuelUsed = num.tryParse(_fuelUsedController.text.trim());
    setState(() => _submitting = true);
    final ok = await widget.repository.completeJob(
      jobId: widget.jobId,
      areaServicedHectares: area,
      notes: _notesController.text.trim(),
      endHourMeter: endHourMeter,
      fuelUsedLitres: fuelUsed,
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
    messenger.showSnackBar(
      const SnackBar(content: Text('Completed work submitted')),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OperatorFarmerConfirmationScreen(
          repository: widget.repository,
          jobId: widget.jobId,
        ),
      ),
    );
  }
}

class OperatorFarmerConfirmationScreen extends StatefulWidget {
  const OperatorFarmerConfirmationScreen({
    super.key,
    required this.repository,
    required this.jobId,
  });

  final OperatorLocalRepository repository;
  final String jobId;

  @override
  State<OperatorFarmerConfirmationScreen> createState() =>
      _OperatorFarmerConfirmationScreenState();
}

class _OperatorFarmerConfirmationScreenState
    extends State<OperatorFarmerConfirmationScreen> {
  final _codeController = TextEditingController();
  final _pinController = TextEditingController();
  final _noteController = TextEditingController();
  String _method = 'pin';
  int _rating = 5;
  bool _dispute = false;
  bool _sendingOtp = false;
  bool _submitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    _pinController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.repository.jobById(widget.jobId);
    return Scaffold(
      appBar: AppBar(title: const Text('Farmer Confirmation')),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.reference ?? job.id,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text('${job.farmerName} - ${job.plot.name}'),
                      if (job.farmerPhone != null) Text(job.farmerPhone!),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _method,
                  decoration: const InputDecoration(
                    labelText: 'Confirmation method',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'pin', child: Text('Farmer PIN')),
                    DropdownMenuItem(value: 'otp', child: Text('SMS OTP')),
                  ],
                  onChanged: (value) =>
                      setState(() => _method = value ?? _method),
                ),
                const SizedBox(height: 12),
                if (_method == 'otp') ...[
                  OutlinedButton.icon(
                    onPressed: _sendingOtp ? null : _requestOtp,
                    icon: const Icon(Icons.sms_outlined),
                    label: Text(_sendingOtp ? 'Sending OTP...' : 'Send OTP'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'OTP code'),
                  ),
                ] else
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Farmer PIN',
                    ),
                  ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _rating,
                  decoration: const InputDecoration(labelText: 'Rating'),
                  items: [1, 2, 3, 4, 5]
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text('$value'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _rating = value ?? _rating),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _dispute,
                  title: const Text('Farmer disputes the work'),
                  onChanged: (value) => setState(() => _dispute = value),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: _dispute ? 'Dispute note' : 'Confirmation note',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: const Icon(Icons.verified_outlined),
                  label: Text(
                    _submitting ? 'Submitting...' : 'Submit Confirmation',
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _submitting
                      ? null
                      : () =>
                            Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Skip for now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _requestOtp() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sendingOtp = true);
    final ok = await widget.repository.requestFarmerOtp(widget.jobId);
    if (!mounted) return;
    setState(() => _sendingOtp = false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'OTP request sent.'
              : widget.repository.lastActionError ?? 'Could not send OTP.',
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final pin = _pinController.text.trim();
    final code = _codeController.text.trim();
    final note = _noteController.text.trim();
    if (_method == 'pin' && pin.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter the farmer PIN.')),
      );
      return;
    }
    if (_method == 'otp' && code.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter the OTP code.')),
      );
      return;
    }
    if (_dispute && note.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter a dispute note.')),
      );
      return;
    }

    setState(() => _submitting = true);
    final ok = await widget.repository.confirmFarmer(
      jobId: widget.jobId,
      method: _method,
      code: _method == 'otp' ? code : null,
      pin: _method == 'pin' ? pin : null,
      rating: _dispute ? null : _rating,
      note: note.isEmpty ? null : note,
      dispute: _dispute,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!ok) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.repository.lastActionError ??
                'Farmer confirmation failed.',
          ),
        ),
      );
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          _dispute
              ? 'Farmer dispute recorded.'
              : 'Farmer confirmation recorded.',
        ),
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
