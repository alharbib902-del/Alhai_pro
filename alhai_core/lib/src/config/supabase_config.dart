/// Supabase Configuration
///
/// Contains Supabase project URL and anon key.
/// NEVER include service_role key in client code.
///
/// Important security note:
/// Values must be passed via --dart-define at build time:
///
/// Development:
/// flutter run --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=xxx
///
/// Production:
/// flutter build apk --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=xxx
///
/// Never hardcode actual values in source code!
library;

import 'package:flutter/foundation.dart';

class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase project URL
  /// Must be provided via --dart-define=SUPABASE_URL=https://your-project.supabase.co
  static const String url = String.fromEnvironment('SUPABASE_URL');

  /// Supabase anon (public) key
  /// Must be provided via --dart-define=SUPABASE_ANON_KEY=your_anon_key
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Validate that required environment variables are set.
  /// Call early in app startup (e.g. main()) to fail fast.
  static void assertConfigured() {
    assert(url.isNotEmpty,
        'SUPABASE_URL not set. Use --dart-define=SUPABASE_URL=...');
    assert(anonKey.isNotEmpty,
        'SUPABASE_ANON_KEY not set. Use --dart-define=SUPABASE_ANON_KEY=...');
  }

  /// Whether to enable Supabase debug logging
  static bool get enableDebugLogs => kDebugMode;

  /// Whether the configuration is complete
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  /// Error message if configuration is incomplete
  static String get configurationError {
    final missing = <String>[];
    if (url.isEmpty) missing.add('SUPABASE_URL');
    if (anonKey.isEmpty) missing.add('SUPABASE_ANON_KEY');

    if (missing.isEmpty) return '';
    return 'Missing required environment variables: ${missing.join(', ')}. '
        'Use --dart-define to provide them.';
  }

  // ==========================================================================
  // SECURITY HEADERS
  // ==========================================================================

  /// Security headers attached to every outgoing API request.
  ///
  /// These provide defence-in-depth at the HTTP transport layer:
  /// - **X-Content-Type-Options**: prevents MIME-type sniffing.
  /// - **X-Frame-Options**: blocks clickjacking by disallowing framing.
  /// - **Strict-Transport-Security**: enforces HTTPS for 1 year including
  ///   sub-domains (relevant when the Supabase client is used from a web
  ///   build or server-side).
  /// - **X-XSS-Protection**: enables the browser's built-in XSS filter
  ///   (legacy but harmless).
  /// - **X-Request-Id**: a per-configuration identifier that can be used for
  ///   request tracing in server logs.
  ///
  /// Usage example with Supabase custom headers:
  /// ```dart
  /// Supabase.initialize(
  ///   url: SupabaseConfig.url,
  ///   anonKey: SupabaseConfig.anonKey,
  ///   headers: SupabaseConfig.secureHeaders,
  /// );
  /// ```
  static const Map<String, String> secureHeaders = {
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
    'X-XSS-Protection': '1; mode=block',
  };
}
