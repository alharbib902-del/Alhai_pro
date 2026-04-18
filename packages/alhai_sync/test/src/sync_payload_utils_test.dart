import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_sync/src/sync_payload_utils.dart';

void main() {
  group('cleanSyncPayload', () {
    test('removes syncedAt (camelCase)', () {
      final payload = {
        'id': 'p-1',
        'name': 'Product',
        'syncedAt': '2026-01-01',
      };

      final cleaned = cleanSyncPayload(payload);

      expect(cleaned.containsKey('syncedAt'), isFalse);
      expect(cleaned['id'], 'p-1');
      expect(cleaned['name'], 'Product');
    });

    test('removes synced_at (snake_case)', () {
      final payload = {'id': 'p-1', 'synced_at': '2026-01-01'};

      final cleaned = cleanSyncPayload(payload);

      expect(cleaned.containsKey('synced_at'), isFalse);
    });

    test('removes items by default', () {
      final payload = {
        'id': 'sale-1',
        'total': 100.0,
        'items': [
          {'product_id': 'p-1'},
        ],
      };

      final cleaned = cleanSyncPayload(payload);

      expect(cleaned.containsKey('items'), isFalse);
    });

    test('keeps items when removeItems is false', () {
      final payload = {
        'id': 'sale-1',
        'items': [
          {'product_id': 'p-1'},
        ],
      };

      final cleaned = cleanSyncPayload(payload, removeItems: false);

      expect(cleaned.containsKey('items'), isTrue);
    });

    test('preserves shift_id and deleted_at for sales (Supabase v44)', () {
      // After v44 migration these columns exist in Supabase; they must
      // NOT be stripped or the server would miss them on push.
      final payload = {
        'id': 'sale-1',
        'total': 100.0,
        'shift_id': 'shift-1',
        'shiftId': 'shift-1',
        'deleted_at': '2026-01-01',
      };

      final cleaned = cleanSyncPayload(payload, tableName: 'sales');

      expect(cleaned['shift_id'], 'shift-1');
      expect(cleaned['shiftId'], 'shift-1');
      expect(cleaned['deleted_at'], '2026-01-01');
      expect(cleaned['id'], 'sale-1');
      expect(cleaned['total'], 100.0);
    });

    test('does not strip columns for tables without local-only config', () {
      final payload = {'id': 'p-1', 'name': 'Product', 'extra_field': 'value'};

      final cleaned = cleanSyncPayload(payload, tableName: 'products');

      expect(cleaned['extra_field'], 'value');
    });

    test('does not modify original map', () {
      final payload = {'id': 'p-1', 'syncedAt': '2026-01-01'};

      cleanSyncPayload(payload);

      expect(payload.containsKey('syncedAt'), isTrue);
    });
  });

  group('toSnakeCase', () {
    test('converts camelCase keys to snake_case', () {
      final map = {
        'storeId': 'store-1',
        'invoiceNumber': 'INV-001',
        'createdAt': '2026-01-01',
      };

      final result = toSnakeCase(map);

      expect(result.containsKey('store_id'), isTrue);
      expect(result.containsKey('invoice_number'), isTrue);
      expect(result.containsKey('created_at'), isTrue);
    });

    test('preserves already snake_case keys', () {
      final map = {'store_id': 'store-1', 'name': 'Test'};

      final result = toSnakeCase(map);

      expect(result['store_id'], 'store-1');
      expect(result['name'], 'Test');
    });

    test('preserves values unchanged', () {
      final map = {'storeId': 'store-1', 'total': 100.5, 'isActive': true};

      final result = toSnakeCase(map);

      expect(result['store_id'], 'store-1');
      expect(result['total'], 100.5);
      expect(result['is_active'], true);
    });

    test('converts nested maps recursively', () {
      final map = {
        'storeId': 'store-1',
        'metadata': <String, dynamic>{
          'createdBy': 'user-1',
          'lastModified': '2026-01-01',
        },
      };

      final result = toSnakeCase(map);

      expect(result['metadata'], isA<Map<String, dynamic>>());
      final nested = result['metadata'] as Map<String, dynamic>;
      expect(nested.containsKey('created_by'), isTrue);
      expect(nested.containsKey('last_modified'), isTrue);
    });
  });

  group('mapColumnsToRemote', () {
    test('passes through when no renames configured', () {
      final payload = {'id': 'p-1', 'name': 'Product', 'store_id': 'store-1'};

      final result = mapColumnsToRemote('products', payload);

      expect(result, equals(payload));
    });

    test('passes through for unknown table', () {
      final payload = {'id': 'x-1', 'field': 'value'};

      final result = mapColumnsToRemote('unknown_table', payload);

      expect(result, equals(payload));
    });
  });

  group('mapColumnsToLocal', () {
    test('passes through when no renames configured', () {
      final payload = {'id': 'p-1', 'name': 'Product', 'store_id': 'store-1'};

      final result = mapColumnsToLocal('products', payload);

      expect(result, equals(payload));
    });

    test('passes through for unknown table', () {
      final payload = {'id': 'x-1', 'field': 'value'};

      final result = mapColumnsToLocal('unknown_table', payload);

      expect(result, equals(payload));
    });
  });

  group('batchMapColumnsToRemote', () {
    test('maps all records in the list', () {
      final records = [
        {'id': 'p-1', 'name': 'A'},
        {'id': 'p-2', 'name': 'B'},
      ];

      final result = batchMapColumnsToRemote('products', records);

      expect(result, hasLength(2));
      expect(result[0]['id'], 'p-1');
      expect(result[1]['id'], 'p-2');
    });

    test('handles empty list', () {
      final result = batchMapColumnsToRemote(
        'products',
        <Map<String, dynamic>>[],
      );
      expect(result, isEmpty);
    });
  });

  group('batchMapColumnsToLocal', () {
    test('maps all records in the list', () {
      final records = [
        {'id': 'p-1', 'store_id': 'store-1'},
        {'id': 'p-2', 'store_id': 'store-2'},
      ];

      final result = batchMapColumnsToLocal('products', records);

      expect(result, hasLength(2));
      expect(result[0]['store_id'], 'store-1');
      expect(result[1]['store_id'], 'store-2');
    });

    test('handles empty list', () {
      final result = batchMapColumnsToLocal(
        'products',
        <Map<String, dynamic>>[],
      );
      expect(result, isEmpty);
    });
  });
}
