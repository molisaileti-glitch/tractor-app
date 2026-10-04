import 'package:flutter/material.dart';

import '../../../../core/location/data/repositories/geolocator_location_repository.dart';
import '../../../../core/location/domain/entities/device_location.dart';
import '../../../../core/location/domain/repositories/location_repository.dart';
import '../../../../core/location/domain/usecases/check_plot_geofence.dart';
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
  bool _requestingOverride = false;
  bool _submittingStart = false;
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
  void initState() {
    super.initState();
    _refreshLocation();
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
    final hasArrived = job.status == OperatorJobStatus.arrived ||
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
                ),
                const SizedBox(height: 16),
                OperatorStatusPill(status: job.status),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _checkingLocation ? null : _refreshLocation,
                  icon: const Icon(Icons.gps_fixed),
                  label: Text(
                    _checkingLocation ? 'Checking GPS...' : 'Check Location',
                  ),
                ),
                const SizedBox(height: 10),
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
                if (_locationError != null) ...[
                  const SizedBox(height: 10),
                  OperatorCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_disabled_outlined,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _locationError!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                if (!isInsideFarm) ...[
                  OutlinedButton.icon(
                    onPressed: _checkingLocation ? null : _refreshLocation,
                    icon: const Icon(Icons.near_me_outlined),
                    label: const Text('Refresh Route'),
                  ),
                  const SizedBox(height: 10),
                ],
                FilledButton.tonalIcon(
                  onPressed:
                      hasArrived ||
                          _submittingArrival ||
                          _geofenceResult == null
                      ? null
                      : _recordArrival,
                  icon: const Icon(Icons.flag_outlined),
                  label: Text(
                    hasArrived
                        ? 'Arrival Recorded'
                        : _submittingArrival
                        ? 'Recording arrival...'
                        : 'Record Arrival',
                  ),
                ),
                const SizedBox(height: 10),
                if (hasArrived) ...[
                  OutlinedButton.icon(
                    onPressed:
                        _submittingInspection || _geofenceResult == null
                        ? null
                        : _recordInspection,
                    icon: const Icon(Icons.fact_check_outlined),
                    label: Text(
                      _submittingInspection
                          ? 'Recording inspection...'
                          : 'Record Inspection',
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonalIcon(
                    onPressed: _runningStartCheck || _geofenceResult == null
                        ? null
                        : _runStartCheck,
                    icon: const Icon(Icons.rule_folder_outlined),
                    label: Text(
                      _runningStartCheck
                          ? 'Running start check...'
                          : 'Run Start Check',
                    ),
                  ),
                  if (_startCheck != null) ...[
                    const SizedBox(height: 10),
                    _StartCheckCard(
                      result: _startCheck!,
                      requestingOverride: _requestingOverride,
                      onRequestOverride: _startCheck!.overrideAllowed
                          ? _requestOverride
                          : null,
                    ),
                  ],
                  const SizedBox(height: 10),
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
                    decoration: const InputDecoration(labelText: 'Implement'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: _geofenceResult != null &&
                            (_startCheck?.canStart ?? false) &&
                            !_submittingStart
                        ? _startJob
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      _submittingStart ? 'Starting...' : 'Start Ploughing',
                    ),
                  ),
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
    if (isInsideFarm) {
      return hasArrived
          ? 'You are inside the assigned farm area.'
          : 'You appear to be at the assigned farm. Record arrival before starting service.';
    }
    final distanceText = distanceMeters == null || distanceMeters.isInfinite
        ? 'unknown'
        : '${distanceMeters.toStringAsFixed(0)} m';
    return hasArrived
        ? 'You are outside the assigned farm. You must be at the registered plot before starting this service. Distance from plot: $distanceText.'
        : 'Follow the route guide to the assigned farm. Distance from plot: $distanceText.';
  }

  Future<void> _refreshLocation() async {
    final job = widget.repository.maybeJobById(widget.jobId);
    if (job == null) return;
    setState(() {
      _checkingLocation = true;
      _locationError = null;
    });

    final result = await _phoneLocationRepository.getCurrentLocation();
    if (!mounted) return;

    if (result is LocationSuccess) {
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
      setState(() {
        _geofenceResult = null;
        _locationError = result.failure.message;
        _checkingLocation = false;
      });
    }
  }

  Future<void> _recordArrival() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _submittingArrival = true);
    final arrived = await widget.repository.arriveJob(
      widget.jobId,
      phone: _geofenceResult?.location,
    );
    if (!mounted) return;
    setState(() => _submittingArrival = false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          arrived
              ? 'Arrival recorded.'
              : widget.repository.lastActionError ?? 'Could not record arrival.',
        ),
      ),
    );
  }

  Future<void> _startJob() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
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
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.repository.lastActionError ??
                'The backend did not allow this job to start.',
          ),
        ),
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
    final messenger = ScaffoldMessenger.of(context);
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
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.repository.lastActionError ?? 'Start check failed.',
          ),
        ),
      );
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.canStart
              ? 'Start check passed. You can start ploughing.'
              : 'Start check failed. Review the checklist.',
        ),
      ),
    );
  }

  Future<void> _requestOverride() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _OverrideReasonDialog(),
    );
    if (reason == null || reason.trim().isEmpty) return;
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _requestingOverride = true);
    final ok = await widget.repository.requestStartOverride(
      jobId: widget.jobId,
      reason: reason.trim(),
      phone: _geofenceResult?.location,
    );
    if (!mounted) return;
    setState(() => _requestingOverride = false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Override request sent to the union.'
              : widget.repository.lastActionError ??
                    'Could not request override.',
        ),
      ),
    );
  }

  Future<void> _recordInspection() async {
    final job = widget.repository.maybeJobById(widget.jobId);
    if (job == null) return;
    final inspection = await showModalBottomSheet<_InspectionPayload>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _InspectionSheet(),
    );
    if (inspection == null) return;
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
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
    setState(() => _submittingInspection = false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Inspection recorded.'
              : widget.repository.lastActionError ??
                    'Inspection could not be recorded.',
        ),
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

class _InspectionSheet extends StatefulWidget {
  const _InspectionSheet();

  @override
  State<_InspectionSheet> createState() => _InspectionSheetState();
}

class _InspectionSheetState extends State<_InspectionSheet> {
  final _fuelController = TextEditingController();
  final _hourMeterController = TextEditingController();
  final _defectsController = TextEditingController();
  bool _isFit = true;
  final Map<String, bool> _checks = {
    'engine_oil': true,
    'coolant': true,
    'fuel': true,
    'tyres': true,
    'brakes': true,
    'lights': true,
    'hydraulics': true,
    'implement': true,
    'leaks': true,
    'tracker': true,
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pre-start Inspection',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            for (final entry in _checks.entries)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: entry.value,
                title: Text(_checkLabel(entry.key)),
                onChanged: (value) {
                  setState(() {
                    _checks[entry.key] = value ?? false;
                    _isFit = !_checks.values.contains(false);
                  });
                },
              ),
            const SizedBox(height: 8),
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
              decoration: const InputDecoration(
                labelText: 'Defects / notes',
              ),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isFit,
              title: const Text('Tractor is fit for work'),
              onChanged: (value) => setState(() => _isFit = value),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _submit,
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final fuel = int.tryParse(_fuelController.text.trim());
    final hourMeter = num.tryParse(_hourMeterController.text.trim());
    final defects = _defectsController.text.trim();
    Navigator.of(context).pop(
      _InspectionPayload(
        checklist: Map<String, Object?>.from(_checks),
        fuelLevelPct: fuel,
        hourMeter: hourMeter,
        defects: defects.isEmpty ? null : defects,
        isFit: _isFit,
      ),
    );
  }

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

class _StartCheckCard extends StatelessWidget {
  const _StartCheckCard({
    required this.result,
    required this.requestingOverride,
    required this.onRequestOverride,
  });

  final OperatorStartCheckResult result;
  final bool requestingOverride;
  final VoidCallback? onRequestOverride;

  @override
  Widget build(BuildContext context) {
    final color = result.canStart
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    return OperatorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.canStart
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                color: color,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.canStart
                      ? 'Ready to start service'
                      : 'Not ready to start',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (result.failed.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Failed: ${result.failed.join(', ')}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
          const SizedBox(height: 10),
          for (final check in result.checks) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  check.passed
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  size: 20,
                  color: check.passed
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          check.label,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        if (check.detail != null)
                          Text(
                            check.detail!,
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.62),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (!result.canStart && result.overrideAllowed) ...[
            const SizedBox(height: 6),
            const Text(
              'Override may be requested from the union.',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: requestingOverride ? null : onRequestOverride,
              icon: const Icon(Icons.lock_open_outlined),
              label: Text(
                requestingOverride
                    ? 'Sending override request...'
                    : 'Request Override',
              ),
            ),
          ] else if (!result.canStart) ...[
            const SizedBox(height: 6),
            const Text(
              'A union override is not allowed for these failed checks.',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ],
      ),
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
