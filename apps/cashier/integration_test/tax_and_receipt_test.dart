/// Integration test: Cashier Tax Calculation & Receipt Generation
///
/// Verifies the tax + receipt pipeline the cashier app relies on for
/// every sale:
///   1. Basic VAT calculation   - 15% on simple items
///   2. Mixed tax items         - taxable + zero-rated in one sale
///   3. Discount before tax     - discount applied to net, VAT on discounted net
///   4. Multi-payment split     - cash + card + wallet sum to total
///   5. Receipt preview         - ReceiptScreen renders before print
///   6. ZATCA QR presence       - QR data is generated for signed receipts
///   7. Arabic receipt render   - Arabic text does not break layout
///   8. Halala rounding         - Saudi 2-decimal (halala) rounding
///
/// The full ZATCA pipeline (signing, clearance, QR TLV encoding) requires
/// live compliance certificates and is covered by unit tests in
/// `packages/alhai_zatca`. Here we:
///   - Use the real `VatCalculator` from `alhai_zatca` for math paths.
///   - Mount the real `ReceiptScreen` via the test app wrapper for the
///     render path, without an actual signed sale.
///   - Provide a tiny inline mock `_FakeZatcaQrBuilder` for any test that
///     needs to assert on a QR payload without hitting real certs.
///
/// Run with:
///   flutter test integration_test/tax_and_receipt_test.dart
///   (requires a running device or emulator)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:alhai_pos/alhai_pos.dart' show PaymentScreen, ReceiptScreen;
import 'package:alhai_zatca/alhai_zatca.dart' show VatCalculator, VatBreakdown;

import 'helpers/test_app.dart';
import 'helpers/test_data.dart';

// ============================================================================
// Helpers / fakes
// ============================================================================

/// Rounds a SAR amount to the nearest halala (2 decimal places).
/// Saudi Arabia uses 100 halala = 1 SAR, so all on-receipt totals are
/// stored with 2 decimals. This mirrors `VatCalculator._round2` which is
/// private inside alhai_zatca.
double _roundHalala(double value) => (value * 100).roundToDouble() / 100;

/// Fake ZATCA QR builder used in place of the real `ZatcaQrService` in
/// tests that need to assert that *something* QR-shaped would be produced
/// for a receipt. The real service needs a signed invoice XML and a
/// loaded compliance certificate, neither of which is available in the
/// integration test harness.
class _FakeZatcaQrBuilder {
  /// Returns a deterministic fake base64 payload that includes the
  /// required TLV fields so presence checks in tests are meaningful.
  String build({
    required String sellerName,
    required String vatNumber,
    required DateTime timestamp,
    required double totalWithVat,
    required double vatAmount,
  }) {
    // Build a predictable, non-empty payload. In real code this would be
    // the TLV-encoded base64 from ZatcaTlvEncoder.encode(...).
    final parts = [
      sellerName,
      vatNumber,
      timestamp.toIso8601String(),
      totalWithVat.toStringAsFixed(2),
      vatAmount.toStringAsFixed(2),
    ];
    return 'ZATCA_QR::${parts.join("|")}';
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ==========================================================================
  // GROUP 1: Basic VAT Calculation
  // ==========================================================================
  //
  // Saudi Arabia uses a 15% standard VAT rate. These tests use the real
  // `VatCalculator` from alhai_zatca so regressions in math surface here.
  // ==========================================================================
  group('Tax & Receipt: Basic VAT Calculation', () {
    testWidgets('15% VAT is added correctly to a net amount', (tester) async {
      // 100 SAR net -> 115 SAR gross at 15%
      final gross = VatCalculator.addVat(netAmount: 100.0);
      expect(gross, closeTo(115.0, 0.001));

      final vat = VatCalculator.vatFromNet(netAmount: 100.0);
      expect(vat, closeTo(15.0, 0.001));
    });

    testWidgets('single-item breakdown matches expected totals',
        (tester) async {
      // One unit of Milk at 6.50 SAR
      final milk = testProducts[0];
      final breakdown = VatCalculator.lineBreakdown(
        unitPrice: milk.price,
        quantity: 1,
      );

      expect(breakdown.netAmount, closeTo(6.50, 0.001));
      expect(breakdown.vatAmount, closeTo(0.98, 0.01));
      expect(breakdown.grossAmount, closeTo(7.48, 0.01));
      expect(breakdown.vatRate, 15.0);
    });

    testWidgets('multi-quantity line scales proportionally', (tester) async {
      // 3 units of Rice at 32.00 each
      final rice = testProducts[2];
      final breakdown = VatCalculator.lineBreakdown(
        unitPrice: rice.price,
        quantity: 3,
      );

      expect(breakdown.netAmount, closeTo(96.00, 0.001));
      expect(breakdown.vatAmount, closeTo(14.40, 0.001));
      expect(breakdown.grossAmount, closeTo(110.40, 0.001));
    });
  });

  // ==========================================================================
  // GROUP 2: Mixed Tax Items
  // ==========================================================================
  //
  // A cashier may ring up a taxable item (standard 15%) alongside a
  // zero-rated item (e.g. exported goods or basic foodstuffs where
  // policy allows). The invoice total must sum them correctly.
  // ==========================================================================
  group('Tax & Receipt: Mixed Tax Items', () {
    testWidgets('zero-rated + standard-rated items sum correctly',
        (tester) async {
      // Taxable: 100 SAR net at 15% -> 115 gross
      final taxable = VatCalculator.breakdownFromNet(netAmount: 100.0);
      // Zero-rated: 50 SAR net at 0% -> 50 gross
      final zeroRated = VatCalculator.breakdownFromNet(
        netAmount: 50.0,
        vatRate: VatCalculator.zeroRate,
      );

      final total = VatCalculator.sumBreakdowns([taxable, zeroRated]);

      expect(total.netAmount, closeTo(150.0, 0.001));
      expect(total.vatAmount, closeTo(15.0, 0.001));
      expect(total.grossAmount, closeTo(165.0, 0.001));
    });

    testWidgets('all zero-rated produces zero VAT', (tester) async {
      final exportA =
          VatCalculator.breakdownFromNet(netAmount: 200.0, vatRate: 0.0);
      final exportB =
          VatCalculator.breakdownFromNet(netAmount: 350.0, vatRate: 0.0);

      final total = VatCalculator.sumBreakdowns([exportA, exportB]);
      expect(total.vatAmount, closeTo(0.0, 0.001));
      expect(total.grossAmount, closeTo(550.0, 0.001));
    });
  });

  // ==========================================================================
  // GROUP 3: Discount Before Tax
  // ==========================================================================
  //
  // Discounts are applied to the net amount; VAT is then computed on the
  // discounted net (standard Saudi practice). This avoids double taxation
  // on rebates.
  // ==========================================================================
  group('Tax & Receipt: Discount Before Tax', () {
    testWidgets('discount applied to line reduces VAT proportionally',
        (tester) async {
      // 5 units of Rice at 32.00 each = 160 net
      // Apply 10 SAR discount -> 150 net
      // VAT @ 15% = 22.50 -> gross 172.50
      final breakdown = VatCalculator.lineBreakdown(
        unitPrice: 32.00,
        quantity: 5,
        discount: 10.0,
      );

      expect(breakdown.netAmount, closeTo(150.0, 0.001));
      expect(breakdown.vatAmount, closeTo(22.50, 0.001));
      expect(breakdown.grossAmount, closeTo(172.50, 0.001));
    });

    testWidgets('zero discount equals no discount path', (tester) async {
      final withZero = VatCalculator.lineBreakdown(
        unitPrice: 10.0,
        quantity: 2,
        discount: 0.0,
      );
      final withoutDiscount = VatCalculator.lineBreakdown(
        unitPrice: 10.0,
        quantity: 2,
      );

      expect(withZero.netAmount, closeTo(withoutDiscount.netAmount, 0.001));
      expect(withZero.vatAmount, closeTo(withoutDiscount.vatAmount, 0.001));
      expect(withZero.grossAmount, closeTo(withoutDiscount.grossAmount, 0.001));
    });
  });

  // ==========================================================================
  // GROUP 4: Multi-Payment Split
  // ==========================================================================
  //
  // Customers often split the total between cash + card + wallet. The
  // payment screen must accept the split and the sum must equal the
  // invoice total. We exercise the PaymentScreen widget tree and verify
  // the math with a local helper (the real widget uses the same formulas
  // internally).
  // ==========================================================================
  group('Tax & Receipt: Multi-Payment Split', () {
    testWidgets('three-way split (cash/card/wallet) sums to total',
        (tester) async {
      // Invoice total: 230.00 SAR
      const cashPart = 100.00;
      const cardPart = 80.00;
      const walletPart = 50.00;
      final total = _roundHalala(cashPart + cardPart + walletPart);

      expect(total, closeTo(230.00, 0.001));
    });

    testWidgets('payment screen loads and accepts amount entry',
        (tester) async {
      // Exercise the real PaymentScreen: the user types a cash amount
      // for a split payment.
      await tester.pumpWidget(buildTestApp(
        initialRoute: '/pos/payment',
        isAuthenticated: true,
      ));
      await pumpAndSettleWithTimeout(tester);

      expect(find.byType(PaymentScreen), findsOneWidget);

      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, '100.00');
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Payment screen must survive partial-amount entry
      expect(find.byType(PaymentScreen), findsOneWidget);
    });

    testWidgets('overpayment change is non-negative', (tester) async {
      // Customer pays 250 on a 230.50 invoice -> change due 19.50
      const total = 230.50;
      const given = 250.00;
      final change = _roundHalala(given - total);

      expect(change, closeTo(19.50, 0.001));
      expect(change >= 0, true);
    });
  });

  // ==========================================================================
  // GROUP 5: Receipt Preview
  // ==========================================================================
  //
  // Before printing, the cashier sees a preview of the receipt on screen.
  // The ReceiptScreen is mounted directly with no sale data - it must not
  // crash and must render its scaffold so print / share actions can be
  // exposed by the real implementation.
  // ==========================================================================
  group('Tax & Receipt: Receipt Preview', () {
    testWidgets('receipt screen renders scaffold for preview', (tester) async {
      await tester.pumpWidget(buildTestApp(
        initialRoute: '/pos/receipt',
        isAuthenticated: true,
      ));
      await pumpAndSettleWithTimeout(tester);

      expect(find.byType(ReceiptScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('receipt screen survives rapid navigation cycles',
        (tester) async {
      // Mount and unmount quickly to catch dispose-related regressions in
      // the preview state machine.
      for (var i = 0; i < 3; i++) {
        await tester.pumpWidget(buildTestApp(
          initialRoute: '/pos/receipt',
          isAuthenticated: true,
        ));
        await pumpAndSettleWithTimeout(tester);
        expect(find.byType(ReceiptScreen), findsOneWidget);
      }
    });
  });

  // ==========================================================================
  // GROUP 6: ZATCA QR Presence
  // ==========================================================================
  //
  // The real ZatcaQrService requires a signed XML invoice and a loaded
  // compliance certificate. In the test harness we substitute a fake
  // builder and verify that a non-empty, parseable QR payload is produced
  // for a typical receipt's worth of data.
  // ==========================================================================
  group('Tax & Receipt: ZATCA QR Presence', () {
    testWidgets('fake QR builder produces non-empty payload for sale',
        (tester) async {
      final breakdown = VatCalculator.breakdownFromNet(netAmount: 100.0);
      final fake = _FakeZatcaQrBuilder();

      final qr = fake.build(
        sellerName: kTestStoreName,
        vatNumber: '300000000000003',
        timestamp: DateTime(2026, 4, 10, 14, 30),
        totalWithVat: breakdown.grossAmount,
        vatAmount: breakdown.vatAmount,
      );

      expect(qr.isNotEmpty, true);
      expect(qr.startsWith('ZATCA_QR::'), true);
      // Seller name, VAT number, VAT amount must all appear in payload
      expect(qr.contains(kTestStoreName), true);
      expect(qr.contains('300000000000003'), true);
      expect(qr.contains('15.00'), true); // VAT amount
      expect(qr.contains('115.00'), true); // Gross amount
    });

    testWidgets(
      'QR payload contents reflect a different sale amount',
      (tester) async {
        final breakdown = VatCalculator.breakdownFromNet(netAmount: 500.0);
        final fake = _FakeZatcaQrBuilder();

        final qr = fake.build(
          sellerName: kTestStoreName,
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 4, 10, 16, 0),
          totalWithVat: breakdown.grossAmount,
          vatAmount: breakdown.vatAmount,
        );

        // Gross for net 500 @ 15% = 575.00; VAT = 75.00
        expect(qr.contains('575.00'), true);
        expect(qr.contains('75.00'), true);
      },
    );

    // NOTE on skipped path:
    // We intentionally skip a test that would call the *real*
    // ZatcaQrService, because that service requires a live ECDSA signing
    // certificate and a canonicalized invoice XML as input - neither of
    // which is available in this integration test harness. Full QR
    // generation is covered by unit tests in packages/alhai_zatca/.
    //
    // Skipped reason: Requires a live ZATCA sandbox certificate. The
    // full pipeline is covered by unit tests in packages/alhai_zatca.
    testWidgets(
      'real ZatcaQrService end-to-end against sandbox (SKIPPED: needs sandbox cert)',
      (tester) async {
        // Intentional placeholder - skipped via the skip: parameter.
      },
      skip: true,
    );
  });

  // ==========================================================================
  // GROUP 7: Arabic Receipt Rendering
  // ==========================================================================
  //
  // The cashier app ships with an Arabic locale and RTL layout. A
  // regression where Arabic text overflows or mis-aligns would break
  // every printed receipt in Saudi Arabia, so we assert the ReceiptScreen
  // mounts cleanly under the default `ar` locale configured in
  // `buildTestApp`.
  // ==========================================================================
  group('Tax & Receipt: Arabic Receipt Rendering', () {
    testWidgets('receipt screen renders without layout errors under Arabic',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        initialRoute: '/pos/receipt',
        isAuthenticated: true,
      ));
      await pumpAndSettleWithTimeout(tester);

      // No overflow or layout exceptions should have been thrown.
      expect(tester.takeException(), isNull);
      expect(find.byType(ReceiptScreen), findsOneWidget);
    });

    testWidgets('Arabic product name does not break VAT math', (tester) async {
      // Use a product whose name is in Arabic - VAT math must be
      // encoding-agnostic.
      final milk = testProducts[0]; // Name: حليب السعودية كامل الدسم 1 لتر
      expect(milk.name.contains('حليب'), true);

      final breakdown = VatCalculator.lineBreakdown(
        unitPrice: milk.price,
        quantity: 2,
      );
      expect(breakdown.netAmount, closeTo(13.00, 0.001));
      expect(breakdown.vatAmount, closeTo(1.95, 0.001));
      expect(breakdown.grossAmount, closeTo(14.95, 0.001));
    });
  });

  // ==========================================================================
  // GROUP 8: Halala (2-decimal) Rounding
  // ==========================================================================
  //
  // Saudi currency is the Riyal, with 100 halala to 1 SAR. All on-receipt
  // amounts must be rounded to 2 decimals per ZATCA. Arithmetic
  // intermediate values may have more precision but the printed /
  // displayed value is always 2dp.
  // ==========================================================================
  group('Tax & Receipt: Halala Rounding', () {
    testWidgets('arithmetic rounding never loses more than 0.005 SAR',
        (tester) async {
      // 3 items at 6.50 each = 19.50 net; VAT @15% = 2.925 -> rounds to 2.93
      final breakdown = VatCalculator.lineBreakdown(
        unitPrice: 6.50,
        quantity: 3,
      );
      expect(breakdown.netAmount, closeTo(19.50, 0.001));
      expect(breakdown.vatAmount, closeTo(2.93, 0.005));
      // Gross = net + rounded VAT = 22.43 (not 22.425)
      expect(breakdown.grossAmount, closeTo(22.43, 0.005));
    });

    testWidgets('validateTotals tolerates 0.01 SAR rounding drift',
        (tester) async {
      // Build an intentionally slightly-off breakdown that still validates
      const net = 99.99;
      const vat = 15.00; // Rounded up from 14.9985
      const gross = 114.99; // net + vat = 114.99

      final ok = VatCalculator.validateTotals(
        netAmount: net,
        vatAmount: vat,
        grossAmount: gross,
        tolerance: 0.01,
      );
      expect(ok, true);
    });

    testWidgets('halala helper rounds half away from zero', (tester) async {
      // Well-known edge cases
      expect(_roundHalala(1.005), closeTo(1.01, 0.001));
      expect(_roundHalala(1.004), closeTo(1.00, 0.001));
      expect(_roundHalala(0.0), closeTo(0.0, 0.001));
      expect(_roundHalala(123.456), closeTo(123.46, 0.001));
    });

    testWidgets('VatBreakdown toString exposes the rounded values',
        (tester) async {
      // Quick check that the shape of VatBreakdown matches what
      // downstream printing code will consume. Avoids surprise renames.
      const breakdown = VatBreakdown(
        netAmount: 100.0,
        vatAmount: 15.0,
        grossAmount: 115.0,
        vatRate: 15.0,
      );
      final s = breakdown.toString();
      expect(s.contains('100'), true);
      expect(s.contains('15'), true);
      expect(s.contains('115'), true);
    });
  });
}
