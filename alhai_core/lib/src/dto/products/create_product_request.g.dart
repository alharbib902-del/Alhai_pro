// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_product_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateProductRequestImpl _$$CreateProductRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateProductRequestImpl(
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  storeId: json['store_id'] as String,
  costPrice: (json['cost_price'] as num?)?.toDouble(),
  stockQty: (json['stock_qty'] as num?)?.toInt() ?? 0,
  minQty: (json['min_qty'] as num?)?.toInt() ?? 1,
  unit: json['unit'] as String?,
  description: json['description'] as String?,
  imageUrl: json['image_url'] as String?,
  barcode: json['barcode'] as String?,
  sku: json['sku'] as String?,
  categoryId: json['category_id'] as String?,
  isActive: json['is_active'] as bool? ?? true,
  trackInventory: json['track_inventory'] as bool? ?? true,
);

Map<String, dynamic> _$$CreateProductRequestImplToJson(
  _$CreateProductRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'price': instance.price,
  'store_id': instance.storeId,
  'cost_price': instance.costPrice,
  'stock_qty': instance.stockQty,
  'min_qty': instance.minQty,
  'unit': instance.unit,
  'description': instance.description,
  'image_url': instance.imageUrl,
  'barcode': instance.barcode,
  'sku': instance.sku,
  'category_id': instance.categoryId,
  'is_active': instance.isActive,
  'track_inventory': instance.trackInventory,
};
