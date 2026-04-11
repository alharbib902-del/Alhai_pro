import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_auth/alhai_auth.dart';

void main() {
  group('AuthStatus', () {
    test('has all expected values', () {
      expect(
        AuthStatus.values,
        containsAll([
          AuthStatus.unknown,
          AuthStatus.authenticated,
          AuthStatus.unauthenticated,
          AuthStatus.sessionExpired,
        ]),
      );
    });
  });

  group('AuthState', () {
    test('default state has unknown status', () {
      const state = AuthState();
      expect(state.status, equals(AuthStatus.unknown));
      expect(state.user, isNull);
      expect(state.error, isNull);
      expect(state.sessionExpiry, isNull);
    });

    test('isAuthenticated returns true for authenticated status', () {
      const state = AuthState(status: AuthStatus.authenticated);
      expect(state.isAuthenticated, isTrue);
    });

    test('isAuthenticated returns false for unauthenticated status', () {
      const state = AuthState(status: AuthStatus.unauthenticated);
      expect(state.isAuthenticated, isFalse);
    });

    test('isLoading returns true for unknown status', () {
      const state = AuthState();
      expect(state.isLoading, isTrue);
    });

    test('isSessionExpired returns true for sessionExpired status', () {
      const state = AuthState(status: AuthStatus.sessionExpired);
      expect(state.isSessionExpired, isTrue);
    });

    test('isSessionValid returns false when no expiry', () {
      const state = AuthState(status: AuthStatus.authenticated);
      expect(state.isSessionValid, isFalse);
    });

    test('isSessionValid returns true when expiry is in the future', () {
      final state = AuthState(
        status: AuthStatus.authenticated,
        sessionExpiry: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(state.isSessionValid, isTrue);
    });

    test('isSessionValid returns false when expiry is in the past', () {
      final state = AuthState(
        status: AuthStatus.authenticated,
        sessionExpiry: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(state.isSessionValid, isFalse);
    });

    test('needsRefresh returns true when no expiry', () {
      const state = AuthState(status: AuthStatus.authenticated);
      expect(state.needsRefresh, isTrue);
    });

    test('needsRefresh returns false when expiry is far in the future', () {
      final state = AuthState(
        status: AuthStatus.authenticated,
        sessionExpiry: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(state.needsRefresh, isFalse);
    });

    test('needsRefresh returns true when within refresh buffer', () {
      final state = AuthState(
        status: AuthStatus.authenticated,
        sessionExpiry: DateTime.now().add(const Duration(minutes: 3)),
      );
      // kTokenRefreshBuffer is 5 minutes, so 3 min remaining should need refresh
      expect(state.needsRefresh, isTrue);
    });

    group('copyWith', () {
      test('preserves existing values when not overridden', () {
        final original = AuthState(
          status: AuthStatus.authenticated,
          error: 'some error',
          sessionExpiry: DateTime.now(),
        );

        final copy = original.copyWith();
        expect(copy.status, equals(original.status));
        expect(copy.error, equals(original.error));
        expect(copy.sessionExpiry, equals(original.sessionExpiry));
      });

      test('overrides specified values', () {
        const original = AuthState(status: AuthStatus.unknown);
        final copy = original.copyWith(status: AuthStatus.authenticated);
        expect(copy.status, equals(AuthStatus.authenticated));
      });

      test('clearError removes error', () {
        const original = AuthState(
          status: AuthStatus.unauthenticated,
          error: 'failed',
        );
        final copy = original.copyWith(clearError: true);
        expect(copy.error, isNull);
      });

      test('clearUser removes user', () {
        const original = AuthState(status: AuthStatus.authenticated);
        final copy = original.copyWith(clearUser: true);
        expect(copy.user, isNull);
      });
    });
  });

  group('SessionStatus', () {
    test('has all expected values', () {
      expect(
        SessionStatus.values,
        containsAll([
          SessionStatus.valid,
          SessionStatus.needsRefresh,
          SessionStatus.expired,
          SessionStatus.notAuthenticated,
        ]),
      );
    });
  });
}
