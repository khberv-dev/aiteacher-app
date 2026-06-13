import 'package:ai_teacher/app/data/cache_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.cache,
    required this.refreshDio,
    this.onUnauthorized,
  });

  final CacheService cache;
  final Dio refreshDio;
  final VoidCallback? onUnauthorized;

  static const String _refreshPath = 'auth/refresh';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final isRefreshCall = options.path.contains(_refreshPath);
    final token = cache.accessToken;
    if (!isRefreshCall && token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isRefreshCall = err.requestOptions.path.contains(_refreshPath);

    if (!isUnauthorized || isRefreshCall) {
      handler.next(err);
      return;
    }

    final refreshToken = cache.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      await _logout();
      handler.next(err);
      return;
    }

    try {
      final response = await refreshDio.post<Map<String, dynamic>>(
        _refreshPath,
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );

      final data = response.data ?? const {};
      final newAccess = data['accessToken'] as String?;
      final newRefresh = data['refreshToken'] as String?;

      if (newAccess == null || newAccess.isEmpty) {
        await _logout();
        handler.next(err);
        return;
      }

      await cache.setAccessToken(newAccess);
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await cache.setRefreshToken(newRefresh);
      }

      final retried = await refreshDio.fetch<dynamic>(
        err.requestOptions..headers['Authorization'] = 'Bearer $newAccess',
      );
      handler.resolve(retried);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _logout();
      }
      handler.next(err);
    }
  }

  Future<void> _logout() async {
    await cache.clear();
    onUnauthorized?.call();
  }
}
