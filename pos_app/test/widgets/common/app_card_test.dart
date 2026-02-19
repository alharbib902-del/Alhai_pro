import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/widgets/common/app_card.dart';

// ===========================================
// App Card Tests
// ===========================================

void main() {
  Widget buildTestWidget(Widget child, {double? width, double? height}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: width ?? 300,
              height: height,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  group('AppCard - Basic Constructor', () {
    testWidgets('يعرض المحتوى', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCard(child: Text('محتوى البطاقة')),
      ));

      expect(find.text('محتوى البطاقة'), findsOneWidget);
    });

    testWidgets('يستدعي onTap عند الضغط', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(buildTestWidget(
        AppCard(
          onTap: () => tapped = true,
          child: const Text('اضغط'),
        ),
      ));

      await tester.tap(find.text('اضغط'));
      expect(tapped, true);
    });

    testWidgets('يستدعي onLongPress عند الضغط المطول', (tester) async {
      bool longPressed = false;

      await tester.pumpWidget(buildTestWidget(
        AppCard(
          onLongPress: () => longPressed = true,
          child: const Text('اضغط مطولاً'),
        ),
      ));

      await tester.longPress(find.text('اضغط مطولاً'));
      expect(longPressed, true);
    });

    testWidgets('يعرض cornerWidget إذا كان موجوداً', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCard(
          cornerWidget: Icon(Icons.check_circle),
          child: Text('بطاقة'),
        ),
      ));

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('يدعم isSelected', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCard(
          isSelected: true,
          child: Text('محدد'),
        ),
      ));

      expect(find.text('محدد'), findsOneWidget);
    });

    testWidgets('يدعم padding مخصص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCard(
          padding: EdgeInsets.all(20),
          child: Text('محتوى'),
        ),
      ));

      expect(find.text('محتوى'), findsOneWidget);
    });

    testWidgets('يدعم margin مخصص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCard(
          margin: EdgeInsets.all(16),
          child: Text('محتوى'),
        ),
      ));

      expect(find.text('محتوى'), findsOneWidget);
    });

    testWidgets('يدعم backgroundColor مخصص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCard(
          backgroundColor: Colors.blue,
          child: Text('محتوى'),
        ),
      ));

      expect(find.text('محتوى'), findsOneWidget);
    });

    testWidgets('يدعم borderColor مخصص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCard(
          borderColor: Colors.red,
          child: Text('محتوى'),
        ),
      ));

      expect(find.text('محتوى'), findsOneWidget);
    });

    testWidgets('يدعم borderRadius مخصص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCard(
          borderRadius: 20,
          child: Text('محتوى'),
        ),
      ));

      expect(find.text('محتوى'), findsOneWidget);
    });

    testWidgets('يدعم elevation', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCard(
          elevation: 4,
          child: Text('محتوى'),
        ),
      ));

      expect(find.text('محتوى'), findsOneWidget);
    });
  });

  group('StatCard', () {
    testWidgets('يعرض العنوان والقيمة والأيقونة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StatCard(
          title: 'المبيعات',
          value: '1,500',
          icon: Icons.shopping_cart,
        ),
      ));

      expect(find.text('المبيعات'), findsOneWidget);
      expect(find.text('1,500'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });

    testWidgets('يعرض التغيير الإيجابي', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StatCard(
          title: 'المبيعات',
          value: '1,500',
          icon: Icons.shopping_cart,
          change: 15.5,
        ),
      ));

      expect(find.text('+15.5%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('يعرض التغيير السلبي', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StatCard(
          title: 'المبيعات',
          value: '1,500',
          icon: Icons.shopping_cart,
          change: -10.2,
        ),
      ));

      expect(find.text('-10.2%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
    });

    testWidgets('يعرض changeLabel إذا كان موجوداً', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StatCard(
          title: 'المبيعات',
          value: '1,500',
          icon: Icons.shopping_cart,
          change: 15.5,
          changeLabel: 'سابق',
        ),
        width: 400,
      ));

      expect(find.text('سابق'), findsOneWidget);
    });

    testWidgets('يستدعي onTap عند الضغط', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(buildTestWidget(
        StatCard(
          title: 'المبيعات',
          value: '1,500',
          icon: Icons.shopping_cart,
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.text('المبيعات'));
      expect(tapped, true);
    });

    testWidgets('يدعم iconColor مخصص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StatCard(
          title: 'المبيعات',
          value: '1,500',
          icon: Icons.shopping_cart,
          iconColor: Colors.green,
        ),
      ));

      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });
  });

  group('ProductCard', () {
    testWidgets('يعرض الاسم والسعر', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ProductCard(
          name: 'حليب طازج',
          price: 5.50,
        ),
      ));

      expect(find.text('حليب طازج'), findsOneWidget);
      expect(find.text('5.50 ر.س'), findsOneWidget);
    });

    testWidgets('يعرض السعر القديم إذا كان موجوداً', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ProductCard(
          name: 'حليب طازج',
          price: 5.50,
          oldPrice: 7.00,
        ),
      ));

      expect(find.text('7.00'), findsOneWidget);
    });

    testWidgets('يعرض حالة المخزون - نفذ', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ProductCard(
          name: 'حليب طازج',
          price: 5.50,
          quantity: 0,
        ),
      ));

      expect(find.text('نفذ'), findsOneWidget);
    });

    testWidgets('يعرض حالة المخزون - قليل', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ProductCard(
          name: 'حليب طازج',
          price: 5.50,
          quantity: 3,
        ),
      ));

      expect(find.text('كمية قليلة (3)'), findsOneWidget);
    });

    testWidgets('يعرض حالة المخزون - متوفر', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ProductCard(
          name: 'حليب طازج',
          price: 5.50,
          quantity: 10,
        ),
      ));

      expect(find.text('متوفر (10)'), findsOneWidget);
    });

    testWidgets('يعرض زر الإضافة للسلة', (tester) async {
      bool added = false;

      await tester.pumpWidget(buildTestWidget(
        ProductCard(
          name: 'حليب طازج',
          price: 5.50,
          quantity: 10,
          onAddToCart: () => added = true,
        ),
      ));

      expect(find.text('أضف'), findsOneWidget);

      await tester.tap(find.text('أضف'));
      expect(added, true);
    });

    testWidgets('يعطل زر الإضافة عندما المخزون 0', (tester) async {
      bool added = false;

      await tester.pumpWidget(buildTestWidget(
        ProductCard(
          name: 'حليب طازج',
          price: 5.50,
          quantity: 0,
          onAddToCart: () => added = true,
        ),
      ));

      await tester.tap(find.text('أضف'));
      expect(added, false);
    });

    testWidgets('يستدعي onTap عند الضغط', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(buildTestWidget(
        ProductCard(
          name: 'حليب طازج',
          price: 5.50,
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.text('حليب طازج'));
      expect(tapped, true);
    });

    testWidgets('يدعم isSelected', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ProductCard(
          name: 'حليب طازج',
          price: 5.50,
          isSelected: true,
        ),
      ));

      expect(find.text('حليب طازج'), findsOneWidget);
    });

    testWidgets('يدعم عملة مخصصة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ProductCard(
          name: 'حليب طازج',
          price: 5.50,
          currency: '\$',
        ),
      ));

      expect(find.text('5.50 \$'), findsOneWidget);
    });
  });

  group('CustomerCard', () {
    testWidgets('يعرض اسم العميل', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const CustomerCard(name: 'أحمد محمد'),
      ));

      expect(find.text('أحمد محمد'), findsOneWidget);
      expect(find.text('أم'), findsOneWidget); // الأحرف الأولى
    });

    testWidgets('يعرض رقم الهاتف إذا كان موجوداً', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const CustomerCard(
          name: 'أحمد محمد',
          phone: '0501234567',
        ),
      ));

      expect(find.text('0501234567'), findsOneWidget);
    });

    testWidgets('يعرض الرصيد الإيجابي (عليه)', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const CustomerCard(
          name: 'أحمد محمد',
          balance: 500,
        ),
      ));

      expect(find.text('عليه'), findsOneWidget);
      expect(find.text('500.00 ر.س'), findsOneWidget);
    });

    testWidgets('يعرض الرصيد السلبي (له)', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const CustomerCard(
          name: 'أحمد محمد',
          balance: -200,
        ),
      ));

      expect(find.text('له'), findsOneWidget);
      expect(find.text('200.00 ر.س'), findsOneWidget);
    });

    testWidgets('يعرض متوازن عندما الرصيد 0', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const CustomerCard(
          name: 'أحمد محمد',
          balance: 0,
        ),
      ));

      expect(find.text('متوازن'), findsOneWidget);
    });

    testWidgets('يستدعي onTap عند الضغط', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(buildTestWidget(
        CustomerCard(
          name: 'أحمد محمد',
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.text('أحمد محمد'));
      expect(tapped, true);
    });

    testWidgets('يدعم isSelected', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const CustomerCard(
          name: 'أحمد محمد',
          isSelected: true,
        ),
      ));

      expect(find.text('أحمد محمد'), findsOneWidget);
    });

    testWidgets('يدعم initials مخصصة', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const CustomerCard(
          name: 'أحمد محمد',
          initials: 'XX',
        ),
      ));

      expect(find.text('XX'), findsOneWidget);
    });

    testWidgets('يحسب الأحرف الأولى من اسم واحد', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const CustomerCard(name: 'أحمد'),
      ));

      expect(find.text('أ'), findsOneWidget);
    });
  });
}
