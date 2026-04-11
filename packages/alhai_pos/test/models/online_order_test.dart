import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_pos/src/models/online_order.dart';

void main() {
  group('OrderItem', () {
    test('total is unitPrice * quantity', () {
      const item = OrderItem(
        productId: 'p1',
        productName: 'Test',
        quantity: 3,
        unitPrice: 10.0,
      );

      expect(item.total, equals(30.0));
    });

    test('total subtracts discount', () {
      const item = OrderItem(
        productId: 'p1',
        productName: 'Test',
        quantity: 2,
        unitPrice: 50.0,
        discount: 10.0,
      );

      // 2 * 50 - 10 = 90
      expect(item.total, equals(90.0));
    });

    test('total with null discount uses 0', () {
      const item = OrderItem(
        productId: 'p1',
        productName: 'Test',
        quantity: 1,
        unitPrice: 25.0,
      );

      expect(item.total, equals(25.0));
    });

    test('copyWith updates fields', () {
      const item = OrderItem(
        productId: 'p1',
        productName: 'Test',
        quantity: 1,
        unitPrice: 10.0,
      );

      final updated = item.copyWith(quantity: 5, notes: 'Extra large');

      expect(updated.quantity, equals(5));
      expect(updated.notes, equals('Extra large'));
      expect(updated.productId, equals('p1'));
    });

    test('toJson and fromJson roundtrip', () {
      const item = OrderItem(
        productId: 'p1',
        productName: 'Test Product',
        quantity: 3,
        unitPrice: 15.5,
        discount: 2.0,
        notes: 'No sugar',
      );

      final json = item.toJson();
      final restored = OrderItem.fromJson(json);

      expect(restored.productId, equals('p1'));
      expect(restored.productName, equals('Test Product'));
      expect(restored.quantity, equals(3));
      expect(restored.unitPrice, equals(15.5));
      expect(restored.discount, equals(2.0));
      expect(restored.notes, equals('No sugar'));
    });

    test('fromJson handles null discount and notes', () {
      final json = {
        'productId': 'p1',
        'productName': 'Test',
        'quantity': 1,
        'unitPrice': 10.0,
        'discount': null,
        'notes': null,
      };

      final item = OrderItem.fromJson(json);

      expect(item.discount, isNull);
      expect(item.notes, isNull);
    });
  });

  group('OnlineOrder', () {
    late OnlineOrder order;

    setUp(() {
      order = OnlineOrder(
        id: 'ORD-001',
        storeId: 'store-1',
        customerId: 'cust-1',
        customerName: 'Ahmed',
        customerPhone: '0512345678',
        customerAddress: 'Riyadh',
        items: const [
          OrderItem(
            productId: 'p1',
            productName: 'A',
            quantity: 2,
            unitPrice: 10.0,
          ),
          OrderItem(
            productId: 'p2',
            productName: 'B',
            quantity: 3,
            unitPrice: 5.0,
          ),
        ],
        subtotal: 35.0,
        deliveryFee: 5.0,
        discount: 2.0,
        total: 38.0,
        paymentStatus: PaymentStatus.paid,
        createdAt: DateTime.now(),
      );
    });

    test('itemCount sums all quantities', () {
      expect(order.itemCount, equals(5)); // 2+3
    });

    test('isNew returns true for recent orders', () {
      final recentOrder = order.copyWith(
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      );
      expect(recentOrder.isNew, isTrue);
    });

    test('isNew returns false for old orders', () {
      final oldOrder = order.copyWith(
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      );
      expect(oldOrder.isNew, isFalse);
    });

    test('isPaid returns true for paid status', () {
      expect(order.isPaid, isTrue);
    });

    test('isPaid returns false for non-paid status', () {
      final codOrder = order.copyWith(
        paymentStatus: PaymentStatus.cashOnDelivery,
      );
      expect(codOrder.isPaid, isFalse);
    });

    test('isCancelled returns true for cancelled status', () {
      final cancelled = order.copyWith(status: OrderStatus.cancelled);
      expect(cancelled.isCancelled, isTrue);
    });

    test('isCancelled returns false for non-cancelled status', () {
      expect(order.isCancelled, isFalse);
    });

    test('isCompleted returns true for delivered status', () {
      final delivered = order.copyWith(status: OrderStatus.delivered);
      expect(delivered.isCompleted, isTrue);
    });

    test('needsAction returns true for pending and accepted', () {
      final pending = order.copyWith(status: OrderStatus.pending);
      final accepted = order.copyWith(status: OrderStatus.accepted);
      final preparing = order.copyWith(status: OrderStatus.preparing);

      expect(pending.needsAction, isTrue);
      expect(accepted.needsAction, isTrue);
      expect(preparing.needsAction, isFalse);
    });

    test('default status is pending', () {
      expect(order.status, equals(OrderStatus.pending));
    });

    test('default deliveryFee is 0', () {
      final minOrder = OnlineOrder(
        id: 'x',
        storeId: 's',
        customerId: 'c',
        customerName: 'n',
        customerPhone: 'p',
        items: const [],
        subtotal: 0,
        total: 0,
        paymentStatus: PaymentStatus.paid,
        createdAt: DateTime.now(),
      );
      expect(minOrder.deliveryFee, equals(0));
      expect(minOrder.discount, equals(0));
    });

    test('copyWith updates all fields', () {
      final updated = order.copyWith(
        customerName: 'Sara',
        status: OrderStatus.delivered,
        driverId: 'drv-1',
        driverName: 'Ali',
        deliveredAt: DateTime(2026, 1, 15),
        cancellationReason: null,
      );

      expect(updated.customerName, equals('Sara'));
      expect(updated.status, equals(OrderStatus.delivered));
      expect(updated.driverId, equals('drv-1'));
      expect(updated.driverName, equals('Ali'));
    });

    test('toJson and fromJson roundtrip', () {
      final json = order.toJson();
      final restored = OnlineOrder.fromJson(json);

      expect(restored.id, equals(order.id));
      expect(restored.storeId, equals(order.storeId));
      expect(restored.customerName, equals(order.customerName));
      expect(restored.items.length, equals(order.items.length));
      expect(restored.subtotal, equals(order.subtotal));
      expect(restored.deliveryFee, equals(order.deliveryFee));
      expect(restored.discount, equals(order.discount));
      expect(restored.total, equals(order.total));
      expect(restored.status, equals(order.status));
      expect(restored.paymentStatus, equals(order.paymentStatus));
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'ORD-1',
        'storeId': 'store-1',
        'customerId': 'cust-1',
        'customerName': 'Test',
        'customerPhone': '0500000000',
        'items': <Map<String, dynamic>>[],
        'subtotal': 0,
        'total': 0,
        'paymentStatus': 'paid',
        'createdAt': '2026-01-15T10:00:00.000',
      };

      final order = OnlineOrder.fromJson(json);

      expect(order.deliveryFee, equals(0));
      expect(order.discount, equals(0));
      expect(order.status, equals(OrderStatus.pending));
      expect(order.acceptedAt, isNull);
      expect(order.driverId, isNull);
    });
  });

  group('OrderStatus extension', () {
    test('all statuses have arabicName', () {
      for (final status in OrderStatus.values) {
        expect(status.arabicName, isNotEmpty);
      }
    });

    test('all statuses have icon', () {
      for (final status in OrderStatus.values) {
        expect(status.icon, isNotEmpty);
      }
    });
  });

  group('PaymentStatus extension', () {
    test('all statuses have arabicName', () {
      for (final status in PaymentStatus.values) {
        expect(status.arabicName, isNotEmpty);
      }
    });

    test('all statuses have icon', () {
      for (final status in PaymentStatus.values) {
        expect(status.icon, isNotEmpty);
      }
    });
  });
}
