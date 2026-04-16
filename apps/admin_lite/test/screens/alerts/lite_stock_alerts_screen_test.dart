/// Tests for Lite Stock Alerts Screen
///
/// Verifies rendering of stock alert items, filter tabs,
/// loading state, error state, and empty state.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';

import 'package:admin_lite/providers/lite_alerts_providers.dart';
import 'package:admin_lite/screens/alerts/lite_stock_alerts_screen.dart';
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
    AsyncValue<List<ProductsTableData>>? alertsValue,
  }) {
    return createTestWidget(
      const LiteStockAlertsScreen(),
      overrides: [
        if (alertsValue != null)
          liteStockAlertsProvider.overrideWith(
            (ref) => alertsValue.when(
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

  group('LiteStockAlertsScreen', () {
    testWidgets('renders with loading state', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final completer = Completer<List<ProductsTableData>>();

      await tester.pumpWidget(
        createTestWidget(
          const LiteStockAlertsScreen(),
          overrides: [
            liteStockAlertsProvider.overrideWith((ref) => completer.future),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(LiteStockAlertsScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows filter tabs', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        buildScreen(alertsValue: const AsyncValue.data([])),
      );
      await tester.pumpAndSettle();

      // Filter chips should be present (All, Out of Stock, Low)
      expect(find.byType(FilterChip), findsNWidgets(3));

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows stock alert product names', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final products = [
        createTestProduct(
          id: 'p1',
          name: 'Low Stock Product',
          stockQty: 2,
          minQty: 10,
        ),
        createTestProduct(
          id: 'p2',
          name: 'Out of Stock Product',
          stockQty: 0,
          minQty: 5,
        ),
      ];

      await tester.pumpWidget(
        buildScreen(alertsValue: AsyncValue.data(products)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Low Stock Product'), findsOneWidget);
      expect(find.text('Out of Stock Product'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('handles error state', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        buildScreen(
          alertsValue: AsyncValue.error(
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
