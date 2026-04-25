import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await seedTestData(db);
  });

  tearDown(() async {
    await db.close();
  });

  SalesTableCompanion makeSale({
    String id = 'sale-1',
    String storeId = 'store-1',
    String receiptNo = 'REC-001',
    String cashierId = 'cashier-1',
    double subtotal = 100.0,
    double total = 100.0,
    String paymentMethod = 'cash',
    String status = 'completed',
    DateTime? createdAt,
  }) {
    return SalesTableCompanion.insert(
      id: id,
      storeId: storeId,
      receiptNo: receiptNo,
      cashierId: cashierId,
      // C-4 Session 3: sales money columns are int cents. Helper keeps the
      // double SAR API for readability; convert at the Value() boundary.
      subtotal: (subtotal * 100).round(),
      total: (total * 100).round(),
      paymentMethod: paymentMethod,
      status: Value(status),
      createdAt: createdAt ?? DateTime(2025, 6, 15, 10, 30),
    );
  }

  group('SalesDao', () {
    test('insertSale and getSaleById', () async {
      await db.salesDao.insertSale(makeSale());

      final sale = await db.salesDao.getSaleById('sale-1');
      expect(sale, isNotNull);
      expect(sale!.receiptNo, 'REC-001');
      expect(sale.total, 10000); // 100.00 SAR in cents (C-4 Session 3)
      expect(sale.paymentMethod, 'cash');
    });

    test('getSaleById returns null for non-existent', () async {
      final sale = await db.salesDao.getSaleById('non-existent');
      expect(sale, isNull);
    });

    test('getAllSales returns sales for store ordered by date desc', () async {
      await db.salesDao.insertSale(
        makeSale(id: 'sale-1', createdAt: DateTime(2025, 6, 15, 10, 0)),
      );
      await db.salesDao.insertSale(
        makeSale(
          id: 'sale-2',
          receiptNo: 'REC-002',
          createdAt: DateTime(2025, 6, 15, 14, 0),
        ),
      );

      final sales = await db.salesDao.getAllSales('store-1');
      expect(sales, hasLength(2));
      // Most recent first
      expect(sales.first.id, 'sale-2');
    });

    test('getSaleByReceiptNo finds correct sale', () async {
      await db.salesDao.insertSale(makeSale());

      final sale = await db.salesDao.getSaleByReceiptNo('REC-001', 'store-1');
      expect(sale, isNotNull);
      expect(sale!.id, 'sale-1');
    });

    test('getSalesByDateRange filters by date', () async {
      await db.salesDao.insertSale(
        makeSale(
          id: 'sale-jan',
          receiptNo: 'R-JAN',
          createdAt: DateTime(2025, 1, 15),
        ),
      );
      await db.salesDao.insertSale(
        makeSale(
          id: 'sale-jun',
          receiptNo: 'R-JUN',
          createdAt: DateTime(2025, 6, 15),
        ),
      );

      final results = await db.salesDao.getSalesByDateRange(
        'store-1',
        DateTime(2025, 6, 1),
        DateTime(2025, 6, 30),
      );
      expect(results, hasLength(1));
      expect(results.first.id, 'sale-jun');
    });

    test('voidSale sets status to voided', () async {
      await db.salesDao.insertSale(makeSale());

      await db.salesDao.voidSale('sale-1');

      final sale = await db.salesDao.getSaleById('sale-1');
      expect(sale!.status, 'voided');
    });

    test('markAsSynced sets syncedAt', () async {
      await db.salesDao.insertSale(makeSale());

      await db.salesDao.markAsSynced('sale-1');

      final sale = await db.salesDao.getSaleById('sale-1');
      expect(sale!.syncedAt, isNotNull);
    });

    test('getUnsyncedSales returns sales without syncedAt', () async {
      await db.salesDao.insertSale(makeSale());
      await db.salesDao.insertSale(
        makeSale(id: 'sale-2', receiptNo: 'REC-002'),
      );
      await db.salesDao.markAsSynced('sale-1');

      final unsynced = await db.salesDao.getUnsyncedSales();
      expect(unsynced, hasLength(1));
      expect(unsynced.first.id, 'sale-2');
    });

    test('getSalesPaginated respects limit and offset', () async {
      for (var i = 0; i < 10; i++) {
        await db.salesDao.insertSale(
          makeSale(
            id: 'sale-$i',
            receiptNo: 'REC-$i',
            createdAt: DateTime(2025, 6, 15, i),
          ),
        );
      }

      final page1 = await db.salesDao.getSalesPaginated(
        'store-1',
        offset: 0,
        limit: 3,
      );
      expect(page1, hasLength(3));

      final page2 = await db.salesDao.getSalesPaginated(
        'store-1',
        offset: 3,
        limit: 3,
      );
      expect(page2, hasLength(3));
    });

    test('getSalesCount returns correct count', () async {
      for (var i = 0; i < 5; i++) {
        await db.salesDao.insertSale(
          makeSale(id: 'sale-$i', receiptNo: 'REC-$i'),
        );
      }

      final count = await db.salesDao.getSalesCount('store-1');
      expect(count, 5);
    });

    test('getSalesPaginated filters by status', () async {
      await db.salesDao.insertSale(makeSale(id: 'sale-1', status: 'completed'));
      await db.salesDao.insertSale(
        makeSale(id: 'sale-2', receiptNo: 'REC-002', status: 'voided'),
      );

      final completedSales = await db.salesDao.getSalesPaginated(
        'store-1',
        status: 'completed',
      );
      expect(completedSales, hasLength(1));
      expect(completedSales.first.id, 'sale-1');
    });

    test('getSalesStats returns correct statistics', () async {
      await db.salesDao.insertSale(makeSale(id: 'sale-1', total: 50.0));
      await db.salesDao.insertSale(
        makeSale(id: 'sale-2', receiptNo: 'REC-002', total: 150.0),
      );

      final stats = await db.salesDao.getSalesStats('store-1');
      expect(stats.count, 2);
      expect(stats.total, 200.0);
      expect(stats.average, 100.0);
      expect(stats.maxSale, 150.0);
      expect(stats.minSale, 50.0);
    });

    // ─── Wave 8 (P0-33): aggregatePaymentBreakdownRaw ────────────────
    group('aggregatePaymentBreakdownRaw', () {
      test('empty store returns zeroed RawPaymentBreakdown', () async {
        final raw = await db.salesDao.aggregatePaymentBreakdownRaw('store-1');
        expect(raw.totalCents, 0);
        expect(raw.cashCents, 0);
        expect(raw.cardCents, 0);
        expect(raw.creditCents, 0);
        expect(raw.includedCount, 0);
        expect(raw.excludedCount, 0);
      });

      test('legacy single-tender rows bucket by payment_method', () async {
        await db.salesDao.insertSale(
          makeSale(id: 's-cash', total: 100.0, paymentMethod: 'cash'),
        );
        await db.salesDao.insertSale(
          makeSale(
            id: 's-card',
            receiptNo: 'R-CARD',
            total: 200.0,
            paymentMethod: 'card',
          ),
        );
        await db.salesDao.insertSale(
          makeSale(
            id: 's-mada',
            receiptNo: 'R-MADA',
            total: 50.0,
            paymentMethod: 'mada',
          ),
        );
        await db.salesDao.insertSale(
          makeSale(
            id: 's-credit',
            receiptNo: 'R-CRED',
            total: 75.0,
            paymentMethod: 'credit',
          ),
        );

        final raw = await db.salesDao.aggregatePaymentBreakdownRaw('store-1');
        expect(raw.cashCents, 10000);  // 100 SAR
        expect(raw.cardCents, 25000);  // 200 + 50 (mada groups with card)
        expect(raw.creditCents, 7500); // 75 SAR
        expect(raw.totalCents, 42500);
        expect(raw.cashCount, 1);
        expect(raw.cardCount, 2);  // card + mada
        expect(raw.creditCount, 1);
        expect(raw.includedCount, 4);
        expect(raw.excludedCount, 0);
      });

      test('multi-tender rows split across buckets', () async {
        // 100 SAR mixed sale: 60 cash + 40 card.
        await db.salesDao.insertSale(
          SalesTableCompanion.insert(
            id: 's-mixed',
            storeId: 'store-1',
            receiptNo: 'R-MIX',
            cashierId: 'cashier-1',
            subtotal: 10000,
            total: 10000,
            paymentMethod: 'mixed',
            cashAmount: const Value(6000),
            cardAmount: const Value(4000),
            createdAt: DateTime(2025, 6, 15, 10),
          ),
        );

        final raw = await db.salesDao.aggregatePaymentBreakdownRaw('store-1');
        expect(raw.cashCents, 6000);
        expect(raw.cardCents, 4000);
        expect(raw.creditCents, 0);
        expect(raw.totalCents, 10000);
        // Per-tender counts: same sale increments both.
        expect(raw.cashCount, 1);
        expect(raw.cardCount, 1);
        expect(raw.includedCount, 1);
      });

      test('voided / refunded sales excluded from sums', () async {
        await db.salesDao.insertSale(
          makeSale(id: 's-paid', total: 100.0, paymentMethod: 'cash'),
        );
        await db.salesDao.insertSale(
          makeSale(
            id: 's-void',
            receiptNo: 'R-VOID',
            total: 500.0,
            paymentMethod: 'cash',
            status: 'voided',
          ),
        );
        await db.salesDao.insertSale(
          makeSale(
            id: 's-ref',
            receiptNo: 'R-REF',
            total: 300.0,
            paymentMethod: 'cash',
            status: 'refunded',
          ),
        );

        final raw = await db.salesDao.aggregatePaymentBreakdownRaw('store-1');
        expect(raw.cashCents, 10000);  // only the 100 SAR completed sale
        expect(raw.totalCents, 10000);
        expect(raw.includedCount, 1);
        expect(raw.excludedCount, 2);
      });

      test('date range filters apply', () async {
        await db.salesDao.insertSale(
          makeSale(
            id: 'old',
            total: 100.0,
            createdAt: DateTime(2025, 1, 15),
          ),
        );
        await db.salesDao.insertSale(
          makeSale(
            id: 'new',
            receiptNo: 'R-NEW',
            total: 200.0,
            createdAt: DateTime(2025, 6, 15),
          ),
        );

        final raw = await db.salesDao.aggregatePaymentBreakdownRaw(
          'store-1',
          from: DateTime(2025, 6, 1),
          to: DateTime(2025, 6, 30),
        );
        expect(raw.totalCents, 20000);
        expect(raw.includedCount, 1);
      });

      test('paid status counts the same as completed', () async {
        await db.salesDao.insertSale(
          makeSale(
            id: 's-paid',
            total: 75.0,
            paymentMethod: 'cash',
            status: 'paid',
          ),
        );

        final raw = await db.salesDao.aggregatePaymentBreakdownRaw('store-1');
        expect(raw.cashCents, 7500);
        expect(raw.includedCount, 1);
      });
    });

    // ─── Wave 8 (P0-33): pagination via offset on getAllSales ────────
    test('getAllSales accepts offset for pagination', () async {
      for (var i = 0; i < 5; i++) {
        await db.salesDao.insertSale(
          makeSale(
            id: 'sale-$i',
            receiptNo: 'REC-$i',
            createdAt: DateTime(2025, 6, 15, i),
          ),
        );
      }

      final firstPage = await db.salesDao.getAllSales(
        'store-1',
        limit: 2,
      );
      final secondPage = await db.salesDao.getAllSales(
        'store-1',
        limit: 2,
        offset: 2,
      );
      expect(firstPage, hasLength(2));
      expect(secondPage, hasLength(2));
      // Order is desc by createdAt — firstPage[0] is sale-4 (latest).
      expect(firstPage.first.id, 'sale-4');
      expect(secondPage.first.id, 'sale-2');
    });
  });
}
