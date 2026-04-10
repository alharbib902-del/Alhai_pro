import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

class FakeDistributorsRepo implements DistributorsRepository {
  @override
  Future<Distributor> getDistributor(String id) async =>
      throw UnimplementedError();
  @override
  Future<Distributor?> getByUserId(String userId) async => null;
  @override
  Future<Paginated<Distributor>> getDistributors(
          {int page = 1,
          int limit = 20,
          DistributorStatus? status,
          DistributorTier? tier,
          String? search}) async =>
      Paginated(items: [], total: 0, page: page, limit: limit);
  @override
  Future<Distributor> createDistributor(
          {required String userId,
          required String companyName,
          required String commercialRegister,
          required String vatNumber,
          String? companyNameEn,
          String? logoUrl,
          String? address,
          String? city,
          String? phone,
          String? email,
          String? website}) async =>
      Distributor(
          id: 'dist-1',
          userId: userId,
          companyName: companyName,
          commercialRegister: commercialRegister,
          vatNumber: vatNumber,
          createdAt: DateTime.now());
  @override
  Future<Distributor> updateDistributor(
          String id, Map<String, dynamic> data) async =>
      throw UnimplementedError();
  @override
  Future<Distributor> approveDistributor(String id, String approvedBy) async =>
      throw UnimplementedError();
  @override
  Future<Distributor> rejectDistributor(
          String id, String rejectedBy, String reason) async =>
      throw UnimplementedError();
  @override
  Future<Distributor> suspendDistributor(String id, String reason) async =>
      throw UnimplementedError();
  @override
  Future<Distributor> upgradeTier(String id, DistributorTier tier) async =>
      throw UnimplementedError();
  @override
  Future<Distributor> toggleFeatured(String id, bool isFeatured) async =>
      throw UnimplementedError();
  @override
  Future<DistributorStats> getStats(String distributorId) async =>
      DistributorStats(
          distributorId: distributorId,
          totalProducts: 50,
          activeProducts: 40,
          totalOrders: 100,
          pendingOrders: 5,
          totalRevenue: 25000.0,
          monthlyRevenue: 5000.0,
          connectedStores: 10,
          avgOrderValue: 250.0);
}

void main() {
  late DistributorService distributorService;
  setUp(() {
    distributorService = DistributorService(FakeDistributorsRepo());
  });

  group('DistributorService', () {
    test('should be created', () {
      expect(distributorService, isNotNull);
    });

    test('getDistributorByUserId should return null for unknown', () async {
      expect(
          await distributorService.getDistributorByUserId('unknown'), isNull);
    });

    test('applyAsDistributor should create distributor', () async {
      final dist = await distributorService.applyAsDistributor(
        userId: 'user-1',
        companyName: 'Test Co',
        commercialRegister: 'CR1',
        vatNumber: 'VAT1',
      );
      expect(dist.companyName, equals('Test Co'));
      expect(dist.status, equals(DistributorStatus.pending));
    });

    test('getDistributors should return paginated', () async {
      final result = await distributorService.getDistributors();
      expect(result, isA<Paginated<Distributor>>());
    });

    test('getStats should return stats', () async {
      final stats = await distributorService.getStats('dist-1');
      expect(stats.totalOrders, equals(100));
      expect(stats.totalRevenue, equals(25000.0));
      expect(stats.connectedStores, equals(10));
    });
  });
}
