// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductResponseImpl _$$ProductResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ProductResponseImpl(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      price: (json['price'] as num).toDouble(),
      costPrice: (json['cost_price'] as num?)?.toDouble(),
      stockQty: (json['stock_qty'] as num).toDouble(),
      minQty: (json['min_qty'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      imageThumbnail: json['image_thumbnail'] as String?,
      imageMedium: json['image_medium'] as String?,
      imageLarge: json['image_large'] as String?,
      imageHash: json['image_hash'] as String?,
      categoryId: json['category_id'] as String?,
      isActive: json['is_active'] as bool,
      trackInventory: json['track_inventory'] as bool? ?? true,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$ProductResponseImplToJson(
        _$ProductResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'store_id': instance.storeId,
      'name': instance.name,
      'sku': instance.sku,
      'barcode': instance.barcode,
      'price': instance.price,
      'cost_price': instance.costPrice,
      'stock_qty': instance.stockQty,
      'min_qty': instance.minQty,
      'unit': instance.unit,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'image_thumbnail': instance.imageThumbnail,
      'image_medium': instance.imageMedium,
      'image_large': instance.imageLarge,
      'image_hash': instance.imageHash,
      'category_id': instance.categoryId,
      'is_active': instance.isActive,
      'track_inventory': instance.trackInventory,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
