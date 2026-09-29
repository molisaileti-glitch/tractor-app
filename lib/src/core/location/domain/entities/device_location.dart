class DeviceLocation {
  const DeviceLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.recordedAt,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime recordedAt;
}

class LocationFailure {
  const LocationFailure(this.message);

  final String message;
}

sealed class LocationResult {
  const LocationResult();
}

class LocationSuccess extends LocationResult {
  const LocationSuccess(this.location);

  final DeviceLocation location;
}

class LocationUnavailable extends LocationResult {
  const LocationUnavailable(this.failure);

  final LocationFailure failure;
}
