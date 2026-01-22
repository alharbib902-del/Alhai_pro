import '../models/paginated.dart';
import '../models/loyalty_points.dart' show LoyaltyTier;

/// Repository contract for loyalty program operations (v2.6.0)
/// Manages customer loyalty points and rewards
abstract class LoyaltyRepository {
  /// Gets loyalty account for a customer
  Future<LoyaltyAccount?> getAccount(String customerId);

  /// Creates a loyalty account
  Future<LoyaltyAccount> createAccount(String customerId);

  /// Adds points for a purchase
  Future<LoyaltyTransaction> addPoints({
    required String customerId,
    required String orderId,
    required int points,
    String? description,
  });

  /// Redeems points
  Future<LoyaltyTransaction> redeemPoints({
    required String customerId,
    required int points,
    required String orderId,
    String? description,
  });

  /// Gets points history
  Future<Paginated<LoyaltyTransaction>> getPointsHistory(
    String customerId, {
    int page = 1,
    int limit = 20,
  });

  /// Gets available rewards
  Future<List<LoyaltyReward>> getAvailableRewards(String storeId);

  /// Redeems a reward
  Future<LoyaltyRedemption> redeemReward({
    required String customerId,
    required String rewardId,
  });

  /// Gets customer tier
  Future<LoyaltyTier> getCustomerTier(String customerId);
}

/// Loyalty account
class LoyaltyAccount {
  final String id;
  final String customerId;
  final int currentPoints;
  final int totalPointsEarned;
  final int totalPointsRedeemed;
  final LoyaltyTier tier;
  final DateTime createdAt;
  final DateTime? lastActivityAt;

  const LoyaltyAccount({
    required this.id,
    required this.customerId,
    required this.currentPoints,
    required this.totalPointsEarned,
    required this.totalPointsRedeemed,
    required this.tier,
    required this.createdAt,
    this.lastActivityAt,
  });
}

/// Loyalty transaction
class LoyaltyTransaction {
  final String id;
  final String customerId;
  final LoyaltyTransactionType type;
  final int points;
  final String? orderId;
  final String? description;
  final DateTime createdAt;

  const LoyaltyTransaction({
    required this.id,
    required this.customerId,
    required this.type,
    required this.points,
    this.orderId,
    this.description,
    required this.createdAt,
  });
}

/// Transaction type
enum LoyaltyTransactionType { earned, redeemed, expired, adjusted }

/// Loyalty reward
class LoyaltyReward {
  final String id;
  final String name;
  final String? description;
  final int pointsRequired;
  final RewardType type;
  final double? discountAmount;
  final double? discountPercent;
  final String? productId;
  final bool isActive;

  const LoyaltyReward({
    required this.id,
    required this.name,
    this.description,
    required this.pointsRequired,
    required this.type,
    this.discountAmount,
    this.discountPercent,
    this.productId,
    required this.isActive,
  });
}

/// Reward type
enum RewardType { discount, freeItem, cashback }

/// Loyalty redemption
class LoyaltyRedemption {
  final String id;
  final String customerId;
  final String rewardId;
  final int pointsUsed;
  final DateTime createdAt;

  const LoyaltyRedemption({
    required this.id,
    required this.customerId,
    required this.rewardId,
    required this.pointsUsed,
    required this.createdAt,
  });
}
