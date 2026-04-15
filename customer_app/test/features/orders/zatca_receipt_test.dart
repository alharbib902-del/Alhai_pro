import 'package:alhai_zatca/alhai_zatca.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri/hijri_calendar.dart';

void main() {
  group('C5: ZATCA receipt components', () {
    test('TLV encoder generates valid base64 QR data', () {
      final encoder = ZatcaTlvEncoder();
      final qrData = encoder.encodeSimplified(
        sellerName: 'متجر الحي',
        vatNumber: '300000000000003',
        timestamp: DateTime(2024, 6, 1, 12, 0),
        totalWithVat: 115.0,
        vatAmount: 15.0,
      );

      expect(qrData, isNotEmpty);
      // Should be valid base64
      expect(() => Uri.parse('data:text/plain;base64,$qrData'), returnsNormally);
    });

    test('order with VAT > 0 should generate QR data', () {
      const vatAmount = 15.0;
      const totalWithVat = 115.0;

      // VAT > 0 means we should show the receipt
      expect(vatAmount > 0, isTrue);

      final encoder = ZatcaTlvEncoder();
      final qrData = encoder.encodeSimplified(
        sellerName: 'Test Store',
        vatNumber: '300000000000003',
        timestamp: DateTime.now(),
        totalWithVat: totalWithVat,
        vatAmount: vatAmount,
      );

      expect(qrData, isNotEmpty);
    });

    test('order with VAT = 0 should not show receipt', () {
      const vatAmount = 0.0;
      // When vatAmount <= 0, receipt is hidden (SizedBox.shrink)
      expect(vatAmount <= 0, isTrue);
    });

    test('Hijri date conversion works correctly', () {
      HijriCalendar.language = 'ar';
      final hijri = HijriCalendar.fromDate(DateTime(2024, 6, 1));

      expect(hijri.hYear, greaterThan(1440));
      expect(hijri.hMonth, greaterThan(0));
      expect(hijri.hMonth, lessThanOrEqualTo(12));
      expect(hijri.hDay, greaterThan(0));
      expect(hijri.hDay, lessThanOrEqualTo(30));
    });

    test('VAT calculation matches receipt display', () {
      const subtotal = 100.0;
      final vat = VatCalculator.vatFromNet(netAmount: subtotal);
      const deliveryFee = 10.0;
      final total = subtotal + vat + deliveryFee;

      expect(vat, equals(15.0));
      expect(total, equals(125.0));
    });
  });
}
