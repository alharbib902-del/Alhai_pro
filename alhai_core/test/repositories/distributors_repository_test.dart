import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/repositories/distributors_repository.dart';

/// Tests for DistributorStats helper class defined in distributors_repository.dart
/// DistributorsRepository is an abstract interface - no implementation to test yet.
void main() {
  group('DistributorStats', () {
    test('should construct with all required fields', () {
      const stats = DistributorStats(
        distributorId: 'dist-1',
        totalProducts: 100,
        activeProducts: 85,
        totalOrders: 500,
        pendingOrders: 10,
        totalRevenue: 250000.0,
        monthlyRevenue: 50000.0,
        connectedStores: 30,
        avgOrderValue: 500.0,
      );

      expect(stats.distributorId, equals('dist-1'));
      expect(stats.totalProducts, equals(100));
      expect(stats.activeProducts, equals(85));
      expect(stats.totalOrders, equals(500));
      expect(stats.pendingOrders, equals(10));
      expect(stats.totalRevenue, equals(250000.0));
      expect(stats.monthlyRevenue, equals(50000.0));
      expect(stats.connectedStores, equals(30));
      expect(stats.avgOrderValue, equals(500.0));
    });

    test('should handle zero stats for new distributor', () {
      const stats = DistributorStats(
        distributorId: 'new-dist',
        totalProducts: 0,
        activeProducts: 0,
        totalOrders: 0,
        pendingOrders: 0,
        totalRevenue: 0,
        monthlyRevenue: 0,
        connectedStores: 0,
        avgOrderValue: 0,
      );

      expect(stats.totalProducts, equals(0));
      expect(stats.totalRevenue, equals(0));
      expect(stats.connectedStores, equals(0));
    });
  });
}
