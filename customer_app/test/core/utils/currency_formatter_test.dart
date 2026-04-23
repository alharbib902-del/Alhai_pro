import 'package:alhai_core/alhai_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:customer_app/core/utils/currency_formatter.dart';

void main() {
  setUpAll(() async {
    // NumberFormat.currency with the 'ar_SA' locale needs the intl locale
    // data initialised; otherwise the call throws LocaleDataException on the
    // test isolate.
    await initializeDateFormatting('ar_SA');
  });

  group('CurrencyFormatter.formatMoney', () {
    test('formats SAR Money with the Arabic-Indic locale by default', () {
      final out = CurrencyFormatter.formatMoney(const Money.sar(10000));
      // 100.00 in ar_SA renders as "١٠٠٫٠٠" + currency symbol. We only assert
      // the symbol is present — the digit rendering is locale-owned.
      expect(out.contains('ر.س'), isTrue, reason: 'SAR symbol must appear');
      expect(out.isNotEmpty, isTrue);
    });

    test('formats in en locale with ASCII digits when asked', () {
      final out = CurrencyFormatter.formatMoney(
        const Money.sar(10050),
        locale: 'en',
      );
      expect(out.contains('100.50'), isTrue);
      expect(out.contains('ر.س'), isTrue);
    });

    test('respects custom decimalDigits', () {
      final out = CurrencyFormatter.formatMoney(
        const Money.sar(12345),
        locale: 'en',
        decimalDigits: 0,
      );
      // 123.45 with decimalDigits: 0 → "123" (no fractional component).
      // Note: the currency symbol "ر.س" itself contains dots, so we cannot
      // assert on raw `contains('.')` — instead, assert no `.NN` tail.
      expect(out.contains('123'), isTrue);
      expect(RegExp(r'\d\.\d').hasMatch(out), isFalse);
    });

    test('round-trips zero cents as zero display', () {
      final out = CurrencyFormatter.formatMoney(
        const Money.sar(0),
        locale: 'en',
      );
      expect(out.contains('0'), isTrue);
    });

    test('handles non-SAR currency by falling through to code as symbol', () {
      final usd = Money.fromCents(10000, currencyCode: 'USD');
      final out = CurrencyFormatter.formatMoney(usd, locale: 'en');
      expect(out.contains('USD'), isTrue);
    });
  });

  group('CurrencyFormatter.formatSar', () {
    test('formats a raw double with the SAR symbol', () {
      final out = CurrencyFormatter.formatSar(50.5, locale: 'en');
      expect(out.contains('50.50'), isTrue);
      expect(out.contains('ر.س'), isTrue);
    });
  });
}
