/// Test app wrapper with mocked dependencies for customer app integration tests.
///
/// Provides a [buildCustomerTestApp] function that creates a fully-configured
/// CustomerApp wrapped in a ProviderScope with mock overrides, bypassing
/// real Supabase initialization.
///
/// Usage:
///   await tester.pumpWidget(buildCustomerTestApp());
///   await tester.pumpAndSettle();
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

// ============================================================================
// TEST APP BUILDER
// ============================================================================

/// Builds a test version of the CustomerApp with controllable provider overrides.
///
/// Parameters:
/// - [initialRoute]: The route to start at (defaults to '/home').
/// - [overrides]: Additional Riverpod provider overrides.
Widget buildCustomerTestApp({
  String initialRoute = '/home',
  List<Override> overrides = const [],
}) {
  final router = GoRouter(
    initialLocation: initialRoute,
    routes: [
      // Auth routes
      GoRoute(
        path: '/',
        builder: (_, __) => const _StubScreen(label: 'Splash'),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (_, __) => const _StubScreen(label: 'Login'),
      ),
      GoRoute(
        path: '/auth/otp',
        builder: (_, state) => _StubScreen(label: 'OTP ${state.extra ?? ""}'),
      ),

      // Main app routes (using stubs since real screens have deep DI deps)
      GoRoute(
        path: '/home',
        builder: (_, __) => const _StubScreen(label: 'Home'),
      ),
      GoRoute(
        path: '/catalog',
        builder: (_, __) => const _StubScreen(label: 'Catalog'),
      ),
      GoRoute(
        path: '/products/:id',
        builder: (_, state) =>
            _StubScreen(label: 'Product ${state.pathParameters["id"]}'),
      ),
      GoRoute(
        path: '/search',
        builder: (_, __) => const _StubScreen(label: 'Search'),
      ),
      GoRoute(
        path: '/cart',
        builder: (_, __) => const _StubScreen(label: 'Cart'),
      ),
      GoRoute(
        path: '/checkout',
        builder: (_, __) => const _StubScreen(label: 'Checkout'),
      ),
      GoRoute(
        path: '/orders',
        builder: (_, __) => const _StubScreen(label: 'Orders'),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (_, state) =>
            _StubScreen(label: 'Order ${state.pathParameters["id"]}'),
      ),
      GoRoute(
        path: '/orders/:id/track',
        builder: (_, state) =>
            _StubScreen(label: 'Track ${state.pathParameters["id"]}'),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const _StubScreen(label: 'Profile'),
      ),
      GoRoute(
        path: '/profile/addresses',
        builder: (_, __) => const _StubScreen(label: 'Addresses'),
      ),
      GoRoute(
        path: '/profile/settings',
        builder: (_, __) => const _StubScreen(label: 'Settings'),
      ),
      GoRoute(
        path: '/stores/nearby',
        builder: (_, __) => const _StubScreen(label: 'Nearby Stores'),
      ),
    ],
  );

  return ProviderScope(
    overrides: [...overrides],
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AlhaiTheme.light,
      darkTheme: AlhaiTheme.dark,
      themeMode: ThemeMode.light,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    ),
  );
}

// ============================================================================
// STUB SCREEN
// ============================================================================

/// Minimal placeholder screen for routes not under direct test.
/// Renders a centered label with a key so tests can verify navigation.
class _StubScreen extends StatelessWidget {
  final String label;
  const _StubScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(label, key: Key('stub_$label'))),
    );
  }
}

// ============================================================================
// TEST UTILITIES
// ============================================================================

/// Pumps the widget tree and waits for all animations to settle.
Future<void> pumpAndSettleWithTimeout(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    timeout,
  );
}

/// Helper to tap a widget found by text.
Future<void> tapByText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

/// Helper to tap a widget found by icon.
Future<void> tapByIcon(WidgetTester tester, IconData icon) async {
  final finder = find.byIcon(icon);
  await tester.ensureVisible(finder);
  await tester.tap(finder.first);
  await tester.pump();
}

/// Verify that a stub screen is displayed with the expected label.
void expectStubScreen(String label) {
  expect(find.byKey(Key('stub_$label')), findsOneWidget);
}
