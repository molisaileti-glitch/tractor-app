import 'package:flutter/material.dart';

import '../../../../core/location/data/repositories/geolocator_location_repository.dart';
import '../../../../core/location/domain/entities/device_location.dart';
import '../../../../core/location/domain/repositories/location_repository.dart';
import '../../../../core/location/domain/usecases/check_plot_geofence.dart';
import '../../../../core/presentation/components/components.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../../domain/entities/operator_job.dart';
import '../widgets/operator_widgets.dart';
import 'operator_progress_screen.dart';

class OperatorArrivalScreen extends StatefulWidget {
  const OperatorArrivalScreen({
    super.key,
    required this.repository,
    required this.jobId,
  });

  final OperatorLocalRepository repository;
  final String jobId;

  @override
  State<OperatorArrivalScreen> createState() => _OperatorArrivalScreenState();
}

class _OperatorArrivalScreenState extends State<OperatorArrivalScreen> {
  final LocationRepository _phoneLocationRepository =
      const GeolocatorLocationRepository();
  final CheckPlotGeofence _checkPlotGeofence = const CheckPlotGeofence();

  bool _checkingLocation = false;
  bool _submittingArrival = false;
  bool _submittingInspection = false;
  bool _runningStartCheck = false;
  bool _submittingStart = false;
  bool _inspectionRecorded = false;
  PlotGeofenceResult? _geofenceResult;
  OperatorStartCheckResult? _startCheck;
  String? _locationError;
  final _hourMeterController = TextEditingController();
  final _implementController = TextEditingController();

  @override
  void dispose() {
    _hourMeterController.dispose();
    _implementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.repository.maybeJobById(widget.jobId);
    if (job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job unavailable')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'This job is no longer available in the operator assignment list.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      );
    }
    final isInsideFarm = _geofenceResult?.isInside ?? false;
    final distanceMeters = _geofenceResult?.distanceFromPlotMeters;
    final hasArrived =
        job.status == OperatorJobStatus.arrived ||
        job.status == OperatorJobStatus.inProgress;
    final routeLocation = _geofenceResult?.location;
    return Scaffold(
      appBar: AppBar(
        title: Text(hasArrived ? 'ARRIVAL & START' : 'JOURNEY TO FARM'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OperatorMapCard(
                  job: job,
                  label: hasArrived ? 'FARM LOCATION' : 'ROUTE TO FARM',
                  routeFromLatitude: routeLocation?.latitude,
                  routeFromLongitude: routeLocation?.longitude,
                  routeEnabled: true,
                ),
                const SizedBox(height: 16),
                OperatorStatusPill(status: job.status),
                const SizedBox(height: 12),
                OperatorCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isInsideFarm
                            ? Icons.check_circle_outline
                            : Icons.warning_amber_outlined,
                        color: isInsideFarm
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _statusText(
                            hasArrived: hasArrived,
                            isInsideFarm: isInsideFarm,
                            distanceMeters: distanceMeters,
                          ),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_geofenceResult != null) ...[
                  const SizedBox(height: 10),
                  OperatorCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LocationFact(
                          label: 'Latitude',
                          value: _geofenceResult!.location.latitude
                              .toStringAsFixed(6),
                        ),
                        _LocationFact(
                          label: 'Longitude',
                          value: _geofenceResult!.location.longitude
                              .toStringAsFixed(6),
                        ),
                        _LocationFact(
                          label: 'Accuracy',
                          value:
                              '${_geofenceResult!.location.accuracyMeters.toStringAsFixed(0)} m',
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _WorkflowStep(
                  number: 1,
                  title: 'Confirm your location',
                  complete: _geofenceResult != null,
                  child: OutlinedButton.icon(
                    onPressed: _checkingLocation ? null : _refreshLocation,
                    icon: const Icon(Icons.gps_fixed),
                    label: Text(
                      _checkingLocation
                          ? 'Checking GPS...'
                          : _geofenceResult == null
                          ? 'Check Location'
                          : 'Refresh Location',
                    ),
                  ),
                ),
                if (_geofenceResult != null && !hasArrived) ...[
                  const SizedBox(height: 12),
                  _WorkflowStep(
                    number: 2,
                    title: 'Travel and record arrival',
                    complete: false,
                    child: Column(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _checkingLocation
                              ? null
                              : _refreshLocation,
                          icon: const Icon(Icons.route_outlined),
                          label: const Text('Refresh Route'),
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: _submittingArrival ? null : _recordArrival,
                          icon: const Icon(Icons.flag_outlined),
                          label: Text(
                            _submittingArrival
                                ? 'Recording arrival...'
                                : 'Record Arrival',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (hasArrived && _geofenceResult != null) ...[
                  const SizedBox(height: 12),
                  _WorkflowStep(
                    number: 2,
                    title: 'Inspect the tractor',
                    complete: _inspectionRecorded,
                    child: OutlinedButton.icon(
                      onPressed: _submittingInspection || _inspectionRecorded
                          ? null
                          : _recordInspection,
                      icon: const Icon(Icons.fact_check_outlined),
                      label: Text(
                        _inspectionRecorded
                            ? 'Inspection Recorded'
                            : _submittingInspection
                            ? 'Recording inspection...'
                            : 'Record Inspection',
                      ),
                    ),
                  ),
                  if (_inspectionRecorded) ...[
                    const SizedBox(height: 12),
                    _WorkflowStep(
                      number: 3,
                      title: 'Run safety checks',
                      complete: _startCheck?.canStart ?? false,
                      child: Column(
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: _runningStartCheck
                                ? null
                                : _runStartCheck,
                            icon: const Icon(Icons.rule_folder_outlined),
                            label: Text(
                              _runningStartCheck
                                  ? 'Running start check...'
                                  : 'Run Start Check',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_startCheck?.canStart ?? false) ...[
                    const SizedBox(height: 12),
                    _WorkflowStep(
                      number: 4,
                      title: 'Start service',
                      complete: false,
                      child: Column(
                        children: [
                          TextField(
                            controller: _hourMeterController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Start hour meter',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _implementController,
                            decoration: const InputDecoration(
                              labelText: 'Implement',
                            ),
                          ),
                          const SizedBox(height: 10),
                          FilledButton.icon(
                            onPressed: _submittingStart ? null : _startJob,
                            icon: const Icon(Icons.play_arrow),
                            label: Text(
                              _submittingStart
                                  ? 'Starting...'
                                  : 'Start Ploughing',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusText({
    required bool hasArrived,
    required bool isInsideFarm,
    required double? distanceMeters,
  }) {
    if (_checkingLocation) {
      return hasArrived
          ? 'Checking phone GPS against the assigned farm boundary.'
          : 'Checking your phone location for the route to the assigned farm.';
    }
    if (_locationError != null) {
      return 'Location could not be verified.';
    }
    if (_geofenceResult == null) {
      return hasArrived
          ? 'Check location before starting this service.'
          : 'Check location to show the route to the farm.';
    }
    if (hasArrived) {
      return 'Phone location captured. Farm proximity will be validated during the start check.';
    }
    if (isInsideFarm) {
      return 'You appear to be at the assigned farm. Record arrival before starting service.';
    }
    final distanceText = distanceMeters == null || distanceMeters.isInfinite
        ? 'unknown'
        : '${distanceMeters.toStringAsFixed(0)} m';
    return 'Follow the route guide to the assigned farm. Distance from plot: $distanceText.';
  }

  Future<void> _refreshLocation() async {
    final job = widget.repository.maybeJobById(widget.jobId);
    debugPrint(
      '[Operator GPS] Check requested for job=${widget.jobId}; '
      'jobFound=${job != null}',
    );
    if (job == null) return;
    setState(() {
      _checkingLocation = true;
      _locationError = null;
    });

    final result = await _phoneLocationRepository.getCurrentLocation();
    if (!mounted) return;

    if (result is LocationSuccess) {
      debugPrint(
        '[Operator GPS] Location ready: '
        '${result.location.latitude},${result.location.longitude} '
        '(accuracy ${result.location.accuracyMeters} m)',
      );
      setState(() {
        _geofenceResult = _checkPlotGeofence(
          plot: job.plot,
          location: result.location,
        );
        _startCheck = null;
        _checkingLocation = false;
      });
      return;
    }

    if (result is LocationUnavailable) {
      debugPrint('[Operator GPS] ${result.failure.message}');
      setState(() {
        _geofenceResult = null;
        _locationError = result.failure.message;
        _checkingLocation = false;
      });
      await showAppErrorDialog(
        context,
        title: 'Location could not be verified',
        message: result.failure.message,
        buttonLabel: 'Try again',
      );
    }
  }

  Future<void> _recordArrival() async {
    setState(() => _submittingArrival = true);
    final arrived = await widget.repository.arriveJob(
      widget.jobId,
      phone: _geofenceResult?.location,
    );
    if (!mounted) return;
    setState(() => _submittingArrival = false);
    showAppSnackBar(
      context,
      message: arrived
          ? 'Arrival recorded.'
          : widget.repository.lastActionError ?? 'Could not record arrival.',
      type: arrived ? AppSnackType.success : AppSnackType.error,
    );
  }

  Future<void> _startJob() async {
    final navigator = Navigator.of(context);
    final location = _geofenceResult?.location;
    final hourMeter = num.tryParse(_hourMeterController.text.trim());
    final implement = _implementController.text.trim();
    setState(() => _submittingStart = true);
    final started = await widget.repository.startJob(
      widget.jobId,
      phone: location,
      hourMeter: hourMeter,
      implement: implement.isEmpty ? null : implement,
    );
    if (!mounted) return;
    setState(() => _submittingStart = false);
    if (!started) {
      showAppSnackBar(
        context,
        message:
            widget.repository.lastActionError ??
            'The backend did not allow this job to start.',
        type: AppSnackType.error,
      );
      return;
    }
    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (_) => OperatorProgressScreen(
          repository: widget.repository,
          jobId: widget.jobId,
        ),
      ),
    );
  }

  Future<void> _runStartCheck() async {
    setState(() => _runningStartCheck = true);
    final result = await widget.repository.runStartCheck(
      jobId: widget.jobId,
      phone: _geofenceResult?.location,
    );
    if (!mounted) return;
    setState(() {
      _startCheck = result;
      _runningStartCheck = false;
    });
    if (result == null) {
      showAppSnackBar(
        context,
        message: widget.repository.lastActionError ?? 'Start check failed.',
        type: AppSnackType.error,
      );
      return;
    }
    if (result.canStart) {
      showAppSnackBar(
        context,
        message: 'Start check passed. You can start ploughing.',
        type: AppSnackType.success,
      );
      return;
    }
    final viewResults = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Start check needs attention'),
        content: Text(
          '${result.failed.length} checks did not pass. Review the results before trying again.',
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        actions: [
          AppDialogActions(
            onCancel: () => Navigator.of(dialogContext).pop(false),
            onConfirm: () => Navigator.of(dialogContext).pop(true),
            cancelLabel: 'Close',
            confirmLabel: 'View Results',
          ),
        ],
      ),
    );
    if (viewResults == true && mounted) {
      await showDialog<void>(
        context: context,
        builder: (_) => _StartCheckResultsDialog(
          result: result,
          onRequestOverride: result.overrideAllowed ? _requestOverride : null,
        ),
      );
    }
  }

  Future<void> _requestOverride() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _OverrideReasonDialog(),
    );
    if (reason == null || reason.trim().isEmpty) return;
    if (!mounted) return;

    final ok = await widget.repository.requestStartOverride(
      jobId: widget.jobId,
      reason: reason.trim(),
      phone: _geofenceResult?.location,
    );
    if (!mounted) return;
    showAppSnackBar(
      context,
      message: ok
          ? 'Override request sent to the union.'
          : widget.repository.lastActionError ?? 'Could not request override.',
      type: ok ? AppSnackType.success : AppSnackType.error,
    );
  }

  Future<void> _recordInspection() async {
    final job = widget.repository.maybeJobById(widget.jobId);
    if (job == null) return;
    final inspection = await showDialog<_InspectionPayload>(
      context: context,
      builder: (_) => const _InspectionDialog(),
    );
    if (inspection == null) return;
    if (!mounted) return;

    setState(() => _submittingInspection = true);
    final ok = await widget.repository.recordInspection(
      tractorId: job.tractorId,
      jobId: job.id,
      checklist: inspection.checklist,
      fuelLevelPct: inspection.fuelLevelPct,
      hourMeter: inspection.hourMeter,
      defects: inspection.defects,
      isFit: inspection.isFit,
      phone: _geofenceResult?.location,
    );
    if (!mounted) return;
    setState(() {
      _submittingInspection = false;
      if (ok) _inspectionRecorded = true;
    });
    showAppSnackBar(
      context,
      message: ok
          ? 'Inspection recorded.'
          : widget.repository.lastActionError ??
                'Inspection could not be recorded.',
      type: ok ? AppSnackType.success : AppSnackType.error,
    );
  }
}

class _WorkflowStep extends StatelessWidget {
  const _WorkflowStep({
    required this.number,
    required this.title,
    required this.complete,
    required this.child,
  });

  final int number;
  final String title;
  final bool complete;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return OperatorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: complete
                    ? color
                    : color.withValues(alpha: 0.12),
                foregroundColor: complete ? Colors.white : color,
                child: complete
                    ? const Icon(Icons.check_rounded, size: 18)
                    : Text('$number'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: complete
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: SizedBox(width: double.infinity, child: child),
                  ),
          ),
        ],
      ),
    );
  }
}

class _InspectionPayload {
  const _InspectionPayload({
    required this.checklist,
    required this.isFit,
    this.fuelLevelPct,
    this.hourMeter,
    this.defects,
  });

  final Map<String, Object?> checklist;
  final int? fuelLevelPct;
  final num? hourMeter;
  final String? defects;
  final bool isFit;
}

class _InspectionDialog extends StatefulWidget {
  const _InspectionDialog();

  @override
  State<_InspectionDialog> createState() => _InspectionDialogState();
}

class _InspectionDialogState extends State<_InspectionDialog> {
  final _fuelController = TextEditingController();
  final _hourMeterController = TextEditingController();
  final _defectsController = TextEditingController();
  bool _showChecklistError = false;
  final Map<String, bool?> _checks = {
    'engine_oil': null,
    'coolant': null,
    'fuel': null,
    'tyres': null,
    'brakes': null,
    'lights': null,
    'hydraulics': null,
    'implement': null,
    'leaks': null,
    'tracker': null,
  };

  @override
  void dispose() {
    _fuelController.dispose();
    _hourMeterController.dispose();
    _defectsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.fact_check_outlined),
          SizedBox(width: 10),
          Expanded(child: Text('Pre-start inspection')),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Safety checklist',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Inspect every item, then select Pass if it is safe or Issue if it needs attention.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              ..._checks.keys.map(
                (key) => _InspectionCheckRow(
                  label: _checkLabel(key),
                  value: _checks[key],
                  onChanged: (value) {
                    setState(() {
                      _checks[key] = value;
                      _showChecklistError = false;
                    });
                  },
                ),
              ),
              if (_showChecklistError) ...[
                const SizedBox(height: 8),
                Text(
                  'Please mark Pass or Issue for every checklist item.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Text(
                'Readings and notes',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _fuelController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Fuel level (%)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _hourMeterController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Hour meter'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _defectsController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Defects / notes'),
              ),
              const SizedBox(height: 10),
              DecoratedBox(
                decoration: BoxDecoration(
                  color:
                      (_isFit
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error)
                          .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: Icon(
                    _isFit
                        ? Icons.verified_outlined
                        : Icons.warning_amber_rounded,
                    color: _isFit
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    _isFit
                        ? 'Tractor is fit for work'
                        : 'Tractor requires attention',
                  ),
                  subtitle: Text(
                    _checks.values.any((value) => value == null)
                        ? 'Complete the checklist to determine its condition.'
                        : _isFit
                        ? 'All inspection items passed.'
                        : 'One or more inspection items have an issue.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actions: [
        AppDialogActions(
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: _submit,
          confirmLabel: 'Submit Inspection',
        ),
      ],
    );
  }

  void _submit() {
    if (_checks.values.any((value) => value == null)) {
      setState(() => _showChecklistError = true);
      return;
    }
    final fuel = int.tryParse(_fuelController.text.trim());
    final hourMeter = num.tryParse(_hourMeterController.text.trim());
    final defects = _defectsController.text.trim();
    Navigator.of(context).pop(
      _InspectionPayload(
        checklist: _checks.map((key, value) => MapEntry(key, value!)),
        fuelLevelPct: fuel,
        hourMeter: hourMeter,
        defects: defects.isEmpty ? null : defects,
        isFit: _isFit,
      ),
    );
  }

  bool get _isFit => _checks.values.every((value) => value == true);

  String _checkLabel(String key) {
    return switch (key) {
      'engine_oil' => 'Engine oil',
      'coolant' => 'Coolant',
      'fuel' => 'Fuel',
      'tyres' => 'Tyres',
      'brakes' => 'Brakes',
      'lights' => 'Lights',
      'hydraulics' => 'Hydraulics',
      'implement' => 'Implement attached',
      'leaks' => 'No leaks',
      'tracker' => 'Tracker',
      _ => key,
    };
  }
}

class _InspectionCheckRow extends StatelessWidget {
  const _InspectionCheckRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool? value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
          child: Row(
            children: [
              Expanded(child: Text(label)),
              Radio<bool>(
                value: true,
                groupValue: value,
                onChanged: (choice) {
                  if (choice != null) onChanged(choice);
                },
              ),
              const Text('Pass'),
              Radio<bool>(
                value: false,
                groupValue: value,
                onChanged: (choice) {
                  if (choice != null) onChanged(choice);
                },
              ),
              const Text('Issue'),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartCheckResultsDialog extends StatelessWidget {
  const _StartCheckResultsDialog({
    required this.result,
    required this.onRequestOverride,
  });

  final OperatorStartCheckResult result;
  final VoidCallback? onRequestOverride;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.rule_folder_outlined),
          SizedBox(width: 10),
          Expanded(child: Text('Start check results')),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppMessage(
                type: result.canStart
                    ? AppMessageType.success
                    : AppMessageType.error,
                title: result.canStart
                    ? 'Ready to start service'
                    : 'Some checks failed',
                message: result.canStart
                    ? 'All required checks passed.'
                    : '${result.failed.length} checks need attention before work can start.',
              ),
              const SizedBox(height: 12),
              for (final check in result.checks)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    check.passed
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    color: check.passed
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                  title: Text(check.label),
                  subtitle: check.detail == null ? null : Text(check.detail!),
                ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actions: [
        if (!result.canStart && result.overrideAllowed)
          AppDialogActions(
            onCancel: () => Navigator.of(context).pop(),
            onConfirm: () {
              Navigator.of(context).pop();
              onRequestOverride?.call();
            },
            cancelLabel: 'Close',
            confirmLabel: 'Request Override',
          )
        else
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
      ],
    );
  }
}

class _OverrideReasonDialog extends StatefulWidget {
  const _OverrideReasonDialog();

  @override
  State<_OverrideReasonDialog> createState() => _OverrideReasonDialogState();
}

class _OverrideReasonDialogState extends State<_OverrideReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Request Start Override'),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Reason',
          hintText: 'Explain why the start check should be overridden',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Send'),
        ),
      ],
    );
  }
}

class _LocationFact extends StatelessWidget {
  const _LocationFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
