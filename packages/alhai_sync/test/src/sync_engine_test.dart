import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_sync/src/connectivity_service.dart';
import 'package:alhai_sync/src/sync_engine.dart';
import 'package:alhai_sync/src/sync_status_tracker.dart';
import 'package:alhai_sync/src/strategies/pull_strategy.dart';
import 'package:alhai_sync/src/strategies/push_strategy.dart';
import 'package:alhai_sync/src/strategies/bidirectional_strategy.dart';
import 'package:alhai_sync/src/strategies/stock_delta_sync.dart';

import '../helpers/sync_test_helpers.dart';

class MockPullStrategy extends Mock implements PullStrategy {}

class MockPushStrategy extends Mock implements PushStrategy {}

class MockBidirectionalStrategy extends Mock
    implements BidirectionalStrategy {}

class MockStockDeltaSync extends Mock implements StockDeltaSync {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockSyncStatusTracker extends Mock implements SyncStatusTracker {}

void main() {
  late MockPullStrategy mockPull;
  late MockPushStrategy mockPush;
  late MockBidirectionalStrategy mockBidirectional;
  late MockStockDeltaSync mockStockDelta;
  late MockConnectivityService mockConnectivity;
  late MockSyncStatusTracker mockStatusTracker;
  late SyncEngine engine;

  setUpAll(() {
    registerSyncFallbackValues();
  });

  setUp(() {
    mockPull = MockPullStrategy();
    mockPush = MockPushStrategy();
    mockBidirectional = MockBidirectionalStrategy();
    mockStockDelta = MockStockDeltaSync();
    mockConnectivity = MockConnectivityService();
    mockStatusTracker = MockSyncStatusTracker();

    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockConnectivity.isOnline).thenReturn(false);
    when(() => mockConnectivity.isOffline).thenReturn(true);

    engine = SyncEngine(
      pullStrategy: mockPull,
      pushStrategy: mockPush,
      bidirectionalStrategy: mockBidirectional,
      stockDeltaSync: mockStockDelta,
      connectivity: mockConnectivity,
      statusTracker: mockStatusTracker,
    );
  });

  tearDown(() {
    engine.dispose();
  });

  group('SyncEngine', () {
    group('initial state', () {
      test('isLocked is false', () {
        expect(engine.isLocked, isFalse);
      });

      test('currentProgress is idle', () {
        expect(engine.currentProgress.state, SyncEngineState.idle);
        expect(engine.currentProgress.phase, SyncPhase.none);
      });
    });

    group('syncNow', () {
      test('returns failure when offline', () async {
        when(() => mockConnectivity.isOffline).thenReturn(true);

        final result = await engine.syncNow();

        expect(result.success, isFalse);
        expect(result.errors, contains('Device is offline'));
      });

      test('returns failure when not initialized', () async {
        when(() => mockConnectivity.isOffline).thenReturn(false);

        final result = await engine.syncNow();

        expect(result.success, isFalse);
        expect(result.errors.first, contains('not initialized'));
      });

      test('returns failure when already locked', () async {
        // Start offline so initialize doesn't auto-sync
        when(() => mockConnectivity.isOnline).thenReturn(false);
        when(() => mockConnectivity.isOffline).thenReturn(true);

        // Set up all strategies to return successfully but with a delay
        final pullCompleter = Completer<List<PullResult>>();
        when(() => mockPull.pullAll(
              orgId: any(named: 'orgId'),
              storeId: any(named: 'storeId'),
            )).thenAnswer((_) => pullCompleter.future);
        when(() => mockStatusTracker.refreshAll())
            .thenAnswer((_) async {});

        // Initialize while offline (no auto sync)
        await engine.initialize(
          orgId: 'org-1',
          storeId: 'store-1',
          deviceId: 'device-1',
        );

        // Now go online
        when(() => mockConnectivity.isOnline).thenReturn(true);
        when(() => mockConnectivity.isOffline).thenReturn(false);

        // Start first sync (will be stuck on pullCompleter)
        final firstSync = engine.syncNow();

        // Wait for the lock to be acquired
        await Future.delayed(const Duration(milliseconds: 50));

        // The engine should be locked now
        expect(engine.isLocked, isTrue);

        // Second sync should fail immediately
        final result = await engine.syncNow();

        expect(result.success, isFalse);
        expect(result.errors, contains('Sync already in progress'));

        // Clean up the first sync
        pullCompleter.complete([]);
        // We need to let the first sync finish to avoid zone errors
        when(() => mockPush.pushPending()).thenAnswer((_) async =>
            PushResult(successCount: 0, failedCount: 0, errors: []));
        when(() => mockBidirectional.syncAll(
              orgId: any(named: 'orgId'),
              storeId: any(named: 'storeId'),
            )).thenAnswer((_) async => []);
        when(() => mockStockDelta.sync(
              orgId: any(named: 'orgId'),
              storeId: any(named: 'storeId'),
              deviceId: any(named: 'deviceId'),
            )).thenAnswer((_) async => StockDeltaResult(
              deltasSent: 0,
              productsUpdated: 0,
              errors: [],
              oversoldProducts: [],
            ));
        await firstSync;
      });

      test('executes all phases successfully', () async {
        when(() => mockPull.pullAll(
              orgId: any(named: 'orgId'),
              storeId: any(named: 'storeId'),
            )).thenAnswer((_) async => [
              PullResult(tableName: 'products', recordsPulled: 5, errors: []),
            ]);

        when(() => mockPush.pushPending()).thenAnswer((_) async =>
            PushResult(successCount: 3, failedCount: 0, errors: []));

        when(() => mockBidirectional.syncAll(
              orgId: any(named: 'orgId'),
              storeId: any(named: 'storeId'),
            )).thenAnswer((_) async => [
              BidirectionalResult(
                tableName: 'customers',
                pushed: 1,
                pulled: 2,
                conflicts: 0,
                errors: [],
              ),
            ]);

        when(() => mockStockDelta.sync(
              orgId: any(named: 'orgId'),
              storeId: any(named: 'storeId'),
              deviceId: any(named: 'deviceId'),
            )).thenAnswer((_) async => StockDeltaResult(
              deltasSent: 2,
              productsUpdated: 2,
              errors: [],
              oversoldProducts: [],
            ));

        when(() => mockStatusTracker.refreshAll())
            .thenAnswer((_) async {});

        // Initialize while offline (setUp already has isOnline=false)
        await engine.initialize(
          orgId: 'org-1',
          storeId: 'store-1',
          deviceId: 'device-1',
        );

        // Now go online and sync
        when(() => mockConnectivity.isOnline).thenReturn(true);
        when(() => mockConnectivity.isOffline).thenReturn(false);

        final result = await engine.syncNow();

        expect(result.success, isTrue);
        expect(result.errors, isEmpty);
        expect(result.totalSynced, greaterThan(0));

        verify(() => mockPull.pullAll(
              orgId: 'org-1',
              storeId: 'store-1',
            )).called(1);
        verify(() => mockPush.pushPending()).called(1);
        verify(() => mockBidirectional.syncAll(
              orgId: 'org-1',
              storeId: 'store-1',
            )).called(1);
        verify(() => mockStockDelta.sync(
              orgId: 'org-1',
              storeId: 'store-1',
              deviceId: 'device-1',
            )).called(1);
        verify(() => mockStatusTracker.refreshAll()).called(1);
      });

      test('collects errors from all phases', () async {
        when(() => mockConnectivity.isOnline).thenReturn(true);
        when(() => mockConnectivity.isOffline).thenReturn(false);

        when(() => mockPull.pullAll(
              orgId: any(named: 'orgId'),
              storeId: any(named: 'storeId'),
            )).thenAnswer((_) async => [
              PullResult(
                  tableName: 'products',
                  recordsPulled: 0,
                  errors: ['Pull error']),
            ]);

        when(() => mockPush.pushPending()).thenAnswer((_) async =>
            PushResult(
                successCount: 0, failedCount: 1, errors: ['Push error']));

        when(() => mockBidirectional.syncAll(
              orgId: any(named: 'orgId'),
              storeId: any(named: 'storeId'),
            )).thenAnswer((_) async => [
              BidirectionalResult(
                tableName: 'customers',
                pushed: 0,
                pulled: 0,
                conflicts: 0,
                errors: ['Bi error'],
              ),
            ]);

        when(() => mockStockDelta.sync(
              orgId: any(named: 'orgId'),
              storeId: any(named: 'storeId'),
              deviceId: any(named: 'deviceId'),
            )).thenAnswer((_) async => StockDeltaResult(
              deltasSent: 0,
              productsUpdated: 0,
              errors: ['Delta error'],
              oversoldProducts: [],
            ));

        when(() => mockStatusTracker.refreshAll())
            .thenAnswer((_) async {});

        // Initialize offline
        await engine.initialize(
          orgId: 'org-1',
          storeId: 'store-1',
          deviceId: 'device-1',
        );

        when(() => mockConnectivity.isOnline).thenReturn(true);
        when(() => mockConnectivity.isOffline).thenReturn(false);

        final result = await engine.syncNow();

        expect(result.success, isFalse);
        expect(result.errors, hasLength(4));
      });

      test('unlocks after sync completes', () async {
        when(() => mockConnectivity.isOnline).thenReturn(true);
        when(() => mockConnectivity.isOffline).thenReturn(false);

        when(() => mockPull.pullAll(
              orgId: any(named: 'orgId'),
              storeId: any(named: 'storeId'),
            )).thenAnswer((_) async => []);
        when(() => mockPush.pushPending()).thenAnswer((_) async =>
            PushResult(successCount: 0, failedCount: 0, errors: []));
        when(() => mockBidirectional.syncAll(
              orgId: any(named: 'orgId'),
              storeId: any(named: 'storeId'),
            )).thenAnswer((_) async => []);
        when(() => mockStockDelta.sync(
              orgId: any(named: 'orgId'),
              storeId: any(named: 'storeId'),
              deviceId: any(named: 'deviceId'),
            )).thenAnswer((_) async => StockDeltaResult(
              deltasSent: 0,
              productsUpdated: 0,
              errors: [],
              oversoldProducts: [],
            ));
        when(() => mockStatusTracker.refreshAll())
            .thenAnswer((_) async {});

        await engine.initialize(
          orgId: 'org-1',
          storeId: 'store-1',
          deviceId: 'device-1',
        );

        when(() => mockConnectivity.isOnline).thenReturn(true);
        when(() => mockConnectivity.isOffline).thenReturn(false);

        await engine.syncNow();

        expect(engine.isLocked, isFalse);
      });

      test('unlocks even when exception is thrown', () async {
        when(() => mockConnectivity.isOnline).thenReturn(true);
        when(() => mockConnectivity.isOffline).thenReturn(false);

        when(() => mockPull.pullAll(
              orgId: any(named: 'orgId'),
              storeId: any(named: 'storeId'),
            )).thenThrow(Exception('Critical error'));

        when(() => mockStatusTracker.refreshAll())
            .thenAnswer((_) async {});

        await engine.initialize(
          orgId: 'org-1',
          storeId: 'store-1',
          deviceId: 'device-1',
        );

        when(() => mockConnectivity.isOnline).thenReturn(true);
        when(() => mockConnectivity.isOffline).thenReturn(false);

        final result = await engine.syncNow();

        expect(result.success, isFalse);
        expect(engine.isLocked, isFalse);
      });
    });

    group('progressStream', () {
      test('is a broadcast stream', () {
        expect(engine.progressStream.isBroadcast, isTrue);
      });

      test('emits progress updates during sync', () async {
        when(() => mockConnectivity.isOnline).thenReturn(true);
        when(() => mockConnectivity.isOffline).thenReturn(false);

        when(() => mockPull.pullAll(
              orgId: any(named: 'orgId'),
              storeId: any(named: 'storeId'),
            )).thenAnswer((_) async => []);
        when(() => mockPush.pushPending()).thenAnswer((_) async =>
            PushResult(successCount: 0, failedCount: 0, errors: []));
        when(() => mockBidirectional.syncAll(
              orgId: any(named: 'orgId'),
              storeId: any(named: 'storeId'),
            )).thenAnswer((_) async => []);
        when(() => mockStockDelta.sync(
              orgId: any(named: 'orgId'),
              storeId: any(named: 'storeId'),
              deviceId: any(named: 'deviceId'),
            )).thenAnswer((_) async => StockDeltaResult(
              deltasSent: 0,
              productsUpdated: 0,
              errors: [],
              oversoldProducts: [],
            ));
        when(() => mockStatusTracker.refreshAll())
            .thenAnswer((_) async {});

        await engine.initialize(
          orgId: 'org-1',
          storeId: 'store-1',
          deviceId: 'device-1',
        );

        when(() => mockConnectivity.isOnline).thenReturn(true);
        when(() => mockConnectivity.isOffline).thenReturn(false);

        final progresses = <SyncProgress>[];
        engine.progressStream.listen(progresses.add);

        await engine.syncNow();

        // Should have multiple progress updates
        expect(progresses, isNotEmpty);

        // First should be syncing
        expect(progresses.first.state, SyncEngineState.syncing);
      });
    });
  });

  group('SyncProgress', () {
    test('progress is 0 when totalTables is 0', () {
      const progress = SyncProgress(totalTables: 0, completedTables: 0);
      expect(progress.progress, 0.0);
    });

    test('progress computes ratio correctly', () {
      const progress = SyncProgress(totalTables: 10, completedTables: 5);
      expect(progress.progress, 0.5);
    });

    test('isSyncing returns true when state is syncing', () {
      const progress = SyncProgress(state: SyncEngineState.syncing);
      expect(progress.isSyncing, isTrue);
    });

    test('isSyncing returns false when state is idle', () {
      const progress = SyncProgress(state: SyncEngineState.idle);
      expect(progress.isSyncing, isFalse);
    });

    test('copyWith preserves values', () {
      const original = SyncProgress(
        state: SyncEngineState.syncing,
        phase: SyncPhase.pulling,
        totalTables: 10,
        completedTables: 3,
        currentTable: 'products',
        errors: ['error1'],
      );

      final copy = original.copyWith(completedTables: 5);

      expect(copy.state, SyncEngineState.syncing);
      expect(copy.phase, SyncPhase.pulling);
      expect(copy.totalTables, 10);
      expect(copy.completedTables, 5);
      expect(copy.currentTable, 'products');
      expect(copy.errors, ['error1']);
    });
  });

  group('SyncEngineResult', () {
    test('totalSynced calculates correctly', () {
      final result = SyncEngineResult(
        success: true,
        errors: [],
        pullResults: [
          PullResult(tableName: 'products', recordsPulled: 10, errors: []),
        ],
        pushResult:
            PushResult(successCount: 5, failedCount: 0, errors: []),
        bidirectionalResults: [
          BidirectionalResult(
            tableName: 'customers',
            pushed: 2,
            pulled: 3,
            conflicts: 0,
            errors: [],
          ),
        ],
        stockDeltaResult: StockDeltaResult(
          deltasSent: 4,
          productsUpdated: 4,
          errors: [],
          oversoldProducts: [],
        ),
      );

      // 10 (pull) + 5 (push) + 2+3 (bi) + 4 (delta) = 24
      expect(result.totalSynced, 24);
    });

    test('totalSynced handles null results', () {
      final result = SyncEngineResult(success: true, errors: []);
      expect(result.totalSynced, 0);
    });
  });
}
