// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DebtImpl _$$DebtImplFromJson(Map<String, dynamic> json) => _$DebtImpl(
  id: json['id'] as String,
  storeId: json['storeId'] as String,
  type: $enumDecode(_$DebtTypeEnumMap, json['type']),
  partyId: json['partyId'] as String,
  partyName: json['partyName'] as String,
  partyPhone: json['partyPhone'] as String?,
  originalAmount: (json['originalAmount'] as num).toDouble(),
  remainingAmount: (json['remainingAmount'] as num).toDouble(),
  orderId: json['orderId'] as String?,
  notes: json['notes'] as String?,
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$DebtImplToJson(_$DebtImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storeId': instance.storeId,
      'type': _$DebtTypeEnumMap[instance.type]!,
      'partyId': instance.partyId,
      'partyName': instance.partyName,
      'partyPhone': instance.partyPhone,
      'originalAmount': instance.originalAmount,
      'remainingAmount': instance.remainingAmount,
      'orderId': instance.orderId,
      'notes': instance.notes,
      'dueDate': instance.dueDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$DebtTypeEnumMap = {
  DebtType.customerDebt: 'customerDebt',
  DebtType.supplierDebt: 'supplierDebt',
};

_$DebtPaymentImpl _$$DebtPaymentImplFromJson(Map<String, dynamic> json) =>
    _$DebtPaymentImpl(
      id: json['id'] as String,
      debtId: json['debtId'] as String,
      amount: (json['amount'] as num).toDouble(),
      notes: json['notes'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$DebtPaymentImplToJson(_$DebtPaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'debtId': instance.debtId,
      'amount': instance.amount,
      'notes': instance.notes,
      'paymentMethod': instance.paymentMethod,
      'createdAt': instance.createdAt.toIso8601String(),
    };
