import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alhai_core/alhai_core.dart' show SupabaseConfig;

/// Supabase client initialization and access for the driver app.
class AppSupabase {
  AppSupabase._();

  static bool _initialized = false;

  /// Initialize Supabase. Call once at app startup.
  static Future<void> initialize() async {
    if (_initialized) return;

    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'Supabase not configured. ${SupabaseConfig.configurationError}',
      );
    }

    // TODO(security): Add certificate pinning for production builds using the
    // http_certificate_pinning package or a custom HttpClient with a pinned
    // SecurityContext. This prevents MITM attacks even if a rogue CA is trusted
    // by the OS. Pin the Supabase project certificate's SHA-256 fingerprint.
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: SupabaseConfig.enableDebugLogs,
      headers: SupabaseConfig.secureHeaders,
    );

    _initialized = true;
    if (kDebugMode) debugPrint('Supabase initialized for driver app');
  }

  /// Get the Supabase client instance.
  static SupabaseClient get client => Supabase.instance.client;

  /// Check if user is currently authenticated.
  static bool get isAuthenticated => client.auth.currentSession != null;

  /// Get current user ID or null.
  static String? get currentUserId => client.auth.currentUser?.id;
}
