import '../../domain/entities/device_location.dart';
import '../../domain/repositories/location_repository.dart';

class MockLocationRepository implements LocationRepository {
  const MockLocationRepository({required this.location});

  final DeviceLocation location;

  @override
  Future<LocationResult> getCurrentLocation() async {
    return LocationSuccess(location);
  }

  @override
  Stream<DeviceLocation> watchLocation() {
    return Stream.value(location);
  }
}
