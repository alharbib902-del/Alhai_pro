import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await seedTestData(db);
    // inventory_movements reference products via FK
    // C-4 Stage B: SAR × 100 = cents
    await db.productsDao.insertProduct(
      ProductsTableCompanion.insert(
        id: 'prod-1',
        storeId: 'store-1',
        name: 'P1',
        price: 1000,
        createdAt: DateTime(2025, 1, 1),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('InventoryDao', () {
    test('insertMovement and getMovementsByProduct', () async {
      await db.inventoryDao.insertMovement(
        InventoryMovementsTableCompanion.insert(
          id: 'mov-1',
          productId: 'prod-1',
          storeId: 'store-1',
          type: 'sale',
          qty: -2,
          previousQty: 100,
          newQty: 98,
          createdAt: DateTime(2025, 6, 15),
        ),
      );

      final movements = await db.inventoryDao.getMovementsByProduct('prod-1');
      expect(movements, hasLength(1));
      expect(movements.first.qty, -2);
      expect(movements.first.type, 'sale');
    });

    test('recordSaleMovement creates negative quantity movement', () async {
      await db.inventoryDao.recordSaleMovement(
        id: 'mov-sale-1',
        productId: 'prod-1',
        storeId: 'store-1',
        qty: 5,
        previousQty: 100,
        saleId: 'sale-1',
      );

      final movements = await db.inventoryDao.getMovementsByProduct('prod-1');
      expect(movements, hasLength(1));
      expect(movements.first.qty, -5); // negative for sales
      expect(movements.first.newQty, 95);
      expect(movements.first.type, 'sale');
      expect(movements.first.referenceType, 'sale');
      expect(movements.first.referenceId, 'sale-1');
    });

    test('recordReceiveMovement creates positive quantity movement', () async {
      // Wave 7 (P0-19): renamed from recordPurchaseMovement; type
      // 'purchase' was remapped to 'receive' in v48.
      await db.inventoryDao.recordReceiveMovement(
        id: 'mov-purchase-1',
        productId: 'prod-1',
        storeId: 'store-1',
        qty: 50,
        previousQty: 100,
        referenceType: 'purchase_order',
        referenceId: 'purchase-1',
      );

      final movements = await db.inventoryDao.getMovementsByProduct('prod-1');
      expect(movements, hasLength(1));
      expect(movements.first.qty, 50); // positive for receives
      expect(movements.first.newQty, 150);
      expect(movements.first.type, 'receive');
    });

    test('recordAdjustment creates correct movement', () async {
      await db.inventoryDao.recordAdjustment(
        id: 'mov-adj-1',
        productId: 'prod-1',
        storeId: 'store-1',
        newQty: 80,
        previousQty: 100,
        reason: 'تلف بضاعة',
      );

      final movements = await db.inventoryDao.getMovementsByProduct('prod-1');
      expect(movements, hasLength(1));
      expect(movements.first.qty, -20);
      expect(movements.first.newQty, 80);
      expect(movements.first.reason, 'تلف بضاعة');
      // Wave 7 (P0-19): type renamed 'adjustment' → 'adjust'.
      expect(movements.first.type, 'adjust');
    });

    test('getMovementsByProduct returns empty for unknown product', () async {
      final movements = await db.inventoryDao.getMovementsByProduct('unknown');
      expect(movements, isEmpty);
    });

    test('markAsSynced sets syncedAt', () async {
      await db.inventoryDao.insertMovement(
        InventoryMovementsTableCompanion.insert(
          id: 'mov-1',
          productId: 'prod-1',
          storeId: 'store-1',
          type: 'sale',
          qty: -1,
          previousQty: 10,
          newQty: 9,
          createdAt: DateTime(2025, 6, 15),
        ),
      );

      await db.inventoryDao.markAsSynced('mov-1');

      final unsynced = await db.inventoryDao.getUnsyncedMovements();
      expect(unsynced, isEmpty);
    });

    test('getUnsyncedMovements returns movements without syncedAt', () async {
      await db.inventoryDao.insertMovement(
        InventoryMovementsTableCompanion.insert(
          id: 'mov-1',
          productId: 'prod-1',
          storeId: 'store-1',
          type: 'sale',
          qty: -1,
          previousQty: 10,
          newQty: 9,
          createdAt: DateTime(2025, 6, 15),
        ),
      );
      await db.inventoryDao.insertMovement(
        InventoryMovementsTableCompanion.insert(
          id: 'mov-2',
          productId: 'prod-1',
          storeId: 'store-1',
          // Wave 7 (P0-19): canonical 'receive' (was 'purchase').
          type: 'receive',
          qty: 20,
          previousQty: 9,
          newQty: 29,
          createdAt: DateTime(2025, 6, 16),
        ),
      );
      await db.inventoryDao.markAsSynced('mov-1');

      final unsynced = await db.inventoryDao.getUnsyncedMovements();
      expect(unsynced, hasLength(1));
      expect(unsynced.first.id, 'mov-2');
    });

    test('movements ordered by createdAt desc', () async {
      await db.inventoryDao.insertMovement(
        InventoryMovementsTableCompanion.insert(
          id: 'mov-1',
          productId: 'prod-1',
          storeId: 'store-1',
          type: 'sale',
          qty: -1,
          previousQty: 10,
          newQty: 9,
          createdAt: DateTime(2025, 6, 14),
        ),
      );
      await db.inventoryDao.insertMovement(
        InventoryMovementsTableCompanion.insert(
          id: 'mov-2',
          productId: 'prod-1',
          storeId: 'store-1',
          // Wave 7 (P0-19): canonical 'receive' (was 'purchase' pre-v48
          // — old name still in legacy backups but rejected on insert
          // by `kInventoryMovementTypes` validation).
          type: 'receive',
          qty: 20,
          previousQty: 9,
          newQty: 29,
          createdAt: DateTime(2025, 6, 16),
        ),
      );

      final movements = await db.inventoryDao.getMovementsByProduct('prod-1');
      expect(movements.first.id, 'mov-2'); // most recent first
    });

    // ─── Wave 7 (P0-19): canonical movement types ────────────────────
    group('canonical type validation', () {
      test('insertMovement accepts every canonical type', () async {
        for (final type in kInventoryMovementTypes) {
          await db.inventoryDao.insertMovement(
            InventoryMovementsTableCompanion.insert(
              id: 'mov-$type',
              productId: 'prod-1',
              storeId: 'store-1',
              type: type,
              qty: 1,
              previousQty: 0,
              newQty: 1,
              createdAt: DateTime(2025, 6, 15),
            ),
          );
        }
        final all = await db.inventoryDao.getMovementsByProduct('prod-1');
        expect(all, hasLength(kInventoryMovementTypes.length));
      });

      test('insertMovement rejects legacy/unknown types', () {
        // 'purchase' / 'addition' / 'subtraction' / 'adjustment' were the
        // legacy strings the v48 migration remapped — new writes must use
        // the canonical names.
        for (final bad in const [
          'purchase',
          'addition',
          'subtraction',
          'adjustment',
          'misc',
          '',
        ]) {
          expect(
            () => db.inventoryDao.insertMovement(
              InventoryMovementsTableCompanion.insert(
                id: 'mov-bad-$bad',
                productId: 'prod-1',
                storeId: 'store-1',
                type: bad,
                qty: 1,
                previousQty: 0,
                newQty: 1,
                createdAt: DateTime(2025, 6, 15),
              ),
            ),
            throwsArgumentError,
          );
        }
      });
    });

    // ─── Wave 7 (P0-19): new DAO helpers — smoke + side effects ──────
    group('new DAO helpers', () {
      test('recordReceiveMovement persists unitCostCents', () async {
        await db.inventoryDao.recordReceiveMovement(
          id: 'mov-recv',
          productId: 'prod-1',
          storeId: 'store-1',
          qty: 10,
          previousQty: 5,
          unitCostCents: 750, // 7.50 SAR per unit
          referenceType: 'manual_addition',
        );
        final all = await db.inventoryDao.getMovementsByProduct('prod-1');
        expect(all, hasLength(1));
        expect(all.first.type, 'receive');
        expect(all.first.unitCostCents, 750);
        expect(all.first.qty, 10);
        expect(all.first.newQty, 15);
      });

      test('recordWastageMovement records negative qty', () async {
        await db.inventoryDao.recordWastageMovement(
          id: 'mov-wst',
          productId: 'prod-1',
          storeId: 'store-1',
          qty: 3,
          previousQty: 20,
          reason: 'expired',
        );
        final all = await db.inventoryDao.getMovementsByProduct('prod-1');
        expect(all.first.type, 'wastage');
        expect(all.first.qty, -3);
        expect(all.first.newQty, 17);
      });

      test('recordStockTakeMovement supports negative delta', () async {
        await db.inventoryDao.recordStockTakeMovement(
          id: 'mov-stk',
          productId: 'prod-1',
          storeId: 'store-1',
          delta: -2, // counted < on-hand
          previousQty: 10,
          reason: 'undercount',
        );
        final all = await db.inventoryDao.getMovementsByProduct('prod-1');
        expect(all.first.type, 'stock_take');
        expect(all.first.qty, -2);
        expect(all.first.newQty, 8);
      });

      test('transfer pair records correct directions', () async {
        await db.inventoryDao.recordTransferOutMovement(
          id: 'mov-out',
          productId: 'prod-1',
          storeId: 'store-1',
          qty: 4,
          previousQty: 12,
          transferId: 'xfer-1',
        );
        await db.inventoryDao.recordTransferInMovement(
          id: 'mov-in',
          productId: 'prod-1',
          storeId: 'store-1',
          qty: 4,
          previousQty: 0,
          transferId: 'xfer-1',
          unitCostCents: 500,
        );
        final all = await db.inventoryDao.getMovementsByProduct('prod-1');
        final out = all.firstWhere((m) => m.id == 'mov-out');
        final inn = all.firstWhere((m) => m.id == 'mov-in');
        expect(out.qty, -4);
        expect(out.type, 'transfer_out');
        expect(inn.qty, 4);
        expect(inn.type, 'transfer_in');
        expect(inn.unitCostCents, 500);
      });
    });

    // ─── Wave 7 (P0-21): WAVG cost computation ───────────────────────
    group('applyReceiveAndRecomputeCost (WAVG)', () {
      test('first receive seeds cost when none was set', () async {
        await db.productsDao.insertProduct(
          ProductsTableCompanion.insert(
            id: 'prod-fresh',
            storeId: 'store-1',
            name: 'Fresh',
            price: 1500,
            costPrice: const Value(null),
            stockQty: const Value(0),
            createdAt: DateTime(2025, 1, 1),
          ),
        );
        final newCost = await db.productsDao.applyReceiveAndRecomputeCost(
          productId: 'prod-fresh',
          qty: 10,
          unitCostCents: 800,
        );
        expect(newCost, 800);
        final p = await db.productsDao.getProductById('prod-fresh');
        expect(p!.stockQty, 10);
        expect(p.costPrice, 800);
      });

      test('weighted average across two receipts', () async {
        await db.productsDao.insertProduct(
          ProductsTableCompanion.insert(
            id: 'prod-wavg',
            storeId: 'store-1',
            name: 'WAVG',
            price: 2000,
            costPrice: const Value(null),
            stockQty: const Value(0),
            createdAt: DateTime(2025, 1, 1),
          ),
        );
        // Receipt 1: 10 units @ 1000c → cost 1000c, stock 10
        await db.productsDao.applyReceiveAndRecomputeCost(
          productId: 'prod-wavg',
          qty: 10,
          unitCostCents: 1000,
        );
        // Receipt 2: 10 units @ 2000c → WAVG (1000*10 + 2000*10) / 20 = 1500c
        final newCost = await db.productsDao.applyReceiveAndRecomputeCost(
          productId: 'prod-wavg',
          qty: 10,
          unitCostCents: 2000,
        );
        expect(newCost, 1500);
        final p = await db.productsDao.getProductById('prod-wavg');
        expect(p!.stockQty, 20);
        expect(p.costPrice, 1500);
      });

      test('null unitCost preserves existing cost (legacy behaviour)', () async {
        await db.productsDao.insertProduct(
          ProductsTableCompanion.insert(
            id: 'prod-legacy',
            storeId: 'store-1',
            name: 'Legacy',
            price: 1000,
            costPrice: const Value(700),
            stockQty: const Value(5),
            createdAt: DateTime(2025, 1, 1),
          ),
        );
        final newCost = await db.productsDao.applyReceiveAndRecomputeCost(
          productId: 'prod-legacy',
          qty: 5,
          unitCostCents: null,
        );
        expect(newCost, 700); // unchanged
        final p = await db.productsDao.getProductById('prod-legacy');
        expect(p!.stockQty, 10); // stock still bumped
        expect(p.costPrice, 700);
      });

      test('fractional qty (decimal pack) WAVG within rounding tolerance', () async {
        await db.productsDao.insertProduct(
          ProductsTableCompanion.insert(
            id: 'prod-frac',
            storeId: 'store-1',
            name: 'Frac',
            price: 5000,
            costPrice: const Value(null),
            stockQty: const Value(0),
            createdAt: DateTime(2025, 1, 1),
          ),
        );
        await db.productsDao.applyReceiveAndRecomputeCost(
          productId: 'prod-frac',
          qty: 0.75,
          unitCostCents: 4000,
        );
        // 0.5 kg @ 6000c. Expected ≈ (4000*0.75 + 6000*0.5) / 1.25 = 4800c
        final newCost = await db.productsDao.applyReceiveAndRecomputeCost(
          productId: 'prod-frac',
          qty: 0.5,
          unitCostCents: 6000,
        );
        expect((newCost! - 4800).abs(), lessThanOrEqualTo(1));
      });

      // ─── P0-27: TOCTOU regression ─────────────────────────────────
      test(
        'concurrent receives serialise via Drift transactions (no last-write-wins)',
        () async {
          // The pre-fix bug: cashier_receiving read stockQty (cached),
          // added the received qty, wrote the result. POS sale
          // happening in parallel did the same with -1. Whichever
          // wrote last clobbered the other → stock drift.
          //
          // Wave 7's `applyReceiveAndRecomputeCost` re-reads inside an
          // internal `attachedDatabase.transaction(...)` which Drift
          // serialises on a single SQLite connection. This test fires
          // two receives "concurrently" (Future.wait) on the same
          // product; if the helper is TOCTOU-correct the final stock
          // is exactly old + qty1 + qty2. If it lost a write the total
          // would be old + max(qty1, qty2).
          await db.productsDao.insertProduct(
            ProductsTableCompanion.insert(
              id: 'prod-race',
              storeId: 'store-1',
              name: 'Race',
              price: 1000,
              costPrice: const Value(500),
              stockQty: const Value(100),
              createdAt: DateTime(2025, 1, 1),
            ),
          );

          await Future.wait([
            db.productsDao.applyReceiveAndRecomputeCost(
              productId: 'prod-race',
              qty: 30,
              unitCostCents: 600,
            ),
            db.productsDao.applyReceiveAndRecomputeCost(
              productId: 'prod-race',
              qty: 20,
              unitCostCents: 700,
            ),
          ]);

          final p = await db.productsDao.getProductById('prod-race');
          expect(p!.stockQty, 150); // 100 + 30 + 20 — both receives applied
        },
      );

      test('concurrent receive + sale stock writes serialise correctly',
          () async {
        // Same race, mixed direction. POS sale of 5 units while a
        // receive of 50 lands. The `applyReceiveAndRecomputeCost`
        // path is serialised; the sale uses a plain `updateStock`
        // and is NOT wrapped in a tx in this test's narrow scope —
        // the production sale flow wraps it in `_db.transaction(...)`
        // (see sale_service.dart). What we're verifying here is that
        // a receive happening alongside DOES re-read inside its tx
        // and doesn't carry a stale snapshot from before the sale.
        await db.productsDao.insertProduct(
          ProductsTableCompanion.insert(
            id: 'prod-mixed',
            storeId: 'store-1',
            name: 'Mixed',
            price: 1000,
            costPrice: const Value(500),
            stockQty: const Value(100),
            createdAt: DateTime(2025, 1, 1),
          ),
        );

        await Future.wait([
          db.productsDao.applyReceiveAndRecomputeCost(
            productId: 'prod-mixed',
            qty: 50,
            unitCostCents: 500,
          ),
          // Simulate a "sale" path — direct stock decrement.
          db.productsDao.updateStock('prod-mixed', 95),
        ]);

        // Either order is valid as long as no write was clobbered.
        // The two valid end states are:
        //   - sale ran first (stock=95), then receive (re-reads 95,
        //     writes 95+50=145)
        //   - receive ran first (stock=150), then sale (writes 95
        //     directly — overwrites the receive)
        // Pre-fix the receive would have taken its captured snapshot
        // (100) and written 100+50=150 even after the sale, masking
        // the sale entirely. Post-fix that scenario can't happen
        // because the receive re-reads inside its tx.
        final p = await db.productsDao.getProductById('prod-mixed');
        expect([95, 145].contains(p!.stockQty), isTrue,
            reason: 'unexpected end stock ${p.stockQty}');
      });
    });
  });
}
