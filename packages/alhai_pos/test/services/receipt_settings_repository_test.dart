import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_pos/src/models/receipt_settings.dart';
import 'package:alhai_pos/src/services/receipt_settings_repository.dart';

/// P0-31: cover the round-trip + the "missing keys → defaults" path.
/// The repository is the single source of truth for the wire format
/// (KV-table key names + bool-string convention) — any drift between
/// reader + writer would re-introduce the audit's original bug
/// (settings written but ignored).
void main() {
  late AppDatabase db;
  late ReceiptSettingsRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ReceiptSettingsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ReceiptSettingsRepository', () {
    test('loadForStore returns defaults when no row exists', () async {
      final settings = await repo.loadForStore('store-empty');
      expect(settings, ReceiptSettings.defaults);
      expect(settings.headerText, '');
      expect(settings.footerText, '');
      expect(settings.showLogo, isTrue);
      expect(settings.showCustomerName, isTrue);
      expect(settings.showCashierName, isTrue);
      expect(settings.showStoreAddress, isTrue);
      expect(settings.paperWidth, '80mm');
    });

    test('saveForStore + loadForStore round-trips every field', () async {
      const original = ReceiptSettings(
        headerText: 'Custom Header — Welcome',
        footerText: 'Thanks for shopping with us',
        showLogo: false,
        showCustomerName: false,
        showCashierName: true,
        showStoreAddress: false,
        paperWidth: '58mm',
      );

      await repo.saveForStore('store-1', original);
      final loaded = await repo.loadForStore('store-1');

      expect(loaded, original);
    });

    test('Arabic text round-trips cleanly', () async {
      const arabicSettings = ReceiptSettings(
        headerText: 'مرحباً بكم في متجرنا',
        footerText: 'نتطلع لخدمتكم مجدداً',
      );
      await repo.saveForStore('store-ar', arabicSettings);

      final loaded = await repo.loadForStore('store-ar');
      expect(loaded.headerText, 'مرحباً بكم في متجرنا');
      expect(loaded.footerText, 'نتطلع لخدمتكم مجدداً');
    });

    test('partial keys → missing fields fall back to defaults', () async {
      // Simulate a legacy row written by an older app build that only
      // saved the header text. The repo should populate every other
      // field from the model defaults rather than crash or write nulls.
      await db.into(db.settingsTable).insert(
            SettingsTableCompanion(
              id: const Value('setting_store-partial_receipt_header'),
              storeId: const Value('store-partial'),
              key: const Value('receipt_header'),
              value: const Value('Header only'),
              updatedAt: Value(DateTime.now()),
            ),
          );

      final loaded = await repo.loadForStore('store-partial');
      expect(loaded.headerText, 'Header only');
      expect(loaded.footerText, ''); // default
      expect(loaded.paperWidth, '80mm'); // default
      expect(loaded.showLogo, isTrue); // default
    });

    test('saveForStore is idempotent + overwrites prior values', () async {
      await repo.saveForStore(
        'store-1',
        const ReceiptSettings(headerText: 'first'),
      );
      await repo.saveForStore(
        'store-1',
        const ReceiptSettings(headerText: 'second', paperWidth: '58mm'),
      );

      final loaded = await repo.loadForStore('store-1');
      expect(loaded.headerText, 'second');
      expect(loaded.paperWidth, '58mm');
    });

    test('saveForStore scopes by storeId — does not cross-contaminate',
        () async {
      await repo.saveForStore(
        'store-A',
        const ReceiptSettings(headerText: 'A header'),
      );
      await repo.saveForStore(
        'store-B',
        const ReceiptSettings(headerText: 'B header'),
      );

      final a = await repo.loadForStore('store-A');
      final b = await repo.loadForStore('store-B');
      expect(a.headerText, 'A header');
      expect(b.headerText, 'B header');
    });

    test('paperWidthMm parses common values + falls back on unknown',
        () async {
      expect(const ReceiptSettings(paperWidth: '80mm').paperWidthMm, 80.0);
      expect(const ReceiptSettings(paperWidth: '58mm').paperWidthMm, 58.0);
      // Typo / bad value → fallback to 80mm so the receipt still prints.
      expect(const ReceiptSettings(paperWidth: 'garbage').paperWidthMm, 80.0);
    });

    test('copyWith preserves untouched fields', () {
      const original = ReceiptSettings(
        headerText: 'h',
        footerText: 'f',
        showLogo: false,
      );
      final modified = original.copyWith(headerText: 'h2');
      expect(modified.headerText, 'h2');
      expect(modified.footerText, 'f'); // preserved
      expect(modified.showLogo, isFalse); // preserved
    });
  });
}
