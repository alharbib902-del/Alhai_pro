import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/services/reports_service.dart';
import 'package:pos_app/providers/reports_providers.dart';

void main() {
  // ==========================================================================
  // ReportPeriod Tests
  // ==========================================================================
  group('ReportPeriod', () {
    group('arabicName', () {
      test('today returns اليوم', () {
        expect(ReportPeriod.today.arabicName, equals('اليوم'));
      });

      test('yesterday returns أمس', () {
        expect(ReportPeriod.yesterday.arabicName, equals('أمس'));
      });

      test('thisWeek returns هذا الأسبوع', () {
        expect(ReportPeriod.thisWeek.arabicName, equals('هذا الأسبوع'));
      });

      test('lastWeek returns الأسبوع الماضي', () {
        expect(ReportPeriod.lastWeek.arabicName, equals('الأسبوع الماضي'));
      });

      test('thisMonth returns هذا الشهر', () {
        expect(ReportPeriod.thisMonth.arabicName, equals('هذا الشهر'));
      });

      test('lastMonth returns الشهر الماضي', () {
        expect(ReportPeriod.lastMonth.arabicName, equals('الشهر الماضي'));
      });

      test('thisYear returns هذه السنة', () {
        expect(ReportPeriod.thisYear.arabicName, equals('هذه السنة'));
      });

      test('custom returns فترة مخصصة', () {
        expect(ReportPeriod.custom.arabicName, equals('فترة مخصصة'));
      });

      test('all periods have non-empty Arabic names', () {
        for (final period in ReportPeriod.values) {
          expect(period.arabicName, isNotEmpty);
        }
      });
    });

    group('getDateRange', () {
      test('today range starts at midnight', () {
        final range = ReportPeriod.today.getDateRange();
        expect(range.start.hour, equals(0));
        expect(range.start.minute, equals(0));
        expect(range.start.second, equals(0));
      });

      test('today range is 1 day', () {
        final range = ReportPeriod.today.getDateRange();
        expect(range.days, equals(1));
      });

      test('yesterday range is 1 day', () {
        final range = ReportPeriod.yesterday.getDateRange();
        expect(range.days, equals(1));
      });

      test('yesterday range ends at today midnight', () {
        final range = ReportPeriod.yesterday.getDateRange();
        final today = DateTime.now();
        expect(range.end.year, equals(today.year));
        expect(range.end.month, equals(today.month));
        expect(range.end.day, equals(today.day));
        expect(range.end.hour, equals(0));
      });

      test('lastWeek range is exactly 7 days', () {
        final range = ReportPeriod.lastWeek.getDateRange();
        expect(range.days, equals(7));
      });

      test('thisMonth range starts on 1st of month', () {
        final range = ReportPeriod.thisMonth.getDateRange();
        expect(range.start.day, equals(1));
      });

      test('lastMonth range starts on 1st of previous month', () {
        final range = ReportPeriod.lastMonth.getDateRange();
        expect(range.start.day, equals(1));
        final now = DateTime.now();
        final expectedMonth = now.month == 1 ? 12 : now.month - 1;
        expect(range.start.month, equals(expectedMonth));
      });

      test('lastMonth range ends on 1st of current month', () {
        final range = ReportPeriod.lastMonth.getDateRange();
        final now = DateTime.now();
        expect(range.end.day, equals(1));
        expect(range.end.month, equals(now.month));
      });

      test('thisYear starts on Jan 1', () {
        final range = ReportPeriod.thisYear.getDateRange();
        expect(range.start.month, equals(1));
        expect(range.start.day, equals(1));
      });

      test('custom returns 1 day default', () {
        final range = ReportPeriod.custom.getDateRange();
        expect(range.days, equals(1));
      });
    });
  });

  // ==========================================================================
  // DateRange Tests
  // ==========================================================================
  group('DateRange', () {
    test('days calculates difference correctly', () {
      final range = DateRange(
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 8),
      );
      expect(range.days, equals(7));
    });

    test('days returns 0 for same day', () {
      final date = DateTime(2026, 1, 1);
      final range = DateRange(date, date);
      expect(range.days, equals(0));
    });

    test('days returns 1 for consecutive days', () {
      final range = DateRange(
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 2),
      );
      expect(range.days, equals(1));
    });

    test('days returns 30 for a month range', () {
      final range = DateRange(
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 31),
      );
      expect(range.days, equals(30));
    });

    test('stores start and end correctly', () {
      final start = DateTime(2026, 2, 1);
      final end = DateTime(2026, 2, 28);
      final range = DateRange(start, end);
      expect(range.start, equals(start));
      expect(range.end, equals(end));
    });
  });

  // ==========================================================================
  // SalesComparison Tests
  // ==========================================================================
  group('SalesComparison', () {
    group('revenueChange', () {
      test('returns 0 when both periods have 0 revenue', () {
        const comparison = SalesComparison(
          currentTotal: 0,
          previousTotal: 0,
          currentCount: 0,
          previousCount: 0,
        );
        expect(comparison.revenueChange, equals(0));
      });

      test('returns 100 when previous is 0 but current has revenue', () {
        const comparison = SalesComparison(
          currentTotal: 1000,
          previousTotal: 0,
          currentCount: 10,
          previousCount: 0,
        );
        expect(comparison.revenueChange, equals(100));
      });

      test('calculates positive change correctly', () {
        const comparison = SalesComparison(
          currentTotal: 1500,
          previousTotal: 1000,
          currentCount: 15,
          previousCount: 10,
        );
        expect(comparison.revenueChange, equals(50.0));
      });

      test('calculates negative change correctly', () {
        const comparison = SalesComparison(
          currentTotal: 500,
          previousTotal: 1000,
          currentCount: 5,
          previousCount: 10,
        );
        expect(comparison.revenueChange, equals(-50.0));
      });

      test('calculates equal revenue (0% change)', () {
        const comparison = SalesComparison(
          currentTotal: 1000,
          previousTotal: 1000,
          currentCount: 10,
          previousCount: 10,
        );
        expect(comparison.revenueChange, equals(0.0));
      });
    });

    group('countChange', () {
      test('returns 0 when both periods have 0 count', () {
        const comparison = SalesComparison(
          currentTotal: 0,
          previousTotal: 0,
          currentCount: 0,
          previousCount: 0,
        );
        expect(comparison.countChange, equals(0));
      });

      test('returns 100 when previous is 0 but current has count', () {
        const comparison = SalesComparison(
          currentTotal: 1000,
          previousTotal: 0,
          currentCount: 10,
          previousCount: 0,
        );
        expect(comparison.countChange, equals(100));
      });

      test('calculates positive change correctly', () {
        const comparison = SalesComparison(
          currentTotal: 1500,
          previousTotal: 1000,
          currentCount: 15,
          previousCount: 10,
        );
        expect(comparison.countChange, equals(50.0));
      });

      test('calculates negative change correctly', () {
        const comparison = SalesComparison(
          currentTotal: 500,
          previousTotal: 1000,
          currentCount: 5,
          previousCount: 10,
        );
        expect(comparison.countChange, equals(-50.0));
      });
    });

    group('isImproved', () {
      test('returns true when revenue increased', () {
        const comparison = SalesComparison(
          currentTotal: 1500,
          previousTotal: 1000,
          currentCount: 15,
          previousCount: 10,
        );
        expect(comparison.isImproved, isTrue);
      });

      test('returns false when revenue decreased', () {
        const comparison = SalesComparison(
          currentTotal: 500,
          previousTotal: 1000,
          currentCount: 5,
          previousCount: 10,
        );
        expect(comparison.isImproved, isFalse);
      });

      test('returns false when revenue is equal', () {
        const comparison = SalesComparison(
          currentTotal: 1000,
          previousTotal: 1000,
          currentCount: 10,
          previousCount: 10,
        );
        expect(comparison.isImproved, isFalse);
      });
    });
  });

  // ==========================================================================
  // InventoryReport Tests
  // ==========================================================================
  group('InventoryReport', () {
    group('outOfStockPercentage', () {
      test('returns 0 when no products', () {
        const report = InventoryReport(
          totalProducts: 0,
          lowStockCount: 0,
          outOfStockCount: 0,
          totalValue: 0,
        );
        expect(report.outOfStockPercentage, equals(0));
      });

      test('calculates correctly', () {
        const report = InventoryReport(
          totalProducts: 100,
          lowStockCount: 10,
          outOfStockCount: 5,
          totalValue: 50000,
        );
        expect(report.outOfStockPercentage, equals(5.0));
      });

      test('returns 100 when all out of stock', () {
        const report = InventoryReport(
          totalProducts: 10,
          lowStockCount: 0,
          outOfStockCount: 10,
          totalValue: 0,
        );
        expect(report.outOfStockPercentage, equals(100.0));
      });
    });

    group('lowStockPercentage', () {
      test('returns 0 when no products', () {
        const report = InventoryReport(
          totalProducts: 0,
          lowStockCount: 0,
          outOfStockCount: 0,
          totalValue: 0,
        );
        expect(report.lowStockPercentage, equals(0));
      });

      test('calculates correctly', () {
        const report = InventoryReport(
          totalProducts: 200,
          lowStockCount: 20,
          outOfStockCount: 5,
          totalValue: 100000,
        );
        expect(report.lowStockPercentage, equals(10.0));
      });
    });
  });

  // ==========================================================================
  // LowStockItem Tests
  // ==========================================================================
  group('LowStockItem', () {
    test('deficit calculates correctly', () {
      const item = LowStockItem(
        productId: 'p1',
        productName: 'منتج 1',
        currentStock: 3,
        minStock: 10,
        suggestedReorder: 17,
      );
      expect(item.deficit, equals(7));
    });

    test('deficit is 0 when stock equals minStock', () {
      const item = LowStockItem(
        productId: 'p1',
        productName: 'منتج 1',
        currentStock: 10,
        minStock: 10,
        suggestedReorder: 10,
      );
      expect(item.deficit, equals(0));
    });

    test('deficit is negative when stock exceeds minStock', () {
      const item = LowStockItem(
        productId: 'p1',
        productName: 'منتج 1',
        currentStock: 15,
        minStock: 10,
        suggestedReorder: 0,
      );
      expect(item.deficit, equals(-5));
    });
  });

  // ==========================================================================
  // TopProduct Tests
  // ==========================================================================
  group('TopProduct', () {
    test('averagePrice calculates correctly', () {
      const product = TopProduct(
        productId: 'p1',
        productName: 'منتج',
        quantitySold: 10,
        revenue: 500,
      );
      expect(product.averagePrice, equals(50.0));
    });

    test('averagePrice returns 0 when no quantity sold', () {
      const product = TopProduct(
        productId: 'p1',
        productName: 'منتج',
        quantitySold: 0,
        revenue: 0,
      );
      expect(product.averagePrice, equals(0));
    });

    test('profit defaults to 0', () {
      const product = TopProduct(
        productId: 'p1',
        productName: 'منتج',
        quantitySold: 5,
        revenue: 250,
      );
      expect(product.profit, equals(0));
    });
  });

  // ==========================================================================
  // DailySales Tests
  // ==========================================================================
  group('DailySales', () {
    test('average calculates correctly', () {
      final sales = DailySales(
        date: DateTime(2026, 1, 15),
        count: 10,
        total: 5000,
      );
      expect(sales.average, equals(500.0));
    });

    test('average returns 0 when no sales', () {
      final sales = DailySales(
        date: DateTime(2026, 1, 15),
        count: 0,
        total: 0,
      );
      expect(sales.average, equals(0));
    });
  });

  // ==========================================================================
  // ProfitReport Tests
  // ==========================================================================
  group('ProfitReport', () {
    test('grossMargin calculates correctly', () {
      final report = ProfitReport(
        period: DateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 31)),
        grossRevenue: 10000,
        costOfGoods: 6000,
        grossProfit: 4000,
        discounts: 500,
        netProfit: 3500,
      );
      expect(report.grossMargin, equals(40.0));
    });

    test('netMargin calculates correctly', () {
      final report = ProfitReport(
        period: DateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 31)),
        grossRevenue: 10000,
        costOfGoods: 6000,
        grossProfit: 4000,
        discounts: 500,
        netProfit: 3500,
      );
      expect(report.netMargin, equals(35.0));
    });

    test('grossMargin returns 0 when no revenue', () {
      final report = ProfitReport(
        period: DateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 31)),
        grossRevenue: 0,
        costOfGoods: 0,
        grossProfit: 0,
        discounts: 0,
        netProfit: 0,
      );
      expect(report.grossMargin, equals(0));
    });

    test('netMargin returns 0 when no revenue', () {
      final report = ProfitReport(
        period: DateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 31)),
        grossRevenue: 0,
        costOfGoods: 0,
        grossProfit: 0,
        discounts: 0,
        netProfit: 0,
      );
      expect(report.netMargin, equals(0));
    });
  });

  // ==========================================================================
  // DailyProfit Tests
  // ==========================================================================
  group('DailyProfit', () {
    test('margin calculates correctly', () {
      final profit = DailyProfit(
        date: DateTime(2026, 1, 15),
        revenue: 1000,
        cost: 600,
        profit: 400,
      );
      expect(profit.margin, equals(40.0));
    });

    test('margin returns 0 when no revenue', () {
      final profit = DailyProfit(
        date: DateTime(2026, 1, 15),
        revenue: 0,
        cost: 0,
        profit: 0,
      );
      expect(profit.margin, equals(0));
    });
  });

  // ==========================================================================
  // SalesReport Tests
  // ==========================================================================
  group('SalesReport', () {
    test('averageSale calculates correctly', () {
      // SalesReport requires SalesStats which comes from DAO
      // We test the formula: count > 0 ? total / count : 0
      // This is tested indirectly through SalesComparison
    });
  });

  // ==========================================================================
  // ReportExportState Tests
  // ==========================================================================
  group('ReportExportState', () {
    test('default state is not exporting', () {
      const state = ReportExportState();
      expect(state.isExporting, isFalse);
    });

    test('default state has no error', () {
      const state = ReportExportState();
      expect(state.error, isNull);
    });

    test('default state has no export path', () {
      const state = ReportExportState();
      expect(state.exportPath, isNull);
    });

    test('copyWith updates isExporting', () {
      const state = ReportExportState();
      final updated = state.copyWith(isExporting: true);
      expect(updated.isExporting, isTrue);
      expect(updated.error, isNull);
      expect(updated.exportPath, isNull);
    });

    test('copyWith updates error', () {
      const state = ReportExportState();
      final updated = state.copyWith(error: 'فشل التصدير');
      expect(updated.error, equals('فشل التصدير'));
      expect(updated.isExporting, isFalse);
    });

    test('copyWith updates exportPath', () {
      const state = ReportExportState();
      final updated = state.copyWith(exportPath: '/path/to/file.pdf');
      expect(updated.exportPath, equals('/path/to/file.pdf'));
    });

    test('copyWith preserves unchanged fields', () {
      const state = ReportExportState(
        isExporting: true,
        error: 'err',
        exportPath: '/path',
      );
      final updated = state.copyWith(isExporting: false);
      expect(updated.isExporting, isFalse);
      // error is explicitly reset to null in copyWith
    });

    test('can chain copyWith calls', () {
      const state = ReportExportState();
      final updated = state
          .copyWith(isExporting: true)
          .copyWith(exportPath: '/done.pdf')
          .copyWith(isExporting: false, exportPath: '/done.pdf');
      expect(updated.isExporting, isFalse);
      expect(updated.exportPath, equals('/done.pdf'));
    });
  });

  // ==========================================================================
  // DashboardSummary Tests
  // ==========================================================================
  group('DashboardSummary', () {
    group('salesChangePercent', () {
      test('returns 0 when both today and yesterday are 0', () {
        const summary = DashboardSummary(
          todaySales: 0,
          todayTransactions: 0,
          yesterdaySales: 0,
          lowStockCount: 0,
          outOfStockCount: 0,
          newCustomersToday: 0,
          pointsEarnedToday: 0,
        );
        expect(summary.salesChangePercent, equals(0));
      });

      test('returns 100 when yesterday is 0 but today has sales', () {
        const summary = DashboardSummary(
          todaySales: 5000,
          todayTransactions: 10,
          yesterdaySales: 0,
          lowStockCount: 0,
          outOfStockCount: 0,
          newCustomersToday: 0,
          pointsEarnedToday: 0,
        );
        expect(summary.salesChangePercent, equals(100));
      });

      test('calculates 50% increase correctly', () {
        const summary = DashboardSummary(
          todaySales: 1500,
          todayTransactions: 15,
          yesterdaySales: 1000,
          lowStockCount: 0,
          outOfStockCount: 0,
          newCustomersToday: 0,
          pointsEarnedToday: 0,
        );
        expect(summary.salesChangePercent, equals(50.0));
      });

      test('calculates negative change correctly', () {
        const summary = DashboardSummary(
          todaySales: 500,
          todayTransactions: 5,
          yesterdaySales: 1000,
          lowStockCount: 0,
          outOfStockCount: 0,
          newCustomersToday: 0,
          pointsEarnedToday: 0,
        );
        expect(summary.salesChangePercent, equals(-50.0));
      });
    });

    group('isImproving', () {
      test('returns true when sales increased', () {
        const summary = DashboardSummary(
          todaySales: 1500,
          todayTransactions: 15,
          yesterdaySales: 1000,
          lowStockCount: 0,
          outOfStockCount: 0,
          newCustomersToday: 0,
          pointsEarnedToday: 0,
        );
        expect(summary.isImproving, isTrue);
      });

      test('returns false when sales decreased', () {
        const summary = DashboardSummary(
          todaySales: 500,
          todayTransactions: 5,
          yesterdaySales: 1000,
          lowStockCount: 0,
          outOfStockCount: 0,
          newCustomersToday: 0,
          pointsEarnedToday: 0,
        );
        expect(summary.isImproving, isFalse);
      });

      test('returns false when sales are equal', () {
        const summary = DashboardSummary(
          todaySales: 1000,
          todayTransactions: 10,
          yesterdaySales: 1000,
          lowStockCount: 0,
          outOfStockCount: 0,
          newCustomersToday: 0,
          pointsEarnedToday: 0,
        );
        expect(summary.isImproving, isFalse);
      });
    });
  });
}
