import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/data/local/daos/loyalty_dao.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await Future.delayed(const Duration(milliseconds: 100));
  });

  tearDown(() async {
    await db.close();
  });

  group('LoyaltyDao - CRUD Operations', () {
    test('createLoyalty يُنشئ سجل نقاط جديد', () async {
      final loyalty = LoyaltyPointsTableCompanion.insert(
        id: 'loyalty-1',
        customerId: 'customer-1',
        storeId: 'store-1',
        currentPoints: const Value(100),
        totalEarned: const Value(100),
        totalRedeemed: const Value(0),
        tierLevel: const Value('bronze'),
      );

      final result = await db.loyaltyDao.createLoyalty(loyalty);
      expect(result, greaterThan(0));
    });

    test('getCustomerLoyalty يعيد نقاط العميل', () async {
      // إنشاء سجل
      await db.loyaltyDao.createLoyalty(
        LoyaltyPointsTableCompanion.insert(
          id: 'loyalty-1',
          customerId: 'customer-1',
          storeId: 'store-1',
          currentPoints: const Value(500),
          totalEarned: const Value(500),
          totalRedeemed: const Value(0),
          tierLevel: const Value('bronze'),
        ),
      );

      // استرجاع
      final loyalty = await db.loyaltyDao.getCustomerLoyalty('customer-1', 'store-1');

      expect(loyalty, isNotNull);
      expect(loyalty!.customerId, 'customer-1');
      expect(loyalty.currentPoints, 500);
    });

    test('getCustomerLoyalty يعيد null للعميل غير الموجود', () async {
      final loyalty = await db.loyaltyDao.getCustomerLoyalty('non-existent', 'store-1');
      expect(loyalty, isNull);
    });

    test('getLoyaltyById يعيد السجل بالمعرف', () async {
      await db.loyaltyDao.createLoyalty(
        LoyaltyPointsTableCompanion.insert(
          id: 'loyalty-123',
          customerId: 'customer-1',
          storeId: 'store-1',
          currentPoints: const Value(200),
          totalEarned: const Value(200),
          totalRedeemed: const Value(0),
          tierLevel: const Value('bronze'),
        ),
      );

      final loyalty = await db.loyaltyDao.getLoyaltyById('loyalty-123');

      expect(loyalty, isNotNull);
      expect(loyalty!.id, 'loyalty-123');
    });

    test('updateLoyalty يحدث البيانات بشكل صحيح', () async {
      await db.loyaltyDao.createLoyalty(
        LoyaltyPointsTableCompanion.insert(
          id: 'loyalty-1',
          customerId: 'customer-1',
          storeId: 'store-1',
          currentPoints: const Value(100),
          totalEarned: const Value(100),
          totalRedeemed: const Value(0),
          tierLevel: const Value('bronze'),
        ),
      );

      final original = await db.loyaltyDao.getLoyaltyById('loyalty-1');
      final updated = original!.copyWith(currentPoints: 300, tierLevel: 'silver');

      await db.loyaltyDao.updateLoyalty(updated);

      final result = await db.loyaltyDao.getLoyaltyById('loyalty-1');
      expect(result!.currentPoints, 300);
      expect(result.tierLevel, 'silver');
    });
  });

  group('LoyaltyDao - Points Operations', () {
    test('addPoints يضيف نقاط للعميل', () async {
      await db.loyaltyDao.createLoyalty(
        LoyaltyPointsTableCompanion.insert(
          id: 'loyalty-1',
          customerId: 'customer-1',
          storeId: 'store-1',
          currentPoints: const Value(100),
          totalEarned: const Value(100),
          totalRedeemed: const Value(0),
          tierLevel: const Value('bronze'),
        ),
      );

      await db.loyaltyDao.addPoints('customer-1', 'store-1', 50);

      final loyalty = await db.loyaltyDao.getCustomerLoyalty('customer-1', 'store-1');
      expect(loyalty!.currentPoints, 150);
      expect(loyalty.totalEarned, 150);
    });

    test('redeemPoints يخصم النقاط بنجاح', () async {
      await db.loyaltyDao.createLoyalty(
        LoyaltyPointsTableCompanion.insert(
          id: 'loyalty-1',
          customerId: 'customer-1',
          storeId: 'store-1',
          currentPoints: const Value(100),
          totalEarned: const Value(100),
          totalRedeemed: const Value(0),
          tierLevel: const Value('bronze'),
        ),
      );

      final success = await db.loyaltyDao.redeemPoints('customer-1', 'store-1', 30);

      expect(success, isTrue);

      final loyalty = await db.loyaltyDao.getCustomerLoyalty('customer-1', 'store-1');
      expect(loyalty!.currentPoints, 70);
      expect(loyalty.totalRedeemed, 30);
    });

    test('redeemPoints يفشل عند عدم كفاية النقاط', () async {
      await db.loyaltyDao.createLoyalty(
        LoyaltyPointsTableCompanion.insert(
          id: 'loyalty-1',
          customerId: 'customer-1',
          storeId: 'store-1',
          currentPoints: const Value(50),
          totalEarned: const Value(50),
          totalRedeemed: const Value(0),
          tierLevel: const Value('bronze'),
        ),
      );

      final success = await db.loyaltyDao.redeemPoints('customer-1', 'store-1', 100);

      expect(success, isFalse);

      // التأكد من عدم تغير النقاط
      final loyalty = await db.loyaltyDao.getCustomerLoyalty('customer-1', 'store-1');
      expect(loyalty!.currentPoints, 50);
    });

    test('redeemPoints يفشل للعميل غير الموجود', () async {
      final success = await db.loyaltyDao.redeemPoints('non-existent', 'store-1', 50);
      expect(success, isFalse);
    });
  });

  group('LoyaltyDao - Tier Calculation', () {
    test('addPoints يحدث المستوى تلقائياً', () async {
      await db.loyaltyDao.createLoyalty(
        LoyaltyPointsTableCompanion.insert(
          id: 'loyalty-1',
          customerId: 'customer-1',
          storeId: 'store-1',
          currentPoints: const Value(900),
          totalEarned: const Value(900),
          totalRedeemed: const Value(0),
          tierLevel: const Value('bronze'),
        ),
      );

      // إضافة نقاط لتجاوز 1000 (silver)
      await db.loyaltyDao.addPoints('customer-1', 'store-1', 200);

      final loyalty = await db.loyaltyDao.getCustomerLoyalty('customer-1', 'store-1');
      expect(loyalty!.tierLevel, 'silver');
    });

    test('المستوى الذهبي عند 5000 نقطة', () async {
      await db.loyaltyDao.createLoyalty(
        LoyaltyPointsTableCompanion.insert(
          id: 'loyalty-1',
          customerId: 'customer-1',
          storeId: 'store-1',
          currentPoints: const Value(4900),
          totalEarned: const Value(4900),
          totalRedeemed: const Value(0),
          tierLevel: const Value('silver'),
        ),
      );

      await db.loyaltyDao.addPoints('customer-1', 'store-1', 200);

      final loyalty = await db.loyaltyDao.getCustomerLoyalty('customer-1', 'store-1');
      expect(loyalty!.tierLevel, 'gold');
    });

    test('المستوى البلاتيني عند 10000 نقطة', () async {
      await db.loyaltyDao.createLoyalty(
        LoyaltyPointsTableCompanion.insert(
          id: 'loyalty-1',
          customerId: 'customer-1',
          storeId: 'store-1',
          currentPoints: const Value(9900),
          totalEarned: const Value(9900),
          totalRedeemed: const Value(0),
          tierLevel: const Value('gold'),
        ),
      );

      await db.loyaltyDao.addPoints('customer-1', 'store-1', 200);

      final loyalty = await db.loyaltyDao.getCustomerLoyalty('customer-1', 'store-1');
      expect(loyalty!.tierLevel, 'platinum');
    });
  });

  group('LoyaltyDao - Query Operations', () {
    setUp(() async {
      // إضافة بيانات اختبارية
      for (int i = 1; i <= 5; i++) {
        await db.loyaltyDao.createLoyalty(
          LoyaltyPointsTableCompanion.insert(
            id: 'loyalty-$i',
            customerId: 'customer-$i',
            storeId: 'store-1',
            currentPoints: Value(i * 100),
            totalEarned: Value(i * 100),
            totalRedeemed: const Value(0),
            tierLevel: Value(i > 3 ? 'silver' : 'bronze'),
          ),
        );
      }
    });

    test('getAllLoyaltyAccounts يعيد جميع الحسابات', () async {
      final accounts = await db.loyaltyDao.getAllLoyaltyAccounts('store-1');
      expect(accounts.length, 5);
    });

    test('getTopCustomers يعيد أفضل العملاء', () async {
      final top = await db.loyaltyDao.getTopCustomers('store-1', limit: 3);

      expect(top.length, 3);
      // يجب أن يكون مرتباً تنازلياً
      expect(top[0].totalEarned, greaterThanOrEqualTo(top[1].totalEarned));
    });

    test('getCustomersByTier يعيد العملاء حسب المستوى', () async {
      final bronzeCustomers = await db.loyaltyDao.getCustomersByTier('store-1', 'bronze');
      final silverCustomers = await db.loyaltyDao.getCustomersByTier('store-1', 'silver');

      expect(bronzeCustomers.length, 3);
      expect(silverCustomers.length, 2);
    });

    test('getAllLoyaltyAccounts لمتجر فارغ', () async {
      final accounts = await db.loyaltyDao.getAllLoyaltyAccounts('non-existent-store');
      expect(accounts, isEmpty);
    });
  });

  group('LoyaltyDao - Transactions', () {
    test('logTransaction يسجل المعاملة', () async {
      final transaction = LoyaltyTransactionsTableCompanion.insert(
        id: 'trans-1',
        loyaltyId: 'loyalty-1',
        customerId: 'customer-1',
        storeId: 'store-1',
        transactionType: 'earn',
        points: 100,
        balanceAfter: 100,
      );

      final result = await db.loyaltyDao.logTransaction(transaction);
      expect(result, greaterThan(0));
    });

    test('getCustomerTransactions يعيد المعاملات', () async {
      // إضافة معاملات
      for (int i = 1; i <= 3; i++) {
        await db.loyaltyDao.logTransaction(
          LoyaltyTransactionsTableCompanion.insert(
            id: 'trans-$i',
            loyaltyId: 'loyalty-1',
            customerId: 'customer-1',
            storeId: 'store-1',
            transactionType: i % 2 == 0 ? 'redeem' : 'earn',
            points: i * 50,
            balanceAfter: 100 + (i * 50),
          ),
        );
      }

      final transactions = await db.loyaltyDao.getCustomerTransactions(
        'customer-1',
        'store-1',
      );

      expect(transactions.length, 3);
    });

    test('getCustomerTransactions يعيد قائمة فارغة لعميل بدون معاملات', () async {
      final transactions = await db.loyaltyDao.getCustomerTransactions(
        'non-existent',
        'store-1',
      );

      expect(transactions, isEmpty);
    });
  });

  group('LoyaltyDao - Rewards', () {
    test('createReward يُنشئ مكافأة', () async {
      final reward = LoyaltyRewardsTableCompanion.insert(
        id: 'reward-1',
        storeId: 'store-1',
        name: 'خصم 10%',
        pointsRequired: 100,
        rewardType: 'discount',
        rewardValue: 10.0,
      );

      final result = await db.loyaltyDao.createReward(reward);
      expect(result, greaterThan(0));
    });

    test('getRewardById يعيد المكافأة', () async {
      await db.loyaltyDao.createReward(
        LoyaltyRewardsTableCompanion.insert(
          id: 'reward-1',
          storeId: 'store-1',
          name: 'خصم 10%',
          pointsRequired: 100,
          rewardType: 'discount',
          rewardValue: 10.0,
        ),
      );

      final reward = await db.loyaltyDao.getRewardById('reward-1');

      expect(reward, isNotNull);
      expect(reward!.name, 'خصم 10%');
    });

    test('getRewardById يعيد null للمكافأة غير الموجودة', () async {
      final reward = await db.loyaltyDao.getRewardById('non-existent');
      expect(reward, isNull);
    });

    test('getAvailableRewards يعيد المكافآت المتاحة', () async {
      // إضافة مكافآت
      await db.loyaltyDao.createReward(
        LoyaltyRewardsTableCompanion.insert(
          id: 'reward-1',
          storeId: 'store-1',
          name: 'خصم 5%',
          pointsRequired: 50,
          rewardType: 'discount',
          rewardValue: 5.0,
          isActive: const Value(true),
        ),
      );

      await db.loyaltyDao.createReward(
        LoyaltyRewardsTableCompanion.insert(
          id: 'reward-2',
          storeId: 'store-1',
          name: 'خصم 10%',
          pointsRequired: 100,
          rewardType: 'discount',
          rewardValue: 10.0,
          isActive: const Value(true),
        ),
      );

      final rewards = await db.loyaltyDao.getAvailableRewards('store-1', customerPoints: 75);

      // يجب أن يعيد فقط المكافآت التي يمكن للعميل الحصول عليها
      expect(rewards.length, 1);
      expect(rewards[0].name, 'خصم 5%');
    });

    test('getAvailableRewards يعيد جميع المكافآت عند نقاط كافية', () async {
      await db.loyaltyDao.createReward(
        LoyaltyRewardsTableCompanion.insert(
          id: 'reward-1',
          storeId: 'store-1',
          name: 'خصم 5%',
          pointsRequired: 50,
          rewardType: 'discount',
          rewardValue: 5.0,
          isActive: const Value(true),
        ),
      );

      await db.loyaltyDao.createReward(
        LoyaltyRewardsTableCompanion.insert(
          id: 'reward-2',
          storeId: 'store-1',
          name: 'خصم 10%',
          pointsRequired: 100,
          rewardType: 'discount',
          rewardValue: 10.0,
          isActive: const Value(true),
        ),
      );

      final rewards = await db.loyaltyDao.getAvailableRewards('store-1', customerPoints: 200);

      expect(rewards.length, 2);
    });

    test('deactivateReward يعطل المكافأة', () async {
      await db.loyaltyDao.createReward(
        LoyaltyRewardsTableCompanion.insert(
          id: 'reward-1',
          storeId: 'store-1',
          name: 'خصم 10%',
          pointsRequired: 100,
          rewardType: 'discount',
          rewardValue: 10.0,
          isActive: const Value(true),
        ),
      );

      await db.loyaltyDao.deactivateReward('reward-1');

      final reward = await db.loyaltyDao.getRewardById('reward-1');
      expect(reward!.isActive, isFalse);
    });

    test('المكافآت المعطلة لا تظهر في getAvailableRewards', () async {
      await db.loyaltyDao.createReward(
        LoyaltyRewardsTableCompanion.insert(
          id: 'reward-1',
          storeId: 'store-1',
          name: 'خصم 5%',
          pointsRequired: 50,
          rewardType: 'discount',
          rewardValue: 5.0,
          isActive: const Value(false),
        ),
      );

      final rewards = await db.loyaltyDao.getAvailableRewards('store-1', customerPoints: 100);
      expect(rewards, isEmpty);
    });
  });

  group('LoyaltyDao - Sync Operations', () {
    test('getUnsyncedLoyalty يعيد السجلات غير المزامنة', () async {
      await db.loyaltyDao.createLoyalty(
        LoyaltyPointsTableCompanion.insert(
          id: 'loyalty-1',
          customerId: 'customer-1',
          storeId: 'store-1',
          currentPoints: const Value(100),
          totalEarned: const Value(100),
          totalRedeemed: const Value(0),
          tierLevel: const Value('bronze'),
        ),
      );

      final unsynced = await db.loyaltyDao.getUnsyncedLoyalty();
      expect(unsynced.length, 1);
    });

    test('markLoyaltySynced يعين تاريخ المزامنة', () async {
      await db.loyaltyDao.createLoyalty(
        LoyaltyPointsTableCompanion.insert(
          id: 'loyalty-1',
          customerId: 'customer-1',
          storeId: 'store-1',
          currentPoints: const Value(100),
          totalEarned: const Value(100),
          totalRedeemed: const Value(0),
          tierLevel: const Value('bronze'),
        ),
      );

      await db.loyaltyDao.markLoyaltySynced('loyalty-1');

      final unsynced = await db.loyaltyDao.getUnsyncedLoyalty();
      expect(unsynced, isEmpty);
    });

    test('getUnsyncedTransactions يعيد المعاملات غير المزامنة', () async {
      await db.loyaltyDao.logTransaction(
        LoyaltyTransactionsTableCompanion.insert(
          id: 'trans-1',
          loyaltyId: 'loyalty-1',
          customerId: 'customer-1',
          storeId: 'store-1',
          transactionType: 'earn',
          points: 100,
          balanceAfter: 100,
        ),
      );

      final unsynced = await db.loyaltyDao.getUnsyncedTransactions();
      expect(unsynced.length, 1);
    });

    test('markTransactionSynced يعين تاريخ المزامنة للمعاملة', () async {
      await db.loyaltyDao.logTransaction(
        LoyaltyTransactionsTableCompanion.insert(
          id: 'trans-1',
          loyaltyId: 'loyalty-1',
          customerId: 'customer-1',
          storeId: 'store-1',
          transactionType: 'earn',
          points: 100,
          balanceAfter: 100,
        ),
      );

      await db.loyaltyDao.markTransactionSynced('trans-1');

      final unsynced = await db.loyaltyDao.getUnsyncedTransactions();
      expect(unsynced, isEmpty);
    });
  });

  group('LoyaltyStats', () {
    test('netPoints يحسب الصافي بشكل صحيح', () {
      const stats = LoyaltyStats(
        totalEarned: 1000,
        totalRedeemed: 300,
        activeCustomers: 5,
        totalTransactions: 10,
      );

      expect(stats.netPoints, 700);
    });

    test('netPoints يعيد صفر عندما الاسترداد يساوي المكتسب', () {
      const stats = LoyaltyStats(
        totalEarned: 500,
        totalRedeemed: 500,
        activeCustomers: 2,
        totalTransactions: 4,
      );

      expect(stats.netPoints, 0);
    });

    test('netPoints مع قيم صفرية', () {
      const stats = LoyaltyStats(
        totalEarned: 0,
        totalRedeemed: 0,
        activeCustomers: 0,
        totalTransactions: 0,
      );

      expect(stats.netPoints, 0);
    });
  });
}
