import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Certificate pinning service for production security.
///
/// Pins Supabase API server certificates against a list of SHA-256 DER
/// fingerprints so that a MITM presenting a cert whose public-key hash is not
/// on the pin list cannot exchange application data with the app.
///
/// ## How it works (actual guarantees)
///
/// `HttpClient.badCertificateCallback` alone is **not** sufficient — per
/// `dart:io`, that callback only fires for certificates the OS has already
/// rejected. Any cert validly signed by a trusted CA (compromised public CA,
/// MDM-installed root, user CA on Android <=11) is accepted silently and
/// never reaches the callback. A prior revision of this service relied on the
/// callback alone, which meant pinning was effectively a no-op against the
/// exact attacker a pin-set is supposed to stop.
///
/// The release-mode client now defends on two layers:
///
/// 1. **Handshake-time (unchanged):** `badCertificateCallback` only accepts a
///    cert the OS rejected if its fingerprint matches a pin. This catches
///    self-signed and untrusted-chain MITMs.
/// 2. **Post-handshake fingerprint check:** every response is intercepted and
///    the server's `X509Certificate` (exposed via
///    `IOStreamedResponse.inner.certificate`) is SHA-256-fingerprinted and
///    compared to the pin list. On mismatch the response stream is closed and
///    a [HandshakeException] is thrown before the caller ever reads the body
///    or response headers, and `persistentConnection = false` ensures every
///    subsequent request re-handshakes.
///
/// ### Residual risk
///
/// Because the post-handshake check runs after the TLS handshake completes
/// but before the response is returned to callers, the *first request* to a
/// CA-signed MITM may deliver request bytes (including `Authorization`
/// headers) before the pin mismatch is detected. The response is never
/// surfaced, all subsequent requests fail, and the connection is torn down —
/// so the attacker cannot maintain a session, but a single request's payload
/// may leak. For stronger guarantees (block before request bytes are sent),
/// adopt `package:http_certificate_pinning` or move to
/// `SecurityContext(withTrustedRoots: false) + setTrustedCertificatesBytes`
/// with pinned cert DER shipped at build time.
///
/// In **debug** builds pinning is disabled so proxy/inspection tools (Charles,
/// mitmproxy, etc.) continue to work during development.
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

    // Defence layer 1: handshake-time check. Only fires when the OS rejects
    // the cert (self-signed / untrusted chain) — does not catch CA-signed
    // MITMs, which is why layer 2 below is required.
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
          final matches = _matchesPinnedFingerprint(cert);
          if (!matches) {
            debugPrint(
              '[CertificatePinning] REJECTED certificate for $host:$port '
              '(fingerprint mismatch at handshake)',
            );
            return false;
          }
          debugPrint(
            '[CertificatePinning] Accepted pinned certificate for $host:$port '
            '(handshake)',
          );
          return true;
        };

    // Force a fresh TLS handshake per request so the post-handshake pin check
    // runs every call; keep-alive would otherwise let the first accepted
    // connection be reused indefinitely.
    return _PinnedClient(ioClient, _matchesPinnedFingerprint);
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

  /// Exposed for tests: verify a given cert against the statically-resolved
  /// pin list. Mirrors the private [_matchesPinnedFingerprint].
  @visibleForTesting
  static bool verifyCertificateForTest(X509Certificate cert) =>
      _matchesPinnedFingerprint(cert);

  /// Exposed for tests: run the post-handshake pin check against a cert and a
  /// matcher. Mirrors the logic the release-mode client applies on each
  /// response before it returns to the caller. Throws [HandshakeException] on
  /// mismatch or when the server presented no certificate.
  @visibleForTesting
  static void assertCertMatchesForTest({
    required X509Certificate? cert,
    required bool Function(X509Certificate) matcher,
    required String host,
  }) {
    if (cert == null || !matcher(cert)) {
      throw HandshakeException('Certificate pin mismatch for $host');
    }
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

/// HTTP client that checks the server certificate against the pin list after
/// the TLS handshake but before the response is surfaced to the caller.
///
/// We cannot use plain [IOClient] here because the `http` package's
/// [IOStreamedResponse] does not expose the underlying [HttpClientResponse]
/// publicly, so the cert is unreachable through that abstraction. Instead we
/// drive [HttpClient] directly and wrap the response in [http.StreamedResponse]
/// ourselves, with a cert check inserted between `close()` and hand-off.
///
/// On mismatch the socket is destroyed via [HttpClientResponse.detachSocket]
/// and a [HandshakeException] is thrown — neither headers nor body reach the
/// caller, and the connection is terminated so subsequent requests can't reuse
/// it.
class _PinnedClient extends http.BaseClient {
  _PinnedClient(this._httpClient, this._matcher);

  final HttpClient _httpClient;
  final bool Function(X509Certificate) _matcher;
  bool _closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (_closed) {
      throw http.ClientException('Client is already closed.', request.url);
    }

    final ioReq = await _httpClient.openUrl(request.method, request.url);
    ioReq.persistentConnection = false;
    ioReq.followRedirects = request.followRedirects;
    ioReq.maxRedirects = request.maxRedirects;
    request.headers.forEach(ioReq.headers.set);
    final bodyStream = request.finalize();
    if (request.contentLength != null) {
      ioReq.contentLength = request.contentLength!;
    }
    await ioReq.addStream(bodyStream);
    final ioResp = await ioReq.close();

    final cert = ioResp.certificate;
    if (cert == null || !_matcher(cert)) {
      final host = request.url.host;
      final reason = cert == null
          ? 'server presented no certificate'
          : 'fingerprint mismatch';
      debugPrint(
        '[CertificatePinning] REJECTED response from $host ($reason)',
      );
      try {
        final socket = await ioResp.detachSocket();
        socket.destroy();
      } catch (_) {
        // ignore teardown failures; we're already throwing.
      }
      throw HandshakeException('Certificate pin mismatch for $host');
    }

    final headers = <String, String>{};
    ioResp.headers.forEach((name, values) {
      headers[name] = values.join(',');
    });

    return http.StreamedResponse(
      ioResp.cast<List<int>>().handleError((Object err) {
        throw http.ClientException(err.toString(), request.url);
      }),
      ioResp.statusCode,
      contentLength: ioResp.contentLength == -1 ? null : ioResp.contentLength,
      request: request,
      headers: headers,
      isRedirect: ioResp.isRedirect,
      persistentConnection: ioResp.persistentConnection,
      reasonPhrase: ioResp.reasonPhrase,
    );
  }

  @override
  void close() {
    if (_closed) return;
    _closed = true;
    _httpClient.close(force: true);
  }
}
