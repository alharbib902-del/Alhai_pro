import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_auth/alhai_auth.dart';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late InMemoryStorage storage;
  setUp(() {
    storage = InMemoryStorage();
    SecureStorageService.setStorage(storage);
  });
  tearDown(() {
    SecureStorageService.resetStorage();
  });
  group('ForegroundLockService', () {
    test('backgrounded briefly (< threshold) does not lock on resume', () async {
      // Fixed clock so we can advance deterministically.
      var now = DateTime.utc(2026, 4, 17, 12, 0, 0);
      var lockFired = false;
      final service = ForegroundLockService(
        threshold: const Duration(minutes: 2),
        onLockRequired: () => lockFired = true,
        clock: () => now,
      );
      // Simulate backgrounding.
      service.didChangeAppLifecycleState(AppLifecycleState.paused);
      // Advance only 30 seconds.
      now = now.add(const Duration(seconds: 30));
      // Simulate resume — wait for the async check to run.
      service.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await service.checkOnResumeForTesting();
      expect(lockFired, isFalse,
          reason: 'Should NOT lock when backgrounded < threshold');
    });
    test('backgrounded > threshold fires onLockRequired on resume', () async {
      var now = DateTime.utc(2026, 4, 17, 12, 0, 0);
      var lockFired = false;
      final service = ForegroundLockService(
        threshold: const Duration(minutes: 2),
        onLockRequired: () => lockFired = true,
        clock: () => now,
      );
      // Record background at t=0.
      await service.recordBackgroundedAt();
      // Advance past threshold.
      now = now.add(const Duration(minutes: 3));
      await service.checkOnResumeForTesting();
      expect(lockFired, isTrue,
          reason: 'Should lock when backgrounded >= threshold');
    });
    test('never backgrounded (cold start) does not lock', () async {
      var lockFired = false;
      final service = ForegroundLockService(
        threshold: const Duration(minutes: 2),
        onLockRequired: () => lockFired = true,
        clock: () => DateTime.utc(2026, 4, 17, 12, 0, 0),
      );
      // No recordBackgroundedAt call → storage is empty.
      await service.checkOnResumeForTesting();
      expect(lockFired, isFalse,
          reason: 'Cold start must not trigger lock');
    });
    test('clearBackgroundTimestamp prevents lock on next resume', () async {
      var now = DateTime.utc(2026, 4, 17, 12, 0, 0);
      var lockFired = false;
      final service = ForegroundLockService(
        threshold: const Duration(minutes: 2),
        onLockRequired: () => lockFired = true,
        clock: () => now,
      );
      await service.recordBackgroundedAt();
      // Simulate successful unlock → timestamp cleared.
      await service.clearBackgroundTimestamp();
      // Advance well past threshold.
      now = now.add(const Duration(minutes: 10));
      await service.checkOnResumeForTesting();
      expect(lockFired, isFalse,
          reason: 'Cleared timestamp must suppress lock');
      // Confirm the storage key is actually gone.
      final stored =
          await storage.read(key: kForegroundLockBackgroundAtKey);
      expect(stored, isNull);
    });
  });
}
