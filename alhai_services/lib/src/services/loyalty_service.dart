import 'package:alhai_core/alhai_core.dart';

/// خدمة نقاط الولاء والمكافآت
/// تستخدم من: pos_app, customer_app
class LoyaltyService {
  final LoyaltyRepository _loyaltyRepo;

  LoyaltyService(this._loyaltyRepo);

  // ==================== الحساب ====================

  /// الحصول على حساب الولاء للعميل
  Future<LoyaltyAccount?> getAccount(String customerId) async {
    return await _loyaltyRepo.getAccount(customerId);
  }

  /// إنشاء حساب ولاء
  Future<LoyaltyAccount> createAccount(String customerId) async {
    return await _loyaltyRepo.createAccount(customerId);
  }

  /// الحصول على مستوى العميل
  Future<LoyaltyTier> getCustomerTier(String customerId) async {
    return await _loyaltyRepo.getCustomerTier(customerId);
  }

  // ==================== النقاط ====================

  /// إضافة نقاط لعملية شراء
  Future<LoyaltyTransaction> addPoints({
    required String customerId,
    required String orderId,
    required int points,
    String? description,
  }) async {
    return await _loyaltyRepo.addPoints(
      customerId: customerId,
      orderId: orderId,
      points: points,
      description: description,
    );
  }

  /// استبدال النقاط
  Future<LoyaltyTransaction> redeemPoints({
    required String customerId,
    required int points,
    required String orderId,
    String? description,
  }) async {
    return await _loyaltyRepo.redeemPoints(
      customerId: customerId,
      points: points,
      orderId: orderId,
      description: description,
    );
  }

  /// سجل النقاط
  Future<Paginated<LoyaltyTransaction>> getPointsHistory(
    String customerId, {
    int page = 1,
    int limit = 20,
  }) async {
    return await _loyaltyRepo.getPointsHistory(
      customerId,
      page: page,
      limit: limit,
    );
  }

  // ==================== المكافآت ====================

  /// المكافآت المتاحة
  Future<List<LoyaltyReward>> getAvailableRewards(String storeId) async {
    return await _loyaltyRepo.getAvailableRewards(storeId);
  }

  /// استبدال مكافأة
  Future<LoyaltyRedemption> redeemReward({
    required String customerId,
    required String rewardId,
  }) async {
    return await _loyaltyRepo.redeemReward(
      customerId: customerId,
      rewardId: rewardId,
    );
  }

  // ==================== حساب النقاط ====================

  /// حساب النقاط لمبلغ معين
  int calculatePoints(double amount, int pointsPerRial) {
    return (amount * pointsPerRial).floor();
  }
}
