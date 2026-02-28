import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_sync/src/org_sync_service.dart';

import '../helpers/sync_test_helpers.dart';

void main() {
  late MockSupabaseClient mockClient;
  late OrgSyncService service;

  setUpAll(() {
    registerSyncFallbackValues();
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    service = OrgSyncService(client: mockClient);
  });

  group('OrgSyncService', () {
    group('syncOperation', () {
      test('performs upsert for CREATE operation', () async {
        final queryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('organizations')).thenAnswer((_) => queryBuilder);
        setupUpsertChain(queryBuilder);

        await service.syncOperation(
          tableName: 'organizations',
          operation: 'CREATE',
          payload: {'id': 'org-1', 'name': 'Test Org'},
        );

        verify(() => queryBuilder.upsert(any(),
                onConflict: any(named: 'onConflict')))
            .called(1);
      });

      test('performs upsert for UPDATE operation', () async {
        final queryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('organizations')).thenAnswer((_) => queryBuilder);
        setupUpsertChain(queryBuilder);

        await service.syncOperation(
          tableName: 'organizations',
          operation: 'UPDATE',
          payload: {'id': 'org-1', 'name': 'Updated Org'},
        );

        verify(() => queryBuilder.upsert(any(),
                onConflict: any(named: 'onConflict')))
            .called(1);
      });

      test('performs delete for DELETE operation', () async {
        final queryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('organizations')).thenAnswer((_) => queryBuilder);
        setupDeleteChain(queryBuilder);

        await service.syncOperation(
          tableName: 'organizations',
          operation: 'DELETE',
          payload: {'id': 'org-1'},
        );

        verify(() => queryBuilder.delete()).called(1);
      });

      test('throws for DELETE without id', () async {
        expect(
          () => service.syncOperation(
            tableName: 'organizations',
            operation: 'DELETE',
            payload: {'name': 'Test'},
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws for unsupported operation', () async {
        expect(
          () => service.syncOperation(
            tableName: 'organizations',
            operation: 'INVALID',
            payload: {'id': 'org-1'},
          ),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('removes synced_at from payload', () async {
        final queryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('organizations')).thenAnswer((_) => queryBuilder);
        setupUpsertChain(queryBuilder);

        await service.syncOperation(
          tableName: 'organizations',
          operation: 'CREATE',
          payload: {
            'id': 'org-1',
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
        expect(sentPayload.containsKey('syncedAt'), isFalse);
      });
    });

    group('fetchOrgUpdates', () {
      test('fetches using eq id for organizations table', () async {
        final queryBuilder = MockSupabaseQueryBuilder();
        final filterBuilder = MockPostgrestFilterBuilder();
        when(() => mockClient.from('organizations')).thenAnswer((_) => queryBuilder);
        when(() => queryBuilder.select(any())).thenAnswer((_) => filterBuilder);
        when(() => filterBuilder.eq(any(), any())).thenAnswer((_) => filterBuilder);

        // Mock the async resolution via then()
        when(() => filterBuilder.then<dynamic>(any(), onError: any(named: 'onError')))
            .thenAnswer((invocation) {
          final onValue = invocation.positionalArguments[0] as Function;
          return Future.value(onValue([
            {'id': 'org-1', 'name': 'Test'}
          ]));
        });

        final result = await service.fetchOrgUpdates(
          tableName: 'organizations',
          orgId: 'org-1',
        );

        verify(() => filterBuilder.eq('id', 'org-1')).called(1);
        expect(result, hasLength(1));
      });

      test('fetches using eq org_id for non-organization tables', () async {
        final queryBuilder = MockSupabaseQueryBuilder();
        final filterBuilder = MockPostgrestFilterBuilder();
        when(() => mockClient.from('subscriptions')).thenAnswer((_) => queryBuilder);
        when(() => queryBuilder.select(any())).thenAnswer((_) => filterBuilder);
        when(() => filterBuilder.eq(any(), any())).thenAnswer((_) => filterBuilder);

        when(() => filterBuilder.then<dynamic>(any(), onError: any(named: 'onError')))
            .thenAnswer((invocation) {
          final onValue = invocation.positionalArguments[0] as Function;
          return Future.value(onValue([
            {'id': 'sub-1', 'org_id': 'org-1'}
          ]));
        });

        final result = await service.fetchOrgUpdates(
          tableName: 'subscriptions',
          orgId: 'org-1',
        );

        verify(() => filterBuilder.eq('org_id', 'org-1')).called(1);
        expect(result, hasLength(1));
      });

      test('rethrows on error', () async {
        final queryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('subscriptions')).thenAnswer((_) => queryBuilder);
        when(() => queryBuilder.select(any()))
            .thenThrow(Exception('Network error'));

        expect(
          () => service.fetchOrgUpdates(
            tableName: 'subscriptions',
            orgId: 'org-1',
          ),
          throwsException,
        );
      });
    });

    group('fetchStoreUpdates', () {
      test('fetches with store_id filter', () async {
        final queryBuilder = MockSupabaseQueryBuilder();
        final filterBuilder = MockPostgrestFilterBuilder();
        when(() => mockClient.from('pos_terminals')).thenAnswer((_) => queryBuilder);
        when(() => queryBuilder.select(any())).thenAnswer((_) => filterBuilder);
        when(() => filterBuilder.eq(any(), any())).thenAnswer((_) => filterBuilder);

        when(() => filterBuilder.then<dynamic>(any(), onError: any(named: 'onError')))
            .thenAnswer((invocation) {
          final onValue = invocation.positionalArguments[0] as Function;
          return Future.value(onValue([
            {'id': 'pos-1', 'store_id': 'store-1'}
          ]));
        });

        final result = await service.fetchStoreUpdates(
          tableName: 'pos_terminals',
          storeId: 'store-1',
        );

        verify(() => filterBuilder.eq('store_id', 'store-1')).called(1);
        expect(result, hasLength(1));
      });
    });
  });

  group('OrgTables', () {
    test('contains expected table names', () {
      expect(OrgTables.organizations, 'organizations');
      expect(OrgTables.subscriptions, 'subscriptions');
      expect(OrgTables.orgMembers, 'org_members');
      expect(OrgTables.userStores, 'user_stores');
      expect(OrgTables.posTerminals, 'pos_terminals');
    });

    test('all list contains all tables in order', () {
      expect(OrgTables.all, [
        'organizations',
        'subscriptions',
        'org_members',
        'user_stores',
        'pos_terminals',
      ]);
    });
  });
}
