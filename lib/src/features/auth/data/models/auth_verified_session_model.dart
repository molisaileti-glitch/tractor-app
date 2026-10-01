import '../../domain/entities/auth_session.dart';

class AuthVerifiedSessionModel {
  const AuthVerifiedSessionModel({
    required this.token,
    required this.expiresAt,
    required this.user,
    required this.tenant,
  });

  factory AuthVerifiedSessionModel.fromJson(Map<String, Object?> json) {
    return AuthVerifiedSessionModel(
      token: json['token']?.toString() ?? '',
      expiresAt: json['expires_at']?.toString(),
      user: AuthUserModel.fromJson(_map(json['user'])),
      tenant: AuthTenantModel.fromJson(_map(json['tenant'])),
    );
  }

  final String token;
  final String? expiresAt;
  final AuthUserModel user;
  final AuthTenantModel tenant;

  AuthSession toEntity() {
    return AuthSession(
      status: AuthSessionStatus.signedIn,
      displayName: user.name,
      role: user.role,
      accessToken: token,
      permissions: user.permissions,
      tenantName: tenant.name,
      userId: user.id,
    );
  }

  static Map<String, Object?> _map(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }
}

class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
  });

  factory AuthUserModel.fromJson(Map<String, Object?> json) {
    return AuthUserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'User',
      email: json['email']?.toString(),
      role: json['role']?.toString(),
      permissions: _stringList(json['permissions']),
    );
  }

  final String id;
  final String name;
  final String? email;
  final String? role;
  final List<String> permissions;

  static List<String> _stringList(Object? value) {
    if (value is List) return value.map((item) => item.toString()).toList();
    return const [];
  }
}

class AuthTenantModel {
  const AuthTenantModel({
    required this.name,
    required this.brand,
    required this.logoUrl,
    required this.locale,
  });

  factory AuthTenantModel.fromJson(Map<String, Object?> json) {
    return AuthTenantModel(
      name: json['name']?.toString(),
      brand: json['brand']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      locale: json['locale']?.toString(),
    );
  }

  final String? name;
  final String? brand;
  final String? logoUrl;
  final String? locale;
}
