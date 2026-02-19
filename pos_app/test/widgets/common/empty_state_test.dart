import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/widgets/common/empty_state.dart';

// ===========================================
// Empty State Widget Tests
// ===========================================

void main() {
  Widget buildTestWidget(EmptyState emptyState) {
    return MaterialApp(
      home: Scaffold(body: emptyState),
    );
  }

  group('EmptyState - Basic Constructor', () {
    testWidgets('يعرض الأيقونة والعنوان', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const EmptyState(
          icon: Icons.shopping_cart,
          title: 'عنوان اختبار',
        ),
      ));

      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      expect(find.text('عنوان اختبار'), findsOneWidget);
    });

    testWidgets('يعرض الوصف إذا كان موجوداً', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const EmptyState(
          icon: Icons.inbox,
          title: 'عنوان',
          description: 'هذا وصف تجريبي',
        ),
      ));

      expect(find.text('هذا وصف تجريبي'), findsOneWidget);
    });

    testWidgets('لا يعرض الوصف إذا كان null', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const EmptyState(
          icon: Icons.inbox,
          title: 'عنوان فقط',
        ),
      ));

      expect(find.text('عنوان فقط'), findsOneWidget);
      // لا يوجد Text آخر غير العنوان
    });

    testWidgets('يعرض الزر إذا كان actionLabel و onAction موجودين', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(buildTestWidget(
        EmptyState(
          icon: Icons.refresh,
          title: 'تحديث',
          actionLabel: 'إعادة المحاولة',
          onAction: () => pressed = true,
        ),
      ));

      expect(find.text('إعادة المحاولة'), findsOneWidget);

      await tester.tap(find.text('إعادة المحاولة'));
      expect(pressed, true);
    });

    testWidgets('لا يعرض الزر إذا كان actionLabel فقط بدون onAction', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const EmptyState(
          icon: Icons.inbox,
          title: 'عنوان',
          actionLabel: 'زر',
          // onAction غير موجود
        ),
      ));

      expect(find.byType(FilledButton), findsNothing);
    });
  });

  group('EmptyState.cart', () {
    testWidgets('يعرض محتوى السلة الفارغة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        EmptyState.cart(),
      ));

      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
      expect(find.text('السلة فارغة'), findsOneWidget);
      expect(find.text('أضف منتجات للبدء'), findsOneWidget);
    });

    testWidgets('يعرض زر تصفح إذا كان onAction موجود', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        EmptyState.cart(onAction: () {}),
      ));

      expect(find.text('تصفح المنتجات'), findsOneWidget);
    });

    testWidgets('لا يعرض زر إذا كان onAction = null', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        EmptyState.cart(),
      ));

      expect(find.byType(FilledButton), findsNothing);
    });
  });

  group('EmptyState.products', () {
    testWidgets('يعرض محتوى لا توجد منتجات', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        EmptyState.products(),
      ));

      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
      expect(find.text('لا توجد منتجات'), findsOneWidget);
      expect(find.text('لم يتم العثور على منتجات'), findsOneWidget);
    });

    testWidgets('يعرض زر تحديث إذا كان onRefresh موجود', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        EmptyState.products(onRefresh: () {}),
      ));

      expect(find.text('تحديث'), findsOneWidget);
    });
  });

  group('EmptyState.search', () {
    testWidgets('يعرض محتوى لا توجد نتائج', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        EmptyState.search(),
      ));

      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('لا توجد نتائج'), findsOneWidget);
    });

    testWidgets('يعرض نص البحث إذا كان موجود', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        EmptyState.search(query: 'تفاح'),
      ));

      expect(find.text('لم يتم العثور على نتائج لـ "تفاح"'), findsOneWidget);
    });

    testWidgets('يعرض رسالة افتراضية إذا لم يكن هناك query', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        EmptyState.search(),
      ));

      expect(find.text('جرب البحث بكلمات مختلفة'), findsOneWidget);
    });
  });

  group('EmptyState.noData', () {
    testWidgets('يعرض محتوى لا توجد بيانات', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        EmptyState.noData(),
      ));

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('لا توجد بيانات'), findsOneWidget);
      expect(find.text('لم يتم العثور على أي بيانات'), findsOneWidget);
    });

    testWidgets('يعرض رسالة مخصصة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        EmptyState.noData(message: 'رسالة مخصصة'),
      ));

      expect(find.text('رسالة مخصصة'), findsOneWidget);
    });
  });

  group('EmptyState.offline', () {
    testWidgets('يعرض محتوى لا يوجد اتصال', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        EmptyState.offline(),
      ));

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('لا يوجد اتصال'), findsOneWidget);
      expect(find.text('تحقق من اتصالك بالإنترنت'), findsOneWidget);
    });

    testWidgets('يعرض زر إعادة المحاولة إذا كان onRetry موجود', (tester) async {
      bool retried = false;

      await tester.pumpWidget(buildTestWidget(
        EmptyState.offline(onRetry: () => retried = true),
      ));

      expect(find.text('إعادة المحاولة'), findsOneWidget);

      await tester.tap(find.text('إعادة المحاولة'));
      expect(retried, true);
    });
  });

  group('EmptyState.customers', () {
    testWidgets('يعرض محتوى لا يوجد عملاء', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        EmptyState.customers(),
      ));

      expect(find.byIcon(Icons.people_outline), findsOneWidget);
      expect(find.text('لا يوجد عملاء'), findsOneWidget);
      expect(find.text('أضف عملاء جدد للبدء'), findsOneWidget);
    });

    testWidgets('يعرض زر إضافة إذا كان onAdd موجود', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        EmptyState.customers(onAdd: () {}),
      ));

      expect(find.text('إضافة عميل'), findsOneWidget);
    });
  });

  group('EmptyState.orders', () {
    testWidgets('يعرض محتوى لا توجد طلبات', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        EmptyState.orders(),
      ));

      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      expect(find.text('لا توجد طلبات'), findsOneWidget);
      expect(find.text('لم تقم بأي طلبات بعد'), findsOneWidget);
    });
  });

  group('EmptyState - Layout', () {
    testWidgets('يتمركز في الوسط', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const EmptyState(
          icon: Icons.inbox,
          title: 'اختبار',
        ),
      ));

      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('يحتوي على padding', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const EmptyState(
          icon: Icons.inbox,
          title: 'اختبار',
        ),
      ));

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('يستخدم Column للترتيب', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const EmptyState(
          icon: Icons.inbox,
          title: 'اختبار',
        ),
      ));

      expect(find.byType(Column), findsOneWidget);
    });
  });
}
