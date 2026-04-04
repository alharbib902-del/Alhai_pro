/// Order status throughout its lifecycle (v3.2 - Complete)
enum OrderStatus {
  /// Order just created
  created,

  /// Order confirmed by store
  confirmed,

  /// Order is being prepared
  preparing,

  /// Order ready for pickup/delivery
  ready,

  /// Order out for delivery
  outForDelivery,

  /// Order delivered to customer
  delivered,

  /// Order picked up by customer
  pickedUp,

  /// Order successfully completed
  completed,

  /// Order cancelled
  cancelled,

  /// Order refunded
  refunded,
}

/// Extension for OrderStatus helpers
extension OrderStatusExt on OrderStatus {
  /// Get display name in Arabic
  String get displayNameAr {
    switch (this) {
      case OrderStatus.created:
        return 'جديد';
      case OrderStatus.confirmed:
        return 'مؤكد';
      case OrderStatus.preparing:
        return 'قيد التحضير';
      case OrderStatus.ready:
        return 'جاهز';
      case OrderStatus.outForDelivery:
        return 'في الطريق';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.pickedUp:
        return 'تم الاستلام';
      case OrderStatus.completed:
        return 'مكتمل';
      case OrderStatus.cancelled:
        return 'ملغي';
      case OrderStatus.refunded:
        return 'مسترد';
    }
  }

  /// Check if order is in final state
  bool get isFinal =>
      this == OrderStatus.completed ||
      this == OrderStatus.cancelled ||
      this == OrderStatus.refunded ||
      this == OrderStatus.delivered ||
      this == OrderStatus.pickedUp;

  /// Check if order can be cancelled
  bool get canCancel =>
      this == OrderStatus.created || this == OrderStatus.confirmed;
}
