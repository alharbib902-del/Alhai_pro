import 'package:alhai_core/alhai_core.dart';

/// خدمة العروض والترويج
/// متوافقة مع PromotionsRepository من alhai_core
class PromotionService {
  final PromotionsRepository _promotionsRepo;

  PromotionService(this._promotionsRepo);

  /// الحصول على العروض النشطة
  Future<List<Promotion>> getActivePromotions(String storeId) async {
    return await _promotionsRepo.getActivePromotions(storeId);
  }

  /// الحصول على جميع العروض
  Future<Paginated<Promotion>> getPromotions(
    String storeId, {
    bool? activeOnly,
    int page = 1,
    int limit = 20,
  }) async {
    return await _promotionsRepo.getPromotions(
      storeId,
      activeOnly: activeOnly,
      page: page,
      limit: limit,
    );
  }

  /// الحصول على عرض بالـ ID
  Future<Promotion> getPromotion(String id) async {
    return await _promotionsRepo.getPromotion(id);
  }

  /// الحصول على عرض بالكود
  Future<Promotion?> getPromotionByCode(String storeId, String code) async {
    return await _promotionsRepo.getByCode(storeId, code);
  }

  /// إنشاء عرض جديد
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
  }) async {
    return await _promotionsRepo.createPromotion(
      storeId: storeId,
      name: name,
      code: code,
      type: type,
      value: value,
      minOrderAmount: minOrderAmount,
      maxDiscount: maxDiscount,
      usageLimit: usageLimit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// تحديث عرض
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
  }) async {
    return await _promotionsRepo.updatePromotion(
      id,
      name: name,
      code: code,
      type: type,
      value: value,
      minOrderAmount: minOrderAmount,
      maxDiscount: maxDiscount,
      usageLimit: usageLimit,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
    );
  }

  /// حذف عرض
  Future<void> deletePromotion(String id) async {
    await _promotionsRepo.deletePromotion(id);
  }

  /// التحقق من صلاحية كود الخصم
  Future<Promotion?> validatePromoCode(
    String storeId,
    String code,
    double orderTotal,
  ) async {
    return await _promotionsRepo.validateCode(storeId, code, orderTotal);
  }

  /// زيادة عداد الاستخدام
  Future<void> incrementUsage(String promotionId) async {
    await _promotionsRepo.incrementUsage(promotionId);
  }
}
