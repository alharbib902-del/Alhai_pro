// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeliveryImpl _$$DeliveryImplFromJson(Map<String, dynamic> json) =>
    _$DeliveryImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      driverId: json['driverId'] as String,
      status: $enumDecode(_$DeliveryStatusEnumMap, json['status']),
      pickupAddress: Address.fromJson(
        json['pickupAddress'] as Map<String, dynamic>,
      ),
      deliveryAddress: Address.fromJson(
        json['deliveryAddress'] as Map<String, dynamic>,
      ),
      driverName: json['driverName'] as String?,
      driverPhone: json['driverPhone'] as String?,
      driverLat: (json['driverLat'] as num?)?.toDouble(),
      driverLng: (json['driverLng'] as num?)?.toDouble(),
      estimatedArrival: json['estimatedArrival'] == null
          ? null
          : DateTime.parse(json['estimatedArrival'] as String),
      pickedUpAt: json['pickedUpAt'] == null
          ? null
          : DateTime.parse(json['pickedUpAt'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$DeliveryImplToJson(_$DeliveryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'driverId': instance.driverId,
      'status': _$DeliveryStatusEnumMap[instance.status]!,
      'pickupAddress': instance.pickupAddress,
      'deliveryAddress': instance.deliveryAddress,
      'driverName': instance.driverName,
      'driverPhone': instance.driverPhone,
      'driverLat': instance.driverLat,
      'driverLng': instance.driverLng,
      'estimatedArrival': instance.estimatedArrival?.toIso8601String(),
      'pickedUpAt': instance.pickedUpAt?.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$DeliveryStatusEnumMap = {
  DeliveryStatus.assigned: 'assigned',
  DeliveryStatus.accepted: 'accepted',
  DeliveryStatus.headingToPickup: 'headingToPickup',
  DeliveryStatus.arrivedAtPickup: 'arrivedAtPickup',
  DeliveryStatus.pickedUp: 'pickedUp',
  DeliveryStatus.headingToCustomer: 'headingToCustomer',
  DeliveryStatus.arrivedAtCustomer: 'arrivedAtCustomer',
  DeliveryStatus.delivered: 'delivered',
  DeliveryStatus.failed: 'failed',
  DeliveryStatus.cancelled: 'cancelled',
};
