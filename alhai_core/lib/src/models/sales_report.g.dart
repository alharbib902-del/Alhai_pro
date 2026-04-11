// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SalesSummaryImpl _$$SalesSummaryImplFromJson(Map<String, dynamic> json) =>
    _$SalesSummaryImpl(
      date: DateTime.parse(json['date'] as String),
      ordersCount: (json['ordersCount'] as num).toInt(),
      itemsSold: (json['itemsSold'] as num).toInt(),
      revenue: (json['revenue'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      discounts: (json['discounts'] as num?)?.toDouble() ?? 0,
      returns: (json['returns'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$$SalesSummaryImplToJson(_$SalesSummaryImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'ordersCount': instance.ordersCount,
      'itemsSold': instance.itemsSold,
      'revenue': instance.revenue,
      'cost': instance.cost,
      'profit': instance.profit,
      'discounts': instance.discounts,
      'returns': instance.returns,
    };

_$ProductSalesImpl _$$ProductSalesImplFromJson(Map<String, dynamic> json) =>
    _$ProductSalesImpl(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      categoryId: json['categoryId'] as String?,
      quantitySold: (json['quantitySold'] as num).toInt(),
      revenue: (json['revenue'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
    );

Map<String, dynamic> _$$ProductSalesImplToJson(_$ProductSalesImpl instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'categoryId': instance.categoryId,
      'quantitySold': instance.quantitySold,
      'revenue': instance.revenue,
      'cost': instance.cost,
      'profit': instance.profit,
    };

_$CategorySalesImpl _$$CategorySalesImplFromJson(Map<String, dynamic> json) =>
    _$CategorySalesImpl(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      productsSold: (json['productsSold'] as num).toInt(),
      revenue: (json['revenue'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
    );

Map<String, dynamic> _$$CategorySalesImplToJson(_$CategorySalesImpl instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'productsSold': instance.productsSold,
      'revenue': instance.revenue,
      'profit': instance.profit,
    };

_$InventoryValueImpl _$$InventoryValueImplFromJson(Map<String, dynamic> json) =>
    _$InventoryValueImpl(
      totalProducts: (json['totalProducts'] as num).toInt(),
      totalUnits: (json['totalUnits'] as num).toInt(),
      costValue: (json['costValue'] as num).toDouble(),
      retailValue: (json['retailValue'] as num).toDouble(),
      lowStockCount: (json['lowStockCount'] as num).toInt(),
      outOfStockCount: (json['outOfStockCount'] as num).toInt(),
    );

Map<String, dynamic> _$$InventoryValueImplToJson(
  _$InventoryValueImpl instance,
) => <String, dynamic>{
  'totalProducts': instance.totalProducts,
  'totalUnits': instance.totalUnits,
  'costValue': instance.costValue,
  'retailValue': instance.retailValue,
  'lowStockCount': instance.lowStockCount,
  'outOfStockCount': instance.outOfStockCount,
};
