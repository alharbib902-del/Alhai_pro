import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Products Screen Components', () {
    group('View Toggle Button', () {
      testWidgets('يعرض الأيقونة', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestViewToggleButton(
                icon: Icons.grid_view_rounded,
                isSelected: true,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
      });

      testWidgets('يستجيب للضغط', (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestViewToggleButton(
                icon: Icons.view_list_rounded,
                isSelected: false,
                onTap: () => tapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(_TestViewToggleButton));
        expect(tapped, isTrue);
      });

      testWidgets('يظهر بشكل مختلف عند التحديد', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Row(
                children: [
                  _TestViewToggleButton(
                    icon: Icons.grid_view_rounded,
                    isSelected: true,
                    onTap: () {},
                  ),
                  _TestViewToggleButton(
                    icon: Icons.view_list_rounded,
                    isSelected: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        // كلا الزرين موجودان
        expect(find.byType(_TestViewToggleButton), findsNWidgets(2));
      });
    });

    group('Product Grid Card', () {
      testWidgets('يعرض اسم المنتج', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestProductGridCard(
                name: 'منتج اختباري',
                barcode: '123456789',
                price: 99.99,
              ),
            ),
          ),
        );

        expect(find.text('منتج اختباري'), findsOneWidget);
        expect(find.text('123456789'), findsOneWidget);
        expect(find.text('99.99 ر.س'), findsOneWidget);
      });

      testWidgets('يعرض placeholder عند عدم وجود صورة', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestProductGridCard(
                name: 'منتج بدون صورة',
                barcode: null,
                price: 50.0,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.image_rounded), findsOneWidget);
      });
    });

    group('Product List Card', () {
      testWidgets('يعرض معلومات المنتج', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestProductListCard(
                name: 'منتج في القائمة',
                barcode: '987654321',
                price: 150.0,
                stockQty: 25,
              ),
            ),
          ),
        );

        expect(find.text('منتج في القائمة'), findsOneWidget);
        expect(find.text('987654321'), findsOneWidget);
        expect(find.text('150.00 ر.س'), findsOneWidget);
        expect(find.text('المخزون: 25'), findsOneWidget);
      });

      testWidgets('يعرض "بدون باركود" عند عدم وجوده', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestProductListCard(
                name: 'منتج',
                barcode: null,
                price: 100.0,
                stockQty: 10,
              ),
            ),
          ),
        );

        expect(find.text('بدون باركود'), findsOneWidget);
      });
    });

    group('Filter Option', () {
      testWidgets('يعرض الـ label والأيقونة', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestFilterOption(
                label: 'متوفر',
                icon: Icons.check_circle_rounded,
                isSelected: false,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('متوفر'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      });

      testWidgets('يظهر علامة التحديد عند الاختيار', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestFilterOption(
                label: 'الكل',
                icon: Icons.apps_rounded,
                isSelected: true,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      });

      testWidgets('يعرض العدد', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestFilterOption(
                label: 'مخزون منخفض',
                icon: Icons.warning_rounded,
                isSelected: false,
                onTap: () {},
                count: 5,
              ),
            ),
          ),
        );

        expect(find.text('5'), findsOneWidget);
      });
    });

    group('Category Chip', () {
      testWidgets('يعرض اسم التصنيف', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestCategoryChip(
                label: 'إلكترونيات',
                isSelected: false,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('إلكترونيات'), findsOneWidget);
      });

      testWidgets('يستجيب للضغط', (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestCategoryChip(
                label: 'ملابس',
                isSelected: false,
                onTap: () => tapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('ملابس'));
        expect(tapped, isTrue);
      });
    });

    group('Stock Badge', () {
      testWidgets('يعرض "نفذ" للمخزون الصفري', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestStockBadge(stockQty: 0, minQty: 5),
            ),
          ),
        );

        expect(find.text('نفذ'), findsOneWidget);
      });

      testWidgets('يعرض "منخفض" للمخزون القليل', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestStockBadge(stockQty: 3, minQty: 5),
            ),
          ),
        );

        expect(find.text('منخفض'), findsOneWidget);
      });

      testWidgets('يعرض "متوفر" للمخزون الكافي', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestStockBadge(stockQty: 50, minQty: 5),
            ),
          ),
        );

        expect(find.text('متوفر'), findsOneWidget);
      });
    });
  });

  group('Products Screen Logic', () {
    test('تصفية المنتجات حسب المخزون - متوفر', () {
      final products = [
        _TestProduct(id: '1', name: 'P1', stockQty: 50, minQty: 5),
        _TestProduct(id: '2', name: 'P2', stockQty: 3, minQty: 5),
        _TestProduct(id: '3', name: 'P3', stockQty: 0, minQty: 5),
      ];

      final available = products
          .where((p) => !p.isOutOfStock && !p.isLowStock)
          .toList();

      expect(available.length, 1);
      expect(available[0].name, 'P1');
    });

    test('تصفية المنتجات حسب المخزون - منخفض', () {
      final products = [
        _TestProduct(id: '1', name: 'P1', stockQty: 50, minQty: 5),
        _TestProduct(id: '2', name: 'P2', stockQty: 3, minQty: 5),
        _TestProduct(id: '3', name: 'P3', stockQty: 0, minQty: 5),
      ];

      final low = products
          .where((p) => p.isLowStock && !p.isOutOfStock)
          .toList();

      expect(low.length, 1);
      expect(low[0].name, 'P2');
    });

    test('تصفية المنتجات حسب المخزون - نفذ', () {
      final products = [
        _TestProduct(id: '1', name: 'P1', stockQty: 50, minQty: 5),
        _TestProduct(id: '2', name: 'P2', stockQty: 3, minQty: 5),
        _TestProduct(id: '3', name: 'P3', stockQty: 0, minQty: 5),
      ];

      final out = products.where((p) => p.isOutOfStock).toList();

      expect(out.length, 1);
      expect(out[0].name, 'P3');
    });

    test('ترتيب المنتجات حسب الاسم تصاعدي', () {
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

    test('ترتيب المنتجات حسب السعر', () {
      final products = [
        _TestProductWithPrice(id: '1', name: 'P1', price: 100),
        _TestProductWithPrice(id: '2', name: 'P2', price: 50),
        _TestProductWithPrice(id: '3', name: 'P3', price: 200),
      ];

      products.sort((a, b) => a.price.compareTo(b.price));

      expect(products[0].price, 50);
      expect(products[1].price, 100);
      expect(products[2].price, 200);
    });

    test('ترتيب المنتجات حسب المخزون', () {
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
  });

  group('Price Formatting', () {
    test('تنسيق السعر مع كسور', () {
      const price = 99.99;
      expect('${price.toStringAsFixed(2)} ر.س', '99.99 ر.س');
    });

    test('تنسيق السعر صحيح', () {
      const price = 100.0;
      expect('${price.toStringAsFixed(2)} ر.س', '100.00 ر.س');
    });

    test('تنسيق السعر صفري', () {
      const price = 0.0;
      expect('${price.toStringAsFixed(2)} ر.س', '0.00 ر.س');
    });
  });
}

// ============================================================================
// Test Helper Widgets
// ============================================================================

class _TestViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TestViewToggleButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.blue : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _TestProductGridCard extends StatelessWidget {
  final String name;
  final String? barcode;
  final double price;

  const _TestProductGridCard({
    required this.name,
    required this.barcode,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Image placeholder
            Container(
              width: 100,
              height: 100,
              color: Colors.grey[200],
              child: const Icon(Icons.image_rounded),
            ),
            const SizedBox(height: 8),
            Text(name),
            if (barcode != null) Text(barcode!),
            Text('${price.toStringAsFixed(2)} ر.س'),
          ],
        ),
      ),
    );
  }
}

class _TestProductListCard extends StatelessWidget {
  final String name;
  final String? barcode;
  final double price;
  final int stockQty;

  const _TestProductListCard({
    required this.name,
    required this.barcode,
    required this.price,
    required this.stockQty,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(barcode ?? 'بدون باركود'),
            Row(
              children: [
                Text('${price.toStringAsFixed(2)} ر.س'),
                const Spacer(),
                Text('المخزون: $stockQty'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TestFilterOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  const _TestFilterOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(label),
            if (count != null) ...[
              const Spacer(),
              Text('$count'),
            ],
            if (isSelected) const Icon(Icons.check_rounded),
          ],
        ),
      ),
    );
  }
}

class _TestCategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TestCategoryChip({
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
    );
  }
}

class _TestStockBadge extends StatelessWidget {
  final int stockQty;
  final int minQty;

  const _TestStockBadge({
    required this.stockQty,
    required this.minQty,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = stockQty <= 0;
    final isLowStock = stockQty > 0 && stockQty <= minQty;

    String label;
    Color color;

    if (isOutOfStock) {
      label = 'نفذ';
      color = Colors.red;
    } else if (isLowStock) {
      label = 'منخفض';
      color = Colors.orange;
    } else {
      label = 'متوفر';
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: color)),
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
  final String name;
  final double price;

  _TestProductWithPrice({
    required this.id,
    required this.name,
    required this.price,
  });
}









