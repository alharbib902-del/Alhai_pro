// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PromotionImpl _$$PromotionImplFromJson(Map<String, dynamic> json) =>
    _$PromotionImpl(
      id: json['id'] as String,
      storeId: json['storeId'] as String,
      name: json['name'] as String,
      code: json['code'] as String?,
      type: $enumDecode(_$PromoTypeEnumMap, json['type']),
      value: (json['value'] as num).toDouble(),
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble(),
      maxDiscount: (json['maxDiscount'] as num?)?.toDouble(),
      usageLimit: (json['usageLimit'] as num?)?.toInt(),
      usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PromotionImplToJson(_$PromotionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storeId': instance.storeId,
      'name': instance.name,
      'code': instance.code,
      'type': _$PromoTypeEnumMap[instance.type]!,
      'value': instance.value,
      'minOrderAmount': instance.minOrderAmount,
      'maxDiscount': instance.maxDiscount,
      'usageLimit': instance.usageLimit,
      'usageCount': instance.usageCount,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$PromoTypeEnumMap = {
  PromoType.percentage: 'percentage',
  PromoType.fixedAmount: 'fixedAmount',
  PromoType.buyXGetY: 'buyXGetY',
};
