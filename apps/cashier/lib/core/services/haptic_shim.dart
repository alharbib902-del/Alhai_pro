/// HapticShim - Wrapper around [HapticFeedback] that respects a user
/// preference toggle.
///
/// The shim is intentionally a pure static class (no DI, no Riverpod) so it
/// can be called from any layer including shared packages without pulling
/// cashier-app-specific imports.
///
/// `enabled` is mirrored to/from [SharedPreferences] under the key
/// `settings_haptic_enabled` by [CashierSettingsScreen]. It defaults to
/// `true` (haptic is ON by default). When disabled, every method is a no-op
/// so callers need not branch.
///
/// Additional hardening:
///   * All calls are wrapped in `try/catch`. On platforms where the haptic
///     channel is unavailable (headless test, old desktop engine, some web
///     browsers) a failure is swallowed silently instead of crashing the UI.
///   * No calls are attempted on `kIsWeb` except `selectionClick` — most
///     browsers ignore others anyway, and some log noisy channel errors.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class HapticShim {
  /// Global on/off flag. Toggled from the Feedback section in settings.
  /// Persisted via SharedPreferences; default true.
  static bool enabled = true;

  /// Load persisted value. Call from main() after SharedPreferences is ready.
  static void loadFromPrefs(bool? v) {
    if (v != null) enabled = v;
  }

  static void lightImpact() {
    if (!enabled) return;
    try {
      HapticFeedback.lightImpact();
    } catch (_) {
      // Swallow: haptics unavailable on this platform (headless/web/desktop).
    }
  }

  static void mediumImpact() {
    if (!enabled) return;
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  static void heavyImpact() {
    if (!enabled) return;
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  static void selectionClick() {
    if (!enabled) return;
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Longer "error" vibrate. On web we fall back to a selection click
  /// because `vibrate` is often a no-op in browsers.
  static void vibrate() {
    if (!enabled) return;
    try {
      if (kIsWeb) {
        HapticFeedback.selectionClick();
      } else {
        HapticFeedback.vibrate();
      }
    } catch (_) {}
  }
}
