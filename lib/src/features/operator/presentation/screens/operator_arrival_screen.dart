import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../additional_data/location/data/repositories/geolocator_location_repository.dart';
import '../../../../additional_data/location/domain/entities/device_location.dart';
import '../../../../additional_data/location/domain/repositories/location_repository.dart';
import '../../../../additional_data/location/domain/usecases/check_plot_geofence.dart';
import '../../../../components/components.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../../domain/entities/operator_job.dart';
import '../widgets/operator_widgets.dart';
import '../widgets/operator_live_job_map.dart';
import 'operator_progress_screen.dart';
import 'operator_job_photos_screen.dart';

class OperatorArrivalScreen extends StatefulWidget {
  const OperatorArrivalScreen({
    super.key,
    required this.repository,
    required this.jobId,
    this.locationRepository = const GeolocatorLocationRepository(),
  });

  final OperatorLocalRepository repository;
  final String jobId;
  final LocationRepository locationRepository;

  @override
  State<OperatorArrivalScreen> createState() => _OperatorArrivalScreenState();
}

class _OperatorArrivalScreenState extends State<OperatorArrivalScreen>
    with WidgetsBindingObserver {
  final CheckPlotGeofence _checkPlotGeofence = const CheckPlotGeofence();

  bool _checkingLocation = false;
  bool _submittingArrival = false;
  bool _submittingInspection = false;
  bool _runningStartCheck = false;
  bool _submittingStart = false;
  PlotGeofenceResult? _geofenceResult;
  OperatorStartCheckResult? _startCheck;
  String? _locationError;
  final _hourMeterController = TextEditingController();
  String? _selectedImplement;
  final _mapKey = GlobalKey<OperatorLiveJobMapState>();
  bool _pollingReadiness = false;
  bool _locationPromptShown = false;
  bool _openingLocationSettings = false;

  bool get _hasInspection => widget.repository.inspectedToday(
    widget.repository.maybeJobById(widget.jobId)?.tractorId ?? '',
  );
  bool get _readyForChecks =>
      !widget.repository.requiresInspection || _hasInspection;

  Future<void> _refreshReadiness(DeviceLocation? phone) async {
    if (_pollingReadiness ||
        _submittingStart ||
        _runningStartCheck ||
        !mounted ||
        !(ModalRoute.of(context)?.isCurrent ?? true)) {
      return;
    }
    _pollingReadiness = true;
    try {
      final job = widget.repository.maybeJobById(widget.jobId);
      if (job != null) {
        setState(() {
          _geofenceResult = phone == null
              ? null
              : _checkPlotGeofence(plot: job.plot, location: phone);
        });
      }
    } finally {
      _pollingReadiness = false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.repository.addListener(_repositoryChanged);
    final job = widget.repository.maybeJobById(widget.jobId);
    if (job != null) {
      unawaited(widget.repository.refreshInspection(job.tractorId));
      unawaited(widget.repository.refreshTrackerPositions());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_checkLocationService(showPrompt: true));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.repository.removeListener(_repositoryChanged);
    _hourMeterController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !_openingLocationSettings) return;
    _openingLocationSettings = false;
    unawaited(_checkLocationService(showPrompt: false));
  }

  Future<void> _checkLocationService({required bool showPrompt}) async {
    final controller = widget.locationRepository;
    if (controller is! LocationSettingsController) return;
    if (!mounted) return;
    final settingsController = controller as LocationSettingsController;
    final enabled = await settingsController.isLocationServiceEnabled();
    if (!mounted) return;
    if (enabled) {
      if (!showPrompt) unawaited(_refreshLocation());
      return;
    }
    setState(() {
      _locationError =
          'Device location is turned off. Turn it on to verify the farm boundary.';
    });
    if (!showPrompt || _locationPromptShown) return;
    _locationPromptShown = true;
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.location_off_outlined, size: 36),
        title: Text(context.appText('Turn on device location')),
        content: Text(
          context.appText(
            'SB Mechanization needs this tablet location to confirm that the operator and tractor are within the farm boundary.',
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        actions: [
          AppDialogActions(
            onCancel: () => Navigator.of(dialogContext).pop(false),
            onConfirm: () => Navigator.of(dialogContext).pop(true),
            cancelLabel: context.appText('Not now'),
            confirmLabel: context.appText('Open location settings'),
          ),
        ],
      ),
    );
    if (openSettings != true || !mounted) return;
    _openingLocationSettings = true;
    await settingsController.openLocationSettings();
  }

  void _repositoryChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final job = widget.repository.maybeJobById(widget.jobId);
    if (job == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.appText('Job unavailable'))),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              context.appText(
                'This job is no longer available in the operator assignment list.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      );
    }
    final isWithinAllowedArea = _geofenceResult?.isWithinAllowedArea ?? false;
    final hasArrived =
        job.status == OperatorJobStatus.arrived ||
        job.status == OperatorJobStatus.inProgress;
    final implementNames = widget.repository.implementNamesFor(job.tractorId);
    if (_selectedImplement != null &&
        !implementNames.contains(_selectedImplement)) {
      _selectedImplement = null;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(hasArrived ? 'ARRIVAL & START' : 'JOURNEY TO FARM'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _mapKey.currentState?.refresh() ?? Future<void>.value(),
            widget.repository.refreshInspection(job.tractorId),
            widget.repository.refreshTrackerPositions(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OperatorLiveJobMap(
                    locationRepository: widget.locationRepository,
                    key: _mapKey,
                    repository: widget.repository,
                    jobId: job.id,
                    refreshPath: false,
                    pollingEnabled: !_submittingStart,
                    onLocationUpdated: _refreshReadiness,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.topRight,
                    child: OperatorStatusPill(status: job.status),
                  ),
                  const SizedBox(height: 12),
                  OperatorCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isWithinAllowedArea
                              ? Icons.check_circle_outline
                              : Icons.warning_amber_outlined,
                          color: isWithinAllowedArea
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _statusText(
                              hasArrived: hasArrived,
                              result: _geofenceResult,
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
                            label: context.appText('Latitude'),
                            value: _geofenceResult!.location.latitude
                                .toStringAsFixed(6),
                          ),
                          _LocationFact(
                            label: context.appText('Longitude'),
                            value: _geofenceResult!.location.longitude
                                .toStringAsFixed(6),
                          ),
                          _LocationFact(
                            label: context.appText('Accuracy'),
                            value:
                                '${_geofenceResult!.location.accuracyMeters.toStringAsFixed(0)} m',
                          ),
                          _LocationFact(
                            label: context.appText('Farm tolerance'),
                            value:
                                '${job.plot.toleranceMeters.toStringAsFixed(0)} m',
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _WorkflowStep(
                    number: 1,
                    title: context.appText('Confirm your location'),
                    complete: _geofenceResult != null,
                    child: OutlinedButton(
                      onPressed: _checkingLocation ? null : _refreshLocation,
                      child: AppButtonContent(
                        loading: _checkingLocation,
                        loadingLabel: context.appText('Checking GPS...'),
                        label: context.appText(
                          _geofenceResult == null
                              ? 'Check Location'
                              : 'Refresh Location',
                        ),
                        icon: Icons.gps_fixed,
                      ),
                    ),
                  ),
                  if (!hasArrived) ...[
                    const SizedBox(height: 12),
                    _WorkflowStep(
                      number: 2,
                      title: context.appText('Travel and record arrival'),
                      complete: false,
                      child: Column(
                        children: [
                          Text(
                            context.appText(
                              'Both your phone and the assigned tractor must be within the farm boundary. The server checks GPS freshness, farm tolerance and proximity to the tractor.',
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: _checkingLocation
                                ? null
                                : _refreshLocation,
                            icon: const Icon(Icons.route_outlined),
                            label: Text(context.appText('Refresh Route')),
                          ),
                          const SizedBox(height: 10),
                          FilledButton(
                            onPressed: _submittingArrival
                                ? null
                                : _recordArrival,
                            child: AppButtonContent(
                              loading: _submittingArrival,
                              loadingLabel: context.appText(
                                'Recording arrival...',
                              ),
                              label: context.appText('Record Arrival'),
                              icon: Icons.flag_outlined,
                              progressColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (job.startOverride != null) ...[
                    const SizedBox(height: 12),
                    AppMessage(
                      message:
                          'Start override: ${job.startOverride!.status}'
                          '${job.startOverride!.status == 'approved' && !job.startOverride!.isUsable ? ' (expired)' : ''}'
                          '${job.startOverride!.note == null ? '' : '\n${job.startOverride!.note}'}',
                      type: job.usableOverrideId != null
                          ? AppMessageType.info
                          : AppMessageType.warning,
                    ),
                  ],
                  if (hasArrived) ...[
                    const SizedBox(height: 12),
                    _WorkflowStep(
                      number: 2,
                      title: context.appText('Inspect the tractor'),
                      complete: _hasInspection,
                      child: OutlinedButton(
                        onPressed: _submittingInspection
                            ? null
                            : _recordInspection,
                        child: AppButtonContent(
                          loading: _submittingInspection,
                          loadingLabel: context.appText(
                            'Recording inspection...',
                          ),
                          label: context.appText(
                            _hasInspection
                                ? "Update Today's Inspection"
                                : 'Record Inspection',
                          ),
                          icon: Icons.fact_check_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_hasInspection) ...[
                      Text(strings.optionalBeforePhotosHint),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        key: const ValueKey('optional-before-service-photos'),
                        onPressed: _submittingInspection || _submittingStart
                            ? null
                            : () => Navigator.of(context).push(
                                appPageRoute(
                                  builder: (_) => OperatorJobPhotosScreen(
                                    repository: widget.repository,
                                    jobId: job.id,
                                    initialKind: 'before',
                                  ),
                                ),
                              ),
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: Text(strings.optionalBeforeServicePhotos),
                      ),
                    ] else
                      Text(strings.inspectionBeforePhotos),
                    if (_readyForChecks) ...[
                      const SizedBox(height: 12),
                      _WorkflowStep(
                        number: 3,
                        title: context.appText('Run safety checks'),
                        complete: _startCheck?.canStart ?? false,
                        child: Column(
                          children: [
                            FilledButton.tonal(
                              onPressed: _runningStartCheck
                                  ? null
                                  : _runStartCheck,
                              child: AppButtonContent(
                                loading: _runningStartCheck,
                                loadingLabel: context.appText(
                                  'Running start check...',
                                ),
                                label: context.appText('Run Start Check'),
                                icon: Icons.rule_folder_outlined,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if ((_startCheck?.canStart ?? false) ||
                        (job.usableOverrideId != null &&
                            (_startCheck?.overrideAllowed ?? false))) ...[
                      const SizedBox(height: 12),
                      _WorkflowStep(
                        number: 4,
                        title: context.appText('Start service'),
                        complete: false,
                        child: Column(
                          children: [
                            TextField(
                              controller: _hourMeterController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: context.appText('Start hour meter'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (implementNames.isEmpty)
                              AppMessage(
                                message: context.appText(
                                  'No implement is configured. The server will validate the service requirements when you start.',
                                ),
                                type: AppMessageType.warning,
                              )
                            else
                              DropdownButtonFormField<String>(
                                initialValue: _selectedImplement,
                                decoration: InputDecoration(
                                  labelText: context.appText('Implement'),
                                  prefixIcon: Icon(Icons.handyman_outlined),
                                ),
                                hint: Text(
                                  context.appText('Select an implement'),
                                ),
                                items: [
                                  for (final implement in implementNames)
                                    DropdownMenuItem(
                                      value: implement,
                                      child: Text(implement),
                                    ),
                                ],
                                onChanged: (value) =>
                                    setState(() => _selectedImplement = value),
                              ),
                            const SizedBox(height: 10),
                            FilledButton(
                              onPressed: _submittingStart ? null : _startJob,
                              child: AppButtonContent(
                                loading: _submittingStart,
                                loadingLabel: context.appText('Starting...'),
                                label: context.appText('Start Service'),
                                icon: Icons.play_arrow,
                                progressColor: Colors.white,
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
      ),
    );
  }

  String _statusText({
    required bool hasArrived,
    required PlotGeofenceResult? result,
  }) {
    if (_checkingLocation) {
      return hasArrived
          ? 'Checking phone GPS against the assigned farm boundary.'
          : 'Checking your phone location for the route to the assigned farm.';
    }
    if (_locationError != null) {
      return 'Location could not be verified.';
    }
    if (result == null) {
      return hasArrived
          ? 'Check location before starting this service.'
          : 'Check location to show the route to the farm.';
    }
    final distanceMeters = result.distanceFromPlotMeters;
    final distanceText = distanceMeters.isInfinite
        ? 'unknown'
        : '${distanceMeters.toStringAsFixed(0)} m';
    return switch (result.state) {
      PlotGeofenceState.insideBoundary =>
        hasArrived
            ? 'GPS evidence is inside the mapped farm boundary. Run Start Check for the server decision.'
            : 'You appear to be inside the assigned farm boundary. Record arrival when the tractor is also present.',
      PlotGeofenceState.withinTolerance =>
        'GPS evidence is $distanceText outside the mapped boundary but within the farm tolerance. Run Start Check for the server decision.',
      PlotGeofenceState.uncertain =>
        'GPS accuracy overlaps the allowed farm area. Keep the tablet in open sky and verify again.',
      PlotGeofenceState.outsideAllowedArea =>
        'GPS evidence is outside the allowed farm area. Distance from the mapped boundary: $distanceText.',
      PlotGeofenceState.unavailable =>
        'The farm boundary or current GPS evidence is unavailable.',
    };
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

    final location = await _acquireReliableLocation();
    if (!mounted) return;
    if (location != null) {
      debugPrint(
        '[Operator GPS] Location ready: '
        '${location.latitude},${location.longitude} '
        '(accuracy ${location.accuracyMeters} m)',
      );
      setState(() {
        _geofenceResult = _checkPlotGeofence(
          plot: job.plot,
          location: location,
        );
        _startCheck = null;
        _checkingLocation = false;
      });
      return;
    }
  }

  Future<DeviceLocation?> _acquireReliableLocation() async {
    final mapState = _mapKey.currentState;
    if (mapState == null) {
      const message = 'The job map is still preparing GPS. Try again shortly.';
      if (mounted) {
        setState(() {
          _checkingLocation = false;
          _locationError = message;
        });
      }
      return null;
    }
    final result = await mapState.acquireFieldEvidence(
      maximumAccuracyMeters: widget.repository.phoneAccuracyMaxMeters,
      maximumFixAge: widget.repository.phoneFixMaximumAge,
    );
    if (!mounted) return null;
    if (result.location != null) {
      setState(() {
        _checkingLocation = false;
        _locationError = null;
      });
      return result.location;
    }
    final message =
        result.message ??
        'A reliable GPS position was not established. Keep the tablet in open sky and try again.';
    setState(() {
      _checkingLocation = false;
      _locationError = message;
    });
    await showAppErrorDialog(
      context,
      title: context.appText('Location could not be verified'),
      message: message,
      buttonLabel: 'Try again',
    );
    return null;
  }

  Future<void> _recordArrival() async {
    final confirmed = await showAppConfirmationDialog(
      context,
      title: context.appText('Record arrival?'),
      message: context.appText(
        'Confirm that you and the assigned tractor have arrived at the farm.',
      ),
      confirmLabel: 'Record Arrival',
    );
    if (!confirmed || !mounted) return;
    setState(() => _submittingArrival = true);
    final phone =
        _mapKey.currentState?.currentFieldEvidence(
          maximumAge: widget.repository.phoneFixMaximumAge,
        ) ??
        await _acquireReliableLocation();
    if (!mounted) return;
    if (phone == null && widget.repository.requiresPhoneLocation) {
      setState(() => _submittingArrival = false);
      return;
    }
    final arrived = await widget.repository.arriveJob(
      widget.jobId,
      phone: phone,
    );
    if (!mounted) return;
    setState(() => _submittingArrival = false);
    showAppSnackBar(
      context,
      message: arrived
          ? 'Arrival recorded. Next, inspect the tractor before running the start check.'
          : widget.repository.lastActionError ?? 'Could not record arrival.',
      type: arrived ? AppSnackType.success : AppSnackType.error,
    );
  }

  Future<void> _startJob() async {
    final navigator = Navigator.of(context);
    final hourMeter = num.tryParse(_hourMeterController.text.trim());
    final implement = _selectedImplement;
    final confirmed = await showAppConfirmationDialog(
      context,
      title: context.appText('Start service?'),
      message: context.appText(
        'This starts recorded work time for the job. Confirm the safety check has passed and the tractor is ready.',
      ),
      confirmLabel: 'Start Service',
    );
    if (!confirmed || !mounted) return;
    setState(() => _submittingStart = true);
    final evidenceMaximumAge = Duration(
      seconds: widget.repository.phoneFixMaximumAge.inSeconds.clamp(1, 30),
    );
    final location =
        _mapKey.currentState?.currentFieldEvidence(
          maximumAge: evidenceMaximumAge,
        ) ??
        await _acquireReliableLocation();
    if (!mounted) return;
    if (location == null &&
        widget.repository.requiresPhoneLocation &&
        widget.repository.maybeJobById(widget.jobId)?.usableOverrideId ==
            null) {
      setState(() => _submittingStart = false);
      showAppSnackBar(
        context,
        message:
            widget.repository.lastActionError ??
            'Refresh phone GPS before starting.',
        type: AppSnackType.error,
      );
      return;
    }
    final started = await widget.repository.startJob(
      widget.jobId,
      phone: location,
      hourMeter: hourMeter,
      implement: implement,
      overrideId: widget.repository
          .maybeJobById(widget.jobId)
          ?.usableOverrideId,
    );
    if (!mounted) return;
    setState(() {
      _submittingStart = false;
      _startCheck = widget.repository.startCheckFor(widget.jobId);
    });
    if (!started) {
      showAppSnackBar(
        context,
        message:
            widget.repository.lastActionError ??
            'This job could not be started. Review the safety checks and try again.',
        type: AppSnackType.error,
      );
      return;
    }
    navigator.pushReplacement(
      appPageRoute(
        builder: (_) => OperatorProgressScreen(
          repository: widget.repository,
          jobId: widget.jobId,
        ),
      ),
    );
  }

  Future<void> _runStartCheck() async {
    setState(() => _runningStartCheck = true);
    final phone = await _acquireReliableLocation();
    if (!mounted) return;
    if (phone == null && widget.repository.requiresPhoneLocation) {
      setState(() => _runningStartCheck = false);
      return;
    }
    final result = await widget.repository.runStartCheck(
      jobId: widget.jobId,
      phone: phone,
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
        message: context.appText(
          'Start check passed. You can start ploughing.',
        ),
        type: AppSnackType.success,
      );
      return;
    }
    final viewResults = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.appText('Start check needs attention')),
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
          ? 'Override requested. This screen will update when the union decides.'
          : widget.repository.lastActionError ?? 'Could not request override.',
      type: ok ? AppSnackType.success : AppSnackType.error,
    );
  }

  Future<void> _recordInspection() async {
    final job = widget.repository.maybeJobById(widget.jobId);
    if (job == null) return;
    final inspection = await Navigator.of(context).push<_InspectionPayload>(
      appPageRoute(
        builder: (_) => _InspectionScreen(
          checklist: widget.repository.inspectionChecklist,
          jobReference: job.reference ?? job.id,
          tractorLabel: job.tractorLabel ?? job.tractorId,
        ),
      ),
    );
    if (inspection == null) return;
    if (!mounted) return;

    final confirmed = await showAppConfirmationDialog(
      context,
      title: context.appText('Submit inspection?'),
      message: inspection.isFit
          ? 'All checklist items passed. Submit this tractor as fit for work?'
          : 'Issues were recorded. Submit this tractor as requiring attention?',
      confirmLabel: 'Submit Inspection',
      danger: !inspection.isFit,
    );
    if (!confirmed || !mounted) return;

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
    });
    showAppSnackBar(
      context,
      message: ok
          ? (_hasInspection
                ? 'Inspection passed. You can add optional before-service photos, or continue to the start check.'
                : 'Inspection recorded. Resolve the tractor issues and pass inspection before starting work.')
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

class _InspectionScreen extends StatefulWidget {
  const _InspectionScreen({
    required this.checklist,
    required this.jobReference,
    required this.tractorLabel,
  });

  final Map<String, String> checklist;
  final String jobReference;
  final String tractorLabel;

  @override
  State<_InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<_InspectionScreen> {
  final _fuelController = TextEditingController();
  final _hourMeterController = TextEditingController();
  final _defectsController = TextEditingController();
  bool _showChecklistError = false;
  bool _reviewing = false;
  String? _readingsError;
  late final Map<String, bool?> _checks;

  static const _fallbackChecklist = <String, String>{
    'engine_oil': 'Engine oil',
    'coolant': 'Coolant',
    'fuel': 'Fuel',
    'tyres': 'Tyres',
    'brakes': 'Brakes',
    'lights': 'Lights',
    'hydraulics': 'Hydraulics',
    'implement': 'Implement attached',
    'leaks': 'No leaks',
    'tracker': 'Tracker',
  };

  Map<String, String> get _checklist =>
      widget.checklist.isEmpty ? _fallbackChecklist : widget.checklist;

  @override
  void initState() {
    super.initState();
    _checks = {for (final key in _checklist.keys) key: null};
    _fuelController.addListener(_refreshReadings);
    _hourMeterController.addListener(_refreshReadings);
    _defectsController.addListener(_refreshReadings);
  }

  @override
  void dispose() {
    _fuelController.removeListener(_refreshReadings);
    _hourMeterController.removeListener(_refreshReadings);
    _defectsController.removeListener(_refreshReadings);
    _fuelController.dispose();
    _hourMeterController.dispose();
    _defectsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completed = _checks.values.whereType<bool>().length;
    final total = _checks.length;
    final progress = total == 0 ? 0.0 : completed / total;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.appText('TRACTOR INSPECTION')),
            Text(
              '${widget.jobReference} · ${widget.tractorLabel}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _InspectionProgressCard(
                      completed: completed,
                      total: total,
                      progress: progress,
                      reviewing: _reviewing,
                    ),
                    const SizedBox(height: 20),
                    if (_reviewing)
                      _buildReview(context)
                    else
                      _buildChecklist(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Align(
              alignment: Alignment.center,
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _reviewing
                            ? () => setState(() => _reviewing = false)
                            : () => Navigator.of(context).pop(),
                        child: Text(
                          context.appText(_reviewing ? 'Back' : 'Cancel'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        key: const ValueKey('inspection-continue'),
                        onPressed: _reviewing ? _submit : _openReview,
                        child: AppButtonContent(
                          label: context.appText(
                            _reviewing ? 'Use Inspection' : 'Review Inspection',
                          ),
                          icon: _reviewing
                              ? Icons.check_circle_outline
                              : Icons.arrow_forward_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChecklist(BuildContext context) {
    final completed = _checks.values.whereType<bool>().length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.appText('Safety checklist'),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          context.appText('Check every item before starting work.'),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        ..._checks.keys.map(
          (key) => _InspectionCheckRow(
            itemKey: key,
            label: _checklist[key] ?? key,
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
          const SizedBox(height: 2),
          AppMessage(
            message: context.appText(
              'Please mark Pass or Issue for every checklist item.',
            ),
            type: AppMessageType.warning,
          ),
        ],
        const SizedBox(height: 18),
        OperatorCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.appText('Readings and notes'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final fields = [
                    TextField(
                      controller: _fuelController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.appText('Fuel level (%)'),
                        hintText: '0–100',
                        prefixIcon: const Icon(
                          Icons.local_gas_station_outlined,
                        ),
                      ),
                    ),
                    TextField(
                      controller: _hourMeterController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: context.appText('Hour meter'),
                        prefixIcon: const Icon(Icons.speed_outlined),
                      ),
                    ),
                  ];
                  if (constraints.maxWidth >= 520) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: fields[0]),
                        const SizedBox(width: 12),
                        Expanded(child: fields[1]),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      fields[0],
                      const SizedBox(height: 12),
                      fields[1],
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _defectsController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: context.appText('Defects / notes'),
                  hintText: context.appText('Describe any issue found'),
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 52),
                    child: Icon(Icons.notes_outlined),
                  ),
                ),
              ),
              if (_readingsError != null) ...[
                const SizedBox(height: 8),
                Text(
                  context.appText(_readingsError!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppMessage(
          title: completed == _checks.length
              ? (_isFit
                    ? context.appText('Tractor is fit for work')
                    : context.appText('Tractor requires attention'))
              : context.appText('Inspection in progress'),
          message: completed == _checks.length
              ? (_isFit
                    ? context.appText('All inspection items passed.')
                    : context.appText(
                        'One or more inspection items have an issue.',
                      ))
              : '$completed of ${_checks.length} checks completed.',
          type: completed != _checks.length
              ? AppMessageType.info
              : _isFit
              ? AppMessageType.success
              : AppMessageType.warning,
        ),
      ],
    );
  }

  Widget _buildReview(BuildContext context) {
    final issues = _checks.entries
        .where((entry) => entry.value == false)
        .map((entry) => _checklist[entry.key] ?? entry.key)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.appText('Review inspection'),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          context.appText(
            'Check the summary before sending this inspection to the union.',
          ),
        ),
        const SizedBox(height: 16),
        AppMessage(
          title: _isFit
              ? context.appText('Tractor is fit for work')
              : context.appText('Tractor requires attention'),
          message: _isFit
              ? context.appText('All inspection items passed.')
              : '${issues.length} inspection item${issues.length == 1 ? '' : 's'} need attention.',
          type: _isFit ? AppMessageType.success : AppMessageType.warning,
        ),
        const SizedBox(height: 14),
        OperatorCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InspectionReviewFact(
                icon: Icons.check_circle_outline,
                label: context.appText('Passed'),
                value: '${_checks.length - issues.length} / ${_checks.length}',
              ),
              const Divider(height: 24),
              _InspectionReviewFact(
                icon: issues.isEmpty
                    ? Icons.verified_outlined
                    : Icons.warning_amber_rounded,
                label: context.appText('Issues'),
                value: issues.isEmpty
                    ? context.appText('None')
                    : issues.join(', '),
              ),
              if (_fuelController.text.trim().isNotEmpty) ...[
                const Divider(height: 24),
                _InspectionReviewFact(
                  icon: Icons.local_gas_station_outlined,
                  label: context.appText('Fuel level (%)'),
                  value: '${_fuelController.text.trim()}%',
                ),
              ],
              if (_hourMeterController.text.trim().isNotEmpty) ...[
                const Divider(height: 24),
                _InspectionReviewFact(
                  icon: Icons.speed_outlined,
                  label: context.appText('Hour meter'),
                  value: _hourMeterController.text.trim(),
                ),
              ],
              if (_defectsController.text.trim().isNotEmpty) ...[
                const Divider(height: 24),
                _InspectionReviewFact(
                  icon: Icons.notes_outlined,
                  label: context.appText('Defects / notes'),
                  value: _defectsController.text.trim(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _refreshReadings() {
    if (mounted && _readingsError != null) {
      setState(() => _readingsError = null);
    }
  }

  void _openReview() {
    if (_checks.values.any((value) => value == null)) {
      setState(() => _showChecklistError = true);
      return;
    }
    final fuelText = _fuelController.text.trim();
    final fuel = fuelText.isEmpty ? null : int.tryParse(fuelText);
    if (fuelText.isNotEmpty && (fuel == null || fuel < 0 || fuel > 100)) {
      setState(() => _readingsError = 'Enter a fuel level from 0 to 100.');
      return;
    }
    final hourText = _hourMeterController.text.trim();
    final hourMeter = hourText.isEmpty ? null : num.tryParse(hourText);
    if (hourText.isNotEmpty && (hourMeter == null || hourMeter < 0)) {
      setState(() => _readingsError = 'Enter a valid non-negative hour meter.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _reviewing = true);
  }

  void _submit() {
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
}

class _InspectionProgressCard extends StatelessWidget {
  const _InspectionProgressCard({
    required this.completed,
    required this.total,
    required this.progress,
    required this.reviewing,
  });

  final int completed;
  final int total;
  final double progress;
  final bool reviewing;

  @override
  Widget build(BuildContext context) {
    return OperatorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.appText(
                    reviewing ? 'Review inspection' : 'Pre-start safety check',
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                key: const ValueKey('inspection-progress'),
                reviewing ? context.appText('Review') : '$completed of $total',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: reviewing ? 1 : progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );
  }
}

class _InspectionReviewFact extends StatelessWidget {
  const _InspectionReviewFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 2),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}

class _InspectionCheckRow extends StatelessWidget {
  const _InspectionCheckRow({
    required this.itemKey,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String itemKey;
  final String label;
  final bool? value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final icon = switch (itemKey) {
      'engine_oil' => Icons.oil_barrel_outlined,
      'coolant' => Icons.water_drop_outlined,
      'fuel' => Icons.local_gas_station_outlined,
      'tyres' => Icons.tire_repair_outlined,
      'brakes' => Icons.motion_photos_paused_outlined,
      'lights' => Icons.lightbulb_outline,
      'hydraulics' => Icons.settings_input_component_outlined,
      'implement' => Icons.handyman_outlined,
      'leaks' => Icons.plumbing_outlined,
      'tracker' => Icons.gps_fixed_outlined,
      _ => Icons.fact_check_outlined,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: value == true
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.045)
              : value == false
              ? Theme.of(context).colorScheme.error.withValues(alpha: 0.045)
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: value == true
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.35)
                : value == false
                ? Theme.of(context).colorScheme.error.withValues(alpha: 0.35)
                : Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InspectionChoiceButton(
                      buttonKey: ValueKey('inspection-$itemKey-pass'),
                      selected: value == true,
                      label: context.appText('Pass'),
                      icon: Icons.check_circle_outline,
                      onTap: () => onChanged(true),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InspectionChoiceButton(
                      buttonKey: ValueKey('inspection-$itemKey-issue'),
                      selected: value == false,
                      label: context.appText('Issue'),
                      icon: Icons.warning_amber_rounded,
                      onTap: () => onChanged(false),
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InspectionChoiceButton extends StatelessWidget {
  const _InspectionChoiceButton({
    required this.buttonKey,
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final Key buttonKey;
  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        key: buttonKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.13)
                : Colors.transparent,
            border: Border.all(
              color: selected
                  ? color
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: selected ? color : null),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? color : null,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
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
      title: Row(
        children: [
          Icon(Icons.rule_folder_outlined),
          SizedBox(width: 10),
          Expanded(child: Text(context.appText('Start check results'))),
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
              if (result.phone != null || result.tractor != null) ...[
                const SizedBox(height: 12),
                Text(
                  context.appText('Server location evidence'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (result.toleranceMeters != null)
                  Text(
                    'Farm tolerance: ${result.toleranceMeters!.toStringAsFixed(0)} m',
                  ),
                if (result.phone?.accuracyMeters != null)
                  Text(
                    'Phone accuracy: ${result.phone!.accuracyMeters!.toStringAsFixed(0)} m',
                  ),
                if (result.phone?.distanceToPlotMeters != null)
                  Text(
                    'Phone distance from farm: ${result.phone!.distanceToPlotMeters!.toStringAsFixed(0)} m',
                  ),
                if (result.phone?.distanceToTractorMeters != null)
                  Text(
                    'Phone distance from tractor: ${result.phone!.distanceToTractorMeters!.toStringAsFixed(0)} m',
                  ),
                if (result.tractor?.distanceToPlotMeters != null)
                  Text(
                    'Tractor distance from farm: ${result.tractor!.distanceToPlotMeters!.toStringAsFixed(0)} m',
                  ),
                if (result.tractor?.ageSeconds != null)
                  Text('Tractor fix age: ${result.tractor!.ageSeconds} s'),
              ],
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
              child: Text(context.appText('Close')),
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
      title: Text(context.appText('Request Start Override')),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        autofocus: true,
        decoration: InputDecoration(
          labelText: context.appText('Reason'),
          hintText: context.appText(
            'Explain why the start check should be overridden',
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actions: [
        AppDialogActions(
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: () => Navigator.of(context).pop(_controller.text),
          confirmLabel: 'Send',
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
