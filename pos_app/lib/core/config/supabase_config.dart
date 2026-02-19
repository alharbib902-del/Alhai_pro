/// Supabase Configuration
///
/// Contains Supabase project URL and anon key.
/// NEVER include service_role key in client code.
library;

import 'package:flutter/foundation.dart';

class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase project URL
  static const String url = 'https://jtgwboqushihwvvsdtud.supabase.co';

  /// Supabase anon (public) key - safe for client-side use
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp0Z3dib3F1c2hpaHd2dnNkdHVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEzODIyODMsImV4cCI6MjA4Njk1ODI4M30.nqYYVlk2YeSgG7FNy7CIpXaw4vHWfU4oRMKDHWL-gzM';

  /// Whether to enable Supabase debug logging
  static bool get enableDebugLogs => kDebugMode;
}
