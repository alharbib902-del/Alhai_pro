import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_order.freezed.dart';
part 'purchase_order.g.dart';

/// Purchase order status
enum PurchaseOrderStatus {
  /// Draft order
  draft,
  /// Order sent to supplier
  ordered,
  /// Partially received
  partiallyReceived,
  /// Fully received
  received,
  /// Cancelled
  cancelled,
}

/// Extension for PurchaseOrderStatus
extension PurchaseOrderStatusExt on PurchaseOrderStatus {
  String get displayNameAr {
    switch (this) {
      case PurchaseOrderStatus.draft:
        return 'مسودة';
      case PurchaseOrderStatus.ordered:
        return 'تم الطلب';
      case PurchaseOrderStatus.partiallyReceived:
        return 'استلام جزئي';
      case PurchaseOrderStatus.received:
        return 'تم الاستلام';
      case PurchaseOrderStatus.cancelled:
        return 'ملغي';
    }
  }
}

/// Purchase order domain model
@freezed
class PurchaseOrder with _$PurchaseOrder {
  const PurchaseOrder._();

  const factory PurchaseOrder({
    required String id,
    String? orderNumber,
    required String storeId,
    required String supplierId,
    String? supplierName,
    required PurchaseOrderStatus status,
    required List<PurchaseOrderItem> items,
    required double subtotal,
    @Default(0) double discount,
    @Default(0) double tax,
    required double total,
    @Default(0) double paidAmount,
    String? notes,
    DateTime? expectedDate,
    DateTime? receivedDate,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _PurchaseOrder;

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) =>
      _$PurchaseOrderFromJson(json);

  /// Remaining amount to pay
  double get remainingAmount => total - paidAmount;

  /// Check if fully paid
  bool get isFullyPaid => paidAmount >= total;

  /// Check if can receive
  bool get canReceive =>
      status == PurchaseOrderStatus.ordered ||
      status == PurchaseOrderStatus.partiallyReceived;
}

/// Purchase order item
@freezed
class PurchaseOrderItem with _$PurchaseOrderItem {
  const PurchaseOrderItem._();

  const factory PurchaseOrderItem({
    required String productId,
    required String name,
    required int orderedQty,
    @Default(0) int receivedQty,
    required double unitCost,
    required double lineTotal,
  }) = _PurchaseOrderItem;

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) =>
      _$PurchaseOrderItemFromJson(json);

  /// Remaining quantity to receive
  int get remainingQty => orderedQty - receivedQty;

  /// Check if fully received
  bool get isFullyReceived => receivedQty >= orderedQty;
}
