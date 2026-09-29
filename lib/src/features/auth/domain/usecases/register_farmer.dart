import '../../../farmer/domain/entities/farmer_profile.dart';
import '../repositories/auth_repository.dart';

class RegisterFarmer {
  const RegisterFarmer(this.repository);

  final AuthRepository repository;

  Future<FarmerProfile> call({
    required FarmerProfile farmerProfile,
    required String password,
  }) {
    return repository.registerFarmer(
      farmerProfile: farmerProfile,
      password: password,
    );
  }
}
