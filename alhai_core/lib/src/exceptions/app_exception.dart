/// Base exception class for all app exceptions (v3.1)
sealed class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  const AppException(this.message, {this.code, this.statusCode});

  @override
  String toString() =>
      'AppException: $message (code: $code, status: $statusCode)';
}

/// Network-related exceptions (connection, timeout)
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.statusCode});
}

/// Authentication/Authorization errors (401, 403)
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.statusCode});
}

/// Validation errors (400)
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException(super.message, {super.code, this.fieldErrors});
}

/// Server errors (5xx)
class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.statusCode});
}

/// Resource not found (404)
class NotFoundException extends AppException {
  const NotFoundException(String message, {String? code})
      : super(message, code: code, statusCode: 404);
}

/// Unknown/unexpected errors (fallback)
class UnknownException extends AppException {
  final Object? cause;
  final StackTrace? stackTrace;

  const UnknownException(
    String message, {
    String? code,
    this.cause,
    this.stackTrace,
  }) : super(message, code: code ?? 'UNKNOWN');

  @override
  String toString() => 'UnknownException: $message (cause: $cause)';
}
