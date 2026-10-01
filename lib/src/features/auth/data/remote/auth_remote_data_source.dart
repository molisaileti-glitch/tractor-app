import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/auth_challenge_model.dart';
import '../models/auth_verified_session_model.dart';

class AuthRemoteException implements Exception {
  const AuthRemoteException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class AuthRemoteDataSource {
  const AuthRemoteDataSource({this.baseUrl = 'http://161.35.65.228'});

  final String baseUrl;

  Future<AuthChallengeModel> login({
    required String identifier,
    required String password,
    required String deviceName,
    String? tenantId,
  }) async {
    final body = <String, Object?>{
      'identifier': identifier,
      'password': password,
      'device_name': deviceName,
    };
    if (tenantId != null) body['tenant_id'] = tenantId;
    final json = await _post('/api/app/login', body);
    final data = _data(json);
    if (data['tenant_choice_required'] == true ||
        json['tenant_choice_required'] == true) {
      throw const AuthRemoteException(
        'This account belongs to more than one organisation. Tenant selection is not connected yet.',
        code: 'tenant_choice_required',
      );
    }
    return AuthChallengeModel.fromJson(data);
  }

  Future<AuthVerifiedSessionModel> verifyOtp({
    required String challengeId,
    required String code,
    required String deviceName,
  }) async {
    final json = await _post('/api/app/verify-otp', {
      'challenge_id': challengeId,
      'code': code,
      'device_name': deviceName,
    });
    return AuthVerifiedSessionModel.fromJson(_data(json));
  }

  Future<AuthChallengeModel> resendOtp({required String challengeId}) async {
    final json = await _post('/api/app/resend-otp', {
      'challenge_id': challengeId,
    });
    return AuthChallengeModel.fromJson(_data(json));
  }

  Future<AuthVerifiedSessionModel> me({required String token}) async {
    final json = await _get('/api/app/me', token: token);
    return AuthVerifiedSessionModel.fromJson(_data(json));
  }

  Future<void> logout({required String token}) async {
    await _post('/api/app/logout', const {}, token: token);
  }

  Future<Map<String, Object?>> _get(String path, {String? token}) async {
    return _send('GET', path, null, token: token);
  }

  Future<Map<String, Object?>> _post(
    String path,
    Map<String, Object?> body, {
    String? token,
  }) {
    return _send('POST', path, body, token: token);
  }

  Future<Map<String, Object?>> _send(
    String method,
    String path,
    Map<String, Object?>? body, {
    String? token,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final uri = Uri.parse('$baseUrl$path');
      _logRequest(
        method: method,
        uri: uri,
        body: body,
        hasToken: token != null,
      );
      final request = method == 'GET'
          ? await client.getUrl(uri).timeout(const Duration(seconds: 10))
          : await client.postUrl(uri).timeout(const Duration(seconds: 10));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      if (token != null && token.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      if (body != null) {
        request.write(jsonEncode(body));
      }

      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      final responseBody = await response.transform(utf8.decoder).join();
      late final Map<String, Object?> decoded;
      try {
        decoded = responseBody.trim().isEmpty
            ? <String, Object?>{}
            : _map(jsonDecode(responseBody));
      } on FormatException {
        _logRawResponse(
          method: method,
          uri: uri,
          statusCode: response.statusCode,
          rawBody: responseBody,
        );
        rethrow;
      }
      _logResponse(
        method: method,
        uri: uri,
        statusCode: response.statusCode,
        body: decoded,
      );
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          decoded['success'] == false) {
        _logRawResponse(
          method: method,
          uri: uri,
          statusCode: response.statusCode,
          rawBody: responseBody,
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AuthRemoteException(
          decoded['message']?.toString() ??
              'Authentication failed with HTTP ${response.statusCode}.',
          code: decoded['code']?.toString(),
        );
      }
      if (decoded['success'] == false) {
        throw AuthRemoteException(
          decoded['message']?.toString() ?? 'Authentication failed.',
          code: decoded['code']?.toString(),
        );
      }
      return decoded;
    } on TimeoutException {
      _logError(method: method, path: path, message: 'request timed out');
      throw const AuthRemoteException('Authentication request timed out.');
    } on SocketException {
      _logError(method: method, path: path, message: 'server unreachable');
      throw const AuthRemoteException('Authentication server is unreachable.');
    } on FormatException {
      _logError(method: method, path: path, message: 'invalid JSON response');
      throw const AuthRemoteException(
        'Authentication server returned invalid JSON.',
      );
    } finally {
      client.close(force: true);
    }
  }

  Map<String, Object?> _data(Map<String, Object?> json) {
    final data = json['data'];
    if (data is Map) return _map(data);
    return json;
  }

  Map<String, Object?> _map(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }

  void _logRequest({
    required String method,
    required Uri uri,
    required Map<String, Object?>? body,
    required bool hasToken,
  }) {
    if (!kDebugMode) return;
    debugPrint('[Auth API] $method $uri');
    debugPrint('[Auth API] auth header: ${hasToken ? 'Bearer ***' : 'none'}');
    if (body != null) {
      debugPrint('[Auth API] request: ${jsonEncode(_redact(body))}');
    }
  }

  void _logResponse({
    required String method,
    required Uri uri,
    required int statusCode,
    required Map<String, Object?> body,
  }) {
    if (!kDebugMode) return;
    debugPrint('[Auth API] response: $method $uri -> HTTP $statusCode');
    debugPrint('[Auth API] body: ${jsonEncode(_redact(body))}');
  }

  void _logRawResponse({
    required String method,
    required Uri uri,
    required int statusCode,
    required String rawBody,
  }) {
    if (!kDebugMode) return;
    debugPrint('[Auth API] raw response: $method $uri -> HTTP $statusCode');
    debugPrint('[Auth API] raw body: ${_redactRawBody(rawBody)}');
  }

  void _logError({
    required String method,
    required String path,
    required String message,
  }) {
    if (!kDebugMode) return;
    debugPrint('[Auth API] error: $method $baseUrl$path -> $message');
  }

  Object? _redact(Object? value) {
    if (value is Map) {
      return value.map((key, value) {
        final normalized = key.toString().toLowerCase();
        if (normalized.contains('password') ||
            normalized == 'code' ||
            normalized.contains('token') ||
            normalized.contains('api_key')) {
          return MapEntry(key.toString(), '***');
        }
        return MapEntry(key.toString(), _redact(value));
      });
    }
    if (value is List) return value.map(_redact).toList();
    return value;
  }

  String _redactRawBody(String rawBody) {
    if (rawBody.isEmpty) return '<empty>';
    try {
      final decoded = jsonDecode(rawBody);
      return jsonEncode(_redact(decoded));
    } on FormatException {
      const maxLength = 3000;
      return rawBody.length <= maxLength
          ? rawBody
          : '${rawBody.substring(0, maxLength)}...<truncated>';
    }
  }
}
