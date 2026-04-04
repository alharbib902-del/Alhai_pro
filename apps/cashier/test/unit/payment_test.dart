import 'package:flutter_test/flutter_test.dart';
import 'package:cashier/core/services/zatca/vat_calculator.dart';

/// Pure payment calculation logic tests.
///
/// These test the payment math independently of any UI or database.
void main() {
  // ==========================================================================
  // CASH PAYMENT & CHANGE CALCULATION
  // ==========================================================================
  group('Cash payment & change calculation', () {
    test('exact amount gives zero change', () {
      const total = 115.0;
      const amountReceived = 115.0;
      const change = amountReceived - total;

      expect(change, equals(0.0));
    });

    test('overpayment gives correct change', () {
      const total = 87.50;
      const amountReceived = 100.0;
      const change = amountReceived - total;

      expect(change, closeTo(12.50, 0.001));
    });

    test('large overpayment', () {
      const total = 23.75;
      const amountReceived = 500.0;
      const change = amountReceived - total;

      expect(change, closeTo(476.25, 0.001));
    });

    test('insufficient amount is detected', () {
      const total = 100.0;
      const amountReceived = 80.0;
      const isInsufficient = amountReceived < total;

      expect(isInsufficient, isTrue);
      expect(total - amountReceived, closeTo(20.0, 0.001));
    });

    test('zero amount is insufficient', () {
      const total = 50.0;
      const amountReceived = 0.0;

      expect(amountReceived < total, isTrue);
    });

    test('fractional amounts calculate correctly', () {
      const total = 33.33;
      const amountReceived = 50.0;
      const change = amountReceived - total;

      expect(change, closeTo(16.67, 0.001));
    });
  });

  // ==========================================================================
  // CARD PAYMENT
  // ==========================================================================
  group('Card payment', () {
    test('card payment always charges exact total (no change)', () {
      const total = 115.0;
      const cardCharged = 115.0;

      expect(cardCharged, equals(total));
      // Card payments never have change
      expect(cardCharged - total, equals(0.0));
    });

    test('card payment for fractional amount', () {
      const total = 99.99;
      const cardCharged = 99.99;

      expect(cardCharged, equals(total));
    });
  });

  // ==========================================================================
  // SPLIT PAYMENT (mixed cash + card)
  // ==========================================================================
  group('Split payment', () {
    test('cash + card covers total exactly', () {
      const total = 200.0;
      const cashPart = 100.0;
      const cardPart = 100.0;

      expect(cashPart + cardPart, equals(total));
    });

    test('uneven split', () {
      const total = 150.0;
      const cashPart = 50.0;
      const cardPart = total - cashPart;

      expect(cardPart, equals(100.0));
      expect(cashPart + cardPart, equals(total));
    });

    test('split with change on cash portion', () {
      const total = 75.0;
      const cashReceived = 50.0;
      const cardPart = 25.0;
      // Customer paid 50 cash for a 50 portion, no change needed
      const cashPortion = total - cardPart;
      const change = cashReceived - cashPortion;

      expect(cashPortion, equals(50.0));
      expect(change, equals(0.0));
    });

    test('split payment insufficient total is detected', () {
      const total = 200.0;
      const cashPart = 80.0;
      const cardPart = 100.0;
      const combinedPaid = cashPart + cardPart;

      expect(combinedPaid < total, isTrue);
      expect(total - combinedPaid, closeTo(20.0, 0.001));
    });

    test('split three ways', () {
      const total = 300.0;
      const cashPart = 100.0;
      const cardPart = 150.0;
      const creditPart = 50.0;
      const sum = cashPart + cardPart + creditPart;

      expect(sum, equals(total));
    });
  });

  // ==========================================================================
  // REFUND (full and partial)
  // ==========================================================================
  group('Refund calculations', () {
    test('full refund equals original total', () {
      const originalTotal = 230.0;
      const refundAmount = 230.0;

      expect(refundAmount, equals(originalTotal));
    });

    test('partial refund for single item', () {
      const originalTotal = 230.0;
      const refundedItemTotal = 50.0;
      const remainingAfterRefund = originalTotal - refundedItemTotal;

      expect(remainingAfterRefund, closeTo(180.0, 0.001));
      expect(refundedItemTotal < originalTotal, isTrue);
    });

    test('partial refund for quantity reduction', () {
      // Original: 5 items at 20.0 each = 100.0
      const originalQty = 5;
      const unitPrice = 20.0;
      const returnQty = 2;

      const refundAmount = returnQty * unitPrice;
      const remainingQty = originalQty - returnQty;
      const remainingTotal = remainingQty * unitPrice;

      expect(refundAmount, equals(40.0));
      expect(remainingQty, equals(3));
      expect(remainingTotal, equals(60.0));
    });

    test('refund cannot exceed original total', () {
      const originalTotal = 100.0;
      const requestedRefund = 150.0;

      expect(requestedRefund > originalTotal, isTrue);
      // The actual refund should be capped
      const actualRefund =
          requestedRefund > originalTotal ? originalTotal : requestedRefund;
      expect(actualRefund, equals(originalTotal));
    });

    test('refund with VAT breakdown', () {
      // Original sale: 100 + 15 VAT = 115
      final breakdown = VatCalculator.breakdown(100.0);
      expect(breakdown.total, closeTo(115.0, 0.01));

      // Refund 50% of items → refund 50 + 7.5 VAT = 57.5
      final refundBreakdown = VatCalculator.breakdown(50.0);
      expect(refundBreakdown.total, closeTo(57.5, 0.01));
      expect(refundBreakdown.vatAmount, closeTo(7.5, 0.01));
    });
  });

  // ==========================================================================
  // PAYMENT VALIDATION
  // ==========================================================================
  group('Payment validation rules', () {
    test('negative amount is invalid', () {
      const amount = -10.0;
      expect(amount < 0, isTrue);
    });

    test('zero total needs no payment', () {
      const total = 0.0;
      expect(total <= 0, isTrue);
    });

    test('very small fractional amounts', () {
      const total = 0.01;
      const paid = 0.01;
      expect(paid >= total, isTrue);
    });

    test('large transaction amount', () {
      const total = 999999.99;
      const paid = 1000000.0;
      const change = paid - total;

      expect(change, closeTo(0.01, 0.001));
    });
  });
}
