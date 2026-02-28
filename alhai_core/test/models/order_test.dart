import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/order.dart';
import 'package:alhai_core/src/models/order_item.dart';
import 'package:alhai_core/src/models/enums/order_status.dart';
import 'package:alhai_core/src/models/enums/payment_method.dart';

void main() {
  group('Order Model', () {
    Order createOrder({
      String id = 'order-1',
      String? orderNumber,
      OrderStatus status = OrderStatus.created,
      List<OrderItem>? items,
      double subtotal = 100.0,
      double discount = 0,
      double deliveryFee = 0,
      double tax = 0,
      double total = 100.0,
      bool isPaid = false,
    }) {
      return Order(
        id: id,
        orderNumber: orderNumber,
        customerId: 'customer-1',
        storeId: 'store-1',
        status: status,
        items: items ??
            [
              const OrderItem(
                productId: 'p1',
                name: 'Product 1',
                unitPrice: 50.0,
                qty: 2,
                lineTotal: 100.0,
              ),
            ],
        subtotal: subtotal,
        discount: discount,
        deliveryFee: deliveryFee,
        tax: tax,
        total: total,
        paymentMethod: PaymentMethod.cash,
        isPaid: isPaid,
        createdAt: DateTime(2026, 1, 15),
      );
    }

    group('itemCount', () {
      test('should calculate total item count from all items', () {
        final order = createOrder(
          items: [
            const OrderItem(
              productId: 'p1',
              name: 'Product 1',
              unitPrice: 25.0,
              qty: 3,
              lineTotal: 75.0,
            ),
            const OrderItem(
              productId: 'p2',
              name: 'Product 2',
              unitPrice: 10.0,
              qty: 5,
              lineTotal: 50.0,
            ),
          ],
        );

        expect(order.itemCount, equals(8));
      });

      test('should return 0 for empty items', () {
        final order = createOrder(items: []);
        expect(order.itemCount, equals(0));
      });
    });

    group('canCancel', () {
      test('should be true for created status', () {
        final order = createOrder(status: OrderStatus.created);
        expect(order.canCancel, isTrue);
      });

      test('should be true for confirmed status', () {
        final order = createOrder(status: OrderStatus.confirmed);
        expect(order.canCancel, isTrue);
      });

      test('should be false for preparing status', () {
        final order = createOrder(status: OrderStatus.preparing);
        expect(order.canCancel, isFalse);
      });

      test('should be false for delivered status', () {
        final order = createOrder(status: OrderStatus.delivered);
        expect(order.canCancel, isFalse);
      });

      test('should be false for cancelled status', () {
        final order = createOrder(status: OrderStatus.cancelled);
        expect(order.canCancel, isFalse);
      });
    });

    group('isCompleted', () {
      test('should be true for delivered status', () {
        final order = createOrder(status: OrderStatus.delivered);
        expect(order.isCompleted, isTrue);
      });

      test('should be true for cancelled status', () {
        final order = createOrder(status: OrderStatus.cancelled);
        expect(order.isCompleted, isTrue);
      });

      test('should be false for created status', () {
        final order = createOrder(status: OrderStatus.created);
        expect(order.isCompleted, isFalse);
      });

      test('should be false for preparing status', () {
        final order = createOrder(status: OrderStatus.preparing);
        expect(order.isCompleted, isFalse);
      });
    });

    group('displayNumber', () {
      test('should return orderNumber when available', () {
        final order = createOrder(orderNumber: 'ORD-001');
        expect(order.displayNumber, equals('ORD-001'));
      });

      test('should generate display number from id when no orderNumber', () {
        final order = createOrder(
          id: 'abcdef12-3456-7890-abcd-ef1234567890',
          orderNumber: null,
        );
        expect(order.displayNumber, equals('#ABCDEF12'));
      });
    });

    group('serialization', () {
      test('should create Order from JSON', () {
        final json = {
          'id': 'order-1',
          'orderNumber': 'ORD-100',
          'customerId': 'cust-1',
          'storeId': 'store-1',
          'status': 'created',
          'items': [
            {
              'productId': 'p1',
              'name': 'Product 1',
              'unitPrice': 25.0,
              'qty': 2,
              'lineTotal': 50.0,
            },
          ],
          'subtotal': 50.0,
          'discount': 5.0,
          'deliveryFee': 10.0,
          'tax': 0.0,
          'total': 55.0,
          'paymentMethod': 'cash',
          'isPaid': true,
          'createdAt': '2026-01-15T00:00:00.000',
        };

        final order = Order.fromJson(json);

        expect(order.id, equals('order-1'));
        expect(order.orderNumber, equals('ORD-100'));
        expect(order.status, equals(OrderStatus.created));
        expect(order.items, hasLength(1));
        expect(order.subtotal, equals(50.0));
        expect(order.discount, equals(5.0));
        expect(order.deliveryFee, equals(10.0));
        expect(order.total, equals(55.0));
        expect(order.isPaid, isTrue);
      });

      test('should serialize to JSON and back', () {
        final order = createOrder(orderNumber: 'ORD-200');
        final jsonStr = jsonEncode(order.toJson());
        final restored = Order.fromJson(
          jsonDecode(jsonStr) as Map<String, dynamic>,
        );

        expect(restored.id, equals(order.id));
        expect(restored.orderNumber, equals(order.orderNumber));
        expect(restored.status, equals(order.status));
        expect(restored.total, equals(order.total));
      });
    });

    group('equality', () {
      test('should be equal for same data', () {
        final order1 = createOrder(id: 'same-id', orderNumber: 'ORD-1');
        final order2 = createOrder(id: 'same-id', orderNumber: 'ORD-1');
        expect(order1, equals(order2));
      });

      test('should not be equal for different ids', () {
        final order1 = createOrder(id: 'id-1');
        final order2 = createOrder(id: 'id-2');
        expect(order1, isNot(equals(order2)));
      });
    });
  });

  group('OrderStatus Extensions', () {
    test('displayNameAr should return Arabic names', () {
      expect(OrderStatus.created.displayNameAr, equals('جديد'));
      expect(OrderStatus.confirmed.displayNameAr, equals('مؤكد'));
      expect(OrderStatus.preparing.displayNameAr, equals('قيد التحضير'));
      expect(OrderStatus.delivered.displayNameAr, equals('تم التوصيل'));
      expect(OrderStatus.cancelled.displayNameAr, equals('ملغي'));
    });

    test('isFinal should be true for terminal statuses', () {
      expect(OrderStatus.completed.isFinal, isTrue);
      expect(OrderStatus.cancelled.isFinal, isTrue);
      expect(OrderStatus.refunded.isFinal, isTrue);
      expect(OrderStatus.delivered.isFinal, isTrue);
      expect(OrderStatus.pickedUp.isFinal, isTrue);
    });

    test('isFinal should be false for active statuses', () {
      expect(OrderStatus.created.isFinal, isFalse);
      expect(OrderStatus.confirmed.isFinal, isFalse);
      expect(OrderStatus.preparing.isFinal, isFalse);
    });

    test('canCancel should be true only for created and confirmed', () {
      expect(OrderStatus.created.canCancel, isTrue);
      expect(OrderStatus.confirmed.canCancel, isTrue);
      expect(OrderStatus.preparing.canCancel, isFalse);
      expect(OrderStatus.delivered.canCancel, isFalse);
    });
  });
}
