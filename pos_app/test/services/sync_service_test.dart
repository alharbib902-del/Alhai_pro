/// اختبارات خدمة المزامنة
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/data/local/daos/sync_queue_dao.dart';
import 'package:pos_app/services/sync/sync_service.dart';

// ============================================================================
// MOCKS
// ============================================================================

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

// ============================================================================
// SETUP
// ============================================================================

void main() {
  setUpAll(() {
    registerFallbackValue(const Duration(days: 7));
  });

  _runTests();
}

void _runTests() {

// ============================================================================
// TEST DATA
// ============================================================================

SyncQueueTableData createTestSyncItem({
  String? id,
  String? tableName,
  String? recordId,
  String? operation,
  String? status,
  int? retryCount,
}) {
  return SyncQueueTableData(
    id: id ?? 'sync-1',
    tableName_: tableName ?? 'sales',
    recordId: recordId ?? 'record-1',
    operation: operation ?? 'CREATE',
    payload: '{"test": "data"}',
    idempotencyKey: 'key-1',
    status: status ?? 'pending',
    priority: 2,
    retryCount: retryCount ?? 0,
    maxRetries: 3,
    createdAt: DateTime.now(),
    lastAttemptAt: null,
    lastError: null,
    syncedAt: null,
  );
}

  late MockSyncQueueDao mockSyncQueueDao;
  late SyncService syncService;

  setUp(() {
    mockSyncQueueDao = MockSyncQueueDao();
    syncService = SyncService(mockSyncQueueDao);
  });

  group('SyncService', () {
    group('enqueue', () {
      test('يُضيف عملية جديدة للطابور', () async {
        // Arrange
        when(() => mockSyncQueueDao.findByIdempotencyKey(any()))
            .thenAnswer((_) async => null);
        when(() => mockSyncQueueDao.enqueue(
              id: any(named: 'id'),
              tableName: any(named: 'tableName'),
              recordId: any(named: 'recordId'),
              operation: any(named: 'operation'),
              payload: any(named: 'payload'),
              idempotencyKey: any(named: 'idempotencyKey'),
              priority: any(named: 'priority'),
            )).thenAnswer((_) async => 1);

        // Act
        final result = await syncService.enqueue(
          tableName: 'sales',
          recordId: 'sale-1',
          operation: SyncOperation.create,
          payload: {'id': 'sale-1', 'total': 100.0},
        );

        // Assert
        expect(result, isNotEmpty);
        verify(() => mockSyncQueueDao.enqueue(
              id: any(named: 'id'),
              tableName: 'sales',
              recordId: 'sale-1',
              operation: 'CREATE',
              payload: any(named: 'payload'),
              idempotencyKey: any(named: 'idempotencyKey'),
              priority: 2,
            )).called(1);
      });

      test('يُرجع المعرف الموجود إذا كانت العملية مكررة', () async {
        // Arrange
        final existingItem = createTestSyncItem(id: 'existing-sync-id');
        when(() => mockSyncQueueDao.findByIdempotencyKey(any()))
            .thenAnswer((_) async => existingItem);

        // Act
        final result = await syncService.enqueue(
          tableName: 'sales',
          recordId: 'sale-1',
          operation: SyncOperation.create,
          payload: {'id': 'sale-1'},
        );

        // Assert
        expect(result, 'existing-sync-id');
        verifyNever(() => mockSyncQueueDao.enqueue(
              id: any(named: 'id'),
              tableName: any(named: 'tableName'),
              recordId: any(named: 'recordId'),
              operation: any(named: 'operation'),
              payload: any(named: 'payload'),
              idempotencyKey: any(named: 'idempotencyKey'),
              priority: any(named: 'priority'),
            ));
      });

      test('يستخدم الأولوية الصحيحة', () async {
        // Arrange
        when(() => mockSyncQueueDao.findByIdempotencyKey(any()))
            .thenAnswer((_) async => null);
        when(() => mockSyncQueueDao.enqueue(
              id: any(named: 'id'),
              tableName: any(named: 'tableName'),
              recordId: any(named: 'recordId'),
              operation: any(named: 'operation'),
              payload: any(named: 'payload'),
              idempotencyKey: any(named: 'idempotencyKey'),
              priority: any(named: 'priority'),
            )).thenAnswer((_) async => 1);

        // Act - High priority
        await syncService.enqueue(
          tableName: 'sales',
          recordId: 'sale-1',
          operation: SyncOperation.create,
          payload: {},
          priority: SyncPriority.high,
        );

        // Assert
        verify(() => mockSyncQueueDao.enqueue(
              id: any(named: 'id'),
              tableName: any(named: 'tableName'),
              recordId: any(named: 'recordId'),
              operation: any(named: 'operation'),
              payload: any(named: 'payload'),
              idempotencyKey: any(named: 'idempotencyKey'),
              priority: 3,
            )).called(1);
      });
    });

    group('enqueueCreate', () {
      test('يُضيف عملية إنشاء', () async {
        // Arrange
        when(() => mockSyncQueueDao.findByIdempotencyKey(any()))
            .thenAnswer((_) async => null);
        when(() => mockSyncQueueDao.enqueue(
              id: any(named: 'id'),
              tableName: any(named: 'tableName'),
              recordId: any(named: 'recordId'),
              operation: any(named: 'operation'),
              payload: any(named: 'payload'),
              idempotencyKey: any(named: 'idempotencyKey'),
              priority: any(named: 'priority'),
            )).thenAnswer((_) async => 1);

        // Act
        await syncService.enqueueCreate(
          tableName: 'products',
          recordId: 'prod-1',
          data: {'name': 'منتج جديد'},
        );

        // Assert
        verify(() => mockSyncQueueDao.enqueue(
              id: any(named: 'id'),
              tableName: 'products',
              recordId: 'prod-1',
              operation: 'CREATE',
              payload: any(named: 'payload'),
              idempotencyKey: any(named: 'idempotencyKey'),
              priority: 2,
            )).called(1);
      });
    });

    group('enqueueUpdate', () {
      test('يُضيف عملية تحديث', () async {
        // Arrange
        when(() => mockSyncQueueDao.findByIdempotencyKey(any()))
            .thenAnswer((_) async => null);
        when(() => mockSyncQueueDao.enqueue(
              id: any(named: 'id'),
              tableName: any(named: 'tableName'),
              recordId: any(named: 'recordId'),
              operation: any(named: 'operation'),
              payload: any(named: 'payload'),
              idempotencyKey: any(named: 'idempotencyKey'),
              priority: any(named: 'priority'),
            )).thenAnswer((_) async => 1);

        // Act
        await syncService.enqueueUpdate(
          tableName: 'products',
          recordId: 'prod-1',
          changes: {'price': 50.0},
        );

        // Assert
        verify(() => mockSyncQueueDao.enqueue(
              id: any(named: 'id'),
              tableName: 'products',
              recordId: 'prod-1',
              operation: 'UPDATE',
              payload: any(named: 'payload'),
              idempotencyKey: any(named: 'idempotencyKey'),
              priority: any(named: 'priority'),
            )).called(1);
      });
    });

    group('enqueueDelete', () {
      test('يُضيف عملية حذف', () async {
        // Arrange
        when(() => mockSyncQueueDao.findByIdempotencyKey(any()))
            .thenAnswer((_) async => null);
        when(() => mockSyncQueueDao.enqueue(
              id: any(named: 'id'),
              tableName: any(named: 'tableName'),
              recordId: any(named: 'recordId'),
              operation: any(named: 'operation'),
              payload: any(named: 'payload'),
              idempotencyKey: any(named: 'idempotencyKey'),
              priority: any(named: 'priority'),
            )).thenAnswer((_) async => 1);

        // Act
        await syncService.enqueueDelete(
          tableName: 'products',
          recordId: 'prod-1',
        );

        // Assert
        verify(() => mockSyncQueueDao.enqueue(
              id: any(named: 'id'),
              tableName: 'products',
              recordId: 'prod-1',
              operation: 'DELETE',
              payload: any(named: 'payload'),
              idempotencyKey: any(named: 'idempotencyKey'),
              priority: any(named: 'priority'),
            )).called(1);
      });
    });

    group('getPendingItems', () {
      test('يُرجع العناصر المعلقة', () async {
        // Arrange
        final items = [
          createTestSyncItem(id: 's1'),
          createTestSyncItem(id: 's2'),
        ];
        when(() => mockSyncQueueDao.getPendingItems())
            .thenAnswer((_) async => items);

        // Act
        final result = await syncService.getPendingItems();

        // Assert
        expect(result.length, 2);
        expect(result[0].id, 's1');
        expect(result[1].id, 's2');
      });
    });

    group('getPendingCount', () {
      test('يُرجع عدد العناصر المعلقة', () async {
        // Arrange
        when(() => mockSyncQueueDao.getPendingCount())
            .thenAnswer((_) async => 15);

        // Act
        final result = await syncService.getPendingCount();

        // Assert
        expect(result, 15);
      });
    });

    group('markAsSyncing', () {
      test('يُحدّث حالة العنصر لـ syncing', () async {
        // Arrange
        when(() => mockSyncQueueDao.markAsSyncing('sync-1'))
            .thenAnswer((_) async => 1);

        // Act
        await syncService.markAsSyncing('sync-1');

        // Assert
        verify(() => mockSyncQueueDao.markAsSyncing('sync-1')).called(1);
      });
    });

    group('markAsSynced', () {
      test('يُحدّث حالة العنصر لـ synced', () async {
        // Arrange
        when(() => mockSyncQueueDao.markAsSynced('sync-1'))
            .thenAnswer((_) async => 1);

        // Act
        await syncService.markAsSynced('sync-1');

        // Assert
        verify(() => mockSyncQueueDao.markAsSynced('sync-1')).called(1);
      });
    });

    group('markAsFailed', () {
      test('يُحدّث حالة العنصر لـ failed مع رسالة الخطأ', () async {
        // Arrange
        when(() => mockSyncQueueDao.markAsFailed('sync-1', 'Network error'))
            .thenAnswer((_) async => 1);

        // Act
        await syncService.markAsFailed('sync-1', 'Network error');

        // Assert
        verify(() => mockSyncQueueDao.markAsFailed('sync-1', 'Network error'))
            .called(1);
      });
    });

    group('removeItem', () {
      test('يحذف عنصر من الطابور', () async {
        // Arrange
        when(() => mockSyncQueueDao.removeItem('sync-1'))
            .thenAnswer((_) async => 1);

        // Act
        await syncService.removeItem('sync-1');

        // Assert
        verify(() => mockSyncQueueDao.removeItem('sync-1')).called(1);
      });
    });

    group('cleanup', () {
      test('يُنظّف العناصر القديمة', () async {
        // Arrange
        when(() => mockSyncQueueDao.cleanupSyncedItems(olderThan: any(named: 'olderThan')))
            .thenAnswer((_) async => 10);

        // Act
        final result = await syncService.cleanup();

        // Assert
        expect(result, 10);
        verify(() => mockSyncQueueDao.cleanupSyncedItems(
              olderThan: const Duration(days: 7),
            )).called(1);
      });

      test('يستخدم المدة المحددة', () async {
        // Arrange
        when(() => mockSyncQueueDao.cleanupSyncedItems(olderThan: any(named: 'olderThan')))
            .thenAnswer((_) async => 5);

        // Act
        final result = await syncService.cleanup(olderThan: const Duration(days: 30));

        // Assert
        expect(result, 5);
        verify(() => mockSyncQueueDao.cleanupSyncedItems(
              olderThan: const Duration(days: 30),
            )).called(1);
      });
    });

    group('watchPendingCount', () {
      test('يُراقب عدد العناصر المعلقة', () async {
        // Arrange
        when(() => mockSyncQueueDao.watchPendingCount())
            .thenAnswer((_) => Stream.fromIterable([5, 4, 3, 2, 1, 0]));

        // Act
        final stream = syncService.watchPendingCount();

        // Assert
        expect(stream, emitsInOrder([5, 4, 3, 2, 1, 0]));
      });
    });
  });

  group('SyncPriority', () {
    test('القيم صحيحة', () {
      expect(SyncPriority.low.index, 0);
      expect(SyncPriority.normal.index, 1);
      expect(SyncPriority.high.index, 2);
    });
  });

  group('SyncOperation', () {
    test('القيم صحيحة', () {
      expect(SyncOperation.create.name, 'create');
      expect(SyncOperation.update.name, 'update');
      expect(SyncOperation.delete.name, 'delete');
    });
  });
}
