enum AuthSessionStatus { signedOut, signedIn, pendingSync }

class AuthSession {
  const AuthSession({
    required this.status,
    this.displayName,
    this.role,
    this.accessToken,
    this.refreshToken,
  });

  final AuthSessionStatus status;
  final String? displayName;
  final String? role;
  final String? accessToken;
  final String? refreshToken;

  bool get isSignedIn => status == AuthSessionStatus.signedIn;
}
