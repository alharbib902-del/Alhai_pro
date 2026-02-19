import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/widgets/common/app_input.dart';

// ===========================================
// App Input Tests
// ===========================================

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ))),
    );
  }

  group('AppTextField - Basic Constructor', () {
    testWidgets('يعرض التسمية', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppTextField(label: 'الاسم'),
      ));

      expect(find.text('الاسم'), findsOneWidget);
    });

    testWidgets('يعرض نص التلميح', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppTextField(hint: 'أدخل اسمك'),
      ));

      expect(find.text('أدخل اسمك'), findsOneWidget);
    });

    testWidgets('يعرض علامة مطلوب (*)', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppTextField(
          label: 'الاسم',
          required: true,
        ),
      ));

      expect(find.text(' *'), findsOneWidget);
    });

    testWidgets('يستدعي onChanged عند التغيير', (tester) async {
      String? value;

      await tester.pumpWidget(buildTestWidget(
        AppTextField(
          onChanged: (v) => value = v,
        ),
      ));

      await tester.enterText(find.byType(TextFormField), 'نص جديد');
      expect(value, 'نص جديد');
    });

    testWidgets('يستدعي onSubmitted عند الإرسال', (tester) async {
      String? submitted;

      await tester.pumpWidget(buildTestWidget(
        AppTextField(
          onSubmitted: (v) => submitted = v,
        ),
      ));

      await tester.enterText(find.byType(TextFormField), 'نص');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submitted, 'نص');
    });

    testWidgets('يعرض أيقونة prefix', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppTextField(prefixIcon: Icons.person),
      ));

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('يعرض suffix', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppTextField(suffix: Icon(Icons.check)),
      ));

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('يدعم readOnly', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppTextField(
          initialValue: 'قراءة فقط',
          readOnly: true,
        ),
      ));

      // التحقق من وجود TextFormField
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('يدعم enabled=false', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppTextField(enabled: false),
      ));

      // التحقق من وجود TextFormField
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('يعرض رسالة الخطأ', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppTextField(errorText: 'هذا الحقل مطلوب'),
      ));

      expect(find.text('هذا الحقل مطلوب'), findsOneWidget);
    });

    testWidgets('يعرض رسالة المساعدة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppTextField(helperText: 'أدخل اسمك الكامل'),
      ));

      expect(find.text('أدخل اسمك الكامل'), findsOneWidget);
    });

    testWidgets('يخفي النص عندما obscureText=true', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppTextField(obscureText: true),
      ));

      // يجب أن يعرض زر تبديل الرؤية
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('يبدل رؤية كلمة السر', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppTextField(obscureText: true),
      ));

      expect(find.byIcon(Icons.visibility), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });

  group('AppTextField.search', () {
    testWidgets('يُنشئ حقل بحث', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppTextField.search(),
      ));

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('يستخدم نص تلميح مخصص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppTextField.search(hint: 'ابحث عن منتج'),
      ));

      expect(find.text('ابحث عن منتج'), findsOneWidget);
    });
  });

  group('AppTextField.number', () {
    testWidgets('يقبل الأرقام فقط', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppTextField.number(label: 'الكمية'),
      ));

      expect(find.text('الكمية'), findsOneWidget);
    });
  });

  group('AppTextField.phone', () {
    testWidgets('يعرض أيقونة الهاتف', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppTextField.phone(),
      ));

      expect(find.byIcon(Icons.phone), findsOneWidget);
    });

    testWidgets('يستخدم تسمية افتراضية', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppTextField.phone(),
      ));

      expect(find.text('رقم الهاتف'), findsOneWidget);
    });
  });

  group('AppTextField.price', () {
    testWidgets('يعرض العملة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppTextField.price(),
      ));

      expect(find.text('ر.س'), findsOneWidget);
    });

    testWidgets('يستخدم عملة مخصصة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppTextField.price(currency: '\$'),
      ));

      expect(find.text('\$'), findsOneWidget);
    });
  });

  group('AppSearchField', () {
    testWidgets('يعرض أيقونة البحث', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppSearchField(),
      ));

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('يعرض نص التلميح الافتراضي', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppSearchField(),
      ));

      expect(find.text('بحث...'), findsOneWidget);
    });

    testWidgets('يستخدم نص تلميح مخصص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppSearchField(hint: 'ابحث هنا'),
      ));

      expect(find.text('ابحث هنا'), findsOneWidget);
    });

    testWidgets('يعرض زر المسح عند وجود نص', (tester) async {
      final controller = TextEditingController(text: 'نص');

      await tester.pumpWidget(buildTestWidget(
        AppSearchField(controller: controller),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('يمسح النص عند الضغط على زر المسح', (tester) async {
      final controller = TextEditingController(text: 'نص');
      bool cleared = false;

      await tester.pumpWidget(buildTestWidget(
        AppSearchField(
          controller: controller,
          onClear: () => cleared = true,
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(controller.text, '');
      expect(cleared, true);
    });

    testWidgets('يستدعي onChanged عند التغيير', (tester) async {
      String? value;

      await tester.pumpWidget(buildTestWidget(
        AppSearchField(onChanged: (v) => value = v),
      ));

      await tester.enterText(find.byType(TextField), 'بحث');
      expect(value, 'بحث');
    });

    testWidgets('يدعم fullWidth', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppSearchField(fullWidth: true),
      ));

      expect(find.byType(AppSearchField), findsOneWidget);
    });
  });

  group('AppQuantityField', () {
    testWidgets('يعرض القيمة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppQuantityField(
          value: 5,
          onChanged: (_) {},
        ),
      ));

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('يعرض أزرار + و -', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppQuantityField(
          value: 5,
          onChanged: (_) {},
        ),
      ));

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('يزيد القيمة عند الضغط على +', (tester) async {
      int value = 5;

      await tester.pumpWidget(buildTestWidget(
        AppQuantityField(
          value: value,
          onChanged: (v) => value = v,
        ),
      ));

      await tester.tap(find.byIcon(Icons.add));
      expect(value, 6);
    });

    testWidgets('ينقص القيمة عند الضغط على -', (tester) async {
      int value = 5;

      await tester.pumpWidget(buildTestWidget(
        AppQuantityField(
          value: value,
          onChanged: (v) => value = v,
        ),
      ));

      await tester.tap(find.byIcon(Icons.remove));
      expect(value, 4);
    });

    testWidgets('لا ينقص أقل من الحد الأدنى', (tester) async {
      int value = 0;

      await tester.pumpWidget(buildTestWidget(
        AppQuantityField(
          value: value,
          onChanged: (v) => value = v,
          min: 0,
        ),
      ));

      await tester.tap(find.byIcon(Icons.remove));
      expect(value, 0);
    });

    testWidgets('لا يزيد أعلى من الحد الأقصى', (tester) async {
      int value = 10;

      await tester.pumpWidget(buildTestWidget(
        AppQuantityField(
          value: value,
          onChanged: (v) => value = v,
          max: 10,
        ),
      ));

      await tester.tap(find.byIcon(Icons.add));
      expect(value, 10);
    });

    testWidgets('يستخدم step مخصص', (tester) async {
      int value = 5;

      await tester.pumpWidget(buildTestWidget(
        AppQuantityField(
          value: value,
          onChanged: (v) => value = v,
          step: 5,
        ),
      ));

      await tester.tap(find.byIcon(Icons.add));
      expect(value, 10);
    });

    testWidgets('يعطل الأزرار عندما enabled=false', (tester) async {
      int value = 5;

      await tester.pumpWidget(buildTestWidget(
        AppQuantityField(
          value: value,
          onChanged: (v) => value = v,
          enabled: false,
        ),
      ));

      await tester.tap(find.byIcon(Icons.add));
      expect(value, 5); // لم يتغير
    });

    testWidgets('يدعم حجم مخصص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppQuantityField(
          value: 5,
          onChanged: (_) {},
          size: 50,
        ),
      ));

      expect(find.text('5'), findsOneWidget);
    });
  });
}
