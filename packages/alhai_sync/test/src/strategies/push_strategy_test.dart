import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_sync/src/strategies/push_strategy.dart';

import '../../helpers/sync_test_helpers.dart';

void main() {
  late MockSupabaseClient mockClient;
  late MockAppDatabase mockDb;
  late MockSyncMetadataDao mockMetadataDao;
  late MockSyncQueueDao mockSyncQueueDao;
  late PushStrategy strategy;

  setUpAll(() {
    registerSyncFallbackValues();
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockDb = MockAppDatabase();
    mockMetadataDao = MockSyncMetadataDao();
    mockSyncQueueDao = MockSyncQueueDao();

    when(() => mockDb.syncQueueDao).thenReturn(mockSyncQueueDao);

    strategy = PushStrategy(
      client: mockClient,
      db: mockDb,
      metadataDao: mockMetadataDao,
    );
  });

  group('PushStrategy', () {
    group('pushTables', () {
      test('contains expected tables', () {
        expect(PushStrategy.pushTables, [
          'sales',
          'sale_items',
          'orders',
          'order_items',
          'cash_movements',
          'audit_log',
          // جداول جديدة
          'inventory_movements',
          'order_status_history',
          'daily_summaries',
          'whatsapp_messages',
          // فواتير - تُنشأ محلياً وتُدفع للسيرفر
          'invoices',
        ]);
      });
    });

    group('pushPending', () {
      test('returns empty result when no pending items', () async {
        when(() => mockSyncQueueDao.getPendingItems())
            .thenAnswer((_) async => []);

        final result = await strategy.pushPending();

        expect(result.successCount, 0);
        expect(result.failedCount, 0);
        expect(result.hasErrors, isFalse);
      });

      test('filters to only push table items', () async {
        final items = [
          createSyncQueueItem(
            id: 'q-1',
            tableName: 'sales',
            operation: 'CREATE',
            payload: jsonEncode({'id': 's-1', 'total': 100}),
          ),
          createSyncQueueItem(
            id: 'q-2',
            tableName: 'products', // Not a push table
            operation: 'UPDATE',
            payload: jsonEncode({'id': 'p-1'}),
          ),
        ];

        when(() => mockSyncQueueDao.getPendingItems())
            .thenAnswer((_) async => items);
        when(() => mockSyncQueueDao.markAsSyncing(any()))
            .thenAnswer((_) async => 1);
        when(() => mockSyncQueueDao.markAsSynced(any()))
            .thenAnswer((_) async => 1);
        when(() => mockMetadataDao.updateLastPushAt(any(), any(),
            syncCount: any(named: 'syncCount'))).thenAnswer((_) async {});

        final queryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('sales')).thenAnswer((_) => queryBuilder);
        setupUpsertChain(queryBuilder);

        final result = await strategy.pushPending();

        expect(result.successCount, 1);
        // products is not a push table, so it's skipped (not counted as failed)
        verify(() => mockSyncQueueDao.markAsSyncing('q-1')).called(1);
        verifyNever(() => mockSyncQueueDao.markAsSyncing('q-2'));
      });

      test('skips items that exceeded maxRetries', () async {
        final items = [
          createSyncQueueItem(
            id: 'q-1',
            tableName: 'sales',
            operation: 'CREATE',
            payload: jsonEncode({'id': 's-1'}),
            retryCount: 5, // >= maxRetries
          ),
        ];

        when(() => mockSyncQueueDao.getPendingItems())
            .thenAnswer((_) async => items);

        final result = await strategy.pushPending();

        expect(result.successCount, 0);
        expect(result.failedCount, 0);
        verifyNever(() => mockSyncQueueDao.markAsSyncing(any()));
      });

      test('marks as conflict after max retries', () async {
        final items = [
          createSyncQueueItem(
            id: 'q-1',
            tableName: 'sales',
            operation: 'CREATE',
            payload: jsonEncode({'id': 's-1'}),
            retryCount: 4, // Will become 5 after failure (>= maxRetries)
          ),
        ];

        when(() => mockSyncQueueDao.getPendingItems())
            .thenAnswer((_) async => items);
        when(() => mockSyncQueueDao.markAsSyncing(any()))
            .thenAnswer((_) async => 1);
        when(() => mockSyncQueueDao.markAsFailed(any(), any()))
            .thenAnswer((_) async => 1);
        when(() => mockSyncQueueDao.markAsConflict(any(), any()))
            .thenAnswer((_) async => 1);
        when(() => mockMetadataDao.updateLastPushAt(any(), any(),
            syncCount: any(named: 'syncCount'))).thenAnswer((_) async {});

        final queryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('sales')).thenAnswer((_) => queryBuilder);
        // Make upsert fail by throwing synchronously
        when(() => queryBuilder.upsert(any(),
                onConflict: any(named: 'onConflict')))
            .thenThrow(Exception('Server error'));

        final result = await strategy.pushPending();

        expect(result.failedCount, 1);
        verify(() => mockSyncQueueDao.markAsConflict('q-1', any())).called(1);
      });

      test('handles DELETE operation', () async {
        final items = [
          createSyncQueueItem(
            id: 'q-1',
            tableName: 'sales',
            operation: 'DELETE',
            payload: jsonEncode({'id': 's-1'}),
          ),
        ];

        when(() => mockSyncQueueDao.getPendingItems())
            .thenAnswer((_) async => items);
        when(() => mockSyncQueueDao.markAsSyncing(any()))
            .thenAnswer((_) async => 1);
        when(() => mockSyncQueueDao.markAsSynced(any()))
            .thenAnswer((_) async => 1);
        when(() => mockMetadataDao.updateLastPushAt(any(), any(),
            syncCount: any(named: 'syncCount'))).thenAnswer((_) async {});

        final queryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('sales')).thenAnswer((_) => queryBuilder);
        setupDeleteChain(queryBuilder);

        final result = await strategy.pushPending();

        expect(result.successCount, 1);
        verify(() => queryBuilder.delete()).called(1);
      });

      test('skips org tables', () async {
        final items = [
          createSyncQueueItem(
            id: 'q-1',
            tableName: 'organizations',
            operation: 'UPDATE',
            payload: jsonEncode({'id': 'org-1'}),
          ),
        ];

        when(() => mockSyncQueueDao.getPendingItems())
            .thenAnswer((_) async => items);

        final result = await strategy.pushPending();

        // Organizations is not in pushTables, so it's filtered out
        expect(result.successCount, 0);
        expect(result.failedCount, 0);
      });

      test('catches general strategy errors', () async {
        when(() => mockSyncQueueDao.getPendingItems())
            .thenThrow(Exception('DB connection failed'));

        final result = await strategy.pushPending();

        expect(result.errors, isNotEmpty);
        expect(result.errors.first, contains('Push strategy error'));
      });
    });

    group('getRetryDelay', () {
      test('returns exponential backoff with jitter', () {
        // We test that the base delay doubles each time
        // Jitter adds 0-999ms, so we check lower bound
        final delay0 = PushStrategy.getRetryDelay(0);
        final delay1 = PushStrategy.getRetryDelay(1);
        final delay2 = PushStrategy.getRetryDelay(2);

        expect(delay0.inSeconds, greaterThanOrEqualTo(2));
        expect(delay0.inSeconds, lessThanOrEqualTo(3));

        expect(delay1.inSeconds, greaterThanOrEqualTo(4));
        expect(delay1.inSeconds, lessThanOrEqualTo(5));

        expect(delay2.inSeconds, greaterThanOrEqualTo(8));
        expect(delay2.inSeconds, lessThanOrEqualTo(9));
      });
    });
  });

  group('PushResult', () {
    test('hasErrors when failedCount > 0', () {
      final result = PushResult(
        successCount: 2,
        failedCount: 1,
        errors: ['error'],
      );
      expect(result.hasErrors, isTrue);
    });

    test('no errors when failedCount is 0', () {
      final result = PushResult(
        successCount: 5,
        failedCount: 0,
        errors: [],
      );
      expect(result.hasErrors, isFalse);
    });

    test('totalCount sums success and failed', () {
      final result = PushResult(
        successCount: 3,
        failedCount: 2,
        errors: [],
      );
      expect(result.totalCount, 5);
    });
  });
}
