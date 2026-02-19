/// Retry Strategy with Jitter
///
/// استراتيجية إعادة المحاولة مع Jitter العشوائي لمنع:
/// - Thundering Herd Problem
/// - تزامن طلبات متعددة
/// - ضغط على السيرفر
///
/// يدعم:
/// - Exponential Backoff مع Jitter
/// - Decorrelated Jitter
/// - Full Jitter
/// - Equal Jitter
library;

import 'dart:math';

import 'package:pos_app/core/monitoring/production_logger.dart';

/// نوع الـ Jitter
enum JitterType {
  /// Full Jitter: delay = random(0, baseDelay * 2^attempt)
  /// الأفضل لتقليل التصادم
  full,

  /// Equal Jitter: delay = baseDelay/2 + random(0, baseDelay/2)
  /// توازن بين الاستجابة السريعة وتقليل التصادم
  equal,

  /// Decorrelated Jitter: delay = min(cap, random(baseDelay, prevDelay * 3))
  /// الأفضل للـ workloads المتغيرة
  decorrelated,

  /// No Jitter: delay = baseDelay * 2^attempt
  /// غير موصى به للـ production
  none,
}

/// تكوين إعادة المحاولة
class RetryConfig {
  /// الحد الأقصى لعدد المحاولات
  final int maxAttempts;

  /// التأخير الأساسي
  final Duration baseDelay;

  /// الحد الأقصى للتأخير
  final Duration maxDelay;

  /// نوع الـ Jitter
  final JitterType jitterType;

  /// معامل Jitter (0.0 - 1.0)
  final double jitterFactor;

  /// أكواد HTTP التي تستدعي إعادة المحاولة
  final List<int> retryStatusCodes;

  /// أكواد HTTP التي لا تستدعي إعادة المحاولة
  final List<int> noRetryStatusCodes;

  const RetryConfig({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.jitterType = JitterType.full,
    this.jitterFactor = 0.5,
    this.retryStatusCodes = const [408, 429, 500, 502, 503, 504],
    this.noRetryStatusCodes = const [400, 401, 403, 404, 422],
  });

  /// تكوين للـ API calls
  static const api = RetryConfig(
    maxAttempts: 3,
    baseDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 30),
    jitterType: JitterType.full,
  );

  /// تكوين للـ Sync operations
  static const sync = RetryConfig(
    maxAttempts: 5,
    baseDelay: Duration(seconds: 2),
    maxDelay: Duration(minutes: 2),
    jitterType: JitterType.decorrelated,
  );

  /// تكوين للـ Critical operations
  static const critical = RetryConfig(
    maxAttempts: 10,
    baseDelay: Duration(milliseconds: 500),
    maxDelay: Duration(minutes: 5),
    jitterType: JitterType.equal,
  );

  /// تكوين سريع للاختبارات
  static const test = RetryConfig(
    maxAttempts: 3,
    baseDelay: Duration(milliseconds: 10),
    maxDelay: Duration(milliseconds: 100),
    jitterType: JitterType.none,
  );
}

/// نتيجة المحاولة
class RetryResult<T> {
  final T? value;
  final Object? error;
  final StackTrace? stackTrace;
  final int attempts;
  final Duration totalDuration;
  final List<Duration> delays;
  final bool isSuccess;

  const RetryResult._({
    this.value,
    this.error,
    this.stackTrace,
    required this.attempts,
    required this.totalDuration,
    required this.delays,
    required this.isSuccess,
  });

  factory RetryResult.success(
    T value, {
    required int attempts,
    required Duration totalDuration,
    required List<Duration> delays,
  }) {
    return RetryResult._(
      value: value,
      attempts: attempts,
      totalDuration: totalDuration,
      delays: delays,
      isSuccess: true,
    );
  }

  factory RetryResult.failure(
    Object error,
    StackTrace? stackTrace, {
    required int attempts,
    required Duration totalDuration,
    required List<Duration> delays,
  }) {
    return RetryResult._(
      error: error,
      stackTrace: stackTrace,
      attempts: attempts,
      totalDuration: totalDuration,
      delays: delays,
      isSuccess: false,
    );
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'RetryResult.success(attempts: $attempts, duration: ${totalDuration.inMilliseconds}ms)';
    }
    return 'RetryResult.failure(attempts: $attempts, error: $error)';
  }
}

/// Retry Strategy
class RetryStrategy {
  RetryStrategy._();

  static final Random _random = Random();
  static Duration? _lastDelay; // للـ decorrelated jitter

  /// حساب التأخير مع Jitter
  static Duration getDelay(
    int attempt, {
    RetryConfig config = const RetryConfig(),
    Duration? previousDelay,
  }) {
    if (attempt < 0) {
      throw ArgumentError('Attempt must be >= 0');
    }

    final delay = switch (config.jitterType) {
      JitterType.full => _fullJitter(attempt, config),
      JitterType.equal => _equalJitter(attempt, config),
      JitterType.decorrelated => _decorrelatedJitter(
          attempt,
          config,
          previousDelay ?? _lastDelay,
        ),
      JitterType.none => _noJitter(attempt, config),
    };

    _lastDelay = delay;
    return delay;
  }

  /// Full Jitter
  /// delay = random(0, min(cap, baseDelay * 2^attempt))
  static Duration _fullJitter(int attempt, RetryConfig config) {
    final exponentialDelay =
        config.baseDelay.inMilliseconds * (1 << attempt);
    final cappedDelay = min(exponentialDelay, config.maxDelay.inMilliseconds);
    final jitteredDelay = _random.nextInt(cappedDelay + 1);
    return Duration(milliseconds: max(1, jitteredDelay));
  }

  /// Equal Jitter
  /// delay = min(cap, baseDelay * 2^attempt) / 2 + random(0, same/2)
  static Duration _equalJitter(int attempt, RetryConfig config) {
    final exponentialDelay =
        config.baseDelay.inMilliseconds * (1 << attempt);
    final cappedDelay = min(exponentialDelay, config.maxDelay.inMilliseconds);
    final halfDelay = cappedDelay ~/ 2;
    final jitteredDelay = halfDelay + _random.nextInt(halfDelay + 1);
    return Duration(milliseconds: max(1, jitteredDelay));
  }

  /// Decorrelated Jitter
  /// delay = min(cap, random(baseDelay, prevDelay * 3))
  static Duration _decorrelatedJitter(
    int attempt,
    RetryConfig config,
    Duration? previousDelay,
  ) {
    final baseMs = config.baseDelay.inMilliseconds;
    final prevMs = previousDelay?.inMilliseconds ?? baseMs;
    final maxMs = min(prevMs * 3, config.maxDelay.inMilliseconds);
    final jitteredDelay = baseMs + _random.nextInt(max(1, maxMs - baseMs + 1));
    return Duration(milliseconds: max(1, jitteredDelay));
  }

  /// No Jitter (Exponential Backoff فقط)
  static Duration _noJitter(int attempt, RetryConfig config) {
    final exponentialDelay =
        config.baseDelay.inMilliseconds * (1 << attempt);
    final cappedDelay = min(exponentialDelay, config.maxDelay.inMilliseconds);
    return Duration(milliseconds: cappedDelay);
  }

  /// تنفيذ مع إعادة المحاولة
  static Future<RetryResult<T>> execute<T>(
    Future<T> Function() operation, {
    RetryConfig config = const RetryConfig(),
    bool Function(Object error)? shouldRetry,
    void Function(int attempt, Duration delay, Object error)? onRetry,
  }) async {
    final stopwatch = Stopwatch()..start();
    final delays = <Duration>[];
    Duration? previousDelay;

    for (var attempt = 0; attempt < config.maxAttempts; attempt++) {
      try {
        final result = await operation();
        stopwatch.stop();
        return RetryResult.success(
          result,
          attempts: attempt + 1,
          totalDuration: stopwatch.elapsed,
          delays: delays,
        );
      } catch (e, st) {
        final isLastAttempt = attempt == config.maxAttempts - 1;
        final retry = shouldRetry?.call(e) ?? true;

        if (isLastAttempt || !retry) {
          stopwatch.stop();
          return RetryResult.failure(
            e,
            st,
            attempts: attempt + 1,
            totalDuration: stopwatch.elapsed,
            delays: delays,
          );
        }

        final delay = getDelay(
          attempt,
          config: config,
          previousDelay: previousDelay,
        );
        delays.add(delay);
        previousDelay = delay;

        onRetry?.call(attempt + 1, delay, e);

        AppLogger.debug(
          'Retry attempt ${attempt + 1}/${config.maxAttempts} '
          'after ${delay.inMilliseconds}ms (error: $e)',
          tag: 'RetryStrategy',
        );

        await Future.delayed(delay);
      }
    }

    // لن نصل هنا أبداً
    throw StateError('Unexpected state in retry logic');
  }

  /// هل يجب إعادة المحاولة لهذا الـ status code؟
  static bool shouldRetryStatusCode(
    int statusCode, {
    RetryConfig config = const RetryConfig(),
  }) {
    if (config.noRetryStatusCodes.contains(statusCode)) {
      return false;
    }
    return config.retryStatusCodes.contains(statusCode);
  }

  /// حساب إجمالي الوقت المتوقع للمحاولات
  static Duration estimateTotalTime({
    required int attempts,
    RetryConfig config = const RetryConfig(),
  }) {
    var total = Duration.zero;
    for (var i = 0; i < attempts - 1; i++) {
      // استخدام no jitter للتقدير
      final delay = _noJitter(i, config);
      total += delay;
    }
    return total;
  }

  /// إعادة تعيين الحالة
  static void reset() {
    _lastDelay = null;
  }
}

/// Extension للـ Future مع Retry
extension RetryFutureExtension<T> on Future<T> {
  /// تنفيذ مع إعادة المحاولة
  Future<T> withRetry({
    RetryConfig config = const RetryConfig(),
    bool Function(Object error)? shouldRetry,
    void Function(int attempt, Duration delay, Object error)? onRetry,
  }) async {
    final result = await RetryStrategy.execute(
      () => this,
      config: config,
      shouldRetry: shouldRetry,
      onRetry: onRetry,
    );

    if (result.isSuccess) {
      return result.value as T;
    }

    throw result.error!;
  }
}

/// Retry Callback للـ Dio
typedef RetryCallback = Future<void> Function(
  int attempt,
  Duration delay,
  Object error,
);

/// Retry Condition للـ Dio
typedef RetryCondition = bool Function(Object error);
