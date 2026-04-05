import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_sync/src/sync_api_service.dart';

import '../helpers/sync_test_helpers.dart';

void main() {
  late MockSupabaseClient mockClient;
  late SyncApiService service;

  setUpAll(() {
    registerSyncFallbackValues();
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    service = SyncApiService(client: mockClient);
  });

  group('SyncApiService', () {
    group('syncOperation', () {
      test('performs upsert for CREATE operation', () async {
        final queryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('products')).thenAnswer((_) => queryBuilder);
        setupUpsertChain(queryBuilder);

        await service.syncOperation(
          tableName: 'products',
          operation: 'CREATE',
          payload: {'id': 'p-1', 'name': 'Test'},
        );

        verify(() => queryBuilder.upsert(any(),
            onConflict: any(named: 'onConflict'))).called(1);
      });

      test('performs upsert for UPDATE operation', () async {
        final queryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('products')).thenAnswer((_) => queryBuilder);
        setupUpsertChain(queryBuilder);

        await service.syncOperation(
          tableName: 'products',
          operation: 'UPDATE',
          payload: {'id': 'p-1', 'name': 'Updated'},
        );

        verify(() => queryBuilder.upsert(any(),
            onConflict: any(named: 'onConflict'))).called(1);
      });

      test('performs delete for DELETE operation', () async {
        final queryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('products')).thenAnswer((_) => queryBuilder);
        setupDeleteChain(queryBuilder);

        await service.syncOperation(
          tableName: 'products',
          operation: 'DELETE',
          payload: {'id': 'p-1'},
        );

        verify(() => queryBuilder.delete()).called(1);
      });

      test('throws for DELETE without id', () async {
        expect(
          () => service.syncOperation(
            tableName: 'products',
            operation: 'DELETE',
            payload: {'name': 'Test'},
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws for unsupported operation', () async {
        expect(
          () => service.syncOperation(
            tableName: 'products',
            operation: 'UNKNOWN',
            payload: {'id': 'p-1'},
          ),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('removes synced_at field from payload', () async {
        final queryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('products')).thenAnswer((_) => queryBuilder);
        setupUpsertChain(queryBuilder);

        await service.syncOperation(
          tableName: 'products',
          operation: 'CREATE',
          payload: {
            'id': 'p-1',
            'name': 'Test',
            'synced_at': '2024-01-01',
            'syncedAt': '2024-01-01',
          },
        );

        final captured = verify(() => queryBuilder.upsert(
              captureAny(),
              onConflict: any(named: 'onConflict'),
            )).captured;

        final sentPayload = captured.first as Map<String, dynamic>;
        expect(sentPayload.containsKey('synced_at'), isFalse);
      });

      test('converts camelCase keys to snake_case', () async {
        final queryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('products')).thenAnswer((_) => queryBuilder);
        setupUpsertChain(queryBuilder);

        await service.syncOperation(
          tableName: 'products',
          operation: 'CREATE',
          payload: {
            'id': 'p-1',
            'productName': 'Test',
            'stockQty': 10,
          },
        );

        final captured = verify(() => queryBuilder.upsert(
              captureAny(),
              onConflict: any(named: 'onConflict'),
            )).captured;

        final sentPayload = captured.first as Map<String, dynamic>;
        expect(sentPayload.containsKey('product_name'), isTrue);
        expect(sentPayload.containsKey('stock_qty'), isTrue);
        expect(sentPayload.containsKey('productName'), isFalse);
      });

      test('is case-insensitive for operation', () async {
        final queryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('products')).thenAnswer((_) => queryBuilder);
        setupUpsertChain(queryBuilder);

        await service.syncOperation(
          tableName: 'products',
          operation: 'create',
          payload: {'id': 'p-1'},
        );

        verify(() => queryBuilder.upsert(any(),
            onConflict: any(named: 'onConflict'))).called(1);
      });
    });

    group('syncBatch', () {
      test('processes all operations successfully', () async {
        final queryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from(any())).thenAnswer((_) => queryBuilder);
        setupUpsertChain(queryBuilder);

        final operations = [
          SyncOperationItem(
            tableName: 'products',
            operation: 'CREATE',
            recordId: 'p-1',
            payload: {'id': 'p-1'},
          ),
          SyncOperationItem(
            tableName: 'products',
            operation: 'UPDATE',
            recordId: 'p-2',
            payload: {'id': 'p-2'},
          ),
        ];

        final result = await service.syncBatch(operations);

        expect(result.successCount, 2);
        expect(result.failedCount, 0);
        expect(result.hasErrors, isFalse);
        expect(result.totalCount, 2);
        expect(result.errors, isEmpty);
      });

      test('handles partial failures', () async {
        final queryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from(any())).thenAnswer((_) => queryBuilder);

        var callCount = 0;
        when(() => queryBuilder.upsert(any(),
            onConflict: any(named: 'onConflict'))).thenAnswer((_) {
          callCount++;
          if (callCount == 2) {
            throw Exception('Network error');
          }
          final upsertBuilder = MockPostgrestFilterBuilderDynamic();
          when(() => upsertBuilder.then<dynamic>(any(),
              onError: any(named: 'onError'))).thenAnswer((invocation) {
            final onValue = invocation.positionalArguments[0] as Function;
            return Future.value(onValue(null));
          });
          when(() => upsertBuilder.timeout(any(),
                  onTimeout: any(named: 'onTimeout')))
              .thenAnswer((_) => Future<dynamic>.value(null));
          return upsertBuilder;
        });

        final operations = [
          SyncOperationItem(
            tableName: 'products',
            operation: 'CREATE',
            recordId: 'p-1',
            payload: {'id': 'p-1'},
          ),
          SyncOperationItem(
            tableName: 'products',
            operation: 'CREATE',
            recordId: 'p-2',
            payload: {'id': 'p-2'},
          ),
        ];

        final result = await service.syncBatch(operations);

        expect(result.successCount, 1);
        expect(result.failedCount, 1);
        expect(result.hasErrors, isTrue);
        expect(result.errors, hasLength(1));
      });

      test('handles empty batch', () async {
        final result = await service.syncBatch([]);

        expect(result.successCount, 0);
        expect(result.failedCount, 0);
        expect(result.hasErrors, isFalse);
      });
    });

    group('fetchById', () {
      test('returns record when found', () async {
        final queryBuilder = MockSupabaseQueryBuilder();
        final filterBuilder = MockPostgrestFilterBuilder();
        when(() => mockClient.from('products')).thenAnswer((_) => queryBuilder);
        when(() => queryBuilder.select(any())).thenAnswer((_) => filterBuilder);
        when(() => filterBuilder.eq(any(), any()))
            .thenAnswer((_) => filterBuilder);
        setupMaybeSingle(filterBuilder, data: {'id': 'p-1', 'name': 'Test'});

        final result =
            await service.fetchById(tableName: 'products', id: 'p-1');

        expect(result, isNotNull);
        expect(result!['id'], 'p-1');
      });

      test('returns null when not found', () async {
        final queryBuilder = MockSupabaseQueryBuilder();
        final filterBuilder = MockPostgrestFilterBuilder();
        when(() => mockClient.from('products')).thenAnswer((_) => queryBuilder);
        when(() => queryBuilder.select(any())).thenAnswer((_) => filterBuilder);
        when(() => filterBuilder.eq(any(), any()))
            .thenAnswer((_) => filterBuilder);
        setupMaybeSingle(filterBuilder, data: null);

        final result =
            await service.fetchById(tableName: 'products', id: 'nonexistent');

        expect(result, isNull);
      });

      test('returns null on error', () async {
        final queryBuilder = MockSupabaseQueryBuilder();
        final filterBuilder = MockPostgrestFilterBuilder();
        when(() => mockClient.from('products')).thenAnswer((_) => queryBuilder);
        when(() => queryBuilder.select(any())).thenAnswer((_) => filterBuilder);
        when(() => filterBuilder.eq(any(), any()))
            .thenAnswer((_) => filterBuilder);
        // Mock maybeSingle to throw synchronously
        when(() => filterBuilder.maybeSingle())
            .thenThrow(Exception('Network error'));

        final result =
            await service.fetchById(tableName: 'products', id: 'p-1');

        expect(result, isNull);
      });
    });
  });

  group('SyncOperationItem', () {
    test('stores all fields correctly', () {
      final item = SyncOperationItem(
        tableName: 'products',
        operation: 'CREATE',
        recordId: 'p-1',
        payload: {'id': 'p-1', 'name': 'Test'},
      );

      expect(item.tableName, 'products');
      expect(item.operation, 'CREATE');
      expect(item.recordId, 'p-1');
      expect(item.payload['name'], 'Test');
    });
  });

  group('SyncBatchResult', () {
    test('hasErrors returns true when failedCount > 0', () {
      final result = SyncBatchResult(
        successCount: 1,
        failedCount: 1,
        errors: ['error'],
      );
      expect(result.hasErrors, isTrue);
    });

    test('hasErrors returns false when failedCount is 0', () {
      final result = SyncBatchResult(
        successCount: 2,
        failedCount: 0,
        errors: [],
      );
      expect(result.hasErrors, isFalse);
    });

    test('totalCount sums success and failed', () {
      final result = SyncBatchResult(
        successCount: 3,
        failedCount: 2,
        errors: [],
      );
      expect(result.totalCount, 5);
    });
  });
}
