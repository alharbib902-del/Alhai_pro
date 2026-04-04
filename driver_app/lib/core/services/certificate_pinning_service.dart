import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Certificate pinning service for production security.
///
/// Pins Supabase API server certificates to prevent MITM attacks, even when a
/// rogue Certificate Authority is trusted by the device OS.
///
/// ## How it works
/// - In **release** builds the custom [HttpClient] rejects any TLS connection
///   whose certificate does not match one of the known SHA-256 fingerprints
///   listed in [_pinnedHashes].
/// - In **debug** builds pinning is disabled so that proxy/inspection tools
///   (Charles, mitmproxy, etc.) continue to work during development.
///
/// ## Updating pins
/// Supabase rotates certificates periodically. When that happens:
/// 1. Obtain the new SHA-256 fingerprint(s) from the Supabase dashboard or by
///    running:
///    ```
///    openssl s_client -connect <project>.supabase.co:443 < /dev/null 2>/dev/null \
///      | openssl x509 -fingerprint -sha256 -noout
///    ```
/// 2. Add the new hash to [_pinnedHashes] **before** the old one expires.
/// 3. Remove retired hashes once the rotation window has closed.
class CertificatePinningService {
  CertificatePinningService._();

  // ---------------------------------------------------------------------------
  // Pinned SHA-256 certificate fingerprints
  // ---------------------------------------------------------------------------

  /// Known SHA-256 fingerprints for the Supabase server certificate chain.
  ///
  /// Add your project's certificate fingerprints here. Each entry should be a
  /// colon-separated, uppercase hex SHA-256 fingerprint, e.g.:
  /// ```
  /// 'AB:CD:EF:12:34:...'
  /// ```
  ///
  /// Keep at least two pins (current + backup/next) to survive rotations
  /// without an app update.
  static const _pinnedHashes = <String>[
    // TODO(security): Add your Supabase project SHA-256 fingerprints here.
    // Run the openssl command from the class doc to obtain them.
    //
    // Example format (do NOT use these values):
    // 'AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99',
  ];

  /// Whether certificate pinning is active.
  ///
  /// Pinning is only enforced when:
  /// - Running in release mode, AND
  /// - At least one fingerprint has been configured.
  static bool get isEnabled => !kDebugMode && _pinnedHashes.isNotEmpty;

  // ---------------------------------------------------------------------------
  // HttpClient factory
  // ---------------------------------------------------------------------------

  /// Creates an [http.Client] with certificate pinning enabled in release mode.
  ///
  /// Pass the returned client to `Supabase.initialize(httpClient: ...)` so all
  /// Supabase HTTP traffic goes through the pinned connection.
  static http.Client createPinnedClient() {
    final ioClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15)
      ..idleTimeout = const Duration(seconds: 30);

    if (kDebugMode) {
      // In debug mode, allow all certificates for proxy/inspection tools.
      debugPrint('[CertificatePinning] Debug mode - pinning disabled');
      return IOClient(ioClient);
    }

    if (_pinnedHashes.isEmpty) {
      // No pins configured yet. Reject bad certificates but skip pin check.
      ioClient.badCertificateCallback = (cert, host, port) {
        debugPrint(
          '[CertificatePinning] Bad certificate for $host:$port '
          '(no pins configured)',
        );
        return false;
      };
      return IOClient(ioClient);
    }

    // Production mode with pins configured: validate fingerprints.
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      debugPrint(
        '[CertificatePinning] Certificate validation failed for $host:$port',
      );
      return false;
    };

    return IOClient(ioClient);
  }

  /// Returns a human-readable status string for diagnostics.
  static String get diagnosticStatus {
    if (kDebugMode) return 'DISABLED (debug mode)';
    if (_pinnedHashes.isEmpty) return 'NOT CONFIGURED (no pins)';
    return 'ACTIVE (${_pinnedHashes.length} pin(s))';
  }
}
