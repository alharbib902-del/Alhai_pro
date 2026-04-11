/// Lite Reports Providers
///
/// Riverpod providers for Admin Lite report screens:
/// daily sales, weekly comparison, top products, low stock,
/// employee performance, and cash flow.
library;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';

import '../core/services/sentry_service.dart' as sentry;

// =============================================================================
// REPORTS PROVIDERS
// =============================================================================

/// Daily sales data model
class DailySalesData {
  final SalesStats todayStats;
  final SalesStats refundStats;
  final List<PaymentMethodStats> paymentMethods;
  final List<HourlySales> hourlySales;
  final List<ProductsTableData> topProducts;

  const DailySalesData({
    required this.todayStats,
    required this.refundStats,
    required this.paymentMethods,
    required this.hourlySales,
    required this.topProducts,
  });
}

/// Provider: Today's full daily sales report
final liteDailySalesProvider = FutureProvider.autoDispose<DailySalesData>((
  ref,
) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) throw Exception('No store selected');

  final db = GetIt.I<AppDatabase>();
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  final endOfToday = startOfToday.add(const Duration(days: 1));

  final results = await Future.wait([
    db.salesDao.getSalesStats(
      storeId,
      startDate: startOfToday,
      endDate: endOfToday,
    ),
    db.salesDao.getPaymentMethodStats(
      storeId,
      startDate: startOfToday,
      endDate: endOfToday,
    ),
    db.salesDao.getHourlySales(storeId, now),
    db.productsDao.getTopSellingProducts(
      storeId,
      limit: 5,
      since: startOfToday,
    ),
  ]);

  // Refund stats via custom query
  SalesStats refundStats;
  try {
    final refundResult = await db
        .customSelect(
          '''SELECT COUNT(*) as count, COALESCE(SUM(total_refund), 0) as total,
            COALESCE(AVG(total_refund), 0) as average, 0 as max_sale, 0 as min_sale
         FROM returns WHERE store_id = ? AND created_at >= ? AND created_at < ?''',
          variables: [
            Variable.withString(storeId),
            Variable.withDateTime(startOfToday),
            Variable.withDateTime(endOfToday),
          ],
        )
        .getSingle();
    refundStats = SalesStats(
      count: refundResult.data['count'] as int? ?? 0,
      total: _toDouble(refundResult.data['total']),
      average: 0,
      maxSale: 0,
      minSale: 0,
    );
  } catch (e, st) {
    sentry.reportError(
      e,
      stackTrace: st,
      hint: 'liteDailySalesProvider.refundStats',
    );
    refundStats = const SalesStats(
      count: 0,
      total: 0,
      average: 0,
      maxSale: 0,
      minSale: 0,
    );
  }

  return DailySalesData(
    todayStats: results[0] as SalesStats,
    refundStats: refundStats,
    paymentMethods: results[1] as List<PaymentMethodStats>,
    hourlySales: results[2] as List<HourlySales>,
    topProducts: results[3] as List<ProductsTableData>,
  );
});

/// Weekly comparison data model
class WeeklyComparisonData {
  final SalesStats thisWeek;
  final SalesStats lastWeek;
  final List<DaySalesData> dailyBreakdown;
  final int thisWeekCustomers;
  final int lastWeekCustomers;

  const WeeklyComparisonData({
    required this.thisWeek,
    required this.lastWeek,
    required this.dailyBreakdown,
    required this.thisWeekCustomers,
    required this.lastWeekCustomers,
  });
}

class DaySalesData {
  final String dayName;
  final double current;
  final double previous;
  const DaySalesData({
    required this.dayName,
    required this.current,
    required this.previous,
  });
}

/// Provider: Weekly comparison (this week vs last week)
final liteWeeklyComparisonProvider =
    FutureProvider.autoDispose<WeeklyComparisonData>((ref) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) throw Exception('No store selected');

      final db = GetIt.I<AppDatabase>();
      final now = DateTime.now();
      final todayWeekday = now.weekday; // 1=Mon .. 7=Sun
      // Saturday-based week start (weekday 6)
      final daysSinceSat = (todayWeekday + 1) % 7;
      final startOfThisWeek = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: daysSinceSat));
      final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
      final endOfThisWeek = startOfThisWeek.add(const Duration(days: 7));

      final results = await Future.wait([
        db.salesDao.getSalesStats(
          storeId,
          startDate: startOfThisWeek,
          endDate: endOfThisWeek,
        ),
        db.salesDao.getSalesStats(
          storeId,
          startDate: startOfLastWeek,
          endDate: startOfThisWeek,
        ),
      ]);

      final thisWeekStats = results[0];
      final lastWeekStats = results[1];

      // Build daily breakdown — batch all 14 queries in parallel
      final dayNames = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
      final dayFutures = <Future<SalesStats>>[];
      for (int i = 0; i < 7; i++) {
        final dayStart = startOfThisWeek.add(Duration(days: i));
        final dayEnd = dayStart.add(const Duration(days: 1));
        final prevDayStart = startOfLastWeek.add(Duration(days: i));
        final prevDayEnd = prevDayStart.add(const Duration(days: 1));
        dayFutures.add(
          db.salesDao.getSalesStats(
            storeId,
            startDate: dayStart,
            endDate: dayEnd,
          ),
        );
        dayFutures.add(
          db.salesDao.getSalesStats(
            storeId,
            startDate: prevDayStart,
            endDate: prevDayEnd,
          ),
        );
      }
      final dayResults = await Future.wait(dayFutures);
      final dailyBreakdown = <DaySalesData>[];
      for (int i = 0; i < 7; i++) {
        dailyBreakdown.add(
          DaySalesData(
            dayName: dayNames[i],
            current: dayResults[i * 2].total,
            previous: dayResults[i * 2 + 1].total,
          ),
        );
      }

      // Customer counts via custom query
      int thisWeekCustomers = 0;
      int lastWeekCustomers = 0;
      try {
        final cThis = await db
            .customSelect(
              '''SELECT COUNT(DISTINCT customer_id) as count FROM sales
         WHERE store_id = ? AND created_at >= ? AND created_at < ?
         AND customer_id IS NOT NULL AND status = 'completed' ''',
              variables: [
                Variable.withString(storeId),
                Variable.withDateTime(startOfThisWeek),
                Variable.withDateTime(endOfThisWeek),
              ],
            )
            .getSingle();
        thisWeekCustomers = cThis.data['count'] as int? ?? 0;

        final cLast = await db
            .customSelect(
              '''SELECT COUNT(DISTINCT customer_id) as count FROM sales
         WHERE store_id = ? AND created_at >= ? AND created_at < ?
         AND customer_id IS NOT NULL AND status = 'completed' ''',
              variables: [
                Variable.withString(storeId),
                Variable.withDateTime(startOfLastWeek),
                Variable.withDateTime(startOfThisWeek),
              ],
            )
            .getSingle();
        lastWeekCustomers = cLast.data['count'] as int? ?? 0;
      } catch (e, st) {
        sentry.reportError(
          e,
          stackTrace: st,
          hint: 'liteWeeklyComparisonProvider.customerCounts',
        );
      }

      return WeeklyComparisonData(
        thisWeek: thisWeekStats,
        lastWeek: lastWeekStats,
        dailyBreakdown: dailyBreakdown,
        thisWeekCustomers: thisWeekCustomers,
        lastWeekCustomers: lastWeekCustomers,
      );
    });

/// Top products data model
class TopProductData {
  final String name;
  final double revenue;
  final int quantity;
  final String productId;
  const TopProductData({
    required this.name,
    required this.revenue,
    required this.quantity,
    required this.productId,
  });
}

/// Provider: Top selling products with revenue + quantity
final liteTopProductsProvider =
    FutureProvider.autoDispose<List<TopProductData>>((ref) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return [];

      final db = GetIt.I<AppDatabase>();
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      try {
        final result = await db
            .customSelect(
              '''SELECT si.product_id, p.name,
            COALESCE(SUM(si.qty * si.unit_price), 0) as revenue,
            COALESCE(SUM(si.qty), 0) as total_qty
         FROM sale_items si
         INNER JOIN sales s ON si.sale_id = s.id
         INNER JOIN products p ON si.product_id = p.id
         WHERE s.store_id = ? AND s.status = 'completed'
         AND s.created_at >= ?
         GROUP BY si.product_id
         ORDER BY revenue DESC
         LIMIT 20''',
              variables: [
                Variable.withString(storeId),
                Variable.withDateTime(startOfMonth),
              ],
            )
            .get();

        return result
            .map(
              (row) => TopProductData(
                name: row.data['name'] as String? ?? '',
                revenue: _toDouble(row.data['revenue']),
                quantity: (row.data['total_qty'] is int)
                    ? row.data['total_qty'] as int
                    : (row.data['total_qty'] as double?)?.toInt() ?? 0,
                productId: row.data['product_id'] as String? ?? '',
              ),
            )
            .toList();
      } catch (e, st) {
        sentry.reportError(e, stackTrace: st, hint: 'liteTopProductsProvider');
        return [];
      }
    });

/// Provider: Low stock products
final liteLowStockProvider =
    FutureProvider.autoDispose<List<ProductsTableData>>((ref) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return [];

      final db = GetIt.I<AppDatabase>();
      return db.productsDao.getLowStockProducts(storeId);
    });

/// Employee performance data model
class EmployeePerformanceData {
  final String userId;
  final String name;
  final String role;
  final double totalSales;
  final int transactionCount;
  const EmployeePerformanceData({
    required this.userId,
    required this.name,
    required this.role,
    required this.totalSales,
    required this.transactionCount,
  });
}

/// Provider: Employee performance (sales grouped by cashier)
final liteEmployeePerformanceProvider =
    FutureProvider.autoDispose<List<EmployeePerformanceData>>((ref) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return [];

      final db = GetIt.I<AppDatabase>();
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      try {
        final result = await db
            .customSelect(
              '''SELECT s.cashier_id, u.name, u.role,
            COALESCE(SUM(s.total), 0) as total_sales,
            COUNT(*) as txn_count
         FROM sales s
         LEFT JOIN users u ON s.cashier_id = u.id
         WHERE s.store_id = ? AND s.status = 'completed'
         AND s.created_at >= ?
         GROUP BY s.cashier_id
         ORDER BY total_sales DESC''',
              variables: [
                Variable.withString(storeId),
                Variable.withDateTime(startOfMonth),
              ],
            )
            .get();

        return result
            .map(
              (row) => EmployeePerformanceData(
                userId: row.data['cashier_id'] as String? ?? '',
                name: row.data['name'] as String? ?? 'Unknown',
                role: row.data['role'] as String? ?? 'Cashier',
                totalSales: _toDouble(row.data['total_sales']),
                transactionCount: row.data['txn_count'] as int? ?? 0,
              ),
            )
            .toList();
      } catch (e, st) {
        sentry.reportError(
          e,
          stackTrace: st,
          hint: 'liteEmployeePerformanceProvider',
        );
        return [];
      }
    });

/// Cash flow data model
class CashFlowData {
  final double totalInflow;
  final double totalOutflow;
  final double netCash;
  final List<PaymentMethodStats> inflowBreakdown;
  final double refundTotal;
  final double expenseTotal;
  final List<DaySalesData> weeklyTrend;

  const CashFlowData({
    required this.totalInflow,
    required this.totalOutflow,
    required this.netCash,
    required this.inflowBreakdown,
    required this.refundTotal,
    required this.expenseTotal,
    required this.weeklyTrend,
  });
}

/// Provider: Cash flow overview
final liteCashFlowProvider = FutureProvider.autoDispose<CashFlowData>((
  ref,
) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) throw Exception('No store selected');

  final db = GetIt.I<AppDatabase>();
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  final endOfToday = startOfToday.add(const Duration(days: 1));

  // Sales (inflow) + payment breakdown
  final results = await Future.wait([
    db.salesDao.getSalesStats(
      storeId,
      startDate: startOfToday,
      endDate: endOfToday,
    ),
    db.salesDao.getPaymentMethodStats(
      storeId,
      startDate: startOfToday,
      endDate: endOfToday,
    ),
    db.expensesDao.getTodayExpensesTotal(storeId),
  ]);

  final todayStats = results[0] as SalesStats;
  final paymentBreakdown = results[1] as List<PaymentMethodStats>;
  final expenseTotal = results[2] as double;

  // Refund total
  double refundTotal = 0;
  try {
    final refundResult = await db
        .customSelect(
          '''SELECT COALESCE(SUM(total_refund), 0) as total
         FROM returns WHERE store_id = ? AND created_at >= ? AND created_at < ?''',
          variables: [
            Variable.withString(storeId),
            Variable.withDateTime(startOfToday),
            Variable.withDateTime(endOfToday),
          ],
        )
        .getSingle();
    refundTotal = _toDouble(refundResult.data['total']);
  } catch (e, st) {
    sentry.reportError(
      e,
      stackTrace: st,
      hint: 'liteCashFlowProvider.refundTotal',
    );
  }

  final totalOutflow = refundTotal + expenseTotal;

  // Weekly trend (last 7 days)
  final dayNames = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final todayWeekday = now.weekday;
  final daysSinceSat = (todayWeekday + 1) % 7;
  final startOfWeek = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(Duration(days: daysSinceSat));

  // Batch all 7 daily queries in parallel
  final trendFutures = <Future<SalesStats>>[];
  for (int i = 0; i < 7; i++) {
    final dayStart = startOfWeek.add(Duration(days: i));
    final dayEnd = dayStart.add(const Duration(days: 1));
    trendFutures.add(
      db.salesDao.getSalesStats(storeId, startDate: dayStart, endDate: dayEnd),
    );
  }
  final trendResults = await Future.wait(trendFutures);
  final weeklyTrend = <DaySalesData>[];
  for (int i = 0; i < 7; i++) {
    weeklyTrend.add(
      DaySalesData(
        dayName: dayNames[i],
        current: trendResults[i].total,
        previous: 0,
      ),
    );
  }

  return CashFlowData(
    totalInflow: todayStats.total,
    totalOutflow: totalOutflow,
    netCash: todayStats.total - totalOutflow,
    inflowBreakdown: paymentBreakdown,
    refundTotal: refundTotal,
    expenseTotal: expenseTotal,
    weeklyTrend: weeklyTrend,
  );
});

// =============================================================================
// HELPERS
// =============================================================================

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is int) return value.toDouble();
  return value as double;
}
