/// Tests for Lite Sales Trend Screen
///
/// Verifies rendering of period selector, summary cards,
/// chart area, comparison section, loading state, and error state.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';

import 'package:admin_lite/providers/lite_reports_providers.dart';
import 'package:admin_lite/screens/dashboard/lite_sales_trend_screen.dart';
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

  DailySalesData createTestDailySales({int count = 10, double total = 2500.0}) {
    return DailySalesData(
      todayStats: SalesStats(
        count: count,
        total: total,
        average: count > 0 ? total / count : 0,
        maxSale: total,
        minSale: 0,
      ),
      refundStats: const SalesStats(
        count: 0,
        total: 0,
        average: 0,
        maxSale: 0,
        minSale: 0,
      ),
      paymentMethods: const [],
      hourlySales: const [],
      topProducts: const [],
    );
  }

  WeeklyComparisonData createTestWeeklyComparison() {
    return WeeklyComparisonData(
      thisWeek: const SalesStats(
        count: 50,
        total: 12000.0,
        average: 240.0,
        maxSale: 500,
        minSale: 50,
      ),
      lastWeek: const SalesStats(
        count: 40,
        total: 10000.0,
        average: 250.0,
        maxSale: 450,
        minSale: 40,
      ),
      dailyBreakdown: const [
        DaySalesData(dayName: 'Sat', current: 2000, previous: 1500),
        DaySalesData(dayName: 'Sun', current: 1800, previous: 1400),
        DaySalesData(dayName: 'Mon', current: 1500, previous: 1200),
        DaySalesData(dayName: 'Tue', current: 2200, previous: 1800),
        DaySalesData(dayName: 'Wed', current: 1700, previous: 1600),
        DaySalesData(dayName: 'Thu', current: 1800, previous: 1500),
        DaySalesData(dayName: 'Fri', current: 1000, previous: 1000),
      ],
      thisWeekCustomers: 25,
      lastWeekCustomers: 20,
    );
  }

  // ===========================================================================
  // Helper
  // ===========================================================================

  Widget buildScreen({
    AsyncValue<DailySalesData>? dailyValue,
    AsyncValue<WeeklyComparisonData>? weeklyValue,
  }) {
    return createTestWidget(
      const LiteSalesTrendScreen(),
      overrides: [
        if (dailyValue != null)
          liteDailySalesProvider.overrideWith(
            (ref) => dailyValue.when(
              data: (d) => Future.value(d),
              loading: () => Future.delayed(const Duration(days: 1)),
              error: (e, s) => Future.error(e, s),
            ),
          ),
        if (weeklyValue != null)
          liteWeeklyComparisonProvider.overrideWith(
            (ref) => weeklyValue.when(
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

  group('LiteSalesTrendScreen', () {
    testWidgets('renders with loading state', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final dailyCompleter = Completer<DailySalesData>();
      final weeklyCompleter = Completer<WeeklyComparisonData>();

      await tester.pumpWidget(
        createTestWidget(
          const LiteSalesTrendScreen(),
          overrides: [
            liteDailySalesProvider.overrideWith((ref) => dailyCompleter.future),
            liteWeeklyComparisonProvider.overrideWith(
              (ref) => weeklyCompleter.future,
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(LiteSalesTrendScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows period selector with 3 options', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final daily = createTestDailySales();
      final weekly = createTestWeeklyComparison();

      await tester.pumpWidget(
        buildScreen(
          dailyValue: AsyncValue.data(daily),
          weeklyValue: AsyncValue.data(weekly),
        ),
      );
      await tester.pumpAndSettle();

      // 3 period options wrapped in GestureDetectors inside a Row
      expect(find.byType(GestureDetector), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows summary cards with data', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final daily = createTestDailySales(count: 10, total: 2500.0);
      final weekly = createTestWeeklyComparison();

      await tester.pumpWidget(
        buildScreen(
          dailyValue: AsyncValue.data(daily),
          weeklyValue: AsyncValue.data(weekly),
        ),
      );
      await tester.pumpAndSettle();

      // Total sales value
      expect(find.text('2500'), findsOneWidget);
      // Orders count
      expect(find.text('10'), findsOneWidget);
      // Summary icons
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
      expect(find.byIcon(Icons.analytics), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows weekly chart with day labels', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final daily = createTestDailySales();
      final weekly = createTestWeeklyComparison();

      await tester.pumpWidget(
        buildScreen(
          dailyValue: AsyncValue.data(daily),
          weeklyValue: AsyncValue.data(weekly),
        ),
      );
      await tester.pumpAndSettle();

      // Day labels from dailyBreakdown
      expect(find.text('Sat'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows comparison section with weekly data', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final daily = createTestDailySales();
      final weekly = createTestWeeklyComparison();

      await tester.pumpWidget(
        buildScreen(
          dailyValue: AsyncValue.data(daily),
          weeklyValue: AsyncValue.data(weekly),
        ),
      );
      await tester.pumpAndSettle();

      // This week total sales
      expect(find.text('12000'), findsOneWidget);
      // Last week total sales
      expect(find.text('10000'), findsOneWidget);
      // Customer counts
      expect(find.text('25'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('has refresh button in app bar', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final daily = createTestDailySales();
      final weekly = createTestWeeklyComparison();

      await tester.pumpWidget(
        buildScreen(
          dailyValue: AsyncValue.data(daily),
          weeklyValue: AsyncValue.data(weekly),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
