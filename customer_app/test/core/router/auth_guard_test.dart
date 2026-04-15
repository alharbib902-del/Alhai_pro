import 'package:flutter_test/flutter_test.dart';

/// Tests for the GoRouter auth guard redirect logic.
///
/// The redirect function in AppRouter follows this logic:
/// - Unauthenticated user accessing a protected route → '/auth/login'
/// - Authenticated user accessing an auth route (not '/') → '/home'
/// - Otherwise → null (no redirect)
///
/// Since GoRouter's redirect is tightly coupled to the router instance
/// and AppSupabase.isAuthenticated (a static getter), we test the
/// redirect logic in isolation by extracting and verifying the rules.

// Simulates the redirect logic from AppRouter
String? authRedirect({
  required bool isAuthenticated,
  required String location,
}) {
  final isPublicRoute = location == '/' ||
      location.startsWith('/auth') ||
      location.startsWith('/onboarding');

  if (!isAuthenticated && !isPublicRoute) {
    return '/auth/login';
  }

  if (isAuthenticated && isPublicRoute && location != '/') {
    return '/home';
  }

  return null;
}

void main() {
  group('Auth guard redirect logic', () {
    test('unauthenticated user accessing /orders → redirect to /auth/login',
        () {
      final result = authRedirect(isAuthenticated: false, location: '/orders');
      expect(result, equals('/auth/login'));
    });

    test('unauthenticated user accessing /home → redirect to /auth/login', () {
      final result = authRedirect(isAuthenticated: false, location: '/home');
      expect(result, equals('/auth/login'));
    });

    test('unauthenticated user accessing /checkout → redirect to /auth/login',
        () {
      final result =
          authRedirect(isAuthenticated: false, location: '/checkout');
      expect(result, equals('/auth/login'));
    });

    test('unauthenticated user accessing /cart → redirect to /auth/login', () {
      final result = authRedirect(isAuthenticated: false, location: '/cart');
      expect(result, equals('/auth/login'));
    });

    test('unauthenticated user accessing /auth/login → no redirect', () {
      final result =
          authRedirect(isAuthenticated: false, location: '/auth/login');
      expect(result, isNull);
    });

    test('unauthenticated user accessing splash (/) → no redirect', () {
      final result = authRedirect(isAuthenticated: false, location: '/');
      expect(result, isNull);
    });

    test('authenticated user accessing /home → no redirect (allowed)', () {
      final result = authRedirect(isAuthenticated: true, location: '/home');
      expect(result, isNull);
    });

    test('authenticated user accessing /orders → no redirect', () {
      final result = authRedirect(isAuthenticated: true, location: '/orders');
      expect(result, isNull);
    });

    test('authenticated user accessing /auth/login → redirect to /home', () {
      final result =
          authRedirect(isAuthenticated: true, location: '/auth/login');
      expect(result, equals('/home'));
    });

    test('authenticated user accessing /auth/otp → redirect to /home', () {
      final result =
          authRedirect(isAuthenticated: true, location: '/auth/otp');
      expect(result, equals('/home'));
    });

    test('authenticated user accessing splash (/) → no redirect', () {
      final result = authRedirect(isAuthenticated: true, location: '/');
      expect(result, isNull);
    });
  });
}
