import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_database/alhai_database.dart' hide OrderStatus, PaymentStatus;
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import '../models/online_order.dart';

const _uuid = Uuid();

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
  final String? _storeId;
  final AppDatabase _db;

  OnlineOrdersNotifier(this._storeId)
      : _db = GetIt.I<AppDatabase>(),
        super(const OnlineOrdersState()) {
    _loadOrders();
  }

  /// تحميل الطلبات من قاعدة البيانات
  Future<void> _loadOrders() async {
    if (_storeId == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dbOrders = await _db.ordersDao.getPendingOrders(_storeId);
      final onlineOrders = await _mapDbOrdersToOnlineOrders(dbOrders);
      state = state.copyWith(
        orders: onlineOrders,
        isLoading: false,
        hasNewOrders: onlineOrders.isNotEmpty,
      );
    } catch (e) {
      debugPrint('[OnlineOrders] Error loading orders: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// تحويل بيانات الطلبات من قاعدة البيانات إلى نموذج OnlineOrder
  Future<List<OnlineOrder>> _mapDbOrdersToOnlineOrders(
      List<OrdersTableData> dbOrders) async {
    final result = <OnlineOrder>[];
    for (final dbOrder in dbOrders) {
      final dbItems = await _db.ordersDao.getOrderItems(dbOrder.id);
      final customer = dbOrder.customerId != null
          ? await _db.customersDao.getCustomerById(dbOrder.customerId!)
          : null;

      result.add(OnlineOrder(
        id: dbOrder.id,
        storeId: dbOrder.storeId,
        customerId: dbOrder.customerId ?? '',
        customerName: customer?.name ?? '',
        customerPhone: customer?.phone ?? '',
        customerAddress: dbOrder.deliveryAddress,
        items: dbItems
            .map((item) => OrderItem(
                  productId: item.productId,
                  productName: item.productName,
                  quantity: item.quantity.toInt(),
                  unitPrice: item.unitPrice,
                  discount: item.discount,
                  notes: item.notes,
                ))
            .toList(),
        subtotal: dbOrder.subtotal,
        deliveryFee: dbOrder.deliveryFee,
        discount: dbOrder.discount,
        total: dbOrder.total,
        status: _mapDbStatus(dbOrder.status),
        paymentStatus: _mapDbPaymentStatus(dbOrder.paymentStatus),
        createdAt: dbOrder.orderDate,
        acceptedAt: dbOrder.confirmedAt,
        preparedAt: dbOrder.readyAt,
        deliveredAt: dbOrder.deliveredAt,
        driverId: dbOrder.driverId,
        notes: dbOrder.notes,
        cancellationReason: dbOrder.cancelReason,
      ));
    }
    return result;
  }

  /// تحويل حالة الطلب من النص إلى enum
  OrderStatus _mapDbStatus(String status) {
    switch (status) {
      case 'created':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.accepted;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
      case 'picked_up':
      case 'completed':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'refunded':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  /// تحويل حالة الدفع من النص إلى enum
  PaymentStatus _mapDbPaymentStatus(String paymentStatus) {
    switch (paymentStatus) {
      case 'paid':
        return PaymentStatus.paid;
      case 'pending':
        return PaymentStatus.cashOnDelivery;
      case 'refunded':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.cashOnDelivery;
    }
  }

  /// إضافة طلب جديد (من WebSocket)
  void addOrder(OnlineOrder order) {
    state = state.copyWith(
      orders: [order, ...state.orders],
      hasNewOrders: true,
    );
  }

  /// قبول الطلب
  Future<void> acceptOrder(String orderId) async {
    _updateLocalStatus(orderId, OrderStatus.accepted);
    await _updateOrderStatusInDb(orderId, 'confirmed');
  }

  /// بدء التجهيز
  Future<void> startPreparing(String orderId) async {
    _updateLocalStatus(orderId, OrderStatus.preparing);
    await _updateOrderStatusInDb(orderId, 'preparing');
  }

  /// تسليم للسائق
  Future<void> assignDriver(String orderId, String driverId, String driverName) async {
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

    // تحديث قاعدة البيانات وطابور المزامنة
    await _db.ordersDao.assignDriver(orderId, driverId);
    await _enqueueSyncUpdate(orderId, 'out_for_delivery',
        extra: {'driver_id': driverId});
  }

  /// إتمام التسليم
  Future<void> markDelivered(String orderId) async {
    _updateLocalStatus(orderId, OrderStatus.delivered);
    await _updateOrderStatusInDb(orderId, 'delivered');
  }

  /// إلغاء الطلب
  Future<void> cancelOrder(String orderId, {String? reason}) async {
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

    await _db.ordersDao.cancelOrder(orderId, reason ?? '');
    await _enqueueSyncUpdate(orderId, 'cancelled',
        extra: {'cancel_reason': reason ?? ''});
  }

  /// تحديد طلب
  void selectOrder(OnlineOrder? order) {
    state = state.copyWith(selectedOrder: order);
  }

  /// مسح علامة الطلبات الجديدة
  void clearNewOrdersFlag() {
    state = state.copyWith(hasNewOrders: false);
  }

  /// تحديث الطلبات من قاعدة البيانات
  Future<void> refreshOrders() async {
    await _loadOrders();
  }

  // =========================================================================
  // PRIVATE HELPERS
  // =========================================================================

  /// تحديث الحالة محلياً في الذاكرة
  void _updateLocalStatus(String orderId, OrderStatus newStatus) {
    final updatedOrders = state.orders.map((order) {
      if (order.id == orderId) {
        return order.copyWith(
          status: newStatus,
          acceptedAt: newStatus == OrderStatus.accepted ? DateTime.now() : null,
          preparedAt: newStatus == OrderStatus.outForDelivery ? DateTime.now() : null,
          deliveredAt: newStatus == OrderStatus.delivered ? DateTime.now() : null,
        );
      }
      return order;
    }).toList();
    state = state.copyWith(orders: updatedOrders);
  }

  /// تحديث حالة الطلب في قاعدة البيانات وإضافة للمزامنة
  Future<void> _updateOrderStatusInDb(String orderId, String dbStatus) async {
    try {
      await _db.ordersDao.updateOrderStatus(orderId, dbStatus);
      await _enqueueSyncUpdate(orderId, dbStatus);
    } catch (e) {
      debugPrint('[OnlineOrders] Error updating order status: $e');
    }
  }

  /// إضافة تحديث للطابور المزامنة
  Future<void> _enqueueSyncUpdate(String orderId, String status,
      {Map<String, dynamic>? extra}) async {
    try {
      final payload = <String, dynamic>{
        'id': orderId,
        'status': status,
      };
      if (extra != null) payload.addAll(extra);

      await _db.syncQueueDao.enqueue(
        id: _uuid.v4(),
        tableName: 'orders',
        recordId: orderId,
        operation: 'UPDATE',
        payload: jsonEncode(payload),
        idempotencyKey: 'order_status_${orderId}_$status',
      );
    } catch (e) {
      debugPrint('[OnlineOrders] Error enqueueing sync: $e');
    }
  }
}

/// مزود الطلبات الأونلاين
final onlineOrdersProvider = StateNotifierProvider<OnlineOrdersNotifier, OnlineOrdersState>(
  (ref) {
    final storeId = ref.watch(currentStoreIdProvider);
    return OnlineOrdersNotifier(storeId);
  },
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
