import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/distributor.dart';

void main() {
  group('Distributor Model', () {
    Distributor createDistributor({
      String id = 'dist-1',
      DistributorStatus status = DistributorStatus.approved,
      DistributorTier tier = DistributorTier.free,
      double avgRating = 0,
      int ratingCount = 0,
    }) {
      return Distributor(
        id: id,
        userId: 'user-1',
        companyName: 'Test Distributor',
        commercialRegister: 'CR-12345',
        vatNumber: 'VAT-12345',
        status: status,
        tier: tier,
        avgRating: avgRating,
        ratingCount: ratingCount,
        createdAt: DateTime(2026, 1, 15),
      );
    }

    group('canSell', () {
      test('should return true for approved distributor', () {
        final dist = createDistributor(status: DistributorStatus.approved);
        expect(dist.canSell, isTrue);
      });

      test('should return false for pending distributor', () {
        final dist = createDistributor(status: DistributorStatus.pending);
        expect(dist.canSell, isFalse);
      });

      test('should return false for suspended distributor', () {
        final dist = createDistributor(status: DistributorStatus.suspended);
        expect(dist.canSell, isFalse);
      });

      test('should return false for rejected distributor', () {
        final dist = createDistributor(status: DistributorStatus.rejected);
        expect(dist.canSell, isFalse);
      });
    });

    group('isPending', () {
      test('should return true for pending status', () {
        final dist = createDistributor(status: DistributorStatus.pending);
        expect(dist.isPending, isTrue);
      });

      test('should return false for approved status', () {
        final dist = createDistributor(status: DistributorStatus.approved);
        expect(dist.isPending, isFalse);
      });
    });

    group('displayRating', () {
      test('should show formatted rating when has ratings', () {
        final dist = createDistributor(avgRating: 4.5, ratingCount: 10);
        expect(dist.displayRating, equals('4.5'));
      });

      test('should show dash when no ratings', () {
        final dist = createDistributor(avgRating: 0, ratingCount: 0);
        expect(dist.displayRating, equals('-'));
      });
    });

    group('serialization', () {
      test('should create Distributor from JSON', () {
        final json = {
          'id': 'dist-1',
          'userId': 'user-1',
          'companyName': 'Test Co',
          'commercialRegister': 'CR-001',
          'vatNumber': 'VAT-001',
          'status': 'APPROVED',
          'tier': 'PRO',
          'totalProducts': 50,
          'totalOrders': 100,
          'totalRevenue': 50000.0,
          'avgRating': 4.2,
          'ratingCount': 25,
          'isFeatured': true,
          'createdAt': '2026-01-15T00:00:00.000',
        };

        final dist = Distributor.fromJson(json);

        expect(dist.id, equals('dist-1'));
        expect(dist.status, equals(DistributorStatus.approved));
        expect(dist.tier, equals(DistributorTier.pro));
        expect(dist.totalProducts, equals(50));
        expect(dist.isFeatured, isTrue);
      });

      test('should serialize to JSON and back', () {
        final dist = createDistributor(
          tier: DistributorTier.enterprise,
          status: DistributorStatus.approved,
        );
        final json = dist.toJson();
        final restored = Distributor.fromJson(json);

        expect(restored.id, equals(dist.id));
        expect(restored.tier, equals(DistributorTier.enterprise));
        expect(restored.status, equals(DistributorStatus.approved));
      });
    });
  });

  group('DistributorStatus Extensions', () {
    test('displayNameAr should return Arabic names', () {
      expect(DistributorStatus.pending.displayNameAr, equals('قيد المراجعة'));
      expect(DistributorStatus.approved.displayNameAr, equals('معتمد'));
      expect(DistributorStatus.suspended.displayNameAr, equals('موقوف'));
      expect(DistributorStatus.rejected.displayNameAr, equals('مرفوض'));
    });

    test('isActive should only be true for approved', () {
      expect(DistributorStatus.approved.isActive, isTrue);
      expect(DistributorStatus.pending.isActive, isFalse);
      expect(DistributorStatus.suspended.isActive, isFalse);
      expect(DistributorStatus.rejected.isActive, isFalse);
    });
  });

  group('DistributorTier Extensions', () {
    test('displayNameAr should return Arabic names', () {
      expect(DistributorTier.free.displayNameAr, equals('مجاني'));
      expect(DistributorTier.pro.displayNameAr, equals('احترافي'));
      expect(DistributorTier.enterprise.displayNameAr, equals('مؤسسي'));
    });

    test('monthlyFee should return correct fees', () {
      expect(DistributorTier.free.monthlyFee, equals(0));
      expect(DistributorTier.pro.monthlyFee, equals(500));
      expect(DistributorTier.enterprise.monthlyFee, equals(1000));
    });

    test('transactionFeePercent should decrease with higher tiers', () {
      expect(DistributorTier.free.transactionFeePercent, equals(3.0));
      expect(DistributorTier.pro.transactionFeePercent, equals(2.0));
      expect(DistributorTier.enterprise.transactionFeePercent, equals(1.5));
    });
  });
}
