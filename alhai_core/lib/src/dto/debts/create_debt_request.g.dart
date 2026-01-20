// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_debt_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDebtRequest _$CreateDebtRequestFromJson(Map<String, dynamic> json) =>
    CreateDebtRequest(
      storeId: json['storeId'] as String,
      type: json['type'] as String,
      partyId: json['partyId'] as String,
      partyName: json['partyName'] as String,
      partyPhone: json['partyPhone'] as String?,
      amount: (json['amount'] as num).toDouble(),
      orderId: json['orderId'] as String?,
      notes: json['notes'] as String?,
      dueDate: json['dueDate'] as String?,
    );

Map<String, dynamic> _$CreateDebtRequestToJson(CreateDebtRequest instance) =>
    <String, dynamic>{
      'storeId': instance.storeId,
      'type': instance.type,
      'partyId': instance.partyId,
      'partyName': instance.partyName,
      'partyPhone': instance.partyPhone,
      'amount': instance.amount,
      'orderId': instance.orderId,
      'notes': instance.notes,
      'dueDate': instance.dueDate,
    };
