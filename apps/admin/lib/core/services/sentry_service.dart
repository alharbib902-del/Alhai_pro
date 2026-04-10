import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Sentry DSN injected via --dart-define at build time.
///
/// Usage:
/// flutter run --dart-define=SENTRY_DSN_ADMIN=https://xxx@xxx.ingest.sentry.io/xxx
/// flutter build apk --dart-define=SENTRY_DSN_ADMIN=https://xxx@xxx.ingest.sentry.io/xxx
const _sentryDsn = String.fromEnvironment('SENTRY_DSN_ADMIN');

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

  await SentryFlutter.init(
    (options) {
      options.dsn = _sentryDsn;
      options.environment = kDebugMode ? 'development' : 'production';
      options.tracesSampleRate = kDebugMode ? 1.0 : 0.3;
      options.attachScreenshot = true;
      options.sendDefaultPii = false;
      options.diagnosticLevel = SentryLevel.warning;
    },
    appRunner: appRunner,
  );
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

  Sentry.addBreadcrumb(Breadcrumb(
    message: message,
    category: category,
    level: level,
    data: data,
    timestamp: DateTime.now(),
  ));
}
