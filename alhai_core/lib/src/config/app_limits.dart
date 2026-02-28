/// Centralized application limits and business constants.
class AppLimits {
  AppLimits._();

  // Pagination
  static const int defaultPageSize = 20;
  static const int alertsPageSize = 50;

  // Retry & Timeout
  static const int maxRetryAttempts = 3;
  static const int maxBackoffMinutes = 60;
  static const int networkTimeoutSeconds = 30;
  static const Duration networkTimeout = Duration(seconds: networkTimeoutSeconds);

  // Memory & Cache
  static const int maxAuditLogEntries = 1000;
  static const int maxUndoHistory = 10;
  static const int maxQueryHistory = 50;
  static const int maxBarcodeBufferLength = 50;
  static const int seedBatchSize = 500;

  // File Sizes
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB

  // Report
  static const int csvPageBreakRows = 50;
}
