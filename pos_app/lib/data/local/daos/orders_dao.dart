import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/orders_table.dart';
import '../tables/order_items_table.dart';

part 'orders_dao.g.dart';

/// DAO لإدارة الطلبات
@DriftAccessor(tables: [OrdersTable, OrderItemsTable])
class OrdersDao extends DatabaseAccessor<AppDatabase> with _$OrdersDaoMixin {
  OrdersDao(super.db);

  // ==================== الطلبات ====================
  
  /// جلب جميع الطلبات لمتجر معين
  Future<List<OrdersTableData>> getOrders(String storeId) {
    return (select(ordersTable)
          ..where((o) => o.storeId.equals(storeId))
          ..orderBy([(o) => OrderingTerm.desc(o.orderDate)]))
        .get();
  }

  /// جلب الطلبات حسب الحالة
  Future<List<OrdersTableData>> getOrdersByStatus(String storeId, String status) {
    return (select(ordersTable)
          ..where((o) => o.storeId.equals(storeId) & o.status.equals(status))
          ..orderBy([(o) => OrderingTerm.desc(o.orderDate)]))
        .get();
  }

  /// جلب الطلبات المعلقة (pending + confirmed + preparing + ready)
  Future<List<OrdersTableData>> getPendingOrders(String storeId) {
    return (select(ordersTable)
          ..where((o) =>
              o.storeId.equals(storeId) &
              o.status.isIn(['pending', 'confirmed', 'preparing', 'ready', 'delivering']))
          ..orderBy([(o) => OrderingTerm.asc(o.orderDate)]))
        .get();
  }

  /// جلب طلب بمعرفه
  Future<OrdersTableData?> getOrderById(String id) {
    return (select(ordersTable)..where((o) => o.id.equals(id)))
        .getSingleOrNull();
  }

  /// جلب طلب برقمه
  Future<OrdersTableData?> getOrderByNumber(String orderNumber) {
    return (select(ordersTable)
          ..where((o) => o.orderNumber.equals(orderNumber)))
        .getSingleOrNull();
  }

  /// إنشاء طلب جديد
  Future<int> createOrder(OrdersTableCompanion order) {
    return into(ordersTable).insert(order);
  }

  /// تحديث حالة الطلب
  Future<int> updateOrderStatus(String id, String status) {
    final now = DateTime.now();
    Map<String, dynamic> statusUpdate = {
      'status': status,
      'updatedAt': now,
    };
    
    // تحديث التاريخ المناسب للحالة
    switch (status) {
      case 'confirmed':
        statusUpdate['confirmedAt'] = now;
        break;
      case 'preparing':
        statusUpdate['preparingAt'] = now;
        break;
      case 'ready':
        statusUpdate['readyAt'] = now;
        break;
      case 'delivering':
        statusUpdate['deliveringAt'] = now;
        break;
      case 'delivered':
        statusUpdate['deliveredAt'] = now;
        break;
      case 'cancelled':
        statusUpdate['cancelledAt'] = now;
        break;
    }
    
    return (update(ordersTable)..where((o) => o.id.equals(id)))
        .write(OrdersTableCompanion(
          status: Value(status),
          updatedAt: Value(now),
          confirmedAt: status == 'confirmed' ? Value(now) : const Value.absent(),
          preparingAt: status == 'preparing' ? Value(now) : const Value.absent(),
          readyAt: status == 'ready' ? Value(now) : const Value.absent(),
          deliveringAt: status == 'delivering' ? Value(now) : const Value.absent(),
          deliveredAt: status == 'delivered' ? Value(now) : const Value.absent(),
          cancelledAt: status == 'cancelled' ? Value(now) : const Value.absent(),
        ));
  }

  /// تعيين سائق للطلب
  Future<int> assignDriver(String orderId, String driverId) {
    return (update(ordersTable)..where((o) => o.id.equals(orderId)))
        .write(OrdersTableCompanion(
          driverId: Value(driverId),
          status: const Value('delivering'),
          deliveringAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// إلغاء الطلب
  Future<int> cancelOrder(String id, String reason) {
    return (update(ordersTable)..where((o) => o.id.equals(id)))
        .write(OrdersTableCompanion(
          status: const Value('cancelled'),
          cancelReason: Value(reason),
          cancelledAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ));
  }

  // ==================== عناصر الطلب ====================
  
  /// جلب عناصر طلب
  Future<List<OrderItemsTableData>> getOrderItems(String orderId) {
    return (select(orderItemsTable)
          ..where((i) => i.orderId.equals(orderId)))
        .get();
  }

  /// إضافة عنصر للطلب
  Future<int> addOrderItem(OrderItemsTableCompanion item) {
    return into(orderItemsTable).insert(item);
  }

  /// إضافة عناصر متعددة للطلب
  Future<void> addOrderItems(List<OrderItemsTableCompanion> items) {
    return batch((b) => b.insertAll(orderItemsTable, items));
  }

  /// حجز المخزون لعناصر الطلب
  Future<void> reserveOrderItems(String orderId) {
    return (update(orderItemsTable)..where((i) => i.orderId.equals(orderId)))
        .write(const OrderItemsTableCompanion(isReserved: Value(true)));
  }

  /// إلغاء حجز المخزون
  Future<void> unreserveOrderItems(String orderId) {
    return (update(orderItemsTable)..where((i) => i.orderId.equals(orderId)))
        .write(const OrderItemsTableCompanion(isReserved: Value(false)));
  }

  // ==================== الإحصائيات ====================

  /// عدد الطلبات حسب الحالة - محسّن باستخدام GROUP BY
  /// تم إصلاح مشكلة N+1 Query
  Future<Map<String, int>> getOrdersCountByStatus(String storeId) async {
    final result = await customSelect(
      '''SELECT status, COUNT(*) as count
         FROM orders
         WHERE store_id = ?
         GROUP BY status''',
      variables: [Variable.withString(storeId)],
      readsFrom: {ordersTable},
    ).get();

    final counts = <String, int>{};
    for (final row in result) {
      final status = row.read<String>('status');
      final count = row.read<int>('count');
      counts[status] = count;
    }
    return counts;
  }

  /// إجمالي مبيعات اليوم من الطلبات - محسّن باستخدام SUM
  Future<double> getTodayOrdersTotal(String storeId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final result = await customSelect(
      '''SELECT COALESCE(SUM(total), 0) as total_sum
         FROM orders
         WHERE store_id = ?
           AND status = 'delivered'
           AND order_date >= ?''',
      variables: [
        Variable.withString(storeId),
        Variable.withDateTime(startOfDay),
      ],
      readsFrom: {ordersTable},
    ).getSingle();

    return result.read<double>('total_sum');
  }

  /// عدد الطلبات المعلقة - محسّن باستخدام COUNT
  Future<int> getPendingOrdersCount(String storeId) async {
    final result = await customSelect(
      '''SELECT COUNT(*) as count
         FROM orders
         WHERE store_id = ?
           AND status IN ('pending', 'confirmed', 'preparing', 'ready', 'delivering')''',
      variables: [Variable.withString(storeId)],
      readsFrom: {ordersTable},
    ).getSingle();

    return result.read<int>('count');
  }

  /// إجمالي الطلبات لفترة معينة
  Future<Map<String, dynamic>> getOrdersStats(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    final result = await customSelect(
      '''SELECT
           COUNT(*) as total_orders,
           COALESCE(SUM(total), 0) as total_revenue,
           COALESCE(AVG(total), 0) as avg_order_value,
           COUNT(CASE WHEN status = 'delivered' THEN 1 END) as delivered_count,
           COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled_count
         FROM orders
         WHERE store_id = ?
           AND order_date >= ?
           AND order_date <= ?''',
      variables: [
        Variable.withString(storeId),
        Variable.withDateTime(start),
        Variable.withDateTime(end),
      ],
      readsFrom: {ordersTable},
    ).getSingle();

    return {
      'totalOrders': result.read<int>('total_orders'),
      'totalRevenue': result.read<double>('total_revenue'),
      'avgOrderValue': result.read<double>('avg_order_value'),
      'deliveredCount': result.read<int>('delivered_count'),
      'cancelledCount': result.read<int>('cancelled_count'),
    };
  }
}
