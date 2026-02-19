import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Inventory Screen Components', () {
    group('Stat Card Widget', () {
      testWidgets('يعرض العنوان والقيمة', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestStatCard(
                icon: Icons.inventory_2_rounded,
                label: 'إجمالي المنتجات',
                value: '150',
                color: Colors.blue,
              ),
            ),
          ),
        );

        expect(find.text('إجمالي المنتجات'), findsOneWidget);
        expect(find.text('150'), findsOneWidget);
        expect(find.byIcon(Icons.inventory_2_rounded), findsOneWidget);
      });

      testWidgets('يعرض تحذير عند وجود مشكلة', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestStatCard(
                icon: Icons.warning_amber_rounded,
                label: 'مخزون منخفض',
                value: '12',
                color: Colors.orange,
                isAlert: true,
              ),
            ),
          ),
        );

        expect(find.text('مخزون منخفض'), findsOneWidget);
        expect(find.text('12'), findsOneWidget);
        // يجب أن يظهر مؤشر التحذير
        expect(find.byIcon(Icons.priority_high_rounded), findsOneWidget);
      });

      testWidgets('يعرض القيمة بالريال', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestStatCard(
                icon: Icons.attach_money_rounded,
                label: 'قيمة المخزون',
                value: '50000 ر.س',
                color: Colors.green,
              ),
            ),
          ),
        );

        expect(find.text('قيمة المخزون'), findsOneWidget);
        expect(find.text('50000 ر.س'), findsOneWidget);
      });
    });

    group('Inventory Card Widget', () {
      testWidgets('يعرض معلومات المنتج', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestInventoryCard(
                name: 'منتج اختباري',
                barcode: '123456789',
                stockQty: 50,
                isLowStock: false,
                isOutOfStock: false,
                isSelected: false,
                onTap: () {},
                onSelect: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('منتج اختباري'), findsOneWidget);
        expect(find.text('123456789'), findsOneWidget);
        expect(find.text('50'), findsOneWidget);
      });

      testWidgets('يعرض "بدون باركود" عند عدم وجوده', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestInventoryCard(
                name: 'منتج',
                barcode: null,
                stockQty: 25,
                isLowStock: false,
                isOutOfStock: false,
                isSelected: false,
                onTap: () {},
                onSelect: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('بدون باركود'), findsOneWidget);
      });

      testWidgets('يعرض حالة "متوفر" للمخزون الكافي', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestInventoryCard(
                name: 'منتج',
                barcode: '111',
                stockQty: 100,
                isLowStock: false,
                isOutOfStock: false,
                isSelected: false,
                onTap: () {},
                onSelect: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('متوفر'), findsOneWidget);
      });

      testWidgets('يعرض حالة "منخفض" للمخزون القليل', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestInventoryCard(
                name: 'منتج',
                barcode: '222',
                stockQty: 3,
                isLowStock: true,
                isOutOfStock: false,
                isSelected: false,
                onTap: () {},
                onSelect: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('منخفض'), findsOneWidget);
      });

      testWidgets('يعرض حالة "نفذ" للمخزون الصفري', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestInventoryCard(
                name: 'منتج',
                barcode: '333',
                stockQty: 0,
                isLowStock: false,
                isOutOfStock: true,
                isSelected: false,
                onTap: () {},
                onSelect: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('نفذ'), findsOneWidget);
      });

      testWidgets('يستجيب للضغط', (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestInventoryCard(
                name: 'منتج قابل للضغط',
                barcode: '444',
                stockQty: 10,
                isLowStock: false,
                isOutOfStock: false,
                isSelected: false,
                onTap: () => tapped = true,
                onSelect: (_) {},
              ),
            ),
          ),
        );

        await tester.tap(find.text('منتج قابل للضغط'));
        expect(tapped, isTrue);
      });

      testWidgets('يظهر checkbox محدد عند التحديد', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestInventoryCard(
                name: 'منتج محدد',
                barcode: '555',
                stockQty: 20,
                isLowStock: false,
                isOutOfStock: false,
                isSelected: true,
                onTap: () {},
                onSelect: (_) {},
              ),
            ),
          ),
        );

        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, isTrue);
      });
    });

    group('Filter Chip Widget', () {
      testWidgets('يعرض النص', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestFilterChip(
                label: 'الكل',
                isSelected: false,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('الكل'), findsOneWidget);
      });

      testWidgets('يظهر بشكل مختلف عند التحديد', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Row(
                children: [
                  _TestFilterChip(
                    label: 'مخزون منخفض',
                    isSelected: true,
                    onTap: () {},
                  ),
                  _TestFilterChip(
                    label: 'نفذ',
                    isSelected: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        // كلاهما موجودان
        expect(find.text('مخزون منخفض'), findsOneWidget);
        expect(find.text('نفذ'), findsOneWidget);
      });
    });

    group('Filter Option Widget', () {
      testWidgets('يعرض الأيقونة والنص والعدد', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestFilterOption(
                label: 'مخزون منخفض',
                icon: Icons.warning_rounded,
                isSelected: false,
                count: 8,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('مخزون منخفض'), findsOneWidget);
        expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
        expect(find.text('8'), findsOneWidget);
      });

      testWidgets('يظهر علامة التحديد عند الاختيار', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestFilterOption(
                label: 'الكل',
                icon: Icons.inventory_2_rounded,
                isSelected: true,
                count: 100,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      });
    });

    group('Quick Action Widget', () {
      testWidgets('يعرض الأيقونة والنص', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestQuickAction(
                label: 'تصدير تقرير المخزون',
                icon: Icons.download_rounded,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('تصدير تقرير المخزون'), findsOneWidget);
        expect(find.byIcon(Icons.download_rounded), findsOneWidget);
      });

      testWidgets('يستجيب للضغط', (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestQuickAction(
                label: 'طباعة قائمة الطلب',
                icon: Icons.print_rounded,
                onTap: () => tapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('طباعة قائمة الطلب'));
        expect(tapped, isTrue);
      });
    });

    group('Empty State', () {
      testWidgets('يعرض رسالة عدم وجود منتجات', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestEmptyState(filterType: 'all'),
            ),
          ),
        );

        expect(find.text('لا توجد منتجات'), findsOneWidget);
      });

      testWidgets('يعرض رسالة عدم وجود مخزون منخفض', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestEmptyState(filterType: 'low'),
            ),
          ),
        );

        expect(find.text('لا يوجد مخزون منخفض'), findsOneWidget);
      });

      testWidgets('يعرض رسالة عدم وجود منتجات نفذت', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestEmptyState(filterType: 'out'),
            ),
          ),
        );

        expect(find.text('لا يوجد منتجات نفذت'), findsOneWidget);
      });
    });
  });

  group('Inventory Screen Logic', () {
    test('تصفية المنتجات حسب المخزون - الكل', () {
      final products = [
        _TestProduct(id: '1', name: 'P1', stockQty: 50, minQty: 5),
        _TestProduct(id: '2', name: 'P2', stockQty: 3, minQty: 5),
        _TestProduct(id: '3', name: 'P3', stockQty: 0, minQty: 5),
        _TestProduct(id: '4', name: 'P4', stockQty: 100, minQty: 5),
      ];

      // لا تصفية - الكل
      final all = products;
      expect(all.length, 4);
    });

    test('تصفية المنتجات حسب المخزون - متوفر', () {
      final products = [
        _TestProduct(id: '1', name: 'P1', stockQty: 50, minQty: 5),
        _TestProduct(id: '2', name: 'P2', stockQty: 3, minQty: 5),
        _TestProduct(id: '3', name: 'P3', stockQty: 0, minQty: 5),
        _TestProduct(id: '4', name: 'P4', stockQty: 100, minQty: 5),
      ];

      final available = products
          .where((p) => !p.isLowStock && !p.isOutOfStock)
          .toList();

      expect(available.length, 2);
      expect(available.map((p) => p.name), containsAll(['P1', 'P4']));
    });

    test('تصفية المنتجات حسب المخزون - منخفض', () {
      final products = [
        _TestProduct(id: '1', name: 'P1', stockQty: 50, minQty: 5),
        _TestProduct(id: '2', name: 'P2', stockQty: 3, minQty: 5),
        _TestProduct(id: '3', name: 'P3', stockQty: 0, minQty: 5),
        _TestProduct(id: '4', name: 'P4', stockQty: 4, minQty: 5),
      ];

      final low = products
          .where((p) => p.isLowStock && !p.isOutOfStock)
          .toList();

      expect(low.length, 2);
      expect(low.map((p) => p.name), containsAll(['P2', 'P4']));
    });

    test('تصفية المنتجات حسب المخزون - نفذ', () {
      final products = [
        _TestProduct(id: '1', name: 'P1', stockQty: 50, minQty: 5),
        _TestProduct(id: '2', name: 'P2', stockQty: 0, minQty: 5),
        _TestProduct(id: '3', name: 'P3', stockQty: 0, minQty: 5),
      ];

      final out = products.where((p) => p.isOutOfStock).toList();

      expect(out.length, 2);
      expect(out.map((p) => p.name), containsAll(['P2', 'P3']));
    });

    test('البحث بالاسم', () {
      final products = [
        _TestProduct(id: '1', name: 'أرز بسمتي', stockQty: 50, minQty: 5),
        _TestProduct(id: '2', name: 'سكر أبيض', stockQty: 30, minQty: 5),
        _TestProduct(id: '3', name: 'أرز مصري', stockQty: 20, minQty: 5),
      ];

      const query = 'أرز';
      final filtered = products
          .where((p) => p.name.contains(query))
          .toList();

      expect(filtered.length, 2);
      expect(filtered.map((p) => p.name), containsAll(['أرز بسمتي', 'أرز مصري']));
    });

    test('ترتيب المنتجات حسب الاسم', () {
      final products = [
        _TestProduct(id: '1', name: 'زيت', stockQty: 10, minQty: 5),
        _TestProduct(id: '2', name: 'أرز', stockQty: 20, minQty: 5),
        _TestProduct(id: '3', name: 'سكر', stockQty: 15, minQty: 5),
      ];

      products.sort((a, b) => a.name.compareTo(b.name));

      expect(products[0].name, 'أرز');
      expect(products[1].name, 'زيت');
      expect(products[2].name, 'سكر');
    });

    test('ترتيب المنتجات حسب الكمية تصاعدي', () {
      final products = [
        _TestProduct(id: '1', name: 'P1', stockQty: 50, minQty: 5),
        _TestProduct(id: '2', name: 'P2', stockQty: 10, minQty: 5),
        _TestProduct(id: '3', name: 'P3', stockQty: 100, minQty: 5),
      ];

      products.sort((a, b) => a.stockQty.compareTo(b.stockQty));

      expect(products[0].stockQty, 10);
      expect(products[1].stockQty, 50);
      expect(products[2].stockQty, 100);
    });

    test('ترتيب المنتجات حسب الكمية تنازلي', () {
      final products = [
        _TestProduct(id: '1', name: 'P1', stockQty: 50, minQty: 5),
        _TestProduct(id: '2', name: 'P2', stockQty: 10, minQty: 5),
        _TestProduct(id: '3', name: 'P3', stockQty: 100, minQty: 5),
      ];

      products.sort((a, b) => -a.stockQty.compareTo(b.stockQty));

      expect(products[0].stockQty, 100);
      expect(products[1].stockQty, 50);
      expect(products[2].stockQty, 10);
    });

    test('حساب قيمة المخزون', () {
      final products = [
        _TestProductWithPrice(id: '1', stockQty: 10, price: 100),
        _TestProductWithPrice(id: '2', stockQty: 5, price: 200),
        _TestProductWithPrice(id: '3', stockQty: 20, price: 50),
      ];

      final totalValue = products.fold<double>(
        0,
        (sum, p) => sum + (p.stockQty * p.price),
      );

      // 10*100 + 5*200 + 20*50 = 1000 + 1000 + 1000 = 3000
      expect(totalValue, 3000);
    });

    test('حساب عدد المنتجات منخفضة المخزون', () {
      final products = [
        _TestProduct(id: '1', name: 'P1', stockQty: 50, minQty: 5),
        _TestProduct(id: '2', name: 'P2', stockQty: 3, minQty: 5),
        _TestProduct(id: '3', name: 'P3', stockQty: 0, minQty: 5),
        _TestProduct(id: '4', name: 'P4', stockQty: 4, minQty: 5),
      ];

      final lowStockCount = products
          .where((p) => p.isLowStock && !p.isOutOfStock)
          .length;

      expect(lowStockCount, 2);
    });

    test('حساب عدد المنتجات التي نفذت', () {
      final products = [
        _TestProduct(id: '1', name: 'P1', stockQty: 50, minQty: 5),
        _TestProduct(id: '2', name: 'P2', stockQty: 0, minQty: 5),
        _TestProduct(id: '3', name: 'P3', stockQty: 0, minQty: 5),
        _TestProduct(id: '4', name: 'P4', stockQty: 10, minQty: 5),
      ];

      final outOfStockCount = products.where((p) => p.isOutOfStock).length;

      expect(outOfStockCount, 2);
    });
  });

  group('Stock Adjustment Logic', () {
    test('تعديل الكمية بالزيادة', () {
      int currentQty = 50;
      const delta = 10;
      final newQty = currentQty + delta;

      expect(newQty, 60);
    });

    test('تعديل الكمية بالنقص', () {
      int currentQty = 50;
      const delta = -10;
      final newQty = (currentQty + delta).clamp(0, 99999);

      expect(newQty, 40);
    });

    test('الكمية لا تقل عن صفر', () {
      int currentQty = 5;
      const delta = -10;
      final newQty = (currentQty + delta).clamp(0, 99999);

      expect(newQty, 0);
    });

    test('الكمية لا تتجاوز الحد الأقصى', () {
      int currentQty = 99990;
      const delta = 100;
      final newQty = (currentQty + delta).clamp(0, 99999);

      expect(newQty, 99999);
    });

    test('أسباب التعديل المتاحة', () {
      const reasons = ['count', 'receive', 'damage', 'return', 'correction', 'other'];

      expect(reasons.length, 6);
      expect(reasons, contains('count'));
      expect(reasons, contains('receive'));
      expect(reasons, contains('damage'));
    });
  });

  group('Stats Calculations', () {
    test('حساب إجمالي المنتجات', () {
      final products = [
        _TestProduct(id: '1', name: 'P1', stockQty: 50, minQty: 5),
        _TestProduct(id: '2', name: 'P2', stockQty: 30, minQty: 5),
        _TestProduct(id: '3', name: 'P3', stockQty: 0, minQty: 5),
      ];

      expect(products.length, 3);
    });

    test('تنسيق قيمة المخزون بالريال', () {
      const totalValue = 50000.0;
      final formatted = '${totalValue.toStringAsFixed(0)} ر.س';

      expect(formatted, '50000 ر.س');
    });

    test('تنسيق قيمة المخزون الكبيرة', () {
      const totalValue = 1234567.89;
      final formatted = '${totalValue.toStringAsFixed(0)} ر.س';

      expect(formatted, '1234568 ر.س');
    });
  });
}

// ============================================================================
// Test Helper Widgets
// ============================================================================

class _TestStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isAlert;

  const _TestStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAlert ? color : Colors.grey,
          width: isAlert ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          if (isAlert)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.priority_high_rounded, size: 12, color: Colors.white),
            ),
        ],
      ),
    );
  }
}

class _TestInventoryCard extends StatelessWidget {
  final String name;
  final String? barcode;
  final int stockQty;
  final bool isLowStock;
  final bool isOutOfStock;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<bool> onSelect;

  const _TestInventoryCard({
    required this.name,
    required this.barcode,
    required this.stockQty,
    required this.isLowStock,
    required this.isOutOfStock,
    required this.isSelected,
    required this.onTap,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final stockColor = isOutOfStock
        ? Colors.red
        : isLowStock
            ? Colors.orange
            : Colors.green;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (value) => onSelect(value ?? false),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: stockColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isOutOfStock
                      ? Icons.error_rounded
                      : isLowStock
                          ? Icons.warning_rounded
                          : Icons.check_circle_rounded,
                  color: stockColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.qr_code_rounded, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          barcode ?? 'بدون باركود',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$stockQty',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: stockColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: stockColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isOutOfStock ? 'نفذ' : isLowStock ? 'منخفض' : 'متوفر',
                      style: TextStyle(fontSize: 11, color: stockColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TestFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.blue.withValues(alpha: 0.15),
    );
  }
}

class _TestFilterOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  const _TestFilterOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.blue : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.blue : Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.black,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.blue : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(Icons.check_rounded, size: 18, color: Colors.blue),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestQuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _TestQuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(child: Text(label)),
              const Icon(Icons.chevron_left_rounded, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestEmptyState extends StatelessWidget {
  final String filterType;

  const _TestEmptyState({required this.filterType});

  @override
  Widget build(BuildContext context) {
    String message;
    switch (filterType) {
      case 'low':
        message = 'لا يوجد مخزون منخفض';
        break;
      case 'out':
        message = 'لا يوجد منتجات نفذت';
        break;
      default:
        message = 'لا توجد منتجات';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inventory_2_rounded, size: 64, color: Colors.blue),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// Test Models
class _TestProduct {
  final String id;
  final String name;
  final int stockQty;
  final int minQty;

  _TestProduct({
    required this.id,
    required this.name,
    required this.stockQty,
    required this.minQty,
  });

  bool get isOutOfStock => stockQty <= 0;
  bool get isLowStock => stockQty > 0 && stockQty <= minQty;
}

class _TestProductWithPrice {
  final String id;
  final int stockQty;
  final double price;

  _TestProductWithPrice({
    required this.id,
    required this.stockQty,
    required this.price,
  });
}











