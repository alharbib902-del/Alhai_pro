/// P0-31: read/write [ReceiptSettings] against the per-store
/// `settings` KV table.
///
/// **Why a repository (instead of letting the screen poke `_db`):**
/// pre-fix the receipt_settings screen wrote 7 keys directly to the
/// table and the receipt-PDF generator never read them. Centralising
/// the key names + parse rules here keeps reader and writer locked
/// to the same wire format — adding an 8th setting only changes one
/// file.
library;

import 'package:alhai_database/alhai_database.dart';

import '../models/receipt_settings.dart';

class ReceiptSettingsRepository {
  /// KV keys persisted in the `settings` table. Kept as static
  /// constants (not free strings) so a typo at a call site is a
  /// compile error, and Sprint 3's cross-app key unification can
  /// rename them in one place. Names match what receipt_settings
  /// screen wrote pre-fix — picked up existing rows transparently.
  static const _kHeader = 'receipt_header';
  static const _kFooter = 'receipt_footer';
  static const _kShowLogo = 'receipt_show_logo';
  static const _kShowCustomerName = 'receipt_show_customer_name';
  static const _kShowCashierName = 'receipt_show_cashier_name';
  static const _kShowStoreAddress = 'receipt_show_store_address';
  static const _kPaperWidth = 'receipt_width';

  final AppDatabase _db;

  ReceiptSettingsRepository(this._db);

  /// Load the receipt settings for [storeId]. Returns
  /// [ReceiptSettings.defaults] when no row exists yet (first install
  /// or a store that hasn't visited the settings screen) — callers
  /// don't have to special-case "null" everywhere.
  Future<ReceiptSettings> loadForStore(String storeId) async {
    final rows = await (_db.select(
      _db.settingsTable,
    )..where((s) => s.storeId.equals(storeId))).get();

    if (rows.isEmpty) return ReceiptSettings.defaults;

    final byKey = <String, String>{
      for (final r in rows) r.key: r.value,
    };

    return ReceiptSettings(
      headerText: byKey[_kHeader] ?? ReceiptSettings.defaults.headerText,
      footerText: byKey[_kFooter] ?? ReceiptSettings.defaults.footerText,
      showLogo: _bool(byKey[_kShowLogo], ReceiptSettings.defaults.showLogo),
      showCustomerName: _bool(
        byKey[_kShowCustomerName],
        ReceiptSettings.defaults.showCustomerName,
      ),
      showCashierName: _bool(
        byKey[_kShowCashierName],
        ReceiptSettings.defaults.showCashierName,
      ),
      showStoreAddress: _bool(
        byKey[_kShowStoreAddress],
        ReceiptSettings.defaults.showStoreAddress,
      ),
      paperWidth: byKey[_kPaperWidth] ?? ReceiptSettings.defaults.paperWidth,
    );
  }

  /// Persist [settings] for [storeId]. Writes one row per key via
  /// `INSERT ... ON CONFLICT DO UPDATE` so a re-save is idempotent
  /// and concurrent writes from another device pick up the latest
  /// value rather than dropping it.
  Future<void> saveForStore(String storeId, ReceiptSettings settings) async {
    final entries = <String, String>{
      _kHeader: settings.headerText,
      _kFooter: settings.footerText,
      _kShowLogo: settings.showLogo.toString(),
      _kShowCustomerName: settings.showCustomerName.toString(),
      _kShowCashierName: settings.showCashierName.toString(),
      _kShowStoreAddress: settings.showStoreAddress.toString(),
      _kPaperWidth: settings.paperWidth,
    };

    // One UPSERT per key. Wrapped in a transaction so a partial
    // failure (e.g. disk full mid-write) doesn't leave the row
    // half-updated — the caller can retry from a clean state. Uses
    // Drift's typed `insertOnConflictUpdate` (matches the rest of
    // the codebase + sidesteps the FormatException SQLite raises
    // when a raw `customStatement` binds a DateTime column with the
    // wrong representation).
    final now = DateTime.now();
    await _db.transaction(() async {
      for (final entry in entries.entries) {
        await _db.into(_db.settingsTable).insertOnConflictUpdate(
              SettingsTableCompanion.insert(
                id: 'setting_${storeId}_${entry.key}',
                storeId: storeId,
                key: entry.key,
                value: entry.value,
                updatedAt: now,
              ),
            );
      }
    });
  }

  /// Parse a stored bool string. Mirrors the convention the screen
  /// has used since day one: anything other than the literal
  /// `"false"` is treated as true. Falls back to [fallback] when
  /// the key isn't set yet so a partial save doesn't flip a toggle
  /// the user never touched.
  static bool _bool(String? raw, bool fallback) {
    if (raw == null) return fallback;
    return raw != 'false';
  }
}
