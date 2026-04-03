/// Lite Low Stock Alerts Screen
///
/// Shows products that are below their reorder threshold,
/// sorted by urgency. Provides quick reorder actions.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Low stock alerts report for Admin Lite
class LiteLowStockScreen extends StatelessWidget {
  const LiteLowStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.lowStock),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list),
            tooltip: l10n.filter,
          ),
          const SizedBox(width: AlhaiSpacing.xs),
        ],
      ),
      body: Column(
        children: [
          // Summary bar
          _buildSummaryBar(context, isDark, l10n),

          // Items list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return _buildStockItem(context, _items[index], isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : AlhaiColors.warning.withValues(alpha: 0.06),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 20, color: AlhaiColors.warning),
          const SizedBox(width: AlhaiSpacing.xs),
          Expanded(
            child: Text(
              '${_items.length} ${l10n.products}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxxs),
            decoration: BoxDecoration(
              color: AlhaiColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_items.where((i) => i.current == 0).length} ${l10n.outOfStock}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AlhaiColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockItem(BuildContext context, _StockItem item, bool isDark) {
    final urgencyColor = item.current == 0
        ? AlhaiColors.error
        : (item.current <= 3 ? AlhaiColors.warning : AlhaiColors.info);
    final fillRatio = item.threshold > 0 ? (item.current / item.threshold).clamp(0.0, 1.0) : 0.0;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: urgencyColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.current == 0 ? Icons.error_outline : Icons.warning_amber,
                  color: urgencyColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      item.sku,
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
                    '${item.current}/${item.threshold}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: urgencyColor,
                    ),
                  ),
                  Text(
                    'units',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          // Stock level bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: fillRatio,
              backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
              color: urgencyColor,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  static const _items = [
    _StockItem('Rice 5kg', 'SKU-001', 0, 10),
    _StockItem('Sugar 2kg', 'SKU-002', 2, 15),
    _StockItem('Cooking Oil 1L', 'SKU-003', 3, 12),
    _StockItem('Lentils 1kg', 'SKU-004', 0, 8),
    _StockItem('Flour 2kg', 'SKU-005', 4, 10),
    _StockItem('Butter 500g', 'SKU-006', 5, 12),
    _StockItem('Cheese 200g', 'SKU-007', 1, 8),
    _StockItem('Tomato Paste 400g', 'SKU-008', 3, 10),
  ];
}

class _StockItem {
  final String name;
  final String sku;
  final int current;
  final int threshold;
  const _StockItem(this.name, this.sku, this.current, this.threshold);
}
