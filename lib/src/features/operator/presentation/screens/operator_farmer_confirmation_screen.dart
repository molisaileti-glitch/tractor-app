import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/repositories/operator_local_repository.dart';
import '../../domain/entities/operator_job.dart';

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
  final _credential = TextEditingController();
  final _note = TextEditingController();
  late String _method =
      widget.repository.maybeJobById(widget.jobId)?.farmerHasPin == true
      ? 'pin'
      : 'otp';
  int? _rating;
  bool _dispute = false;
  bool _busy = false;
  String? _message;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.repository.refreshJobDetail(widget.jobId);
    });
  }

  @override
  void dispose() {
    _credential.clear();
    _credential.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    final ok = await widget.repository.sendFarmerOtp(widget.jobId);
    if (mounted) {
      setState(() {
        _busy = false;
        _error = !ok;
        _message = ok
            ? 'Code sent to the farmer. It expires in 10 minutes; five wrong attempts invalidate it.'
            : widget.repository.lastActionError;
      });
    }
  }

  Future<void> _submit() async {
    final code = _credential.text.trim();
    if (!RegExp(_method == 'pin' ? r'^\d{4}$' : r'^\d{6}$').hasMatch(code) ||
        (_dispute && _note.text.trim().isEmpty)) {
      setState(() {
        _error = true;
        _message =
            'Enter the ${_method == 'pin' ? 'four-digit PIN' : 'six-digit code'}${_dispute ? ' and describe the problem' : ''}.';
      });
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    final ok = await widget.repository.confirmFarmerService(
      jobId: widget.jobId,
      method: _method,
      credential: code,
      rating: _rating,
      dispute: _dispute,
      note: _note.text.trim(),
    );
    if (!mounted) return;
    _credential.clear();
    setState(() {
      _busy = false;
      _error = !ok;
      _message = ok
          ? (_dispute
                ? 'The problem was sent to the union for review.'
                : 'Farmer confirmation recorded. The union can now review and verify the work.')
          : widget.repository.lastActionError ??
                'Confirmation failed. Please try again.';
    });
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      appBar: AppBar(title: const Text('Farmer confirmation')),
      body: AnimatedBuilder(
        animation: widget.repository,
        builder: (context, _) {
          final job = widget.repository.maybeJobById(widget.jobId);
          if (job == null) {
            return const Center(
              child: Text('This job is no longer available.'),
            );
          }
          if (!job.farmerHasPin && _method == 'pin') _method = 'otp';
          final pending =
              job.status == OperatorJobStatus.completedPendingConfirmation &&
              job.farmerConfirmedAt == null;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                '${job.reference ?? job.id} - ${job.farmerName}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (!pending)
                Text(
                  job.farmerConfirmedAt != null
                      ? 'The farmer has already confirmed this service.'
                      : 'This job is ${job.status.label.toLowerCase()}.',
                )
              else ...[
                const Text(
                  'Hand the phone to the farmer. The farmer should review the work and enter their own PIN or SMS code.',
                ),
                const SizedBox(height: 12),
                if (!job.farmerHasPin)
                  const Text(
                    'No farmer PIN is configured. Use an SMS code or ask the union to help.',
                  ),
                DropdownButtonFormField<String>(
                  key: ValueKey('confirmation-method-$_method'),
                  initialValue: _method,
                  decoration: const InputDecoration(
                    labelText: 'Confirmation method',
                  ),
                  items: [
                    if (job.farmerHasPin)
                      const DropdownMenuItem(
                        value: 'pin',
                        child: Text('Farmer PIN'),
                      ),
                    const DropdownMenuItem(
                      value: 'otp',
                      child: Text('SMS code'),
                    ),
                  ],
                  onChanged: _busy
                      ? null
                      : (value) => setState(() {
                          _method = value!;
                          _credential.clear();
                          _message = null;
                        }),
                ),
                if (_method == 'otp')
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _sendOtp,
                    icon: const Icon(Icons.sms_outlined),
                    label: const Text('Send code to farmer'),
                  ),
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey('farmer-credential'),
                  controller: _credential,
                  enabled: !_busy,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.number,
                  maxLength: _method == 'pin' ? 4 : 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: _method == 'pin'
                        ? 'Farmer four-digit PIN'
                        : 'Farmer six-digit SMS code',
                  ),
                ),
                DropdownButtonFormField<int>(
                  initialValue: _rating,
                  decoration: const InputDecoration(
                    labelText: 'Farmer rating (optional)',
                  ),
                  items: [
                    for (var i = 1; i <= 5; i++)
                      DropdownMenuItem(value: i, child: Text('$i / 5')),
                  ],
                  onChanged: _busy
                      ? null
                      : (value) => setState(() => _rating = value),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _dispute,
                  title: const Text('I am not satisfied - report a problem'),
                  onChanged: _busy
                      ? null
                      : (value) => setState(() => _dispute = value!),
                ),
                if (_dispute)
                  TextField(
                    controller: _note,
                    enabled: !_busy,
                    minLines: 2,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Describe the problem',
                    ),
                  ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _busy ? null : _submit,
                  icon: Icon(_dispute ? Icons.flag : Icons.verified_user),
                  label: Text(
                    _busy
                        ? 'Submitting...'
                        : _dispute
                        ? 'Farmer: submit problem'
                        : 'Farmer: confirm satisfaction',
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _busy ? null : () => Navigator.of(context).pop(),
                  child: const Text('Confirm later'),
                ),
              ],
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    _message!,
                    style: TextStyle(
                      color: _error
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );
}
