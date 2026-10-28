import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../additional_data/location/data/repositories/geolocator_location_repository.dart';
import '../../../../additional_data/location/domain/entities/device_location.dart';
import '../../../../additional_data/location/domain/repositories/location_repository.dart';
import '../../../../additional_data/location/domain/usecases/check_plot_geofence.dart';
import '../../../../components/components.dart';
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
  bool _refreshingFromCard = false;
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
        OperatorEvidenceUpdate(
          decision: OperatorEvidenceDecision.collecting,
          acceptedSamples: 0,
          requiredSamples: 3,
          message: context.appText(
            'GPS verification stopped because this screen is hidden.',
          ),
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
        label: context.appText('JOB MAP'),
      );
      if (widget.fill) return map;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          map,
          const SizedBox(height: 10),
          _LocationReadinessCard(
            phone: phone,
            tracker: tracker,
            phoneGeofence: phoneGeofence,
            tractorGeofence: tractorGeofence,
            phoneError: _phoneError,
            phoneQualityMessage: _phoneQualityMessage,
            hasBoundary: job.plot.boundaryPoints.length >= 3,
            hasFarmCentre: job.plot.boundaryPoints.isNotEmpty,
            routeEnabled: widget.routeEnabled,
            hasTrack: job.trackPoints.isNotEmpty,
            refreshing: _refreshingFromCard,
            onRefresh: _refreshFromCard,
          ),
        ],
      );
    },
  );

  Future<void> _refreshFromCard() async {
    if (_refreshingFromCard) return;
    setState(() => _refreshingFromCard = true);
    try {
      await refresh(reloadJob: true, refreshPhone: true);
    } finally {
      if (mounted) setState(() => _refreshingFromCard = false);
    }
  }
}

class _LocationReadinessCard extends StatelessWidget {
  const _LocationReadinessCard({
    required this.phone,
    required this.tracker,
    required this.phoneGeofence,
    required this.tractorGeofence,
    required this.phoneError,
    required this.phoneQualityMessage,
    required this.hasBoundary,
    required this.hasFarmCentre,
    required this.routeEnabled,
    required this.hasTrack,
    required this.refreshing,
    required this.onRefresh,
  });

  final DeviceLocation? phone;
  final TractorTrackerPosition? tracker;
  final PlotGeofenceResult? phoneGeofence;
  final PlotGeofenceResult? tractorGeofence;
  final String? phoneError;
  final String? phoneQualityMessage;
  final bool hasBoundary;
  final bool hasFarmCentre;
  final bool routeEnabled;
  final bool hasTrack;
  final bool refreshing;
  final VoidCallback onRefresh;

  bool get _operatorReady => phoneGeofence?.isWithinAllowedArea ?? false;
  bool get _tractorReady => tractorGeofence?.isWithinAllowedArea ?? false;

  @override
  Widget build(BuildContext context) {
    final ready = _operatorReady && _tractorReady;
    final scheme = Theme.of(context).colorScheme;
    final statusColor = ready ? scheme.primary : scheme.error;
    return OperatorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                ready ? Icons.verified_outlined : Icons.warning_amber_rounded,
                color: statusColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.appText('Location readiness'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Text(
                    context.appText(ready ? 'Ready' : 'Needs attention'),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _LocationReadinessRow(
            icon: Icons.person_pin_circle_outlined,
            title: context.appText('Operator GPS'),
            status: _statusTitle(context, phoneGeofence, isTractor: false),
            detail: _operatorDetail(context),
            state: _state(phoneGeofence),
          ),
          const Divider(height: 24),
          _LocationReadinessRow(
            icon: Icons.agriculture_outlined,
            title: context.appText('Tractor GPS'),
            status: _statusTitle(context, tractorGeofence, isTractor: true),
            detail: _tractorDetail(context),
            state: _state(tractorGeofence),
          ),
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 20, color: scheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.appText(
                        hasBoundary
                            ? 'Start Check will verify both positions using the server farm tolerance.'
                            : hasFarmCentre
                            ? 'Only the farm centre is available. Start Check will make the server decision.'
                            : 'Farm coordinates are unavailable. Ask the union to check the plot location.',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (routeEnabled || hasTrack) ...[
            const SizedBox(height: 10),
            Text(
              context.appText(
                hasTrack
                    ? 'The tractor trail uses green inside the farm, red outside and grey when unknown.'
                    : 'The tractor trail will appear after work begins.',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: refreshing ? null : onRefresh,
            child: AppButtonContent(
              label: context.appText('Refresh location'),
              loading: refreshing,
              loadingLabel: context.appText('Refreshing location...'),
              icon: Icons.refresh_rounded,
            ),
          ),
        ],
      ),
    );
  }

  _ReadinessState _state(PlotGeofenceResult? result) {
    if (result == null) return _ReadinessState.waiting;
    return result.isWithinAllowedArea
        ? _ReadinessState.ready
        : _ReadinessState.attention;
  }

  String _statusTitle(
    BuildContext context,
    PlotGeofenceResult? result, {
    required bool isTractor,
  }) {
    if (result == null) {
      return context.appText(
        isTractor ? 'Waiting for tractor location' : 'Location unavailable',
      );
    }
    return context.appText(switch (result.state) {
      PlotGeofenceState.insideBoundary => 'Inside the farm boundary',
      PlotGeofenceState.withinTolerance => 'Within farm tolerance',
      PlotGeofenceState.uncertain => 'GPS result is uncertain',
      PlotGeofenceState.outsideAllowedArea => 'Outside the allowed farm area',
      PlotGeofenceState.unavailable => 'Boundary result unavailable',
    });
  }

  String _operatorDetail(BuildContext context) {
    if (phoneError != null) return context.appText(phoneError!);
    if (phoneQualityMessage != null) {
      return context.appText(phoneQualityMessage!);
    }
    if (phone == null) return context.appText('No recent phone position.');
    final distance = phoneGeofence?.distanceFromPlotMeters;
    final distanceText = distance == null || !distance.isFinite
        ? null
        : '${distance.toStringAsFixed(0)} m from boundary';
    return [
      'Accuracy: ±${phone!.accuracyMeters.toStringAsFixed(0)} m',
      ?distanceText,
    ].join(' • ');
  }

  String _tractorDetail(BuildContext context) {
    final position = tracker;
    if (position == null) {
      return context.appText('No recent tracker position.');
    }
    final age = position.currentAgeSeconds;
    if (!position.isLive) {
      return age == null
          ? context.appText('No recent tracker position.')
          : 'Last tracker fix ${_ageLabel(age)} ago.';
    }
    final distance = tractorGeofence?.distanceFromPlotMeters;
    return distance == null || !distance.isFinite
        ? context.appText('Live tracker position received.')
        : '${distance.toStringAsFixed(0)} m from boundary • live tracker';
  }

  String _ageLabel(int seconds) {
    if (seconds < 60) return '$seconds sec';
    if (seconds < 3600) return '${seconds ~/ 60} min';
    return '${seconds ~/ 3600} hr';
  }
}

enum _ReadinessState { ready, waiting, attention }

class _LocationReadinessRow extends StatelessWidget {
  const _LocationReadinessRow({
    required this.icon,
    required this.title,
    required this.status,
    required this.detail,
    required this.state,
  });

  final IconData icon;
  final String title;
  final String status;
  final String detail;
  final _ReadinessState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (state) {
      _ReadinessState.ready => scheme.primary,
      _ReadinessState.waiting => scheme.tertiary,
      _ReadinessState.attention => scheme.error,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 2),
              Text(
                status,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              Text(detail, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
