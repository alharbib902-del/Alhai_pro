import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/order_item.dart';

part 'order_item_response.freezed.dart';
part 'order_item_response.g.dart';

/// DTO for order item in API response (snake_case)
@freezed
class OrderItemResponse with _$OrderItemResponse {
  const OrderItemResponse._();

  const factory OrderItemResponse({
    @JsonKey(name: 'product_id') required String productId,
    required String name,
    @JsonKey(name: 'unit_price') required double unitPrice,
    required int qty,
    @JsonKey(name: 'line_total') required double lineTotal,
  }) = _OrderItemResponse;

  factory OrderItemResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderItemResponseFromJson(json);

  /// Maps DTO to Domain model
  OrderItem toDomain() {
    return OrderItem(
      productId: productId,
      name: name,
      unitPrice: unitPrice,
      qty: qty,
      lineTotal: lineTotal,
    );
  }
}
