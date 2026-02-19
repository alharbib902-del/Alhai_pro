import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/services/ai_analytics_service.dart';

// ===========================================
// AI Analytics Service Tests
// ===========================================

void main() {
  group('InsightType', () {
    test('يحتوي على جميع الأنواع', () {
      expect(InsightType.values.length, 10);
      expect(InsightType.values, contains(InsightType.restockSuggestion));
      expect(InsightType.values, contains(InsightType.topSelling));
      expect(InsightType.values, contains(InsightType.slowMoving));
      expect(InsightType.values, contains(InsightType.profitOpportunity));
      expect(InsightType.values, contains(InsightType.stockWarning));
      expect(InsightType.values, contains(InsightType.salesTrend));
      expect(InsightType.values, contains(InsightType.demandForecast));
      expect(InsightType.values, contains(InsightType.pricingOptimization));
      expect(InsightType.values, contains(InsightType.peakTime));
      expect(InsightType.values, contains(InsightType.vipCustomer));
    });
  });

  group('InsightPriority', () {
    test('يحتوي على جميع الأولويات', () {
      expect(InsightPriority.values.length, 4);
      expect(InsightPriority.values, contains(InsightPriority.low));
      expect(InsightPriority.values, contains(InsightPriority.medium));
      expect(InsightPriority.values, contains(InsightPriority.high));
      expect(InsightPriority.values, contains(InsightPriority.critical));
    });
  });

  group('AiInsight', () {
    test('يُنشئ اقتراح بشكل صحيح', () {
      final insight = AiInsight(
        id: 'test_001',
        type: InsightType.stockWarning,
        priority: InsightPriority.high,
        title: 'تحذير مخزون',
        description: 'الكمية منخفضة',
        createdAt: DateTime.now(),
      );

      expect(insight.id, 'test_001');
      expect(insight.type, InsightType.stockWarning);
      expect(insight.priority, InsightPriority.high);
    });

    test('emoji يُرجع الأيقونة الصحيحة', () {
      expect(
        AiInsight(
          id: '1', type: InsightType.restockSuggestion, priority: InsightPriority.high,
          title: '', description: '', createdAt: DateTime.now(),
        ).emoji,
        '📦',
      );

      expect(
        AiInsight(
          id: '2', type: InsightType.topSelling, priority: InsightPriority.low,
          title: '', description: '', createdAt: DateTime.now(),
        ).emoji,
        '🏆',
      );

      expect(
        AiInsight(
          id: '3', type: InsightType.slowMoving, priority: InsightPriority.medium,
          title: '', description: '', createdAt: DateTime.now(),
        ).emoji,
        '🐌',
      );

      expect(
        AiInsight(
          id: '4', type: InsightType.profitOpportunity, priority: InsightPriority.medium,
          title: '', description: '', createdAt: DateTime.now(),
        ).emoji,
        '💰',
      );

      expect(
        AiInsight(
          id: '5', type: InsightType.stockWarning, priority: InsightPriority.critical,
          title: '', description: '', createdAt: DateTime.now(),
        ).emoji,
        '⚠️',
      );

      expect(
        AiInsight(
          id: '6', type: InsightType.salesTrend, priority: InsightPriority.low,
          title: '', description: '', createdAt: DateTime.now(),
        ).emoji,
        '📈',
      );

      expect(
        AiInsight(
          id: '7', type: InsightType.demandForecast, priority: InsightPriority.high,
          title: '', description: '', createdAt: DateTime.now(),
        ).emoji,
        '🔮',
      );

      expect(
        AiInsight(
          id: '8', type: InsightType.pricingOptimization, priority: InsightPriority.medium,
          title: '', description: '', createdAt: DateTime.now(),
        ).emoji,
        '💲',
      );

      expect(
        AiInsight(
          id: '9', type: InsightType.peakTime, priority: InsightPriority.low,
          title: '', description: '', createdAt: DateTime.now(),
        ).emoji,
        '⏰',
      );

      expect(
        AiInsight(
          id: '10', type: InsightType.vipCustomer, priority: InsightPriority.low,
          title: '', description: '', createdAt: DateTime.now(),
        ).emoji,
        '⭐',
      );
    });
  });

  group('ProductAnalyticsData', () {
    test('يُنشئ بيانات منتج بشكل صحيح', () {
      const product = ProductAnalyticsData(
        id: 'prod_001',
        name: 'حليب',
        price: 10.0,
        cost: 8.0,
        stockQty: 50,
        minStock: 10,
        soldThisWeek: 25,
        soldLastWeek: 20,
        soldThisMonth: 100,
      );

      expect(product.id, 'prod_001');
      expect(product.name, 'حليب');
      expect(product.price, 10.0);
      expect(product.cost, 8.0);
    });

    group('profitMargin', () {
      test('يحسب هامش الربح بشكل صحيح', () {
        const product = ProductAnalyticsData(
          id: '1', name: 'منتج', price: 100.0, cost: 60.0,
          stockQty: 10, minStock: 5, soldThisWeek: 5, soldLastWeek: 5, soldThisMonth: 20,
        );

        expect(product.profitMargin, 40.0); // (100-60)/100 * 100 = 40%
      });

      test('يُرجع 0 إذا السعر 0', () {
        const product = ProductAnalyticsData(
          id: '1', name: 'منتج', price: 0.0, cost: 60.0,
          stockQty: 10, minStock: 5, soldThisWeek: 5, soldLastWeek: 5, soldThisMonth: 20,
        );

        expect(product.profitMargin, 0.0);
      });
    });

    group('weeklyTurnover', () {
      test('يحسب معدل الدوران الأسبوعي', () {
        const product = ProductAnalyticsData(
          id: '1', name: 'منتج', price: 10.0, cost: 8.0,
          stockQty: 100, minStock: 10, soldThisWeek: 50, soldLastWeek: 40, soldThisMonth: 200,
        );

        expect(product.weeklyTurnover, 0.5); // 50/100 = 0.5
      });

      test('يُرجع 0 إذا المخزون 0', () {
        const product = ProductAnalyticsData(
          id: '1', name: 'منتج', price: 10.0, cost: 8.0,
          stockQty: 0, minStock: 10, soldThisWeek: 50, soldLastWeek: 40, soldThisMonth: 200,
        );

        expect(product.weeklyTurnover, 0.0);
      });
    });

    group('salesChangePercent', () {
      test('يحسب نسبة التغير بشكل صحيح', () {
        const product = ProductAnalyticsData(
          id: '1', name: 'منتج', price: 10.0, cost: 8.0,
          stockQty: 50, minStock: 10, soldThisWeek: 30, soldLastWeek: 20, soldThisMonth: 100,
        );

        expect(product.salesChangePercent, 50.0); // (30-20)/20 * 100 = 50%
      });

      test('يُرجع 100 إذا الأسبوع الماضي 0 وهذا الأسبوع > 0', () {
        const product = ProductAnalyticsData(
          id: '1', name: 'منتج', price: 10.0, cost: 8.0,
          stockQty: 50, minStock: 10, soldThisWeek: 30, soldLastWeek: 0, soldThisMonth: 100,
        );

        expect(product.salesChangePercent, 100.0);
      });

      test('يُرجع 0 إذا كلاهما 0', () {
        const product = ProductAnalyticsData(
          id: '1', name: 'منتج', price: 10.0, cost: 8.0,
          stockQty: 50, minStock: 10, soldThisWeek: 0, soldLastWeek: 0, soldThisMonth: 0,
        );

        expect(product.salesChangePercent, 0.0);
      });
    });
  });

  group('SalesAnalyticsData', () {
    test('يُنشئ بيانات مبيعات بشكل صحيح', () {
      const sales = SalesAnalyticsData(
        todaySales: 1000.0,
        yesterdaySales: 800.0,
        thisWeekSales: 5000.0,
        lastWeekSales: 4500.0,
        thisMonthSales: 20000.0,
        lastMonthSales: 18000.0,
        todayTransactions: 50,
        thisWeekTransactions: 250,
        hourlyDistribution: {10: 100.0, 11: 150.0, 12: 200.0},
        dailyDistribution: {0: 700.0, 1: 800.0, 2: 750.0},
      );

      expect(sales.todaySales, 1000.0);
      expect(sales.todayTransactions, 50);
    });

    group('avgTransactionToday', () {
      test('يحسب متوسط الفاتورة', () {
        const sales = SalesAnalyticsData(
          todaySales: 1000.0, yesterdaySales: 800.0, thisWeekSales: 5000.0, lastWeekSales: 4500.0,
          thisMonthSales: 20000.0, lastMonthSales: 18000.0, todayTransactions: 50, thisWeekTransactions: 250,
          hourlyDistribution: {}, dailyDistribution: {},
        );

        expect(sales.avgTransactionToday, 20.0); // 1000/50 = 20
      });

      test('يُرجع 0 إذا لا توجد معاملات', () {
        const sales = SalesAnalyticsData(
          todaySales: 0.0, yesterdaySales: 800.0, thisWeekSales: 5000.0, lastWeekSales: 4500.0,
          thisMonthSales: 20000.0, lastMonthSales: 18000.0, todayTransactions: 0, thisWeekTransactions: 250,
          hourlyDistribution: {}, dailyDistribution: {},
        );

        expect(sales.avgTransactionToday, 0.0);
      });
    });

    group('dailyChangePercent', () {
      test('يحسب نسبة التغير اليومي', () {
        const sales = SalesAnalyticsData(
          todaySales: 1000.0, yesterdaySales: 800.0, thisWeekSales: 5000.0, lastWeekSales: 4500.0,
          thisMonthSales: 20000.0, lastMonthSales: 18000.0, todayTransactions: 50, thisWeekTransactions: 250,
          hourlyDistribution: {}, dailyDistribution: {},
        );

        expect(sales.dailyChangePercent, 25.0); // (1000-800)/800 * 100 = 25%
      });
    });

    group('weeklyChangePercent', () {
      test('يحسب نسبة التغير الأسبوعي', () {
        const sales = SalesAnalyticsData(
          todaySales: 1000.0, yesterdaySales: 800.0, thisWeekSales: 5000.0, lastWeekSales: 4000.0,
          thisMonthSales: 20000.0, lastMonthSales: 18000.0, todayTransactions: 50, thisWeekTransactions: 250,
          hourlyDistribution: {}, dailyDistribution: {},
        );

        expect(sales.weeklyChangePercent, 25.0); // (5000-4000)/4000 * 100 = 25%
      });
    });

    group('monthlyChangePercent', () {
      test('يحسب نسبة التغير الشهري', () {
        const sales = SalesAnalyticsData(
          todaySales: 1000.0, yesterdaySales: 800.0, thisWeekSales: 5000.0, lastWeekSales: 4000.0,
          thisMonthSales: 22000.0, lastMonthSales: 20000.0, todayTransactions: 50, thisWeekTransactions: 250,
          hourlyDistribution: {}, dailyDistribution: {},
        );

        expect(sales.monthlyChangePercent, 10.0); // (22000-20000)/20000 * 100 = 10%
      });
    });
  });

  group('AiAnalyticsService', () {
    group('analyze', () {
      test('يُنشئ نتيجة تحليل صحيحة', () async {
        final products = [
          const ProductAnalyticsData(
            id: 'prod_001', name: 'حليب', price: 10.0, cost: 8.0,
            stockQty: 5, minStock: 10, soldThisWeek: 25, soldLastWeek: 20, soldThisMonth: 100,
          ),
          const ProductAnalyticsData(
            id: 'prod_002', name: 'خبز', price: 5.0, cost: 3.0,
            stockQty: 0, minStock: 20, soldThisWeek: 30, soldLastWeek: 25, soldThisMonth: 120,
          ),
        ];

        const sales = SalesAnalyticsData(
          todaySales: 1000.0, yesterdaySales: 700.0, thisWeekSales: 5000.0, lastWeekSales: 4000.0,
          thisMonthSales: 20000.0, lastMonthSales: 18000.0, todayTransactions: 50, thisWeekTransactions: 250,
          hourlyDistribution: {10: 100.0, 14: 200.0, 18: 150.0},
          dailyDistribution: {0: 700.0, 4: 1000.0, 5: 600.0},
        );

        final result = await AiAnalyticsService.analyze(
          products: products,
          sales: sales,
        );

        expect(result.insights, isNotEmpty);
        expect(result.summary, isNotEmpty);
        expect(result.analyzedAt, isNotNull);
      });

      test('يُنشئ تحذير للمخزون المنخفض', () async {
        final products = [
          const ProductAnalyticsData(
            id: 'prod_001', name: 'حليب', price: 10.0, cost: 8.0,
            stockQty: 5, minStock: 10, soldThisWeek: 25, soldLastWeek: 20, soldThisMonth: 100,
          ),
        ];

        const sales = SalesAnalyticsData(
          todaySales: 100.0, yesterdaySales: 100.0, thisWeekSales: 500.0, lastWeekSales: 500.0,
          thisMonthSales: 2000.0, lastMonthSales: 2000.0, todayTransactions: 10, thisWeekTransactions: 50,
          hourlyDistribution: {}, dailyDistribution: {},
        );

        final result = await AiAnalyticsService.analyze(
          products: products,
          sales: sales,
        );

        final stockWarnings = result.insights.where((i) => i.type == InsightType.stockWarning);
        expect(stockWarnings, isNotEmpty);
      });

      test('يُنشئ تحذير لنفاد المخزون', () async {
        final products = [
          const ProductAnalyticsData(
            id: 'prod_001', name: 'خبز', price: 5.0, cost: 3.0,
            stockQty: 0, minStock: 20, soldThisWeek: 30, soldLastWeek: 25, soldThisMonth: 120,
          ),
        ];

        const sales = SalesAnalyticsData(
          todaySales: 100.0, yesterdaySales: 100.0, thisWeekSales: 500.0, lastWeekSales: 500.0,
          thisMonthSales: 2000.0, lastMonthSales: 2000.0, todayTransactions: 10, thisWeekTransactions: 50,
          hourlyDistribution: {}, dailyDistribution: {},
        );

        final result = await AiAnalyticsService.analyze(
          products: products,
          sales: sales,
        );

        final restockSuggestions = result.insights.where((i) => i.type == InsightType.restockSuggestion);
        expect(restockSuggestions, isNotEmpty);
      });
    });

    group('getQuickInsights', () {
      test('يُنشئ اقتراح عند ارتفاع المبيعات', () {
        final insights = AiAnalyticsService.getQuickInsights(
          todaySales: 1000.0,
          yesterdaySales: 800.0,
          lowStockCount: 0,
          outOfStockCount: 0,
        );

        final salesUp = insights.where((i) => i.id == 'quick_sales_up');
        expect(salesUp, isNotEmpty);
      });

      test('يُنشئ اقتراح عند انخفاض المبيعات', () {
        final insights = AiAnalyticsService.getQuickInsights(
          todaySales: 500.0,
          yesterdaySales: 800.0,
          lowStockCount: 0,
          outOfStockCount: 0,
        );

        final salesDown = insights.where((i) => i.id == 'quick_sales_down');
        expect(salesDown, isNotEmpty);
      });

      test('يُنشئ تحذير عند نفاد المخزون', () {
        final insights = AiAnalyticsService.getQuickInsights(
          todaySales: 1000.0,
          yesterdaySales: 1000.0,
          lowStockCount: 0,
          outOfStockCount: 5,
        );

        final outOfStock = insights.where((i) => i.id == 'quick_out_of_stock');
        expect(outOfStock, isNotEmpty);
        expect(outOfStock.first.priority, InsightPriority.critical);
      });

      test('يُنشئ تحذير عند انخفاض المخزون', () {
        final insights = AiAnalyticsService.getQuickInsights(
          todaySales: 1000.0,
          yesterdaySales: 1000.0,
          lowStockCount: 10,
          outOfStockCount: 0,
        );

        final lowStock = insights.where((i) => i.id == 'quick_low_stock');
        expect(lowStock, isNotEmpty);
        expect(lowStock.first.priority, InsightPriority.high);
      });
    });
  });
}
