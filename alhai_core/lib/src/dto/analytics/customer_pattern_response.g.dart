// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_pattern_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerPatternResponse _$CustomerPatternResponseFromJson(
  Map<String, dynamic> json,
) => CustomerPatternResponse(
  customerId: json['customerId'] as String,
  customerName: json['customerName'] as String,
  totalOrders: (json['totalOrders'] as num).toInt(),
  totalSpent: (json['totalSpent'] as num).toDouble(),
  averageOrderValue: (json['averageOrderValue'] as num).toDouble(),
  frequentProducts: (json['frequentProducts'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  daysSinceLastOrder: (json['daysSinceLastOrder'] as num).toInt(),
  lastOrderDate: json['lastOrderDate'] as String?,
);

Map<String, dynamic> _$CustomerPatternResponseToJson(
  CustomerPatternResponse instance,
) => <String, dynamic>{
  'customerId': instance.customerId,
  'customerName': instance.customerName,
  'totalOrders': instance.totalOrders,
  'totalSpent': instance.totalSpent,
  'averageOrderValue': instance.averageOrderValue,
  'frequentProducts': instance.frequentProducts,
  'daysSinceLastOrder': instance.daysSinceLastOrder,
  'lastOrderDate': instance.lastOrderDate,
};
