/// Lite Quick Price Update Screen
///
/// Allows quick price changes for products with search,
/// queried from productsDao with real updateProduct().
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart' show Money;
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart' show CurrencyFormatter;
import 'package:get_it/get_it.dart';

import '../../core/services/sentry_service.dart';
import '../../providers/lite_screen_providers.dart';

/// Quick price update screen for Admin Lite
class LiteQuickPriceScreen extends ConsumerStatefulWidget {
  const LiteQuickPriceScreen({super.key});

  @override
  ConsumerState<LiteQuickPriceScreen> createState() =>
      _LiteQuickPriceScreenState();
}

class _LiteQuickPriceScreenState extends ConsumerState<LiteQuickPriceScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _searchQuery = value);
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
    return products
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              (p.barcode?.toLowerCase().contains(q) ?? false) ||
              (p.sku?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context);
    final dataAsync = ref.watch(liteAllProductsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.price), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(
              isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _debounce?.cancel();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white24
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white12
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white,
              ),
            ),
          ),
          Expanded(
            child: dataAsync.when(
              data: (products) {
                final filtered = _filter(products);
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

  Widget _buildCardList(
    List<ProductsTableData> products,
    bool isDark,
    bool isMobile,
    AppLocalizations l10n,
  ) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg,
      ),
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
            DataColumn(label: Text(l10n.price), numeric: true),
            DataColumn(label: Text(l10n.categoryLabel)),
            DataColumn(label: Text(l10n.actionsCol)),
          ],
          rows: products
              .map(
                (product) => DataRow(
                  key: ValueKey(product.id),
                  cells: [
                    DataCell(Text(product.name)),
                    DataCell(
                      // C-4 (Session 41 §B1): formatNumber handles the cents
                      // → SAR scale via Money.fromCents + grouping separators,
                      // keeping the localized ${l10n.sar} suffix intact
                      // (formatMoney would emit the default store symbol
                      // `ر.س`, which drifts from the English-locale SAR
                      // literal). Drift row → int cents after Stage B.
                      Text(
                        '${CurrencyFormatter.formatNumber(Money.fromCents(product.price).toDouble())} ${l10n.sar}',
                      ),
                    ),
                    DataCell(Text(product.categoryId ?? '-')),
                    DataCell(
                      IconButton(
                        tooltip: l10n.edit,
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () =>
                            _showPriceDialog(context, product, isDark, l10n),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildProductTile(
    BuildContext context,
    ProductsTableData product,
    bool isDark,
    AppLocalizations l10n,
  ) {
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
            width: AlhaiSpacing.listTileCompactMinHeight,
            height: AlhaiSpacing.listTileCompactMinHeight,
            decoration: BoxDecoration(
              color: AlhaiColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AlhaiColors.primary,
              size: 22,
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
                Text(
                  product.sku ?? product.barcode ?? '',
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
            // C-4 (Session 41 §B1): formatNumber handles the cents → SAR
            // scale via Money.fromCents and (with decimalDigits: 0) produces
            // the same whole-number grouping the old toStringAsFixed(0) gave,
            // while keeping the literal "SAR" suffix from the original site.
            // Drift row → int cents after Stage B.
            '${CurrencyFormatter.formatNumber(Money.fromCents(product.price).toDouble(), decimalDigits: 0)} SAR',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          IconButton(
            tooltip: 'Edit price',
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

  void _showPriceDialog(
    BuildContext context,
    ProductsTableData product,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final controller = TextEditingController(
      // C-4 Stage B: product.price is int cents; controller shows SAR.
      text: (product.price / 100.0).toStringAsFixed(2),
    );
    String? errorText;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(product.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  setDialogState(() {
                    if (value.isEmpty) {
                      errorText = null;
                    } else if (parsed == null || parsed <= 0) {
                      errorText = l10n.errorOccurred;
                    } else {
                      errorText = null;
                    }
                  });
                },
                decoration: InputDecoration(
                  labelText: l10n.price,
                  suffixText: 'SAR',
                  errorText: errorText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
              onPressed: () async {
                final newPrice = double.tryParse(controller.text);
                if (newPrice != null && newPrice > 0) {
                  try {
                    final db = GetIt.I<AppDatabase>();
                    // C-4 Stage B: product.price is int cents; convert user-typed SAR double.
                    final updated = product.copyWith(
                      price: (newPrice * 100).round(),
                      updatedAt: Value(DateTime.now()),
                    );
                    await db.productsDao.updateProduct(updated);
                    ref.invalidate(liteAllProductsProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.success),
                          backgroundColor: AlhaiColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  } catch (e, st) {
                    reportError(
                      e,
                      stackTrace: st,
                      hint: 'LiteQuickPriceScreen: price update',
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.errorOccurred),
                          backgroundColor: AlhaiColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  }
                } else {
                  setDialogState(() {
                    errorText = l10n.errorOccurred;
                  });
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
