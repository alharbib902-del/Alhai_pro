import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/create_order_params.dart';
import 'order_item_request.dart';

part 'create_order_request.freezed.dart';
part 'create_order_request.g.dart';

/// DTO for create order request to API (snake_case)
@freezed
class CreateOrderRequest with _$CreateOrderRequest {
  const CreateOrderRequest._();

  const factory CreateOrderRequest({
    @JsonKey(name: 'client_order_id') required String clientOrderId,
    @JsonKey(name: 'store_id') required String storeId,
    required List<OrderItemRequest> items,
    @JsonKey(name: 'delivery_address') String? deliveryAddress,
    @JsonKey(name: 'payment_method') required String paymentMethod,
  }) = _CreateOrderRequest;

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderRequestFromJson(json);

  /// Creates DTO from Domain model
  factory CreateOrderRequest.fromDomain(CreateOrderParams params) {
    return CreateOrderRequest(
      clientOrderId: params.clientOrderId,
      storeId: params.storeId,
      items: params.items.map((i) => OrderItemRequest.fromDomain(i)).toList(),
      deliveryAddress: params.deliveryAddress,
      paymentMethod: params.paymentMethod.name,
    );
  }
}

/// Extension on CreateOrderParams for convenient conversion
extension CreateOrderParamsX on CreateOrderParams {
  /// Converts Domain model to DTO for API request
  CreateOrderRequest toRequest() {
    return CreateOrderRequest.fromDomain(this);
  }
}
