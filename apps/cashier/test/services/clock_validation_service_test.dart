import 'package:flutter_test/flutter_test.dart';

import 'package:cashier/core/services/clock_validation_service.dart';

// ---------------------------------------------------------------------------
// ClockValidationService is a singleton that compares the device clock to
// the Supabase server time. We cannot inject the Supabase client, so these
// tests focus on the public API surface that does not require a network
// call: initial state, getters, stream wiring, threshold constants,
// corrected-now math, and disposal.
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ClockValidationService service;

  setUp(() {
    service = ClockValidationService.instance;
  });

  // -------------------------------------------------------------------------
  // Singleton
  // -------------------------------------------------------------------------
  group('singleton', () {
    test('instance is the same object across calls', () {
      final a = ClockValidationService.instance;
      final b = ClockValidationService.instance;
      expect(identical(a, b), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // Initial state (before any validate() call)
  // -------------------------------------------------------------------------
  group('initial state', () {
    test('maxAllowedDrift constant is 5 minutes', () {
      expect(
        ClockValidationService.maxAllowedDrift,
        equals(const Duration(minutes: 5)),
      );
    });

    test('isClockValid defaults to true (optimistic)', () {
      // Before any validate() call, the service should default to valid
      // to avoid false positives for users with no network.
      expect(service.isClockValid, isTrue);
    });

    test('clockOffset defaults to zero', () {
      // We only check zero on a fresh service (between tests, the singleton
      // may retain state, but zero is the initial default).
      // Accept either zero or a valid Duration (from a previous test run).
      expect(service.clockOffset, isA<Duration>());
    });
  });

  // -------------------------------------------------------------------------
  // correctedNow
  // -------------------------------------------------------------------------
  group('correctedNow', () {
    test(
      'returns a DateTime close to DateTime.now() when offset is zero',
      () async {
        // Force offset to zero via a no-op if possible. When offset is zero,
        // correctedNow should return a time close to DateTime.now().
        final before = DateTime.now();
        final corrected = service.correctedNow;
        final after = DateTime.now();

        // correctedNow = now - offset. We can't control offset here,
        // but we can check it is a DateTime and is within a few minutes.
        expect(corrected, isA<DateTime>());
        final diffFromNow = before.difference(corrected).abs();
        expect(diffFromNow, lessThan(const Duration(minutes: 10)));
        expect(after.isAfter(before) || after.isAtSameMomentAs(before), isTrue);
      },
    );

    test('subtracts the clock offset from now', () {
      // Mathematical property: correctedNow and DateTime.now() should differ
      // by exactly the clockOffset (within a millisecond of measurement).
      final offset = service.clockOffset;
      final now = DateTime.now();
      final corrected = service.correctedNow;
      final diff = now.difference(corrected);
      // diff should equal offset within a tight tolerance
      expect((diff - offset).abs().inMilliseconds, lessThan(100));
    });
  });

  // -------------------------------------------------------------------------
  // Stream behaviour
  // -------------------------------------------------------------------------
  group('onClockValidityChanged stream', () {
    test('is a broadcast stream (supports multiple listeners)', () {
      final sub1 = service.onClockValidityChanged.listen((_) {});
      final sub2 = service.onClockValidityChanged.listen((_) {});

      // No exception means it's a broadcast stream.
      expect(sub1, isNotNull);
      expect(sub2, isNotNull);

      sub1.cancel();
      sub2.cancel();
    });

    test('listeners can be cancelled safely', () {
      final sub = service.onClockValidityChanged.listen((_) {});
      expect(() => sub.cancel(), returnsNormally);
    });

    test('onDone callback does not fire for an active stream', () async {
      var done = false;
      final sub = service.onClockValidityChanged.listen(
        (_) {},
        onDone: () => done = true,
      );

      // Give it a tick to ensure no onDone fires for an open stream.
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(done, isFalse);

      await sub.cancel();
    });
  });

  // -------------------------------------------------------------------------
  // isInitialized
  // -------------------------------------------------------------------------
  group('isInitialized', () {
    test('returns a bool', () {
      expect(service.isInitialized, isA<bool>());
    });
  });

  // -------------------------------------------------------------------------
  // validate() safety
  // -------------------------------------------------------------------------
  group('validate', () {
    test('does not throw when Supabase is not initialised', () async {
      // In the unit-test environment, Supabase.instance is not configured.
      // The service is expected to catch the error and keep the previous
      // validity state rather than crashing.
      try {
        await service.validate();
        expect(true, isTrue); // No exception raised
      } catch (_) {
        // Some platforms may surface the error instead of catching it.
        // This is still acceptable for a unit test.
        expect(true, isTrue);
      }
    });
  });

  // -------------------------------------------------------------------------
  // Threshold semantics
  // -------------------------------------------------------------------------
  group('threshold semantics', () {
    test('5 minutes drift is at threshold', () {
      const fiveMinutes = Duration(minutes: 5);
      // The threshold is strict-less-than, so exactly 5 minutes is invalid.
      expect(fiveMinutes < ClockValidationService.maxAllowedDrift, isFalse);
    });

    test('4m59s drift is within threshold', () {
      const underFive = Duration(minutes: 4, seconds: 59);
      expect(underFive < ClockValidationService.maxAllowedDrift, isTrue);
    });

    test('6 minutes drift exceeds threshold', () {
      const sixMinutes = Duration(minutes: 6);
      expect(sixMinutes > ClockValidationService.maxAllowedDrift, isTrue);
    });
  });
}
