import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/wholesale_order.dart';

void main() {
  group('WholesaleOrder Model', () {
    WholesaleOrder createOrder({
      String id = 'wo-1',
      WholesaleOrderStatus status = WholesaleOrderStatus.pending,
      List<WholesaleOrderItem>? items,
      double subtotal = 1000.0,
      double total = 1000.0,
    }) {
      return WholesaleOrder(
        id: id,
        orderNumber: 'WO-001',
        distributorId: 'dist-1',
        storeId: 'store-1',
        storeName: 'Test Store',
        status: status,
        paymentMethod: WholesalePaymentMethod.bankTransfer,
        items:
            items ??
            [
              const WholesaleOrderItem(
                productId: 'p1',
                productName: 'Product 1',
                quantity: 10,
                unitPrice: 50.0,
                totalPrice: 500.0,
              ),
              const WholesaleOrderItem(
                productId: 'p2',
                productName: 'Product 2',
                quantity: 5,
                unitPrice: 100.0,
                totalPrice: 500.0,
              ),
            ],
        subtotal: subtotal,
        total: total,
        createdAt: DateTime(2026, 1, 15),
      );
    }

    group('totalItems', () {
      test('should calculate total items from all order items', () {
        final order = createOrder();
        expect(order.totalItems, equals(15)); // 10 + 5
      });

      test('should return 0 for empty items', () {
        final order = createOrder(items: []);
        expect(order.totalItems, equals(0));
      });
    });

    group('canCancel', () {
      test('should be true for pending', () {
        final order = createOrder(status: WholesaleOrderStatus.pending);
        expect(order.canCancel, isTrue);
      });

      test('should be true for confirmed', () {
        final order = createOrder(status: WholesaleOrderStatus.confirmed);
        expect(order.canCancel, isTrue);
      });

      test('should be false for processing', () {
        final order = createOrder(status: WholesaleOrderStatus.processing);
        expect(order.canCancel, isFalse);
      });

      test('should be false for shipped', () {
        final order = createOrder(status: WholesaleOrderStatus.shipped);
        expect(order.canCancel, isFalse);
      });

      test('should be false for delivered', () {
        final order = createOrder(status: WholesaleOrderStatus.delivered);
        expect(order.canCancel, isFalse);
      });

      test('should be false for cancelled', () {
        final order = createOrder(status: WholesaleOrderStatus.cancelled);
        expect(order.canCancel, isFalse);
      });
    });

    group('isCompleted', () {
      test('should be true only for delivered', () {
        final order = createOrder(status: WholesaleOrderStatus.delivered);
        expect(order.isCompleted, isTrue);
      });

      test('should be false for other statuses', () {
        for (final status in WholesaleOrderStatus.values) {
          if (status != WholesaleOrderStatus.delivered) {
            final order = createOrder(status: status);
            expect(order.isCompleted, isFalse, reason: 'Status: $status');
          }
        }
      });
    });

    group('serialization', () {
      test('should create WholesaleOrder from JSON', () {
        final json = {
          'id': 'wo-1',
          'orderNumber': 'WO-100',
          'distributorId': 'dist-1',
          'storeId': 'store-1',
          'storeName': 'Store A',
          'status': 'PENDING',
          'paymentMethod': 'BANK_TRANSFER',
          'items': [
            {
              'productId': 'p1',
              'productName': 'Product 1',
              'quantity': 10,
              'unitPrice': 50.0,
              'totalPrice': 500.0,
            },
          ],
          'subtotal': 500.0,
          'discount': 0.0,
          'tax': 75.0,
          'total': 575.0,
          'createdAt': '2026-01-15T00:00:00.000',
        };

        final order = WholesaleOrder.fromJson(json);

        expect(order.id, equals('wo-1'));
        expect(order.orderNumber, equals('WO-100'));
        expect(order.status, equals(WholesaleOrderStatus.pending));
        expect(
          order.paymentMethod,
          equals(WholesalePaymentMethod.bankTransfer),
        );
        expect(order.items, hasLength(1));
        expect(order.total, equals(575.0));
      });

      test('should serialize to JSON and back', () {
        final order = createOrder();
        final jsonStr = jsonEncode(order.toJson());
        final restored = WholesaleOrder.fromJson(
          jsonDecode(jsonStr) as Map<String, dynamic>,
        );

        expect(restored.id, equals(order.id));
        expect(restored.status, equals(order.status));
        expect(restored.totalItems, equals(order.totalItems));
      });
    });
  });

  group('WholesaleOrderStatus Extensions', () {
    test('displayNameAr should return Arabic names', () {
      expect(
        WholesaleOrderStatus.pending.displayNameAr,
        equals('قيد الانتظار'),
      );
      expect(WholesaleOrderStatus.confirmed.displayNameAr, equals('مؤكد'));
      expect(
        WholesaleOrderStatus.processing.displayNameAr,
        equals('قيد التجهيز'),
      );
      expect(WholesaleOrderStatus.shipped.displayNameAr, equals('في الطريق'));
      expect(
        WholesaleOrderStatus.delivered.displayNameAr,
        equals('تم التوصيل'),
      );
      expect(WholesaleOrderStatus.cancelled.displayNameAr, equals('ملغي'));
    });

    test('isActive should be true for non-terminal statuses', () {
      expect(WholesaleOrderStatus.pending.isActive, isTrue);
      expect(WholesaleOrderStatus.confirmed.isActive, isTrue);
      expect(WholesaleOrderStatus.processing.isActive, isTrue);
      expect(WholesaleOrderStatus.shipped.isActive, isTrue);
      expect(WholesaleOrderStatus.delivered.isActive, isFalse);
      expect(WholesaleOrderStatus.cancelled.isActive, isFalse);
    });
  });

  group('WholesalePaymentMethod Extensions', () {
    test('displayNameAr should return Arabic names', () {
      expect(WholesalePaymentMethod.cash.displayNameAr, equals('نقداً'));
      expect(
        WholesalePaymentMethod.bankTransfer.displayNameAr,
        equals('تحويل بنكي'),
      );
      expect(WholesalePaymentMethod.credit.displayNameAr, equals('آجل'));
      expect(WholesalePaymentMethod.check.displayNameAr, equals('شيك'));
      expect(WholesalePaymentMethod.app.displayNameAr, equals('تطبيق'));
    });
  });
}
