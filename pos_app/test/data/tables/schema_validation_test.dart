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
    'PRAGMA table_info($table)',
    variables: [],
    readsFrom: {},
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
