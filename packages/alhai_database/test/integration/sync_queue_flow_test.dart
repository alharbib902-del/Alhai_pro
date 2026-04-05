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

  group('Sync Queue Lifecycle Flow', () {
    test('full lifecycle: enqueue -> pending -> syncing -> synced', () async {
      // Step 1: Insert sync queue items
      await db.syncQueueDao.enqueue(
        id: 'sq-1',
        tableName: 'products',
        recordId: 'prod-1',
        operation: 'CREATE',
        payload: '{"id":"prod-1","name":"حليب طازج","price":5.5}',
        idempotencyKey: 'idem-prod-1-create',
        priority: 2,
      );
      await db.syncQueueDao.enqueue(
        id: 'sq-2',
        tableName: 'sales',
        recordId: 'sale-1',
        operation: 'CREATE',
        payload: '{"id":"sale-1","total":100.0}',
        idempotencyKey: 'idem-sale-1-create',
        priority: 3, // Higher priority for sales
      );
      await db.syncQueueDao.enqueue(
        id: 'sq-3',
        tableName: 'products',
        recordId: 'prod-2',
        operation: 'UPDATE',
        payload: '{"id":"prod-2","price":7.0}',
        idempotencyKey: 'idem-prod-2-update',
        priority: 1, // Low priority
      );

      // Step 2: Verify pending items are retrieved in correct order (priority desc, then created_at asc)
      final pendingItems = await db.syncQueueDao.getPendingItems();
      expect(pendingItems, hasLength(3));
      expect(pendingItems[0].id, 'sq-2',
          reason: 'Highest priority (3) should be first');
      expect(pendingItems[1].id, 'sq-1',
          reason: 'Normal priority (2) should be second');
      expect(pendingItems[2].id, 'sq-3',
          reason: 'Low priority (1) should be last');

      // Verify pending count
      final pendingCount = await db.syncQueueDao.getPendingCount();
      expect(pendingCount, 3);

      // Step 3: Mark first item as syncing (simulating sync process start)
      await db.syncQueueDao.markAsSyncing('sq-2');
      final syncingItems = await db.syncQueueDao.getAllItems();
      final syncingItem = syncingItems.firstWhere((i) => i.id == 'sq-2');
      expect(syncingItem.status, 'syncing');
      expect(syncingItem.lastAttemptAt, isNotNull);

      // Step 4: Mark item as synced (simulating successful sync)
      await db.syncQueueDao.markAsSynced('sq-2');
      final syncedItems = await db.syncQueueDao.getAllItems();
      final syncedItem = syncedItems.firstWhere((i) => i.id == 'sq-2');
      expect(syncedItem.status, 'synced');
      expect(syncedItem.syncedAt, isNotNull);

      // Step 5: Verify completed items are excluded from pending
      final remainingPending = await db.syncQueueDao.getPendingItems();
      expect(remainingPending, hasLength(2));
      expect(remainingPending.map((i) => i.id), isNot(contains('sq-2')),
          reason: 'Synced item should not appear in pending list');

      final remainingCount = await db.syncQueueDao.getPendingCount();
      expect(remainingCount, 2);
    });

    test('retry logic: failed items increment attempts and remain pending',
        () async {
      // Enqueue an item
      await db.syncQueueDao.enqueue(
        id: 'retry-1',
        tableName: 'products',
        recordId: 'prod-1',
        operation: 'CREATE',
        payload: '{"id":"prod-1"}',
        idempotencyKey: 'idem-retry-1',
      );

      // Step 5: Test retry logic - first failure
      await db.syncQueueDao.markAsFailed('retry-1', 'Network timeout');
      var allItems = await db.syncQueueDao.getAllItems();
      var item = allItems.firstWhere((i) => i.id == 'retry-1');
      expect(item.status, 'failed');
      expect(item.retryCount, 1);
      expect(item.lastError, 'Network timeout');
      expect(item.maxRetries, 3);

      // Failed item with retryCount < maxRetries should still be in pending
      var pending = await db.syncQueueDao.getPendingItems();
      expect(pending, hasLength(1),
          reason: 'Failed item with retries remaining should be in pending');

      // Second failure
      await db.syncQueueDao.markAsFailed('retry-1', 'Server error 500');
      allItems = await db.syncQueueDao.getAllItems();
      item = allItems.firstWhere((i) => i.id == 'retry-1');
      expect(item.retryCount, 2);
      expect(item.lastError, 'Server error 500');

      // Still pending (2 < 3)
      pending = await db.syncQueueDao.getPendingItems();
      expect(pending, hasLength(1));

      // Third failure - exhausts retries
      await db.syncQueueDao.markAsFailed('retry-1', 'Server error 503');
      allItems = await db.syncQueueDao.getAllItems();
      item = allItems.firstWhere((i) => i.id == 'retry-1');
      expect(item.retryCount, 3);

      // Now retryCount >= maxRetries, should NOT be in pending
      pending = await db.syncQueueDao.getPendingItems();
      expect(pending, isEmpty,
          reason: 'Item that exhausted retries should not be in pending');

      // But should appear in conflict items
      final conflicts = await db.syncQueueDao.getConflictItems();
      expect(conflicts, hasLength(1));
      expect(conflicts.first.id, 'retry-1');
    });

    test('retryItem resets failed item back to pending', () async {
      await db.syncQueueDao.enqueue(
        id: 'reset-1',
        tableName: 'sales',
        recordId: 'sale-1',
        operation: 'CREATE',
        payload: '{}',
        idempotencyKey: 'idem-reset-1',
      );

      // Fail the item twice
      await db.syncQueueDao.markAsFailed('reset-1', 'Error 1');
      await db.syncQueueDao.markAsFailed('reset-1', 'Error 2');

      var items = await db.syncQueueDao.getAllItems();
      var item = items.first;
      expect(item.retryCount, 2);
      expect(item.status, 'failed');

      // Reset via retryItem
      await db.syncQueueDao.retryItem('reset-1');

      items = await db.syncQueueDao.getAllItems();
      item = items.first;
      expect(item.status, 'pending');
      expect(item.retryCount, 0,
          reason: 'retryItem should reset retryCount to 0');

      // Should be back in pending
      final pending = await db.syncQueueDao.getPendingItems();
      expect(pending, hasLength(1));
    });

    test('idempotency key prevents duplicate queue entries', () async {
      await db.syncQueueDao.enqueue(
        id: 'uniq-1',
        tableName: 'products',
        recordId: 'prod-1',
        operation: 'CREATE',
        payload: '{"v":1}',
        idempotencyKey: 'same-key',
      );

      // Attempting to insert with same idempotency key should be silently
      // skipped (idempotency guard returns 0 instead of inserting)
      final result = await db.syncQueueDao.enqueue(
        id: 'uniq-2',
        tableName: 'products',
        recordId: 'prod-1',
        operation: 'CREATE',
        payload: '{"v":2}',
        idempotencyKey: 'same-key',
      );
      expect(result, 0,
          reason: 'Duplicate idempotency key should be skipped (return 0)');

      // Verify findByIdempotencyKey works
      final found = await db.syncQueueDao.findByIdempotencyKey('same-key');
      expect(found, isNotNull);
      expect(found!.id, 'uniq-1');
    });

    test('conflict resolution flow: conflict -> resolved', () async {
      await db.syncQueueDao.enqueue(
        id: 'conflict-1',
        tableName: 'products',
        recordId: 'prod-1',
        operation: 'UPDATE',
        payload: '{"price":10.0}',
        idempotencyKey: 'idem-conflict-1',
      );

      // Mark as conflict
      await db.syncQueueDao.markAsConflict(
          'conflict-1', 'Version mismatch: server has newer data');

      var items = await db.syncQueueDao.getAllItems();
      var item = items.first;
      expect(item.status, 'conflict');
      expect(item.lastError, 'Version mismatch: server has newer data');

      // Conflict items should appear in conflict list
      final conflicts = await db.syncQueueDao.getConflictItems();
      expect(conflicts, hasLength(1));

      // Resolve the conflict
      await db.syncQueueDao.markResolved('conflict-1');

      items = await db.syncQueueDao.getAllItems();
      item = items.first;
      expect(item.status, 'resolved');
      expect(item.syncedAt, isNotNull);

      // No longer in conflicts
      final remainingConflicts = await db.syncQueueDao.getConflictItems();
      expect(remainingConflicts, isEmpty);

      // Not in pending either
      final pending = await db.syncQueueDao.getPendingItems();
      expect(pending, isEmpty);
    });

    test('removeItem removes synced items and keeps pending', () async {
      // Insert and sync two items
      await db.syncQueueDao.enqueue(
        id: 'clean-1',
        tableName: 'products',
        recordId: 'prod-1',
        operation: 'CREATE',
        payload: '{}',
        idempotencyKey: 'idem-clean-1',
      );
      await db.syncQueueDao.enqueue(
        id: 'clean-2',
        tableName: 'products',
        recordId: 'prod-2',
        operation: 'CREATE',
        payload: '{}',
        idempotencyKey: 'idem-clean-2',
      );

      // Mark both as synced
      await db.syncQueueDao.markAsSynced('clean-1');
      await db.syncQueueDao.markAsSynced('clean-2');

      // Add a pending item that should NOT be cleaned
      await db.syncQueueDao.enqueue(
        id: 'clean-3',
        tableName: 'sales',
        recordId: 'sale-1',
        operation: 'CREATE',
        payload: '{}',
        idempotencyKey: 'idem-clean-3',
      );

      var allItems = await db.syncQueueDao.getAllItems();
      expect(allItems, hasLength(3));

      // Verify synced items have syncedAt set
      final syncedItems = allItems.where((i) => i.status == 'synced').toList();
      expect(syncedItems, hasLength(2));
      for (final item in syncedItems) {
        expect(item.syncedAt, isNotNull,
            reason: 'Synced items should have syncedAt');
      }

      // Remove synced items manually (simulating cleanup)
      await db.syncQueueDao.removeItem('clean-1');
      await db.syncQueueDao.removeItem('clean-2');

      allItems = await db.syncQueueDao.getAllItems();
      expect(allItems, hasLength(1));
      expect(allItems.first.id, 'clean-3',
          reason: 'Only pending item should remain');
      expect(allItems.first.status, 'pending');
    });

    test('mixed operations: multiple items through different lifecycle paths',
        () async {
      // Enqueue 5 items
      for (int i = 1; i <= 5; i++) {
        await db.syncQueueDao.enqueue(
          id: 'mix-$i',
          tableName: i <= 3 ? 'products' : 'sales',
          recordId: 'record-$i',
          operation: i.isEven ? 'UPDATE' : 'CREATE',
          payload: '{"index":$i}',
          idempotencyKey: 'idem-mix-$i',
          priority: i <= 2 ? 3 : 1, // First two are high priority
        );
      }

      // Item 1: Sync successfully
      await db.syncQueueDao.markAsSyncing('mix-1');
      await db.syncQueueDao.markAsSynced('mix-1');

      // Item 2: Fail then retry then succeed
      await db.syncQueueDao.markAsFailed('mix-2', 'Temporary error');
      await db.syncQueueDao.markAsSyncing('mix-2');
      await db.syncQueueDao.markAsSynced('mix-2');

      // Item 3: Fail until conflict
      await db.syncQueueDao.markAsFailed('mix-3', 'Error 1');
      await db.syncQueueDao.markAsFailed('mix-3', 'Error 2');
      await db.syncQueueDao.markAsFailed('mix-3', 'Error 3');

      // Item 4: Mark as conflict directly
      await db.syncQueueDao.markAsConflict('mix-4', 'Data conflict');

      // Item 5: Still pending

      // Verify counts
      final pending = await db.syncQueueDao.getPendingItems();
      expect(pending, hasLength(1), reason: 'Only mix-5 should be pending');
      expect(pending.first.id, 'mix-5');

      final conflicts = await db.syncQueueDao.getConflictItems();
      expect(conflicts, hasLength(2),
          reason: 'mix-3 (exhausted) and mix-4 (marked conflict)');

      final allItems = await db.syncQueueDao.getAllItems();
      expect(allItems, hasLength(5));

      // Verify individual statuses
      final statusMap = {for (final item in allItems) item.id: item.status};
      expect(statusMap['mix-1'], 'synced');
      expect(statusMap['mix-2'], 'synced');
      expect(statusMap['mix-3'], 'failed');
      expect(statusMap['mix-4'], 'conflict');
      expect(statusMap['mix-5'], 'pending');
    });
  });
}
