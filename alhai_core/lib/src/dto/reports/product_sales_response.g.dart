// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_sales_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductSalesResponse _$ProductSalesResponseFromJson(
  Map<String, dynamic> json,
) => ProductSalesResponse(
  productId: json['productId'] as String,
  productName: json['productName'] as String,
  categoryId: json['categoryId'] as String?,
  quantitySold: (json['quantitySold'] as num).toInt(),
  revenue: (json['revenue'] as num).toDouble(),
  cost: (json['cost'] as num).toDouble(),
  profit: (json['profit'] as num).toDouble(),
);

Map<String, dynamic> _$ProductSalesResponseToJson(
  ProductSalesResponse instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'productName': instance.productName,
  'categoryId': instance.categoryId,
  'quantitySold': instance.quantitySold,
  'revenue': instance.revenue,
  'cost': instance.cost,
  'profit': instance.profit,
};
