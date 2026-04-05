import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/wholesale_order.dart';
import 'package:alhai_core/src/repositories/wholesale_orders_repository.dart';

/// Tests for WholesaleOrderSummary helper class defined in wholesale_orders_repository.dart
/// WholesaleOrdersRepository is an abstract interface - no implementation to test yet.
void main() {
  group('WholesaleOrderSummary', () {
    test('should construct with all required fields', () {
      const summary = WholesaleOrderSummary(
        distributorId: 'dist-1',
        totalOrders: 100,
        pendingOrders: 10,
        completedOrders: 80,
        cancelledOrders: 10,
        totalRevenue: 500000.0,
        avgOrderValue: 5000.0,
        byStatus: {
          WholesaleOrderStatus.pending: 10,
          WholesaleOrderStatus.confirmed: 5,
          WholesaleOrderStatus.processing: 3,
          WholesaleOrderStatus.shipped: 2,
          WholesaleOrderStatus.delivered: 80,
        },
      );

      expect(summary.distributorId, equals('dist-1'));
      expect(summary.totalOrders, equals(100));
      expect(summary.pendingOrders, equals(10));
      expect(summary.completedOrders, equals(80));
      expect(summary.cancelledOrders, equals(10));
      expect(summary.totalRevenue, equals(500000.0));
      expect(summary.avgOrderValue, equals(5000.0));
      expect(summary.byStatus[WholesaleOrderStatus.delivered], equals(80));
    });

    test('should handle empty stats', () {
      const summary = WholesaleOrderSummary(
        distributorId: 'new-dist',
        totalOrders: 0,
        pendingOrders: 0,
        completedOrders: 0,
        cancelledOrders: 0,
        totalRevenue: 0,
        avgOrderValue: 0,
        byStatus: {},
      );

      expect(summary.totalOrders, equals(0));
      expect(summary.byStatus, isEmpty);
    });
  });
}
