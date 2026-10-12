import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/device_location.dart';
import '../../domain/repositories/location_repository.dart';

class GeolocatorLocationRepository implements LocationRepository {
  const GeolocatorLocationRepository();

  @override
  Future<LocationResult> getCurrentLocation() async {
    final stopwatch = Stopwatch()..start();
    debugPrint('[GPS] Check started');
    final permissionResult = await _ensurePermission();
    if (permissionResult != null) {
      debugPrint('[GPS] Check stopped: $permissionResult');
      return LocationUnavailable(LocationFailure(permissionResult));
    }

    try {
      debugPrint(
        '[GPS] Requesting current position '
        '(provider=platform default, accuracy=high, no timeout)',
      );
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      );
      debugPrint(
        '[GPS] Current position received after ${stopwatch.elapsedMilliseconds}ms: '
        '${position.latitude},${position.longitude}; '
        'accuracy=${position.accuracy}m; timestamp=${position.timestamp}',
      );
      return LocationSuccess(_fromPosition(position));
    } on Exception catch (error, stackTrace) {
      debugPrint(
        '[GPS] Current position failed after ${stopwatch.elapsedMilliseconds}ms: '
        '${error.runtimeType}: $error',
      );
      debugPrintStack(label: '[GPS] Stack trace', stackTrace: stackTrace);
      return LocationUnavailable(
        LocationFailure('Could not read phone GPS: $error'),
      );
    }
  }

  @override
  Stream<DeviceLocation> watchLocation() async* {
    final permissionResult = await _ensurePermission();
    if (permissionResult != null) return;

    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).map(_fromPosition);
  }

  Future<String?> _ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint('[GPS] Location services enabled: $serviceEnabled');
    if (!serviceEnabled) {
      return 'Location services are disabled. Please turn on phone GPS.';
    }

    var permission = await Geolocator.checkPermission();
    debugPrint('[GPS] Permission before request: $permission');
    if (permission == LocationPermission.denied) {
      debugPrint('[GPS] Requesting location permission');
      permission = await Geolocator.requestPermission();
      debugPrint('[GPS] Permission after request: $permission');
    }

    if (permission == LocationPermission.denied) {
      return 'Location permission was denied.';
    }
    if (permission == LocationPermission.deniedForever) {
      return 'Location permission is permanently denied. Enable it in phone settings.';
    }

    return null;
  }

  DeviceLocation _fromPosition(Position position) {
    return DeviceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
      recordedAt: position.timestamp,
    );
  }
}
