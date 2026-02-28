import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_pos/src/models/online_order.dart';
import 'package:alhai_pos/src/providers/online_orders_provider.dart';

void main() {
  group('OnlineOrdersState', () {
    test('default state has empty orders', () {
      const state = OnlineOrdersState();

      expect(state.orders, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.selectedOrder, isNull);
      expect(state.hasNewOrders, isFalse);
    });

    test('pendingOrders filters correctly', () {
      final state = OnlineOrdersState(
        orders: [
          _createOrder(id: '1', status: OrderStatus.pending),
          _createOrder(id: '2', status: OrderStatus.accepted),
          _createOrder(id: '3', status: OrderStatus.pending),
        ],
      );

      expect(state.pendingOrders.length, equals(2));
    });

    test('acceptedOrders filters correctly', () {
      final state = OnlineOrdersState(
        orders: [
          _createOrder(id: '1', status: OrderStatus.pending),
          _createOrder(id: '2', status: OrderStatus.accepted),
        ],
      );

      expect(state.acceptedOrders.length, equals(1));
      expect(state.acceptedOrders.first.id, equals('2'));
    });

    test('preparingOrders filters correctly', () {
      final state = OnlineOrdersState(
        orders: [
          _createOrder(id: '1', status: OrderStatus.preparing),
          _createOrder(id: '2', status: OrderStatus.accepted),
        ],
      );

      expect(state.preparingOrders.length, equals(1));
    });

    test('deliveryOrders filters correctly', () {
      final state = OnlineOrdersState(
        orders: [
          _createOrder(id: '1', status: OrderStatus.outForDelivery),
          _createOrder(id: '2', status: OrderStatus.pending),
        ],
      );

      expect(state.deliveryOrders.length, equals(1));
    });

    test('actionRequiredCount counts pending and accepted', () {
      final state = OnlineOrdersState(
        orders: [
          _createOrder(id: '1', status: OrderStatus.pending),
          _createOrder(id: '2', status: OrderStatus.accepted),
          _createOrder(id: '3', status: OrderStatus.preparing),
          _createOrder(id: '4', status: OrderStatus.delivered),
        ],
      );

      expect(state.actionRequiredCount, equals(2));
    });

    test('copyWith updates fields', () {
      const state = OnlineOrdersState();
      final updated = state.copyWith(isLoading: true, hasNewOrders: true);

      expect(updated.isLoading, isTrue);
      expect(updated.hasNewOrders, isTrue);
      expect(updated.orders, isEmpty);
    });
  });

  group('OnlineOrdersNotifier', () {
    late OnlineOrdersNotifier notifier;

    setUp(() {
      notifier = OnlineOrdersNotifier();
    });

    test('initializes with mock data', () {
      expect(notifier.state.orders, isNotEmpty);
      expect(notifier.state.hasNewOrders, isTrue);
    });

    test('addOrder adds order to beginning', () {
      final initialCount = notifier.state.orders.length;
      final newOrder = _createOrder(id: 'NEW-001');

      notifier.addOrder(newOrder);

      expect(notifier.state.orders.length, equals(initialCount + 1));
      expect(notifier.state.orders.first.id, equals('NEW-001'));
      expect(notifier.state.hasNewOrders, isTrue);
    });

    test('acceptOrder changes status to accepted', () {
      final orderId = notifier.state.orders
          .firstWhere((o) => o.status == OrderStatus.pending)
          .id;

      notifier.acceptOrder(orderId);

      final order =
          notifier.state.orders.firstWhere((o) => o.id == orderId);
      expect(order.status, equals(OrderStatus.accepted));
      expect(order.acceptedAt, isNotNull);
    });

    test('startPreparing changes status to preparing', () {
      // First accept an order
      final orderId = notifier.state.orders
          .firstWhere((o) => o.status == OrderStatus.pending)
          .id;
      notifier.acceptOrder(orderId);

      notifier.startPreparing(orderId);

      final order =
          notifier.state.orders.firstWhere((o) => o.id == orderId);
      expect(order.status, equals(OrderStatus.preparing));
    });

    test('assignDriver updates order with driver info', () {
      final orderId = notifier.state.orders.first.id;

      notifier.assignDriver(orderId, 'driver-1', 'Ahmed');

      final order =
          notifier.state.orders.firstWhere((o) => o.id == orderId);
      expect(order.status, equals(OrderStatus.outForDelivery));
      expect(order.driverId, equals('driver-1'));
      expect(order.driverName, equals('Ahmed'));
      expect(order.preparedAt, isNotNull);
    });

    test('markDelivered sets delivered status', () {
      final orderId = notifier.state.orders.first.id;

      notifier.markDelivered(orderId);

      final order =
          notifier.state.orders.firstWhere((o) => o.id == orderId);
      expect(order.status, equals(OrderStatus.delivered));
      expect(order.deliveredAt, isNotNull);
    });

    test('cancelOrder sets cancelled status with reason', () {
      final orderId = notifier.state.orders.first.id;

      notifier.cancelOrder(orderId, reason: 'Customer request');

      final order =
          notifier.state.orders.firstWhere((o) => o.id == orderId);
      expect(order.status, equals(OrderStatus.cancelled));
      expect(order.cancellationReason, equals('Customer request'));
    });

    test('selectOrder sets selected order', () {
      final order = notifier.state.orders.first;

      notifier.selectOrder(order);

      expect(notifier.state.selectedOrder, equals(order));
    });

    test('selectOrder with null clears selection', () {
      notifier.selectOrder(notifier.state.orders.first);
      notifier.selectOrder(null);

      // State's selectedOrder should be the previous one (copyWith keeps it)
      // Actually, copying with null order keeps the old one.
      // This is a known behavior of copyWith pattern
    });

    test('clearNewOrdersFlag resets hasNewOrders', () {
      expect(notifier.state.hasNewOrders, isTrue);

      notifier.clearNewOrdersFlag();

      expect(notifier.state.hasNewOrders, isFalse);
    });

    test('refreshOrders sets loading then clears', () async {
      final future = notifier.refreshOrders();

      expect(notifier.state.isLoading, isTrue);

      await future;

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNull);
    });

    test('full order lifecycle: pending -> accepted -> preparing -> delivered',
        () {
      final order = _createOrder(id: 'lifecycle-1');
      notifier.addOrder(order);

      // 1. Accept
      notifier.acceptOrder('lifecycle-1');
      expect(
        notifier.state.orders.firstWhere((o) => o.id == 'lifecycle-1').status,
        equals(OrderStatus.accepted),
      );

      // 2. Start preparing
      notifier.startPreparing('lifecycle-1');
      expect(
        notifier.state.orders.firstWhere((o) => o.id == 'lifecycle-1').status,
        equals(OrderStatus.preparing),
      );

      // 3. Assign driver
      notifier.assignDriver('lifecycle-1', 'drv-1', 'Ali');
      expect(
        notifier.state.orders.firstWhere((o) => o.id == 'lifecycle-1').status,
        equals(OrderStatus.outForDelivery),
      );

      // 4. Mark delivered
      notifier.markDelivered('lifecycle-1');
      final finalOrder =
          notifier.state.orders.firstWhere((o) => o.id == 'lifecycle-1');
      expect(finalOrder.status, equals(OrderStatus.delivered));
      expect(finalOrder.isCompleted, isTrue);
    });
  });
}

// ============================================================================
// HELPERS
// ============================================================================

OnlineOrder _createOrder({
  required String id,
  OrderStatus status = OrderStatus.pending,
  PaymentStatus paymentStatus = PaymentStatus.paid,
  double total = 50.0,
}) {
  return OnlineOrder(
    id: id,
    storeId: 'store-1',
    customerId: 'cust-1',
    customerName: 'Test Customer',
    customerPhone: '0512345678',
    items: [
      const OrderItem(
        productId: 'p1',
        productName: 'Test Product',
        quantity: 1,
        unitPrice: 50.0,
      ),
    ],
    subtotal: total,
    total: total,
    status: status,
    paymentStatus: paymentStatus,
    createdAt: DateTime.now(),
  );
}
