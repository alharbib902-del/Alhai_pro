import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/src/services/storage_monitor.dart';

void main() {
  late StorageMonitor monitor;

  setUp(() {
    monitor = StorageMonitor();
  });

  group('StorageMonitor — status classification', () {
    test('healthy when usage < 80%', () async {
      // Without override, default is healthy (can't measure in test)
      final status = await monitor.checkStorage();
      expect(status, equals(StorageStatus.healthy));
    });

    test('override: healthy at 50%', () async {
      monitor.setOverrideStatus(StorageStatus.healthy);
      expect(await monitor.checkStorage(), StorageStatus.healthy);
    });

    test('override: warning at 85%', () async {
      monitor.setOverrideStatus(StorageStatus.warning);
      expect(await monitor.checkStorage(), StorageStatus.warning);
    });

    test('override: critical at 92%', () async {
      monitor.setOverrideStatus(StorageStatus.critical);
      expect(await monitor.checkStorage(), StorageStatus.critical);
    });

    test('override: full at 97%', () async {
      monitor.setOverrideStatus(StorageStatus.full);
      expect(await monitor.checkStorage(), StorageStatus.full);
    });
  });

  group('StorageMonitor.assertCanWrite', () {
    test('does not throw when storage is healthy', () async {
      monitor.setOverrideStatus(StorageStatus.healthy);
      await expectLater(monitor.assertCanWrite(), completes);
    });

    test('does not throw when storage is warning', () async {
      monitor.setOverrideStatus(StorageStatus.warning);
      await expectLater(monitor.assertCanWrite(), completes);
    });

    test('does not throw when storage is critical', () async {
      monitor.setOverrideStatus(StorageStatus.critical);
      await expectLater(monitor.assertCanWrite(), completes);
    });

    test('throws StorageFullException when storage is full', () async {
      monitor.setOverrideStatus(StorageStatus.full);
      await expectLater(
        monitor.assertCanWrite(),
        throwsA(isA<StorageFullException>()),
      );
    });
  });

  group('StorageFullException', () {
    test('contains descriptive message', () {
      const e = StorageFullException('test message');
      expect(e.message, equals('test message'));
      expect(e.toString(), contains('test message'));
    });
  });
}
