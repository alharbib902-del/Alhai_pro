/// Tests for Lite Quick Price Screen
///
/// Verifies rendering of product price cards, search functionality,
/// edit button, loading state, error state, and empty state.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';

import 'package:admin_lite/providers/lite_management_providers.dart';
import 'package:admin_lite/screens/management/lite_quick_price_screen.dart';
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

  Widget buildScreen({AsyncValue<List<ProductsTableData>>? productsValue}) {
    return createTestWidget(
      const LiteQuickPriceScreen(),
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

  group('LiteQuickPriceScreen', () {
    testWidgets('renders with loading state', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final completer = Completer<List<ProductsTableData>>();

      await tester.pumpWidget(
        createTestWidget(
          const LiteQuickPriceScreen(),
          overrides: [
            liteAllProductsProvider.overrideWith((ref) => completer.future),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(LiteQuickPriceScreen), findsOneWidget);
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

    testWidgets('shows product cards with name and price', (tester) async {
      // Use mobile size so card list renders (not DataTable)
      tester.view.physicalSize = const Size(500, 900);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final products = [
        createTestProduct(id: 'p1', name: 'Milk', price: 12.0),
        createTestProduct(id: 'p2', name: 'Bread', price: 5.0),
      ];

      await tester.pumpWidget(
        buildScreen(productsValue: AsyncValue.data(products)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Milk'), findsOneWidget);
      expect(find.text('Bread'), findsOneWidget);
      expect(find.text('12 SAR'), findsOneWidget);
      expect(find.text('5 SAR'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows edit button for each product', (tester) async {
      // Use mobile size for card list layout
      tester.view.physicalSize = const Size(500, 900);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final products = [
        createTestProduct(id: 'p1', name: 'Product A', price: 25.0),
        createTestProduct(id: 'p2', name: 'Product B', price: 30.0),
      ];

      await tester.pumpWidget(
        buildScreen(productsValue: AsyncValue.data(products)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsNWidgets(2));

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('edit button opens price dialog', (tester) async {
      // Use mobile size for card list layout
      tester.view.physicalSize = const Size(500, 900);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final products = [
        createTestProduct(id: 'p1', name: 'Test Product', price: 25.0),
      ];

      await tester.pumpWidget(
        buildScreen(productsValue: AsyncValue.data(products)),
      );
      await tester.pumpAndSettle();

      // Tap edit button
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Dialog should show product name as title
      expect(find.text('Test Product'), findsNWidgets(2)); // card + dialog
      // Dialog should have cancel and save buttons
      expect(find.byType(AlertDialog), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('search filters products', (tester) async {
      tester.view.physicalSize = const Size(500, 900);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final products = [
        createTestProduct(id: 'p1', name: 'Apple Juice', price: 10.0),
        createTestProduct(id: 'p2', name: 'Orange Soda', price: 8.0),
      ];

      await tester.pumpWidget(
        buildScreen(productsValue: AsyncValue.data(products)),
      );
      await tester.pumpAndSettle();

      // Both products visible initially
      expect(find.text('Apple Juice'), findsOneWidget);
      expect(find.text('Orange Soda'), findsOneWidget);

      // Type in search
      await tester.enterText(find.byType(TextField), 'Apple');
      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Only Apple Juice should be visible
      expect(find.text('Apple Juice'), findsOneWidget);
      expect(find.text('Orange Soda'), findsNothing);

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
