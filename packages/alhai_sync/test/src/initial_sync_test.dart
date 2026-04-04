import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_sync/src/initial_sync.dart';

import '../helpers/sync_test_helpers.dart';

void main() {
  late MockSupabaseClient mockClient;
  late MockAppDatabase mockDb;
  late MockSyncMetadataDao mockMetadataDao;
  late InitialSync initialSync;

  setUpAll(() {
    registerSyncFallbackValues();
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockDb = MockAppDatabase();
    mockMetadataDao = MockSyncMetadataDao();

    initialSync = InitialSync(
      client: mockClient,
      db: mockDb,
      metadataDao: mockMetadataDao,
    );
  });

  tearDown(() {
    initialSync.dispose();
  });

  group('InitialSync', () {
    group('downloadOrder', () {
      test('contains expected tables in dependency order', () {
        expect(InitialSync.downloadOrder, [
          // المرحلة 1: البنية الأساسية
          'organizations',
          'stores',
          'users',
          'roles',
          // المرحلة 2: البيانات المرجعية
          'categories',
          'products',
          'settings',
          'expense_categories',
          // المرحلة 3: البيانات التشغيلية (Pull)
          'discounts',
          'coupons',
          'promotions',
          'loyalty_rewards',
          'drivers',
          // المرحلة 4: البيانات ثنائية الاتجاه
          'customers',
          'customer_addresses',
          'suppliers',
          'accounts',
          'loyalty_points',
          'whatsapp_templates',
          // المرحلة 5: البيانات التفصيلية
          'shifts',
          'notifications',
          'product_expiry',
        ]);
      });
    });

    group('isComplete', () {
      test('returns true when all tables are initial synced', () async {
        for (final table in InitialSync.downloadOrder) {
          when(() => mockMetadataDao.isInitialSynced(table))
              .thenAnswer((_) async => true);
        }

        final result = await initialSync.isComplete();

        expect(result, isTrue);
      });

      test('returns false when any table is not synced', () async {
        for (final table in InitialSync.downloadOrder) {
          when(() => mockMetadataDao.isInitialSynced(table))
              .thenAnswer((_) async => table != 'products');
        }

        final result = await initialSync.isComplete();

        expect(result, isFalse);
      });

      test('returns false when no tables are synced', () async {
        for (final table in InitialSync.downloadOrder) {
          when(() => mockMetadataDao.isInitialSynced(table))
              .thenAnswer((_) async => false);
        }

        final result = await initialSync.isComplete();

        expect(result, isFalse);
      });
    });

    group('getRemainingTables', () {
      test('returns all tables when none are synced', () async {
        for (final table in InitialSync.downloadOrder) {
          when(() => mockMetadataDao.isInitialSynced(table))
              .thenAnswer((_) async => false);
        }

        final remaining = await initialSync.getRemainingTables();

        expect(remaining, InitialSync.downloadOrder);
      });

      test('returns empty when all are synced', () async {
        for (final table in InitialSync.downloadOrder) {
          when(() => mockMetadataDao.isInitialSynced(table))
              .thenAnswer((_) async => true);
        }

        final remaining = await initialSync.getRemainingTables();

        expect(remaining, isEmpty);
      });

      test('returns only unsynced tables', () async {
        for (final table in InitialSync.downloadOrder) {
          when(() => mockMetadataDao.isInitialSynced(table)).thenAnswer(
              (_) async => table == 'organizations' || table == 'stores');
        }

        final remaining = await initialSync.getRemainingTables();

        expect(remaining, isNot(contains('organizations')));
        expect(remaining, isNot(contains('stores')));
        expect(remaining, contains('users'));
        expect(remaining, contains('products'));
      });
    });

    group('execute', () {
      test('returns success with 0 records when all tables already synced',
          () async {
        for (final table in InitialSync.downloadOrder) {
          when(() => mockMetadataDao.isInitialSynced(table))
              .thenAnswer((_) async => true);
        }

        final result = await initialSync.execute(
          orgId: 'org-1',
          storeId: 'store-1',
        );

        expect(result.success, isTrue);
        expect(result.totalRecords, 0);
        expect(result.errors, isEmpty);
      });

      test('emits progress events during sync', () async {
        // Only one table remaining
        for (final table in InitialSync.downloadOrder) {
          when(() => mockMetadataDao.isInitialSynced(table))
              .thenAnswer((_) async => table != 'organizations');
        }

        // Mock the download for organizations
        final queryBuilder = MockSupabaseQueryBuilder();
        final filterBuilder = MockPostgrestFilterBuilder();
        when(() => mockClient.from('organizations'))
            .thenAnswer((_) => queryBuilder);
        setupSelectChain(queryBuilder, filterBuilder, data: []);

        when(() => mockMetadataDao.markInitialSynced(any()))
            .thenAnswer((_) async {});
        when(() => mockMetadataDao.updateLastPullAt(any(), any(),
            syncCount: any(named: 'syncCount'))).thenAnswer((_) async {});

        final progresses = <InitialSyncProgress>[];
        initialSync.progressStream.listen(progresses.add);

        await initialSync.execute(orgId: 'org-1', storeId: 'store-1');

        expect(progresses, isNotEmpty);
        // Last progress should be complete
        expect(progresses.last.isComplete, isTrue);
      });

      test('continues syncing other tables when one fails', () async {
        // All tables remaining
        for (final table in InitialSync.downloadOrder) {
          when(() => mockMetadataDao.isInitialSynced(table))
              .thenAnswer((_) async => false);
        }

        // For each table, set up the mock to either succeed or fail
        for (final table in InitialSync.downloadOrder) {
          final queryBuilder = MockSupabaseQueryBuilder();
          final filterBuilder = MockPostgrestFilterBuilder();
          when(() => mockClient.from(table)).thenAnswer((_) => queryBuilder);

          if (table == 'users') {
            // Simulate failure for users by throwing synchronously from select()
            when(() => queryBuilder.select(any()))
                .thenThrow(Exception('Network error'));
          } else {
            setupSelectChain(queryBuilder, filterBuilder, data: []);
          }

          when(() => mockMetadataDao.markInitialSynced(table))
              .thenAnswer((_) async {});
          when(() => mockMetadataDao.updateLastPullAt(table, any(),
              syncCount: any(named: 'syncCount'))).thenAnswer((_) async {});
          when(() => mockMetadataDao.setError(table, any()))
              .thenAnswer((_) async {});
        }

        final result = await initialSync.execute(
          orgId: 'org-1',
          storeId: 'store-1',
        );

        expect(result.success, isFalse); // At least one error
        expect(result.errors, isNotEmpty);
        // Verify that users failed
        expect(result.errors.any((e) => e.contains('users')), isTrue);
        // But other tables should have been attempted
        verify(() => mockMetadataDao.markInitialSynced('organizations'))
            .called(1);
      });
    });

    group('progressStream', () {
      test('is a broadcast stream', () {
        expect(initialSync.progressStream.isBroadcast, isTrue);
      });
    });
  });

  group('InitialSyncProgress', () {
    test('default values', () {
      const progress = InitialSyncProgress();
      expect(progress.currentTable, '');
      expect(progress.currentTableIndex, 0);
      expect(progress.totalTables, 0);
      expect(progress.recordsDownloaded, 0);
      expect(progress.isComplete, isFalse);
      expect(progress.error, isNull);
    });

    test('progress computes ratio correctly', () {
      const progress = InitialSyncProgress(
        currentTableIndex: 5,
        totalTables: 10,
      );
      expect(progress.progress, 0.5);
    });

    test('progress is 0 when totalTables is 0', () {
      const progress = InitialSyncProgress(
        currentTableIndex: 0,
        totalTables: 0,
      );
      expect(progress.progress, 0.0);
    });
  });

  group('InitialSyncResult', () {
    test('stores all fields correctly', () {
      final result = InitialSyncResult(
        success: true,
        totalRecords: 100,
        errors: [],
      );
      expect(result.success, isTrue);
      expect(result.totalRecords, 100);
      expect(result.errors, isEmpty);
    });

    test('stores errors', () {
      final result = InitialSyncResult(
        success: false,
        totalRecords: 50,
        errors: ['products: Network error'],
      );
      expect(result.success, isFalse);
      expect(result.errors, hasLength(1));
    });
  });
}
