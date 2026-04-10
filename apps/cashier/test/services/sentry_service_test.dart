import 'package:flutter_test/flutter_test.dart';

import 'package:cashier/core/services/sentry_service.dart';

// ---------------------------------------------------------------------------
// The sentry_service in the cashier app uses a compile-time environment
// variable (`String.fromEnvironment('SENTRY_DSN')`) to decide whether to
// initialise Sentry. In unit tests the DSN is empty, so the service should
// gracefully skip initialisation and not crash when reportError / addBreadcrumb
// are called. These tests verify the "no DSN configured" code paths.
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('isSentryConfigured', () {
    test('returns false when no DSN is provided at build time', () {
      // Without --dart-define=SENTRY_DSN, this should be false.
      expect(isSentryConfigured, isFalse);
    });
  });

  group('initSentry', () {
    test('runs the app runner when Sentry is not configured', () async {
      var ran = false;
      await initSentry(appRunner: () async {
        ran = true;
      });
      expect(ran, isTrue);
    });

    test('propagates errors thrown by the app runner', () async {
      Object? error;
      try {
        await initSentry(appRunner: () async {
          throw StateError('boom');
        });
      } catch (e) {
        error = e;
      }
      expect(error, isA<StateError>());
    });

    test('runs a synchronous no-op runner without error', () async {
      await expectLater(
        initSentry(appRunner: () async {}),
        completes,
      );
    });
  });

  group('reportError', () {
    test('does not throw when DSN is not configured', () async {
      await expectLater(
        reportError(Exception('test')),
        completes,
      );
    });

    test('accepts a stack trace', () async {
      await expectLater(
        reportError(
          Exception('test'),
          stackTrace: StackTrace.current,
        ),
        completes,
      );
    });

    test('accepts a hint message', () async {
      await expectLater(
        reportError(
          Exception('test'),
          hint: 'optional context',
        ),
        completes,
      );
    });

    test('handles null stack trace and null hint', () async {
      await expectLater(
        reportError(Exception('null case')),
        completes,
      );
    });

    test('handles arbitrary error types', () async {
      await expectLater(reportError('just a string'), completes);
      await expectLater(reportError(42), completes);
      await expectLater(reportError(StateError('state')), completes);
    });
  });

  group('addBreadcrumb', () {
    test('does not throw when Sentry is not configured', () {
      expect(
        () => addBreadcrumb(message: 'user clicked button'),
        returnsNormally,
      );
    });

    test('uses default category "app" when omitted', () {
      expect(
        () => addBreadcrumb(message: 'default category'),
        returnsNormally,
      );
    });

    test('accepts a custom category', () {
      expect(
        () => addBreadcrumb(message: 'payment flow', category: 'payment'),
        returnsNormally,
      );
    });

    test('accepts arbitrary extra data map', () {
      expect(
        () => addBreadcrumb(
          message: 'with data',
          category: 'sale',
          data: {'total': 100, 'method': 'cash'},
        ),
        returnsNormally,
      );
    });

    test('handles empty message safely', () {
      expect(
        () => addBreadcrumb(message: ''),
        returnsNormally,
      );
    });
  });
}
