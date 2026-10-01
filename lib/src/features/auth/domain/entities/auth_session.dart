enum AuthSessionStatus { signedOut, signedIn, pendingSync }

class AuthSession {
  const AuthSession({
    required this.status,
    this.displayName,
    this.role,
    this.accessToken,
    this.refreshToken,
    this.permissions = const [],
    this.tenantName,
    this.userId,
  });

  final AuthSessionStatus status;
  final String? displayName;
  final String? role;
  final String? accessToken;
  final String? refreshToken;
  final List<String> permissions;
  final String? tenantName;
  final String? userId;

  bool get isSignedIn => status == AuthSessionStatus.signedIn;
}
