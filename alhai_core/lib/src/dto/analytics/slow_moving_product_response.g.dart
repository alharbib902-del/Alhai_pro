// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slow_moving_product_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SlowMovingProductResponse _$SlowMovingProductResponseFromJson(
        Map<String, dynamic> json) =>
    SlowMovingProductResponse(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      categoryName: json['categoryName'] as String?,
      daysSinceLastSale: (json['daysSinceLastSale'] as num).toInt(),
      stockQty: (json['stockQty'] as num).toInt(),
      stockValue: (json['stockValue'] as num).toDouble(),
      suggestedDiscount: (json['suggestedDiscount'] as num?)?.toDouble(),
      lastSaleDate: json['lastSaleDate'] as String?,
    );

Map<String, dynamic> _$SlowMovingProductResponseToJson(
        SlowMovingProductResponse instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'categoryName': instance.categoryName,
      'daysSinceLastSale': instance.daysSinceLastSale,
      'stockQty': instance.stockQty,
      'stockValue': instance.stockValue,
      'suggestedDiscount': instance.suggestedDiscount,
      'lastSaleDate': instance.lastSaleDate,
    };
