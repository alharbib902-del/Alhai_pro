import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_services/alhai_services.dart';

void main() {
  late BackupService backupService;

  setUp(() {
    backupService = BackupService();
  });

  group('BackupService', () {
    test('should be created', () {
      expect(backupService, isNotNull);
    });

    group('createBackup', () {
      test('should create a successful backup', () async {
        final result = await backupService.createBackup(
          storeId: 'store-1',
          data: {'products': [], 'orders': []},
        );

        expect(result.success, isTrue);
        expect(result.backup, isNotNull);
        expect(result.backup!.storeId, equals('store-1'));
        expect(result.backup!.type, equals(BackupType.full));
        expect(result.sizeBytes, isNotNull);
        expect(result.sizeBytes!, greaterThan(0));
      });

      test('should create backup with specific type', () async {
        final result = await backupService.createBackup(
          storeId: 'store-1',
          data: {'products': []},
          type: BackupType.products,
        );

        expect(result.success, isTrue);
        expect(result.backup!.type, equals(BackupType.products));
      });

      test('backup should have valid id', () async {
        final result = await backupService.createBackup(
          storeId: 'store-1',
          data: {},
        );

        expect(result.backup!.id, startsWith('backup_'));
      });

      test('backup should include version', () async {
        final result = await backupService.createBackup(
          storeId: 'store-1',
          data: {},
        );

        expect(result.backup!.version, equals('1.0.0'));
      });
    });

    group('exportToJson', () {
      test('should export backup as JSON string', () {
        final backup = BackupData(
          id: 'backup-1',
          storeId: 'store-1',
          type: BackupType.full,
          data: {'key': 'value'},
          createdAt: DateTime(2026, 3, 15),
          version: '1.0.0',
        );

        final json = backupService.exportToJson(backup);
        final decoded = jsonDecode(json) as Map<String, dynamic>;

        expect(decoded['id'], equals('backup-1'));
        expect(decoded['storeId'], equals('store-1'));
        expect(decoded['type'], equals('full'));
      });
    });

    group('restoreBackup', () {
      test('should restore from valid backup JSON', () async {
        // Create a backup first
        final createResult = await backupService.createBackup(
          storeId: 'store-1',
          data: {
            'products': [1, 2, 3]
          },
        );

        // Export to JSON, then encode as base64 (simulating the backup format)
        final jsonStr = backupService.exportToJson(createResult.backup!);
        final encoded = base64Encode(utf8.encode(jsonStr));

        final result = await backupService.restoreBackup(encoded);

        expect(result.success, isTrue);
        expect(result.backup, isNotNull);
        expect(result.backup!.storeId, equals('store-1'));
      });

      test('should fail for invalid data', () async {
        final result = await backupService.restoreBackup('invalid-data!!!');

        expect(result.success, isFalse);
        expect(result.error, isNotNull);
      });
    });

    group('validateBackup', () {
      test('should validate a correct backup', () async {
        final createResult = await backupService.createBackup(
          storeId: 'store-1',
          data: {'products': []},
        );

        final jsonStr = backupService.exportToJson(createResult.backup!);
        final encoded = base64Encode(utf8.encode(jsonStr));

        final validation = backupService.validateBackup(encoded);

        expect(validation.isValid, isTrue);
        expect(validation.storeId, equals('store-1'));
        expect(validation.version, equals('1.0.0'));
        expect(validation.type, equals(BackupType.full));
      });

      test('should reject invalid backup', () {
        final validation = backupService.validateBackup('not-a-backup');
        expect(validation.isValid, isFalse);
        expect(validation.error, isNotNull);
      });

      test('should reject backup missing required fields', () {
        final incompleteJson = jsonEncode({'someKey': 'value'});
        final encoded = base64Encode(utf8.encode(incompleteJson));

        final validation = backupService.validateBackup(encoded);
        expect(validation.isValid, isFalse);
      });
    });

    group('BackupData', () {
      test('should serialize to and from JSON', () {
        final backup = BackupData(
          id: 'backup-1',
          storeId: 'store-1',
          type: BackupType.orders,
          data: {'order': 'data'},
          createdAt: DateTime(2026, 3, 15),
          version: '1.0.0',
        );

        final json = backup.toJson();
        final restored = BackupData.fromJson(json);

        expect(restored.id, equals(backup.id));
        expect(restored.storeId, equals(backup.storeId));
        expect(restored.type, equals(BackupType.orders));
        expect(restored.version, equals('1.0.0'));
      });
    });

    group('BackupType', () {
      test('should have all expected values', () {
        expect(BackupType.values, contains(BackupType.full));
        expect(BackupType.values, contains(BackupType.products));
        expect(BackupType.values, contains(BackupType.orders));
        expect(BackupType.values, contains(BackupType.customers));
        expect(BackupType.values, contains(BackupType.settings));
      });
    });
  });
}
