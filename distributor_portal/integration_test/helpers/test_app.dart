/// Test app wrapper with mocked dependencies for distributor portal integration tests.
///
/// Provides a [buildDistributorTestApp] function that creates a fully-configured
/// DistributorPortal wrapped in a ProviderScope with mock overrides, bypassing
/// real Supabase initialization and deferred-loaded screens.
///
/// All routes use lightweight [_StubScreen] widgets keyed by label so tests
/// can verify navigation without pulling in real screen dependencies.
///
/// Usage:
///   await tester.pumpWidget(buildDistributorTestApp());
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

/// Builds a test version of the DistributorPortal with controllable provider
/// overrides and a GoRouter using stub screens for every route.
///
/// Parameters:
/// - [initialRoute]: The route to start at (defaults to '/dashboard').
/// - [overrides]: Additional Riverpod provider overrides.
Widget buildDistributorTestApp({
  String initialRoute = '/dashboard',
  List<Override> overrides = const [],
}) {
  final router = GoRouter(
    initialLocation: initialRoute,
    routes: [
      // ====================================================================
      // Public / auth routes
      // ====================================================================
      GoRoute(
        path: '/login',
        builder: (_, __) => const _StubScreen(label: 'Login'),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const _StubScreen(label: 'Signup'),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (_, state) {
          final email = state.extra as String?;
          return _StubScreen(
            label: 'Verify Email${email != null ? ' $email' : ''}',
          );
        },
      ),
      GoRoute(
        path: '/mfa-verify',
        builder: (_, state) {
          final factorId = state.extra as String? ?? '';
          return _StubScreen(
            label: 'MFA Verify${factorId.isNotEmpty ? ' $factorId' : ''}',
          );
        },
      ),
      GoRoute(
        path: '/mfa-enroll',
        builder: (_, state) {
          final forced = state.extra as bool? ?? false;
          return _StubScreen(label: 'MFA Enroll${forced ? ' forced' : ''}');
        },
      ),

      // ====================================================================
      // Protected routes (would normally live inside ShellRoute)
      // Using flat routes with stubs to avoid DistributorShell DI.
      // ====================================================================
      GoRoute(
        path: '/dashboard',
        builder: (_, __) => const _StubScreen(label: 'Dashboard'),
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
        path: '/invoices',
        builder: (_, __) => const _StubScreen(label: 'Invoices'),
      ),
      GoRoute(
        path: '/invoices/:id',
        builder: (_, state) =>
            _StubScreen(label: 'Invoice ${state.pathParameters["id"]}'),
      ),
      GoRoute(
        path: '/products',
        builder: (_, __) => const _StubScreen(label: 'Products'),
      ),
      GoRoute(
        path: '/pricing',
        builder: (_, __) => const _StubScreen(label: 'Pricing'),
      ),
      GoRoute(
        path: '/pricing-tiers',
        builder: (_, __) => const _StubScreen(label: 'Pricing Tiers'),
      ),
      GoRoute(
        path: '/reports',
        builder: (_, __) => const _StubScreen(label: 'Reports'),
      ),
      GoRoute(
        path: '/audit',
        builder: (_, __) => const _StubScreen(label: 'Audit'),
      ),
      GoRoute(
        path: '/documents',
        builder: (_, __) => const _StubScreen(label: 'Documents'),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const _StubScreen(label: 'Settings'),
      ),

      // ====================================================================
      // Admin routes (super_admin only in production)
      // ====================================================================
      GoRoute(
        path: '/admin',
        builder: (_, __) => const _StubScreen(label: 'Admin'),
      ),
      GoRoute(
        path: '/admin/distributor/:id',
        builder: (_, state) => _StubScreen(
          label: 'Admin Distributor ${state.pathParameters["id"]}',
        ),
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
///
/// Uses a generous timeout (30 s by default) to handle deferred loads
/// and slow CI runners.
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

/// Helper to tap a widget found by its visible text.
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
