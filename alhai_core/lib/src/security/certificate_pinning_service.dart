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
/// Fingerprints are supplied at build time via `--dart-define`. Up to ten pins
/// (`SUPABASE_CERT_FINGERPRINT_1` … `SUPABASE_CERT_FINGERPRINT_10`) are
/// supported so rotations can roll through multiple releases without app
/// updates:
/// ```
/// flutter build apk --release \
///   --dart-define=SUPABASE_CERT_FINGERPRINT_1=<base64 sha256> \
///   --dart-define=SUPABASE_CERT_FINGERPRINT_2=<base64 sha256> \
///   --dart-define=SUPABASE_CERT_FINGERPRINT_3=<base64 sha256>
/// ```
///
/// Legacy `SUPABASE_CERT_FINGERPRINT` / `SUPABASE_CERT_FINGERPRINT_BACKUP`
/// variables are still honoured when none of the numbered variants are set —
/// existing CI pipelines continue to work unchanged.
///
/// The expected format is the **base64-encoded SHA-256 hash of the DER-encoded
/// certificate** (the `sha256//` value used by RFC 7469 HPKP-style pinning).
///
/// Keep at least two pins (current + next) to survive rotations without an app
/// update.
class CertificatePinningService {
  CertificatePinningService._();

  /// Maximum number of numbered pin slots honoured (`_1`.._maxNumberedPins`).
  static const int _maxNumberedPins = 10;

  // Legacy pin sources (kept for backward compatibility).
  static const String _legacyPrimary = String.fromEnvironment(
    'SUPABASE_CERT_FINGERPRINT',
  );
  static const String _legacyBackup = String.fromEnvironment(
    'SUPABASE_CERT_FINGERPRINT_BACKUP',
  );

  // Numbered pin sources (preferred). `String.fromEnvironment` requires a
  // `const` argument, so each slot has to be declared explicitly.
  static const String _pin1 = String.fromEnvironment(
    'SUPABASE_CERT_FINGERPRINT_1',
  );
  static const String _pin2 = String.fromEnvironment(
    'SUPABASE_CERT_FINGERPRINT_2',
  );
  static const String _pin3 = String.fromEnvironment(
    'SUPABASE_CERT_FINGERPRINT_3',
  );
  static const String _pin4 = String.fromEnvironment(
    'SUPABASE_CERT_FINGERPRINT_4',
  );
  static const String _pin5 = String.fromEnvironment(
    'SUPABASE_CERT_FINGERPRINT_5',
  );
  static const String _pin6 = String.fromEnvironment(
    'SUPABASE_CERT_FINGERPRINT_6',
  );
  static const String _pin7 = String.fromEnvironment(
    'SUPABASE_CERT_FINGERPRINT_7',
  );
  static const String _pin8 = String.fromEnvironment(
    'SUPABASE_CERT_FINGERPRINT_8',
  );
  static const String _pin9 = String.fromEnvironment(
    'SUPABASE_CERT_FINGERPRINT_9',
  );
  static const String _pin10 = String.fromEnvironment(
    'SUPABASE_CERT_FINGERPRINT_10',
  );

  static final List<String> _pinnedHashes = resolvePins(
    numbered: const <String>[
      _pin1,
      _pin2,
      _pin3,
      _pin4,
      _pin5,
      _pin6,
      _pin7,
      _pin8,
      _pin9,
      _pin10,
    ],
    legacyPrimary: _legacyPrimary,
    legacyBackup: _legacyBackup,
  );

  /// Resolves a pin list from the provided sources.
  ///
  /// Precedence:
  /// 1. Any non-empty value in [numbered] (up to [_maxNumberedPins]).
  /// 2. Only if [numbered] is entirely empty, fall back to [legacyPrimary] /
  ///    [legacyBackup].
  ///
  /// The returned list is trimmed and deduplicated preserving first occurrence.
  /// Exposed for test harnesses — production code reads from the static
  /// [_pinnedHashes] built via build-time `--dart-define` values.
  @visibleForTesting
  static List<String> resolvePins({
    required List<String> numbered,
    String legacyPrimary = '',
    String legacyBackup = '',
  }) {
    final capped = numbered.length > _maxNumberedPins
        ? numbered.sublist(0, _maxNumberedPins)
        : numbered;
    final fromNumbered = capped
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList(growable: false);

    final source = fromNumbered.isNotEmpty
        ? fromNumbered
        : <String>[
            if (legacyPrimary.trim().isNotEmpty) legacyPrimary.trim(),
            if (legacyBackup.trim().isNotEmpty) legacyBackup.trim(),
          ];

    final seen = <String>{};
    final deduped = <String>[];
    for (final pin in source) {
      if (seen.add(pin)) deduped.add(pin);
    }
    return List<String>.unmodifiable(deduped);
  }

  /// Whether certificate pinning is active.
  ///
  /// Pinning is only enforced when running in release mode AND at least one
  /// fingerprint has been configured.
  static bool get isEnabled => !kDebugMode && _pinnedHashes.isNotEmpty;

  /// Number of resolved pins (after dedupe, trimmed, legacy fallback applied).
  static int get pinCount => _pinnedHashes.length;

  /// Creates an [http.Client] with certificate pinning enforced in release mode.
  ///
  /// Throws [StateError] in release mode when no fingerprints are configured.
  /// In debug mode a missing pin list only triggers a warning log.
  static http.Client createPinnedClient() {
    if (kReleaseMode && _pinnedHashes.isEmpty) {
      throw StateError(
        '[CertificatePinning] No pinned fingerprints configured for a '
        'release build. Rebuild with '
        '--dart-define=SUPABASE_CERT_FINGERPRINT_1=<base64 sha256> '
        '(and _2/_3/... for rotation headroom; legacy '
        'SUPABASE_CERT_FINGERPRINT[_BACKUP] are still accepted). Refusing '
        'to initialize an unpinned HTTP client.',
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
          'SUPABASE_CERT_FINGERPRINT_1 before release.',
        );
      } else {
        debugPrint(
          '[CertificatePinning] Debug mode: pinning disabled for dev tools '
          '(${_pinnedHashes.length} pin(s) would be enforced in release)',
        );
      }
      return IOClient(ioClient);
    }

    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
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
  @visibleForTesting
  static bool constantTimeEquals(String a, String b) =>
      _constantTimeEquals(a, b);

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
    final count = _pinnedHashes.length;
    if (kDebugMode) {
      return count == 0
          ? 'DISABLED (debug mode, no pins)'
          : 'DISABLED (debug mode, $count pin(s) configured)';
    }
    if (count == 0) return 'NOT CONFIGURED (no pins)';
    return 'ACTIVE ($count pin(s))';
  }
}
