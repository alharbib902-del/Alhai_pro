import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/providers/dashboard_providers.dart';

void main() {
  group('DashboardData', () {
    test('should have default values', () {
      const data = DashboardData();
      expect(data.todaySales, 0);
      expect(data.todayOrders, 0);
      expect(data.lowStockCount, 0);
      expect(data.newCustomersToday, 0);
      expect(data.yesterdaySales, 0);
      expect(data.yesterdayOrders, 0);
      expect(data.expiringProductsCount, 0);
      expect(data.recentSales, isEmpty);
      expect(data.topSellingProducts, isEmpty);
      expect(data.weeklySales, isEmpty);
      expect(data.monthlySales, isEmpty);
    });

    group('salesChangePercent', () {
      test('should return 0 when both today and yesterday are 0', () {
        const data = DashboardData();
        expect(data.salesChangePercent, 0);
      });

      test('should return 100 when yesterday is 0 but today has sales', () {
        const data = DashboardData(todaySales: 500, yesterdaySales: 0);
        expect(data.salesChangePercent, 100);
      });

      test('should calculate positive change', () {
        const data = DashboardData(todaySales: 150, yesterdaySales: 100);
        expect(data.salesChangePercent, 50);
      });

      test('should calculate negative change', () {
        const data = DashboardData(todaySales: 50, yesterdaySales: 100);
        expect(data.salesChangePercent, -50);
      });

      test('should return 0 when sales are same', () {
        const data = DashboardData(todaySales: 100, yesterdaySales: 100);
        expect(data.salesChangePercent, 0);
      });
    });

    group('ordersChangePercent', () {
      test('should return 0 when both are 0', () {
        const data = DashboardData();
        expect(data.ordersChangePercent, 0);
      });

      test('should return 100 when yesterday is 0 but today has orders', () {
        const data = DashboardData(todayOrders: 10, yesterdayOrders: 0);
        expect(data.ordersChangePercent, 100);
      });

      test('should calculate positive change', () {
        const data = DashboardData(todayOrders: 15, yesterdayOrders: 10);
        expect(data.ordersChangePercent, 50);
      });

      test('should calculate negative change', () {
        const data = DashboardData(todayOrders: 5, yesterdayOrders: 10);
        expect(data.ordersChangePercent, -50);
      });
    });
  });

  group('DailySalesData', () {
    test('should store date, total, and count', () {
      final date = DateTime(2024, 1, 15);
      final data = DailySalesData(date: date, total: 1500.50, count: 25);
      expect(data.date, date);
      expect(data.total, 1500.50);
      expect(data.count, 25);
    });

    test('should handle zero values', () {
      final data = DailySalesData(date: DateTime.now(), total: 0, count: 0);
      expect(data.total, 0);
      expect(data.count, 0);
    });
  });
}
