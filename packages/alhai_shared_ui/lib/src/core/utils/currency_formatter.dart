/// Currency Formatter - تنسيق العملات
///
/// يوفر تنسيق متوافق مع الإعدادات المحلية للأرقام والعملات.
/// يستخدم NumberFormat من حزمة intl لعرض الأرقام العربية-الهندية
/// ومجموعات الأرقام المناسبة في اللغة العربية.
library;

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:alhai_core/alhai_core.dart' show Money, StoreSettings;

/// أداة تنسيق العملات مع دعم الإعدادات المحلية
class CurrencyFormatter {
  CurrencyFormatter._();

  /// تنسيق مبلغ مع رمز العملة
  ///
  /// مثال: `١٬٢٣٤٫٥٠ ر.س` (عربي) أو `1,234.50 ر.س` (إنجليزي)
  static String format(
    double amount, {
    String? locale,
    String? symbol,
    int decimalDigits = 2,
  }) {
    final effectiveSymbol = symbol ?? StoreSettings.defaultCurrencySymbol;
    final fmt = NumberFormat.currency(
      locale: locale ?? 'ar_SA',
      symbol: effectiveSymbol,
      decimalDigits: decimalDigits,
    );
    return fmt.format(amount);
  }

  /// تنسيق مبلغ مختصر (بدون كسور عشرية)
  ///
  /// مثال: `١٬٢٣٤ ر.س` (عربي) أو `1,234 ر.س` (إنجليزي)
  static String formatCompact(double amount, {String? locale, String? symbol}) {
    final effectiveSymbol = symbol ?? StoreSettings.defaultCurrencySymbol;
    final fmt = NumberFormat.currency(
      locale: locale ?? 'ar_SA',
      symbol: effectiveSymbol,
      decimalDigits: 0,
    );
    return fmt.format(amount);
  }

  /// تنسيق رقم فقط (بدون رمز عملة) مع فواصل المجموعات
  ///
  /// مثال: `١٬٢٣٤٫٥٠` (عربي) أو `1,234.50` (إنجليزي)
  ///
  /// With `decimalDigits: 0`, uses the plain `#,##0` pattern so there is no
  /// trailing separator (previous `#,##0.` + 0 zeros left a dangling `.`).
  static String formatNumber(
    double amount, {
    String? locale,
    int decimalDigits = 2,
  }) {
    final pattern = decimalDigits <= 0
        ? '#,##0'
        : '#,##0.${'0' * decimalDigits}';
    final fmt = NumberFormat(pattern, locale ?? 'ar_SA');
    return fmt.format(amount);
  }

  /// تنسيق مبلغ مع رمز العملة باستخدام اللغة من السياق
  ///
  /// يستخرج اللغة من `Localizations.localeOf(context)` تلقائيًا
  static String formatWithContext(
    BuildContext context,
    double amount, {
    String? symbol,
    int decimalDigits = 2,
  }) {
    final locale = Localizations.localeOf(context).toString();
    return format(
      amount,
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
  }

  /// تنسيق مبلغ مختصر باستخدام اللغة من السياق
  static String formatCompactWithContext(
    BuildContext context,
    double amount, {
    String? symbol,
  }) {
    final locale = Localizations.localeOf(context).toString();
    return formatCompact(amount, locale: locale, symbol: symbol);
  }

  /// تنسيق رقم فقط باستخدام اللغة من السياق
  static String formatNumberWithContext(
    BuildContext context,
    double amount, {
    int decimalDigits = 2,
  }) {
    final locale = Localizations.localeOf(context).toString();
    return formatNumber(amount, locale: locale, decimalDigits: decimalDigits);
  }

  // ── Money overload (plan D2) ───────────────────────────────────────────────

  /// Format a [Money] value using its own currency code.
  ///
  /// Saves the `product.price / 100.0` boilerplate at every display site and
  /// picks the correct currency symbol for non-SAR values automatically.
  ///
  /// For SAR, uses `StoreSettings.defaultCurrencySymbol` (`ر.س` by default).
  /// For other currencies, falls back to the ISO-4217 code as symbol — add a
  /// case to [_symbolFor] when USD/AED launch.
  static String formatMoney(
    Money money, {
    String? locale,
    int decimalDigits = 2,
  }) {
    return format(
      money.toDouble(),
      locale: locale,
      symbol: _symbolFor(money.currencyCode),
      decimalDigits: decimalDigits,
    );
  }

  /// Compact [Money] formatter (no decimals).
  static String formatMoneyCompact(Money money, {String? locale}) {
    return formatCompact(
      money.toDouble(),
      locale: locale,
      symbol: _symbolFor(money.currencyCode),
    );
  }

  /// Context-aware [Money] formatter; picks locale from [Localizations].
  static String formatMoneyWithContext(
    BuildContext context,
    Money money, {
    int decimalDigits = 2,
  }) {
    return formatWithContext(
      context,
      money.toDouble(),
      symbol: _symbolFor(money.currencyCode),
      decimalDigits: decimalDigits,
    );
  }

  /// Map ISO-4217 code → display symbol.
  static String _symbolFor(String code) {
    switch (code) {
      case 'SAR':
        return StoreSettings.defaultCurrencySymbol;
      default:
        return code;
    }
  }

  // ── Int-cents convenience (Phase 2, task 2.2) ────────────────────────────
  //
  // Drift stores money columns as int cents (C-4 migration). The patterns
  // `(cents / 100.0).toStringAsFixed(2)` and `cents / 100.0` then pass to
  // [format] are scattered across 47+ UI sites — one of them (split_receipt
  // at :346) leaked a 100× display bug in Phase 1. These overloads close
  // that door: callers pass raw cents, we handle the conversion once.

  /// Format int cents (Drift storage) as `"150.75 ر.س"` or `"1,234.50 ر.س"`.
  static String fromCents(int cents, {String? locale, int decimalDigits = 2}) {
    return format(cents / 100.0, locale: locale, decimalDigits: decimalDigits);
  }

  /// Compact int-cents formatter (no decimals).
  static String fromCentsCompact(int cents, {String? locale}) {
    return formatCompact(cents / 100.0, locale: locale);
  }

  /// Context-aware int-cents formatter — preferred API for widgets.
  static String fromCentsWithContext(
    BuildContext context,
    int cents, {
    int decimalDigits = 2,
  }) {
    return formatWithContext(context, cents / 100.0, decimalDigits: decimalDigits);
  }
}
