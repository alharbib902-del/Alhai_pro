// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_sales_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategorySalesResponse _$CategorySalesResponseFromJson(
        Map<String, dynamic> json) =>
    CategorySalesResponse(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      productsSold: (json['productsSold'] as num).toInt(),
      revenue: (json['revenue'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
    );

Map<String, dynamic> _$CategorySalesResponseToJson(
        CategorySalesResponse instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'productsSold': instance.productsSold,
      'revenue': instance.revenue,
      'profit': instance.profit,
    };
