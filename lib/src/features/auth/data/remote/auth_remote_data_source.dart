import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../core/constants/mechanization_endpoints.dart';
import '../models/auth_challenge_model.dart';
import '../models/auth_verified_session_model.dart';

class AuthRemoteException implements Exception {
  const AuthRemoteException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  bool get isSessionExpired =>
      statusCode == 401 ||
      statusCode == 419 ||
      code == 'unauthenticated' ||
      code == 'unauthorized' ||
      code == 'token_expired' ||
      code == 'session_expired';

  @override
  String toString() => message;
}

class AuthRemoteDataSource {
  const AuthRemoteDataSource({this.baseUrl = MechanizationEndpoints.baseUrl});

  static int _requestSequence = 0;

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
    final json = await _post(
      '/api/app/login',
      body,
      operation: 'request login OTP',
    );
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
    }, operation: 'verify login OTP');
    return AuthVerifiedSessionModel.fromJson(_data(json));
  }

  Future<AuthChallengeModel> resendOtp({required String challengeId}) async {
    final json = await _post('/api/app/resend-otp', {
      'challenge_id': challengeId,
    }, operation: 'resend login OTP');
    return AuthChallengeModel.fromJson(_data(json));
  }

  Future<AuthVerifiedSessionModel> me({required String token}) async {
    final json = await _get(
      '/api/app/me',
      token: token,
      operation: 'load authenticated user',
    );
    return AuthVerifiedSessionModel.fromJson(_data(json), accessToken: token);
  }

  Future<void> logout({required String token}) async {
    await _post('/api/app/logout', const {}, token: token, operation: 'logout');
  }

  Future<Map<String, Object?>> _get(
    String path, {
    String? token,
    String? operation,
  }) async {
    return _send('GET', path, null, token: token, operation: operation);
  }

  Future<Map<String, Object?>> _post(
    String path,
    Map<String, Object?> body, {
    String? token,
    String? operation,
  }) {
    return _send('POST', path, body, token: token, operation: operation);
  }

  Future<Map<String, Object?>> _send(
    String method,
    String path,
    Map<String, Object?>? body, {
    String? token,
    String? operation,
  }) async {
    final requestId = ++_requestSequence;
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final uri = Uri.parse('$baseUrl$path');
      _logRequest(
        requestId: requestId,
        operation: operation,
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
          requestId: requestId,
          method: method,
          uri: uri,
          statusCode: response.statusCode,
          rawBody: responseBody,
        );
        rethrow;
      }
      _logResponse(
        requestId: requestId,
        method: method,
        uri: uri,
        statusCode: response.statusCode,
        body: decoded,
      );
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          decoded['success'] == false) {
        _logRawResponse(
          requestId: requestId,
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
          statusCode: response.statusCode,
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
      _logError(
        requestId: requestId,
        method: method,
        path: path,
        message: 'request timed out',
      );
      throw const AuthRemoteException('Authentication request timed out.');
    } on SocketException {
      _logError(
        requestId: requestId,
        method: method,
        path: path,
        message: 'server unreachable',
      );
      throw const AuthRemoteException('Authentication server is unreachable.');
    } on FormatException {
      _logError(
        requestId: requestId,
        method: method,
        path: path,
        message: 'invalid JSON response',
      );
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
    required int requestId,
    required String? operation,
    required String method,
    required Uri uri,
    required Map<String, Object?>? body,
    required bool hasToken,
  }) {
    if (!kDebugMode) return;
    if (operation != null) {
      debugPrint('[Auth API #$requestId] operation: $operation');
    }
    debugPrint('[Auth API #$requestId] --> $method $uri');
    debugPrint(
      '[Auth API #$requestId] auth header: '
      '${hasToken ? 'Bearer ***' : 'none'}',
    );
    if (body != null) {
      _logJson(requestId, 'request body', _redact(body));
    }
  }

  void _logResponse({
    required int requestId,
    required String method,
    required Uri uri,
    required int statusCode,
    required Map<String, Object?> body,
  }) {
    if (!kDebugMode) return;
    debugPrint('[Auth API #$requestId] <-- HTTP $statusCode $method $uri');
    _logJson(requestId, 'response body', _redact(body));
  }

  void _logRawResponse({
    required int requestId,
    required String method,
    required Uri uri,
    required int statusCode,
    required String rawBody,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      '[Auth API #$requestId] raw response: '
      '$method $uri -> HTTP $statusCode',
    );
    _logText(requestId, 'raw body', _redactRawBody(rawBody));
  }

  void _logError({
    required int requestId,
    required String method,
    required String path,
    required String message,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      '[Auth API #$requestId] error: $method $baseUrl$path -> $message',
    );
  }

  void _logJson(int requestId, String label, Object? value) {
    _logText(requestId, label, jsonEncode(value));
  }

  void _logText(int requestId, String label, String value) {
    if (!kDebugMode) return;
    const chunkSize = 900;
    final total = value.isEmpty ? 1 : (value.length / chunkSize).ceil();
    for (var index = 0; index < total; index++) {
      final start = index * chunkSize;
      final end = (start + chunkSize).clamp(0, value.length);
      debugPrint(
        '[Auth API #$requestId] $label [${index + 1}/$total] '
        '${value.substring(start, end)}',
      );
    }
  }

  Object? _redact(Object? value) {
    if (value is Map) {
      return value.map((key, value) {
        final normalized = key.toString().toLowerCase();
        if (normalized.contains('password') ||
            normalized == 'code' ||
            normalized.contains('token') ||
            normalized.contains('api_key') ||
            normalized == 'challenge_id' ||
            normalized == 'identifier' ||
            normalized == 'phone' ||
            normalized == 'email' ||
            normalized == 'destination') {
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
