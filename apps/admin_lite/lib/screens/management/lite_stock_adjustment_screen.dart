/// Lite Stock Adjustment Screen
///
/// Quick stock adjustments with search, queried from productsDao
/// with real updateStock() and inventoryDao recording.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:get_it/get_it.dart';

import '../../providers/lite_screen_providers.dart';

/// Quick stock adjustment screen for Admin Lite
class LiteStockAdjustmentScreen extends ConsumerStatefulWidget {
  const LiteStockAdjustmentScreen({super.key});

  @override
  ConsumerState<LiteStockAdjustmentScreen> createState() => _LiteStockAdjustmentScreenState();
}

class _LiteStockAdjustmentScreenState extends ConsumerState<LiteStockAdjustmentScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _searchQuery = value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<ProductsTableData> _filter(List<ProductsTableData> products) {
    if (_searchQuery.isEmpty) return products;
    final q = _searchQuery.toLowerCase();
    return products.where((p) =>
        p.name.toLowerCase().contains(q) ||
        (p.barcode?.toLowerCase().contains(q) ?? false) ||
        (p.sku?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  Future<void> _adjustStock(ProductsTableData product, double delta) async {
    final db = GetIt.I<AppDatabase>();
    final storeId = ref.read(currentStoreIdProvider);
    final newQty = product.stockQty + delta;
    if (newQty < 0) return;

    try {
      await db.productsDao.updateStock(product.id, newQty);
      await db.inventoryDao.recordAdjustment(
        id: const Uuid().v4(),
        productId: product.id,
        storeId: storeId ?? product.storeId,
        newQty: newQty,
        previousQty: product.stockQty,
        reason: 'Admin Lite adjustment',
      );
      ref.invalidate(liteAllProductsProvider);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.success),
            backgroundColor: AlhaiColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOccurred),
            backgroundColor: AlhaiColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;
    final dataAsync = ref.watch(liteAllProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adjustment),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(tooltip: 'Clear search', icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _debounce?.cancel(); setState(() => _searchQuery = ''); })
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white24 : Theme.of(context).colorScheme.outlineVariant)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant)),
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
              ),
            ),
          ),
          Expanded(
            child: dataAsync.when(
              data: (products) {
                final filtered = _filter(products);
                if (filtered.isEmpty) {
                  return Center(child: Text(l10n.noResults, style: TextStyle(color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant)));
                }
                final isWide = size.width > 900;
                if (isWide) {
                  return _buildDataTable(filtered, isDark, l10n);
                }
                return _buildCardList(filtered, isDark, isMobile, l10n);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.errorOccurred),
                    TextButton.icon(onPressed: () => ref.invalidate(liteAllProductsProvider), icon: const Icon(Icons.refresh_rounded), label: Text(l10n.tryAgain)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardList(List<ProductsTableData> products, bool isDark, bool isMobile, AppLocalizations l10n) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return KeyedSubtree(
          key: ValueKey(product.id),
          child: _buildProductTile(context, product, isDark, l10n),
        );
      },
    );
  }

  Widget _buildDataTable(List<ProductsTableData> products, bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.lg),
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
          ),
          columns: [
            DataColumn(label: Text(l10n.product)),
            DataColumn(label: Text(l10n.currentStock), numeric: true),
            DataColumn(label: Text(l10n.minimumQuantity), numeric: true),
            DataColumn(label: Text(l10n.status)),
            DataColumn(label: Text(l10n.actionsCol)),
          ],
          rows: products.map((product) {
            final stock = product.stockQty.toInt();
            final threshold = product.minQty.toInt();
            final stockColor = stock == 0
                ? AlhaiColors.error
                : (stock <= threshold ? AlhaiColors.warning : AlhaiColors.success);
            final statusText = stock == 0
                ? l10n.outOfStock
                : (stock <= threshold ? l10n.lowStock : l10n.stock);

            return DataRow(
              key: ValueKey(product.id),
              cells: [
                DataCell(Text(product.name)),
                DataCell(Text(
                  '$stock',
                  style: TextStyle(fontWeight: FontWeight.bold, color: stockColor),
                )),
                DataCell(Text('$threshold')),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxxs),
                  decoration: BoxDecoration(color: stockColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(statusText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: stockColor)),
                )),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: '-1',
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      color: AlhaiColors.error,
                      onPressed: stock > 0 ? () => _adjustStock(product, -1) : null,
                    ),
                    IconButton(
                      tooltip: '+1',
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      color: AlhaiColors.success,
                      onPressed: () => _adjustStock(product, 1),
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProductTile(BuildContext context, ProductsTableData product, bool isDark, AppLocalizations l10n) {
    final stock = product.stockQty.toInt();
    final threshold = product.minQty.toInt();
    final stockColor = stock == 0
        ? AlhaiColors.error
        : (stock <= threshold ? AlhaiColors.warning : AlhaiColors.success);

    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: AlhaiSpacing.listTileCompactMinHeight, height: AlhaiSpacing.listTileCompactMinHeight,
            decoration: BoxDecoration(color: stockColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.inventory_2, color: stockColor, size: 22),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                Row(
                  children: [
                    Text('${l10n.stock}: ', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant)),
                    Text('$stock', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: stockColor)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Decrease stock',
                  onPressed: stock > 0 ? () => _adjustStock(product, -1) : null,
                  icon: const Icon(Icons.remove, size: 16),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                  color: AlhaiColors.error,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xxs),
                  child: Text('$stock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                ),
                IconButton(
                  tooltip: 'Increase stock',
                  onPressed: () => _adjustStock(product, 1),
                  icon: const Icon(Icons.add, size: 16),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                  color: AlhaiColors.success,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
