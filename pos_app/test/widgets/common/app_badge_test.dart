import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/widgets/common/app_badge.dart';
import 'package:pos_app/l10n/generated/app_localizations.dart';

// ===========================================
// App Badge Tests
// ===========================================

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ar'),
      home: Scaffold(body: Center(child: child)),
    );
  }

  /// Wraps a builder that gets BuildContext to create context-dependent widgets
  Widget buildContextTestWidget(Widget Function(BuildContext context) builder) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ar'),
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => builder(context),
          ),
        ),
      ),
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
      await tester.pumpAndSettle();

      expect(find.text('جديد'), findsOneWidget);
    });

    testWidgets('يعرض الأيقونة إذا كانت موجودة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppBadge(
          label: 'نقد',
          icon: Icons.payments,
        ),
      ));
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      expect(find.text('مكتمل'), findsOneWidget);
    });

    testWidgets('يدعم أحجام مختلفة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppBadge.success('نجاح', size: AppBadgeSize.large),
      ));
      await tester.pumpAndSettle();

      expect(find.text('نجاح'), findsOneWidget);
    });
  });

  group('AppBadge.warning', () {
    testWidgets('يُنشئ شارة تحذير', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppBadge.warning('تحذير'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('تحذير'), findsOneWidget);
    });
  });

  group('AppBadge.error', () {
    testWidgets('يُنشئ شارة خطأ', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppBadge.error('خطأ'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('خطأ'), findsOneWidget);
    });
  });

  group('AppBadge.info', () {
    testWidgets('يُنشئ شارة معلومات', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppBadge.info('معلومة'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('معلومة'), findsOneWidget);
    });
  });

  group('AppBadge.stock', () {
    testWidgets('يعرض "نفد" عندما الكمية 0', (tester) async {
      await tester.pumpWidget(buildContextTestWidget(
        (context) => AppBadge.stock(context, 0),
      ));
      await tester.pumpAndSettle();

      expect(find.text('نفد'), findsOneWidget);
    });

    testWidgets('يعرض "نفد" عندما الكمية سالبة', (tester) async {
      await tester.pumpWidget(buildContextTestWidget(
        (context) => AppBadge.stock(context, -5),
      ));
      await tester.pumpAndSettle();

      expect(find.text('نفد'), findsOneWidget);
    });

    testWidgets('يعرض "منخفض" عندما الكمية أقل من الحد الأدنى', (tester) async {
      await tester.pumpWidget(buildContextTestWidget(
        (context) => AppBadge.stock(context, 3, minQuantity: 5),
      ));
      await tester.pumpAndSettle();

      expect(find.text('منخفض (3)'), findsOneWidget);
    });

    testWidgets('يعرض "متوفر" عندما الكمية كافية', (tester) async {
      await tester.pumpWidget(buildContextTestWidget(
        (context) => AppBadge.stock(context, 10, minQuantity: 5),
      ));
      await tester.pumpAndSettle();

      expect(find.text('متوفر (10)'), findsOneWidget);
    });
  });

  group('AppBadge.paymentMethod', () {
    testWidgets('يعرض شارة نقد', (tester) async {
      await tester.pumpWidget(buildContextTestWidget(
        (context) => AppBadge.paymentMethod(context, 'cash'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('نقداً'), findsOneWidget);
      expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
    });

    testWidgets('يعرض شارة بطاقة', (tester) async {
      await tester.pumpWidget(buildContextTestWidget(
        (context) => AppBadge.paymentMethod(context, 'card'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('بطاقة'), findsOneWidget);
      expect(find.byIcon(Icons.credit_card), findsOneWidget);
    });

    testWidgets('يعرض شارة آجل', (tester) async {
      await tester.pumpWidget(buildContextTestWidget(
        (context) => AppBadge.paymentMethod(context, 'credit'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('آجل'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('يعرض طريقة دفع مخصصة', (tester) async {
      await tester.pumpWidget(buildContextTestWidget(
        (context) => AppBadge.paymentMethod(context, 'other'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('other'), findsOneWidget);
      expect(find.byIcon(Icons.payment), findsOneWidget);
    });

    testWidgets('يدعم الأسماء العربية', (tester) async {
      await tester.pumpWidget(buildContextTestWidget(
        (context) => AppBadge.paymentMethod(context, 'نقد'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('نقداً'), findsOneWidget);
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
      await tester.pumpAndSettle();

      expect(find.text('filled'), findsOneWidget);
    });

    testWidgets('outlined variant', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppBadge(
          label: 'outlined',
          variant: AppBadgeVariant.outlined,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('outlined'), findsOneWidget);
    });

    testWidgets('soft variant', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppBadge(
          label: 'soft',
          variant: AppBadgeVariant.soft,
        ),
      ));
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      expect(find.text('صغير'), findsOneWidget);
    });

    testWidgets('medium size', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppBadge(
          label: 'متوسط',
          size: AppBadgeSize.medium,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('متوسط'), findsOneWidget);
    });

    testWidgets('large size', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppBadge(
          label: 'كبير',
          size: AppBadgeSize.large,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('كبير'), findsOneWidget);
    });
  });

  group('AppCountBadge', () {
    testWidgets('يعرض العدد', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCountBadge(count: 5),
      ));
      await tester.pumpAndSettle();

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('لا يعرض شيء عندما العدد 0 و showZero=false', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCountBadge(count: 0),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('يعرض 0 عندما showZero=true', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCountBadge(count: 0, showZero: true),
      ));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('يعرض maxCount+ عندما العدد أكبر من maxCount', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCountBadge(count: 150, maxCount: 99),
      ));
      await tester.pumpAndSettle();

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('يدعم حجم مخصص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCountBadge(count: 5, size: 30),
      ));
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      expect(find.text('نشط'), findsOneWidget);
    });

    testWidgets('يعرض حالة غير نشطة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppStatusBadge(
          isActive: false,
          label: 'غير نشط',
        ),
      ));
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      expect(find.text('نشط'), findsNothing);
    });
  });

  group('AppStatusBadge.online', () {
    testWidgets('يعرض "متصل" عندما isOnline=true', (tester) async {
      await tester.pumpWidget(buildContextTestWidget(
        (context) => AppStatusBadge.online(context, isOnline: true),
      ));
      // Use pump() instead of pumpAndSettle() because the pulse animation never settles
      await tester.pump();

      expect(find.text('متصل'), findsOneWidget);
    });

    testWidgets('يعرض "غير متصل" عندما isOnline=false', (tester) async {
      await tester.pumpWidget(buildContextTestWidget(
        (context) => AppStatusBadge.online(context, isOnline: false),
      ));
      await tester.pumpAndSettle();

      expect(find.text('غير متصل'), findsOneWidget);
    });
  });

  group('AppStatusBadge.active', () {
    testWidgets('يعرض "نشط" عندما isActive=true', (tester) async {
      await tester.pumpWidget(buildContextTestWidget(
        (context) => AppStatusBadge.active(context, isActive: true),
      ));
      await tester.pumpAndSettle();

      expect(find.text('نشط'), findsOneWidget);
    });

    testWidgets('يعرض "غير نشط" عندما isActive=false', (tester) async {
      await tester.pumpWidget(buildContextTestWidget(
        (context) => AppStatusBadge.active(context, isActive: false),
      ));
      await tester.pumpAndSettle();

      expect(find.text('غير نشط'), findsOneWidget);
    });
  });

  group('AppCategoryBadge', () {
    testWidgets('يعرض اسم التصنيف', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCategoryBadge(category: 'مشروبات'),
      ));
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      expect(find.text('مشروبات'), findsOneWidget);
    });

    testWidgets('يدعم لون مخصص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCategoryBadge(
          category: 'مشروبات',
          color: Colors.purple,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('مشروبات'), findsOneWidget);
    });
  });
}
