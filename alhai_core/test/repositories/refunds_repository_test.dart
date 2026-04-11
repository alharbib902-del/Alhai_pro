import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/refund.dart';
import 'package:alhai_core/src/repositories/refunds_repository.dart';

/// Tests for helper classes defined in refunds_repository.dart:
/// RefundsSummary, OriginalSaleInfo, RefundableItem
/// RefundsRepository is an abstract interface - no implementation to test yet.
void main() {
  group('RefundsSummary', () {
    test('should construct with all required fields', () {
      const summary = RefundsSummary(
        storeId: 'store-1',
        totalRefundedAmount: 1500.0,
        totalRefundCount: 10,
        pendingCount: 3,
        byReason: {
          RefundReason.customerRequest: 5,
          RefundReason.defectiveProduct: 3,
          RefundReason.priceError: 2,
        },
        byMethod: {RefundMethod.cash: 1000.0, RefundMethod.card: 500.0},
      );

      expect(summary.storeId, equals('store-1'));
      expect(summary.totalRefundedAmount, equals(1500.0));
      expect(summary.totalRefundCount, equals(10));
      expect(summary.pendingCount, equals(3));
      expect(summary.byReason[RefundReason.customerRequest], equals(5));
      expect(summary.byMethod[RefundMethod.cash], equals(1000.0));
    });
  });

  group('OriginalSaleInfo', () {
    test('should calculate availableForRefund', () {
      final info = OriginalSaleInfo(
        saleId: 'sale-1',
        receiptNumber: 'REC-001',
        saleDate: DateTime(2026, 1, 15),
        totalAmount: 200.0,
        items: const [],
        alreadyRefundedAmount: 50.0,
      );

      expect(info.availableForRefund, equals(150.0));
    });

    test('should calculate availableForRefund with saleDate', () {
      final info = OriginalSaleInfo(
        saleId: 'sale-1',
        receiptNumber: 'REC-001',
        saleDate: DateTime(2026, 1, 15),
        totalAmount: 200.0,
        items: [],
        alreadyRefundedAmount: 50.0,
      );

      expect(info.availableForRefund, equals(150.0));
    });

    test('canRefund should be true when available > 0', () {
      final info = OriginalSaleInfo(
        saleId: 'sale-1',
        receiptNumber: 'REC-001',
        saleDate: DateTime(2026, 1, 15),
        totalAmount: 200.0,
        items: const [],
        alreadyRefundedAmount: 100.0,
      );

      expect(info.canRefund, isTrue);
    });

    test('canRefund should be false when fully refunded', () {
      final info = OriginalSaleInfo(
        saleId: 'sale-1',
        receiptNumber: 'REC-001',
        saleDate: DateTime(2026, 1, 15),
        totalAmount: 200.0,
        items: const [],
        alreadyRefundedAmount: 200.0,
      );

      expect(info.canRefund, isFalse);
    });
  });

  group('RefundableItem', () {
    test('should calculate availableQuantity', () {
      const item = RefundableItem(
        productId: 'p1',
        productName: 'Product 1',
        originalQuantity: 5,
        refundedQuantity: 2,
        unitPrice: 25.0,
      );

      expect(item.availableQuantity, equals(3));
    });

    test('canRefund should be true when available quantity > 0', () {
      const item = RefundableItem(
        productId: 'p1',
        productName: 'Product 1',
        originalQuantity: 5,
        refundedQuantity: 2,
        unitPrice: 25.0,
      );

      expect(item.canRefund, isTrue);
    });

    test('canRefund should be false when fully refunded', () {
      const item = RefundableItem(
        productId: 'p1',
        productName: 'Product 1',
        originalQuantity: 5,
        refundedQuantity: 5,
        unitPrice: 25.0,
      );

      expect(item.canRefund, isFalse);
    });
  });
}
