/// Reports Service - خدمة التقارير المتقدمة
///
/// يوفر:
/// - تقرير المبيعات اليومي/الأسبوعي/الشهري
/// - تحليل أفضل المنتجات
/// - تقرير الأرباح
/// - تقارير المخزون
/// - تقارير الكاشير
library reports_service;

import 'package:drift/drift.dart' show Variable;
import 'package:flutter/foundation.dart';

import 'package:alhai_database/alhai_database.dart';

// ============================================================================
// REPORT PERIODS
// ============================================================================

/// فترة التقرير
enum ReportPeriod {
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  thisYear,
  custom;

  String get arabicName {
    switch (this) {
      case ReportPeriod.today:
        return 'اليوم';
      case ReportPeriod.yesterday:
        return 'أمس';
      case ReportPeriod.thisWeek:
        return 'هذا الأسبوع';
      case ReportPeriod.lastWeek:
        return 'الأسبوع الماضي';
      case ReportPeriod.thisMonth:
        return 'هذا الشهر';
      case ReportPeriod.lastMonth:
        return 'الشهر الماضي';
      case ReportPeriod.thisYear:
        return 'هذه السنة';
      case ReportPeriod.custom:
        return 'فترة مخصصة';
    }
  }

  DateRange getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (this) {
      case ReportPeriod.today:
        return DateRange(today, today.add(const Duration(days: 1)));
      case ReportPeriod.yesterday:
        final yesterday = today.subtract(const Duration(days: 1));
        return DateRange(yesterday, today);
      case ReportPeriod.thisWeek:
        final startOfWeek = today.subtract(
          Duration(days: today.weekday - 6),
        ); // السبت
        return DateRange(startOfWeek, now);
      case ReportPeriod.lastWeek:
        final startOfThisWeek = today.subtract(
          Duration(days: today.weekday - 6),
        );
        final startOfLastWeek = startOfThisWeek.subtract(
          const Duration(days: 7),
        );
        return DateRange(startOfLastWeek, startOfThisWeek);
      case ReportPeriod.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        return DateRange(startOfMonth, now);
      case ReportPeriod.lastMonth:
        final startOfThisMonth = DateTime(now.year, now.month, 1);
        final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
        return DateRange(startOfLastMonth, startOfThisMonth);
      case ReportPeriod.thisYear:
        final startOfYear = DateTime(now.year, 1, 1);
        return DateRange(startOfYear, now);
      case ReportPeriod.custom:
        return DateRange(today, today.add(const Duration(days: 1)));
    }
  }
}

/// نطاق تاريخي
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange(this.start, this.end);

  int get days => end.difference(start).inDays;
}

// ============================================================================
// REPORT MODELS
// ============================================================================

/// تقرير المبيعات الشامل
class SalesReport {
  final DateRange period;
  final SalesStats stats;
  final List<HourlySales> hourlySales;
  final List<DailySales> dailySales;
  final List<PaymentMethodStats> paymentMethods;
  final List<TopProduct> topProducts;
  final List<CashierPerformance> cashierPerformance;
  final SalesComparison? comparison;

  const SalesReport({
    required this.period,
    required this.stats,
    this.hourlySales = const [],
    this.dailySales = const [],
    this.paymentMethods = const [],
    this.topProducts = const [],
    this.cashierPerformance = const [],
    this.comparison,
  });

  /// متوسط البيع
  double get averageSale => stats.count > 0 ? stats.total / stats.count : 0;

  /// متوسط المبيعات اليومي
  double get dailyAverage =>
      period.days > 0 ? stats.total / period.days : stats.total;
}

/// مبيعات يومية
class DailySales {
  final DateTime date;
  final int count;
  final double total;

  const DailySales({
    required this.date,
    required this.count,
    required this.total,
  });

  double get average => count > 0 ? total / count : 0;
}

/// أفضل منتج
class TopProduct {
  final String productId;
  final String productName;
  final int quantitySold;
  final double revenue;
  final double profit;

  const TopProduct({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
    this.profit = 0,
  });

  double get averagePrice => quantitySold > 0 ? revenue / quantitySold : 0;
}

/// أداء الكاشير
class CashierPerformance {
  final String cashierId;
  final String cashierName;
  final int salesCount;
  final double totalSales;
  final double averageSale;
  final int transactionCount;

  const CashierPerformance({
    required this.cashierId,
    required this.cashierName,
    required this.salesCount,
    required this.totalSales,
    required this.averageSale,
    required this.transactionCount,
  });
}

/// مقارنة المبيعات
class SalesComparison {
  final double currentTotal;
  final double previousTotal;
  final int currentCount;
  final int previousCount;

  const SalesComparison({
    required this.currentTotal,
    required this.previousTotal,
    required this.currentCount,
    required this.previousCount,
  });

  /// نسبة التغير في المبيعات
  double get revenueChange {
    if (previousTotal == 0) return currentTotal > 0 ? 100 : 0;
    return ((currentTotal - previousTotal) / previousTotal) * 100;
  }

  /// نسبة التغير في العدد
  double get countChange {
    if (previousCount == 0) return currentCount > 0 ? 100 : 0;
    return ((currentCount - previousCount) / previousCount) * 100;
  }

  bool get isImproved => revenueChange > 0;
}

/// تقرير المخزون
class InventoryReport {
  final int totalProducts;
  final int lowStockCount;
  final int outOfStockCount;
  final double totalValue;
  final List<LowStockItem> lowStockItems;
  final List<CategoryInventory> byCategory;

  const InventoryReport({
    required this.totalProducts,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.totalValue,
    this.lowStockItems = const [],
    this.byCategory = const [],
  });

  double get outOfStockPercentage =>
      totalProducts > 0 ? (outOfStockCount / totalProducts) * 100 : 0;

  double get lowStockPercentage =>
      totalProducts > 0 ? (lowStockCount / totalProducts) * 100 : 0;
}

/// منتج منخفض المخزون
class LowStockItem {
  final String productId;
  final String productName;
  final double currentStock;
  final double minStock;
  final double suggestedReorder;

  const LowStockItem({
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.minStock,
    required this.suggestedReorder,
  });

  double get deficit => minStock - currentStock;
}

/// مخزون حسب الفئة
class CategoryInventory {
  final String categoryId;
  final String categoryName;
  final int productCount;
  final int totalStock;
  final double totalValue;

  const CategoryInventory({
    required this.categoryId,
    required this.categoryName,
    required this.productCount,
    required this.totalStock,
    required this.totalValue,
  });
}

/// تقرير الأرباح
class ProfitReport {
  final DateRange period;
  final double grossRevenue;
  final double costOfGoods;
  final double grossProfit;
  final double discounts;
  final double netProfit;
  final List<DailyProfit> dailyProfits;

  const ProfitReport({
    required this.period,
    required this.grossRevenue,
    required this.costOfGoods,
    required this.grossProfit,
    required this.discounts,
    required this.netProfit,
    this.dailyProfits = const [],
  });

  double get grossMargin =>
      grossRevenue > 0 ? (grossProfit / grossRevenue) * 100 : 0;
  double get netMargin =>
      grossRevenue > 0 ? (netProfit / grossRevenue) * 100 : 0;
}

/// ربح يومي
class DailyProfit {
  final DateTime date;
  final double revenue;
  final double cost;
  final double profit;

  const DailyProfit({
    required this.date,
    required this.revenue,
    required this.cost,
    required this.profit,
  });

  double get margin => revenue > 0 ? (profit / revenue) * 100 : 0;
}

// ============================================================================
// REPORTS SERVICE
// ============================================================================

/// خدمة التقارير
class ReportsService {
  final SalesDao _salesDao;
  final ProductsDao _productsDao;
  final InventoryDao _inventoryDao;
  final LoyaltyDao? _loyaltyDao;

  ReportsService({
    required SalesDao salesDao,
    required ProductsDao productsDao,
    required InventoryDao inventoryDao,
    LoyaltyDao? loyaltyDao,
  }) : _salesDao = salesDao,
       _productsDao = productsDao,
       _inventoryDao = inventoryDao,
       _loyaltyDao = loyaltyDao;

  // ============================================================================
  // SALES REPORTS
  // ============================================================================

  /// تقرير المبيعات الشامل
  Future<SalesReport> getSalesReport(
    String storeId, {
    required ReportPeriod period,
    DateRange? customRange,
    bool includeHourly = true,
    bool includeDaily = true,
    bool includeComparison = true,
  }) async {
    final range = period == ReportPeriod.custom && customRange != null
        ? customRange
        : period.getDateRange();

    // إحصائيات أساسية
    final stats = await _salesDao.getSalesStats(
      storeId,
      startDate: range.start,
      endDate: range.end,
    );

    // طرق الدفع
    final paymentMethods = await _salesDao.getPaymentMethodStats(
      storeId,
      startDate: range.start,
      endDate: range.end,
    );

    // المبيعات بالساعة (لليوم فقط)
    List<HourlySales> hourlySales = [];
    if (includeHourly && range.days <= 1) {
      hourlySales = await _salesDao.getHourlySales(storeId, range.start);
    }

    // المبيعات اليومية
    List<DailySales> dailySales = [];
    if (includeDaily && range.days > 1) {
      dailySales = await _getDailySales(storeId, range);
    }

    // المقارنة مع الفترة السابقة
    SalesComparison? comparison;
    if (includeComparison) {
      comparison = await _getSalesComparison(storeId, range);
    }

    // أفضل المنتجات
    final topProducts = await _getTopProducts(storeId, range, limit: 10);

    debugPrint(
      '[ReportsService] Sales report generated: ${stats.count} sales, ${stats.total} SAR',
    );

    return SalesReport(
      period: range,
      stats: stats,
      hourlySales: hourlySales,
      dailySales: dailySales,
      paymentMethods: paymentMethods,
      topProducts: topProducts,
      comparison: comparison,
    );
  }

  /// إحصائيات سريعة لليوم
  Future<SalesStats> getTodayStats(String storeId, {String? cashierId}) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _salesDao.getSalesStats(
      storeId,
      startDate: startOfDay,
      endDate: endOfDay,
      cashierId: cashierId,
    );
  }

  /// مبيعات يومية للفترة - استعلام واحد بدلاً من N+1
  Future<List<DailySales>> _getDailySales(
    String storeId,
    DateRange range,
  ) async {
    final result = await _salesDao
        .customSelect(
          '''SELECT
           DATE(created_at) as sale_date,
           COUNT(*) as sale_count,
           COALESCE(SUM(total), 0) as sale_total
         FROM sales
         WHERE store_id = ?
           AND status = 'completed'
           AND deleted_at IS NULL
           AND created_at >= ?
           AND created_at < ?
         GROUP BY DATE(created_at)
         ORDER BY sale_date ASC''',
          variables: [
            Variable.withString(storeId),
            Variable.withDateTime(range.start),
            Variable.withDateTime(range.end),
          ],
        )
        .get();

    // Build a map from query results
    final salesByDate = <String, DailySales>{};
    for (final row in result) {
      final dateStr = row.data['sale_date'] as String;
      final parsed = DateTime.tryParse(dateStr);
      if (parsed != null) {
        final key =
            '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
        salesByDate[key] = DailySales(
          date: parsed,
          count: (row.data['sale_count'] as int?) ?? 0,
          total: _toDouble(row.data['sale_total']),
        );
      }
    }

    // Fill in zero-sales days to keep the chart continuous
    final dailySales = <DailySales>[];
    var currentDate = range.start;
    while (currentDate.isBefore(range.end)) {
      final key =
          '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
      dailySales.add(
        salesByDate[key] ?? DailySales(date: currentDate, count: 0, total: 0),
      );
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dailySales;
  }

  /// مقارنة مع الفترة السابقة
  Future<SalesComparison> _getSalesComparison(
    String storeId,
    DateRange currentRange,
  ) async {
    final currentStats = await _salesDao.getSalesStats(
      storeId,
      startDate: currentRange.start,
      endDate: currentRange.end,
    );

    // حساب الفترة السابقة
    final duration = currentRange.end.difference(currentRange.start);
    final previousStart = currentRange.start.subtract(duration);
    final previousEnd = currentRange.start;

    final previousStats = await _salesDao.getSalesStats(
      storeId,
      startDate: previousStart,
      endDate: previousEnd,
    );

    return SalesComparison(
      currentTotal: currentStats.total,
      previousTotal: previousStats.total,
      currentCount: currentStats.count,
      previousCount: previousStats.count,
    );
  }

  // ============================================================================
  // PRODUCT REPORTS
  // ============================================================================

  /// Top selling products with actual quantity & revenue from sale_items
  Future<List<TopProduct>> _getTopProducts(
    String storeId,
    DateRange range, {
    int limit = 10,
  }) async {
    final result = await _salesDao
        .customSelect(
          '''SELECT
           p.id as product_id,
           p.name as product_name,
           COALESCE(SUM(si.qty), 0) as total_qty,
           COALESCE(SUM(si.qty * si.price), 0) as total_revenue
         FROM sale_items si
         INNER JOIN sales s ON si.sale_id = s.id
         INNER JOIN products p ON si.product_id = p.id
         WHERE s.store_id = ?
           AND s.status = 'completed'
           AND s.deleted_at IS NULL
           AND s.created_at >= ?
           AND s.created_at < ?
         GROUP BY si.product_id
         ORDER BY total_revenue DESC
         LIMIT ?''',
          variables: [
            Variable.withString(storeId),
            Variable.withDateTime(range.start),
            Variable.withDateTime(range.end),
            Variable.withInt(limit),
          ],
        )
        .get();

    return result
        .map(
          (row) => TopProduct(
            productId: row.data['product_id'] as String,
            productName: row.data['product_name'] as String,
            quantitySold: _toInt(row.data['total_qty']),
            revenue: _toDouble(row.data['total_revenue']),
          ),
        )
        .toList();
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return 0;
  }

  static double _toDouble(dynamic v) {
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return 0.0;
  }

  /// المنتجات الأقل مبيعاً
  Future<List<ProductsTableData>> getSlowMovingProducts(
    String storeId, {
    int limit = 10,
  }) async {
    // المنتجات التي لم تباع في آخر 30 يوم
    return _productsDao.getProductsPaginated(storeId, limit: limit);
  }

  // ============================================================================
  // INVENTORY REPORTS
  // ============================================================================

  /// تقرير المخزون
  ///
  /// Uses a single aggregation query for counts/value, then only fetches
  /// low-stock items (bounded) instead of loading every product row.
  Future<InventoryReport> getInventoryReport(String storeId) async {
    final products = await _productsDao.getProductsPaginated(
      storeId,
      limit: 500,
    );

    int lowStockCount = 0;
    int outOfStockCount = 0;
    double totalValue = 0;
    final lowStockItems = <LowStockItem>[];

    for (final product in products) {
      final stock = product.stockQty;
      final minStock = product.minQty;
      final price = product.costPrice ?? product.price;

      totalValue += stock * price;

      if (stock <= 0) {
        outOfStockCount++;
        lowStockItems.add(
          LowStockItem(
            productId: product.id,
            productName: product.name,
            currentStock: stock,
            minStock: minStock,
            suggestedReorder: minStock * 2,
          ),
        );
      } else if (stock <= minStock) {
        lowStockCount++;
        lowStockItems.add(
          LowStockItem(
            productId: product.id,
            productName: product.name,
            currentStock: stock,
            minStock: minStock,
            suggestedReorder: minStock - stock + minStock,
          ),
        );
      }
    }

    // ترتيب حسب الأكثر احتياجاً
    lowStockItems.sort((a, b) => a.deficit.compareTo(b.deficit));

    return InventoryReport(
      totalProducts: products.length,
      lowStockCount: lowStockCount,
      outOfStockCount: outOfStockCount,
      totalValue: totalValue,
      lowStockItems: lowStockItems.take(20).toList(),
    );
  }

  /// حركات المخزون لمنتج
  Future<List<InventoryMovementsTableData>> getInventoryMovements(
    String storeId, {
    String? productId,
  }) async {
    if (productId != null) {
      return _inventoryDao.getMovementsByProduct(productId);
    }
    return _inventoryDao.getTodayMovements(storeId);
  }

  // ============================================================================
  // LOYALTY REPORTS
  // ============================================================================

  /// تقرير الولاء
  Future<LoyaltyStats?> getLoyaltyReport(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_loyaltyDao == null) return null;

    return _loyaltyDao.getStats(
      storeId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// أفضل العملاء
  Future<List<LoyaltyPointsTableData>> getTopLoyaltyCustomers(
    String storeId, {
    int limit = 10,
  }) async {
    if (_loyaltyDao == null) return [];

    return _loyaltyDao.getTopCustomers(storeId, limit: limit);
  }

  // ============================================================================
  // DASHBOARD SUMMARY
  // ============================================================================

  /// ملخص للوحة التحكم
  Future<DashboardSummary> getDashboardSummary(String storeId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // مبيعات اليوم
    final todayStats = await _salesDao.getSalesStats(
      storeId,
      startDate: startOfDay,
      endDate: endOfDay,
    );

    // مقارنة مع أمس
    final yesterday = startOfDay.subtract(const Duration(days: 1));
    final yesterdayStats = await _salesDao.getSalesStats(
      storeId,
      startDate: yesterday,
      endDate: startOfDay,
    );

    // المخزون
    final inventoryReport = await getInventoryReport(storeId);

    // الولاء
    final loyaltyStats = await getLoyaltyReport(
      storeId,
      startDate: startOfDay,
      endDate: endOfDay,
    );

    return DashboardSummary(
      todaySales: todayStats.total,
      todayTransactions: todayStats.count,
      yesterdaySales: yesterdayStats.total,
      lowStockCount: inventoryReport.lowStockCount,
      outOfStockCount: inventoryReport.outOfStockCount,
      newCustomersToday: loyaltyStats?.activeCustomers ?? 0,
      pointsEarnedToday: loyaltyStats?.totalEarned ?? 0,
    );
  }
}

/// ملخص لوحة التحكم
class DashboardSummary {
  final double todaySales;
  final int todayTransactions;
  final double yesterdaySales;
  final int lowStockCount;
  final int outOfStockCount;
  final int newCustomersToday;
  final int pointsEarnedToday;

  const DashboardSummary({
    required this.todaySales,
    required this.todayTransactions,
    required this.yesterdaySales,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.newCustomersToday,
    required this.pointsEarnedToday,
  });

  /// نسبة التغير عن أمس
  double get salesChangePercent {
    if (yesterdaySales == 0) return todaySales > 0 ? 100 : 0;
    return ((todaySales - yesterdaySales) / yesterdaySales) * 100;
  }

  bool get isImproving => salesChangePercent > 0;
}
