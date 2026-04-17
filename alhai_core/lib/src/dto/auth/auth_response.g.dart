// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserResponseImpl _$$UserResponseImplFromJson(Map<String, dynamic> json) =>
    _$UserResponseImpl(
      id: json['id'] as String,
      phone: json['phone'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      storeId: json['store_id'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$$UserResponseImplToJson(_$UserResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'name': instance.name,
      'role': instance.role,
      'store_id': instance.storeId,
      'created_at': instance.createdAt,
    };

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map<String, dynamic> json) =>
    _$AuthResponseImpl(
      user: UserResponse.fromJson(json['user'] as Map<String, dynamic>),
      tokens: AuthTokensResponse.fromJson(
        json['tokens'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{'user': instance.user, 'tokens': instance.tokens};
