import 'package:freezed_annotation/freezed_annotation.dart';

part 'promotion.freezed.dart';
part 'promotion.g.dart';

/// Promotion type enum (v2.4.0)
enum PromoType {
  percentage,
  fixedAmount,
  buyXGetY,
}

/// Extension for PromoType
extension PromoTypeExt on PromoType {
  String get displayNameAr {
    switch (this) {
      case PromoType.percentage:
        return 'نسبة مئوية';
      case PromoType.fixedAmount:
        return 'مبلغ ثابت';
      case PromoType.buyXGetY:
        return 'اشتري X واحصل على Y';
    }
  }

  String get dbValue {
    switch (this) {
      case PromoType.percentage:
        return 'percentage';
      case PromoType.fixedAmount:
        return 'fixed_amount';
      case PromoType.buyXGetY:
        return 'buy_x_get_y';
    }
  }

  static PromoType fromDbValue(String value) {
    switch (value) {
      case 'percentage':
        return PromoType.percentage;
      case 'fixed_amount':
        return PromoType.fixedAmount;
      case 'buy_x_get_y':
        return PromoType.buyXGetY;
      default:
        return PromoType.percentage;
    }
  }
}

/// Promotion domain model (v2.4.0)
@freezed
class Promotion with _$Promotion {
  const Promotion._();

  const factory Promotion({
    required String id,
    required String storeId,
    required String name,
    String? code,
    required PromoType type,
    required double value,
    double? minOrderAmount,
    double? maxDiscount,
    int? usageLimit,
    @Default(0) int usageCount,
    required DateTime startDate,
    required DateTime endDate,
    @Default(true) bool isActive,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Promotion;

  factory Promotion.fromJson(Map<String, dynamic> json) =>
      _$PromotionFromJson(json);

  /// Check if promotion is currently valid
  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        (usageLimit == null || usageCount < usageLimit!);
  }

  /// Check if promotion has usage remaining
  bool get hasUsageRemaining => usageLimit == null || usageCount < usageLimit!;

  /// Calculate discount amount for a given order total
  double calculateDiscount(double orderTotal) {
    if (!isValid) return 0;
    if (minOrderAmount != null && orderTotal < minOrderAmount!) return 0;

    double discount;
    switch (type) {
      case PromoType.percentage:
        discount = orderTotal * (value / 100);
        break;
      case PromoType.fixedAmount:
        discount = value;
        break;
      case PromoType.buyXGetY:
        discount = 0; // Complex logic handled elsewhere
        break;
    }

    if (maxDiscount != null && discount > maxDiscount!) {
      discount = maxDiscount!;
    }

    return discount;
  }
}
