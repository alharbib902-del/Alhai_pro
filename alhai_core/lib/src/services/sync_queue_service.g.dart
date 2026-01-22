// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_queue_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SyncQueueItemImpl _$$SyncQueueItemImplFromJson(Map<String, dynamic> json) =>
    _$SyncQueueItemImpl(
      id: json['id'] as String,
      entityType: $enumDecode(_$SyncEntityTypeEnumMap, json['entityType']),
      entityId: json['entityId'] as String,
      operation: $enumDecode(_$SyncOperationTypeEnumMap, json['operation']),
      status: $enumDecode(_$SyncStatusEnumMap, json['status']),
      payload: json['payload'] as String,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      maxAttempts: (json['maxAttempts'] as num?)?.toInt() ?? 3,
      lastError: json['lastError'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      syncedAt: json['syncedAt'] == null
          ? null
          : DateTime.parse(json['syncedAt'] as String),
      nextRetryAt: json['nextRetryAt'] == null
          ? null
          : DateTime.parse(json['nextRetryAt'] as String),
    );

Map<String, dynamic> _$$SyncQueueItemImplToJson(_$SyncQueueItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entityType': _$SyncEntityTypeEnumMap[instance.entityType]!,
      'entityId': instance.entityId,
      'operation': _$SyncOperationTypeEnumMap[instance.operation]!,
      'status': _$SyncStatusEnumMap[instance.status]!,
      'payload': instance.payload,
      'attempts': instance.attempts,
      'maxAttempts': instance.maxAttempts,
      'lastError': instance.lastError,
      'createdAt': instance.createdAt.toIso8601String(),
      'syncedAt': instance.syncedAt?.toIso8601String(),
      'nextRetryAt': instance.nextRetryAt?.toIso8601String(),
    };

const _$SyncEntityTypeEnumMap = {
  SyncEntityType.sale: 'SALE',
  SyncEntityType.order: 'ORDER',
  SyncEntityType.inventory: 'INVENTORY',
  SyncEntityType.customer: 'CUSTOMER',
  SyncEntityType.product: 'PRODUCT',
  SyncEntityType.shift: 'SHIFT',
  SyncEntityType.cashMovement: 'CASH_MOVEMENT',
  SyncEntityType.refund: 'REFUND',
};

const _$SyncOperationTypeEnumMap = {
  SyncOperationType.create: 'CREATE',
  SyncOperationType.update: 'UPDATE',
  SyncOperationType.delete: 'DELETE',
};

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'PENDING',
  SyncStatus.syncing: 'SYNCING',
  SyncStatus.synced: 'SYNCED',
  SyncStatus.failed: 'FAILED',
  SyncStatus.conflict: 'CONFLICT',
};

_$SyncConflictImpl _$$SyncConflictImplFromJson(Map<String, dynamic> json) =>
    _$SyncConflictImpl(
      id: json['id'] as String,
      entityType: $enumDecode(_$SyncEntityTypeEnumMap, json['entityType']),
      entityId: json['entityId'] as String,
      localValue: json['localValue'] as Map<String, dynamic>,
      serverValue: json['serverValue'] as Map<String, dynamic>,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      isResolved: json['isResolved'] as bool? ?? false,
      resolution: json['resolution'] as String?,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
    );

Map<String, dynamic> _$$SyncConflictImplToJson(_$SyncConflictImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entityType': _$SyncEntityTypeEnumMap[instance.entityType]!,
      'entityId': instance.entityId,
      'localValue': instance.localValue,
      'serverValue': instance.serverValue,
      'detectedAt': instance.detectedAt.toIso8601String(),
      'isResolved': instance.isResolved,
      'resolution': instance.resolution,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
    };
