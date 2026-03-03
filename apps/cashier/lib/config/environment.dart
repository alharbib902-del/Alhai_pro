/// Environment configuration — separates dev/staging/prod settings.
///
/// Values are injected at build time via `--dart-define=ENV=production`.
/// Usage:
///   flutter run --dart-define=ENV=dev
///   flutter build web --dart-define=ENV=production
library;

enum Environment { dev, staging, production }

class AppEnvironment {
  AppEnvironment._();

  /// Current environment from compile-time define
  static const _envString = String.fromEnvironment('ENV', defaultValue: 'dev');

  static Environment get current {
    return switch (_envString) {
      'production' || 'prod' => Environment.production,
      'staging' => Environment.staging,
      _ => Environment.dev,
    };
  }

  static bool get isDev => current == Environment.dev;
  static bool get isStaging => current == Environment.staging;
  static bool get isProduction => current == Environment.production;

  /// Supabase URL — injected via --dart-define or falls back to env default
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Supabase anon key — injected via --dart-define
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Sentry DSN — injected via --dart-define
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  /// Whether to enable verbose logging (only in dev)
  static bool get enableDebugLogs => isDev;

  /// Whether to enable Sentry error reporting
  static bool get enableSentry => !isDev && sentryDsn.isNotEmpty;

  /// App display name by environment
  static String get appName => switch (current) {
    Environment.dev => 'Al-HAI Cashier (Dev)',
    Environment.staging => 'Al-HAI Cashier (Staging)',
    Environment.production => 'Al-HAI Cashier',
  };
}
