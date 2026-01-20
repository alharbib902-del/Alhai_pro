import 'package:freezed_annotation/freezed_annotation.dart';

part 'pricing_tier.freezed.dart';
part 'pricing_tier.g.dart';

/// Pricing tier type enum (v2.6.0)
enum PricingTierType {
  @JsonValue('QUANTITY')
  quantity,
  @JsonValue('STORE_TYPE')
  storeType,
  @JsonValue('LOYALTY')
  loyalty,
  @JsonValue('SPECIAL')
  special,
}

/// Extension for PricingTierType
extension PricingTierTypeExt on PricingTierType {
  String get displayNameAr {
    switch (this) {
      case PricingTierType.quantity:
        return 'حسب الكمية';
      case PricingTierType.storeType:
        return 'حسب نوع المتجر';
      case PricingTierType.loyalty:
        return 'حسب الولاء';
      case PricingTierType.special:
        return 'سعر خاص';
    }
  }
}

/// PricingTier domain model (v2.6.0)
/// Wholesale pricing tiers for distributors
/// Referenced by: distributor_portal
@freezed
class PricingTier with _$PricingTier {
  const PricingTier._();

  const factory PricingTier({
    required String id,
    required String distributorId,
    required String name,
    String? description,
    required PricingTierType type,
    int? minQuantity,
    int? maxQuantity,
    double? discountPercent,
    double? discountAmount,
    List<String>? applicableStoreIds,
    List<String>? applicableProductIds,
    @Default(true) bool isActive,
    DateTime? startDate,
    DateTime? endDate,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _PricingTier;

  factory PricingTier.fromJson(Map<String, dynamic> json) =>
      _$PricingTierFromJson(json);

  /// Check if tier is currently valid
  bool get isValid {
    final now = DateTime.now();
    if (!isActive) return false;
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  /// Get discount display
  String get discountDisplay {
    if (discountPercent != null && discountPercent! > 0) {
      return '${discountPercent!.toStringAsFixed(0)}%';
    }
    if (discountAmount != null && discountAmount! > 0) {
      return '${discountAmount!.toStringAsFixed(2)} ر.س';
    }
    return '-';
  }

  /// Check if quantity-based
  bool get isQuantityBased => type == PricingTierType.quantity;
}

/// DistributorProduct model
/// Product listing by a distributor
@freezed
class DistributorProduct with _$DistributorProduct {
  const DistributorProduct._();

  const factory DistributorProduct({
    required String id,
    required String distributorId,
    required String productId,
    required String productName,
    String? productSku,
    String? barcode,
    String? imageUrl,
    String? category,
    required double wholesalePrice,
    double? retailPrice,
    @Default(0) int stockQuantity,
    int? minOrderQuantity,
    String? unit,
    @Default(true) bool isAvailable,
    List<PricingTier>? pricingTiers,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _DistributorProduct;

  factory DistributorProduct.fromJson(Map<String, dynamic> json) =>
      _$DistributorProductFromJson(json);

  /// Check if in stock
  bool get inStock => stockQuantity > 0 && isAvailable;

  /// Get margin if retail price available
  double? get margin {
    if (retailPrice == null || retailPrice! <= 0) return null;
    return ((retailPrice! - wholesalePrice) / retailPrice!) * 100;
  }
}
