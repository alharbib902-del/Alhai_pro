import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await seedTestData(db);
    // order_items reference products via FK
    final now = DateTime(2025, 1, 1);
    for (var i = 1; i <= 2; i++) {
      await db.productsDao.insertProduct(ProductsTableCompanion.insert(
        id: 'prod-$i',
        storeId: 'store-1',
        name: 'P$i',
        price: 10.0,
        createdAt: now,
      ));
    }
  });

  tearDown(() async {
    await db.close();
  });

  OrdersTableCompanion makeOrder({
    String id = 'order-1',
    String storeId = 'store-1',
    String orderNumber = 'ORD-20250615-001',
    String status = 'created',
    double total = 150.0,
    DateTime? orderDate,
  }) {
    final now = orderDate ?? DateTime(2025, 6, 15, 12, 0);
    return OrdersTableCompanion.insert(
      id: id,
      storeId: storeId,
      orderNumber: orderNumber,
      status: Value(status),
      total: Value(total),
      orderDate: now,
      createdAt: now,
      updatedAt: Value(now),
    );
  }

  OrderItemsTableCompanion makeOrderItem({
    String id = 'oi-1',
    String orderId = 'order-1',
    String productId = 'prod-1',
    String productName = 'بيتزا مارغريتا',
    double quantity = 2.0,
    double unitPrice = 30.0,
    double total = 60.0,
  }) {
    return OrderItemsTableCompanion.insert(
      id: id,
      orderId: orderId,
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      total: total,
    );
  }

  group('OrdersDao', () {
    test('createOrder and getOrderById', () async {
      await db.ordersDao.createOrder(makeOrder());

      final order = await db.ordersDao.getOrderById('order-1');
      expect(order, isNotNull);
      expect(order!.orderNumber, 'ORD-20250615-001');
      expect(order.status, 'created');
      expect(order.total, 150.0);
    });

    test('getOrderById returns null for non-existent', () async {
      final order = await db.ordersDao.getOrderById('non-existent');
      expect(order, isNull);
    });

    test('getOrderByNumber finds order', () async {
      await db.ordersDao.createOrder(makeOrder());

      final order = await db.ordersDao.getOrderByNumber('ORD-20250615-001');
      expect(order, isNotNull);
      expect(order!.id, 'order-1');
    });

    test('getOrders returns all orders for store', () async {
      await db.ordersDao.createOrder(makeOrder());
      await db.ordersDao.createOrder(makeOrder(
        id: 'order-2',
        orderNumber: 'ORD-20250615-002',
      ));

      final orders = await db.ordersDao.getOrders('store-1');
      expect(orders, hasLength(2));
    });

    test('getOrdersByStatus filters correctly', () async {
      await db.ordersDao.createOrder(makeOrder(id: 'o1', status: 'created'));
      await db.ordersDao.createOrder(makeOrder(
        id: 'o2',
        orderNumber: 'ORD-002',
        status: 'delivered',
      ));

      final pending =
          await db.ordersDao.getOrdersByStatus('store-1', 'created');
      expect(pending, hasLength(1));
      expect(pending.first.id, 'o1');
    });

    test('getPendingOrders returns all non-completed orders', () async {
      await db.ordersDao.createOrder(
          makeOrder(id: 'o1', orderNumber: 'ORD-1', status: 'created'));
      await db.ordersDao.createOrder(
          makeOrder(id: 'o2', orderNumber: 'ORD-2', status: 'confirmed'));
      await db.ordersDao.createOrder(
          makeOrder(id: 'o3', orderNumber: 'ORD-3', status: 'delivered'));
      await db.ordersDao.createOrder(
          makeOrder(id: 'o4', orderNumber: 'ORD-4', status: 'cancelled'));

      final pending = await db.ordersDao.getPendingOrders('store-1');
      expect(pending, hasLength(2)); // pending + confirmed
    });

    test('updateOrderStatus changes status', () async {
      await db.ordersDao.createOrder(makeOrder());

      await db.ordersDao.updateOrderStatus('order-1', 'confirmed');

      final order = await db.ordersDao.getOrderById('order-1');
      expect(order!.status, 'confirmed');
      expect(order.confirmedAt, isNotNull);
    });

    test('cancelOrder sets status and reason', () async {
      await db.ordersDao.createOrder(makeOrder());

      await db.ordersDao.cancelOrder('order-1', 'العميل ألغى الطلب');

      final order = await db.ordersDao.getOrderById('order-1');
      expect(order!.status, 'cancelled');
      expect(order.cancelReason, 'العميل ألغى الطلب');
      expect(order.cancelledAt, isNotNull);
    });

    test('assignDriver updates driver and status', () async {
      await db.ordersDao.createOrder(makeOrder());

      await db.ordersDao.assignDriver('order-1', 'driver-1');

      final order = await db.ordersDao.getOrderById('order-1');
      expect(order!.driverId, 'driver-1');
      expect(order.status, 'out_for_delivery');
    });

    // Order Items
    test('addOrderItem and getOrderItems', () async {
      await db.ordersDao.createOrder(makeOrder());
      await db.ordersDao.addOrderItem(makeOrderItem());
      await db.ordersDao.addOrderItem(makeOrderItem(
        id: 'oi-2',
        productName: 'كولا',
        productId: 'prod-2',
      ));

      final items = await db.ordersDao.getOrderItems('order-1');
      expect(items, hasLength(2));
    });

    test('addOrderItems batch inserts', () async {
      await db.ordersDao.createOrder(makeOrder());
      await db.ordersDao.addOrderItems([
        makeOrderItem(id: 'oi-1'),
        makeOrderItem(id: 'oi-2', productId: 'prod-2'),
      ]);

      final items = await db.ordersDao.getOrderItems('order-1');
      expect(items, hasLength(2));
    });

    test('reserveOrderItems marks items as reserved', () async {
      await db.ordersDao.createOrder(makeOrder());
      await db.ordersDao.addOrderItem(makeOrderItem());

      await db.ordersDao.reserveOrderItems('order-1');

      final items = await db.ordersDao.getOrderItems('order-1');
      expect(items.first.isReserved, true);
    });

    test('unreserveOrderItems removes reservation', () async {
      await db.ordersDao.createOrder(makeOrder());
      await db.ordersDao.addOrderItem(makeOrderItem());
      await db.ordersDao.reserveOrderItems('order-1');
      await db.ordersDao.unreserveOrderItems('order-1');

      final items = await db.ordersDao.getOrderItems('order-1');
      expect(items.first.isReserved, false);
    });
  });
}
