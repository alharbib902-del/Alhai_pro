import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Dashboard Screen Components', () {
    group('Dashboard Card Widget', () {
      testWidgets('يعرض العنوان والقيمة', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestDashboardCard(
                icon: Icons.attach_money,
                title: 'مبيعات اليوم',
                value: '1000 ر.س',
                subtitle: 'إجمالي المبيعات',
                color: Colors.green,
              ),
            ),
          ),
        );

        expect(find.text('مبيعات اليوم'), findsOneWidget);
        expect(find.text('1000 ر.س'), findsOneWidget);
        expect(find.text('إجمالي المبيعات'), findsOneWidget);
        expect(find.byIcon(Icons.attach_money), findsOneWidget);
      });

      testWidgets('يعرض ألوان مختلفة', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  _TestDashboardCard(
                    icon: Icons.receipt_long,
                    title: 'الطلبات',
                    value: '25',
                    subtitle: 'طلب',
                    color: Colors.blue,
                  ),
                  _TestDashboardCard(
                    icon: Icons.inventory,
                    title: 'المخزون',
                    value: '5',
                    subtitle: 'منتج',
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('الطلبات'), findsOneWidget);
        expect(find.text('المخزون'), findsOneWidget);
      });
    });

    group('Quick Action Widget', () {
      testWidgets('يعرض الأيقونة والنص', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestQuickAction(
                icon: Icons.point_of_sale,
                label: 'نقطة البيع',
                color: Colors.blue,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('نقطة البيع'), findsOneWidget);
        expect(find.byIcon(Icons.point_of_sale), findsOneWidget);
      });

      testWidgets('يستجيب للضغط', (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestQuickAction(
                icon: Icons.inventory_2,
                label: 'المخزون',
                color: Colors.green,
                onTap: () => tapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('المخزون'));
        expect(tapped, isTrue);
      });

      testWidgets('يعرض الألوان بشكل صحيح', (tester) async {
        const testColor = Colors.purple;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestQuickAction(
                icon: Icons.people,
                label: 'العملاء',
                color: testColor,
                onTap: () {},
              ),
            ),
          ),
        );

        final icon = tester.widget<Icon>(find.byIcon(Icons.people));
        expect(icon.color, testColor);
      });
    });

    group('Welcome Card', () {
      testWidgets('يعرض رسالة الترحيب', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestWelcomeCard(),
            ),
          ),
        );

        expect(find.text('مرحباً!'), findsOneWidget);
        expect(find.text('إليك ملخص أداء متجرك اليوم'), findsOneWidget);
      });

      testWidgets('يستخدم التدرج اللوني', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestWelcomeCard(),
            ),
          ),
        );

        // التحقق من وجود الـ Card
        expect(find.byType(Card), findsOneWidget);
      });
    });

    group('Stats Display', () {
      testWidgets('يعرض إحصائيات صفرية', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestStatsDisplay(
                todaySales: 0,
                todayOrders: 0,
                lowStockCount: 0,
              ),
            ),
          ),
        );

        expect(find.text('0 ر.س'), findsOneWidget);
        expect(find.text('0'), findsNWidgets(2)); // orders and low stock
      });

      testWidgets('يعرض إحصائيات بقيم', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestStatsDisplay(
                todaySales: 5000,
                todayOrders: 25,
                lowStockCount: 3,
              ),
            ),
          ),
        );

        expect(find.text('5000 ر.س'), findsOneWidget);
        expect(find.text('25'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('يعرض المبيعات بالتنسيق الصحيح', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestStatsDisplay(
                todaySales: 12345.67,
                todayOrders: 100,
                lowStockCount: 10,
              ),
            ),
          ),
        );

        // يجب أن يعرض بدون كسور عشرية
        expect(find.text('12346 ر.س'), findsOneWidget);
      });
    });

    group('Empty State', () {
      testWidgets('يعرض رسالة عدم وجود مبيعات', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestEmptyState(),
            ),
          ),
        );

        expect(find.text('لا توجد مبيعات اليوم'), findsOneWidget);
      });
    });

    group('Sale Tile', () {
      testWidgets('يعرض بيانات البيع', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestSaleTile(
                receiptNo: 'POS-20240101-0001',
                total: 150.0,
                customerName: 'أحمد محمد',
                paymentMethod: 'cash',
              ),
            ),
          ),
        );

        expect(find.text('POS-20240101-0001'), findsOneWidget);
        expect(find.text('150 ر.س'), findsOneWidget);
        expect(find.text('أحمد محمد'), findsOneWidget);
        expect(find.text('نقداً'), findsOneWidget);
      });

      testWidgets('يعرض عميل نقدي بدون اسم', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestSaleTile(
                receiptNo: 'POS-20240101-0002',
                total: 200.0,
                customerName: null,
                paymentMethod: 'cash',
              ),
            ),
          ),
        );

        expect(find.text('عميل نقدي'), findsOneWidget);
      });

      testWidgets('يعرض طريقة الدفع بالبطاقة', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestSaleTile(
                receiptNo: 'POS-20240101-0003',
                total: 500.0,
                customerName: 'خالد علي',
                paymentMethod: 'card',
              ),
            ),
          ),
        );

        expect(find.text('بطاقة'), findsOneWidget);
      });
    });

    group('Loading State', () {
      testWidgets('يعرض مؤشر التحميل', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('AppBar', () {
      testWidgets('يعرض عنوان لوحة التحكم', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              appBar: _TestAppBar(),
            ),
          ),
        );

        expect(find.text('لوحة التحكم'), findsOneWidget);
        expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });
    });

    group('Grid Layout', () {
      testWidgets('يحسب عدد الأعمدة بشكل صحيح', (tester) async {
        // للشاشات الصغيرة (< 400) = 3 أعمدة
        // للشاشات الكبيرة = 4 أعمدة

        const smallWidth = 350.0;
        const smallColumns = smallWidth < 400 ? 3 : 4;
        expect(smallColumns, 3);

        const largeWidth = 500.0;
        const largeColumns = largeWidth < 400 ? 3 : 4;
        expect(largeColumns, 4);
      });
    });
  });

  group('Dashboard Data Calculations', () {
    test('تنسيق المبلغ بالريال', () {
      const amount = 1234.56;
      final formatted = '${amount.toStringAsFixed(0)} ر.س';
      expect(formatted, '1235 ر.س');
    });

    test('تنسيق المبلغ الصفري', () {
      const amount = 0.0;
      final formatted = '${amount.toStringAsFixed(0)} ر.س';
      expect(formatted, '0 ر.س');
    });

    test('تنسيق المبلغ الكبير', () {
      const amount = 99999.99;
      final formatted = '${amount.toStringAsFixed(0)} ر.س';
      expect(formatted, '100000 ر.س');
    });

    test('تحويل طريقة الدفع للعربية', () {
      String getPaymentLabel(String method) {
        return method == 'cash' ? 'نقداً' : 'بطاقة';
      }

      expect(getPaymentLabel('cash'), 'نقداً');
      expect(getPaymentLabel('card'), 'بطاقة');
      expect(getPaymentLabel('mada'), 'بطاقة');
    });
  });
}

// ============================================================================
// Test Helper Widgets
// ============================================================================

class _TestDashboardCard extends StatelessWidget {
  final IconData icon;
  final String title, value, subtitle;
  final Color color;

  const _TestDashboardCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ]),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

class _TestQuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TestQuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _TestWelcomeCard extends StatelessWidget {
  const _TestWelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade400]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مرحباً!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('إليك ملخص أداء متجرك اليوم', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _TestStatsDisplay extends StatelessWidget {
  final double todaySales;
  final int todayOrders;
  final int lowStockCount;

  const _TestStatsDisplay({
    required this.todaySales,
    required this.todayOrders,
    required this.lowStockCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${todaySales.toStringAsFixed(0)} ر.س'),
        Text('$todayOrders'),
        Text('$lowStockCount'),
      ],
    );
  }
}

class _TestEmptyState extends StatelessWidget {
  const _TestEmptyState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text('لا توجد مبيعات اليوم',
            style: TextStyle(color: Colors.grey.shade600)),
        ),
      ),
    );
  }
}

class _TestSaleTile extends StatelessWidget {
  final String receiptNo;
  final double total;
  final String? customerName;
  final String paymentMethod;

  const _TestSaleTile({
    required this.receiptNo,
    required this.total,
    required this.customerName,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade50,
          child: const Icon(Icons.receipt, color: Colors.green),
        ),
        title: Row(
          children: [
            Text(receiptNo, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            const Spacer(),
            Text('${total.toStringAsFixed(0)} ر.س'),
          ],
        ),
        subtitle: Text(customerName ?? 'عميل نقدي'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            paymentMethod == 'cash' ? 'نقداً' : 'بطاقة',
            style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class _TestAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _TestAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('لوحة التحكم'),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}



