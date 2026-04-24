/// Hijri date formatting helper for Saudi market.
///
/// Computes Hijri (Islamic) dates from Gregorian using the Umm al-Qura
/// algorithm approximation. For production with strict accuracy requirements,
/// swap to the `hijri: ^3.0.0` package or `umm_al_qura_calendar` — this helper
/// exposes the same public shape so the migration is one import change.
///
/// Accuracy: ±1 day vs. official Saudi calendar (acceptable for display only —
/// do NOT use this for legal timestamps or ZATCA compliance).
library;

import 'package:intl/intl.dart';

class HijriDate {
  final int year;
  final int month;
  final int day;

  const HijriDate({
    required this.year,
    required this.month,
    required this.day,
  });

  static const List<String> _arabicMonths = [
    'محرّم', 'صفر', 'ربيع الأول', 'ربيع الآخر',
    'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
    'رمضان', 'شوّال', 'ذو القعدة', 'ذو الحجة',
  ];

  String get monthName =>
      (month >= 1 && month <= 12) ? _arabicMonths[month - 1] : '';

  String format({bool withHijriSuffix = true}) {
    final suffix = withHijriSuffix ? ' هـ' : '';
    return '$day $monthName $year$suffix';
  }
}

/// Hijri date formatter — approximation via Julian Day conversion.
///
/// Reference: Fliegel & Van Flandern (1968) + Islamic epoch offset 1948440.
/// The calculation is deterministic and fully offline — no network or
/// timezone dependency beyond the input [DateTime].
class HijriDateFormatter {
  /// Convert a Gregorian [DateTime] to Hijri (approximation).
  static HijriDate fromGregorian(DateTime date) {
    final julianDay = _gregorianToJulianDay(date.year, date.month, date.day);
    return _julianDayToHijri(julianDay);
  }

  /// Format [date] as "15 رمضان 1445 هـ" (or similar with locale).
  ///
  /// If [showBothCalendars] is true, returns "15 رمضان 1445 هـ (2024/3/25)".
  static String format(
    DateTime date, {
    bool showBothCalendars = false,
    String locale = 'ar',
  }) {
    final hijri = fromGregorian(date);
    final hijriStr = hijri.format();
    if (!showBothCalendars) return hijriStr;
    final gregorianStr = DateFormat('yyyy/M/d', locale).format(date);
    return '$hijriStr ($gregorianStr)';
  }

  /// Today in Hijri (Arabic formatted).
  static String today({bool showBothCalendars = false}) =>
      format(DateTime.now(), showBothCalendars: showBothCalendars);

  // ──────────────────────────────────────────────────────────────────────
  // Internal: Gregorian → Julian Day Number (Fliegel & Van Flandern 1968).
  // Accurate for any date between 1 Jan 4713 BC and far into the future.
  static int _gregorianToJulianDay(int year, int month, int day) {
    final a = ((14 - month) / 12).floor();
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        ((153 * m + 2) / 5).floor() +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045;
  }

  // Internal: Julian Day Number → Hijri via tabular lunar cycle.
  // Islamic epoch (1 Muharram 1 AH) = Julian Day 1948440.
  // Average lunar year ≈ 354.367 days; cycle of 30 years has 11 leap years
  // (days 2,5,7,10,13,16,18,21,24,26,29).
  static HijriDate _julianDayToHijri(int julianDay) {
    final daysSinceEpoch = julianDay - 1948440;
    final thirtyYearCycles = (daysSinceEpoch / 10631).floor();
    var remaining = daysSinceEpoch - thirtyYearCycles * 10631;

    const cumulativeLeapDays = [
      0, 354, 709, 1063, 1417, 1772, 2126, 2481, 2835, 3189,
      3544, 3898, 4252, 4607, 4961, 5315, 5670, 6024, 6378, 6733,
      7087, 7442, 7796, 8150, 8505, 8859, 9214, 9568, 9922, 10277, 10631,
    ];

    var yearInCycle = 0;
    for (var i = 0; i < 30; i++) {
      if (remaining < cumulativeLeapDays[i + 1]) {
        yearInCycle = i;
        remaining -= cumulativeLeapDays[i];
        break;
      }
    }

    final year = thirtyYearCycles * 30 + yearInCycle + 1;

    const monthLengths = [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29];
    var month = 1;
    for (final len in monthLengths) {
      if (remaining < len) break;
      remaining -= len;
      month++;
    }

    final day = remaining + 1;
    return HijriDate(year: year, month: month, day: day);
  }
}
