import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

class FakeReportsRepo implements ReportsRepository {
  @override
  Future<SalesSummary> getDailySummary(String storeId, DateTime date) async =>
      SalesSummary(
        date: date,
        ordersCount: 25,
        itemsSold: 100,
        revenue: 5000.0,
        cost: 3000.0,
        profit: 2000.0,
      );
  @override
  Future<List<SalesSummary>> getSalesSummaries(
    String storeId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final days = endDate.difference(startDate).inDays + 1;
    return List.generate(
      days,
      (i) => SalesSummary(
        date: startDate.add(Duration(days: i)),
        ordersCount: 25 + i,
        itemsSold: 100,
        revenue: 5000.0,
        cost: 3000.0,
        profit: 2000.0,
      ),
    );
  }

  @override
  Future<List<ProductSales>> getTopProducts(
    String storeId, {
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  }) async => [
    ProductSales(
      productId: 'p1',
      productName: 'Coffee',
      quantitySold: 100,
      revenue: 1500.0,
      cost: 800.0,
      profit: 700.0,
    ),
  ];
  @override
  Future<List<CategorySales>> getCategorySales(
    String storeId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async => [
    const CategorySales(
      categoryId: 'c1',
      categoryName: 'Beverages',
      productsSold: 50,
      revenue: 3000.0,
      profit: 1500.0,
    ),
  ];
  @override
  Future<InventoryValue> getInventoryValue(String storeId) async =>
      const InventoryValue(
        totalProducts: 100,
        totalUnits: 5000,
        costValue: 30000.0,
        retailValue: 50000.0,
        lowStockCount: 5,
        outOfStockCount: 2,
      );
  @override
  Future<Map<int, double>> getHourlySales(
    String storeId,
    DateTime date,
  ) async => {8: 200.0, 14: 1200.0};
  @override
  Future<MonthlyComparison> getMonthlyComparison(
    String storeId, {
    required int year,
    required int month,
  }) async => const MonthlyComparison(
    currentMonthRevenue: 50000.0,
    previousMonthRevenue: 45000.0,
    currentMonthProfit: 20000.0,
    previousMonthProfit: 18000.0,
    currentMonthOrders: 200,
    previousMonthOrders: 180,
  );
}

void main() {
  late ReportService reportService;
  setUp(() {
    reportService = ReportService(FakeReportsRepo());
  });

  group('ReportService', () {
    test('should be created', () {
      expect(reportService, isNotNull);
    });

    test('getDailySummary should return summary', () async {
      final s = await reportService.getDailySummary(
        'store-1',
        DateTime(2026, 3, 15),
      );
      expect(s.revenue, equals(5000.0));
      expect(s.ordersCount, equals(25));
    });

    test('getTodaySummary should work', () async {
      final s = await reportService.getTodaySummary('store-1');
      expect(s.revenue, greaterThan(0));
    });

    test('getSalesSummaries should return for date range', () async {
      final summaries = await reportService.getSalesSummaries(
        'store-1',
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 7),
      );
      expect(summaries, hasLength(7));
    });

    test('getWeeklySummary should return list', () async {
      final s = await reportService.getWeeklySummary('store-1');
      expect(s, isNotEmpty);
    });

    test('getMonthlySummary should return list', () async {
      final s = await reportService.getMonthlySummary('store-1');
      expect(s, isNotEmpty);
    });

    test('getTopProducts should return list', () async {
      final products = await reportService.getTopProducts(
        'store-1',
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 31),
      );
      expect(products, hasLength(1));
      expect(products.first.productName, equals('Coffee'));
    });

    test('getCategorySales should return list', () async {
      final categories = await reportService.getCategorySales(
        'store-1',
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 31),
      );
      expect(categories, isNotEmpty);
    });

    test('getInventoryValue should return value', () async {
      final value = await reportService.getInventoryValue('store-1');
      expect(value.totalProducts, equals(100));
      expect(value.retailValue, equals(50000.0));
    });

    test('getHourlySales should return map', () async {
      final hourly = await reportService.getHourlySales(
        'store-1',
        DateTime(2026, 3, 15),
      );
      expect(hourly, isNotEmpty);
      expect(hourly[14], equals(1200.0));
    });

    test('getMonthlyComparison should return comparison', () async {
      final comparison = await reportService.getMonthlyComparison(
        'store-1',
        year: 2026,
        month: 3,
      );
      expect(comparison.currentMonthRevenue, equals(50000.0));
      expect(comparison.revenueChange, greaterThan(0));
    });
  });
}
