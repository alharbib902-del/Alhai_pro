import 'package:freezed_annotation/freezed_annotation.dart';

part 'loyalty_points.freezed.dart';
part 'loyalty_points.g.dart';

/// Loyalty Points model (v3.4)
@freezed
class LoyaltyPoints with _$LoyaltyPoints {
  const LoyaltyPoints._();

  const factory LoyaltyPoints({
    required String id,
    required String customerId,
    @Default(0) int balance,
    @Default(LoyaltyTier.bronze) LoyaltyTier tier,
    @Default(0) int earnedThisMonth,
    @Default(0) int redeemedThisMonth,
    @Default(0) int expiringPoints,
    DateTime? expiryDate,
    @Default(0) int currentStreak, // Days ordering consecutively
    @Default(0) int longestStreak,
    DateTime? lastEarnedAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _LoyaltyPoints;

  factory LoyaltyPoints.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyPointsFromJson(json);

  /// Get points needed for next tier
  int get pointsToNextTier {
    switch (tier) {
      case LoyaltyTier.bronze:
        return 1000 - balance; // Bronze to Silver
      case LoyaltyTier.silver:
        return 5000 - balance; // Silver to Gold
      case LoyaltyTier.gold:
        return 10000 - balance; // Gold to Platinum
      case LoyaltyTier.platinum:
        return 0; // Max tier
    }
  }

  /// Get next tier
  LoyaltyTier? get nextTier {
    switch (tier) {
      case LoyaltyTier.bronze:
        return LoyaltyTier.silver;
      case LoyaltyTier.silver:
        return LoyaltyTier.gold;
      case LoyaltyTier.gold:
        return LoyaltyTier.platinum;
      case LoyaltyTier.platinum:
        return null; // Already max
    }
  }

  /// Calculate tier from points
  static LoyaltyTier calculateTier(int points) {
    if (points >= 10000) return LoyaltyTier.platinum;
    if (points >= 5000) return LoyaltyTier.gold;
    if (points >= 1000) return LoyaltyTier.silver;
    return LoyaltyTier.bronze;
  }
}

/// Loyalty tier enum
enum LoyaltyTier {
  @JsonValue('bronze')
  bronze,
  @JsonValue('silver')
  silver,
  @JsonValue('gold')
  gold,
  @JsonValue('platinum')
  platinum,
}
