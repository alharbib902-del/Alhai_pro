import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/debt.dart';

void main() {
  group('Debt Model', () {
    Debt createDebt({
      String id = 'debt-1',
      DebtType type = DebtType.customerDebt,
      double originalAmount = 100.0,
      double remainingAmount = 100.0,
      DateTime? dueDate,
    }) {
      return Debt(
        id: id,
        storeId: 'store-1',
        type: type,
        partyId: 'party-1',
        partyName: 'Test Party',
        originalAmount: originalAmount,
        remainingAmount: remainingAmount,
        dueDate: dueDate,
        createdAt: DateTime(2026, 1, 15),
      );
    }

    group('paidAmount', () {
      test('should calculate paid amount correctly', () {
        final debt = createDebt(originalAmount: 100.0, remainingAmount: 30.0);
        expect(debt.paidAmount, equals(70.0));
      });

      test('should be 0 when nothing paid', () {
        final debt = createDebt(originalAmount: 100.0, remainingAmount: 100.0);
        expect(debt.paidAmount, equals(0));
      });

      test('should equal original when fully paid', () {
        final debt = createDebt(originalAmount: 100.0, remainingAmount: 0);
        expect(debt.paidAmount, equals(100.0));
      });
    });

    group('isFullyPaid', () {
      test('should return true when remaining is 0', () {
        final debt = createDebt(remainingAmount: 0);
        expect(debt.isFullyPaid, isTrue);
      });

      test('should return true when remaining is negative (overpaid)', () {
        final debt = createDebt(remainingAmount: -5.0);
        expect(debt.isFullyPaid, isTrue);
      });

      test('should return false when remaining is positive', () {
        final debt = createDebt(remainingAmount: 50.0);
        expect(debt.isFullyPaid, isFalse);
      });
    });

    group('isOverdue', () {
      test('should return true when past due date and not fully paid', () {
        final debt = createDebt(
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
          remainingAmount: 50.0,
        );
        expect(debt.isOverdue, isTrue);
      });

      test('should return false when no due date set', () {
        final debt = createDebt(dueDate: null, remainingAmount: 50.0);
        expect(debt.isOverdue, isFalse);
      });

      test('should return false when fully paid even if past due', () {
        final debt = createDebt(
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
          remainingAmount: 0,
        );
        expect(debt.isOverdue, isFalse);
      });

      test('should return false when due date is in the future', () {
        final debt = createDebt(
          dueDate: DateTime.now().add(const Duration(days: 7)),
          remainingAmount: 50.0,
        );
        expect(debt.isOverdue, isFalse);
      });
    });

    group('paymentProgress', () {
      test('should return 0.5 when half paid', () {
        final debt = createDebt(originalAmount: 100.0, remainingAmount: 50.0);
        expect(debt.paymentProgress, closeTo(0.5, 0.001));
      });

      test('should return 1.0 when fully paid', () {
        final debt = createDebt(originalAmount: 100.0, remainingAmount: 0);
        expect(debt.paymentProgress, closeTo(1.0, 0.001));
      });

      test('should return 0.0 when nothing paid', () {
        final debt = createDebt(originalAmount: 100.0, remainingAmount: 100.0);
        expect(debt.paymentProgress, closeTo(0.0, 0.001));
      });

      test('should return 0 when original amount is 0', () {
        final debt = createDebt(originalAmount: 0, remainingAmount: 0);
        expect(debt.paymentProgress, equals(0));
      });
    });

    group('serialization', () {
      test('should create Debt from JSON', () {
        final json = {
          'id': 'debt-1',
          'storeId': 'store-1',
          'type': 'customerDebt',
          'partyId': 'party-1',
          'partyName': 'Test Customer',
          'originalAmount': 200.0,
          'remainingAmount': 80.0,
          'dueDate': '2026-02-15T00:00:00.000',
          'createdAt': '2026-01-15T00:00:00.000',
        };

        final debt = Debt.fromJson(json);

        expect(debt.id, equals('debt-1'));
        expect(debt.type, equals(DebtType.customerDebt));
        expect(debt.originalAmount, equals(200.0));
        expect(debt.remainingAmount, equals(80.0));
        expect(debt.paidAmount, equals(120.0));
      });

      test('should serialize to JSON and back', () {
        final debt = createDebt(
          originalAmount: 200.0,
          remainingAmount: 50.0,
          dueDate: DateTime(2026, 2, 15),
        );
        final json = debt.toJson();
        final restored = Debt.fromJson(json);

        expect(restored.id, equals(debt.id));
        expect(restored.originalAmount, equals(200.0));
        expect(restored.remainingAmount, equals(50.0));
      });
    });
  });

  group('DebtPayment Model', () {
    test('should create from JSON', () {
      final json = {
        'id': 'payment-1',
        'debtId': 'debt-1',
        'amount': 50.0,
        'notes': 'Partial payment',
        'paymentMethod': 'cash',
        'createdAt': '2026-01-20T00:00:00.000',
      };

      final payment = DebtPayment.fromJson(json);

      expect(payment.id, equals('payment-1'));
      expect(payment.debtId, equals('debt-1'));
      expect(payment.amount, equals(50.0));
      expect(payment.notes, equals('Partial payment'));
    });

    test('should serialize to JSON and back', () {
      final payment = DebtPayment(
        id: 'p1',
        debtId: 'debt-1',
        amount: 75.0,
        createdAt: DateTime(2026, 1, 20),
      );
      final json = payment.toJson();
      final restored = DebtPayment.fromJson(json);

      expect(restored.id, equals(payment.id));
      expect(restored.amount, equals(75.0));
    });
  });
}
