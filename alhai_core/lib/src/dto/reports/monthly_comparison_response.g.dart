// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_comparison_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonthlyComparisonResponse _$MonthlyComparisonResponseFromJson(
        Map<String, dynamic> json) =>
    MonthlyComparisonResponse(
      currentMonthRevenue: (json['currentMonthRevenue'] as num).toDouble(),
      previousMonthRevenue: (json['previousMonthRevenue'] as num).toDouble(),
      currentMonthProfit: (json['currentMonthProfit'] as num).toDouble(),
      previousMonthProfit: (json['previousMonthProfit'] as num).toDouble(),
      currentMonthOrders: (json['currentMonthOrders'] as num).toInt(),
      previousMonthOrders: (json['previousMonthOrders'] as num).toInt(),
    );

Map<String, dynamic> _$MonthlyComparisonResponseToJson(
        MonthlyComparisonResponse instance) =>
    <String, dynamic>{
      'currentMonthRevenue': instance.currentMonthRevenue,
      'previousMonthRevenue': instance.previousMonthRevenue,
      'currentMonthProfit': instance.currentMonthProfit,
      'previousMonthProfit': instance.previousMonthProfit,
      'currentMonthOrders': instance.currentMonthOrders,
      'previousMonthOrders': instance.previousMonthOrders,
    };
