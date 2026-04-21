// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_product_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UpdateProductRequestImpl _$$UpdateProductRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateProductRequestImpl(
      name: json['name'] as String?,
      price: (json['price'] as num?)?.toInt(),
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      barcode: json['barcode'] as String?,
      categoryId: json['category_id'] as String?,
      available: json['available'] as bool?,
    );

Map<String, dynamic> _$$UpdateProductRequestImplToJson(
        _$UpdateProductRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'barcode': instance.barcode,
      'category_id': instance.categoryId,
      'available': instance.available,
    };
