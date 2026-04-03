/// Lite Top Products Screen
///
/// Shows top selling products by revenue and quantity,
/// with filter by period and category.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Top products report for Admin Lite
class LiteTopProductsScreen extends StatefulWidget {
  const LiteTopProductsScreen({super.key});

  @override
  State<LiteTopProductsScreen> createState() => _LiteTopProductsScreenState();
}

class _LiteTopProductsScreenState extends State<LiteTopProductsScreen> {
  int _sortBy = 0; // 0=revenue, 1=quantity

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.topProductsTab),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Sort toggle
          _buildSortToggle(isDark, l10n),

          // Products list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return _buildProductTile(context, product, index, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortToggle(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildSortChip(l10n.totalSales, 0, isDark),
          const SizedBox(width: AlhaiSpacing.xs),
          _buildSortChip(l10n.quantity, 1, isDark),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, int index, bool isDark) {
    final isSelected = _sortBy == index;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _sortBy = index),
      selectedColor: AlhaiColors.primary.withValues(alpha: 0.15),
      checkmarkColor: AlhaiColors.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? AlhaiColors.primary
            : (isDark ? Colors.white70 : Theme.of(context).colorScheme.onSurface),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? AlhaiColors.primary : (isDark ? Colors.white24 : Theme.of(context).colorScheme.outlineVariant),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildProductTile(BuildContext context, _ProductData product, int index, bool isDark) {
    final rank = index + 1;
    final rankColor = rank <= 3 ? AlhaiColors.warning : (isDark ? Colors.white24 : Colors.grey.shade300);

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
          // Rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: rank <= 3 ? AlhaiColors.warning : (isDark ? Colors.white54 : Colors.black54),
                ),
              ),
            ),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          // Product info
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
                const SizedBox(height: AlhaiSpacing.xxxs),
                Text(
                  '${product.quantity} units',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Revenue
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                product.revenue,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    product.trend >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: product.trend >= 0 ? AlhaiColors.success : AlhaiColors.error,
                  ),
                  Text(
                    '${product.trend.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: product.trend >= 0 ? AlhaiColors.success : AlhaiColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const _products = [
    _ProductData('Rice 10kg', '4,500', 450, 12.5),
    _ProductData('Sugar 5kg', '3,800', 380, 8.2),
    _ProductData('Cooking Oil 2L', '3,200', 320, -2.1),
    _ProductData('Milk 1L', '2,800', 560, 15.0),
    _ProductData('Bread', '2,500', 625, 3.4),
    _ProductData('Eggs 30pc', '2,200', 220, 6.1),
    _ProductData('Chicken 1kg', '2,000', 200, -5.3),
    _ProductData('Tomato Paste', '1,800', 360, 1.2),
    _ProductData('Tea 200g', '1,600', 320, 4.5),
    _ProductData('Coffee 250g', '1,400', 140, 7.8),
  ];
}

class _ProductData {
  final String name;
  final String revenue;
  final int quantity;
  final double trend;
  const _ProductData(this.name, this.revenue, this.quantity, this.trend);
}
