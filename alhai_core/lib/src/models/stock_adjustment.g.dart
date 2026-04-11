// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_adjustment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StockAdjustmentImpl _$$StockAdjustmentImplFromJson(
  Map<String, dynamic> json,
) => _$StockAdjustmentImpl(
  id: json['id'] as String,
  productId: json['productId'] as String,
  storeId: json['storeId'] as String,
  type: $enumDecode(_$AdjustmentTypeEnumMap, json['type']),
  quantity: (json['quantity'] as num).toDouble(),
  previousQty: (json['previousQty'] as num).toDouble(),
  newQty: (json['newQty'] as num).toDouble(),
  reason: json['reason'] as String?,
  referenceId: json['referenceId'] as String?,
  createdBy: json['createdBy'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$StockAdjustmentImplToJson(
  _$StockAdjustmentImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'storeId': instance.storeId,
  'type': _$AdjustmentTypeEnumMap[instance.type]!,
  'quantity': instance.quantity,
  'previousQty': instance.previousQty,
  'newQty': instance.newQty,
  'reason': instance.reason,
  'referenceId': instance.referenceId,
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$AdjustmentTypeEnumMap = {
  AdjustmentType.received: 'received',
  AdjustmentType.returned: 'returned',
  AdjustmentType.damaged: 'damaged',
  AdjustmentType.correction: 'correction',
  AdjustmentType.transferOut: 'transferOut',
  AdjustmentType.transferIn: 'transferIn',
  AdjustmentType.sold: 'sold',
};
