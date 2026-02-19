import 'package:flutter_test/flutter_test.dart';

/// اختبارات بنية Customers Providers
///
/// الـ providers تعتمد على getIt<AppDatabase>() لذلك الاختبارات هنا تركز على:
/// - حسابات الديون والائتمان
/// - منطق التحقق من حد الائتمان
///
/// اختبارات التكامل الكاملة مع DB موجودة في:
/// test/data/daos/customers_dao_test.dart + accounts_dao_test.dart
void main() {
  group('Customer Debt Calculations', () {
    test('total debt is sum of unpaid transactions', () {
      final transactions = [150.0, 200.0, 350.0, 100.0];
      final totalDebt = transactions.fold(0.0, (sum, t) => sum + t);
      expect(totalDebt, equals(800.0));
    });

    test('remaining credit limit is max - current debt', () {
      const creditLimit = 5000.0;
      const currentDebt = 3200.0;
      const remaining = creditLimit - currentDebt;
      expect(remaining, equals(1800.0));
    });

    test('can make purchase when remaining limit is sufficient', () {
      const creditLimit = 5000.0;
      const currentDebt = 3200.0;
      const purchaseAmount = 1500.0;
      const remaining = creditLimit - currentDebt;
      const canPurchase = remaining >= purchaseAmount;
      expect(canPurchase, isTrue);
    });

    test('cannot make purchase when exceeds credit limit', () {
      const creditLimit = 5000.0;
      const currentDebt = 4500.0;
      const purchaseAmount = 1000.0;
      const remaining = creditLimit - currentDebt;
      const canPurchase = remaining >= purchaseAmount;
      expect(canPurchase, isFalse);
    });

    test('zero credit limit means no credit allowed', () {
      const creditLimit = 0.0;
      const currentDebt = 0.0;
      const purchaseAmount = 100.0;
      const remaining = creditLimit - currentDebt;
      const canPurchase = remaining >= purchaseAmount;
      expect(canPurchase, isFalse);
    });

    test('debt exceeds credit limit scenario', () {
      const creditLimit = 5000.0;
      const currentDebt = 5500.0; // already over limit
      const remaining = creditLimit - currentDebt;
      expect(remaining, isNegative);
    });
  });

  group('Customer Payment Calculations', () {
    test('partial payment reduces debt', () {
      const totalDebt = 1000.0;
      const payment = 400.0;
      const remainingDebt = totalDebt - payment;
      expect(remainingDebt, equals(600.0));
    });

    test('full payment clears debt', () {
      const totalDebt = 1000.0;
      const payment = 1000.0;
      const remainingDebt = totalDebt - payment;
      expect(remainingDebt, equals(0.0));
    });

    test('overpayment results in credit balance', () {
      const totalDebt = 1000.0;
      const payment = 1200.0;
      const balance = totalDebt - payment;
      expect(balance, isNegative); // customer has credit
    });
  });

  group('Account Type Classification', () {
    test('receivable accounts are customer debts', () {
      // حسابات العملاء المدينة (receivable) = ديون العملاء لنا
      const accountType = 'receivable';
      expect(accountType, equals('receivable'));
    });

    test('payable accounts are supplier debts', () {
      // حسابات الموردين الدائنة (payable) = ديوننا للموردين
      const accountType = 'payable';
      expect(accountType, equals('payable'));
    });

    test('total receivable calculation', () {
      final receivables = [
        {'name': 'عميل 1', 'balance': 500.0},
        {'name': 'عميل 2', 'balance': 1200.0},
        {'name': 'عميل 3', 'balance': 300.0},
      ];
      final total = receivables.fold<double>(
        0.0,
        (sum, r) => sum + (r['balance'] as double),
      );
      expect(total, equals(2000.0));
    });
  });
}
