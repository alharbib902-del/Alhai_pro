import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_sync/src/sync_service.dart';

// ─── Mocks ──────────────────────────────────────────────────────────

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

void main() {
  late MockSyncQueueDao mockDao;
  late SyncService service;

  setUpAll(() {
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    mockDao = MockSyncQueueDao();
    service = SyncService(mockDao);
  });

  // ─── Payload validation ───────────────────────────────────────────

  group('Payload validation', () {
    test('rejects empty payload', () async {
      _setupHealthyQueue(mockDao);
      await expectLater(
        service.enqueue(
          tableName: 'products',
          recordId: 'r1',
          operation: SyncOperation.create,
          payload: {},
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects payload without id (non-delete)', () async {
      _setupHealthyQueue(mockDao);
      await expectLater(
        service.enqueue(
          tableName: 'products',
          recordId: 'r1',
          operation: SyncOperation.create,
          payload: {'name': 'test'},
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('accepts delete payload with only deleted:true', () async {
      // Setup mocks for a successful enqueue path
      _setupHealthyQueue(mockDao);
      _setupNoPendingItems(mockDao);
      _setupNoExistingIdempotency(mockDao);
      _setupEnqueueSuccess(mockDao);

      final id = await service.enqueueDelete(
        tableName: 'products',
        recordId: 'r1',
      );
      expect(id, isA<String>());
    });

    test('rejects payload with NaN value', () async {
      _setupHealthyQueue(mockDao);
      await expectLater(
        service.enqueue(
          tableName: 'products',
          recordId: 'r1',
          operation: SyncOperation.update,
          payload: {'id': 'r1', 'price': double.nan},
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects payload with Infinity value', () async {
      _setupHealthyQueue(mockDao);
      await expectLater(
        service.enqueue(
          tableName: 'products',
          recordId: 'r1',
          operation: SyncOperation.update,
          payload: {'id': 'r1', 'price': double.infinity},
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects payload with unreasonable date (before 2020)', () async {
      expect(
        () => service.enqueue(
          tableName: 'sales',
          recordId: 'r1',
          operation: SyncOperation.create,
          payload: {'id': 'r1', 'created_at': '2019-01-01T00:00:00Z'},
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects payload with unreasonable date (after 2100)', () async {
      expect(
        () => service.enqueue(
          tableName: 'sales',
          recordId: 'r1',
          operation: SyncOperation.create,
          payload: {'id': 'r1', 'created_at': '2101-01-01T00:00:00Z'},
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('accepts payload with valid date', () async {
      _setupHealthyQueue(mockDao);
      _setupNoPendingItems(mockDao);
      _setupNoExistingIdempotency(mockDao);
      _setupEnqueueSuccess(mockDao);

      final id = await service.enqueue(
        tableName: 'sales',
        recordId: 'r1',
        operation: SyncOperation.create,
        payload: {'id': 'r1', 'created_at': '2025-06-15T10:00:00Z'},
      );
      expect(id, isA<String>());
    });
  });

  // ─── Enqueue convenience methods ──────────────────────────────────

  group('Enqueue convenience methods', () {
    setUp(() {
      _setupHealthyQueue(mockDao);
      _setupNoPendingItems(mockDao);
      _setupNoExistingIdempotency(mockDao);
      _setupEnqueueSuccess(mockDao);
    });

    test('enqueueCreate delegates to enqueue with create operation', () async {
      final id = await service.enqueueCreate(
        tableName: 'products',
        recordId: 'r1',
        data: {'id': 'r1', 'name': 'Test'},
      );
      expect(id, isA<String>());
      verify(() => mockDao.enqueue(
            id: any(named: 'id'),
            tableName: 'products',
            recordId: 'r1',
            operation: 'CREATE',
            payload: any(named: 'payload'),
            idempotencyKey: any(named: 'idempotencyKey'),
            priority: any(named: 'priority'),
          )).called(1);
    });

    test('enqueueUpdate delegates to enqueue with update operation', () async {
      final id = await service.enqueueUpdate(
        tableName: 'products',
        recordId: 'r1',
        changes: {'id': 'r1', 'price': 10.0},
      );
      expect(id, isA<String>());
      verify(() => mockDao.enqueue(
            id: any(named: 'id'),
            tableName: 'products',
            recordId: 'r1',
            operation: 'UPDATE',
            payload: any(named: 'payload'),
            idempotencyKey: any(named: 'idempotencyKey'),
            priority: any(named: 'priority'),
          )).called(1);
    });

    test('enqueueDelete delegates with deleted:true payload', () async {
      final id = await service.enqueueDelete(
        tableName: 'products',
        recordId: 'r1',
      );
      expect(id, isA<String>());
      verify(() => mockDao.enqueue(
            id: any(named: 'id'),
            tableName: 'products',
            recordId: 'r1',
            operation: 'DELETE',
            payload: jsonEncode({'deleted': true}),
            idempotencyKey: any(named: 'idempotencyKey'),
            priority: any(named: 'priority'),
          )).called(1);
    });
  });

  // ─── Deduplication (same-operation) ───────────────────────────────

  group('Same-operation deduplication', () {
    test('coalesces update to pending item instead of creating new', () async {
      _setupHealthyQueue(mockDao);
      _setupNoPendingItems(mockDao);

      // Simulate existing pending item with same idempotency key
      final existingItem = _fakeSyncQueueItem(
        id: 'existing-id',
        status: 'pending',
        operation: 'UPDATE',
      );
      when(() => mockDao.findByIdempotencyKey(any()))
          .thenAnswer((_) async => existingItem);
      when(() => mockDao.updatePayload(any(), any()))
          .thenAnswer((_) async => 1);

      final id = await service.enqueue(
        tableName: 'products',
        recordId: 'r1',
        operation: SyncOperation.update,
        payload: {'id': 'r1', 'price': 20.0},
      );

      expect(id, 'existing-id');
      verify(() => mockDao.updatePayload('existing-id', any())).called(1);
      verifyNever(() => mockDao.enqueue(
            id: any(named: 'id'),
            tableName: any(named: 'tableName'),
            recordId: any(named: 'recordId'),
            operation: any(named: 'operation'),
            payload: any(named: 'payload'),
            idempotencyKey: any(named: 'idempotencyKey'),
            priority: any(named: 'priority'),
          ));
    });
  });

  // ─── Queue overload protection ────────────────────────────────────

  group('Queue overload protection', () {
    test('high-priority tables are not downgraded when queue is overloaded',
        () async {
      // Setup overloaded queue
      _setupOverloadedQueue(mockDao);
      _setupNoPendingItems(mockDao);
      _setupNoExistingIdempotency(mockDao);
      _setupEnqueueSuccess(mockDao);

      await service.enqueueCreate(
        tableName: 'sales', // high-priority table
        recordId: 'r1',
        data: {'id': 'r1', 'total': 100.0},
      );

      // Should enqueue with normal priority (2), not downgraded to low (1)
      verify(() => mockDao.enqueue(
            id: any(named: 'id'),
            tableName: 'sales',
            recordId: 'r1',
            operation: 'CREATE',
            payload: any(named: 'payload'),
            idempotencyKey: any(named: 'idempotencyKey'),
            priority: 2, // normal priority preserved
          )).called(1);
    });

    test('low-priority tables are downgraded when queue is overloaded',
        () async {
      _setupOverloadedQueue(mockDao);
      _setupNoPendingItems(mockDao);
      _setupNoExistingIdempotency(mockDao);
      _setupEnqueueSuccess(mockDao);

      await service.enqueueCreate(
        tableName: 'categories', // non-high-priority table
        recordId: 'r1',
        data: {'id': 'r1', 'name': 'Food'},
      );

      // Should enqueue with low priority (1)
      verify(() => mockDao.enqueue(
            id: any(named: 'id'),
            tableName: 'categories',
            recordId: 'r1',
            operation: 'CREATE',
            payload: any(named: 'payload'),
            idempotencyKey: any(named: 'idempotencyKey'),
            priority: 1, // downgraded to low
          )).called(1);
    });
  });

  // ─── Delegation methods ───────────────────────────────────────────

  group('DAO delegation methods', () {
    test('getPendingItems delegates to DAO', () async {
      when(() => mockDao.getPendingItems()).thenAnswer((_) async => []);
      final items = await service.getPendingItems();
      expect(items, isEmpty);
      verify(() => mockDao.getPendingItems()).called(1);
    });

    test('getPendingCount delegates to DAO', () async {
      when(() => mockDao.getPendingCount()).thenAnswer((_) async => 5);
      final count = await service.getPendingCount();
      expect(count, 5);
    });

    test('markAsSyncing delegates to DAO', () async {
      when(() => mockDao.markAsSyncing(any())).thenAnswer((_) async => 1);
      await service.markAsSyncing('id-1');
      verify(() => mockDao.markAsSyncing('id-1')).called(1);
    });

    test('markAsSynced delegates to DAO', () async {
      when(() => mockDao.markAsSynced(any())).thenAnswer((_) async => 1);
      await service.markAsSynced('id-1');
      verify(() => mockDao.markAsSynced('id-1')).called(1);
    });

    test('markAsFailed delegates to DAO', () async {
      when(() => mockDao.markAsFailed(any(), any())).thenAnswer((_) async => 1);
      await service.markAsFailed('id-1', 'timeout');
      verify(() => mockDao.markAsFailed('id-1', 'timeout')).called(1);
    });

    test('cleanup delegates to DAO with default duration', () async {
      when(() => mockDao.cleanupSyncedItems(olderThan: any(named: 'olderThan')))
          .thenAnswer((_) async => 10);
      final count = await service.cleanup();
      expect(count, 10);
    });

    test('resetStuckItems delegates to DAO', () async {
      when(() => mockDao.resetStuckItems()).thenAnswer((_) async => 3);
      final count = await service.resetStuckItems();
      expect(count, 3);
    });

    test('isQueueOverloaded returns false for healthy queue', () async {
      _setupHealthyQueue(mockDao);
      final overloaded = await service.isQueueOverloaded();
      expect(overloaded, isFalse);
    });

    test('isQueueOverloaded returns true for overloaded queue', () async {
      _setupOverloadedQueue(mockDao);
      final overloaded = await service.isQueueOverloaded();
      expect(overloaded, isTrue);
    });
  });

  // ─── SyncOperation & SyncPriority enums ───────────────────────────

  group('Enums', () {
    test('SyncOperation has all expected values', () {
      expect(
          SyncOperation.values,
          containsAll([
            SyncOperation.create,
            SyncOperation.update,
            SyncOperation.delete,
          ]));
    });

    test('SyncPriority has all expected values', () {
      expect(
          SyncPriority.values,
          containsAll([
            SyncPriority.low,
            SyncPriority.normal,
            SyncPriority.high,
          ]));
    });
  });
}

// ─── Helper functions ─────────────────────────────────────────────────

SyncQueueHealth _healthyQueue() => SyncQueueHealth(
      totalItems: 100,
      pendingCount: 50,
      syncingCount: 10,
      failedCount: 5,
      conflictCount: 0,
      syncedCount: 35,
      oldestPendingAt: null,
      avgRetryCount: 0.5,
      itemsPerTable: {},
    );

SyncQueueHealth _overloadedQueue() => SyncQueueHealth(
      totalItems: 15000,
      pendingCount: 11000,
      syncingCount: 500,
      failedCount: 200,
      conflictCount: 50,
      syncedCount: 3250,
      oldestPendingAt: null,
      avgRetryCount: 2.0,
      itemsPerTable: {},
    );

void _setupHealthyQueue(MockSyncQueueDao dao) {
  when(() => dao.getQueueHealth()).thenAnswer((_) async => _healthyQueue());
}

void _setupOverloadedQueue(MockSyncQueueDao dao) {
  when(() => dao.getQueueHealth()).thenAnswer((_) async => _overloadedQueue());
}

void _setupNoPendingItems(MockSyncQueueDao dao) {
  when(() => dao.findPendingByTableRecord(any(), any()))
      .thenAnswer((_) async => []);
}

void _setupNoExistingIdempotency(MockSyncQueueDao dao) {
  when(() => dao.findByIdempotencyKey(any())).thenAnswer((_) async => null);
}

void _setupEnqueueSuccess(MockSyncQueueDao dao) {
  when(() => dao.enqueue(
        id: any(named: 'id'),
        tableName: any(named: 'tableName'),
        recordId: any(named: 'recordId'),
        operation: any(named: 'operation'),
        payload: any(named: 'payload'),
        idempotencyKey: any(named: 'idempotencyKey'),
        priority: any(named: 'priority'),
      )).thenAnswer((_) async => 1);
}

SyncQueueTableData _fakeSyncQueueItem({
  required String id,
  required String status,
  required String operation,
}) {
  return SyncQueueTableData(
    id: id,
    tableName_: 'products',
    recordId: 'r1',
    operation: operation,
    payload: jsonEncode({'id': 'r1', 'name': 'test'}),
    idempotencyKey: 'products_r1_${operation.toLowerCase()}',
    status: status,
    retryCount: 0,
    maxRetries: 5,
    createdAt: DateTime.now(),
    priority: 2,
    lastError: null,
  );
}
