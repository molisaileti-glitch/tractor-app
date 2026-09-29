import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ServiceOrdersFetchResult {
  const ServiceOrdersFetchResult({required this.orders, this.errorMessage});

  final List<Map<String, Object?>> orders;
  final String? errorMessage;

  bool get isSuccess => errorMessage == null;
}

class ServiceOrdersRemoteDataSource {
  const ServiceOrdersRemoteDataSource({
    this.endpoint =
        'http://45.77.1.62:8080/api/v1/input-requests/service-orders',
  });

  final String endpoint;

  Future<ServiceOrdersFetchResult> fetchServiceOrders() async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client
          .getUrl(Uri.parse(endpoint))
          .timeout(const Duration(seconds: 10));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return ServiceOrdersFetchResult(
          orders: const [],
          errorMessage: 'Backend returned HTTP ${response.statusCode}.',
        );
      }

      final decoded = body.trim().isEmpty ? const [] : jsonDecode(body);
      return ServiceOrdersFetchResult(orders: _extractOrders(decoded));
    } on TimeoutException {
      return const ServiceOrdersFetchResult(
        orders: [],
        errorMessage: 'Backend request timed out.',
      );
    } on FormatException {
      return const ServiceOrdersFetchResult(
        orders: [],
        errorMessage: 'Backend returned invalid JSON.',
      );
    } on SocketException {
      return const ServiceOrdersFetchResult(
        orders: [],
        errorMessage: 'Backend is unreachable from this device.',
      );
    } catch (error) {
      return ServiceOrdersFetchResult(
        orders: const [],
        errorMessage: 'Could not fetch service orders: $error',
      );
    } finally {
      client.close(force: true);
    }
  }

  List<Map<String, Object?>> _extractOrders(Object? decoded) {
    if (decoded is List) {
      return decoded.whereType<Map>().map(_stringKeyedMap).toList();
    }
    if (decoded is Map) {
      for (final key in const ['data', 'items', 'serviceOrders', 'results']) {
        final value = decoded[key];
        if (value is List) {
          return value.whereType<Map>().map(_stringKeyedMap).toList();
        }
      }
      return [_stringKeyedMap(decoded)];
    }
    return const [];
  }

  Map<String, Object?> _stringKeyedMap(Map<dynamic, dynamic> value) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
}
