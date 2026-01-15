// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoreResponseImpl _$$StoreResponseImplFromJson(Map<String, dynamic> json) =>
    _$StoreResponseImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      logoUrl: json['logo_url'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool,
      ownerId: json['owner_id'] as String,
      deliveryRadius: (json['delivery_radius'] as num?)?.toDouble(),
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble(),
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble(),
      acceptsDelivery: json['accepts_delivery'] as bool? ?? true,
      acceptsPickup: json['accepts_pickup'] as bool? ?? true,
      workingHoursJson: json['working_hours'] as Map<String, dynamic>?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$StoreResponseImplToJson(_$StoreResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'phone': instance.phone,
      'email': instance.email,
      'lat': instance.lat,
      'lng': instance.lng,
      'image_url': instance.imageUrl,
      'logo_url': instance.logoUrl,
      'description': instance.description,
      'is_active': instance.isActive,
      'owner_id': instance.ownerId,
      'delivery_radius': instance.deliveryRadius,
      'min_order_amount': instance.minOrderAmount,
      'delivery_fee': instance.deliveryFee,
      'accepts_delivery': instance.acceptsDelivery,
      'accepts_pickup': instance.acceptsPickup,
      'working_hours': instance.workingHoursJson,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
