import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

/// Logging interceptor for Dio requests/responses
///
/// Provides:
/// - Request/response logging with sensitive data masking
/// - Correlation IDs for tracing
/// - User/Store context in logs
/// - Error logging
/// - Performance timing
class LoggingInterceptor extends Interceptor {
  final bool logRequestBody;
  final bool logResponseBody;
  final int maxBodyLength;

  /// Sensitive headers to mask
  static const _sensitiveHeaders = [
    'authorization',
    'x-api-key',
    'cookie',
    'set-cookie',
  ];

  /// Sensitive body fields to mask
  static const _sensitiveFields = [
    'password',
    'otp',
    'pin',
    'token',
    'access_token',
    'refresh_token',
    'secret',
    'credit_card',
    'cvv',
  ];

  LoggingInterceptor({
    this.logRequestBody = kDebugMode,
    this.logResponseBody = kDebugMode,
    this.maxBodyLength = 500,
  });

  final Map<RequestOptions, DateTime> _requestTimes = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _requestTimes[options] = DateTime.now();

    // Generate correlation ID for tracing
    final correlationId = _generateCorrelationId();
    options.headers['X-Correlation-ID'] = correlationId;

    // Extract context from headers (if set by app)
    final userId = options.headers['X-User-ID'];
    final storeId = options.headers['X-Store-ID'];

    logger.info(
      '→ ${options.method} ${options.uri}',
      data: {
        'correlationId': correlationId,
        if (userId != null) 'userId': userId,
        if (storeId != null) 'storeId': storeId,
        'headers': _maskHeaders(options.headers),
        if (logRequestBody && options.data != null)
          'body': _maskAndTruncate(options.data),
      },
    );

    logger.addBreadcrumb(
      '${options.method} ${options.path}',
      category: 'http.request',
      data: {
        'url': options.uri.toString(),
        if (userId != null) 'userId': userId,
        if (storeId != null) 'storeId': storeId,
      },
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final duration = _getDuration(response.requestOptions);
    final correlationId = response.requestOptions.headers['X-Correlation-ID'];

    logger.info(
      '← ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri} (${duration}ms)',
      data: {
        'correlationId': correlationId,
        'duration': duration,
        'statusCode': response.statusCode,
        'endpoint': response.requestOptions.path,
        if (logResponseBody && response.data != null)
          'body': _maskAndTruncate(response.data),
      },
    );

    logger.addBreadcrumb(
      '${response.statusCode} ${response.requestOptions.path}',
      category: 'http.response',
      data: {'duration': duration, 'statusCode': response.statusCode},
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final duration = _getDuration(err.requestOptions);
    final correlationId = err.requestOptions.headers['X-Correlation-ID'];

    logger.error(
      '✕ ${err.response?.statusCode ?? 'ERR'} ${err.requestOptions.method} ${err.requestOptions.uri} (${duration}ms)',
      error: err,
      data: {
        'correlationId': correlationId,
        'duration': duration,
        'statusCode': err.response?.statusCode,
        'endpoint': err.requestOptions.path,
        'type': err.type.name,
        'message': err.message,
        if (err.response?.data != null)
          'responseBody': _maskAndTruncate(err.response!.data),
      },
    );

    logger.addBreadcrumb(
      'Error: ${err.type.name}',
      category: 'http.error',
      data: {
        'url': err.requestOptions.uri.toString(),
        'statusCode': err.response?.statusCode,
      },
    );

    handler.next(err);
  }

  int _getDuration(RequestOptions options) {
    final startTime = _requestTimes.remove(options);
    if (startTime == null) return -1;
    return DateTime.now().difference(startTime).inMilliseconds;
  }

  /// Masks sensitive headers
  Map<String, dynamic> _maskHeaders(Map<String, dynamic> headers) {
    final masked = <String, dynamic>{};
    for (final entry in headers.entries) {
      final key = entry.key.toLowerCase();
      if (_sensitiveHeaders.contains(key)) {
        masked[entry.key] = '***MASKED***';
      } else {
        masked[entry.key] = entry.value;
      }
    }
    return masked;
  }

  /// Masks sensitive fields and truncates
  String _maskAndTruncate(dynamic data) {
    if (data == null) return '';

    String text;
    if (data is Map) {
      final masked = _maskMap(data);
      text = masked.toString();
    } else {
      text = data.toString();
    }

    return _truncate(text);
  }

  /// Recursively masks sensitive fields in a map
  Map<String, dynamic> _maskMap(Map data) {
    final masked = <String, dynamic>{};
    for (final entry in data.entries) {
      final key = entry.key.toString().toLowerCase();
      if (_sensitiveFields.any((f) => key.contains(f))) {
        masked[entry.key.toString()] = '***MASKED***';
      } else if (entry.value is Map) {
        masked[entry.key.toString()] = _maskMap(entry.value as Map);
      } else {
        masked[entry.key.toString()] = entry.value;
      }
    }
    return masked;
  }

  String _truncate(String text) {
    if (text.length <= maxBodyLength) return text;
    return '${text.substring(0, maxBodyLength)}... (truncated)';
  }

  String _generateCorrelationId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${_randomHex(4)}';
  }

  String _randomHex(int length) {
    final random = DateTime.now().microsecond;
    return random.toRadixString(16).padLeft(length, '0').substring(0, length);
  }
}
