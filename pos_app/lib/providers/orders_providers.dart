/// Orders Providers - مزودات الطلبات
///
/// توفر بيانات الطلبات من قاعدة البيانات
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/app_database.dart';
import '../di/injection.dart';
import 'products_providers.dart';

// ============================================================================
// DATA MODELS
// ============================================================================

/// بيانات تفاصيل الطلب
class OrderDetailData {
  final OrdersTableData order;
  final List<OrderItemsTableData> items;

  const OrderDetailData({required this.order, required this.items});
}

// ============================================================================
// READ PROVIDERS
// ============================================================================

/// قائمة جميع الطلبات
final ordersListProvider =
    FutureProvider.autoDispose<List<OrdersTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = getIt<AppDatabase>();
  return db.ordersDao.getOrders(storeId);
});

/// الطلبات حسب الحالة
final ordersByStatusProvider = FutureProvider.autoDispose
    .family<List<OrdersTableData>, String>((ref, status) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = getIt<AppDatabase>();
  return db.ordersDao.getOrdersByStatus(storeId, status);
});

/// الطلبات المعلقة
final pendingOrdersProvider =
    FutureProvider.autoDispose<List<OrdersTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = getIt<AppDatabase>();
  return db.ordersDao.getPendingOrders(storeId);
});

/// إحصائيات حالات الطلبات
final ordersStatsProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return {};
  final db = getIt<AppDatabase>();
  return db.ordersDao.getOrdersCountByStatus(storeId);
});

/// عدد الطلبات المعلقة
final pendingOrdersCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return 0;
  final db = getIt<AppDatabase>();
  return db.ordersDao.getPendingOrdersCount(storeId);
});

/// إجمالي طلبات اليوم
final todayOrdersTotalProvider =
    FutureProvider.autoDispose<double>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return 0.0;
  final db = getIt<AppDatabase>();
  return db.ordersDao.getTodayOrdersTotal(storeId);
});

/// تفاصيل طلب واحد
final orderDetailProvider = FutureProvider.autoDispose
    .family<OrderDetailData?, String>((ref, id) async {
  final db = getIt<AppDatabase>();
  final order = await db.ordersDao.getOrderById(id);
  if (order == null) return null;
  final items = await db.ordersDao.getOrderItems(id);
  return OrderDetailData(order: order, items: items);
});

/// إحصائيات الطلبات التفصيلية
final ordersDetailedStatsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return {};
  final db = getIt<AppDatabase>();
  return db.ordersDao.getOrdersStats(storeId);
});

// ============================================================================
// ACTION HELPERS
// ============================================================================

/// تحديث حالة الطلب
Future<void> updateOrderStatus(
    WidgetRef ref, String orderId, String newStatus) async {
  final db = getIt<AppDatabase>();
  await db.ordersDao.updateOrderStatus(orderId, newStatus);
  ref.invalidate(ordersListProvider);
  ref.invalidate(ordersStatsProvider);
  ref.invalidate(pendingOrdersProvider);
  ref.invalidate(pendingOrdersCountProvider);
  ref.invalidate(orderDetailProvider(orderId));
}

/// إلغاء الطلب
Future<void> cancelOrder(
    WidgetRef ref, String orderId, String reason) async {
  final db = getIt<AppDatabase>();
  await db.ordersDao.cancelOrder(orderId, reason);
  ref.invalidate(ordersListProvider);
  ref.invalidate(ordersStatsProvider);
  ref.invalidate(pendingOrdersProvider);
  ref.invalidate(pendingOrdersCountProvider);
  ref.invalidate(orderDetailProvider(orderId));
}
