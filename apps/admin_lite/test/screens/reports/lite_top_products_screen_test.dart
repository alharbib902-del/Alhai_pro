/// Tests for Lite Top Products Screen
///
/// Verifies rendering of top product tiles, sort toggle,
/// loading state, error state, and empty state.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:admin_lite/providers/lite_reports_providers.dart';
import 'package:admin_lite/screens/reports/lite_top_products_screen.dart';
import '../../helpers/mock_database.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase db;

  setUpAll(() => registerLiteFallbackValues());

  setUp(() {
    db = setupMockDatabase();
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  // ===========================================================================
  // Factory helpers
  // ===========================================================================

  TopProductData createTestTopProduct({
    String name = 'Product A',
    double revenue = 1000.0,
    int quantity = 50,
    String productId = 'prod-1',
  }) {
    return TopProductData(
      name: name,
      revenue: revenue,
      quantity: quantity,
      productId: productId,
    );
  }

  // ===========================================================================
  // Helper
  // ===========================================================================

  Widget buildScreen({AsyncValue<List<TopProductData>>? productsValue}) {
    return createTestWidget(
      const LiteTopProductsScreen(),
      overrides: [
        if (productsValue != null)
          liteTopProductsProvider.overrideWith(
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

  group('LiteTopProductsScreen', () {
    testWidgets('renders with loading state', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final completer = Completer<List<TopProductData>>();

      await tester.pumpWidget(
        createTestWidget(
          const LiteTopProductsScreen(),
          overrides: [
            liteTopProductsProvider.overrideWith((ref) => completer.future),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(LiteTopProductsScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows sort toggle chips', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        buildScreen(productsValue: const AsyncValue.data([])),
      );
      await tester.pumpAndSettle();

      // 2 sort chips: Revenue and Quantity
      expect(find.byType(FilterChip), findsNWidgets(2));

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows product tiles with data', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final products = [
        createTestTopProduct(
          name: 'Top Product A',
          revenue: 5000.0,
          quantity: 100,
          productId: 'p1',
        ),
        createTestTopProduct(
          name: 'Top Product B',
          revenue: 3000.0,
          quantity: 50,
          productId: 'p2',
        ),
      ];

      await tester.pumpWidget(
        buildScreen(productsValue: AsyncValue.data(products)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Top Product A'), findsOneWidget);
      expect(find.text('Top Product B'), findsOneWidget);
      // Revenue values
      expect(find.text('5000'), findsOneWidget);
      expect(find.text('3000'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows rank numbers for products', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final products = [
        createTestTopProduct(name: 'First', productId: 'p1'),
        createTestTopProduct(name: 'Second', productId: 'p2'),
      ];

      await tester.pumpWidget(
        buildScreen(productsValue: AsyncValue.data(products)),
      );
      await tester.pumpAndSettle();

      // Rank numbers
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows quantity units', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final products = [createTestTopProduct(quantity: 75, productId: 'p1')];

      await tester.pumpWidget(
        buildScreen(productsValue: AsyncValue.data(products)),
      );
      await tester.pumpAndSettle();

      expect(find.text('75 units'), findsOneWidget);

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
