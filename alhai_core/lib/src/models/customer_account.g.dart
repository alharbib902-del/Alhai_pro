// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerAccountImpl _$$CustomerAccountImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerAccountImpl(
  id: json['id'] as String,
  customerId: json['customerId'] as String,
  storeId: json['storeId'] as String,
  balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
  creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 500.0,
  isActive: json['isActive'] as bool? ?? true,
  totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
  completedOrders: (json['completedOrders'] as num?)?.toInt() ?? 0,
  cancelledOrders: (json['cancelledOrders'] as num?)?.toInt() ?? 0,
  lastOrderAt: json['lastOrderAt'] == null
      ? null
      : DateTime.parse(json['lastOrderAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$CustomerAccountImplToJson(
  _$CustomerAccountImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'customerId': instance.customerId,
  'storeId': instance.storeId,
  'balance': instance.balance,
  'creditLimit': instance.creditLimit,
  'isActive': instance.isActive,
  'totalOrders': instance.totalOrders,
  'completedOrders': instance.completedOrders,
  'cancelledOrders': instance.cancelledOrders,
  'lastOrderAt': instance.lastOrderAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
