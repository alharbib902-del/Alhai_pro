import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

class FakeAnalyticsRepository implements AnalyticsRepository {
  @override
  Future<List<SlowMovingProduct>> getSlowMovingProducts(String storeId,
          {int daysThreshold = 30, int limit = 20}) async =>
      [
        SlowMovingProduct(
            productId: 'p1',
            productName: 'Slow',
            daysSinceLastSale: 45,
            stockQty: 50,
            stockValue: 500.0),
      ];

  @override
  Future<List<ReorderSuggestion>> getReorderSuggestions(String storeId,
          {int daysAhead = 7}) async =>
      [];

  @override
  Future<List<SalesForecast>> getSalesForecast(String storeId,
          {int days = 7}) async =>
      [];

  @override
  Future<PeakHoursAnalysis> getPeakHoursAnalysis(String storeId,
          {DateTime? startDate, DateTime? endDate}) async =>
      PeakHoursAnalysis(
          peakHour: 14,
          slowestHour: 6,
          peakHourRevenue: 1200.0,
          hourlyRevenue: {14: 1200.0},
          hourlyOrders: {14: 15});

  @override
  Future<List<CustomerPattern>> getCustomerPatterns(String storeId,
          {int limit = 20}) async =>
      [];

  @override
  Future<List<SmartAlert>> getSmartAlerts(String storeId,
          {bool unreadOnly = false, int limit = 50}) async =>
      [];

  @override
  Future<void> markAlertRead(String alertId) async {}

  @override
  Future<void> markAllAlertsRead(String storeId) async {}

  @override
  Future<DashboardSummary> getDashboardSummary(String storeId) async =>
      DashboardSummary(
        todaySales: SalesSummary(
            date: DateTime.now(),
            ordersCount: 25,
            itemsSold: 100,
            revenue: 5000.0,
            cost: 3000.0,
            profit: 2000.0),
        alertsCount: 3,
        lowStockCount: 5,
        slowMovingCount: 2,
        revenueChange: 10.0,
        pendingOrdersCount: 3,
        totalDebtsAmount: 1000.0,
      );
}

void main() {
  late AnalyticsService analyticsService;
  setUp(() {
    analyticsService = AnalyticsService(FakeAnalyticsRepository());
  });

  group('AnalyticsService', () {
    test('should be created', () {
      expect(analyticsService, isNotNull);
    });

    test('getSlowMovingProducts should return list', () async {
      final products = await analyticsService.getSlowMovingProducts('store-1');
      expect(products, hasLength(1));
      expect(products.first.daysSinceLastSale, greaterThan(30));
    });

    test('getReorderSuggestions should return list', () async {
      final suggestions =
          await analyticsService.getReorderSuggestions('store-1');
      expect(suggestions, isA<List<ReorderSuggestion>>());
    });

    test('getSalesForecast should return list', () async {
      final forecast = await analyticsService.getSalesForecast('store-1');
      expect(forecast, isA<List<SalesForecast>>());
    });

    test('getPeakHoursAnalysis should return analysis', () async {
      final analysis = await analyticsService.getPeakHoursAnalysis('store-1');
      expect(analysis.peakHour, equals(14));
    });

    test('getSmartAlerts should return list', () async {
      final alerts = await analyticsService.getSmartAlerts('store-1');
      expect(alerts, isA<List<SmartAlert>>());
    });

    test('markAlertRead should not throw', () async {
      await analyticsService.markAlertRead('alert-1');
    });

    test('markAllAlertsRead should not throw', () async {
      await analyticsService.markAllAlertsRead('store-1');
    });

    test('getDashboardSummary should return summary', () async {
      final summary = await analyticsService.getDashboardSummary('store-1');
      expect(summary.lowStockCount, equals(5));
      expect(summary.alertsCount, equals(3));
    });
  });
}
