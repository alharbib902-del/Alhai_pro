import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/sales_report.dart';

void main() {
  group('SalesSummary Model', () {
    group('profitMargin', () {
      test('should calculate profit margin correctly', () {
        final summary = SalesSummary(
          date: DateTime(2026, 1, 15),
          ordersCount: 10,
          itemsSold: 50,
          revenue: 1000.0,
          cost: 600.0,
          profit: 400.0,
        );

        expect(summary.profitMargin, closeTo(40.0, 0.01));
      });

      test('should return 0 when revenue is 0', () {
        final summary = SalesSummary(
          date: DateTime(2026, 1, 15),
          ordersCount: 0,
          itemsSold: 0,
          revenue: 0,
          cost: 0,
          profit: 0,
        );

        expect(summary.profitMargin, equals(0));
      });
    });

    group('averageOrderValue', () {
      test('should calculate average order value', () {
        final summary = SalesSummary(
          date: DateTime(2026, 1, 15),
          ordersCount: 5,
          itemsSold: 20,
          revenue: 500.0,
          cost: 300.0,
          profit: 200.0,
        );

        expect(summary.averageOrderValue, equals(100.0));
      });

      test('should return 0 when no orders', () {
        final summary = SalesSummary(
          date: DateTime(2026, 1, 15),
          ordersCount: 0,
          itemsSold: 0,
          revenue: 0,
          cost: 0,
          profit: 0,
        );

        expect(summary.averageOrderValue, equals(0));
      });
    });

    group('serialization', () {
      test('should create SalesSummary from JSON', () {
        final json = {
          'date': '2026-01-15T00:00:00.000',
          'ordersCount': 10,
          'itemsSold': 50,
          'revenue': 1000.0,
          'cost': 600.0,
          'profit': 400.0,
          'discounts': 50.0,
          'returns': 20.0,
        };

        final summary = SalesSummary.fromJson(json);

        expect(summary.ordersCount, equals(10));
        expect(summary.revenue, equals(1000.0));
        expect(summary.discounts, equals(50.0));
        expect(summary.returns, equals(20.0));
      });

      test('should serialize to JSON and back', () {
        final summary = SalesSummary(
          date: DateTime(2026, 1, 15),
          ordersCount: 10,
          itemsSold: 50,
          revenue: 1000.0,
          cost: 600.0,
          profit: 400.0,
          discounts: 50.0,
          returns: 20.0,
        );
        final json = summary.toJson();
        final restored = SalesSummary.fromJson(json);

        expect(restored.revenue, equals(1000.0));
        expect(restored.profit, equals(400.0));
        expect(restored.discounts, equals(50.0));
      });
    });
  });

  group('ProductSales Model', () {
    group('profitMargin', () {
      test('should calculate profit margin correctly', () {
        const sales = ProductSales(
          productId: 'p1',
          productName: 'Product 1',
          quantitySold: 100,
          revenue: 5000.0,
          cost: 3000.0,
          profit: 2000.0,
        );

        expect(sales.profitMargin, closeTo(40.0, 0.01));
      });

      test('should return 0 when revenue is 0', () {
        const sales = ProductSales(
          productId: 'p1',
          productName: 'Product 1',
          quantitySold: 0,
          revenue: 0,
          cost: 0,
          profit: 0,
        );

        expect(sales.profitMargin, equals(0));
      });
    });

    group('serialization', () {
      test('should create ProductSales from JSON', () {
        final json = {
          'productId': 'p1',
          'productName': 'Product 1',
          'categoryId': 'cat-1',
          'quantitySold': 100,
          'revenue': 5000.0,
          'cost': 3000.0,
          'profit': 2000.0,
        };

        final sales = ProductSales.fromJson(json);

        expect(sales.productId, equals('p1'));
        expect(sales.quantitySold, equals(100));
        expect(sales.revenue, equals(5000.0));
        expect(sales.categoryId, equals('cat-1'));
      });
    });
  });

  group('CategorySales Model', () {
    test('should create from JSON', () {
      final json = {
        'categoryId': 'cat-1',
        'categoryName': 'Electronics',
        'productsSold': 50,
        'revenue': 10000.0,
        'profit': 3000.0,
      };

      final sales = CategorySales.fromJson(json);

      expect(sales.categoryId, equals('cat-1'));
      expect(sales.productsSold, equals(50));
      expect(sales.revenue, equals(10000.0));
    });
  });

  group('InventoryValue Model', () {
    test('should create from JSON', () {
      final json = {
        'totalProducts': 100,
        'totalUnits': 5000,
        'costValue': 100000.0,
        'retailValue': 150000.0,
        'lowStockCount': 5,
        'outOfStockCount': 2,
      };

      final inventory = InventoryValue.fromJson(json);

      expect(inventory.totalProducts, equals(100));
      expect(inventory.totalUnits, equals(5000));
      expect(inventory.costValue, equals(100000.0));
      expect(inventory.retailValue, equals(150000.0));
      expect(inventory.lowStockCount, equals(5));
      expect(inventory.outOfStockCount, equals(2));
    });

    test('should serialize to JSON and back', () {
      const inventory = InventoryValue(
        totalProducts: 100,
        totalUnits: 5000,
        costValue: 100000.0,
        retailValue: 150000.0,
        lowStockCount: 5,
        outOfStockCount: 2,
      );
      final json = inventory.toJson();
      final restored = InventoryValue.fromJson(json);

      expect(restored.totalProducts, equals(100));
      expect(restored.retailValue, equals(150000.0));
    });
  });
}
