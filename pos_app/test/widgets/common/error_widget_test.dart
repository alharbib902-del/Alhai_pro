import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/widgets/common/error_widget.dart' as app;

// ===========================================
// Error Widget Tests
// ===========================================

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('ErrorWidget - Basic Constructor', () {
    testWidgets('يعرض الرسالة والأيقونة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const app.ErrorWidget(message: 'حدث خطأ'),
      ));

      expect(find.text('حدث خطأ'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('يعرض أيقونة مخصصة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const app.ErrorWidget(
          message: 'خطأ',
          icon: Icons.warning,
        ),
      ));

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('يعرض زر إعادة المحاولة عندما onRetry موجود', (tester) async {
      bool retried = false;

      await tester.pumpWidget(buildTestWidget(
        app.ErrorWidget(
          message: 'خطأ',
          onRetry: () => retried = true,
        ),
      ));

      expect(find.text('إعادة المحاولة'), findsOneWidget);

      await tester.tap(find.text('إعادة المحاولة'));
      expect(retried, true);
    });

    testWidgets('لا يعرض زر إعادة المحاولة عندما onRetry غير موجود', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const app.ErrorWidget(message: 'خطأ'),
      ));

      expect(find.text('إعادة المحاولة'), findsNothing);
    });

    testWidgets('يتمركز في الوسط', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const app.ErrorWidget(message: 'خطأ'),
      ));

      // التحقق من وجود Center widget
      expect(find.byWidgetPredicate((widget) => widget is Center), findsAtLeastNWidgets(1));
    });
  });

  group('ErrorWidget.network', () {
    testWidgets('يعرض رسالة خطأ الشبكة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        app.ErrorWidget.network(),
      ));

      expect(find.text('خطأ في الاتصال بالخادم'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('يعرض زر إعادة المحاولة', (tester) async {
      bool retried = false;

      await tester.pumpWidget(buildTestWidget(
        app.ErrorWidget.network(onRetry: () => retried = true),
      ));

      await tester.tap(find.text('إعادة المحاولة'));
      expect(retried, true);
    });
  });

  group('ErrorWidget.loading', () {
    testWidgets('يعرض رسالة فشل التحميل الافتراضية', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        app.ErrorWidget.loading(),
      ));

      expect(find.text('فشل تحميل البيانات'), findsOneWidget);
      expect(find.byIcon(Icons.sync_problem), findsOneWidget);
    });

    testWidgets('يعرض رسالة مخصصة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        app.ErrorWidget.loading(details: 'فشل تحميل المنتجات'),
      ));

      expect(find.text('فشل تحميل المنتجات'), findsOneWidget);
    });
  });

  group('ErrorWidget.generic', () {
    testWidgets('يعرض رسالة الخطأ العام الافتراضية', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        app.ErrorWidget.generic(),
      ));

      expect(find.text('حدث خطأ غير متوقع'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('يعرض رسالة مخصصة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        app.ErrorWidget.generic(message: 'خطأ مخصص'),
      ));

      expect(find.text('خطأ مخصص'), findsOneWidget);
    });
  });

  group('ErrorMessage', () {
    testWidgets('يعرض رسالة الخطأ', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const app.ErrorMessage(message: 'رسالة خطأ'),
      ));

      expect(find.text('رسالة خطأ'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('يعرض زر الإغلاق عندما onDismiss موجود', (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(buildTestWidget(
        app.ErrorMessage(
          message: 'خطأ',
          onDismiss: () => dismissed = true,
        ),
      ));

      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, true);
    });

    testWidgets('لا يعرض زر الإغلاق عندما onDismiss غير موجود', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const app.ErrorMessage(message: 'خطأ'),
      ));

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('يستخدم Container مع تنسيق صحيح', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const app.ErrorMessage(message: 'خطأ'),
      ));

      expect(find.byType(Container), findsWidgets);
    });
  });
}
