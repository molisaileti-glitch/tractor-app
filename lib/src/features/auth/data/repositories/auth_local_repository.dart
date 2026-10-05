import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../farmer/data/models/farmer_profile_model.dart';
import '../../../farmer/domain/entities/farmer_profile.dart';
import '../models/auth_challenge_model.dart';
import '../remote/auth_remote_data_source.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthLocalRepository extends ChangeNotifier implements AuthRepository {
  AuthLocalRepository({
    AuthRemoteDataSource? remoteDataSource,
    FlutterSecureStorage? secureStorage,
  }) : remoteDataSource = remoteDataSource ?? const AuthRemoteDataSource(),
       secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'kwanza_track_access_token';

  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  AuthSession _currentSession = const AuthSession(
    status: AuthSessionStatus.signedOut,
  );

  final List<FarmerProfileModel> _farmers = [];

  @override
  AuthSession get currentSession => _currentSession;

  List<FarmerProfileModel> get farmers => List.unmodifiable(_farmers);

  Future<AuthSession> restoreSavedSession() async {
    try {
      final token = await secureStorage.read(key: _accessTokenKey);
      if (token == null || token.isEmpty) return _currentSession;
      return await refreshRemoteSession(token: token);
    } on AuthRemoteException catch (error) {
      if (!error.isSessionExpired) rethrow;
      await secureStorage.delete(key: _accessTokenKey);
      _currentSession = const AuthSession(status: AuthSessionStatus.signedOut);
      notifyListeners();
      return _currentSession;
    } catch (_) {
      return _currentSession;
    }
  }

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
    await _persistAccessToken(_currentSession.accessToken);
    notifyListeners();
    return _currentSession;
  }

  Future<AuthChallengeModel> resendRemoteOtp({required String challengeId}) {
    return remoteDataSource.resendOtp(challengeId: challengeId);
  }

  Future<AuthSession> refreshRemoteSession({required String token}) async {
    final verified = await remoteDataSource.me(token: token);
    _currentSession = verified.toEntity();
    await _persistAccessToken(_currentSession.accessToken);
    notifyListeners();
    return _currentSession;
  }

  @override
  Future<AuthSession> signIn({
    required String phoneOrEmail,
    required String password,
  }) {
    throw UnsupportedError('Password sign-in is not available in online mode.');
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
      passwordHash: 'remote-only',
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
    await _persistAccessToken(null);
    notifyListeners();
    if (token != null && token.isNotEmpty) {
      try {
        await remoteDataSource.logout(token: token);
      } on AuthRemoteException {
        // The local app should still return to Login even if remote logout fails.
      }
    }
  }

  Future<void> _persistAccessToken(String? token) async {
    try {
      if (token == null || token.isEmpty) {
        await secureStorage.delete(key: _accessTokenKey);
        return;
      }
      await secureStorage.write(key: _accessTokenKey, value: token);
    } catch (error) {
      debugPrint('Could not persist auth token: $error');
    }
  }
}
