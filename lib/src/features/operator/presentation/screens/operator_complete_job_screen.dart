// File purpose: Implements the operator complete job screen and connects user actions to feature state.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../additional_data/location/domain/entities/device_location.dart';
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
    this.initialPhone,
  });

  final OperatorLocalRepository repository;
  final String jobId;
  final DeviceLocation? initialPhone;

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
  String? _endHourMeterError;
  String? _fuelUsedError;

  static final TextInputFormatter _decimalFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
        return RegExp(r'^\d*(?:\.\d{0,2})?$').hasMatch(newValue.text)
            ? newValue
            : oldValue;
      });

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
        appBar: AppBar(title: Text(context.appText('Job unavailable'))),
        body: Center(
          child: Text(
            context.appText('This assignment is no longer available.'),
          ),
        ),
      );
    }
    final startHourMeter = widget.repository.baselineHourMeterForJob(job.id);
    final enteredEndHourMeter = num.tryParse(
      _endHourMeterController.text.trim(),
    );
    final meterDifference =
        startHourMeter != null &&
            enteredEndHourMeter != null &&
            enteredEndHourMeter >= startHourMeter
        ? enteredEndHourMeter - startHourMeter
        : null;
    return Scaffold(
      appBar: AppBar(title: Text(context.appText('Complete Job'))),
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
                        label: context.appText('Started'),
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
                OperatorCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.appText(
                            'Use the readings shown on the tractor and the actual fuel record. Do not enter estimates or the number of hours worked.',
                          ),
                        ),
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
                  decoration: InputDecoration(
                    labelText: context.appText('Reported acres'),
                    helperText: context.appText(
                      'Enter your best field estimate. The backend calculates tracker-estimated acres after completion for union review.',
                    ),
                    helperMaxLines: 3,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey('completion-end-hour-meter'),
                  controller: _endHourMeterController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [_decimalFormatter],
                  onChanged: (_) => setState(() => _endHourMeterError = null),
                  decoration: InputDecoration(
                    labelText: context.appText('End hour meter'),
                    suffixText: 'h',
                    errorText: _endHourMeterError,
                    helperMaxLines: 2,
                    helperText: meterDifference != null
                        ? context
                              .appText(
                                'Start reading: {start} h - Meter difference: {difference} h',
                              )
                              .replaceAll(
                                '{start}',
                                _formatReading(startHourMeter!),
                              )
                              .replaceAll(
                                '{difference}',
                                _formatReading(meterDifference),
                              )
                        : startHourMeter == null
                        ? context.appText(
                            'Enter the final reading displayed by the tractor hour meter.',
                          )
                        : context
                              .appText(
                                'Recorded start reading: {start} h. The end reading cannot be lower.',
                              )
                              .replaceAll(
                                '{start}',
                                _formatReading(startHourMeter),
                              ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey('completion-fuel-used'),
                  controller: _fuelUsedController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [_decimalFormatter],
                  onChanged: (_) => setState(() => _fuelUsedError = null),
                  decoration: InputDecoration(
                    labelText: context.appText('Fuel used (L)'),
                    suffixText: 'L',
                    errorText: _fuelUsedError,
                    helperMaxLines: 2,
                    helperText: context.appText(
                      'Enter the actual litres used for this job from the fuel or issue record. Leave blank if no reading is available.',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: context.appText('Add Notes'),
                  ),
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
        title: context.appText('Missing acres'),
        message: context.appText(
          'Enter the reported acres completed before submitting.',
        ),
      );
      return;
    }
    final readings = _validatedReadings();
    if (readings == null) return;
    final confirmed = await showAppConfirmationDialog(
      context,
      title: context.appText('Submit completed work?'),
      message: context.appText(
        'This will send the job completion details to the union for review.',
      ),
      confirmLabel: 'Submit',
    );
    if (!confirmed || !mounted) return;
    setState(() => _submitting = true);
    final phone =
        _freshInitialPhone() ?? await widget.repository.captureFieldLocation();
    final ok = await widget.repository.completeJob(
      jobId: widget.jobId,
      reportedAcres: area,
      notes: _notesController.text.trim(),
      endHourMeter: readings.$1,
      fuelUsedLitres: readings.$2,
      phone: phone,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!ok) {
      await showAppErrorDialog(
        context,
        title: context.appText('Could not submit'),
        message:
            widget.repository.lastActionError ??
            'Completed work could not be submitted.',
      );
      return;
    }
    await showAppSuccessDialog(
      context,
      title: context.appText('Work submitted'),
      message: context.appText(
        'Work was completed. The farmer can now confirm satisfaction using their PIN or SMS code, or confirm later.',
      ),
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

  DeviceLocation? _freshInitialPhone() {
    final phone = widget.initialPhone;
    if (phone == null || phone.isMocked) return null;
    final age = DateTime.now().difference(phone.recordedAt).inSeconds;
    final maximumAge = widget.repository.phoneFixMaximumAge.inSeconds;
    if (age < -30 || age > maximumAge) return null;
    if (!phone.accuracyMeters.isFinite ||
        phone.accuracyMeters < 0 ||
        phone.accuracyMeters > widget.repository.phoneAccuracyMaxMeters) {
      return null;
    }
    return phone;
  }

  (num?, num?)? _validatedReadings() {
    final endText = _endHourMeterController.text.trim();
    final fuelText = _fuelUsedController.text.trim();
    final endHourMeter = endText.isEmpty ? null : num.tryParse(endText);
    final fuelUsed = fuelText.isEmpty ? null : num.tryParse(fuelText);
    final startHourMeter = widget.repository.baselineHourMeterForJob(
      widget.jobId,
    );

    String? endError;
    String? fuelError;
    if (endText.isNotEmpty &&
        (endHourMeter == null || !endHourMeter.isFinite || endHourMeter < 0)) {
      endError = context.appText('Enter a valid hour-meter reading.');
    } else if (endHourMeter != null &&
        startHourMeter != null &&
        endHourMeter < startHourMeter) {
      endError = context
          .appText('End reading must be at least {start} h.')
          .replaceAll('{start}', _formatReading(startHourMeter));
    }
    if (fuelText.isNotEmpty &&
        (fuelUsed == null || !fuelUsed.isFinite || fuelUsed < 0)) {
      fuelError = context.appText(
        'Enter zero or the actual non-negative litres used.',
      );
    }
    setState(() {
      _endHourMeterError = endError;
      _fuelUsedError = fuelError;
    });
    if (endError != null || fuelError != null) return null;
    return (endHourMeter, fuelUsed);
  }

  String _formatReading(num value) {
    final rounded = value.toStringAsFixed(2);
    return rounded.replaceFirst(RegExp(r'\.?0+$'), '');
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
