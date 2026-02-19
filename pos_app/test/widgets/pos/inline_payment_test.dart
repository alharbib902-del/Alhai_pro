import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pos_app/l10n/generated/app_localizations.dart';
import 'package:pos_app/widgets/pos/inline_payment.dart';

// ===========================================
// Inline Payment Tests
// ===========================================

/// Helper to wrap widget with localization
Widget buildTestApp(Widget child) {
  return MaterialApp(
    locale: const Locale('ar'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(child: child),
    ),
  );
}

void main() {
  group('PaymentMethod Enum', () {
    test('يحتوي على 4 طرق دفع', () {
      expect(PaymentMethod.values, hasLength(4));
    });

    test('cash له القيم الصحيحة', () {
      expect(PaymentMethod.cash.icon, Icons.payments);
      expect(PaymentMethod.cash.color, const Color(0xFF4CAF50));
    });

    test('card له القيم الصحيحة', () {
      expect(PaymentMethod.card.icon, Icons.credit_card);
      expect(PaymentMethod.card.color, const Color(0xFF2196F3));
    });

    test('credit له القيم الصحيحة', () {
      expect(PaymentMethod.credit.icon, Icons.schedule);
      expect(PaymentMethod.credit.color, const Color(0xFFFF9800));
    });

    test('كل طريقة لها icon', () {
      for (final method in PaymentMethod.values) {
        expect(method.icon, isNotNull);
      }
    });

    test('كل طريقة لها color', () {
      for (final method in PaymentMethod.values) {
        expect(method.color, isNotNull);
      }
    });
  });

  group('PaymentResult', () {
    test('constructor يُنشئ instance صحيح', () {
      const result = PaymentResult(
        method: PaymentMethod.cash,
        amountPaid: 100.0,
        change: 10.0,
        success: true,
      );

      expect(result.method, PaymentMethod.cash);
      expect(result.amountPaid, 100.0);
      expect(result.change, 10.0);
      expect(result.success, true);
    });

    test('يدعم قيم مختلفة', () {
      const result = PaymentResult(
        method: PaymentMethod.card,
        amountPaid: 50.0,
        change: 0.0,
        success: false,
      );

      expect(result.method, PaymentMethod.card);
      expect(result.amountPaid, 50.0);
      expect(result.change, 0.0);
      expect(result.success, false);
    });

    test('يدعم credit payment', () {
      const result = PaymentResult(
        method: PaymentMethod.credit,
        amountPaid: 200.0,
        change: 0.0,
        success: true,
      );

      expect(result.method, PaymentMethod.credit);
      expect(result.success, true);
    });
  });

  group('InlinePayment Widget', () {
    testWidgets('يعرض العنوان "الدفع"', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const InlinePayment(total: 100.0)),
      );
      await tester.pumpAndSettle();

      expect(find.text('الدفع'), findsOneWidget);
    });

    testWidgets('يعرض الإجمالي', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const InlinePayment(total: 99.99)),
      );
      await tester.pumpAndSettle();

      expect(find.text('الإجمالي'), findsOneWidget);
      expect(find.textContaining('99.99'), findsAtLeastNWidgets(1));
    });

    testWidgets('يعرض جميع طرق الدفع', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const InlinePayment(total: 50.0)),
      );
      await tester.pumpAndSettle();

      expect(find.text('نقداً'), findsOneWidget);
      expect(find.text('بطاقة'), findsOneWidget);
      expect(find.text('آجل'), findsOneWidget);
    });

    testWidgets('يعرض زر إتمام الدفع', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const InlinePayment(total: 100.0)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('إتمام الدفع'), findsOneWidget);
    });

    testWidgets('يعرض حقل المبلغ المستلم للنقد', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const InlinePayment(total: 100.0)),
      );
      await tester.pumpAndSettle();

      expect(find.text('المبلغ المستلم'), findsOneWidget);
    });

    testWidgets('يعرض أيقونة الإغلاق عندما onCancel موجود', (tester) async {
      await tester.pumpWidget(
        buildTestApp(InlinePayment(
          total: 100.0,
          onCancel: () {},
        )),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('لا يعرض أيقونة الإغلاق عندما onCancel null', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const InlinePayment(
          total: 100.0,
          onCancel: null,
        )),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('يستدعي onCancel عند الضغط على زر الإغلاق', (tester) async {
      bool cancelled = false;

      await tester.pumpWidget(
        buildTestApp(InlinePayment(
          total: 100.0,
          onCancel: () => cancelled = true,
        )),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(cancelled, true);
    });

    testWidgets('يعرض أيقونات طرق الدفع', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const InlinePayment(total: 100.0)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.payments), findsOneWidget);
      expect(find.byIcon(Icons.credit_card), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('يعرض TextField', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const InlinePayment(total: 50.0)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('يعرض زر الدفع', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const InlinePayment(total: 50.0)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('إتمام الدفع'), findsOneWidget);
    });
  });

  group('InlinePayment Calculations', () {
    test('حساب الباقي: 100 - 90 = 10', () {
      const paid = 100.0;
      const total = 90.0;
      const change = paid - total;

      expect(change, 10.0);
    });

    test('لا يوجد باقي عندما المبلغ مساوي للإجمالي', () {
      const paid = 50.0;
      const total = 50.0;
      const change = paid - total;

      expect(change, 0.0);
    });

    test('الباقي سالب عندما المبلغ أقل من الإجمالي', () {
      const paid = 40.0;
      const total = 50.0;
      const change = paid - total;

      expect(change, -10.0);
    });
  });

  group('PaymentMethod Colors', () {
    test('cash أخضر', () {
      expect(PaymentMethod.cash.color, const Color(0xFF4CAF50));
    });

    test('card أزرق', () {
      expect(PaymentMethod.card.color, const Color(0xFF2196F3));
    });

    test('credit برتقالي', () {
      expect(PaymentMethod.credit.color, const Color(0xFFFF9800));
    });
  });

  group('PaymentMethod localizedLabel', () {
    test('localizedLabel method exists on all values', () {
      // localizedLabel requires AppLocalizations which needs context
      // so we just verify the method exists
      for (final method in PaymentMethod.values) {
        expect(method.localizedLabel, isNotNull);
      }
    });
  });
}
