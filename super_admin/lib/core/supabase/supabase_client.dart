import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alhai_core/alhai_core.dart' show SupabaseConfig;

/// Default timeout durations for Supabase network operations.
class SupabaseTimeouts {
  SupabaseTimeouts._();

  /// Timeout for establishing a TCP connection.
  static const connectionTimeout = Duration(seconds: 15);

  /// Timeout for idle keep-alive connections.
  static const idleTimeout = Duration(seconds: 60);

  /// Per-request timeout for individual Supabase queries.
  ///
  /// Use with `.timeout()` on any Future-based Supabase call when you
  /// need explicit request-level protection against hung requests.
  static const requestTimeout = Duration(seconds: 30);
}

/// Supabase client initialization and access for super_admin.
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
    final ioClient = HttpClient()
      ..connectionTimeout = SupabaseTimeouts.connectionTimeout
      ..idleTimeout = SupabaseTimeouts.idleTimeout;

    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: SupabaseConfig.enableDebugLogs,
      httpClient: IOClient(ioClient),
    ).timeout(
      const Duration(seconds: 20),
      onTimeout: () => throw TimeoutException(
        'Supabase initialization timed out after 20 seconds',
      ),
    );

    _initialized = true;
    if (kDebugMode) debugPrint('Supabase initialized (super_admin)');
  }

  /// Get the Supabase client instance.
  static SupabaseClient get client => Supabase.instance.client;

  /// Check if user is currently authenticated.
  static bool get isAuthenticated => client.auth.currentSession != null;

  /// Get current user ID or null.
  static String? get currentUserId => client.auth.currentUser?.id;
}
