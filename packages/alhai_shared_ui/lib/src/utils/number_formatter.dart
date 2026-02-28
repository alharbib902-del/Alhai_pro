import 'package:intl/intl.dart';

/// Centralized number formatting utility for locale-aware displays.
class AppNumberFormatter {
  AppNumberFormatter._();

  /// Format currency amount with locale awareness.
  /// Returns formatted string like "1,234.56" or "1,234" for Arabic.
  static String currency(double value, {String locale = 'en', int decimals = 2}) {
    final format = NumberFormat.currency(
      locale: locale,
      symbol: '',
      decimalDigits: value.truncateToDouble() == value ? 0 : decimals,
    );
    return format.format(value).trim();
  }

  /// Format integer with thousands separator.
  static String integer(int value, {String locale = 'en'}) {
    return NumberFormat('#,###', locale).format(value);
  }

  /// Format percentage.
  static String percentage(double value, {String locale = 'en', int decimals = 1}) {
    return NumberFormat.percentPattern(locale).format(value / 100);
  }

  /// Format compact number (1K, 1M).
  static String compact(num value, {String locale = 'en'}) {
    return NumberFormat.compact(locale: locale).format(value);
  }
}
