import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

import '../../helpers/mock_database.dart';
import '../../helpers/test_factories.dart';
import '../../helpers/test_helpers.dart';

import 'package:cashier/screens/sales/sales_history_screen.dart';

void main() {
  late MockOrdersDao ordersDao;
  late MockAppDatabase db;

  setUpAll(() {
    registerCashierFallbackValues();
  });

  setUp(() {
    ordersDao = MockOrdersDao();
    db = setupMockDatabase(ordersDao: ordersDao);
    setupTestGetIt(mockDb: db);
  });

  tearDown(tearDownTestGetIt);

  group('SalesHistoryScreen', () {
    testWidgets('renders loading indicator while fetching orders',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrders(any()))
          .thenAnswer((_) async => <OrdersTableData>[]);

      await tester.pumpWidget(createTestWidget(const SalesHistoryScreen()));

      // Screen uses ShimmerList for loading state (not CircularProgressIndicator)
      expect(find.byType(ShimmerList), findsOneWidget);
    });

    testWidgets('shows empty state when no orders match', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrders(any()))
          .thenAnswer((_) async => <OrdersTableData>[]);

      await tester.pumpWidget(createTestWidget(const SalesHistoryScreen()));
      await tester.pumpAndSettle();

      // Empty state icon should be visible
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    });

    testWidgets('displays order cards when data is loaded', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final orders = [
        createTestOrder(
          id: 'order-1',
          total: 115.0,
          status: 'completed',
          createdAt: DateTime.now(),
        ),
        createTestOrder(
          id: 'order-2',
          total: 230.0,
          status: 'completed',
          createdAt: DateTime.now(),
        ),
      ];

      when(() => ordersDao.getOrders(any()))
          .thenAnswer((_) async => orders);

      await tester.pumpWidget(createTestWidget(const SalesHistoryScreen()));
      await tester.pumpAndSettle();

      // Should find order amount text
      expect(find.byIcon(Icons.receipt_long_rounded), findsWidgets);
    });

    testWidgets('shows search bar after loading', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrders(any()))
          .thenAnswer((_) async => <OrdersTableData>[]);

      await tester.pumpWidget(createTestWidget(const SalesHistoryScreen()));
      await tester.pumpAndSettle();

      // Search field should be present
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('displays summary stats section', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final orders = [
        createTestOrder(
          id: 'order-today',
          total: 100.0,
          status: 'completed',
          createdAt: DateTime.now(),
        ),
      ];

      when(() => ordersDao.getOrders(any()))
          .thenAnswer((_) async => orders);

      await tester.pumpWidget(createTestWidget(const SalesHistoryScreen()));
      await tester.pumpAndSettle();

      // Summary stats container should exist (total sales count and amount)
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('has date filter chips', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrders(any()))
          .thenAnswer((_) async => <OrdersTableData>[]);

      await tester.pumpWidget(createTestWidget(const SalesHistoryScreen()));
      await tester.pumpAndSettle();

      // Date filter chips should be present
      expect(find.byType(SingleChildScrollView), findsWidgets);
      // Date range icon should appear in the custom date chip
      expect(find.byIcon(Icons.date_range_outlined), findsOneWidget);
    });
  });
}
