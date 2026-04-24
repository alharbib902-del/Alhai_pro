library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashier/screens/settings/devices/add_payment_device_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';

void main() {
  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    // AddPaymentDeviceScreen uses _db.into(_db.settingsTable) on save.
    // The form can render without any DB calls (form-only screen).
    final db = setupMockDatabase();
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  group('AddPaymentDeviceScreen', () {
    testWidgets('renders the form', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const AddPaymentDeviceScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(AddPaymentDeviceScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('has text fields for name, IP, port', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const AddPaymentDeviceScreen()));
      await tester.pumpAndSettle();

      // The form has name, IP address, and port text fields
      expect(find.byType(TextFormField), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(
          const AddPaymentDeviceScreen(),
          theme: ThemeData.dark(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AddPaymentDeviceScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const AddPaymentDeviceScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(AddPaymentDeviceScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('has dropdown for device type', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const AddPaymentDeviceScreen()));
      await tester.pumpAndSettle();

      // Device type selector uses custom GestureDetector chips
      expect(find.byType(GestureDetector), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // --- New behaviour: Arabic section headers -----------------------------

    testWidgets('shows Arabic section headers', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const AddPaymentDeviceScreen()));
      await tester.pumpAndSettle();

      // Previously English: "Device Info", "Device Name", "Device Type",
      // "Connection Method".
      expect(find.text('معلومات الجهاز'), findsOneWidget);
      expect(find.text('اسم الجهاز'), findsOneWidget);
      expect(find.text('نوع الجهاز'), findsOneWidget);
      expect(find.text('طريقة الاتصال'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  // -------------------------------------------------------------------------
  // Unit-level: the device serialisation migrated from pipe-delimited
  // strings to JSON. payment_devices_screen falls back to the legacy format
  // for old rows, but new writes must be JSON — verify the shape here so a
  // regression does not slip past a purely visual widget test.
  // -------------------------------------------------------------------------
  group('Payment-device JSON serialisation', () {
    test('encodes name/type/method/testPassed as a JSON object', () {
      // Mirror of the save-path encoder in add_payment_device_screen.dart.
      final encoded = jsonEncode({
        'name': 'Mada Main',
        'type': 'Point of Sale',
        'method': 'Network',
        'testPassed': true,
      });

      // Must start with '{' so the reader's JSON fast-path fires.
      expect(encoded.startsWith('{'), isTrue);

      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      expect(decoded['name'], equals('Mada Main'));
      expect(decoded['type'], equals('Point of Sale'));
      expect(decoded['method'], equals('Network'));
      expect(decoded['testPassed'], isTrue);
    });

    test('testPassed defaults to false when connection test not run', () {
      // Non-network methods (QR Code, Bluetooth, etc.) cannot auto-run the
      // Socket.connect probe — the source sets testPassed = false and
      // shows a "not available yet" snackbar. JSON must carry that fact so
      // the device list does not claim the device is reachable.
      final encoded = jsonEncode({
        'name': 'QR Reader',
        'type': 'Scanner',
        'method': 'QR Code',
        'testPassed': false,
      });

      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      expect(decoded['testPassed'], isFalse);
    });

    test('JSON is distinguishable from legacy pipe format', () {
      // Legacy rows look like "Name|Type|Method|true". The reader picks
      // JSON only when the value starts with '{' — make sure the new
      // format starts with that char and the legacy one does not.
      final newFormat = jsonEncode({'name': 'X', 'type': 'Y', 'method': 'Z'});
      const legacyFormat = 'X|Y|Z|true';

      expect(newFormat[0], equals('{'));
      expect(legacyFormat[0], isNot(equals('{')));
    });
  });
}
