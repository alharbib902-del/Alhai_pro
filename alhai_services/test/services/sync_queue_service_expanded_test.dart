import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

void main() {
  late SyncQueueServiceImpl syncService;

  setUp(() {
    syncService = SyncQueueServiceImpl();
    syncService.clearQueue();
  });

  group('SyncQueueServiceImpl - Expanded', () {
    group('max retry limit enforcement', () {
      test('should not allow retry after max attempts reached', () async {
        // Arrange
        final item = await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-1',
          operation: SyncOperationType.create,
          payload: {'total': 100},
        );

        // Fail the item 3 times (default maxAttempts = 3)
        await syncService.markFailed(item.id, 'Error 1');
        await syncService.markFailed(item.id, 'Error 2');
        await syncService.markFailed(item.id, 'Error 3');

        // Act & Assert
        expect(
          () => syncService.retryItem(item.id),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('cannot be retried'),
          )),
        );
      });

      test('should allow retry before max attempts', () async {
        // Arrange
        final item = await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-1',
          operation: SyncOperationType.create,
          payload: {'total': 100},
        );

        // Fail once
        await syncService.markFailed(item.id, 'First error');

        // Act - should succeed since 1 < 3
        final retried = await syncService.retryItem(item.id);

        // Assert
        expect(retried.status, equals(SyncStatus.pending));
      });

      test('canRetry should be false when status is not failed', () async {
        final item = await syncService.enqueue(
          entityType: SyncEntityType.order,
          entityId: 'order-1',
          operation: SyncOperationType.create,
          payload: {},
        );

        // Item is pending, not failed
        expect(item.canRetry, isFalse);
      });
    });

    group('exponential backoff timing', () {
      test('first failure should set ~1 minute backoff', () async {
        final item = await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-1',
          operation: SyncOperationType.create,
          payload: {'total': 50},
        );

        final beforeFail = DateTime.now();
        await syncService.markFailed(item.id, 'Network error');

        // Get the updated item from the queue
        final allItems = syncService.getAllItems();
        final failedItem = allItems.firstWhere((i) => i.id == item.id);

        // backoffMinutes = (1 << (1 - 1)).clamp(1, 60) = 1
        // nextRetry should be ~1 minute from now
        expect(failedItem.nextRetryAt, isNotNull);
        final expectedMin = beforeFail.add(const Duration(minutes: 1));
        expect(
          failedItem.nextRetryAt!.difference(expectedMin).inSeconds.abs(),
          lessThan(5),
        );
      });

      test('second failure should set ~2 minute backoff', () async {
        final item = await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-2',
          operation: SyncOperationType.update,
          payload: {'status': 'voided'},
        );

        await syncService.markFailed(item.id, 'Error 1');
        final beforeSecondFail = DateTime.now();
        await syncService.markFailed(item.id, 'Error 2');

        final allItems = syncService.getAllItems();
        final failedItem = allItems.firstWhere((i) => i.id == item.id);

        // backoffMinutes = (1 << (2 - 1)).clamp(1, 60) = 2
        final expectedMin = beforeSecondFail.add(const Duration(minutes: 2));
        expect(failedItem.nextRetryAt, isNotNull);
        expect(
          failedItem.nextRetryAt!.difference(expectedMin).inSeconds.abs(),
          lessThan(5),
        );
      });

      test('backoff should be clamped at 60 minutes max', () async {
        final item = await syncService.enqueue(
          entityType: SyncEntityType.inventory,
          entityId: 'inv-1',
          operation: SyncOperationType.update,
          payload: {'qty': 5},
        );

        // Fail 10 times to trigger high backoff
        // 2^9 = 512, but should be clamped to 60
        for (int i = 0; i < 10; i++) {
          await syncService.markFailed(item.id, 'Error $i');
        }

        final allItems = syncService.getAllItems();
        final failedItem = allItems.firstWhere((i) => i.id == item.id);
        expect(failedItem.attempts, equals(10));

        // The backoff for attempt 10 would be 2^9 = 512, clamped to 60
        // We verify nextRetryAt is not more than ~61 minutes from now
        final maxExpected = DateTime.now().add(const Duration(minutes: 61));
        expect(failedItem.nextRetryAt!.isBefore(maxExpected), isTrue);
      });
    });

    group('conflict detection and resolution', () {
      test('should add and retrieve unresolved conflicts', () async {
        // Arrange
        syncService.addConflict(
          entityType: SyncEntityType.product,
          entityId: 'prod-1',
          localValue: {'price': 10.0},
          serverValue: {'price': 12.0},
        );

        // Act
        final conflicts = await syncService.getConflicts();

        // Assert
        expect(conflicts.length, equals(1));
        expect(conflicts.first.entityId, equals('prod-1'));
        expect(conflicts.first.localValue['price'], equals(10.0));
        expect(conflicts.first.serverValue['price'], equals(12.0));
        expect(conflicts.first.isResolved, isFalse);
      });

      test('resolveConflict with acceptLocal should re-enqueue local value',
          () async {
        syncService.addConflict(
          entityType: SyncEntityType.product,
          entityId: 'prod-1',
          localValue: {'price': 10.0, 'name': 'Local'},
          serverValue: {'price': 12.0, 'name': 'Server'},
        );

        final conflicts = await syncService.getConflicts();
        await syncService.resolveConflict(
          conflicts.first.id,
          ConflictResolution.acceptLocal,
        );

        // Conflict should be resolved
        final unresolvedConflicts = await syncService.getConflicts();
        expect(unresolvedConflicts, isEmpty);

        // A new sync item should be enqueued with local value
        final pending = await syncService.getPendingItems();
        expect(pending.length, equals(1));
      });

      test('resolveConflict with acceptServer should not enqueue anything',
          () async {
        syncService.addConflict(
          entityType: SyncEntityType.product,
          entityId: 'prod-1',
          localValue: {'price': 10.0},
          serverValue: {'price': 12.0},
        );

        final conflicts = await syncService.getConflicts();
        await syncService.resolveConflict(
          conflicts.first.id,
          ConflictResolution.acceptServer,
        );

        // No new items should be enqueued
        final pending = await syncService.getPendingItems();
        expect(pending, isEmpty);
      });

      test('resolveConflict with merge should enqueue merged data', () async {
        syncService.addConflict(
          entityType: SyncEntityType.product,
          entityId: 'prod-1',
          localValue: {'price': 10.0, 'localOnly': 'yes'},
          serverValue: {'price': 12.0, 'serverOnly': 'yes'},
        );

        final conflicts = await syncService.getConflicts();
        await syncService.resolveConflict(
          conflicts.first.id,
          ConflictResolution.merge,
        );

        final pending = await syncService.getPendingItems();
        expect(pending.length, equals(1));
      });

      test('resolveConflict with invalid ID should throw', () async {
        expect(
          () => syncService.resolveConflict(
            'non-existent-id',
            ConflictResolution.acceptServer,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('conflict count should appear in summary', () async {
        syncService.addConflict(
          entityType: SyncEntityType.product,
          entityId: 'prod-1',
          localValue: {'price': 10.0},
          serverValue: {'price': 12.0},
        );

        syncService.addConflict(
          entityType: SyncEntityType.customer,
          entityId: 'cust-1',
          localValue: {'name': 'Local'},
          serverValue: {'name': 'Server'},
        );

        final summary = await syncService.getSummary();
        expect(summary.conflictCount, equals(2));
        expect(summary.hasIssues, isTrue);
      });
    });

    group('dequeue order (FIFO)', () {
      test('processQueue should process oldest items first', () async {
        // Arrange - enqueue items at different "times"
        await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-oldest',
          operation: SyncOperationType.create,
          payload: {'order': 1},
        );

        await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-middle',
          operation: SyncOperationType.create,
          payload: {'order': 2},
        );

        await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-newest',
          operation: SyncOperationType.create,
          payload: {'order': 3},
        );

        // Track processing order
        final processedOrder = <String>[];
        syncService.setSyncHandler((item) async {
          processedOrder.add(item.entityId);
          return true;
        });

        // Act
        await syncService.processQueue();

        // Assert - should be processed in FIFO order
        expect(processedOrder,
            equals(['sale-oldest', 'sale-middle', 'sale-newest']));
      });

      test('failed items should also be processed in FIFO order', () async {
        // Arrange
        final item1 = await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-1',
          operation: SyncOperationType.create,
          payload: {},
        );

        final item2 = await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-2',
          operation: SyncOperationType.create,
          payload: {},
        );

        // Mark both as failed (they become needsSync = true)
        await syncService.markFailed(item1.id, 'Error');
        await syncService.markFailed(item2.id, 'Error');

        final processedOrder = <String>[];
        syncService.setSyncHandler((item) async {
          processedOrder.add(item.entityId);
          return true;
        });

        // Act
        await syncService.processQueue();

        // Assert
        expect(processedOrder.first, equals('sale-1'));
        expect(processedOrder.last, equals('sale-2'));
      });
    });

    group('concurrent sync prevention', () {
      test('processQueue should return 0 if already processing', () async {
        // Arrange - set up a slow handler to keep processing busy
        syncService.setSyncHandler((item) async {
          await Future.delayed(const Duration(milliseconds: 500));
          return true;
        });

        await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-1',
          operation: SyncOperationType.create,
          payload: {'total': 100},
        );

        // Act - start processing and try to process again immediately
        final firstProcess = syncService.processQueue();
        // Small delay to ensure the first process has started
        await Future.delayed(const Duration(milliseconds: 50));
        final secondResult = await syncService.processQueue();

        // Assert - second call should return 0 (skipped)
        expect(secondResult, equals(0));

        // Wait for first to complete
        final firstResult = await firstProcess;
        expect(firstResult, equals(1));
      });

      test('processQueue should return 0 when offline', () async {
        // Arrange
        syncService.setConnectivityCheck(() async => false);

        await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-1',
          operation: SyncOperationType.create,
          payload: {'total': 100},
        );

        // Act
        final result = await syncService.processQueue();

        // Assert
        expect(result, equals(0));
      });
    });

    group('clearSyncedItems', () {
      test('should only remove synced items', () async {
        // Arrange
        final item1 = await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-1',
          operation: SyncOperationType.create,
          payload: {},
        );

        await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-2',
          operation: SyncOperationType.create,
          payload: {},
        );

        // Mark first as synced
        await syncService.markSynced(item1.id);

        // Act
        final cleared = await syncService.clearSyncedItems();

        // Assert
        expect(cleared, equals(1));
        final remaining = syncService.getAllItems();
        expect(remaining.length, equals(1));
        expect(remaining.first.entityId, equals('sale-2'));
      });
    });

    group('hasPendingItems', () {
      test('should return false when queue is empty', () async {
        expect(await syncService.hasPendingItems(), isFalse);
      });

      test('should return true when there are pending items', () async {
        await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-1',
          operation: SyncOperationType.create,
          payload: {},
        );

        expect(await syncService.hasPendingItems(), isTrue);
      });

      test('should return false when all items are synced', () async {
        final item = await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-1',
          operation: SyncOperationType.create,
          payload: {},
        );

        await syncService.markSynced(item.id);

        expect(await syncService.hasPendingItems(), isFalse);
      });

      test('should return true when there are failed items', () async {
        final item = await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-1',
          operation: SyncOperationType.create,
          payload: {},
        );

        await syncService.markFailed(item.id, 'Error');

        // failed items have needsSync = true
        expect(await syncService.hasPendingItems(), isTrue);
      });
    });

    group('background sync', () {
      test('startBackgroundSync should process pending items', () async {
        // Arrange
        syncService.setConnectivityCheck(() async => true);
        syncService.setSyncHandler((item) async => true);

        await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-1',
          operation: SyncOperationType.create,
          payload: {'total': 100},
        );

        // Act
        await syncService.startBackgroundSync();

        // Assert - the item should have been processed
        final summary = await syncService.getSummary();
        expect(summary.syncedCount, equals(1));
        expect(summary.pendingCount, equals(0));
      });

      test('stopBackgroundSync should disable auto-sync', () async {
        syncService.setConnectivityCheck(() async => true);
        await syncService.startBackgroundSync();
        await syncService.stopBackgroundSync();

        // Enqueue after stopping - should NOT auto-process
        // (the queue won't auto-process because background sync is off)
        // We verify the item stays pending
        await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-2',
          operation: SyncOperationType.create,
          payload: {'total': 200},
        );

        // Give a small delay
        await Future.delayed(const Duration(milliseconds: 100));

        final pending = await syncService.getPendingItems();
        // The first enqueue during startBackgroundSync might have been processed,
        // but sale-2 should remain pending since background sync is off
        final sale2Pending = pending.where((i) => i.entityId == 'sale-2');
        expect(sale2Pending.isNotEmpty, isTrue);
      });
    });

    group('summary', () {
      test('should accurately count items by status', () async {
        // Arrange - create items with different statuses
        await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-pending',
          operation: SyncOperationType.create,
          payload: {},
        );

        final syncedItem = await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-synced',
          operation: SyncOperationType.create,
          payload: {},
        );
        await syncService.markSynced(syncedItem.id);

        final failedItem = await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-failed',
          operation: SyncOperationType.create,
          payload: {},
        );
        await syncService.markFailed(failedItem.id, 'Error');

        // Act
        final summary = await syncService.getSummary();

        // Assert
        expect(summary.pendingCount, equals(1));
        expect(summary.syncedCount, equals(1));
        expect(summary.failedCount, equals(1));
        expect(summary.totalPending, equals(1));
        expect(summary.totalIssues, equals(1));
        expect(summary.hasIssues, isTrue);
        expect(summary.isAllSynced, isFalse);
      });

      test('isAllSynced should be true when no pending or failed', () async {
        final item = await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-1',
          operation: SyncOperationType.create,
          payload: {},
        );
        await syncService.markSynced(item.id);

        final summary = await syncService.getSummary();
        expect(summary.isAllSynced, isTrue);
      });
    });

    group('processQueue with sync handler', () {
      test('should mark items as failed when handler returns false', () async {
        syncService.setSyncHandler((item) async => false);

        await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-1',
          operation: SyncOperationType.create,
          payload: {},
        );

        await syncService.processQueue();

        final summary = await syncService.getSummary();
        expect(summary.failedCount, equals(1));
        expect(summary.syncedCount, equals(0));
      });

      test('should mark items as failed when handler throws', () async {
        syncService.setSyncHandler((item) async {
          throw Exception('API error');
        });

        await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-1',
          operation: SyncOperationType.create,
          payload: {},
        );

        await syncService.processQueue();

        final summary = await syncService.getSummary();
        expect(summary.failedCount, equals(1));
      });

      test('should update lastSyncAt after processing', () async {
        syncService.setSyncHandler((item) async => true);

        await syncService.enqueue(
          entityType: SyncEntityType.sale,
          entityId: 'sale-1',
          operation: SyncOperationType.create,
          payload: {},
        );

        final before = DateTime.now();
        await syncService.processQueue();

        final summary = await syncService.getSummary();
        expect(summary.lastSyncAt, isNotNull);
        expect(
          summary.lastSyncAt!.isAfter(before) ||
              summary.lastSyncAt!.isAtSameMomentAs(before),
          isTrue,
        );
      });
    });
  });
}
