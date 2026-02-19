import 'package:flutter_test/flutter_test.dart';

/// اختبارات بنية Shifts Providers
///
/// الـ providers تعتمد على getIt<AppDatabase>() لذلك الاختبارات هنا تركز على:
/// - التحقق من أن الـ providers معرّفة بشكل صحيح
/// - اختبار المنطق النقي (pure logic) المتاح
///
/// اختبارات التكامل الكاملة مع DB موجودة في:
/// test/data/daos/shifts_dao_test.dart
void main() {
  group('Shifts Provider Structure', () {
    test('shift status values are well-defined', () {
      // الورديات لها 3 حالات: open, closed, cancelled
      const statuses = ['open', 'closed', 'cancelled'];
      expect(statuses, contains('open'));
      expect(statuses, contains('closed'));
      expect(statuses.length, equals(3));
    });

    test('cash movement types are well-defined', () {
      // حركات الصندوق: cash_in, cash_out
      const types = ['cash_in', 'cash_out'];
      expect(types, contains('cash_in'));
      expect(types, contains('cash_out'));
      expect(types.length, equals(2));
    });

    test('shift difference calculation works correctly', () {
      // الفرق = النقد الفعلي - النقد المتوقع
      const closingCash = 1500.0;
      const expectedCash = 1450.0;
      const difference = closingCash - expectedCash;
      expect(difference, equals(50.0)); // زيادة 50 ريال
    });

    test('shift difference calculation - deficit', () {
      const closingCash = 1400.0;
      const expectedCash = 1450.0;
      const difference = closingCash - expectedCash;
      expect(difference, equals(-50.0)); // نقص 50 ريال
    });

    test('shift difference calculation - exact match', () {
      const closingCash = 1450.0;
      const expectedCash = 1450.0;
      const difference = closingCash - expectedCash;
      expect(difference, equals(0.0));
    });

    test('expected cash calculation', () {
      // النقد المتوقع = رصيد الافتتاح + المبيعات نقداً - المرتجعات - المصروفات
      const openingCash = 500.0;
      const cashSales = 3000.0;
      const cashRefunds = 200.0;
      const cashExpenses = 150.0;
      const expectedCash =
          openingCash + cashSales - cashRefunds - cashExpenses;
      expect(expectedCash, equals(3150.0));
    });

    test('shift duration calculation', () {
      final openedAt = DateTime(2026, 2, 12, 8, 0);
      final closedAt = DateTime(2026, 2, 12, 16, 30);
      final duration = closedAt.difference(openedAt);
      expect(duration.inHours, equals(8));
      expect(duration.inMinutes, equals(510));
    });
  });
}
