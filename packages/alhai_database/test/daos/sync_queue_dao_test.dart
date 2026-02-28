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

  group('SyncQueueDao', () {
    test('enqueue adds item to sync queue', () async {
      await db.syncQueueDao.enqueue(
        id: 'sq-1',
        tableName: 'products',
        recordId: 'prod-1',
        operation: 'CREATE',
        payload: '{"name":"حليب"}',
        idempotencyKey: 'key-1',
      );

      final items = await db.syncQueueDao.getPendingItems();
      expect(items, hasLength(1));
      expect(items.first.tableName_, 'products');
      expect(items.first.operation, 'CREATE');
    });

    test('getPendingCount returns correct count', () async {
      await db.syncQueueDao.enqueue(
        id: 'sq-1',
        tableName: 'products',
        recordId: 'prod-1',
        operation: 'CREATE',
        payload: '{}',
        idempotencyKey: 'key-1',
      );
      await db.syncQueueDao.enqueue(
        id: 'sq-2',
        tableName: 'sales',
        recordId: 'sale-1',
        operation: 'CREATE',
        payload: '{}',
        idempotencyKey: 'key-2',
      );

      final count = await db.syncQueueDao.getPendingCount();
      expect(count, 2);
    });

    test('markAsSyncing updates status', () async {
      await db.syncQueueDao.enqueue(
        id: 'sq-1',
        tableName: 'products',
        recordId: 'prod-1',
        operation: 'CREATE',
        payload: '{}',
        idempotencyKey: 'key-1',
      );

      await db.syncQueueDao.markAsSyncing('sq-1');

      final items = await db.syncQueueDao.getAllItems();
      expect(items.first.status, 'syncing');
      expect(items.first.lastAttemptAt, isNotNull);
    });

    test('markAsSynced updates status and sets syncedAt', () async {
      await db.syncQueueDao.enqueue(
        id: 'sq-1',
        tableName: 'products',
        recordId: 'prod-1',
        operation: 'CREATE',
        payload: '{}',
        idempotencyKey: 'key-1',
      );

      await db.syncQueueDao.markAsSynced('sq-1');

      final items = await db.syncQueueDao.getAllItems();
      expect(items.first.status, 'synced');
      expect(items.first.syncedAt, isNotNull);
    });

    test('markAsFailed increments retryCount and sets error', () async {
      await db.syncQueueDao.enqueue(
        id: 'sq-1',
        tableName: 'products',
        recordId: 'prod-1',
        operation: 'CREATE',
        payload: '{}',
        idempotencyKey: 'key-1',
      );

      await db.syncQueueDao.markAsFailed('sq-1', 'خطأ في الشبكة');

      final items = await db.syncQueueDao.getAllItems();
      expect(items.first.status, 'failed');
      expect(items.first.retryCount, 1);
      expect(items.first.lastError, 'خطأ في الشبكة');
    });

    test('findByIdempotencyKey finds item', () async {
      await db.syncQueueDao.enqueue(
        id: 'sq-1',
        tableName: 'products',
        recordId: 'prod-1',
        operation: 'CREATE',
        payload: '{}',
        idempotencyKey: 'unique-key-123',
      );

      final item =
          await db.syncQueueDao.findByIdempotencyKey('unique-key-123');
      expect(item, isNotNull);
      expect(item!.id, 'sq-1');
    });

    test('findByIdempotencyKey returns null when not found', () async {
      final item =
          await db.syncQueueDao.findByIdempotencyKey('non-existent');
      expect(item, isNull);
    });

    test('removeItem deletes item', () async {
      await db.syncQueueDao.enqueue(
        id: 'sq-1',
        tableName: 'products',
        recordId: 'prod-1',
        operation: 'CREATE',
        payload: '{}',
        idempotencyKey: 'key-1',
      );

      final deleted = await db.syncQueueDao.removeItem('sq-1');
      expect(deleted, 1);

      final count = await db.syncQueueDao.getPendingCount();
      expect(count, 0);
    });

    test('enqueue with priority orders correctly', () async {
      await db.syncQueueDao.enqueue(
        id: 'sq-low',
        tableName: 'products',
        recordId: 'prod-1',
        operation: 'CREATE',
        payload: '{}',
        idempotencyKey: 'key-low',
        priority: 1,
      );
      await db.syncQueueDao.enqueue(
        id: 'sq-high',
        tableName: 'sales',
        recordId: 'sale-1',
        operation: 'CREATE',
        payload: '{}',
        idempotencyKey: 'key-high',
        priority: 3,
      );

      final items = await db.syncQueueDao.getPendingItems();
      expect(items.first.id, 'sq-high'); // high priority first
    });

    test('retryItem resets status and retryCount', () async {
      await db.syncQueueDao.enqueue(
        id: 'sq-1',
        tableName: 'products',
        recordId: 'prod-1',
        operation: 'CREATE',
        payload: '{}',
        idempotencyKey: 'key-1',
      );
      await db.syncQueueDao.markAsFailed('sq-1', 'error');

      await db.syncQueueDao.retryItem('sq-1');

      final items = await db.syncQueueDao.getAllItems();
      expect(items.first.status, 'pending');
      expect(items.first.retryCount, 0);
    });

    test('markAsConflict sets conflict status', () async {
      await db.syncQueueDao.enqueue(
        id: 'sq-1',
        tableName: 'products',
        recordId: 'prod-1',
        operation: 'UPDATE',
        payload: '{}',
        idempotencyKey: 'key-1',
      );

      await db.syncQueueDao.markAsConflict('sq-1', 'تعارض في البيانات');

      final items = await db.syncQueueDao.getAllItems();
      expect(items.first.status, 'conflict');
      expect(items.first.lastError, 'تعارض في البيانات');
    });

    test('markResolved sets resolved status', () async {
      await db.syncQueueDao.enqueue(
        id: 'sq-1',
        tableName: 'products',
        recordId: 'prod-1',
        operation: 'UPDATE',
        payload: '{}',
        idempotencyKey: 'key-1',
      );
      await db.syncQueueDao.markAsConflict('sq-1', 'conflict');

      await db.syncQueueDao.markResolved('sq-1');

      final items = await db.syncQueueDao.getAllItems();
      expect(items.first.status, 'resolved');
    });
  });
}
