import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/order.dart';
import '../shared/enum_parsers.dart';
import 'order_item_response.dart';

part 'order_response.freezed.dart';
part 'order_response.g.dart';

/// DTO for order response from API (snake_case) - Complete v3.2
@freezed
class OrderResponse with _$OrderResponse {
  const OrderResponse._();

  const factory OrderResponse({
    required String id,
    @JsonKey(name: 'order_number') String? orderNumber,
    @JsonKey(name: 'customer_id') required String customerId,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'customer_phone') String? customerPhone,
    @JsonKey(name: 'store_id') required String storeId,
    @JsonKey(name: 'store_name') String? storeName,
    required String status,
    required List<OrderItemResponse> items,
    required double subtotal,
    @Default(0) double discount,
    @JsonKey(name: 'delivery_fee') @Default(0) double deliveryFee,
    @Default(0) double tax,
    required double total,
    @JsonKey(name: 'payment_method') required String paymentMethod,
    @JsonKey(name: 'is_paid') @Default(false) bool isPaid,
    @JsonKey(name: 'address_id') String? addressId,
    String? notes,
    @JsonKey(name: 'cancellation_reason') String? cancellationReason,
    @JsonKey(name: 'confirmed_at') String? confirmedAt,
    @JsonKey(name: 'preparing_at') String? preparingAt,
    @JsonKey(name: 'ready_at') String? readyAt,
    @JsonKey(name: 'delivered_at') String? deliveredAt,
    @JsonKey(name: 'cancelled_at') String? cancelledAt,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _OrderResponse;

  factory OrderResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderResponseFromJson(json);

  /// Maps DTO to Domain model
  Order toDomain() {
    return Order(
      id: id,
      orderNumber: orderNumber,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      storeId: storeId,
      storeName: storeName,
      status: OrderStatusX.fromApi(status),
      items: items.map((i) => i.toDomain()).toList(),
      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      tax: tax,
      total: total,
      paymentMethod: PaymentMethodX.fromApi(paymentMethod),
      isPaid: isPaid,
      addressId: addressId,
      notes: notes,
      cancellationReason: cancellationReason,
      confirmedAt: confirmedAt != null ? DateTime.parse(confirmedAt!) : null,
      preparingAt: preparingAt != null ? DateTime.parse(preparingAt!) : null,
      readyAt: readyAt != null ? DateTime.parse(readyAt!) : null,
      deliveredAt: deliveredAt != null ? DateTime.parse(deliveredAt!) : null,
      cancelledAt: cancelledAt != null ? DateTime.parse(cancelledAt!) : null,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }
}
