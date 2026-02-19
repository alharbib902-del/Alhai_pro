/// خدمة تحليلات AI - AI Analytics Service
///
/// توفر تحليلات ذكية واقتراحات مبنية على بيانات المبيعات والمخزون
/// - تحليل أنماط المبيعات
/// - توقع الطلب
/// - اقتراحات تحسين المخزون
/// - تنبيهات ذكية
library;


// ============================================================================
// AI INSIGHT MODELS
// ============================================================================

/// نوع الاقتراح
enum InsightType {
  /// اقتراح إعادة تخزين
  restockSuggestion,
  /// منتج الأكثر مبيعاً
  topSelling,
  /// منتج بطيء الحركة
  slowMoving,
  /// فرصة ربح
  profitOpportunity,
  /// تحذير مخزون
  stockWarning,
  /// اتجاه مبيعات
  salesTrend,
  /// توقع طلب
  demandForecast,
  /// تحسين سعر
  pricingOptimization,
  /// وقت الذروة
  peakTime,
  /// عميل VIP
  vipCustomer,
}

/// أولوية الاقتراح
enum InsightPriority {
  low,
  medium,
  high,
  critical,
}

/// اقتراح AI
class AiInsight {
  final String id;
  final InsightType type;
  final InsightPriority priority;
  final String title;
  final String description;
  final String? actionLabel;
  final String? actionRoute;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final double? confidence;

  const AiInsight({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    this.actionLabel,
    this.actionRoute,
    this.data,
    required this.createdAt,
    this.confidence,
  });

  /// أيقونة الاقتراح
  String get emoji {
    switch (type) {
      case InsightType.restockSuggestion:
        return '📦';
      case InsightType.topSelling:
        return '🏆';
      case InsightType.slowMoving:
        return '🐌';
      case InsightType.profitOpportunity:
        return '💰';
      case InsightType.stockWarning:
        return '⚠️';
      case InsightType.salesTrend:
        return '📈';
      case InsightType.demandForecast:
        return '🔮';
      case InsightType.pricingOptimization:
        return '💲';
      case InsightType.peakTime:
        return '⏰';
      case InsightType.vipCustomer:
        return '⭐';
    }
  }
}

/// نتيجة التحليل
class AnalyticsResult {
  final List<AiInsight> insights;
  final Map<String, dynamic> summary;
  final DateTime analyzedAt;

  const AnalyticsResult({
    required this.insights,
    required this.summary,
    required this.analyzedAt,
  });
}

/// بيانات المنتج للتحليل
class ProductAnalyticsData {
  final String id;
  final String name;
  final double price;
  final double cost;
  final int stockQty;
  final int minStock;
  final int soldThisWeek;
  final int soldLastWeek;
  final int soldThisMonth;
  final DateTime? lastSaleDate;

  const ProductAnalyticsData({
    required this.id,
    required this.name,
    required this.price,
    required this.cost,
    required this.stockQty,
    required this.minStock,
    required this.soldThisWeek,
    required this.soldLastWeek,
    required this.soldThisMonth,
    this.lastSaleDate,
  });

  /// هامش الربح
  double get profitMargin => price > 0 ? ((price - cost) / price) * 100 : 0;

  /// معدل الدوران الأسبوعي
  double get weeklyTurnover =>
      stockQty > 0 ? soldThisWeek / stockQty : 0;

  /// نسبة التغير في المبيعات
  double get salesChangePercent {
    if (soldLastWeek == 0) return soldThisWeek > 0 ? 100 : 0;
    return ((soldThisWeek - soldLastWeek) / soldLastWeek) * 100;
  }
}

/// بيانات المبيعات للتحليل
class SalesAnalyticsData {
  final double todaySales;
  final double yesterdaySales;
  final double thisWeekSales;
  final double lastWeekSales;
  final double thisMonthSales;
  final double lastMonthSales;
  final int todayTransactions;
  final int thisWeekTransactions;
  final Map<int, double> hourlyDistribution; // ساعة -> مبيعات
  final Map<int, double> dailyDistribution; // يوم -> مبيعات

  const SalesAnalyticsData({
    required this.todaySales,
    required this.yesterdaySales,
    required this.thisWeekSales,
    required this.lastWeekSales,
    required this.thisMonthSales,
    required this.lastMonthSales,
    required this.todayTransactions,
    required this.thisWeekTransactions,
    required this.hourlyDistribution,
    required this.dailyDistribution,
  });

  /// متوسط قيمة الفاتورة اليوم
  double get avgTransactionToday =>
      todayTransactions > 0 ? todaySales / todayTransactions : 0;

  /// نسبة التغير اليومي
  double get dailyChangePercent {
    if (yesterdaySales == 0) return todaySales > 0 ? 100 : 0;
    return ((todaySales - yesterdaySales) / yesterdaySales) * 100;
  }

  /// نسبة التغير الأسبوعي
  double get weeklyChangePercent {
    if (lastWeekSales == 0) return thisWeekSales > 0 ? 100 : 0;
    return ((thisWeekSales - lastWeekSales) / lastWeekSales) * 100;
  }

  /// نسبة التغير الشهري
  double get monthlyChangePercent {
    if (lastMonthSales == 0) return thisMonthSales > 0 ? 100 : 0;
    return ((thisMonthSales - lastMonthSales) / lastMonthSales) * 100;
  }
}

// ============================================================================
// AI ANALYTICS SERVICE
// ============================================================================

/// خدمة تحليلات AI
class AiAnalyticsService {
  AiAnalyticsService._();

  /// تحليل شامل
  static Future<AnalyticsResult> analyze({
    required List<ProductAnalyticsData> products,
    required SalesAnalyticsData sales,
  }) async {
    final insights = <AiInsight>[];

    // 1. تحليل المنتجات
    insights.addAll(_analyzeProducts(products));

    // 2. تحليل المبيعات
    insights.addAll(_analyzeSales(sales));

    // 3. تحليل أوقات الذروة
    insights.addAll(_analyzePeakTimes(sales));

    // ترتيب حسب الأولوية
    insights.sort((a, b) {
      final priorityCompare = b.priority.index.compareTo(a.priority.index);
      if (priorityCompare != 0) return priorityCompare;
      return b.createdAt.compareTo(a.createdAt);
    });

    return AnalyticsResult(
      insights: insights,
      summary: _generateSummary(products, sales),
      analyzedAt: DateTime.now(),
    );
  }

  // ==========================================================================
  // تحليل المنتجات
  // ==========================================================================

  static List<AiInsight> _analyzeProducts(List<ProductAnalyticsData> products) {
    final insights = <AiInsight>[];
    final now = DateTime.now();

    for (final product in products) {
      // 1. تحذير المخزون المنخفض
      if (product.stockQty <= product.minStock && product.stockQty > 0) {
        insights.add(AiInsight(
          id: 'low_stock_${product.id}',
          type: InsightType.stockWarning,
          priority: InsightPriority.high,
          title: 'مخزون منخفض: ${product.name}',
          description:
              'الكمية المتبقية ${product.stockQty} فقط! يُنصح بإعادة التخزين قريباً.',
          actionLabel: 'عرض المخزون',
          actionRoute: '/inventory',
          data: {'productId': product.id, 'currentStock': product.stockQty},
          createdAt: now,
          confidence: 0.95,
        ));
      }

      // 2. نفاد المخزون
      if (product.stockQty == 0) {
        insights.add(AiInsight(
          id: 'out_of_stock_${product.id}',
          type: InsightType.restockSuggestion,
          priority: InsightPriority.critical,
          title: 'نفاد المخزون: ${product.name}',
          description:
              'هذا المنتج نفد من المخزون! كان يبيع ${product.soldThisMonth} وحدة شهرياً.',
          actionLabel: 'إضافة مخزون',
          actionRoute: '/inventory/add',
          data: {'productId': product.id, 'monthlyAvg': product.soldThisMonth},
          createdAt: now,
          confidence: 1.0,
        ));
      }

      // 3. منتج بطيء الحركة
      if (product.stockQty > 0 &&
          product.soldThisMonth == 0 &&
          product.lastSaleDate != null &&
          now.difference(product.lastSaleDate!).inDays > 30) {
        insights.add(AiInsight(
          id: 'slow_moving_${product.id}',
          type: InsightType.slowMoving,
          priority: InsightPriority.medium,
          title: 'منتج بطيء الحركة: ${product.name}',
          description:
              'لم يُباع منذ ${now.difference(product.lastSaleDate!).inDays} يوم. فكر في عمل عرض أو تخفيض السعر.',
          actionLabel: 'إنشاء عرض',
          data: {
            'productId': product.id,
            'daysSinceLastSale': now.difference(product.lastSaleDate!).inDays
          },
          createdAt: now,
          confidence: 0.85,
        ));
      }

      // 4. فرصة ربح
      if (product.profitMargin < 15 && product.soldThisMonth > 10) {
        insights.add(AiInsight(
          id: 'profit_${product.id}',
          type: InsightType.profitOpportunity,
          priority: InsightPriority.medium,
          title: 'فرصة زيادة الربح: ${product.name}',
          description:
              'هامش الربح ${product.profitMargin.toStringAsFixed(1)}% منخفض لمنتج يبيع ${product.soldThisMonth} وحدة شهرياً.',
          data: {'productId': product.id, 'margin': product.profitMargin},
          createdAt: now,
          confidence: 0.75,
        ));
      }

      // 5. منتج الأكثر مبيعاً
      if (product.soldThisWeek > 20) {
        insights.add(AiInsight(
          id: 'top_selling_${product.id}',
          type: InsightType.topSelling,
          priority: InsightPriority.low,
          title: 'الأكثر مبيعاً: ${product.name}',
          description:
              'بيع ${product.soldThisWeek} وحدة هذا الأسبوع (+${product.salesChangePercent.toStringAsFixed(0)}%)',
          data: {'productId': product.id, 'soldThisWeek': product.soldThisWeek},
          createdAt: now,
          confidence: 0.9,
        ));
      }

      // 6. اقتراح إعادة التخزين بناءً على معدل البيع
      final daysOfStock =
          product.soldThisWeek > 0 ? (product.stockQty / (product.soldThisWeek / 7)).round() : 999;
      if (daysOfStock <= 7 && daysOfStock > 0) {
        insights.add(AiInsight(
          id: 'restock_${product.id}',
          type: InsightType.demandForecast,
          priority: InsightPriority.high,
          title: 'توقع نفاد: ${product.name}',
          description:
              'بناءً على معدل البيع، سينفد المخزون خلال $daysOfStock أيام تقريباً.',
          actionLabel: 'طلب توريد',
          data: {'productId': product.id, 'daysRemaining': daysOfStock},
          createdAt: now,
          confidence: 0.8,
        ));
      }
    }

    return insights;
  }

  // ==========================================================================
  // تحليل المبيعات
  // ==========================================================================

  static List<AiInsight> _analyzeSales(SalesAnalyticsData sales) {
    final insights = <AiInsight>[];
    final now = DateTime.now();

    // 1. اتجاه المبيعات اليومي
    if (sales.dailyChangePercent.abs() >= 20) {
      final isUp = sales.dailyChangePercent > 0;
      insights.add(AiInsight(
        id: 'daily_trend_${now.millisecondsSinceEpoch}',
        type: InsightType.salesTrend,
        priority: InsightPriority.medium,
        title: isUp ? '📈 ارتفاع المبيعات اليوم' : '📉 انخفاض المبيعات اليوم',
        description: isUp
            ? 'المبيعات أعلى بـ ${sales.dailyChangePercent.toStringAsFixed(0)}% من الأمس!'
            : 'المبيعات أقل بـ ${sales.dailyChangePercent.abs().toStringAsFixed(0)}% من الأمس.',
        data: {
          'change': sales.dailyChangePercent,
          'today': sales.todaySales,
          'yesterday': sales.yesterdaySales
        },
        createdAt: now,
        confidence: 0.85,
      ));
    }

    // 2. اتجاه المبيعات الأسبوعي
    if (sales.weeklyChangePercent.abs() >= 15) {
      final isUp = sales.weeklyChangePercent > 0;
      insights.add(AiInsight(
        id: 'weekly_trend_${now.millisecondsSinceEpoch}',
        type: InsightType.salesTrend,
        priority: InsightPriority.medium,
        title:
            isUp ? '📊 أداء أسبوعي ممتاز' : '📊 أداء أسبوعي يحتاج تحسين',
        description: isUp
            ? 'مبيعات الأسبوع أعلى بـ ${sales.weeklyChangePercent.toStringAsFixed(0)}% من الأسبوع الماضي!'
            : 'مبيعات الأسبوع أقل بـ ${sales.weeklyChangePercent.abs().toStringAsFixed(0)}% من الأسبوع الماضي.',
        actionLabel: 'عرض التقارير',
        actionRoute: '/reports',
        data: {'change': sales.weeklyChangePercent},
        createdAt: now,
        confidence: 0.9,
      ));
    }

    // 3. متوسط قيمة الفاتورة
    if (sales.avgTransactionToday > 0) {
      insights.add(AiInsight(
        id: 'avg_transaction_${now.millisecondsSinceEpoch}',
        type: InsightType.salesTrend,
        priority: InsightPriority.low,
        title: 'متوسط الفاتورة اليوم',
        description:
            '${sales.avgTransactionToday.toStringAsFixed(2)} ر.س (${sales.todayTransactions} فاتورة)',
        data: {
          'avg': sales.avgTransactionToday,
          'count': sales.todayTransactions
        },
        createdAt: now,
        confidence: 1.0,
      ));
    }

    return insights;
  }

  // ==========================================================================
  // تحليل أوقات الذروة
  // ==========================================================================

  static List<AiInsight> _analyzePeakTimes(SalesAnalyticsData sales) {
    final insights = <AiInsight>[];
    final now = DateTime.now();

    // تحديد ساعة الذروة
    if (sales.hourlyDistribution.isNotEmpty) {
      final peakHour = sales.hourlyDistribution.entries
          .reduce((a, b) => a.value > b.value ? a : b);

      if (peakHour.value > 0) {
        final hourString = _formatHour(peakHour.key);
        insights.add(AiInsight(
          id: 'peak_hour_${now.millisecondsSinceEpoch}',
          type: InsightType.peakTime,
          priority: InsightPriority.low,
          title: 'وقت الذروة',
          description:
              'أعلى مبيعات عادةً بين الساعة $hourString - تأكد من توفر الموظفين!',
          data: {'peakHour': peakHour.key, 'sales': peakHour.value},
          createdAt: now,
          confidence: 0.75,
        ));
      }
    }

    // تحديد يوم الذروة
    if (sales.dailyDistribution.isNotEmpty) {
      final peakDay = sales.dailyDistribution.entries
          .reduce((a, b) => a.value > b.value ? a : b);

      if (peakDay.value > 0) {
        final dayName = _getDayName(peakDay.key);
        insights.add(AiInsight(
          id: 'peak_day_${now.millisecondsSinceEpoch}',
          type: InsightType.peakTime,
          priority: InsightPriority.low,
          title: 'يوم الذروة',
          description:
              'يوم $dayName هو الأكثر مبيعاً عادةً - خطط المخزون وفقاً لذلك.',
          data: {'peakDay': peakDay.key, 'sales': peakDay.value},
          createdAt: now,
          confidence: 0.7,
        ));
      }
    }

    return insights;
  }

  // ==========================================================================
  // ملخص التحليل
  // ==========================================================================

  static Map<String, dynamic> _generateSummary(
    List<ProductAnalyticsData> products,
    SalesAnalyticsData sales,
  ) {
    // المنتجات منخفضة المخزون
    final lowStockCount =
        products.where((p) => p.stockQty <= p.minStock && p.stockQty > 0).length;

    // المنتجات النافدة
    final outOfStockCount = products.where((p) => p.stockQty == 0).length;

    // المنتجات الأكثر مبيعاً
    final topProducts = [...products]
      ..sort((a, b) => b.soldThisWeek.compareTo(a.soldThisWeek));

    // المنتجات بطيئة الحركة
    final slowProducts = products
        .where((p) => p.stockQty > 0 && p.soldThisMonth == 0)
        .length;

    // متوسط هامش الربح
    final avgMargin = products.isNotEmpty
        ? products.map((p) => p.profitMargin).reduce((a, b) => a + b) /
            products.length
        : 0.0;

    return {
      'lowStockCount': lowStockCount,
      'outOfStockCount': outOfStockCount,
      'slowMovingCount': slowProducts,
      'topProducts': topProducts.take(5).map((p) => p.name).toList(),
      'avgProfitMargin': avgMargin,
      'todaySales': sales.todaySales,
      'dailyChange': sales.dailyChangePercent,
      'weeklyChange': sales.weeklyChangePercent,
      'avgTransaction': sales.avgTransactionToday,
    };
  }

  // ==========================================================================
  // مساعدات
  // ==========================================================================

  static String _formatHour(int hour) {
    if (hour == 0) return '12:00 ص';
    if (hour == 12) return '12:00 م';
    if (hour < 12) return '$hour:00 ص';
    return '${hour - 12}:00 م';
  }

  static String _getDayName(int day) {
    const days = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت'
    ];
    return days[day % 7];
  }

  // ==========================================================================
  // اقتراحات سريعة
  // ==========================================================================

  /// الحصول على اقتراحات سريعة للصفحة الرئيسية
  static List<AiInsight> getQuickInsights({
    required double todaySales,
    required double yesterdaySales,
    required int lowStockCount,
    required int outOfStockCount,
  }) {
    final insights = <AiInsight>[];
    final now = DateTime.now();

    // اقتراح المبيعات
    final dailyChange = yesterdaySales > 0
        ? ((todaySales - yesterdaySales) / yesterdaySales) * 100
        : 0.0;

    if (dailyChange >= 10) {
      insights.add(AiInsight(
        id: 'quick_sales_up',
        type: InsightType.salesTrend,
        priority: InsightPriority.low,
        title: 'أداء ممتاز اليوم! 🎉',
        description:
            'المبيعات أعلى بـ ${dailyChange.toStringAsFixed(0)}% من الأمس',
        createdAt: now,
      ));
    } else if (dailyChange <= -10) {
      insights.add(AiInsight(
        id: 'quick_sales_down',
        type: InsightType.salesTrend,
        priority: InsightPriority.medium,
        title: 'المبيعات أقل من الأمس',
        description:
            'جرب تفعيل عروض لزيادة المبيعات',
        createdAt: now,
      ));
    }

    // تحذير المخزون
    if (outOfStockCount > 0) {
      insights.add(AiInsight(
        id: 'quick_out_of_stock',
        type: InsightType.stockWarning,
        priority: InsightPriority.critical,
        title: '$outOfStockCount منتج نفد من المخزون!',
        description: 'راجع المخزون وأعد الطلب',
        actionLabel: 'عرض المخزون',
        actionRoute: '/inventory',
        createdAt: now,
      ));
    } else if (lowStockCount > 0) {
      insights.add(AiInsight(
        id: 'quick_low_stock',
        type: InsightType.stockWarning,
        priority: InsightPriority.high,
        title: '$lowStockCount منتج مخزونه منخفض',
        description: 'يُنصح بإعادة التخزين قريباً',
        actionLabel: 'عرض المخزون',
        actionRoute: '/inventory',
        createdAt: now,
      ));
    }

    return insights;
  }
}
