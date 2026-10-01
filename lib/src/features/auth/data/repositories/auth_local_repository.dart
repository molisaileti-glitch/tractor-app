import 'package:flutter/foundation.dart';

import '../../../farmer/data/models/farmer_profile_model.dart';
import '../../../farmer/domain/entities/farmer_profile.dart';
import '../models/auth_challenge_model.dart';
import '../remote/auth_remote_data_source.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthLocalRepository extends ChangeNotifier implements AuthRepository {
  AuthLocalRepository({AuthRemoteDataSource? remoteDataSource})
    : remoteDataSource = remoteDataSource ?? const AuthRemoteDataSource();

  final AuthRemoteDataSource remoteDataSource;

  AuthSession _currentSession = const AuthSession(
    status: AuthSessionStatus.signedOut,
  );

  final List<FarmerProfileModel> _farmers = [];

  @override
  AuthSession get currentSession => _currentSession;

  List<FarmerProfileModel> get farmers => List.unmodifiable(_farmers);

  Future<AuthChallengeModel> requestLoginChallenge({
    required String identifier,
    required String password,
    required String deviceName,
  }) {
    return remoteDataSource.login(
      identifier: identifier,
      password: password,
      deviceName: deviceName,
    );
  }

  Future<AuthSession> verifyRemoteOtp({
    required String challengeId,
    required String code,
    required String deviceName,
  }) async {
    final verified = await remoteDataSource.verifyOtp(
      challengeId: challengeId,
      code: code,
      deviceName: deviceName,
    );
    _currentSession = verified.toEntity();
    notifyListeners();
    return _currentSession;
  }

  @override
  Future<AuthSession> signIn({
    required String phoneOrEmail,
    required String password,
  }) async {
    final normalized = phoneOrEmail.trim().toLowerCase();
    final farmer = _farmers.where((candidate) {
      return candidate.phoneNumber == phoneOrEmail.trim() ||
          candidate.email?.toLowerCase() == normalized;
    }).firstOrNull;

    _currentSession = AuthSession(
      status: AuthSessionStatus.signedIn,
      displayName: farmer?.toEntity().fullName ?? 'Asha Manager',
      role: farmer == null ? 'manager' : 'farmer',
    );
    notifyListeners();
    return _currentSession;
  }

  @override
  Future<FarmerProfile> registerFarmer({
    required FarmerProfile farmerProfile,
    required String password,
  }) async {
    final farmerModel = FarmerProfileModel(
      id: farmerProfile.id,
      firstName: farmerProfile.firstName,
      middleName: farmerProfile.middleName,
      lastName: farmerProfile.lastName,
      phoneNumber: farmerProfile.phoneNumber,
      email: farmerProfile.email,
      passwordHash: _offlinePasswordMarker(password),
      membershipNumber: farmerProfile.membershipNumber,
      village: farmerProfile.village,
      sex: farmerProfile.sex,
      identityDocumentType: farmerProfile.identityDocumentType,
      identityNumber: farmerProfile.identityNumber,
      dateOfBirth: farmerProfile.dateOfBirth,
      createdAt: farmerProfile.createdAt,
      updatedAt: farmerProfile.updatedAt,
    );

    _farmers.add(farmerModel);
    _currentSession = AuthSession(
      status: AuthSessionStatus.pendingSync,
      displayName: farmerModel.toEntity().fullName,
      role: 'farmer',
    );
    notifyListeners();
    return farmerModel.toEntity();
  }

  @override
  Future<void> signOut() async {
    final token = _currentSession.accessToken;
    _currentSession = const AuthSession(status: AuthSessionStatus.signedOut);
    notifyListeners();
    if (token != null && token.isNotEmpty) {
      try {
        await remoteDataSource.logout(token: token);
      } on AuthRemoteException {
        // The local app should still return to Login even if remote logout fails.
      }
    }
  }

  String _offlinePasswordMarker(String password) {
    return 'offline-demo:${password.length}';
  }
}
