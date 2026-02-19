import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pos_app/services/reports_service.dart';
import 'package:pos_app/data/local/daos/sales_dao.dart';
import 'package:pos_app/data/local/daos/products_dao.dart';
import 'package:pos_app/data/local/daos/inventory_dao.dart';
import 'package:pos_app/data/local/daos/loyalty_dao.dart';

// Mock classes
class MockSalesDao extends Mock implements SalesDao {}
class MockProductsDao extends Mock implements ProductsDao {}
class MockInventoryDao extends Mock implements InventoryDao {}
class MockLoyaltyDao extends Mock implements LoyaltyDao {}

// Fake class for DateTime
class FakeDateTime extends Fake implements DateTime {}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2024, 1, 1));
  });
  group('ReportPeriod', () {
    test('has correct arabic names', () {
      expect(ReportPeriod.today.arabicName, 'اليوم');
      expect(ReportPeriod.yesterday.arabicName, 'أمس');
      expect(ReportPeriod.thisWeek.arabicName, 'هذا الأسبوع');
      expect(ReportPeriod.lastWeek.arabicName, 'الأسبوع الماضي');
      expect(ReportPeriod.thisMonth.arabicName, 'هذا الشهر');
      expect(ReportPeriod.lastMonth.arabicName, 'الشهر الماضي');
      expect(ReportPeriod.thisYear.arabicName, 'هذه السنة');
      expect(ReportPeriod.custom.arabicName, 'فترة مخصصة');
    });

    test('today returns correct date range', () {
      final range = ReportPeriod.today.getDateRange();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      expect(range.start, today);
      expect(range.end, today.add(const Duration(days: 1)));
      expect(range.days, 1);
    });

    test('yesterday returns correct date range', () {
      final range = ReportPeriod.yesterday.getDateRange();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      expect(range.start, yesterday);
      expect(range.end, today);
    });

    test('thisMonth returns correct date range', () {
      final range = ReportPeriod.thisMonth.getDateRange();
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      expect(range.start, startOfMonth);
      expect(range.end.isAfter(startOfMonth), true);
    });
  });

  group('DateRange', () {
    test('calculates days correctly', () {
      final range = DateRange(
        DateTime(2024, 1, 1),
        DateTime(2024, 1, 8),
      );

      expect(range.days, 7);
    });

    test('same day returns 0 days', () {
      final date = DateTime(2024, 1, 1);
      final range = DateRange(date, date);

      expect(range.days, 0);
    });
  });

  group('SalesReport', () {
    test('calculates average sale correctly', () {
      final report = SalesReport(
        period: DateRange(DateTime.now(), DateTime.now()),
        stats: const SalesStats(
          count: 10,
          total: 1000.0,
          average: 100.0,
          maxSale: 200.0,
          minSale: 50.0,
        ),
      );

      expect(report.averageSale, 100.0);
    });

    test('average sale is 0 when count is 0', () {
      final report = SalesReport(
        period: DateRange(DateTime.now(), DateTime.now()),
        stats: const SalesStats(
          count: 0,
          total: 0,
          average: 0,
          maxSale: 0,
          minSale: 0,
        ),
      );

      expect(report.averageSale, 0);
    });

    test('calculates daily average correctly', () {
      final report = SalesReport(
        period: DateRange(
          DateTime(2024, 1, 1),
          DateTime(2024, 1, 8), // 7 days
        ),
        stats: const SalesStats(
          count: 70,
          total: 7000.0,
          average: 100.0,
          maxSale: 200.0,
          minSale: 50.0,
        ),
      );

      expect(report.dailyAverage, 1000.0); // 7000 / 7
    });
  });

  group('DailySales', () {
    test('calculates average correctly', () {
      final daily = DailySales(
        date: DateTime(2024, 1, 15),
        count: 10,
        total: 500.0,
      );

      expect(daily.average, 50.0);
    });

    test('average is 0 when count is 0', () {
      final daily = DailySales(
        date: DateTime(2024, 1, 15),
        count: 0,
        total: 0,
      );

      expect(daily.average, 0);
    });
  });

  group('TopProduct', () {
    test('calculates average price correctly', () {
      const product = TopProduct(
        productId: 'prod-1',
        productName: 'Test Product',
        quantitySold: 50,
        revenue: 500.0,
        profit: 100.0,
      );

      expect(product.averagePrice, 10.0);
    });

    test('average price is 0 when quantity is 0', () {
      const product = TopProduct(
        productId: 'prod-1',
        productName: 'Test Product',
        quantitySold: 0,
        revenue: 0,
      );

      expect(product.averagePrice, 0);
    });
  });

  group('SalesComparison', () {
    test('calculates revenue change correctly', () {
      const comparison = SalesComparison(
        currentTotal: 1200.0,
        previousTotal: 1000.0,
        currentCount: 12,
        previousCount: 10,
      );

      expect(comparison.revenueChange, 20.0); // 20% increase
      expect(comparison.isImproved, true);
    });

    test('calculates negative change correctly', () {
      const comparison = SalesComparison(
        currentTotal: 800.0,
        previousTotal: 1000.0,
        currentCount: 8,
        previousCount: 10,
      );

      expect(comparison.revenueChange, -20.0); // 20% decrease
      expect(comparison.isImproved, false);
    });

    test('handles zero previous total', () {
      const comparison = SalesComparison(
        currentTotal: 1000.0,
        previousTotal: 0,
        currentCount: 10,
        previousCount: 0,
      );

      expect(comparison.revenueChange, 100.0);
    });

    test('handles zero current total', () {
      const comparison = SalesComparison(
        currentTotal: 0,
        previousTotal: 0,
        currentCount: 0,
        previousCount: 0,
      );

      expect(comparison.revenueChange, 0);
    });

    test('calculates count change correctly', () {
      const comparison = SalesComparison(
        currentTotal: 1000.0,
        previousTotal: 1000.0,
        currentCount: 15,
        previousCount: 10,
      );

      expect(comparison.countChange, 50.0); // 50% increase
    });
  });

  group('InventoryReport', () {
    test('calculates out of stock percentage correctly', () {
      const report = InventoryReport(
        totalProducts: 100,
        lowStockCount: 10,
        outOfStockCount: 5,
        totalValue: 10000.0,
      );

      expect(report.outOfStockPercentage, 5.0);
      expect(report.lowStockPercentage, 10.0);
    });

    test('handles zero products', () {
      const report = InventoryReport(
        totalProducts: 0,
        lowStockCount: 0,
        outOfStockCount: 0,
        totalValue: 0,
      );

      expect(report.outOfStockPercentage, 0);
      expect(report.lowStockPercentage, 0);
    });
  });

  group('LowStockItem', () {
    test('calculates deficit correctly', () {
      const item = LowStockItem(
        productId: 'prod-1',
        productName: 'Test',
        currentStock: 3,
        minStock: 10,
        suggestedReorder: 20,
      );

      expect(item.deficit, 7);
    });
  });

  group('ProfitReport', () {
    test('calculates margins correctly', () {
      final report = ProfitReport(
        period: DateRange(DateTime(2024, 1, 1), DateTime(2024, 1, 31)),
        grossRevenue: 10000.0,
        costOfGoods: 6000.0,
        grossProfit: 4000.0,
        discounts: 500.0,
        netProfit: 3500.0,
      );

      expect(report.grossMargin, 40.0); // 4000/10000 * 100
      expect(report.netMargin, 35.0); // 3500/10000 * 100
    });

    test('handles zero revenue', () {
      final report = ProfitReport(
        period: DateRange(DateTime(2024, 1, 1), DateTime(2024, 1, 31)),
        grossRevenue: 0,
        costOfGoods: 0,
        grossProfit: 0,
        discounts: 0,
        netProfit: 0,
      );

      expect(report.grossMargin, 0);
      expect(report.netMargin, 0);
    });
  });

  group('DailyProfit', () {
    test('calculates margin correctly', () {
      final daily = DailyProfit(
        date: DateTime(2024, 1, 15),
        revenue: 1000.0,
        cost: 600.0,
        profit: 400.0,
      );

      expect(daily.margin, 40.0);
    });
  });

  group('DashboardSummary', () {
    test('calculates sales change correctly', () {
      const summary = DashboardSummary(
        todaySales: 1200.0,
        todayTransactions: 12,
        yesterdaySales: 1000.0,
        lowStockCount: 5,
        outOfStockCount: 2,
        newCustomersToday: 3,
        pointsEarnedToday: 1500,
      );

      expect(summary.salesChangePercent, 20.0);
      expect(summary.isImproving, true);
    });

    test('handles zero yesterday sales', () {
      const summary = DashboardSummary(
        todaySales: 1000.0,
        todayTransactions: 10,
        yesterdaySales: 0,
        lowStockCount: 0,
        outOfStockCount: 0,
        newCustomersToday: 0,
        pointsEarnedToday: 0,
      );

      expect(summary.salesChangePercent, 100.0);
    });
  });

  group('ReportsService', () {
    late MockSalesDao mockSalesDao;
    late MockProductsDao mockProductsDao;
    late MockInventoryDao mockInventoryDao;
    late MockLoyaltyDao mockLoyaltyDao;
    late ReportsService service;

    setUp(() {
      mockSalesDao = MockSalesDao();
      mockProductsDao = MockProductsDao();
      mockInventoryDao = MockInventoryDao();
      mockLoyaltyDao = MockLoyaltyDao();

      service = ReportsService(
        salesDao: mockSalesDao,
        productsDao: mockProductsDao,
        inventoryDao: mockInventoryDao,
        loyaltyDao: mockLoyaltyDao,
      );
    });

    test('getTodayStats calls dao correctly', () async {
      when(() => mockSalesDao.getSalesStats(
        'store-1',
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        cashierId: any(named: 'cashierId'),
      )).thenAnswer((_) async => const SalesStats(
        count: 10,
        total: 1000.0,
        average: 100.0,
        maxSale: 200.0,
        minSale: 50.0,
      ));

      final result = await service.getTodayStats('store-1');

      expect(result.count, 10);
      expect(result.total, 1000.0);
      verify(() => mockSalesDao.getSalesStats(
        'store-1',
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        cashierId: null,
      )).called(1);
    });

    test('getInventoryReport calculates correctly', () async {
      when(() => mockProductsDao.getAllProducts('store-1'))
          .thenAnswer((_) async => []);

      final result = await service.getInventoryReport('store-1');

      expect(result.totalProducts, 0);
      expect(result.lowStockCount, 0);
      expect(result.outOfStockCount, 0);
    });
  });
}
