import 'package:alhai_zatca/alhai_zatca.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('C4: VAT calculation using VatCalculator', () {
    test('100 SAR subtotal → 15 SAR VAT at 15%', () {
      final vat = VatCalculator.vatFromNet(netAmount: 100.0);
      expect(vat, equals(15.0));
    });

    test('200 SAR subtotal → 30 SAR VAT', () {
      final vat = VatCalculator.vatFromNet(netAmount: 200.0);
      expect(vat, equals(30.0));
    });

    test('total = subtotal + VAT + delivery', () {
      const subtotal = 100.0;
      const deliveryFee = 10.0;
      final vat = VatCalculator.vatFromNet(netAmount: subtotal);
      final total = subtotal + vat + deliveryFee;
      expect(total, equals(125.0));
    });

    test('zero subtotal → zero VAT', () {
      final vat = VatCalculator.vatFromNet(netAmount: 0.0);
      expect(vat, equals(0.0));
    });

    test('fractional amount rounds correctly', () {
      // 33.33 * 0.15 = 4.9995 → rounds to 5.00
      final vat = VatCalculator.vatFromNet(netAmount: 33.33);
      expect(vat, equals(5.0));
    });

    test('breakdownFromNet provides consistent net + vat = gross', () {
      final breakdown = VatCalculator.breakdownFromNet(netAmount: 100.0);
      expect(breakdown.netAmount, equals(100.0));
      expect(breakdown.vatAmount, equals(15.0));
      expect(breakdown.grossAmount, equals(115.0));
      expect(breakdown.vatRate, equals(15.0));
    });
  });
}
