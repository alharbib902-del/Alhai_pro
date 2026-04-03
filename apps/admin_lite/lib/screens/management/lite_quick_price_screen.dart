/// Lite Quick Price Update Screen
///
/// Allows quick price changes for products with search,
/// current price display, and inline editing.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Quick price update screen for Admin Lite
class LiteQuickPriceScreen extends StatefulWidget {
  const LiteQuickPriceScreen({super.key});

  @override
  State<LiteQuickPriceScreen> createState() => _LiteQuickPriceScreenState();
}

class _LiteQuickPriceScreenState extends State<LiteQuickPriceScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_PriceProduct> get _filteredProducts {
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
        title: Text(l10n.price),
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

  Widget _buildProductTile(BuildContext context, _PriceProduct product, bool isDark, AppLocalizations l10n) {
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
              color: AlhaiColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: AlhaiColors.primary, size: 22),
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
                Text(
                  product.sku,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${product.price} SAR',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              if (product.oldPrice != null)
                Text(
                  '${product.oldPrice} SAR',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AlhaiColors.error,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          IconButton(
            onPressed: () => _showPriceDialog(context, product, isDark, l10n),
            icon: const Icon(Icons.edit, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: AlhaiColors.primary.withValues(alpha: 0.1),
              foregroundColor: AlhaiColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showPriceDialog(BuildContext context, _PriceProduct product, bool isDark, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.price,
                hintText: product.price,
                suffixText: 'SAR',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  static const _products = [
    _PriceProduct('Rice 10kg', 'SKU-001', '45', null),
    _PriceProduct('Sugar 5kg', 'SKU-002', '22', '25'),
    _PriceProduct('Cooking Oil 2L', 'SKU-003', '24', null),
    _PriceProduct('Milk 1L', 'SKU-004', '6', null),
    _PriceProduct('Bread', 'SKU-005', '3', null),
    _PriceProduct('Eggs 30pc', 'SKU-006', '18', '20'),
    _PriceProduct('Chicken 1kg', 'SKU-007', '28', null),
    _PriceProduct('Tomato Paste 400g', 'SKU-008', '5', null),
    _PriceProduct('Tea 200g', 'SKU-009', '12', null),
    _PriceProduct('Coffee 250g', 'SKU-010', '35', '38'),
  ];
}

class _PriceProduct {
  final String name;
  final String sku;
  final String price;
  final String? oldPrice;
  const _PriceProduct(this.name, this.sku, this.price, this.oldPrice);
}
