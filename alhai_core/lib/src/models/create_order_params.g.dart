// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateOrderParamsImpl _$$CreateOrderParamsImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateOrderParamsImpl(
      clientOrderId: json['clientOrderId'] as String,
      storeId: json['storeId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      addressId: json['addressId'] as String?,
      deliveryAddress: json['deliveryAddress'] as String?,
      paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
    );

Map<String, dynamic> _$$CreateOrderParamsImplToJson(
        _$CreateOrderParamsImpl instance) =>
    <String, dynamic>{
      'clientOrderId': instance.clientOrderId,
      'storeId': instance.storeId,
      'items': instance.items,
      'addressId': instance.addressId,
      'deliveryAddress': instance.deliveryAddress,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.card: 'card',
  PaymentMethod.wallet: 'wallet',
  PaymentMethod.bankTransfer: 'bankTransfer',
};
