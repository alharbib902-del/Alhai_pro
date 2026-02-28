import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_sync/src/strategies/bidirectional_strategy.dart';

import '../../helpers/sync_test_helpers.dart';

void main() {
  late MockSupabaseClient mockClient;
  late MockAppDatabase mockDb;
  late MockSyncMetadataDao mockMetadataDao;
  late MockSyncQueueDao mockSyncQueueDao;
  late BidirectionalStrategy strategy;

  setUpAll(() {
    registerSyncFallbackValues();
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockDb = MockAppDatabase();
    mockMetadataDao = MockSyncMetadataDao();
    mockSyncQueueDao = MockSyncQueueDao();

    when(() => mockDb.syncQueueDao).thenReturn(mockSyncQueueDao);

    strategy = BidirectionalStrategy(
      client: mockClient,
      db: mockDb,
      metadataDao: mockMetadataDao,
    );
  });

  group('BidirectionalStrategy', () {
    group('tableConfigs', () {
      test('contains expected tables', () {
        final tableNames = BidirectionalStrategy.tableConfigs
            .map((c) => c.tableName)
            .toList();
        expect(tableNames, contains('customers'));
        expect(tableNames, contains('expenses'));
        expect(tableNames, contains('returns'));
        expect(tableNames, contains('return_items'));
        expect(tableNames, contains('purchases'));
        expect(tableNames, contains('purchase_items'));
      });

      test('customers uses lastWriteWins conflict resolution', () {
        final config = BidirectionalStrategy.tableConfigs
            .firstWhere((c) => c.tableName == 'customers');
        expect(config.conflictResolution, ConflictResolution.lastWriteWins);
      });

      test('expenses uses localWins conflict resolution', () {
        final config = BidirectionalStrategy.tableConfigs
            .firstWhere((c) => c.tableName == 'expenses');
        expect(config.conflictResolution, ConflictResolution.localWins);
      });
    });

    group('syncTable', () {
      test('handles errors gracefully', () async {
        when(() => mockSyncQueueDao.getPendingItems())
            .thenThrow(Exception('DB error'));
        when(() => mockMetadataDao.setError(any(), any()))
            .thenAnswer((_) async {});

        final result = await strategy.syncTable(
          config: const BidirectionalTableConfig(
            tableName: 'customers',
            conflictResolution: ConflictResolution.lastWriteWins,
          ),
          orgId: 'org-1',
          storeId: 'store-1',
        );

        expect(result.tableName, 'customers');
        expect(result.hasErrors, isTrue);
        verify(() => mockMetadataDao.setError('customers', any())).called(1);
      });

      test('pushes local changes then pulls server changes', () async {
        // Mock local push: no pending items
        when(() => mockSyncQueueDao.getPendingItems())
            .thenAnswer((_) async => []);
        when(() => mockMetadataDao.getLastPullAt('customers'))
            .thenAnswer((_) async => null);

        // Mock server pull: no records
        final queryBuilder = MockSupabaseQueryBuilder();
        final filterBuilder = MockPostgrestFilterBuilder();
        when(() => mockClient.from('customers')).thenAnswer((_) => queryBuilder);
        setupSelectChain(queryBuilder, filterBuilder, data: []);

        when(() => mockMetadataDao.updateLastPushAt(any(), any(),
                syncCount: any(named: 'syncCount')))
            .thenAnswer((_) async {});
        when(() => mockMetadataDao.updateLastPullAt(any(), any(),
                syncCount: any(named: 'syncCount')))
            .thenAnswer((_) async {});
        when(() => mockMetadataDao.clearError(any()))
            .thenAnswer((_) async {});

        final result = await strategy.syncTable(
          config: const BidirectionalTableConfig(
            tableName: 'customers',
            conflictResolution: ConflictResolution.lastWriteWins,
          ),
          orgId: 'org-1',
          storeId: 'store-1',
        );

        expect(result.tableName, 'customers');
        expect(result.hasErrors, isFalse);
        expect(result.pushed, 0);
        expect(result.pulled, 0);
        expect(result.conflicts, 0);
      });

      test('pushes pending local changes to server', () async {
        final items = [
          createSyncQueueItem(
            id: 'q-1',
            tableName: 'customers',
            operation: 'CREATE',
            payload: jsonEncode({'id': 'c-1', 'name': 'John'}),
          ),
        ];

        when(() => mockSyncQueueDao.getPendingItems())
            .thenAnswer((_) async => items);
        when(() => mockSyncQueueDao.markAsSyncing(any()))
            .thenAnswer((_) async => 1);
        when(() => mockSyncQueueDao.markAsSynced(any()))
            .thenAnswer((_) async => 1);
        when(() => mockMetadataDao.getLastPullAt('customers'))
            .thenAnswer((_) async => null);

        final queryBuilder = MockSupabaseQueryBuilder();
        final filterBuilder = MockPostgrestFilterBuilder();
        when(() => mockClient.from('customers')).thenAnswer((_) => queryBuilder);
        setupUpsertChain(queryBuilder);
        setupSelectChain(queryBuilder, filterBuilder, data: []);

        when(() => mockMetadataDao.updateLastPushAt(any(), any(),
                syncCount: any(named: 'syncCount')))
            .thenAnswer((_) async {});
        when(() => mockMetadataDao.updateLastPullAt(any(), any(),
                syncCount: any(named: 'syncCount')))
            .thenAnswer((_) async {});
        when(() => mockMetadataDao.clearError(any()))
            .thenAnswer((_) async {});

        final result = await strategy.syncTable(
          config: const BidirectionalTableConfig(
            tableName: 'customers',
            conflictResolution: ConflictResolution.lastWriteWins,
          ),
          orgId: 'org-1',
          storeId: 'store-1',
        );

        expect(result.pushed, 1);
        verify(() => mockSyncQueueDao.markAsSynced('q-1')).called(1);
      });
    });

    group('syncAll', () {
      test('syncs all configured tables', () async {
        // For each table, mock the push + pull to succeed
        for (final config in BidirectionalStrategy.tableConfigs) {
          when(() => mockSyncQueueDao.getPendingItems())
              .thenAnswer((_) async => []);
          when(() => mockMetadataDao.getLastPullAt(config.tableName))
              .thenAnswer((_) async => null);

          final queryBuilder = MockSupabaseQueryBuilder();
          final filterBuilder = MockPostgrestFilterBuilder();
          when(() => mockClient.from(config.tableName))
              .thenAnswer((_) => queryBuilder);
          setupSelectChain(queryBuilder, filterBuilder, data: []);

          when(() => mockMetadataDao.updateLastPushAt(config.tableName, any(),
                  syncCount: any(named: 'syncCount')))
              .thenAnswer((_) async {});
          when(() => mockMetadataDao.updateLastPullAt(config.tableName, any(),
                  syncCount: any(named: 'syncCount')))
              .thenAnswer((_) async {});
          when(() => mockMetadataDao.clearError(config.tableName))
              .thenAnswer((_) async {});
        }

        final results = await strategy.syncAll(
          orgId: 'org-1',
          storeId: 'store-1',
        );

        expect(results,
            hasLength(BidirectionalStrategy.tableConfigs.length));
      });
    });
  });

  group('BidirectionalTableConfig', () {
    test('stores tableName and conflictResolution', () {
      const config = BidirectionalTableConfig(
        tableName: 'customers',
        conflictResolution: ConflictResolution.lastWriteWins,
      );
      expect(config.tableName, 'customers');
      expect(config.conflictResolution, ConflictResolution.lastWriteWins);
    });
  });

  group('ConflictResolution', () {
    test('has expected values', () {
      expect(ConflictResolution.values, [
        ConflictResolution.lastWriteWins,
        ConflictResolution.localWins,
        ConflictResolution.deltaMerge,
      ]);
    });
  });

  group('BidirectionalResult', () {
    test('hasErrors returns true when errors exist', () {
      final result = BidirectionalResult(
        tableName: 'customers',
        pushed: 1,
        pulled: 2,
        conflicts: 0,
        errors: ['error'],
      );
      expect(result.hasErrors, isTrue);
    });

    test('hasErrors returns false when no errors', () {
      final result = BidirectionalResult(
        tableName: 'customers',
        pushed: 1,
        pulled: 2,
        conflicts: 0,
        errors: [],
      );
      expect(result.hasErrors, isFalse);
    });
  });
}
