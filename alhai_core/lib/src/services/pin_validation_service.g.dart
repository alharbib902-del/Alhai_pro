// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin_validation_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PinValidationRequestImpl _$$PinValidationRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$PinValidationRequestImpl(
      pin: json['pin'] as String,
      action: $enumDecode(_$PinActionTypeEnumMap, json['action']),
      supervisorId: json['supervisorId'] as String?,
    );

Map<String, dynamic> _$$PinValidationRequestImplToJson(
        _$PinValidationRequestImpl instance) =>
    <String, dynamic>{
      'pin': instance.pin,
      'action': _$PinActionTypeEnumMap[instance.action]!,
      'supervisorId': instance.supervisorId,
    };

const _$PinActionTypeEnumMap = {
  PinActionType.refund: 'REFUND',
  PinActionType.discount: 'DISCOUNT',
  PinActionType.voidSale: 'VOID',
  PinActionType.cashOut: 'CASH_OUT',
  PinActionType.priceOverride: 'PRICE_OVERRIDE',
  PinActionType.shiftClose: 'SHIFT_CLOSE',
};

_$PinValidationResultImpl _$$PinValidationResultImplFromJson(
        Map<String, dynamic> json) =>
    _$PinValidationResultImpl(
      isValid: json['isValid'] as bool,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      role: json['role'] as String?,
      permissions: (json['permissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      errorMessage: json['errorMessage'] as String?,
      remainingAttempts: (json['remainingAttempts'] as num?)?.toInt() ?? 0,
      lockedUntil: json['lockedUntil'] == null
          ? null
          : DateTime.parse(json['lockedUntil'] as String),
    );

Map<String, dynamic> _$$PinValidationResultImplToJson(
        _$PinValidationResultImpl instance) =>
    <String, dynamic>{
      'isValid': instance.isValid,
      'userId': instance.userId,
      'userName': instance.userName,
      'role': instance.role,
      'permissions': instance.permissions,
      'errorMessage': instance.errorMessage,
      'remainingAttempts': instance.remainingAttempts,
      'lockedUntil': instance.lockedUntil?.toIso8601String(),
    };

_$EmergencyCodeImpl _$$EmergencyCodeImplFromJson(Map<String, dynamic> json) =>
    _$EmergencyCodeImpl(
      code: json['code'] as String,
      supervisorId: json['supervisorId'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      isUsed: json['isUsed'] as bool? ?? false,
    );

Map<String, dynamic> _$$EmergencyCodeImplToJson(_$EmergencyCodeImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'supervisorId': instance.supervisorId,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'isUsed': instance.isUsed,
    };

_$TotpSecretImpl _$$TotpSecretImplFromJson(Map<String, dynamic> json) =>
    _$TotpSecretImpl(
      userId: json['userId'] as String,
      secret: json['secret'] as String,
      syncedAt: DateTime.parse(json['syncedAt'] as String),
    );

Map<String, dynamic> _$$TotpSecretImplToJson(_$TotpSecretImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'secret': instance.secret,
      'syncedAt': instance.syncedAt.toIso8601String(),
    };
