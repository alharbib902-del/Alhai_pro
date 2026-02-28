import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/repositories/cash_movements_repository.dart';

/// Tests for CashMovementsSummary helper class defined in cash_movements_repository.dart
/// CashMovementsRepository is an abstract interface - no implementation to test yet.
void main() {
  group('CashMovementsSummary', () {
    test('should construct with all required fields', () {
      const summary = CashMovementsSummary(
        shiftId: 'shift-1',
        totalCashIn: 500.0,
        totalCashOut: 200.0,
        netMovement: 300.0,
        movementCount: 5,
      );

      expect(summary.shiftId, equals('shift-1'));
      expect(summary.totalCashIn, equals(500.0));
      expect(summary.totalCashOut, equals(200.0));
      expect(summary.netMovement, equals(300.0));
      expect(summary.movementCount, equals(5));
    });

    test('should handle zero movements', () {
      const summary = CashMovementsSummary(
        shiftId: 'shift-1',
        totalCashIn: 0,
        totalCashOut: 0,
        netMovement: 0,
        movementCount: 0,
      );

      expect(summary.totalCashIn, equals(0));
      expect(summary.totalCashOut, equals(0));
      expect(summary.netMovement, equals(0));
      expect(summary.movementCount, equals(0));
    });

    test('should handle negative net movement (more cash out)', () {
      const summary = CashMovementsSummary(
        shiftId: 'shift-1',
        totalCashIn: 100.0,
        totalCashOut: 300.0,
        netMovement: -200.0,
        movementCount: 3,
      );

      expect(summary.netMovement, isNegative);
    });
  });
}
