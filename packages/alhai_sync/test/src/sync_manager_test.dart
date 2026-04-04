import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_sync/src/connectivity_service.dart';
import 'package:alhai_sync/src/sync_manager.dart';
import 'package:alhai_sync/src/sync_service.dart';
import 'package:alhai_database/alhai_database.dart';

import '../helpers/sync_test_helpers.dart';

class MockSyncService extends Mock implements SyncService {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late MockSyncService mockSyncService;
  late MockConnectivityService mockConnectivity;
  late SyncManager manager;

  setUpAll(() {
    registerSyncFallbackValues();
  });

  setUp(() {
    mockSyncService = MockSyncService();
    mockConnectivity = MockConnectivityService();

    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockConnectivity.isOnline).thenReturn(false);
    when(() => mockConnectivity.isOffline).thenReturn(true);

    manager = SyncManager(
      syncService: mockSyncService,
      connectivityService: mockConnectivity,
    );
  });

  tearDown(() {
    manager.dispose();
  });

  group('SyncManager', () {
    group('initialize', () {
      test('subscribes to connectivity changes', () async {
        when(() => mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => const Stream.empty());
        when(() => mockConnectivity.isOnline).thenReturn(false);

        await manager.initialize();

        verify(() => mockConnectivity.onConnectivityChanged).called(1);
      });

      test('syncs pending when online at init', () async {
        when(() => mockConnectivity.isOnline).thenReturn(true);
        when(() => mockConnectivity.isOffline).thenReturn(false);
        when(() => mockSyncService.getPendingItems())
            .thenAnswer((_) async => []);

        await manager.initialize();

        verify(() => mockSyncService.getPendingItems()).called(1);
      });

      test('does not sync when offline at init', () async {
        when(() => mockConnectivity.isOnline).thenReturn(false);
        when(() => mockConnectivity.isOffline).thenReturn(true);

        await manager.initialize();

        verifyNever(() => mockSyncService.getPendingItems());
      });
    });

    group('syncPending', () {
      test('returns empty result when already syncing', () async {
        // Make the manager "syncing" by starting a sync that takes time
        when(() => mockConnectivity.isOnline).thenReturn(true);
        when(() => mockConnectivity.isOffline).thenReturn(false);

        final completer = Completer<List<SyncQueueTableData>>();
        when(() => mockSyncService.getPendingItems())
            .thenAnswer((_) => completer.future);

        // Start first sync (will be in progress)
        final firstSync = manager.syncPending();

        // Second sync should return immediately
        final secondResult = await manager.syncPending();

        expect(secondResult.successCount, 0);
        expect(secondResult.failedCount, 0);

        // Complete first sync
        completer.complete([]);
        await firstSync;
      });

      test('returns empty result when offline', () async {
        when(() => mockConnectivity.isOffline).thenReturn(true);

        final result = await manager.syncPending();

        expect(result.successCount, 0);
        expect(result.failedCount, 0);
      });

      test('processes pending items successfully', () async {
        when(() => mockConnectivity.isOnline).thenReturn(true);
        when(() => mockConnectivity.isOffline).thenReturn(false);

        final items = [
          createSyncQueueItem(
            id: 'q-1',
            tableName: 'products',
            operation: 'CREATE',
            payload: jsonEncode({'id': 'p-1', 'name': 'Test'}),
          ),
        ];

        when(() => mockSyncService.getPendingItems())
            .thenAnswer((_) async => items);
        when(() => mockSyncService.markAsSyncing(any()))
            .thenAnswer((_) async {});
        when(() => mockSyncService.markAsSynced(any()))
            .thenAnswer((_) async {});

        // Use a custom onSync callback
        final syncedItems = <String>[];
        final managerWithCallback = SyncManager(
          syncService: mockSyncService,
          connectivityService: mockConnectivity,
          onSync: (tableName, operation, payload) async {
            syncedItems.add(tableName);
          },
        );

        final result = await managerWithCallback.syncPending();

        expect(result.successCount, 1);
        expect(result.failedCount, 0);
        expect(syncedItems, ['products']);

        verify(() => mockSyncService.markAsSyncing('q-1')).called(1);
        verify(() => mockSyncService.markAsSynced('q-1')).called(1);

        managerWithCallback.dispose();
      });

      test('handles sync failure and marks as failed', () async {
        when(() => mockConnectivity.isOnline).thenReturn(true);
        when(() => mockConnectivity.isOffline).thenReturn(false);

        final items = [
          createSyncQueueItem(
            id: 'q-1',
            tableName: 'products',
            operation: 'CREATE',
            payload: jsonEncode({'id': 'p-1'}),
          ),
        ];

        when(() => mockSyncService.getPendingItems())
            .thenAnswer((_) async => items);
        when(() => mockSyncService.markAsSyncing(any()))
            .thenAnswer((_) async {});
        when(() => mockSyncService.markAsFailed(any(), any()))
            .thenAnswer((_) async {});

        final managerWithCallback = SyncManager(
          syncService: mockSyncService,
          connectivityService: mockConnectivity,
          onSync: (tableName, operation, payload) async {
            throw Exception('Network error');
          },
        );

        final result = await managerWithCallback.syncPending();

        expect(result.successCount, 0);
        expect(result.failedCount, 1);
        expect(result.errors, hasLength(1));

        verify(() => mockSyncService.markAsFailed('q-1', any())).called(1);

        managerWithCallback.dispose();
      });

      test('emits syncing then idle status on success', () async {
        when(() => mockConnectivity.isOnline).thenReturn(true);
        when(() => mockConnectivity.isOffline).thenReturn(false);
        when(() => mockSyncService.getPendingItems())
            .thenAnswer((_) async => []);

        final statuses = <SyncStatus>[];
        manager.statusStream.listen(statuses.add);

        await manager.syncPending();

        // Allow microtasks to deliver stream events
        await Future<void>.delayed(Duration.zero);

        // Should emit syncing, then idle
        expect(statuses,
            containsAllInOrder([SyncStatus.syncing, SyncStatus.idle]));
      });

      test('emits error status on failure', () async {
        when(() => mockConnectivity.isOnline).thenReturn(true);
        when(() => mockConnectivity.isOffline).thenReturn(false);

        final items = [
          createSyncQueueItem(
            id: 'q-1',
            payload: jsonEncode({'id': 'p-1'}),
          ),
        ];

        when(() => mockSyncService.getPendingItems())
            .thenAnswer((_) async => items);
        when(() => mockSyncService.markAsSyncing(any()))
            .thenAnswer((_) async {});
        when(() => mockSyncService.markAsFailed(any(), any()))
            .thenAnswer((_) async {});

        final managerWithCallback = SyncManager(
          syncService: mockSyncService,
          connectivityService: mockConnectivity,
          onSync: (_, __, ___) async => throw Exception('fail'),
        );

        final statuses = <SyncStatus>[];
        managerWithCallback.statusStream.listen(statuses.add);

        await managerWithCallback.syncPending();

        // Allow microtasks to deliver stream events
        await Future<void>.delayed(Duration.zero);

        expect(statuses, contains(SyncStatus.error));

        managerWithCallback.dispose();
      });
    });

    group('cleanup', () {
      test('delegates to sync service', () async {
        when(() => mockSyncService.cleanup(olderThan: any(named: 'olderThan')))
            .thenAnswer((_) async => 7);

        final result = await manager.cleanup();

        expect(result, 7);
      });
    });

    group('statusStream', () {
      test('is a broadcast stream', () {
        expect(manager.statusStream.isBroadcast, isTrue);
      });
    });

    group('isSyncing', () {
      test('returns false initially', () {
        expect(manager.isSyncing, isFalse);
      });
    });
  });

  group('RetryStrategy', () {
    test('getDelay returns exponential backoff', () {
      expect(RetryStrategy.getDelay(0), const Duration(seconds: 2));
      expect(RetryStrategy.getDelay(1), const Duration(seconds: 4));
      expect(RetryStrategy.getDelay(2), const Duration(seconds: 8));
    });

    test('maxRetries is 3', () {
      expect(RetryStrategy.maxRetries, 3);
    });
  });

  group('SyncResult', () {
    test('hasErrors returns true when failedCount > 0', () {
      final result = SyncResult(
        successCount: 1,
        failedCount: 1,
        errors: ['error'],
      );
      expect(result.hasErrors, isTrue);
    });

    test('hasErrors returns false when failedCount is 0', () {
      final result = SyncResult(
        successCount: 2,
        failedCount: 0,
        errors: [],
      );
      expect(result.hasErrors, isFalse);
    });

    test('totalCount sums success and failed', () {
      final result = SyncResult(
        successCount: 3,
        failedCount: 2,
        errors: [],
      );
      expect(result.totalCount, 5);
    });
  });
}
