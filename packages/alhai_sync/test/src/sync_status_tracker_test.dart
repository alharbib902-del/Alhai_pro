import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_sync/src/sync_status_tracker.dart';

import '../helpers/sync_test_helpers.dart';

void main() {
  late MockAppDatabase mockDb;
  late MockSyncMetadataDao mockMetadataDao;
  late MockStockDeltasDao mockDeltasDao;
  late MockSyncQueueDao mockSyncQueueDao;
  late SyncStatusTracker tracker;

  setUpAll(() {
    registerSyncFallbackValues();
  });

  setUp(() {
    mockDb = MockAppDatabase();
    mockMetadataDao = MockSyncMetadataDao();
    mockDeltasDao = MockStockDeltasDao();
    mockSyncQueueDao = MockSyncQueueDao();

    // SyncStatusTracker accesses db.syncQueueDao
    when(() => mockDb.syncQueueDao).thenReturn(mockSyncQueueDao);

    tracker = SyncStatusTracker(
      db: mockDb,
      metadataDao: mockMetadataDao,
      deltasDao: mockDeltasDao,
    );
  });

  tearDown(() {
    tracker.dispose();
  });

  group('SyncStatusTracker', () {
    group('initial state', () {
      test('currentOverview starts with default values', () {
        final overview = tracker.currentOverview;
        expect(overview.health, SyncHealthStatus.healthy);
        expect(overview.totalPending, 0);
        expect(overview.totalFailed, 0);
        expect(overview.totalDeltasPending, 0);
        expect(overview.tables, isEmpty);
        expect(overview.lastFullSyncAt, isNull);
      });
    });

    group('refreshAll', () {
      test('updates overview with data from DAOs', () async {
        final now = DateTime.now().toUtc();
        when(() => mockMetadataDao.getAll()).thenAnswer(
          (_) async => [
            createSyncMetadata(
              tableName: 'products',
              lastPullAt: now,
              isInitialSynced: true,
              pendingCount: 2,
              failedCount: 0,
            ),
            createSyncMetadata(
              tableName: 'sales',
              lastPullAt: now.subtract(const Duration(minutes: 5)),
              isInitialSynced: true,
              pendingCount: 0,
              failedCount: 1,
            ),
          ],
        );
        when(
          () => mockSyncQueueDao.getPendingCount(),
        ).thenAnswer((_) async => 5);
        when(() => mockDeltasDao.getPendingCount()).thenAnswer((_) async => 3);

        await tracker.refreshAll();

        final overview = tracker.currentOverview;
        expect(overview.totalPending, 5);
        expect(overview.totalDeltasPending, 3);
        expect(overview.totalFailed, 1);
        expect(overview.tables, hasLength(2));
      });

      test('calculates health as healthy when no pending or failed', () async {
        when(() => mockMetadataDao.getAll()).thenAnswer((_) async => []);
        when(
          () => mockSyncQueueDao.getPendingCount(),
        ).thenAnswer((_) async => 0);
        when(() => mockDeltasDao.getPendingCount()).thenAnswer((_) async => 0);

        await tracker.refreshAll();

        expect(tracker.currentOverview.health, SyncHealthStatus.healthy);
      });

      test('calculates health as syncing when pending > 0', () async {
        when(() => mockMetadataDao.getAll()).thenAnswer((_) async => []);
        when(
          () => mockSyncQueueDao.getPendingCount(),
        ).thenAnswer((_) async => 3);
        when(() => mockDeltasDao.getPendingCount()).thenAnswer((_) async => 0);

        await tracker.refreshAll();

        expect(tracker.currentOverview.health, SyncHealthStatus.syncing);
      });

      test('calculates health as warning when failed > 0 and <= 10', () async {
        when(() => mockMetadataDao.getAll()).thenAnswer(
          (_) async => [
            createSyncMetadata(tableName: 'products', failedCount: 5),
          ],
        );
        when(
          () => mockSyncQueueDao.getPendingCount(),
        ).thenAnswer((_) async => 0);
        when(() => mockDeltasDao.getPendingCount()).thenAnswer((_) async => 0);

        await tracker.refreshAll();

        expect(tracker.currentOverview.health, SyncHealthStatus.warning);
      });

      test('calculates health as critical when failed > 10', () async {
        when(() => mockMetadataDao.getAll()).thenAnswer(
          (_) async => [
            createSyncMetadata(tableName: 'products', failedCount: 11),
          ],
        );
        when(
          () => mockSyncQueueDao.getPendingCount(),
        ).thenAnswer((_) async => 0);
        when(() => mockDeltasDao.getPendingCount()).thenAnswer((_) async => 0);

        await tracker.refreshAll();

        expect(tracker.currentOverview.health, SyncHealthStatus.critical);
      });

      test('emits overview on stream', () async {
        when(() => mockMetadataDao.getAll()).thenAnswer((_) async => []);
        when(
          () => mockSyncQueueDao.getPendingCount(),
        ).thenAnswer((_) async => 0);
        when(() => mockDeltasDao.getPendingCount()).thenAnswer((_) async => 0);

        final future = expectLater(
          tracker.overviewStream,
          emits(isA<SyncOverview>()),
        );

        await tracker.refreshAll();
        await future;
      });

      test('handles errors gracefully', () async {
        when(() => mockMetadataDao.getAll()).thenThrow(Exception('DB error'));

        // Should not throw
        await tracker.refreshAll();

        // Overview should remain at default
        expect(tracker.currentOverview.health, SyncHealthStatus.healthy);
      });

      test('determines lastFullSyncAt from earliest pull time', () async {
        final earlier = DateTime(2024, 1, 1);
        final later = DateTime(2024, 6, 1);
        when(() => mockMetadataDao.getAll()).thenAnswer(
          (_) async => [
            createSyncMetadata(tableName: 'products', lastPullAt: later),
            createSyncMetadata(tableName: 'sales', lastPullAt: earlier),
          ],
        );
        when(
          () => mockSyncQueueDao.getPendingCount(),
        ).thenAnswer((_) async => 0);
        when(() => mockDeltasDao.getPendingCount()).thenAnswer((_) async => 0);

        await tracker.refreshAll();

        expect(tracker.currentOverview.lastFullSyncAt, earlier);
      });
    });

    group('startTracking / stopTracking', () {
      test('startTracking triggers initial refresh', () async {
        when(() => mockMetadataDao.getAll()).thenAnswer((_) async => []);
        when(
          () => mockSyncQueueDao.getPendingCount(),
        ).thenAnswer((_) async => 0);
        when(() => mockDeltasDao.getPendingCount()).thenAnswer((_) async => 0);

        tracker.startTracking();

        // Wait for the initial refresh to complete
        await Future.delayed(const Duration(milliseconds: 100));

        verify(() => mockMetadataDao.getAll()).called(greaterThanOrEqualTo(1));
      });

      test('stopTracking cancels periodic refresh', () {
        // Should not throw
        tracker.startTracking();
        tracker.stopTracking();
      });
    });

    group('getPendingCount', () {
      test('returns sum of queue + deltas pending', () async {
        when(
          () => mockSyncQueueDao.getPendingCount(),
        ).thenAnswer((_) async => 5);
        when(() => mockDeltasDao.getPendingCount()).thenAnswer((_) async => 3);

        final count = await tracker.getPendingCount();

        expect(count, 8);
      });
    });

    group('getLastSyncTime', () {
      test('returns pull time when only pull exists', () async {
        final pullTime = DateTime(2024, 6, 1);
        when(() => mockMetadataDao.getForTable('products')).thenAnswer(
          (_) async =>
              createSyncMetadata(tableName: 'products', lastPullAt: pullTime),
        );

        final result = await tracker.getLastSyncTime('products');

        expect(result, pullTime);
      });

      test('returns push time when only push exists', () async {
        final pushTime = DateTime(2024, 6, 1);
        when(() => mockMetadataDao.getForTable('sales')).thenAnswer(
          (_) async =>
              createSyncMetadata(tableName: 'sales', lastPushAt: pushTime),
        );

        final result = await tracker.getLastSyncTime('sales');

        expect(result, pushTime);
      });

      test('returns the later of pull and push times', () async {
        final pullTime = DateTime(2024, 6, 1);
        final pushTime = DateTime(2024, 7, 1);
        when(() => mockMetadataDao.getForTable('customers')).thenAnswer(
          (_) async => createSyncMetadata(
            tableName: 'customers',
            lastPullAt: pullTime,
            lastPushAt: pushTime,
          ),
        );

        final result = await tracker.getLastSyncTime('customers');

        expect(result, pushTime);
      });

      test('returns null when no metadata exists', () async {
        when(
          () => mockMetadataDao.getForTable('unknown'),
        ).thenAnswer((_) async => null);

        final result = await tracker.getLastSyncTime('unknown');

        expect(result, isNull);
      });

      test('returns null when both times are null', () async {
        when(
          () => mockMetadataDao.getForTable('products'),
        ).thenAnswer((_) async => createSyncMetadata(tableName: 'products'));

        final result = await tracker.getLastSyncTime('products');

        expect(result, isNull);
      });
    });

    group('overviewStream', () {
      test('is a broadcast stream', () {
        expect(tracker.overviewStream.isBroadcast, isTrue);
      });
    });
  });

  group('SyncOverview', () {
    test('default values', () {
      const overview = SyncOverview();
      expect(overview.health, SyncHealthStatus.healthy);
      expect(overview.totalPending, 0);
      expect(overview.totalFailed, 0);
      expect(overview.totalDeltasPending, 0);
      expect(overview.tables, isEmpty);
      expect(overview.lastFullSyncAt, isNull);
    });
  });

  group('TableSyncStatus', () {
    test('hasErrors returns true when failedCount > 0', () {
      const status = TableSyncStatus(tableName: 'products', failedCount: 1);
      expect(status.hasErrors, isTrue);
    });

    test('hasErrors returns true when lastError is not null', () {
      const status = TableSyncStatus(
        tableName: 'products',
        lastError: 'Some error',
      );
      expect(status.hasErrors, isTrue);
    });

    test('hasPending returns true when pendingCount > 0', () {
      const status = TableSyncStatus(tableName: 'products', pendingCount: 3);
      expect(status.hasPending, isTrue);
    });

    test('isSynced returns true when fully synced with no pending/failed', () {
      const status = TableSyncStatus(
        tableName: 'products',
        isInitialSynced: true,
        pendingCount: 0,
        failedCount: 0,
      );
      expect(status.isSynced, isTrue);
    });

    test('isSynced returns false when not initial synced', () {
      const status = TableSyncStatus(
        tableName: 'products',
        isInitialSynced: false,
        pendingCount: 0,
        failedCount: 0,
      );
      expect(status.isSynced, isFalse);
    });
  });
}
