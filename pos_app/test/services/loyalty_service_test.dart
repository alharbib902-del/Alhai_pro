import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pos_app/services/loyalty_service.dart';
import 'package:pos_app/data/local/daos/loyalty_dao.dart';
import 'package:pos_app/data/local/app_database.dart';

// Mock classes
class MockLoyaltyDao extends Mock implements LoyaltyDao {}

// Fake classes for fallback values
class FakeLoyaltyPointsTableCompanion extends Fake implements LoyaltyPointsTableCompanion {}
class FakeLoyaltyTransactionsTableCompanion extends Fake implements LoyaltyTransactionsTableCompanion {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeLoyaltyPointsTableCompanion());
    registerFallbackValue(FakeLoyaltyTransactionsTableCompanion());
  });
  group('LoyaltyConfig', () {
    test('default config has correct values', () {
      const config = LoyaltyConfig.defaultConfig;

      expect(config.pointsPerRiyal, 1.5);
      expect(config.minPurchaseForPoints, 10.0);
      expect(config.pointValueInRiyal, 0.1);
      expect(config.minRedeemPoints, 100);
      expect(config.silverThreshold, 1000);
      expect(config.goldThreshold, 5000);
      expect(config.platinumThreshold, 10000);
    });

    test('multipliers are correct', () {
      const config = LoyaltyConfig.defaultConfig;

      expect(config.silverMultiplier, 1.25);
      expect(config.goldMultiplier, 1.5);
      expect(config.platinumMultiplier, 2.0);
    });
  });

  group('CustomerTier', () {
    test('has correct arabic names', () {
      expect(CustomerTier.bronze.arabicName, 'برونزي');
      expect(CustomerTier.silver.arabicName, 'فضي');
      expect(CustomerTier.gold.arabicName, 'ذهبي');
      expect(CustomerTier.platinum.arabicName, 'بلاتيني');
    });

    test('has correct emojis', () {
      expect(CustomerTier.bronze.emoji, '🥉');
      expect(CustomerTier.silver.emoji, '🥈');
      expect(CustomerTier.gold.emoji, '🥇');
      expect(CustomerTier.platinum.emoji, '💎');
    });

    test('fromString parses correctly', () {
      expect(CustomerTier.fromString('bronze'), CustomerTier.bronze);
      expect(CustomerTier.fromString('silver'), CustomerTier.silver);
      expect(CustomerTier.fromString('gold'), CustomerTier.gold);
      expect(CustomerTier.fromString('platinum'), CustomerTier.platinum);
    });

    test('fromString returns bronze for unknown', () {
      expect(CustomerTier.fromString('unknown'), CustomerTier.bronze);
      expect(CustomerTier.fromString(''), CustomerTier.bronze);
    });
  });

  group('LoyaltyTransactionType', () {
    test('has correct arabic names', () {
      expect(LoyaltyTransactionType.earn.arabicName, 'اكتساب');
      expect(LoyaltyTransactionType.redeem.arabicName, 'استبدال');
      expect(LoyaltyTransactionType.expire.arabicName, 'انتهاء صلاحية');
      expect(LoyaltyTransactionType.adjust.arabicName, 'تعديل');
    });
  });

  group('EarnPointsResult', () {
    test('failed result has correct properties', () {
      const result = EarnPointsResult(
        success: false,
        pointsEarned: 0,
        newBalance: 0,
        tier: CustomerTier.bronze,
        message: 'Error',
      );

      expect(result.success, false);
      expect(result.pointsEarned, 0);
      expect(result.tierUpgrade, false);
    });

    test('successful result with tier upgrade', () {
      const result = EarnPointsResult(
        success: true,
        pointsEarned: 150,
        newBalance: 1150,
        tier: CustomerTier.silver,
        tierUpgrade: true,
        message: 'Upgraded!',
      );

      expect(result.success, true);
      expect(result.tierUpgrade, true);
      expect(result.tier, CustomerTier.silver);
    });
  });

  group('RedeemPointsResult', () {
    test('failed factory creates correct result', () {
      final result = RedeemPointsResult.failed('Not enough points');

      expect(result.success, false);
      expect(result.message, 'Not enough points');
      expect(result.pointsRedeemed, 0);
      expect(result.discountAmount, 0);
    });

    test('successful result has all properties', () {
      const result = RedeemPointsResult(
        success: true,
        pointsRedeemed: 100,
        discountAmount: 10.0,
        remainingPoints: 50,
        rewardName: 'خصم 10%',
      );

      expect(result.success, true);
      expect(result.pointsRedeemed, 100);
      expect(result.discountAmount, 10.0);
      expect(result.remainingPoints, 50);
    });
  });

  group('CustomerLoyaltyInfo', () {
    test('calculates value in riyal correctly', () {
      const info = CustomerLoyaltyInfo(
        customerId: 'customer-1',
        currentPoints: 1000,
        totalEarned: 1500,
        totalRedeemed: 500,
        tier: CustomerTier.silver,
        pointsToNextTier: 4000,
        multiplier: 1.25,
      );

      // 1000 points * 0.1 SAR/point = 100 SAR
      expect(info.valueInRiyal, 100.0);
    });
  });

  group('LoyaltyService', () {
    late MockLoyaltyDao mockDao;
    late LoyaltyService service;

    setUp(() {
      mockDao = MockLoyaltyDao();
      service = LoyaltyService(mockDao);
    });

    group('calculateExpectedPoints', () {
      test('returns 0 for amount below minimum', () {
        final points = service.calculateExpectedPoints(5.0, CustomerTier.bronze);
        expect(points, 0);
      });

      test('calculates correctly for bronze tier', () {
        // 100 SAR * 1.5 points/SAR * 1.0 multiplier = 150 points
        final points = service.calculateExpectedPoints(100.0, CustomerTier.bronze);
        expect(points, 150);
      });

      test('calculates correctly for silver tier', () {
        // 100 SAR * 1.5 points/SAR * 1.25 multiplier = 188 points (rounded)
        final points = service.calculateExpectedPoints(100.0, CustomerTier.silver);
        expect(points, 188);
      });

      test('calculates correctly for gold tier', () {
        // 100 SAR * 1.5 points/SAR * 1.5 multiplier = 225 points
        final points = service.calculateExpectedPoints(100.0, CustomerTier.gold);
        expect(points, 225);
      });

      test('calculates correctly for platinum tier', () {
        // 100 SAR * 1.5 points/SAR * 2.0 multiplier = 300 points
        final points = service.calculateExpectedPoints(100.0, CustomerTier.platinum);
        expect(points, 300);
      });
    });

    group('calculateDiscountValue', () {
      test('calculates correctly', () {
        // 100 points * 0.1 SAR/point = 10 SAR
        final discount = service.calculateDiscountValue(100);
        expect(discount, 10.0);
      });

      test('returns 0 for 0 points', () {
        final discount = service.calculateDiscountValue(0);
        expect(discount, 0.0);
      });
    });

    group('earnPoints', () {
      test('fails when amount below minimum', () async {
        final result = await service.earnPoints(
          customerId: 'customer-1',
          storeId: 'store-1',
          purchaseAmount: 5.0,
          saleId: 'sale-1',
        );

        expect(result.success, false);
        expect(result.pointsEarned, 0);
        verifyNever(() => mockDao.getCustomerLoyalty(any(), any()));
      });

      test('creates new loyalty account if not exists', () async {
        // First call returns null (no account)
        when(() => mockDao.getCustomerLoyalty('customer-1', 'store-1'))
            .thenAnswer((_) async => null);

        // Create account
        when(() => mockDao.createLoyalty(any()))
            .thenAnswer((_) async => 1);

        // Second call returns the new account
        when(() => mockDao.getCustomerLoyalty('customer-1', 'store-1'))
            .thenAnswer((_) async => _createMockLoyaltyData());

        when(() => mockDao.addPoints(any(), any(), any()))
            .thenAnswer((_) async {});

        when(() => mockDao.logTransaction(any()))
            .thenAnswer((_) async => 1);

        final result = await service.earnPoints(
          customerId: 'customer-1',
          storeId: 'store-1',
          purchaseAmount: 100.0,
          saleId: 'sale-1',
        );

        expect(result.success, true);
        expect(result.pointsEarned, greaterThan(0));
      });
    });

    group('redeemPoints', () {
      test('fails when below minimum redeem', () async {
        final result = await service.redeemPoints(
          customerId: 'customer-1',
          storeId: 'store-1',
          points: 50,
        );

        expect(result.success, false);
        expect(result.message, contains('الحد الأدنى'));
      });

      test('fails when no loyalty account', () async {
        when(() => mockDao.getCustomerLoyalty('customer-1', 'store-1'))
            .thenAnswer((_) async => null);

        final result = await service.redeemPoints(
          customerId: 'customer-1',
          storeId: 'store-1',
          points: 100,
        );

        expect(result.success, false);
        expect(result.message, contains('لا يوجد حساب'));
      });

      test('fails when insufficient points', () async {
        when(() => mockDao.getCustomerLoyalty('customer-1', 'store-1'))
            .thenAnswer((_) async => _createMockLoyaltyData(currentPoints: 50));

        final result = await service.redeemPoints(
          customerId: 'customer-1',
          storeId: 'store-1',
          points: 100,
        );

        expect(result.success, false);
        expect(result.message, contains('رصيدك'));
      });

      test('succeeds with sufficient points', () async {
        when(() => mockDao.getCustomerLoyalty('customer-1', 'store-1'))
            .thenAnswer((_) async => _createMockLoyaltyData(currentPoints: 500));

        when(() => mockDao.redeemPoints('customer-1', 'store-1', 100))
            .thenAnswer((_) async => true);

        when(() => mockDao.logTransaction(any()))
            .thenAnswer((_) async => 1);

        final result = await service.redeemPoints(
          customerId: 'customer-1',
          storeId: 'store-1',
          points: 100,
        );

        expect(result.success, true);
        expect(result.pointsRedeemed, 100);
        expect(result.discountAmount, 10.0); // 100 * 0.1
        expect(result.remainingPoints, 400);
      });
    });
  });
}

/// Helper to create mock loyalty data
LoyaltyPointsTableData _createMockLoyaltyData({
  String id = 'loyalty-1',
  String customerId = 'customer-1',
  String storeId = 'store-1',
  int currentPoints = 100,
  int totalEarned = 200,
  int totalRedeemed = 100,
  String tierLevel = 'bronze',
}) {
  return LoyaltyPointsTableData(
    id: id,
    customerId: customerId,
    storeId: storeId,
    currentPoints: currentPoints,
    totalEarned: totalEarned,
    totalRedeemed: totalRedeemed,
    tierLevel: tierLevel,
    createdAt: DateTime.now(),
    updatedAt: null,
    syncedAt: null,
  );
}
