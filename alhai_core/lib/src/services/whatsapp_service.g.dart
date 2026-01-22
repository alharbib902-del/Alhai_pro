// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whatsapp_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WhatsAppReceiptRequestImpl _$$WhatsAppReceiptRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$WhatsAppReceiptRequestImpl(
      orderId: json['orderId'] as String,
      phone: json['phone'] as String,
      customerName: json['customerName'] as String,
      language: json['language'] as String?,
    );

Map<String, dynamic> _$$WhatsAppReceiptRequestImplToJson(
        _$WhatsAppReceiptRequestImpl instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'phone': instance.phone,
      'customerName': instance.customerName,
      'language': instance.language,
    };

_$WhatsAppReceiptResponseImpl _$$WhatsAppReceiptResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$WhatsAppReceiptResponseImpl(
      messageId: json['messageId'] as String,
      status: $enumDecode(_$WhatsAppMessageStatusEnumMap, json['status']),
      receiptUrl: json['receiptUrl'] as String,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$WhatsAppReceiptResponseImplToJson(
        _$WhatsAppReceiptResponseImpl instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'status': _$WhatsAppMessageStatusEnumMap[instance.status]!,
      'receiptUrl': instance.receiptUrl,
      'errorMessage': instance.errorMessage,
    };

const _$WhatsAppMessageStatusEnumMap = {
  WhatsAppMessageStatus.queued: 'QUEUED',
  WhatsAppMessageStatus.sent: 'SENT',
  WhatsAppMessageStatus.delivered: 'DELIVERED',
  WhatsAppMessageStatus.failed: 'FAILED',
};
