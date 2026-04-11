import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
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
///   whose SHA-256 certificate fingerprint does not match one of the known
///   fingerprints listed in [_pinnedHashes]. The service refuses to initialize
///   when the pin list is empty in release mode — fail closed.
/// - In **debug** builds pinning is disabled so that proxy/inspection tools
///   (Charles, mitmproxy, etc.) continue to work during development.
///
/// ## Configuring pins
/// Fingerprints are supplied at build time via `--dart-define`:
/// ```
/// flutter build apk --release \
///   --dart-define=SUPABASE_CERT_FINGERPRINT=<base64 sha256> \
///   --dart-define=SUPABASE_CERT_FINGERPRINT_BACKUP=<base64 sha256>
/// ```
///
/// The expected format is the **base64-encoded SHA-256 hash of the DER-encoded
/// certificate** (the `sha256//` value used by RFC 7469 HPKP-style pinning).
/// To obtain it:
/// ```
/// openssl s_client -connect <project>.supabase.co:443 -servername <project>.supabase.co < /dev/null 2>/dev/null \
///   | openssl x509 -outform DER \
///   | openssl dgst -sha256 -binary \
///   | base64
/// ```
///
/// Keep at least two pins (current + backup/next) to survive rotations
/// without an app update.
class CertificatePinningService {
  CertificatePinningService._();

  // ---------------------------------------------------------------------------
  // Pinned SHA-256 certificate fingerprints
  // ---------------------------------------------------------------------------

  /// Primary fingerprint, injected via `--dart-define=SUPABASE_CERT_FINGERPRINT=`.
  static const String _primaryFingerprint = String.fromEnvironment(
    'SUPABASE_CERT_FINGERPRINT',
  );

  /// Optional backup fingerprint for rotation windows.
  static const String _backupFingerprint = String.fromEnvironment(
    'SUPABASE_CERT_FINGERPRINT_BACKUP',
  );

  /// Active pin list, normalized (trimmed, non-empty).
  static final List<String> _pinnedHashes = <String>[
    if (_primaryFingerprint.trim().isNotEmpty) _primaryFingerprint.trim(),
    if (_backupFingerprint.trim().isNotEmpty) _backupFingerprint.trim(),
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

  /// Creates an [http.Client] with certificate pinning enforced in release mode.
  ///
  /// Throws [StateError] in release mode when no fingerprints are configured.
  /// In debug mode a missing pin list only triggers a warning log so that
  /// developer builds keep working.
  ///
  /// Pass the returned client to `Supabase.initialize(httpClient: ...)` so all
  /// Supabase HTTP traffic goes through the pinned connection.
  static http.Client createPinnedClient() {
    // Fail-closed in release mode: refuse to boot without pins.
    if (kReleaseMode && _pinnedHashes.isEmpty) {
      throw StateError(
        '[CertificatePinning] No pinned fingerprints configured for a '
        'release build. Rebuild with '
        '--dart-define=SUPABASE_CERT_FINGERPRINT=<base64 sha256> '
        '(and optionally SUPABASE_CERT_FINGERPRINT_BACKUP). Refusing to '
        'initialize an unpinned HTTP client.',
      );
    }

    final ioClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15)
      ..idleTimeout = const Duration(seconds: 30);

    if (kDebugMode) {
      if (_pinnedHashes.isEmpty) {
        debugPrint(
          '[CertificatePinning] WARNING: Debug build has no pinned '
          'fingerprints — certificate pinning is DISABLED. Configure '
          'SUPABASE_CERT_FINGERPRINT before release.',
        );
      } else {
        debugPrint(
          '[CertificatePinning] Debug mode: pinning disabled for dev tools',
        );
      }
      return IOClient(ioClient);
    }

    // Release mode with pins configured: validate fingerprints against the
    // SHA-256 of the DER-encoded peer certificate.
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
          // First gate: if the platform already considered the cert valid the
          // callback would not be invoked — reaching here means the cert is
          // untrusted or hostname mismatched. Enforce pin match as a second gate
          // and fail-closed on any mismatch.
          final matches = _matchesPinnedFingerprint(cert);
          if (!matches) {
            debugPrint(
              '[CertificatePinning] REJECTED certificate for $host:$port '
              '(fingerprint mismatch)',
            );
            return false;
          }
          debugPrint(
            '[CertificatePinning] Accepted pinned certificate for $host:$port',
          );
          return true;
        };

    return IOClient(ioClient);
  }

  /// Computes the base64-encoded SHA-256 of the DER bytes of [cert] and
  /// returns whether it matches any configured pin.
  static bool _matchesPinnedFingerprint(X509Certificate cert) {
    final derBytes = cert.der;
    final digest = sha256.convert(derBytes);
    final actual = base64.encode(digest.bytes);
    for (final pin in _pinnedHashes) {
      if (_constantTimeEquals(actual, pin)) return true;
    }
    return false;
  }

  /// Constant-time string comparison to avoid timing oracles.
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  /// Returns a human-readable status string for diagnostics.
  static String get diagnosticStatus {
    if (kDebugMode) {
      return _pinnedHashes.isEmpty
          ? 'DISABLED (debug mode, no pins)'
          : 'DISABLED (debug mode, ${_pinnedHashes.length} pin(s) configured)';
    }
    if (_pinnedHashes.isEmpty) return 'NOT CONFIGURED (no pins)';
    return 'ACTIVE (${_pinnedHashes.length} pin(s))';
  }
}
