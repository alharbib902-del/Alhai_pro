import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_sync/src/sync_table_validator.dart';

void main() {
  group('allowedSyncTables', () {
    test('contains all expected core tables', () {
      expect(allowedSyncTables, contains('products'));
      expect(allowedSyncTables, contains('sales'));
      expect(allowedSyncTables, contains('orders'));
      expect(allowedSyncTables, contains('customers'));
      expect(allowedSyncTables, contains('categories'));
      expect(allowedSyncTables, contains('suppliers'));
      expect(allowedSyncTables, contains('stores'));
      expect(allowedSyncTables, contains('users'));
    });

    test('contains financial tables', () {
      expect(allowedSyncTables, contains('accounts'));
      expect(allowedSyncTables, contains('transactions'));
      expect(allowedSyncTables, contains('expenses'));
    });

    test('contains sync-related tables', () {
      expect(allowedSyncTables, contains('inventory_movements'));
      expect(allowedSyncTables, contains('daily_summaries'));
      expect(allowedSyncTables, contains('shifts'));
    });

    test('does not contain dangerous tables', () {
      expect(allowedSyncTables, isNot(contains('pg_catalog')));
      expect(allowedSyncTables, isNot(contains('information_schema')));
      expect(allowedSyncTables, isNot(contains('auth.users')));
    });
  });

  group('validateTableName', () {
    test('accepts valid table names', () {
      expect(() => validateTableName('products'), returnsNormally);
      expect(() => validateTableName('sales'), returnsNormally);
      expect(() => validateTableName('orders'), returnsNormally);
      expect(() => validateTableName('categories'), returnsNormally);
    });

    test('throws ArgumentError for invalid table names', () {
      expect(
        () => validateTableName('malicious_table'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws for SQL injection attempts', () {
      expect(
        () => validateTableName('products; DROP TABLE users;'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => validateTableName("products' OR '1'='1"),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => validateTableName('products UNION SELECT * FROM users'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws for empty string', () {
      expect(
        () => validateTableName(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('is case-sensitive (SQL table names are lowercase)', () {
      expect(
        () => validateTableName('Products'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => validateTableName('SALES'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
