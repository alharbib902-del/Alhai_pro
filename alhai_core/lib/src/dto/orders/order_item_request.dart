import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/order_item.dart';

part 'order_item_request.freezed.dart';
part 'order_item_request.g.dart';

/// DTO for order item in API request (snake_case)
@freezed
class OrderItemRequest with _$OrderItemRequest {
  const OrderItemRequest._();

  const factory OrderItemRequest({
    @JsonKey(name: 'product_id') required String productId,
    required String name,
    @JsonKey(name: 'unit_price') required double unitPrice,
    required int qty,
    @JsonKey(name: 'line_total') required double lineTotal,
  }) = _OrderItemRequest;

  factory OrderItemRequest.fromJson(Map<String, dynamic> json) =>
      _$OrderItemRequestFromJson(json);

  /// Creates DTO from Domain model
  factory OrderItemRequest.fromDomain(OrderItem item) {
    return OrderItemRequest(
      productId: item.productId,
      name: item.name,
      unitPrice: item.unitPrice,
      qty: item.qty,
      lineTotal: item.lineTotal,
    );
  }
}
