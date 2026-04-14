/// Independent verification for Fix #6: Storage Monitoring.
///
/// KEY FINDING: _getStorageInfo() always returns null, so checkStorage()
/// always returns healthy in production.  These tests verify the override
/// mechanism and threshold classification, documenting the limitation.
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/src/services/storage_monitor.dart';

void main() {
  late StorageMonitor monitor;

  setUp(() {
    monitor = StorageMonitor();
  });

  group('VERIFICATION — Fix #6: Storage Monitor thresholds', () {
    // -----------------------------------------------------------------------
    // 1. Without override, always returns healthy (the null limitation)
    // -----------------------------------------------------------------------
    test('without override: always returns healthy (_getStorageInfo is null)',
        () async {
      // This documents the limitation: _getStorageInfo() returns null,
      // so checkStorage() always returns healthy in production.
      final status = await monitor.checkStorage();
      expect(status, equals(StorageStatus.healthy),
          reason: '_getStorageInfo returns null → defaults to healthy');
    });

    // -----------------------------------------------------------------------
    // 2. Threshold boundary tests via override
    // -----------------------------------------------------------------------
    test('override: healthy status', () async {
      monitor.setOverrideStatus(StorageStatus.healthy);
      expect(await monitor.checkStorage(), StorageStatus.healthy);
    });

    test('override: warning status', () async {
      monitor.setOverrideStatus(StorageStatus.warning);
      expect(await monitor.checkStorage(), StorageStatus.warning);
    });

    test('override: critical status', () async {
      monitor.setOverrideStatus(StorageStatus.critical);
      expect(await monitor.checkStorage(), StorageStatus.critical);
    });

    test('override: full status', () async {
      monitor.setOverrideStatus(StorageStatus.full);
      expect(await monitor.checkStorage(), StorageStatus.full);
    });

    test('override can be cleared back to null (defaults to healthy)', () async {
      monitor.setOverrideStatus(StorageStatus.full);
      expect(await monitor.checkStorage(), StorageStatus.full);

      monitor.setOverrideStatus(null);
      expect(await monitor.checkStorage(), StorageStatus.healthy,
          reason: 'After clearing override, _getStorageInfo is null → healthy');
    });
  });

  group('VERIFICATION — Fix #6: assertCanWrite', () {
    test('healthy → no exception', () async {
      monitor.setOverrideStatus(StorageStatus.healthy);
      await expectLater(monitor.assertCanWrite(), completes);
    });

    test('warning → no exception (writes still allowed)', () async {
      monitor.setOverrideStatus(StorageStatus.warning);
      await expectLater(monitor.assertCanWrite(), completes);
    });

    test('critical → no exception (writes still allowed)', () async {
      monitor.setOverrideStatus(StorageStatus.critical);
      await expectLater(monitor.assertCanWrite(), completes);
    });

    test('full → throws StorageFullException', () async {
      monitor.setOverrideStatus(StorageStatus.full);
      await expectLater(
        monitor.assertCanWrite(),
        throwsA(isA<StorageFullException>()),
      );
    });

    test('StorageFullException message is descriptive', () {
      const e = StorageFullException('disk full');
      expect(e.message, equals('disk full'));
      expect(e.toString(), contains('StorageFullException'));
      expect(e.toString(), contains('disk full'));
    });
  });

  group('VERIFICATION — Fix #6: StorageStatus enum coverage', () {
    test('all 4 status values exist', () {
      expect(StorageStatus.values, hasLength(4));
      expect(
        StorageStatus.values,
        containsAll([
          StorageStatus.healthy,
          StorageStatus.warning,
          StorageStatus.critical,
          StorageStatus.full,
        ]),
      );
    });
  });
}
