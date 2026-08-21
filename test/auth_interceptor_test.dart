import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:auth_katalog_app/data/services/dio_client.dart';
import 'package:auth_katalog_app/data/services/secure_storage_service.dart';

class MockSecureStorage extends Mock implements SecureStorageService {}

class TestAdapter implements HttpClientAdapter {
  int refreshCallCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await Future.delayed(const Duration(milliseconds: 10));

    if (options.path.contains('/auth/refresh')) {
      refreshCallCount++;
      final body = utf8.encode(
        jsonEncode({'accessToken': 'new_token', 'refreshToken': 'new_refresh'}),
      );
      return ResponseBody.fromBytes(
        body,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    final auth = options.headers['Authorization']?.toString() ?? '';
    if (auth.contains('old_token')) {
      final body = utf8.encode('{}');
      return ResponseBody.fromBytes(
        body,
        401,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    final body = utf8.encode(jsonEncode({'id': 1}));
    return ResponseBody.fromBytes(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late MockSecureStorage mockStorage;
  late String currentAccessToken;
  late String currentRefreshToken;

  setUp(() {
    mockStorage = MockSecureStorage();
    currentAccessToken = 'old_token';
    currentRefreshToken = 'refresh_token';

    when(() => mockStorage.getAccessToken())
        .thenAnswer((_) async => currentAccessToken);
    when(() => mockStorage.getRefreshToken())
        .thenAnswer((_) async => currentRefreshToken);
    when(() => mockStorage.saveTokens(any(), any()))
        .thenAnswer((invocation) async {
          currentAccessToken = invocation.positionalArguments[0] as String;
          currentRefreshToken = invocation.positionalArguments[1] as String;
        });
    when(() => mockStorage.clearTokens()).thenAnswer((_) async {});
  });

  test(
    'Single-flight: refresh dipanggil 1x untuk 3 request 401 barengan',
    () async {
      final adapter = TestAdapter();

      final refreshDio = Dio(BaseOptions(baseUrl: 'https://dummyjson.com'));
      refreshDio.httpClientAdapter = adapter;

      final dioClient = DioClient(mockStorage, refreshDio: refreshDio);
      dioClient.dio.httpClientAdapter = adapter;

      final results = await Future.wait([
        dioClient.dio.get('/products/1').catchError((e) => e),
        dioClient.dio.get('/products/2').catchError((e) => e),
        dioClient.dio.get('/products/3').catchError((e) => e),
      ]);

      expect(results[0], isNot(isA<DioException>()));
      expect(results[1], isNot(isA<DioException>()));
      expect(results[2], isNot(isA<DioException>()));

      expect(adapter.refreshCallCount, equals(1));
    },
  );
}
