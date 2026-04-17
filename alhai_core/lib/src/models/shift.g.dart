// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShiftImpl _$$ShiftImplFromJson(Map<String, dynamic> json) => _$ShiftImpl(
  id: json['id'] as String,
  storeId: json['storeId'] as String,
  cashierId: json['cashierId'] as String,
  openingCash: (json['openingCash'] as num).toDouble(),
  closingCash: (json['closingCash'] as num?)?.toDouble(),
  expectedCash: (json['expectedCash'] as num?)?.toDouble(),
  cashDifference: (json['cashDifference'] as num?)?.toDouble(),
  status:
      $enumDecodeNullable(_$ShiftStatusEnumMap, json['status']) ??
      ShiftStatus.open,
  openedAt: DateTime.parse(json['openedAt'] as String),
  closedAt: json['closedAt'] == null
      ? null
      : DateTime.parse(json['closedAt'] as String),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$ShiftImplToJson(_$ShiftImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storeId': instance.storeId,
      'cashierId': instance.cashierId,
      'openingCash': instance.openingCash,
      'closingCash': instance.closingCash,
      'expectedCash': instance.expectedCash,
      'cashDifference': instance.cashDifference,
      'status': _$ShiftStatusEnumMap[instance.status]!,
      'openedAt': instance.openedAt.toIso8601String(),
      'closedAt': instance.closedAt?.toIso8601String(),
      'notes': instance.notes,
    };

const _$ShiftStatusEnumMap = {
  ShiftStatus.open: 'open',
  ShiftStatus.closed: 'closed',
};
