import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';

/// Helper to create a Product for stock tests
// C-4 Stage B: SAR × 100 = cents
Product _product({
  String id = 'p1',
  double stockQty = 100,
  double minQty = 5,
  bool trackInventory = true,
}) {
  return Product(
    id: id,
    storeId: 'store-1',
    name: 'Test Product',
    price: 2500,
    stockQty: stockQty,
    minQty: minQty,
    isActive: true,
    trackInventory: trackInventory,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  // ==========================================================================
  // LOW STOCK DETECTION
  // ==========================================================================
  group('Product.isLowStock', () {
    test('returns true when stockQty <= minQty', () {
      final product = _product(stockQty: 5, minQty: 5);
      expect(product.isLowStock, isTrue);
    });

    test('returns true when stockQty < minQty', () {
      final product = _product(stockQty: 3, minQty: 5);
      expect(product.isLowStock, isTrue);
    });

    test('returns false when stockQty > minQty', () {
      final product = _product(stockQty: 10, minQty: 5);
      expect(product.isLowStock, isFalse);
    });

    test('returns true when stockQty is 0', () {
      final product = _product(stockQty: 0, minQty: 5);
      expect(product.isLowStock, isTrue);
    });

    test('returns true when both are 0', () {
      final product = _product(stockQty: 0, minQty: 0);
      expect(product.isLowStock, isTrue);
    });

    test('returns true when stockQty is 1 and minQty is 1', () {
      final product = _product(stockQty: 1, minQty: 1);
      expect(product.isLowStock, isTrue);
    });
  });

  // ==========================================================================
  // OUT OF STOCK DETECTION
  // ==========================================================================
  group('Product.isOutOfStock', () {
    test('returns true when stockQty is 0', () {
      final product = _product(stockQty: 0);
      expect(product.isOutOfStock, isTrue);
    });

    test('returns false when stockQty is 1', () {
      final product = _product(stockQty: 1);
      expect(product.isOutOfStock, isFalse);
    });

    test('returns false when stockQty is high', () {
      final product = _product(stockQty: 999);
      expect(product.isOutOfStock, isFalse);
    });
  });

  // ==========================================================================
  // STOCK DEDUCTION LOGIC
  // ==========================================================================
  group('Stock deduction', () {
    test('deducting sold quantity from stock', () {
      final product = _product(stockQty: 50);
      const soldQty = 3;
      final newStock = product.stockQty - soldQty;

      expect(newStock, equals(47));
    });

    test('selling all remaining stock', () {
      final product = _product(stockQty: 5);
      const soldQty = 5;
      final newStock = product.stockQty - soldQty;

      expect(newStock, equals(0));
    });

    test('attempting to sell more than available is detected', () {
      final product = _product(stockQty: 3);
      const requestedQty = 5;
      final isInsufficient = product.stockQty < requestedQty;

      expect(isInsufficient, isTrue);
    });

    test('selling from zero stock is detected', () {
      final product = _product(stockQty: 0);
      const requestedQty = 1;

      expect(product.isOutOfStock, isTrue);
      expect(product.stockQty < requestedQty, isTrue);
    });

    test('deduction does not go negative when checked', () {
      final product = _product(stockQty: 10);
      const soldQty = 7;

      // Only deduct if sufficient
      final canSell = product.stockQty >= soldQty;
      expect(canSell, isTrue);

      final newStock = product.stockQty - soldQty;
      expect(newStock, equals(3));
      expect(newStock >= 0, isTrue);
    });
  });

  // ==========================================================================
  // STOCK ADDITION (RECEIVING / RETURN)
  // ==========================================================================
  group('Stock addition', () {
    test('receiving new stock', () {
      final product = _product(stockQty: 20);
      const receivedQty = 30;
      final newStock = product.stockQty + receivedQty;

      expect(newStock, equals(50));
    });

    test('return restores stock', () {
      final product = _product(stockQty: 47);
      const returnedQty = 3;
      final newStock = product.stockQty + returnedQty;

      expect(newStock, equals(50));
    });

    test('adding to zero stock', () {
      final product = _product(stockQty: 0);
      const addedQty = 100;
      final newStock = product.stockQty + addedQty;

      expect(newStock, equals(100));
    });
  });

  // ==========================================================================
  // LOW STOCK ALERT THRESHOLDS
  // ==========================================================================
  group('Low stock alert thresholds', () {
    test('just above threshold → not low', () {
      final product = _product(stockQty: 6, minQty: 5);
      expect(product.isLowStock, isFalse);
    });

    test('at threshold → low', () {
      final product = _product(stockQty: 5, minQty: 5);
      expect(product.isLowStock, isTrue);
    });

    test('just below threshold → low', () {
      final product = _product(stockQty: 4, minQty: 5);
      expect(product.isLowStock, isTrue);
    });

    test('custom high threshold', () {
      final product = _product(stockQty: 50, minQty: 100);
      expect(product.isLowStock, isTrue);
    });

    test('after sale: check if newly low', () {
      // Start above threshold
      final beforeSale = _product(stockQty: 10, minQty: 5);
      expect(beforeSale.isLowStock, isFalse);

      // After selling 6 → stock = 4 → now low
      final afterStock = beforeSale.stockQty - 6;
      final afterSale = _product(stockQty: afterStock, minQty: 5);
      expect(afterSale.isLowStock, isTrue);
    });
  });

  // ==========================================================================
  // SELL PREVENTION WITH ZERO STOCK
  // ==========================================================================
  group('Prevent sale at zero stock', () {
    test('trackInventory=true + stockQty=0 → should prevent sale', () {
      final product = _product(stockQty: 0, trackInventory: true);

      expect(product.trackInventory, isTrue);
      expect(product.isOutOfStock, isTrue);

      // Business rule: if trackInventory && isOutOfStock → block
      final shouldBlock = product.trackInventory && product.isOutOfStock;
      expect(shouldBlock, isTrue);
    });

    test('trackInventory=false + stockQty=0 → allow sale anyway', () {
      final product = _product(stockQty: 0, trackInventory: false);

      // Services that don't track inventory can always be sold
      final shouldBlock = product.trackInventory && product.isOutOfStock;
      expect(shouldBlock, isFalse);
    });

    test('trackInventory=true + stockQty > 0 → allow', () {
      final product = _product(stockQty: 1, trackInventory: true);

      final shouldBlock = product.trackInventory && product.isOutOfStock;
      expect(shouldBlock, isFalse);
    });

    test('requested qty exceeds available stock', () {
      final product = _product(stockQty: 3, trackInventory: true);
      const requestedQty = 5;

      final shouldBlock =
          product.trackInventory && product.stockQty < requestedQty;
      expect(shouldBlock, isTrue);
    });

    test('requested qty equals available stock → allow', () {
      final product = _product(stockQty: 5, trackInventory: true);
      const requestedQty = 5;

      final shouldBlock =
          product.trackInventory && product.stockQty < requestedQty;
      expect(shouldBlock, isFalse);
    });
  });

  // ==========================================================================
  // PROFIT MARGIN
  // ==========================================================================
  group('Product.profitMargin', () {
    test('calculates margin correctly', () {
      // C-4 Stage B: SAR × 100 = cents
      final product = Product(
        id: 'p1',
        storeId: 's1',
        name: 'Test',
        price: 3000,
        costPrice: 2000,
        stockQty: 10,
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
      );
      // (30-20)/20 * 100 = 50% (ratio invariant to cents/SAR)
      expect(product.profitMargin, closeTo(50.0, 0.01));
    });

    test('returns null when costPrice is null', () {
      final product = Product(
        id: 'p1',
        storeId: 's1',
        name: 'Test',
        price: 3000,
        stockQty: 10,
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(product.profitMargin, isNull);
    });

    test('returns null when costPrice is 0', () {
      final product = Product(
        id: 'p1',
        storeId: 's1',
        name: 'Test',
        price: 3000,
        costPrice: 0,
        stockQty: 10,
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(product.profitMargin, isNull);
    });

    test('negative margin when selling below cost', () {
      final product = Product(
        id: 'p1',
        storeId: 's1',
        name: 'Test',
        price: 1500,
        costPrice: 2000,
        stockQty: 10,
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
      );
      // (15-20)/20 * 100 = -25% (ratio invariant to cents/SAR)
      expect(product.profitMargin, closeTo(-25.0, 0.01));
    });
  });
}
