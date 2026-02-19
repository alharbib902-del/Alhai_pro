import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/widgets/common/app_badge.dart';

// ===========================================
// App Badge Tests
// ===========================================

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('AppBadgeVariant enum', () {
    test('يحتوي على جميع الأنواع', () {
      expect(AppBadgeVariant.values.length, 3);
      expect(AppBadgeVariant.values, contains(AppBadgeVariant.filled));
      expect(AppBadgeVariant.values, contains(AppBadgeVariant.outlined));
      expect(AppBadgeVariant.values, contains(AppBadgeVariant.soft));
    });
  });

  group('AppBadgeSize enum', () {
    test('يحتوي على جميع الأحجام', () {
      expect(AppBadgeSize.values.length, 3);
      expect(AppBadgeSize.values, contains(AppBadgeSize.small));
      expect(AppBadgeSize.values, contains(AppBadgeSize.medium));
      expect(AppBadgeSize.values, contains(AppBadgeSize.large));
    });
  });

  group('AppBadge - Basic Constructor', () {
    testWidgets('يعرض النص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppBadge(label: 'جديد'),
      ));

      expect(find.text('جديد'), findsOneWidget);
    });

    testWidgets('يعرض الأيقونة إذا كانت موجودة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppBadge(
          label: 'نقد',
          icon: Icons.payments,
        ),
      ));

      expect(find.byIcon(Icons.payments), findsOneWidget);
    });

    testWidgets('يستدعي onTap عند الضغط', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(buildTestWidget(
        AppBadge(
          label: 'اضغط',
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.text('اضغط'));
      expect(tapped, true);
    });

    testWidgets('يعرض أيقونة الحذف إذا كان onDelete موجوداً', (tester) async {
      bool deleted = false;

      await tester.pumpWidget(buildTestWidget(
        AppBadge(
          label: 'تصنيف',
          onDelete: () => deleted = true,
        ),
      ));

      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      expect(deleted, true);
    });
  });

  group('AppBadge.success', () {
    testWidgets('يُنشئ شارة نجاح', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppBadge.success('مكتمل'),
      ));

      expect(find.text('مكتمل'), findsOneWidget);
    });

    testWidgets('يدعم أحجام مختلفة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppBadge.success('نجاح', size: AppBadgeSize.large),
      ));

      expect(find.text('نجاح'), findsOneWidget);
    });
  });

  group('AppBadge.warning', () {
    testWidgets('يُنشئ شارة تحذير', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppBadge.warning('تحذير'),
      ));

      expect(find.text('تحذير'), findsOneWidget);
    });
  });

  group('AppBadge.error', () {
    testWidgets('يُنشئ شارة خطأ', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppBadge.error('خطأ'),
      ));

      expect(find.text('خطأ'), findsOneWidget);
    });
  });

  group('AppBadge.info', () {
    testWidgets('يُنشئ شارة معلومات', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppBadge.info('معلومة'),
      ));

      expect(find.text('معلومة'), findsOneWidget);
    });
  });

  group('AppBadge.stock', () {
    testWidgets('يعرض "نفذ" عندما الكمية 0', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppBadge.stock(0),
      ));

      expect(find.text('نفذ'), findsOneWidget);
    });

    testWidgets('يعرض "نفذ" عندما الكمية سالبة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppBadge.stock(-5),
      ));

      expect(find.text('نفذ'), findsOneWidget);
    });

    testWidgets('يعرض "قليل" عندما الكمية أقل من الحد الأدنى', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppBadge.stock(3, minQuantity: 5),
      ));

      expect(find.text('قليل (3)'), findsOneWidget);
    });

    testWidgets('يعرض "متوفر" عندما الكمية كافية', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppBadge.stock(10, minQuantity: 5),
      ));

      expect(find.text('متوفر (10)'), findsOneWidget);
    });
  });

  group('AppBadge.paymentMethod', () {
    testWidgets('يعرض شارة نقد', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppBadge.paymentMethod('cash'),
      ));

      expect(find.text('نقد'), findsOneWidget);
      expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
    });

    testWidgets('يعرض شارة بطاقة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppBadge.paymentMethod('card'),
      ));

      expect(find.text('بطاقة'), findsOneWidget);
      expect(find.byIcon(Icons.credit_card), findsOneWidget);
    });

    testWidgets('يعرض شارة آجل', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppBadge.paymentMethod('credit'),
      ));

      expect(find.text('آجل'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('يعرض طريقة دفع مخصصة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppBadge.paymentMethod('other'),
      ));

      expect(find.text('other'), findsOneWidget);
      expect(find.byIcon(Icons.payment), findsOneWidget);
    });

    testWidgets('يدعم الأسماء العربية', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppBadge.paymentMethod('نقد'),
      ));

      expect(find.text('نقد'), findsOneWidget);
    });
  });

  group('AppBadge - Variants', () {
    testWidgets('filled variant', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppBadge(
          label: 'filled',
          variant: AppBadgeVariant.filled,
        ),
      ));

      expect(find.text('filled'), findsOneWidget);
    });

    testWidgets('outlined variant', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppBadge(
          label: 'outlined',
          variant: AppBadgeVariant.outlined,
        ),
      ));

      expect(find.text('outlined'), findsOneWidget);
    });

    testWidgets('soft variant', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppBadge(
          label: 'soft',
          variant: AppBadgeVariant.soft,
        ),
      ));

      expect(find.text('soft'), findsOneWidget);
    });
  });

  group('AppBadge - Sizes', () {
    testWidgets('small size', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppBadge(
          label: 'صغير',
          size: AppBadgeSize.small,
        ),
      ));

      expect(find.text('صغير'), findsOneWidget);
    });

    testWidgets('medium size', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppBadge(
          label: 'متوسط',
          size: AppBadgeSize.medium,
        ),
      ));

      expect(find.text('متوسط'), findsOneWidget);
    });

    testWidgets('large size', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppBadge(
          label: 'كبير',
          size: AppBadgeSize.large,
        ),
      ));

      expect(find.text('كبير'), findsOneWidget);
    });
  });

  group('AppCountBadge', () {
    testWidgets('يعرض العدد', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCountBadge(count: 5),
      ));

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('لا يعرض شيء عندما العدد 0 و showZero=false', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCountBadge(count: 0),
      ));

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('يعرض 0 عندما showZero=true', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCountBadge(count: 0, showZero: true),
      ));

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('يعرض maxCount+ عندما العدد أكبر من maxCount', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCountBadge(count: 150, maxCount: 99),
      ));

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('يدعم حجم مخصص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCountBadge(count: 5, size: 30),
      ));

      expect(find.text('5'), findsOneWidget);
    });
  });

  group('AppStatusBadge', () {
    testWidgets('يعرض حالة نشطة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppStatusBadge(
          isActive: true,
          label: 'نشط',
        ),
      ));

      expect(find.text('نشط'), findsOneWidget);
    });

    testWidgets('يعرض حالة غير نشطة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppStatusBadge(
          isActive: false,
          label: 'غير نشط',
        ),
      ));

      expect(find.text('غير نشط'), findsOneWidget);
    });

    testWidgets('لا يعرض النص عندما showLabel=false', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppStatusBadge(
          isActive: true,
          label: 'نشط',
          showLabel: false,
        ),
      ));

      expect(find.text('نشط'), findsNothing);
    });
  });

  group('AppStatusBadge.online', () {
    testWidgets('يعرض "متصل" عندما isOnline=true', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppStatusBadge.online(isOnline: true),
      ));

      expect(find.text('متصل'), findsOneWidget);
    });

    testWidgets('يعرض "غير متصل" عندما isOnline=false', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppStatusBadge.online(isOnline: false),
      ));

      expect(find.text('غير متصل'), findsOneWidget);
    });
  });

  group('AppStatusBadge.active', () {
    testWidgets('يعرض "نشط" عندما isActive=true', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppStatusBadge.active(isActive: true),
      ));

      expect(find.text('نشط'), findsOneWidget);
    });

    testWidgets('يعرض "غير نشط" عندما isActive=false', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppStatusBadge.active(isActive: false),
      ));

      expect(find.text('غير نشط'), findsOneWidget);
    });
  });

  group('AppCategoryBadge', () {
    testWidgets('يعرض اسم التصنيف', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCategoryBadge(category: 'مشروبات'),
      ));

      expect(find.text('مشروبات'), findsOneWidget);
    });

    testWidgets('يستدعي onTap عند الضغط', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(buildTestWidget(
        AppCategoryBadge(
          category: 'مشروبات',
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.text('مشروبات'));
      expect(tapped, true);
    });

    testWidgets('يدعم حالة isSelected', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCategoryBadge(
          category: 'مشروبات',
          isSelected: true,
        ),
      ));

      expect(find.text('مشروبات'), findsOneWidget);
    });

    testWidgets('يدعم لون مخصص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCategoryBadge(
          category: 'مشروبات',
          color: Colors.purple,
        ),
      ));

      expect(find.text('مشروبات'), findsOneWidget);
    });
  });
}
