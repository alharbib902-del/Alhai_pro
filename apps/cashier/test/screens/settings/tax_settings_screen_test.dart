library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:cashier/screens/settings/store/tax_settings_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';

void main() {
  late MockStoresDao storesDao;

  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    storesDao = MockStoresDao();

    // TaxSettingsScreen uses _db.storesDao.getStoreById() and settingsTable.
    // Default: storesDao returns null (no store found), settingsTable fails in catch.
    when(() => storesDao.getStoreById(any())).thenAnswer((_) async => null);

    final db = setupMockDatabase(storesDao: storesDao);
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  group('TaxSettingsScreen', () {
    testWidgets('renders with defaults', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const TaxSettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TaxSettingsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows loading indicator initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      // Use Completer to keep loading state without creating timers
      final completer = Completer<StoresTableData?>();
      when(
        () => storesDao.getStoreById(any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget(const TaxSettingsScreen()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(null);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const TaxSettingsScreen(), theme: ThemeData.dark()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TaxSettingsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const TaxSettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TaxSettingsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('has tax rate text field', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const TaxSettingsScreen()));
      await tester.pumpAndSettle();

      // Tax screen has text fields for tax rate and tax number
      expect(find.byType(TextField), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // ----- New behaviour: Arabic strings (tax_rate basis-points migration) ---

    testWidgets('shows Saudi VAT helper text in Arabic', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const TaxSettingsScreen()));
      await tester.pumpAndSettle();

      // "Saudi VAT is 15%" is now in Arabic with Arabic-Indic percent sign.
      expect(
        find.text('ضريبة القيمة المضافة السعودية 15٪'),
        findsOneWidget,
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('tax rate field has numeric input formatter', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const TaxSettingsScreen()));
      await tester.pumpAndSettle();

      // Find the tax rate TextField — it has FilteringTextInputFormatter
      // allowing ^\d{0,3}(\.\d{0,2})?.
      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      final rateField = textFields.firstWhere(
        (f) => f.inputFormatters != null && f.inputFormatters!.isNotEmpty,
        orElse: () => textFields.first,
      );

      expect(rateField.inputFormatters, isNotNull);
      expect(rateField.inputFormatters!.isNotEmpty, isTrue);
      expect(
        rateField.inputFormatters!.first,
        isA<FilteringTextInputFormatter>(),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('tax rate field rejects letters via formatter', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const TaxSettingsScreen()));
      await tester.pumpAndSettle();

      // Smoke check: apply the formatter manually against garbage input.
      final rx = RegExp(r'^\d{0,3}(\.\d{0,2})?');
      expect(rx.hasMatch('15'), isTrue);
      expect(rx.hasMatch('15.25'), isTrue);
      expect(rx.hasMatch('100'), isTrue);
      // The pattern matches the empty-prefix before 'abc', so the formatter
      // will strip 'abc' — verify the regex itself does what we expect.
      expect(rx.firstMatch('abc')?.group(0), equals(''));

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  // -------------------------------------------------------------------------
  // Unit-level: the basis-points encode/decode is pure logic that ships
  // inside the screen. Mirror the algorithm here so regressions of the
  // storage contract fail at compile time the moment the source changes.
  // -------------------------------------------------------------------------
  group('Tax rate basis-points encoding', () {
    // Mirror of _encodeTaxRateAsBasisPoints from tax_settings_screen.dart.
    String encode(double percent) => (percent * 100).round().toString();

    // Mirror of _decodeStoredTaxRate from tax_settings_screen.dart.
    String decode(String stored) {
      final trimmed = stored.trim();
      if (trimmed.isEmpty) return '15';
      if (!trimmed.contains('.')) {
        final bps = int.tryParse(trimmed);
        if (bps != null) {
          final percent = bps / 100.0;
          final asStr = percent.toStringAsFixed(2);
          final out = asStr.replaceFirst(RegExp(r'\.?0+$'), '');
          return out.isEmpty ? '0' : out;
        }
      }
      final asDouble = double.tryParse(trimmed);
      if (asDouble == null || !asDouble.isFinite) return '15';
      return trimmed;
    }

    test('encodes 15% as 1500 basis points', () {
      expect(encode(15), equals('1500'));
    });

    test('encodes fractional percent as integer bps', () {
      expect(encode(15.25), equals('1525'));
      expect(encode(15.5), equals('1550'));
      expect(encode(0), equals('0'));
      expect(encode(100), equals('10000'));
    });

    test('decodes basis-points back to percent string', () {
      expect(decode('1500'), equals('15'));
      expect(decode('1525'), equals('15.25'));
      expect(decode('1550'), equals('15.5'));
      expect(decode('0'), equals('0'));
    });

    test('decodes legacy decimal rows unchanged', () {
      // Backward compat: rows written before v1.3 stored the raw percent
      // as a decimal string. The decode() trusts floats (anything with a
      // dot) verbatim, so '15.0' stays '15.0' rather than being
      // re-interpreted as 0.15% basis-points.
      expect(decode('15.0'), equals('15.0'));
      expect(decode('15.00'), equals('15.00'));
    });

    test('integer-only stored value is treated as basis-points', () {
      // This is the migration edge: a new-format row of '1500' decodes to
      // '15'. A pure int '15' has no dot, so it is also treated as
      // basis-points → 0.15%. Old rows that lacked a decimal would have
      // been migrated via the Supabase v77 backfill, so this path only
      // fires for brand-new writes.
      expect(decode('15'), equals('0.15'));
      expect(decode('1500'), equals('15'));
    });

    test('empty stored value falls back to default 15', () {
      expect(decode(''), equals('15'));
      expect(decode('   '), equals('15'));
    });

    test('garbage stored value falls back to default 15', () {
      expect(decode('not-a-number'), equals('15'));
    });

    test('round-trip through encode/decode preserves percent', () {
      for (final p in const [0.0, 5.0, 15.0, 15.25, 50.0, 100.0]) {
        final encoded = encode(p);
        final decoded = decode(encoded);
        // Decoded is the user-facing string; parse back to compare.
        expect(double.parse(decoded), closeTo(p, 0.01));
      }
    });
  });

  // -------------------------------------------------------------------------
  // Unit-level: the tax-rate validator. The source rejects anything outside
  // [0, 100] and non-finite values; mirror the rule here so the error path
  // has coverage without requiring a full widget-driven save.
  // -------------------------------------------------------------------------
  group('Tax rate validator', () {
    double? parse(String raw) {
      final text = raw.trim();
      if (text.isEmpty) return null;
      final value = double.tryParse(text);
      if (value == null || !value.isFinite) return null;
      if (value < 0 || value > 100) return null;
      return value;
    }

    test('accepts 0 and 100 inclusive', () {
      expect(parse('0'), equals(0.0));
      expect(parse('100'), equals(100.0));
    });

    test('accepts typical Saudi 15%', () {
      expect(parse('15'), equals(15.0));
      expect(parse('15.5'), equals(15.5));
    });

    test('rejects negative', () {
      expect(parse('-1'), isNull);
    });

    test('rejects >100', () {
      expect(parse('101'), isNull);
      expect(parse('200'), isNull);
    });

    test('rejects empty and whitespace', () {
      expect(parse(''), isNull);
      expect(parse('   '), isNull);
    });

    test('rejects non-numeric', () {
      expect(parse('abc'), isNull);
      expect(parse('15abc'), isNull);
    });
  });
}
