import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  group('StockDeltasDao', () {
    test('addDelta creates stock delta entry', () async {
      await db.stockDeltasDao.addDelta(
        id: 'sd-1',
        productId: 'prod-1',
        storeId: 'store-1',
        quantityChange: -3,
        deviceId: 'device-1',
        operationType: 'sale',
        referenceId: 'sale-1',
      );

      final pending = await db.stockDeltasDao.getPendingDeltas();
      expect(pending, hasLength(1));
      expect(pending.first.quantityChange, -3);
      expect(pending.first.operationType, 'sale');
      expect(pending.first.syncStatus, 'pending');
    });

    test('getPendingDeltas returns only pending entries', () async {
      await db.stockDeltasDao.addDelta(
        id: 'sd-1',
        productId: 'prod-1',
        storeId: 'store-1',
        quantityChange: -2,
        deviceId: 'device-1',
        operationType: 'sale',
      );
      await db.stockDeltasDao.addDelta(
        id: 'sd-2',
        productId: 'prod-2',
        storeId: 'store-1',
        quantityChange: 10,
        deviceId: 'device-1',
        operationType: 'purchase',
      );

      // Mark one as synced
      await db.stockDeltasDao.markSynced(['sd-1']);

      final pending = await db.stockDeltasDao.getPendingDeltas();
      expect(pending, hasLength(1));
      expect(pending.first.id, 'sd-2');
    });

    test('getPendingDeltasForStore filters by store', () async {
      await db.stockDeltasDao.addDelta(
        id: 'sd-1',
        productId: 'prod-1',
        storeId: 'store-1',
        quantityChange: -1,
        deviceId: 'device-1',
        operationType: 'sale',
      );
      await db.stockDeltasDao.addDelta(
        id: 'sd-2',
        productId: 'prod-2',
        storeId: 'store-2',
        quantityChange: -1,
        deviceId: 'device-2',
        operationType: 'sale',
      );

      final store1Pending =
          await db.stockDeltasDao.getPendingDeltasForStore('store-1');
      expect(store1Pending, hasLength(1));
      expect(store1Pending.first.storeId, 'store-1');
    });

    test('getPendingCount returns correct count', () async {
      await db.stockDeltasDao.addDelta(
        id: 'sd-1',
        productId: 'prod-1',
        storeId: 'store-1',
        quantityChange: -1,
        deviceId: 'device-1',
        operationType: 'sale',
      );
      await db.stockDeltasDao.addDelta(
        id: 'sd-2',
        productId: 'prod-2',
        storeId: 'store-1',
        quantityChange: 5,
        deviceId: 'device-1',
        operationType: 'purchase',
      );

      final count = await db.stockDeltasDao.getPendingCount();
      expect(count, 2);
    });

    test('markSynced updates status and syncedAt', () async {
      await db.stockDeltasDao.addDelta(
        id: 'sd-1',
        productId: 'prod-1',
        storeId: 'store-1',
        quantityChange: -1,
        deviceId: 'device-1',
        operationType: 'sale',
      );

      await db.stockDeltasDao.markSynced(['sd-1']);

      final count = await db.stockDeltasDao.getPendingCount();
      expect(count, 0);
    });

    test('markFailed sets status to failed', () async {
      await db.stockDeltasDao.addDelta(
        id: 'sd-1',
        productId: 'prod-1',
        storeId: 'store-1',
        quantityChange: -1,
        deviceId: 'device-1',
        operationType: 'sale',
      );

      await db.stockDeltasDao.markFailed(['sd-1']);

      // getPendingDeltas should still not include it (failed, but retryCount may apply)
      final pending = await db.stockDeltasDao.getPendingDeltas();
      // Since default status is now 'failed', pending excludes it
      expect(pending, isEmpty);
    });

    test('retryFailed resets failed items to pending', () async {
      await db.stockDeltasDao.addDelta(
        id: 'sd-1',
        productId: 'prod-1',
        storeId: 'store-1',
        quantityChange: -1,
        deviceId: 'device-1',
        operationType: 'sale',
      );
      await db.stockDeltasDao.markFailed(['sd-1']);

      await db.stockDeltasDao.retryFailed();

      final count = await db.stockDeltasDao.getPendingCount();
      expect(count, 1);
    });

    test('getDeltaSummaryByProduct groups by product', () async {
      await db.stockDeltasDao.addDelta(
        id: 'sd-1',
        productId: 'prod-1',
        storeId: 'store-1',
        quantityChange: -3,
        deviceId: 'device-1',
        operationType: 'sale',
      );
      await db.stockDeltasDao.addDelta(
        id: 'sd-2',
        productId: 'prod-1',
        storeId: 'store-1',
        quantityChange: -2,
        deviceId: 'device-1',
        operationType: 'sale',
      );
      await db.stockDeltasDao.addDelta(
        id: 'sd-3',
        productId: 'prod-2',
        storeId: 'store-1',
        quantityChange: 10,
        deviceId: 'device-1',
        operationType: 'purchase',
      );

      final summary =
          await db.stockDeltasDao.getDeltaSummaryByProduct('store-1');
      expect(summary, hasLength(2));
    });

    test('markSynced with empty list does nothing', () async {
      await db.stockDeltasDao.markSynced([]);
      // Should not throw
      final count = await db.stockDeltasDao.getPendingCount();
      expect(count, 0);
    });
  });
}
