# Report 4: Generated Unit Tests

## Test file locations:

```
test/data/daos/organizations_dao_test.dart
test/data/daos/org_members_dao_test.dart
test/data/daos/pos_terminals_dao_test.dart
test/services/sync/org_sync_service_test.dart
test/data/tables/schema_validation_test.dart
```

## File 1: `test/data/daos/organizations_dao_test.dart`

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';

import 'package:pos_app/data/local/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('OrganizationsDao', () {
    test('insert and retrieve organization', () async {
      await db.organizationsDao.upsertOrganization(
        OrganizationsTableCompanion.insert(
          id: 'org-1',
          name: 'Test Org',
          createdAt: DateTime.now(),
        ),
      );

      final org = await db.organizationsDao.getOrganizationById('org-1');
      expect(org, isNotNull);
      expect(org!.name, 'Test Org');
    });

    test('update organization', () async {
      await db.organizationsDao.upsertOrganization(
        OrganizationsTableCompanion.insert(
          id: 'org-1',
          name: 'Old Name',
          createdAt: DateTime.now(),
        ),
      );

      await db.organizationsDao.upsertOrganization(
        OrganizationsTableCompanion.insert(
          id: 'org-1',
          name: 'New Name',
          createdAt: DateTime.now(),
        ),
      );

      final org = await db.organizationsDao.getOrganizationById('org-1');
      expect(org!.name, 'New Name');
    });

    test('delete organization', () async {
      await db.organizationsDao.upsertOrganization(
        OrganizationsTableCompanion.insert(
          id: 'org-1',
          name: 'To Delete',
          createdAt: DateTime.now(),
        ),
      );

      await db.organizationsDao.deleteOrganization('org-1');
      final org = await db.organizationsDao.getOrganizationById('org-1');
      expect(org, isNull);
    });

    test('watch organization emits updates', () async {
      final stream = db.organizationsDao.watchOrganization('org-1');

      await db.organizationsDao.upsertOrganization(
        OrganizationsTableCompanion.insert(
          id: 'org-1',
          name: 'Stream Test',
          createdAt: DateTime.now(),
        ),
      );

      await expectLater(
        stream,
        emits(isNotNull),
      );
    });

    test('get active subscription', () async {
      await db.organizationsDao.upsertSubscription(
        SubscriptionsTableCompanion.insert(
          id: 'sub-1',
          orgId: 'org-1',
          currentPeriodStart: DateTime.now(),
          currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
        ),
      );

      final sub = await db.organizationsDao.getActiveSubscription('org-1');
      expect(sub, isNotNull);
      expect(sub!.status, 'active');
    });
  });
}
```

## File 2: `test/data/daos/org_members_dao_test.dart`

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';

import 'package:pos_app/data/local/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('OrgMembersDao', () {
    test('add and retrieve org members', () async {
      await db.orgMembersDao.upsertOrgMember(
        OrgMembersTableCompanion.insert(
          id: 'member-1',
          orgId: 'org-1',
          userId: 'user-1',
          createdAt: DateTime.now(),
        ),
      );

      final members = await db.orgMembersDao.getOrgMembers('org-1');
      expect(members.length, 1);
      expect(members.first.role, 'staff');
    });

    test('get member by user id', () async {
      await db.orgMembersDao.upsertOrgMember(
        OrgMembersTableCompanion.insert(
          id: 'member-1',
          orgId: 'org-1',
          userId: 'user-1',
          createdAt: DateTime.now(),
        ),
      );

      final member =
          await db.orgMembersDao.getMemberByUserId('org-1', 'user-1');
      expect(member, isNotNull);
    });

    test('user store assignments', () async {
      await db.orgMembersDao.upsertUserStore(
        UserStoresTableCompanion.insert(
          id: 'us-1',
          userId: 'user-1',
          storeId: 'store-1',
          createdAt: DateTime.now(),
        ),
      );

      final stores = await db.orgMembersDao.getUserStores('user-1');
      expect(stores.length, 1);
      expect(stores.first.role, 'cashier');

      final users = await db.orgMembersDao.getStoreUsers('store-1');
      expect(users.length, 1);
    });
  });
}
```

## File 3: `test/data/daos/pos_terminals_dao_test.dart`

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';

import 'package:pos_app/data/local/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('PosTerminalsDao', () {
    test('create and retrieve terminal', () async {
      await db.posTerminalsDao.upsertTerminal(
        PosTerminalsTableCompanion.insert(
          id: 'term-1',
          storeId: 'store-1',
          orgId: 'org-1',
          name: 'Terminal 1',
          createdAt: DateTime.now(),
        ),
      );

      final terminal = await db.posTerminalsDao.getTerminal('term-1');
      expect(terminal, isNotNull);
      expect(terminal!.name, 'Terminal 1');
    });

    test('get active terminals', () async {
      await db.posTerminalsDao.upsertTerminal(
        PosTerminalsTableCompanion.insert(
          id: 'term-1',
          storeId: 'store-1',
          orgId: 'org-1',
          name: 'Active',
          createdAt: DateTime.now(),
        ),
      );

      final active =
          await db.posTerminalsDao.getActiveTerminals('store-1');
      expect(active.length, 1);
    });

    test('update heartbeat', () async {
      await db.posTerminalsDao.upsertTerminal(
        PosTerminalsTableCompanion.insert(
          id: 'term-1',
          storeId: 'store-1',
          orgId: 'org-1',
          name: 'Terminal 1',
          createdAt: DateTime.now(),
        ),
      );

      await db.posTerminalsDao.updateHeartbeat('term-1');
      final terminal = await db.posTerminalsDao.getTerminal('term-1');
      expect(terminal!.lastHeartbeatAt, isNotNull);
    });

    test('update current shift', () async {
      await db.posTerminalsDao.upsertTerminal(
        PosTerminalsTableCompanion.insert(
          id: 'term-1',
          storeId: 'store-1',
          orgId: 'org-1',
          name: 'Terminal 1',
          createdAt: DateTime.now(),
        ),
      );

      await db.posTerminalsDao.updateCurrentShift('term-1', 'shift-1');
      final terminal = await db.posTerminalsDao.getTerminal('term-1');
      expect(terminal!.currentShiftId, 'shift-1');
    });
  });
}
```

## File 4: `test/services/sync/org_sync_service_test.dart`

```dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/services/sync/json_converter.dart';

void main() {
  group('JsonColumnConverter', () {
    final converter = JsonColumnConverter.instance;

    test('identifies JSONB fields', () {
      expect(converter.isJsonbField('roles', 'permissions'), true);
      expect(converter.isJsonbField('roles', 'name'), false);
      expect(converter.isJsonbField('audit_log', 'old_value'), true);
    });

    test('toRemote parses JSON strings to objects', () {
      final local = {'permissions': '{"read": true}', 'name': 'Admin'};
      final remote = converter.toRemote('roles', local);

      expect(remote['permissions'], isA<Map>());
      expect(remote['name'], 'Admin');
    });

    test('toLocal serializes objects to JSON strings', () {
      final remote = {'permissions': {'read': true}, 'name': 'Admin'};
      final local = converter.toLocal('roles', remote);

      expect(local['permissions'], isA<String>());
      expect(local['name'], 'Admin');
    });

    test('round-trip preserves data', () {
      final original = {'items': [1, 2, 3], 'name': 'test'};
      final local = converter.toLocal('held_invoices', original);
      final remote = converter.toRemote('held_invoices', local);

      expect(remote['items'], [1, 2, 3]);
    });

    test('handles invalid JSON gracefully', () {
      final data = {'permissions': 'not-json', 'name': 'test'};
      final result = converter.toRemote('roles', data);
      expect(result['permissions'], 'not-json');
    });

    test('mergeJsonStrings deep merges', () {
      final base = '{"a": 1, "b": {"c": 2}}';
      final override = '{"b": {"d": 3}, "e": 4}';
      final merged = jsonDecode(JsonColumnConverter.mergeJsonStrings(base, override));

      expect(merged['a'], 1);
      expect(merged['b']['c'], 2);
      expect(merged['b']['d'], 3);
      expect(merged['e'], 4);
    });
  });
}
```

## File 5: `test/data/tables/schema_validation_test.dart`

```dart
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/data/local/app_database.dart';

Future<bool> _tableExists(AppDatabase db, String tableName) async {
  final result = await db.customSelect(
    "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
    variables: [Variable.withString(tableName)],
    readsFrom: {},
  ).get();
  return result.isNotEmpty;
}

Future<Set<String>> _getTableColumns(AppDatabase db, String table) async {
  final result = await db.customSelect(
    'PRAGMA table_info($table)', variables: [], readsFrom: {},
  ).get();
  return result.map((r) => r.data['name'] as String).toSet();
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => await db.close());

  group('Schema Validation', () {
    test('all core tables exist', () async {
      for (final table in [
        'products', 'sales', 'sale_items', 'orders', 'order_items',
        'categories', 'customers', 'suppliers', 'users', 'stores',
        'shifts', 'accounts', 'transactions', 'inventory_movements',
        'sync_queue', 'audit_log',
      ]) {
        expect(await _tableExists(db, table), isTrue,
            reason: 'Missing table: $table');
      }
    });

    test('multi-tenant tables exist', () async {
      for (final table in [
        'organizations', 'subscriptions', 'org_members',
        'user_stores', 'pos_terminals',
      ]) {
        expect(await _tableExists(db, table), isTrue,
            reason: 'Missing multi-tenant table: $table');
      }
    });

    test('org_id column exists on required tables', () async {
      for (final table in [
        'products', 'categories', 'customers', 'sales', 'orders',
        'inventory_movements', 'accounts', 'suppliers', 'stores',
        'users', 'shifts', 'audit_log', 'loyalty_points', 'expenses',
        'returns', 'purchases', 'discounts', 'notifications',
        'daily_summaries',
      ]) {
        final columns = await _getTableColumns(db, table);
        expect(columns.contains('org_id'), isTrue,
            reason: 'Table $table missing org_id');
      }
    });

    test('users table has auth_uid and role_id', () async {
      final columns = await _getTableColumns(db, 'users');
      expect(columns.contains('auth_uid'), isTrue);
      expect(columns.contains('role_id'), isTrue);
    });

    test('sales and shifts have terminal_id', () async {
      for (final table in ['sales', 'shifts']) {
        final columns = await _getTableColumns(db, table);
        expect(columns.contains('terminal_id'), isTrue,
            reason: 'Table $table missing terminal_id');
      }
    });
  });
}
```
