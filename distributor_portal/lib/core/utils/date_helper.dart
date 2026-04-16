/// Date formatting helper with Hijri/Gregorian dual display.
///
/// Saudi commercial documents require Hijri dates alongside Gregorian.
library;

import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' show DateFormat;

class DateHelper {
  DateHelper._();

  /// Format as Gregorian only: "01/05/2026"
  static String toGregorian(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'ar').format(date);
  }

  /// Format as Gregorian with time: "2026/01/05 - 14:30"
  static String toGregorianWithTime(DateTime date) {
    return DateFormat('yyyy/MM/dd - HH:mm', 'ar').format(date);
  }

  /// Format as Hijri only: "12/10/1447"
  static String toHijri(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    return '${hijri.hDay}/${hijri.hMonth}/${hijri.hYear}';
  }

  /// Dual format: "01/05/2026 (12/10/1447هـ)"
  static String dual(DateTime date) {
    return '${toGregorian(date)} (${toHijri(date)}هـ)';
  }

  /// Dual format with time: "2026/01/05 - 14:30 (12/10/1447هـ)"
  static String dualWithTime(DateTime date) {
    return '${toGregorianWithTime(date)} (${toHijri(date)}هـ)';
  }
}
