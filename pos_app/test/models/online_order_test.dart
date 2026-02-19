import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/models/online_order.dart';

void main() {
  group('OnlineOrder Model Tests', () {
    test('إنشاء طلب بالقيم الافتراضية', () {
      final order = OnlineOrder(
        id: 'ORD-001',
        storeId: 'store1',
        customerId: 'cust1',
        customerName: 'أحمد محمد',
        customerPhone: '0512345678',
        items: const [
          OrderItem(
            productId: 'p1',
            productName: 'بيبسي',
            quantity: 2,
            unitPrice: 5,
          ),
        ],
        subtotal: 10,
        total: 15,
        paymentStatus: PaymentStatus.paid,
        createdAt: DateTime.now(),
      );

      expect(order.id, 'ORD-001');
      expect(order.status, OrderStatus.pending);
      expect(order.isPaid, isTrue);
      expect(order.isCancelled, isFalse);
    });

    test('itemCount يحسب عدد المنتجات بشكل صحيح', () {
      final order = OnlineOrder(
        id: 'ORD-002',
        storeId: 'store1',
        customerId: 'cust1',
        customerName: 'سارة',
        customerPhone: '0598765432',
        items: const [
          OrderItem(productId: 'p1', productName: 'منتج 1', quantity: 2, unitPrice: 5),
          OrderItem(productId: 'p2', productName: 'منتج 2', quantity: 3, unitPrice: 10),
        ],
        subtotal: 40,
        total: 45,
        paymentStatus: PaymentStatus.cashOnDelivery,
        createdAt: DateTime.now(),
      );

      expect(order.itemCount, 5); // 2 + 3
    });

    test('isNew يرجع true للطلبات الجديدة', () {
      final newOrder = OnlineOrder(
        id: 'ORD-003',
        storeId: 'store1',
        customerId: 'cust1',
        customerName: 'خالد',
        customerPhone: '0551234567',
        items: const [],
        subtotal: 0,
        total: 0,
        paymentStatus: PaymentStatus.paid,
        createdAt: DateTime.now(),
      );

      expect(newOrder.isNew, isTrue);
    });

    test('isNew يرجع false للطلبات القديمة', () {
      final oldOrder = OnlineOrder(
        id: 'ORD-004',
        storeId: 'store1',
        customerId: 'cust1',
        customerName: 'علي',
        customerPhone: '0559876543',
        items: const [],
        subtotal: 0,
        total: 0,
        paymentStatus: PaymentStatus.paid,
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      );

      expect(oldOrder.isNew, isFalse);
    });

    test('needsAction للطلبات المعلقة والمقبولة', () {
      final pendingOrder = OnlineOrder(
        id: 'ORD-005',
        storeId: 'store1',
        customerId: 'cust1',
        customerName: 'محمد',
        customerPhone: '0501234567',
        items: const [],
        subtotal: 0,
        total: 0,
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.paid,
        createdAt: DateTime.now(),
      );

      final acceptedOrder = pendingOrder.copyWith(status: OrderStatus.accepted);
      final deliveredOrder = pendingOrder.copyWith(status: OrderStatus.delivered);

      expect(pendingOrder.needsAction, isTrue);
      expect(acceptedOrder.needsAction, isTrue);
      expect(deliveredOrder.needsAction, isFalse);
    });

    test('copyWith ينشئ نسخة معدلة', () {
      final original = OnlineOrder(
        id: 'ORD-006',
        storeId: 'store1',
        customerId: 'cust1',
        customerName: 'فهد',
        customerPhone: '0503456789',
        items: const [],
        subtotal: 100,
        total: 105,
        paymentStatus: PaymentStatus.paid,
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(
        status: OrderStatus.delivered,
        driverId: 'driver1',
        driverName: 'السائق أحمد',
      );

      expect(updated.id, original.id);
      expect(updated.status, OrderStatus.delivered);
      expect(updated.driverName, 'السائق أحمد');
    });

    test('toJson و fromJson يعملان بشكل صحيح', () {
      final original = OnlineOrder(
        id: 'ORD-007',
        storeId: 'store1',
        customerId: 'cust1',
        customerName: 'عبدالله',
        customerPhone: '0507654321',
        items: const [
          OrderItem(productId: 'p1', productName: 'منتج', quantity: 1, unitPrice: 10),
        ],
        subtotal: 10,
        total: 15,
        paymentStatus: PaymentStatus.paid,
        createdAt: DateTime(2026, 2, 1, 12, 0, 0),
      );

      final json = original.toJson();
      final restored = OnlineOrder.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.customerName, original.customerName);
      expect(restored.items.length, original.items.length);
      expect(restored.total, original.total);
    });
  });

  group('OrderItem Tests', () {
    test('total يحسب إجمالي العنصر بشكل صحيح', () {
      const item = OrderItem(
        productId: 'p1',
        productName: 'بيبسي',
        quantity: 3,
        unitPrice: 5,
      );

      expect(item.total, 15); // 3 * 5
    });

    test('total يطبق الخصم', () {
      const item = OrderItem(
        productId: 'p2',
        productName: 'شيبس',
        quantity: 2,
        unitPrice: 10,
        discount: 5,
      );

      expect(item.total, 15); // (2 * 10) - 5
    });

    test('copyWith ينشئ نسخة معدلة', () {
      const original = OrderItem(
        productId: 'p1',
        productName: 'منتج',
        quantity: 1,
        unitPrice: 100,
      );

      final updated = original.copyWith(quantity: 5);

      expect(updated.productId, original.productId);
      expect(updated.quantity, 5);
    });
  });

  group('OrderStatus Extension Tests', () {
    test('arabicName يرجع الاسم بالعربي', () {
      expect(OrderStatus.pending.arabicName, 'بانتظار القبول');
      expect(OrderStatus.accepted.arabicName, 'تم القبول');
      expect(OrderStatus.preparing.arabicName, 'جاري التجهيز');
      expect(OrderStatus.outForDelivery.arabicName, 'في الطريق');
      expect(OrderStatus.delivered.arabicName, 'تم التسليم');
      expect(OrderStatus.cancelled.arabicName, 'ملغي');
    });

    test('icon يرجع الأيقونة المناسبة', () {
      expect(OrderStatus.pending.icon, '🟡');
      expect(OrderStatus.delivered.icon, '✅');
      expect(OrderStatus.cancelled.icon, '❌');
    });
  });

  group('PaymentStatus Extension Tests', () {
    test('arabicName يرجع الاسم بالعربي', () {
      expect(PaymentStatus.paid.arabicName, 'مدفوع');
      expect(PaymentStatus.cashOnDelivery.arabicName, 'الدفع عند الاستلام');
      expect(PaymentStatus.failed.arabicName, 'فشل الدفع');
    });

    test('icon يرجع الأيقونة المناسبة', () {
      expect(PaymentStatus.paid.icon, '✅');
      expect(PaymentStatus.cashOnDelivery.icon, '💵');
      expect(PaymentStatus.failed.icon, '❌');
    });
  });
}
