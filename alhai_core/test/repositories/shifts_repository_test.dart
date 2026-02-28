import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/repositories/shifts_repository.dart';

/// Tests for ShiftSummary helper class defined in shifts_repository.dart
/// ShiftsRepository is an abstract interface - no implementation to test yet.
void main() {
  group('ShiftSummary', () {
    test('should construct with all required fields', () {
      const summary = ShiftSummary(
        shiftId: 'shift-1',
        openingCash: 500.0,
        closingCash: 750.0,
        expectedCash: 700.0,
        cashDifference: 50.0,
        totalOrders: 25,
        totalSales: 2500.0,
        salesByMethod: {'cash': 1500.0, 'card': 1000.0},
      );

      expect(summary.shiftId, equals('shift-1'));
      expect(summary.openingCash, equals(500.0));
      expect(summary.closingCash, equals(750.0));
      expect(summary.expectedCash, equals(700.0));
      expect(summary.cashDifference, equals(50.0));
      expect(summary.totalOrders, equals(25));
      expect(summary.totalSales, equals(2500.0));
      expect(summary.salesByMethod['cash'], equals(1500.0));
      expect(summary.salesByMethod['card'], equals(1000.0));
    });

    test('should handle empty sales by method', () {
      const summary = ShiftSummary(
        shiftId: 'shift-1',
        openingCash: 500.0,
        closingCash: 500.0,
        expectedCash: 500.0,
        cashDifference: 0,
        totalOrders: 0,
        totalSales: 0,
        salesByMethod: {},
      );

      expect(summary.salesByMethod, isEmpty);
      expect(summary.totalOrders, equals(0));
    });

    test('should handle negative cash difference (shortage)', () {
      const summary = ShiftSummary(
        shiftId: 'shift-1',
        openingCash: 500.0,
        closingCash: 680.0,
        expectedCash: 700.0,
        cashDifference: -20.0,
        totalOrders: 10,
        totalSales: 1000.0,
        salesByMethod: {'cash': 1000.0},
      );

      expect(summary.cashDifference, isNegative);
    });
  });
}
