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
      final remote = {
        'permissions': {'read': true},
        'name': 'Admin',
      };
      final local = converter.toLocal('roles', remote);

      expect(local['permissions'], isA<String>());
      expect(local['name'], 'Admin');
    });

    test('round-trip preserves data', () {
      final original = {
        'items': [1, 2, 3],
        'name': 'test',
      };
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
      final merged =
          jsonDecode(JsonColumnConverter.mergeJsonStrings(base, override));

      expect(merged['a'], 1);
      expect(merged['b']['c'], 2);
      expect(merged['b']['d'], 3);
      expect(merged['e'], 4);
    });
  });
}
