import 'dart:async';
import 'dart:convert';
import 'dart:io';

class KwanzaTrackApiException implements Exception {
  const KwanzaTrackApiException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => message;
}

class KwanzaTrackMobileApiClient {
  const KwanzaTrackMobileApiClient({
    this.baseUrl = 'http://161.35.65.228',
    this.apiPrefix = '/api/v1/mech',
  });

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
    return _get('/requests/$requestId', token: token);
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
    return _get('/service-types', token: token);
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
  }) {
    return _send('GET', path, token: token, query: query);
  }

  Future<Map<String, Object?>> _post(
    String path, {
    required String token,
    Map<String, Object?> body = const {},
  }) {
    return _send('POST', path, token: token, body: body);
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
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final uri = _uri(path, query);
      final request = switch (method) {
        'GET' => await client.getUrl(uri).timeout(const Duration(seconds: 10)),
        'PUT' => await client.putUrl(uri).timeout(const Duration(seconds: 10)),
        'PATCH' =>
          await client.patchUrl(uri).timeout(const Duration(seconds: 10)),
        _ => await client.postUrl(uri).timeout(const Duration(seconds: 10)),
      };
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      if (body != null) request.write(jsonEncode(_cleanBody(body)));

      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      final responseBody = await response.transform(utf8.decoder).join();
      final decoded = responseBody.trim().isEmpty
          ? <String, Object?>{}
          : _map(jsonDecode(responseBody));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw KwanzaTrackApiException(
          decoded['message']?.toString() ??
              'Request failed with HTTP ${response.statusCode}.',
          code: decoded['code']?.toString(),
          statusCode: response.statusCode,
        );
      }
      if (decoded['success'] == false) {
        throw KwanzaTrackApiException(
          decoded['message']?.toString() ?? 'Request failed.',
          code: decoded['code']?.toString(),
          statusCode: response.statusCode,
        );
      }
      return decoded;
    } on TimeoutException {
      throw const KwanzaTrackApiException('Request timed out.');
    } on SocketException {
      throw const KwanzaTrackApiException('Server is unreachable.');
    } on FormatException {
      throw const KwanzaTrackApiException('Server returned invalid JSON.');
    } finally {
      client.close(force: true);
    }
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
