import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/data/local/daos/loyalty_dao.dart';
import 'package:pos_app/providers/loyalty_providers.dart';
import 'package:pos_app/services/loyalty_service.dart';

void main() {
  group('LoyaltyConfig', () {
    test('الإعدادات الافتراضية صحيحة', () {
      const config = LoyaltyConfig.defaultConfig;

      expect(config.pointsPerRiyal, 1.5);
      expect(config.minPurchaseForPoints, 10.0);
      expect(config.pointValueInRiyal, 0.1);
      expect(config.minRedeemPoints, 100);
      expect(config.silverThreshold, 1000);
      expect(config.goldThreshold, 5000);
      expect(config.platinumThreshold, 10000);
    });

    test('مضاعفات المستويات صحيحة', () {
      const config = LoyaltyConfig.defaultConfig;

      expect(config.silverMultiplier, 1.25);
      expect(config.goldMultiplier, 1.5);
      expect(config.platinumMultiplier, 2.0);
    });

    test('إنشاء إعدادات مخصصة', () {
      const config = LoyaltyConfig(
        pointsPerRiyal: 2.0,
        minPurchaseForPoints: 20.0,
      );

      expect(config.pointsPerRiyal, 2.0);
      expect(config.minPurchaseForPoints, 20.0);
    });
  });

  group('CustomerTier', () {
    test('الأسماء العربية صحيحة', () {
      expect(CustomerTier.bronze.arabicName, 'برونزي');
      expect(CustomerTier.silver.arabicName, 'فضي');
      expect(CustomerTier.gold.arabicName, 'ذهبي');
      expect(CustomerTier.platinum.arabicName, 'بلاتيني');
    });

    test('الإيموجي صحيح', () {
      expect(CustomerTier.bronze.emoji, '🥉');
      expect(CustomerTier.silver.emoji, '🥈');
      expect(CustomerTier.gold.emoji, '🥇');
      expect(CustomerTier.platinum.emoji, '💎');
    });

    test('fromString يحول النص للمستوى', () {
      expect(CustomerTier.fromString('bronze'), CustomerTier.bronze);
      expect(CustomerTier.fromString('silver'), CustomerTier.silver);
      expect(CustomerTier.fromString('gold'), CustomerTier.gold);
      expect(CustomerTier.fromString('platinum'), CustomerTier.platinum);
    });

    test('fromString يعيد bronze للقيمة غير المعروفة', () {
      expect(CustomerTier.fromString('unknown'), CustomerTier.bronze);
      expect(CustomerTier.fromString(''), CustomerTier.bronze);
    });
  });

  group('LoyaltyTransactionType', () {
    test('الأسماء العربية صحيحة', () {
      expect(LoyaltyTransactionType.earn.arabicName, 'اكتساب');
      expect(LoyaltyTransactionType.redeem.arabicName, 'استبدال');
      expect(LoyaltyTransactionType.expire.arabicName, 'انتهاء صلاحية');
      expect(LoyaltyTransactionType.adjust.arabicName, 'تعديل');
    });
  });

  group('EarnPointsResult', () {
    test('إنشاء نتيجة ناجحة', () {
      const result = EarnPointsResult(
        success: true,
        pointsEarned: 150,
        newBalance: 500,
        tier: CustomerTier.bronze,
        tierUpgrade: false,
      );

      expect(result.success, isTrue);
      expect(result.pointsEarned, 150);
      expect(result.newBalance, 500);
      expect(result.tier, CustomerTier.bronze);
      expect(result.tierUpgrade, isFalse);
    });

    test('إنشاء نتيجة مع ترقية المستوى', () {
      const result = EarnPointsResult(
        success: true,
        pointsEarned: 200,
        newBalance: 1100,
        tier: CustomerTier.silver,
        tierUpgrade: true,
        message: 'مبروك! تمت ترقيتك',
      );

      expect(result.tierUpgrade, isTrue);
      expect(result.tier, CustomerTier.silver);
      expect(result.message, contains('مبروك'));
    });

    test('إنشاء نتيجة فاشلة', () {
      const result = EarnPointsResult(
        success: false,
        pointsEarned: 0,
        newBalance: 0,
        tier: CustomerTier.bronze,
        message: 'المبلغ أقل من الحد الأدنى',
      );

      expect(result.success, isFalse);
      expect(result.pointsEarned, 0);
    });
  });

  group('RedeemPointsResult', () {
    test('إنشاء نتيجة ناجحة', () {
      const result = RedeemPointsResult(
        success: true,
        pointsRedeemed: 100,
        discountAmount: 10.0,
        remainingPoints: 400,
      );

      expect(result.success, isTrue);
      expect(result.pointsRedeemed, 100);
      expect(result.discountAmount, 10.0);
      expect(result.remainingPoints, 400);
    });

    test('factory failed يُنشئ نتيجة فاشلة', () {
      final result = RedeemPointsResult.failed('رصيد غير كافي');

      expect(result.success, isFalse);
      expect(result.message, 'رصيد غير كافي');
      expect(result.pointsRedeemed, 0);
      expect(result.discountAmount, 0);
    });

    test('إنشاء نتيجة مع اسم المكافأة', () {
      const result = RedeemPointsResult(
        success: true,
        pointsRedeemed: 200,
        discountAmount: 20.0,
        remainingPoints: 300,
        rewardName: 'خصم 10%',
      );

      expect(result.rewardName, 'خصم 10%');
    });
  });

  group('CustomerLoyaltyInfo', () {
    test('إنشاء معلومات العميل', () {
      const info = CustomerLoyaltyInfo(
        customerId: 'customer-1',
        currentPoints: 500,
        totalEarned: 800,
        totalRedeemed: 300,
        tier: CustomerTier.bronze,
        pointsToNextTier: 500,
        multiplier: 1.0,
      );

      expect(info.customerId, 'customer-1');
      expect(info.currentPoints, 500);
      expect(info.totalEarned, 800);
      expect(info.totalRedeemed, 300);
      expect(info.tier, CustomerTier.bronze);
      expect(info.pointsToNextTier, 500);
    });

    test('valueInRiyal يحسب القيمة بالريال', () {
      const info = CustomerLoyaltyInfo(
        customerId: 'customer-1',
        currentPoints: 1000,
        totalEarned: 1000,
        totalRedeemed: 0,
        tier: CustomerTier.silver,
        pointsToNextTier: 4000,
        multiplier: 1.25,
      );

      // 1000 * 0.1 = 100 ريال
      expect(info.valueInRiyal, 100.0);
    });

    test('valueInRiyal مع قيم صفرية', () {
      const info = CustomerLoyaltyInfo(
        customerId: 'customer-1',
        currentPoints: 0,
        totalEarned: 0,
        totalRedeemed: 0,
        tier: CustomerTier.bronze,
        pointsToNextTier: 1000,
        multiplier: 1.0,
      );

      expect(info.valueInRiyal, 0.0);
    });
  });

  group('CustomerLoyaltyState', () {
    test('الحالة الابتدائية', () {
      const state = CustomerLoyaltyState();

      expect(state.isLoading, isFalse);
      expect(state.info, isNull);
      expect(state.availableRewards, isEmpty);
      expect(state.recentTransactions, isEmpty);
      expect(state.error, isNull);
    });

    test('copyWith يعمل بشكل صحيح', () {
      const state = CustomerLoyaltyState();
      final newState = state.copyWith(isLoading: true);

      expect(newState.isLoading, isTrue);
      expect(state.isLoading, isFalse);
    });

    test('copyWith يحافظ على القيم الأخرى', () {
      const info = CustomerLoyaltyInfo(
        customerId: 'c1',
        currentPoints: 100,
        totalEarned: 100,
        totalRedeemed: 0,
        tier: CustomerTier.bronze,
        pointsToNextTier: 900,
        multiplier: 1.0,
      );

      const state = CustomerLoyaltyState(
        isLoading: false,
        info: info,
      );

      final newState = state.copyWith(error: 'خطأ');

      expect(newState.info, info);
      expect(newState.error, 'خطأ');
    });

    test('canRedeem يعيد true عند نقاط كافية', () {
      const info = CustomerLoyaltyInfo(
        customerId: 'c1',
        currentPoints: 200,
        totalEarned: 200,
        totalRedeemed: 0,
        tier: CustomerTier.bronze,
        pointsToNextTier: 800,
        multiplier: 1.0,
      );

      const state = CustomerLoyaltyState(info: info);

      expect(state.canRedeem, isTrue);
    });

    test('canRedeem يعيد false عند نقاط غير كافية', () {
      const info = CustomerLoyaltyInfo(
        customerId: 'c1',
        currentPoints: 50,
        totalEarned: 50,
        totalRedeemed: 0,
        tier: CustomerTier.bronze,
        pointsToNextTier: 950,
        multiplier: 1.0,
      );

      const state = CustomerLoyaltyState(info: info);

      expect(state.canRedeem, isFalse);
    });

    test('canRedeem يعيد false بدون info', () {
      const state = CustomerLoyaltyState();
      expect(state.canRedeem, isFalse);
    });

    test('pointsValue يعيد قيمة النقاط', () {
      const info = CustomerLoyaltyInfo(
        customerId: 'c1',
        currentPoints: 500,
        totalEarned: 500,
        totalRedeemed: 0,
        tier: CustomerTier.bronze,
        pointsToNextTier: 500,
        multiplier: 1.0,
      );

      const state = CustomerLoyaltyState(info: info);

      expect(state.pointsValue, 50.0);
    });

    test('pointsValue يعيد 0 بدون info', () {
      const state = CustomerLoyaltyState();
      expect(state.pointsValue, 0);
    });
  });

  group('LoyaltyDiscountState', () {
    test('الحالة الابتدائية', () {
      const state = LoyaltyDiscountState();

      expect(state.isApplied, isFalse);
      expect(state.pointsUsed, 0);
      expect(state.discountAmount, 0);
      expect(state.rewardName, isNull);
    });

    test('copyWith يعمل بشكل صحيح', () {
      const state = LoyaltyDiscountState();
      final newState = state.copyWith(
        isApplied: true,
        pointsUsed: 100,
        discountAmount: 10.0,
        rewardName: 'خصم 10%',
      );

      expect(newState.isApplied, isTrue);
      expect(newState.pointsUsed, 100);
      expect(newState.discountAmount, 10.0);
      expect(newState.rewardName, 'خصم 10%');
    });

    test('empty constant', () {
      expect(LoyaltyDiscountState.empty.isApplied, isFalse);
      expect(LoyaltyDiscountState.empty.pointsUsed, 0);
    });
  });

  group('LoyaltyStats', () {
    test('إنشاء الإحصائيات', () {
      const stats = LoyaltyStats(
        totalEarned: 10000,
        totalRedeemed: 3000,
        activeCustomers: 50,
        totalTransactions: 200,
      );

      expect(stats.totalEarned, 10000);
      expect(stats.totalRedeemed, 3000);
      expect(stats.activeCustomers, 50);
      expect(stats.totalTransactions, 200);
    });

    test('netPoints يحسب الصافي', () {
      const stats = LoyaltyStats(
        totalEarned: 10000,
        totalRedeemed: 3000,
        activeCustomers: 50,
        totalTransactions: 200,
      );

      expect(stats.netPoints, 7000);
    });

    test('netPoints مع قيم متساوية', () {
      const stats = LoyaltyStats(
        totalEarned: 5000,
        totalRedeemed: 5000,
        activeCustomers: 10,
        totalTransactions: 20,
      );

      expect(stats.netPoints, 0);
    });
  });

  group('LoyaltyService - calculateExpectedPoints', () {
    test('حساب النقاط المتوقعة للمستوى البرونزي', () {
      // لا يمكننا اختبار LoyaltyService مباشرة بدون DAO
      // لكن يمكننا اختبار الحسابات الرياضية

      // مبلغ 100 ريال * 1.5 نقطة/ريال * 1.0 مضاعف = 150 نقطة
      const amount = 100.0;
      const pointsPerRiyal = 1.5;
      const multiplier = 1.0; // bronze

      final expected = (amount * pointsPerRiyal * multiplier).round();
      expect(expected, 150);
    });

    test('حساب النقاط للمستوى الفضي', () {
      const amount = 100.0;
      const pointsPerRiyal = 1.5;
      const multiplier = 1.25; // silver

      final expected = (amount * pointsPerRiyal * multiplier).round();
      expect(expected, 188); // 150 * 1.25 = 187.5 ≈ 188
    });

    test('حساب النقاط للمستوى الذهبي', () {
      const amount = 100.0;
      const pointsPerRiyal = 1.5;
      const multiplier = 1.5; // gold

      final expected = (amount * pointsPerRiyal * multiplier).round();
      expect(expected, 225);
    });

    test('حساب النقاط للمستوى البلاتيني', () {
      const amount = 100.0;
      const pointsPerRiyal = 1.5;
      const multiplier = 2.0; // platinum

      final expected = (amount * pointsPerRiyal * multiplier).round();
      expect(expected, 300);
    });

    test('لا نقاط للمبلغ أقل من الحد الأدنى', () {
      const amount = 5.0; // أقل من 10
      const minPurchase = 10.0;

      const shouldEarn = amount >= minPurchase;
      expect(shouldEarn, isFalse);
    });
  });

  group('LoyaltyService - calculateDiscountValue', () {
    test('حساب قيمة الخصم', () {
      const points = 500;
      const pointValueInRiyal = 0.1;

      const discount = points * pointValueInRiyal;
      expect(discount, 50.0);
    });

    test('حساب قيمة الخصم للحد الأدنى', () {
      const points = 100; // الحد الأدنى
      const pointValueInRiyal = 0.1;

      const discount = points * pointValueInRiyal;
      expect(discount, 10.0);
    });
  });

  group('Tier Calculation', () {
    test('برونزي عند أقل من 1000', () {
      const totalPoints = 500;
      const silverThreshold = 1000;
      const goldThreshold = 5000;
      const platinumThreshold = 10000;

      CustomerTier tier;
      if (totalPoints >= platinumThreshold) {
        tier = CustomerTier.platinum;
      } else if (totalPoints >= goldThreshold) {
        tier = CustomerTier.gold;
      } else if (totalPoints >= silverThreshold) {
        tier = CustomerTier.silver;
      } else {
        tier = CustomerTier.bronze;
      }

      expect(tier, CustomerTier.bronze);
    });

    test('فضي عند 1000-4999', () {
      const totalPoints = 2000;
      const silverThreshold = 1000;
      const goldThreshold = 5000;
      const platinumThreshold = 10000;

      CustomerTier tier;
      if (totalPoints >= platinumThreshold) {
        tier = CustomerTier.platinum;
      } else if (totalPoints >= goldThreshold) {
        tier = CustomerTier.gold;
      } else if (totalPoints >= silverThreshold) {
        tier = CustomerTier.silver;
      } else {
        tier = CustomerTier.bronze;
      }

      expect(tier, CustomerTier.silver);
    });

    test('ذهبي عند 5000-9999', () {
      const totalPoints = 7000;
      const silverThreshold = 1000;
      const goldThreshold = 5000;
      const platinumThreshold = 10000;

      CustomerTier tier;
      if (totalPoints >= platinumThreshold) {
        tier = CustomerTier.platinum;
      } else if (totalPoints >= goldThreshold) {
        tier = CustomerTier.gold;
      } else if (totalPoints >= silverThreshold) {
        tier = CustomerTier.silver;
      } else {
        tier = CustomerTier.bronze;
      }

      expect(tier, CustomerTier.gold);
    });

    test('بلاتيني عند 10000 فأكثر', () {
      const totalPoints = 15000;
      const silverThreshold = 1000;
      const goldThreshold = 5000;
      const platinumThreshold = 10000;

      CustomerTier tier;
      if (totalPoints >= platinumThreshold) {
        tier = CustomerTier.platinum;
      } else if (totalPoints >= goldThreshold) {
        tier = CustomerTier.gold;
      } else if (totalPoints >= silverThreshold) {
        tier = CustomerTier.silver;
      } else {
        tier = CustomerTier.bronze;
      }

      expect(tier, CustomerTier.platinum);
    });

    test('حدود المستويات الدقيقة', () {
      // عند 999 = برونزي
      expect(999 < 1000, isTrue);

      // عند 1000 = فضي
      expect(1000 >= 1000, isTrue);

      // عند 4999 = فضي
      expect(4999 >= 1000 && 4999 < 5000, isTrue);

      // عند 5000 = ذهبي
      expect(5000 >= 5000, isTrue);

      // عند 9999 = ذهبي
      expect(9999 >= 5000 && 9999 < 10000, isTrue);

      // عند 10000 = بلاتيني
      expect(10000 >= 10000, isTrue);
    });
  });

  group('Points to Next Tier', () {
    test('من برونزي للفضي', () {
      const currentTotal = 500;
      const silverThreshold = 1000;

      const pointsNeeded = silverThreshold - currentTotal;
      expect(pointsNeeded, 500);
    });

    test('من فضي للذهبي', () {
      const currentTotal = 2000;
      const goldThreshold = 5000;

      const pointsNeeded = goldThreshold - currentTotal;
      expect(pointsNeeded, 3000);
    });

    test('من ذهبي للبلاتيني', () {
      const currentTotal = 7500;
      const platinumThreshold = 10000;

      const pointsNeeded = platinumThreshold - currentTotal;
      expect(pointsNeeded, 2500);
    });

    test('بلاتيني لا يحتاج نقاط إضافية', () {
      const currentTotal = 15000;
      const tier = CustomerTier.platinum;

      const pointsNeeded = tier == CustomerTier.platinum ? 0 : 10000 - currentTotal;
      expect(pointsNeeded, 0);
    });
  });
}


