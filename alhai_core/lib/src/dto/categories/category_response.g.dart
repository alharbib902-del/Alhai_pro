// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryResponseImpl _$$CategoryResponseImplFromJson(
  Map<String, dynamic> json,
) => _$CategoryResponseImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  parentId: json['parent_id'] as String?,
  imageUrl: json['image_url'] as String?,
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$$CategoryResponseImplToJson(
  _$CategoryResponseImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'parent_id': instance.parentId,
  'image_url': instance.imageUrl,
  'sort_order': instance.sortOrder,
  'is_active': instance.isActive,
};
