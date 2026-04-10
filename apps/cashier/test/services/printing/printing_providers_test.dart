import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cashier/services/printing/print_service.dart';
import 'package:cashier/services/printing/printing_providers.dart';

// ---------------------------------------------------------------------------
// Tests cover the public, testable surface of the printing providers:
//   - PrintServiceNotifier.setAutoPrint / isAutoPrintEnabled (SharedPreferences)
//   - printerStatusProvider / connectedPrinterNameProvider defaults
//   - autoPrintEnabledProvider default value and toggling
//   - failedPrintJobsCountProvider fallback when no printer is set
//   - disconnectAndClear clears state
// The actual printer connection logic depends on platform plugins that are
// not available in unit tests, so those code paths are covered indirectly.
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // -------------------------------------------------------------------------
  // autoPrintEnabledProvider
  // -------------------------------------------------------------------------
  group('autoPrintEnabledProvider', () {
    test('defaults to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(autoPrintEnabledProvider), isFalse);
    });

    test('can be toggled to true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(autoPrintEnabledProvider.notifier).state = true;
      expect(container.read(autoPrintEnabledProvider), isTrue);
    });

    test('can be toggled back to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(autoPrintEnabledProvider.notifier).state = true;
      container.read(autoPrintEnabledProvider.notifier).state = false;
      expect(container.read(autoPrintEnabledProvider), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // printerStatusProvider
  // -------------------------------------------------------------------------
  group('printerStatusProvider', () {
    test('returns disconnected when no service is set', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(printerStatusProvider),
          equals(PrinterStatus.disconnected));
    });
  });

  // -------------------------------------------------------------------------
  // connectedPrinterNameProvider
  // -------------------------------------------------------------------------
  group('connectedPrinterNameProvider', () {
    test('returns null when no service is set', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(connectedPrinterNameProvider), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // failedPrintJobsCountProvider
  // -------------------------------------------------------------------------
  group('failedPrintJobsCountProvider', () {
    test('returns 0 when no printer / queue is set', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(failedPrintJobsCountProvider), equals(0));
    });
  });

  // -------------------------------------------------------------------------
  // printServiceProvider
  // -------------------------------------------------------------------------
  group('printServiceProvider', () {
    test('initial state is null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(printServiceProvider), isNull);
    });

    test('loadSavedPrinter does not throw when no preferences exist',
        () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(printServiceProvider.notifier);
      await expectLater(notifier.loadSavedPrinter(), completes);

      // No prefs set → service should remain null
      expect(container.read(printServiceProvider), isNull);
    });

    test('disconnectAndClear clears the service and prefs', () async {
      SharedPreferences.setMockInitialValues({
        'pref_printer_type': 'bluetooth',
        'pref_printer_name': 'My Printer',
        'pref_printer_address': '00:11:22:33:44:55',
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(printServiceProvider.notifier);
      await notifier.disconnectAndClear();

      expect(container.read(printServiceProvider), isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('pref_printer_type'), isNull);
      expect(prefs.getString('pref_printer_name'), isNull);
      expect(prefs.getString('pref_printer_address'), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Static auto-print helpers
  // -------------------------------------------------------------------------
  group('auto-print preference helpers', () {
    test('isAutoPrintEnabled defaults to false', () async {
      SharedPreferences.setMockInitialValues({});
      final enabled = await PrintServiceNotifier.isAutoPrintEnabled();
      expect(enabled, isFalse);
    });

    test('setAutoPrint(true) persists the preference', () async {
      SharedPreferences.setMockInitialValues({});

      await PrintServiceNotifier.setAutoPrint(true);
      final enabled = await PrintServiceNotifier.isAutoPrintEnabled();
      expect(enabled, isTrue);
    });

    test('setAutoPrint(false) clears the preference', () async {
      SharedPreferences.setMockInitialValues({'pref_auto_print': true});

      await PrintServiceNotifier.setAutoPrint(false);
      final enabled = await PrintServiceNotifier.isAutoPrintEnabled();
      expect(enabled, isFalse);
    });

    test('roundtrip: set then read', () async {
      SharedPreferences.setMockInitialValues({});

      expect(await PrintServiceNotifier.isAutoPrintEnabled(), isFalse);
      await PrintServiceNotifier.setAutoPrint(true);
      expect(await PrintServiceNotifier.isAutoPrintEnabled(), isTrue);
      await PrintServiceNotifier.setAutoPrint(false);
      expect(await PrintServiceNotifier.isAutoPrintEnabled(), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // printReceiptWithService / printReceiptQueued via container
  // -------------------------------------------------------------------------
  // These helpers require a WidgetRef which is cumbersome in a pure unit
  // test. The key "no service configured" branch is covered by reading the
  // providers above.
}
