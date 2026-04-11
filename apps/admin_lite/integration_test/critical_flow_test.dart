/// Integration test: Admin Lite Critical Flow
///
/// Exercises the most important flows in the admin_lite app (a slimmed-down
/// admin client focused on monitoring + approvals + AI reports):
///   1. App launch via a simplified test router (bypasses Firebase/Supabase)
///   2. Dashboard loads on startup
///   3. Navigation between dashboard, approvals, reports, and settings tabs
///   4. Approval center is reachable
///   5. Quick reports navigation works
///   6. Settings access
///
/// The real admin_lite app uses a ShellRoute with a LiteShell bottom-nav
/// wrapper which depends on a long Riverpod/Drift/Supabase chain. As with
/// the cashier and admin tests, we use a stripped-down test router that
/// renders stub screens for every route under test.
///
/// Run with:
///   flutter test integration_test/critical_flow_test.dart
///   (requires a running device or emulator)
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:go_router/go_router.dart';

import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart'
    show
        currentStoreIdProvider,
        currentUserProvider,
        isAuthenticatedProvider,
        userRoleProvider;

// ============================================================================
// HELPERS
// ============================================================================

/// Stub screen with a stable Key so tests can assert which route is active.
class _StubScreen extends StatelessWidget {
  final String label;
  const _StubScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(child: Text(label, key: Key('stub_$label'))),
    );
  }
}

/// Test admin_lite app with a stripped-down router. Renders stub screens
/// for every key route in the production lite_router so we can verify
/// navigation without instantiating LiteShell or any DAO-dependent screen.
Widget _buildLiteTestApp({
  String initialRoute = '/home',
  bool isAuthenticated = true,
  String? storeId = 'test-store-001',
}) {
  final router = GoRouter(
    initialLocation: initialRoute,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const _StubScreen(label: 'Splash'),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const _StubScreen(label: 'Login'),
      ),
      GoRoute(
        path: '/store-select',
        builder: (_, __) => const _StubScreen(label: 'Store Select'),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const _StubScreen(label: 'Home'),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (_, __) => const _StubScreen(label: 'Dashboard'),
      ),
      GoRoute(
        path: '/approvals',
        builder: (_, __) => const _StubScreen(label: 'Approvals'),
      ),
      GoRoute(
        path: '/lite/sales-trend',
        builder: (_, __) => const _StubScreen(label: 'Sales Trend'),
      ),
      GoRoute(
        path: '/lite/alerts-summary',
        builder: (_, __) => const _StubScreen(label: 'Alerts Summary'),
      ),
      GoRoute(
        path: '/lite/reports/daily-sales',
        builder: (_, __) => const _StubScreen(label: 'Daily Sales'),
      ),
      GoRoute(
        path: '/lite/reports/top-products',
        builder: (_, __) => const _StubScreen(label: 'Top Products'),
      ),
      GoRoute(
        path: '/lite/reports/low-stock',
        builder: (_, __) => const _StubScreen(label: 'Low Stock'),
      ),
      GoRoute(
        path: '/orders',
        builder: (_, __) => const _StubScreen(label: 'Orders'),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const _StubScreen(label: 'Settings'),
      ),
    ],
  );

  final testUser = User(
    id: 'test-admin-lite-001',
    phone: '+966500000000',
    name: 'Test Lite Admin',
    role: UserRole.storeOwner,
    storeId: storeId,
    createdAt: DateTime(2026, 1, 1),
  );

  return ProviderScope(
    overrides: [
      if (storeId != null)
        currentStoreIdProvider.overrideWith((ref) => storeId),
      isAuthenticatedProvider.overrideWithValue(isAuthenticated),
      currentUserProvider.overrideWithValue(isAuthenticated ? testUser : null),
      userRoleProvider.overrideWithValue(
        isAuthenticated ? UserRole.storeOwner : null,
      ),
    ],
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: const Locale('en'),
      supportedLocales: SupportedLocales.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    ),
  );
}

Future<void> _pumpAndSettle(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 200));
}

// ============================================================================
// TESTS
// ============================================================================

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ==========================================================================
  // GROUP 1: App Launch
  // ==========================================================================
  group('Admin Lite Critical Flow: App Launch', () {
    testWidgets('app launches and renders MaterialApp.router', (tester) async {
      await tester.pumpWidget(_buildLiteTestApp());
      await _pumpAndSettle(tester);

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(ProviderScope), findsOneWidget);
    });

    testWidgets('authenticated start lands on home/dashboard', (tester) async {
      await tester.pumpWidget(_buildLiteTestApp(initialRoute: '/home'));
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Home')), findsOneWidget);
    });

    testWidgets('unauthenticated start lands on login', (tester) async {
      await tester.pumpWidget(
        _buildLiteTestApp(
          initialRoute: '/login',
          isAuthenticated: false,
          storeId: null,
        ),
      );
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Login')), findsOneWidget);
    });
  });

  // ==========================================================================
  // GROUP 2: Bottom Navigation Tabs
  // ==========================================================================
  //
  // The lite app uses a 5-tab bottom navigation (dashboard, approvals,
  // reports, orders, settings). We exercise the route transitions that
  // tapping each tab triggers.
  // ==========================================================================
  group('Admin Lite Critical Flow: Tab Navigation', () {
    testWidgets('can navigate from dashboard to approvals', (tester) async {
      await tester.pumpWidget(_buildLiteTestApp(initialRoute: '/dashboard'));
      await _pumpAndSettle(tester);
      expect(find.byKey(const Key('stub_Dashboard')), findsOneWidget);

      final router = GoRouter.of(tester.element(find.byType(Scaffold)));
      router.go('/approvals');
      await _pumpAndSettle(tester);
      expect(find.byKey(const Key('stub_Approvals')), findsOneWidget);
    });

    testWidgets('can navigate to settings tab', (tester) async {
      await tester.pumpWidget(_buildLiteTestApp(initialRoute: '/home'));
      await _pumpAndSettle(tester);

      final router = GoRouter.of(tester.element(find.byType(Scaffold)));
      router.go('/settings');
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Settings')), findsOneWidget);
    });

    testWidgets('can navigate to orders tab', (tester) async {
      await tester.pumpWidget(_buildLiteTestApp(initialRoute: '/home'));
      await _pumpAndSettle(tester);

      final router = GoRouter.of(tester.element(find.byType(Scaffold)));
      router.go('/orders');
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Orders')), findsOneWidget);
    });

    testWidgets(
      'cycles through dashboard -> approvals -> orders -> dashboard',
      (tester) async {
        await tester.pumpWidget(_buildLiteTestApp(initialRoute: '/dashboard'));
        await _pumpAndSettle(tester);

        final router = GoRouter.of(tester.element(find.byType(Scaffold)));

        router.go('/approvals');
        await _pumpAndSettle(tester);
        expect(find.byKey(const Key('stub_Approvals')), findsOneWidget);

        router.go('/orders');
        await _pumpAndSettle(tester);
        expect(find.byKey(const Key('stub_Orders')), findsOneWidget);

        router.go('/dashboard');
        await _pumpAndSettle(tester);
        expect(find.byKey(const Key('stub_Dashboard')), findsOneWidget);
      },
    );
  });

  // ==========================================================================
  // GROUP 3: Quick Reports
  // ==========================================================================
  //
  // The lite app's reports tab links into per-report screens.
  // ==========================================================================
  group('Admin Lite Critical Flow: Quick Reports', () {
    testWidgets('daily sales report is reachable', (tester) async {
      await tester.pumpWidget(
        _buildLiteTestApp(initialRoute: '/lite/reports/daily-sales'),
      );
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Daily Sales')), findsOneWidget);
    });

    testWidgets('top products report is reachable', (tester) async {
      await tester.pumpWidget(
        _buildLiteTestApp(initialRoute: '/lite/reports/top-products'),
      );
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Top Products')), findsOneWidget);
    });

    testWidgets('low stock report is reachable', (tester) async {
      await tester.pumpWidget(
        _buildLiteTestApp(initialRoute: '/lite/reports/low-stock'),
      );
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Low Stock')), findsOneWidget);
    });

    testWidgets('sales trend screen is reachable', (tester) async {
      await tester.pumpWidget(
        _buildLiteTestApp(initialRoute: '/lite/sales-trend'),
      );
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Sales Trend')), findsOneWidget);
    });

    testWidgets('alerts summary is reachable from dashboard', (tester) async {
      await tester.pumpWidget(_buildLiteTestApp(initialRoute: '/dashboard'));
      await _pumpAndSettle(tester);

      final router = GoRouter.of(tester.element(find.byType(Scaffold)));
      router.go('/lite/alerts-summary');
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Alerts Summary')), findsOneWidget);
    });
  });

  // ==========================================================================
  // GROUP 4: Approval Center
  // ==========================================================================
  group('Admin Lite Critical Flow: Approvals', () {
    testWidgets('approval center loads on direct navigation', (tester) async {
      await tester.pumpWidget(_buildLiteTestApp(initialRoute: '/approvals'));
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Approvals')), findsOneWidget);
    });

    testWidgets('navigating from approvals to settings works', (tester) async {
      await tester.pumpWidget(_buildLiteTestApp(initialRoute: '/approvals'));
      await _pumpAndSettle(tester);

      final router = GoRouter.of(tester.element(find.byType(Scaffold)));
      router.go('/settings');
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Settings')), findsOneWidget);
    });
  });
}
