import 'package:alhai_core/alhai_core.dart';

/// خدمة إدارة الطلبات
/// متوافقة مع OrdersRepository من alhai_core
class OrderService {
  final OrdersRepository _ordersRepo;
  final OrderPaymentsRepository _paymentsRepo;

  // السلة المحلية - تخزين بسيط
  final List<Map<String, dynamic>> _cartItems = [];

  OrderService(this._ordersRepo, this._paymentsRepo);

  /// الحصول على السلة الحالية
  List<Map<String, dynamic>> get cartItems => List.unmodifiable(_cartItems);

  /// عدد العناصر في السلة
  int get cartItemCount => _cartItems.length;

  /// إجمالي السلة
  double get cartTotal => _cartItems.fold(
        0,
        (sum, item) =>
            sum + ((item['unitPrice'] as double) * (item['qty'] as int)),
      );

  /// إضافة منتج للسلة
  void addToCart({
    required String productId,
    required String name,
    required double unitPrice,
    int qty = 1,
  }) {
    final existingIndex =
        _cartItems.indexWhere((i) => i['productId'] == productId);
    if (existingIndex >= 0) {
      _cartItems[existingIndex]['qty'] =
          (_cartItems[existingIndex]['qty'] as int) + qty;
      _cartItems[existingIndex]['lineTotal'] =
          (_cartItems[existingIndex]['unitPrice'] as double) *
              (_cartItems[existingIndex]['qty'] as int);
    } else {
      _cartItems.add({
        'productId': productId,
        'name': name,
        'unitPrice': unitPrice,
        'qty': qty,
        'lineTotal': unitPrice * qty,
      });
    }
  }

  /// تحديث كمية منتج في السلة
  void updateCartItemQuantity(String productId, int qty) {
    final index = _cartItems.indexWhere((i) => i['productId'] == productId);
    if (index >= 0) {
      if (qty <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index]['qty'] = qty;
        _cartItems[index]['lineTotal'] =
            (_cartItems[index]['unitPrice'] as double) * qty;
      }
    }
  }

  /// إزالة منتج من السلة
  void removeFromCart(String productId) {
    _cartItems.removeWhere((i) => i['productId'] == productId);
  }

  /// مسح السلة
  void clearCart() {
    _cartItems.clear();
  }

  /// إنشاء طلب من السلة
  Future<Order> createOrder(CreateOrderParams params) async {
    final order = await _ordersRepo.createOrder(params);
    clearCart();
    return order;
  }

  /// الحصول على طلب بالـ ID
  Future<Order> getOrderById(String id) async {
    return await _ordersRepo.getOrder(id);
  }

  /// الحصول على قائمة الطلبات
  Future<Paginated<Order>> getOrders({
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    return await _ordersRepo.getOrders(
      status: status,
      page: page,
      limit: limit,
    );
  }

  /// تحديث حالة الطلب
  Future<Order> updateOrderStatus(String orderId, OrderStatus status) async {
    return await _ordersRepo.updateStatus(orderId, status);
  }

  /// إلغاء طلب
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    await _ordersRepo.cancelOrder(orderId, reason: reason);
  }

  /// الحصول على مدفوعات الطلب
  Future<List<OrderPayment>> getOrderPayments(String orderId) async {
    return await _paymentsRepo.getOrderPayments(orderId);
  }
}
