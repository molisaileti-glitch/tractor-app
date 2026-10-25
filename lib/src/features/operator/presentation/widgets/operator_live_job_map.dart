import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../additional_data/location/data/repositories/geolocator_location_repository.dart';
import '../../../../additional_data/location/domain/entities/device_location.dart';
import '../../../../additional_data/location/domain/repositories/location_repository.dart';
import '../../../../additional_data/location/domain/usecases/check_plot_geofence.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../../domain/entities/operator_job.dart';
import 'operator_widgets.dart';

/// Phone coordinates come only from this device's GPS; tractor coordinates
/// come only from the assigned tractor's backend tracker.
class OperatorLiveJobMap extends StatefulWidget {
  const OperatorLiveJobMap({
    super.key,
    required this.repository,
    required this.jobId,
    this.fill = false,
    this.routeEnabled = true,
    this.refreshPath = true,
    this.refreshOnOpen = true,
    this.pollingEnabled = true,
    this.onLocationUpdated,
    this.locationRepository = const GeolocatorLocationRepository(),
  });

  final OperatorLocalRepository repository;
  final String jobId;
  final bool fill;
  final bool routeEnabled;
  final bool refreshPath;
  final bool refreshOnOpen;
  final bool pollingEnabled;
  final Future<void> Function(DeviceLocation? phone)? onLocationUpdated;
  final LocationRepository locationRepository;

  @override
  State<OperatorLiveJobMap> createState() => OperatorLiveJobMapState();
}

class OperatorLiveJobMapState extends State<OperatorLiveJobMap>
    with WidgetsBindingObserver {
  DeviceLocation? _phone;
  String? _phoneError;
  Timer? _timer;
  Future<void>? _refreshing;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _start();
        unawaited(refresh(reloadJob: widget.refreshOnOpen));
      }
    });
  }

  void _start() {
    _timer ??= Timer.periodic(const Duration(seconds: 12), (_) {
      final job = widget.repository.maybeJobById(widget.jobId);
      final needsLiveUpdates =
          job != null &&
          [
            OperatorJobStatus.enRoute,
            OperatorJobStatus.arrived,
            OperatorJobStatus.inProgress,
            OperatorJobStatus.paused,
          ].contains(job.status);
      if (widget.pollingEnabled && needsLiveUpdates) unawaited(refresh());
    });
  }

  Future<void> refresh({bool reloadJob = true}) {
    if (!mounted ||
        !_foreground ||
        !(ModalRoute.of(context)?.isCurrent ?? true)) {
      return Future.value();
    }
    return _refreshing ??= _refresh(
      reloadJob: reloadJob,
    ).whenComplete(() => _refreshing = null);
  }

  Future<void> _refresh({required bool reloadJob}) async {
    try {
      await Future.wait<void>([
        _readPhone(),
        if (reloadJob)
          if (widget.refreshPath)
            widget.repository.refreshWorkProgress(widget.jobId)
          else
            widget.repository.refreshJobDetail(widget.jobId).then((_) {}),
      ]);
      if (mounted &&
          _foreground &&
          (ModalRoute.of(context)?.isCurrent ?? true)) {
        await widget.onLocationUpdated?.call(_phone);
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _phoneError =
              'Could not refresh this job map. Pull to refresh and try again.',
        );
      }
    }
  }

  Future<void> _readPhone() async {
    final result = await widget.locationRepository.getCurrentLocation();
    if (!mounted || !_foreground) return;
    setState(() {
      _phone = result is LocationSuccess ? result.location : null;
      _phoneError = result is LocationUnavailable
          ? result.failure.message
          : null;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) {
      _start();
    } else {
      _timer?.cancel();
      _timer = null;
      _phone = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.repository,
    builder: (context, _) {
      final job = widget.repository.maybeJobById(widget.jobId);
      if (job == null) return const SizedBox.shrink();
      final tracker = widget.repository.trackerPositionFor(job.tractorId);
      final phone = _phone;
      final geofence = const CheckPlotGeofence();
      final phoneInside = phone == null
          ? null
          : geofence(plot: job.plot, location: phone).isInside;
      final tractorInside = tracker?.isLive != true
          ? null
          : geofence(
              plot: job.plot,
              location: DeviceLocation(
                latitude: tracker!.latitude,
                longitude: tracker.longitude,
                accuracyMeters: 0,
                recordedAt: DateTime.now(),
              ),
            ).isInside;
      final map = OperatorMapCard(
        job: job,
        fill: widget.fill,
        showTrack: true,
        tractorPosition: widget.repository.trackerPositionFor(job.tractorId),
        routeFromLatitude: _phone?.latitude,
        routeFromLongitude: _phone?.longitude,
        phoneRecordedAt: _phone?.recordedAt,
        phoneAccuracyMeters: _phone?.accuracyMeters,
        routeEnabled: widget.routeEnabled,
        label: 'JOB MAP',
      );
      if (widget.fill) return map;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          map,
          const SizedBox(height: 8),
          if (job.plot.boundaryPoints.length >= 3) ...[
            Text(
              'Operator GPS: ${phoneInside == null
                  ? 'unavailable'
                  : phoneInside
                  ? 'inside farm boundary'
                  : 'outside farm boundary'}.',
            ),
            Text(
              'Tractor GPS: ${tractorInside == null
                  ? 'current position unavailable'
                  : tractorInside
                  ? 'inside farm boundary'
                  : 'outside farm boundary'}.',
            ),
            const Text(
              'Boundary estimates are for guidance. Run Start Check for the server result and configured tolerance.',
            ),
          ],
          if (_phoneError != null)
            Text('Operator location unavailable: $_phoneError'),
          if (job.plot.boundaryPoints.isEmpty)
            const Text(
              'Farm coordinates are unavailable. Ask the union to check the plot location.',
            ),
          if (job.plot.boundaryPoints.length == 1)
            const Text(
              'Only the farm centre is available. The backend checks whether work can start.',
            ),
          if (widget.routeEnabled)
            const Text(
              'Directions lead toward the plot centre. A dashed line shows direction only, not a road route.',
            ),
          Text(
            job.trackPoints.isEmpty
                ? 'No recorded tractor trail yet.'
                : 'Tractor trail: green inside the plot, red outside, grey unknown.',
          ),
        ],
      );
    },
  );
}
