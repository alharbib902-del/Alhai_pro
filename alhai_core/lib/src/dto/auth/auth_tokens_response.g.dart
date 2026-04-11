// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_tokens_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthTokensResponseImpl _$$AuthTokensResponseImplFromJson(
  Map<String, dynamic> json,
) => _$AuthTokensResponseImpl(
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
  expiresAt: json['expires_at'] as String,
);

Map<String, dynamic> _$$AuthTokensResponseImplToJson(
  _$AuthTokensResponseImpl instance,
) => <String, dynamic>{
  'access_token': instance.accessToken,
  'refresh_token': instance.refreshToken,
  'expires_at': instance.expiresAt,
};
