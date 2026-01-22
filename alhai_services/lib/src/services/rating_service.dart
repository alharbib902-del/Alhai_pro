import 'package:alhai_core/alhai_core.dart';

/// خدمة التقييمات
/// تستخدم من: customer_app, pos_app
class RatingService {
  final RatingsRepository _ratingsRepo;

  RatingService(this._ratingsRepo);

  /// الحصول على تقييمات كيان
  Future<Paginated<Rating>> getRatings(
    RatingEntityType entityType,
    String entityId, {
    int page = 1,
    int limit = 20,
  }) async {
    return await _ratingsRepo.getRatings(
      entityType,
      entityId,
      page: page,
      limit: limit,
    );
  }

  /// الحصول على تقييم بالـ ID
  Future<Rating> getRating(String id) async {
    return await _ratingsRepo.getRating(id);
  }

  /// إضافة تقييم جديد
  Future<Rating> createRating({
    required RatingEntityType entityType,
    required String entityId,
    required String customerId,
    required String orderId,
    required int stars,
    String? comment,
    List<String>? tags,
  }) async {
    return await _ratingsRepo.createRating(
      entityType: entityType,
      entityId: entityId,
      customerId: customerId,
      orderId: orderId,
      stars: stars,
      comment: comment,
      tags: tags,
    );
  }

  /// تحديث تقييم
  Future<Rating> updateRating(
    String id, {
    int? stars,
    String? comment,
  }) async {
    return await _ratingsRepo.updateRating(id, stars: stars, comment: comment);
  }

  /// حذف تقييم
  Future<void> deleteRating(String id) async {
    await _ratingsRepo.deleteRating(id);
  }

  /// ملخص التقييمات
  Future<RatingSummary> getRatingSummary(RatingEntityType entityType, String entityId) async {
    return await _ratingsRepo.getRatingSummary(entityType, entityId);
  }

  /// تقييمات العميل
  Future<List<Rating>> getCustomerRatings(String customerId) async {
    return await _ratingsRepo.getCustomerRatings(customerId);
  }

  // ==================== تقييمات محددة ====================

  /// تقييمات المتجر
  Future<RatingSummary> getStoreRatingSummary(String storeId) async {
    return await getRatingSummary(RatingEntityType.store, storeId);
  }

  /// تقييمات المنتج
  Future<RatingSummary> getProductRatingSummary(String productId) async {
    return await getRatingSummary(RatingEntityType.product, productId);
  }

  /// تقييمات السائق
  Future<RatingSummary> getDriverRatingSummary(String driverId) async {
    return await getRatingSummary(RatingEntityType.driver, driverId);
  }
}
