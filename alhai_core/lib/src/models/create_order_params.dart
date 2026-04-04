import 'package:freezed_annotation/freezed_annotation.dart';

import 'order_item.dart';
import 'enums/payment_method.dart';

part 'create_order_params.freezed.dart';
part 'create_order_params.g.dart';

/// CreateOrderParams domain model - parameters for creating a new order
@freezed
class CreateOrderParams with _$CreateOrderParams {
  const factory CreateOrderParams({
    required String clientOrderId,
    required String storeId,
    required List<OrderItem> items,
    String? addressId,
    String? deliveryAddress,
    required PaymentMethod paymentMethod,
    @Default(0) double deliveryFee,
  }) = _CreateOrderParams;

  factory CreateOrderParams.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderParamsFromJson(json);
}
