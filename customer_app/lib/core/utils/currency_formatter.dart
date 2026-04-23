/// Currency formatter for customer_app.
///
/// Minimal vendored subset of `alhai_shared_ui.CurrencyFormatter`. customer_app
/// cannot (yet) depend on `alhai_shared_ui` because that package pulls in
/// backend-heavy deps (alhai_database / alhai_sync / alhai_auth) that do not
/// belong in a customer-facing mobile bundle. Decision logged under §4b in the
/// 2026-04-24 handover: option (b) — vendor a ~20-LOC helper here. If the
/// customer_app ever takes a structural dep on `alhai_shared_ui`, this file
/// becomes a thin re-export — the API matches by design.
///
/// Locale: defaults to `ar_SA` so Arabic-Indic digits + grouping render
/// natively in the Arabic-only customer shell. Pass `locale: 'en'` to render
/// ASCII digits on sites that need them.
library;

import 'package:intl/intl.dart';
import 'package:alhai_core/alhai_core.dart' show Money, StoreSettings;

/// Currency formatter for customer_app.
///
/// Prefer [formatMoney] over `toStringAsFixed(2)` + manual `ر.س` concat —
/// the locale-aware output survives future i18n expansion without touching
/// call sites.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Format a [Money] value with its currency's symbol.
  ///
  /// Defaults: `ar_SA` locale, 2 decimal digits. The SAR symbol comes from
  /// [StoreSettings.defaultCurrencySymbol] (`ر.س`).
  static String formatMoney(
    Money money, {
    String locale = 'ar_SA',
    int decimalDigits = 2,
  }) {
    return _format(
      money.toDouble(),
      locale: locale,
      symbol: _symbolFor(money.currencyCode),
      decimalDigits: decimalDigits,
    );
  }

  /// Format a raw SAR double. Use [formatMoney] whenever a [Money] is
  /// available — the [Money] overload picks the correct symbol for
  /// non-SAR values when multi-currency arrives.
  static String formatSar(
    double amount, {
    String locale = 'ar_SA',
    int decimalDigits = 2,
  }) {
    return _format(
      amount,
      locale: locale,
      symbol: StoreSettings.defaultCurrencySymbol,
      decimalDigits: decimalDigits,
    );
  }

  static String _format(
    double amount, {
    required String locale,
    required String symbol,
    required int decimalDigits,
  }) {
    final fmt = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return fmt.format(amount);
  }

  static String _symbolFor(String currencyCode) {
    switch (currencyCode) {
      case 'SAR':
        return StoreSettings.defaultCurrencySymbol;
      default:
        return currencyCode;
    }
  }
}
