import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await seedTestData(db);
    // loyalty references customers via FK
    final now = DateTime(2025, 1, 1);
    for (var i = 0; i <= 4; i++) {
      await db.customersDao.insertCustomer(CustomersTableCompanion.insert(
        id: 'cust-$i',
        storeId: 'store-1',
        name: 'Cust $i',
        createdAt: now,
      ));
    }
  });

  tearDown(() async {
    await db.close();
  });

  LoyaltyPointsTableCompanion makeLoyalty({
    String id = 'lp-1',
    String customerId = 'cust-1',
    String storeId = 'store-1',
    int currentPoints = 100,
    int totalEarned = 200,
    int totalRedeemed = 100,
    String tierLevel = 'bronze',
  }) {
    return LoyaltyPointsTableCompanion.insert(
      id: id,
      customerId: customerId,
      storeId: storeId,
      currentPoints: Value(currentPoints),
      totalEarned: Value(totalEarned),
      totalRedeemed: Value(totalRedeemed),
      tierLevel: Value(tierLevel),
      createdAt: DateTime.now(),
    );
  }

  group('LoyaltyDao - Points', () {
    test('createLoyalty and getCustomerLoyalty', () async {
      await db.loyaltyDao.createLoyalty(makeLoyalty());

      final loyalty =
          await db.loyaltyDao.getCustomerLoyalty('cust-1', 'store-1');
      expect(loyalty, isNotNull);
      expect(loyalty!.currentPoints, 100);
      expect(loyalty.totalEarned, 200);
      expect(loyalty.tierLevel, 'bronze');
    });

    test('getLoyaltyById returns correct record', () async {
      await db.loyaltyDao.createLoyalty(makeLoyalty());

      final loyalty = await db.loyaltyDao.getLoyaltyById('lp-1');
      expect(loyalty, isNotNull);
      expect(loyalty!.customerId, 'cust-1');
    });

    test('addPoints increases points and totalEarned', () async {
      await db.loyaltyDao.createLoyalty(makeLoyalty(
        currentPoints: 100,
        totalEarned: 200,
      ));

      await db.loyaltyDao.addPoints('cust-1', 'store-1', 50);

      final loyalty =
          await db.loyaltyDao.getCustomerLoyalty('cust-1', 'store-1');
      expect(loyalty!.currentPoints, 150);
      expect(loyalty.totalEarned, 250);
    });

    test('redeemPoints decreases currentPoints', () async {
      await db.loyaltyDao.createLoyalty(makeLoyalty(currentPoints: 200));

      final result = await db.loyaltyDao.redeemPoints('cust-1', 'store-1', 50);
      expect(result, true);

      final loyalty =
          await db.loyaltyDao.getCustomerLoyalty('cust-1', 'store-1');
      expect(loyalty!.currentPoints, 150);
    });

    test('redeemPoints fails when insufficient points', () async {
      await db.loyaltyDao.createLoyalty(makeLoyalty(currentPoints: 30));

      final result = await db.loyaltyDao.redeemPoints('cust-1', 'store-1', 50);
      expect(result, false);
    });

    test('getAllLoyaltyAccounts returns all for store', () async {
      await db.loyaltyDao.createLoyalty(makeLoyalty());
      await db.loyaltyDao.createLoyalty(makeLoyalty(
        id: 'lp-2',
        customerId: 'cust-2',
        currentPoints: 500,
      ));

      final accounts = await db.loyaltyDao.getAllLoyaltyAccounts('store-1');
      expect(accounts, hasLength(2));
      // ordered by currentPoints desc
      expect(accounts.first.currentPoints, 500);
    });

    test('getTopCustomers returns limited results', () async {
      for (var i = 0; i < 5; i++) {
        await db.loyaltyDao.createLoyalty(makeLoyalty(
          id: 'lp-$i',
          customerId: 'cust-$i',
          totalEarned: i * 100,
        ));
      }

      final top = await db.loyaltyDao.getTopCustomers('store-1', limit: 3);
      expect(top, hasLength(3));
    });

    test('getCustomersByTier filters correctly', () async {
      await db.loyaltyDao.createLoyalty(makeLoyalty(
        id: 'lp-1',
        customerId: 'cust-1',
        tierLevel: 'gold',
      ));
      await db.loyaltyDao.createLoyalty(makeLoyalty(
        id: 'lp-2',
        customerId: 'cust-2',
        tierLevel: 'bronze',
      ));

      final gold = await db.loyaltyDao.getCustomersByTier('store-1', 'gold');
      expect(gold, hasLength(1));
      expect(gold.first.customerId, 'cust-1');
    });
  });

  group('LoyaltyDao - Transactions', () {
    test('logTransaction and getCustomerTransactions', () async {
      // Create prerequisite loyalty record (FK parent for loyaltyId)
      await db.loyaltyDao.createLoyalty(makeLoyalty());

      await db.loyaltyDao.logTransaction(
        LoyaltyTransactionsTableCompanion.insert(
          id: 'ltx-1',
          loyaltyId: 'lp-1',
          customerId: 'cust-1',
          storeId: 'store-1',
          transactionType: 'earn',
          points: 50,
          balanceAfter: 150,
          createdAt: DateTime.now(),
        ),
      );

      final txns =
          await db.loyaltyDao.getCustomerTransactions('cust-1', 'store-1');
      expect(txns, hasLength(1));
      expect(txns.first.transactionType, 'earn');
      expect(txns.first.points, 50);
    });
  });

  group('LoyaltyDao - Rewards', () {
    test('createReward and getRewardById', () async {
      await db.loyaltyDao.createReward(
        LoyaltyRewardsTableCompanion.insert(
          id: 'rew-1',
          storeId: 'store-1',
          name: 'خصم 10%',
          pointsRequired: 500,
          rewardType: 'discount_percentage',
          rewardValue: 10.0,
          createdAt: DateTime.now(),
        ),
      );

      final reward = await db.loyaltyDao.getRewardById('rew-1');
      expect(reward, isNotNull);
      expect(reward!.name, 'خصم 10%');
      expect(reward.pointsRequired, 500);
    });

    test('getAvailableRewards returns active non-expired rewards', () async {
      await db.loyaltyDao.createReward(
        LoyaltyRewardsTableCompanion.insert(
          id: 'rew-1',
          storeId: 'store-1',
          name: 'مكافأة نشطة',
          pointsRequired: 100,
          rewardType: 'discount_fixed',
          rewardValue: 5.0,
          isActive: const Value(true),
          createdAt: DateTime.now(),
        ),
      );
      await db.loyaltyDao.createReward(
        LoyaltyRewardsTableCompanion.insert(
          id: 'rew-2',
          storeId: 'store-1',
          name: 'مكافأة غير نشطة',
          pointsRequired: 50,
          rewardType: 'discount_fixed',
          rewardValue: 2.0,
          isActive: const Value(false),
          createdAt: DateTime.now(),
        ),
      );

      final available = await db.loyaltyDao.getAvailableRewards('store-1');
      expect(available, hasLength(1));
      expect(available.first.name, 'مكافأة نشطة');
    });

    test('deactivateReward sets isActive to false', () async {
      await db.loyaltyDao.createReward(
        LoyaltyRewardsTableCompanion.insert(
          id: 'rew-1',
          storeId: 'store-1',
          name: 'مكافأة',
          pointsRequired: 100,
          rewardType: 'free_item',
          rewardValue: 1.0,
          createdAt: DateTime.now(),
        ),
      );

      await db.loyaltyDao.deactivateReward('rew-1');

      final reward = await db.loyaltyDao.getRewardById('rew-1');
      expect(reward!.isActive, false);
    });
  });
}
