import 'package:flutter/material.dart';

import '../../../../components/components.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../widgets/operator_widgets.dart';
import 'operator_job_photos_screen.dart';
import 'operator_farmer_confirmation_screen.dart';

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
    final strings = AppLocalizations.of(context)!;
    final job = widget.repository.maybeJobById(widget.jobId);
    if (job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job unavailable')),
        body: const Center(
          child: Text('This assignment is no longer available.'),
        ),
      );
    }
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
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.topRight,
                        child: OperatorStatusPill(status: job.status),
                      ),
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
                  decoration: const InputDecoration(labelText: 'Fuel used (L)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Add Notes'),
                ),
                const SizedBox(height: 16),
                Text(strings.optionalAfterPhotosHint),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const ValueKey('optional-after-service-photos'),
                  onPressed: _submitting
                      ? null
                      : () => Navigator.of(context).push(
                          appPageRoute(
                            builder: (_) => OperatorJobPhotosScreen(
                              repository: widget.repository,
                              jobId: widget.jobId,
                              initialKind: 'after',
                            ),
                          ),
                        ),
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: Text(strings.optionalAfterServicePhotos),
                ),
                const SizedBox(height: 12),
                AppGlowButton(
                  onPressed: _submitting ? null : _submit,
                  loading: _submitting,
                  icon: Icons.lock_outline,
                  label: _submitting ? 'Submitting...' : 'Finish Job',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final area = double.tryParse(_areaController.text.trim());
    if (area == null || !area.isFinite || area <= 0) {
      await showAppErrorDialog(
        context,
        title: 'Missing acres',
        message: 'Enter the reported acres completed before submitting.',
      );
      return;
    }
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Submit completed work?',
      message:
          'This will send the job completion details to the union for review.',
      confirmLabel: 'Submit',
    );
    if (!confirmed || !mounted) return;

    final endHourMeter = num.tryParse(_endHourMeterController.text.trim());
    final fuelUsed = num.tryParse(_fuelUsedController.text.trim());
    if ((_endHourMeterController.text.trim().isNotEmpty &&
            (endHourMeter == null ||
                !endHourMeter.isFinite ||
                endHourMeter < 0)) ||
        (_fuelUsedController.text.trim().isNotEmpty &&
            (fuelUsed == null || !fuelUsed.isFinite || fuelUsed < 0))) {
      await showAppErrorDialog(
        context,
        title: 'Invalid readings',
        message: 'Enter valid non-negative meter and fuel readings.',
      );
      return;
    }
    setState(() => _submitting = true);
    final phone = await widget.repository.captureFieldLocation();
    final ok = await widget.repository.completeJob(
      jobId: widget.jobId,
      reportedAcres: area,
      notes: _notesController.text.trim(),
      endHourMeter: endHourMeter,
      fuelUsedLitres: fuelUsed,
      phone: phone,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!ok) {
      await showAppErrorDialog(
        context,
        title: 'Could not submit',
        message:
            widget.repository.lastActionError ??
            'Completed work could not be submitted.',
      );
      return;
    }
    await showAppSuccessDialog(
      context,
      title: 'Work submitted',
      message:
          'Work was completed. The farmer can now confirm satisfaction using their PIN or SMS code, or confirm later.',
    );
    if (!mounted) return;
    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.isFirst);
    navigator.push(
      appPageRoute(
        builder: (_) => OperatorFarmerConfirmationScreen(
          repository: widget.repository,
          jobId: widget.jobId,
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
