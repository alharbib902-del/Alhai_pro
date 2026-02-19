import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';

/// شاشة تقرير المخزون
class InventoryReportScreen extends ConsumerStatefulWidget {
  const InventoryReportScreen({super.key});

  @override
  ConsumerState<InventoryReportScreen> createState() => _InventoryReportScreenState();
}

class _InventoryReportScreenState extends ConsumerState<InventoryReportScreen> {
  String _selectedCategory = 'all';
  List<ProductsTableData> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return;
    final db = getIt<AppDatabase>();
    final products = await db.productsDao.getAllProducts(storeId);
    if (mounted) {
      setState(() {
        _products = products;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('تقرير المخزون')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final inventory = _products.map((p) => _InventoryItem(
      name: p.name,
      category: p.categoryId ?? 'غير مصنف',
      sku: p.sku ?? p.barcode ?? '',
      stock: p.stockQty,
      minStock: p.minQty,
      cost: p.costPrice ?? 0,
      price: p.price,
      lastUpdated: p.updatedAt ?? p.createdAt,
    )).toList();

    final filtered = _selectedCategory == 'all' ? inventory : inventory.where((i) => i.category == _selectedCategory).toList();
    final outOfStock = inventory.where((i) => i.stock <= 0).length;
    final lowStock = inventory.where((i) => i.stock > 0 && i.stock <= i.minStock).length;
    final totalValue = inventory.fold(0.0, (sum, i) => sum + (i.cost * i.stock));
    final totalItems = inventory.fold(0, (sum, i) => sum + i.stock);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير المخزون'),
        actions: [
          IconButton(icon: const Icon(Icons.file_download), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تصدير التقرير')))),
          IconButton(icon: const Icon(Icons.print), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('طباعة التقرير')))),
        ],
      ),
      body: Column(
        children: [
          // الإحصائيات
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _StatCard(icon: Icons.inventory_2, label: 'إجمالي الأصناف', value: '${inventory.length}', color: Colors.blue),
                const SizedBox(width: 12),
                _StatCard(icon: Icons.shopping_bag, label: 'إجمالي الوحدات', value: '$totalItems', color: Colors.green),
                const SizedBox(width: 12),
                _StatCard(icon: Icons.warning, label: 'منخفض', value: '$lowStock', color: Colors.orange),
                const SizedBox(width: 12),
                _StatCard(icon: Icons.remove_shopping_cart, label: 'نافد', value: '$outOfStock', color: Colors.red),
              ],
            ),
          ),

          // قيمة المخزون
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.green.shade600, Colors.green.shade400]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                const Text('قيمة المخزون الإجمالية', style: TextStyle(color: Colors.white)),
                const Spacer(),
                Text('${totalValue.toStringAsFixed(0)} ر.س', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // التصفية
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _FilterChip(label: 'الكل', selected: _selectedCategory == 'all', onTap: () => setState(() => _selectedCategory = 'all')),
                ...inventory.map((i) => i.category).toSet().map((cat) => _FilterChip(label: cat, selected: _selectedCategory == cat, onTap: () => setState(() => _selectedCategory = cat))),
              ],
            ),
          ),

          // جدول المخزون
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('المنتج')),
                  DataColumn(label: Text('SKU')),
                  DataColumn(label: Text('المخزون'), numeric: true),
                  DataColumn(label: Text('الحد الأدنى'), numeric: true),
                  DataColumn(label: Text('التكلفة'), numeric: true),
                  DataColumn(label: Text('السعر'), numeric: true),
                  DataColumn(label: Text('القيمة'), numeric: true),
                  DataColumn(label: Text('الحالة')),
                ],
                rows: filtered.map((item) {
                  final isLow = item.stock < item.minStock;
                  return DataRow(
                    color: WidgetStateProperty.resolveWith((states) => isLow ? Colors.red.shade50 : null),
                    cells: [
                      DataCell(Text(item.name)),
                      DataCell(Text(item.sku, style: const TextStyle(fontFamily: 'monospace'))),
                      DataCell(Text(item.stock.toString())),
                      DataCell(Text(item.minStock.toString())),
                      DataCell(Text(item.cost.toStringAsFixed(2))),
                      DataCell(Text(item.price.toStringAsFixed(2))),
                      DataCell(Text((item.cost * item.stock).toStringAsFixed(0))),
                      DataCell(isLow ? Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)), child: const Text('منخفض', style: TextStyle(color: Colors.white, fontSize: 10))) : const Icon(Icons.check, color: Colors.green, size: 16)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryItem {
  final String name, category, sku;
  final int stock, minStock;
  final double cost, price;
  final DateTime lastUpdated;
  _InventoryItem({required this.name, required this.category, required this.sku, required this.stock, required this.minStock, required this.cost, required this.price, required this.lastUpdated});
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Column(children: [Icon(icon, color: color, size: 20), Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)), Text(label, style: TextStyle(fontSize: 10, color: color))])));
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsetsDirectional.only(start: 8), child: FilterChip(label: Text(label), selected: selected, onSelected: (_) => onTap()));
}
