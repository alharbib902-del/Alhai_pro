/// Orders Providers - مزودات الطلبات
///
/// توفر بيانات الطلبات من قاعدة البيانات
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:uuid/uuid.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';

const _uuid = Uuid();

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
final ordersListProvider = FutureProvider.autoDispose<List<OrdersTableData>>((
  ref,
) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = GetIt.I<AppDatabase>();
  return db.ordersDao.getOrders(storeId);
});

/// الطلبات حسب الحالة
final ordersByStatusProvider = FutureProvider.autoDispose
    .family<List<OrdersTableData>, String>((ref, status) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return [];
      final db = GetIt.I<AppDatabase>();
      return db.ordersDao.getOrdersByStatus(storeId, status);
    });

/// الطلبات المعلقة
final pendingOrdersProvider = FutureProvider.autoDispose<List<OrdersTableData>>(
  (ref) async {
    final storeId = ref.watch(currentStoreIdProvider);
    if (storeId == null) return [];
    final db = GetIt.I<AppDatabase>();
    return db.ordersDao.getPendingOrders(storeId);
  },
);

/// إحصائيات حالات الطلبات
final ordersStatsProvider = FutureProvider.autoDispose<Map<String, int>>((
  ref,
) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return {};
  final db = GetIt.I<AppDatabase>();
  return db.ordersDao.getOrdersCountByStatus(storeId);
});

/// عدد الطلبات المعلقة
final pendingOrdersCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return 0;
  final db = GetIt.I<AppDatabase>();
  return db.ordersDao.getPendingOrdersCount(storeId);
});

/// إجمالي طلبات اليوم
final todayOrdersTotalProvider = FutureProvider.autoDispose<double>((
  ref,
) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return 0.0;
  final db = GetIt.I<AppDatabase>();
  return db.ordersDao.getTodayOrdersTotal(storeId);
});

/// تفاصيل طلب واحد
final orderDetailProvider = FutureProvider.autoDispose
    .family<OrderDetailData?, String>((ref, id) async {
      final db = GetIt.I<AppDatabase>();
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
      final db = GetIt.I<AppDatabase>();
      return db.ordersDao.getOrdersStats(storeId);
    });

// ============================================================================
// ACTION HELPERS
// ============================================================================

/// تحديث حالة الطلب
Future<void> updateOrderStatus(
  WidgetRef ref,
  String orderId,
  String newStatus,
) async {
  final db = GetIt.I<AppDatabase>();

  // جلب الحالة القديمة قبل التحديث
  final oldOrder = await db.ordersDao.getOrderById(orderId);
  final oldStatus = oldOrder?.status;

  await db.ordersDao.updateOrderStatus(orderId, newStatus);

  // إضافة لطابور المزامنة - تحديث حالة الطلب
  final now = DateTime.now();
  await db.syncQueueDao.enqueue(
    id: _uuid.v4(),
    tableName: 'orders',
    recordId: orderId,
    operation: 'UPDATE',
    payload:
        '{"id":"$orderId","status":"$newStatus","updated_at":"${now.toUtc().toIso8601String()}"}',
    idempotencyKey: 'order_status_${orderId}_$newStatus',
  );

  // إضافة سجل في تاريخ حالات الطلب
  final historyId = _uuid.v4();
  await db.customStatement(
    'INSERT INTO order_status_history (id, order_id, from_status, to_status, created_at) VALUES (?, ?, ?, ?, ?)',
    [
      historyId,
      orderId,
      oldStatus,
      newStatus,
      now.millisecondsSinceEpoch ~/ 1000,
    ],
  );
  await db.syncQueueDao.enqueue(
    id: _uuid.v4(),
    tableName: 'order_status_history',
    recordId: historyId,
    operation: 'CREATE',
    payload:
        '{"id":"$historyId","order_id":"$orderId","from_status":"${oldStatus ?? ''}","to_status":"$newStatus","created_at":"${now.toUtc().toIso8601String()}"}',
    idempotencyKey: 'order_history_$historyId',
  );

  ref.invalidate(ordersListProvider);
  ref.invalidate(ordersStatsProvider);
  ref.invalidate(pendingOrdersProvider);
  ref.invalidate(pendingOrdersCountProvider);
  ref.invalidate(orderDetailProvider(orderId));
}

/// إلغاء الطلب
Future<void> cancelOrder(WidgetRef ref, String orderId, String reason) async {
  final db = GetIt.I<AppDatabase>();

  // جلب الحالة القديمة قبل الإلغاء
  final oldOrder = await db.ordersDao.getOrderById(orderId);
  final oldStatus = oldOrder?.status;

  await db.ordersDao.cancelOrder(orderId, reason);

  // إضافة لطابور المزامنة - إلغاء الطلب
  final now = DateTime.now();
  await db.syncQueueDao.enqueue(
    id: _uuid.v4(),
    tableName: 'orders',
    recordId: orderId,
    operation: 'UPDATE',
    payload:
        '{"id":"$orderId","status":"cancelled","cancellation_reason":"$reason","cancelled_at":"${now.toUtc().toIso8601String()}","updated_at":"${now.toUtc().toIso8601String()}"}',
    idempotencyKey: 'order_cancel_$orderId',
  );

  // إضافة سجل في تاريخ حالات الطلب
  final historyId = _uuid.v4();
  await db.customStatement(
    'INSERT INTO order_status_history (id, order_id, from_status, to_status, notes, created_at) VALUES (?, ?, ?, ?, ?, ?)',
    [
      historyId,
      orderId,
      oldStatus,
      'cancelled',
      reason,
      now.millisecondsSinceEpoch ~/ 1000,
    ],
  );
  await db.syncQueueDao.enqueue(
    id: _uuid.v4(),
    tableName: 'order_status_history',
    recordId: historyId,
    operation: 'CREATE',
    payload:
        '{"id":"$historyId","order_id":"$orderId","from_status":"${oldStatus ?? ''}","to_status":"cancelled","notes":"$reason","created_at":"${now.toUtc().toIso8601String()}"}',
    idempotencyKey: 'order_history_$historyId',
  );

  ref.invalidate(ordersListProvider);
  ref.invalidate(ordersStatsProvider);
  ref.invalidate(pendingOrdersProvider);
  ref.invalidate(pendingOrdersCountProvider);
  ref.invalidate(orderDetailProvider(orderId));
}
