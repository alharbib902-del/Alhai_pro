import '../../dto/addresses/address_response.dart';
import '../../models/enums/delivery_status.dart';

/// Remote data source contract for delivery API calls
abstract class DeliveryRemoteDataSource {
  /// Gets deliveries assigned to current driver
  Future<List<DeliveryResponse>> getMyDeliveries();

  /// Gets a specific delivery by ID
  Future<DeliveryResponse> getDelivery(String id);

  /// Gets delivery by order ID
  Future<DeliveryResponse?> getDeliveryByOrderId(String orderId);

  /// Updates delivery status
  Future<DeliveryResponse> updateStatus(String id, DeliveryStatus status);

  /// Updates driver location
  Future<void> updateLocation({
    required String deliveryId,
    required double lat,
    required double lng,
  });

  /// Accepts a delivery
  Future<DeliveryResponse> acceptDelivery(String id);

  /// Rejects a delivery
  Future<void> rejectDelivery(String id, {String? reason});

  /// Marks delivery as picked up
  Future<DeliveryResponse> markPickedUp(String id);

  /// Marks delivery as delivered
  Future<DeliveryResponse> markDelivered(String id, {String? notes});

  /// Reports delivery issue
  Future<void> reportIssue(String id, String issue);
}

/// DTO for delivery response from API
class DeliveryResponse {
  final String id;
  final String orderId;
  final String driverId;
  final String status;
  final AddressResponse pickupAddress;
  final AddressResponse deliveryAddress;
  final String? driverName;
  final String? driverPhone;
  final double? driverLat;
  final double? driverLng;
  final String? estimatedArrival;
  final String? pickedUpAt;
  final String? deliveredAt;
  final String? notes;
  final String createdAt;

  DeliveryResponse({
    required this.id,
    required this.orderId,
    required this.driverId,
    required this.status,
    required this.pickupAddress,
    required this.deliveryAddress,
    this.driverName,
    this.driverPhone,
    this.driverLat,
    this.driverLng,
    this.estimatedArrival,
    this.pickedUpAt,
    this.deliveredAt,
    this.notes,
    required this.createdAt,
  });
}
