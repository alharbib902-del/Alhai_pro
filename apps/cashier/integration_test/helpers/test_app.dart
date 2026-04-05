/// Test app wrapper with mocked dependencies for integration tests.
///
/// Provides a [buildTestApp] function that creates a fully-configured
/// CashierApp wrapped in a ProviderScope with mock overrides, bypassing
/// real Firebase/Supabase/database initialization.
///
/// Usage:
///   await tester.pumpWidget(buildTestApp());
///   await tester.pumpAndSettle();
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_pos/alhai_pos.dart';
import 'package:alhai_database/alhai_database.dart';

import 'test_data.dart';

// ============================================================================
// MOCK CLASSES
// ============================================================================

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSaleService extends Mock implements SaleService {}

// ============================================================================
// TEST APP BUILDER
// ============================================================================

/// Builds a test version of the CashierApp with controllable provider overrides.
///
/// Parameters:
/// - [initialRoute]: The route to start at (defaults to '/pos').
/// - [isAuthenticated]: Whether the user should start as authenticated.
/// - [storeId]: The store ID to use (null = no store selected).
/// - [overrides]: Additional provider overrides for specific test scenarios.
/// - [products]: Products to pre-load into the products state.
/// - [cartItems]: Items to pre-load into the cart.
Widget buildTestApp({
  String initialRoute = '/pos',
  bool isAuthenticated = true,
  String? storeId = kTestStoreId,
  List<Override> overrides = const [],
  List<Product>? products,
  List<PosCartItem>? cartItems,
}) {
  final router = GoRouter(
    initialLocation: initialRoute,
    routes: [
      // Minimal route set for integration tests.
      // Each test navigates through the real screens,
      // but we define stubs for routes not under test.
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
        path: '/pos',
        builder: (_, __) => const PosScreen(),
      ),
      GoRoute(
        path: '/pos/payment',
        builder: (_, __) => const PaymentScreen(),
      ),
      GoRoute(
        path: '/pos/receipt',
        builder: (_, __) => const ReceiptScreen(),
      ),
      GoRoute(
        path: '/returns',
        builder: (_, __) => const ReturnsScreen(),
      ),
      GoRoute(
        path: '/returns/request',
        builder: (_, __) => const RefundRequestScreen(),
      ),
      GoRoute(
        path: '/returns/reason',
        builder: (_, __) => const RefundReasonScreen(),
      ),
      GoRoute(
        path: '/returns/receipt/:id',
        builder: (_, state) => RefundReceiptScreen(
          refundId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/shifts/open',
        builder: (_, __) => const _StubScreen(label: 'Shift Open'),
      ),
      GoRoute(
        path: '/shifts/close',
        builder: (_, __) => const _StubScreen(label: 'Shift Close'),
      ),
      GoRoute(
        path: '/sales',
        builder: (_, __) => const _StubScreen(label: 'Sales'),
      ),
      GoRoute(
        path: '/sales/:id',
        builder: (_, state) => _StubScreen(
          label: 'Sale Detail ${state.pathParameters["id"]}',
        ),
      ),
      GoRoute(
        path: '/invoices',
        builder: (_, __) => const _StubScreen(label: 'Invoices'),
      ),
      GoRoute(
        path: '/reports',
        builder: (_, __) => const _StubScreen(label: 'Reports'),
      ),
      GoRoute(
        path: '/inventory',
        builder: (_, __) => const _StubScreen(label: 'Inventory'),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const _StubScreen(label: 'Settings'),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (_, __) => const _StubScreen(label: 'Dashboard'),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const _StubScreen(label: 'Notifications'),
      ),
      GoRoute(
        path: '/customers',
        builder: (_, __) => const _StubScreen(label: 'Customers'),
      ),
      GoRoute(
        path: '/products',
        builder: (_, __) => const _StubScreen(label: 'Products'),
      ),
      GoRoute(
        path: '/shifts',
        builder: (_, __) => const _StubScreen(label: 'Shifts'),
      ),
      GoRoute(
        path: '/sync',
        builder: (_, __) => const _StubScreen(label: 'Sync'),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const _StubScreen(label: 'Profile'),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      // Auth: simulate authenticated state with a test store
      if (storeId != null)
        currentStoreIdProvider.overrideWith((ref) => storeId),

      // Theme: use light mode for consistent screenshots
      themeProvider.overrideWith((ref) => ThemeNotifier(ThemeMode.light)),

      // Spread caller-provided overrides last so they win
      ...overrides,
    ],
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      locale: const Locale('ar'),
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

// ============================================================================
// STUB SCREEN
// ============================================================================

/// Minimal placeholder screen used for routes that are not under test.
/// Renders a centered label so tests can verify navigation happened.
class _StubScreen extends StatelessWidget {
  final String label;
  const _StubScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          label,
          key: Key('stub_$label'),
        ),
      ),
    );
  }
}

// ============================================================================
// TEST UTILITIES
// ============================================================================

/// Pumps the widget tree and waits for all animations and async work to settle.
/// Uses a longer timeout than the default to accommodate integration test load times.
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

/// Helper to enter text into a text field found by key.
Future<void> enterTextByKey(
  WidgetTester tester,
  String key,
  String text,
) async {
  final finder = find.byKey(Key(key));
  await tester.ensureVisible(finder);
  await tester.enterText(finder, text);
  await tester.pump();
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

/// Verify a screen is displayed by checking for expected text or widget type.
void expectScreenVisible(String text) {
  expect(find.text(text), findsWidgets);
}

/// Verify a specific widget type is present in the tree.
void expectWidgetPresent<T extends Widget>() {
  expect(find.byType(T), findsWidgets);
}
