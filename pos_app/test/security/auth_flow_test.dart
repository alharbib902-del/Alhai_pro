import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/providers/auth_providers.dart';

void main() {
  group('Auth Providers Tests', () {
    group('AuthStatus', () {
      test('should have all required values', () {
        expect(AuthStatus.values.length, 4);
        expect(AuthStatus.values.contains(AuthStatus.unknown), true);
        expect(AuthStatus.values.contains(AuthStatus.authenticated), true);
        expect(AuthStatus.values.contains(AuthStatus.unauthenticated), true);
        expect(AuthStatus.values.contains(AuthStatus.sessionExpired), true);
      });
    });

    group('AuthState', () {
      test('should have default values', () {
        const state = AuthState();
        
        expect(state.status, AuthStatus.unknown);
        expect(state.user, null);
        expect(state.error, null);
        expect(state.sessionExpiry, null);
      });

      test('should calculate isAuthenticated correctly', () {
        const authenticatedState = AuthState(status: AuthStatus.authenticated);
        const unauthenticatedState = AuthState(status: AuthStatus.unauthenticated);
        
        expect(authenticatedState.isAuthenticated, true);
        expect(unauthenticatedState.isAuthenticated, false);
      });

      test('should calculate isLoading correctly', () {
        const unknownState = AuthState(status: AuthStatus.unknown);
        const authenticatedState = AuthState(status: AuthStatus.authenticated);
        
        expect(unknownState.isLoading, true);
        expect(authenticatedState.isLoading, false);
      });

      test('should calculate isSessionExpired correctly', () {
        const expiredState = AuthState(status: AuthStatus.sessionExpired);
        const validState = AuthState(status: AuthStatus.authenticated);
        
        expect(expiredState.isSessionExpired, true);
        expect(validState.isSessionExpired, false);
      });

      test('should calculate isSessionValid correctly', () {
        final validState = AuthState(
          status: AuthStatus.authenticated,
          sessionExpiry: DateTime.now().add(const Duration(hours: 1)),
        );
        
        final expiredState = AuthState(
          status: AuthStatus.authenticated,
          sessionExpiry: DateTime.now().subtract(const Duration(hours: 1)),
        );
        
        const noExpiryState = AuthState(status: AuthStatus.authenticated);
        
        expect(validState.isSessionValid, true);
        expect(expiredState.isSessionValid, false);
        expect(noExpiryState.isSessionValid, false);
      });

      test('should calculate needsRefresh correctly', () {
        // يحتاج تجديد (أقل من 5 دقائق للانتهاء)
        final needsRefreshState = AuthState(
          status: AuthStatus.authenticated,
          sessionExpiry: DateTime.now().add(const Duration(minutes: 3)),
        );
        
        // لا يحتاج تجديد (أكثر من 5 دقائق للانتهاء)
        final noRefreshState = AuthState(
          status: AuthStatus.authenticated,
          sessionExpiry: DateTime.now().add(const Duration(minutes: 10)),
        );
        
        expect(needsRefreshState.needsRefresh, true);
        expect(noRefreshState.needsRefresh, false);
      });

      test('copyWith should work correctly', () {
        const state = AuthState(
          status: AuthStatus.unknown,
          error: 'test error',
        );
        
        final newState = state.copyWith(
          status: AuthStatus.authenticated,
          clearError: true,
        );
        
        expect(newState.status, AuthStatus.authenticated);
        expect(newState.error, null);
      });
    });

    group('Constants', () {
      test('session duration should be 30 minutes', () {
        expect(kSessionDuration, const Duration(minutes: 30));
      });

      test('token refresh buffer should be 5 minutes', () {
        expect(kTokenRefreshBuffer, const Duration(minutes: 5));
      });
    });
  });
}
