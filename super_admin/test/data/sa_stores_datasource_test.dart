import 'package:flutter_test/flutter_test.dart';
import 'package:super_admin/core/services/audit_log_service.dart';
import 'package:super_admin/data/models/sa_store_model.dart';
import 'package:super_admin/data/sa_stores_datasource.dart';

import '../helpers/mock_supabase_client.dart';
import '../helpers/test_factories.dart';

void main() {
  late MockSupabaseClient mock;
  late SAStoresDatasource ds;

  setUp(() {
    resetFactoryIds();
    mock = MockSupabaseClient();
    ds = SAStoresDatasource.test(mock.client);
  });

  // ==========================================================================
  // getStores
  // ==========================================================================

  group('getStores', () {
    test('returns parsed stores with no filters', () async {
      // Arrange
      mock.setResponse('stores', [
        SAStoreFactory.json(id: 's1', name: 'Store One'),
        SAStoreFactory.json(id: 's2', name: 'Store Two'),
      ]);

      // Act
      final result = await ds.getStores();

      // Assert
      expect(result, hasLength(2));
      expect(result[0], isA<SAStore>());
      expect(result[0].id, equals('s1'));
      expect(result[0].name, equals('Store One'));
      expect(result[1].id, equals('s2'));
    });

    test('does not add eq filter when statusFilter is null', () async {
      // Arrange
      mock.setResponse('stores', []);

      // Act
      await ds.getStores();

      // Assert
      final ops = mock.queryLog['stores']!.first;
      final eqOps = ops.where((op) => op.method == 'eq');
      expect(eqOps, isEmpty);
    });

    test('does not add eq filter when statusFilter is "all"', () async {
      // Arrange
      mock.setResponse('stores', []);

      // Act
      await ds.getStores(statusFilter: 'all');

      // Assert
      final ops = mock.queryLog['stores']!.first;
      final eqOps = ops.where((op) => op.method == 'eq');
      expect(eqOps, isEmpty);
    });

    test('adds eq(is_active, true) for active statusFilter', () async {
      // Arrange
      mock.setResponse('stores', []);

      // Act
      await ds.getStores(statusFilter: 'active');

      // Assert
      final ops = mock.queryLog['stores']!.first;
      final eqOp = ops.firstWhere((op) => op.method == 'eq');
      expect(eqOp.args[0], equals('is_active'));
      expect(eqOp.args[1], isTrue);
    });

    test('adds eq(is_active, false) for suspended statusFilter', () async {
      // Arrange
      mock.setResponse('stores', []);

      // Act
      await ds.getStores(statusFilter: 'suspended');

      // Assert
      final ops = mock.queryLog['stores']!.first;
      final eqOp = ops.firstWhere((op) => op.method == 'eq');
      expect(eqOp.args[0], equals('is_active'));
      expect(eqOp.args[1], isFalse);
    });

    test('adds or filter when search is provided', () async {
      // Arrange
      mock.setResponse('stores', []);

      // Act
      await ds.getStores(search: 'cafe');

      // Assert
      final ops = mock.queryLog['stores']!.first;
      final orOp = ops.firstWhere((op) => op.method == 'or');
      expect(orOp.args[0], contains('cafe'));
    });

    test('does not add or filter when search is empty', () async {
      // Arrange
      mock.setResponse('stores', []);

      // Act
      await ds.getStores(search: '');

      // Assert
      final ops = mock.queryLog['stores']!.first;
      final orOps = ops.where((op) => op.method == 'or');
      expect(orOps, isEmpty);
    });

    test('sanitizes search input', () async {
      // Arrange
      mock.setResponse('stores', []);

      // Act
      await ds.getStores(search: '100%_store');

      // Assert
      final ops = mock.queryLog['stores']!.first;
      final orOp = ops.firstWhere((op) => op.method == 'or');
      final filter = orOp.args[0] as String;
      expect(filter, contains(r'100\%\_store'));
    });

    test('orders by created_at descending', () async {
      // Arrange
      mock.setResponse('stores', []);

      // Act
      await ds.getStores();

      // Assert
      final ops = mock.queryLog['stores']!.first;
      final orderOp = ops.firstWhere((op) => op.method == 'order');
      expect(orderOp.args[0], equals('created_at'));
      expect(orderOp.args[1], isFalse);
    });

    test('returns empty list when no stores exist', () async {
      // Arrange
      mock.setResponse('stores', []);

      // Act
      final result = await ds.getStores();

      // Assert
      expect(result, isEmpty);
    });

    test('parses nested subscriptions from the join', () async {
      // Arrange
      mock.setResponse('stores', [
        SAStoreFactory.json(
          id: 's1',
          name: 'Store With Sub',
          subscriptions: [
            {
              'id': 'sub-1',
              'plan': 'basic',
              'status': 'active',
              'amount': 99.0,
              'current_period_start': '2025-01-01T00:00:00Z',
              'current_period_end': '2025-02-01T00:00:00Z',
              'org_id': 's1',
            },
          ],
        ),
      ]);

      // Act
      final result = await ds.getStores();

      // Assert
      expect(result.first.subscriptions, hasLength(1));
      expect(result.first.subscriptions.first.planSlug, equals('basic'));
      expect(result.first.subscriptions.first.status, equals('active'));
    });
  });

  // ==========================================================================
  // getStore
  // ==========================================================================

  group('getStore', () {
    test('returns a single store by ID', () async {
      // Arrange
      mock.setResponse(
        'stores',
        SAStoreFactory.json(id: 's42', name: 'My Store'),
      );

      // Act
      final store = await ds.getStore('s42');

      // Assert
      expect(store.id, equals('s42'));
      expect(store.name, equals('My Store'));
    });

    test('sends eq filter for the store id and calls single()', () async {
      // Arrange
      mock.setResponse('stores', SAStoreFactory.json(id: 's42'));

      // Act
      await ds.getStore('s42');

      // Assert
      final ops = mock.queryLog['stores']!.first;
      final eqOp = ops.firstWhere((op) => op.method == 'eq');
      expect(eqOp.args[0], equals('id'));
      expect(eqOp.args[1], equals('s42'));
      expect(ops.any((op) => op.method == 'single'), isTrue);
    });

    test('returns store with nested subscriptions', () async {
      // Arrange
      mock.setResponse('stores', {
        'id': 's42',
        'name': 'My Store',
        'address': '123 Main St',
        'phone': '+966500000000',
        'email': 's42@test.com',
        'is_active': true,
        'owner_id': 'owner-1',
        'business_type': 'retail',
        'created_at': '2025-01-01T00:00:00Z',
        'logo': null,
        'subscriptions': [
          {
            'id': 'sub-1',
            'plan': 'pro',
            'status': 'active',
            'amount': 249.0,
            'current_period_start': '2025-01-01T00:00:00Z',
            'current_period_end': '2025-02-01T00:00:00Z',
            'org_id': 's42',
          },
        ],
      });

      // Act
      final store = await ds.getStore('s42');

      // Assert
      expect(store.subscriptions, hasLength(1));
      expect(store.subscriptions.first.planSlug, equals('pro'));
    });
  });

  // ==========================================================================
  // getStoreUsageStats
  // ==========================================================================

  group('getStoreUsageStats', () {
    test('returns usage stats from parallel count queries', () async {
      // Arrange -- all three tables use the same mock config, but
      // the mock returns counts per table name.
      mock.setCount('sales', 120);
      mock.setCount('products', 45);
      mock.setCount('users', 8);

      // Act
      final stats = await ds.getStoreUsageStats('s1');

      // Assert
      expect(stats.transactions, equals(120));
      expect(stats.products, equals(45));
      expect(stats.employees, equals(8));
      expect(stats.branches, equals(1)); // hardcoded default
    });

    test('filters each query by store_id', () async {
      // Arrange
      mock.setCount('sales', 0);
      mock.setCount('products', 0);
      mock.setCount('users', 0);

      // Act
      await ds.getStoreUsageStats('s1');

      // Assert -- each table should have an eq('store_id', 's1')
      for (final table in ['sales', 'products', 'users']) {
        final ops = mock.queryLog[table]!.first;
        final eqOp = ops.firstWhere((op) => op.method == 'eq');
        expect(eqOp.args[0], equals('store_id'));
        expect(eqOp.args[1], equals('s1'));
      }
    });

    test('returns zero stats when no data exists', () async {
      // Arrange
      mock.setCount('sales', 0);
      mock.setCount('products', 0);
      mock.setCount('users', 0);

      // Act
      final stats = await ds.getStoreUsageStats('s1');

      // Assert
      expect(stats.transactions, equals(0));
      expect(stats.products, equals(0));
      expect(stats.employees, equals(0));
    });
  });

  // ==========================================================================
  // createStore
  // ==========================================================================

  group('createStore', () {
    // Shared response shape mirroring what the v49 `create_store` RPC
    // returns -- a single public.stores row (nested subscriptions are NOT
    // returned by the RPC; they live in the subscriptions table and can
    // be joined on read).
    Map<String, dynamic> rpcStoreRow({
      String id = 'new-store-1',
      String name = 'Fresh Store',
      String? phone,
      String? email,
      String? taxNumber,
    }) => {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'tax_number': taxNumber,
      'is_active': true,
      'org_id': null,
      'owner_id': null,
      'currency': 'SAR',
      'timezone': 'Asia/Riyadh',
      'created_at': '2025-06-01T00:00:00Z',
    };

    test('calls create_store RPC with correct p_* params', () async {
      // Arrange
      mock.setRpcResponse(
        'create_store',
        rpcStoreRow(
          id: 'new-store-1',
          name: 'Fresh Store',
          phone: '+966500001111',
          email: 'fresh@test.com',
          taxNumber: '300123456789003',
        ),
      );

      // Act
      final store = await ds.createStore(
        name: 'Fresh Store',
        phone: '+966500001111',
        email: 'fresh@test.com',
        taxNumber: '300123456789003',
        plan: 'starter',
        businessType: 'restaurant',
      );

      // Assert -- returned row parses
      expect(store.id, equals('new-store-1'));
      expect(store.name, equals('Fresh Store'));

      // Assert -- exactly one RPC invocation with the expected name + params
      final calls = mock.queryLog['rpc:create_store'];
      expect(calls, isNotNull);
      expect(calls, hasLength(1));
      final op = calls!.single.single;
      expect(op.method, equals('rpc'));
      expect(op.args[0], equals('create_store'));

      final params = op.args[1] as Map<String, dynamic>;
      expect(params['p_name'], equals('Fresh Store'));
      expect(params['p_phone'], equals('+966500001111'));
      expect(params['p_email'], equals('fresh@test.com'));
      expect(params['p_tax_number'], equals('300123456789003'));
      expect(params['p_plan'], equals('starter'));
      expect(params['p_business_type'], equals('restaurant'));
    });

    test('normalises empty-string optional params to null', () async {
      // Arrange
      mock.setRpcResponse('create_store', rpcStoreRow());

      // Act -- pass empty strings / whitespace for every optional field
      await ds.createStore(
        name: 'Fresh Store',
        phone: '',
        email: '   ',
        taxNumber: '',
        plan: 'free',
        businessType: '  ',
      );

      // Assert -- each optional becomes null, not '' or '   '
      final params =
          mock.queryLog['rpc:create_store']!.single.single.args[1]
              as Map<String, dynamic>;
      expect(params['p_phone'], isNull);
      expect(params['p_email'], isNull);
      expect(params['p_tax_number'], isNull);
      expect(params['p_business_type'], isNull);
      expect(params['p_name'], equals('Fresh Store')); // required, kept
      expect(params['p_plan'], equals('free'));       // required, kept
    });

    test('propagates RPC errors (server-side rollback is authoritative)',
        () async {
      // Arrange -- the RPC raises (could be 42501 guard, 22023 empty, or
      // 23514 CHECK violation). The datasource just surfaces the error;
      // the full transaction rollback is handled server-side.
      mock.setRpcError('create_store', Exception('RPC failed'));

      // Act & Assert
      await expectLater(
        () => ds.createStore(
          name: 'Will Fail',
          phone: '+966500000000',
          email: 'fail@test.com',
          plan: 'starter',
          businessType: 'retail',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'does not emit a datasource-side sa_audit_log row '
      '(RPC owns the audit write)',
      () async {
        // Arrange -- inject an audit service so any call would show in
        // queryLog; the assertion below verifies none was made.
        final dsWithAudit = SAStoresDatasource.test(
          mock.client,
          audit: AuditLogService.test(mock.client),
        );
        mock.setRpcResponse('create_store', rpcStoreRow());

        // Act
        await dsWithAudit.createStore(
          name: 'Audit Check',
          phone: '+966500002222',
          email: 'audit@test.com',
          plan: 'free',
          businessType: 'retail',
        );

        // Assert -- no INSERT was logged against the sa_audit_log table.
        // (The server-side v49 RPC writes its audit row internally; that
        // write never round-trips through the client mock.)
        expect(mock.queryLog['sa_audit_log'], isNull);
      },
    );
  });

  // ==========================================================================
  // updateStoreStatus
  // ==========================================================================

  group('updateStoreStatus', () {
    test('sets is_active to true when activating', () async {
      // Arrange
      mock.setResponse('stores', []);

      // Act
      await ds.updateStoreStatus('s1', true);

      // Assert
      final ops = mock.queryLog['stores']!.first;
      final updateOp = ops.firstWhere((op) => op.method == 'update');
      expect(updateOp.args[0], equals({'is_active': true}));
      final eqOp = ops.firstWhere((op) => op.method == 'eq');
      expect(eqOp.args[0], equals('id'));
      expect(eqOp.args[1], equals('s1'));
    });

    test('sets is_active to false when suspending', () async {
      // Arrange
      mock.setResponse('stores', []);

      // Act
      await ds.updateStoreStatus('s1', false);

      // Assert
      final ops = mock.queryLog['stores']!.first;
      final updateOp = ops.firstWhere((op) => op.method == 'update');
      expect(updateOp.args[0], equals({'is_active': false}));
    });
  });

  // ==========================================================================
  // updateStorePlan
  // ==========================================================================

  group('updateStorePlan', () {
    test('looks up org_id then updates subscription plan', () async {
      // Arrange -- stores select returns org_id, subscriptions update succeeds
      mock.setResponse('stores', {'org_id': 'org-42'});
      mock.setResponse('subscriptions', []);

      // Act
      await ds.updateStorePlan('s1', 'pro');

      // Assert -- check stores lookup
      final storeOps = mock.queryLog['stores']!.first;
      expect(storeOps.any((op) => op.method == 'maybeSingle'), isTrue);
      final storeEq = storeOps.firstWhere((op) => op.method == 'eq');
      expect(storeEq.args[0], equals('id'));
      expect(storeEq.args[1], equals('s1'));

      // Check subscription update
      final subOps = mock.queryLog['subscriptions']!.first;
      final updateOp = subOps.firstWhere((op) => op.method == 'update');
      expect(updateOp.args[0], equals({'plan': 'pro'}));
      final eqOps = subOps.where((op) => op.method == 'eq').toList();
      // Should have eq('org_id', 'org-42') and eq('status', 'active')
      expect(
        eqOps.any((op) => op.args[0] == 'org_id' && op.args[1] == 'org-42'),
        isTrue,
      );
      expect(
        eqOps.any((op) => op.args[0] == 'status' && op.args[1] == 'active'),
        isTrue,
      );
    });

    test('falls back to storeId when org_id is null', () async {
      // Arrange -- store lookup returns no org_id
      mock.setResponse('stores', <String, dynamic>{});
      mock.setResponse('subscriptions', []);

      // Act
      await ds.updateStorePlan('s1', 'basic');

      // Assert -- should use storeId as fallback org_id
      final subOps = mock.queryLog['subscriptions']!.first;
      final eqOps = subOps.where((op) => op.method == 'eq').toList();
      expect(
        eqOps.any((op) => op.args[0] == 'org_id' && op.args[1] == 's1'),
        isTrue,
      );
    });
  });

  // ==========================================================================
  // getTotalStoreCount / getActiveStoreCount
  // ==========================================================================

  group('getTotalStoreCount', () {
    test('returns total count of all stores', () async {
      // Arrange
      mock.setCount('stores', 100);

      // Act
      final count = await ds.getTotalStoreCount();

      // Assert
      expect(count, equals(100));
    });

    test('uses count(CountOption.exact)', () async {
      // Arrange
      mock.setCount('stores', 0);

      // Act
      await ds.getTotalStoreCount();

      // Assert
      final ops = mock.queryLog['stores']!.first;
      expect(ops.any((op) => op.method == 'count'), isTrue);
    });
  });

  group('getActiveStoreCount', () {
    test('returns count of active stores', () async {
      // Arrange
      mock.setCount('stores', 75);

      // Act
      final count = await ds.getActiveStoreCount();

      // Assert
      expect(count, equals(75));
    });

    test('filters by is_active = true', () async {
      // Arrange
      mock.setCount('stores', 0);

      // Act
      await ds.getActiveStoreCount();

      // Assert
      final ops = mock.queryLog['stores']!.first;
      final eqOp = ops.firstWhere((op) => op.method == 'eq');
      expect(eqOp.args[0], equals('is_active'));
      expect(eqOp.args[1], isTrue);
    });
  });

  // ==========================================================================
  // softDeleteStore / restoreStore
  // ==========================================================================

  group('softDeleteStore', () {
    test('sets is_active to false for the given store', () async {
      // Arrange
      mock.setResponse('stores', []);

      // Act
      await ds.softDeleteStore('s1');

      // Assert
      final ops = mock.queryLog['stores']!.first;
      final updateOp = ops.firstWhere((op) => op.method == 'update');
      expect(updateOp.args[0], equals({'is_active': false}));
      final eqOp = ops.firstWhere((op) => op.method == 'eq');
      expect(eqOp.args[0], equals('id'));
      expect(eqOp.args[1], equals('s1'));
    });
  });

  group('restoreStore', () {
    test('sets is_active to true for the given store', () async {
      // Arrange
      mock.setResponse('stores', []);

      // Act
      await ds.restoreStore('s1');

      // Assert
      final ops = mock.queryLog['stores']!.first;
      final updateOp = ops.firstWhere((op) => op.method == 'update');
      expect(updateOp.args[0], equals({'is_active': true}));
      final eqOp = ops.firstWhere((op) => op.method == 'eq');
      expect(eqOp.args[0], equals('id'));
      expect(eqOp.args[1], equals('s1'));
    });
  });

  // ==========================================================================
  // getStoreOwner
  // ==========================================================================

  group('getStoreOwner', () {
    test('returns the store owner when found', () async {
      // Arrange
      mock.setResponse('users', {
        'id': 'owner-1',
        'name': 'Ali Owner',
        'phone': '+966500001111',
        'email': 'ali@test.com',
        'role': 'owner',
      });

      // Act
      final owner = await ds.getStoreOwner('s1');

      // Assert
      expect(owner, isNotNull);
      expect(owner!.id, equals('owner-1'));
      expect(owner.name, equals('Ali Owner'));
      expect(owner.role, equals('owner'));
    });

    test('returns null when no owner found', () async {
      // Arrange -- maybeSingle returns null when list is empty
      mock.setResponse('users', <dynamic>[]);

      // Act
      final owner = await ds.getStoreOwner('s1');

      // Assert
      expect(owner, isNull);
    });

    test('filters by store_id and role = owner', () async {
      // Arrange
      mock.setResponse('users', <dynamic>[]);

      // Act
      await ds.getStoreOwner('s1');

      // Assert
      final ops = mock.queryLog['users']!.first;
      final eqOps = ops.where((op) => op.method == 'eq').toList();
      expect(
        eqOps.any((op) => op.args[0] == 'store_id' && op.args[1] == 's1'),
        isTrue,
      );
      expect(
        eqOps.any((op) => op.args[0] == 'role' && op.args[1] == 'owner'),
        isTrue,
      );
    });

    test('calls maybeSingle() for optional result', () async {
      // Arrange
      mock.setResponse('users', <dynamic>[]);

      // Act
      await ds.getStoreOwner('s1');

      // Assert
      final ops = mock.queryLog['users']!.first;
      expect(ops.any((op) => op.method == 'maybeSingle'), isTrue);
    });
  });

  // ==========================================================================
  // Error handling
  // ==========================================================================

  group('error handling', () {
    test('getStores propagates errors', () async {
      // Arrange
      mock.setError('stores', Exception('Network error'));

      // Act & Assert
      expect(() => ds.getStores(), throwsA(isA<Exception>()));
    });

    test('getStore propagates errors', () async {
      // Arrange
      mock.setError('stores', Exception('Not found'));

      // Act & Assert
      expect(() => ds.getStore('s1'), throwsA(isA<Exception>()));
    });

    test(
      'getStoreUsageStats propagates errors from any parallel query',
      () async {
        // Arrange -- make sales fail, products/users succeed
        mock.setError('sales', Exception('Table not found'));
        mock.setCount('products', 0);
        mock.setCount('users', 0);

        // Act & Assert
        expect(() => ds.getStoreUsageStats('s1'), throwsA(isA<Exception>()));
      },
    );

    test('softDeleteStore propagates errors', () async {
      // Arrange
      mock.setError('stores', Exception('Permission denied'));

      // Act & Assert
      expect(() => ds.softDeleteStore('s1'), throwsA(isA<Exception>()));
    });
  });
}
