/// Test app wrapper with mocked dependencies for driver app integration tests.
///
/// Provides a [buildDriverTestApp] function that creates a fully-configured
/// driver app wrapped in a ProviderScope with mock overrides, bypassing
/// real Supabase initialization and deep DI dependencies.
///
/// Usage:
///   await tester.pumpWidget(buildDriverTestApp());
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

/// Builds a test version of the driver app with controllable provider overrides.
///
/// Parameters:
/// - [initialRoute]: The route to start at (defaults to '/home').
/// - [overrides]: Additional Riverpod provider overrides.
Widget buildDriverTestApp({
  String initialRoute = '/home',
  List<Override> overrides = const [],
}) {
  final router = GoRouter(
    initialLocation: initialRoute,
    routes: [
      // ── Auth routes ──────────────────────────────────────────────────
      GoRoute(
        path: '/',
        builder: (_, __) => const _StubScreen(label: 'Splash'),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const _StubScreen(label: 'Login'),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (_, __) => const _StubScreen(label: 'Profile Setup'),
      ),

      // ── Main tab routes ──────────────────────────────────────────────
      GoRoute(
        path: '/home',
        builder: (_, __) => const _StubScreen(label: 'Home'),
      ),
      GoRoute(
        path: '/deliveries',
        builder: (_, __) => const _StubScreen(label: 'Deliveries'),
      ),
      GoRoute(
        path: '/earnings',
        builder: (_, __) => const _StubScreen(label: 'Earnings'),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const _StubScreen(label: 'Profile'),
      ),

      // ── Full-screen detail routes ────────────────────────────────────
      GoRoute(
        path: '/orders/new',
        builder: (_, __) => const _StubScreen(label: 'New Order'),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (_, state) =>
            _StubScreen(label: 'Order ${state.pathParameters["id"]}'),
      ),
      GoRoute(
        path: '/orders/:id/navigate',
        builder: (_, state) =>
            _StubScreen(label: 'Navigate ${state.pathParameters["id"]}'),
      ),
      GoRoute(
        path: '/orders/:id/pickup-otp',
        builder: (_, state) =>
            _StubScreen(label: 'Pickup OTP ${state.pathParameters["id"]}'),
      ),
      GoRoute(
        path: '/orders/:id/proof',
        builder: (_, state) =>
            _StubScreen(label: 'Proof ${state.pathParameters["id"]}'),
      ),
      GoRoute(
        path: '/chat/:orderId',
        builder: (_, state) =>
            _StubScreen(label: 'Chat ${state.pathParameters["orderId"]}'),
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
