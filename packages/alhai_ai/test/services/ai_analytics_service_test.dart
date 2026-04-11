import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_ai/src/services/ai_analytics_service.dart';

void main() {
  group('InsightType', () {
    test('has all values', () {
      expect(InsightType.values.length, 10);
    });
  });

  group('InsightPriority', () {
    test('has all values', () {
      expect(InsightPriority.values.length, 4);
    });
  });

  group('AiInsight', () {
    test('emoji getter returns value for each type', () {
      final now = DateTime.now();
      for (final type in InsightType.values) {
        final insight = AiInsight(
          id: 'test',
          type: type,
          priority: InsightPriority.low,
          title: 'Test',
          description: 'Test',
          createdAt: now,
        );
        expect(insight.emoji, isNotEmpty);
      }
    });
  });

  group('ProductAnalyticsData', () {
    test('profitMargin calculates correctly', () {
      const product = ProductAnalyticsData(
        id: 'p1',
        name: 'Test',
        price: 100,
        cost: 60,
        stockQty: 50,
        minStock: 10,
        soldThisWeek: 20,
        soldLastWeek: 15,
        soldThisMonth: 80,
      );

      expect(product.profitMargin, 40.0);
    });

    test('profitMargin returns 0 when price is 0', () {
      const product = ProductAnalyticsData(
        id: 'p1',
        name: 'Test',
        price: 0,
        cost: 60,
        stockQty: 50,
        minStock: 10,
        soldThisWeek: 20,
        soldLastWeek: 15,
        soldThisMonth: 80,
      );

      expect(product.profitMargin, 0);
    });

    test('weeklyTurnover calculates correctly', () {
      const product = ProductAnalyticsData(
        id: 'p1',
        name: 'Test',
        price: 100,
        cost: 60,
        stockQty: 50,
        minStock: 10,
        soldThisWeek: 25,
        soldLastWeek: 15,
        soldThisMonth: 80,
      );

      expect(product.weeklyTurnover, 0.5);
    });

    test('weeklyTurnover returns 0 when stock is 0', () {
      const product = ProductAnalyticsData(
        id: 'p1',
        name: 'Test',
        price: 100,
        cost: 60,
        stockQty: 0,
        minStock: 10,
        soldThisWeek: 25,
        soldLastWeek: 15,
        soldThisMonth: 80,
      );

      expect(product.weeklyTurnover, 0);
    });

    test('salesChangePercent calculates positive change', () {
      const product = ProductAnalyticsData(
        id: 'p1',
        name: 'Test',
        price: 100,
        cost: 60,
        stockQty: 50,
        minStock: 10,
        soldThisWeek: 20,
        soldLastWeek: 10,
        soldThisMonth: 80,
      );

      expect(product.salesChangePercent, 100.0);
    });

    test(
      'salesChangePercent returns 100 when last week was 0 and this week > 0',
      () {
        const product = ProductAnalyticsData(
          id: 'p1',
          name: 'Test',
          price: 100,
          cost: 60,
          stockQty: 50,
          minStock: 10,
          soldThisWeek: 20,
          soldLastWeek: 0,
          soldThisMonth: 80,
        );

        expect(product.salesChangePercent, 100);
      },
    );

    test('salesChangePercent returns 0 when both weeks are 0', () {
      const product = ProductAnalyticsData(
        id: 'p1',
        name: 'Test',
        price: 100,
        cost: 60,
        stockQty: 50,
        minStock: 10,
        soldThisWeek: 0,
        soldLastWeek: 0,
        soldThisMonth: 0,
      );

      expect(product.salesChangePercent, 0);
    });
  });

  group('SalesAnalyticsData', () {
    test('avgTransactionToday calculates correctly', () {
      const sales = SalesAnalyticsData(
        todaySales: 1000,
        yesterdaySales: 800,
        thisWeekSales: 5000,
        lastWeekSales: 4500,
        thisMonthSales: 20000,
        lastMonthSales: 18000,
        todayTransactions: 10,
        thisWeekTransactions: 50,
        hourlyDistribution: {},
        dailyDistribution: {},
      );

      expect(sales.avgTransactionToday, 100.0);
    });

    test('avgTransactionToday returns 0 when no transactions', () {
      const sales = SalesAnalyticsData(
        todaySales: 0,
        yesterdaySales: 800,
        thisWeekSales: 5000,
        lastWeekSales: 4500,
        thisMonthSales: 20000,
        lastMonthSales: 18000,
        todayTransactions: 0,
        thisWeekTransactions: 50,
        hourlyDistribution: {},
        dailyDistribution: {},
      );

      expect(sales.avgTransactionToday, 0);
    });

    test('dailyChangePercent calculates positive change', () {
      const sales = SalesAnalyticsData(
        todaySales: 1200,
        yesterdaySales: 1000,
        thisWeekSales: 5000,
        lastWeekSales: 4500,
        thisMonthSales: 20000,
        lastMonthSales: 18000,
        todayTransactions: 10,
        thisWeekTransactions: 50,
        hourlyDistribution: {},
        dailyDistribution: {},
      );

      expect(sales.dailyChangePercent, 20.0);
    });

    test('dailyChangePercent handles zero yesterday', () {
      const sales = SalesAnalyticsData(
        todaySales: 1000,
        yesterdaySales: 0,
        thisWeekSales: 5000,
        lastWeekSales: 4500,
        thisMonthSales: 20000,
        lastMonthSales: 18000,
        todayTransactions: 10,
        thisWeekTransactions: 50,
        hourlyDistribution: {},
        dailyDistribution: {},
      );

      expect(sales.dailyChangePercent, 100);
    });

    test('weeklyChangePercent calculates correctly', () {
      const sales = SalesAnalyticsData(
        todaySales: 1000,
        yesterdaySales: 800,
        thisWeekSales: 5000,
        lastWeekSales: 4000,
        thisMonthSales: 20000,
        lastMonthSales: 18000,
        todayTransactions: 10,
        thisWeekTransactions: 50,
        hourlyDistribution: {},
        dailyDistribution: {},
      );

      expect(sales.weeklyChangePercent, 25.0);
    });

    test('monthlyChangePercent calculates correctly', () {
      const sales = SalesAnalyticsData(
        todaySales: 1000,
        yesterdaySales: 800,
        thisWeekSales: 5000,
        lastWeekSales: 4500,
        thisMonthSales: 20000,
        lastMonthSales: 16000,
        todayTransactions: 10,
        thisWeekTransactions: 50,
        hourlyDistribution: {},
        dailyDistribution: {},
      );

      expect(sales.monthlyChangePercent, 25.0);
    });
  });

  group('analyze', () {
    test('returns insights for low stock products', () async {
      final products = [
        const ProductAnalyticsData(
          id: 'p1',
          name: 'Low Stock Product',
          price: 50,
          cost: 30,
          stockQty: 5,
          minStock: 10,
          soldThisWeek: 20,
          soldLastWeek: 15,
          soldThisMonth: 80,
        ),
      ];

      const sales = SalesAnalyticsData(
        todaySales: 1000,
        yesterdaySales: 800,
        thisWeekSales: 5000,
        lastWeekSales: 4500,
        thisMonthSales: 20000,
        lastMonthSales: 18000,
        todayTransactions: 10,
        thisWeekTransactions: 50,
        hourlyDistribution: {},
        dailyDistribution: {},
      );

      final result = await AiAnalyticsService.analyze(
        products: products,
        sales: sales,
      );

      expect(result.insights, isNotEmpty);
      expect(result.analyzedAt, isNotNull);
      expect(result.summary, isNotEmpty);

      final stockWarnings = result.insights
          .where((i) => i.type == InsightType.stockWarning)
          .toList();
      expect(stockWarnings, isNotEmpty);
    });

    test('returns critical insight for out of stock products', () async {
      final products = [
        const ProductAnalyticsData(
          id: 'p1',
          name: 'Out of Stock',
          price: 50,
          cost: 30,
          stockQty: 0,
          minStock: 10,
          soldThisWeek: 0,
          soldLastWeek: 15,
          soldThisMonth: 50,
        ),
      ];

      const sales = SalesAnalyticsData(
        todaySales: 1000,
        yesterdaySales: 800,
        thisWeekSales: 5000,
        lastWeekSales: 4500,
        thisMonthSales: 20000,
        lastMonthSales: 18000,
        todayTransactions: 10,
        thisWeekTransactions: 50,
        hourlyDistribution: {},
        dailyDistribution: {},
      );

      final result = await AiAnalyticsService.analyze(
        products: products,
        sales: sales,
      );

      final restockSuggestions = result.insights
          .where((i) => i.type == InsightType.restockSuggestion)
          .toList();
      expect(restockSuggestions, isNotEmpty);
      expect(restockSuggestions.first.priority, InsightPriority.critical);
    });

    test('insights are sorted by priority', () async {
      final products = [
        const ProductAnalyticsData(
          id: 'p1',
          name: 'Out of Stock',
          price: 50,
          cost: 30,
          stockQty: 0,
          minStock: 10,
          soldThisWeek: 0,
          soldLastWeek: 15,
          soldThisMonth: 50,
        ),
        const ProductAnalyticsData(
          id: 'p2',
          name: 'Top Seller',
          price: 100,
          cost: 60,
          stockQty: 100,
          minStock: 10,
          soldThisWeek: 30,
          soldLastWeek: 20,
          soldThisMonth: 120,
        ),
      ];

      const sales = SalesAnalyticsData(
        todaySales: 1500,
        yesterdaySales: 1000,
        thisWeekSales: 8000,
        lastWeekSales: 5000,
        thisMonthSales: 30000,
        lastMonthSales: 22000,
        todayTransactions: 15,
        thisWeekTransactions: 80,
        hourlyDistribution: {12: 500, 17: 800},
        dailyDistribution: {5: 3000},
      );

      final result = await AiAnalyticsService.analyze(
        products: products,
        sales: sales,
      );

      for (int i = 0; i < result.insights.length - 1; i++) {
        expect(
          result.insights[i].priority.index,
          greaterThanOrEqualTo(result.insights[i + 1].priority.index),
        );
      }
    });

    test('summary contains expected keys', () async {
      final products = [
        const ProductAnalyticsData(
          id: 'p1',
          name: 'Test',
          price: 100,
          cost: 60,
          stockQty: 50,
          minStock: 10,
          soldThisWeek: 20,
          soldLastWeek: 15,
          soldThisMonth: 80,
        ),
      ];

      const sales = SalesAnalyticsData(
        todaySales: 1000,
        yesterdaySales: 800,
        thisWeekSales: 5000,
        lastWeekSales: 4500,
        thisMonthSales: 20000,
        lastMonthSales: 18000,
        todayTransactions: 10,
        thisWeekTransactions: 50,
        hourlyDistribution: {},
        dailyDistribution: {},
      );

      final result = await AiAnalyticsService.analyze(
        products: products,
        sales: sales,
      );

      expect(result.summary.containsKey('lowStockCount'), isTrue);
      expect(result.summary.containsKey('outOfStockCount'), isTrue);
      expect(result.summary.containsKey('todaySales'), isTrue);
      expect(result.summary.containsKey('avgProfitMargin'), isTrue);
    });

    test('returns empty insights for healthy data', () async {
      final products = [
        const ProductAnalyticsData(
          id: 'p1',
          name: 'Healthy Product',
          price: 100,
          cost: 40,
          stockQty: 200,
          minStock: 10,
          soldThisWeek: 5,
          soldLastWeek: 5,
          soldThisMonth: 20,
        ),
      ];

      const sales = SalesAnalyticsData(
        todaySales: 1000,
        yesterdaySales: 950,
        thisWeekSales: 5000,
        lastWeekSales: 4800,
        thisMonthSales: 20000,
        lastMonthSales: 19500,
        todayTransactions: 10,
        thisWeekTransactions: 50,
        hourlyDistribution: {},
        dailyDistribution: {},
      );

      final result = await AiAnalyticsService.analyze(
        products: products,
        sales: sales,
      );

      // Should not generate low stock, out of stock, or large trend insights
      final critical = result.insights
          .where((i) => i.priority == InsightPriority.critical)
          .toList();
      expect(critical, isEmpty);
    });
  });

  group('getQuickInsights', () {
    test('returns sales up insight when daily change >= 10%', () {
      final insights = AiAnalyticsService.getQuickInsights(
        todaySales: 1100,
        yesterdaySales: 1000,
        lowStockCount: 0,
        outOfStockCount: 0,
      );

      final salesInsights = insights
          .where((i) => i.type == InsightType.salesTrend)
          .toList();
      expect(salesInsights, isNotEmpty);
    });

    test('returns sales down insight when daily change <= -10%', () {
      final insights = AiAnalyticsService.getQuickInsights(
        todaySales: 800,
        yesterdaySales: 1000,
        lowStockCount: 0,
        outOfStockCount: 0,
      );

      final salesInsights = insights
          .where((i) => i.type == InsightType.salesTrend)
          .toList();
      expect(salesInsights, isNotEmpty);
    });

    test('returns critical warning for out of stock', () {
      final insights = AiAnalyticsService.getQuickInsights(
        todaySales: 1000,
        yesterdaySales: 1000,
        lowStockCount: 0,
        outOfStockCount: 3,
      );

      final stockWarnings = insights
          .where((i) => i.type == InsightType.stockWarning)
          .toList();
      expect(stockWarnings, isNotEmpty);
      expect(stockWarnings.first.priority, InsightPriority.critical);
    });

    test('returns high warning for low stock (no out of stock)', () {
      final insights = AiAnalyticsService.getQuickInsights(
        todaySales: 1000,
        yesterdaySales: 1000,
        lowStockCount: 5,
        outOfStockCount: 0,
      );

      final stockWarnings = insights
          .where((i) => i.type == InsightType.stockWarning)
          .toList();
      expect(stockWarnings, isNotEmpty);
      expect(stockWarnings.first.priority, InsightPriority.high);
    });

    test('returns empty list for stable data without stock issues', () {
      final insights = AiAnalyticsService.getQuickInsights(
        todaySales: 1000,
        yesterdaySales: 1000,
        lowStockCount: 0,
        outOfStockCount: 0,
      );

      expect(insights, isEmpty);
    });
  });
}
