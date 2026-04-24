/// Phase 4.5 — small process-global controller that lets non-POS widgets
/// (e.g. the cashier shell's keyboard-shortcut scope) ask the currently
/// mounted [PosScreen] to focus one of its internal [FocusNode]s without
/// exposing those nodes directly.
///
/// The POS screen registers callbacks in `initState` and clears them in
/// `dispose`. Outside callers (e.g. `cashier_shell.dart`) call
/// `PosFocusController.requestSearchFocus()`; when the POS is not mounted the
/// call is a silent no-op (the shortcut still works, it just has nothing to
/// focus).
///
/// Why a singleton and not a Riverpod provider?
///
/// - The focus nodes live on a mutable [StatefulWidget] state — wrapping them
///   in a provider would force every rebuild to re-register, which defeats
///   the purpose.
/// - Shortcuts need to fire synchronously from a `VoidCallback` inside
///   `CallbackShortcuts`. A provider lookup works, but a static field is
///   simpler and matches the existing pattern used by [ShortcutsShim] /
///   [HapticShim] in the cashier app.
/// - There is only ever one POS screen mounted at a time (GoRouter keeps it
///   alive inside the ShellRoute). If a second instance ever registers, the
///   later one wins — which is the correct behaviour for a focus shortcut.
library;

/// Controller exposing focus hooks from [PosScreen] to the cashier shell.
///
/// All callbacks are nullable and default to no-ops; the POS screen assigns
/// them on mount and clears them on unmount. Shell code should always use the
/// public `requestXxx()` helpers rather than reading the fields directly, so
/// a future refactor to a provider-based approach stays backwards-compatible.
class PosFocusController {
  PosFocusController._();

  /// Callback that asks the POS screen to focus its product-search field.
  /// Assigned by `PosScreen.initState`, cleared by `dispose`.
  static void Function()? _searchFocusRequester;

  /// Register a search-focus callback. Called from `PosScreen.initState`.
  static void registerSearchFocus(void Function() requester) {
    _searchFocusRequester = requester;
  }

  /// Clear the search-focus callback. Called from `PosScreen.dispose` so we
  /// don't hold a reference to a disposed [State].
  static void clearSearchFocus() {
    _searchFocusRequester = null;
  }

  /// Ask the currently-mounted POS screen to focus its search field. No-op
  /// when no POS is mounted (e.g. the cashier is on /sales). Returns `true`
  /// when a handler was registered and invoked, `false` otherwise — callers
  /// can use this to decide whether to fall back to a route-level action.
  static bool requestSearchFocus() {
    final requester = _searchFocusRequester;
    if (requester == null) return false;
    requester();
    return true;
  }
}
