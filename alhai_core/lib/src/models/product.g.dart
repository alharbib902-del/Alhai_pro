// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: json['id'] as String,
      storeId: json['storeId'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      price: (json['price'] as num).toDouble(),
      costPrice: (json['costPrice'] as num?)?.toDouble(),
      stockQty: (json['stockQty'] as num).toDouble(),
      minQty: (json['minQty'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      imageThumbnail: json['imageThumbnail'] as String?,
      imageMedium: json['imageMedium'] as String?,
      imageLarge: json['imageLarge'] as String?,
      imageHash: json['imageHash'] as String?,
      categoryId: json['categoryId'] as String?,
      isActive: json['isActive'] as bool,
      trackInventory: json['trackInventory'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storeId': instance.storeId,
      'name': instance.name,
      'sku': instance.sku,
      'barcode': instance.barcode,
      'price': instance.price,
      'costPrice': instance.costPrice,
      'stockQty': instance.stockQty,
      'minQty': instance.minQty,
      'unit': instance.unit,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'imageThumbnail': instance.imageThumbnail,
      'imageMedium': instance.imageMedium,
      'imageLarge': instance.imageLarge,
      'imageHash': instance.imageHash,
      'categoryId': instance.categoryId,
      'isActive': instance.isActive,
      'trackInventory': instance.trackInventory,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
