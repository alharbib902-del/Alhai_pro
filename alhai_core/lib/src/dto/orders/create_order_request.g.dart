// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateOrderRequestImpl _$$CreateOrderRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateOrderRequestImpl(
  clientOrderId: json['client_order_id'] as String,
  storeId: json['store_id'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItemRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
  deliveryAddress: json['delivery_address'] as String?,
  paymentMethod: json['payment_method'] as String,
  deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$CreateOrderRequestImplToJson(
  _$CreateOrderRequestImpl instance,
) => <String, dynamic>{
  'client_order_id': instance.clientOrderId,
  'store_id': instance.storeId,
  'items': instance.items,
  'delivery_address': instance.deliveryAddress,
  'payment_method': instance.paymentMethod,
  'delivery_fee': instance.deliveryFee,
};
