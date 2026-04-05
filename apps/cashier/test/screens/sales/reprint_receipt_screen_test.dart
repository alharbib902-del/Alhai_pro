import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../helpers/mock_database.dart';
import '../../helpers/test_factories.dart';
import '../../helpers/test_helpers.dart';

import 'package:cashier/screens/sales/reprint_receipt_screen.dart';

void main() {
  late MockSalesDao salesDao;
  late MockAppDatabase db;

  setUpAll(() {
    registerCashierFallbackValues();
  });

  setUp(() {
    salesDao = MockSalesDao();
    db = setupMockDatabase(salesDao: salesDao);
    setupTestGetIt(mockDb: db);
  });

  tearDown(tearDownTestGetIt);

  group('ReprintReceiptScreen', () {
    testWidgets('shows loading indicator while fetching', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => salesDao.getAllSales(any(), limit: any(named: 'limit')))
          .thenAnswer((_) async => <SalesTableData>[]);

      await tester.pumpWidget(createTestWidget(const ReprintReceiptScreen()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no orders', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => salesDao.getAllSales(any(), limit: any(named: 'limit')))
          .thenAnswer((_) async => <SalesTableData>[]);

      await tester.pumpWidget(createTestWidget(const ReprintReceiptScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    });

    testWidgets('displays list of orders when loaded', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final sales = [
        createTestSale(
          id: 'sale-1',
          total: 100.0,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        createTestSale(
          id: 'sale-2',
          total: 200.0,
          createdAt: DateTime.now(),
        ),
      ];

      when(() => salesDao.getAllSales(any(), limit: any(named: 'limit')))
          .thenAnswer((_) async => sales);

      await tester.pumpWidget(createTestWidget(const ReprintReceiptScreen()));
      await tester.pumpAndSettle();

      // Order cards with receipt icons
      expect(find.byIcon(Icons.receipt_rounded), findsWidgets);
    });

    testWidgets('has a search bar for filtering', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => salesDao.getAllSales(any(), limit: any(named: 'limit')))
          .thenAnswer((_) async => <SalesTableData>[]);

      await tester.pumpWidget(createTestWidget(const ReprintReceiptScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('shows select-to-print prompt in wide layout', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => salesDao.getAllSales(any(), limit: any(named: 'limit')))
          .thenAnswer((_) async => <SalesTableData>[]);

      await tester.pumpWidget(createTestWidget(const ReprintReceiptScreen()));
      await tester.pumpAndSettle();

      // Print prompt icon should be visible (no order selected)
      expect(find.byIcon(Icons.print_outlined), findsOneWidget);
    });
  });
}
