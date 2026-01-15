import 'package:dio/dio.dart';

import 'app_exception.dart';

/// Maps Dio errors and API responses to AppException hierarchy (v3.1 FINAL)
/// Supports: String/Map/List messages, ar/en localization, fieldErrors
class ErrorMapper {
  const ErrorMapper._();

  /// Converts DioException to appropriate AppException
  static AppException fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Request timeout', code: 'TIMEOUT');

      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection', code: 'NO_INTERNET');

      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);

      case DioExceptionType.cancel:
        return const NetworkException('Request cancelled', code: 'CANCELLED');

      case DioExceptionType.badCertificate:
        return const NetworkException('Bad certificate', code: 'BAD_CERTIFICATE');

      case DioExceptionType.unknown:
        // Check if response exists (sometimes happens)
        if (error.response != null) {
          return _handleBadResponse(error.response);
        }
        return const NetworkException('Network error', code: 'UNKNOWN');
    }
  }

  /// Handles HTTP error responses (4xx, 5xx)
  static AppException _handleBadResponse(Response<dynamic>? response) {
    if (response == null) {
      return const ServerException('No response from server', code: 'NO_RESPONSE');
    }

    final statusCode = response.statusCode;
    final data = response.data;

    // Extract message from body first (not from error.message)
    final message = _extractMessage(data) ?? 'Server error';
    final code = _extractCode(data);

    switch (statusCode) {
      case 400:
        return ValidationException(
          message,
          code: code ?? 'BAD_REQUEST',
          fieldErrors: _extractFieldErrors(data),
        );

      case 401:
        return AuthException(
          message,
          code: code ?? 'UNAUTHORIZED',
          statusCode: 401,
        );

      case 403:
        return AuthException(
          message,
          code: code ?? 'FORBIDDEN',
          statusCode: 403,
        );

      case 404:
        return NotFoundException(
          message,
          code: code ?? 'NOT_FOUND',
        );

      case 422:
        return ValidationException(
          message,
          code: code ?? 'UNPROCESSABLE_ENTITY',
          fieldErrors: _extractFieldErrors(data),
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message,
          code: code ?? 'SERVER_ERROR',
          statusCode: statusCode,
        );

      default:
        return ServerException(
          message,
          code: code ?? 'HTTP_ERROR',
          statusCode: statusCode,
        );
    }
  }

  /// Extracts error message from response data
  /// Handles: String, Map with "message" (String or Map ar/en), List
  static String? _extractMessage(dynamic data) {
    if (data == null) return null;

    // Case 1: String response
    if (data is String) {
      return data.isNotEmpty ? data : null;
    }

    // Case 2: Map response
    if (data is Map<String, dynamic>) {
      final messageField = data['message'] ?? data['error'] ?? data['msg'] ?? data['detail'];

      // message could be String
      if (messageField is String) {
        return messageField.isNotEmpty ? messageField : null;
      }

      // message could be Map with ar/en (localized)
      if (messageField is Map<String, dynamic>) {
        // Prefer 'ar' then 'en' then first available
        final firstValue = messageField.values.isNotEmpty ? messageField.values.first : null;
        return messageField['ar'] as String? ??
            messageField['en'] as String? ??
            firstValue?.toString();
      }

      return null;
    }

    // Case 3: List response
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is String) return first;
      if (first is Map<String, dynamic>) {
        return _extractMessage(first);
      }
    }

    return null;
  }

  /// Extracts error code from response data
  static String? _extractCode(dynamic data) {
    if (data is Map<String, dynamic>) {
      final code = data['code'] ?? data['errorCode'] ?? data['error_code'];
      if (code is String) return code;
      if (code is int) return code.toString();
    }
    return null;
  }

  /// Extracts field validation errors from response
  /// Handles: errors as Map<String, List<String>> or Map<String, String>
  static Map<String, List<String>>? _extractFieldErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    // Try 'errors', 'fieldErrors', 'field_errors'
    final errors = data['errors'] ?? data['fieldErrors'] ?? data['field_errors'];
    if (errors == null) return null;

    final result = <String, List<String>>{};

    if (errors is Map<String, dynamic>) {
      errors.forEach((key, value) {
        if (value is List) {
          // List<String> or List<dynamic>
          result[key] = value.map((e) => e.toString()).toList();
        } else if (value is String) {
          // Single string error
          result[key] = [value];
        } else if (value is Map<String, dynamic>) {
          // Nested map (ar/en localization)
          final firstValue = value.values.isNotEmpty ? value.values.first : null;
          final msg = value['ar'] as String? ??
              value['en'] as String? ??
              firstValue?.toString();
          if (msg != null) result[key] = [msg];
        }
      });
    }

    return result.isNotEmpty ? result : null;
  }
}
