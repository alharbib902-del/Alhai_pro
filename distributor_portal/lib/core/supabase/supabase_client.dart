import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alhai_core/alhai_core.dart' show SupabaseConfig;

/// Supabase client initialization and access for the distributor portal.
///
/// **Security note on token storage:**
/// On web, Supabase Flutter stores auth tokens in localStorage by default.
/// This is acceptable for web deployments but tokens are accessible to any JS
/// running on the same origin. The CSP headers in index.html mitigate XSS risk.
/// For mobile/desktop builds, consider providing a custom [LocalStorage]
/// implementation backed by flutter_secure_storage for encrypted token storage:
///
/// ```dart
/// // Example for mobile builds:
/// // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
/// // authOptions: FlutterAuthClientOptions(
/// //   localStorage: SecureLocalStorage(),
/// // ),
/// ```
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

    // Use a custom HttpClient with timeouts to avoid hanging requests.
    // 30s connection timeout, 60s idle timeout.
    final ioClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30)
      ..idleTimeout = const Duration(seconds: 60);

    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: SupabaseConfig.enableDebugLogs,
      httpClient: IOClient(ioClient),
    );

    _initialized = true;
    if (kDebugMode) debugPrint('Supabase initialized for distributor portal');
  }

  /// Get the Supabase client instance.
  static SupabaseClient get client => Supabase.instance.client;

  /// Check if user is currently authenticated.
  static bool get isAuthenticated => client.auth.currentSession != null;

  /// Get current user ID or null.
  static String? get currentUserId => client.auth.currentUser?.id;

  /// Get current user email or null.
  static String? get currentUserEmail => client.auth.currentUser?.email;
}
