import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/cash_movement.dart';

void main() {
  group('CashMovement Model', () {
    CashMovement createMovement({
      String id = 'movement-1',
      CashMovementType type = CashMovementType.cashIn,
      double amount = 100.0,
      CashMovementReason reason = CashMovementReason.changeFund,
    }) {
      return CashMovement(
        id: id,
        shiftId: 'shift-1',
        storeId: 'store-1',
        cashierId: 'cashier-1',
        type: type,
        amount: amount,
        reason: reason,
        createdAt: DateTime(2026, 1, 15),
      );
    }

    group('signedAmount', () {
      test('should return positive for cash in', () {
        final movement =
            createMovement(type: CashMovementType.cashIn, amount: 100.0);
        expect(movement.signedAmount, equals(100.0));
      });

      test('should return negative for cash out', () {
        final movement =
            createMovement(type: CashMovementType.cashOut, amount: 50.0);
        expect(movement.signedAmount, equals(-50.0));
      });
    });

    group('requiresSupervisor', () {
      test('should require supervisor for cash out > 100', () {
        final movement = createMovement(
          type: CashMovementType.cashOut,
          amount: 150.0,
        );
        expect(movement.requiresSupervisor, isTrue);
      });

      test('should not require supervisor for cash out <= 100', () {
        final movement = createMovement(
          type: CashMovementType.cashOut,
          amount: 100.0,
        );
        expect(movement.requiresSupervisor, isFalse);
      });

      test('should not require supervisor for cash in regardless of amount',
          () {
        final movement = createMovement(
          type: CashMovementType.cashIn,
          amount: 500.0,
        );
        expect(movement.requiresSupervisor, isFalse);
      });
    });

    group('formattedAmount', () {
      test('should show positive sign for cash in', () {
        final movement =
            createMovement(type: CashMovementType.cashIn, amount: 100.0);
        expect(movement.formattedAmount, equals('+100.00 ر.س'));
      });

      test('should show negative sign for cash out', () {
        final movement =
            createMovement(type: CashMovementType.cashOut, amount: 50.0);
        expect(movement.formattedAmount, equals('-50.00 ر.س'));
      });

      test('should format with 2 decimal places', () {
        final movement = createMovement(amount: 99.5);
        expect(movement.formattedAmount, contains('99.50'));
      });
    });

    group('serialization', () {
      test('should create CashMovement from JSON', () {
        final json = {
          'id': 'movement-1',
          'shiftId': 'shift-1',
          'storeId': 'store-1',
          'cashierId': 'cashier-1',
          'type': 'CASH_IN',
          'amount': 200.0,
          'reason': 'CHANGE_FUND',
          'notes': 'Extra change',
          'createdAt': '2026-01-15T10:00:00.000',
        };

        final movement = CashMovement.fromJson(json);

        expect(movement.id, equals('movement-1'));
        expect(movement.type, equals(CashMovementType.cashIn));
        expect(movement.amount, equals(200.0));
        expect(movement.reason, equals(CashMovementReason.changeFund));
      });

      test('should serialize to JSON and back', () {
        final movement = createMovement(
          type: CashMovementType.cashOut,
          amount: 75.0,
          reason: CashMovementReason.expense,
        );
        final json = movement.toJson();
        final restored = CashMovement.fromJson(json);

        expect(restored.id, equals(movement.id));
        expect(restored.type, equals(CashMovementType.cashOut));
        expect(restored.amount, equals(75.0));
        expect(restored.reason, equals(CashMovementReason.expense));
      });
    });
  });

  group('CashMovementType Extensions', () {
    test('displayNameAr should return Arabic names', () {
      expect(CashMovementType.cashIn.displayNameAr, equals('إيداع'));
      expect(CashMovementType.cashOut.displayNameAr, equals('سحب'));
    });

    test('dbValue should return correct database values', () {
      expect(CashMovementType.cashIn.dbValue, equals('CASH_IN'));
      expect(CashMovementType.cashOut.dbValue, equals('CASH_OUT'));
    });

    test('isPositive should be true for cashIn', () {
      expect(CashMovementType.cashIn.isPositive, isTrue);
      expect(CashMovementType.cashOut.isPositive, isFalse);
    });
  });

  group('CashMovementReason Extensions', () {
    test('displayNameAr should return Arabic names', () {
      expect(
          CashMovementReason.bankDeposit.displayNameAr, equals('إيداع بنكي'));
      expect(CashMovementReason.changeFund.displayNameAr, equals('صندوق فكة'));
      expect(CashMovementReason.expense.displayNameAr, equals('مصروف'));
      expect(
          CashMovementReason.supplierPayment.displayNameAr, equals('دفع مورد'));
      expect(CashMovementReason.other.displayNameAr, equals('أخرى'));
    });
  });
}
