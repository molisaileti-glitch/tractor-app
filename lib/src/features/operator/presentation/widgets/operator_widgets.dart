import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/operator_job.dart';
import 'map_position_grouping.dart';
import '../../../../l10n/localized_copy.dart';

const _googleRoutesAndroidApiKey = 'AIzaSyAARTXTKRaYC011X_ruaKhK_R4uzgWtt0U';
const _googleRoutesIosApiKey = 'AIzaSyARbOp7_7i56wwdstWxPxy-lVH2ERjHdQ0';
const _applicationId = 'com.example.tractor';
const _androidCertSha1 = '40F065D6613192655D59990520E93ED368DC45B7';

class OperatorCard extends StatelessWidget {
  const OperatorCard({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: card,
    );
  }
}

class OperatorStatusPill extends StatelessWidget {
  const OperatorStatusPill({super.key, required this.status});

  final OperatorJobStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      OperatorJobStatus.scheduled => const Color(0xFF64748B),
      OperatorJobStatus.assigned => const Color(0xFF64748B),
      OperatorJobStatus.dispatched => const Color(0xFFF59E0B),
      OperatorJobStatus.enRoute => const Color(0xFFF97316),
      OperatorJobStatus.arrived => const Color(0xFF0EA5E9),
      OperatorJobStatus.inProgress => const Color(0xFF2563EB),
      OperatorJobStatus.paused => const Color(0xFF7C3AED),
      OperatorJobStatus.completedPendingConfirmation => const Color(0xFF10B981),
      OperatorJobStatus.verified => const Color(0xFF059669),
      OperatorJobStatus.closed => const Color(0xFF334155),
      OperatorJobStatus.cancelled => const Color(0xFF94A3B8),
      OperatorJobStatus.flagged => const Color(0xFFE11D48),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              localizedOperatorStatus(context, status),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String localizedOperatorStatus(BuildContext context, OperatorJobStatus status) {
  final strings = AppLocalizations.of(context)!;
  return switch (status) {
    OperatorJobStatus.scheduled => strings.scheduled,
    OperatorJobStatus.assigned => strings.assigned,
    OperatorJobStatus.dispatched => strings.dispatched,
    OperatorJobStatus.enRoute => strings.enRoute,
    OperatorJobStatus.arrived => strings.arrived,
    OperatorJobStatus.inProgress => strings.jobInProgress,
    OperatorJobStatus.paused => 'Paused',
    OperatorJobStatus.completedPendingConfirmation =>
      strings.completedPendingConfirmation,
    OperatorJobStatus.verified => 'Verified',
    OperatorJobStatus.closed => 'Closed',
    OperatorJobStatus.cancelled => 'Cancelled',
    OperatorJobStatus.flagged => 'Flagged',
  };
}

class OperatorMapCard extends StatefulWidget {
  const OperatorMapCard({
    super.key,
    this.job,
    this.jobs = const [],
    this.showTractor = true,
    this.showTrack = false,
    this.routeFromLatitude,
    this.routeFromLongitude,
    this.phoneRecordedAt,
    this.phoneAccuracyMeters,
    this.tractorPosition,
    this.routeEnabled = false,
    this.label = 'ASSIGNED FARM',
    this.fill = false,
  });

  final OperatorJob? job;
  final List<OperatorJob> jobs;
  final bool showTractor;
  final bool showTrack;
  final double? routeFromLatitude;
  final double? routeFromLongitude;
  final DateTime? phoneRecordedAt;
  final double? phoneAccuracyMeters;
  final TractorTrackerPosition? tractorPosition;
  final bool routeEnabled;
  final String label;
  final bool fill;

  @override
  State<OperatorMapCard> createState() => _OperatorMapCardState();
}

class _OperatorMapCardState extends State<OperatorMapCard> {
  GoogleMapController? _controller;
  BitmapDescriptor? _tractorMarkerIcon;
  BitmapDescriptor? _farmMarkerIcon;
  BitmapDescriptor? _operatorMarkerIcon;
  BitmapDescriptor? _combinedMarkerIcon;
  String? _routeOrigin;
  List<LatLng> _routePoints = const [];
  String? _routeSummary;
  String? _routeKey;
  bool _loadingRoute = false;
  String? _routeError;
  LatLng? _lastRouteOrigin;
  DateTime? _lastRouteRequestedAt;
  bool _routeQuotaExhausted = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadMarkerIcons());
    unawaited(_loadRouteIfNeeded());
  }

  @override
  void didUpdateWidget(covariant OperatorMapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(_loadRouteIfNeeded());
    final oldTracker = oldWidget.tractorPosition;
    final liveTractorAppeared =
        oldTracker?.isLive != true && widget.tractorPosition?.isLive == true;
    final phoneAppeared =
        oldWidget.routeFromLatitude == null && widget.routeFromLatitude != null;
    if (liveTractorAppeared || phoneAppeared) {
      final mappedJobs = [
        if (widget.job != null) widget.job!,
        ...widget.jobs.where((item) => item.id != widget.job?.id),
      ].where((item) => item.plot.boundaryPoints.isNotEmpty).toList();
      final routeStart = _routeStart;
      final destination = mappedJobs.isEmpty
          ? null
          : _jobPoint(mappedJobs.first);
      unawaited(
        _fitMap(
          mappedJobs,
          routeStart,
          destination,
          _phonePoint,
          _liveTractorPoint,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleJobs = [
      if (widget.job != null) widget.job!,
      ...widget.jobs.where((item) => item.id != widget.job?.id),
    ];
    final mappedJobs = visibleJobs
        .where(
          (item) =>
              item.plot.boundaryPoints.isNotEmpty ||
              item.trackPoints.isNotEmpty,
        )
        .toList();
    final routeStart = _routeStart;
    final phonePoint = _phonePoint;
    final tractorPoint = _tractorPoint;
    final hasCoordinates =
        mappedJobs.isNotEmpty || phonePoint != null || tractorPoint != null;
    final farms = mappedJobs
        .where((job) => job.plot.boundaryPoints.isNotEmpty)
        .toList();
    final routeDestination = routeStart != null && farms.isNotEmpty
        ? _jobPoint(farms.first)
        : null;
    final hasRoute = routeStart != null && routeDestination != null;
    final initialTarget = mappedJobs.isNotEmpty
        ? _jobPoint(mappedJobs.first)
        : tractorPoint ?? phonePoint;

    final map = ClipRRect(
      borderRadius: BorderRadius.circular(widget.fill ? 0 : 8),
      child: !hasCoordinates
          ? _NoMapCoordinates(label: widget.label)
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: hasRoute
                    ? _midpoint(routeStart, routeDestination)
                    : initialTarget!,
                zoom: hasRoute
                    ? 12
                    : mappedJobs.length == 1
                    ? 15
                    : 12,
              ),
              markers: _markers(mappedJobs, phonePoint, tractorPoint),
              polygons: _polygons(mappedJobs),
              polylines: _polylines(mappedJobs, routeStart, routeDestination),
              mapType: MapType.hybrid,
              compassEnabled: true,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
              },
              onMapCreated: (controller) {
                _controller = controller;
                unawaited(
                  _fitMap(
                    mappedJobs,
                    routeStart,
                    routeDestination,
                    phonePoint,
                    _liveTractorPoint,
                  ),
                );
              },
            ),
    );

    final content = Stack(
      fit: StackFit.expand,
      children: [
        map,
        if (widget.routeEnabled && farms.isNotEmpty)
          Positioned(
            left: 12,
            right: 12,
            top: widget.fill ? 94 : 54,
            child: Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                child: Wrap(
                  spacing: 6,
                  children: [
                    ChoiceChip(
                      avatar: const Icon(Icons.agriculture, size: 18),
                      label: Text(context.appText('Tractor route')),
                      selected: _usesTractorRoute,
                      onSelected: widget.tractorPosition?.isLive == true
                          ? (_) => _selectRoute('tractor')
                          : null,
                    ),
                    ChoiceChip(
                      avatar: const Icon(Icons.person, size: 18),
                      label: Text(context.appText('Operator route')),
                      selected: !_usesTractorRoute && _phonePoint != null,
                      onSelected: _phonePoint != null
                          ? (_) => _selectRoute('operator')
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (widget.tractorPosition != null)
          Positioned(
            left: 12,
            top: 12,
            child: _TrackerStatusBadge(position: widget.tractorPosition!),
          ),
        if (_routeSummary != null && _routePoints.isNotEmpty)
          Positioned(
            right: 12,
            top: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF1E40AF),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_car,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_usesTractorRoute ? 'Tractor' : 'Operator'} · $_routeSummary',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_routeError != null && hasRoute)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Icon(
                      Icons.route_outlined,
                      color: Theme.of(context).colorScheme.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _routeError!,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    TextButton(
                      onPressed: _routeQuotaExhausted
                          ? null
                          : () => _selectRoute(
                              _usesTractorRoute ? 'tractor' : 'operator',
                            ),
                      child: Text(context.appText('Retry')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (widget.routeEnabled && routeStart == null && mappedJobs.isNotEmpty)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Icon(Icons.location_disabled_outlined, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.appText(
                          'Allow location access and check GPS to calculate the road route.',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );

    if (widget.fill) return content;

    return AspectRatio(
      aspectRatio: 1.45,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: content,
      ),
    );
  }

  LatLng _jobPoint(OperatorJob job) {
    if (job.plot.boundaryPoints.isNotEmpty) {
      final latitude =
          job.plot.boundaryPoints.fold<double>(
            0,
            (sum, point) => sum + point.latitude,
          ) /
          job.plot.boundaryPoints.length;
      final longitude =
          job.plot.boundaryPoints.fold<double>(
            0,
            (sum, point) => sum + point.longitude,
          ) /
          job.plot.boundaryPoints.length;
      return LatLng(latitude, longitude);
    }
    final point = job.trackPoints.last;
    return LatLng(point.latitude, point.longitude);
  }

  LatLng? get _routeStart {
    if (_routeOrigin == 'tractor') {
      return widget.tractorPosition?.isLive == true ? _tractorPoint : null;
    }
    return _usesTractorRoute ? _tractorPoint : _phonePoint;
  }

  bool get _usesTractorRoute => _routeOrigin == 'tractor'
      ? widget.tractorPosition?.isLive == true
      : _routeOrigin == 'operator'
      ? false
      : widget.tractorPosition?.isLive == true;

  void _selectRoute(String origin) {
    setState(() {
      _routeOrigin = origin;
      _routeKey = null;
      _lastRouteOrigin = null;
      _lastRouteRequestedAt = null;
      _routePoints = const [];
      _routeSummary = null;
      _routeError = null;
      _loadingRoute = false;
    });
    unawaited(_loadRouteIfNeeded());
  }

  LatLng? get _phonePoint {
    final latitude = widget.routeFromLatitude;
    final longitude = widget.routeFromLongitude;
    if (!_validCoordinate(latitude, longitude)) return null;
    final recordedAt = widget.phoneRecordedAt;
    final age = recordedAt == null
        ? null
        : DateTime.now().difference(recordedAt).inSeconds;
    if (age == null || age < -30 || age > 180) {
      return null;
    }
    return LatLng(latitude!, longitude!);
  }

  LatLng? get _tractorPoint {
    final position = widget.tractorPosition;
    if (position == null ||
        !widget.showTractor ||
        !_validCoordinate(position.latitude, position.longitude)) {
      return null;
    }
    return LatLng(position.latitude, position.longitude);
  }

  LatLng? get _liveTractorPoint =>
      widget.tractorPosition?.isLive == true ? _tractorPoint : null;

  bool _validCoordinate(double? lat, double? lng) =>
      lat != null &&
      lng != null &&
      lat.isFinite &&
      lng.isFinite &&
      lat.abs() <= 90 &&
      lng.abs() <= 180;

  LatLng _midpoint(LatLng first, LatLng second) {
    return LatLng(
      (first.latitude + second.latitude) / 2,
      (first.longitude + second.longitude) / 2,
    );
  }

  Set<Marker> _markers(
    List<OperatorJob> jobs,
    LatLng? phonePoint,
    LatLng? tractorPoint,
  ) {
    final groupNearby =
        phonePoint != null &&
        tractorPoint != null &&
        canGroupOperatorAndTractor(
          phoneLatitude: phonePoint.latitude,
          phoneLongitude: phonePoint.longitude,
          tractorLatitude: tractorPoint.latitude,
          tractorLongitude: tractorPoint.longitude,
          phoneAccuracyMeters: widget.phoneAccuracyMeters,
          tractorIsLive: widget.tractorPosition?.isLive == true,
        );
    return {
      if (groupNearby)
        Marker(
          markerId: const MarkerId('operator-and-tractor'),
          position: tractorPoint,
          icon:
              _combinedMarkerIcon ??
              _tractorMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          anchor: const Offset(.5, .5),
          consumeTapEvents: true,
          infoWindow: InfoWindow(
            title: context.appText('Operator + tractor'),
            snippet: 'Locations close together',
          ),
          onTap: () => _showNearbyLocations(phonePoint, tractorPoint),
        ),
      if (tractorPoint != null && !groupNearby)
        Marker(
          markerId: const MarkerId('tractor-tracker-location'),
          position: tractorPoint,
          icon:
              _tractorMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: widget.tractorPosition?.isLive == true
                ? 'Tractor location'
                : 'Tractor last known location',
          ),
        ),
      if (phonePoint != null && !groupNearby)
        Marker(
          markerId: const MarkerId('operator-phone-location'),
          position: phonePoint,
          icon:
              _operatorMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(
            title: context.appText('Operator - phone GPS'),
          ),
        ),
      for (final job in jobs)
        if (job.plot.boundaryPoints.isNotEmpty)
          Marker(
            markerId: MarkerId('job-${job.id}'),
            position: _jobPoint(job),
            icon:
                _farmMarkerIcon ??
                BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
            infoWindow: InfoWindow(
              title: job.plot.name,
              snippet:
                  '${job.serviceType.label} - ${job.status.label} - ${job.tractorLabel ?? job.tractorId}',
            ),
          ),
    };
  }

  void _showNearbyLocations(LatLng phone, LatLng tractor) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.appText('Operator + tractor'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              context.appText(
                'The reported locations are close together. This does not confirm the operator is on the tractor.',
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person, color: Color(0xFF7C3AED)),
              title: Text(context.appText('Operator - phone GPS')),
              subtitle: Text(
                '${phone.latitude.toStringAsFixed(6)}, ${phone.longitude.toStringAsFixed(6)}\n'
                'Accuracy: ${widget.phoneAccuracyMeters?.toStringAsFixed(0)} m',
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.agriculture, color: Color(0xFFF97316)),
              title: Text(context.appText('Tractor - tracker GPS')),
              subtitle: Text(
                '${tractor.latitude.toStringAsFixed(6)}, ${tractor.longitude.toStringAsFixed(6)}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadMarkerIcons() async {
    final tractorIcon = await _makeMarkerIcon(
      icon: Icons.agriculture,
      color: const Color(0xFFF97316),
    );
    final farmIcon = await _makeMarkerIcon(
      icon: Icons.landscape,
      color: AppColors.fieldGreen,
    );
    final operatorIcon = await _makeMarkerIcon(
      icon: Icons.person,
      color: const Color(0xFF7C3AED),
    );
    final combinedIcon = await _makeMarkerIcon(
      icon: Icons.agriculture,
      color: const Color(0xFFF97316),
      badge: Icons.person,
    );
    if (!mounted) return;
    setState(() {
      _tractorMarkerIcon = tractorIcon;
      _farmMarkerIcon = farmIcon;
      _operatorMarkerIcon = operatorIcon;
      _combinedMarkerIcon = combinedIcon;
    });
  }

  Future<BitmapDescriptor> _makeMarkerIcon({
    required IconData icon,
    required Color color,
    IconData? badge,
  }) async {
    const canvasSize = 96.0;
    const circleCenter = Offset(canvasSize / 2, canvasSize / 2);
    const circleRadius = 38.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawCircle(
      circleCenter.translate(0, 4),
      circleRadius,
      Paint()..color = Colors.black.withValues(alpha: 0.22),
    );
    canvas.drawCircle(
      circleCenter,
      circleRadius,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(circleCenter, circleRadius - 5, Paint()..color = color);

    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: Colors.white,
          fontSize: 44,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        (canvasSize - textPainter.width) / 2,
        (canvasSize - textPainter.height) / 2,
      ),
    );
    if (badge != null) {
      const center = Offset(73, 73);
      canvas.drawCircle(center, 21, Paint()..color = Colors.white);
      canvas.drawCircle(center, 18, Paint()..color = const Color(0xFF7C3AED));
      final painter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(badge.codePoint),
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontFamily: badge.fontFamily,
            package: badge.fontPackage,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        center - Offset(painter.width / 2, painter.height / 2),
      );
    }

    final image = await recorder.endRecording().toImage(
      canvasSize.toInt(),
      canvasSize.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final markerBytes = bytes?.buffer.asUint8List() ?? Uint8List(0);
    return BitmapDescriptor.bytes(
      markerBytes,
      width: 48,
      height: 48,
      imagePixelRatio: 2,
    );
  }

  Set<Polygon> _polygons(List<OperatorJob> jobs) {
    return {
      for (final job in jobs)
        if (job.plot.boundaryPoints.length >= 3)
          Polygon(
            polygonId: PolygonId('plot-${job.id}'),
            points: [
              for (final point in job.plot.boundaryPoints)
                LatLng(point.latitude, point.longitude),
            ],
            fillColor: AppColors.fieldGreen.withValues(alpha: 0.14),
            strokeColor: AppColors.fieldGreen,
            strokeWidth: 2,
          ),
    };
  }

  Set<Polyline> _polylines(
    List<OperatorJob> jobs,
    LatLng? routeStart,
    LatLng? routeDestination,
  ) {
    return {
      if (routeStart != null &&
          routeDestination != null &&
          _routePoints.length >= 2)
        Polyline(
          polylineId: const PolylineId('driving-route'),
          points: _routePoints,
          color: const Color(0xFF2563EB),
          width: 6,
        )
      else if (routeStart != null &&
          routeDestination != null &&
          widget.routeEnabled)
        Polyline(
          polylineId: const PolylineId('fallback-guideline'),
          points: [routeStart, routeDestination],
          color: const Color(0xFF60A5FA),
          width: 3,
          patterns: [PatternItem.dash(12), PatternItem.gap(8)],
        ),
      for (final job in jobs)
        if (widget.showTrack)
          for (var index = 1; index < job.trackPoints.length; index++)
            Polyline(
              polylineId: PolylineId('track-${job.id}-$index'),
              points: [
                LatLng(
                  job.trackPoints[index - 1].latitude,
                  job.trackPoints[index - 1].longitude,
                ),
                LatLng(
                  job.trackPoints[index].latitude,
                  job.trackPoints[index].longitude,
                ),
              ],
              color: job.trackPoints[index] is WorkTrackPoint
                  ? ((job.trackPoints[index] as WorkTrackPoint).inside == true
                        ? const Color(0xFF10B981)
                        : (job.trackPoints[index] as WorkTrackPoint).inside ==
                              false
                        ? const Color(0xFFE11D48)
                        : const Color(0xFF64748B))
                  : const Color(0xFF64748B),
              width: 5,
            ),
    };
  }

  Future<void> _fitMap(
    List<OperatorJob> mappedJobs,
    LatLng? routeStart,
    LatLng? routeDestination,
    LatLng? phonePoint,
    LatLng? tractorPoint,
  ) async {
    final controller = _controller;
    if (controller == null) return;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    final points = <LatLng>[
      for (final job in mappedJobs) _jobPoint(job),
      for (final job in mappedJobs)
        for (final point in job.plot.boundaryPoints)
          LatLng(point.latitude, point.longitude),
      for (final job in mappedJobs)
        for (final point in job.trackPoints)
          LatLng(point.latitude, point.longitude),
      ?routeStart,
      ?routeDestination,
      ?phonePoint,
      ?tractorPoint,
      ..._routePoints,
    ];
    if (points.length < 2) return;

    final bounds = _boundsFor(points);
    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 42));
  }

  LatLngBounds _boundsFor(List<LatLng> points) {
    var south = points.first.latitude;
    var north = points.first.latitude;
    var west = points.first.longitude;
    var east = points.first.longitude;
    for (final point in points.skip(1)) {
      if (point.latitude < south) south = point.latitude;
      if (point.latitude > north) north = point.latitude;
      if (point.longitude < west) west = point.longitude;
      if (point.longitude > east) east = point.longitude;
    }
    if (south == north) {
      south -= 0.002;
      north += 0.002;
    }
    if (west == east) {
      west -= 0.002;
      east += 0.002;
    }
    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  Future<void> _loadRouteIfNeeded() async {
    if (!widget.routeEnabled) return;
    final mappedJobs = [
      if (widget.job != null) widget.job!,
      ...widget.jobs.where((item) => item.id != widget.job?.id),
    ].where((item) => item.plot.boundaryPoints.isNotEmpty).toList();
    final start = _routeStart;
    if (start == null || mappedJobs.isEmpty) {
      debugPrint(
        '[Routes API] Waiting: origin=${start == null ? 'missing' : 'ready'}, '
        'farm=${mappedJobs.isEmpty ? 'missing' : 'ready'}',
      );
      if (_routePoints.isNotEmpty || _routeError != null || _loadingRoute) {
        setState(() {
          _routePoints = const [];
          _routeSummary = null;
          _routeKey = null;
          _routeError = null;
          _loadingRoute = false;
        });
      }
      return;
    }

    if (_routeQuotaExhausted) {
      if (_routeError == null && mounted) {
        setState(() {
          _routeError =
              'The Google road-directions quota has been reached for today. '
              'Operator, tractor and farm positions are still available.';
        });
      }
      return;
    }

    final destination = _jobPoint(mappedJobs.first);
    final requestedAt = DateTime.now();
    final lastRequestedAt = _lastRouteRequestedAt;
    if (lastRequestedAt != null &&
        requestedAt.difference(lastRequestedAt) < const Duration(minutes: 2)) {
      return;
    }
    final lastOrigin = _lastRouteOrigin;
    if (lastOrigin != null &&
        _routePoints.isNotEmpty &&
        _mapDistanceMeters(lastOrigin, start) < 100) {
      return;
    }
    final nextKey =
        '${start.latitude.toStringAsFixed(6)},${start.longitude.toStringAsFixed(6)}:'
        '${destination.latitude.toStringAsFixed(6)},${destination.longitude.toStringAsFixed(6)}';
    if (_routeKey == nextKey) return;

    setState(() {
      _routeKey = nextKey;
      _loadingRoute = true;
      _routeError = null;
      _routePoints = const [];
      _routeSummary = null;
    });
    _lastRouteOrigin = start;
    _lastRouteRequestedAt = requestedAt;

    try {
      debugPrint(
        '[Routes API] Requesting ${start.latitude},${start.longitude} -> '
        '${destination.latitude},${destination.longitude}',
      );
      final result = await _fetchDrivingRoute(start, destination);
      if (!mounted || _routeKey != nextKey) return;
      setState(() {
        _routePoints = result.points;
        _routeSummary = result.summary;
        _loadingRoute = false;
        _routeError = result.points.length >= 2
            ? null
            : 'No road route was returned for this farm.';
      });
      debugPrint(
        '[Routes API] Received ${result.points.length} route points'
        '${result.summary != null ? ' (${result.summary})' : ''}',
      );
      unawaited(
        _fitMap(mappedJobs, start, destination, _phonePoint, _liveTractorPoint),
      );
    } catch (error) {
      debugPrint('[Routes API] $error');
      if (!mounted || _routeKey != nextKey) return;
      final quotaExceeded = error.toString().contains('429');
      setState(() {
        _routePoints = const [];
        _routeSummary = null;
        _loadingRoute = false;
        _routeQuotaExhausted = quotaExceeded;
        _routeError = quotaExceeded
            ? 'The Google road-directions quota has been reached for today. '
                  'Operator, tractor and farm positions are still available.'
            : 'Road directions are unavailable right now. Please try again.';
      });
    }
  }

  double _mapDistanceMeters(LatLng first, LatLng second) {
    const earthRadiusMeters = 6371000.0;
    const radians = math.pi / 180;
    final latitudeDelta = (second.latitude - first.latitude) * radians;
    final longitudeDelta = (second.longitude - first.longitude) * radians;
    final a =
        math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
        math.cos(first.latitude * radians) *
            math.cos(second.latitude * radians) *
            math.sin(longitudeDelta / 2) *
            math.sin(longitudeDelta / 2);
    return earthRadiusMeters * 2 * math.asin(math.sqrt(a.clamp(0.0, 1.0)));
  }

  Future<_DrivingRouteResult> _fetchDrivingRoute(
    LatLng origin,
    LatLng destination,
  ) async {
    final uri = Uri.https(
      'routes.googleapis.com',
      '/directions/v2:computeRoutes',
    );
    debugPrint('[Routes API] Endpoint: $uri');
    final payload = <String, Object?>{
      'origin': {
        'location': {
          'latLng': {
            'latitude': origin.latitude,
            'longitude': origin.longitude,
          },
        },
      },
      'destination': {
        'location': {
          'latLng': {
            'latitude': destination.latitude,
            'longitude': destination.longitude,
          },
        },
      },
      'travelMode': 'DRIVE',
      'routingPreference': 'TRAFFIC_AWARE',
      'computeAlternativeRoutes': true,
      'polylineQuality': 'OVERVIEW',
      'polylineEncoding': 'ENCODED_POLYLINE',
    };

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.headers.set(
        'X-Goog-Api-Key',
        Platform.isIOS ? _googleRoutesIosApiKey : _googleRoutesAndroidApiKey,
      );
      request.headers.set(
        'X-Goog-FieldMask',
        'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
      );
      if (Platform.isAndroid) {
        request.headers.set('X-Android-Package', _applicationId);
        request.headers.set('X-Android-Cert', _androidCertSha1);
      } else if (Platform.isIOS) {
        request.headers.set('X-Ios-Bundle-Identifier', _applicationId);
      }
      request.write(jsonEncode(payload));
      final response = await request.close();
      final body = await utf8.decodeStream(response);
      debugPrint(
        '[Routes API] Response status=${response.statusCode}; '
        'bodyBytes=${body.length}',
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Routes request failed (${response.statusCode}): $body',
          uri: uri,
        );
      }
      final decoded = jsonDecode(body) as Map<String, Object?>;
      final routes = decoded['routes'];
      if (routes is! List || routes.isEmpty) {
        return const _DrivingRouteResult(points: []);
      }
      final availableRoutes = routes.whereType<Map<String, Object?>>().toList();
      if (availableRoutes.isEmpty) {
        return const _DrivingRouteResult(points: []);
      }
      availableRoutes.sort((first, second) {
        final firstDistance =
            (first['distanceMeters'] as num?)?.toInt() ?? 0x7fffffff;
        final secondDistance =
            (second['distanceMeters'] as num?)?.toInt() ?? 0x7fffffff;
        return firstDistance.compareTo(secondDistance);
      });
      final route = availableRoutes.first;
      final polyline = route['polyline'];
      if (polyline is! Map<String, Object?>) {
        return const _DrivingRouteResult(points: []);
      }
      final encoded = polyline['encodedPolyline'];
      if (encoded is! String || encoded.isEmpty) {
        return const _DrivingRouteResult(points: []);
      }
      final points = _decodePolyline(encoded);

      final distanceMeters = (route['distanceMeters'] as num?)?.toInt();
      final durationStr = route['duration'] as String?;
      int? durationSeconds;
      if (durationStr != null && durationStr.endsWith('s')) {
        durationSeconds = int.tryParse(
          durationStr.substring(0, durationStr.length - 1),
        );
      }

      final summaryParts = <String>[];
      if (distanceMeters != null) {
        if (distanceMeters >= 1000) {
          summaryParts.add('${(distanceMeters / 1000).toStringAsFixed(1)} km');
        } else {
          summaryParts.add('$distanceMeters m');
        }
      }
      if (durationSeconds != null) {
        final mins = (durationSeconds / 60).round();
        if (mins < 1) {
          summaryParts.add('< 1 min');
        } else if (mins >= 60) {
          final hours = mins ~/ 60;
          final remMins = mins % 60;
          summaryParts.add('${hours}h ${remMins}m');
        } else {
          summaryParts.add('$mins min');
        }
      }

      final summary = summaryParts.isEmpty ? null : summaryParts.join(' • ');
      return _DrivingRouteResult(points: points, summary: summary);
    } finally {
      client.close(force: true);
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0;
    var latitude = 0;
    var longitude = 0;

    while (index < encoded.length) {
      var shift = 0;
      var result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < encoded.length);
      final deltaLatitude = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      latitude += deltaLatitude;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < encoded.length);
      final deltaLongitude = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      longitude += deltaLongitude;

      points.add(LatLng(latitude / 1E5, longitude / 1E5));
    }

    return points;
  }
}

class _TrackerStatusBadge extends StatelessWidget {
  const _TrackerStatusBadge({required this.position});

  final TractorTrackerPosition position;

  @override
  Widget build(BuildContext context) {
    final color = position.isLive
        ? AppColors.adaptiveSuccess(context)
        : AppColors.warning;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.agriculture, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              _label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _label {
    if (position.isLive) return 'Tractor live';
    final age = position.currentAgeSeconds;
    if (age == null) return 'Tracker offline';
    if (age < 60) return 'Last fix ${age}s ago';
    if (age < 3600) return 'Last fix ${age ~/ 60}m ago';
    return 'Last fix ${age ~/ 3600}h ago';
  }
}

class _NoMapCoordinates extends StatelessWidget {
  const _NoMapCoordinates({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE6EFE8),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(18),
      child: Text(
        'No map coordinates returned for $label.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: const Color(0xFF284437),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DrivingRouteResult {
  const _DrivingRouteResult({required this.points, this.summary});

  final List<LatLng> points;
  final String? summary;
}
