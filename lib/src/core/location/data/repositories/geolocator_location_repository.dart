import 'package:geolocator/geolocator.dart';

import '../../domain/entities/device_location.dart';
import '../../domain/repositories/location_repository.dart';

class GeolocatorLocationRepository implements LocationRepository {
  const GeolocatorLocationRepository();

  @override
  Future<LocationResult> getCurrentLocation() async {
    final permissionResult = await _ensurePermission();
    if (permissionResult != null) {
      return LocationUnavailable(LocationFailure(permissionResult));
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      );
      return LocationSuccess(_fromPosition(position));
    } on Exception catch (error) {
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
    if (!serviceEnabled) {
      return 'Location services are disabled. Please turn on phone GPS.';
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
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
