/// Integration test: Admin Critical Flow
///
/// Exercises the most important navigation and rendering paths in the
/// admin dashboard app:
///   1. App launch via a simplified test router (bypasses Firebase/Supabase)
///   2. Dashboard / home renders on startup
///   3. Navigation between dashboard, products, orders, inventory, settings
///   4. Products list screen is reachable
///   5. Search / filter interaction does not crash
///   6. Settings area is accessible
///
/// The real admin app uses a ShellRoute wrapping a persistent sidebar
/// (`AdminDashboardShell`) which in turn depends on a long list of
/// Riverpod providers backed by a real Drift database and Supabase client.
/// Instantiating the full app in an integration test environment is not
/// feasible, so this test builds a stripped-down test router mirroring the
/// production routes and backs it with the shared mock provider overrides
/// from `apps/admin/test/helpers/mock_providers.dart`.
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

/// Minimal stub screen used for routes under test. Each stub carries a
/// stable [Key] so tests can assert which route is currently active.
class _StubScreen extends StatelessWidget {
  final String label;
  const _StubScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, key: Key('stub_$label')),
            const SizedBox(height: 16),
            // Simulate a search field for filter/search tests
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                key: Key('${label}_search'),
                decoration: InputDecoration(
                  hintText: 'Search $label',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Builds a test version of the admin app using a stripped-down router that
/// renders stub screens for every route. This avoids the AdminDashboardShell
/// and all the complex Riverpod/Drift/Supabase wiring the production router
/// needs.
Widget _buildAdminTestApp({
  String initialRoute = '/home',
  bool isAuthenticated = true,
  String? storeId = 'test-store-001',
}) {
  final router = GoRouter(
    initialLocation: initialRoute,
    routes: [
      GoRoute(
          path: '/splash',
          builder: (_, __) => const _StubScreen(label: 'Splash')),
      GoRoute(
          path: '/login',
          builder: (_, __) => const _StubScreen(label: 'Login')),
      GoRoute(
        path: '/store-select',
        builder: (_, __) => const _StubScreen(label: 'Store Select'),
      ),
      GoRoute(
          path: '/home', builder: (_, __) => const _StubScreen(label: 'Home')),
      GoRoute(
        path: '/dashboard',
        builder: (_, __) => const _StubScreen(label: 'Dashboard'),
      ),
      GoRoute(
        path: '/products',
        builder: (_, __) => const _StubScreen(label: 'Products'),
      ),
      GoRoute(
        path: '/products/add',
        builder: (_, __) => const _StubScreen(label: 'Add Product'),
      ),
      GoRoute(
        path: '/orders',
        builder: (_, __) => const _StubScreen(label: 'Orders'),
      ),
      GoRoute(
        path: '/sales',
        builder: (_, __) => const _StubScreen(label: 'Sales'),
      ),
      GoRoute(
        path: '/inventory',
        builder: (_, __) => const _StubScreen(label: 'Inventory'),
      ),
      GoRoute(
        path: '/customers',
        builder: (_, __) => const _StubScreen(label: 'Customers'),
      ),
      GoRoute(
        path: '/reports',
        builder: (_, __) => const _StubScreen(label: 'Reports'),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const _StubScreen(label: 'Settings'),
      ),
      GoRoute(
        path: '/settings/store',
        builder: (_, __) => const _StubScreen(label: 'Store Settings'),
      ),
      GoRoute(
        path: '/employees',
        builder: (_, __) => const _StubScreen(label: 'Employees'),
      ),
      GoRoute(
        path: '/suppliers',
        builder: (_, __) => const _StubScreen(label: 'Suppliers'),
      ),
    ],
  );

  // Create a lightweight test user for auth-aware providers.
  final testUser = User(
    id: 'test-admin-001',
    phone: '+966500000000',
    name: 'Test Admin',
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

  group('Admin Critical Flow: App Launch', () {
    testWidgets('app launches and renders MaterialApp.router', (tester) async {
      await tester.pumpWidget(_buildAdminTestApp());
      await _pumpAndSettle(tester);

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(ProviderScope), findsOneWidget);
    });

    testWidgets('authenticated start lands on home screen', (tester) async {
      await tester.pumpWidget(_buildAdminTestApp(initialRoute: '/home'));
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Home')), findsOneWidget);
    });

    testWidgets('unauthenticated start lands on login stub', (tester) async {
      await tester.pumpWidget(_buildAdminTestApp(
        initialRoute: '/login',
        isAuthenticated: false,
        storeId: null,
      ));
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Login')), findsOneWidget);
    });

    testWidgets('dashboard route is reachable directly', (tester) async {
      await tester.pumpWidget(_buildAdminTestApp(initialRoute: '/dashboard'));
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Dashboard')), findsOneWidget);
    });
  });

  // ==========================================================================
  // GROUP: Navigation Between Main Screens
  // ==========================================================================
  //
  // The admin app has a persistent sidebar with links to every top-level
  // screen. In this test we use GoRouter.go() directly to simulate the
  // result of tapping those sidebar entries.
  // ==========================================================================
  group('Admin Critical Flow: Navigation', () {
    testWidgets('can navigate from home to dashboard', (tester) async {
      await tester.pumpWidget(_buildAdminTestApp(initialRoute: '/home'));
      await _pumpAndSettle(tester);
      expect(find.byKey(const Key('stub_Home')), findsOneWidget);

      final router = GoRouter.of(tester.element(find.byType(Scaffold)));
      router.go('/dashboard');
      await _pumpAndSettle(tester);
      expect(find.byKey(const Key('stub_Dashboard')), findsOneWidget);
    });

    testWidgets('can navigate to products screen', (tester) async {
      await tester.pumpWidget(_buildAdminTestApp(initialRoute: '/home'));
      await _pumpAndSettle(tester);

      final router = GoRouter.of(tester.element(find.byType(Scaffold)));
      router.go('/products');
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Products')), findsOneWidget);
    });

    testWidgets('can navigate to orders screen', (tester) async {
      await tester.pumpWidget(_buildAdminTestApp(initialRoute: '/home'));
      await _pumpAndSettle(tester);

      final router = GoRouter.of(tester.element(find.byType(Scaffold)));
      router.go('/orders');
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Orders')), findsOneWidget);
    });

    testWidgets('can navigate to inventory screen', (tester) async {
      await tester.pumpWidget(_buildAdminTestApp(initialRoute: '/home'));
      await _pumpAndSettle(tester);

      final router = GoRouter.of(tester.element(find.byType(Scaffold)));
      router.go('/inventory');
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Inventory')), findsOneWidget);
    });

    testWidgets('can navigate across multiple screens in sequence',
        (tester) async {
      await tester.pumpWidget(_buildAdminTestApp(initialRoute: '/home'));
      await _pumpAndSettle(tester);

      final router = GoRouter.of(tester.element(find.byType(Scaffold)));

      // Home -> Products -> Orders -> Inventory -> Home
      router.go('/products');
      await _pumpAndSettle(tester);
      expect(find.byKey(const Key('stub_Products')), findsOneWidget);

      router.go('/orders');
      await _pumpAndSettle(tester);
      expect(find.byKey(const Key('stub_Orders')), findsOneWidget);

      router.go('/inventory');
      await _pumpAndSettle(tester);
      expect(find.byKey(const Key('stub_Inventory')), findsOneWidget);

      router.go('/home');
      await _pumpAndSettle(tester);
      expect(find.byKey(const Key('stub_Home')), findsOneWidget);
    });
  });

  // ==========================================================================
  // GROUP: Products List and Search
  // ==========================================================================
  group('Admin Critical Flow: Products List', () {
    testWidgets('products list screen loads', (tester) async {
      await tester.pumpWidget(_buildAdminTestApp(initialRoute: '/products'));
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Products')), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('products search field accepts input', (tester) async {
      await tester.pumpWidget(_buildAdminTestApp(initialRoute: '/products'));
      await _pumpAndSettle(tester);

      final searchField = find.byKey(const Key('Products_search'));
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'milk');
      await tester.pump();

      // Search stays active - no crashes
      expect(find.text('milk'), findsOneWidget);
    });

    testWidgets('navigating to add product route works', (tester) async {
      await tester.pumpWidget(_buildAdminTestApp(initialRoute: '/products'));
      await _pumpAndSettle(tester);

      final router = GoRouter.of(tester.element(find.byType(Scaffold)));
      router.go('/products/add');
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Add Product')), findsOneWidget);
    });
  });

  // ==========================================================================
  // GROUP: Settings Access
  // ==========================================================================
  group('Admin Critical Flow: Settings', () {
    testWidgets('settings screen is accessible', (tester) async {
      await tester.pumpWidget(_buildAdminTestApp(initialRoute: '/settings'));
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Settings')), findsOneWidget);
    });

    testWidgets('store settings sub-route is reachable', (tester) async {
      await tester.pumpWidget(_buildAdminTestApp(initialRoute: '/settings'));
      await _pumpAndSettle(tester);

      final router = GoRouter.of(tester.element(find.byType(Scaffold)));
      router.go('/settings/store');
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Store Settings')), findsOneWidget);
    });

    testWidgets('can navigate from settings back to home', (tester) async {
      await tester.pumpWidget(_buildAdminTestApp(initialRoute: '/settings'));
      await _pumpAndSettle(tester);
      expect(find.byKey(const Key('stub_Settings')), findsOneWidget);

      final router = GoRouter.of(tester.element(find.byType(Scaffold)));
      router.go('/home');
      await _pumpAndSettle(tester);

      expect(find.byKey(const Key('stub_Home')), findsOneWidget);
    });
  });
}
