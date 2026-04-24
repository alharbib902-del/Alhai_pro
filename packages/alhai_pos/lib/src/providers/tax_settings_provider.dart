/// Tax Settings Provider - مزود إعدادات الضريبة
///
/// Sprint 1 / P0-03: bridges the gap between [TaxSettingsScreen] (the
/// writer) and [VatCalculator] (the reader). Before this, the toggle and
/// rate on the screen were persisted to `settings` but ignored everywhere
/// else — invoices always shipped 15% regardless of user intent.
///
/// The writer encodes the rate as basis points (`"1500"` = 15.00%), so
/// tax-aware callers should read the rate via this provider instead of
/// reading `settings` directly.
///
/// ## Storage contract
/// The `settings` KV table holds three rows per store:
///   - `tax_rate`       — basis points as text, e.g. `"1500"` for 15%
///   - `tax_enabled`    — `"true"` or `"false"`
///   - `tax_inclusive`  — `"true"` or `"false"`
///
/// ## Usage
/// In async contexts (event handlers, service methods):
/// ```dart
/// final tax = await ref.read(taxSettingsProvider.future);
/// final vat = VatCalculator.vatFromNet(
///   netAmount: subtotal,
///   vatRate: tax.effectiveRate,
/// );
/// ```
///
/// In build contexts (widgets):
/// ```dart
/// final tax = ref.watch(taxSettingsProvider).valueOrNull
///     ?? TaxSettings.fallback;
/// final vat = VatCalculator.vatFromNet(
///   netAmount: subtotal,
///   vatRate: tax.effectiveRate,
/// );
/// ```
///
/// The `?? TaxSettings.fallback` keeps behaviour identical to the legacy
/// `VatCalculator.standardRate` default (15%) during the initial load or
/// when no store is selected, so the UI never shows a momentarily wrong
/// total while the provider resolves.
library;

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart' show currentStoreIdProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

/// Immutable snapshot of a store's tax configuration.
class TaxSettings {
  /// Nominal rate as a percentage (e.g. 15.0 for 15%).
  final double ratePercent;

  /// Whether VAT should be applied at all. When false, [effectiveRate] is 0.
  final bool enabled;

  /// Whether prices shown to users are VAT-inclusive (gross) or exclusive
  /// (net). VAT is still computed the same way either way; this flag only
  /// affects how the amount is displayed / entered.
  final bool inclusive;

  const TaxSettings({
    required this.ratePercent,
    required this.enabled,
    required this.inclusive,
  });

  /// Rate to pass to [VatCalculator]. Returns 0 when VAT is disabled so
  /// callers don't need a second branch for the disabled case.
  double get effectiveRate => enabled ? ratePercent : 0.0;

  /// Safe default used when the provider hasn't resolved yet (initial load,
  /// no store selected, DAO error). Matches the historical
  /// `VatCalculator.standardRate` behaviour so the UI never momentarily
  /// shows a different total during startup.
  static const fallback = TaxSettings(
    ratePercent: 15.0,
    enabled: true,
    inclusive: true,
  );

  TaxSettings copyWith({
    double? ratePercent,
    bool? enabled,
    bool? inclusive,
  }) => TaxSettings(
    ratePercent: ratePercent ?? this.ratePercent,
    enabled: enabled ?? this.enabled,
    inclusive: inclusive ?? this.inclusive,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxSettings &&
          other.ratePercent == ratePercent &&
          other.enabled == enabled &&
          other.inclusive == inclusive;

  @override
  int get hashCode => Object.hash(ratePercent, enabled, inclusive);

  @override
  String toString() =>
      'TaxSettings(rate: $ratePercent%, enabled: $enabled, inclusive: $inclusive)';
}

/// Reads the current store's tax settings from the `settings` KV table.
///
/// Invalidated by the Tax Settings screen after save so callers re-read the
/// new values immediately. Returns [TaxSettings.fallback] on any error or
/// when no store is selected — never throws.
final taxSettingsProvider = FutureProvider<TaxSettings>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null || storeId.isEmpty) {
    return TaxSettings.fallback;
  }

  try {
    final db = GetIt.I<AppDatabase>();
    final rows = await (db.select(db.settingsTable)
          ..where((s) => s.storeId.equals(storeId)))
        .get();

    var ratePercent = TaxSettings.fallback.ratePercent;
    var enabled = TaxSettings.fallback.enabled;
    var inclusive = TaxSettings.fallback.inclusive;

    for (final row in rows) {
      switch (row.key) {
        case 'tax_rate':
          // Stored as basis points by TaxSettingsScreen (e.g. "1500" = 15%).
          final bps = int.tryParse(row.value);
          if (bps != null && bps >= 0 && bps <= 10000) {
            ratePercent = bps / 100.0;
          }
        case 'tax_enabled':
          enabled = row.value != 'false';
        case 'tax_inclusive':
          inclusive = row.value != 'false';
      }
    }

    return TaxSettings(
      ratePercent: ratePercent,
      enabled: enabled,
      inclusive: inclusive,
    );
  } catch (_) {
    // Defensive: never let a transient DB read break the checkout flow.
    // Consumers fall back to 15% (the legacy hardcoded behaviour).
    return TaxSettings.fallback;
  }
});
