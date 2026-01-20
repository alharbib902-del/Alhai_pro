import 'package:freezed_annotation/freezed_annotation.dart';

part 'wholesale_order.freezed.dart';
part 'wholesale_order.g.dart';

/// Wholesale order status enum (v2.6.0)
enum WholesaleOrderStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('CONFIRMED')
  confirmed,
  @JsonValue('PROCESSING')
  processing,
  @JsonValue('SHIPPED')
  shipped,
  @JsonValue('DELIVERED')
  delivered,
  @JsonValue('CANCELLED')
  cancelled,
}

/// Extension for WholesaleOrderStatus
extension WholesaleOrderStatusExt on WholesaleOrderStatus {
  String get displayNameAr {
    switch (this) {
      case WholesaleOrderStatus.pending:
        return 'قيد الانتظار';
      case WholesaleOrderStatus.confirmed:
        return 'مؤكد';
      case WholesaleOrderStatus.processing:
        return 'قيد التجهيز';
      case WholesaleOrderStatus.shipped:
        return 'في الطريق';
      case WholesaleOrderStatus.delivered:
        return 'تم التوصيل';
      case WholesaleOrderStatus.cancelled:
        return 'ملغي';
    }
  }

  bool get isActive =>
      this != WholesaleOrderStatus.delivered &&
      this != WholesaleOrderStatus.cancelled;
}

/// Wholesale payment method enum
enum WholesalePaymentMethod {
  @JsonValue('CASH')
  cash,
  @JsonValue('BANK_TRANSFER')
  bankTransfer,
  @JsonValue('CREDIT')
  credit,
  @JsonValue('CHECK')
  check,
  @JsonValue('APP')
  app,
}

/// Extension for WholesalePaymentMethod
extension WholesalePaymentMethodExt on WholesalePaymentMethod {
  String get displayNameAr {
    switch (this) {
      case WholesalePaymentMethod.cash:
        return 'نقداً';
      case WholesalePaymentMethod.bankTransfer:
        return 'تحويل بنكي';
      case WholesalePaymentMethod.credit:
        return 'آجل';
      case WholesalePaymentMethod.check:
        return 'شيك';
      case WholesalePaymentMethod.app:
        return 'تطبيق';
    }
  }
}

/// WholesaleOrder domain model (v2.6.0)
/// B2B order from store to distributor
/// Referenced by: distributor_portal, admin_pos
@freezed
class WholesaleOrder with _$WholesaleOrder {
  const WholesaleOrder._();

  const factory WholesaleOrder({
    required String id,
    required String orderNumber,
    required String distributorId,
    required String storeId,
    required String storeName,
    required WholesaleOrderStatus status,
    required WholesalePaymentMethod paymentMethod,
    required List<WholesaleOrderItem> items,
    required double subtotal,
    @Default(0.0) double discount,
    @Default(0.0) double tax,
    required double total,
    String? notes,
    String? deliveryAddress,
    DateTime? expectedDeliveryDate,
    DateTime? confirmedAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _WholesaleOrder;

  factory WholesaleOrder.fromJson(Map<String, dynamic> json) =>
      _$WholesaleOrderFromJson(json);

  /// Total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Check if can cancel
  bool get canCancel =>
      status == WholesaleOrderStatus.pending ||
      status == WholesaleOrderStatus.confirmed;

  /// Check if is completed
  bool get isCompleted => status == WholesaleOrderStatus.delivered;
}

/// WholesaleOrderItem model
@freezed
class WholesaleOrderItem with _$WholesaleOrderItem {
  const WholesaleOrderItem._();

  const factory WholesaleOrderItem({
    required String productId,
    required String productName,
    String? productSku,
    required int quantity,
    required double unitPrice,
    required double totalPrice,
    double? discount,
    String? unit,
  }) = _WholesaleOrderItem;

  factory WholesaleOrderItem.fromJson(Map<String, dynamic> json) =>
      _$WholesaleOrderItemFromJson(json);
}
