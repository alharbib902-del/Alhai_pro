import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/providers/dashboard_providers.dart';

void main() {
  // ==========================================================================
  // DashboardData Model Tests
  // ==========================================================================
  group('DashboardData', () {
    group('default values', () {
      test('todaySales defaults to 0', () {
        const data = DashboardData();
        expect(data.todaySales, equals(0));
      });

      test('todayOrders defaults to 0', () {
        const data = DashboardData();
        expect(data.todayOrders, equals(0));
      });

      test('lowStockCount defaults to 0', () {
        const data = DashboardData();
        expect(data.lowStockCount, equals(0));
      });

      test('newCustomersToday defaults to 0', () {
        const data = DashboardData();
        expect(data.newCustomersToday, equals(0));
      });

      test('yesterdaySales defaults to 0', () {
        const data = DashboardData();
        expect(data.yesterdaySales, equals(0));
      });

      test('yesterdayOrders defaults to 0', () {
        const data = DashboardData();
        expect(data.yesterdayOrders, equals(0));
      });

      test('recentSales defaults to empty list', () {
        const data = DashboardData();
        expect(data.recentSales, isEmpty);
      });

      test('topSellingProducts defaults to empty list', () {
        const data = DashboardData();
        expect(data.topSellingProducts, isEmpty);
      });

      test('weeklySales defaults to empty list', () {
        const data = DashboardData();
        expect(data.weeklySales, isEmpty);
      });

      test('monthlySales defaults to empty list', () {
        const data = DashboardData();
        expect(data.monthlySales, isEmpty);
      });
    });

    group('salesChangePercent', () {
      test('returns 0 when both today and yesterday are 0', () {
        const data = DashboardData(todaySales: 0, yesterdaySales: 0);
        expect(data.salesChangePercent, equals(0));
      });

      test('returns 100 when yesterday is 0 but today has sales', () {
        const data = DashboardData(todaySales: 500, yesterdaySales: 0);
        expect(data.salesChangePercent, equals(100));
      });

      test('returns 0 when today is 0 and yesterday is 0', () {
        const data = DashboardData(todaySales: 0, yesterdaySales: 0);
        expect(data.salesChangePercent, equals(0));
      });

      test('calculates positive change correctly', () {
        const data = DashboardData(todaySales: 1500, yesterdaySales: 1000);
        expect(data.salesChangePercent, equals(50.0));
      });

      test('calculates negative change correctly', () {
        const data = DashboardData(todaySales: 500, yesterdaySales: 1000);
        expect(data.salesChangePercent, equals(-50.0));
      });

      test('calculates 100% increase (doubled)', () {
        const data = DashboardData(todaySales: 2000, yesterdaySales: 1000);
        expect(data.salesChangePercent, equals(100.0));
      });

      test('calculates small percentage correctly', () {
        const data = DashboardData(todaySales: 1010, yesterdaySales: 1000);
        expect(data.salesChangePercent, closeTo(1.0, 0.01));
      });

      test('handles equal sales (0% change)', () {
        const data = DashboardData(todaySales: 1000, yesterdaySales: 1000);
        expect(data.salesChangePercent, equals(0.0));
      });

      test('handles large values', () {
        const data = DashboardData(
          todaySales: 1000000,
          yesterdaySales: 500000,
        );
        expect(data.salesChangePercent, equals(100.0));
      });
    });

    group('ordersChangePercent', () {
      test('returns 0 when both today and yesterday are 0', () {
        const data = DashboardData(todayOrders: 0, yesterdayOrders: 0);
        expect(data.ordersChangePercent, equals(0));
      });

      test('returns 100 when yesterday is 0 but today has orders', () {
        const data = DashboardData(todayOrders: 10, yesterdayOrders: 0);
        expect(data.ordersChangePercent, equals(100));
      });

      test('calculates positive change correctly', () {
        const data = DashboardData(todayOrders: 30, yesterdayOrders: 20);
        expect(data.ordersChangePercent, equals(50.0));
      });

      test('calculates negative change correctly', () {
        const data = DashboardData(todayOrders: 10, yesterdayOrders: 20);
        expect(data.ordersChangePercent, equals(-50.0));
      });

      test('handles equal orders (0% change)', () {
        const data = DashboardData(todayOrders: 15, yesterdayOrders: 15);
        expect(data.ordersChangePercent, equals(0.0));
      });

      test('calculates 200% increase (tripled)', () {
        const data = DashboardData(todayOrders: 30, yesterdayOrders: 10);
        expect(data.ordersChangePercent, equals(200.0));
      });

      test('calculates fraction percentage correctly', () {
        const data = DashboardData(todayOrders: 7, yesterdayOrders: 3);
        expect(
          data.ordersChangePercent,
          closeTo(133.33, 0.01),
        );
      });
    });

    group('custom values', () {
      test('stores custom todaySales', () {
        const data = DashboardData(todaySales: 5000);
        expect(data.todaySales, equals(5000));
      });

      test('stores custom todayOrders', () {
        const data = DashboardData(todayOrders: 42);
        expect(data.todayOrders, equals(42));
      });

      test('stores custom lowStockCount', () {
        const data = DashboardData(lowStockCount: 7);
        expect(data.lowStockCount, equals(7));
      });

      test('stores custom newCustomersToday', () {
        const data = DashboardData(newCustomersToday: 3);
        expect(data.newCustomersToday, equals(3));
      });
    });
  });

  // ==========================================================================
  // DailySalesData Model Tests
  // ==========================================================================
  group('DailySalesData', () {
    test('stores date correctly', () {
      final date = DateTime(2026, 2, 12);
      final data = DailySalesData(date: date, total: 1000, count: 10);
      expect(data.date, equals(date));
    });

    test('stores total correctly', () {
      final data = DailySalesData(
        date: DateTime(2026, 2, 12),
        total: 5500.50,
        count: 25,
      );
      expect(data.total, equals(5500.50));
    });

    test('stores count correctly', () {
      final data = DailySalesData(
        date: DateTime(2026, 2, 12),
        total: 1000,
        count: 15,
      );
      expect(data.count, equals(15));
    });

    test('can represent zero sales day', () {
      final data = DailySalesData(
        date: DateTime(2026, 2, 12),
        total: 0,
        count: 0,
      );
      expect(data.total, equals(0));
      expect(data.count, equals(0));
    });
  });
}
