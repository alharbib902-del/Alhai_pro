// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_product_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateProductParamsImpl _$$CreateProductParamsImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateProductParamsImpl(
      name: json['name'] as String,
      price: (json['price'] as num).toInt(),
      storeId: json['storeId'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      barcode: json['barcode'] as String?,
      categoryId: json['categoryId'] as String?,
      available: json['available'] as bool? ?? true,
    );

Map<String, dynamic> _$$CreateProductParamsImplToJson(
        _$CreateProductParamsImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
      'storeId': instance.storeId,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'barcode': instance.barcode,
      'categoryId': instance.categoryId,
      'available': instance.available,
    };
