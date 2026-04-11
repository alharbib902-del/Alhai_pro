import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_sync/src/sync_service.dart';

import '../helpers/sync_test_helpers.dart';

void main() {
  late MockSyncQueueDao mockSyncQueueDao;
  late SyncService syncService;

  setUpAll(() {
    registerSyncFallbackValues();
  });

  setUp(() {
    mockSyncQueueDao = MockSyncQueueDao();
    syncService = SyncService(mockSyncQueueDao);

    // Default stubs needed by enqueue's queue-health check and cross-op dedup
    when(() => mockSyncQueueDao.getQueueHealth()).thenAnswer(
      (_) async => SyncQueueHealth(
        totalItems: 10,
        pendingCount: 5,
        syncingCount: 0,
        failedCount: 0,
        conflictCount: 0,
        syncedCount: 5,
        oldestPendingAt: null,
        avgRetryCount: 0,
        itemsPerTable: {},
      ),
    );
    when(
      () => mockSyncQueueDao.findPendingByTableRecord(any(), any()),
    ).thenAnswer((_) async => []);
  });

  group('SyncService', () {
    group('enqueue', () {
      test('creates new queue entry when no duplicate exists', () async {
        when(
          () => mockSyncQueueDao.findByIdempotencyKey(any()),
        ).thenAnswer((_) async => null);
        when(
          () => mockSyncQueueDao.enqueue(
            id: any(named: 'id'),
            tableName: any(named: 'tableName'),
            recordId: any(named: 'recordId'),
            operation: any(named: 'operation'),
            payload: any(named: 'payload'),
            idempotencyKey: any(named: 'idempotencyKey'),
            priority: any(named: 'priority'),
          ),
        ).thenAnswer((_) async => 1);

        final id = await syncService.enqueue(
          tableName: 'products',
          recordId: 'p-1',
          operation: SyncOperation.create,
          payload: {'id': 'p-1', 'name': 'Test'},
        );

        expect(id, isNotEmpty);
        verify(
          () => mockSyncQueueDao.enqueue(
            id: any(named: 'id'),
            tableName: 'products',
            recordId: 'p-1',
            operation: 'CREATE',
            payload: any(named: 'payload'),
            idempotencyKey: 'products_p-1_create',
            priority: 2,
          ),
        ).called(1);
      });

      test('returns existing id when duplicate exists', () async {
        final existingItem = createSyncQueueItem(id: 'existing-id');
        when(
          () => mockSyncQueueDao.findByIdempotencyKey(any()),
        ).thenAnswer((_) async => existingItem);
        when(
          () => mockSyncQueueDao.updatePayload(any(), any()),
        ).thenAnswer((_) async => 1);

        final id = await syncService.enqueue(
          tableName: 'products',
          recordId: 'record-1',
          operation: SyncOperation.create,
          payload: {'id': 'record-1'},
        );

        expect(id, 'existing-id');
        verifyNever(
          () => mockSyncQueueDao.enqueue(
            id: any(named: 'id'),
            tableName: any(named: 'tableName'),
            recordId: any(named: 'recordId'),
            operation: any(named: 'operation'),
            payload: any(named: 'payload'),
            idempotencyKey: any(named: 'idempotencyKey'),
            priority: any(named: 'priority'),
          ),
        );
      });

      test('uses correct priority value', () async {
        when(
          () => mockSyncQueueDao.findByIdempotencyKey(any()),
        ).thenAnswer((_) async => null);
        when(
          () => mockSyncQueueDao.enqueue(
            id: any(named: 'id'),
            tableName: any(named: 'tableName'),
            recordId: any(named: 'recordId'),
            operation: any(named: 'operation'),
            payload: any(named: 'payload'),
            idempotencyKey: any(named: 'idempotencyKey'),
            priority: any(named: 'priority'),
          ),
        ).thenAnswer((_) async => 1);

        await syncService.enqueue(
          tableName: 'sales',
          recordId: 's-1',
          operation: SyncOperation.create,
          payload: {'id': 's-1'},
          priority: SyncPriority.high,
        );

        verify(
          () => mockSyncQueueDao.enqueue(
            id: any(named: 'id'),
            tableName: 'sales',
            recordId: 's-1',
            operation: 'CREATE',
            payload: any(named: 'payload'),
            idempotencyKey: any(named: 'idempotencyKey'),
            priority: 3,
          ),
        ).called(1);
      });

      test('encodes payload as JSON', () async {
        when(
          () => mockSyncQueueDao.findByIdempotencyKey(any()),
        ).thenAnswer((_) async => null);
        when(
          () => mockSyncQueueDao.enqueue(
            id: any(named: 'id'),
            tableName: any(named: 'tableName'),
            recordId: any(named: 'recordId'),
            operation: any(named: 'operation'),
            payload: any(named: 'payload'),
            idempotencyKey: any(named: 'idempotencyKey'),
            priority: any(named: 'priority'),
          ),
        ).thenAnswer((_) async => 1);

        final testPayload = {'id': 'p-1', 'name': 'Test', 'price': 10.5};
        await syncService.enqueue(
          tableName: 'products',
          recordId: 'p-1',
          operation: SyncOperation.update,
          payload: testPayload,
        );

        final captured = verify(
          () => mockSyncQueueDao.enqueue(
            id: any(named: 'id'),
            tableName: any(named: 'tableName'),
            recordId: any(named: 'recordId'),
            operation: any(named: 'operation'),
            payload: captureAny(named: 'payload'),
            idempotencyKey: any(named: 'idempotencyKey'),
            priority: any(named: 'priority'),
          ),
        ).captured;

        final encodedPayload = captured.first as String;
        final decoded = jsonDecode(encodedPayload) as Map<String, dynamic>;
        expect(decoded['name'], 'Test');
        expect(decoded['price'], 10.5);
      });
    });

    group('enqueueCreate', () {
      test('delegates to enqueue with create operation', () async {
        when(
          () => mockSyncQueueDao.findByIdempotencyKey(any()),
        ).thenAnswer((_) async => null);
        when(
          () => mockSyncQueueDao.enqueue(
            id: any(named: 'id'),
            tableName: any(named: 'tableName'),
            recordId: any(named: 'recordId'),
            operation: any(named: 'operation'),
            payload: any(named: 'payload'),
            idempotencyKey: any(named: 'idempotencyKey'),
            priority: any(named: 'priority'),
          ),
        ).thenAnswer((_) async => 1);

        await syncService.enqueueCreate(
          tableName: 'products',
          recordId: 'p-1',
          data: {'id': 'p-1'},
        );

        verify(
          () => mockSyncQueueDao.enqueue(
            id: any(named: 'id'),
            tableName: 'products',
            recordId: 'p-1',
            operation: 'CREATE',
            payload: any(named: 'payload'),
            idempotencyKey: any(named: 'idempotencyKey'),
            priority: any(named: 'priority'),
          ),
        ).called(1);
      });
    });

    group('enqueueUpdate', () {
      test('delegates to enqueue with update operation', () async {
        when(
          () => mockSyncQueueDao.findByIdempotencyKey(any()),
        ).thenAnswer((_) async => null);
        when(
          () => mockSyncQueueDao.enqueue(
            id: any(named: 'id'),
            tableName: any(named: 'tableName'),
            recordId: any(named: 'recordId'),
            operation: any(named: 'operation'),
            payload: any(named: 'payload'),
            idempotencyKey: any(named: 'idempotencyKey'),
            priority: any(named: 'priority'),
          ),
        ).thenAnswer((_) async => 1);

        await syncService.enqueueUpdate(
          tableName: 'products',
          recordId: 'p-1',
          changes: {'id': 'p-1', 'name': 'Updated'},
        );

        verify(
          () => mockSyncQueueDao.enqueue(
            id: any(named: 'id'),
            tableName: 'products',
            recordId: 'p-1',
            operation: 'UPDATE',
            payload: any(named: 'payload'),
            idempotencyKey: any(named: 'idempotencyKey'),
            priority: any(named: 'priority'),
          ),
        ).called(1);
      });
    });

    group('enqueueDelete', () {
      test(
        'delegates to enqueue with delete operation and deleted payload',
        () async {
          when(
            () => mockSyncQueueDao.findByIdempotencyKey(any()),
          ).thenAnswer((_) async => null);
          when(
            () => mockSyncQueueDao.enqueue(
              id: any(named: 'id'),
              tableName: any(named: 'tableName'),
              recordId: any(named: 'recordId'),
              operation: any(named: 'operation'),
              payload: any(named: 'payload'),
              idempotencyKey: any(named: 'idempotencyKey'),
              priority: any(named: 'priority'),
            ),
          ).thenAnswer((_) async => 1);

          await syncService.enqueueDelete(
            tableName: 'products',
            recordId: 'p-1',
          );

          final captured = verify(
            () => mockSyncQueueDao.enqueue(
              id: any(named: 'id'),
              tableName: 'products',
              recordId: 'p-1',
              operation: 'DELETE',
              payload: captureAny(named: 'payload'),
              idempotencyKey: any(named: 'idempotencyKey'),
              priority: any(named: 'priority'),
            ),
          ).captured;

          final payload =
              jsonDecode(captured.first as String) as Map<String, dynamic>;
          expect(payload['deleted'], true);
        },
      );
    });

    group('getPendingItems', () {
      test('delegates to DAO', () async {
        final items = [createSyncQueueItem()];
        when(
          () => mockSyncQueueDao.getPendingItems(),
        ).thenAnswer((_) async => items);

        final result = await syncService.getPendingItems();

        expect(result, items);
        verify(() => mockSyncQueueDao.getPendingItems()).called(1);
      });
    });

    group('getPendingCount', () {
      test('delegates to DAO', () async {
        when(
          () => mockSyncQueueDao.getPendingCount(),
        ).thenAnswer((_) async => 5);

        final result = await syncService.getPendingCount();

        expect(result, 5);
      });
    });

    group('watchPendingCount', () {
      test('delegates to DAO stream', () {
        when(
          () => mockSyncQueueDao.watchPendingCount(),
        ).thenAnswer((_) => Stream.fromIterable([0, 3, 5]));

        final stream = syncService.watchPendingCount();

        expectLater(stream, emitsInOrder([0, 3, 5]));
      });
    });

    group('markAsSyncing', () {
      test('delegates to DAO', () async {
        when(
          () => mockSyncQueueDao.markAsSyncing(any()),
        ).thenAnswer((_) async => 1);

        await syncService.markAsSyncing('test-id');

        verify(() => mockSyncQueueDao.markAsSyncing('test-id')).called(1);
      });
    });

    group('markAsSynced', () {
      test('delegates to DAO', () async {
        when(
          () => mockSyncQueueDao.markAsSynced(any()),
        ).thenAnswer((_) async => 1);

        await syncService.markAsSynced('test-id');

        verify(() => mockSyncQueueDao.markAsSynced('test-id')).called(1);
      });
    });

    group('markAsFailed', () {
      test('delegates to DAO with error', () async {
        when(
          () => mockSyncQueueDao.markAsFailed(any(), any()),
        ).thenAnswer((_) async => 1);

        await syncService.markAsFailed('test-id', 'Network error');

        verify(
          () => mockSyncQueueDao.markAsFailed('test-id', 'Network error'),
        ).called(1);
      });
    });

    group('getConflictItems', () {
      test('delegates to DAO', () async {
        final items = [createSyncQueueItem(status: 'conflict')];
        when(
          () => mockSyncQueueDao.getConflictItems(),
        ).thenAnswer((_) async => items);

        final result = await syncService.getConflictItems();

        expect(result, items);
      });
    });

    group('watchPendingItems', () {
      test('delegates to DAO stream', () {
        final items = [createSyncQueueItem()];
        when(
          () => mockSyncQueueDao.watchPendingItems(),
        ).thenAnswer((_) => Stream.value(items));

        final stream = syncService.watchPendingItems();

        expectLater(stream, emits(items));
      });
    });

    group('watchConflictItems', () {
      test('delegates to DAO stream', () {
        final items = [createSyncQueueItem(status: 'conflict')];
        when(
          () => mockSyncQueueDao.watchConflictItems(),
        ).thenAnswer((_) => Stream.value(items));

        final stream = syncService.watchConflictItems();

        expectLater(stream, emits(items));
      });
    });

    group('watchConflictCount', () {
      test('delegates to DAO stream', () {
        when(
          () => mockSyncQueueDao.watchConflictCount(),
        ).thenAnswer((_) => Stream.fromIterable([0, 2]));

        final stream = syncService.watchConflictCount();

        expectLater(stream, emitsInOrder([0, 2]));
      });
    });

    group('markResolved', () {
      test('delegates to DAO', () async {
        when(
          () => mockSyncQueueDao.markResolved(any()),
        ).thenAnswer((_) async => 1);

        await syncService.markResolved('test-id');

        verify(() => mockSyncQueueDao.markResolved('test-id')).called(1);
      });
    });

    group('markAsConflict', () {
      test('delegates to DAO with error', () async {
        when(
          () => mockSyncQueueDao.markAsConflict(any(), any()),
        ).thenAnswer((_) async => 1);

        await syncService.markAsConflict('test-id', 'Conflict detected');

        verify(
          () => mockSyncQueueDao.markAsConflict('test-id', 'Conflict detected'),
        ).called(1);
      });
    });

    group('retryItem', () {
      test('delegates to DAO', () async {
        when(
          () => mockSyncQueueDao.retryItem(any()),
        ).thenAnswer((_) async => 1);

        await syncService.retryItem('test-id');

        verify(() => mockSyncQueueDao.retryItem('test-id')).called(1);
      });
    });

    group('removeItem', () {
      test('delegates to DAO', () async {
        when(
          () => mockSyncQueueDao.removeItem(any()),
        ).thenAnswer((_) async => 1);

        await syncService.removeItem('test-id');

        verify(() => mockSyncQueueDao.removeItem('test-id')).called(1);
      });
    });

    group('cleanup', () {
      test('delegates to DAO with default duration', () async {
        when(
          () => mockSyncQueueDao.cleanupSyncedItems(
            olderThan: any(named: 'olderThan'),
          ),
        ).thenAnswer((_) async => 10);

        final result = await syncService.cleanup();

        expect(result, 10);
        verify(
          () => mockSyncQueueDao.cleanupSyncedItems(
            olderThan: const Duration(days: 7),
          ),
        ).called(1);
      });

      test('delegates to DAO with custom duration', () async {
        when(
          () => mockSyncQueueDao.cleanupSyncedItems(
            olderThan: any(named: 'olderThan'),
          ),
        ).thenAnswer((_) async => 5);

        final result = await syncService.cleanup(
          olderThan: const Duration(days: 1),
        );

        expect(result, 5);
        verify(
          () => mockSyncQueueDao.cleanupSyncedItems(
            olderThan: const Duration(days: 1),
          ),
        ).called(1);
      });
    });
  });
}
