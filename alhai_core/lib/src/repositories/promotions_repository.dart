import '../models/paginated.dart';
import '../models/promotion.dart';

/// Repository contract for promotion operations (v2.4.0)
abstract class PromotionsRepository {
  /// Gets all promotions for a store
  Future<Paginated<Promotion>> getPromotions(
    String storeId, {
    int page = 1,
    int limit = 20,
    bool? activeOnly,
  });

  /// Gets active promotions for a store (customer-facing)
  Future<List<Promotion>> getActivePromotions(String storeId);

  /// Gets a promotion by ID
  Future<Promotion> getPromotion(String id);

  /// Gets a promotion by code
  Future<Promotion?> getByCode(String storeId, String code);

  /// Validates and applies a promotion code
  Future<Promotion?> validateCode(
    String storeId,
    String code,
    double orderTotal,
  );

  /// Creates a new promotion
  Future<Promotion> createPromotion({
    required String storeId,
    required String name,
    String? code,
    required PromoType type,
    required double value,
    double? minOrderAmount,
    double? maxDiscount,
    int? usageLimit,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Updates an existing promotion
  Future<Promotion> updatePromotion(
    String id, {
    String? name,
    String? code,
    PromoType? type,
    double? value,
    double? minOrderAmount,
    double? maxDiscount,
    int? usageLimit,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  });

  /// Deletes a promotion
  Future<void> deletePromotion(String id);

  /// Increments usage count (called after successful order)
  Future<void> incrementUsage(String promotionId);
}
