// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String?,
  name: json['name'] as String,
  imageUrl: json['imageUrl'] as String?,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  storeId: json['storeId'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  isVerified: json['isVerified'] as bool? ?? false,
  fcmToken: json['fcmToken'] as String?,
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'email': instance.email,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'role': _$UserRoleEnumMap[instance.role]!,
      'storeId': instance.storeId,
      'isActive': instance.isActive,
      'isVerified': instance.isVerified,
      'fcmToken': instance.fcmToken,
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.superAdmin: 'superAdmin',
  UserRole.storeOwner: 'storeOwner',
  UserRole.employee: 'employee',
  UserRole.delivery: 'delivery',
  UserRole.customer: 'customer',
};
