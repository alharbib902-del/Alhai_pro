import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/models/zatca_invoice_line.dart';

void main() {
  group('ZatcaInvoiceLine', () {
    // ── Construction ─────────────────────────────────────

    group('construction', () {
      test('creates with required fields', () {
        final line = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Widget',
          quantity: 2,
          unitPrice: 50.0,
          vatRate: 15.0,
        );
        expect(line.lineId, '1');
        expect(line.itemName, 'Widget');
        expect(line.quantity, 2);
        expect(line.unitPrice, 50.0);
        expect(line.vatRate, 15.0);
      });

      test('defaults unitCode to PCE', () {
        final line = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Widget',
          quantity: 1,
          unitPrice: 10.0,
          vatRate: 15.0,
        );
        expect(line.unitCode, 'PCE');
      });

      test('defaults vatCategoryCode to S (standard)', () {
        final line = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Widget',
          quantity: 1,
          unitPrice: 10.0,
          vatRate: 15.0,
        );
        expect(line.vatCategoryCode, 'S');
      });

      test('defaults discountAmount to 0.0', () {
        final line = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Widget',
          quantity: 1,
          unitPrice: 10.0,
          vatRate: 15.0,
        );
        expect(line.discountAmount, 0.0);
      });

      test('stores optional fields when provided', () {
        final line = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Widget',
          quantity: 1,
          unitCode: 'KGM',
          unitPrice: 10.0,
          grossPrice: 12.0,
          discountAmount: 2.0,
          discountReason: 'Promo',
          vatRate: 15.0,
          vatCategoryCode: 'Z',
          vatExemptionReason: 'Zero-rated export',
          vatExemptionReasonCode: 'VATEX-SA-HEA',
          barcode: '1234567890',
          sellerItemId: 'SKU-001',
        );

        expect(line.unitCode, 'KGM');
        expect(line.grossPrice, 12.0);
        expect(line.discountAmount, 2.0);
        expect(line.discountReason, 'Promo');
        expect(line.vatCategoryCode, 'Z');
        expect(line.vatExemptionReason, 'Zero-rated export');
        expect(line.vatExemptionReasonCode, 'VATEX-SA-HEA');
        expect(line.barcode, '1234567890');
        expect(line.sellerItemId, 'SKU-001');
      });
    });

    // ── Computed values ──────────────────────────────────

    group('computed totals', () {
      test('lineNetAmount = quantity * unitPrice when no discount', () {
        final line = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Widget',
          quantity: 3,
          unitPrice: 20.0,
          vatRate: 15.0,
        );
        expect(line.lineNetAmount, 60.0);
      });

      test('lineNetAmount subtracts discountAmount', () {
        final line = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Widget',
          quantity: 3,
          unitPrice: 20.0,
          vatRate: 15.0,
          discountAmount: 10.0,
        );
        expect(line.lineNetAmount, 50.0);
      });

      test('vatAmount = lineNetAmount * vatRate / 100', () {
        final line = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Widget',
          quantity: 2,
          unitPrice: 100.0,
          vatRate: 15.0,
        );
        expect(line.vatAmount, 30.0);
      });

      test('vatAmount is zero when vatRate is zero', () {
        final line = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Widget',
          quantity: 2,
          unitPrice: 100.0,
          vatRate: 0.0,
          vatCategoryCode: 'Z',
        );
        expect(line.vatAmount, 0.0);
      });

      test('lineTotal = lineNetAmount + vatAmount', () {
        final line = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Widget',
          quantity: 2,
          unitPrice: 100.0,
          vatRate: 15.0,
        );
        expect(line.lineTotal, 230.0);
      });

      test('handles zero quantity', () {
        final line = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Widget',
          quantity: 0,
          unitPrice: 100.0,
          vatRate: 15.0,
        );
        expect(line.lineNetAmount, 0.0);
        expect(line.vatAmount, 0.0);
        expect(line.lineTotal, 0.0);
      });

      test('handles fractional quantity', () {
        final line = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Cheese',
          quantity: 0.5,
          unitCode: 'KGM',
          unitPrice: 40.0,
          vatRate: 15.0,
        );
        expect(line.lineNetAmount, 20.0);
        expect(line.vatAmount, 3.0);
        expect(line.lineTotal, 23.0);
      });
    });

    // ── Rounding helpers ─────────────────────────────────

    group('rounding helpers', () {
      test('lineNetAmountRounded rounds to 2 decimal places', () {
        final line = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Item',
          quantity: 3,
          unitPrice: 33.333,
          vatRate: 15.0,
        );
        // 3 * 33.333 = 99.999 -> 100.00
        expect(line.lineNetAmountRounded, 100.00);
      });

      test('vatAmountRounded rounds to 2 decimal places', () {
        final line = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Item',
          quantity: 1,
          unitPrice: 33.33,
          vatRate: 15.0,
        );
        // VAT: 33.33 * 0.15 = 4.9995 -> 5.00
        expect(line.vatAmountRounded, 5.00);
      });

      test('rounded values keep exact 2-decimal totals', () {
        final line = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Item',
          quantity: 2,
          unitPrice: 100.0,
          vatRate: 15.0,
        );
        expect(line.lineNetAmountRounded, 200.00);
        expect(line.vatAmountRounded, 30.00);
      });
    });

    // ── copyWith ─────────────────────────────────────────

    group('copyWith', () {
      test('returns identical copy when no arguments given', () {
        final original = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Widget',
          quantity: 2,
          unitPrice: 50.0,
          vatRate: 15.0,
          barcode: '1234',
        );
        final copy = original.copyWith();
        expect(copy.lineId, original.lineId);
        expect(copy.itemName, original.itemName);
        expect(copy.quantity, original.quantity);
        expect(copy.unitPrice, original.unitPrice);
        expect(copy.barcode, original.barcode);
      });

      test('updates only specified fields', () {
        final original = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Widget',
          quantity: 2,
          unitPrice: 50.0,
          vatRate: 15.0,
        );
        final updated = original.copyWith(
          quantity: 5,
          discountAmount: 10.0,
        );
        expect(updated.quantity, 5);
        expect(updated.discountAmount, 10.0);
        // Unchanged
        expect(updated.lineId, original.lineId);
        expect(updated.unitPrice, original.unitPrice);
      });
    });

    // ── Serialization ────────────────────────────────────

    group('toJson / fromJson', () {
      test('roundtrips with required fields', () {
        final line = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Widget',
          quantity: 2,
          unitPrice: 50.0,
          vatRate: 15.0,
        );
        final json = line.toJson();
        final restored = ZatcaInvoiceLine.fromJson(json);

        expect(restored.lineId, line.lineId);
        expect(restored.itemName, line.itemName);
        expect(restored.quantity, line.quantity);
        expect(restored.unitPrice, line.unitPrice);
        expect(restored.vatRate, line.vatRate);
        expect(restored.unitCode, 'PCE');
        expect(restored.vatCategoryCode, 'S');
        expect(restored.discountAmount, 0.0);
      });

      test('roundtrips with all optional fields', () {
        final line = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Widget',
          quantity: 2,
          unitCode: 'KGM',
          unitPrice: 50.0,
          grossPrice: 55.0,
          discountAmount: 5.0,
          discountReason: 'Promo',
          vatRate: 15.0,
          vatCategoryCode: 'Z',
          vatExemptionReason: 'Zero-rated',
          vatExemptionReasonCode: 'VATEX-SA-HEA',
          barcode: '1234567890',
          sellerItemId: 'SKU-001',
        );
        final json = line.toJson();
        final restored = ZatcaInvoiceLine.fromJson(json);

        expect(restored.unitCode, 'KGM');
        expect(restored.grossPrice, 55.0);
        expect(restored.discountAmount, 5.0);
        expect(restored.discountReason, 'Promo');
        expect(restored.vatCategoryCode, 'Z');
        expect(restored.vatExemptionReason, 'Zero-rated');
        expect(restored.vatExemptionReasonCode, 'VATEX-SA-HEA');
        expect(restored.barcode, '1234567890');
        expect(restored.sellerItemId, 'SKU-001');
      });

      test('toJson omits null optional fields', () {
        final line = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Widget',
          quantity: 1,
          unitPrice: 10.0,
          vatRate: 15.0,
        );
        final json = line.toJson();
        expect(json.containsKey('grossPrice'), isFalse);
        expect(json.containsKey('discountReason'), isFalse);
        expect(json.containsKey('vatExemptionReason'), isFalse);
        expect(json.containsKey('barcode'), isFalse);
        expect(json.containsKey('sellerItemId'), isFalse);
      });

      test('fromJson handles numeric values passed as int', () {
        final json = <String, dynamic>{
          'lineId': '1',
          'itemName': 'Widget',
          'quantity': 2,
          'unitPrice': 50,
          'vatRate': 15,
        };
        final line = ZatcaInvoiceLine.fromJson(json);
        expect(line.quantity, 2.0);
        expect(line.unitPrice, 50.0);
        expect(line.vatRate, 15.0);
      });

      test('fromJson applies defaults for missing optional fields', () {
        final json = <String, dynamic>{
          'lineId': '1',
          'itemName': 'Widget',
          'quantity': 1.0,
          'unitPrice': 10.0,
          'vatRate': 15.0,
        };
        final line = ZatcaInvoiceLine.fromJson(json);
        expect(line.unitCode, 'PCE');
        expect(line.vatCategoryCode, 'S');
        expect(line.discountAmount, 0.0);
      });

      test('handles Arabic item names', () {
        final line = ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'منتج اختبار',
          quantity: 1,
          unitPrice: 100.0,
          vatRate: 15.0,
        );
        final json = line.toJson();
        final restored = ZatcaInvoiceLine.fromJson(json);
        expect(restored.itemName, 'منتج اختبار');
      });
    });

    // ── Smoke test ───────────────────────────────────────

    test('toString does not throw', () {
      final line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Widget',
        quantity: 1,
        unitPrice: 10.0,
        vatRate: 15.0,
      );
      expect(line.toString(), isNotEmpty);
    });
  });
}
