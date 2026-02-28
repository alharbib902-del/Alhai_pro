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
  /// Required: --dart-define=SUPABASE_URL=https://your-project.supabase.co
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
  );

  /// Supabase anon (public) key
  /// Required: --dart-define=SUPABASE_ANON_KEY=your_anon_key
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

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
}
