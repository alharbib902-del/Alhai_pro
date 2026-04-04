/// Lite Stock Adjustment Screen
///
/// Quick stock adjustments with search, queried from productsDao
/// with real updateStock() and inventoryDao recording.
/// Supports RTL, dark mode, and responsive layouts.
library;

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

  @override
  void dispose() {
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
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })
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
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildProductTile(context, filtered[index], isDark, l10n);
                  },
                );
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
            width: 44, height: 44,
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
