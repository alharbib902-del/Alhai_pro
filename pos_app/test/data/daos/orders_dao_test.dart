import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:pos_app/data/local/app_database.dart';

// ===========================================
// Orders DAO Tests
// ===========================================

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('OrdersDao', () {
    const testStoreId = 'store_123';

    OrdersTableCompanion createOrder({
      required String id,
      required String orderNumber,
      String status = 'pending',
      String? customerId,
      double subtotal = 100,
      double taxAmount = 15,
      double total = 115,
      String deliveryType = 'delivery',
      DateTime? orderDate,
    }) {
      final now = orderDate ?? DateTime.now();
      return OrdersTableCompanion.insert(
        id: id,
        storeId: testStoreId,
        orderNumber: orderNumber,
        customerId: Value(customerId),
        status: Value(status),
        subtotal: Value(subtotal),
        taxAmount: Value(taxAmount),
        total: Value(total),
        deliveryType: Value(deliveryType),
        orderDate: now,
        createdAt: now,
        updatedAt: now,
      );
    }

    group('createOrder', () {
      test('يُنشئ طلب جديد بنجاح', () async {
        final order = createOrder(
          id: 'order_001',
          orderNumber: 'ORD-20260203-001',
          customerId: 'cust_001',
        );

        final result = await database.ordersDao.createOrder(order);
        expect(result, greaterThan(0));

        final fetched = await database.ordersDao.getOrderById('order_001');
        expect(fetched, isNotNull);
        expect(fetched!.orderNumber, 'ORD-20260203-001');
        expect(fetched.status, 'pending');
      });
    });

    group('getOrderById', () {
      test('يجد الطلب بالمعرف', () async {
        await database.ordersDao.createOrder(
          createOrder(id: 'order_001', orderNumber: 'ORD-001'),
        );

        final result = await database.ordersDao.getOrderById('order_001');
        expect(result, isNotNull);
        expect(result!.id, 'order_001');
      });

      test('يُرجع null إذا لم يُوجد الطلب', () async {
        final result = await database.ordersDao.getOrderById('non_existent');
        expect(result, isNull);
      });
    });

    group('getOrderByNumber', () {
      test('يجد الطلب برقمه', () async {
        await database.ordersDao.createOrder(
          createOrder(id: 'order_001', orderNumber: 'ORD-20260203-001'),
        );

        final result = await database.ordersDao.getOrderByNumber('ORD-20260203-001');
        expect(result, isNotNull);
        expect(result!.id, 'order_001');
      });
    });

    group('getOrders', () {
      test('يُرجع جميع طلبات المتجر', () async {
        await database.ordersDao.createOrder(
          createOrder(id: 'order_001', orderNumber: 'ORD-001'),
        );
        await database.ordersDao.createOrder(
          createOrder(id: 'order_002', orderNumber: 'ORD-002'),
        );
        await database.ordersDao.createOrder(
          createOrder(id: 'order_003', orderNumber: 'ORD-003'),
        );

        final result = await database.ordersDao.getOrders(testStoreId);
        expect(result.length, 3);
      });

      test('يُرتب الطلبات تنازلياً حسب التاريخ', () async {
        final now = DateTime.now();
        await database.ordersDao.createOrder(
          createOrder(
            id: 'order_old',
            orderNumber: 'ORD-OLD',
            orderDate: now.subtract(const Duration(days: 2)),
          ),
        );
        await database.ordersDao.createOrder(
          createOrder(
            id: 'order_new',
            orderNumber: 'ORD-NEW',
            orderDate: now,
          ),
        );

        final result = await database.ordersDao.getOrders(testStoreId);
        expect(result[0].id, 'order_new'); // الأحدث أولاً
      });
    });

    group('getOrdersByStatus', () {
      test('يُرجع الطلبات حسب الحالة', () async {
        await database.ordersDao.createOrder(
          createOrder(id: 'order_001', orderNumber: 'ORD-001', status: 'pending'),
        );
        await database.ordersDao.createOrder(
          createOrder(id: 'order_002', orderNumber: 'ORD-002', status: 'confirmed'),
        );
        await database.ordersDao.createOrder(
          createOrder(id: 'order_003', orderNumber: 'ORD-003', status: 'pending'),
        );

        final pendingOrders = await database.ordersDao.getOrdersByStatus(
          testStoreId,
          'pending',
        );
        expect(pendingOrders.length, 2);
        expect(pendingOrders.every((o) => o.status == 'pending'), isTrue);
      });
    });

    group('getPendingOrders', () {
      test('يُرجع الطلبات المعلقة فقط', () async {
        await database.ordersDao.createOrder(
          createOrder(id: 'order_001', orderNumber: 'ORD-001', status: 'pending'),
        );
        await database.ordersDao.createOrder(
          createOrder(id: 'order_002', orderNumber: 'ORD-002', status: 'confirmed'),
        );
        await database.ordersDao.createOrder(
          createOrder(id: 'order_003', orderNumber: 'ORD-003', status: 'delivered'),
        );
        await database.ordersDao.createOrder(
          createOrder(id: 'order_004', orderNumber: 'ORD-004', status: 'preparing'),
        );

        final result = await database.ordersDao.getPendingOrders(testStoreId);
        // pending, confirmed, preparing (not delivered)
        expect(result.length, 3);
      });
    });

    group('updateOrderStatus', () {
      test('يُحدّث حالة الطلب', () async {
        await database.ordersDao.createOrder(
          createOrder(id: 'order_001', orderNumber: 'ORD-001', status: 'pending'),
        );

        await database.ordersDao.updateOrderStatus('order_001', 'confirmed');

        final result = await database.ordersDao.getOrderById('order_001');
        expect(result!.status, 'confirmed');
        expect(result.confirmedAt, isNotNull);
      });

      test('يُحدّث التاريخ المناسب لكل حالة', () async {
        await database.ordersDao.createOrder(
          createOrder(id: 'order_001', orderNumber: 'ORD-001'),
        );

        await database.ordersDao.updateOrderStatus('order_001', 'preparing');
        var order = await database.ordersDao.getOrderById('order_001');
        expect(order!.preparingAt, isNotNull);

        await database.ordersDao.updateOrderStatus('order_001', 'ready');
        order = await database.ordersDao.getOrderById('order_001');
        expect(order!.readyAt, isNotNull);

        await database.ordersDao.updateOrderStatus('order_001', 'delivered');
        order = await database.ordersDao.getOrderById('order_001');
        expect(order!.deliveredAt, isNotNull);
      });
    });

    group('assignDriver', () {
      test('يُعيّن سائق للطلب', () async {
        await database.ordersDao.createOrder(
          createOrder(id: 'order_001', orderNumber: 'ORD-001', status: 'ready'),
        );

        await database.ordersDao.assignDriver('order_001', 'driver_001');

        final result = await database.ordersDao.getOrderById('order_001');
        expect(result!.driverId, 'driver_001');
        expect(result.status, 'delivering');
        expect(result.deliveringAt, isNotNull);
      });
    });

    group('cancelOrder', () {
      test('يُلغي الطلب مع السبب', () async {
        await database.ordersDao.createOrder(
          createOrder(id: 'order_001', orderNumber: 'ORD-001'),
        );

        await database.ordersDao.cancelOrder('order_001', 'العميل ألغى الطلب');

        final result = await database.ordersDao.getOrderById('order_001');
        expect(result!.status, 'cancelled');
        expect(result.cancelReason, 'العميل ألغى الطلب');
        expect(result.cancelledAt, isNotNull);
      });
    });

    group('getOrdersCountByStatus', () {
      test('يُرجع عدد الطلبات لكل حالة', () async {
        await database.ordersDao.createOrder(
          createOrder(id: 'order_001', orderNumber: 'ORD-001', status: 'pending'),
        );
        await database.ordersDao.createOrder(
          createOrder(id: 'order_002', orderNumber: 'ORD-002', status: 'pending'),
        );
        await database.ordersDao.createOrder(
          createOrder(id: 'order_003', orderNumber: 'ORD-003', status: 'delivered'),
        );

        final counts = await database.ordersDao.getOrdersCountByStatus(testStoreId);
        expect(counts['pending'], 2);
        expect(counts['delivered'], 1);
      });
    });

    group('getPendingOrdersCount', () {
      test('يُرجع عدد الطلبات المعلقة', () async {
        await database.ordersDao.createOrder(
          createOrder(id: 'order_001', orderNumber: 'ORD-001', status: 'pending'),
        );
        await database.ordersDao.createOrder(
          createOrder(id: 'order_002', orderNumber: 'ORD-002', status: 'confirmed'),
        );
        await database.ordersDao.createOrder(
          createOrder(id: 'order_003', orderNumber: 'ORD-003', status: 'delivered'),
        );

        final count = await database.ordersDao.getPendingOrdersCount(testStoreId);
        expect(count, 2); // pending و confirmed فقط
      });
    });
  });
}
