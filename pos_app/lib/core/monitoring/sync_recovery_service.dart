/// Sync Recovery Service
///
/// خدمة استعادة المزامنة عند حدوث أخطاء:
/// - اكتشاف العناصر الفاشلة
/// - محاولة الإصلاح التلقائي
/// - تقارير المشاكل
/// - استراتيجيات الاسترداد
library;

import 'dart:async';
import 'production_logger.dart';

/// نوع خطأ المزامنة
enum SyncErrorType {
  networkError,       // خطأ شبكة
  serverError,        // خطأ سيرفر (5xx)
  clientError,        // خطأ عميل (4xx)
  validationError,    // خطأ تحقق
  conflictError,      // تعارض بيانات
  timeoutError,       // انتهاء المهلة
  unknownError,       // خطأ غير معروف
}

/// معلومات خطأ المزامنة
class SyncErrorInfo {
  final String itemId;
  final String tableName;
  final String operation;
  final SyncErrorType errorType;
  final String errorMessage;
  final int retryCount;
  final DateTime firstOccurred;
  final DateTime lastOccurred;

  SyncErrorInfo({
    required this.itemId,
    required this.tableName,
    required this.operation,
    required this.errorType,
    required this.errorMessage,
    required this.retryCount,
    required this.firstOccurred,
    required this.lastOccurred,
  });

  /// هل يمكن إعادة المحاولة؟
  bool get isRetryable {
    return errorType == SyncErrorType.networkError ||
           errorType == SyncErrorType.serverError ||
           errorType == SyncErrorType.timeoutError;
  }

  /// هل يحتاج تدخل يدوي؟
  bool get requiresManualIntervention {
    return errorType == SyncErrorType.conflictError ||
           errorType == SyncErrorType.validationError ||
           retryCount >= 5;
  }

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'tableName': tableName,
    'operation': operation,
    'errorType': errorType.name,
    'errorMessage': errorMessage,
    'retryCount': retryCount,
    'firstOccurred': firstOccurred.toIso8601String(),
    'lastOccurred': lastOccurred.toIso8601String(),
    'isRetryable': isRetryable,
    'requiresManualIntervention': requiresManualIntervention,
  };
}

/// استراتيجية الاسترداد
enum RecoveryStrategy {
  retry,          // إعادة المحاولة
  skip,           // تخطي
  rollback,       // التراجع
  manualResolve,  // حل يدوي
}

/// نتيجة الاسترداد
class RecoveryResult {
  final String itemId;
  final RecoveryStrategy strategy;
  final bool success;
  final String? message;

  RecoveryResult({
    required this.itemId,
    required this.strategy,
    required this.success,
    this.message,
  });
}

/// تقرير الاسترداد
class RecoveryReport {
  final DateTime timestamp;
  final int totalItems;
  final int recoveredItems;
  final int skippedItems;
  final int failedItems;
  final List<RecoveryResult> results;
  final Duration duration;

  RecoveryReport({
    required this.totalItems,
    required this.recoveredItems,
    required this.skippedItems,
    required this.failedItems,
    required this.results,
    required this.duration,
  }) : timestamp = DateTime.now();

  double get successRate => totalItems > 0 ? recoveredItems / totalItems : 0;

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'totalItems': totalItems,
    'recoveredItems': recoveredItems,
    'skippedItems': skippedItems,
    'failedItems': failedItems,
    'successRate': successRate,
    'durationMs': duration.inMilliseconds,
  };
}

/// خدمة استعادة المزامنة
class SyncRecoveryService {
  final Future<List<Map<String, dynamic>>> Function() getFailedItems;
  final Future<void> Function(String id) retryItem;
  final Future<void> Function(String id) skipItem;
  final Future<void> Function(String id) rollbackItem;
  final Future<void> Function(String id, String error) markAsFailed;

  SyncRecoveryService({
    required this.getFailedItems,
    required this.retryItem,
    required this.skipItem,
    required this.rollbackItem,
    required this.markAsFailed,
  });

  /// تحليل الأخطاء الفاشلة
  Future<List<SyncErrorInfo>> analyzeFailures() async {
    final failures = <SyncErrorInfo>[];
    final items = await getFailedItems();

    for (final item in items) {
      final errorType = _classifyError(item['lastError'] as String?);
      failures.add(SyncErrorInfo(
        itemId: item['id'] as String,
        tableName: item['tableName'] as String? ?? 'unknown',
        operation: item['operation'] as String? ?? 'unknown',
        errorType: errorType,
        errorMessage: item['lastError'] as String? ?? 'Unknown error',
        retryCount: item['retryCount'] as int? ?? 0,
        firstOccurred: DateTime.parse(item['createdAt'] as String),
        lastOccurred: item['lastAttemptAt'] != null
            ? DateTime.parse(item['lastAttemptAt'] as String)
            : DateTime.now(),
      ));
    }

    return failures;
  }

  /// تصنيف نوع الخطأ
  SyncErrorType _classifyError(String? error) {
    if (error == null) return SyncErrorType.unknownError;

    final lowerError = error.toLowerCase();

    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('socket')) {
      return SyncErrorType.networkError;
    }

    if (lowerError.contains('timeout')) {
      return SyncErrorType.timeoutError;
    }

    if (lowerError.contains('500') ||
        lowerError.contains('502') ||
        lowerError.contains('503') ||
        lowerError.contains('server')) {
      return SyncErrorType.serverError;
    }

    if (lowerError.contains('400') ||
        lowerError.contains('401') ||
        lowerError.contains('403') ||
        lowerError.contains('404')) {
      return SyncErrorType.clientError;
    }

    if (lowerError.contains('validation') ||
        lowerError.contains('invalid')) {
      return SyncErrorType.validationError;
    }

    if (lowerError.contains('conflict') ||
        lowerError.contains('duplicate')) {
      return SyncErrorType.conflictError;
    }

    return SyncErrorType.unknownError;
  }

  /// تحديد استراتيجية الاسترداد
  RecoveryStrategy determineStrategy(SyncErrorInfo error) {
    // الأخطاء القابلة لإعادة المحاولة
    if (error.isRetryable && error.retryCount < 5) {
      return RecoveryStrategy.retry;
    }

    // أخطاء التحقق - تخطي
    if (error.errorType == SyncErrorType.validationError) {
      return RecoveryStrategy.skip;
    }

    // أخطاء التعارض - تحتاج حل يدوي
    if (error.errorType == SyncErrorType.conflictError) {
      return RecoveryStrategy.manualResolve;
    }

    // أخطاء العميل - تخطي عادة
    if (error.errorType == SyncErrorType.clientError) {
      return RecoveryStrategy.skip;
    }

    // افتراضي - حل يدوي
    return RecoveryStrategy.manualResolve;
  }

  /// تنفيذ الاسترداد التلقائي
  Future<RecoveryReport> runAutoRecovery({
    bool retryNetworkErrors = true,
    bool skipValidationErrors = true,
    int maxRetries = 3,
  }) async {
    final stopwatch = Stopwatch()..start();
    final results = <RecoveryResult>[];
    int recovered = 0;
    int skipped = 0;
    int failed = 0;

    final failures = await analyzeFailures();

    ProductionLogger.info(
      'Starting auto recovery for ${failures.length} items',
      tag: 'SyncRecovery',
    );

    for (final failure in failures) {
      final strategy = determineStrategy(failure);
      RecoveryResult result;

      try {
        switch (strategy) {
          case RecoveryStrategy.retry:
            if (retryNetworkErrors || failure.errorType != SyncErrorType.networkError) {
              await retryItem(failure.itemId);
              result = RecoveryResult(
                itemId: failure.itemId,
                strategy: strategy,
                success: true,
                message: 'Retried successfully',
              );
              recovered++;
            } else {
              result = RecoveryResult(
                itemId: failure.itemId,
                strategy: RecoveryStrategy.skip,
                success: true,
                message: 'Skipped network error',
              );
              skipped++;
            }

          case RecoveryStrategy.skip:
            if (skipValidationErrors) {
              await skipItem(failure.itemId);
              result = RecoveryResult(
                itemId: failure.itemId,
                strategy: strategy,
                success: true,
                message: 'Skipped validation error',
              );
              skipped++;
            } else {
              result = RecoveryResult(
                itemId: failure.itemId,
                strategy: RecoveryStrategy.manualResolve,
                success: false,
                message: 'Requires manual resolution',
              );
              failed++;
            }

          case RecoveryStrategy.rollback:
            await rollbackItem(failure.itemId);
            result = RecoveryResult(
              itemId: failure.itemId,
              strategy: strategy,
              success: true,
              message: 'Rolled back',
            );
            recovered++;

          case RecoveryStrategy.manualResolve:
            result = RecoveryResult(
              itemId: failure.itemId,
              strategy: strategy,
              success: false,
              message: 'Requires manual resolution',
            );
            failed++;
        }
      } catch (e) {
        result = RecoveryResult(
          itemId: failure.itemId,
          strategy: strategy,
          success: false,
          message: 'Recovery failed: $e',
        );
        failed++;

        await markAsFailed(failure.itemId, 'Recovery failed: $e');
      }

      results.add(result);
    }

    stopwatch.stop();

    final report = RecoveryReport(
      totalItems: failures.length,
      recoveredItems: recovered,
      skippedItems: skipped,
      failedItems: failed,
      results: results,
      duration: stopwatch.elapsed,
    );

    ProductionLogger.info(
      'Recovery completed: ${report.recoveredItems}/${report.totalItems} recovered',
      tag: 'SyncRecovery',
      context: report.toJson(),
    );

    return report;
  }

  /// الحصول على ملخص الأخطاء
  Future<Map<SyncErrorType, int>> getErrorSummary() async {
    final failures = await analyzeFailures();
    final summary = <SyncErrorType, int>{};

    for (final failure in failures) {
      summary[failure.errorType] = (summary[failure.errorType] ?? 0) + 1;
    }

    return summary;
  }

  /// الحصول على العناصر التي تحتاج تدخل يدوي
  Future<List<SyncErrorInfo>> getItemsRequiringManualIntervention() async {
    final failures = await analyzeFailures();
    return failures.where((f) => f.requiresManualIntervention).toList();
  }
}
