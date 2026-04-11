import 'dart:async';

import 'package:dio/dio.dart';

import '../../datasources/local/auth_local_datasource.dart';
import '../../datasources/local/entities/auth_tokens_entity.dart';
import '../api_dio_holder.dart';

/// AuthInterceptor v3.1 - Completer-based token refresh
/// - Single refresh at a time via Completer
/// - No handler storage
/// - No refresh if no refreshToken
/// - Prevents infinite loop with _retried flag
/// - Skips /auth/* endpoints (no Bearer, no refresh)
class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource _localDataSource;
  final ApiDioHolder _apiDioHolder;
  final Dio _refreshDio;

  Completer<void>? _refreshCompleter;
  bool _isRefreshing = false;

  AuthInterceptor({
    required AuthLocalDataSource localDataSource,
    required ApiDioHolder apiDioHolder,
    required Dio refreshDio,
  }) : _localDataSource = localDataSource,
       _apiDioHolder = apiDioHolder,
       _refreshDio = refreshDio;

  /// Checks if path is an auth endpoint (skip token handling)
  bool _isAuthEndpoint(String path) => path.contains('/auth/');

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth endpoints - no Bearer token needed
    if (_isAuthEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    // Get stored tokens
    final tokens = await _localDataSource.getTokens();

    if (tokens != null && tokens.accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Skip auth endpoints - no refresh needed
    if (_isAuthEndpoint(err.requestOptions.path)) {
      handler.next(err);
      return;
    }

    // Only handle 401 errors
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Check if already retried (prevent infinite loop)
    if (err.requestOptions.extra['_retried'] == true) {
      handler.next(err);
      return;
    }

    // Get stored tokens
    final tokens = await _localDataSource.getTokens();

    // No refresh token available, reject
    if (tokens == null || tokens.refreshToken.isEmpty) {
      handler.next(err);
      return;
    }

    try {
      // Wait for ongoing refresh or start new one
      await _refreshTokens();

      // Retry original request with new token
      final newTokens = await _localDataSource.getTokens();
      if (newTokens == null) {
        handler.next(err);
        return;
      }

      // Clone request with new token and _retried flag
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer ${newTokens.accessToken}';
      options.extra['_retried'] = true;

      // Retry using same apiDio instance
      final response = await _apiDioHolder.apiDio.fetch(options);
      handler.resolve(response);
    } catch (e) {
      // Refresh failed, clear tokens and reject
      await _localDataSource.clearTokens();
      await _localDataSource.clearUser();
      handler.next(err);
    }
  }

  /// Refreshes tokens - uses Completer to ensure single refresh
  Future<void> _refreshTokens() async {
    // If already refreshing, wait for completion
    if (_isRefreshing && _refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<void>();

    try {
      final tokens = await _localDataSource.getTokens();
      if (tokens == null || tokens.refreshToken.isEmpty) {
        throw Exception('No refresh token');
      }

      // Use refreshDio (no interceptors) to avoid loop
      final response = await _refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': tokens.refreshToken},
      );

      // Parse response as Map directly (no DTO import)
      final data = response.data as Map<String, dynamic>;
      await _localDataSource.saveTokens(
        AuthTokensEntity(
          accessToken: data['access_token'] as String,
          refreshToken: data['refresh_token'] as String,
          expiresAt: data['expires_at'] as String,
        ),
      );

      _refreshCompleter!.complete();
    } catch (e) {
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }
}
