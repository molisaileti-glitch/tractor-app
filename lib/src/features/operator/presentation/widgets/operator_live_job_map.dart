import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../additional_data/location/data/repositories/geolocator_location_repository.dart';
import '../../../../additional_data/location/domain/entities/device_location.dart';
import '../../../../additional_data/location/domain/repositories/location_repository.dart';
import '../../../../additional_data/location/domain/usecases/check_plot_geofence.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../../domain/entities/operator_job.dart';
import 'operator_location_evidence_collector.dart';
import 'operator_phone_location_stabilizer.dart';
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
  DeviceLocation? _verifiedPhone;
  DeviceLocation? _fieldEvidence;
  String? _phoneError;
  String? _phoneQualityMessage;
  Timer? _timer;
  StreamSubscription<DeviceLocation>? _locationSubscription;
  StreamSubscription<DeviceLocation>? _verificationSubscription;
  Timer? _verificationTimer;
  Completer<OperatorEvidenceUpdate>? _verificationCompleter;
  Future<OperatorEvidenceUpdate>? _verificationFuture;
  Future<void>? _refreshing;
  bool _foreground = true;
  bool _routeIsCurrent = true;
  final _locationStabilizer = OperatorPhoneLocationStabilizer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncRouteActivity();
        if (_routeIsCurrent) {
          unawaited(refresh(reloadJob: widget.refreshOnOpen));
        }
      }
    });
  }

  void _start() {
    if (!_foreground || !_routeIsCurrent) return;
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
      if (widget.pollingEnabled && needsLiveUpdates) {
        unawaited(refresh(refreshPhone: false));
      }
    });
  }

  void _startLocationTracking() {
    if (!_foreground ||
        !_routeIsCurrent ||
        _locationSubscription != null ||
        _verificationSubscription != null ||
        _verificationCompleter != null) {
      return;
    }
    late final StreamSubscription<DeviceLocation> subscription;
    subscription = widget.locationRepository.watchLocation().listen(
      _applyPhoneLocation,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('[Operator GPS filter] stream_error=$error');
        if (mounted && _foreground && _routeIsCurrent) {
          setState(() {
            _phoneQualityMessage =
                'Live GPS updates paused. Pull to refresh the location.';
          });
        }
      },
      onDone: () {
        if (identical(_locationSubscription, subscription)) {
          _locationSubscription = null;
        }
      },
    );
    _locationSubscription = subscription;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    if (_routeIsCurrent == isCurrent) return;
    _routeIsCurrent = isCurrent;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncRouteActivity();
    });
  }

  void _syncRouteActivity() {
    _routeIsCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    if (_foreground && _routeIsCurrent) {
      _start();
      _startLocationTracking();
      return;
    }
    _timer?.cancel();
    _timer = null;
    _cancelVerification();
    final subscription = _locationSubscription;
    _locationSubscription = null;
    unawaited(subscription?.cancel());
  }

  Future<void> refresh({bool reloadJob = true, bool refreshPhone = true}) {
    if (!mounted ||
        !_foreground ||
        !(ModalRoute.of(context)?.isCurrent ?? true)) {
      return Future.value();
    }
    return _refreshing ??= _refresh(
      reloadJob: reloadJob,
      refreshPhone: refreshPhone,
    ).whenComplete(() => _refreshing = null);
  }

  Future<void> _refresh({
    required bool reloadJob,
    required bool refreshPhone,
  }) async {
    try {
      await Future.wait<void>([
        if (refreshPhone) _readPhone(),
        if (reloadJob)
          if (widget.refreshPath)
            widget.repository.refreshWorkProgress(widget.jobId)
          else
            widget.repository.refreshJobDetail(widget.jobId).then((_) {}),
      ]);
      if (mounted &&
          _foreground &&
          (ModalRoute.of(context)?.isCurrent ?? true)) {
        await widget.onLocationUpdated?.call(
          currentFieldEvidence() ?? _freshVerifiedPhone,
        );
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
    if (result is LocationSuccess) {
      _applyPhoneLocation(result.location);
    } else if (result is LocationUnavailable) {
      setState(() {
        _locationStabilizer.reset();
        _phone = null;
        _verifiedPhone = null;
        _phoneError = result.failure.message;
        _phoneQualityMessage = null;
      });
    }
  }

  void _applyPhoneLocation(DeviceLocation rawLocation) {
    if (!mounted || !_foreground || !_routeIsCurrent) return;
    final update = _locationStabilizer.add(rawLocation);
    setState(() {
      _phone = update.displayLocation;
      _verifiedPhone = update.verifiedLocation;
      _phoneError = null;
      _phoneQualityMessage = update.message;
    });
    debugPrint(
      '[Operator GPS filter] decision=${update.decision.name}; '
      'movement_m=${update.distanceMeters.toStringAsFixed(1)}; '
      'accuracy_m=${rawLocation.accuracyMeters.toStringAsFixed(1)}; '
      'speed_mps=${rawLocation.speedMetersPerSecond.toStringAsFixed(1)}; '
      'mocked=${rawLocation.isMocked}; '
      'usable_for_checks=${update.verifiedLocation != null}',
    );
  }

  DeviceLocation? get _freshVerifiedPhone {
    final phone = _verifiedPhone;
    if (phone == null) return null;
    final age = DateTime.now().difference(phone.recordedAt).inSeconds;
    return age >= -30 && age <= 15 ? phone : null;
  }

  DeviceLocation? currentFieldEvidence({
    Duration maximumAge = const Duration(seconds: 30),
  }) {
    final evidence = _fieldEvidence;
    if (evidence == null) return null;
    final age = DateTime.now().difference(evidence.recordedAt).inSeconds;
    return age >= -30 && age <= maximumAge.inSeconds ? evidence : null;
  }

  Future<OperatorEvidenceUpdate> acquireFieldEvidence({
    required double maximumAccuracyMeters,
    required Duration maximumFixAge,
  }) {
    return _verificationFuture ??= _acquireFieldEvidence(
      maximumAccuracyMeters: maximumAccuracyMeters,
      maximumFixAge: maximumFixAge,
    ).whenComplete(() => _verificationFuture = null);
  }

  Future<OperatorEvidenceUpdate> _acquireFieldEvidence({
    required double maximumAccuracyMeters,
    required Duration maximumFixAge,
  }) async {
    final normalSubscription = _locationSubscription;
    _locationSubscription = null;
    await normalSubscription?.cancel();
    final collector = OperatorLocationEvidenceCollector(
      maximumAccuracyMeters: maximumAccuracyMeters,
      maximumFixAge: Duration(seconds: maximumFixAge.inSeconds.clamp(1, 30)),
    );
    if (mounted) {
      setState(() {
        _phoneError = null;
        _phoneQualityMessage = 'Collecting reliable GPS readings: 0/3.';
      });
    }

    OperatorEvidenceUpdate result;
    try {
      result = await _collectVerificationPhase(
        collector: collector,
        stream: _verificationLocationStream(),
        timeout: const Duration(seconds: 20),
      );
      if (!result.isReady &&
          mounted &&
          _foreground &&
          _routeIsCurrent &&
          defaultTargetPlatform == TargetPlatform.android) {
        if (mounted) {
          setState(() {
            _phoneQualityMessage =
                'The normal Android provider did not establish a stable '
                'position. Trying the tablet GPS provider.';
          });
        }
        result = await _collectVerificationPhase(
          collector: collector,
          stream: _verificationLocationStream(forceNativeProvider: true),
          timeout: const Duration(seconds: 25),
        );
      }
      if (result.location != null) {
        _fieldEvidence = result.location;
        _verifiedPhone = result.location;
        await widget.onLocationUpdated?.call(result.location);
      }
      if (mounted) {
        setState(() {
          _phoneQualityMessage = result.message;
          if (!result.isReady) {
            _phoneError =
                'A reliable GPS position was not established. Keep the '
                'tablet in open sky and try again.';
          }
        });
      }
      return result;
    } finally {
      _verificationTimer?.cancel();
      _verificationTimer = null;
      await _verificationSubscription?.cancel();
      _verificationSubscription = null;
      _verificationCompleter = null;
      if (mounted && _foreground && _routeIsCurrent) {
        _startLocationTracking();
      }
    }
  }

  Stream<DeviceLocation> _verificationLocationStream({
    bool forceNativeProvider = false,
  }) {
    final repository = widget.locationRepository;
    if (repository is VerificationLocationRepository) {
      return repository.watchVerificationLocation(
        forceNativeProvider: forceNativeProvider,
      );
    }
    return repository.watchLocation();
  }

  Future<OperatorEvidenceUpdate> _collectVerificationPhase({
    required OperatorLocationEvidenceCollector collector,
    required Stream<DeviceLocation> stream,
    required Duration timeout,
  }) async {
    final completer = Completer<OperatorEvidenceUpdate>();
    _verificationCompleter = completer;
    var latest = OperatorEvidenceUpdate(
      decision: OperatorEvidenceDecision.collecting,
      acceptedSamples: collector.samples.length,
      requiredSamples: collector.requiredSamples,
      message:
          'Reliable GPS readings: ${collector.samples.length}/${collector.requiredSamples}.',
    );
    void finish(OperatorEvidenceUpdate value) {
      if (!completer.isCompleted) completer.complete(value);
    }

    _verificationTimer = Timer(timeout, () => finish(latest));
    late final StreamSubscription<DeviceLocation> subscription;
    subscription = stream.listen(
      (rawLocation) {
        if (!mounted || !_foreground || !_routeIsCurrent) {
          finish(latest);
          return;
        }
        _applyPhoneLocation(rawLocation);
        latest = collector.add(rawLocation);
        if (mounted) {
          setState(() => _phoneQualityMessage = latest.message);
        }
        debugPrint(
          '[Operator GPS evidence] decision=${latest.decision.name}; '
          'samples=${latest.acceptedSamples}/${latest.requiredSamples}; '
          'accuracy_m=${rawLocation.accuracyMeters.toStringAsFixed(1)}',
        );
        if (latest.isReady) finish(latest);
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('[Operator GPS evidence] stream_error=$error');
        finish(
          OperatorEvidenceUpdate(
            decision: OperatorEvidenceDecision.rejectedInvalid,
            acceptedSamples: collector.samples.length,
            requiredSamples: collector.requiredSamples,
            message: 'Android could not provide verification GPS: $error',
          ),
        );
      },
      onDone: () => finish(latest),
    );
    _verificationSubscription = subscription;
    final result = await completer.future;
    _verificationTimer?.cancel();
    _verificationTimer = null;
    await subscription.cancel();
    if (identical(_verificationSubscription, subscription)) {
      _verificationSubscription = null;
    }
    return result;
  }

  void _cancelVerification() {
    _verificationTimer?.cancel();
    _verificationTimer = null;
    final completer = _verificationCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(
        const OperatorEvidenceUpdate(
          decision: OperatorEvidenceDecision.collecting,
          acceptedSamples: 0,
          requiredSamples: 3,
          message: 'GPS verification stopped because this screen is hidden.',
        ),
      );
    }
    _verificationCompleter = null;
    unawaited(_verificationSubscription?.cancel());
    _verificationSubscription = null;
  }

  @override
  void didUpdateWidget(covariant OperatorLiveJobMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.jobId != widget.jobId ||
        oldWidget.locationRepository != widget.locationRepository) {
      unawaited(_locationSubscription?.cancel());
      _locationSubscription = null;
      _locationStabilizer.reset();
      _phone = null;
      _verifiedPhone = null;
      _fieldEvidence = null;
      _phoneQualityMessage = null;
      if (_routeIsCurrent) _startLocationTracking();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) {
      _syncRouteActivity();
    } else {
      _syncRouteActivity();
      _locationStabilizer.reset();
      _phone = null;
      _verifiedPhone = null;
      _fieldEvidence = null;
      _phoneQualityMessage = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cancelVerification();
    unawaited(_locationSubscription?.cancel());
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
      final phone = _freshVerifiedPhone;
      final geofence = const CheckPlotGeofence();
      final phoneGeofence = phone == null
          ? null
          : geofence(plot: job.plot, location: phone);
      final tractorGeofence = tracker?.isLive != true
          ? null
          : geofence(
              plot: job.plot,
              location: DeviceLocation(
                latitude: tracker!.latitude,
                longitude: tracker.longitude,
                accuracyMeters: 0,
                recordedAt: DateTime.now(),
              ),
            );
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
            Text('Operator GPS: ${_geofenceLabel(phoneGeofence)}.'),
            Text('Tractor GPS: ${_geofenceLabel(tractorGeofence)}.'),
            const Text(
              'Boundary estimates are for guidance. Run Start Check for the server result and configured tolerance.',
            ),
          ],
          if (_phoneError != null)
            Text('Operator location unavailable: $_phoneError'),
          if (_phoneQualityMessage != null) Text(_phoneQualityMessage!),
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

  String _geofenceLabel(PlotGeofenceResult? result) {
    if (result == null) return 'current position unavailable';
    final distance = result.distanceFromPlotMeters.isFinite
        ? '${result.distanceFromPlotMeters.toStringAsFixed(0)} m'
        : 'an unknown distance';
    return switch (result.state) {
      PlotGeofenceState.insideBoundary => 'inside the mapped farm boundary',
      PlotGeofenceState.withinTolerance =>
        '$distance outside the boundary and within configured tolerance',
      PlotGeofenceState.uncertain =>
        'near the boundary; GPS accuracy makes the result uncertain',
      PlotGeofenceState.outsideAllowedArea =>
        '$distance outside the allowed farm area',
      PlotGeofenceState.unavailable => 'boundary result unavailable',
    };
  }
}
