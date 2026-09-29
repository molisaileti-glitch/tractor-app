import '../../../farmer/domain/entities/farmer_profile.dart';
import '../entities/auth_session.dart';

abstract class AuthRepository {
  AuthSession get currentSession;

  Future<AuthSession> signIn({
    required String phoneOrEmail,
    required String password,
  });

  Future<FarmerProfile> registerFarmer({
    required FarmerProfile farmerProfile,
    required String password,
  });

  Future<void> signOut();
}
