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

  // ============================================================================
  // Pagination Methods - M61: تحسينات الأداء للقوائم الطويلة
  // ============================================================================

  /// جلب الطلبات مع Pagination
  /// [offset] - عدد العناصر للتخطي
  /// [limit] - الحد الأقصى للنتائج (افتراضي 50)
  Future<List<OrdersTableData>> getOrdersPaginated(
    String storeId, {
    int offset = 0,
    int limit = 50,
    String? status,
  }) {
    var query = select(ordersTable)
      ..where((o) {
        var condition = o.storeId.equals(storeId);
        if (status != null) {
          condition = condition & o.status.equals(status);
        }
        return condition;
      })
      ..orderBy([(o) => OrderingTerm.desc(o.orderDate)])
      ..limit(limit, offset: offset);

    return query.get();
  }

  /// عدد الطلبات الكلي (للـ pagination)
  Future<int> getOrdersCount(String storeId, {String? status}) async {
    final countExpression = ordersTable.id.count();

    var query = selectOnly(ordersTable)
      ..addColumns([countExpression])
      ..where(ordersTable.storeId.equals(storeId));

    if (status != null) {
      query.where(ordersTable.status.equals(status));
    }

    final result = await query.getSingle();
    return result.read(countExpression) ?? 0;
  }

  /// جلب الطلبات حسب الحالة
  Future<List<OrdersTableData>> getOrdersByStatus(String storeId, String status) {
    return (select(ordersTable)
          ..where((o) => o.storeId.equals(storeId) & o.status.equals(status))
          ..orderBy([(o) => OrderingTerm.desc(o.orderDate)]))
        .get();
  }

  /// جلب الطلبات المعلقة (created + confirmed + preparing + ready)
  Future<List<OrdersTableData>> getPendingOrders(String storeId) {
    return (select(ordersTable)
          ..where((o) =>
              o.storeId.equals(storeId) &
              o.status.isIn(['created', 'confirmed', 'preparing', 'ready', 'out_for_delivery']))
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
      case 'out_for_delivery':
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
          deliveringAt: status == 'out_for_delivery' ? Value(now) : const Value.absent(),
          deliveredAt: status == 'delivered' ? Value(now) : const Value.absent(),
          cancelledAt: status == 'cancelled' ? Value(now) : const Value.absent(),
        ));
  }

  /// تعيين سائق للطلب
  Future<int> assignDriver(String orderId, String driverId) {
    return (update(ordersTable)..where((o) => o.id.equals(orderId)))
        .write(OrdersTableCompanion(
          driverId: Value(driverId),
          status: const Value('out_for_delivery'),
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
           AND status IN ('created', 'confirmed', 'preparing', 'ready', 'out_for_delivery')''',
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

  // ============================================================================
  // H03: JOIN queries - استعلامات مع ربط الجداول
  // ============================================================================

  /// طلب كامل مع العناصر والمنتجات
  Future<OrderWithItems?> getOrderWithItems(String orderId) async {
    // جلب الطلب
    final order = await getOrderById(orderId);
    if (order == null) return null;

    // جلب العناصر مع أسماء المنتجات
    final itemsResult = await customSelect(
      '''SELECT oi.*, p.name as product_name, p.barcode as product_barcode,
              p.image_thumbnail as product_image
         FROM order_items oi
         LEFT JOIN products p ON oi.product_id = p.id
         WHERE oi.order_id = ?''',
      variables: [Variable.withString(orderId)],
    ).get();

    // M36: Local Drift DB uses 'quantity', 'unit_price', 'total' as column names.
    // These are the canonical names in the Drift schema (order_items_table.dart).
    // The Supabase schema uses 'qty', 'unit_price', 'total_price' but that
    // mapping is handled by the sync layer (sync_payload_utils.dart).
    final items = itemsResult.map((row) => OrderItemWithProduct(
      id: row.data['id'] as String,
      orderId: row.data['order_id'] as String,
      productId: row.data['product_id'] as String,
      productName: row.data['product_name'] as String? ?? '',
      productBarcode: row.data['product_barcode'] as String?,
      productImage: row.data['product_image'] as String?,
      qty: _toDouble(row.data['quantity']),
      price: _toDouble(row.data['unit_price']),
      total: _toDouble(row.data['total']),
    )).toList();

    return OrderWithItems(order: order, items: items);
  }

  /// طلبات مع اسم العميل
  Future<List<OrderWithCustomer>> getOrdersWithCustomer(
    String storeId, {
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    var whereClause = 'o.store_id = ?';
    final variables = <Variable>[Variable.withString(storeId)];

    if (status != null) {
      whereClause += ' AND o.status = ?';
      variables.add(Variable.withString(status));
    }

    final result = await customSelect(
      '''SELECT o.id, o.order_number, o.status, o.total, o.order_date,
              o.customer_id, o.delivery_type, o.payment_method,
              c.name as customer_name, c.phone as customer_phone
         FROM orders o
         LEFT JOIN customers c ON o.customer_id = c.id
         WHERE $whereClause
         ORDER BY o.order_date DESC
         LIMIT ? OFFSET ?''',
      variables: [...variables, Variable.withInt(limit), Variable.withInt(offset)],
    ).get();

    return result.map((row) => OrderWithCustomer(
      id: row.data['id'] as String,
      orderNumber: row.data['order_number'] as String,
      status: row.data['status'] as String,
      total: _toDouble(row.data['total']),
      orderDate: DateTime.tryParse(row.data['order_date'].toString()) ?? DateTime.now(),
      customerName: row.data['customer_name'] as String?,
      customerPhone: row.data['customer_phone'] as String?,
      deliveryType: row.data['delivery_type'] as String?,
      paymentMethod: row.data['payment_method'] as String?,
    )).toList();
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    return value as double;
  }
}

/// طلب مع عناصره
class OrderWithItems {
  final OrdersTableData order;
  final List<OrderItemWithProduct> items;

  const OrderWithItems({required this.order, required this.items});
}

/// عنصر طلب مع تفاصيل المنتج
class OrderItemWithProduct {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final String? productBarcode;
  final String? productImage;
  final double qty;
  final double price;
  final double total;

  const OrderItemWithProduct({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    this.productBarcode,
    this.productImage,
    required this.qty,
    required this.price,
    required this.total,
  });
}

/// طلب مع اسم العميل
class OrderWithCustomer {
  final String id;
  final String orderNumber;
  final String status;
  final double total;
  final DateTime orderDate;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryType;
  final String? paymentMethod;

  const OrderWithCustomer({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.total,
    required this.orderDate,
    this.customerName,
    this.customerPhone,
    this.deliveryType,
    this.paymentMethod,
  });
}
