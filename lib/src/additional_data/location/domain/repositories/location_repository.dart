import '../entities/device_location.dart';

abstract class LocationRepository {
  Future<LocationResult> getCurrentLocation();

  Stream<DeviceLocation> watchLocation();
}

abstract class VerificationLocationRepository implements LocationRepository {
  /// A short, foreground-only stream used while the operator is confirming
  /// field evidence. Implementations may increase accuracy and update rate.
  Stream<DeviceLocation> watchVerificationLocation({
    bool forceNativeProvider = false,
  });
}

/// Optional device-settings controls used by screens that require GPS.
/// Test and web repositories can omit this capability.
abstract class LocationSettingsController {
  Future<bool> isLocationServiceEnabled();

  Future<bool> openLocationSettings();

  Future<bool> openAppSettings();
}
