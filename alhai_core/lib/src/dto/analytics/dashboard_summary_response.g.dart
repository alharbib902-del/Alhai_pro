// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_summary_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardSummaryResponse _$DashboardSummaryResponseFromJson(
        Map<String, dynamic> json) =>
    DashboardSummaryResponse(
      todaySales: SalesSummaryResponse.fromJson(
          json['todaySales'] as Map<String, dynamic>),
      alertsCount: (json['alertsCount'] as num).toInt(),
      lowStockCount: (json['lowStockCount'] as num).toInt(),
      slowMovingCount: (json['slowMovingCount'] as num).toInt(),
      revenueChange: (json['revenueChange'] as num).toDouble(),
      pendingOrdersCount: (json['pendingOrdersCount'] as num).toInt(),
      totalDebtsAmount: (json['totalDebtsAmount'] as num).toDouble(),
    );

Map<String, dynamic> _$DashboardSummaryResponseToJson(
        DashboardSummaryResponse instance) =>
    <String, dynamic>{
      'todaySales': instance.todaySales,
      'alertsCount': instance.alertsCount,
      'lowStockCount': instance.lowStockCount,
      'slowMovingCount': instance.slowMovingCount,
      'revenueChange': instance.revenueChange,
      'pendingOrdersCount': instance.pendingOrdersCount,
      'totalDebtsAmount': instance.totalDebtsAmount,
    };
