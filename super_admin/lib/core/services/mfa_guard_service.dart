import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized MFA / AAL2 verification helper.
///
/// The Super Admin app enforces Multi-Factor Authentication on every
/// privileged route. Supabase exposes the current Authenticator Assurance
/// Level (AAL) on the session; an AAL of `aal2` means the user has completed
/// TOTP verification in this session.
///
/// Previously this logic was duplicated in `app_router.dart` and
/// `sa_login_screen.dart`. This helper centralizes it so both call sites
/// (and any future guard) share identical fail-safe behavior.
class MfaGuardService {
  /// Returns `true` iff the client's current session is at AAL2.
  ///
  /// Fail-safe: any exception (SDK not wired, session stale, AAL API
  /// unavailable) resolves to `false` so callers deny access by default.
  static bool isAAL2(SupabaseClient client) {
    try {
      final aal = client.auth.mfa.getAuthenticatorAssuranceLevel();
      return aal.currentLevel == AuthenticatorAssuranceLevels.aal2;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('MfaGuardService.isAAL2: failed to read AAL — $e');
      }
      return false;
    }
  }

  /// Returns `true` iff the user still needs to complete MFA (below AAL2).
  ///
  /// If the AAL API throws — e.g. the Supabase project does not have MFA
  /// enabled — this returns `true` so the UI routes the user to the MFA
  /// screen which shows an appropriate message.
  static bool requiresMfa(SupabaseClient client) {
    try {
      final aal = client.auth.mfa.getAuthenticatorAssuranceLevel();
      return aal.currentLevel != AuthenticatorAssuranceLevels.aal2;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('MfaGuardService.requiresMfa: failed to read AAL — $e');
      }
      return true;
    }
  }

  /// Defense-in-depth guard for privileged mutations.
  ///
  /// Call before any super-admin mutation (update/delete/privileged RPC).
  /// The GoRouter redirect already enforces AAL2 on navigation, but a
  /// widget already mounted when the session's AAL drops to aal1 would
  /// only be re-guarded on the next navigation event. This method-level
  /// check plugs that window.
  ///
  /// Throws [MfaRequiredException] if the session is not AAL2 — callers
  /// let it propagate so the top-level error boundary can route to /mfa.
  static void requireAAL2(SupabaseClient client) {
    if (!isAAL2(client)) {
      throw const MfaRequiredException(
        'This action requires recent multi-factor authentication. '
        'Please complete MFA verification and try again.',
      );
    }
  }
}

/// Thrown by [MfaGuardService.requireAAL2] when the current session is
/// below AAL2. The top-level error boundary should catch this and redirect
/// the user to the MFA screen.
class MfaRequiredException implements Exception {
  final String message;
  const MfaRequiredException(this.message);

  @override
  String toString() => 'MfaRequiredException: $message';
}
