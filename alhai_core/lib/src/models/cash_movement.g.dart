// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_movement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CashMovementImpl _$$CashMovementImplFromJson(Map<String, dynamic> json) =>
    _$CashMovementImpl(
      id: json['id'] as String,
      shiftId: json['shiftId'] as String,
      storeId: json['storeId'] as String,
      cashierId: json['cashierId'] as String,
      type: $enumDecode(_$CashMovementTypeEnumMap, json['type']),
      amount: (json['amount'] as num).toDouble(),
      reason: $enumDecode(_$CashMovementReasonEnumMap, json['reason']),
      notes: json['notes'] as String?,
      supervisorId: json['supervisorId'] as String?,
      supervisorPin: json['supervisorPin'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CashMovementImplToJson(_$CashMovementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shiftId': instance.shiftId,
      'storeId': instance.storeId,
      'cashierId': instance.cashierId,
      'type': _$CashMovementTypeEnumMap[instance.type]!,
      'amount': instance.amount,
      'reason': _$CashMovementReasonEnumMap[instance.reason]!,
      'notes': instance.notes,
      'supervisorId': instance.supervisorId,
      'supervisorPin': instance.supervisorPin,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$CashMovementTypeEnumMap = {
  CashMovementType.cashIn: 'CASH_IN',
  CashMovementType.cashOut: 'CASH_OUT',
};

const _$CashMovementReasonEnumMap = {
  CashMovementReason.bankDeposit: 'BANK_DEPOSIT',
  CashMovementReason.changeFund: 'CHANGE_FUND',
  CashMovementReason.expense: 'EXPENSE',
  CashMovementReason.supplierPayment: 'SUPPLIER_PAYMENT',
  CashMovementReason.other: 'OTHER',
};
