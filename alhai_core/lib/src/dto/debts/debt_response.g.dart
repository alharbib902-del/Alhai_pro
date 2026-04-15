// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DebtResponse _$DebtResponseFromJson(Map<String, dynamic> json) => DebtResponse(
      id: json['id'] as String,
      storeId: json['storeId'] as String,
      type: json['type'] as String,
      partyId: json['partyId'] as String,
      partyName: json['partyName'] as String,
      partyPhone: json['partyPhone'] as String?,
      originalAmount: (json['originalAmount'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      orderId: json['orderId'] as String?,
      notes: json['notes'] as String?,
      dueDate: json['dueDate'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$DebtResponseToJson(DebtResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storeId': instance.storeId,
      'type': instance.type,
      'partyId': instance.partyId,
      'partyName': instance.partyName,
      'partyPhone': instance.partyPhone,
      'originalAmount': instance.originalAmount,
      'remainingAmount': instance.remainingAmount,
      'orderId': instance.orderId,
      'notes': instance.notes,
      'dueDate': instance.dueDate,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
