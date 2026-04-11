import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

void main() {
  late ReceiptService receiptService;

  setUp(() {
    receiptService = ReceiptService();
  });

  // =====================================================
  // Helper to create a test order
  // =====================================================

  Order createTestOrder({
    String id = 'order-123',
    String? orderNumber,
    List<OrderItem>? items,
    double subtotal = 100.0,
    double discount = 0.0,
    double tax = 15.0,
    double total = 115.0,
    PaymentMethod paymentMethod = PaymentMethod.cash,
  }) {
    return Order(
      id: id,
      orderNumber: orderNumber,
      customerId: 'cust-1',
      storeId: 'store-1',
      status: OrderStatus.completed,
      items:
          items ??
          [
            const OrderItem(
              productId: 'prod-1',
              name: 'Test Product',
              unitPrice: 50.0,
              qty: 2,
              lineTotal: 100.0,
            ),
          ],
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      paymentMethod: paymentMethod,
      isPaid: true,
      createdAt: DateTime(2026, 3, 15, 14, 30),
    );
  }

  Store createTestStore({
    String name = 'Al-HAI Store',
    String address = 'Riyadh, Saudi Arabia',
    String? phone = '0500000000',
  }) {
    return Store(
      id: 'store-1',
      name: name,
      address: address,
      phone: phone,
      lat: 24.7136,
      lng: 46.6753,
      isActive: true,
      ownerId: 'owner-1',
      createdAt: DateTime(2026, 1, 1),
    );
  }

  group('ReceiptService', () {
    group('generateReceiptText', () {
      test('should include store name in header', () {
        // Arrange
        final order = createTestOrder();
        final store = createTestStore(name: 'My Test Store');

        // Act
        final receipt = receiptService.generateReceiptText(
          order: order,
          store: store,
        );

        // Assert
        expect(receipt, contains('My Test Store'));
      });

      test('should include store address and phone', () {
        final order = createTestOrder();
        final store = createTestStore(
          address: 'شارع العليا، الرياض',
          phone: '0551234567',
        );

        final receipt = receiptService.generateReceiptText(
          order: order,
          store: store,
        );

        expect(receipt, contains('شارع العليا، الرياض'));
        expect(receipt, contains('0551234567'));
      });

      test('should include order number', () {
        final order = createTestOrder(orderNumber: 'POS-20260315-0001');
        final store = createTestStore();

        final receipt = receiptService.generateReceiptText(
          order: order,
          store: store,
        );

        expect(receipt, contains('POS-20260315-0001'));
      });

      test('should include date and time', () {
        final order = createTestOrder();
        final store = createTestStore();

        final receipt = receiptService.generateReceiptText(
          order: order,
          store: store,
        );

        expect(receipt, contains('2026/03/15'));
        expect(receipt, contains('14:30'));
      });

      test('should include item details', () {
        final order = createTestOrder(
          items: [
            const OrderItem(
              productId: 'prod-1',
              name: 'كابتشينو',
              unitPrice: 18.0,
              qty: 3,
              lineTotal: 54.0,
            ),
          ],
        );
        final store = createTestStore();

        final receipt = receiptService.generateReceiptText(
          order: order,
          store: store,
        );

        expect(receipt, contains('كابتشينو'));
        expect(receipt, contains('3'));
        expect(receipt, contains('18.00'));
        expect(receipt, contains('54.00'));
      });

      test('should show subtotal, tax, and total', () {
        final order = createTestOrder(subtotal: 200.0, tax: 30.0, total: 230.0);
        final store = createTestStore();

        final receipt = receiptService.generateReceiptText(
          order: order,
          store: store,
        );

        expect(receipt, contains('200.00'));
        expect(receipt, contains('30.00'));
        expect(receipt, contains('230.00'));
      });

      test('should show discount when present', () {
        final order = createTestOrder(
          subtotal: 200.0,
          discount: 20.0,
          tax: 27.0,
          total: 207.0,
        );
        final store = createTestStore();

        final receipt = receiptService.generateReceiptText(
          order: order,
          store: store,
        );

        expect(receipt, contains('الخصم'));
        expect(receipt, contains('20.00'));
      });

      test('should not show discount when zero', () {
        final order = createTestOrder(discount: 0.0);
        final store = createTestStore();

        final receipt = receiptService.generateReceiptText(
          order: order,
          store: store,
        );

        expect(receipt, isNot(contains('الخصم')));
      });

      test('should show cashier name when provided', () {
        final order = createTestOrder();
        final store = createTestStore();

        final receipt = receiptService.generateReceiptText(
          order: order,
          store: store,
          cashierName: 'أحمد',
        );

        expect(receipt, contains('أحمد'));
        expect(receipt, contains('الكاشير'));
      });

      test('should show payment method in Arabic', () {
        final order = createTestOrder(paymentMethod: PaymentMethod.cash);
        final store = createTestStore();

        final receipt = receiptService.generateReceiptText(
          order: order,
          store: store,
        );

        expect(receipt, contains('نقدي'));
      });

      test('should show card payment method', () {
        final order = createTestOrder(paymentMethod: PaymentMethod.card);
        final store = createTestStore();

        final receipt = receiptService.generateReceiptText(
          order: order,
          store: store,
        );

        expect(receipt, contains('بطاقة'));
      });

      test('should include custom receipt header when set', () {
        final order = createTestOrder();
        final store = createTestStore();
        const settings = StoreSettings(
          id: 'settings-1',
          storeId: 'store-1',
          receiptHeader: 'مرحباً بكم في متجرنا',
        );

        final receipt = receiptService.generateReceiptText(
          order: order,
          store: store,
          settings: settings,
        );

        expect(receipt, contains('مرحباً بكم في متجرنا'));
      });

      test('should include custom receipt footer when set', () {
        final order = createTestOrder();
        final store = createTestStore();
        const settings = StoreSettings(
          id: 'settings-1',
          storeId: 'store-1',
          receiptFooter: 'شكراً لتسوقكم معنا!',
        );

        final receipt = receiptService.generateReceiptText(
          order: order,
          store: store,
          settings: settings,
        );

        expect(receipt, contains('شكراً لتسوقكم معنا!'));
      });

      test('should show default footer when no settings', () {
        final order = createTestOrder();
        final store = createTestStore();

        final receipt = receiptService.generateReceiptText(
          order: order,
          store: store,
        );

        expect(receipt, contains('شكراً لزيارتكم'));
      });

      test('should handle multiple items', () {
        final order = createTestOrder(
          items: [
            const OrderItem(
              productId: 'prod-1',
              name: 'Item A',
              unitPrice: 10.0,
              qty: 2,
              lineTotal: 20.0,
            ),
            const OrderItem(
              productId: 'prod-2',
              name: 'Item B',
              unitPrice: 30.0,
              qty: 1,
              lineTotal: 30.0,
            ),
            const OrderItem(
              productId: 'prod-3',
              name: 'Item C',
              unitPrice: 5.0,
              qty: 4,
              lineTotal: 20.0,
            ),
          ],
          subtotal: 70.0,
          tax: 10.5,
          total: 80.5,
        );
        final store = createTestStore();

        final receipt = receiptService.generateReceiptText(
          order: order,
          store: store,
        );

        expect(receipt, contains('Item A'));
        expect(receipt, contains('Item B'));
        expect(receipt, contains('Item C'));
      });
    });

    group('generateReceiptHtml', () {
      test('should generate valid HTML structure', () {
        final order = createTestOrder();
        final store = createTestStore();

        final html = receiptService.generateReceiptHtml(
          order: order,
          store: store,
        );

        expect(html, contains('<!DOCTYPE html>'));
        expect(html, contains('<html'));
        expect(html, contains('</html>'));
        expect(html, contains('dir="rtl"'));
        expect(html, contains('lang="ar"'));
      });

      test('should escape HTML special characters in store name', () {
        final order = createTestOrder();
        final store = createTestStore(name: '<script>alert("xss")</script>');

        final html = receiptService.generateReceiptHtml(
          order: order,
          store: store,
        );

        expect(html, isNot(contains('<script>')));
        expect(html, contains('&lt;script&gt;'));
      });

      test('should escape HTML special characters in item names', () {
        final order = createTestOrder(
          items: [
            const OrderItem(
              productId: 'prod-1',
              name: 'Product <b>Bold</b> & "Special"',
              unitPrice: 10.0,
              qty: 1,
              lineTotal: 10.0,
            ),
          ],
        );
        final store = createTestStore();

        final html = receiptService.generateReceiptHtml(
          order: order,
          store: store,
        );

        expect(html, isNot(contains('<b>Bold</b>')));
        expect(html, contains('&lt;b&gt;'));
        expect(html, contains('&amp;'));
        expect(html, contains('&quot;'));
      });

      test('should include store info in HTML', () {
        final order = createTestOrder();
        final store = createTestStore(name: 'متجر الهاي', address: 'الرياض');

        final html = receiptService.generateReceiptHtml(
          order: order,
          store: store,
        );

        expect(html, contains('متجر الهاي'));
        expect(html, contains('الرياض'));
      });

      test('should include totals in HTML', () {
        final order = createTestOrder(
          subtotal: 100.0,
          discount: 10.0,
          tax: 13.5,
          total: 103.5,
        );
        final store = createTestStore();

        final html = receiptService.generateReceiptHtml(
          order: order,
          store: store,
        );

        expect(html, contains('100.00'));
        expect(html, contains('10.00'));
        expect(html, contains('13.50'));
        expect(html, contains('103.50'));
      });

      test('should include CSS styles', () {
        final order = createTestOrder();
        final store = createTestStore();

        final html = receiptService.generateReceiptHtml(
          order: order,
          store: store,
        );

        expect(html, contains('<style>'));
        expect(html, contains('80mm')); // receipt width
      });

      test('should show custom footer in HTML', () {
        final order = createTestOrder();
        final store = createTestStore();
        const settings = StoreSettings(
          id: 's1',
          storeId: 'store-1',
          receiptFooter: 'Thanks for shopping!',
        );

        final html = receiptService.generateReceiptHtml(
          order: order,
          store: store,
          settings: settings,
        );

        expect(html, contains('Thanks for shopping!'));
      });
    });
  });
}
