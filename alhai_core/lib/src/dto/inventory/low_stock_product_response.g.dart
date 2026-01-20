// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'low_stock_product_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LowStockProductResponse _$LowStockProductResponseFromJson(
        Map<String, dynamic> json) =>
    LowStockProductResponse(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      currentQty: (json['currentQty'] as num).toInt(),
      minQty: (json['minQty'] as num).toInt(),
    );

Map<String, dynamic> _$LowStockProductResponseToJson(
        LowStockProductResponse instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'currentQty': instance.currentQty,
      'minQty': instance.minQty,
    };
