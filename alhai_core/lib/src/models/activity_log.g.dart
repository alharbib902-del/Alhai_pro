// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivityLogImpl _$$ActivityLogImplFromJson(Map<String, dynamic> json) =>
    _$ActivityLogImpl(
      id: json['id'] as String,
      storeId: json['storeId'] as String?,
      userId: json['userId'] as String?,
      action: json['action'] as String,
      entityType: json['entityType'] as String?,
      entityId: json['entityId'] as String?,
      details: json['details'] as Map<String, dynamic>?,
      ipAddress: json['ipAddress'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ActivityLogImplToJson(_$ActivityLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storeId': instance.storeId,
      'userId': instance.userId,
      'action': instance.action,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'details': instance.details,
      'ipAddress': instance.ipAddress,
      'createdAt': instance.createdAt.toIso8601String(),
    };
