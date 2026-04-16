/// Tests for Lite Stock Adjustment Screen
///
/// Verifies rendering of product stock cards, search functionality,
/// loading state, error state, and product display.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';

import 'package:admin_lite/providers/lite_management_providers.dart';
import 'package:admin_lite/screens/management/lite_stock_adjustment_screen.dart';
import '../../helpers/mock_database.dart';
import '../../helpers/test_helpers.dart';
import '../../helpers/test_factories.dart';

void main() {
  late MockAppDatabase db;

  setUpAll(() => registerLiteFallbackValues());

  setUp(() {
    db = setupMockDatabase();
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  // ===========================================================================
  // Helper
  // ===========================================================================

  Widget buildScreen({
    AsyncValue<List<ProductsTableData>>? productsValue,
  }) {
    return createTestWidget(
      const LiteStockAdjustmentScreen(),
      overrides: [
        if (productsValue != null)
          liteAllProductsProvider.overrideWith(
            (ref) => productsValue.when(
              data: (d) => Future.value(d),
              loading: () => Future.delayed(const Duration(days: 1)),
              error: (e, s) => Future.error(e, s),
            ),
          ),
      ],
    );
  }

  // ===========================================================================
  // Tests
  // ===========================================================================

  group('LiteStockAdjustmentScreen', () {
    testWidgets('renders with loading state', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final completer = Completer<List<ProductsTableData>>();

      await tester.pumpWidget(
        createTestWidget(
          const LiteStockAdjustmentScreen(),
          overrides: [
            liteAllProductsProvider.overrideWith((ref) => completer.future),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(LiteStockAdjustmentScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows search field', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        buildScreen(productsValue: const AsyncValue.data([])),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows product cards with stock info', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final products = [
        createTestProduct(
          id: 'p1',
          name: 'Product A',
          stockQty: 25,
          price: 10.0,
        ),
        createTestProduct(
          id: 'p2',
          name: 'Product B',
          stockQty: 50,
          price: 20.0,
        ),
      ];

      await tester.pumpWidget(
        buildScreen(productsValue: AsyncValue.data(products)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Product A'), findsOneWidget);
      expect(find.text('Product B'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('search filters products by name', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final products = [
        createTestProduct(id: 'p1', name: 'Milk Carton', stockQty: 20),
        createTestProduct(id: 'p2', name: 'Water Bottle', stockQty: 100),
      ];

      await tester.pumpWidget(
        buildScreen(productsValue: AsyncValue.data(products)),
      );
      await tester.pumpAndSettle();

      // Both visible initially
      expect(find.text('Milk Carton'), findsOneWidget);
      expect(find.text('Water Bottle'), findsOneWidget);

      // Type in search
      await tester.enterText(find.byType(TextField), 'Milk');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Only Milk Carton should be visible
      expect(find.text('Milk Carton'), findsOneWidget);
      expect(find.text('Water Bottle'), findsNothing);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('handles error state', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        buildScreen(
          productsValue: AsyncValue.error(
            Exception('Load error'),
            StackTrace.current,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
