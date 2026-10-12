import '../entities/device_location.dart';

abstract class LocationRepository {
  Future<LocationResult> getCurrentLocation();

  Stream<DeviceLocation> watchLocation();
}
