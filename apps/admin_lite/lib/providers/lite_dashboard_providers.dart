/// Lite Dashboard Providers
///
/// Combines dashboard data with pending approval counts
/// and recent activity from the audit log for the Admin Lite dashboard.
library;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';

// =============================================================================
// LITE STATS DATA MODEL
// =============================================================================

/// Combined stats for the Lite dashboard
class LiteStatsData {
  final int pendingApprovals;
  final double todaySales;
  final int lowStockCount;
  final int activeShifts;
  final int todayOrders;
  final double salesChangePercent;

  const LiteStatsData({
    this.pendingApprovals = 0,
    this.todaySales = 0,
    this.lowStockCount = 0,
    this.activeShifts = 0,
    this.todayOrders = 0,
    this.salesChangePercent = 0,
  });
}

/// Recent activity entry from audit log
class ActivityEntry {
  final String id;
  final String userName;
  final String action;
  final String? description;
  final DateTime timestamp;

  const ActivityEntry({
    required this.id,
    required this.userName,
    required this.action,
    this.description,
    required this.timestamp,
  });
}

// =============================================================================
// LITE STATS PROVIDER
// =============================================================================

/// Combined stats provider: dashboard data + pending approvals + active shifts
final liteStatsProvider = FutureProvider.autoDispose<LiteStatsData>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return const LiteStatsData();

  final db = GetIt.I<AppDatabase>();
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  final endOfToday = startOfToday.add(const Duration(days: 1));

  // Run queries in parallel
  final results = await Future.wait([
    // 0: Pending approvals count
    _getPendingApprovalsCount(db, storeId),
    // 1: Today's sales
    db.salesDao.getSalesStats(storeId, startDate: startOfToday, endDate: endOfToday),
    // 2: Yesterday's sales (for change %)
    db.salesDao.getSalesStats(
      storeId,
      startDate: startOfToday.subtract(const Duration(days: 1)),
      endDate: startOfToday,
    ),
    // 3: Low stock products
    db.productsDao.getLowStockProducts(storeId),
    // 4: Active shifts count
    _getActiveShiftsCount(db, storeId),
  ]);

  final pendingCount = results[0] as int;
  final todayStats = results[1] as SalesStats;
  final yesterdayStats = results[2] as SalesStats;
  final lowStock = results[3] as List<ProductsTableData>;
  final activeShifts = results[4] as int;

  double salesChange = 0;
  if (yesterdayStats.total > 0) {
    salesChange = ((todayStats.total - yesterdayStats.total) / yesterdayStats.total) * 100;
  } else if (todayStats.total > 0) {
    salesChange = 100;
  }

  return LiteStatsData(
    pendingApprovals: pendingCount,
    todaySales: todayStats.total,
    lowStockCount: lowStock.length,
    activeShifts: activeShifts,
    todayOrders: todayStats.count,
    salesChangePercent: salesChange,
  );
});

// =============================================================================
// RECENT ACTIVITY PROVIDER
// =============================================================================

/// Recent activity from audit log (last 20 entries)
final recentActivityProvider = FutureProvider.autoDispose<List<ActivityEntry>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];

  final db = GetIt.I<AppDatabase>();

  try {
    final logs = await db.auditLogDao.getLogs(storeId, limit: 20);

    return logs.map((log) => ActivityEntry(
      id: log.id,
      userName: log.userName,
      action: log.action,
      description: log.description,
      timestamp: log.createdAt,
    )).toList();
  } catch (_) {
    return [];
  }
});

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

Future<int> _getPendingApprovalsCount(AppDatabase db, String storeId) async {
  try {
    final result = await db.customSelect(
      '''SELECT COUNT(*) as count
         FROM returns
         WHERE store_id = ?
         AND status = 'pending' ''',
      variables: [Variable.withString(storeId)],
    ).getSingle();
    return result.data['count'] as int? ?? 0;
  } catch (_) {
    return 0;
  }
}

Future<int> _getActiveShiftsCount(AppDatabase db, String storeId) async {
  try {
    final result = await db.customSelect(
      '''SELECT COUNT(*) as count
         FROM shifts
         WHERE store_id = ?
         AND status = 'open' ''',
      variables: [Variable.withString(storeId)],
    ).getSingle();
    return result.data['count'] as int? ?? 0;
  } catch (_) {
    return 0;
  }
}
