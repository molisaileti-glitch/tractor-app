import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/device_location.dart';
import '../../domain/repositories/location_repository.dart';

class GeolocatorLocationRepository
    implements VerificationLocationRepository, LocationSettingsController {
  const GeolocatorLocationRepository();

  // Some tablets need substantially longer to obtain their first GNSS fix
  // after booting. Keep one native request alive long enough for a cold start;
  // callers share this request through [_pendingLocationRequest].
  static const Duration _positionTimeout = Duration(minutes: 2);
  static Future<LocationResult>? _pendingLocationRequest;
  static DateTime? _pendingLocationStartedAt;
  static int? _pendingLocationRequestId;
  static int _requestSequence = 0;

  @override
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<LocationResult> getCurrentLocation() async {
    final pendingRequest = _pendingLocationRequest;
    if (pendingRequest != null) {
      final age = _pendingLocationStartedAt == null
          ? null
          : DateTime.now().difference(_pendingLocationStartedAt!);
      debugPrint(
        '[GPS #${_pendingLocationRequestId ?? '?'}] Reusing the current '
        'in-flight position request; age_ms=${age?.inMilliseconds ?? 'unknown'}',
      );
      return pendingRequest;
    }

    final requestId = ++_requestSequence;
    final startedAt = DateTime.now();
    final request = _readCurrentLocation(requestId);
    _pendingLocationRequest = request;
    _pendingLocationRequestId = requestId;
    _pendingLocationStartedAt = startedAt;
    try {
      final result = await request;
      debugPrint(
        '[GPS #$requestId] Request completed; '
        'outcome=${result is LocationSuccess ? 'success' : 'unavailable'}; '
        'total_ms=${DateTime.now().difference(startedAt).inMilliseconds}',
      );
      return result;
    } finally {
      if (identical(_pendingLocationRequest, request)) {
        _pendingLocationRequest = null;
        _pendingLocationRequestId = null;
        _pendingLocationStartedAt = null;
      }
    }
  }

  Future<LocationResult> _readCurrentLocation(int requestId) async {
    final stopwatch = Stopwatch()..start();
    final prefix = '[GPS #$requestId]';
    debugPrint(
      '$prefix Check started; platform=${defaultTargetPlatform.name}; '
      'requested_accuracy=high; timeout_s=${_positionTimeout.inSeconds}',
    );
    try {
      final permissionResult = await _ensurePermission(prefix);
      if (permissionResult != null) {
        debugPrint('$prefix Blocked before native request: $permissionResult');
        return LocationUnavailable(LocationFailure(permissionResult));
      }

      await _logDiagnosticSnapshot(prefix, phase: 'before_request');
      debugPrint(
        '$prefix Starting native getCurrentPosition; '
        'provider=platform_default; accuracy=high; '
        'distance_filter_m=5; timeout_s=${_positionTimeout.inSeconds}',
      );
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
          timeLimit: _positionTimeout,
        ),
      );
      debugPrint(
        '$prefix Current position received; '
        'elapsed_ms=${stopwatch.elapsedMilliseconds}; '
        '${_describePosition(position)}',
      );
      return LocationSuccess(_fromPosition(position));
    } on TimeoutException catch (error) {
      debugPrint(
        '$prefix Native position timed out; '
        'elapsed_ms=${stopwatch.elapsedMilliseconds}; error=$error',
      );
      await _logDiagnosticSnapshot(prefix, phase: 'after_timeout');
      return const LocationUnavailable(
        LocationFailure(
          'Phone GPS is on and permission is allowed, but Android did not '
          'return a position within 2 minutes. Move to an open area with a '
          'clear view of the sky, confirm your position in Google Maps, then '
          'try again.',
        ),
      );
    } on LocationServiceDisabledException catch (error, stackTrace) {
      debugPrint(
        '$prefix Location service became disabled during the native request; '
        'elapsed_ms=${stopwatch.elapsedMilliseconds}; error=$error',
      );
      debugPrintStack(
        label: '$prefix Location service stack trace',
        stackTrace: stackTrace,
      );
      return const LocationUnavailable(
        LocationFailure(
          'Location services were turned off while checking your position. '
          'Turn on phone GPS and try again.',
        ),
      );
    } on PermissionDefinitionsNotFoundException catch (error, stackTrace) {
      debugPrint(
        '$prefix Location permission definitions are missing from the native '
        'app; elapsed_ms=${stopwatch.elapsedMilliseconds}; error=$error',
      );
      debugPrintStack(
        label: '$prefix Permission configuration stack trace',
        stackTrace: stackTrace,
      );
      return const LocationUnavailable(
        LocationFailure(
          'The application location permission configuration is missing.',
        ),
      );
    } on PermissionRequestInProgressException catch (error, stackTrace) {
      debugPrint(
        '$prefix Another Android permission dialog is already active; '
        'elapsed_ms=${stopwatch.elapsedMilliseconds}; error=$error',
      );
      debugPrintStack(
        label: '$prefix Permission request stack trace',
        stackTrace: stackTrace,
      );
      return const LocationUnavailable(
        LocationFailure(
          'Another location permission request is already open. Complete it '
          'and try again.',
        ),
      );
    } on PermissionDeniedException catch (error, stackTrace) {
      debugPrint(
        '$prefix Android rejected location permission during the native '
        'request; elapsed_ms=${stopwatch.elapsedMilliseconds}; error=$error',
      );
      debugPrintStack(
        label: '$prefix Permission stack trace',
        stackTrace: stackTrace,
      );
      return const LocationUnavailable(
        LocationFailure(
          'Location permission was removed while checking your position. '
          'Allow precise location for SB Mechanization and try again.',
        ),
      );
    } on PositionUpdateException catch (error, stackTrace) {
      debugPrint(
        '$prefix Android location provider reported an update failure; '
        'elapsed_ms=${stopwatch.elapsedMilliseconds}; error=$error',
      );
      debugPrintStack(
        label: '$prefix Position update stack trace',
        stackTrace: stackTrace,
      );
      return LocationUnavailable(
        LocationFailure('Android could not update the phone position: $error'),
      );
    } on Exception catch (error, stackTrace) {
      debugPrint(
        '$prefix Unexpected location failure; '
        'elapsed_ms=${stopwatch.elapsedMilliseconds}; '
        'type=${error.runtimeType}; error=$error',
      );
      debugPrintStack(label: '$prefix Stack trace', stackTrace: stackTrace);
      return LocationUnavailable(
        LocationFailure('Could not read phone GPS: $error'),
      );
    }
  }

  @override
  Stream<DeviceLocation> watchLocation() async* {
    const prefix = '[GPS stream]';
    debugPrint('$prefix Subscription requested');
    final permissionResult = await _ensurePermission(prefix);
    if (permissionResult != null) {
      debugPrint('$prefix Subscription blocked: $permissionResult');
      return;
    }

    try {
      var updateNumber = 0;
      final settings = defaultTargetPlatform == TargetPlatform.android
          ? AndroidSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
              intervalDuration: Duration(seconds: 5),
            )
          : const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
            );
      await for (final position in Geolocator.getPositionStream(
        locationSettings: settings,
      )) {
        updateNumber += 1;
        debugPrint(
          '$prefix Update #$updateNumber received; ${_describePosition(position)}',
        );
        yield _fromPosition(position);
      }
      debugPrint('$prefix Native position stream closed');
    } on Exception catch (error, stackTrace) {
      debugPrint(
        '$prefix Stream failed; type=${error.runtimeType}; error=$error',
      );
      debugPrintStack(label: '$prefix Stack trace', stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Stream<DeviceLocation> watchVerificationLocation({
    bool forceNativeProvider = false,
  }) async* {
    const prefix = '[GPS verification]';
    debugPrint(
      '$prefix Subscription requested; '
      'force_native_provider=$forceNativeProvider',
    );
    final permissionResult = await _ensurePermission(prefix);
    if (permissionResult != null) {
      debugPrint('$prefix Subscription blocked: $permissionResult');
      throw StateError(permissionResult);
    }

    final settings = defaultTargetPlatform == TargetPlatform.android
        ? AndroidSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 0,
            intervalDuration: const Duration(seconds: 3),
            forceLocationManager: forceNativeProvider,
          )
        : const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 0,
          );
    var updateNumber = 0;
    await for (final position in Geolocator.getPositionStream(
      locationSettings: settings,
    )) {
      updateNumber += 1;
      debugPrint(
        '$prefix Update #$updateNumber received; ${_describePosition(position)}',
      );
      yield _fromPosition(position);
    }
  }

  Future<String?> _ensurePermission(String prefix) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('$prefix Checking Android location service state');
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint(
      '$prefix Location service state received; enabled=$serviceEnabled; '
      'elapsed_ms=${stopwatch.elapsedMilliseconds}',
    );
    if (!serviceEnabled) {
      return 'Location services are disabled. Please turn on phone GPS.';
    }

    stopwatch.reset();
    var permission = await Geolocator.checkPermission();
    debugPrint(
      '$prefix Runtime permission checked; permission=$permission; '
      'elapsed_ms=${stopwatch.elapsedMilliseconds}',
    );
    if (permission == LocationPermission.denied) {
      stopwatch.reset();
      debugPrint(
        '$prefix Runtime permission is denied; opening the Android permission '
        'request now',
      );
      permission = await Geolocator.requestPermission();
      debugPrint(
        '$prefix Android permission request completed; permission=$permission; '
        'elapsed_ms=${stopwatch.elapsedMilliseconds}',
      );
    }

    if (permission == LocationPermission.denied) {
      return 'Location permission was denied.';
    }
    if (permission == LocationPermission.deniedForever) {
      return 'Location permission is permanently denied. Enable it in phone settings.';
    }
    if (permission == LocationPermission.unableToDetermine) {
      return 'Android could not determine the location permission state.';
    }

    debugPrint('$prefix Runtime permission accepted: $permission');

    return null;
  }

  Future<void> _logDiagnosticSnapshot(
    String prefix, {
    required String phase,
  }) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('$prefix Diagnostic $phase; service_enabled=$serviceEnabled');
    } on Exception catch (error) {
      debugPrint(
        '$prefix Diagnostic $phase; could_not_read_service_state; '
        'type=${error.runtimeType}; error=$error',
      );
    }

    try {
      final permission = await Geolocator.checkPermission();
      debugPrint('$prefix Diagnostic $phase; permission=$permission');
    } on Exception catch (error) {
      debugPrint(
        '$prefix Diagnostic $phase; could_not_read_permission; '
        'type=${error.runtimeType}; error=$error',
      );
    }

    try {
      final accuracy = await Geolocator.getLocationAccuracy();
      debugPrint(
        '$prefix Diagnostic $phase; permission_accuracy=$accuracy '
        '(precise is required for reliable geofence checks)',
      );
    } on Exception catch (error) {
      debugPrint(
        '$prefix Diagnostic $phase; could_not_read_permission_accuracy; '
        'type=${error.runtimeType}; error=$error',
      );
    }

    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      debugPrint(
        '$prefix Diagnostic $phase; last_known=${lastKnown == null ? 'none' : _describePosition(lastKnown)}',
      );
    } on Exception catch (error) {
      debugPrint(
        '$prefix Diagnostic $phase; could_not_read_last_known_position; '
        'type=${error.runtimeType}; error=$error',
      );
    }
  }

  String _describePosition(Position position) {
    final ageSeconds =
        DateTime.now().difference(position.timestamp).inMilliseconds ~/ 1000;
    return 'lat=${position.latitude}; lng=${position.longitude}; '
        'accuracy_m=${position.accuracy}; has_accuracy=${position.hasAccuracy}; '
        'age_s=$ageSeconds; timestamp=${position.timestamp.toUtc().toIso8601String()}; '
        'speed_mps=${position.speed}; mocked=${position.isMocked}';
  }

  DeviceLocation _fromPosition(Position position) {
    return DeviceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
      recordedAt: position.timestamp,
      speedMetersPerSecond: position.speed,
      isMocked: position.isMocked,
    );
  }
}
