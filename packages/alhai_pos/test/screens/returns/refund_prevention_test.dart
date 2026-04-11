/// Unit tests for refund prevention logic
///
/// Tests the LOGIC of determining refund eligibility:
/// - Available quantities after prior returns
/// - Full-return blocking
/// - Partial-return remaining qty
/// - Voided sale blocking
/// - VAT inclusion in refund amounts
///
/// These are pure unit tests (no widget tests, no UI).
library;

import 'package:flutter_test/flutter_test.dart';

// ==========================================================================
// Refund eligibility logic (extracted from UI for testability)
//
// In the app, this logic lives across:
//   - create_return_drawer.dart (maxReturn field per item)
//   - returns_providers.dart (getReturnsBySaleId)
//   - returns_dao.dart (getReturnItems)
//
// These functions codify the business rules so we can test them in isolation.
// ==========================================================================

/// Represents an item on the original sale
class SaleItem {
  final String productId;
  final String productName;
  final double qty;
  final double unitPrice;

  const SaleItem({
    required this.productId,
    required this.productName,
    required this.qty,
    required this.unitPrice,
  });
}

/// Represents an item that was previously returned
class ReturnedItem {
  final String productId;
  final double qty;

  const ReturnedItem({required this.productId, required this.qty});
}

/// Represents a prior return record against a sale
class PriorReturn {
  final String status; // 'completed', 'pending', 'rejected'
  final List<ReturnedItem> items;

  const PriorReturn({required this.status, required this.items});
}

/// Calculate available quantity for refund per product.
///
/// For each sale item, subtracts the total previously-returned qty
/// (from completed returns only). Returns a map of productId -> available qty.
Map<String, double> calculateAvailableForRefund({
  required List<SaleItem> saleItems,
  required List<PriorReturn> priorReturns,
}) {
  // Sum previously returned quantities (only completed returns count)
  final returnedQty = <String, double>{};
  for (final ret in priorReturns) {
    if (ret.status != 'completed') continue;
    for (final item in ret.items) {
      returnedQty[item.productId] =
          (returnedQty[item.productId] ?? 0) + item.qty;
    }
  }

  // Calculate remaining available quantity
  final available = <String, double>{};
  for (final item in saleItems) {
    final returned = returnedQty[item.productId] ?? 0;
    final remaining = (item.qty - returned).clamp(0.0, item.qty);
    available[item.productId] = remaining;
  }

  return available;
}

/// Check if refund is completely blocked for a sale.
///
/// A refund is blocked when:
/// - The sale is voided
/// - All items have been fully returned already
bool isRefundBlocked({
  required String saleStatus,
  required Map<String, double> availableQty,
}) {
  if (saleStatus == 'voided') return true;
  return availableQty.values.every((qty) => qty <= 0);
}

/// Calculate the refund amount including 15% VAT.
///
/// In Saudi Arabia, VAT is 15%. The refund amount is calculated as:
/// subtotal * (1 + 0.15) = subtotal * 1.15
double calculateRefundAmountWithVat(double subtotal, {double vatRate = 0.15}) {
  return subtotal * (1 + vatRate);
}

// ==========================================================================
// Tests
// ==========================================================================

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // Available quantities
  // ──────────────────────────────────────────────────────────────────────────
  group('calculateAvailableForRefund', () {
    test('sale with no prior returns: all items available', () {
      final saleItems = [
        const SaleItem(
          productId: 'p1',
          productName: 'Milk',
          qty: 3,
          unitPrice: 12,
        ),
        const SaleItem(
          productId: 'p2',
          productName: 'Bread',
          qty: 2,
          unitPrice: 5,
        ),
        const SaleItem(
          productId: 'p3',
          productName: 'Cheese',
          qty: 1,
          unitPrice: 18.5,
        ),
      ];

      final available = calculateAvailableForRefund(
        saleItems: saleItems,
        priorReturns: [],
      );

      expect(available['p1'], 3.0);
      expect(available['p2'], 2.0);
      expect(available['p3'], 1.0);
    });

    test('sale with full prior return: all items have 0 available', () {
      final saleItems = [
        const SaleItem(
          productId: 'p1',
          productName: 'Milk',
          qty: 2,
          unitPrice: 12,
        ),
        const SaleItem(
          productId: 'p2',
          productName: 'Bread',
          qty: 1,
          unitPrice: 5,
        ),
      ];

      final priorReturns = [
        const PriorReturn(
          status: 'completed',
          items: [
            ReturnedItem(productId: 'p1', qty: 2),
            ReturnedItem(productId: 'p2', qty: 1),
          ],
        ),
      ];

      final available = calculateAvailableForRefund(
        saleItems: saleItems,
        priorReturns: priorReturns,
      );

      expect(available['p1'], 0.0);
      expect(available['p2'], 0.0);
    });

    test('sale with partial return: only remaining quantities available', () {
      final saleItems = [
        const SaleItem(
          productId: 'p1',
          productName: 'Milk',
          qty: 5,
          unitPrice: 12,
        ),
        const SaleItem(
          productId: 'p2',
          productName: 'Bread',
          qty: 3,
          unitPrice: 5,
        ),
      ];

      final priorReturns = [
        const PriorReturn(
          status: 'completed',
          items: [
            ReturnedItem(productId: 'p1', qty: 2), // 5-2 = 3 remaining
            // p2 not returned at all
          ],
        ),
      ];

      final available = calculateAvailableForRefund(
        saleItems: saleItems,
        priorReturns: priorReturns,
      );

      expect(available['p1'], 3.0);
      expect(available['p2'], 3.0); // Full qty still available
    });

    test('multiple partial returns accumulate correctly', () {
      final saleItems = [
        const SaleItem(
          productId: 'p1',
          productName: 'Milk',
          qty: 10,
          unitPrice: 12,
        ),
      ];

      final priorReturns = [
        const PriorReturn(
          status: 'completed',
          items: [ReturnedItem(productId: 'p1', qty: 3)],
        ),
        const PriorReturn(
          status: 'completed',
          items: [ReturnedItem(productId: 'p1', qty: 4)],
        ),
      ];

      final available = calculateAvailableForRefund(
        saleItems: saleItems,
        priorReturns: priorReturns,
      );

      // 10 - 3 - 4 = 3 remaining
      expect(available['p1'], 3.0);
    });

    test('rejected returns are not counted against available qty', () {
      final saleItems = [
        const SaleItem(
          productId: 'p1',
          productName: 'Milk',
          qty: 5,
          unitPrice: 12,
        ),
      ];

      final priorReturns = [
        const PriorReturn(
          status: 'rejected', // should be ignored
          items: [ReturnedItem(productId: 'p1', qty: 5)],
        ),
      ];

      final available = calculateAvailableForRefund(
        saleItems: saleItems,
        priorReturns: priorReturns,
      );

      expect(available['p1'], 5.0); // Full qty still available
    });

    test('returned quantity clamped to 0 (never negative)', () {
      final saleItems = [
        const SaleItem(
          productId: 'p1',
          productName: 'Milk',
          qty: 2,
          unitPrice: 12,
        ),
      ];

      // Hypothetical data inconsistency: returned more than sold
      final priorReturns = [
        const PriorReturn(
          status: 'completed',
          items: [ReturnedItem(productId: 'p1', qty: 5)],
        ),
      ];

      final available = calculateAvailableForRefund(
        saleItems: saleItems,
        priorReturns: priorReturns,
      );

      expect(available['p1'], 0.0); // Clamped, not negative
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Refund blocking
  // ──────────────────────────────────────────────────────────────────────────
  group('isRefundBlocked', () {
    test('completed sale with available items: not blocked', () {
      final blocked = isRefundBlocked(
        saleStatus: 'completed',
        availableQty: {'p1': 3.0, 'p2': 1.0},
      );
      expect(blocked, isFalse);
    });

    test('voided sale: refund blocked regardless of available qty', () {
      final blocked = isRefundBlocked(
        saleStatus: 'voided',
        availableQty: {'p1': 5.0, 'p2': 2.0},
      );
      expect(blocked, isTrue);
    });

    test('fully returned sale: refund blocked', () {
      final blocked = isRefundBlocked(
        saleStatus: 'completed',
        availableQty: {'p1': 0.0, 'p2': 0.0},
      );
      expect(blocked, isTrue);
    });

    test('partially returned sale: not blocked (some qty > 0)', () {
      final blocked = isRefundBlocked(
        saleStatus: 'completed',
        availableQty: {'p1': 0.0, 'p2': 1.0},
      );
      expect(blocked, isFalse);
    });

    test('voided sale: blocked even with 0 available qty', () {
      final blocked = isRefundBlocked(
        saleStatus: 'voided',
        availableQty: {'p1': 0.0},
      );
      expect(blocked, isTrue);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // VAT calculation in refund
  // ──────────────────────────────────────────────────────────────────────────
  group('refund amount includes 15% VAT', () {
    test('100 SAR subtotal: refund = 115 SAR with VAT', () {
      final refund = calculateRefundAmountWithVat(100);
      expect(refund, closeTo(115.0, 0.001));
    });

    test('0 subtotal: refund = 0', () {
      final refund = calculateRefundAmountWithVat(0);
      expect(refund, closeTo(0.0, 0.001));
    });

    test('49.50 subtotal: refund = 56.925 with 15% VAT', () {
      // 49.50 * 1.15 = 56.925
      final refund = calculateRefundAmountWithVat(49.50);
      expect(refund, closeTo(56.925, 0.001));
    });

    test('single item refund: qty * unitPrice * 1.15', () {
      // Returning 2 units of Milk at 12 SAR each
      const qty = 2.0;
      const unitPrice = 12.0;
      const subtotal = qty * unitPrice; // 24.0
      final refund = calculateRefundAmountWithVat(subtotal);

      expect(subtotal, 24.0);
      expect(refund, closeTo(27.6, 0.001)); // 24 * 1.15
    });

    test('multiple items refund: sum of subtotals * 1.15', () {
      // Returning: 2 Milk @12 + 1 Bread @5 = 29 subtotal
      const subtotal = 2 * 12.0 + 1 * 5.0; // 29.0
      final refund = calculateRefundAmountWithVat(subtotal);

      expect(refund, closeTo(33.35, 0.001)); // 29 * 1.15
    });

    test('fractional amount rounds correctly', () {
      // 33.33 * 1.15 = 38.3295
      final refund = calculateRefundAmountWithVat(33.33);
      expect(refund, closeTo(38.3295, 0.001));
    });

    test('custom VAT rate 5%', () {
      final refund = calculateRefundAmountWithVat(100, vatRate: 0.05);
      expect(refund, closeTo(105.0, 0.001));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Integration: full scenario
  // ──────────────────────────────────────────────────────────────────────────
  group('end-to-end refund scenarios', () {
    test('new sale -> check eligibility -> partial return -> check again', () {
      final saleItems = [
        const SaleItem(
          productId: 'p1',
          productName: 'Milk 1L',
          qty: 3,
          unitPrice: 12,
        ),
        const SaleItem(
          productId: 'p2',
          productName: 'Cheese',
          qty: 2,
          unitPrice: 18.5,
        ),
      ];

      // Step 1: Fresh sale, all available
      var available = calculateAvailableForRefund(
        saleItems: saleItems,
        priorReturns: [],
      );
      expect(available['p1'], 3.0);
      expect(available['p2'], 2.0);
      expect(
        isRefundBlocked(saleStatus: 'completed', availableQty: available),
        isFalse,
      );

      // Step 2: Partial return of 1 Milk
      final afterFirstReturn = [
        const PriorReturn(
          status: 'completed',
          items: [ReturnedItem(productId: 'p1', qty: 1)],
        ),
      ];
      available = calculateAvailableForRefund(
        saleItems: saleItems,
        priorReturns: afterFirstReturn,
      );
      expect(available['p1'], 2.0);
      expect(available['p2'], 2.0);
      expect(
        isRefundBlocked(saleStatus: 'completed', availableQty: available),
        isFalse,
      );

      // Step 3: Return remaining items
      final afterFullReturn = [
        ...afterFirstReturn,
        const PriorReturn(
          status: 'completed',
          items: [
            ReturnedItem(productId: 'p1', qty: 2),
            ReturnedItem(productId: 'p2', qty: 2),
          ],
        ),
      ];
      available = calculateAvailableForRefund(
        saleItems: saleItems,
        priorReturns: afterFullReturn,
      );
      expect(available['p1'], 0.0);
      expect(available['p2'], 0.0);
      expect(
        isRefundBlocked(saleStatus: 'completed', availableQty: available),
        isTrue,
      );
    });

    test('refund amount for partial return includes VAT', () {
      // Return 2 Milk at 12 SAR each from a 3-Milk sale
      const returnSubtotal = 2 * 12.0; // 24 SAR
      final refundTotal = calculateRefundAmountWithVat(returnSubtotal);

      // 24 * 1.15 = 27.6 SAR
      expect(refundTotal, closeTo(27.6, 0.001));
    });
  });
}
