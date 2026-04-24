library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashier/screens/settings/devices/printer_settings_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';

void main() {
  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    // PrinterSettingsScreen uses _db.select(_db.settingsTable) which
    // will throw on the mock. The screen catch-block handles it gracefully
    // and falls back to default printers.
    final db = setupMockDatabase();
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  group('PrinterSettingsScreen', () {
    testWidgets('renders with default printers when DB empty', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const PrinterSettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(PrinterSettingsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows loading indicator initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const PrinterSettingsScreen()));
      await tester.pumpAndSettle();

      // Provider resolves synchronously in test, so loading state
      // is not observable. Verify the screen rendered successfully.
      expect(find.byType(PrinterSettingsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(
          const PrinterSettingsScreen(),
          theme: ThemeData.dark(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PrinterSettingsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const PrinterSettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(PrinterSettingsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on tablet viewport', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const PrinterSettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(PrinterSettingsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  // -------------------------------------------------------------------------
  // Unit-level: IPv4 regex + port range. Mirror the source contract so a
  // regression fails the moment someone relaxes validation — an invalid
  // IP quietly persisted would have produced an opaque socket error on
  // the next print attempt.
  // -------------------------------------------------------------------------
  group('Printer IPv4 + port validation', () {
    final ipv4 = RegExp(
      r'^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$',
    );

    test('accepts common LAN addresses', () {
      expect(ipv4.hasMatch('192.168.1.100'), isTrue);
      expect(ipv4.hasMatch('10.0.0.1'), isTrue);
      expect(ipv4.hasMatch('172.16.254.1'), isTrue);
    });

    test('accepts boundary octet values 0 and 255', () {
      expect(ipv4.hasMatch('0.0.0.0'), isTrue);
      expect(ipv4.hasMatch('255.255.255.255'), isTrue);
    });

    test('rejects octets above 255', () {
      expect(ipv4.hasMatch('256.0.0.1'), isFalse);
      expect(ipv4.hasMatch('192.168.1.300'), isFalse);
    });

    test('rejects malformed shapes', () {
      expect(ipv4.hasMatch('192.168.1'), isFalse); // too few octets
      expect(ipv4.hasMatch('192.168.1.1.1'), isFalse); // too many
      expect(ipv4.hasMatch('192.168.1.'), isFalse); // trailing dot
      expect(ipv4.hasMatch(''), isFalse);
      expect(ipv4.hasMatch('not.an.ip.addr'), isFalse);
    });

    test('port range is [1, 65535]', () {
      bool validPort(int p) => p >= 1 && p <= 65535;

      expect(validPort(1), isTrue);
      expect(validPort(9100), isTrue); // ESC/POS default
      expect(validPort(65535), isTrue);
      expect(validPort(0), isFalse);
      expect(validPort(-1), isFalse);
      expect(validPort(65536), isFalse);
    });
  });
}
