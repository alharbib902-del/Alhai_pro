import 'package:freezed_annotation/freezed_annotation.dart';

import 'address.dart';
import 'enums/delivery_status.dart';

part 'delivery.freezed.dart';
part 'delivery.g.dart';

/// Delivery domain model for tracking deliveries
@freezed
class Delivery with _$Delivery {
  const factory Delivery({
    required String id,
    required String orderId,
    required String driverId,
    required DeliveryStatus status,
    required Address pickupAddress,
    required Address deliveryAddress,
    String? driverName,
    String? driverPhone,
    double? driverLat,
    double? driverLng,
    DateTime? estimatedArrival,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
    String? notes,
    required DateTime createdAt,
  }) = _Delivery;

  factory Delivery.fromJson(Map<String, dynamic> json) =>
      _$DeliveryFromJson(json);
}
