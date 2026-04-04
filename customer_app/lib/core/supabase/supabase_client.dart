import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alhai_core/alhai_core.dart' show SupabaseConfig;

/// Secure async storage backed by flutter_secure_storage for Supabase auth tokens.
class SecureLocalStorage extends GotrueAsyncStorage {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  Future<String?> getItem({required String key}) => _storage.read(key: key);

  @override
  Future<void> setItem({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> removeItem({required String key}) => _storage.delete(key: key);
}

/// Supabase client initialization and access for the customer app.
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

    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: SupabaseConfig.enableDebugLogs,
      authOptions: FlutterAuthClientOptions(
        autoRefreshToken: true,
        pkceAsyncStorage: SecureLocalStorage(),
      ),
    );

    _initialized = true;
    if (kDebugMode) debugPrint('Supabase initialized with secure storage');
  }

  /// Get the Supabase client instance.
  static SupabaseClient get client => Supabase.instance.client;

  /// Check if user is currently authenticated.
  static bool get isAuthenticated => client.auth.currentSession != null;

  /// Get current user ID or null.
  static String? get currentUserId => client.auth.currentUser?.id;
}
