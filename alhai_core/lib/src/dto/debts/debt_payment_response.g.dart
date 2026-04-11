// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_payment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DebtPaymentResponse _$DebtPaymentResponseFromJson(Map<String, dynamic> json) =>
    DebtPaymentResponse(
      id: json['id'] as String,
      debtId: json['debtId'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$DebtPaymentResponseToJson(
  DebtPaymentResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'debtId': instance.debtId,
  'amount': instance.amount,
  'paymentMethod': instance.paymentMethod,
  'notes': instance.notes,
  'createdAt': instance.createdAt,
};

RecordPaymentRequest _$RecordPaymentRequestFromJson(
  Map<String, dynamic> json,
) => RecordPaymentRequest(
  debtId: json['debtId'] as String,
  amount: (json['amount'] as num).toDouble(),
  paymentMethod: json['paymentMethod'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$RecordPaymentRequestToJson(
  RecordPaymentRequest instance,
) => <String, dynamic>{
  'debtId': instance.debtId,
  'amount': instance.amount,
  'paymentMethod': instance.paymentMethod,
  'notes': instance.notes,
};
