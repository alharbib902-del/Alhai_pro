/// App Flavor Configuration
///
/// Supports dev, staging, and prod environments via --dart-define=FLAVOR=xxx
///
/// Usage:
///   flutter run --dart-define=FLAVOR=dev
///   flutter run --dart-define=FLAVOR=staging
///   flutter build apk --dart-define=FLAVOR=prod
library;

enum AppFlavor {
  dev,
  staging,
  prod;

  static AppFlavor get current {
    const flavorStr = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    return switch (flavorStr) {
      'prod' || 'production' => AppFlavor.prod,
      'staging' || 'stg' => AppFlavor.staging,
      _ => AppFlavor.dev,
    };
  }

  bool get isDev => this == AppFlavor.dev;
  bool get isStaging => this == AppFlavor.staging;
  bool get isProd => this == AppFlavor.prod;

  String get label => switch (this) {
    AppFlavor.dev => 'DEV',
    AppFlavor.staging => 'STG',
    AppFlavor.prod => '',
  };

  String get appNameSuffix => switch (this) {
    AppFlavor.dev => ' (Dev)',
    AppFlavor.staging => ' (Staging)',
    AppFlavor.prod => '',
  };
}

/// Centralized environment configuration that reads from --dart-define
class EnvConfig {
  EnvConfig._();

  static AppFlavor get flavor => AppFlavor.current;

  /// Supabase
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// AI Server
  static const String aiServerUrl = String.fromEnvironment('AI_SERVER_URL');

  /// Sentry DSN (error tracking)
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  /// Enable debug logging
  static bool get enableDebugLogs => flavor.isDev || flavor.isStaging;

  /// Whether all required config is present
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String get configSummary =>
      'Flavor: ${flavor.name}, Supabase: ${supabaseUrl.isNotEmpty ? "OK" : "MISSING"}, '
      'AI: ${aiServerUrl.isNotEmpty ? "OK" : "N/A"}';
}
