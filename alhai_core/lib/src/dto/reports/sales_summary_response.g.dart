// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_summary_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalesSummaryResponse _$SalesSummaryResponseFromJson(
        Map<String, dynamic> json) =>
    SalesSummaryResponse(
      date: json['date'] as String,
      ordersCount: (json['ordersCount'] as num).toInt(),
      itemsSold: (json['itemsSold'] as num).toInt(),
      revenue: (json['revenue'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      discounts: (json['discounts'] as num?)?.toDouble(),
      returns: (json['returns'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SalesSummaryResponseToJson(
        SalesSummaryResponse instance) =>
    <String, dynamic>{
      'date': instance.date,
      'ordersCount': instance.ordersCount,
      'itemsSold': instance.itemsSold,
      'revenue': instance.revenue,
      'cost': instance.cost,
      'profit': instance.profit,
      'discounts': instance.discounts,
      'returns': instance.returns,
    };
