import 'package:freezed_annotation/freezed_annotation.dart';

import 'address.dart';
import 'enums/order_status.dart';
import 'enums/payment_method.dart';
import 'order_item.dart';

part 'order.freezed.dart';
part 'order.g.dart';

/// Order domain model (v3.2 - Complete)
@freezed
class Order with _$Order {
  const Order._();

  const factory Order({
    required String id,
    String? orderNumber,
    required String customerId,
    String? customerName,
    String? customerPhone,
    required String storeId,
    String? storeName,
    required OrderStatus status,
    required List<OrderItem> items,
    required double subtotal,
    @Default(0) double discount,
    @Default(0) double deliveryFee,
    @Default(0) double tax,
    required double total,
    required PaymentMethod paymentMethod,
    @Default(false) bool isPaid,
    String? addressId,
    Address? deliveryAddress,
    String? notes,
    String? cancellationReason,
    DateTime? confirmedAt,
    DateTime? preparingAt,
    DateTime? readyAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) =>
      _$OrderFromJson(json);

  /// Get items count
  int get itemCount => items.fold(0, (sum, item) => sum + item.qty);

  /// Check if order can be cancelled
  bool get canCancel => 
      status == OrderStatus.created || 
      status == OrderStatus.confirmed;

  /// Check if order is completed
  bool get isCompleted => 
      status == OrderStatus.delivered || 
      status == OrderStatus.cancelled;

  /// Get display-friendly order number
  String get displayNumber => orderNumber ?? '#${id.substring(0, 8).toUpperCase()}';
}
