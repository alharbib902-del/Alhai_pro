import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

/// شاشة تقرير المخزون
class InventoryReportScreen extends ConsumerStatefulWidget {
  const InventoryReportScreen({super.key});

  @override
  ConsumerState<InventoryReportScreen> createState() =>
      _InventoryReportScreenState();
}

class _InventoryReportScreenState extends ConsumerState<InventoryReportScreen> {
  String _selectedCategory = 'all';
  List<ProductsTableData> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final db = GetIt.I<AppDatabase>();
      final products = await db.productsDao.getAllProducts(storeId);
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.inventoryReport)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.inventoryReport)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: AlhaiSpacing.md),
                Text(
                  '\u062D\u062F\u062B \u062E\u0637\u0623 \u0641\u064A \u062A\u062D\u0645\u064A\u0644 \u062A\u0642\u0631\u064A\u0631 \u0627\u0644\u0645\u062E\u0632\u0648\u0646',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AlhaiSpacing.md),
                FilledButton.icon(
                  onPressed: _loadProducts,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.inventoryReport)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 80,
                  color: Theme.of(context).dividerColor,
                ),
                const SizedBox(height: AlhaiSpacing.md),
                Text(
                  '\u0644\u0627 \u062A\u0648\u062C\u062F \u0645\u0646\u062A\u062C\u0627\u062A \u0641\u064A \u0627\u0644\u0645\u062E\u0632\u0648\u0646',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xs),
                Text(
                  '\u0623\u0636\u0641 \u0645\u0646\u062A\u062C\u0627\u062A \u0644\u0639\u0631\u0636 \u062A\u0642\u0631\u064A\u0631 \u0627\u0644\u0645\u062E\u0632\u0648\u0646',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final inventory = _products
        .map(
          (p) => _InventoryItem(
            name: p.name,
            category: p.categoryId ?? l10n.categories,
            sku: p.sku ?? p.barcode ?? '',
            stock: p.stockQty,
            minStock: p.minQty,
            cost: p.costPrice ?? 0,
            price: p.price,
            lastUpdated: p.updatedAt ?? p.createdAt,
          ),
        )
        .toList();

    final filtered = _selectedCategory == 'all'
        ? inventory
        : inventory.where((i) => i.category == _selectedCategory).toList();
    final outOfStock = inventory.where((i) => i.stock <= 0).length;
    final lowStock = inventory
        .where((i) => i.stock > 0 && i.stock <= i.minStock)
        .length;
    final totalValue = inventory.fold(
      0.0,
      (sum, i) => sum + (i.cost * i.stock),
    );
    final totalItems = inventory.fold(0, (sum, i) => sum + i.stock.toInt());

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inventoryReport),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.exportAction))),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.printAction))),
          ),
        ],
      ),
      body: ResponsiveBuilder(
        builder: (context, deviceType, width) {
          return Column(
            children: [
              // الإحصائيات
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                child: Row(
                  children: [
                    _StatCard(
                      icon: Icons.inventory_2,
                      label: l10n.products,
                      value: '${inventory.length}',
                      color: AppColors.info,
                    ),
                    const SizedBox(width: AlhaiSpacing.sm),
                    _StatCard(
                      icon: Icons.shopping_bag,
                      label: l10n.inventory,
                      value: '$totalItems',
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AlhaiSpacing.sm),
                    _StatCard(
                      icon: Icons.warning,
                      label: l10n.lowStock,
                      value: '$lowStock',
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AlhaiSpacing.sm),
                    _StatCard(
                      icon: Icons.remove_shopping_cart,
                      label: l10n.outOfStock,
                      value: '$outOfStock',
                      color: AppColors.error,
                    ),
                  ],
                ),
              ),

              // قيمة المخزون
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF16A34A), Color(0xFF4ADE80)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: Theme.of(context).colorScheme.surface,
                      size: 32,
                    ),
                    const SizedBox(width: AlhaiSpacing.sm),
                    Text(
                      l10n.inventoryReport,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${totalValue.toStringAsFixed(0)} ${l10n.sar}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.surface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // التصفية
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                child: Row(
                  children: [
                    _FilterChip(
                      label: l10n.all,
                      selected: _selectedCategory == 'all',
                      onTap: () => setState(() => _selectedCategory = 'all'),
                    ),
                    ...inventory
                        .map((i) => i.category)
                        .toSet()
                        .map(
                          (cat) => _FilterChip(
                            label: cat,
                            selected: _selectedCategory == cat,
                            onTap: () =>
                                setState(() => _selectedCategory = cat),
                          ),
                        ),
                  ],
                ),
              ),

              // جدول المخزون
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16,
                    columns: [
                      DataColumn(label: Text(l10n.products)),
                      const DataColumn(label: Text('SKU')),
                      DataColumn(label: Text(l10n.inventory), numeric: true),
                      DataColumn(label: Text(l10n.lowStock), numeric: true),
                      DataColumn(label: Text(l10n.costs), numeric: true),
                      DataColumn(label: Text(l10n.price), numeric: true),
                      DataColumn(label: Text(l10n.totalSales), numeric: true),
                      DataColumn(label: Text(l10n.status)),
                    ],
                    rows: filtered.map((item) {
                      final isLow = item.stock < item.minStock;
                      return DataRow(
                        color: WidgetStateProperty.resolveWith(
                          (states) => isLow
                              ? AppColors.error.withValues(alpha: 0.05)
                              : null,
                        ),
                        cells: [
                          DataCell(Text(item.name)),
                          DataCell(
                            Text(
                              item.sku,
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                          DataCell(Text(item.stock.toString())),
                          DataCell(Text(item.minStock.toString())),
                          DataCell(Text(item.cost.toStringAsFixed(2))),
                          DataCell(Text(item.price.toStringAsFixed(2))),
                          DataCell(
                            Text((item.cost * item.stock).toStringAsFixed(0)),
                          ),
                          DataCell(
                            isLow
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'منخفض',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        fontSize: 10,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.check,
                                    color: AppColors.success,
                                    size: 16,
                                  ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InventoryItem {
  final String name, category, sku;
  final double stock, minStock;
  final double cost, price;
  final DateTime lastUpdated;
  _InventoryItem({
    required this.name,
    required this.category,
    required this.sku,
    required this.stock,
    required this.minStock,
    required this.cost,
    required this.price,
    required this.lastUpdated,
  });
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 18,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    ),
  );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(start: 8),
    child: FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    ),
  );
}
