import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:distributor_portal/core/utils/date_helper.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar');
  });

  group('DateHelper', () {
    // Use a known date: April 16, 2026 (Gregorian)
    final testDate = DateTime(2026, 4, 16, 14, 30);

    test('toGregorian formats correctly', () {
      final result = DateHelper.toGregorian(testDate);
      // Should contain day/month/year
      expect(result, contains('16'));
      expect(result, contains('04'));
      expect(result, contains('2026'));
    });

    test('toGregorianWithTime includes time', () {
      final result = DateHelper.toGregorianWithTime(testDate);
      expect(result, contains('2026'));
      expect(result, contains('14:30'));
    });

    test('toHijri returns non-empty Hijri date', () {
      final result = DateHelper.toHijri(testDate);
      expect(result.isNotEmpty, isTrue);
      // Should contain slashes between day/month/year
      expect(result.split('/').length, 3);
      // Hijri year should be in 1447-1448 range for 2026
      final parts = result.split('/');
      final hijriYear = int.tryParse(parts.last) ?? 0;
      expect(hijriYear, inInclusiveRange(1447, 1449));
    });

    test('dual contains both Gregorian and Hijri with هـ suffix', () {
      final result = DateHelper.dual(testDate);
      expect(result, contains('2026'));
      expect(result, contains('هـ'));
      expect(result, contains('('));
      expect(result, contains(')'));
    });

    test('dualWithTime contains time and Hijri', () {
      final result = DateHelper.dualWithTime(testDate);
      expect(result, contains('14:30'));
      expect(result, contains('هـ'));
    });

    test('handles epoch date without throwing', () {
      final epoch = DateTime(1970, 1, 1);
      expect(() => DateHelper.dual(epoch), returnsNormally);
      expect(DateHelper.dual(epoch), contains('1970'));
    });

    test('handles future date', () {
      final future = DateTime(2030, 12, 31);
      expect(() => DateHelper.dual(future), returnsNormally);
      expect(DateHelper.dual(future), contains('2030'));
    });
  });
}
