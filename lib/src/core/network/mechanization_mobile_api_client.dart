import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data' show BytesBuilder;

import 'package:flutter/foundation.dart';

import '../constants/mechanization_endpoints.dart';

class _PhotoUpload {
  const _PhotoUpload(this.bytes, this.name, this.mime, this.fields);
  final Uint8List bytes;
  final String name;
  final String mime;
  final Map<String, String> fields;
}

class MechanizationApiException implements Exception {
  const MechanizationApiException(
    this.message, {
    this.code,
    this.statusCode,
    this.errors = const {},
    this.retryAfter,
  });

  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, Object?> errors;
  final Duration? retryAfter;

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

class MechanizationMobileApiClient {
  const MechanizationMobileApiClient({
    this.baseUrl = MechanizationEndpoints.baseUrl,
    this.apiPrefix = '/api/v1/mech',
  });

  static FutureOr<void> Function(String token)? onUnauthorized;
  static int _requestSequence = 0;
  static final Map<String, DateTime> _retryNotBefore = {};

  final String baseUrl;
  final String apiPrefix;

  Future<Map<String, Object?>> me({required String token}) {
    return _get('/me', token: token);
  }

  Future<Map<String, Object?>> dashboard({
    required String token,
    int days = 30,
  }) {
    return _get('/dashboard', token: token, query: {'days': days});
  }

  Future<Map<String, Object?>> calendar({
    required String token,
    String? from,
    String? to,
    bool? mine,
    String? status,
    String? tractorId,
    String? operatorId,
  }) {
    return _get(
      '/calendar',
      token: token,
      query: {
        'from': from,
        'to': to,
        'mine': mine == null ? null : (mine ? '1' : '0'),
        'status': status,
        'tractor_id': tractorId,
        'operator_id': operatorId,
      },
    );
  }

  Future<Map<String, Object?>> calendarBacklog({required String token}) {
    return _get('/calendar/backlog', token: token);
  }

  Future<Map<String, Object?>> jobs({
    required String token,
    String? status,
    String? date,
    String? from,
    String? to,
    bool? mine,
    String? tractorId,
    int? page,
    int? perPage,
  }) {
    return _get(
      '/jobs',
      token: token,
      query: {
        'status': status,
        'date': date,
        'from': from,
        'to': to,
        'mine': mine == null ? null : (mine ? '1' : '0'),
        'tractor_id': tractorId,
        'page': page,
        'per_page': perPage,
      },
    );
  }

  Future<Map<String, Object?>> job({
    required String token,
    required String jobId,
  }) {
    return _get('/jobs/$jobId', token: token);
  }

  Future<Map<String, Object?>> jobPath({
    required String token,
    required String jobId,
  }) {
    return _get('/jobs/$jobId/path', token: token);
  }

  Future<Map<String, Object?>> acceptJob({
    required String token,
    required String jobId,
    String? clientEventId,
    Map<String, Object?>? phone,
  }) {
    return _jobAction(token, jobId, 'accept', {
      'client_event_id': clientEventId,
      'phone': phone,
    });
  }

  Future<Map<String, Object?>> markEnRoute({
    required String token,
    required String jobId,
    String? clientEventId,
    Map<String, Object?>? phone,
  }) {
    return _jobAction(token, jobId, 'en-route', {
      'client_event_id': clientEventId,
      'phone': phone,
    });
  }

  Future<Map<String, Object?>> arriveJob({
    required String token,
    required String jobId,
    String? clientEventId,
    Map<String, Object?>? phone,
  }) {
    return _jobAction(token, jobId, 'arrive', {
      'client_event_id': clientEventId,
      'phone': phone,
    });
  }

  Future<Map<String, Object?>> startCheck({
    required String token,
    required String jobId,
    Map<String, Object?>? phone,
  }) {
    return _post(
      '/jobs/$jobId/start-check',
      token: token,
      body: {'phone': phone},
    );
  }

  Future<Map<String, Object?>> startJob({
    required String token,
    required String jobId,
    String? clientEventId,
    num? hourMeter,
    String? implement,
    String? overrideId,
    Map<String, Object?>? phone,
  }) {
    return _post(
      '/jobs/$jobId/start',
      token: token,
      body: {
        'client_event_id': clientEventId,
        'hour_meter': hourMeter,
        'implement': implement,
        'override_id': overrideId,
        'phone': phone,
      },
    );
  }

  Future<Map<String, Object?>> pauseJob({
    required String token,
    required String jobId,
    String? clientEventId,
    String? reason,
    Map<String, Object?>? phone,
  }) {
    return _jobAction(token, jobId, 'pause', {
      'client_event_id': clientEventId,
      'reason': reason,
      'phone': phone,
    });
  }

  Future<Map<String, Object?>> resumeJob({
    required String token,
    required String jobId,
    String? clientEventId,
    Map<String, Object?>? phone,
  }) {
    return _jobAction(token, jobId, 'resume', {
      'client_event_id': clientEventId,
      'phone': phone,
    });
  }

  Future<Map<String, Object?>> completeJob({
    required String token,
    required String jobId,
    required num reportedAcres,
    String? clientEventId,
    num? endHourMeter,
    num? fuelUsedLitres,
    String? notes,
    Map<String, Object?>? phone,
  }) {
    return _post(
      '/jobs/$jobId/complete',
      token: token,
      body: {
        'reported_acres': reportedAcres,
        'client_event_id': clientEventId,
        'end_hour_meter': endHourMeter,
        'fuel_used_l': fuelUsedLitres,
        'notes': notes,
        'phone': phone,
      },
    );
  }

  Future<Map<String, Object?>> reportIssue({
    required String token,
    required String jobId,
    required String text,
    String severity = 'warning',
    bool? openTicket,
    Map<String, Object?>? phone,
  }) {
    return _post(
      '/jobs/$jobId/issue',
      token: token,
      body: {
        'text': text,
        'severity': severity,
        'open_ticket': openTicket,
        'phone': phone,
      },
    );
  }

  Future<Map<String, Object?>> requestOverride({
    required String token,
    required String jobId,
    required String reason,
    Map<String, Object?>? phone,
  }) {
    return _post(
      '/jobs/$jobId/override-request',
      token: token,
      body: {'reason': reason, 'phone': phone},
    );
  }

  Future<Map<String, Object?>> farmerOtp({
    required String token,
    required String jobId,
  }) {
    return _post('/jobs/$jobId/farmer-otp', token: token);
  }

  Future<Map<String, Object?>> uploadJobPhoto({
    required String token,
    required String jobId,
    required Uint8List bytes,
    required String fileName,
    required String kind,
    String? caption,
  }) {
    if (!const {
      'before',
      'during',
      'after',
      'signature',
      'issue',
      'other',
    }.contains(kind)) {
      throw const MechanizationApiException('Choose a valid photo type.');
    }
    if (bytes.isEmpty || bytes.length > 8 * 1024 * 1024) {
      throw const MechanizationApiException(
        'Choose a photo smaller than 8 MB.',
      );
    }
    final mime =
        bytes.length >= 3 &&
            bytes[0] == 255 &&
            bytes[1] == 216 &&
            bytes[2] == 255
        ? 'image/jpeg'
        : bytes.length >= 8 &&
              listEquals(bytes.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10])
        ? 'image/png'
        : bytes.length >= 12 &&
              ascii.decode(bytes.sublist(0, 4), allowInvalid: true) == 'RIFF' &&
              ascii.decode(bytes.sublist(8, 12), allowInvalid: true) == 'WEBP'
        ? 'image/webp'
        : null;
    if (mime == null) {
      throw const MechanizationApiException('Choose a JPG, PNG or WebP photo.');
    }
    final safeName = fileName
        .split(RegExp(r'[/\\]'))
        .last
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return _send(
      'POST',
      '/jobs/$jobId/photos',
      token: token,
      upload:
          _PhotoUpload(bytes, safeName.isEmpty ? 'photo.jpg' : safeName, mime, {
            'kind': kind,
            if (caption != null && caption.trim().isNotEmpty)
              'caption': caption.trim(),
          }),
    );
  }

  Future<Map<String, Object?>> farmerConfirm({
    required String token,
    required String jobId,
    required Map<String, Object?> body,
  }) {
    return _post('/jobs/$jobId/farmer-confirm', token: token, body: body);
  }

  Future<Map<String, Object?>> dispatchJob({
    required String token,
    required String jobId,
    String? tractorId,
    String? operatorId,
  }) {
    return _post(
      '/jobs/$jobId/dispatch',
      token: token,
      body: {'tractor_id': tractorId, 'operator_id': operatorId},
    );
  }

  Future<Map<String, Object?>> rescheduleJob({
    required String token,
    required String jobId,
    required String scheduledDate,
    String? windowStart,
    String? windowEnd,
    String? reason,
  }) {
    return _post(
      '/jobs/$jobId/reschedule',
      token: token,
      body: {
        'scheduled_date': scheduledDate,
        'window_start': windowStart,
        'window_end': windowEnd,
        'reason': reason,
      },
    );
  }

  Future<Map<String, Object?>> verifyJob({
    required String token,
    required String jobId,
    required num verifiedAcres,
    num? amount,
    String? note,
  }) {
    return _post(
      '/jobs/$jobId/verify',
      token: token,
      body: {'verified_acres': verifiedAcres, 'amount': amount, 'note': note},
    );
  }

  Future<Map<String, Object?>> confirmJob({
    required String token,
    required String jobId,
    int? rating,
    String? note,
    bool? dispute,
  }) {
    return _post(
      '/jobs/$jobId/confirm',
      token: token,
      body: {'rating': rating, 'note': note, 'dispute': dispute},
    );
  }

  Future<Map<String, Object?>> closeJob({
    required String token,
    required String jobId,
    String? paymentStatus,
    String? note,
  }) {
    return _post(
      '/jobs/$jobId/close',
      token: token,
      body: {'payment_status': paymentStatus, 'note': note},
    );
  }

  Future<Map<String, Object?>> flagJob({
    required String token,
    required String jobId,
    required String reason,
  }) {
    return _post('/jobs/$jobId/flag', token: token, body: {'reason': reason});
  }

  Future<Map<String, Object?>> unflagJob({
    required String token,
    required String jobId,
    String? note,
  }) {
    return _post('/jobs/$jobId/unflag', token: token, body: {'note': note});
  }

  Future<Map<String, Object?>> cancelJob({
    required String token,
    required String jobId,
    String? reason,
    bool? cancelRequest,
  }) {
    return _post(
      '/jobs/$jobId/cancel',
      token: token,
      body: {'reason': reason, 'cancel_request': cancelRequest},
    );
  }

  Future<Map<String, Object?>> refreshVerification({
    required String token,
    required String jobId,
  }) {
    return _post('/jobs/$jobId/refresh-verification', token: token);
  }

  Future<Map<String, Object?>> tractors({
    required String token,
    bool? mine,
    bool? live,
  }) {
    return _get(
      '/tractors',
      token: token,
      query: {
        'mine': mine == null ? null : (mine ? '1' : '0'),
        'live': live == null ? null : (live ? '1' : '0'),
      },
    );
  }

  Future<Map<String, Object?>> tractor({
    required String token,
    required String tractorId,
  }) {
    return _get('/tractors/$tractorId', token: token);
  }

  Future<Map<String, Object?>> tractorQr({
    required String token,
    required String qrToken,
  }) {
    return _get('/tractors/qr/$qrToken', token: token);
  }

  Future<Map<String, Object?>> inspectionToday({
    required String token,
    required String tractorId,
  }) {
    return _get('/tractors/$tractorId/inspection/today', token: token);
  }

  Future<Map<String, Object?>> createInspection({
    required String token,
    required String tractorId,
    required Map<String, Object?> checklist,
    int? fuelLevelPct,
    num? hourMeter,
    String? defects,
    bool? isFit,
    String? jobId,
    Map<String, Object?>? phone,
  }) {
    return _post(
      '/tractors/$tractorId/inspections',
      token: token,
      body: {
        'checklist': checklist,
        'fuel_level_pct': fuelLevelPct,
        'hour_meter': hourMeter,
        'defects': defects,
        'is_fit': isFit,
        'job_id': jobId,
        'phone': phone,
      },
    );
  }

  Future<Map<String, Object?>> recordFuel({
    required String token,
    required String tractorId,
    required num litres,
    num? cost,
    num? hourMeter,
    String? source,
    String? jobId,
    String? note,
  }) {
    return _post(
      '/tractors/$tractorId/fuel',
      token: token,
      body: {
        'litres': litres,
        'cost': cost,
        'hour_meter': hourMeter,
        'source': source,
        'job_id': jobId,
        'note': note,
      },
    );
  }

  Future<Map<String, Object?>> requests({
    required String token,
    String? status,
    String? farmerId,
    String? queryText,
    int? page,
  }) {
    return _get(
      '/requests',
      token: token,
      operation: 'service requests list',
      query: {
        'status': status,
        'farmer_id': farmerId,
        'q': queryText,
        'page': page,
      },
    );
  }

  Future<Map<String, Object?>> request({
    required String token,
    required String requestId,
  }) {
    return _get(
      '/requests/$requestId',
      token: token,
      operation: 'service request detail',
    );
  }

  Future<Map<String, Object?>> createRequest({
    required String token,
    required String farmerId,
    required String plotId,
    required String serviceTypeId,
    num? requestedAcres,
    String? preferredDate,
    String? preferredWindow,
    String? priority,
    String? notes,
  }) {
    return _post(
      '/requests',
      token: token,
      operation: 'register service request',
      body: {
        'farmer_id': farmerId,
        'plot_id': plotId,
        'service_type_id': serviceTypeId,
        'requested_acres': requestedAcres,
        'preferred_date': preferredDate,
        'preferred_window': preferredWindow,
        'priority': priority,
        'notes': notes,
      },
    );
  }

  Future<Map<String, Object?>> approveRequest({
    required String token,
    required String requestId,
    num? estimateAmount,
    String? priority,
    String? note,
  }) {
    return _post(
      '/requests/$requestId/approve',
      token: token,
      operation: 'approve service request',
      body: {
        'estimate_amount': estimateAmount,
        'priority': priority,
        'note': note,
      },
    );
  }

  Future<Map<String, Object?>> returnRequest({
    required String token,
    required String requestId,
    required String reason,
  }) {
    return _post(
      '/requests/$requestId/return',
      token: token,
      body: {'reason': reason},
    );
  }

  Future<Map<String, Object?>> rejectRequest({
    required String token,
    required String requestId,
    required String reason,
  }) {
    return _post(
      '/requests/$requestId/reject',
      token: token,
      body: {'reason': reason},
    );
  }

  Future<Map<String, Object?>> cancelRequest({
    required String token,
    required String requestId,
    String? reason,
  }) {
    return _post(
      '/requests/$requestId/cancel',
      token: token,
      body: {'reason': reason},
    );
  }

  Future<Map<String, Object?>> scheduleRequest({
    required String token,
    required String requestId,
    required String scheduledDate,
    String? windowStart,
    String? windowEnd,
    String? tractorId,
    String? operatorId,
    num? plannedAcres,
    String? implement,
    String? notes,
  }) {
    return _post(
      '/requests/$requestId/schedule',
      token: token,
      body: {
        'scheduled_date': scheduledDate,
        'window_start': windowStart,
        'window_end': windowEnd,
        'tractor_id': tractorId,
        'operator_id': operatorId,
        'planned_acres': plannedAcres,
        'implement': implement,
        'notes': notes,
      },
    );
  }

  Future<Map<String, Object?>> availability({
    required String token,
    String? date,
    String? tractorId,
    String? operatorId,
    String? excludeJobId,
  }) {
    return _get(
      '/requests/availability',
      token: token,
      query: {
        'date': date,
        'tractor_id': tractorId,
        'operator_id': operatorId,
        'exclude_job_id': excludeJobId,
      },
    );
  }

  Future<Map<String, Object?>> overrides({
    required String token,
    String? status,
  }) {
    return _get('/overrides', token: token, query: {'status': status});
  }

  Future<Map<String, Object?>> decideOverride({
    required String token,
    required String overrideId,
    required bool approve,
    String? note,
  }) {
    return _post(
      '/overrides/$overrideId/decide',
      token: token,
      body: {'approve': approve, 'note': note},
    );
  }

  Future<Map<String, Object?>> exceptions({
    required String token,
    String? status,
    String? severity,
    String? tractorId,
    int? page,
  }) {
    return _get(
      '/exceptions',
      token: token,
      query: {
        'status': status,
        'severity': severity,
        'tractor_id': tractorId,
        'page': page,
      },
    );
  }

  Future<Map<String, Object?>> acknowledgeException({
    required String token,
    required String exceptionId,
  }) {
    return _post('/exceptions/$exceptionId/ack', token: token);
  }

  Future<Map<String, Object?>> resolveException({
    required String token,
    required String exceptionId,
    required String remarks,
    bool? dismiss,
  }) {
    return _post(
      '/exceptions/$exceptionId/resolve',
      token: token,
      body: {'remarks': remarks, 'dismiss': dismiss},
    );
  }

  Future<Map<String, Object?>> farmers({
    required String token,
    String? queryText,
    int? page,
  }) {
    return _get(
      '/farmers',
      token: token,
      query: {'q': queryText, 'page': page},
    );
  }

  Future<Map<String, Object?>> farmer({
    required String token,
    required String farmerId,
  }) {
    return _get('/farmers/$farmerId', token: token);
  }

  Future<Map<String, Object?>> createFarmer({
    required String token,
    required Map<String, Object?> body,
  }) {
    return _post('/farmers', token: token, body: body);
  }

  Future<Map<String, Object?>> createFarmerPlot({
    required String token,
    required String farmerId,
    required Map<String, Object?> body,
  }) {
    return _post('/farmers/$farmerId/plots', token: token, body: body);
  }

  Future<Map<String, Object?>> updatePlot({
    required String token,
    required String plotId,
    required Map<String, Object?> body,
  }) {
    return _put('/plots/$plotId', token: token, body: body);
  }

  Future<Map<String, Object?>> serviceTypes({required String token}) {
    return _get(
      '/service-types',
      token: token,
      operation: 'service types list',
    );
  }

  Future<Map<String, Object?>> unions({required String token}) {
    return _get('/unions', token: token);
  }

  Future<Map<String, Object?>> operators({required String token}) {
    return _get('/operators', token: token);
  }

  Future<Map<String, Object?>> _jobAction(
    String token,
    String jobId,
    String action,
    Map<String, Object?> body,
  ) {
    return _post('/jobs/$jobId/$action', token: token, body: body);
  }

  Future<Map<String, Object?>> _get(
    String path, {
    required String token,
    Map<String, Object?>? query,
    String? operation,
  }) {
    return _send('GET', path, token: token, query: query, operation: operation);
  }

  Future<Map<String, Object?>> _post(
    String path, {
    required String token,
    Map<String, Object?> body = const {},
    String? operation,
  }) {
    return _send('POST', path, token: token, body: body, operation: operation);
  }

  Future<Map<String, Object?>> _put(
    String path, {
    required String token,
    Map<String, Object?> body = const {},
  }) {
    return _send('PUT', path, token: token, body: body);
  }

  Future<Map<String, Object?>> _send(
    String method,
    String path, {
    required String token,
    Map<String, Object?>? body,
    Map<String, Object?>? query,
    String? operation,
    _PhotoUpload? upload,
  }) async {
    final retryAt = _retryNotBefore[token];
    if (retryAt != null && retryAt.isAfter(DateTime.now())) {
      final remaining = retryAt.difference(DateTime.now());
      throw MechanizationApiException(
        'Please wait ${remaining.inSeconds + 1} seconds before trying again.',
        statusCode: 429,
        retryAfter: remaining,
      );
    }
    _retryNotBefore.remove(token);
    final requestId = ++_requestSequence;
    final stopwatch = Stopwatch()..start();
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final uri = _uri(path, query);
      if (operation != null) {
        _log(requestId, 'operation: $operation');
      }
      _log(requestId, '--> $method $uri');
      if (body != null) {
        _logJson(requestId, 'request body', _cleanBody(body));
      }
      final request = switch (method) {
        'GET' => await client.getUrl(uri).timeout(const Duration(seconds: 10)),
        'PUT' => await client.putUrl(uri).timeout(const Duration(seconds: 10)),
        'PATCH' =>
          await client.patchUrl(uri).timeout(const Duration(seconds: 10)),
        _ => await client.postUrl(uri).timeout(const Duration(seconds: 10)),
      };
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      if (upload != null) {
        final boundary =
            'sb-mechanization-${DateTime.now().microsecondsSinceEpoch}-$requestId';
        request.headers.contentType = ContentType(
          'multipart',
          'form-data',
          parameters: {'boundary': boundary},
        );
        final payload = BytesBuilder(copy: false);
        for (final field in upload.fields.entries) {
          payload.add(
            utf8.encode(
              '--$boundary\r\nContent-Disposition: form-data; name="${field.key}"\r\n\r\n${field.value}\r\n',
            ),
          );
        }
        payload.add(
          utf8.encode(
            '--$boundary\r\nContent-Disposition: form-data; name="file"; filename="${upload.name}"\r\nContent-Type: ${upload.mime}\r\n\r\n',
          ),
        );
        payload.add(upload.bytes);
        payload.add(utf8.encode('\r\n--$boundary--\r\n'));
        final encoded = payload.takeBytes();
        request.contentLength = encoded.length;
        request.add(encoded);
        _logJson(requestId, 'multipart fields', {
          ...upload.fields,
          'file': {'type': upload.mime, 'bytes': upload.bytes.length},
        });
      } else {
        request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
        if (body != null) request.write(jsonEncode(_cleanBody(body)));
      }

      final response = await request.close().timeout(
        Duration(seconds: upload == null ? 15 : 60),
      );
      if (response.statusCode == 401 || response.statusCode == 419) {
        await onUnauthorized?.call(token);
      }
      final responseBody = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 15));
      Map<String, Object?> decoded;
      try {
        decoded = responseBody.trim().isEmpty
            ? <String, Object?>{}
            : _map(jsonDecode(responseBody));
      } on FormatException {
        if (response.statusCode >= 200 && response.statusCode < 300) rethrow;
        decoded = {};
      }
      final retrySeconds = int.tryParse(
        response.headers.value('retry-after') ?? '',
      );
      if (response.statusCode == 429 &&
          retrySeconds != null &&
          retrySeconds > 0) {
        _retryNotBefore[token] = DateTime.now().add(
          Duration(seconds: retrySeconds),
        );
      }
      _log(
        requestId,
        '<-- HTTP ${response.statusCode} ${stopwatch.elapsedMilliseconds}ms',
      );
      _logJson(requestId, 'response body', decoded);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw MechanizationApiException(
          decoded['message']?.toString() ??
              'Request failed with HTTP ${response.statusCode}.',
          code: decoded['code']?.toString(),
          statusCode: response.statusCode,
          errors: _map(decoded['errors']),
          retryAfter: retrySeconds == null
              ? null
              : Duration(seconds: retrySeconds),
        );
      }
      if (decoded['success'] == false) {
        throw MechanizationApiException(
          decoded['message']?.toString() ?? 'Request failed.',
          code: decoded['code']?.toString(),
          statusCode: response.statusCode,
          errors: _map(decoded['errors']),
          retryAfter: retrySeconds == null
              ? null
              : Duration(seconds: retrySeconds),
        );
      }
      return decoded;
    } on TimeoutException {
      _log(requestId, 'xx> timeout after ${stopwatch.elapsedMilliseconds}ms');
      throw const MechanizationApiException('Request timed out.');
    } on SocketException catch (error) {
      _log(requestId, 'xx> socket error: $error');
      throw const MechanizationApiException('Server is unreachable.');
    } on HttpException {
      throw const MechanizationApiException(
        'The server connection was interrupted. Please try again.',
      );
    } on FormatException catch (error) {
      _log(requestId, 'xx> invalid JSON: $error');
      throw const MechanizationApiException('Server returned invalid JSON.');
    } on MechanizationApiException catch (error) {
      _log(
        requestId,
        'xx> API error status=${error.statusCode} code=${error.code} '
        'message=${error.message}',
      );
      rethrow;
    } catch (error, stackTrace) {
      _log(requestId, 'xx> unexpected error: $error\n$stackTrace');
      rethrow;
    } finally {
      stopwatch.stop();
      client.close(force: true);
    }
  }

  void _log(int requestId, String message) {
    if (kDebugMode) debugPrint('[Mech API #$requestId] $message');
  }

  void _logJson(int requestId, String label, Object? value) {
    if (!kDebugMode) return;
    final encoded = jsonEncode(_sanitizeForLog(value));
    const chunkSize = 900;
    final total = (encoded.length / chunkSize).ceil();
    for (var index = 0; index < total; index++) {
      final start = index * chunkSize;
      final end = (start + chunkSize).clamp(0, encoded.length);
      _log(
        requestId,
        '$label [${index + 1}/$total] ${encoded.substring(start, end)}',
      );
    }
  }

  Object? _sanitizeForLog(Object? value, [String? parentKey]) {
    if (value is Map) {
      return value.map((key, item) {
        final name = key.toString();
        return MapEntry(name, _sanitizeForLog(item, name));
      });
    }
    if (value is Iterable) {
      return value.map((item) => _sanitizeForLog(item, parentKey)).toList();
    }
    final key = parentKey?.toLowerCase();
    if (key == null) return value;
    const secrets = {
      'password',
      'password_confirmation',
      'pin',
      'otp',
      'farmer_otp',
      'code',
      'token',
      'access_token',
      'refresh_token',
      'api_key',
      'authorization',
      'challenge_id',
      'qr_token',
      'national_id',
    };
    if (secrets.contains(key)) return '***';
    if ((key == 'phone' ||
            key == 'email' ||
            key == 'identifier' ||
            key == 'destination') &&
        value is String) {
      return '***';
    }
    return value;
  }

  Uri _uri(String path, Map<String, Object?>? query) {
    final uri = Uri.parse('$baseUrl$apiPrefix$path');
    final cleaned = <String, String>{};
    query?.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        cleaned[key] = value.toString();
      }
    });
    return cleaned.isEmpty ? uri : uri.replace(queryParameters: cleaned);
  }

  Map<String, Object?> _cleanBody(Map<String, Object?> body) {
    final cleaned = <String, Object?>{};
    body.forEach((key, value) {
      if (value != null) cleaned[key] = value;
    });
    return cleaned;
  }

  Map<String, Object?> _map(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }
}
