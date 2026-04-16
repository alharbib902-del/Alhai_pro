import 'package:flutter_test/flutter_test.dart';
import 'package:distributor_portal/core/utils/vat_calculator.dart';

void main() {
  group('VatCalculator', () {
    test('saudiVatRate is 15%', () {
      expect(VatCalculator.saudiVatRate, 0.15);
    });

    test('withVat adds 15% to subtotal', () {
      expect(VatCalculator.withVat(100.0), closeTo(115.0, 0.01));
      expect(VatCalculator.withVat(200.0), closeTo(230.0, 0.01));
      expect(VatCalculator.withVat(0.0), 0.0);
    });

    test('vatAmount calculates 15% of subtotal', () {
      expect(VatCalculator.vatAmount(100.0), closeTo(15.0, 0.01));
      expect(VatCalculator.vatAmount(200.0), closeTo(30.0, 0.01));
      expect(VatCalculator.vatAmount(0.0), 0.0);
    });

    test('extractSubtotal removes VAT from total', () {
      expect(VatCalculator.extractSubtotal(115.0), closeTo(100.0, 0.01));
      expect(VatCalculator.extractSubtotal(230.0), closeTo(200.0, 0.01));
      expect(VatCalculator.extractSubtotal(0.0), 0.0);
    });

    test('withVat and extractSubtotal are inverse operations', () {
      const subtotal = 1234.56;
      final total = VatCalculator.withVat(subtotal);
      final recovered = VatCalculator.extractSubtotal(total);
      expect(recovered, closeTo(subtotal, 0.01));
    });

    test('breakdown returns correct map', () {
      final result = VatCalculator.breakdown(100.0);
      expect(result['subtotal'], 100.0);
      expect(result['vat'], closeTo(15.0, 0.01));
      expect(result['total'], closeTo(115.0, 0.01));
    });

    test('breakdown with zero subtotal', () {
      final result = VatCalculator.breakdown(0.0);
      expect(result['subtotal'], 0.0);
      expect(result['vat'], 0.0);
      expect(result['total'], 0.0);
    });

    test('breakdown vat + subtotal equals total', () {
      final result = VatCalculator.breakdown(999.99);
      expect(
        result['subtotal']! + result['vat']!,
        closeTo(result['total']!, 0.01),
      );
    });

    test('handles large amounts correctly', () {
      const large = 999999.99;
      final vat = VatCalculator.vatAmount(large);
      expect(vat, closeTo(150000.0, 1.0));
      expect(VatCalculator.withVat(large), closeTo(1149999.99, 0.01));
    });
  });
}
