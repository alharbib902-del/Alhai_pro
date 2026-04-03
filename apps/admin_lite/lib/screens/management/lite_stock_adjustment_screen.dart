/// Lite Stock Adjustment Screen
///
/// Quick stock adjustments with search, current quantity display,
/// and increment/decrement controls.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Quick stock adjustment screen for Admin Lite
class LiteStockAdjustmentScreen extends StatefulWidget {
  const LiteStockAdjustmentScreen({super.key});

  @override
  State<LiteStockAdjustmentScreen> createState() => _LiteStockAdjustmentScreenState();
}

class _LiteStockAdjustmentScreenState extends State<LiteStockAdjustmentScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_StockProduct> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adjustment),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
              ),
            ),
          ),

          // Products list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                return _buildProductTile(context, _filteredProducts[index], isDark, l10n);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(BuildContext context, _StockProduct product, bool isDark, AppLocalizations l10n) {
    final stockColor = product.stock == 0
        ? AlhaiColors.error
        : (product.stock <= product.threshold ? AlhaiColors.warning : AlhaiColors.success);

    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: stockColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.inventory_2, color: stockColor, size: 22),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${l10n.stock}: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${product.stock}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: stockColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Adjustment controls
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.remove, size: 16),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                  color: AlhaiColors.error,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xxs),
                  child: Text(
                    '${product.stock}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
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

  static const _products = [
    _StockProduct('Rice 10kg', 45, 10),
    _StockProduct('Sugar 5kg', 22, 15),
    _StockProduct('Cooking Oil 2L', 8, 12),
    _StockProduct('Milk 1L', 35, 20),
    _StockProduct('Bread', 50, 30),
    _StockProduct('Eggs 30pc', 12, 10),
    _StockProduct('Chicken 1kg', 0, 8),
    _StockProduct('Tomato Paste 400g', 18, 10),
    _StockProduct('Tea 200g', 25, 10),
    _StockProduct('Coffee 250g', 3, 8),
  ];
}

class _StockProduct {
  final String name;
  final int stock;
  final int threshold;
  const _StockProduct(this.name, this.stock, this.threshold);
}
