import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_sync/src/conflict_resolver.dart';
import 'package:alhai_sync/src/pull_sync_service.dart';
import 'package:alhai_sync/src/sync_api_service.dart';

import '../helpers/sync_test_helpers.dart';

class MockSyncApiService extends Mock implements SyncApiService {}

class MockConflictResolver extends Mock implements ConflictResolver {}

void main() {
  late MockSyncApiService mockSyncApi;
  late MockAppDatabase mockDb;
  late MockSyncMetadataDao mockMetadataDao;
  late MockSyncQueueDao mockSyncQueueDao;
  late PullSyncService service;

  setUpAll(() {
    registerSyncFallbackValues();
  });

  setUp(() {
    mockSyncApi = MockSyncApiService();
    mockDb = MockAppDatabase();
    mockMetadataDao = MockSyncMetadataDao();
    mockSyncQueueDao = MockSyncQueueDao();

    service = PullSyncService(
      syncApi: mockSyncApi,
      db: mockDb,
      metadataDao: mockMetadataDao,
      syncQueueDao: mockSyncQueueDao,
    );
  });

  group('PullSyncService', () {
    group('pullUpdates', () {
      test('pulls all configured tables', () async {
        // Setup: no previous pull, no records returned
        when(() => mockMetadataDao.getLastPullAt(any()))
            .thenAnswer((_) async => null);
        when(() => mockSyncApi.fetchUpdates(
              tableName: any(named: 'tableName'),
              storeId: any(named: 'storeId'),
              since: any(named: 'since'),
            )).thenAnswer((_) async => []);

        final result = await service.pullUpdates(storeId: 'store-1');

        expect(result.success, isTrue);
        expect(result.totalPulled, 0);
        expect(result.errors, isEmpty);

        // Should have queried each pull table
        for (final table in PullSyncService.pullTables) {
          verify(() => mockSyncApi.fetchUpdates(
                tableName: table,
                storeId: 'store-1',
                since: null,
              )).called(1);
        }
      });

      test('accumulates records from multiple tables', () async {
        when(() => mockMetadataDao.getLastPullAt(any()))
            .thenAnswer((_) async => null);

        when(() => mockSyncApi.fetchUpdates(
              tableName: 'products',
              storeId: any(named: 'storeId'),
              since: any(named: 'since'),
            )).thenAnswer((_) async => [
              {'id': 'p-1', 'name': 'Product 1'},
              {'id': 'p-2', 'name': 'Product 2'},
            ]);

        // Other tables return empty
        when(() => mockSyncApi.fetchUpdates(
              tableName: any(named: 'tableName', that: isNot('products')),
              storeId: any(named: 'storeId'),
              since: any(named: 'since'),
            )).thenAnswer((_) async => []);

        when(() => mockSyncQueueDao.getPendingRecordIdsForTable(any()))
            .thenAnswer((_) async => <String>{});

        // Mock the DB batch insert
        when(() => mockDb.customStatement(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockDb.batch(any())).thenAnswer((invocation) async {
          // ignore: unused_local_variable
          final fn = invocation.positionalArguments[0] as Function;
          // Don't actually call fn to avoid complex batch mocking
        });

        when(() => mockMetadataDao.updateLastPullAt(
              any(),
              any(),
              syncCount: any(named: 'syncCount'),
            )).thenAnswer((_) async {});

        final result = await service.pullUpdates(storeId: 'store-1');

        expect(result.tableCounts['products'], 2);
        expect(result.totalPulled, 2);
      });

      test('continues on table error and collects errors', () async {
        when(() => mockMetadataDao.getLastPullAt(any()))
            .thenAnswer((_) async => null);

        // First table fails
        when(() => mockSyncApi.fetchUpdates(
              tableName: 'products',
              storeId: any(named: 'storeId'),
              since: any(named: 'since'),
            )).thenThrow(Exception('Network error'));

        // Other tables succeed
        when(() => mockSyncApi.fetchUpdates(
              tableName: any(named: 'tableName', that: isNot('products')),
              storeId: any(named: 'storeId'),
              since: any(named: 'since'),
            )).thenAnswer((_) async => []);

        final result = await service.pullUpdates(storeId: 'store-1');

        expect(result.hasErrors, isTrue);
        expect(result.errors, isNotEmpty);
        expect(result.errors.first, contains('products'));
      });

      test('passes lastPullAt as since parameter', () async {
        final lastPull = DateTime(2026, 1, 10);

        when(() => mockMetadataDao.getLastPullAt('products'))
            .thenAnswer((_) async => lastPull);
        when(() => mockMetadataDao.getLastPullAt(
                any(that: isNot('products'))))
            .thenAnswer((_) async => null);

        when(() => mockSyncApi.fetchUpdates(
              tableName: any(named: 'tableName'),
              storeId: any(named: 'storeId'),
              since: any(named: 'since'),
            )).thenAnswer((_) async => []);

        await service.pullUpdates(storeId: 'store-1');

        verify(() => mockSyncApi.fetchUpdates(
              tableName: 'products',
              storeId: 'store-1',
              since: lastPull,
            )).called(1);
      });
    });

    group('pullTables', () {
      test('contains expected tables', () {
        expect(PullSyncService.pullTables, contains('products'));
        expect(PullSyncService.pullTables, contains('categories'));
        expect(PullSyncService.pullTables, contains('settings'));
        expect(PullSyncService.pullTables, contains('discounts'));
      });
    });
  });

  group('PullSyncResult', () {
    test('success is true when no errors', () {
      final result = PullSyncResult(
        tableCounts: {'products': 5},
        totalPulled: 5,
        errors: [],
      );
      expect(result.success, isTrue);
      expect(result.hasErrors, isFalse);
    });

    test('success is false with errors', () {
      final result = PullSyncResult(
        tableCounts: {},
        totalPulled: 0,
        errors: ['products: Network error'],
      );
      expect(result.success, isFalse);
      expect(result.hasErrors, isTrue);
    });

    test('toString includes summary', () {
      final result = PullSyncResult(
        tableCounts: {'products': 5, 'categories': 3},
        totalPulled: 8,
        skippedConflicts: 2,
        errors: [],
      );
      final str = result.toString();
      expect(str, contains('total=8'));
      expect(str, contains('tables=2'));
      expect(str, contains('skippedConflicts=2'));
    });
  });
}
