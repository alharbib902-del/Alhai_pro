// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_adjustment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockAdjustmentResponse _$StockAdjustmentResponseFromJson(
        Map<String, dynamic> json) =>
    StockAdjustmentResponse(
      id: json['id'] as String,
      productId: json['productId'] as String,
      storeId: json['storeId'] as String,
      type: json['type'] as String,
      quantity: (json['quantity'] as num).toInt(),
      previousQty: (json['previousQty'] as num).toInt(),
      newQty: (json['newQty'] as num).toInt(),
      reason: json['reason'] as String?,
      referenceId: json['referenceId'] as String?,
      createdBy: json['createdBy'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$StockAdjustmentResponseToJson(
        StockAdjustmentResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'storeId': instance.storeId,
      'type': instance.type,
      'quantity': instance.quantity,
      'previousQty': instance.previousQty,
      'newQty': instance.newQty,
      'reason': instance.reason,
      'referenceId': instance.referenceId,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt,
    };
