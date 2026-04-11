/// Currency Formatter - تنسيق العملات
///
/// يوفر تنسيق متوافق مع الإعدادات المحلية للأرقام والعملات.
/// يستخدم NumberFormat من حزمة intl لعرض الأرقام العربية-الهندية
/// ومجموعات الأرقام المناسبة في اللغة العربية.
library;

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:alhai_core/alhai_core.dart' show StoreSettings;

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
  static String formatNumber(
    double amount, {
    String? locale,
    int decimalDigits = 2,
  }) {
    final fmt = NumberFormat('#,##0.${'0' * decimalDigits}', locale ?? 'ar_SA');
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
}
