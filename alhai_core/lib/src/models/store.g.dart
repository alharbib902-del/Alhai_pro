// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoreImpl _$$StoreImplFromJson(Map<String, dynamic> json) => _$StoreImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      logoUrl: json['logoUrl'] as String?,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool,
      ownerId: json['ownerId'] as String,
      deliveryRadius: (json['deliveryRadius'] as num?)?.toDouble(),
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble(),
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
      acceptsDelivery: json['acceptsDelivery'] as bool? ?? true,
      acceptsPickup: json['acceptsPickup'] as bool? ?? true,
      workingHours: json['workingHours'] == null
          ? null
          : WorkingHours.fromJson(json['workingHours'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$StoreImplToJson(_$StoreImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'phone': instance.phone,
      'email': instance.email,
      'lat': instance.lat,
      'lng': instance.lng,
      'imageUrl': instance.imageUrl,
      'logoUrl': instance.logoUrl,
      'description': instance.description,
      'isActive': instance.isActive,
      'ownerId': instance.ownerId,
      'deliveryRadius': instance.deliveryRadius,
      'minOrderAmount': instance.minOrderAmount,
      'deliveryFee': instance.deliveryFee,
      'acceptsDelivery': instance.acceptsDelivery,
      'acceptsPickup': instance.acceptsPickup,
      'workingHours': instance.workingHours,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$WorkingHoursImpl _$$WorkingHoursImplFromJson(Map<String, dynamic> json) =>
    _$WorkingHoursImpl(
      monday: json['monday'] == null
          ? null
          : DayHours.fromJson(json['monday'] as Map<String, dynamic>),
      tuesday: json['tuesday'] == null
          ? null
          : DayHours.fromJson(json['tuesday'] as Map<String, dynamic>),
      wednesday: json['wednesday'] == null
          ? null
          : DayHours.fromJson(json['wednesday'] as Map<String, dynamic>),
      thursday: json['thursday'] == null
          ? null
          : DayHours.fromJson(json['thursday'] as Map<String, dynamic>),
      friday: json['friday'] == null
          ? null
          : DayHours.fromJson(json['friday'] as Map<String, dynamic>),
      saturday: json['saturday'] == null
          ? null
          : DayHours.fromJson(json['saturday'] as Map<String, dynamic>),
      sunday: json['sunday'] == null
          ? null
          : DayHours.fromJson(json['sunday'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$WorkingHoursImplToJson(_$WorkingHoursImpl instance) =>
    <String, dynamic>{
      'monday': instance.monday,
      'tuesday': instance.tuesday,
      'wednesday': instance.wednesday,
      'thursday': instance.thursday,
      'friday': instance.friday,
      'saturday': instance.saturday,
      'sunday': instance.sunday,
    };

_$DayHoursImpl _$$DayHoursImplFromJson(Map<String, dynamic> json) =>
    _$DayHoursImpl(
      open: json['open'] as String,
      close: json['close'] as String,
      isClosed: json['isClosed'] as bool? ?? false,
    );

Map<String, dynamic> _$$DayHoursImplToJson(_$DayHoursImpl instance) =>
    <String, dynamic>{
      'open': instance.open,
      'close': instance.close,
      'isClosed': instance.isClosed,
    };
