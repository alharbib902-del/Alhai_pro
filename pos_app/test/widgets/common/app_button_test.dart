import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/widgets/common/app_button.dart';

// ===========================================
// App Button Tests
// ===========================================

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('ButtonSize enum', () {
    test('يحتوي على جميع الأحجام', () {
      expect(ButtonSize.values.length, 3);
      expect(ButtonSize.values, contains(ButtonSize.small));
      expect(ButtonSize.values, contains(ButtonSize.medium));
      expect(ButtonSize.values, contains(ButtonSize.large));
    });
  });

  group('AppButtonVariant enum', () {
    test('يحتوي على جميع الأنواع', () {
      expect(AppButtonVariant.values.length, 4);
      expect(AppButtonVariant.values, contains(AppButtonVariant.filled));
      expect(AppButtonVariant.values, contains(AppButtonVariant.outlined));
      expect(AppButtonVariant.values, contains(AppButtonVariant.ghost));
      expect(AppButtonVariant.values, contains(AppButtonVariant.soft));
    });
  });

  group('AppButton - Basic Constructor', () {
    testWidgets('يعرض النص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppButton(label: 'اضغط هنا'),
      ));

      expect(find.text('اضغط هنا'), findsOneWidget);
    });

    testWidgets('يستدعي onPressed عند الضغط', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(buildTestWidget(
        AppButton(
          label: 'اضغط',
          onPressed: () => pressed = true,
        ),
      ));

      await tester.tap(find.text('اضغط'));
      expect(pressed, true);
    });

    testWidgets('يعرض الأيقونة إذا كانت موجودة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppButton(
          label: 'حفظ',
          icon: Icons.save,
        ),
      ));

      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('يعرض أيقونة suffix إذا كانت موجودة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppButton(
          label: 'التالي',
          suffixIcon: Icons.arrow_forward,
        ),
      ));

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('يعرض CircularProgressIndicator عندما isLoading=true', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppButton(
          label: 'جاري الحفظ',
          isLoading: true,
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('لا يستجيب عندما disabled=true', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(buildTestWidget(
        AppButton(
          label: 'اضغط',
          onPressed: () => pressed = true,
          disabled: true,
        ),
      ));

      await tester.tap(find.text('اضغط'));
      expect(pressed, false);
    });

    testWidgets('لا يستجيب عندما isLoading=true', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(buildTestWidget(
        AppButton(
          label: 'اضغط',
          onPressed: () => pressed = true,
          isLoading: true,
        ),
      ));

      await tester.tap(find.text('اضغط'));
      expect(pressed, false);
    });

    testWidgets('يعرض shortcutHint إذا كان موجوداً', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppButton(
          label: 'بحث',
          shortcutHint: 'F1',
        ),
      ));

      expect(find.text('F1'), findsOneWidget);
    });
  });

  group('AppButton.primary', () {
    testWidgets('يُنشئ زر أساسي', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppButton.primary(label: 'حفظ'),
      ));

      expect(find.text('حفظ'), findsOneWidget);
    });

    testWidgets('يدعم fullWidth', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppButton.primary(
          label: 'حفظ',
          fullWidth: true,
        ),
      ));

      expect(find.text('حفظ'), findsOneWidget);
    });

    testWidgets('يدعم isFullWidth alias', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppButton.primary(
          label: 'حفظ',
          isFullWidth: true,
        ),
      ));

      expect(find.text('حفظ'), findsOneWidget);
    });
  });

  group('AppButton.secondary', () {
    testWidgets('يُنشئ زر ثانوي', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppButton.secondary(label: 'إلغاء'),
      ));

      expect(find.text('إلغاء'), findsOneWidget);
    });
  });

  group('AppButton.danger', () {
    testWidgets('يُنشئ زر خطر', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppButton.danger(label: 'حذف'),
      ));

      expect(find.text('حذف'), findsOneWidget);
    });
  });

  group('AppButton.success', () {
    testWidgets('يُنشئ زر نجاح', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppButton.success(label: 'تأكيد'),
      ));

      expect(find.text('تأكيد'), findsOneWidget);
    });
  });

  group('AppButton.ghost', () {
    testWidgets('يُنشئ زر ghost', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppButton.ghost(label: 'المزيد'),
      ));

      expect(find.text('المزيد'), findsOneWidget);
    });
  });

  group('AppButton - Sizes', () {
    testWidgets('small size', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppButton(
          label: 'صغير',
          size: ButtonSize.small,
        ),
      ));

      expect(find.text('صغير'), findsOneWidget);
    });

    testWidgets('medium size', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppButton(
          label: 'متوسط',
          size: ButtonSize.medium,
        ),
      ));

      expect(find.text('متوسط'), findsOneWidget);
    });

    testWidgets('large size', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppButton(
          label: 'كبير',
          size: ButtonSize.large,
        ),
      ));

      expect(find.text('كبير'), findsOneWidget);
    });
  });

  group('AppButton - Variants', () {
    testWidgets('filled variant', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppButton(
          label: 'filled',
          variant: AppButtonVariant.filled,
        ),
      ));

      expect(find.text('filled'), findsOneWidget);
    });

    testWidgets('outlined variant', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppButton(
          label: 'outlined',
          variant: AppButtonVariant.outlined,
        ),
      ));

      expect(find.text('outlined'), findsOneWidget);
    });

    testWidgets('ghost variant', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppButton(
          label: 'ghost',
          variant: AppButtonVariant.ghost,
        ),
      ));

      expect(find.text('ghost'), findsOneWidget);
    });

    testWidgets('soft variant', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppButton(
          label: 'soft',
          variant: AppButtonVariant.soft,
        ),
      ));

      expect(find.text('soft'), findsOneWidget);
    });
  });

  group('AppIconButton', () {
    testWidgets('يعرض الأيقونة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppIconButton(icon: Icons.add),
      ));

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('يستدعي onPressed عند الضغط', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(buildTestWidget(
        AppIconButton(
          icon: Icons.add,
          onPressed: () => pressed = true,
        ),
      ));

      await tester.tap(find.byIcon(Icons.add));
      expect(pressed, true);
    });

    testWidgets('يعرض CircularProgressIndicator عندما isLoading=true', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppIconButton(
          icon: Icons.add,
          isLoading: true,
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('لا يستجيب عندما disabled=true', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(buildTestWidget(
        AppIconButton(
          icon: Icons.add,
          onPressed: () => pressed = true,
          disabled: true,
        ),
      ));

      await tester.tap(find.byIcon(Icons.add));
      expect(pressed, false);
    });

    testWidgets('يعرض tooltip إذا كان موجوداً', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppIconButton(
          icon: Icons.add,
          tooltip: 'إضافة',
        ),
      ));

      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('يدعم أحجام مختلفة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppIconButton(
          icon: Icons.add,
          size: 50,
        ),
      ));

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('يدعم جميع variants', (tester) async {
      for (final variant in AppButtonVariant.values) {
        await tester.pumpWidget(buildTestWidget(
          AppIconButton(
            icon: Icons.add,
            variant: variant,
          ),
        ));

        expect(find.byIcon(Icons.add), findsOneWidget);
      }
    });
  });
}
