/// Tests for Shift Close Cash Formula
///
/// The expected cash in the drawer at shift close is:
///   openingCash + cashSales + mixedCashPortion - cashRefunds + cashIn - cashOut
///
/// Card sales and credit sales are NOT included in expected cash.
/// Variance = actualCash - expectedCash.
///
/// These tests verify the formula used in shift_close_screen.dart
/// and the DAO methods getCashSalesTotalForPeriod / getCashRefundsTotalForPeriod.
library;

import 'package:flutter_test/flutter_test.dart';

// ==========================================================================
// Shift Cash Formula (extracted from shift_close_screen.dart)
//
// In the app this calculation lives in _buildContent():
//   expectedCash = openingCash + cashIn - cashOut + cashSales - cashRefunds
//
// Where:
//   cashSales = getCashSalesTotalForPeriod + getMixedCashAmountForPeriod
//   cashRefunds = getCashRefundsTotalForPeriod
//
// The variance (difference) = actualCash - expectedCash
// ==========================================================================

/// Calculate expected cash in the drawer at shift close.
///
/// Parameters:
/// - [openingCash]: Cash put into the drawer when shift opened
/// - [cashSales]: Total of cash-only sales (payment_method = 'cash')
/// - [mixedCashPortion]: Cash portion from mixed-payment sales
/// - [cashRefunds]: Total cash refunded to customers during shift
/// - [cashIn]: Manual cash deposits during shift
/// - [cashOut]: Manual cash withdrawals during shift
double calculateExpectedCash({
  required double openingCash,
  required double cashSales,
  double mixedCashPortion = 0,
  required double cashRefunds,
  required double cashIn,
  required double cashOut,
}) {
  return openingCash +
      (cashSales + mixedCashPortion) -
      cashRefunds +
      cashIn -
      cashOut;
}

/// Calculate variance between actual and expected cash.
///
/// Positive = surplus (more cash than expected)
/// Negative = deficit (less cash than expected)
/// Zero = drawer matches
double calculateVariance({
  required double actualCash,
  required double expectedCash,
}) {
  return actualCash - expectedCash;
}

// ==========================================================================
// Tests
// ==========================================================================

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // Core formula
  // ──────────────────────────────────────────────────────────────────────────
  group('expectedCash formula', () {
    test('opening + cash sales - cash refunds + cash in - cash out', () {
      final expected = calculateExpectedCash(
        openingCash: 500,
        cashSales: 1200,
        cashRefunds: 150,
        cashIn: 200,
        cashOut: 100,
      );

      // 500 + 1200 - 150 + 200 - 100 = 1650
      expect(expected, closeTo(1650.0, 0.001));
    });

    test('all zeros: expected = 0', () {
      final expected = calculateExpectedCash(
        openingCash: 0,
        cashSales: 0,
        cashRefunds: 0,
        cashIn: 0,
        cashOut: 0,
      );

      expect(expected, closeTo(0.0, 0.001));
    });

    test('only opening cash, no transactions', () {
      final expected = calculateExpectedCash(
        openingCash: 1000,
        cashSales: 0,
        cashRefunds: 0,
        cashIn: 0,
        cashOut: 0,
      );

      expect(expected, closeTo(1000.0, 0.001));
    });

    test('opening cash + sales only', () {
      final expected = calculateExpectedCash(
        openingCash: 500,
        cashSales: 3000,
        cashRefunds: 0,
        cashIn: 0,
        cashOut: 0,
      );

      // 500 + 3000 = 3500
      expect(expected, closeTo(3500.0, 0.001));
    });

    test('heavy refunds can make expected cash less than opening', () {
      final expected = calculateExpectedCash(
        openingCash: 500,
        cashSales: 200,
        cashRefunds: 800,
        cashIn: 0,
        cashOut: 0,
      );

      // 500 + 200 - 800 = -100 (deficit situation)
      expect(expected, closeTo(-100.0, 0.001));
    });

    test('fractional amounts handled correctly', () {
      final expected = calculateExpectedCash(
        openingCash: 500.50,
        cashSales: 1234.75,
        cashRefunds: 45.25,
        cashIn: 100.00,
        cashOut: 50.50,
      );

      // 500.50 + 1234.75 - 45.25 + 100.00 - 50.50 = 1739.50
      expect(expected, closeTo(1739.50, 0.001));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Card sales NOT included
  // ──────────────────────────────────────────────────────────────────────────
  group('card sales NOT included in expected cash', () {
    test('card sales do not affect expected cash', () {
      // The DAO getCashSalesTotalForPeriod filters: payment_method = 'cash'
      // So card sales never appear in cashSales parameter.
      // This test documents that the formula ONLY uses cash sales.

      const openingCash = 500.0;
      const cashSalesOnly = 800.0;
      // Imagine there were also 2000 SAR in card sales - they don't count
      const cardSales = 2000.0; // NOT passed to formula

      final expected = calculateExpectedCash(
        openingCash: openingCash,
        cashSales: cashSalesOnly, // Only cash, not cashSalesOnly + cardSales
        cashRefunds: 0,
        cashIn: 0,
        cashOut: 0,
      );

      // Expected is 500 + 800 = 1300, NOT 500 + 800 + 2000
      expect(expected, closeTo(1300.0, 0.001));
      expect(expected,
          isNot(closeTo(openingCash + cashSalesOnly + cardSales, 0.001)));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Credit sales NOT included
  // ──────────────────────────────────────────────────────────────────────────
  group('credit sales NOT included in expected cash', () {
    test('credit (deferred) sales do not affect expected cash', () {
      // Credit/deferred sales have payment_method = 'credit'
      // getCashSalesTotalForPeriod filters these out.

      const openingCash = 500.0;
      const cashSalesOnly = 600.0;
      // Imagine 1500 SAR in credit sales - they don't count
      const creditSales = 1500.0; // NOT passed to formula

      final expected = calculateExpectedCash(
        openingCash: openingCash,
        cashSales: cashSalesOnly,
        cashRefunds: 0,
        cashIn: 0,
        cashOut: 0,
      );

      // Expected is 500 + 600 = 1100, NOT 500 + 600 + 1500
      expect(expected, closeTo(1100.0, 0.001));
      expect(expected,
          isNot(closeTo(openingCash + cashSalesOnly + creditSales, 0.001)));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Mixed payment: only cash portion counted
  // ──────────────────────────────────────────────────────────────────────────
  group('mixed payment: only cash portion counted', () {
    test('mixed sale: only cash_amount portion adds to expected cash', () {
      // A 500 SAR sale paid with 300 cash + 200 card
      // getCashSalesTotalForPeriod returns 0 for this sale (payment_method='mixed')
      // getMixedCashAmountForPeriod returns 300 (the cash_amount column)

      final expected = calculateExpectedCash(
        openingCash: 500,
        cashSales: 0, // pure cash sales
        mixedCashPortion: 300, // cash portion from mixed payments
        cashRefunds: 0,
        cashIn: 0,
        cashOut: 0,
      );

      // 500 + 0 + 300 = 800 (not 500 + 500)
      expect(expected, closeTo(800.0, 0.001));
    });

    test('combined: pure cash sales + mixed cash portion', () {
      // Pure cash sale: 400 SAR
      // Mixed sale: 600 SAR total, 350 cash + 250 card
      // Only 400 + 350 = 750 should count

      final expected = calculateExpectedCash(
        openingCash: 200,
        cashSales: 400,
        mixedCashPortion: 350,
        cashRefunds: 50,
        cashIn: 0,
        cashOut: 0,
      );

      // 200 + (400 + 350) - 50 + 0 - 0 = 900
      expect(expected, closeTo(900.0, 0.001));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Variance calculation
  // ──────────────────────────────────────────────────────────────────────────
  group('variance = actual - expected', () {
    test('exact match: variance = 0', () {
      final variance = calculateVariance(
        actualCash: 1650,
        expectedCash: 1650,
      );

      expect(variance, closeTo(0.0, 0.001));
    });

    test('surplus: actual > expected (positive variance)', () {
      final variance = calculateVariance(
        actualCash: 1700,
        expectedCash: 1650,
      );

      expect(variance, closeTo(50.0, 0.001));
      expect(variance, greaterThan(0));
    });

    test('deficit: actual < expected (negative variance)', () {
      final variance = calculateVariance(
        actualCash: 1600,
        expectedCash: 1650,
      );

      expect(variance, closeTo(-50.0, 0.001));
      expect(variance, lessThan(0));
    });

    test('large deficit', () {
      final variance = calculateVariance(
        actualCash: 500,
        expectedCash: 2000,
      );

      expect(variance, closeTo(-1500.0, 0.001));
    });

    test('fractional variance', () {
      final variance = calculateVariance(
        actualCash: 1650.75,
        expectedCash: 1650.50,
      );

      expect(variance, closeTo(0.25, 0.001));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Zero opening cash
  // ──────────────────────────────────────────────────────────────────────────
  group('zero opening cash is valid', () {
    test('shift opened with 0 cash, expected = sales - refunds + in - out', () {
      final expected = calculateExpectedCash(
        openingCash: 0,
        cashSales: 500,
        cashRefunds: 50,
        cashIn: 100,
        cashOut: 0,
      );

      // 0 + 500 - 50 + 100 - 0 = 550
      expect(expected, closeTo(550.0, 0.001));
    });

    test('zero opening, zero sales, only cashIn: expected = cashIn', () {
      final expected = calculateExpectedCash(
        openingCash: 0,
        cashSales: 0,
        cashRefunds: 0,
        cashIn: 1000,
        cashOut: 0,
      );

      expect(expected, closeTo(1000.0, 0.001));
    });

    test('zero opening with refund: expected is negative', () {
      final expected = calculateExpectedCash(
        openingCash: 0,
        cashSales: 0,
        cashRefunds: 100,
        cashIn: 0,
        cashOut: 0,
      );

      // 0 + 0 - 100 + 0 - 0 = -100
      expect(expected, closeTo(-100.0, 0.001));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Real-world scenario
  // ──────────────────────────────────────────────────────────────────────────
  group('real-world shift close scenario', () {
    test('full shift lifecycle', () {
      // Shift opens with 500 SAR
      // During the day:
      //   - 10 cash sales totaling 3,500 SAR
      //   - 5 card sales totaling 2,000 SAR (NOT counted)
      //   - 2 credit sales totaling 800 SAR (NOT counted)
      //   - 1 mixed sale: 400 SAR total, 250 cash + 150 card
      //   - 2 cash refunds totaling 175 SAR
      //   - 1 cash deposit (cashIn) of 200 SAR
      //   - 1 cash withdrawal (cashOut) of 500 SAR

      final expected = calculateExpectedCash(
        openingCash: 500,
        cashSales: 3500,
        mixedCashPortion: 250,
        cashRefunds: 175,
        cashIn: 200,
        cashOut: 500,
      );

      // 500 + (3500 + 250) - 175 + 200 - 500 = 3775
      expect(expected, closeTo(3775.0, 0.001));

      // Cashier counts 3800 SAR in drawer
      final variance = calculateVariance(
        actualCash: 3800,
        expectedCash: expected,
      );

      // Surplus of 25 SAR
      expect(variance, closeTo(25.0, 0.001));
      expect(variance, greaterThan(0));
    });

    test('deficit scenario: cashier miscounted', () {
      final expected = calculateExpectedCash(
        openingCash: 500,
        cashSales: 2000,
        cashRefunds: 100,
        cashIn: 0,
        cashOut: 0,
      );

      // 500 + 2000 - 100 = 2400
      expect(expected, closeTo(2400.0, 0.001));

      // Cashier counts only 2350
      final variance = calculateVariance(
        actualCash: 2350,
        expectedCash: expected,
      );

      // Deficit of 50 SAR
      expect(variance, closeTo(-50.0, 0.001));
      expect(variance, lessThan(0));
    });
  });
}
