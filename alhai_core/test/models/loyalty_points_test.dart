import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/loyalty_points.dart';

void main() {
  group('LoyaltyPoints Model', () {
    LoyaltyPoints createLoyalty({
      String id = 'lp-1',
      int balance = 0,
      LoyaltyTier tier = LoyaltyTier.bronze,
    }) {
      return LoyaltyPoints(
        id: id,
        customerId: 'customer-1',
        balance: balance,
        tier: tier,
        createdAt: DateTime(2026, 1, 15),
      );
    }

    group('pointsToNextTier', () {
      test('should return points needed from bronze to silver (1000)', () {
        final loyalty = createLoyalty(balance: 300, tier: LoyaltyTier.bronze);
        expect(loyalty.pointsToNextTier, equals(700));
      });

      test('should return points needed from silver to gold (5000)', () {
        final loyalty = createLoyalty(balance: 2000, tier: LoyaltyTier.silver);
        expect(loyalty.pointsToNextTier, equals(3000));
      });

      test('should return points needed from gold to platinum (10000)', () {
        final loyalty = createLoyalty(balance: 7000, tier: LoyaltyTier.gold);
        expect(loyalty.pointsToNextTier, equals(3000));
      });

      test('should return 0 for platinum (max tier)', () {
        final loyalty = createLoyalty(balance: 15000, tier: LoyaltyTier.platinum);
        expect(loyalty.pointsToNextTier, equals(0));
      });
    });

    group('nextTier', () {
      test('should return silver for bronze', () {
        final loyalty = createLoyalty(tier: LoyaltyTier.bronze);
        expect(loyalty.nextTier, equals(LoyaltyTier.silver));
      });

      test('should return gold for silver', () {
        final loyalty = createLoyalty(tier: LoyaltyTier.silver);
        expect(loyalty.nextTier, equals(LoyaltyTier.gold));
      });

      test('should return platinum for gold', () {
        final loyalty = createLoyalty(tier: LoyaltyTier.gold);
        expect(loyalty.nextTier, equals(LoyaltyTier.platinum));
      });

      test('should return null for platinum (max tier)', () {
        final loyalty = createLoyalty(tier: LoyaltyTier.platinum);
        expect(loyalty.nextTier, isNull);
      });
    });

    group('calculateTier (static)', () {
      test('should return bronze for < 1000 points', () {
        expect(LoyaltyPoints.calculateTier(500), equals(LoyaltyTier.bronze));
      });

      test('should return silver for >= 1000 points', () {
        expect(LoyaltyPoints.calculateTier(1000), equals(LoyaltyTier.silver));
      });

      test('should return gold for >= 5000 points', () {
        expect(LoyaltyPoints.calculateTier(5000), equals(LoyaltyTier.gold));
      });

      test('should return platinum for >= 10000 points', () {
        expect(LoyaltyPoints.calculateTier(10000), equals(LoyaltyTier.platinum));
      });

      test('should return bronze for 0 points', () {
        expect(LoyaltyPoints.calculateTier(0), equals(LoyaltyTier.bronze));
      });

      test('should return platinum for very high points', () {
        expect(LoyaltyPoints.calculateTier(100000), equals(LoyaltyTier.platinum));
      });
    });

    group('serialization', () {
      test('should create LoyaltyPoints from JSON', () {
        final json = {
          'id': 'lp-1',
          'customerId': 'customer-1',
          'balance': 2500,
          'tier': 'silver',
          'earnedThisMonth': 200,
          'redeemedThisMonth': 50,
          'expiringPoints': 100,
          'currentStreak': 5,
          'longestStreak': 10,
          'createdAt': '2026-01-15T00:00:00.000',
        };

        final loyalty = LoyaltyPoints.fromJson(json);

        expect(loyalty.id, equals('lp-1'));
        expect(loyalty.balance, equals(2500));
        expect(loyalty.tier, equals(LoyaltyTier.silver));
        expect(loyalty.earnedThisMonth, equals(200));
        expect(loyalty.currentStreak, equals(5));
      });

      test('should serialize to JSON and back', () {
        final loyalty = createLoyalty(
          balance: 5000,
          tier: LoyaltyTier.gold,
        );
        final json = loyalty.toJson();
        final restored = LoyaltyPoints.fromJson(json);

        expect(restored.balance, equals(5000));
        expect(restored.tier, equals(LoyaltyTier.gold));
      });

      test('should use defaults for missing fields', () {
        final json = {
          'id': 'lp-1',
          'customerId': 'c1',
          'createdAt': '2026-01-15T00:00:00.000',
        };

        final loyalty = LoyaltyPoints.fromJson(json);

        expect(loyalty.balance, equals(0));
        expect(loyalty.tier, equals(LoyaltyTier.bronze));
        expect(loyalty.earnedThisMonth, equals(0));
        expect(loyalty.currentStreak, equals(0));
      });
    });
  });
}
