import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alhai_core/alhai_core.dart'
    show CertificatePinningService, SupabaseConfig;

/// Supabase client initialization and access for the driver app.
class AppSupabase {
  AppSupabase._();

  static bool _initialized = false;

  /// Initialize Supabase. Call once at app startup.
  ///
  /// Security measures applied:
  /// - **Certificate pinning**: A custom [HttpClient] from
  ///   [CertificatePinningService] is attached in release builds to reject
  ///   connections whose TLS certificate does not match the pinned SHA-256
  ///   fingerprints. See [CertificatePinningService] for pin management.
  /// - **Secure headers**: Standard security headers from [SupabaseConfig].
  /// - **Connection timeouts**: The pinned client enforces a 15 s connection
  ///   timeout and 30 s idle timeout to avoid hanging requests.
  static Future<void> initialize() async {
    if (_initialized) return;

    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'Supabase not configured. ${SupabaseConfig.configurationError}',
      );
    }

    // Certificate pinning: creates a custom HttpClient that validates the
    // server certificate chain against known SHA-256 fingerprints in release
    // mode. In debug mode pinning is disabled for proxy/inspection tools.
    final httpClient = CertificatePinningService.createPinnedClient();

    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: SupabaseConfig.enableDebugLogs,
      headers: SupabaseConfig.secureHeaders,
      httpClient: httpClient,
    );

    _initialized = true;
    if (kDebugMode) {
      debugPrint('Supabase initialized for driver app');
      debugPrint(
        'Certificate pinning: ${CertificatePinningService.diagnosticStatus}',
      );
    }
  }

  /// Get the Supabase client instance.
  static SupabaseClient get client => Supabase.instance.client;

  /// Check if user is currently authenticated.
  static bool get isAuthenticated => client.auth.currentSession != null;

  /// Get current user ID or null.
  static String? get currentUserId => client.auth.currentUser?.id;
}
