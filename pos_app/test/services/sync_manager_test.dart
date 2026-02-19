/// اختبارات مدير المزامنة
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/services/connectivity_service.dart';
import 'package:pos_app/services/sync/sync_service.dart';
import 'package:pos_app/services/sync/sync_manager.dart';

// ============================================================================
// MOCKS
// ============================================================================

class MockSyncService extends Mock implements SyncService {}

class MockConnectivityService extends Mock implements ConnectivityService {}

// ============================================================================
// TEST DATA
// ============================================================================

SyncQueueTableData _createTestSyncItem({
  String? id,
  String? tableName,
  String? operation,
  int? retryCount,
}) {
  return SyncQueueTableData(
    id: id ?? 'sync-1',
    tableName_: tableName ?? 'sales',
    recordId: 'record-1',
    operation: operation ?? 'CREATE',
    payload: '{"test": "data"}',
    idempotencyKey: 'key-1',
    status: 'pending',
    priority: 2,
    retryCount: retryCount ?? 0,
    maxRetries: 3,
    createdAt: DateTime.now(),
    lastAttemptAt: null,
    lastError: null,
    syncedAt: null,
  );
}

// ============================================================================
// TESTS
// ============================================================================

void main() {
  late MockSyncService mockSyncService;
  late MockConnectivityService mockConnectivityService;
  late StreamController<bool> connectivityController;

  setUp(() {
    mockSyncService = MockSyncService();
    mockConnectivityService = MockConnectivityService();
    connectivityController = StreamController<bool>.broadcast();

    when(() => mockConnectivityService.onConnectivityChanged)
        .thenAnswer((_) => connectivityController.stream);
  });

  tearDown(() {
    connectivityController.close();
  });

  group('SyncManager', () {
    group('initialize', () {
      test('يُزامن عند التهيئة إذا كان متصل', () async {
        // Arrange
        when(() => mockConnectivityService.isOnline).thenReturn(true);
        when(() => mockConnectivityService.isOffline).thenReturn(false);
        when(() => mockSyncService.getPendingItems())
            .thenAnswer((_) async => []);

        final manager = SyncManager(
          syncService: mockSyncService,
          connectivityService: mockConnectivityService,
        );

        // Act
        await manager.initialize();

        // Assert
        verify(() => mockSyncService.getPendingItems()).called(1);

        manager.dispose();
      });

      test('لا يُزامن عند التهيئة إذا كان غير متصل', () async {
        // Arrange
        when(() => mockConnectivityService.isOnline).thenReturn(false);
        when(() => mockConnectivityService.isOffline).thenReturn(true);

        final manager = SyncManager(
          syncService: mockSyncService,
          connectivityService: mockConnectivityService,
        );

        // Act
        await manager.initialize();

        // Assert
        verifyNever(() => mockSyncService.getPendingItems());

        manager.dispose();
      });
    });

    group('syncPending', () {
      test('يُزامن العناصر المعلقة بنجاح', () async {
        // Arrange
        final items = [
          _createTestSyncItem(id: 's1'),
          _createTestSyncItem(id: 's2'),
        ];

        when(() => mockConnectivityService.isOnline).thenReturn(true);
        when(() => mockConnectivityService.isOffline).thenReturn(false);
        when(() => mockSyncService.getPendingItems())
            .thenAnswer((_) async => items);
        when(() => mockSyncService.markAsSyncing(any()))
            .thenAnswer((_) async {});
        when(() => mockSyncService.markAsSynced(any()))
            .thenAnswer((_) async {});

        var syncCalled = 0;
        final manager = SyncManager(
          syncService: mockSyncService,
          connectivityService: mockConnectivityService,
          onSync: (tableName, operation, payload) async {
            syncCalled++;
          },
        );

        // Act
        final result = await manager.syncPending();

        // Assert
        expect(result.successCount, 2);
        expect(result.failedCount, 0);
        expect(result.hasErrors, isFalse);
        expect(syncCalled, 2);

        manager.dispose();
      });

      test('يُعالج أخطاء المزامنة', () async {
        // Arrange
        final items = [_createTestSyncItem(id: 's1')];

        when(() => mockConnectivityService.isOnline).thenReturn(true);
        when(() => mockConnectivityService.isOffline).thenReturn(false);
        when(() => mockSyncService.getPendingItems())
            .thenAnswer((_) async => items);
        when(() => mockSyncService.markAsSyncing(any()))
            .thenAnswer((_) async {});
        when(() => mockSyncService.markAsFailed(any(), any()))
            .thenAnswer((_) async {});

        final manager = SyncManager(
          syncService: mockSyncService,
          connectivityService: mockConnectivityService,
          onSync: (tableName, operation, payload) async {
            throw Exception('Network error');
          },
        );

        // Act
        final result = await manager.syncPending();

        // Assert
        expect(result.successCount, 0);
        expect(result.failedCount, 1);
        expect(result.hasErrors, isTrue);
        expect(result.errors.first, contains('sales'));
        verify(() => mockSyncService.markAsFailed('s1', any())).called(1);

        manager.dispose();
      });

      test('لا يُزامن إذا كان غير متصل', () async {
        // Arrange
        when(() => mockConnectivityService.isOnline).thenReturn(false);
        when(() => mockConnectivityService.isOffline).thenReturn(true);

        final manager = SyncManager(
          syncService: mockSyncService,
          connectivityService: mockConnectivityService,
        );

        // Act
        final result = await manager.syncPending();

        // Assert
        expect(result.successCount, 0);
        expect(result.failedCount, 0);
        verifyNever(() => mockSyncService.getPendingItems());

        manager.dispose();
      });

      test('لا يُزامن إذا كانت المزامنة جارية', () async {
        // Arrange
        when(() => mockConnectivityService.isOnline).thenReturn(true);
        when(() => mockConnectivityService.isOffline).thenReturn(false);

        final completer = Completer<List<SyncQueueTableData>>();
        when(() => mockSyncService.getPendingItems())
            .thenAnswer((_) => completer.future);

        final manager = SyncManager(
          syncService: mockSyncService,
          connectivityService: mockConnectivityService,
        );

        // Act - Start first sync
        final firstSync = manager.syncPending();

        // Try to start second sync while first is running
        final secondResult = await manager.syncPending();

        // Complete first sync
        completer.complete([]);
        await firstSync;

        // Assert - Second sync should return empty result
        expect(secondResult.successCount, 0);
        expect(secondResult.failedCount, 0);

        manager.dispose();
      });
    });

    group('statusStream', () {
      test('يُبث حالة المزامنة', () async {
        // Arrange
        when(() => mockConnectivityService.isOnline).thenReturn(true);
        when(() => mockConnectivityService.isOffline).thenReturn(false);
        when(() => mockSyncService.getPendingItems())
            .thenAnswer((_) async => []);

        final manager = SyncManager(
          syncService: mockSyncService,
          connectivityService: mockConnectivityService,
        );

        final statuses = <SyncStatus>[];
        final subscription = manager.statusStream.listen(statuses.add);

        // Act
        await manager.syncPending();
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(statuses, contains(SyncStatus.syncing));
        expect(statuses, contains(SyncStatus.idle));

        await subscription.cancel();
        manager.dispose();
      });

      test('يُبث حالة خطأ عند الفشل', () async {
        // Arrange
        final items = [_createTestSyncItem()];

        when(() => mockConnectivityService.isOnline).thenReturn(true);
        when(() => mockConnectivityService.isOffline).thenReturn(false);
        when(() => mockSyncService.getPendingItems())
            .thenAnswer((_) async => items);
        when(() => mockSyncService.markAsSyncing(any()))
            .thenAnswer((_) async {});
        when(() => mockSyncService.markAsFailed(any(), any()))
            .thenAnswer((_) async {});

        final manager = SyncManager(
          syncService: mockSyncService,
          connectivityService: mockConnectivityService,
          onSync: (_, __, ___) async => throw Exception('Error'),
        );

        final statuses = <SyncStatus>[];
        final subscription = manager.statusStream.listen(statuses.add);

        // Act
        await manager.syncPending();
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(statuses, contains(SyncStatus.syncing));
        expect(statuses, contains(SyncStatus.error));

        await subscription.cancel();
        manager.dispose();
      });
    });

    group('isSyncing', () {
      test('يُرجع true أثناء المزامنة', () async {
        // Arrange
        when(() => mockConnectivityService.isOnline).thenReturn(true);
        when(() => mockConnectivityService.isOffline).thenReturn(false);

        final completer = Completer<List<SyncQueueTableData>>();
        when(() => mockSyncService.getPendingItems())
            .thenAnswer((_) => completer.future);

        final manager = SyncManager(
          syncService: mockSyncService,
          connectivityService: mockConnectivityService,
        );

        // Act
        expect(manager.isSyncing, isFalse);

        final syncFuture = manager.syncPending();
        await Future.delayed(const Duration(milliseconds: 10));

        expect(manager.isSyncing, isTrue);

        completer.complete([]);
        await syncFuture;

        expect(manager.isSyncing, isFalse);

        manager.dispose();
      });
    });

    group('connectivity changes', () {
      test('يُزامن عند استعادة الاتصال', () async {
        // Arrange
        when(() => mockConnectivityService.isOnline).thenReturn(false);
        when(() => mockConnectivityService.isOffline).thenReturn(true);

        final manager = SyncManager(
          syncService: mockSyncService,
          connectivityService: mockConnectivityService,
        );

        await manager.initialize();

        // Simulate going online
        when(() => mockConnectivityService.isOnline).thenReturn(true);
        when(() => mockConnectivityService.isOffline).thenReturn(false);
        when(() => mockSyncService.getPendingItems())
            .thenAnswer((_) async => []);

        // Act
        connectivityController.add(true);
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        verify(() => mockSyncService.getPendingItems()).called(1);

        manager.dispose();
      });
    });

    group('cleanup', () {
      test('يُنظّف العناصر القديمة', () async {
        // Arrange
        when(() => mockSyncService.cleanup())
            .thenAnswer((_) async => 5);

        final manager = SyncManager(
          syncService: mockSyncService,
          connectivityService: mockConnectivityService,
        );

        // Act
        final result = await manager.cleanup();

        // Assert
        expect(result, 5);
        verify(() => mockSyncService.cleanup()).called(1);

        manager.dispose();
      });
    });

    group('dispose', () {
      test('يُغلق الموارد بشكل صحيح', () async {
        // Arrange
        when(() => mockConnectivityService.isOnline).thenReturn(false);

        final manager = SyncManager(
          syncService: mockSyncService,
          connectivityService: mockConnectivityService,
        );

        await manager.initialize();

        // Act & Assert - Should not throw
        manager.dispose();
      });
    });
  });

  group('RetryStrategy', () {
    test('يحسب التأخير بشكل صحيح', () {
      expect(RetryStrategy.getDelay(0), const Duration(seconds: 2));
      expect(RetryStrategy.getDelay(1), const Duration(seconds: 4));
      expect(RetryStrategy.getDelay(2), const Duration(seconds: 8));
    });

    test('maxRetries هو 3', () {
      expect(RetryStrategy.maxRetries, 3);
    });
  });

  group('SyncResult', () {
    test('hasErrors يُرجع true عند وجود فشل', () {
      final result = SyncResult(
        successCount: 5,
        failedCount: 2,
        errors: ['error1', 'error2'],
      );

      expect(result.hasErrors, isTrue);
      expect(result.totalCount, 7);
    });

    test('hasErrors يُرجع false عند عدم وجود فشل', () {
      final result = SyncResult(
        successCount: 5,
        failedCount: 0,
        errors: [],
      );

      expect(result.hasErrors, isFalse);
      expect(result.totalCount, 5);
    });
  });

  group('SyncStatus', () {
    test('القيم صحيحة', () {
      expect(SyncStatus.values.length, 3);
      expect(SyncStatus.idle.name, 'idle');
      expect(SyncStatus.syncing.name, 'syncing');
      expect(SyncStatus.error.name, 'error');
    });
  });
}
