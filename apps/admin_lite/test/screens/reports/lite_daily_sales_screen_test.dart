/// Tests for Lite Daily Sales Screen
///
/// Verifies rendering of daily sales totals, payment methods breakdown,
/// hourly chart, loading state, and error state.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';

import 'package:admin_lite/providers/lite_reports_providers.dart';
import 'package:admin_lite/screens/reports/lite_daily_sales_screen.dart';
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
  // Factory helpers
  // ===========================================================================

  DailySalesData createTestDailySales({
    int salesCount = 12,
    double salesTotal = 3500.0,
    double refundTotal = 150.0,
    List<PaymentMethodStats>? paymentMethods,
    List<HourlySales>? hourlySales,
    List<ProductsTableData>? topProducts,
  }) {
    return DailySalesData(
      todayStats: SalesStats(
        count: salesCount,
        total: salesTotal,
        average: salesCount > 0 ? salesTotal / salesCount : 0,
        maxSale: salesTotal,
        minSale: 0,
      ),
      refundStats: SalesStats(
        count: 1,
        total: refundTotal,
        average: refundTotal,
        maxSale: refundTotal,
        minSale: refundTotal,
      ),
      paymentMethods: paymentMethods ??
          [
            const PaymentMethodStats(method: 'cash', count: 8, total: 2000.0),
            const PaymentMethodStats(method: 'card', count: 4, total: 1500.0),
          ],
      hourlySales: hourlySales ?? [],
      topProducts: topProducts ?? [],
    );
  }

  // ===========================================================================
  // Helper
  // ===========================================================================

  Widget buildScreen({
    AsyncValue<DailySalesData>? salesValue,
  }) {
    return createTestWidget(
      const LiteDailySalesScreen(),
      overrides: [
        if (salesValue != null)
          liteDailySalesProvider.overrideWith(
            (ref) => salesValue.when(
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

  group('LiteDailySalesScreen', () {
    testWidgets('renders with loading state', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final completer = Completer<DailySalesData>();

      await tester.pumpWidget(
        createTestWidget(
          const LiteDailySalesScreen(),
          overrides: [
            liteDailySalesProvider.overrideWith((ref) => completer.future),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(LiteDailySalesScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows sales totals with data', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final data = createTestDailySales(
        salesCount: 12,
        salesTotal: 3500.0,
        refundTotal: 150.0,
      );

      await tester.pumpWidget(
        buildScreen(salesValue: AsyncValue.data(data)),
      );
      await tester.pumpAndSettle();

      // Total sales value
      expect(find.text('3500'), findsOneWidget);
      // Order count
      expect(find.text('12'), findsOneWidget);
      // Refund total
      expect(find.text('150'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows sales total icons', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        buildScreen(salesValue: AsyncValue.data(createTestDailySales())),
      );
      await tester.pumpAndSettle();

      // Icons for total sales, orders, refunds
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.byIcon(Icons.receipt), findsOneWidget);
      expect(find.byIcon(Icons.undo), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows payment method breakdown', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final data = createTestDailySales(
        paymentMethods: [
          const PaymentMethodStats(method: 'cash', count: 8, total: 2000.0),
          const PaymentMethodStats(method: 'card', count: 4, total: 1500.0),
        ],
      );

      await tester.pumpWidget(
        buildScreen(salesValue: AsyncValue.data(data)),
      );
      await tester.pumpAndSettle();

      // Payment method labels
      expect(find.text('cash'), findsOneWidget);
      expect(find.text('card'), findsOneWidget);
      // Payment icon
      expect(find.byIcon(Icons.payment), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows calendar icon in app bar', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        buildScreen(salesValue: AsyncValue.data(createTestDailySales())),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('has RefreshIndicator', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        buildScreen(salesValue: AsyncValue.data(createTestDailySales())),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('handles error state with retry', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        buildScreen(
          salesValue: AsyncValue.error(
            Exception('Load error'),
            StackTrace.current,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
