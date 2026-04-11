import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

// ---------------------------------------------------------------------------
// Minimal Fakes - only implement methods used by OrderService
// ---------------------------------------------------------------------------
class FakeOrdersRepository implements OrdersRepository {
  int createCallCount = 0;

  @override
  Future<Order> createOrder(CreateOrderParams params) async {
    createCallCount++;
    return Order(
      id: 'order-$createCallCount',
      orderNumber: 'POS-0001',
      customerId: 'cust-1',
      storeId: params.storeId,
      status: OrderStatus.completed,
      items: params.items,
      subtotal: 20.0,
      total: 20.0,
      paymentMethod: params.paymentMethod,
      isPaid: true,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<Order> getOrder(String id) async => throw UnimplementedError();

  @override
  Future<Paginated<Order>> getOrders({
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    return Paginated(items: [], total: 0, page: page, limit: limit);
  }

  @override
  Future<Order> updateStatus(String id, OrderStatus status) async =>
      throw UnimplementedError();

  @override
  Future<void> cancelOrder(String id, {String? reason}) async {}
}

class FakeOrderPaymentsRepository implements OrderPaymentsRepository {
  @override
  Future<OrderPayment> addPayment({
    required String orderId,
    required PaymentMethod method,
    required double amount,
    String? referenceNo,
  }) async {
    return OrderPayment(
      id: 'pay-1',
      orderId: orderId,
      method: method,
      amount: amount,
      referenceNo: referenceNo,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<OrderPayment>> getOrderPayments(String orderId) async => [];

  @override
  Future<double> getTotalPaid(String orderId) async => 50.0;

  @override
  Future<double> getRemainingBalance(String orderId, double orderTotal) async =>
      orderTotal - 50.0;

  @override
  Future<OrderPayment> getPayment(String id) async =>
      throw UnimplementedError();

  @override
  Future<List<OrderPayment>> getPaymentsByMethod(
    String storeId, {
    required DateTime startDate,
    required DateTime endDate,
    PaymentMethod? method,
  }) async => [];
}

void main() {
  late OrderService orderService;
  late FakeOrdersRepository fakeOrdersRepo;
  late FakeOrderPaymentsRepository fakePaymentsRepo;

  setUp(() {
    fakeOrdersRepo = FakeOrdersRepository();
    fakePaymentsRepo = FakeOrderPaymentsRepository();
    orderService = OrderService(fakeOrdersRepo, fakePaymentsRepo);
  });

  group('OrderService', () {
    test('should be created', () {
      expect(orderService, isNotNull);
    });

    group('cart operations', () {
      test('cart should start empty', () {
        expect(orderService.cartItems, isEmpty);
        expect(orderService.cartItemCount, equals(0));
        expect(orderService.cartTotal, equals(0.0));
      });

      test('addToCart should add new item', () {
        orderService.addToCart(
          productId: 'prod-1',
          name: 'Product A',
          unitPrice: 10.0,
          qty: 2,
        );
        expect(orderService.cartItemCount, equals(1));
        expect(orderService.cartTotal, equals(20.0));
      });

      test('addToCart should increase qty for existing product', () {
        orderService.addToCart(
          productId: 'prod-1',
          name: 'Product A',
          unitPrice: 10.0,
          qty: 2,
        );
        orderService.addToCart(
          productId: 'prod-1',
          name: 'Product A',
          unitPrice: 10.0,
          qty: 3,
        );
        expect(orderService.cartItemCount, equals(1));
        expect(orderService.cartTotal, equals(50.0));
      });

      test('addToCart should handle multiple products', () {
        orderService.addToCart(
          productId: 'prod-1',
          name: 'Product A',
          unitPrice: 10.0,
        );
        orderService.addToCart(
          productId: 'prod-2',
          name: 'Product B',
          unitPrice: 25.0,
          qty: 2,
        );
        expect(orderService.cartItemCount, equals(2));
        expect(orderService.cartTotal, equals(60.0));
      });

      test('updateCartItemQuantity should update quantity', () {
        orderService.addToCart(
          productId: 'prod-1',
          name: 'Product A',
          unitPrice: 10.0,
          qty: 2,
        );
        orderService.updateCartItemQuantity('prod-1', 5);
        expect(orderService.cartTotal, equals(50.0));
      });

      test('updateCartItemQuantity should remove when qty <= 0', () {
        orderService.addToCart(
          productId: 'prod-1',
          name: 'Product A',
          unitPrice: 10.0,
          qty: 2,
        );
        orderService.updateCartItemQuantity('prod-1', 0);
        expect(orderService.cartItemCount, equals(0));
      });

      test('removeFromCart should remove specific product', () {
        orderService.addToCart(productId: 'prod-1', name: 'A', unitPrice: 10.0);
        orderService.addToCart(productId: 'prod-2', name: 'B', unitPrice: 20.0);
        orderService.removeFromCart('prod-1');
        expect(orderService.cartItemCount, equals(1));
        expect(orderService.cartTotal, equals(20.0));
      });

      test('clearCart should empty the cart', () {
        orderService.addToCart(productId: 'prod-1', name: 'A', unitPrice: 10.0);
        orderService.clearCart();
        expect(orderService.cartItemCount, equals(0));
      });

      test('cartItems should return unmodifiable list', () {
        orderService.addToCart(productId: 'prod-1', name: 'A', unitPrice: 10.0);
        expect(
          () => orderService.cartItems.add({}),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    group('createOrder', () {
      test('should create order and clear cart', () async {
        orderService.addToCart(
          productId: 'prod-1',
          name: 'A',
          unitPrice: 10.0,
          qty: 2,
        );

        final order = await orderService.createOrder(
          CreateOrderParams(
            clientOrderId: 'client-1',
            storeId: 'store-1',
            items: [
              const OrderItem(
                productId: 'prod-1',
                name: 'A',
                unitPrice: 10.0,
                qty: 2,
                lineTotal: 20.0,
              ),
            ],
            paymentMethod: PaymentMethod.cash,
          ),
        );

        expect(order.id, isNotEmpty);
        expect(orderService.cartItemCount, equals(0));
      });
    });

    group('getOrderPayments', () {
      test('should delegate to payments repo', () async {
        final payments = await orderService.getOrderPayments('order-1');
        expect(payments, isA<List<OrderPayment>>());
      });
    });
  });
}
