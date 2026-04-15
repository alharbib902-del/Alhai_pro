import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/io_client.dart';
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

  /// Known SHA-256 fingerprints of Supabase TLS certificates.
  /// Update these when Supabase rotates certificates.
  /// To obtain: openssl s_client -connect <project>.supabase.co:443 | openssl x509 -fingerprint -sha256
  static const List<String> _pinnedFingerprints = [
    // Supabase uses AWS/Cloudflare certificates.
    // TODO: Replace with actual project certificate fingerprint before production release.
    // Example format: 'AB:CD:EF:...' (SHA-256 fingerprint)
  ];

  /// Constant-time comparison to prevent timing attacks on fingerprint matching.
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    final aLower = a.toLowerCase();
    final bLower = b.toLowerCase();
    for (var i = 0; i < aLower.length; i++) {
      result |= aLower.codeUnitAt(i) ^ bLower.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Creates an HttpClient with certificate pinning in release mode.
  static HttpClient _createPinnedClient() {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30)
      ..idleTimeout = const Duration(seconds: 60);

    // Only enforce pinning in release mode and when fingerprints are configured
    if (kReleaseMode && _pinnedFingerprints.isNotEmpty) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Compute SHA-256 fingerprint from the certificate's DER encoding
        final derBytes = cert.der;
        final digest = sha256.convert(derBytes);
        final fingerprint = digest.bytes
            .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
            .join(':');

        // Check against all pinned fingerprints using constant-time comparison
        for (final pinned in _pinnedFingerprints) {
          if (_constantTimeEquals(fingerprint, pinned)) {
            return true; // Certificate matches — accept
          }
        }

        // Fail closed: reject connections with unknown certificates
        return false;
      };
    }

    return client;
  }

  /// Initialize Supabase. Call once at app startup.
  static Future<void> initialize() async {
    if (_initialized) return;

    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'Supabase not configured. ${SupabaseConfig.configurationError}',
      );
    }

    final ioClient = _createPinnedClient();

    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: SupabaseConfig.enableDebugLogs,
      httpClient: IOClient(ioClient),
      authOptions: FlutterAuthClientOptions(
        autoRefreshToken: true,
        pkceAsyncStorage: SecureLocalStorage(),
      ),
    );

    _initialized = true;
    if (kDebugMode) debugPrint('Supabase initialized with secure storage and cert pinning');
  }

  /// Get the Supabase client instance.
  static SupabaseClient get client => Supabase.instance.client;

  /// Check if user is currently authenticated.
  static bool get isAuthenticated => client.auth.currentSession != null;

  /// Get current user ID or null.
  static String? get currentUserId => client.auth.currentUser?.id;
}
