// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_value_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryValueResponse _$InventoryValueResponseFromJson(
  Map<String, dynamic> json,
) => InventoryValueResponse(
  totalProducts: (json['totalProducts'] as num).toInt(),
  totalUnits: (json['totalUnits'] as num).toInt(),
  costValue: (json['costValue'] as num).toDouble(),
  retailValue: (json['retailValue'] as num).toDouble(),
  lowStockCount: (json['lowStockCount'] as num).toInt(),
  outOfStockCount: (json['outOfStockCount'] as num).toInt(),
);

Map<String, dynamic> _$InventoryValueResponseToJson(
  InventoryValueResponse instance,
) => <String, dynamic>{
  'totalProducts': instance.totalProducts,
  'totalUnits': instance.totalUnits,
  'costValue': instance.costValue,
  'retailValue': instance.retailValue,
  'lowStockCount': instance.lowStockCount,
  'outOfStockCount': instance.outOfStockCount,
};
