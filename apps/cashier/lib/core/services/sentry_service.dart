import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Sentry DSN injected via --dart-define at build time.
///
/// Usage:
/// flutter run --dart-define=SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx
/// flutter build apk --dart-define=SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx
const _sentryDsn = String.fromEnvironment('SENTRY_DSN');

/// Whether Sentry is configured (DSN provided).
bool get isSentryConfigured => _sentryDsn.isNotEmpty;

/// Initialize Sentry and run the app inside its error boundary.
///
/// Wraps [appRunner] with SentryFlutter.init when a DSN is provided.
/// Falls back to running [appRunner] directly in debug mode or when
/// no DSN is configured.
Future<void> initSentry({required Future<void> Function() appRunner}) async {
  if (!isSentryConfigured) {
    if (kDebugMode) debugPrint('Sentry DSN not configured — skipping init');
    await appRunner();
    return;
  }

  await SentryFlutter.init((options) {
    options.dsn = _sentryDsn;
    options.environment = kDebugMode ? 'development' : 'production';
    options.tracesSampleRate = kDebugMode ? 1.0 : 0.3;
    options.attachScreenshot = true;
    options.sendDefaultPii = false;
    options.diagnosticLevel = SentryLevel.warning;
  }, appRunner: appRunner);
}

/// Report an exception to Sentry (non-fatal).
///
/// Also prints to console in debug mode.
Future<void> reportError(
  dynamic exception, {
  StackTrace? stackTrace,
  String? hint,
}) async {
  if (kDebugMode) {
    debugPrint('Error: $exception${hint != null ? ' ($hint)' : ''}');
  }
  if (!isSentryConfigured) return;

  await Sentry.captureException(
    exception,
    stackTrace: stackTrace,
    hint: hint != null ? Hint.withMap({'message': hint}) : null,
  );
}

/// Add a navigation/action breadcrumb for debugging context.
void addBreadcrumb({
  required String message,
  String category = 'app',
  SentryLevel level = SentryLevel.info,
  Map<String, dynamic>? data,
}) {
  if (kDebugMode) debugPrint('[$category] $message');
  if (!isSentryConfigured) return;

  Sentry.addBreadcrumb(
    Breadcrumb(
      message: message,
      category: category,
      level: level,
      data: data,
      timestamp: DateTime.now(),
    ),
  );
}

/// Phase 5 §5.4 — Performance monitoring helper.
///
/// Wraps [body] in a Sentry transaction so its duration, status, and any
/// caught exception are recorded as a performance event. No-op when
/// Sentry is not configured (returns the result without observability).
///
/// Example:
/// ```dart
/// final sales = await tracePerformance(
///   name: 'loadDailySales',
///   operation: 'db.query',
///   body: () => salesDao.getSalesForDate(today),
/// );
/// ```
///
/// Operation taxonomy:
/// - `db.query`, `db.write`       — local Drift DAO calls
/// - `http.client`                — outbound Supabase requests
/// - `ui.render`                  — expensive build/layout work
/// - `sync.push`, `sync.pull`     — sync queue batches
///
/// Sample rates: `tracesSampleRate` in [initSentry] caps volume
/// (1.0 in debug, 0.3 in production). Transactions beyond the cap are
/// dropped on the client.
Future<T> tracePerformance<T>({
  required String name,
  required String operation,
  required Future<T> Function() body,
  Map<String, dynamic>? data,
}) async {
  if (!isSentryConfigured) {
    // Short-circuit when DSN missing — tests + local dev shouldn't pay
    // the wrapper cost.
    return body();
  }

  final transaction = Sentry.startTransaction(
    name,
    operation,
    bindToScope: false,
  );

  if (data != null) {
    data.forEach(transaction.setData);
  }

  try {
    final result = await body();
    transaction.status = const SpanStatus.ok();
    return result;
  } catch (e, st) {
    transaction.throwable = e;
    transaction.status = const SpanStatus.internalError();
    // Re-report so the transaction links the exception as a related event.
    await reportError(e, stackTrace: st, hint: 'tracePerformance:$name');
    rethrow;
  } finally {
    await transaction.finish();
  }
}

/// Synchronous variant — use for CPU-bound work that doesn't await.
T tracePerformanceSync<T>({
  required String name,
  required String operation,
  required T Function() body,
  Map<String, dynamic>? data,
}) {
  if (!isSentryConfigured) return body();

  final transaction = Sentry.startTransaction(
    name,
    operation,
    bindToScope: false,
  );

  if (data != null) {
    data.forEach(transaction.setData);
  }

  try {
    final result = body();
    transaction.status = const SpanStatus.ok();
    return result;
  } catch (e, st) {
    transaction.throwable = e;
    transaction.status = const SpanStatus.internalError();
    reportError(e, stackTrace: st, hint: 'tracePerformanceSync:$name');
    rethrow;
  } finally {
    transaction.finish();
  }
}
