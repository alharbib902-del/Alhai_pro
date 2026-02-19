import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/widgets/pos/inline_payment.dart';

void main() {
  group('InlinePayment Widget Tests', () {
    testWidgets('يعرض طرق الدفع الثلاثة', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InlinePayment(
                total: 100.0,
                onComplete: (_) {},
              ),
            ),
          ),
        ),
      );

      // التحقق من وجود الأزرار الثلاثة
      expect(find.text('نقد'), findsOneWidget);
      expect(find.text('بطاقة'), findsOneWidget);
      expect(find.text('آجل'), findsOneWidget);
    });

    testWidgets('الضغط على نقد يختار طريقة الدفع النقدي', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InlinePayment(
                total: 100.0,
                onComplete: (_) {},
              ),
            ),
          ),
        ),
      );

      // الضغط على زر نقد
      await tester.tap(find.text('نقد'));
      await tester.pumpAndSettle();

      // يجب أن يظهر حقل المبلغ المستلم
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('يحسب الباقي بشكل صحيح', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InlinePayment(
                total: 85.50,
                onComplete: (_) {},
              ),
            ),
          ),
        ),
      );

      // اختيار نقد
      await tester.tap(find.text('نقد'));
      await tester.pumpAndSettle();

      // إدخال 100 ر.س
      final textField = find.byType(TextField).first;
      await tester.enterText(textField, '100');
      await tester.pumpAndSettle();

      // التحقق من عرض الباقي (14.50)
      expect(find.textContaining('14.50'), findsOneWidget);
    });

    testWidgets('لا يسمح بإتمام الدفع بمبلغ أقل من المطلوب', (tester) async {
      bool completed = false;
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InlinePayment(
                total: 100.0,
                onComplete: (_) => completed = true,
              ),
            ),
          ),
        ),
      );

      // اختيار نقد
      await tester.tap(find.text('نقد'));
      await tester.pumpAndSettle();

      // إدخال مبلغ أقل
      final textField = find.byType(TextField).first;
      await tester.enterText(textField, '50');
      await tester.pumpAndSettle();

      // محاولة الضغط على إتمام
      final completeButton = find.text('إتمام الدفع');
      if (completeButton.evaluate().isNotEmpty) {
        await tester.tap(completeButton);
        await tester.pumpAndSettle();
      }

      // لا يجب أن تكتمل العملية
      expect(completed, isFalse);
    });
  });
}
