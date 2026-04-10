import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:cashier/core/services/backup_manager.dart';

import '../helpers/mock_database.dart';

// ---------------------------------------------------------------------------
// BackupManager export/import requires a real AppDatabase with all 28 tables,
// which is not feasible in a unit test. These tests focus on:
//   - validateBackup (pure JSON parsing, no DB)
//   - BackupBundle / BackupInfo / RestoreReport value semantics
//   - importFromJson error handling for malformed / empty input
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // validateBackup
  // -------------------------------------------------------------------------
  group('validateBackup', () {
    // validateBackup does not touch the database, so we can pass a null-safe
    // BackupManager built with any object. We only exercise validateBackup.
    late BackupManager manager;

    setUp(() {
      // BackupManager is constructed with an AppDatabase, but validateBackup
      // never touches it. We use a MockAppDatabase from the shared helpers.
      manager = BackupManager(MockAppDatabase());
    });

    test('returns BackupInfo for a valid JSON payload', () {
      final jsonStr = jsonEncode({
        'version': '1.0.0',
        'storeId': 'store-1',
        'createdAt': '2026-04-10T10:00:00.000Z',
        'tableCount': 20,
        'totalRows': 500,
        'data': {},
      });

      final info = manager.validateBackup(jsonStr);
      expect(info, isNotNull);
      expect(info!.version, equals('1.0.0'));
      expect(info.storeId, equals('store-1'));
      expect(info.tableCount, equals(20));
      expect(info.totalRows, equals(500));
      expect(info.createdAt, isNotNull);
      expect(info.createdAt!.year, equals(2026));
    });

    test('returns null for malformed JSON', () {
      final info = manager.validateBackup('not valid json at all');
      expect(info, isNull);
    });

    test('returns null for empty string', () {
      final info = manager.validateBackup('');
      expect(info, isNull);
    });

    test('handles missing fields with defaults', () {
      final jsonStr = jsonEncode({'data': {}});
      final info = manager.validateBackup(jsonStr);
      expect(info, isNotNull);
      expect(info!.version, equals('?'));
      expect(info.storeId, equals('?'));
      expect(info.tableCount, equals(0));
      expect(info.totalRows, equals(0));
    });

    test('handles unparseable createdAt as null', () {
      final jsonStr = jsonEncode({
        'version': '1.0.0',
        'createdAt': 'not-a-date',
      });
      final info = manager.validateBackup(jsonStr);
      expect(info, isNotNull);
      expect(info!.createdAt, isNull);
    });

    test('returns null when jsonDecode returns non-object (e.g. array)', () {
      final info = manager.validateBackup('[1,2,3]');
      // jsonDecode succeeds but the cast to Map<String, dynamic> fails.
      expect(info, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // importFromJson error handling
  // -------------------------------------------------------------------------
  group('importFromJson error handling', () {
    late BackupManager manager;

    setUp(() {
      manager = BackupManager(MockAppDatabase());
    });

    test('returns RestoreReport(success=false) for empty data map', () async {
      final jsonStr = jsonEncode({'version': '1.0.0', 'data': {}});
      final report = await manager.importFromJson(jsonStr);

      expect(report.success, isFalse);
      expect(report.error, equals('Empty backup data'));
      expect(report.restoredRows, equals(0));
      expect(report.restoredTables, equals(0));
    });

    test('returns RestoreReport(success=false) for missing data key', () async {
      final jsonStr = jsonEncode({'version': '1.0.0'});
      final report = await manager.importFromJson(jsonStr);

      expect(report.success, isFalse);
    });

    test('returns RestoreReport(success=false) for malformed JSON', () async {
      final report = await manager.importFromJson('not json');
      expect(report.success, isFalse);
      // The error message should be set
      expect(report.error, isNotNull);
      expect(report.error!.isNotEmpty, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // BackupBundle value class
  // -------------------------------------------------------------------------
  group('BackupBundle', () {
    test('stores all fields', () {
      final bundle = BackupBundle(
        jsonString: '{}',
        totalRows: 100,
        tableCount: 5,
        sizeBytes: 2048,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(bundle.jsonString, equals('{}'));
      expect(bundle.totalRows, equals(100));
      expect(bundle.tableCount, equals(5));
      expect(bundle.sizeBytes, equals(2048));
      expect(bundle.createdAt.year, equals(2026));
    });

    test('sizeMb correctly converts bytes to megabytes', () {
      final bundle = BackupBundle(
        jsonString: '{}',
        totalRows: 0,
        tableCount: 0,
        sizeBytes: 1024 * 1024, // exactly 1 MB
        createdAt: DateTime.now(),
      );
      expect(bundle.sizeMb, equals(1.0));
    });

    test('sizeMb = 0 for empty bundle', () {
      final bundle = BackupBundle(
        jsonString: '',
        totalRows: 0,
        tableCount: 0,
        sizeBytes: 0,
        createdAt: DateTime.now(),
      );
      expect(bundle.sizeMb, equals(0));
    });

    test('sizeMb = 0.5 for 512 KB', () {
      final bundle = BackupBundle(
        jsonString: '',
        totalRows: 0,
        tableCount: 0,
        sizeBytes: 512 * 1024,
        createdAt: DateTime.now(),
      );
      expect(bundle.sizeMb, equals(0.5));
    });
  });

  // -------------------------------------------------------------------------
  // BackupInfo value class
  // -------------------------------------------------------------------------
  group('BackupInfo', () {
    test('constructor stores all fields', () {
      final info = BackupInfo(
        version: '2.0.0',
        storeId: 'store-42',
        createdAt: DateTime(2026, 4, 10),
        tableCount: 30,
        totalRows: 1000,
      );
      expect(info.version, equals('2.0.0'));
      expect(info.storeId, equals('store-42'));
      expect(info.createdAt, isNotNull);
      expect(info.tableCount, equals(30));
      expect(info.totalRows, equals(1000));
    });

    test('allows null createdAt', () {
      const info = BackupInfo(
        version: '1.0.0',
        storeId: 's',
        tableCount: 0,
        totalRows: 0,
      );
      expect(info.createdAt, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // RestoreReport value class
  // -------------------------------------------------------------------------
  group('RestoreReport', () {
    test('success defaults have zero rows / tables', () {
      const report = RestoreReport(success: true);
      expect(report.success, isTrue);
      expect(report.error, isNull);
      expect(report.restoredRows, equals(0));
      expect(report.restoredTables, equals(0));
    });

    test('failure stores error message', () {
      const report = RestoreReport(success: false, error: 'db locked');
      expect(report.success, isFalse);
      expect(report.error, equals('db locked'));
    });

    test('success with stats captures row and table count', () {
      const report = RestoreReport(
        success: true,
        restoredRows: 250,
        restoredTables: 12,
      );
      expect(report.restoredRows, equals(250));
      expect(report.restoredTables, equals(12));
    });
  });
}
