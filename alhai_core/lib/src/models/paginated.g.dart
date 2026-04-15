// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaginatedImpl<T> _$$PaginatedImplFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    _$PaginatedImpl<T>(
      items: (json['items'] as List<dynamic>).map(fromJsonT).toList(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      total: (json['total'] as num?)?.toInt(),
      hasMore: json['hasMore'] as bool? ?? false,
    );

Map<String, dynamic> _$$PaginatedImplToJson<T>(
  _$PaginatedImpl<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'items': instance.items.map(toJsonT).toList(),
      'page': instance.page,
      'limit': instance.limit,
      'total': instance.total,
      'hasMore': instance.hasMore,
    };
