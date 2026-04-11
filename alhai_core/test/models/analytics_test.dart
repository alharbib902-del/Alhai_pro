import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/analytics.dart';

void main() {
  group('AlertType Extensions', () {
    test('displayNameAr should return Arabic names', () {
      expect(AlertType.lowStock.displayNameAr, equals('مخزون منخفض'));
      expect(AlertType.slowMoving.displayNameAr, equals('صنف راكد'));
      expect(
        AlertType.expiringSoon.displayNameAr,
        equals('قرب انتهاء الصلاحية'),
      );
      expect(AlertType.highDemand.displayNameAr, equals('طلب عالي'));
      expect(AlertType.debtOverdue.displayNameAr, equals('دين متأخر'));
      expect(AlertType.priceChange.displayNameAr, equals('تغير سعر'));
      expect(
        AlertType.reorderSuggestion.displayNameAr,
        equals('اقتراح إعادة طلب'),
      );
    });

    test('priority should return correct priority levels', () {
      expect(AlertType.expiringSoon.priority, equals(5));
      expect(AlertType.lowStock.priority, equals(4));
      expect(AlertType.highDemand.priority, equals(4));
      expect(AlertType.debtOverdue.priority, equals(3));
      expect(AlertType.slowMoving.priority, equals(2));
      expect(AlertType.priceChange.priority, equals(2));
      expect(AlertType.reorderSuggestion.priority, equals(1));
    });
  });

  group('SlowMovingProduct Model', () {
    group('riskLevel', () {
      test('should return very high for > 90 days', () {
        const product = SlowMovingProduct(
          productId: 'p1',
          productName: 'Product 1',
          daysSinceLastSale: 100,
          stockQty: 50,
          stockValue: 500.0,
        );
        expect(product.riskLevel, equals('عالي جداً'));
      });

      test('should return high for > 60 days', () {
        const product = SlowMovingProduct(
          productId: 'p1',
          productName: 'Product 1',
          daysSinceLastSale: 75,
          stockQty: 50,
          stockValue: 500.0,
        );
        expect(product.riskLevel, equals('عالي'));
      });

      test('should return medium for > 30 days', () {
        const product = SlowMovingProduct(
          productId: 'p1',
          productName: 'Product 1',
          daysSinceLastSale: 45,
          stockQty: 50,
          stockValue: 500.0,
        );
        expect(product.riskLevel, equals('متوسط'));
      });

      test('should return low for <= 30 days', () {
        const product = SlowMovingProduct(
          productId: 'p1',
          productName: 'Product 1',
          daysSinceLastSale: 20,
          stockQty: 50,
          stockValue: 500.0,
        );
        expect(product.riskLevel, equals('منخفض'));
      });
    });

    test('should serialize to JSON and back', () {
      const product = SlowMovingProduct(
        productId: 'p1',
        productName: 'Product 1',
        categoryName: 'Category A',
        daysSinceLastSale: 45,
        stockQty: 50,
        stockValue: 500.0,
        suggestedDiscount: 15.0,
      );
      final json = product.toJson();
      final restored = SlowMovingProduct.fromJson(json);

      expect(restored.productId, equals('p1'));
      expect(restored.daysSinceLastSale, equals(45));
      expect(restored.suggestedDiscount, equals(15.0));
    });
  });

  group('SalesForecast Model', () {
    group('confidenceLevel', () {
      test('should return high for confidence >= 0.8', () {
        final forecast = SalesForecast(
          date: DateTime(2026, 2, 1),
          predictedRevenue: 5000.0,
          predictedOrders: 50,
          confidence: 0.85,
        );
        expect(forecast.confidenceLevel, equals('عالي'));
      });

      test('should return medium for confidence >= 0.6', () {
        final forecast = SalesForecast(
          date: DateTime(2026, 2, 1),
          predictedRevenue: 5000.0,
          predictedOrders: 50,
          confidence: 0.7,
        );
        expect(forecast.confidenceLevel, equals('متوسط'));
      });

      test('should return low for confidence < 0.6', () {
        final forecast = SalesForecast(
          date: DateTime(2026, 2, 1),
          predictedRevenue: 5000.0,
          predictedOrders: 50,
          confidence: 0.4,
        );
        expect(forecast.confidenceLevel, equals('منخفض'));
      });
    });

    test('should serialize to JSON and back', () {
      final forecast = SalesForecast(
        date: DateTime(2026, 2, 1),
        predictedRevenue: 5000.0,
        predictedOrders: 50,
        confidence: 0.85,
        lowerBound: 4000.0,
        upperBound: 6000.0,
      );
      final json = forecast.toJson();
      final restored = SalesForecast.fromJson(json);

      expect(restored.predictedRevenue, equals(5000.0));
      expect(restored.confidence, equals(0.85));
      expect(restored.lowerBound, equals(4000.0));
    });
  });

  group('SmartAlert Model', () {
    test('priority should come from type', () {
      final alert = SmartAlert(
        id: 'alert-1',
        type: AlertType.lowStock,
        title: 'Low Stock Alert',
        message: 'Product running low',
        createdAt: DateTime(2026, 1, 15),
      );

      expect(alert.priority, equals(AlertType.lowStock.priority));
      expect(alert.priority, equals(4));
    });

    test('should default isRead to false', () {
      final alert = SmartAlert(
        id: 'alert-1',
        type: AlertType.lowStock,
        title: 'Alert',
        message: 'Test',
        createdAt: DateTime(2026, 1, 15),
      );

      expect(alert.isRead, isFalse);
    });

    test('should serialize to JSON and back', () {
      final alert = SmartAlert(
        id: 'alert-1',
        type: AlertType.expiringSoon,
        title: 'Expiring',
        message: 'Product expiring',
        actionLabel: 'View',
        actionRoute: '/products/p1',
        metadata: {'productId': 'p1'},
        createdAt: DateTime(2026, 1, 15),
      );
      final json = alert.toJson();
      final restored = SmartAlert.fromJson(json);

      expect(restored.id, equals('alert-1'));
      expect(restored.type, equals(AlertType.expiringSoon));
      expect(restored.actionLabel, equals('View'));
    });
  });

  group('ReorderSuggestion Model', () {
    group('urgency', () {
      test('should return urgent for <= 3 days until stockout', () {
        const suggestion = ReorderSuggestion(
          productId: 'p1',
          productName: 'Product 1',
          currentStock: 5,
          suggestedQuantity: 50,
          averageDailySales: 2.0,
          daysUntilStockout: 2,
        );
        expect(suggestion.urgency, equals('عاجل'));
      });

      test('should return important for <= 7 days until stockout', () {
        const suggestion = ReorderSuggestion(
          productId: 'p1',
          productName: 'Product 1',
          currentStock: 10,
          suggestedQuantity: 50,
          averageDailySales: 2.0,
          daysUntilStockout: 5,
        );
        expect(suggestion.urgency, equals('مهم'));
      });

      test('should return normal for > 7 days until stockout', () {
        const suggestion = ReorderSuggestion(
          productId: 'p1',
          productName: 'Product 1',
          currentStock: 20,
          suggestedQuantity: 50,
          averageDailySales: 2.0,
          daysUntilStockout: 10,
        );
        expect(suggestion.urgency, equals('عادي'));
      });
    });

    test('should serialize to JSON and back', () {
      const suggestion = ReorderSuggestion(
        productId: 'p1',
        productName: 'Product 1',
        currentStock: 5,
        suggestedQuantity: 50,
        averageDailySales: 2.5,
        daysUntilStockout: 2,
        preferredSupplierId: 'sup-1',
        preferredSupplierName: 'Supplier A',
      );
      final json = suggestion.toJson();
      final restored = ReorderSuggestion.fromJson(json);

      expect(restored.productId, equals('p1'));
      expect(restored.suggestedQuantity, equals(50));
      expect(restored.preferredSupplierId, equals('sup-1'));
    });
  });
}
