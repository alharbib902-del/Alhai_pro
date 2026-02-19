/// Loyalty Providers - مزودات نظام الولاء
///
/// يوفر:
/// - معلومات ولاء العميل المحدد
/// - المكافآت المتاحة
/// - إحصائيات النقاط
/// - تكامل مع POS
library loyalty_providers;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../services/loyalty_service.dart';
import '../data/local/daos/loyalty_dao.dart';
import '../data/local/app_database.dart';
import 'auth_providers.dart';

// ============================================================================
// SERVICE PROVIDER
// ============================================================================

/// مزود خدمة الولاء
final loyaltyServiceProvider = Provider<LoyaltyService>((ref) {
  // يجب تهيئة LoyaltyDao من قاعدة البيانات
  throw UnimplementedError('يجب تهيئة loyaltyServiceProvider في main.dart');
});

/// مزود إعدادات الولاء
final loyaltyConfigProvider = Provider<LoyaltyConfig>((ref) {
  return LoyaltyConfig.defaultConfig;
});

// ============================================================================
// CUSTOMER LOYALTY STATE
// ============================================================================

/// حالة ولاء العميل المحدد
class CustomerLoyaltyState {
  final bool isLoading;
  final CustomerLoyaltyInfo? info;
  final List<LoyaltyRewardsTableData> availableRewards;
  final List<LoyaltyTransactionsTableData> recentTransactions;
  final String? error;

  const CustomerLoyaltyState({
    this.isLoading = false,
    this.info,
    this.availableRewards = const [],
    this.recentTransactions = const [],
    this.error,
  });

  CustomerLoyaltyState copyWith({
    bool? isLoading,
    CustomerLoyaltyInfo? info,
    List<LoyaltyRewardsTableData>? availableRewards,
    List<LoyaltyTransactionsTableData>? recentTransactions,
    String? error,
  }) {
    return CustomerLoyaltyState(
      isLoading: isLoading ?? this.isLoading,
      info: info ?? this.info,
      availableRewards: availableRewards ?? this.availableRewards,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      error: error,
    );
  }

  /// هل لديه نقاط كافية للاستبدال
  bool get canRedeem {
    const config = LoyaltyConfig.defaultConfig;
    return (info?.currentPoints ?? 0) >= config.minRedeemPoints;
  }

  /// قيمة النقاط بالريال
  double get pointsValue => info?.valueInRiyal ?? 0;
}

/// مزود حالة ولاء العميل الحالي
final currentCustomerLoyaltyProvider =
    StateNotifierProvider<CustomerLoyaltyNotifier, CustomerLoyaltyState>((ref) {
  final service = ref.watch(loyaltyServiceProvider);
  return CustomerLoyaltyNotifier(service);
});

/// Notifier لإدارة ولاء العميل
class CustomerLoyaltyNotifier extends StateNotifier<CustomerLoyaltyState> {
  final LoyaltyService _service;
  String? _currentCustomerId;
  String? _currentStoreId;

  CustomerLoyaltyNotifier(this._service) : super(const CustomerLoyaltyState());

  /// تحميل بيانات العميل
  Future<void> loadCustomer(String customerId, String storeId) async {
    _currentCustomerId = customerId;
    _currentStoreId = storeId;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final info = await _service.getCustomerInfo(customerId, storeId);

      if (info == null) {
        // إنشاء حساب جديد
        final newInfo = await _service.createLoyaltyAccount(customerId, storeId);
        state = state.copyWith(
          isLoading: false,
          info: newInfo,
          availableRewards: [],
          recentTransactions: [],
        );
        return;
      }

      // تحميل المكافآت والسجل
      final rewards = await _service.getAvailableRewards(customerId, storeId);
      final transactions = await _service.getCustomerHistory(customerId, storeId, limit: 10);

      state = state.copyWith(
        isLoading: false,
        info: info,
        availableRewards: rewards,
        recentTransactions: transactions,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ في تحميل بيانات الولاء',
      );
      debugPrint('[LoyaltyNotifier] Error: $e');
    }
  }

  /// مسح بيانات العميل
  void clearCustomer() {
    _currentCustomerId = null;
    _currentStoreId = null;
    state = const CustomerLoyaltyState();
  }

  /// اكتساب نقاط من عملية بيع
  Future<EarnPointsResult> earnPoints({
    required double purchaseAmount,
    required String saleId,
    String? cashierId,
  }) async {
    if (_currentCustomerId == null || _currentStoreId == null) {
      return const EarnPointsResult(
        success: false,
        pointsEarned: 0,
        newBalance: 0,
        tier: CustomerTier.bronze,
        message: 'لم يتم تحديد عميل',
      );
    }

    final result = await _service.earnPoints(
      customerId: _currentCustomerId!,
      storeId: _currentStoreId!,
      purchaseAmount: purchaseAmount,
      saleId: saleId,
      cashierId: cashierId,
    );

    if (result.success) {
      // تحديث الحالة
      await loadCustomer(_currentCustomerId!, _currentStoreId!);
    }

    return result;
  }

  /// استبدال نقاط
  Future<RedeemPointsResult> redeemPoints(int points, {String? saleId, String? cashierId}) async {
    if (_currentCustomerId == null || _currentStoreId == null) {
      return RedeemPointsResult.failed('لم يتم تحديد عميل');
    }

    final result = await _service.redeemPoints(
      customerId: _currentCustomerId!,
      storeId: _currentStoreId!,
      points: points,
      saleId: saleId,
      cashierId: cashierId,
    );

    if (result.success) {
      await loadCustomer(_currentCustomerId!, _currentStoreId!);
    }

    return result;
  }

  /// استبدال مكافأة
  Future<RedeemPointsResult> redeemReward({
    required String rewardId,
    required double purchaseAmount,
    String? saleId,
    String? cashierId,
  }) async {
    if (_currentCustomerId == null || _currentStoreId == null) {
      return RedeemPointsResult.failed('لم يتم تحديد عميل');
    }

    final result = await _service.redeemReward(
      customerId: _currentCustomerId!,
      storeId: _currentStoreId!,
      rewardId: rewardId,
      purchaseAmount: purchaseAmount,
      saleId: saleId,
      cashierId: cashierId,
    );

    if (result.success) {
      await loadCustomer(_currentCustomerId!, _currentStoreId!);
    }

    return result;
  }

  /// حساب النقاط المتوقعة
  int calculateExpectedPoints(double amount) {
    final tier = state.info?.tier ?? CustomerTier.bronze;
    return _service.calculateExpectedPoints(amount, tier);
  }
}

// ============================================================================
// LOYALTY STATS PROVIDERS
// ============================================================================

/// مزود إحصائيات الولاء للمتجر
final loyaltyStatsProvider = FutureProvider.family<LoyaltyStats, String>((ref, storeId) async {
  final service = ref.watch(loyaltyServiceProvider);
  return service.getStats(storeId);
});

/// مزود إحصائيات اليوم
final todayLoyaltyStatsProvider = FutureProvider<LoyaltyStats>((ref) async {
  final service = ref.watch(loyaltyServiceProvider);
  final user = ref.watch(currentUserProvider);

  if (user?.storeId == null) {
    return const LoyaltyStats(
      totalEarned: 0,
      totalRedeemed: 0,
      activeCustomers: 0,
      totalTransactions: 0,
    );
  }

  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  return service.getStats(
    user!.storeId!,
    startDate: startOfDay,
    endDate: endOfDay,
  );
});

/// مزود أفضل العملاء
final topCustomersProvider = FutureProvider.family<List<LoyaltyPointsTableData>, String>((ref, storeId) async {
  final service = ref.watch(loyaltyServiceProvider);
  return service.getTopCustomers(storeId, limit: 10);
});

// ============================================================================
// POS INTEGRATION
// ============================================================================

/// حالة خصم الولاء في الفاتورة الحالية
class LoyaltyDiscountState {
  final bool isApplied;
  final int pointsUsed;
  final double discountAmount;
  final String? rewardName;

  const LoyaltyDiscountState({
    this.isApplied = false,
    this.pointsUsed = 0,
    this.discountAmount = 0,
    this.rewardName,
  });

  LoyaltyDiscountState copyWith({
    bool? isApplied,
    int? pointsUsed,
    double? discountAmount,
    String? rewardName,
  }) {
    return LoyaltyDiscountState(
      isApplied: isApplied ?? this.isApplied,
      pointsUsed: pointsUsed ?? this.pointsUsed,
      discountAmount: discountAmount ?? this.discountAmount,
      rewardName: rewardName ?? this.rewardName,
    );
  }

  /// مسح الخصم
  static const empty = LoyaltyDiscountState();
}

/// مزود خصم الولاء للفاتورة الحالية
final loyaltyDiscountProvider = StateProvider<LoyaltyDiscountState>((ref) {
  return const LoyaltyDiscountState();
});

/// مزود لحساب النقاط المتوقعة للفاتورة الحالية
final expectedPointsProvider = Provider<int>((ref) {
  ref.watch(currentCustomerLoyaltyProvider);
  // يجب ربطه مع cart total
  return 0;
});

// ============================================================================
// REWARD SELECTION
// ============================================================================

/// مزود المكافأة المحددة
final selectedRewardProvider = StateProvider<LoyaltyRewardsTableData?>((ref) {
  return null;
});

/// مزود لحساب خصم المكافأة
final rewardDiscountProvider = Provider.family<double, double>((ref, purchaseAmount) {
  final reward = ref.watch(selectedRewardProvider);
  if (reward == null) return 0;

  if (purchaseAmount < reward.minPurchase) return 0;

  switch (reward.rewardType) {
    case 'discount_percentage':
      return purchaseAmount * (reward.rewardValue / 100);
    case 'discount_fixed':
      return reward.rewardValue;
    default:
      return reward.rewardValue;
  }
});
