import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pos_app/l10n/generated/app_localizations.dart';
import 'package:pos_app/widgets/pos/inline_payment.dart';

/// Helper to wrap widget with localization and Riverpod
Widget buildTestApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('InlinePayment Widget Tests', () {
    testWidgets('يعرض طرق الدفع الثلاثة', (tester) async {
      await tester.pumpWidget(
        buildTestApp(InlinePayment(
          total: 100.0,
          onComplete: (_) {},
        )),
      );
      await tester.pumpAndSettle();

      expect(find.text('نقداً'), findsOneWidget);
      expect(find.text('بطاقة'), findsOneWidget);
      expect(find.text('آجل'), findsOneWidget);
    });

    testWidgets('الضغط على نقد يختار طريقة الدفع النقدي', (tester) async {
      await tester.pumpWidget(
        buildTestApp(InlinePayment(
          total: 100.0,
          onComplete: (_) {},
        )),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('نقداً'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('يحسب الباقي بشكل صحيح', (tester) async {
      await tester.pumpWidget(
        buildTestApp(InlinePayment(
          total: 85.50,
          onComplete: (_) {},
        )),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('نقداً'));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField).first;
      await tester.enterText(textField, '100');
      await tester.pumpAndSettle();

      expect(find.textContaining('14.50'), findsOneWidget);
    });

    testWidgets('لا يسمح بإتمام الدفع بمبلغ أقل من المطلوب', (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        buildTestApp(InlinePayment(
          total: 100.0,
          onComplete: (_) => completed = true,
        )),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('نقداً'));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField).first;
      await tester.enterText(textField, '50');
      await tester.pumpAndSettle();

      final completeButton = find.text('إتمام الدفع');
      if (completeButton.evaluate().isNotEmpty) {
        await tester.tap(completeButton);
        await tester.pumpAndSettle();
      }

      expect(completed, isFalse);
    });
  });
}
