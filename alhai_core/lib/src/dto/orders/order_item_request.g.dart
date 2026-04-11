// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderItemRequestImpl _$$OrderItemRequestImplFromJson(
  Map<String, dynamic> json,
) => _$OrderItemRequestImpl(
  productId: json['product_id'] as String,
  name: json['name'] as String,
  unitPrice: (json['unit_price'] as num).toDouble(),
  qty: (json['qty'] as num).toInt(),
  lineTotal: (json['line_total'] as num).toDouble(),
);

Map<String, dynamic> _$$OrderItemRequestImplToJson(
  _$OrderItemRequestImpl instance,
) => <String, dynamic>{
  'product_id': instance.productId,
  'name': instance.name,
  'unit_price': instance.unitPrice,
  'qty': instance.qty,
  'line_total': instance.lineTotal,
};
