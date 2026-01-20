// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderPaymentImpl _$$OrderPaymentImplFromJson(Map<String, dynamic> json) =>
    _$OrderPaymentImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      method: $enumDecode(_$PaymentMethodEnumMap, json['method']),
      amount: (json['amount'] as num).toDouble(),
      referenceNo: json['referenceNo'] as String?,
      status: json['status'] as String? ?? 'completed',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$OrderPaymentImplToJson(_$OrderPaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'method': _$PaymentMethodEnumMap[instance.method]!,
      'amount': instance.amount,
      'referenceNo': instance.referenceNo,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.card: 'card',
  PaymentMethod.wallet: 'wallet',
  PaymentMethod.bankTransfer: 'bankTransfer',
};
