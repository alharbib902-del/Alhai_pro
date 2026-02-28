import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../helpers/mock_database.dart';
import '../../helpers/test_factories.dart';
import '../../helpers/test_helpers.dart';

import 'package:cashier/screens/sales/sale_detail_screen.dart';

void main() {
  late MockOrdersDao ordersDao;
  late MockSaleItemsDao saleItemsDao;
  late MockAppDatabase db;

  setUpAll(() {
    registerCashierFallbackValues();
  });

  setUp(() {
    ordersDao = MockOrdersDao();
    saleItemsDao = MockSaleItemsDao();
    db = setupMockDatabase(ordersDao: ordersDao, saleItemsDao: saleItemsDao);
    setupTestGetIt(mockDb: db);
  });

  tearDown(tearDownTestGetIt);

  group('SaleDetailScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrderById(any()))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(
        createTestWidget(const SaleDetailScreen(saleId: 'sale-1')),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows not-found when order is null', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrderById(any()))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(
        createTestWidget(const SaleDetailScreen(saleId: 'nonexistent')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sale not found'), findsOneWidget);
    });

    testWidgets('displays order details when loaded', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final order = createTestOrder(
        id: 'sale-123',
        total: 115.0,
        status: 'completed',
      );
      final items = [
        createTestSaleItem(
          id: 'item-1',
          saleId: 'sale-123',
          productName: '\u0645\u0646\u062a\u062c 1',
          qty: 2,
          unitPrice: 25.0,
        ),
      ];

      when(() => ordersDao.getOrderById('sale-123'))
          .thenAnswer((_) async => order);
      when(() => saleItemsDao.getItemsBySaleId('sale-123'))
          .thenAnswer((_) async => items);

      await tester.pumpWidget(
        createTestWidget(const SaleDetailScreen(saleId: 'sale-123')),
      );
      await tester.pumpAndSettle();

      // Top bar should show sale ID prefix
      expect(find.textContaining('#sale-123'), findsWidgets);
    });

    testWidgets('shows items card with item count', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final order = createTestOrder(id: 'sale-1', total: 50.0);
      final items = [
        createTestSaleItem(id: 'item-1', saleId: 'sale-1'),
        createTestSaleItem(id: 'item-2', saleId: 'sale-1', productName: '\u0645\u0646\u062a\u062c 2'),
      ];

      when(() => ordersDao.getOrderById('sale-1'))
          .thenAnswer((_) async => order);
      when(() => saleItemsDao.getItemsBySaleId('sale-1'))
          .thenAnswer((_) async => items);

      await tester.pumpWidget(
        createTestWidget(const SaleDetailScreen(saleId: 'sale-1')),
      );
      await tester.pumpAndSettle();

      // Item count badge should show 2
      expect(find.text('2'), findsWidgets);
    });

    testWidgets('shows reprint and refund action buttons', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final order = createTestOrder(id: 'sale-1', total: 100.0);

      when(() => ordersDao.getOrderById('sale-1'))
          .thenAnswer((_) async => order);
      when(() => saleItemsDao.getItemsBySaleId('sale-1'))
          .thenAnswer((_) async => <SaleItemsTableData>[]);

      await tester.pumpWidget(
        createTestWidget(const SaleDetailScreen(saleId: 'sale-1')),
      );
      await tester.pumpAndSettle();

      // Reprint button icon
      expect(find.byIcon(Icons.print_rounded), findsOneWidget);
      // Refund button icon
      expect(find.byIcon(Icons.assignment_return_rounded), findsOneWidget);
    });

    testWidgets('has a refresh button in top bar', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrderById(any()))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(
        createTestWidget(const SaleDetailScreen(saleId: 'sale-1')),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });
  });
}
