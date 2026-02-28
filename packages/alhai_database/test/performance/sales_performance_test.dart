import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  SalesTableCompanion _makeSale({
    required String id,
    String storeId = 'store-1',
    required String receiptNo,
    String cashierId = 'cashier-1',
    double subtotal = 100.0,
    double total = 100.0,
    String paymentMethod = 'cash',
    String status = 'completed',
    required DateTime createdAt,
  }) {
    return SalesTableCompanion.insert(
      id: id,
      storeId: storeId,
      receiptNo: receiptNo,
      cashierId: cashierId,
      subtotal: subtotal,
      total: total,
      paymentMethod: paymentMethod,
      status: Value(status),
      createdAt: createdAt,
    );
  }

  SaleItemsTableCompanion _makeSaleItem({
    required String id,
    required String saleId,
    required String productId,
    String productName = 'Test Product',
    double qty = 1,
    double unitPrice = 10.0,
    double subtotal = 10.0,
    double total = 10.0,
  }) {
    return SaleItemsTableCompanion.insert(
      id: id,
      saleId: saleId,
      productId: productId,
      productName: productName,
      qty: qty,
      unitPrice: unitPrice,
      subtotal: subtotal,
      total: total,
    );
  }

  group('Sales Insert Performance', () {
    setUp(() {
      db = createTestDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    test('insert 500 sales with items in batch completes under 5s', () async {
      // First, insert some products for sale items to reference
      for (int i = 0; i < 10; i++) {
        await db.productsDao.insertProduct(ProductsTableCompanion.insert(
          id: 'prod_$i',
          storeId: 'store-1',
          name: 'Product $i',
          price: 10.0 + i,
          createdAt: DateTime(2025, 1, 1),
        ));
      }

      final sw = Stopwatch()..start();

      for (int i = 0; i < 500; i++) {
        final saleId = 'sale_$i';
        final baseDate = DateTime(2025, 6, 1).add(Duration(hours: i));

        await db.salesDao.insertSale(_makeSale(
          id: saleId,
          receiptNo: 'REC-${i.toString().padLeft(4, '0')}',
          total: 50.0 + (i % 100),
          subtotal: 50.0 + (i % 100),
          createdAt: baseDate,
        ));

        // Each sale has 2 items
        await db.saleItemsDao.insertItems([
          _makeSaleItem(
            id: 'item_${i}_0',
            saleId: saleId,
            productId: 'prod_${i % 10}',
            productName: 'Product ${i % 10}',
            qty: 1 + (i % 3),
            unitPrice: 20.0,
            subtotal: 20.0 * (1 + (i % 3)),
            total: 20.0 * (1 + (i % 3)),
          ),
          _makeSaleItem(
            id: 'item_${i}_1',
            saleId: saleId,
            productId: 'prod_${(i + 5) % 10}',
            productName: 'Product ${(i + 5) % 10}',
            qty: 1,
            unitPrice: 30.0,
            subtotal: 30.0,
            total: 30.0,
          ),
        ]);
      }

      sw.stop();

      // Verify data was inserted correctly using getSalesCount (avoids deletedAt issue)
      final salesCount = await db.salesDao.getSalesCount('store-1');
      expect(salesCount, 500);

      expect(sw.elapsedMilliseconds, lessThan(5000),
          reason: 'Inserting 500 sales with items should complete under 5s '
              '(actual: ${sw.elapsedMilliseconds}ms)');
    });
  });

  group('Sales Query By Date Range Performance', () {
    setUp(() async {
      db = createTestDatabase();

      // Seed 500 sales spread across 30 days in June 2025
      for (int i = 0; i < 500; i++) {
        final day = (i % 30) + 1;
        final hour = i % 24;
        await db.salesDao.insertSale(_makeSale(
          id: 'sale_$i',
          receiptNo: 'REC-${i.toString().padLeft(4, '0')}',
          total: 50.0 + (i % 200),
          subtotal: 50.0 + (i % 200),
          createdAt: DateTime(2025, 6, day, hour, i % 60),
        ));
      }
    });

    tearDown(() async {
      await db.close();
    });

    test('getSalesPaginated for 7-day date range completes under 200ms', () async {
      final sw = Stopwatch()..start();
      final results = await db.salesDao.getSalesPaginated(
        'store-1',
        startDate: DateTime(2025, 6, 10),
        endDate: DateTime(2025, 6, 17),
        offset: 0,
        limit: 500, // large limit to get all in range
      );
      sw.stop();

      expect(results, isNotEmpty, reason: 'Date range query should return results');
      expect(sw.elapsedMilliseconds, lessThan(200),
          reason: 'Date range query over 500 sales should complete under 200ms '
              '(actual: ${sw.elapsedMilliseconds}ms)');
    });

    test('getSalesStats for single day completes under 100ms', () async {
      final sw = Stopwatch()..start();
      final stats = await db.salesDao.getSalesStats(
        'store-1',
        startDate: DateTime(2025, 6, 15),
        endDate: DateTime(2025, 6, 16),
      );
      sw.stop();

      expect(stats.count, greaterThan(0), reason: 'Single day stats should have results');
      expect(sw.elapsedMilliseconds, lessThan(100),
          reason: 'Single day stats should complete under 100ms '
              '(actual: ${sw.elapsedMilliseconds}ms)');
    });

    test('getSalesPaginated with date filter completes under 100ms', () async {
      final sw = Stopwatch()..start();
      final results = await db.salesDao.getSalesPaginated(
        'store-1',
        startDate: DateTime(2025, 6, 10),
        endDate: DateTime(2025, 6, 20),
        offset: 0,
        limit: 20,
      );
      sw.stop();

      expect(results, isNotEmpty);
      expect(results.length, lessThanOrEqualTo(20));
      expect(sw.elapsedMilliseconds, lessThan(100),
          reason: 'Paginated sales with date filter should complete under 100ms '
              '(actual: ${sw.elapsedMilliseconds}ms)');
    });
  });

  group('Sales Aggregation Performance', () {
    setUp(() async {
      db = createTestDatabase();

      // Seed 500 completed sales for aggregation testing
      for (int i = 0; i < 500; i++) {
        await db.salesDao.insertSale(_makeSale(
          id: 'sale_$i',
          receiptNo: 'REC-${i.toString().padLeft(4, '0')}',
          total: 25.0 + (i % 300),
          subtotal: 25.0 + (i % 300),
          paymentMethod: i % 3 == 0 ? 'cash' : (i % 3 == 1 ? 'card' : 'mixed'),
          createdAt: DateTime(2025, 6, (i % 30) + 1, i % 24),
        ));
      }
    });

    tearDown(() async {
      await db.close();
    });

    test('getSalesStats aggregation completes under 100ms', () async {
      final sw = Stopwatch()..start();
      final stats = await db.salesDao.getSalesStats('store-1');
      sw.stop();

      expect(stats.count, 500, reason: 'Should count all 500 sales');
      expect(stats.total, greaterThan(0), reason: 'Total should be positive');
      expect(stats.average, greaterThan(0), reason: 'Average should be positive');
      expect(stats.maxSale, greaterThanOrEqualTo(stats.minSale));
      expect(sw.elapsedMilliseconds, lessThan(100),
          reason: 'Sales stats aggregation should complete under 100ms '
              '(actual: ${sw.elapsedMilliseconds}ms)');
    });

    test('getSalesCount completes under 50ms', () async {
      final sw = Stopwatch()..start();
      final count = await db.salesDao.getSalesCount('store-1');
      sw.stop();

      expect(count, 500);
      expect(sw.elapsedMilliseconds, lessThan(50),
          reason: 'Sales count should complete under 50ms '
              '(actual: ${sw.elapsedMilliseconds}ms)');
    });

    test('getSalesStats with date range filter completes under 100ms', () async {
      final sw = Stopwatch()..start();
      final stats = await db.salesDao.getSalesStats(
        'store-1',
        startDate: DateTime(2025, 6, 10),
        endDate: DateTime(2025, 6, 20),
      );
      sw.stop();

      expect(stats.count, greaterThan(0), reason: 'Filtered stats should have results');
      expect(sw.elapsedMilliseconds, lessThan(100),
          reason: 'Filtered sales stats should complete under 100ms '
              '(actual: ${sw.elapsedMilliseconds}ms)');
    });
  });
}
