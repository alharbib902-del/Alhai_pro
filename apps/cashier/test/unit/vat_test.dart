import 'package:flutter_test/flutter_test.dart';
import 'package:cashier/services/zatca/vat_calculator.dart';

void main() {
  // ==========================================================================
  // calculateVat — مبلغ الضريبة من المبلغ قبل الضريبة
  // ==========================================================================
  group('VatCalculator.calculateVat', () {
    test('15% of 100 = 15', () {
      expect(VatCalculator.calculateVat(100), closeTo(15.0, 0.001));
    });

    test('15% of 200 = 30', () {
      expect(VatCalculator.calculateVat(200), closeTo(30.0, 0.001));
    });

    test('15% of 1 = 0.15', () {
      expect(VatCalculator.calculateVat(1), closeTo(0.15, 0.001));
    });

    test('15% of 0 = 0', () {
      expect(VatCalculator.calculateVat(0), equals(0.0));
    });

    test('15% of 33.33 (fractional)', () {
      expect(VatCalculator.calculateVat(33.33), closeTo(4.9995, 0.001));
    });

    test('15% of 0.01 (small amount)', () {
      expect(VatCalculator.calculateVat(0.01), closeTo(0.0015, 0.0001));
    });

    test('15% of 999999 (large amount)', () {
      expect(VatCalculator.calculateVat(999999), closeTo(149999.85, 0.01));
    });

    test('custom rate 5% of 100 = 5', () {
      expect(VatCalculator.calculateVat(100, rate: 0.05), closeTo(5.0, 0.001));
    });

    test('custom rate 10% of 100 = 10', () {
      expect(VatCalculator.calculateVat(100, rate: 0.10), closeTo(10.0, 0.001));
    });

    test('custom rate 0% = no tax', () {
      expect(VatCalculator.calculateVat(100, rate: 0.0), equals(0.0));
    });
  });

  // ==========================================================================
  // addVat — المبلغ شامل الضريبة
  // ==========================================================================
  group('VatCalculator.addVat', () {
    test('100 + 15% = 115', () {
      expect(VatCalculator.addVat(100), closeTo(115.0, 0.001));
    });

    test('200 + 15% = 230', () {
      expect(VatCalculator.addVat(200), closeTo(230.0, 0.001));
    });

    test('0 + 15% = 0', () {
      expect(VatCalculator.addVat(0), equals(0.0));
    });

    test('50 + 10% = 55', () {
      expect(VatCalculator.addVat(50, rate: 0.10), closeTo(55.0, 0.001));
    });

    test('fractional amount: 33.33 + 15%', () {
      expect(VatCalculator.addVat(33.33), closeTo(38.3295, 0.001));
    });
  });

  // ==========================================================================
  // removeVat — استخراج المبلغ قبل الضريبة من الإجمالي
  // ==========================================================================
  group('VatCalculator.removeVat', () {
    test('115 → 100 (reverse 15%)', () {
      expect(VatCalculator.removeVat(115), closeTo(100.0, 0.01));
    });

    test('230 → 200', () {
      expect(VatCalculator.removeVat(230), closeTo(200.0, 0.01));
    });

    test('0 → 0', () {
      expect(VatCalculator.removeVat(0), equals(0.0));
    });

    test('57.5 → 50', () {
      expect(VatCalculator.removeVat(57.5), closeTo(50.0, 0.01));
    });

    test('roundtrip: addVat then removeVat returns original', () {
      const original = 123.45;
      final withVat = VatCalculator.addVat(original);
      final backToOriginal = VatCalculator.removeVat(withVat);
      expect(backToOriginal, closeTo(original, 0.01));
    });
  });

  // ==========================================================================
  // extractVat — استخراج مبلغ الضريبة من الإجمالي شامل الضريبة
  // ==========================================================================
  group('VatCalculator.extractVat', () {
    test('from 115 → VAT = 15', () {
      expect(VatCalculator.extractVat(115), closeTo(15.0, 0.01));
    });

    test('from 230 → VAT = 30', () {
      expect(VatCalculator.extractVat(230), closeTo(30.0, 0.01));
    });

    test('from 0 → VAT = 0', () {
      expect(VatCalculator.extractVat(0), equals(0.0));
    });

    test('from 57.5 → VAT = 7.5', () {
      expect(VatCalculator.extractVat(57.5), closeTo(7.5, 0.01));
    });

    test('extractVat + removeVat = original total', () {
      const total = 345.0;
      final vat = VatCalculator.extractVat(total);
      final beforeVat = VatCalculator.removeVat(total);
      expect(vat + beforeVat, closeTo(total, 0.01));
    });
  });

  // ==========================================================================
  // breakdown — تفاصيل الفاتورة الكاملة
  // ==========================================================================
  group('VatCalculator.breakdown', () {
    test('simple breakdown without discount', () {
      final b = VatCalculator.breakdown(100);

      expect(b.subtotal, equals(100));
      expect(b.discount, equals(0));
      expect(b.taxableAmount, equals(100));
      expect(b.vatRate, equals(0.15));
      expect(b.vatAmount, closeTo(15.0, 0.001));
      expect(b.total, closeTo(115.0, 0.001));
    });

    test('breakdown with flat discount', () {
      final b = VatCalculator.breakdown(100, discount: 20);

      expect(b.subtotal, equals(100));
      expect(b.discount, equals(20));
      expect(b.taxableAmount, equals(80));
      expect(b.vatAmount, closeTo(12.0, 0.001));
      expect(b.total, closeTo(92.0, 0.001));
    });

    test('breakdown with full discount (free)', () {
      final b = VatCalculator.breakdown(100, discount: 100);

      expect(b.taxableAmount, equals(0));
      expect(b.vatAmount, equals(0.0));
      expect(b.total, equals(0.0));
    });

    test('breakdown with custom rate', () {
      final b = VatCalculator.breakdown(200, rate: 0.10);

      expect(b.vatRate, equals(0.10));
      expect(b.vatAmount, closeTo(20.0, 0.001));
      expect(b.total, closeTo(220.0, 0.001));
    });

    test('breakdown with discount + custom rate', () {
      final b = VatCalculator.breakdown(500, discount: 50, rate: 0.10);

      expect(b.taxableAmount, equals(450));
      expect(b.vatAmount, closeTo(45.0, 0.001));
      expect(b.total, closeTo(495.0, 0.001));
    });

    test('breakdown total = taxableAmount + vatAmount', () {
      final b = VatCalculator.breakdown(333.33, discount: 33.33);

      expect(b.total, closeTo(b.taxableAmount + b.vatAmount, 0.001));
    });

    test('rounding: SAR amounts should be reasonable', () {
      // 49.99 subtotal, 15% VAT = 7.4985 VAT → ~57.49
      final b = VatCalculator.breakdown(49.99);

      expect(b.vatAmount, closeTo(7.4985, 0.001));
      expect(b.total, closeTo(57.4885, 0.001));
    });

    test('common POS amounts', () {
      // 9.99 SAR item
      final b1 = VatCalculator.breakdown(9.99);
      expect(b1.vatAmount, closeTo(1.4985, 0.001));

      // 250 SAR item
      final b2 = VatCalculator.breakdown(250);
      expect(b2.vatAmount, closeTo(37.5, 0.001));
      expect(b2.total, closeTo(287.5, 0.001));
    });
  });
}
