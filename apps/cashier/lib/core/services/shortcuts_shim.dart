/// Phase 4.5 — ShortcutsShim: tiny static toggle that controls whether the
/// cashier-level keyboard-shortcut bindings are active.
///
/// Keyboard shortcuts are built into [CashierShell] and the POS screen via
/// [CallbackShortcuts]. A cashier on a touchscreen-only till may prefer to
/// disable them entirely (the `+` and `-` keys in particular can collide with
/// a connected barcode scanner that emits a trailing character). This flag
/// lets the shell short-circuit the `bindings` map to an empty one when OFF
/// without tearing down the widget tree.
///
/// The flag lives here (not on a Riverpod provider) for the same reason as
/// [HapticShim] — shared packages need to read it without pulling cashier-app
/// imports, and there is only ever one value per process.
///
/// Persistence: [kPrefKeyboardShortcutsEnabled] in SharedPreferences; default
/// true (shortcuts ON — the cashier is assumed to be a desktop power user).
library;

class ShortcutsShim {
  /// SharedPreferences key. Kept next to the shim so both the settings UI and
  /// the shell agree on the name.
  static const String prefKey = 'settings_keyboard_shortcuts_enabled';

  /// Global on/off flag. Toggled from the settings screen.
  static bool enabled = true;

  /// Load persisted value. Call from main() after SharedPreferences is ready.
  static void loadFromPrefs(bool? v) {
    if (v != null) enabled = v;
  }
}

/// Convenience export — the settings screen writes with this name and main.dart
/// reads with this name, avoiding the "stringly-typed" pref-key drift that
/// bit us earlier with haptic/sound keys.
const String kPrefKeyboardShortcutsEnabled = ShortcutsShim.prefKey;
