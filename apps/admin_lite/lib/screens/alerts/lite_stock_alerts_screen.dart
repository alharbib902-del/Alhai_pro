/// Lite Stock Alerts Screen
///
/// Dedicated screen for stock-related alerts queried from
/// productsDao.getLowStockProducts(). Shows out-of-stock
/// and low-stock products.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../providers/lite_screen_providers.dart';

/// Stock alerts screen for Admin Lite
class LiteStockAlertsScreen extends ConsumerStatefulWidget {
  const LiteStockAlertsScreen({super.key});

  @override
  ConsumerState<LiteStockAlertsScreen> createState() =>
      _LiteStockAlertsScreenState();
}

class _LiteStockAlertsScreenState extends ConsumerState<LiteStockAlertsScreen> {
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context);
    final dataAsync = ref.watch(liteStockAlertsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.lowStock), centerTitle: true),
      body: Column(
        children: [
          _buildFilterTabs(isDark, l10n),
          Expanded(
            child: dataAsync.when(
              data: (products) {
                final filtered = _filterProducts(products);
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noResults,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white54
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
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
                    TextButton.icon(
                      onPressed: () => ref.invalidate(liteStockAlertsProvider),
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

  List<ProductsTableData> _filterProducts(List<ProductsTableData> products) {
    switch (_filterIndex) {
      case 1:
        return products.where((p) => p.stockQty <= 0).toList();
      case 2:
        return products
            .where((p) => p.stockQty > 0 && p.stockQty <= p.minQty)
            .toList();
      default:
        return products;
    }
  }

  Widget _buildFilterTabs(bool isDark, AppLocalizations l10n) {
    final filters = [l10n.all, l10n.outOfStock, l10n.lowStock];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white12
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.asMap().entries.map((entry) {
            final isSelected = _filterIndex == entry.key;
            return Padding(
              padding: const EdgeInsetsDirectional.only(end: AlhaiSpacing.xs),
              child: FilterChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (_) => setState(() => _filterIndex = entry.key),
                selectedColor: AlhaiColors.primary.withValues(alpha: 0.15),
                checkmarkColor: AlhaiColors.primary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? AlhaiColors.primary
                      : (isDark
                            ? Colors.white70
                            : Theme.of(context).colorScheme.onSurface),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                side: BorderSide(
                  color: isSelected
                      ? AlhaiColors.primary
                      : (isDark
                            ? Colors.white24
                            : Theme.of(context).colorScheme.outlineVariant),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCardList(
    List<ProductsTableData> products,
    bool isDark,
    bool isMobile,
    AppLocalizations l10n,
  ) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(liteStockAlertsProvider),
      child: ListView.builder(
        padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildAlertTile(context, products[index], isDark);
        },
      ),
    );
  }

  Widget _buildDataTable(
    List<ProductsTableData> products,
    bool isDark,
    AppLocalizations l10n,
  ) {
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
            DataColumn(label: Text(l10n.stock), numeric: true),
            DataColumn(label: Text(l10n.minimumQuantity), numeric: true),
            DataColumn(label: Text(l10n.status)),
          ],
          rows: products.map((product) {
            final stock = product.stockQty.toInt();
            final isOutOfStock = stock <= 0;
            final color = isOutOfStock
                ? AlhaiColors.error
                : AlhaiColors.warning;
            final statusText = isOutOfStock ? l10n.outOfStock : l10n.lowStock;

            return DataRow(
              key: ValueKey(product.id),
              cells: [
                DataCell(Text(product.name)),
                DataCell(
                  Text(
                    '$stock',
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                ),
                DataCell(Text('${product.minQty.toInt()}')),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.xs,
                      vertical: AlhaiSpacing.xxxs,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAlertTile(
    BuildContext context,
    ProductsTableData product,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context);
    final stock = product.stockQty.toInt();
    final isOutOfStock = stock <= 0;
    final color = isOutOfStock ? AlhaiColors.error : AlhaiColors.warning;
    final icon = isOutOfStock ? Icons.error_outline : Icons.warning_amber;
    final desc = isOutOfStock
        ? '${l10n.outOfStock} (0 ${l10n.units})'
        : '$stock ${l10n.units} ${l10n.remainingLabel}';

    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white12
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
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
                const SizedBox(height: AlhaiSpacing.xxxs),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white38
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.xs,
              vertical: AlhaiSpacing.xxxs,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$stock',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
