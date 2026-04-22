/// Per-device receipt-number suffix (C-1).
///
/// Two devices in the same store working offline used to each see their
/// own local `todayCount` and both generate `POS-YYYYMMDD-NNNN` with the
/// same NNNN, then collide on the Supabase unique index when the second
/// one syncs. Adding a random 4-hex-char suffix per device to the
/// receipt format breaks the collision by construction, no server
/// coordination required.
///
/// The suffix is generated once on first use (`Random.secure()`,
/// 16 random bits = 65 536 possibilities) and persisted to
/// SharedPreferences under a versioned key. Stable across app restarts,
/// regenerated only on a fresh install. Collision probability for a
/// store with N devices is `N*(N-1)/2 / 65 536` — for a typical 2-5
/// terminal store that's \~0.001-0.015%, effectively zero.
library;

import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Stable 4-hex-char per-device suffix, persisted in SharedPreferences.
///
/// Inject this into [SaleService] so receipt numbers on different
/// devices cannot collide even when both are offline. Tests can
/// substitute a subclass or set `SharedPreferences.setMockInitialValues`
/// with a fixed payload.
class TerminalSuffixService {
  /// SharedPreferences key. Versioned so future format changes can be
  /// introduced without re-reading a stale value.
  static const String prefsKey = 'pos.terminal.suffix.v1';

  /// Matches the canonical suffix shape: four lowercase hex characters.
  static final RegExp _suffixPattern = RegExp(r'^[0-9a-f]{4}$');

  final Random _random;

  /// In-process cache so the first read after boot is async and the rest
  /// are synchronous-ish (still wrapped in Future for API uniformity).
  String? _cached;

  TerminalSuffixService({Random? random})
    : _random = random ?? Random.secure();

  /// Returns the suffix for this device.
  ///
  /// On first call: reads from SharedPreferences. If absent or malformed,
  /// generates a fresh 4-hex-char suffix via [Random.secure] and
  /// persists it. Subsequent calls are cached in-process and return
  /// synchronously via `Future.value`.
  ///
  /// If SharedPreferences is unavailable (widget-test without binding,
  /// headless contexts), falls back to an in-memory generated suffix
  /// that is stable for this process's lifetime. Persistence is
  /// best-effort; the caller never sees an error.
  Future<String> getSuffix() async {
    final cached = _cached;
    if (cached != null) return cached;

    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(prefsKey);
      if (stored != null && _suffixPattern.hasMatch(stored)) {
        _cached = stored;
        return stored;
      }
      final generated = _generate();
      await prefs.setString(prefsKey, generated);
      _cached = generated;
      return generated;
    } catch (_) {
      // SharedPreferences unavailable — fall back to process-scoped
      // suffix. The badge/receipt still prints; next cold-start may pick
      // a different suffix, but within one session receipts from this
      // instance are consistent, which is what the collision-guard
      // actually needs.
      final fallback = _generate();
      _cached = fallback;
      return fallback;
    }
  }

  String _generate() =>
      _random.nextInt(0x10000).toRadixString(16).padLeft(4, '0');
}
