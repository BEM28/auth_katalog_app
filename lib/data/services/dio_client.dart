import 'package:auth_katalog_app/core/constants/api_contant.dart';
import 'package:dio/dio.dart';

import 'secure_storage_service.dart';

class _PendingRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
  _PendingRequest(this.options, this.handler);
}

class DioClient {
  late Dio dio;
  final SecureStorageService _storage;
  final Dio? _refreshDio;
  final void Function()? onLogout;

  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  DioClient(this._storage, {this._refreshDio, this.onLogout}) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            final requestOptions = error.requestOptions;

            if (_isRefreshing) {
              // Single-flight: antri, simpan handler agar bisa di-resolve/reject nanti.
              _pendingRequests.add(_PendingRequest(requestOptions, handler));
              return;
            }

            _isRefreshing = true;

            try {
              final newToken = await _refreshToken();

              // Retry request pemicu 401 ini.
              requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final response = await dio.fetch(requestOptions);
              handler.resolve(response);

              // Retry semua request yang mengantri.
              for (final pending in _pendingRequests) {
                pending.options.headers['Authorization'] = 'Bearer $newToken';
                try {
                  final resp = await dio.fetch(pending.options);
                  pending.handler.resolve(resp);
                } catch (e) {
                  pending.handler.reject(e is DioException ? e : error);
                }
              }
              _pendingRequests.clear();
            } catch (e) {
              // Refresh gagal (refresh token invalid) → clear + balik ke login.
              await _storage.clearTokens();
              handler.reject(error);
              for (final pending in _pendingRequests) {
                pending.handler.reject(error);
              }
              _pendingRequests.clear();
              onLogout?.call();
            } finally {
              _isRefreshing = false;
            }
          } else {
            handler.next(error);
          }
        },
      ),
    );
  }

  Future<String> _refreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No refresh token');
    }

    final refreshDio =
        _refreshDio ?? Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    final response = await refreshDio.post(
      ApiConstants.refresh,
      data: {'refreshToken': refreshToken, 'expiresInMins': 1},
    );

    final newAccessToken = response.data['accessToken'] as String;
    final newRefreshToken = response.data['refreshToken'] as String;

    await _storage.saveTokens(newAccessToken, newRefreshToken);
    return newAccessToken;
  }
}
