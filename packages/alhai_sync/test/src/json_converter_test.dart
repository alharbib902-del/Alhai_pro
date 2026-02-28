import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_sync/src/json_converter.dart';

void main() {
  late JsonColumnConverter converter;

  setUp(() {
    converter = JsonColumnConverter.instance;
  });

  group('JsonColumnConverter', () {
    group('isJsonbField', () {
      test('returns true for known JSONB fields', () {
        expect(converter.isJsonbField('roles', 'permissions'), isTrue);
        expect(converter.isJsonbField('sync_queue', 'payload'), isTrue);
        expect(converter.isJsonbField('audit_log', 'old_value'), isTrue);
        expect(converter.isJsonbField('audit_log', 'new_value'), isTrue);
        expect(converter.isJsonbField('discounts', 'product_ids'), isTrue);
        expect(converter.isJsonbField('discounts', 'category_ids'), isTrue);
        expect(converter.isJsonbField('notifications', 'data'), isTrue);
        expect(converter.isJsonbField('held_invoices', 'items'), isTrue);
        expect(converter.isJsonbField('stock_takes', 'items'), isTrue);
        expect(converter.isJsonbField('stock_transfers', 'items'), isTrue);
        expect(converter.isJsonbField('promotions', 'rules'), isTrue);
        expect(converter.isJsonbField('organizations', 'settings'), isTrue);
        expect(converter.isJsonbField('subscriptions', 'features'), isTrue);
        expect(converter.isJsonbField('pos_terminals', 'settings'), isTrue);
      });

      test('returns false for non-JSONB fields', () {
        expect(converter.isJsonbField('roles', 'name'), isFalse);
        expect(converter.isJsonbField('products', 'name'), isFalse);
        expect(converter.isJsonbField('sales', 'total'), isFalse);
      });

      test('returns false for unknown tables', () {
        expect(converter.isJsonbField('unknown_table', 'field'), isFalse);
        expect(converter.isJsonbField('', 'field'), isFalse);
      });
    });

    group('getJsonbFields', () {
      test('returns correct fields for known tables', () {
        expect(converter.getJsonbFields('roles'), {'permissions'});
        expect(converter.getJsonbFields('audit_log'), {'old_value', 'new_value'});
        expect(
            converter.getJsonbFields('discounts'), {'product_ids', 'category_ids'});
      });

      test('returns empty set for unknown tables', () {
        expect(converter.getJsonbFields('unknown_table'), isEmpty);
      });
    });

    group('toRemote', () {
      test('parses JSON strings into objects for JSONB fields', () {
        final payload = {
          'id': 'role-1',
          'name': 'admin',
          'permissions': '["read","write","delete"]',
        };

        final result = converter.toRemote('roles', payload);

        expect(result['id'], 'role-1');
        expect(result['name'], 'admin');
        expect(result['permissions'], isA<List>());
        expect(result['permissions'], ['read', 'write', 'delete']);
      });

      test('parses JSON map strings into objects', () {
        final payload = {
          'id': 'org-1',
          'settings': '{"theme":"dark","lang":"ar"}',
        };

        final result = converter.toRemote('organizations', payload);

        expect(result['settings'], isA<Map>());
        expect(result['settings']['theme'], 'dark');
      });

      test('leaves non-JSONB fields unchanged', () {
        final payload = {
          'id': 'product-1',
          'name': 'Test Product',
          'price': 10.5,
        };

        final result = converter.toRemote('products', payload);

        expect(result, equals(payload));
      });

      test('leaves non-JSON string JSONB fields unchanged', () {
        final payload = {
          'id': 'role-1',
          'permissions': 'not-json-string',
        };

        final result = converter.toRemote('roles', payload);

        // non-decodable strings stay as-is since _parseJsonString returns them
        expect(result['permissions'], 'not-json-string');
      });

      test('handles empty JSON string in JSONB field', () {
        final payload = {
          'id': 'role-1',
          'permissions': '',
        };

        final result = converter.toRemote('roles', payload);

        expect(result['permissions'], '');
      });

      test('handles JSONB field with non-string value (already an object)', () {
        final payload = {
          'id': 'role-1',
          'permissions': ['read', 'write'],
        };

        final result = converter.toRemote('roles', payload);

        // Already a list, not a string, so no conversion
        expect(result['permissions'], ['read', 'write']);
      });
    });

    group('toLocal', () {
      test('serializes objects to JSON strings for JSONB fields', () {
        final payload = {
          'id': 'role-1',
          'name': 'admin',
          'permissions': ['read', 'write', 'delete'],
        };

        final result = converter.toLocal('roles', payload);

        expect(result['id'], 'role-1');
        expect(result['name'], 'admin');
        expect(result['permissions'], isA<String>());
        final decoded = jsonDecode(result['permissions'] as String);
        expect(decoded, ['read', 'write', 'delete']);
      });

      test('serializes map objects to JSON strings', () {
        final payload = {
          'id': 'org-1',
          'settings': {'theme': 'dark', 'lang': 'ar'},
        };

        final result = converter.toLocal('organizations', payload);

        expect(result['settings'], isA<String>());
        final decoded =
            jsonDecode(result['settings'] as String) as Map<String, dynamic>;
        expect(decoded['theme'], 'dark');
      });

      test('leaves non-JSONB fields unchanged', () {
        final payload = {
          'id': 'product-1',
          'name': 'Test Product',
        };

        final result = converter.toLocal('products', payload);

        expect(result, equals(payload));
      });

      test('leaves null JSONB fields as null', () {
        final payload = {
          'id': 'role-1',
          'permissions': null,
        };

        final result = converter.toLocal('roles', payload);

        expect(result['permissions'], isNull);
      });

      test('leaves string JSONB fields as strings', () {
        final payload = {
          'id': 'role-1',
          'permissions': '["read"]',
        };

        final result = converter.toLocal('roles', payload);

        // Already a string, _toJsonString returns it as-is
        expect(result['permissions'], '["read"]');
      });
    });

    group('batchToLocal', () {
      test('converts a list of records', () {
        final records = [
          {
            'id': 'role-1',
            'permissions': ['read'],
          },
          {
            'id': 'role-2',
            'permissions': ['write'],
          },
        ];

        final result = converter.batchToLocal('roles', records);

        expect(result, hasLength(2));
        expect(result[0]['permissions'], isA<String>());
        expect(result[1]['permissions'], isA<String>());
      });

      test('handles empty list', () {
        final result = converter.batchToLocal('roles', []);
        expect(result, isEmpty);
      });
    });

    group('batchToRemote', () {
      test('converts a list of records', () {
        final records = [
          {
            'id': 'role-1',
            'permissions': '["read"]',
          },
          {
            'id': 'role-2',
            'permissions': '["write"]',
          },
        ];

        final result = converter.batchToRemote('roles', records);

        expect(result, hasLength(2));
        expect(result[0]['permissions'], isA<List>());
        expect(result[1]['permissions'], isA<List>());
      });
    });

    group('isValidJson', () {
      test('returns true for valid JSON', () {
        expect(JsonColumnConverter.isValidJson('{"key":"value"}'), isTrue);
        expect(JsonColumnConverter.isValidJson('["a","b"]'), isTrue);
        expect(JsonColumnConverter.isValidJson('"hello"'), isTrue);
        expect(JsonColumnConverter.isValidJson('123'), isTrue);
        expect(JsonColumnConverter.isValidJson('true'), isTrue);
        expect(JsonColumnConverter.isValidJson('null'), isTrue);
      });

      test('returns false for invalid JSON', () {
        expect(JsonColumnConverter.isValidJson('{invalid}'), isFalse);
        expect(JsonColumnConverter.isValidJson(''), isFalse);
        expect(JsonColumnConverter.isValidJson('{'), isFalse);
        expect(JsonColumnConverter.isValidJson('hello world'), isFalse);
      });
    });

    group('mergeJsonStrings', () {
      test('merges two JSON objects', () {
        const base = '{"a":1,"b":2}';
        const override = '{"b":3,"c":4}';

        final result = JsonColumnConverter.mergeJsonStrings(base, override);
        final decoded = jsonDecode(result) as Map<String, dynamic>;

        expect(decoded['a'], 1);
        expect(decoded['b'], 3); // override wins
        expect(decoded['c'], 4);
      });

      test('performs deep merge for nested objects', () {
        const base = '{"settings":{"theme":"light","lang":"en"}}';
        const override = '{"settings":{"theme":"dark"}}';

        final result = JsonColumnConverter.mergeJsonStrings(base, override);
        final decoded = jsonDecode(result) as Map<String, dynamic>;
        final settings = decoded['settings'] as Map<String, dynamic>;

        expect(settings['theme'], 'dark'); // overridden
        expect(settings['lang'], 'en'); // preserved from base
      });

      test('returns override when base is not a map', () {
        const base = '["a","b"]';
        const override = '{"key":"value"}';

        final result = JsonColumnConverter.mergeJsonStrings(base, override);

        expect(result, override);
      });

      test('returns override when inputs are invalid JSON', () {
        const base = 'invalid';
        const override = 'also_invalid';

        final result = JsonColumnConverter.mergeJsonStrings(base, override);

        expect(result, override);
      });
    });

    group('normalizeJson', () {
      test('sorts keys alphabetically', () {
        const input = '{"z":1,"a":2,"m":3}';

        final result = JsonColumnConverter.normalizeJson(input);
        final decoded = jsonDecode(result) as Map<String, dynamic>;
        final keys = decoded.keys.toList();

        expect(keys, ['a', 'm', 'z']);
      });

      test('sorts nested keys recursively', () {
        const input = '{"b":{"z":1,"a":2},"a":3}';

        final result = JsonColumnConverter.normalizeJson(input);
        final decoded = jsonDecode(result) as Map<String, dynamic>;
        final outerKeys = decoded.keys.toList();
        final innerKeys =
            (decoded['b'] as Map<String, dynamic>).keys.toList();

        expect(outerKeys, ['a', 'b']);
        expect(innerKeys, ['a', 'z']);
      });

      test('handles arrays', () {
        const input = '{"items":[{"z":1,"a":2},{"b":3}]}';

        final result = JsonColumnConverter.normalizeJson(input);
        final decoded = jsonDecode(result) as Map<String, dynamic>;
        final items = decoded['items'] as List;
        final firstItem = items[0] as Map<String, dynamic>;

        expect(firstItem.keys.toList(), ['a', 'z']);
      });

      test('returns input for invalid JSON', () {
        const input = 'not-json';

        final result = JsonColumnConverter.normalizeJson(input);

        expect(result, input);
      });
    });
  });
}
