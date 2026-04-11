import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_reports/alhai_reports.dart';

void main() {
  group('ReportExportState', () {
    test('default constructor has expected defaults', () {
      const state = ReportExportState();
      expect(state.isExporting, isFalse);
      expect(state.error, isNull);
      expect(state.exportPath, isNull);
    });

    test('copyWith preserves existing values when not overridden', () {
      const state = ReportExportState(
        isExporting: true,
        error: 'some error',
        exportPath: '/path',
      );
      final copy = state.copyWith();
      expect(copy.isExporting, isTrue);
    });

    test('copyWith overrides specified values', () {
      const state = ReportExportState();
      final updated = state.copyWith(isExporting: true, error: 'Export failed');
      expect(updated.isExporting, isTrue);
      expect(updated.error, equals('Export failed'));
    });
  });

  group('ReportPeriod provider defaults', () {
    test('ReportPeriod.today is default value', () {
      // The selectedReportPeriodProvider defaults to today
      expect(ReportPeriod.today.arabicName, isNotEmpty);
    });

    test('all ReportPeriod values have Arabic names', () {
      for (final period in ReportPeriod.values) {
        expect(
          period.arabicName,
          isNotEmpty,
          reason: '${period.name} should have an Arabic name',
        );
      }
    });
  });

  group('Report model constructors from providers', () {
    test('SalesReport with empty lists is valid', () {
      final report = SalesReport(
        period: DateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 2)),
        stats: SalesStats(
          count: 0,
          total: 0,
          average: 0,
          maxSale: 0,
          minSale: 0,
        ),
      );

      expect(report.hourlySales, isEmpty);
      expect(report.dailySales, isEmpty);
      expect(report.paymentMethods, isEmpty);
      expect(report.topProducts, isEmpty);
      expect(report.cashierPerformance, isEmpty);
      expect(report.comparison, isNull);
    });

    test('InventoryReport with empty lists is valid', () {
      const report = InventoryReport(
        totalProducts: 0,
        lowStockCount: 0,
        outOfStockCount: 0,
        totalValue: 0,
      );

      expect(report.lowStockItems, isEmpty);
      expect(report.byCategory, isEmpty);
    });

    test('DashboardSummary computes salesChangePercent', () {
      const summary = DashboardSummary(
        todaySales: 1500,
        todayTransactions: 15,
        yesterdaySales: 1000,
        lowStockCount: 2,
        outOfStockCount: 1,
        newCustomersToday: 3,
        pointsEarnedToday: 50,
      );

      expect(summary.salesChangePercent, equals(50.0));
      expect(summary.isImproving, isTrue);
    });
  });
}
