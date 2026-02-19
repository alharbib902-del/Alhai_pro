/// اختبارات DAO طابور المزامنة
///
/// اختبارات تكامل تستخدم قاعدة بيانات SQLite في الذاكرة
library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pos_app/data/local/app_database.dart';

// ============================================================================
// TESTS
// ============================================================================

void main() {
  late AppDatabase db;

  setUp(() {
    // إنشاء قاعدة بيانات في الذاكرة للاختبار
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('SyncQueueDao', () {
    group('enqueue', () {
      test('يُضيف عنصر للطابور', () async {
        // Act
        final result = await db.syncQueueDao.enqueue(
          id: 'sync-1',
          tableName: 'sales',
          recordId: 'sale-1',
          operation: 'CREATE',
          payload: '{"test": "data"}',
          idempotencyKey: 'key-1',
          priority: 2,
        );

        // Assert
        expect(result, 1);
      });

      test('يُضيف عناصر متعددة', () async {
        // Act
        await db.syncQueueDao.enqueue(
          id: 'sync-1',
          tableName: 'sales',
          recordId: 'sale-1',
          operation: 'CREATE',
          payload: '{}',
          idempotencyKey: 'key-1',
        );
        await db.syncQueueDao.enqueue(
          id: 'sync-2',
          tableName: 'products',
          recordId: 'prod-1',
          operation: 'UPDATE',
          payload: '{}',
          idempotencyKey: 'key-2',
        );

        final items = await db.syncQueueDao.getPendingItems();

        // Assert
        expect(items.length, 2);
      });
    });

    group('getPendingItems', () {
      test('يُرجع العناصر المعلقة فقط', () async {
        // Arrange
        await db.syncQueueDao.enqueue(
          id: 'sync-1',
          tableName: 'sales',
          recordId: 'sale-1',
          operation: 'CREATE',
          payload: '{}',
          idempotencyKey: 'key-1',
        );
        await db.syncQueueDao.enqueue(
          id: 'sync-2',
          tableName: 'sales',
          recordId: 'sale-2',
          operation: 'CREATE',
          payload: '{}',
          idempotencyKey: 'key-2',
        );

        // Mark one as synced
        await db.syncQueueDao.markAsSynced('sync-1');

        // Act
        final items = await db.syncQueueDao.getPendingItems();

        // Assert
        expect(items.length, 1);
        expect(items.first.id, 'sync-2');
      });

      test('يُرتب العناصر حسب الأولوية ثم التاريخ', () async {
        // Arrange
        await db.syncQueueDao.enqueue(
          id: 'sync-low',
          tableName: 'sales',
          recordId: 'sale-1',
          operation: 'CREATE',
          payload: '{}',
          idempotencyKey: 'key-1',
          priority: 1, // منخفض
        );
        await db.syncQueueDao.enqueue(
          id: 'sync-high',
          tableName: 'sales',
          recordId: 'sale-2',
          operation: 'CREATE',
          payload: '{}',
          idempotencyKey: 'key-2',
          priority: 3, // عالي
        );
        await db.syncQueueDao.enqueue(
          id: 'sync-normal',
          tableName: 'sales',
          recordId: 'sale-3',
          operation: 'CREATE',
          payload: '{}',
          idempotencyKey: 'key-3',
          priority: 2, // عادي
        );

        // Act
        final items = await db.syncQueueDao.getPendingItems();

        // Assert
        expect(items.length, 3);
        expect(items[0].id, 'sync-high');
        expect(items[1].id, 'sync-normal');
        expect(items[2].id, 'sync-low');
      });

      test('يتضمن العناصر الفاشلة مع محاولات متبقية', () async {
        // Arrange
        await db.syncQueueDao.enqueue(
          id: 'sync-1',
          tableName: 'sales',
          recordId: 'sale-1',
          operation: 'CREATE',
          payload: '{}',
          idempotencyKey: 'key-1',
        );
        await db.syncQueueDao.markAsFailed('sync-1', 'Error 1');

        // Act
        final items = await db.syncQueueDao.getPendingItems();

        // Assert - Should include failed item with retries remaining
        expect(items.length, 1);
        expect(items.first.status, 'failed');
      });
    });

    group('getPendingCount', () {
      test('يُرجع عدد العناصر المعلقة', () async {
        // Arrange
        await db.syncQueueDao.enqueue(
          id: 'sync-1',
          tableName: 'sales',
          recordId: 'sale-1',
          operation: 'CREATE',
          payload: '{}',
          idempotencyKey: 'key-1',
        );
        await db.syncQueueDao.enqueue(
          id: 'sync-2',
          tableName: 'sales',
          recordId: 'sale-2',
          operation: 'CREATE',
          payload: '{}',
          idempotencyKey: 'key-2',
        );

        // Act
        final count = await db.syncQueueDao.getPendingCount();

        // Assert
        expect(count, 2);
      });

      test('يُرجع صفر إذا لم تكن هناك عناصر', () async {
        // Act
        final count = await db.syncQueueDao.getPendingCount();

        // Assert
        expect(count, 0);
      });
    });

    group('markAsSyncing', () {
      test('يُحدّث الحالة لـ syncing', () async {
        // Arrange
        await db.syncQueueDao.enqueue(
          id: 'sync-1',
          tableName: 'sales',
          recordId: 'sale-1',
          operation: 'CREATE',
          payload: '{}',
          idempotencyKey: 'key-1',
        );

        // Act
        await db.syncQueueDao.markAsSyncing('sync-1');

        // Assert
        final items = await db.syncQueueDao.getPendingItems();
        expect(items, isEmpty); // لم يعد معلقاً
      });
    });

    group('markAsSynced', () {
      test('يُحدّث الحالة لـ synced', () async {
        // Arrange
        await db.syncQueueDao.enqueue(
          id: 'sync-1',
          tableName: 'sales',
          recordId: 'sale-1',
          operation: 'CREATE',
          payload: '{}',
          idempotencyKey: 'key-1',
        );

        // Act
        await db.syncQueueDao.markAsSynced('sync-1');
        final count = await db.syncQueueDao.getPendingCount();

        // Assert
        expect(count, 0);
      });
    });

    group('markAsFailed', () {
      test('يُحدّث الحالة لـ failed ويزيد عداد المحاولات', () async {
        // Arrange
        await db.syncQueueDao.enqueue(
          id: 'sync-1',
          tableName: 'sales',
          recordId: 'sale-1',
          operation: 'CREATE',
          payload: '{}',
          idempotencyKey: 'key-1',
        );

        // Act
        await db.syncQueueDao.markAsFailed('sync-1', 'Network error');
        final items = await db.syncQueueDao.getPendingItems();

        // Assert
        expect(items.first.status, 'failed');
        expect(items.first.retryCount, 1);
        expect(items.first.lastError, 'Network error');
      });

      test('لا يُرجع العناصر بعد الوصول للحد الأقصى للمحاولات', () async {
        // Arrange
        await db.syncQueueDao.enqueue(
          id: 'sync-1',
          tableName: 'sales',
          recordId: 'sale-1',
          operation: 'CREATE',
          payload: '{}',
          idempotencyKey: 'key-1',
        );

        // Fail 3 times (max retries)
        await db.syncQueueDao.markAsFailed('sync-1', 'Error 1');
        await db.syncQueueDao.markAsFailed('sync-1', 'Error 2');
        await db.syncQueueDao.markAsFailed('sync-1', 'Error 3');

        // Act
        final items = await db.syncQueueDao.getPendingItems();

        // Assert - Should not return items that exceeded max retries
        expect(items, isEmpty);
      });
    });

    group('removeItem', () {
      test('يحذف العنصر من الطابور', () async {
        // Arrange
        await db.syncQueueDao.enqueue(
          id: 'sync-1',
          tableName: 'sales',
          recordId: 'sale-1',
          operation: 'CREATE',
          payload: '{}',
          idempotencyKey: 'key-1',
        );

        // Act
        await db.syncQueueDao.removeItem('sync-1');
        final count = await db.syncQueueDao.getPendingCount();

        // Assert
        expect(count, 0);
      });
    });

    group('findByIdempotencyKey', () {
      test('يجد العنصر بمفتاح idempotency', () async {
        // Arrange
        await db.syncQueueDao.enqueue(
          id: 'sync-1',
          tableName: 'sales',
          recordId: 'sale-1',
          operation: 'CREATE',
          payload: '{"data": "test"}',
          idempotencyKey: 'unique-key-123',
        );

        // Act
        final item = await db.syncQueueDao.findByIdempotencyKey('unique-key-123');

        // Assert
        expect(item, isNotNull);
        expect(item!.id, 'sync-1');
      });

      test('يُرجع null إذا لم يُوجد العنصر', () async {
        // Act
        final item = await db.syncQueueDao.findByIdempotencyKey('non-existent');

        // Assert
        expect(item, isNull);
      });
    });

    group('cleanupSyncedItems', () {
      test('يحذف العناصر المزامنة القديمة', () async {
        // Arrange
        await db.syncQueueDao.enqueue(
          id: 'sync-1',
          tableName: 'sales',
          recordId: 'sale-1',
          operation: 'CREATE',
          payload: '{}',
          idempotencyKey: 'key-1',
        );
        await db.syncQueueDao.markAsSynced('sync-1');

        // Manually update syncedAt to be old
        await db.customUpdate(
          'UPDATE sync_queue SET synced_at = ? WHERE id = ?',
          variables: [
            Variable.withDateTime(DateTime.now().subtract(const Duration(days: 10))),
            const Variable('sync-1'),
          ],
          updates: {},
        );

        // Act
        final deleted = await db.syncQueueDao.cleanupSyncedItems(
          olderThan: const Duration(days: 7),
        );

        // Assert
        expect(deleted, 1);
      });

      test('لا يحذف العناصر المزامنة الحديثة', () async {
        // Arrange
        await db.syncQueueDao.enqueue(
          id: 'sync-1',
          tableName: 'sales',
          recordId: 'sale-1',
          operation: 'CREATE',
          payload: '{}',
          idempotencyKey: 'key-1',
        );
        await db.syncQueueDao.markAsSynced('sync-1');

        // Act
        final deleted = await db.syncQueueDao.cleanupSyncedItems(
          olderThan: const Duration(days: 7),
        );

        // Assert
        expect(deleted, 0);
      });
    });

    group('watchPendingCount', () {
      test('يُراقب التغييرات في عدد العناصر المعلقة', () async {
        // Arrange
        final counts = <int>[];
        final subscription = db.syncQueueDao.watchPendingCount().listen(counts.add);

        // Act
        await Future.delayed(const Duration(milliseconds: 50));

        await db.syncQueueDao.enqueue(
          id: 'sync-1',
          tableName: 'sales',
          recordId: 'sale-1',
          operation: 'CREATE',
          payload: '{}',
          idempotencyKey: 'key-1',
        );
        await Future.delayed(const Duration(milliseconds: 50));

        await db.syncQueueDao.markAsSynced('sync-1');
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        await subscription.cancel();
        expect(counts, contains(0));
        expect(counts, contains(1));
      });
    });
  });
}
