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
  const NotFoundException(super.message, {super.code}) : super(statusCode: 404);
}

/// Append-only violation (attempt to modify an immutable record like a
/// completed sale).  Used by ZATCA-compliance guards.
class AppendOnlyViolationException extends AppException {
  const AppendOnlyViolationException(super.message, {super.code})
    : super(statusCode: 409);
}

/// Migration failure with backup path for recovery.
class MigrationFailedException extends AppException {
  final int fromVersion;
  final int toVersion;
  final String? backupPath;
  final Object? originalError;

  const MigrationFailedException({
    required this.fromVersion,
    required this.toVersion,
    this.backupPath,
    this.originalError,
  }) : super(
         'Database migration from v$fromVersion to v$toVersion failed. '
         'Backup available at: $backupPath',
         code: 'MIGRATION_FAILED',
       );
}

/// Unknown/unexpected errors (fallback)
class UnknownException extends AppException {
  final Object? cause;
  final StackTrace? stackTrace;

  const UnknownException(
    super.message, {
    String? code,
    this.cause,
    this.stackTrace,
  }) : super(code: code ?? 'UNKNOWN');

  @override
  String toString() => 'UnknownException: $message (cause: $cause)';
}
