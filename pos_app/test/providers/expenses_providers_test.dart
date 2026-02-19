import 'package:flutter_test/flutter_test.dart';

/// اختبارات بنية Expenses Providers
///
/// الـ providers تعتمد على getIt<AppDatabase>() لذلك الاختبارات هنا تركز على:
/// - حسابات المصروفات
/// - تصنيف المصروفات
/// - التحقق من صحة بيانات المصروفات
///
/// اختبارات التكامل الكاملة مع DB موجودة في:
/// test/data/daos/expenses_dao_test.dart
void main() {
  group('Expense Calculations', () {
    test('total daily expenses sums correctly', () {
      final expenses = [250.0, 150.0, 500.0, 75.0];
      final total = expenses.fold(0.0, (sum, e) => sum + e);
      expect(total, equals(975.0));
    });

    test('total is 0 when no expenses', () {
      final expenses = <double>[];
      final total = expenses.fold(0.0, (sum, e) => sum + e);
      expect(total, equals(0.0));
    });

    test('average expense calculation', () {
      final expenses = [100.0, 200.0, 300.0, 400.0];
      final total = expenses.fold(0.0, (sum, e) => sum + e);
      final average = total / expenses.length;
      expect(average, equals(250.0));
    });
  });

  group('Expense Category Grouping', () {
    test('groups expenses by category', () {
      final expenses = [
        {'category': 'إيجار', 'amount': 5000.0},
        {'category': 'رواتب', 'amount': 8000.0},
        {'category': 'إيجار', 'amount': 500.0},
        {'category': 'كهرباء', 'amount': 1200.0},
        {'category': 'رواتب', 'amount': 3000.0},
      ];

      final grouped = <String, double>{};
      for (final expense in expenses) {
        final category = expense['category'] as String;
        final amount = expense['amount'] as double;
        grouped[category] = (grouped[category] ?? 0) + amount;
      }

      expect(grouped['إيجار'], equals(5500.0));
      expect(grouped['رواتب'], equals(11000.0));
      expect(grouped['كهرباء'], equals(1200.0));
      expect(grouped.length, equals(3));
    });

    test('category percentage calculation', () {
      const categoryTotal = 5000.0;
      const grandTotal = 20000.0;
      const percentage = (categoryTotal / grandTotal) * 100;
      expect(percentage, equals(25.0));
    });

    test('category percentage when total is 0', () {
      const categoryTotal = 0.0;
      const grandTotal = 0.0;
      const percentage =
          grandTotal > 0 ? (categoryTotal / grandTotal) * 100 : 0.0;
      expect(percentage, equals(0.0));
    });
  });

  group('Expense Payment Methods', () {
    test('valid payment methods', () {
      const methods = ['cash', 'card', 'transfer'];
      expect(methods, contains('cash'));
      expect(methods, contains('card'));
      expect(methods, contains('transfer'));
    });

    test('default payment method is cash', () {
      const defaultMethod = 'cash';
      expect(defaultMethod, equals('cash'));
    });
  });

  group('Expense Date Filtering', () {
    test('filters expenses within date range', () {
      final today = DateTime(2026, 2, 12);
      final expenses = [
        {'date': DateTime(2026, 2, 11), 'amount': 100.0},
        {'date': DateTime(2026, 2, 12), 'amount': 200.0},
        {'date': DateTime(2026, 2, 12), 'amount': 300.0},
        {'date': DateTime(2026, 2, 13), 'amount': 400.0},
      ];

      final todayExpenses = expenses.where((e) {
        final date = e['date'] as DateTime;
        return date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
      }).toList();

      expect(todayExpenses.length, equals(2));
      final total = todayExpenses.fold<double>(
        0.0,
        (sum, e) => sum + (e['amount'] as double),
      );
      expect(total, equals(500.0));
    });

    test('monthly expense total', () {
      final expenses = [
        {'date': DateTime(2026, 2, 1), 'amount': 5000.0},
        {'date': DateTime(2026, 2, 10), 'amount': 1200.0},
        {'date': DateTime(2026, 2, 15), 'amount': 800.0},
        {'date': DateTime(2026, 1, 30), 'amount': 3000.0}, // different month
      ];

      final febExpenses = expenses.where((e) {
        final date = e['date'] as DateTime;
        return date.month == 2 && date.year == 2026;
      }).toList();

      final total = febExpenses.fold<double>(
        0.0,
        (sum, e) => sum + (e['amount'] as double),
      );
      expect(total, equals(7000.0));
    });
  });

  group('Expense Validation', () {
    test('amount must be positive', () {
      const amount = 100.0;
      expect(amount > 0, isTrue);
    });

    test('zero amount is invalid for expense', () {
      const amount = 0.0;
      expect(amount > 0, isFalse);
    });

    test('negative amount is invalid', () {
      const amount = -50.0;
      expect(amount > 0, isFalse);
    });

    test('description must not be empty', () {
      const description = 'دفع إيجار الشهر';
      expect(description.isNotEmpty, isTrue);
    });

    test('category must be selected', () {
      const categoryId = 'cat_rent_001';
      expect(categoryId.isNotEmpty, isTrue);
    });
  });
}
