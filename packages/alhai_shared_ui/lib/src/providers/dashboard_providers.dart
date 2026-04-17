/// Dashboard Providers - مزودات لوحة التحكم
///
/// توفر بيانات لوحة التحكم بشكل تفاعلي من قاعدة البيانات
/// بدلاً من القيم المحفوظة مسبقاً (hardcoded)
library;

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';

// ============================================================================
// DASHBOARD DATA MODEL
// ============================================================================

/// بيانات لوحة التحكم الكاملة
class DashboardData {
  final double todaySales;
  final int todayOrders;
  final int lowStockCount;
  final int newCustomersToday;
  final double yesterdaySales;
  final int yesterdayOrders;
  final int expiringProductsCount;
  final List<SalesTableData> recentSales;
  final List<ProductsTableData> topSellingProducts;
  final List<DailySalesData> weeklySales;
  final List<DailySalesData> monthlySales;

  const DashboardData({
    this.todaySales = 0,
    this.todayOrders = 0,
    this.lowStockCount = 0,
    this.newCustomersToday = 0,
    this.yesterdaySales = 0,
    this.yesterdayOrders = 0,
    this.expiringProductsCount = 0,
    this.recentSales = const [],
    this.topSellingProducts = const [],
    this.weeklySales = const [],
    this.monthlySales = const [],
  });

  /// نسبة التغير في المبيعات مقارنة بأمس
  double get salesChangePercent {
    if (yesterdaySales == 0) return todaySales > 0 ? 100 : 0;
    return ((todaySales - yesterdaySales) / yesterdaySales) * 100;
  }

  /// نسبة التغير في الطلبات مقارنة بأمس
  double get ordersChangePercent {
    if (yesterdayOrders == 0) return todayOrders > 0 ? 100 : 0;
    return ((todayOrders - yesterdayOrders) / yesterdayOrders) * 100;
  }
}

/// بيانات مبيعات يومية (للرسم البياني)
class DailySalesData {
  final DateTime date;
  final double total;
  final int count;

  const DailySalesData({
    required this.date,
    required this.total,
    required this.count,
  });
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// مزود بيانات لوحة التحكم الرئيسي
/// يجمع كل البيانات المطلوبة في استعلام واحد
/// Keeps data alive for 5 minutes to avoid re-fetching on tab switches.
final dashboardDataProvider = FutureProvider.autoDispose<DashboardData>((
  ref,
) async {
  // Keep the provider alive for 5 minutes after last listener detaches,
  // so navigating away and back doesn't trigger a re-fetch.
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), link.close);
  ref.onDispose(timer.cancel);

  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return const DashboardData();

  final db = GetIt.I<AppDatabase>();
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  final endOfToday = startOfToday.add(const Duration(days: 1));
  final startOfYesterday = startOfToday.subtract(const Duration(days: 1));

  // Parallel queries for performance
  final results = await Future.wait([
    // 0: Today's sales stats
    db.salesDao.getSalesStats(
      storeId,
      startDate: startOfToday,
      endDate: endOfToday,
    ),
    // 1: Yesterday's sales stats
    db.salesDao.getSalesStats(
      storeId,
      startDate: startOfYesterday,
      endDate: startOfToday,
    ),
    // 2: Low stock products
    db.productsDao.getLowStockProducts(storeId),
    // 3: New customers today
    _getTodayNewCustomersCount(db, storeId, startOfToday, endOfToday),
    // 4: Recent sales
    db.salesDao.getSalesByDate(storeId, now),
    // 5: Top selling products
    db.productsDao.getTopSellingProducts(storeId, limit: 5),
    // 6: Weekly sales data
    _getWeeklySales(db, storeId, now),
    // 7: Monthly sales data (last 4 weeks)
    _getMonthlySales(db, storeId, now),
    // 8: Expiring products count (within 7 days)
    _getExpiringProductsCount(db, storeId, now),
  ]);

  final todayStats = results[0] as SalesStats;
  final yesterdayStats = results[1] as SalesStats;
  final lowStockProducts = results[2] as List<ProductsTableData>;
  final newCustomers = results[3] as int;
  final recentSales = results[4] as List<SalesTableData>;
  final topProducts = results[5] as List<ProductsTableData>;
  final weeklySales = results[6] as List<DailySalesData>;
  final monthlySales = results[7] as List<DailySalesData>;
  final expiringCount = results[8] as int;

  return DashboardData(
    todaySales: todayStats.total,
    todayOrders: todayStats.count,
    lowStockCount: lowStockProducts.length,
    newCustomersToday: newCustomers,
    yesterdaySales: yesterdayStats.total,
    yesterdayOrders: yesterdayStats.count,
    expiringProductsCount: expiringCount,
    recentSales: recentSales.take(5).toList(),
    topSellingProducts: topProducts,
    weeklySales: weeklySales,
    monthlySales: monthlySales,
  );
});

/// عدد العملاء الجدد اليوم
Future<int> _getTodayNewCustomersCount(
  AppDatabase db,
  String storeId,
  DateTime startOfDay,
  DateTime endOfDay,
) async {
  try {
    final result = await db.customSelect(
      '''SELECT COUNT(*) as count
         FROM customers
         WHERE store_id = ?
         AND created_at >= ?
         AND created_at < ?''',
      variables: [
        Variable.withString(storeId),
        Variable.withDateTime(startOfDay),
        Variable.withDateTime(endOfDay),
      ],
    ).getSingle();
    return result.data['count'] as int? ?? 0;
  } catch (e) {
    if (kDebugMode) debugPrint('Error getting today customer count: $e');
    return 0;
  }
}

/// بيانات المبيعات الأسبوعية (آخر 7 أيام)
Future<List<DailySalesData>> _getWeeklySales(
  AppDatabase db,
  String storeId,
  DateTime now,
) async {
  final days = <DailySalesData>[];
  for (int i = 6; i >= 0; i--) {
    final date = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: i));
    final nextDate = date.add(const Duration(days: 1));
    try {
      final stats = await db.salesDao.getSalesStats(
        storeId,
        startDate: date,
        endDate: nextDate,
      );
      days.add(
        DailySalesData(date: date, total: stats.total, count: stats.count),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting daily sales for $date: $e');
      days.add(DailySalesData(date: date, total: 0, count: 0));
    }
  }
  return days;
}

/// بيانات المبيعات الشهرية (آخر 4 أسابيع)
Future<List<DailySalesData>> _getMonthlySales(
  AppDatabase db,
  String storeId,
  DateTime now,
) async {
  final weeks = <DailySalesData>[];
  for (int i = 3; i >= 0; i--) {
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: (i + 1) * 7));
    final weekEnd = weekStart.add(const Duration(days: 7));
    try {
      final stats = await db.salesDao.getSalesStats(
        storeId,
        startDate: weekStart,
        endDate: weekEnd,
      );
      weeks.add(
        DailySalesData(date: weekStart, total: stats.total, count: stats.count),
      );
    } catch (e) {
      if (kDebugMode)
        debugPrint('Error getting weekly sales for $weekStart: $e');
      weeks.add(DailySalesData(date: weekStart, total: 0, count: 0));
    }
  }
  return weeks;
}

/// عدد المنتجات قريبة الانتهاء (خلال 7 أيام)
Future<int> _getExpiringProductsCount(
  AppDatabase db,
  String storeId,
  DateTime now,
) async {
  try {
    final in7Days = now.add(const Duration(days: 7));
    final result = await db.customSelect(
      '''SELECT COUNT(*) as count
         FROM product_expiry
         WHERE store_id = ?
         AND expiry_date > ?
         AND expiry_date <= ?''',
      variables: [
        Variable.withString(storeId),
        Variable.withDateTime(now),
        Variable.withDateTime(in7Days),
      ],
    ).getSingle();
    return result.data['count'] as int? ?? 0;
  } catch (e) {
    if (kDebugMode) debugPrint('Error getting expiring products count: $e');
    return 0;
  }
}

/// مزود مراقبة مبيعات اليوم (Stream) - للتحديث التلقائي
final todaySalesStreamProvider =
    StreamProvider.autoDispose<List<SalesTableData>>((ref) {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return const Stream.empty();

  final db = GetIt.I<AppDatabase>();
  return db.salesDao.watchTodaySales(storeId);
});
