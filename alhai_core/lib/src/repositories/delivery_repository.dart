import '../models/delivery.dart';
import '../models/enums/delivery_status.dart';

/// Repository contract for delivery operations
/// Used by Delivery App and Merchant App
abstract class DeliveryRepository {
  /// Gets deliveries assigned to current driver
  Future<List<Delivery>> getMyDeliveries();

  /// Gets a specific delivery by ID
  Future<Delivery> getDelivery(String id);

  /// Gets deliveries for an order
  Future<Delivery?> getDeliveryByOrderId(String orderId);

  /// Updates delivery status
  Future<Delivery> updateStatus(String id, DeliveryStatus status);

  /// Updates driver location
  Future<void> updateLocation({
    required String deliveryId,
    required double lat,
    required double lng,
  });

  /// Accepts a delivery assignment
  Future<Delivery> acceptDelivery(String id);

  /// Rejects a delivery assignment
  Future<void> rejectDelivery(String id, {String? reason});

  /// Marks delivery as picked up
  Future<Delivery> markPickedUp(String id);

  /// Marks delivery as delivered
  Future<Delivery> markDelivered(String id, {String? notes});

  /// Reports delivery issue
  Future<void> reportIssue(String id, String issue);
}
