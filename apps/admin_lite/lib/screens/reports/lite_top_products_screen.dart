/// Lite Top Products Screen
///
/// Shows top selling products by revenue and quantity,
/// queried from salesDao GROUP BY product.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../providers/lite_screen_providers.dart';

/// Top products report for Admin Lite
class LiteTopProductsScreen extends ConsumerStatefulWidget {
  const LiteTopProductsScreen({super.key});

  @override
  ConsumerState<LiteTopProductsScreen> createState() =>
      _LiteTopProductsScreenState();
}

class _LiteTopProductsScreenState extends ConsumerState<LiteTopProductsScreen> {
  int _sortBy = 0; // 0=revenue, 1=quantity

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context);
    final dataAsync = ref.watch(liteTopProductsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.topProductsTab), centerTitle: true),
      body: Column(
        children: [
          _buildSortToggle(isDark, l10n),
          Expanded(
            child: dataAsync.when(
              data: (products) {
                final sorted = List<TopProductData>.from(products);
                if (_sortBy == 1) {
                  sorted.sort((a, b) => b.quantity.compareTo(a.quantity));
                }
                if (sorted.isEmpty) {
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
                return ListView.builder(
                  padding: EdgeInsets.all(
                    isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg,
                  ),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    return _buildProductTile(
                      context,
                      sorted[index],
                      index,
                      isDark,
                    );
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
                      onPressed: () => ref.invalidate(liteTopProductsProvider),
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

  Widget _buildSortToggle(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.sm,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildProductTile(
    BuildContext context,
    TopProductData product,
    int index,
    bool isDark,
  ) {
    final rank = index + 1;
    final rankColor = rank <= 3
        ? AlhaiColors.warning
        : (isDark ? Colors.white24 : Colors.grey.shade300);

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
                  color: rank <= 3
                      ? AlhaiColors.warning
                      : (isDark ? Colors.white54 : Colors.black54),
                ),
              ),
            ),
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
                  '${product.quantity} units',
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
          Text(
            product.revenue.toStringAsFixed(0),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
