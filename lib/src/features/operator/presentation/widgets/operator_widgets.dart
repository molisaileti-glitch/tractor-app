import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/operator_job.dart';

const _googleDirectionsApiKey = 'AIzaSyAARTXTKRaYC011X_ruaKhK_R4uzgWtt0U';

class OperatorCard extends StatelessWidget {
  const OperatorCard({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
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
      OperatorJobStatus.scheduled => Theme.of(context).colorScheme.tertiary,
      OperatorJobStatus.assigned => const Color(0xFF64748B),
      OperatorJobStatus.dispatched => const Color(0xFF7B4BD2),
      OperatorJobStatus.enRoute => const Color(0xFF7B4BD2),
      OperatorJobStatus.arrived => const Color(0xFF0EA5E9),
      OperatorJobStatus.inProgress => Theme.of(context).colorScheme.primary,
      OperatorJobStatus.completedPendingConfirmation => Theme.of(
        context,
      ).colorScheme.secondary,
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
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
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
    this.label = 'ASSIGNED FARM',
    this.fill = false,
  });

  final OperatorJob? job;
  final List<OperatorJob> jobs;
  final bool showTractor;
  final bool showTrack;
  final double? routeFromLatitude;
  final double? routeFromLongitude;
  final String label;
  final bool fill;

  @override
  State<OperatorMapCard> createState() => _OperatorMapCardState();
}

class _OperatorMapCardState extends State<OperatorMapCard> {
  GoogleMapController? _controller;
  BitmapDescriptor? _tractorMarkerIcon;
  BitmapDescriptor? _farmMarkerIcon;
  List<LatLng> _routePoints = const [];
  String? _routeKey;
  bool _loadingRoute = false;
  String? _routeError;

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
    final hasRoute = routeStart != null && mappedJobs.isNotEmpty;
    final routeDestination = hasRoute ? _jobPoint(mappedJobs.first) : null;

    final map = ClipRRect(
      borderRadius: BorderRadius.circular(widget.fill ? 0 : 8),
      child: mappedJobs.isEmpty
          ? _NoMapCoordinates(label: widget.label)
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: hasRoute
                    ? _midpoint(routeStart, routeDestination!)
                    : _jobPoint(mappedJobs.first),
                zoom: hasRoute
                    ? 12
                    : mappedJobs.length == 1
                    ? 15
                    : 12,
              ),
              markers: _markers(mappedJobs, routeStart),
              polygons: _polygons(mappedJobs),
              polylines: _polylines(mappedJobs, routeStart, routeDestination),
              compassEnabled: true,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (controller) {
                _controller = controller;
                unawaited(_fitMap(mappedJobs, routeStart, routeDestination));
              },
            ),
    );

    final content = Stack(
      fit: StackFit.expand,
      children: [
        map,
        Positioned(
          left: 12,
          top: 12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.agriculture, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_loadingRoute)
          const Positioned(
            right: 12,
            top: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Padding(
                padding: EdgeInsets.all(9),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
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
    final latitude = widget.routeFromLatitude;
    final longitude = widget.routeFromLongitude;
    if (latitude == null || longitude == null) return null;
    return LatLng(latitude, longitude);
  }

  LatLng _midpoint(LatLng first, LatLng second) {
    return LatLng(
      (first.latitude + second.latitude) / 2,
      (first.longitude + second.longitude) / 2,
    );
  }

  Set<Marker> _markers(List<OperatorJob> jobs, LatLng? routeStart) {
    return {
      if (routeStart != null)
        Marker(
          markerId: const MarkerId('tractor-current-location'),
          position: routeStart,
          icon:
              _tractorMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: const InfoWindow(title: 'Tractor / current location'),
        ),
      for (final job in jobs)
        Marker(
          markerId: MarkerId('job-${job.id}'),
          position: _jobPoint(job),
          icon:
              _farmMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: job.plot.name,
            snippet:
                '${job.serviceType.label} - ${job.status.label} - ${job.tractorLabel ?? job.tractorId}',
          ),
        ),
    };
  }

  Future<void> _loadMarkerIcons() async {
    final tractorIcon = await _makeMarkerIcon(
      icon: Icons.agriculture,
      color: const Color(0xFFF97316),
    );
    final farmIcon = await _makeMarkerIcon(
      icon: Icons.landscape,
      color: const Color(0xFF2F6F4E),
    );
    if (!mounted) return;
    setState(() {
      _tractorMarkerIcon = tractorIcon;
      _farmMarkerIcon = farmIcon;
    });
  }

  Future<BitmapDescriptor> _makeMarkerIcon({
    required IconData icon,
    required Color color,
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
    canvas.drawCircle(circleCenter, circleRadius, Paint()..color = Colors.white);
    canvas.drawCircle(
      circleCenter,
      circleRadius - 5,
      Paint()..color = color,
    );

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

    final image = await recorder
        .endRecording()
        .toImage(canvasSize.toInt(), canvasSize.toInt());
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
            fillColor: const Color(0xFF2F6F4E).withValues(alpha: 0.14),
            strokeColor: const Color(0xFF2F6F4E),
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
        ),
      for (final job in jobs)
        if (widget.showTrack && job.trackPoints.length >= 2)
          Polyline(
            polylineId: PolylineId('track-${job.id}'),
            points: [
              for (final point in job.trackPoints)
                LatLng(point.latitude, point.longitude),
            ],
            color: const Color(0xFF7B4BD2),
            width: 5,
          ),
    };
  }

  Future<void> _fitMap(
    List<OperatorJob> mappedJobs,
    LatLng? routeStart,
    LatLng? routeDestination,
  ) async {
    final controller = _controller;
    if (controller == null || mappedJobs.isEmpty) return;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    final points = <LatLng>[
      for (final job in mappedJobs) _jobPoint(job),
      for (final job in mappedJobs)
        for (final point in job.plot.boundaryPoints)
          LatLng(point.latitude, point.longitude),
      ?routeStart,
      ?routeDestination,
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
    final mappedJobs = [
      if (widget.job != null) widget.job!,
      ...widget.jobs.where((item) => item.id != widget.job?.id),
    ].where((item) => item.plot.boundaryPoints.isNotEmpty).toList();
    final start = _routeStart;
    if (start == null || mappedJobs.isEmpty) {
      if (_routePoints.isNotEmpty || _routeError != null || _loadingRoute) {
        setState(() {
          _routePoints = const [];
          _routeKey = null;
          _routeError = null;
          _loadingRoute = false;
        });
      }
      return;
    }

    final destination = _jobPoint(mappedJobs.first);
    final nextKey =
        '${start.latitude.toStringAsFixed(6)},${start.longitude.toStringAsFixed(6)}:'
        '${destination.latitude.toStringAsFixed(6)},${destination.longitude.toStringAsFixed(6)}';
    if (_routeKey == nextKey || _loadingRoute) return;

    setState(() {
      _routeKey = nextKey;
      _loadingRoute = true;
      _routeError = null;
      _routePoints = const [];
    });

    try {
      final points = await _fetchDrivingRoute(start, destination);
      if (!mounted || _routeKey != nextKey) return;
      setState(() {
        _routePoints = points;
        _loadingRoute = false;
        _routeError = points.length >= 2
            ? null
            : 'No road route was returned for this farm.';
      });
      unawaited(_fitMap(mappedJobs, start, destination));
    } catch (_) {
      if (!mounted || _routeKey != nextKey) return;
      setState(() {
        _routePoints = const [];
        _loadingRoute = false;
        _routeError =
            'Road route unavailable. Check Directions API access for this key.';
      });
    }
  }

  Future<List<LatLng>> _fetchDrivingRoute(
    LatLng origin,
    LatLng destination,
  ) async {
    final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': 'driving',
      'key': _googleDirectionsApiKey,
    });

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      final body = await utf8.decodeStream(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const SocketException('Directions request failed');
      }
      final decoded = jsonDecode(body) as Map<String, Object?>;
      if (decoded['status'] != 'OK') {
        throw const FormatException('Directions returned no route');
      }
      final routes = decoded['routes'];
      if (routes is! List || routes.isEmpty) return const [];
      final route = routes.first;
      if (route is! Map<String, Object?>) return const [];
      final overview = route['overview_polyline'];
      if (overview is! Map<String, Object?>) return const [];
      final encoded = overview['points'];
      if (encoded is! String || encoded.isEmpty) return const [];
      return _decodePolyline(encoded);
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
