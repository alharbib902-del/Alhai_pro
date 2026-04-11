import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/loyalty_points.dart' show LoyaltyTier;
import 'package:alhai_core/src/repositories/loyalty_repository.dart';

/// Tests for LoyaltyAccount, LoyaltyTransaction, LoyaltyReward,
/// LoyaltyRedemption, LoyaltyTransactionType, RewardType
/// defined in loyalty_repository.dart.
/// LoyaltyRepository is an abstract interface - no implementation to test yet.
void main() {
  group('LoyaltyAccount', () {
    test('should construct with all required fields', () {
      final account = LoyaltyAccount(
        id: 'acc-1',
        customerId: 'customer-1',
        currentPoints: 500,
        totalPointsEarned: 1000,
        totalPointsRedeemed: 500,
        tier: LoyaltyTier.silver,
        createdAt: DateTime(2026, 1, 15),
      );

      expect(account.id, equals('acc-1'));
      expect(account.customerId, equals('customer-1'));
      expect(account.currentPoints, equals(500));
      expect(account.totalPointsEarned, equals(1000));
      expect(account.totalPointsRedeemed, equals(500));
      expect(account.tier, equals(LoyaltyTier.silver));
      expect(account.lastActivityAt, isNull);
    });
  });

  group('LoyaltyTransaction', () {
    test('should construct earned transaction', () {
      final tx = LoyaltyTransaction(
        id: 'tx-1',
        customerId: 'customer-1',
        type: LoyaltyTransactionType.earned,
        points: 100,
        orderId: 'order-1',
        description: 'Points earned from purchase',
        createdAt: DateTime(2026, 1, 15),
      );

      expect(tx.type, equals(LoyaltyTransactionType.earned));
      expect(tx.points, equals(100));
      expect(tx.orderId, equals('order-1'));
    });

    test('should construct redeemed transaction', () {
      final tx = LoyaltyTransaction(
        id: 'tx-2',
        customerId: 'customer-1',
        type: LoyaltyTransactionType.redeemed,
        points: 50,
        createdAt: DateTime(2026, 1, 15),
      );

      expect(tx.type, equals(LoyaltyTransactionType.redeemed));
      expect(tx.orderId, isNull);
    });
  });

  group('LoyaltyTransactionType', () {
    test('should have all expected values', () {
      expect(LoyaltyTransactionType.values, hasLength(4));
      expect(
        LoyaltyTransactionType.values,
        contains(LoyaltyTransactionType.earned),
      );
      expect(
        LoyaltyTransactionType.values,
        contains(LoyaltyTransactionType.redeemed),
      );
      expect(
        LoyaltyTransactionType.values,
        contains(LoyaltyTransactionType.expired),
      );
      expect(
        LoyaltyTransactionType.values,
        contains(LoyaltyTransactionType.adjusted),
      );
    });
  });

  group('LoyaltyReward', () {
    test('should construct discount reward', () {
      const reward = LoyaltyReward(
        id: 'reward-1',
        name: '10% Off',
        description: 'Get 10% off your next order',
        pointsRequired: 200,
        type: RewardType.discount,
        discountPercent: 10.0,
        isActive: true,
      );

      expect(reward.name, equals('10% Off'));
      expect(reward.type, equals(RewardType.discount));
      expect(reward.discountPercent, equals(10.0));
      expect(reward.pointsRequired, equals(200));
    });

    test('should construct free item reward', () {
      const reward = LoyaltyReward(
        id: 'reward-2',
        name: 'Free Coffee',
        pointsRequired: 500,
        type: RewardType.freeItem,
        productId: 'coffee-1',
        isActive: true,
      );

      expect(reward.type, equals(RewardType.freeItem));
      expect(reward.productId, equals('coffee-1'));
    });

    test('should construct cashback reward', () {
      const reward = LoyaltyReward(
        id: 'reward-3',
        name: 'Cashback 50 SAR',
        pointsRequired: 1000,
        type: RewardType.cashback,
        discountAmount: 50.0,
        isActive: true,
      );

      expect(reward.type, equals(RewardType.cashback));
      expect(reward.discountAmount, equals(50.0));
    });
  });

  group('RewardType', () {
    test('should have all expected values', () {
      expect(RewardType.values, hasLength(3));
      expect(RewardType.values, contains(RewardType.discount));
      expect(RewardType.values, contains(RewardType.freeItem));
      expect(RewardType.values, contains(RewardType.cashback));
    });
  });

  group('LoyaltyRedemption', () {
    test('should construct with all required fields', () {
      final redemption = LoyaltyRedemption(
        id: 'red-1',
        customerId: 'customer-1',
        rewardId: 'reward-1',
        pointsUsed: 200,
        createdAt: DateTime(2026, 1, 15),
      );

      expect(redemption.id, equals('red-1'));
      expect(redemption.customerId, equals('customer-1'));
      expect(redemption.rewardId, equals('reward-1'));
      expect(redemption.pointsUsed, equals(200));
    });
  });
}
