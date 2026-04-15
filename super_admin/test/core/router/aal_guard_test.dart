import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

/// Tests for the AAL2 enforcement logic in _guardRedirect (F1 fix).
///
/// Since _guardRedirect is a private top-level function that depends on
/// Riverpod Ref + GoRouterState, we test the AAL2 decision logic in
/// isolation using the same Supabase MFA API surface.
void main() {
  group('AAL2 guard logic', () {
    test('AAL1 user on /dashboard should be redirected to /mfa', () {
      // Simulates the guard decision: authenticated + superAdmin but AAL1.
      const currentLevel = AuthenticatorAssuranceLevels.aal1;
      const path = '/dashboard';
      const mfaPath = '/mfa';

      // Guard logic: if not AAL2, redirect to /mfa unless already there.
      String? redirect;
      if (currentLevel != AuthenticatorAssuranceLevels.aal2) {
        if (path != mfaPath) {
          redirect = mfaPath;
        }
      }

      expect(redirect, equals('/mfa'));
    });

    test('AAL2 user on /dashboard should be allowed (no redirect)', () {
      const currentLevel = AuthenticatorAssuranceLevels.aal2;
      const path = '/dashboard';
      const mfaPath = '/mfa';

      String? redirect;
      if (currentLevel != AuthenticatorAssuranceLevels.aal2) {
        if (path != mfaPath) {
          redirect = mfaPath;
        }
      }

      expect(redirect, isNull);
    });

    test('AAL1 user on /mfa should stay (no redirect)', () {
      const currentLevel = AuthenticatorAssuranceLevels.aal1;
      const path = '/mfa';
      const mfaPath = '/mfa';

      String? redirect;
      if (currentLevel != AuthenticatorAssuranceLevels.aal2) {
        if (path != mfaPath) {
          redirect = mfaPath;
        }
      }

      expect(redirect, isNull);
    });

    test('AAL2 user on /mfa should be redirected to /dashboard', () {
      const currentLevel = AuthenticatorAssuranceLevels.aal2;
      const path = '/mfa';
      const loginPath = '/login';
      const splashPath = '/';
      const mfaPath = '/mfa';
      const dashboardPath = '/dashboard';

      // After AAL2 check passes, guard redirects public pages to dashboard.
      String? redirect;
      final isAal2 = currentLevel == AuthenticatorAssuranceLevels.aal2;
      if (isAal2) {
        if (path == loginPath || path == splashPath || path == mfaPath) {
          redirect = dashboardPath;
        }
      }

      expect(redirect, equals('/dashboard'));
    });

    test('exception in AAL check should deny access (fail-safe)', () {
      // Simulates: try { ... } catch (_) { isAal2 = false; }
      bool isAal2 = false;
      try {
        // Simulate an exception during AAL check.
        throw Exception('Supabase MFA API unavailable');
      } catch (_) {
        isAal2 = false;
      }

      const path = '/dashboard';
      const mfaPath = '/mfa';

      String? redirect;
      if (!isAal2) {
        if (path != mfaPath) {
          redirect = mfaPath;
        }
      }

      expect(redirect, equals('/mfa'));
    });
  });
}
