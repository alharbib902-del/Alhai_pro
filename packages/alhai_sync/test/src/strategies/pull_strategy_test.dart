import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_sync/src/strategies/pull_strategy.dart';

import '../../helpers/sync_test_helpers.dart';

void main() {
  late MockSupabaseClient mockClient;
  late MockAppDatabase mockDb;
  late MockSyncMetadataDao mockMetadataDao;
  late PullStrategy strategy;

  setUpAll(() {
    registerSyncFallbackValues();
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockDb = MockAppDatabase();
    mockMetadataDao = MockSyncMetadataDao();

    strategy = PullStrategy(
      client: mockClient,
      db: mockDb,
      metadataDao: mockMetadataDao,
    );
  });

  group('PullStrategy', () {
    group('pullTables', () {
      test('contains expected tables', () {
        expect(PullStrategy.pullTables, [
          'categories',
          'products',
          'stores',
          'roles',
          'settings',
          // جداول جديدة
          'users',
          'discounts',
          'coupons',
          'promotions',
          'loyalty_rewards',
          'drivers',
          'expense_categories',
        ]);
      });
    });

    group('pullTable', () {
      test('handles error gracefully and returns result with errors', () async {
        when(() => mockMetadataDao.getLastPullAt(any()))
            .thenThrow(Exception('DB error'));
        when(() => mockMetadataDao.setError(any(), any()))
            .thenAnswer((_) async {});

        final result = await strategy.pullTable(
          tableName: 'products',
          orgId: 'org-1',
          storeId: 'store-1',
        );

        expect(result.tableName, 'products');
        expect(result.hasErrors, isTrue);
        expect(result.recordsPulled, 0);
        verify(() => mockMetadataDao.setError('products', any())).called(1);
      });

      test('updates metadata after successful pull with 0 records', () async {
        when(() => mockMetadataDao.getLastPullAt('products'))
            .thenAnswer((_) async => null);

        final queryBuilder = MockSupabaseQueryBuilder();
        final filterBuilder = MockPostgrestFilterBuilder();
        when(() => mockClient.from('products')).thenAnswer((_) => queryBuilder);
        setupSelectChain(queryBuilder, filterBuilder, data: []);

        when(() => mockMetadataDao.updateLastPullAt(any(), any(),
            syncCount: any(named: 'syncCount'))).thenAnswer((_) async {});
        when(() => mockMetadataDao.clearError(any())).thenAnswer((_) async {});

        final result = await strategy.pullTable(
          tableName: 'products',
          orgId: 'org-1',
          storeId: 'store-1',
        );

        expect(result.tableName, 'products');
        expect(result.hasErrors, isFalse);
        expect(result.recordsPulled, 0);
        verify(() => mockMetadataDao.updateLastPullAt(
              'products',
              any(),
              syncCount: 0,
            )).called(1);
        verify(() => mockMetadataDao.clearError('products')).called(1);
      });
    });

    group('pullAll', () {
      test('pulls all tables and returns results', () async {
        // For each table, mock the pull to succeed with no records
        for (final tableName in PullStrategy.pullTables) {
          when(() => mockMetadataDao.getLastPullAt(tableName))
              .thenAnswer((_) async => null);

          final queryBuilder = MockSupabaseQueryBuilder();
          final filterBuilder = MockPostgrestFilterBuilder();
          when(() => mockClient.from(tableName))
              .thenAnswer((_) => queryBuilder);
          setupSelectChain(queryBuilder, filterBuilder, data: []);

          when(() => mockMetadataDao.updateLastPullAt(tableName, any(),
              syncCount: any(named: 'syncCount'))).thenAnswer((_) async {});
          when(() => mockMetadataDao.clearError(tableName))
              .thenAnswer((_) async {});
        }

        final results = await strategy.pullAll(
          orgId: 'org-1',
          storeId: 'store-1',
        );

        expect(results, hasLength(PullStrategy.pullTables.length));
        for (final result in results) {
          expect(result.hasErrors, isFalse);
        }
      });
    });
  });

  group('PullResult', () {
    test('hasErrors returns true when errors exist', () {
      final result = PullResult(
        tableName: 'products',
        recordsPulled: 0,
        errors: ['error'],
      );
      expect(result.hasErrors, isTrue);
    });

    test('hasErrors returns false when no errors', () {
      final result = PullResult(
        tableName: 'products',
        recordsPulled: 5,
        errors: [],
      );
      expect(result.hasErrors, isFalse);
    });
  });
}
