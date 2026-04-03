/// Widget tests for OrderTrackingScreen
///
/// Tests: loading state, error state, empty orders, stat cards
/// Note: OrderTrackingScreen uses GetIt.I<AppDatabase> directly (not providers),
/// so we test the UI states by mocking the GetIt registration.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/src/screens/orders/order_tracking_screen.dart';
import 'package:alhai_shared_ui/src/providers/sync_providers.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAppDatabase extends Mock implements AppDatabase {}

class MockOrdersDao extends Mock implements OrdersDao {}

class MockCustomersDao extends Mock implements CustomersDao {}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _buildTestWidget() {
  return ProviderScope(
    overrides: [
      currentStoreIdProvider.overrideWith((ref) => 'test-store-id'),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const OrderTrackingScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAppDatabase mockDb;
  late MockOrdersDao mockOrdersDao;
  late MockCustomersDao mockCustomersDao;

  setUp(() {
    mockDb = MockAppDatabase();
    mockOrdersDao = MockOrdersDao();
    mockCustomersDao = MockCustomersDao();

    when(() => mockDb.ordersDao).thenReturn(mockOrdersDao);
    when(() => mockDb.customersDao).thenReturn(mockCustomersDao);

    // Register mock in GetIt
    final getIt = GetIt.instance;
    if (getIt.isRegistered<AppDatabase>()) {
      getIt.unregister<AppDatabase>();
    }
    getIt.registerSingleton<AppDatabase>(mockDb);
  });

  tearDown(() {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<AppDatabase>()) {
      getIt.unregister<AppDatabase>();
    }
  });

  group('OrderTrackingScreen', () {
    testWidgets('shows loading then empty state', (tester) async {
      when(() => mockOrdersDao.getPendingOrders(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestWidget());
      // Initially shows loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // After loading, shows the delivery icon (empty state)
      expect(find.byIcon(Icons.delivery_dining), findsWidgets);
    });

    testWidgets('shows error state on exception', (tester) async {
      when(() => mockOrdersDao.getPendingOrders(any()))
          .thenThrow(Exception('DB error'));

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Error icon
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows refresh button on error', (tester) async {
      when(() => mockOrdersDao.getPendingOrders(any()))
          .thenThrow(Exception('DB error'));

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byIcon(Icons.refresh), findsWidgets);
    });

    testWidgets('shows orders when data loaded', (tester) async {
      final testOrder = OrdersTableData(
        id: 'order-1',
        storeId: 'test-store-id',
        orderNumber: 'ORD-001',
        channel: 'online',
        status: 'created',
        subtotal: 85,
        taxAmount: 15,
        deliveryFee: 0,
        discount: 0,
        total: 100,
        paymentStatus: 'paid',
        deliveryType: 'delivery',
        confirmationAttempts: 0,
        autoReorderTriggered: false,
        orderDate: DateTime(2026, 1, 15),
        createdAt: DateTime(2026, 1, 15, 10, 0),
      );

      when(() => mockOrdersDao.getPendingOrders(any()))
          .thenAnswer((_) async => [testOrder]);
      when(() => mockOrdersDao.getOrderItems(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should have stat cards visible (pending, preparing, delivering)
      expect(find.byIcon(Icons.pending), findsOneWidget);
      expect(find.byIcon(Icons.restaurant), findsOneWidget);
      expect(find.byIcon(Icons.delivery_dining), findsWidgets);
    });

    testWidgets('has AppBar with orders title', (tester) async {
      when(() => mockOrdersDao.getPendingOrders(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
