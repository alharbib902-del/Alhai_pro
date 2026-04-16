/// Tests for Lite Low Stock Screen
///
/// Verifies rendering of low stock items, summary bar, progress indicators,
/// loading state, error state, and empty state.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';

import 'package:admin_lite/providers/lite_reports_providers.dart';
import 'package:admin_lite/screens/reports/lite_low_stock_screen.dart';
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
    AsyncValue<List<ProductsTableData>>? stockValue,
  }) {
    return createTestWidget(
      const LiteLowStockScreen(),
      overrides: [
        if (stockValue != null)
          liteLowStockProvider.overrideWith(
            (ref) => stockValue.when(
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

  group('LiteLowStockScreen', () {
    testWidgets('renders with loading state', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final completer = Completer<List<ProductsTableData>>();

      await tester.pumpWidget(
        createTestWidget(
          const LiteLowStockScreen(),
          overrides: [
            liteLowStockProvider.overrideWith((ref) => completer.future),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(LiteLowStockScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows empty state when no low stock items', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        buildScreen(stockValue: const AsyncValue.data([])),
      );
      await tester.pumpAndSettle();

      // Empty state shows check icon
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows summary bar with item count', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final products = [
        createTestProduct(
          id: 'p1',
          name: 'Product A',
          stockQty: 2,
          minQty: 10,
        ),
        createTestProduct(
          id: 'p2',
          name: 'Product B',
          stockQty: 0,
          minQty: 5,
        ),
      ];

      await tester.pumpWidget(
        buildScreen(stockValue: AsyncValue.data(products)),
      );
      await tester.pumpAndSettle();

      // Warning icon in summary bar
      expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows product names in stock list', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final products = [
        createTestProduct(
          id: 'p1',
          name: 'Low Stock Item',
          stockQty: 3,
          minQty: 10,
        ),
      ];

      await tester.pumpWidget(
        buildScreen(stockValue: AsyncValue.data(products)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Low Stock Item'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows stock level ratio', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final products = [
        createTestProduct(
          id: 'p1',
          name: 'Test Product',
          stockQty: 3,
          minQty: 10,
        ),
      ];

      await tester.pumpWidget(
        buildScreen(stockValue: AsyncValue.data(products)),
      );
      await tester.pumpAndSettle();

      // Shows current/threshold ratio
      expect(find.text('3/10'), findsOneWidget);
      // Progress indicator for stock level
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('out of stock shows error icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final products = [
        createTestProduct(
          id: 'p1',
          name: 'Out of Stock Item',
          stockQty: 0,
          minQty: 5,
        ),
      ];

      await tester.pumpWidget(
        buildScreen(stockValue: AsyncValue.data(products)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows refresh button in app bar', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        buildScreen(stockValue: const AsyncValue.data([])),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('handles error state', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        buildScreen(
          stockValue: AsyncValue.error(
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
