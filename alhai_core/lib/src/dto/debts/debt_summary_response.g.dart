// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_summary_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DebtSummaryResponse _$DebtSummaryResponseFromJson(Map<String, dynamic> json) =>
    DebtSummaryResponse(
      totalCustomerDebts: (json['totalCustomerDebts'] as num).toDouble(),
      totalSupplierDebts: (json['totalSupplierDebts'] as num).toDouble(),
      overdueCount: (json['overdueCount'] as num).toInt(),
      overdueAmount: (json['overdueAmount'] as num).toDouble(),
    );

Map<String, dynamic> _$DebtSummaryResponseToJson(
  DebtSummaryResponse instance,
) => <String, dynamic>{
  'totalCustomerDebts': instance.totalCustomerDebts,
  'totalSupplierDebts': instance.totalSupplierDebts,
  'overdueCount': instance.overdueCount,
  'overdueAmount': instance.overdueAmount,
};
