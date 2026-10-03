import 'package:flutter/material.dart';

import '../../../../core/location/data/repositories/geolocator_location_repository.dart';
import '../../../../core/location/data/repositories/mock_location_repository.dart';
import '../../../../core/location/domain/entities/device_location.dart';
import '../../../../core/location/domain/repositories/location_repository.dart';
import '../../../../core/location/domain/usecases/check_plot_geofence.dart';
import '../../../farmer/domain/entities/farm_plot.dart';
import '../../data/repositories/operator_local_repository.dart';
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

  bool _useSimulation = false;
  bool _simulateInsideFarm = true;
  bool _checkingLocation = false;
  bool _submittingInspection = false;
  bool _submittingStart = false;
  PlotGeofenceResult? _geofenceResult;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _refreshLocation();
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.repository.jobById(widget.jobId);
    final isInsideFarm = _geofenceResult?.isInside ?? false;
    final distanceMeters = _geofenceResult?.distanceFromPlotMeters;
    return Scaffold(
      appBar: AppBar(title: Text(job.plot.name.toUpperCase())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OperatorMapCard(),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Use simulated GPS for testing'),
                  subtitle: const Text('Turn off on a real phone.'),
                  value: _useSimulation,
                  onChanged: (value) {
                    setState(() => _useSimulation = value);
                    _refreshLocation();
                  },
                ),
                if (_useSimulation)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Simulate tractor inside assigned farm'),
                    value: _simulateInsideFarm,
                    onChanged: (value) {
                      setState(() => _simulateInsideFarm = value);
                      _refreshLocation();
                    },
                  ),
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
                    onPressed: () {},
                    icon: const Icon(Icons.near_me_outlined),
                    label: const Text('View Directions'),
                  ),
                  const SizedBox(height: 10),
                ],
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
                FilledButton.icon(
                  onPressed: _geofenceResult != null && !_submittingStart
                      ? _startJob
                      : null,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(_submittingStart ? 'Starting...' : 'Start Job'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusText({
    required bool isInsideFarm,
    required double? distanceMeters,
  }) {
    if (_checkingLocation) {
      return 'Checking phone GPS against the assigned farm boundary.';
    }
    if (_locationError != null) {
      return 'Location could not be verified.';
    }
    if (_geofenceResult == null) {
      return 'Check location before starting this service.';
    }
    if (isInsideFarm) {
      return 'You are inside the assigned farm area.';
    }
    final distanceText = distanceMeters == null || distanceMeters.isInfinite
        ? 'unknown'
        : '${distanceMeters.toStringAsFixed(0)} m';
    return 'You are outside the assigned farm. You must be at the registered plot before starting this service. Distance from plot: $distanceText.';
  }

  Future<void> _refreshLocation() async {
    final job = widget.repository.jobById(widget.jobId);
    setState(() {
      _checkingLocation = true;
      _locationError = null;
    });

    final repository = _useSimulation
        ? MockLocationRepository(
            location: _simulatedLocation(
              plot: job.plot,
              insideFarm: _simulateInsideFarm,
            ),
          )
        : _phoneLocationRepository;
    final result = await repository.getCurrentLocation();
    if (!mounted) return;

    switch (result) {
      case LocationSuccess(:final location):
        setState(() {
          _geofenceResult = _checkPlotGeofence(
            plot: job.plot,
            location: location,
          );
          _checkingLocation = false;
        });
      case LocationUnavailable(:final failure):
        setState(() {
          _geofenceResult = null;
          _locationError = failure.message;
          _checkingLocation = false;
        });
    }
  }

  DeviceLocation _simulatedLocation({
    required FarmPlot plot,
    required bool insideFarm,
  }) {
    if (plot.boundaryPoints.isEmpty) {
      return DeviceLocation(
        latitude: insideFarm ? -6.7971107 : -6.1709,
        longitude: insideFarm ? 39.2488665 : 35.7409,
        accuracyMeters: insideFarm ? 8 : 18,
        recordedAt: DateTime.now(),
      );
    }
    final latitude =
        plot.boundaryPoints
            .map((point) => point.latitude)
            .reduce((value, element) => value + element) /
        plot.boundaryPoints.length;
    final longitude =
        plot.boundaryPoints
            .map((point) => point.longitude)
            .reduce((value, element) => value + element) /
        plot.boundaryPoints.length;

    return DeviceLocation(
      latitude: insideFarm ? latitude : latitude + 0.02,
      longitude: insideFarm ? longitude : longitude + 0.02,
      accuracyMeters: insideFarm ? 8 : 18,
      recordedAt: DateTime.now(),
    );
  }

  Future<void> _startJob() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final location = _geofenceResult?.location;
    setState(() => _submittingStart = true);
    final arrived = await widget.repository.arriveJob(
      widget.jobId,
      phone: location,
    );
    if (!mounted) return;
    if (!arrived) {
      setState(() => _submittingStart = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.repository.lastActionError ?? 'Could not record arrival.',
          ),
        ),
      );
      return;
    }
    final started = await widget.repository.startJob(
      widget.jobId,
      phone: location,
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

  Future<void> _recordInspection() async {
    final job = widget.repository.jobById(widget.jobId);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _submittingInspection = true);
    final ok = await widget.repository.recordInspection(
      tractorId: job.tractorId,
      jobId: job.id,
      checklist: const {
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
      },
      isFit: true,
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
