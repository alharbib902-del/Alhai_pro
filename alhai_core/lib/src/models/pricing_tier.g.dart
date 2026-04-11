// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricing_tier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PricingTierImpl _$$PricingTierImplFromJson(Map<String, dynamic> json) =>
    _$PricingTierImpl(
      id: json['id'] as String,
      distributorId: json['distributorId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: $enumDecode(_$PricingTierTypeEnumMap, json['type']),
      minQuantity: (json['minQuantity'] as num?)?.toInt(),
      maxQuantity: (json['maxQuantity'] as num?)?.toInt(),
      discountPercent: (json['discountPercent'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      applicableStoreIds: (json['applicableStoreIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      applicableProductIds: (json['applicableProductIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isActive: json['isActive'] as bool? ?? true,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PricingTierImplToJson(_$PricingTierImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'distributorId': instance.distributorId,
      'name': instance.name,
      'description': instance.description,
      'type': _$PricingTierTypeEnumMap[instance.type]!,
      'minQuantity': instance.minQuantity,
      'maxQuantity': instance.maxQuantity,
      'discountPercent': instance.discountPercent,
      'discountAmount': instance.discountAmount,
      'applicableStoreIds': instance.applicableStoreIds,
      'applicableProductIds': instance.applicableProductIds,
      'isActive': instance.isActive,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$PricingTierTypeEnumMap = {
  PricingTierType.quantity: 'QUANTITY',
  PricingTierType.storeType: 'STORE_TYPE',
  PricingTierType.loyalty: 'LOYALTY',
  PricingTierType.special: 'SPECIAL',
};

_$DistributorProductImpl _$$DistributorProductImplFromJson(
  Map<String, dynamic> json,
) => _$DistributorProductImpl(
  id: json['id'] as String,
  distributorId: json['distributorId'] as String,
  productId: json['productId'] as String,
  productName: json['productName'] as String,
  productSku: json['productSku'] as String?,
  barcode: json['barcode'] as String?,
  imageUrl: json['imageUrl'] as String?,
  category: json['category'] as String?,
  wholesalePrice: (json['wholesalePrice'] as num).toDouble(),
  retailPrice: (json['retailPrice'] as num?)?.toDouble(),
  stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
  minOrderQuantity: (json['minOrderQuantity'] as num?)?.toInt(),
  unit: json['unit'] as String?,
  isAvailable: json['isAvailable'] as bool? ?? true,
  pricingTiers: (json['pricingTiers'] as List<dynamic>?)
      ?.map((e) => PricingTier.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$DistributorProductImplToJson(
  _$DistributorProductImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'distributorId': instance.distributorId,
  'productId': instance.productId,
  'productName': instance.productName,
  'productSku': instance.productSku,
  'barcode': instance.barcode,
  'imageUrl': instance.imageUrl,
  'category': instance.category,
  'wholesalePrice': instance.wholesalePrice,
  'retailPrice': instance.retailPrice,
  'stockQuantity': instance.stockQuantity,
  'minOrderQuantity': instance.minOrderQuantity,
  'unit': instance.unit,
  'isAvailable': instance.isAvailable,
  'pricingTiers': instance.pricingTiers,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
