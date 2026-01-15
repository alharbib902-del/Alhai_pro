import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_adjustment.freezed.dart';
part 'stock_adjustment.g.dart';

/// Stock adjustment type
enum AdjustmentType {
  /// Stock received from supplier
  received,
  /// Stock returned to supplier
  returned,
  /// Damaged/expired stock
  damaged,
  /// Manual correction
  correction,
  /// Stock transfer out
  transferOut,
  /// Stock transfer in
  transferIn,
  /// Sold (via POS)
  sold,
}

/// Extension for AdjustmentType
extension AdjustmentTypeExt on AdjustmentType {
  String get displayNameAr {
    switch (this) {
      case AdjustmentType.received:
        return 'استلام';
      case AdjustmentType.returned:
        return 'إرجاع';
      case AdjustmentType.damaged:
        return 'تالف';
      case AdjustmentType.correction:
        return 'تعديل';
      case AdjustmentType.transferOut:
        return 'تحويل صادر';
      case AdjustmentType.transferIn:
        return 'تحويل وارد';
      case AdjustmentType.sold:
        return 'مباع';
    }
  }

  /// Whether this type increases stock
  bool get isAddition => this == AdjustmentType.received ||
      this == AdjustmentType.transferIn ||
      this == AdjustmentType.correction;
}

/// Stock adjustment domain model
@freezed
class StockAdjustment with _$StockAdjustment {
  const factory StockAdjustment({
    required String id,
    required String productId,
    required String storeId,
    required AdjustmentType type,
    required int quantity,
    required int previousQty,
    required int newQty,
    String? reason,
    String? referenceId,
    String? createdBy,
    required DateTime createdAt,
  }) = _StockAdjustment;

  factory StockAdjustment.fromJson(Map<String, dynamic> json) =>
      _$StockAdjustmentFromJson(json);
}
