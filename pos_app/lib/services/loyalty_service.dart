/// Loyalty Service - خدمة نظام الولاء والنقاط
///
/// يوفر:
/// - اكتساب النقاط من المشتريات
/// - استبدال النقاط بخصومات
/// - إدارة مستويات العملاء
/// - المكافآت والعروض
library loyalty_service;

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import '../data/local/app_database.dart';
import '../data/local/daos/loyalty_dao.dart';

/// إعدادات نظام الولاء
class LoyaltyConfig {
  /// نقاط لكل ريال
  final double pointsPerRiyal;

  /// الحد الأدنى للشراء لاكتساب النقاط
  final double minPurchaseForPoints;

  /// قيمة النقطة بالريال (للاستبدال)
  final double pointValueInRiyal;

  /// الحد الأدنى للاستبدال
  final int minRedeemPoints;

  /// حدود المستويات
  final int silverThreshold;
  final int goldThreshold;
  final int platinumThreshold;

  /// مضاعفات المستويات
  final double silverMultiplier;
  final double goldMultiplier;
  final double platinumMultiplier;

  const LoyaltyConfig({
    this.pointsPerRiyal = 1.5,
    this.minPurchaseForPoints = 10.0,
    this.pointValueInRiyal = 0.1,
    this.minRedeemPoints = 100,
    this.silverThreshold = 1000,
    this.goldThreshold = 5000,
    this.platinumThreshold = 10000,
    this.silverMultiplier = 1.25,
    this.goldMultiplier = 1.5,
    this.platinumMultiplier = 2.0,
  });

  /// الإعدادات الافتراضية
  static const defaultConfig = LoyaltyConfig();
}

/// مستوى العميل
enum CustomerTier {
  bronze,
  silver,
  gold,
  platinum;

  String get arabicName {
    switch (this) {
      case CustomerTier.bronze:
        return 'برونزي';
      case CustomerTier.silver:
        return 'فضي';
      case CustomerTier.gold:
        return 'ذهبي';
      case CustomerTier.platinum:
        return 'بلاتيني';
    }
  }

  String get emoji {
    switch (this) {
      case CustomerTier.bronze:
        return '🥉';
      case CustomerTier.silver:
        return '🥈';
      case CustomerTier.gold:
        return '🥇';
      case CustomerTier.platinum:
        return '💎';
    }
  }

  static CustomerTier fromString(String value) {
    return CustomerTier.values.firstWhere(
      (t) => t.name == value,
      orElse: () => CustomerTier.bronze,
    );
  }
}

/// نوع معاملة النقاط
enum LoyaltyTransactionType {
  earn,
  redeem,
  expire,
  adjust;

  String get arabicName {
    switch (this) {
      case LoyaltyTransactionType.earn:
        return 'اكتساب';
      case LoyaltyTransactionType.redeem:
        return 'استبدال';
      case LoyaltyTransactionType.expire:
        return 'انتهاء صلاحية';
      case LoyaltyTransactionType.adjust:
        return 'تعديل';
    }
  }
}

/// نتيجة اكتساب النقاط
class EarnPointsResult {
  final bool success;
  final int pointsEarned;
  final int newBalance;
  final CustomerTier tier;
  final String? message;
  final bool tierUpgrade;

  const EarnPointsResult({
    required this.success,
    required this.pointsEarned,
    required this.newBalance,
    required this.tier,
    this.message,
    this.tierUpgrade = false,
  });
}

/// نتيجة استبدال النقاط
class RedeemPointsResult {
  final bool success;
  final int pointsRedeemed;
  final double discountAmount;
  final int remainingPoints;
  final String? message;
  final String? rewardName;

  const RedeemPointsResult({
    required this.success,
    this.pointsRedeemed = 0,
    this.discountAmount = 0,
    this.remainingPoints = 0,
    this.message,
    this.rewardName,
  });

  factory RedeemPointsResult.failed(String message) {
    return RedeemPointsResult(success: false, message: message);
  }
}

/// معلومات ولاء العميل
class CustomerLoyaltyInfo {
  final String customerId;
  final int currentPoints;
  final int totalEarned;
  final int totalRedeemed;
  final CustomerTier tier;
  final int pointsToNextTier;
  final double multiplier;

  const CustomerLoyaltyInfo({
    required this.customerId,
    required this.currentPoints,
    required this.totalEarned,
    required this.totalRedeemed,
    required this.tier,
    required this.pointsToNextTier,
    required this.multiplier,
  });

  /// القيمة بالريال
  double get valueInRiyal => currentPoints * LoyaltyConfig.defaultConfig.pointValueInRiyal;
}

/// خدمة الولاء
class LoyaltyService {
  final LoyaltyDao _dao;
  final LoyaltyConfig config;
  final _uuid = const Uuid();

  LoyaltyService(this._dao, {this.config = LoyaltyConfig.defaultConfig});

  // ============================================================================
  // CUSTOMER LOYALTY
  // ============================================================================

  /// الحصول على معلومات ولاء العميل
  Future<CustomerLoyaltyInfo?> getCustomerInfo(String customerId, String storeId) async {
    final loyalty = await _dao.getCustomerLoyalty(customerId, storeId);
    if (loyalty == null) return null;

    final tier = CustomerTier.fromString(loyalty.tierLevel);
    final multiplier = _getMultiplier(tier);
    final pointsToNext = _pointsToNextTier(loyalty.totalEarned, tier);

    return CustomerLoyaltyInfo(
      customerId: customerId,
      currentPoints: loyalty.currentPoints,
      totalEarned: loyalty.totalEarned,
      totalRedeemed: loyalty.totalRedeemed,
      tier: tier,
      pointsToNextTier: pointsToNext,
      multiplier: multiplier,
    );
  }

  /// إنشاء حساب ولاء للعميل
  Future<CustomerLoyaltyInfo> createLoyaltyAccount(String customerId, String storeId) async {
    final existing = await _dao.getCustomerLoyalty(customerId, storeId);
    if (existing != null) {
      return (await getCustomerInfo(customerId, storeId))!;
    }

    final id = _uuid.v4();
    await _dao.createLoyalty(LoyaltyPointsTableCompanion.insert(
      id: id,
      customerId: customerId,
      storeId: storeId,
    ));

    return CustomerLoyaltyInfo(
      customerId: customerId,
      currentPoints: 0,
      totalEarned: 0,
      totalRedeemed: 0,
      tier: CustomerTier.bronze,
      pointsToNextTier: config.silverThreshold,
      multiplier: 1.0,
    );
  }

  // ============================================================================
  // EARN POINTS
  // ============================================================================

  /// اكتساب نقاط من عملية شراء
  Future<EarnPointsResult> earnPoints({
    required String customerId,
    required String storeId,
    required double purchaseAmount,
    required String saleId,
    String? cashierId,
  }) async {
    // التحقق من الحد الأدنى
    if (purchaseAmount < config.minPurchaseForPoints) {
      return EarnPointsResult(
        success: false,
        pointsEarned: 0,
        newBalance: 0,
        tier: CustomerTier.bronze,
        message: 'المبلغ أقل من الحد الأدنى (${config.minPurchaseForPoints} ريال)',
      );
    }

    // إنشاء حساب إذا لم يكن موجوداً
    var loyalty = await _dao.getCustomerLoyalty(customerId, storeId);
    if (loyalty == null) {
      await createLoyaltyAccount(customerId, storeId);
      loyalty = await _dao.getCustomerLoyalty(customerId, storeId);
    }

    final currentTier = CustomerTier.fromString(loyalty!.tierLevel);
    final multiplier = _getMultiplier(currentTier);

    // حساب النقاط
    final basePoints = (purchaseAmount * config.pointsPerRiyal).round();
    final earnedPoints = (basePoints * multiplier).round();

    // تحديث النقاط
    final newBalance = loyalty.currentPoints + earnedPoints;
    final newTotalEarned = loyalty.totalEarned + earnedPoints;
    final newTier = _calculateTier(newTotalEarned);
    final tierUpgraded = newTier != currentTier;

    await _dao.addPoints(customerId, storeId, earnedPoints);

    // تسجيل المعاملة
    await _dao.logTransaction(LoyaltyTransactionsTableCompanion.insert(
      id: _uuid.v4(),
      loyaltyId: loyalty.id,
      customerId: customerId,
      storeId: storeId,
      transactionType: LoyaltyTransactionType.earn.name,
      points: earnedPoints,
      balanceAfter: newBalance,
      saleId: Value(saleId),
      saleAmount: Value(purchaseAmount),
      description: const Value('اكتساب من عملية بيع'),
      cashierId: Value(cashierId),
    ));

    debugPrint('[LoyaltyService] Customer $customerId earned $earnedPoints points');

    return EarnPointsResult(
      success: true,
      pointsEarned: earnedPoints,
      newBalance: newBalance,
      tier: newTier,
      tierUpgrade: tierUpgraded,
      message: tierUpgraded
        ? 'مبروك! تمت ترقيتك إلى المستوى ${newTier.arabicName} ${newTier.emoji}'
        : null,
    );
  }

  // ============================================================================
  // REDEEM POINTS
  // ============================================================================

  /// استبدال نقاط بخصم
  Future<RedeemPointsResult> redeemPoints({
    required String customerId,
    required String storeId,
    required int points,
    String? saleId,
    String? cashierId,
  }) async {
    // التحقق من الحد الأدنى
    if (points < config.minRedeemPoints) {
      return RedeemPointsResult.failed(
        'الحد الأدنى للاستبدال ${config.minRedeemPoints} نقطة',
      );
    }

    final loyalty = await _dao.getCustomerLoyalty(customerId, storeId);
    if (loyalty == null) {
      return RedeemPointsResult.failed('لا يوجد حساب ولاء لهذا العميل');
    }

    if (loyalty.currentPoints < points) {
      return RedeemPointsResult.failed(
        'رصيدك الحالي ${loyalty.currentPoints} نقطة فقط',
      );
    }

    // حساب الخصم
    final discountAmount = points * config.pointValueInRiyal;
    final newBalance = loyalty.currentPoints - points;

    // خصم النقاط
    final success = await _dao.redeemPoints(customerId, storeId, points);
    if (!success) {
      return RedeemPointsResult.failed('حدث خطأ أثناء الاستبدال');
    }

    // تسجيل المعاملة
    await _dao.logTransaction(LoyaltyTransactionsTableCompanion.insert(
      id: _uuid.v4(),
      loyaltyId: loyalty.id,
      customerId: customerId,
      storeId: storeId,
      transactionType: LoyaltyTransactionType.redeem.name,
      points: -points,
      balanceAfter: newBalance,
      saleId: Value(saleId),
      saleAmount: Value(discountAmount),
      description: const Value('استبدال نقاط بخصم'),
      cashierId: Value(cashierId),
    ));

    debugPrint('[LoyaltyService] Customer $customerId redeemed $points points for $discountAmount SAR');

    return RedeemPointsResult(
      success: true,
      pointsRedeemed: points,
      discountAmount: discountAmount,
      remainingPoints: newBalance,
      message: 'تم استبدال $points نقطة بخصم ${discountAmount.toStringAsFixed(2)} ريال',
    );
  }

  /// استبدال مكافأة محددة
  Future<RedeemPointsResult> redeemReward({
    required String customerId,
    required String storeId,
    required String rewardId,
    required double purchaseAmount,
    String? saleId,
    String? cashierId,
  }) async {
    final reward = await _dao.getRewardById(rewardId);
    if (reward == null) {
      return RedeemPointsResult.failed('المكافأة غير موجودة');
    }

    if (!reward.isActive) {
      return RedeemPointsResult.failed('المكافأة غير نشطة');
    }

    if (reward.expiresAt != null && reward.expiresAt!.isBefore(DateTime.now())) {
      return RedeemPointsResult.failed('انتهت صلاحية المكافأة');
    }

    if (purchaseAmount < reward.minPurchase) {
      return RedeemPointsResult.failed(
        'الحد الأدنى للشراء ${reward.minPurchase} ريال',
      );
    }

    final loyalty = await _dao.getCustomerLoyalty(customerId, storeId);
    if (loyalty == null) {
      return RedeemPointsResult.failed('لا يوجد حساب ولاء');
    }

    // التحقق من المستوى المطلوب
    if (reward.requiredTier != 'all') {
      final requiredTier = CustomerTier.fromString(reward.requiredTier);
      final customerTier = CustomerTier.fromString(loyalty.tierLevel);
      if (customerTier.index < requiredTier.index) {
        return RedeemPointsResult.failed(
          'هذه المكافأة متاحة للمستوى ${requiredTier.arabicName} وأعلى',
        );
      }
    }

    if (loyalty.currentPoints < reward.pointsRequired) {
      return RedeemPointsResult.failed(
        'تحتاج ${reward.pointsRequired} نقطة، رصيدك ${loyalty.currentPoints}',
      );
    }

    // حساب الخصم حسب نوع المكافأة
    double discountAmount;
    switch (reward.rewardType) {
      case 'discount_percentage':
        discountAmount = purchaseAmount * (reward.rewardValue / 100);
        break;
      case 'discount_fixed':
        discountAmount = reward.rewardValue;
        break;
      default:
        discountAmount = reward.rewardValue;
    }

    final newBalance = loyalty.currentPoints - reward.pointsRequired;

    // خصم النقاط
    await _dao.redeemPoints(customerId, storeId, reward.pointsRequired);

    // تسجيل المعاملة
    await _dao.logTransaction(LoyaltyTransactionsTableCompanion.insert(
      id: _uuid.v4(),
      loyaltyId: loyalty.id,
      customerId: customerId,
      storeId: storeId,
      transactionType: LoyaltyTransactionType.redeem.name,
      points: -reward.pointsRequired,
      balanceAfter: newBalance,
      saleId: Value(saleId),
      saleAmount: Value(discountAmount),
      description: Value('استبدال مكافأة: ${reward.name}'),
      cashierId: Value(cashierId),
    ));

    return RedeemPointsResult(
      success: true,
      pointsRedeemed: reward.pointsRequired,
      discountAmount: discountAmount,
      remainingPoints: newBalance,
      rewardName: reward.name,
      message: 'تم تطبيق ${reward.name}',
    );
  }

  // ============================================================================
  // REWARDS
  // ============================================================================

  /// الحصول على المكافآت المتاحة للعميل
  Future<List<LoyaltyRewardsTableData>> getAvailableRewards(
    String customerId,
    String storeId,
  ) async {
    final loyalty = await _dao.getCustomerLoyalty(customerId, storeId);
    return _dao.getAvailableRewards(
      storeId,
      customerPoints: loyalty?.currentPoints,
      customerTier: loyalty?.tierLevel,
    );
  }

  // ============================================================================
  // STATS & REPORTS
  // ============================================================================

  /// إحصائيات نظام الولاء
  Future<LoyaltyStats> getStats(String storeId, {DateTime? startDate, DateTime? endDate}) {
    return _dao.getStats(storeId, startDate: startDate, endDate: endDate);
  }

  /// أفضل العملاء
  Future<List<LoyaltyPointsTableData>> getTopCustomers(String storeId, {int limit = 10}) {
    return _dao.getTopCustomers(storeId, limit: limit);
  }

  /// سجل معاملات العميل
  Future<List<LoyaltyTransactionsTableData>> getCustomerHistory(
    String customerId,
    String storeId, {
    int limit = 50,
  }) {
    return _dao.getCustomerTransactions(customerId, storeId, limit: limit);
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  double _getMultiplier(CustomerTier tier) {
    switch (tier) {
      case CustomerTier.platinum:
        return config.platinumMultiplier;
      case CustomerTier.gold:
        return config.goldMultiplier;
      case CustomerTier.silver:
        return config.silverMultiplier;
      case CustomerTier.bronze:
        return 1.0;
    }
  }

  CustomerTier _calculateTier(int totalPoints) {
    if (totalPoints >= config.platinumThreshold) return CustomerTier.platinum;
    if (totalPoints >= config.goldThreshold) return CustomerTier.gold;
    if (totalPoints >= config.silverThreshold) return CustomerTier.silver;
    return CustomerTier.bronze;
  }

  int _pointsToNextTier(int currentTotal, CustomerTier currentTier) {
    switch (currentTier) {
      case CustomerTier.bronze:
        return config.silverThreshold - currentTotal;
      case CustomerTier.silver:
        return config.goldThreshold - currentTotal;
      case CustomerTier.gold:
        return config.platinumThreshold - currentTotal;
      case CustomerTier.platinum:
        return 0; // أعلى مستوى
    }
  }

  /// حساب النقاط المتوقعة لمبلغ معين
  int calculateExpectedPoints(double amount, CustomerTier tier) {
    if (amount < config.minPurchaseForPoints) return 0;
    final basePoints = (amount * config.pointsPerRiyal).round();
    return (basePoints * _getMultiplier(tier)).round();
  }

  /// حساب الخصم المتاح للنقاط
  double calculateDiscountValue(int points) {
    return points * config.pointValueInRiyal;
  }
}
