// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_alert_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SmartAlertResponse _$SmartAlertResponseFromJson(Map<String, dynamic> json) =>
    SmartAlertResponse(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      actionLabel: json['actionLabel'] as String?,
      actionRoute: json['actionRoute'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$SmartAlertResponseToJson(SmartAlertResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'message': instance.message,
      'actionLabel': instance.actionLabel,
      'actionRoute': instance.actionRoute,
      'metadata': instance.metadata,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt,
    };
