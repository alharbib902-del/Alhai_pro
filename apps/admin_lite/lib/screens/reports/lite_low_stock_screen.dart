/// Lite Low Stock Alerts Screen
///
/// Shows products that are below their reorder threshold,
/// sorted by urgency. Queries real data from productsDao.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../providers/lite_screen_providers.dart';

/// Low stock alerts report for Admin Lite
class LiteLowStockScreen extends ConsumerWidget {
  const LiteLowStockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;
    final dataAsync = ref.watch(liteLowStockProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.lowStock),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(liteLowStockProvider),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.sync,
          ),
          const SizedBox(width: AlhaiSpacing.xs),
        ],
      ),
      body: dataAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 64,
                      color: isDark
                          ? Colors.white24
                          : AlhaiColors.success.withValues(alpha: 0.5)),
                  const SizedBox(height: AlhaiSpacing.md),
                  Text(l10n.noResults,
                      style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? Colors.white54
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                ],
              ),
            );
          }
          final outOfStockCount = items.where((p) => p.stockQty <= 0).length;
          return Column(
            children: [
              _buildSummaryBar(
                  context, isDark, l10n, items.length, outOfStockCount),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => ref.invalidate(liteLowStockProvider),
                  child: ListView.builder(
                    padding: EdgeInsets.all(
                        isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _buildStockItem(context, items[index], isDark);
                    },
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.errorOccurred),
              TextButton.icon(
                onPressed: () => ref.invalidate(liteLowStockProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBar(BuildContext context, bool isDark,
      AppLocalizations l10n, int total, int outOfStock) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : AlhaiColors.warning.withValues(alpha: 0.06),
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
          Icon(Icons.warning_amber_rounded,
              size: 20, color: AlhaiColors.warning),
          const SizedBox(width: AlhaiSpacing.xs),
          Expanded(
            child: Text(
              '$total ${l10n.products}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxxs),
            decoration: BoxDecoration(
              color: AlhaiColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$outOfStock ${l10n.outOfStock}',
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

  Widget _buildStockItem(BuildContext context, dynamic product, bool isDark) {
    final stockQty = (product.stockQty is int)
        ? (product.stockQty as int).toDouble()
        : product.stockQty as double;
    final minQty = (product.minQty is int)
        ? (product.minQty as int).toDouble()
        : product.minQty as double;
    final current = stockQty.toInt();
    final threshold = minQty.toInt();

    final urgencyColor = current == 0
        ? AlhaiColors.error
        : (current <= 3 ? AlhaiColors.warning : AlhaiColors.info);
    final fillRatio =
        threshold > 0 ? (current / threshold).clamp(0.0, 1.0) : 0.0;

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
                  current == 0 ? Icons.error_outline : Icons.warning_amber,
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
                      product.name as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      product.sku as String? ??
                          product.barcode as String? ??
                          '',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$current/$threshold',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: urgencyColor,
                    ),
                  ),
                  Text(
                    product.unit as String? ?? 'units',
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
}
