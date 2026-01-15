// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AddressImpl _$$AddressImplFromJson(Map<String, dynamic> json) =>
    _$AddressImpl(
      id: json['id'] as String,
      label: json['label'] as String,
      fullAddress: json['fullAddress'] as String,
      city: json['city'] as String,
      district: json['district'] as String?,
      street: json['street'] as String?,
      buildingNumber: json['buildingNumber'] as String?,
      apartmentNumber: json['apartmentNumber'] as String?,
      landmark: json['landmark'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$$AddressImplToJson(_$AddressImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'fullAddress': instance.fullAddress,
      'city': instance.city,
      'district': instance.district,
      'street': instance.street,
      'buildingNumber': instance.buildingNumber,
      'apartmentNumber': instance.apartmentNumber,
      'landmark': instance.landmark,
      'lat': instance.lat,
      'lng': instance.lng,
      'isDefault': instance.isDefault,
    };
