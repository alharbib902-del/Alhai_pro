import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/widgets/common/undo_system.dart';

void main() {
  group('UndoStack Tests', () {
    test('يبدأ بـ stack فارغ', () {
      final notifier = UndoStackNotifier();
      expect(notifier.state, isEmpty);
      expect(notifier.canUndo, isFalse);
    });

    test('يضيف عملية للـ stack', () {
      final notifier = UndoStackNotifier();
      
      notifier.push(UndoableAction(
        type: UndoActionType.removeFromCart,
        description: 'حذف منتج',
        undoCallback: () {},
      ));

      expect(notifier.state.length, 1);
      expect(notifier.canUndo, isTrue);
    });

    test('يزيل آخر عملية عند التراجع', () {
      final notifier = UndoStackNotifier();
      
      notifier.push(UndoableAction(
        type: UndoActionType.removeFromCart,
        description: 'حذف منتج 1',
        undoCallback: () {},
      ));
      
      notifier.push(UndoableAction(
        type: UndoActionType.removeFromCart,
        description: 'حذف منتج 2',
        undoCallback: () {},
      ));

      expect(notifier.state.length, 2);

      final popped = notifier.pop();
      expect(popped?.description, 'حذف منتج 2');
      expect(notifier.state.length, 1);
    });

    test('يحتفظ بآخر 10 عمليات فقط', () {
      final notifier = UndoStackNotifier();
      
      // إضافة 15 عملية
      for (int i = 0; i < 15; i++) {
        notifier.push(UndoableAction(
          type: UndoActionType.removeFromCart,
          description: 'عملية $i',
          undoCallback: () {},
        ));
      }

      // يجب أن يكون هناك 10 فقط
      expect(notifier.state.length, 10);
      // أول عملية يجب أن تكون عملية 5 (لأن 0-4 تمت إزالتها)
      expect(notifier.state.first.description, 'عملية 5');
    });

    test('يمسح كل العمليات', () {
      final notifier = UndoStackNotifier();
      
      notifier.push(UndoableAction(
        type: UndoActionType.removeFromCart,
        description: 'عملية',
        undoCallback: () {},
      ));

      notifier.clear();
      expect(notifier.state, isEmpty);
    });

    test('lastAction يرجع آخر عملية', () {
      final notifier = UndoStackNotifier();
      
      notifier.push(UndoableAction(
        type: UndoActionType.clearCart,
        description: 'مسح السلة',
        undoCallback: () {},
      ));

      expect(notifier.lastAction?.type, UndoActionType.clearCart);
    });

    test('pop يرجع null إذا كان الـ stack فارغ', () {
      final notifier = UndoStackNotifier();
      expect(notifier.pop(), isNull);
    });
  });

  group('UndoableAction Tests', () {
    test('يحفظ المبلغ إذا تم توفيره', () {
      final action = UndoableAction(
        type: UndoActionType.applyDiscount,
        description: 'تطبيق خصم',
        undoCallback: () {},
        amount: 50.0,
      );

      expect(action.amount, 50.0);
    });

    test('يحفظ timestamp تلقائياً', () {
      final before = DateTime.now();
      final action = UndoableAction(
        type: UndoActionType.changeQuantity,
        description: 'تغيير الكمية',
        undoCallback: () {},
      );
      final after = DateTime.now();

      expect(action.timestamp.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(action.timestamp.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });
  });

  group('confirmLargeOperation Tests', () {
    testWidgets('لا يعرض تأكيد للمبالغ الصغيرة', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  final result = await confirmLargeOperation(
                    context,
                    title: 'تأكيد',
                    message: 'هل أنت متأكد؟',
                    amount: 100.0,
                    threshold: 500.0,
                  );
                  // يجب أن يرجع true مباشرة بدون عرض dialog
                  expect(result, isTrue);
                },
                child: const Text('Test'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();
      
      // لا يجب أن يظهر dialog
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('يعرض تأكيد للمبالغ الكبيرة', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  await confirmLargeOperation(
                    context,
                    title: 'تأكيد',
                    message: 'هل أنت متأكد؟',
                    amount: 1000.0,
                    threshold: 500.0,
                  );
                },
                child: const Text('Test'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();
      
      // يجب أن يظهر dialog
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('تأكيد'), findsWidgets);
    });
  });
}
