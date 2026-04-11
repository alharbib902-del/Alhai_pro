import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

class FakeLoyaltyRepository implements LoyaltyRepository {
  @override
  Future<LoyaltyAccount?> getAccount(String customerId) async => null;
  @override
  Future<LoyaltyAccount> createAccount(String customerId) async =>
      LoyaltyAccount(
        id: 'l-1',
        customerId: customerId,
        currentPoints: 0,
        totalPointsEarned: 0,
        totalPointsRedeemed: 0,
        tier: LoyaltyTier.bronze,
        createdAt: DateTime.now(),
      );
  @override
  Future<LoyaltyTier> getCustomerTier(String customerId) async =>
      LoyaltyTier.bronze;
  @override
  Future<LoyaltyTransaction> addPoints({
    required String customerId,
    required String orderId,
    required int points,
    String? description,
  }) async => LoyaltyTransaction(
    id: 'tx-1',
    customerId: customerId,
    type: LoyaltyTransactionType.earned,
    points: points,
    orderId: orderId,
    createdAt: DateTime.now(),
  );
  @override
  Future<LoyaltyTransaction> redeemPoints({
    required String customerId,
    required int points,
    required String orderId,
    String? description,
  }) async => LoyaltyTransaction(
    id: 'tx-2',
    customerId: customerId,
    type: LoyaltyTransactionType.redeemed,
    points: -points,
    orderId: orderId,
    createdAt: DateTime.now(),
  );
  @override
  Future<Paginated<LoyaltyTransaction>> getPointsHistory(
    String customerId, {
    int page = 1,
    int limit = 20,
  }) async => Paginated(items: [], total: 0, page: page, limit: limit);
  @override
  Future<List<LoyaltyReward>> getAvailableRewards(String storeId) async => [];
  @override
  Future<LoyaltyRedemption> redeemReward({
    required String customerId,
    required String rewardId,
  }) async => LoyaltyRedemption(
    id: 'red-1',
    customerId: customerId,
    rewardId: rewardId,
    pointsUsed: 100,
    createdAt: DateTime.now(),
  );
}

void main() {
  late LoyaltyService loyaltyService;
  setUp(() {
    loyaltyService = LoyaltyService(FakeLoyaltyRepository());
  });

  group('LoyaltyService', () {
    test('should be created', () {
      expect(loyaltyService, isNotNull);
    });
    test('getAccount should return null for new customer', () async {
      expect(await loyaltyService.getAccount('cust-1'), isNull);
    });
    test('createAccount should create account', () async {
      final account = await loyaltyService.createAccount('cust-1');
      expect(account.customerId, equals('cust-1'));
      expect(account.currentPoints, equals(0));
    });
    test('getCustomerTier should return tier', () async {
      expect(
        await loyaltyService.getCustomerTier('cust-1'),
        equals(LoyaltyTier.bronze),
      );
    });
    test('addPoints should create transaction', () async {
      final tx = await loyaltyService.addPoints(
        customerId: 'cust-1',
        orderId: 'order-1',
        points: 50,
      );
      expect(tx.points, equals(50));
      expect(tx.type, equals(LoyaltyTransactionType.earned));
    });
    test('redeemPoints should create negative transaction', () async {
      final tx = await loyaltyService.redeemPoints(
        customerId: 'cust-1',
        points: 30,
        orderId: 'order-2',
      );
      expect(tx.points, equals(-30));
      expect(tx.type, equals(LoyaltyTransactionType.redeemed));
    });
    test('calculatePoints should compute correctly', () {
      expect(loyaltyService.calculatePoints(100.0, 1), equals(100));
      expect(loyaltyService.calculatePoints(50.0, 2), equals(100));
      expect(loyaltyService.calculatePoints(33.33, 1), equals(33));
      expect(loyaltyService.calculatePoints(0.0, 1), equals(0));
    });
    test('redeemReward should return redemption', () async {
      final r = await loyaltyService.redeemReward(
        customerId: 'c1',
        rewardId: 'r1',
      );
      expect(r.rewardId, equals('r1'));
    });
  });
}
