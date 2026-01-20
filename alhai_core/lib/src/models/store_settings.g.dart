// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoreSettingsImpl _$$StoreSettingsImplFromJson(Map<String, dynamic> json) =>
    _$StoreSettingsImpl(
      id: json['id'] as String,
      storeId: json['storeId'] as String,
      receiptHeader: json['receiptHeader'] as String?,
      receiptFooter: json['receiptFooter'] as String?,
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 15.0,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 10,
      enableLoyalty: json['enableLoyalty'] as bool? ?? true,
      loyaltyPointsPerRial:
          (json['loyaltyPointsPerRial'] as num?)?.toInt() ?? 1,
      autoPrintReceipt: json['autoPrintReceipt'] as bool? ?? true,
      currency: json['currency'] as String? ?? 'SAR',
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$StoreSettingsImplToJson(_$StoreSettingsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storeId': instance.storeId,
      'receiptHeader': instance.receiptHeader,
      'receiptFooter': instance.receiptFooter,
      'taxRate': instance.taxRate,
      'lowStockThreshold': instance.lowStockThreshold,
      'enableLoyalty': instance.enableLoyalty,
      'loyaltyPointsPerRial': instance.loyaltyPointsPerRial,
      'autoPrintReceipt': instance.autoPrintReceipt,
      'currency': instance.currency,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
