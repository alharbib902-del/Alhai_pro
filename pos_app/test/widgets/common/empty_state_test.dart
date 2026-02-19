import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/widgets/common/app_empty_state.dart';

// ===========================================
// Empty State Widget Tests
// ===========================================

void main() {
  Widget buildTestWidget(AppEmptyState emptyState) {
    return MaterialApp(
      home: Scaffold(body: emptyState),
    );
  }

  group('AppEmptyState - Basic Constructor', () {
    testWidgets('يعرض الأيقونة والعنوان', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppEmptyState(
          icon: Icons.shopping_cart,
          title: 'عنوان اختبار',
        ),
      ));

      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      expect(find.text('عنوان اختبار'), findsOneWidget);
    });

    testWidgets('يعرض الوصف إذا كان موجوداً', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppEmptyState(
          icon: Icons.inbox,
          title: 'عنوان',
          description: 'هذا وصف تجريبي',
        ),
      ));

      expect(find.text('هذا وصف تجريبي'), findsOneWidget);
    });

    testWidgets('لا يعرض الوصف إذا كان null', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppEmptyState(
          icon: Icons.inbox,
          title: 'عنوان فقط',
        ),
      ));

      expect(find.text('عنوان فقط'), findsOneWidget);
    });

    testWidgets('يعرض الزر إذا كان actionText و onAction موجودين', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(buildTestWidget(
        AppEmptyState(
          icon: Icons.refresh,
          title: 'تحديث',
          actionText: 'إعادة المحاولة',
          onAction: () => pressed = true,
        ),
      ));

      expect(find.text('إعادة المحاولة'), findsOneWidget);

      await tester.tap(find.text('إعادة المحاولة'));
      expect(pressed, true);
    });

    testWidgets('لا يعرض الزر إذا كان actionText فقط بدون onAction', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppEmptyState(
          icon: Icons.inbox,
          title: 'عنوان',
          actionText: 'زر',
          // onAction غير موجود
        ),
      ));

      // No button rendered because onAction is null
      expect(find.text('زر'), findsNothing);
    });
  });

  group('AppEmptyState.emptyCart', () {
    testWidgets('يعرض محتوى السلة الفارغة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppEmptyState.emptyCart(),
      ));

      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
      expect(find.text('السلة فارغة'), findsOneWidget);
      expect(find.text('أضف منتجات للسلة لبدء البيع'), findsOneWidget);
    });

    testWidgets('يعرض زر تصفح إذا كان onBrowse موجود', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppEmptyState.emptyCart(onBrowse: () {}),
      ));

      expect(find.text('تصفح المنتجات'), findsOneWidget);
    });

    testWidgets('لا يعرض زر إذا كان onBrowse = null', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppEmptyState.emptyCart(),
      ));

      expect(find.text('تصفح المنتجات'), findsNothing);
    });
  });

  group('AppEmptyState.noProducts', () {
    testWidgets('يعرض محتوى لا توجد منتجات', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppEmptyState.noProducts(),
      ));

      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
      expect(find.text('لا توجد منتجات'), findsOneWidget);
      expect(find.text('ابدأ بإضافة منتجاتك الآن'), findsOneWidget);
    });

    testWidgets('يعرض زر إضافة إذا كان onAdd موجود', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppEmptyState.noProducts(onAdd: () {}),
      ));

      expect(find.text('إضافة منتج'), findsOneWidget);
    });
  });

  group('AppEmptyState.noSearchResults', () {
    testWidgets('يعرض محتوى لا توجد نتائج', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppEmptyState.noSearchResults(),
      ));

      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('لا توجد نتائج'), findsOneWidget);
    });

    testWidgets('يعرض نص البحث إذا كان موجود', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppEmptyState.noSearchResults(query: 'تفاح'),
      ));

      expect(find.text('لا توجد نتائج لـ "تفاح"'), findsOneWidget);
    });

    testWidgets('يعرض رسالة افتراضية إذا لم يكن هناك query', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppEmptyState.noSearchResults(),
      ));

      expect(find.text('جرب البحث بكلمات مختلفة'), findsOneWidget);
    });
  });

  group('AppEmptyState.noData', () {
    testWidgets('يعرض محتوى لا توجد بيانات', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppEmptyState.noData(),
      ));

      expect(find.byIcon(Icons.folder_open), findsOneWidget);
      expect(find.text('لا توجد بيانات'), findsOneWidget);
    });

    testWidgets('يعرض عنوان مخصص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppEmptyState.noData(title: 'رسالة مخصصة'),
      ));

      expect(find.text('رسالة مخصصة'), findsOneWidget);
    });
  });

  group('AppEmptyState.noConnection', () {
    testWidgets('يعرض محتوى لا يوجد اتصال', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppEmptyState.noConnection(),
      ));

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('لا يوجد اتصال'), findsOneWidget);
      expect(find.text('تحقق من اتصالك بالإنترنت'), findsOneWidget);
    });

    testWidgets('يعرض زر إعادة المحاولة إذا كان onRetry موجود', (tester) async {
      bool retried = false;

      await tester.pumpWidget(buildTestWidget(
        AppEmptyState.noConnection(onRetry: () => retried = true),
      ));

      expect(find.text('إعادة المحاولة'), findsOneWidget);

      await tester.tap(find.text('إعادة المحاولة'));
      expect(retried, true);
    });
  });

  group('AppEmptyState.noCustomers', () {
    testWidgets('يعرض محتوى لا يوجد عملاء', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppEmptyState.noCustomers(),
      ));

      expect(find.byIcon(Icons.people_outline), findsOneWidget);
      expect(find.text('لا يوجد عملاء'), findsOneWidget);
      expect(find.text('ابدأ بإضافة عملائك الآن'), findsOneWidget);
    });

    testWidgets('يعرض زر إضافة إذا كان onAdd موجود', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppEmptyState.noCustomers(onAdd: () {}),
      ));

      expect(find.text('إضافة عميل'), findsOneWidget);
    });
  });

  group('AppEmptyState.noOrders', () {
    testWidgets('يعرض محتوى لا توجد طلبات', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppEmptyState.noOrders(),
      ));

      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      expect(find.text('لا توجد طلبات'), findsOneWidget);
      expect(find.text('ستظهر الطلبات الجديدة هنا'), findsOneWidget);
    });
  });

  group('AppEmptyState - Layout', () {
    testWidgets('يتمركز في الوسط', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppEmptyState(
          icon: Icons.inbox,
          title: 'اختبار',
        ),
      ));

      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('يحتوي على padding', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppEmptyState(
          icon: Icons.inbox,
          title: 'اختبار',
        ),
      ));

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('يستخدم Column للترتيب', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppEmptyState(
          icon: Icons.inbox,
          title: 'اختبار',
        ),
      ));

      expect(find.byType(Column), findsOneWidget);
    });
  });
}
