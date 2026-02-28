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
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      when(() => mockProductsDao.getAllProducts(any()))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 2));
        return <ProductsTableData>[];
      });

      await tester.pumpWidget(
        buildTestableWidget(const InventoryReportScreen()),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state when loading fails', (tester) async {
      when(() => mockProductsDao.getAllProducts(any()))
          .thenThrow(Exception('Database error'));

      await tester.pumpWidget(
        buildTestableWidget(const InventoryReportScreen()),
      );
      await tester.pumpAndSettle();

      // Error state shows error icon and retry button
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });

    testWidgets('shows empty state when no products', (tester) async {
      // Default mock returns empty list
      await tester.pumpWidget(
        buildTestableWidget(const InventoryReportScreen()),
      );
      await tester.pumpAndSettle();

      // Empty state shows inventory_2_outlined icon
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    testWidgets('shows data table when products exist', (tester) async {
      final now = DateTime.now();
      when(() => mockProductsDao.getAllProducts(any()))
          .thenAnswer((_) async => [
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
                  taxable: true,
                  trackStock: true,
                ),
              ]);

      await tester.pumpWidget(
        buildTestableWidget(const InventoryReportScreen()),
      );
      await tester.pumpAndSettle();

      // Should show the DataTable with product data
      expect(find.byType(DataTable), findsOneWidget);
      expect(find.text('Test Product'), findsOneWidget);
    });

    testWidgets('has export and print buttons in app bar', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const InventoryReportScreen()),
      );
      await tester.pumpAndSettle();

      // Export and print buttons
      expect(find.byIcon(Icons.file_download), findsOneWidget);
      expect(find.byIcon(Icons.print), findsOneWidget);
    });

    testWidgets('retry button reloads data on error', (tester) async {
      int callCount = 0;
      when(() => mockProductsDao.getAllProducts(any()))
          .thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw Exception('Database error');
        }
        return <ProductsTableData>[];
      });

      await tester.pumpWidget(
        buildTestableWidget(const InventoryReportScreen()),
      );
      await tester.pumpAndSettle();

      // Should be in error state
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);

      // Tap retry button
      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pumpAndSettle();

      // After retry, should show empty state (no products)
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });
  });
}
