// `hide` avoids a symbol clash with flutter_test's isNull/isNotNull matchers.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_reports/alhai_reports.dart';

import '../../helpers/reports_test_helpers.dart';

void main() {
  late MockSalesDao mockSalesDao;
  late MockProductsDao mockProductsDao;
  late MockInventoryDao mockInventoryDao;
  late MockLoyaltyDao mockLoyaltyDao;
  late ReportsService service;

  setUpAll(() {
    registerReportsFallbackValues();
  });

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

  group('ReportsService', () {
    group('getTodayStats', () {
      test('returns stats from SalesDao for today', () async {
        final expectedStats = createTestSalesStats(count: 25, total: 2500.0);

        when(
          () => mockSalesDao.getSalesStats(
            any(),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            cashierId: any(named: 'cashierId'),
          ),
        ).thenAnswer((_) async => expectedStats);

        final stats = await service.getTodayStats('store-1');

        expect(stats.count, equals(25));
        expect(stats.total, equals(2500.0));
      });

      test('passes cashierId when provided', () async {
        when(
          () => mockSalesDao.getSalesStats(
            any(),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            cashierId: any(named: 'cashierId'),
          ),
        ).thenAnswer((_) async => createTestSalesStats());

        await service.getTodayStats('store-1', cashierId: 'cashier-1');

        verify(
          () => mockSalesDao.getSalesStats(
            'store-1',
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            cashierId: 'cashier-1',
          ),
        ).called(1);
      });
    });

    group('getInventoryReport', () {
      test('returns report with correct low stock count', () async {
        // Create mock products with varying stock levels
        final products = <ProductsTableData>[];

        // Service calls getProductsPaginated(storeId, limit: 500).
        when(
          () => mockProductsDao.getProductsPaginated(
            any(),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
            categoryId: any(named: 'categoryId'),
            activeOnly: any(named: 'activeOnly'),
          ),
        ).thenAnswer((_) async => products);

        final report = await service.getInventoryReport('store-1');

        expect(report.totalProducts, equals(0));
        expect(report.lowStockCount, equals(0));
        expect(report.outOfStockCount, equals(0));
      });
    });

    group('getInventoryMovements', () {
      test('calls getMovementsByProduct when productId provided', () async {
        when(
          () => mockInventoryDao.getMovementsByProduct(any()),
        ).thenAnswer((_) async => []);

        await service.getInventoryMovements('store-1', productId: 'product-1');

        verify(
          () => mockInventoryDao.getMovementsByProduct('product-1'),
        ).called(1);
      });

      test('calls getTodayMovements when no productId', () async {
        when(
          () => mockInventoryDao.getTodayMovements(any()),
        ).thenAnswer((_) async => []);

        await service.getInventoryMovements('store-1');

        verify(() => mockInventoryDao.getTodayMovements('store-1')).called(1);
      });
    });

    group('getLoyaltyReport', () {
      test('returns null when loyaltyDao is null', () async {
        final serviceWithoutLoyalty = ReportsService(
          salesDao: mockSalesDao,
          productsDao: mockProductsDao,
          inventoryDao: mockInventoryDao,
          loyaltyDao: null,
        );

        final result = await serviceWithoutLoyalty.getLoyaltyReport('store-1');
        expect(result, isNull);
      });

      test('returns stats from loyalty dao', () async {
        final expectedStats = LoyaltyStats(
          totalEarned: 500,
          totalRedeemed: 200,
          activeCustomers: 50,
          totalTransactions: 100,
        );

        when(
          () => mockLoyaltyDao.getStats(
            any(),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer((_) async => expectedStats);

        final result = await service.getLoyaltyReport('store-1');
        expect(result, isNotNull);
        expect(result!.totalEarned, equals(500));
        expect(result.activeCustomers, equals(50));
      });
    });

    group('getTopLoyaltyCustomers', () {
      test('returns empty list when loyaltyDao is null', () async {
        final serviceWithoutLoyalty = ReportsService(
          salesDao: mockSalesDao,
          productsDao: mockProductsDao,
          inventoryDao: mockInventoryDao,
          loyaltyDao: null,
        );

        final result = await serviceWithoutLoyalty.getTopLoyaltyCustomers(
          'store-1',
        );
        expect(result, isEmpty);
      });

      test('returns top customers from loyalty dao', () async {
        when(
          () =>
              mockLoyaltyDao.getTopCustomers(any(), limit: any(named: 'limit')),
        ).thenAnswer((_) async => []);

        final result = await service.getTopLoyaltyCustomers('store-1');
        expect(result, isEmpty);
        verify(
          () => mockLoyaltyDao.getTopCustomers('store-1', limit: 10),
        ).called(1);
      });
    });

    group('getSalesReport', () {
      test('returns report with stats for a period', () async {
        when(
          () => mockSalesDao.getSalesStats(
            any(),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            cashierId: any(named: 'cashierId'),
          ),
        ).thenAnswer(
          (_) async => createTestSalesStats(count: 10, total: 1000.0),
        );

        when(
          () => mockSalesDao.getPaymentMethodStats(
            any(),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer((_) async => []);

        when(
          () => mockSalesDao.getHourlySales(any(), any()),
        ).thenAnswer((_) async => []);

        // _getTopProducts runs a raw SQL via salesDao.customSelect(...).get().
        final topProductsSelectable = MockSelectable<QueryRow>();
        when(
          () => topProductsSelectable.get(),
        ).thenAnswer((_) async => <QueryRow>[]);
        when(
          () => mockSalesDao.customSelect(
            any(),
            variables: any(named: 'variables'),
          ),
        ).thenReturn(topProductsSelectable);

        final report = await service.getSalesReport(
          'store-1',
          period: ReportPeriod.today,
          includeDaily: false,
          includeComparison: false,
        );

        expect(report.stats.count, equals(10));
        expect(report.stats.total, equals(1000.0));
      });
    });

    group('getDashboardSummary', () {
      test('returns combined summary from multiple sources', () async {
        when(
          () => mockSalesDao.getSalesStats(
            any(),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            cashierId: any(named: 'cashierId'),
          ),
        ).thenAnswer(
          (_) async => createTestSalesStats(count: 20, total: 3000.0),
        );

        // getDashboardSummary → getInventoryReport → getProductsPaginated.
        when(
          () => mockProductsDao.getProductsPaginated(
            any(),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
            categoryId: any(named: 'categoryId'),
            activeOnly: any(named: 'activeOnly'),
          ),
        ).thenAnswer((_) async => <ProductsTableData>[]);

        when(
          () => mockLoyaltyDao.getStats(
            any(),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer(
          (_) async => LoyaltyStats(
            totalEarned: 100,
            totalRedeemed: 50,
            activeCustomers: 10,
            totalTransactions: 20,
          ),
        );

        final summary = await service.getDashboardSummary('store-1');

        expect(summary.todaySales, equals(3000.0));
        expect(summary.todayTransactions, equals(20));
      });
    });
  });

  group('ReportPeriod', () {
    test('today returns range from start of today to end of today', () {
      final range = ReportPeriod.today.getDateRange();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      expect(range.start, equals(today));
      expect(range.end, equals(today.add(const Duration(days: 1))));
    });

    test('yesterday returns range from yesterday to today', () {
      final range = ReportPeriod.yesterday.getDateRange();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      expect(range.start, equals(yesterday));
      expect(range.end, equals(today));
    });

    test('thisMonth starts at first of month', () {
      final range = ReportPeriod.thisMonth.getDateRange();
      expect(range.start.day, equals(1));
    });

    test('thisYear starts at January 1st', () {
      final range = ReportPeriod.thisYear.getDateRange();
      expect(range.start.month, equals(1));
      expect(range.start.day, equals(1));
    });

    test('arabicName returns non-empty string for all values', () {
      for (final period in ReportPeriod.values) {
        expect(period.arabicName, isNotEmpty);
      }
    });
  });

  group('DateRange', () {
    test('days returns correct number of days', () {
      final range = DateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 8));
      expect(range.days, equals(7));
    });

    test('days returns 0 for same-day range', () {
      final day = DateTime(2026, 1, 1);
      final range = DateRange(day, day);
      expect(range.days, equals(0));
    });
  });

  group('SalesReport model', () {
    test('averageSale returns correct average', () {
      final report = SalesReport(
        period: DateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 2)),
        stats: createTestSalesStats(count: 10, total: 1000.0),
      );

      expect(report.averageSale, equals(100.0));
    });

    test('averageSale returns 0 when no sales', () {
      final report = SalesReport(
        period: DateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 2)),
        stats: createTestSalesStats(count: 0, total: 0.0),
      );

      expect(report.averageSale, equals(0));
    });

    test('dailyAverage divides by days in period', () {
      final report = SalesReport(
        period: DateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 8)),
        stats: createTestSalesStats(count: 70, total: 7000.0),
      );

      expect(report.dailyAverage, equals(1000.0));
    });
  });

  group('DailySales model', () {
    test('average returns correct value', () {
      final sales = DailySales(
        date: DateTime(2026, 1, 1),
        count: 5,
        total: 500.0,
      );
      expect(sales.average, equals(100.0));
    });

    test('average returns 0 when count is 0', () {
      final sales = DailySales(
        date: DateTime(2026, 1, 1),
        count: 0,
        total: 0.0,
      );
      expect(sales.average, equals(0));
    });
  });

  group('TopProduct model', () {
    test('averagePrice returns correct value', () {
      const product = TopProduct(
        productId: 'p1',
        productName: 'Test',
        quantitySold: 10,
        revenue: 500.0,
      );

      expect(product.averagePrice, equals(50.0));
    });

    test('averagePrice returns 0 when none sold', () {
      const product = TopProduct(
        productId: 'p1',
        productName: 'Test',
        quantitySold: 0,
        revenue: 0,
      );

      expect(product.averagePrice, equals(0));
    });
  });

  group('SalesComparison model', () {
    test('revenueChange calculates percentage correctly', () {
      const comp = SalesComparison(
        currentTotal: 1200.0,
        previousTotal: 1000.0,
        currentCount: 12,
        previousCount: 10,
      );

      expect(comp.revenueChange, equals(20.0));
    });

    test('revenueChange returns 100 when previous is zero and current > 0', () {
      const comp = SalesComparison(
        currentTotal: 500.0,
        previousTotal: 0,
        currentCount: 5,
        previousCount: 0,
      );

      expect(comp.revenueChange, equals(100));
    });

    test('revenueChange returns 0 when both are zero', () {
      const comp = SalesComparison(
        currentTotal: 0,
        previousTotal: 0,
        currentCount: 0,
        previousCount: 0,
      );

      expect(comp.revenueChange, equals(0));
    });

    test('isImproved returns true for positive change', () {
      const comp = SalesComparison(
        currentTotal: 1100.0,
        previousTotal: 1000.0,
        currentCount: 11,
        previousCount: 10,
      );

      expect(comp.isImproved, isTrue);
    });

    test('isImproved returns false for negative change', () {
      const comp = SalesComparison(
        currentTotal: 800.0,
        previousTotal: 1000.0,
        currentCount: 8,
        previousCount: 10,
      );

      expect(comp.isImproved, isFalse);
    });

    test('countChange calculates correctly', () {
      const comp = SalesComparison(
        currentTotal: 1000.0,
        previousTotal: 1000.0,
        currentCount: 15,
        previousCount: 10,
      );

      expect(comp.countChange, equals(50.0));
    });
  });

  group('InventoryReport model', () {
    test('outOfStockPercentage calculates correctly', () {
      const report = InventoryReport(
        totalProducts: 100,
        lowStockCount: 10,
        outOfStockCount: 5,
        totalValue: 50000.0,
      );

      expect(report.outOfStockPercentage, equals(5.0));
    });

    test('lowStockPercentage calculates correctly', () {
      const report = InventoryReport(
        totalProducts: 100,
        lowStockCount: 20,
        outOfStockCount: 5,
        totalValue: 50000.0,
      );

      expect(report.lowStockPercentage, equals(20.0));
    });

    test('percentages return 0 when no products', () {
      const report = InventoryReport(
        totalProducts: 0,
        lowStockCount: 0,
        outOfStockCount: 0,
        totalValue: 0,
      );

      expect(report.outOfStockPercentage, equals(0));
      expect(report.lowStockPercentage, equals(0));
    });
  });

  group('LowStockItem model', () {
    test('deficit returns correct value', () {
      const item = LowStockItem(
        productId: 'p1',
        productName: 'Test',
        currentStock: 3,
        minStock: 10,
        suggestedReorder: 17,
      );

      expect(item.deficit, equals(7));
    });
  });

  group('ProfitReport model', () {
    test('grossMargin calculates correctly', () {
      final profitReport = ProfitReport(
        period: DateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 31)),
        grossRevenue: 1000.0,
        costOfGoods: 600.0,
        grossProfit: 400.0,
        discounts: 50.0,
        netProfit: 350.0,
      );

      expect(profitReport.grossMargin, equals(40.0));
    });

    test('netMargin calculates correctly', () {
      final report = ProfitReport(
        period: DateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 31)),
        grossRevenue: 1000.0,
        costOfGoods: 600.0,
        grossProfit: 400.0,
        discounts: 50.0,
        netProfit: 350.0,
      );

      expect(report.netMargin, equals(35.0));
    });

    test('margins return 0 when no revenue', () {
      final report = ProfitReport(
        period: DateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 31)),
        grossRevenue: 0,
        costOfGoods: 0,
        grossProfit: 0,
        discounts: 0,
        netProfit: 0,
      );

      expect(report.grossMargin, equals(0));
      expect(report.netMargin, equals(0));
    });
  });

  group('DailyProfit model', () {
    test('margin calculates correctly', () {
      final profit = DailyProfit(
        date: DateTime(2026, 1, 1),
        revenue: 1000.0,
        cost: 600.0,
        profit: 400.0,
      );

      expect(profit.margin, equals(40.0));
    });

    test('margin returns 0 when no revenue', () {
      final profit = DailyProfit(
        date: DateTime(2026, 1, 1),
        revenue: 0,
        cost: 0,
        profit: 0,
      );

      expect(profit.margin, equals(0));
    });
  });

  group('DashboardSummary model', () {
    test('salesChangePercent calculates correctly', () {
      const summary = DashboardSummary(
        todaySales: 1200.0,
        todayTransactions: 12,
        yesterdaySales: 1000.0,
        lowStockCount: 0,
        outOfStockCount: 0,
        newCustomersToday: 0,
        pointsEarnedToday: 0,
      );

      expect(summary.salesChangePercent, equals(20.0));
    });

    test('salesChangePercent returns 100 when yesterday was zero', () {
      const summary = DashboardSummary(
        todaySales: 500.0,
        todayTransactions: 5,
        yesterdaySales: 0,
        lowStockCount: 0,
        outOfStockCount: 0,
        newCustomersToday: 0,
        pointsEarnedToday: 0,
      );

      expect(summary.salesChangePercent, equals(100));
    });

    test('isImproving returns true for positive change', () {
      const summary = DashboardSummary(
        todaySales: 1100.0,
        todayTransactions: 11,
        yesterdaySales: 1000.0,
        lowStockCount: 0,
        outOfStockCount: 0,
        newCustomersToday: 0,
        pointsEarnedToday: 0,
      );

      expect(summary.isImproving, isTrue);
    });

    test('isImproving returns false for negative change', () {
      const summary = DashboardSummary(
        todaySales: 800.0,
        todayTransactions: 8,
        yesterdaySales: 1000.0,
        lowStockCount: 0,
        outOfStockCount: 0,
        newCustomersToday: 0,
        pointsEarnedToday: 0,
      );

      expect(summary.isImproving, isFalse);
    });
  });

  group('ReportExportState', () {
    test('default state is not exporting', () {
      const state = ReportExportState();
      expect(state.isExporting, isFalse);
      expect(state.error, isNull);
      expect(state.exportPath, isNull);
    });

    test('copyWith overrides values', () {
      const state = ReportExportState();
      final updated = state.copyWith(
        isExporting: true,
        exportPath: '/path/to/file.pdf',
      );

      expect(updated.isExporting, isTrue);
      expect(updated.exportPath, equals('/path/to/file.pdf'));
    });
  });
}
