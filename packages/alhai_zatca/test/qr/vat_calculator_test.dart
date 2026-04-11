import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/qr/vat_calculator.dart';

void main() {
  group('VatCalculator', () {
    // ── Constants ────────────────────────────────────────

    group('constants', () {
      test('standardRate is 15.0 (Saudi VAT rate)', () {
        expect(VatCalculator.standardRate, 15.0);
      });

      test('zeroRate is 0.0', () {
        expect(VatCalculator.zeroRate, 0.0);
      });
    });

    // ── addVat ───────────────────────────────────────────

    group('addVat', () {
      test('adds 15% VAT to 100 to produce 115', () {
        expect(VatCalculator.addVat(netAmount: 100.0), 115.0);
      });

      test('adds 15% VAT to 200 to produce 230', () {
        expect(VatCalculator.addVat(netAmount: 200.0), 230.0);
      });

      test('supports custom VAT rate', () {
        expect(VatCalculator.addVat(netAmount: 100.0, vatRate: 10.0), 110.0);
      });

      test('returns unchanged amount for zero rate', () {
        expect(VatCalculator.addVat(netAmount: 100.0, vatRate: 0.0), 100.0);
      });

      test('rounds to 2 decimal places', () {
        // 33.33 * 1.15 = 38.3295 → rounds to 38.33
        expect(VatCalculator.addVat(netAmount: 33.33), 38.33);
      });
    });

    // ── removeVat ────────────────────────────────────────

    group('removeVat', () {
      test('removes 15% VAT from 115 to produce 100', () {
        expect(VatCalculator.removeVat(grossAmount: 115.0), 100.0);
      });

      test('removes 15% VAT from 230 to produce 200', () {
        expect(VatCalculator.removeVat(grossAmount: 230.0), 200.0);
      });

      test('supports custom VAT rate', () {
        expect(
          VatCalculator.removeVat(grossAmount: 110.0, vatRate: 10.0),
          100.0,
        );
      });

      test('returns unchanged amount for zero rate', () {
        expect(
          VatCalculator.removeVat(grossAmount: 100.0, vatRate: 0.0),
          100.0,
        );
      });
    });

    // ── extractVat ───────────────────────────────────────

    group('extractVat', () {
      test('extracts 15 from 115', () {
        expect(VatCalculator.extractVat(grossAmount: 115.0), 15.0);
      });

      test('extracts 30 from 230', () {
        expect(VatCalculator.extractVat(grossAmount: 230.0), 30.0);
      });

      test('returns 0 for zero rate', () {
        expect(VatCalculator.extractVat(grossAmount: 100.0, vatRate: 0.0), 0.0);
      });
    });

    // ── vatFromNet ───────────────────────────────────────

    group('vatFromNet', () {
      test('calculates 15 VAT from 100 net', () {
        expect(VatCalculator.vatFromNet(netAmount: 100.0), 15.0);
      });

      test('calculates 30 VAT from 200 net', () {
        expect(VatCalculator.vatFromNet(netAmount: 200.0), 30.0);
      });

      test('returns 0 for zero rate (zero-rated items)', () {
        expect(VatCalculator.vatFromNet(netAmount: 100.0, vatRate: 0.0), 0.0);
      });

      test('returns 0 for exempt items (rate=0)', () {
        expect(VatCalculator.vatFromNet(netAmount: 500.0, vatRate: 0.0), 0.0);
      });

      test('rounds to 2 decimals for fractional rates', () {
        // 100 * 7.5 / 100 = 7.5
        expect(VatCalculator.vatFromNet(netAmount: 100.0, vatRate: 7.5), 7.5);
      });
    });

    // ── vatFromGross / netFromGross ──────────────────────

    group('vatFromGross', () {
      test('extracts 15 from gross 115', () {
        expect(VatCalculator.vatFromGross(grossAmount: 115.0), 15.0);
      });

      test('handles repeating decimal gracefully', () {
        // 10 / 1.15 ≈ 8.695652...  → net=8.70, vat=1.30
        final vat = VatCalculator.vatFromGross(grossAmount: 10.0);
        expect(vat, closeTo(1.30, 0.01));
      });
    });

    group('netFromGross', () {
      test('calculates net 100 from gross 115', () {
        expect(VatCalculator.netFromGross(grossAmount: 115.0), 100.0);
      });

      test('calculates net 200 from gross 230', () {
        expect(VatCalculator.netFromGross(grossAmount: 230.0), 200.0);
      });
    });

    // ── grossFromNet ─────────────────────────────────────

    group('grossFromNet', () {
      test('calculates gross 115 from net 100', () {
        expect(VatCalculator.grossFromNet(netAmount: 100.0), 115.0);
      });

      test('calculates gross 230 from net 200', () {
        expect(VatCalculator.grossFromNet(netAmount: 200.0), 230.0);
      });
    });

    // ── breakdownFromNet ─────────────────────────────────

    group('breakdownFromNet', () {
      test('returns correct breakdown for standard rate', () {
        final b = VatCalculator.breakdownFromNet(netAmount: 100.0);
        expect(b.netAmount, 100.0);
        expect(b.vatAmount, 15.0);
        expect(b.grossAmount, 115.0);
        expect(b.vatRate, 15.0);
      });

      test('handles zero-rated items', () {
        final b = VatCalculator.breakdownFromNet(
          netAmount: 100.0,
          vatRate: 0.0,
        );
        expect(b.netAmount, 100.0);
        expect(b.vatAmount, 0.0);
        expect(b.grossAmount, 100.0);
      });

      test('net + vat equals gross within rounding tolerance', () {
        final b = VatCalculator.breakdownFromNet(netAmount: 33.33);
        expect(
          VatCalculator.validateTotals(
            netAmount: b.netAmount,
            vatAmount: b.vatAmount,
            grossAmount: b.grossAmount,
          ),
          isTrue,
        );
      });
    });

    // ── breakdownFromGross ───────────────────────────────

    group('breakdownFromGross', () {
      test('returns correct breakdown for gross 115', () {
        final b = VatCalculator.breakdownFromGross(grossAmount: 115.0);
        expect(b.netAmount, 100.0);
        expect(b.vatAmount, 15.0);
        expect(b.grossAmount, 115.0);
      });

      test('handles gross with zero rate', () {
        final b = VatCalculator.breakdownFromGross(
          grossAmount: 100.0,
          vatRate: 0.0,
        );
        expect(b.netAmount, 100.0);
        expect(b.vatAmount, 0.0);
        expect(b.grossAmount, 100.0);
      });
    });

    // ── lineBreakdown ────────────────────────────────────

    group('lineBreakdown', () {
      test('quantity * unitPrice with standard rate', () {
        final b = VatCalculator.lineBreakdown(unitPrice: 50.0, quantity: 2);
        expect(b.netAmount, 100.0);
        expect(b.vatAmount, 15.0);
        expect(b.grossAmount, 115.0);
      });

      test('applies discount before VAT', () {
        // 50 * 3 - 10 = 140 net, 21 vat, 161 gross
        final b = VatCalculator.lineBreakdown(
          unitPrice: 50.0,
          quantity: 3,
          discount: 10.0,
        );
        expect(b.netAmount, 140.0);
        expect(b.vatAmount, 21.0);
        expect(b.grossAmount, 161.0);
      });

      test('handles fractional quantity', () {
        final b = VatCalculator.lineBreakdown(unitPrice: 100.0, quantity: 1.5);
        expect(b.netAmount, 150.0);
        expect(b.vatAmount, 22.5);
      });
    });

    // ── validateTotals ───────────────────────────────────

    group('validateTotals', () {
      test('accepts matching totals', () {
        expect(
          VatCalculator.validateTotals(
            netAmount: 100.0,
            vatAmount: 15.0,
            grossAmount: 115.0,
          ),
          isTrue,
        );
      });

      test('accepts small rounding differences within tolerance', () {
        expect(
          VatCalculator.validateTotals(
            netAmount: 100.005,
            vatAmount: 15.0,
            grossAmount: 115.0,
          ),
          isTrue,
        );
      });

      test('rejects totals that differ beyond tolerance', () {
        expect(
          VatCalculator.validateTotals(
            netAmount: 100.0,
            vatAmount: 15.0,
            grossAmount: 120.0,
          ),
          isFalse,
        );
      });
    });

    // ── validateVatAmount ────────────────────────────────

    group('validateVatAmount', () {
      test('accepts correct VAT for standard rate', () {
        expect(
          VatCalculator.validateVatAmount(netAmount: 100.0, vatAmount: 15.0),
          isTrue,
        );
      });

      test('rejects VAT that does not match rate', () {
        expect(
          VatCalculator.validateVatAmount(netAmount: 100.0, vatAmount: 10.0),
          isFalse,
        );
      });

      test('accepts within tolerance', () {
        expect(
          VatCalculator.validateVatAmount(netAmount: 100.0, vatAmount: 15.005),
          isTrue,
        );
      });
    });

    // ── sumBreakdowns (multi-item totals) ────────────────

    group('sumBreakdowns', () {
      test('sums empty list to zeros', () {
        final result = VatCalculator.sumBreakdowns([]);
        expect(result.netAmount, 0.0);
        expect(result.vatAmount, 0.0);
        expect(result.grossAmount, 0.0);
      });

      test('sums single breakdown to itself', () {
        final b = VatCalculator.breakdownFromNet(netAmount: 100.0);
        final result = VatCalculator.sumBreakdowns([b]);
        expect(result.netAmount, 100.0);
        expect(result.vatAmount, 15.0);
        expect(result.grossAmount, 115.0);
      });

      test('sums multiple items correctly', () {
        final b1 = VatCalculator.breakdownFromNet(netAmount: 100.0);
        final b2 = VatCalculator.breakdownFromNet(netAmount: 200.0);
        final b3 = VatCalculator.breakdownFromNet(netAmount: 50.0);

        final result = VatCalculator.sumBreakdowns([b1, b2, b3]);
        expect(result.netAmount, 350.0);
        expect(result.vatAmount, 52.5);
        expect(result.grossAmount, 402.5);
      });

      test('preserves standard rate when summing', () {
        final b1 = VatCalculator.breakdownFromNet(netAmount: 100.0);
        final b2 = VatCalculator.breakdownFromNet(netAmount: 200.0);
        final result = VatCalculator.sumBreakdowns([b1, b2]);
        expect(result.vatRate, VatCalculator.standardRate);
      });
    });

    // ── rounding edge cases ──────────────────────────────

    group('rounding edge cases', () {
      test('rounds 0.005 up to 0.01', () {
        // 100 * 0.005 = 0.5, but because we multiply by 100 first: (0.005*100).round()/100 = 1/100 = 0.01
        final vat = VatCalculator.vatFromNet(netAmount: 1 / 3, vatRate: 1.5);
        // 0.3333... * 0.015 = 0.005 → 0.01
        expect(vat, closeTo(0.01, 0.001));
      });

      test('handles large amounts without overflow', () {
        final vat = VatCalculator.vatFromNet(netAmount: 1000000.0);
        expect(vat, 150000.0);
      });

      test('handles very small amounts', () {
        final vat = VatCalculator.vatFromNet(netAmount: 0.10);
        // 0.1 * 0.15 = 0.015 → rounds to 0.02
        expect(vat, closeTo(0.02, 0.001));
      });

      test('handles zero amount', () {
        final vat = VatCalculator.vatFromNet(netAmount: 0.0);
        expect(vat, 0.0);
      });
    });

    // ── VatBreakdown ─────────────────────────────────────

    group('VatBreakdown', () {
      test('toString contains all amounts', () {
        const b = VatBreakdown(
          netAmount: 100.0,
          vatAmount: 15.0,
          grossAmount: 115.0,
          vatRate: 15.0,
        );
        final str = b.toString();
        expect(str, contains('100'));
        expect(str, contains('15'));
        expect(str, contains('115'));
      });
    });
  });
}
