import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tractor/src/core/network/kwanza_track_mobile_api_client.dart';

void main() {
  test(
    'photo upload sends real multipart fields and unmodified image bytes',
    () async {
      final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=',
      );
      final api = await _server((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/api/v1/mech/jobs/job-1/photos');
        expect(request.headers.value('authorization'), 'Bearer photo-token');
        expect(request.headers.contentType!.mimeType, 'multipart/form-data');
        final boundary = request.headers.contentType!.parameters['boundary']!;
        final bytes = await request.fold<List<int>>(
          [],
          (all, chunk) => all..addAll(chunk),
        );
        final wire = latin1.decode(bytes);
        expect(wire, contains('name="kind"\r\n\r\nbefore'));
        expect(wire, contains('name="caption"\r\n\r\nBefore work'));
        expect(wire, contains('name="file"; filename="field.png"'));
        expect(wire, contains('Content-Type: image/png'));
        expect(wire, contains(latin1.decode(png)));
        expect(wire.endsWith('--$boundary--\r\n'), isTrue);
        await _reply(request, {
          'data': {'id': 'photo-1', 'kind': 'before', 'url': '/photos/1.png'},
        }, status: 201);
      });
      await api.uploadJobPhoto(
        token: 'photo-token',
        jobId: 'job-1',
        bytes: png,
        fileName: 'field.png',
        kind: 'before',
        caption: 'Before work',
      );
    },
  );

  test(
    'photo validation rejects unsupported and oversized files before sending',
    () {
      const api = KwanzaTrackMobileApiClient();
      expect(
        () => api.uploadJobPhoto(
          token: 'token',
          jobId: 'job',
          bytes: Uint8List.fromList([1, 2]),
          fileName: 'bad.jpg',
          kind: 'before',
        ),
        throwsA(isA<KwanzaTrackApiException>()),
      );
      expect(
        () => api.uploadJobPhoto(
          token: 'token',
          jobId: 'job',
          bytes: Uint8List(8 * 1024 * 1024 + 1),
          fileName: 'large.jpg',
          kind: 'before',
        ),
        throwsA(isA<KwanzaTrackApiException>()),
      );
    },
  );

  test(
    'PIN confirmation uses the documented JSON contract with a leading zero',
    () async {
      final api = await _server((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/api/v1/mech/jobs/job-1/farmer-confirm');
        final body = jsonDecode(await utf8.decoder.bind(request).join()) as Map;
        expect(body, {'method': 'pin', 'pin': '0123', 'rating': 4});
        await _reply(request, {
          'data': {
            'id': 'job-1',
            'farmer_confirmed_at': '2026-10-25T10:00:00Z',
          },
        });
      });
      await api.farmerConfirm(
        token: 'operator',
        jobId: 'job-1',
        body: {'method': 'pin', 'pin': '0123', 'rating': 4},
      );
    },
  );
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
