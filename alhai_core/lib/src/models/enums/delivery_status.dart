/// Delivery status enum for tracking deliveries
enum DeliveryStatus {
  /// Order assigned to driver
  assigned,

  /// Driver accepted the order
  accepted,

  /// Driver heading to pickup
  headingToPickup,

  /// Driver arrived at store
  arrivedAtPickup,

  /// Driver picked up the order
  pickedUp,

  /// Driver heading to customer
  headingToCustomer,

  /// Driver arrived at customer location
  arrivedAtCustomer,

  /// Order delivered
  delivered,

  /// Delivery failed
  failed,

  /// Delivery cancelled
  cancelled,
}

/// Extension for DeliveryStatus API parsing
extension DeliveryStatusX on DeliveryStatus {
  /// Convert to API string
  String toApi() => name;

  /// Parse from API string
  static DeliveryStatus fromApi(String value) {
    return DeliveryStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DeliveryStatus.assigned,
    );
  }

  /// Get display name in Arabic
  String get displayNameAr {
    switch (this) {
      case DeliveryStatus.assigned:
        return 'تم التعيين';
      case DeliveryStatus.accepted:
        return 'تم القبول';
      case DeliveryStatus.headingToPickup:
        return 'في الطريق للاستلام';
      case DeliveryStatus.arrivedAtPickup:
        return 'وصل للمتجر';
      case DeliveryStatus.pickedUp:
        return 'تم الاستلام';
      case DeliveryStatus.headingToCustomer:
        return 'في الطريق للتوصيل';
      case DeliveryStatus.arrivedAtCustomer:
        return 'وصل للعميل';
      case DeliveryStatus.delivered:
        return 'تم التوصيل';
      case DeliveryStatus.failed:
        return 'فشل التوصيل';
      case DeliveryStatus.cancelled:
        return 'ملغي';
    }
  }
}
