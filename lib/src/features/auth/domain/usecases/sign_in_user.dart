import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class SignInUser {
  const SignInUser(this.repository);

  final AuthRepository repository;

  Future<AuthSession> call({
    required String phoneOrEmail,
    required String password,
  }) {
    return repository.signIn(phoneOrEmail: phoneOrEmail, password: password);
  }
}
