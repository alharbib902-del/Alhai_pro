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

  group('SyncMetadataDao', () {
    test('updateLastPullAt creates or updates record', () async {
      final pullTime = DateTime(2025, 6, 15, 10, 0);
      await db.syncMetadataDao.updateLastPullAt('products', pullTime,
          syncCount: 50);

      final metadata = await db.syncMetadataDao.getForTable('products');
      expect(metadata, isNotNull);
      expect(metadata!.lastPullAt, pullTime);
      expect(metadata.lastSyncCount, 50);
      expect(metadata.isInitialSynced, true);
    });

    test('updateLastPushAt creates or updates record', () async {
      final pushTime = DateTime(2025, 6, 15, 11, 0);
      await db.syncMetadataDao.updateLastPushAt('sales', pushTime,
          syncCount: 10);

      final metadata = await db.syncMetadataDao.getForTable('sales');
      expect(metadata, isNotNull);
      expect(metadata!.lastPushAt, pushTime);
    });

    test('getForTable returns null for unknown table', () async {
      final metadata =
          await db.syncMetadataDao.getForTable('non_existent');
      expect(metadata, isNull);
    });

    test('getAll returns all metadata records', () async {
      await db.syncMetadataDao
          .updateLastPullAt('products', DateTime.now());
      await db.syncMetadataDao
          .updateLastPullAt('sales', DateTime.now());

      final all = await db.syncMetadataDao.getAll();
      expect(all, hasLength(2));
    });

    test('markInitialSynced sets flag to true', () async {
      await db.syncMetadataDao.markInitialSynced('customers');

      final synced =
          await db.syncMetadataDao.isInitialSynced('customers');
      expect(synced, true);
    });

    test('isInitialSynced returns false for unknown table', () async {
      final synced =
          await db.syncMetadataDao.isInitialSynced('unknown_table');
      expect(synced, false);
    });

    test('updateCounts sets pending and failed counts', () async {
      await db.syncMetadataDao.updateCounts('products', 5, 2);

      final metadata = await db.syncMetadataDao.getForTable('products');
      expect(metadata!.pendingCount, 5);
      expect(metadata.failedCount, 2);
    });

    test('setError records error message', () async {
      await db.syncMetadataDao
          .setError('products', 'فشل الاتصال بالسيرفر');

      final metadata = await db.syncMetadataDao.getForTable('products');
      expect(metadata!.lastError, 'فشل الاتصال بالسيرفر');
    });

    test('clearError removes error message', () async {
      await db.syncMetadataDao
          .setError('products', 'خطأ');
      await db.syncMetadataDao.clearError('products');

      final metadata = await db.syncMetadataDao.getForTable('products');
      expect(metadata!.lastError, isNull);
    });

    test('getLastPullAt returns correct time', () async {
      final time = DateTime(2025, 6, 15, 12, 30);
      await db.syncMetadataDao.updateLastPullAt('products', time);

      final lastPull =
          await db.syncMetadataDao.getLastPullAt('products');
      expect(lastPull, time);
    });

    test('getLastPullAt returns null for unknown table', () async {
      final lastPull =
          await db.syncMetadataDao.getLastPullAt('unknown');
      expect(lastPull, isNull);
    });

    test('getTotalPendingCount sums all pending counts', () async {
      await db.syncMetadataDao.updateCounts('products', 5, 0);
      await db.syncMetadataDao.updateCounts('sales', 3, 0);

      final total = await db.syncMetadataDao.getTotalPendingCount();
      expect(total, 8);
    });

    test('getTotalFailedCount sums all failed counts', () async {
      await db.syncMetadataDao.updateCounts('products', 0, 2);
      await db.syncMetadataDao.updateCounts('sales', 0, 1);

      final total = await db.syncMetadataDao.getTotalFailedCount();
      expect(total, 3);
    });

    test('resetTable removes metadata for specific table', () async {
      await db.syncMetadataDao
          .updateLastPullAt('products', DateTime.now());
      await db.syncMetadataDao
          .updateLastPullAt('sales', DateTime.now());

      await db.syncMetadataDao.resetTable('products');

      final products = await db.syncMetadataDao.getForTable('products');
      expect(products, isNull);

      final sales = await db.syncMetadataDao.getForTable('sales');
      expect(sales, isNotNull);
    });

    test('resetAll removes all metadata', () async {
      await db.syncMetadataDao
          .updateLastPullAt('products', DateTime.now());
      await db.syncMetadataDao
          .updateLastPullAt('sales', DateTime.now());

      await db.syncMetadataDao.resetAll();

      final all = await db.syncMetadataDao.getAll();
      expect(all, isEmpty);
    });
  });
}
