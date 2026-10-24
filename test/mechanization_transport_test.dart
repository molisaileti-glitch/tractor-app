import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tractor/src/core/network/kwanza_track_mobile_api_client.dart';

void main() {
  test(
    'start sends documented method, bearer token, phone and override ID',
    () async {
      Map<String, Object?>? body;
      final api = await _server((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/api/v1/mech/jobs/job-1/start');
        expect(request.headers.value('authorization'), 'Bearer mobile-token');
        body = Map<String, Object?>.from(
          jsonDecode(await utf8.decoder.bind(request).join()) as Map,
        );
        await _reply(request, {
          'success': true,
          'data': {
            'job': {'id': 'job-1'},
          },
        });
      });
      await api.startJob(
        token: 'mobile-token',
        jobId: 'job-1',
        overrideId: 'approved-1',
        clientEventId: 'tap-1',
        phone: {'latitude': -6.17, 'longitude': 35.74, 'accuracy_m': 8},
      );
      expect(body!['override_id'], 'approved-1');
      expect(body!['client_event_id'], 'tap-1');
      expect(body!['phone'], {
        'latitude': -6.17,
        'longitude': 35.74,
        'accuracy_m': 8,
      });
      expect(body!.containsKey('implement'), isFalse);
    },
  );

  test(
    'completion sends acres and completion does not call confirmation or close',
    () async {
      final paths = <String>[];
      final api = await _server((request) async {
        paths.add(request.uri.path);
        final body = jsonDecode(await utf8.decoder.bind(request).join()) as Map;
        expect(body['reported_acres'], 6.25);
        expect(body['fuel_used_l'], 22);
        expect(body['end_hour_meter'], 1244);
        expect(body.containsKey('area_ha'), isFalse);
        await _reply(request, {
          'success': true,
          'data': {'id': 'job-1', 'status': 'completed'},
        });
      });
      final response = await api.completeJob(
        token: 'mobile-token',
        jobId: 'job-1',
        reportedAcres: 6.25,
        endHourMeter: 1244,
        fuelUsedLitres: 22,
      );
      expect((response['data'] as Map)['status'], 'completed');
      expect(paths, ['/api/v1/mech/jobs/job-1/complete']);
    },
  );

  test('start refusal preserves the structured checklist', () async {
    final api = await _server((request) async {
      await request.drain<void>();
      await _reply(request, {
        'success': false,
        'message': 'Start denied',
        'code': 'start_denied',
        'errors': {
          'can_start': false,
          'override_allowed': false,
          'failed': ['inspection_today'],
          'checks': [
            {'key': 'inspection_today', 'passed': false},
          ],
        },
      }, status: 422);
    });
    await expectLater(
      api.startJob(token: 'mobile-token', jobId: 'job-1'),
      throwsA(
        isA<KwanzaTrackApiException>()
            .having((e) => e.statusCode, 'status', 422)
            .having((e) => e.code, 'code', 'start_denied')
            .having((e) => e.errors['failed'], 'failed checks', [
              'inspection_today',
            ]),
      ),
    );
  });

  test(
    'HTML unauthorized response still identifies the expired token',
    () async {
      final previous = KwanzaTrackMobileApiClient.onUnauthorized;
      addTearDown(() => KwanzaTrackMobileApiClient.onUnauthorized = previous);
      String? expiredToken;
      KwanzaTrackMobileApiClient.onUnauthorized = (token) {
        expiredToken = token;
      };
      final api = await _server((request) async {
        request.response.statusCode = 401;
        request.response.write('<html>Unauthorized</html>');
        await request.response.close();
      });
      await expectLater(
        api.me(token: 'expired-token'),
        throwsA(
          isA<KwanzaTrackApiException>().having(
            (e) => e.statusCode,
            'status',
            401,
          ),
        ),
      );
      expect(expiredToken, 'expired-token');
    },
  );

  test('rate limit preserves Retry-After', () async {
    var requests = 0;
    final api = await _server((request) async {
      requests++;
      request.response.headers.set('Retry-After', '60');
      await _reply(request, {
        'success': false,
        'message': 'Please wait',
      }, status: 429);
    });
    await expectLater(
      api.me(token: 'rate-limited-token'),
      throwsA(
        isA<KwanzaTrackApiException>().having(
          (e) => e.retryAfter,
          'retry delay',
          const Duration(seconds: 60),
        ),
      ),
    );
    await expectLater(
      api.me(token: 'rate-limited-token'),
      throwsA(
        isA<KwanzaTrackApiException>().having(
          (e) => e.statusCode,
          'status',
          429,
        ),
      ),
    );
    expect(requests, 1);
  });
}

Future<KwanzaTrackMobileApiClient> _server(
  Future<void> Function(HttpRequest) handle,
) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  addTearDown(() => server.close(force: true));
  server.listen(handle);
  return KwanzaTrackMobileApiClient(baseUrl: 'http://127.0.0.1:${server.port}');
}

Future<void> _reply(
  HttpRequest request,
  Map<String, Object?> body, {
  int status = 200,
}) async {
  request.response.statusCode = status;
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode(body));
  await request.response.close();
}
