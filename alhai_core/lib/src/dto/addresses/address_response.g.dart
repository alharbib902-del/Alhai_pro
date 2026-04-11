// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AddressResponseImpl _$$AddressResponseImplFromJson(
  Map<String, dynamic> json,
) => _$AddressResponseImpl(
  id: json['id'] as String,
  label: json['label'] as String,
  fullAddress: json['full_address'] as String,
  city: json['city'] as String,
  district: json['district'] as String?,
  street: json['street'] as String?,
  buildingNumber: json['building_number'] as String?,
  apartmentNumber: json['apartment_number'] as String?,
  landmark: json['landmark'] as String?,
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  isDefault: json['is_default'] as bool? ?? false,
);

Map<String, dynamic> _$$AddressResponseImplToJson(
  _$AddressResponseImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'full_address': instance.fullAddress,
  'city': instance.city,
  'district': instance.district,
  'street': instance.street,
  'building_number': instance.buildingNumber,
  'apartment_number': instance.apartmentNumber,
  'landmark': instance.landmark,
  'lat': instance.lat,
  'lng': instance.lng,
  'is_default': instance.isDefault,
};
