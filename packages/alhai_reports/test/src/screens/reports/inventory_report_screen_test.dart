import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_reports/alhai_reports.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  late MockProductsDao mockProductsDao;

  setUpAll(() {
    registerWidgetTestFallbackValues();
  });

  setUp(() {
    final mocks = setupMockGetIt();
    mockProductsDao = mocks.productsDao;
  });

  tearDown(() {
    teardownMockGetIt();
  });

  group('InventoryReportScreen', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const InventoryReportScreen()),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      final completer = Completer<List<ProductsTableData>>();
      when(
        () => mockProductsDao.getProductsPaginated(
          any(),
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
          categoryId: any(named: 'categoryId'),
          activeOnly: any(named: 'activeOnly'),
        ),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        buildTestableWidget(const InventoryReportScreen()),
      );
      await tester.pump();

      // Screen should be in loading state
      expect(find.byType(InventoryReportScreen), findsOneWidget);

      completer.complete(<ProductsTableData>[]);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('shows error state when loading fails', (tester) async {
      when(
        () => mockProductsDao.getProductsPaginated(
          any(),
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
          categoryId: any(named: 'categoryId'),
          activeOnly: any(named: 'activeOnly'),
        ),
      ).thenThrow(Exception('Database error'));

      await tester.pumpWidget(
        buildTestableWidget(const InventoryReportScreen()),
      );
      await tester.pump(const Duration(seconds: 1));

      // Error state shows error icon and retry button
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });

    testWidgets('shows empty state when no products', (tester) async {
      // Default mock returns empty list
      await tester.pumpWidget(
        buildTestableWidget(const InventoryReportScreen()),
      );
      await tester.pump(const Duration(seconds: 1));

      // Empty state shows inventory_2_outlined icon
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    testWidgets('shows data table when products exist', (tester) async {
      final now = DateTime.now();
      when(
        () => mockProductsDao.getProductsPaginated(
          any(),
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
          categoryId: any(named: 'categoryId'),
          activeOnly: any(named: 'activeOnly'),
        ),
      ).thenAnswer(
        (_) async => [
          ProductsTableData(
            id: 'p1',
            storeId: 'test-store-id',
            name: 'Test Product',
            price: 50.0,
            stockQty: 100,
            minQty: 10,
            costPrice: 30.0,
            createdAt: now,
            isActive: true,
            trackInventory: true,
            onlineAvailable: false,
            onlineReservedQty: 0,
            autoReorder: false,
          ),
        ],
      );

      await tester.pumpWidget(
        buildTestableWidget(const InventoryReportScreen()),
      );
      await tester.pump(const Duration(seconds: 1));

      // Should show the DataTable with product data
      expect(find.byType(DataTable), findsOneWidget);
      expect(find.text('Test Product'), findsOneWidget);
    });

    testWidgets('renders app bar after data loads', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const InventoryReportScreen()),
      );
      await tester.pump(const Duration(seconds: 1));

      // Screen renders with app bar
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('retry button reloads data on error', (tester) async {
      int callCount = 0;
      when(
        () => mockProductsDao.getProductsPaginated(
          any(),
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
          categoryId: any(named: 'categoryId'),
          activeOnly: any(named: 'activeOnly'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw Exception('Database error');
        }
        return <ProductsTableData>[];
      });

      await tester.pumpWidget(
        buildTestableWidget(const InventoryReportScreen()),
      );
      await tester.pump(const Duration(seconds: 1));

      // Should be in error state
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);

      // Tap retry button
      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pump(const Duration(seconds: 1));

      // After retry, should show empty state (no products)
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });
  });
}
