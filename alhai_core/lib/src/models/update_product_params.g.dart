// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_product_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UpdateProductParamsImpl _$$UpdateProductParamsImplFromJson(
  Map<String, dynamic> json,
) => _$UpdateProductParamsImpl(
  id: json['id'] as String,
  name: json['name'] as String?,
  price: (json['price'] as num?)?.toDouble(),
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  barcode: json['barcode'] as String?,
  categoryId: json['categoryId'] as String?,
  available: json['available'] as bool?,
);

Map<String, dynamic> _$$UpdateProductParamsImplToJson(
  _$UpdateProductParamsImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'barcode': instance.barcode,
  'categoryId': instance.categoryId,
  'available': instance.available,
};
