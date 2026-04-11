// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderItemResponseImpl _$$OrderItemResponseImplFromJson(
  Map<String, dynamic> json,
) => _$OrderItemResponseImpl(
  productId: json['product_id'] as String,
  name: json['name'] as String,
  unitPrice: (json['unit_price'] as num).toDouble(),
  qty: (json['qty'] as num).toInt(),
  lineTotal: (json['line_total'] as num).toDouble(),
);

Map<String, dynamic> _$$OrderItemResponseImplToJson(
  _$OrderItemResponseImpl instance,
) => <String, dynamic>{
  'product_id': instance.productId,
  'name': instance.name,
  'unit_price': instance.unitPrice,
  'qty': instance.qty,
  'line_total': instance.lineTotal,
};
