import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/online_order.dart';

/// حالة الطلبات الأونلاين
class OnlineOrdersState {
  final List<OnlineOrder> orders;
  final bool isLoading;
  final String? error;
  final OnlineOrder? selectedOrder;
  final bool hasNewOrders;

  const OnlineOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.selectedOrder,
    this.hasNewOrders = false,
  });

  /// الطلبات المعلقة
  List<OnlineOrder> get pendingOrders => 
    orders.where((o) => o.status == OrderStatus.pending).toList();

  /// الطلبات المقبولة
  List<OnlineOrder> get acceptedOrders => 
    orders.where((o) => o.status == OrderStatus.accepted).toList();

  /// الطلبات قيد التجهيز
  List<OnlineOrder> get preparingOrders => 
    orders.where((o) => o.status == OrderStatus.preparing).toList();

  /// الطلبات في التوصيل
  List<OnlineOrder> get deliveryOrders => 
    orders.where((o) => o.status == OrderStatus.outForDelivery).toList();

  /// الطلبات المكتملة اليوم
  List<OnlineOrder> get completedToday {
    final today = DateTime.now();
    return orders.where((o) => 
      o.status == OrderStatus.delivered &&
      o.deliveredAt != null &&
      o.deliveredAt!.day == today.day &&
      o.deliveredAt!.month == today.month &&
      o.deliveredAt!.year == today.year
    ).toList();
  }

  /// عدد الطلبات التي تحتاج إجراء
  int get actionRequiredCount => 
    orders.where((o) => o.needsAction).length;

  /// إجمالي المبيعات اليوم
  double get todayTotal => completedToday.fold(0, (sum, o) => sum + o.total);

  OnlineOrdersState copyWith({
    List<OnlineOrder>? orders,
    bool? isLoading,
    String? error,
    OnlineOrder? selectedOrder,
    bool? hasNewOrders,
  }) {
    return OnlineOrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      hasNewOrders: hasNewOrders ?? this.hasNewOrders,
    );
  }
}

/// مدير الطلبات الأونلاين
class OnlineOrdersNotifier extends StateNotifier<OnlineOrdersState> {
  OnlineOrdersNotifier() : super(const OnlineOrdersState()) {
    // تحميل بيانات تجريبية للاختبار
    _loadMockData();
  }

  /// تحميل بيانات تجريبية
  void _loadMockData() {
    final mockOrders = [
      OnlineOrder(
        id: 'ORD-001',
        storeId: 'store1',
        customerId: 'cust1',
        customerName: 'أحمد محمد',
        customerPhone: '0512345678',
        customerAddress: 'شارع الملك فهد، جدة',
        items: [
          const OrderItem(productId: 'p1', productName: 'بيبسي كبير', quantity: 2, unitPrice: 5),
          const OrderItem(productId: 'p2', productName: 'شيبس ليز', quantity: 1, unitPrice: 3),
        ],
        subtotal: 13,
        deliveryFee: 5,
        total: 18,
        paymentStatus: PaymentStatus.paid,
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      OnlineOrder(
        id: 'ORD-002',
        storeId: 'store1',
        customerId: 'cust2',
        customerName: 'سارة علي',
        customerPhone: '0598765432',
        customerAddress: 'حي النزهة، الرياض',
        items: [
          const OrderItem(productId: 'p3', productName: 'ماء معدني', quantity: 6, unitPrice: 1),
          const OrderItem(productId: 'p4', productName: 'عصير برتقال', quantity: 2, unitPrice: 4),
        ],
        subtotal: 14,
        deliveryFee: 5,
        total: 19,
        paymentStatus: PaymentStatus.cashOnDelivery,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      OnlineOrder(
        id: 'ORD-003',
        storeId: 'store1',
        customerId: 'cust3',
        customerName: 'خالد عبدالله',
        customerPhone: '0551234567',
        customerAddress: 'حي الروضة، جدة',
        items: [
          const OrderItem(productId: 'p5', productName: 'حليب طازج', quantity: 2, unitPrice: 8),
          const OrderItem(productId: 'p6', productName: 'خبز', quantity: 3, unitPrice: 2),
          const OrderItem(productId: 'p7', productName: 'بيض', quantity: 1, unitPrice: 15),
        ],
        subtotal: 37,
        deliveryFee: 5,
        total: 42,
        status: OrderStatus.accepted,
        paymentStatus: PaymentStatus.paid,
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        acceptedAt: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
    ];

    state = state.copyWith(orders: mockOrders, hasNewOrders: true);
  }

  /// إضافة طلب جديد (من WebSocket)
  void addOrder(OnlineOrder order) {
    state = state.copyWith(
      orders: [order, ...state.orders],
      hasNewOrders: true,
    );
  }

  /// قبول الطلب
  void acceptOrder(String orderId) {
    final updatedOrders = state.orders.map((order) {
      if (order.id == orderId) {
        return order.copyWith(
          status: OrderStatus.accepted,
          acceptedAt: DateTime.now(),
        );
      }
      return order;
    }).toList();

    state = state.copyWith(orders: updatedOrders);
  }

  /// بدء التجهيز
  void startPreparing(String orderId) {
    final updatedOrders = state.orders.map((order) {
      if (order.id == orderId) {
        return order.copyWith(
          status: OrderStatus.preparing,
        );
      }
      return order;
    }).toList();

    state = state.copyWith(orders: updatedOrders);
  }

  /// تسليم للسائق
  void assignDriver(String orderId, String driverId, String driverName) {
    final updatedOrders = state.orders.map((order) {
      if (order.id == orderId) {
        return order.copyWith(
          status: OrderStatus.outForDelivery,
          driverId: driverId,
          driverName: driverName,
          preparedAt: DateTime.now(),
        );
      }
      return order;
    }).toList();

    state = state.copyWith(orders: updatedOrders);
  }

  /// إتمام التسليم
  void markDelivered(String orderId) {
    final updatedOrders = state.orders.map((order) {
      if (order.id == orderId) {
        return order.copyWith(
          status: OrderStatus.delivered,
          deliveredAt: DateTime.now(),
        );
      }
      return order;
    }).toList();

    state = state.copyWith(orders: updatedOrders);
  }

  /// إلغاء الطلب
  void cancelOrder(String orderId, {String? reason}) {
    final updatedOrders = state.orders.map((order) {
      if (order.id == orderId) {
        return order.copyWith(
          status: OrderStatus.cancelled,
          cancellationReason: reason,
        );
      }
      return order;
    }).toList();

    state = state.copyWith(orders: updatedOrders);
  }

  /// تحديد طلب
  void selectOrder(OnlineOrder? order) {
    state = state.copyWith(selectedOrder: order);
  }

  /// مسح علامة الطلبات الجديدة
  void clearNewOrdersFlag() {
    state = state.copyWith(hasNewOrders: false);
  }

  /// تحديث الطلبات من الخادم
  Future<void> refreshOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: استدعاء API حقيقي
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// مزود الطلبات الأونلاين
final onlineOrdersProvider = StateNotifierProvider<OnlineOrdersNotifier, OnlineOrdersState>(
  (ref) => OnlineOrdersNotifier(),
);

/// الطلبات المعلقة
final pendingOrdersProvider = Provider<List<OnlineOrder>>((ref) {
  return ref.watch(onlineOrdersProvider).pendingOrders;
});

/// عدد الطلبات التي تحتاج إجراء
final actionRequiredCountProvider = Provider<int>((ref) {
  return ref.watch(onlineOrdersProvider).actionRequiredCount;
});

/// هل يوجد طلبات جديدة
final hasNewOrdersProvider = Provider<bool>((ref) {
  return ref.watch(onlineOrdersProvider).hasNewOrders;
});

/// الطلب المحدد
final selectedOrderProvider = Provider<OnlineOrder?>((ref) {
  return ref.watch(onlineOrdersProvider).selectedOrder;
});
