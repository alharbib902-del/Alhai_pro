/// اختبارات حوار ملاحظة البيع - SaleNoteDialog Tests
///
/// يختبر:
/// - عرض الشرائح السريعة (توصيل، تغليف هدية، هش، عاجل، حجز)
/// - إدخال النص في حقل الملاحظة
/// - اختيار الشرائح وإضافتها للنص
/// - حد الأحرف (200 حرف)
/// - أزرار الإلغاء والحفظ والمسح
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/widgets/pos/sale_note_dialog.dart';

void main() {
  // دالة مساعدة لبناء الحوار داخل MaterialApp
  Widget buildDialog({String? initialNote}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () {
                showDialog<String>(
                  context: context,
                  builder: (_) => SaleNoteDialog(initialNote: initialNote),
                );
              },
              child: const Text('افتح الحوار'),
            ),
          ),
        ),
      ),
    );
  }

  // دالة مساعدة لفتح الحوار
  Future<void> openDialog(WidgetTester tester, {String? initialNote}) async {
    await tester.pumpWidget(buildDialog(initialNote: initialNote));
    await tester.tap(find.text('افتح الحوار'));
    await tester.pumpAndSettle();
  }

  group('SaleNoteDialog - عنوان الحوار', () {
    testWidgets('يعرض عنوان الحوار "ملاحظة على الفاتورة"', (tester) async {
      await openDialog(tester);

      expect(find.text('ملاحظة على الفاتورة'), findsOneWidget);
    });
  });

  group('SaleNoteDialog - الشرائح السريعة', () {
    testWidgets('يعرض جميع الشرائح السريعة الخمسة', (tester) async {
      await openDialog(tester);

      expect(find.text('توصيل'), findsOneWidget);
      expect(find.text('تغليف هدية'), findsOneWidget);
      expect(find.text('هش - حساس'), findsOneWidget);
      expect(find.text('عاجل'), findsOneWidget);
      expect(find.text('حجز'), findsOneWidget);
    });

    testWidgets('يعرض الشرائح كـ ActionChip', (tester) async {
      await openDialog(tester);

      expect(find.byType(ActionChip), findsNWidgets(5));
    });

    testWidgets('الضغط على شريحة يضيف النص لحقل الإدخال', (tester) async {
      await openDialog(tester);

      await tester.tap(find.text('توصيل'));
      await tester.pumpAndSettle();

      // التحقق من أن النص أُضيف لحقل الإدخال
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, 'توصيل');
    });

    testWidgets('الضغط على شريحتين يفصل بينهما بفاصلة', (tester) async {
      await openDialog(tester);

      await tester.tap(find.text('توصيل'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('عاجل'));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, 'توصيل, عاجل');
    });

    testWidgets('الضغط على شريحة ثالثة تضاف بعد فاصلة', (tester) async {
      await openDialog(tester);

      await tester.tap(find.text('توصيل'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('عاجل'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('حجز'));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, 'توصيل, عاجل, حجز');
    });
  });

  group('SaleNoteDialog - حقل الإدخال', () {
    testWidgets('يعرض حقل إدخال النص', (tester) async {
      await openDialog(tester);

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('يعرض تلميح "أضف ملاحظة..."', (tester) async {
      await openDialog(tester);

      expect(find.text('أضف ملاحظة...'), findsOneWidget);
    });

    testWidgets('يقبل إدخال نص من المستخدم', (tester) async {
      await openDialog(tester);

      await tester.enterText(find.byType(TextField), 'ملاحظة اختبار');
      await tester.pumpAndSettle();

      expect(find.text('ملاحظة اختبار'), findsOneWidget);
    });

    testWidgets('حد الأحرف 200 حرف', (tester) async {
      await openDialog(tester);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLength, 200);
    });

    testWidgets('عدد الأسطر 3', (tester) async {
      await openDialog(tester);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, 3);
    });
  });

  group('SaleNoteDialog - الملاحظة الأولية', () {
    testWidgets('يعرض الملاحظة الأولية في حقل الإدخال', (tester) async {
      await openDialog(tester, initialNote: 'ملاحظة سابقة');

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, 'ملاحظة سابقة');
    });

    testWidgets('يظهر زر "مسح" عند وجود ملاحظة أولية', (tester) async {
      await openDialog(tester, initialNote: 'ملاحظة');

      expect(find.text('مسح'), findsOneWidget);
    });
  });

  group('SaleNoteDialog - الأزرار', () {
    testWidgets('يعرض زر إلغاء', (tester) async {
      await openDialog(tester);

      expect(find.text('إلغاء'), findsOneWidget);
    });

    testWidgets('يعرض زر حفظ', (tester) async {
      await openDialog(tester);

      expect(find.text('حفظ'), findsOneWidget);
    });

    testWidgets('لا يعرض زر مسح عندما حقل النص فارغ', (tester) async {
      await openDialog(tester);

      expect(find.text('مسح'), findsNothing);
    });

    testWidgets('يعرض زر مسح بعد إدخال نص', (tester) async {
      await openDialog(tester);

      await tester.enterText(find.byType(TextField), 'ملاحظة');
      await tester.pumpAndSettle();

      expect(find.text('مسح'), findsOneWidget);
    });

    testWidgets('الضغط على إلغاء يغلق الحوار', (tester) async {
      await openDialog(tester);

      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();

      expect(find.text('ملاحظة على الفاتورة'), findsNothing);
    });

    testWidgets('الضغط على حفظ يغلق الحوار', (tester) async {
      await openDialog(tester);

      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();

      expect(find.text('ملاحظة على الفاتورة'), findsNothing);
    });

    testWidgets('زر مسح يظهر باللون الأحمر', (tester) async {
      await openDialog(tester, initialNote: 'ملاحظة');

      final clearButton = tester.widget<Text>(find.text('مسح'));
      expect(clearButton.style?.color, Colors.red);
    });
  });
}
