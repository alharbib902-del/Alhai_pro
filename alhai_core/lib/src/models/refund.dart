import 'package:freezed_annotation/freezed_annotation.dart';

part 'refund.freezed.dart';
part 'refund.g.dart';

/// Refund status enum (v2.5.0)
enum RefundStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('APPROVED')
  approved,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('REJECTED')
  rejected,
}

/// Extension for RefundStatus
extension RefundStatusExt on RefundStatus {
  String get displayNameAr {
    switch (this) {
      case RefundStatus.pending:
        return 'معلق';
      case RefundStatus.approved:
        return 'موافق عليه';
      case RefundStatus.completed:
        return 'مكتمل';
      case RefundStatus.rejected:
        return 'مرفوض';
    }
  }

  bool get isActive =>
      this == RefundStatus.pending || this == RefundStatus.approved;
}

/// Refund reason enum
enum RefundReason {
  @JsonValue('CUSTOMER_REQUEST')
  customerRequest,
  @JsonValue('DEFECTIVE_PRODUCT')
  defectiveProduct,
  @JsonValue('WRONG_ITEM')
  wrongItem,
  @JsonValue('EXPIRED_PRODUCT')
  expiredProduct,
  @JsonValue('PRICE_ERROR')
  priceError,
  @JsonValue('OTHER')
  other,
}

/// Extension for RefundReason
extension RefundReasonExt on RefundReason {
  String get displayNameAr {
    switch (this) {
      case RefundReason.customerRequest:
        return 'طلب العميل';
      case RefundReason.defectiveProduct:
        return 'منتج معيب';
      case RefundReason.wrongItem:
        return 'منتج خاطئ';
      case RefundReason.expiredProduct:
        return 'منتج منتهي';
      case RefundReason.priceError:
        return 'خطأ في السعر';
      case RefundReason.other:
        return 'أخرى';
    }
  }
}

/// Refund method enum
enum RefundMethod {
  @JsonValue('CASH')
  cash,
  @JsonValue('CARD')
  card,
  @JsonValue('CREDIT')
  credit,
}

/// Extension for RefundMethod
extension RefundMethodExt on RefundMethod {
  String get displayNameAr {
    switch (this) {
      case RefundMethod.cash:
        return 'نقداً';
      case RefundMethod.card:
        return 'بطاقة';
      case RefundMethod.credit:
        return 'رصيد';
    }
  }
}

/// Refund domain model (v2.5.0)
/// Tracks refunds and returns
/// Referenced by: US-5.1, US-5.2, US-5.3
@freezed
class Refund with _$Refund {
  const Refund._();

  const factory Refund({
    required String id,
    required String originalSaleId,
    required String storeId,
    required String cashierId,
    String? customerId,
    required RefundStatus status,
    required RefundReason reason,
    required RefundMethod method,
    required double totalAmount,
    required List<RefundItem> items,
    String? notes,
    String? supervisorId,
    required DateTime createdAt,
    DateTime? completedAt,
  }) = _Refund;

  factory Refund.fromJson(Map<String, dynamic> json) => _$RefundFromJson(json);

  /// Check if refund is pending
  bool get isPending => status == RefundStatus.pending;

  /// Check if refund is completed
  bool get isCompleted => status == RefundStatus.completed;

  /// Total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Requires supervisor approval
  bool get requiresSupervisor => totalAmount > 50 || reason == RefundReason.priceError;
}

/// RefundItem domain model
@freezed
class RefundItem with _$RefundItem {
  const RefundItem._();

  const factory RefundItem({
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    required double totalAmount,
    String? reason,
  }) = _RefundItem;

  factory RefundItem.fromJson(Map<String, dynamic> json) =>
      _$RefundItemFromJson(json);
}
