/// Lite Quick Price Update Screen
///
/// Allows quick price changes for products with search,
/// queried from productsDao with real updateProduct().
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';

import '../../providers/lite_screen_providers.dart';

/// Quick price update screen for Admin Lite
class LiteQuickPriceScreen extends ConsumerStatefulWidget {
  const LiteQuickPriceScreen({super.key});

  @override
  ConsumerState<LiteQuickPriceScreen> createState() => _LiteQuickPriceScreenState();
}

class _LiteQuickPriceScreenState extends ConsumerState<LiteQuickPriceScreen> {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;
    final dataAsync = ref.watch(liteAllProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.price),
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
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
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
                    TextButton.icon(
                      onPressed: () => ref.invalidate(liteAllProductsProvider),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.tryAgain),
                    ),
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
            decoration: BoxDecoration(color: AlhaiColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.inventory_2_outlined, color: AlhaiColors.primary, size: 22),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                Text(product.sku ?? product.barcode ?? '', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Text('${product.price.toStringAsFixed(0)} SAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(width: AlhaiSpacing.xs),
          IconButton(
            onPressed: () => _showPriceDialog(context, product, isDark, l10n),
            icon: const Icon(Icons.edit, size: 18),
            style: IconButton.styleFrom(backgroundColor: AlhaiColors.primary.withValues(alpha: 0.1), foregroundColor: AlhaiColors.primary),
          ),
        ],
      ),
    );
  }

  void _showPriceDialog(BuildContext context, ProductsTableData product, bool isDark, AppLocalizations l10n) {
    final controller = TextEditingController(text: product.price.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.price,
                suffixText: 'SAR',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              final newPrice = double.tryParse(controller.text);
              if (newPrice != null && newPrice > 0) {
                final db = GetIt.I<AppDatabase>();
                final updated = product.copyWith(price: newPrice, updatedAt: DateTime.now());
                await db.productsDao.updateProduct(updated);
                ref.invalidate(liteAllProductsProvider);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
