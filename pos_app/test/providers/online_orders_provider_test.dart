import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/models/online_order.dart';
import 'package:pos_app/providers/online_orders_provider.dart';

void main() {
  group('OnlineOrdersNotifier Tests', () {
    late OnlineOrdersNotifier notifier;

    setUp(() {
      notifier = OnlineOrdersNotifier();
    });

    test('يبدأ بـ mock data', () {
      expect(notifier.state.orders.isNotEmpty, isTrue);
      expect(notifier.state.hasNewOrders, isTrue);
    });

    test('acceptOrder يغير حالة الطلب', () {
      final orderId = notifier.state.orders.first.id;
      
      notifier.acceptOrder(orderId);
      
      final order = notifier.state.orders.firstWhere((o) => o.id == orderId);
      expect(order.status, OrderStatus.accepted);
      expect(order.acceptedAt, isNotNull);
    });

    test('startPreparing يغير الحالة للتجهيز', () {
      final orderId = notifier.state.orders.first.id;
      
      notifier.acceptOrder(orderId);
      notifier.startPreparing(orderId);
      
      final order = notifier.state.orders.firstWhere((o) => o.id == orderId);
      expect(order.status, OrderStatus.preparing);
    });

    test('assignDriver يضيف السائق ويغير الحالة', () {
      final orderId = notifier.state.orders.first.id;
      
      notifier.acceptOrder(orderId);
      notifier.assignDriver(orderId, 'driver1', 'علي السائق');
      
      final order = notifier.state.orders.firstWhere((o) => o.id == orderId);
      expect(order.status, OrderStatus.outForDelivery);
      expect(order.driverId, 'driver1');
      expect(order.driverName, 'علي السائق');
    });

    test('markDelivered يكمل الطلب', () {
      final orderId = notifier.state.orders.first.id;
      
      notifier.acceptOrder(orderId);
      notifier.assignDriver(orderId, 'driver1', 'السائق');
      notifier.markDelivered(orderId);
      
      final order = notifier.state.orders.firstWhere((o) => o.id == orderId);
      expect(order.status, OrderStatus.delivered);
      expect(order.deliveredAt, isNotNull);
    });

    test('cancelOrder يلغي الطلب مع السبب', () {
      final orderId = notifier.state.orders.first.id;
      
      notifier.cancelOrder(orderId, reason: 'منتج غير متوفر');
      
      final order = notifier.state.orders.firstWhere((o) => o.id == orderId);
      expect(order.status, OrderStatus.cancelled);
      expect(order.cancellationReason, 'منتج غير متوفر');
    });

    test('addOrder يضيف طلب جديد', () {
      final initialCount = notifier.state.orders.length;
      
      final newOrder = OnlineOrder(
        id: 'ORD-NEW',
        storeId: 'store1',
        customerId: 'cust-new',
        customerName: 'عميل جديد',
        customerPhone: '0501112223',
        items: const [],
        subtotal: 50,
        total: 55,
        paymentStatus: PaymentStatus.paid,
        createdAt: DateTime.now(),
      );
      
      notifier.addOrder(newOrder);
      
      expect(notifier.state.orders.length, initialCount + 1);
      expect(notifier.state.orders.first.id, 'ORD-NEW');
    });

    test('selectOrder يحدد الطلب', () {
      final order = notifier.state.orders.first;
      
      notifier.selectOrder(order);
      
      expect(notifier.state.selectedOrder, order);
    });

    test('clearNewOrdersFlag يمسح علامة الطلبات الجديدة', () {
      expect(notifier.state.hasNewOrders, isTrue);
      
      notifier.clearNewOrdersFlag();
      
      expect(notifier.state.hasNewOrders, isFalse);
    });
  });

  group('OnlineOrdersState Tests', () {
    test('pendingOrders يرجع الطلبات المعلقة فقط', () {
      final notifier = OnlineOrdersNotifier();
      
      // قبول طلب واحد
      notifier.acceptOrder(notifier.state.orders.first.id);
      
      final pendingCount = notifier.state.pendingOrders.length;
      final totalCount = notifier.state.orders.length;
      
      expect(pendingCount, lessThan(totalCount));
    });

    test('actionRequiredCount يحسب الطلبات التي تحتاج إجراء', () {
      final notifier = OnlineOrdersNotifier();
      
      final count = notifier.state.actionRequiredCount;
      
      expect(count, greaterThan(0));
    });
  });
}
