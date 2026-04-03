// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adjust_stock_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdjustStockRequest _$AdjustStockRequestFromJson(Map<String, dynamic> json) =>
    AdjustStockRequest(
      productId: json['productId'] as String,
      storeId: json['storeId'] as String,
      type: json['type'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      reason: json['reason'] as String?,
      referenceId: json['referenceId'] as String?,
    );

Map<String, dynamic> _$AdjustStockRequestToJson(AdjustStockRequest instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'storeId': instance.storeId,
      'type': instance.type,
      'quantity': instance.quantity,
      'reason': instance.reason,
      'referenceId': instance.referenceId,
    };
