/// Distributor Products Catalog Screen
///
/// Displays real product catalog from Supabase with search and category filtering.
/// Uses debounced search and ListView.builder for virtualized rendering.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../data/models.dart';
import '../../providers/distributor_providers.dart';
import '../../ui/skeleton_loading.dart';
import 'create_product_dialog.dart';

class DistributorProductsScreen extends ConsumerStatefulWidget {
  const DistributorProductsScreen({super.key});

  @override
  ConsumerState<DistributorProductsScreen> createState() =>
      _DistributorProductsScreenState();
}

class _DistributorProductsScreenState
    extends ConsumerState<DistributorProductsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = '';
  Timer? _debounceTimer;

  // Sorting state
  int _sortColumnIndex = 0; // default sort by name
  bool _sortAscending = true;

  List<DistributorProduct> _filter(List<DistributorProduct> products) {
    var filtered = products;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (p) =>
                p.name.contains(_searchQuery) ||
                (p.barcode?.contains(_searchQuery) ?? false),
          )
          .toList();
    }
    if (_selectedCategory.isNotEmpty) {
      filtered = filtered
          .where((p) => p.category == _selectedCategory)
          .toList();
    }
    return filtered;
  }

  List<DistributorProduct> _sortProducts(List<DistributorProduct> products) {
    final sorted = List<DistributorProduct>.from(products);
    sorted.sort((a, b) {
      int result;
      switch (_sortColumnIndex) {
        case 0: // name
          result = a.name.compareTo(b.name);
        case 3: // price
          result = a.price.compareTo(b.price);
        case 4: // stock
          result = a.stock.compareTo(b.stock);
        default:
          result = 0;
      }
      return _sortAscending ? result : -result;
    });
    return sorted;
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _searchQuery = value);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= AlhaiBreakpoints.desktop;
    final isMedium = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: Text(
          l10n.distributorProducts,
          style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
        ),
        centerTitle: false,
        actions: [
          Semantics(
            button: true,
            label: l10n.distributorAddProduct,
            child: FilledButton.icon(
              onPressed: () async {
                await CreateProductDialog.show(context);
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l10n.distributorAddProduct),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.md,
                  vertical: AlhaiSpacing.xs,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AlhaiRadius.sm + 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
        ],
      ),
      body: productsAsync.when(
        loading: () => const TableSkeleton(rows: 8, columns: 5),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.distributorLoadError),
              const SizedBox(height: AlhaiSpacing.md),
              FilledButton.icon(
                onPressed: () => ref.invalidate(productsProvider),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l10n.distributorRetry),
              ),
            ],
          ),
        ),
        data: (allProducts) {
          final products = _filter(allProducts);
          final sortedProducts = _sortProducts(products);
          final categories = categoriesAsync.valueOrNull ?? [];
          final hasActiveFilter =
              _searchQuery.isNotEmpty || _selectedCategory.isNotEmpty;

          return Column(
            children: [
              // Search & Filter Bar
              _buildSearchBar(isDark, isMedium, categories, l10n),

              // Search result count
              if (hasActiveFilter)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.mdl,
                    vertical: AlhaiSpacing.xs,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      '${sortedProducts.length} results',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ),
                ),

              // Products List
              Expanded(
                child: sortedProducts.isEmpty
                    ? _buildEmptyState(isDark, l10n, hasActiveFilter)
                    : isWide
                    ? _buildDataTable(sortedProducts, isDark, l10n)
                    : _buildProductCards(
                        sortedProducts,
                        isDark,
                        isMedium,
                        l10n,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(
    bool isDark,
    bool isMedium,
    List<String> categories,
    AppLocalizations? l10n,
  ) {
    final allCategories = ['', ...categories];

    return Container(
      padding: EdgeInsets.all(isMedium ? AlhaiSpacing.mdl : AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(bottom: BorderSide(color: AppColors.getBorder(isDark))),
      ),
      child: Column(
        children: [
          Semantics(
            label: l10n?.distributorSearchHint ?? 'Search products',
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(color: AppColors.getTextPrimary(isDark)),
              decoration: InputDecoration(
                hintText:
                    l10n?.distributorSearchHint ??
                    'Search by name or barcode...',
                hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.getTextMuted(isDark),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? Semantics(
                        button: true,
                        label: 'Clear search',
                        child: IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: AppColors.getTextMuted(isDark),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _debounceTimer?.cancel();
                            setState(() => _searchQuery = '');
                          },
                        ),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.getSurfaceVariant(isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AlhaiRadius.md),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.md,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          SizedBox(
            height: 44, // Meet minimum 44px touch target
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: allCategories.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AlhaiSpacing.xs),
              itemBuilder: (_, index) {
                final cat = allCategories[index];
                final label = cat.isEmpty
                    ? (l10n?.distributorAllOrders ?? 'All')
                    : cat;
                final isSelected = cat == _selectedCategory;
                return FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  selectedColor: AppColors.primary.withValues(alpha: 0.12),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.getTextSecondary(isDark),
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.getBorder(isDark),
                  ),
                  // Fixed touch targets: removed VisualDensity.compact, proper padding
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(
    List<DistributorProduct> products,
    bool isDark,
    AppLocalizations? l10n,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      itemCount: products.length + 1, // +1 for the header
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.mdl,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceVariant(isDark),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border.all(color: AppColors.getBorder(isDark)),
            ),
            child: Row(
              children: [
                _tableHeader(
                  l10n?.products ?? 'Product',
                  4,
                  isDark,
                  sortIndex: 0,
                ),
                _tableHeader(l10n?.distributorBarcode ?? 'Barcode', 2, isDark),
                _tableHeader(
                  l10n?.distributorCategory ?? 'Category',
                  2,
                  isDark,
                ),
                _tableHeader(l10n?.price ?? 'Price', 2, isDark, sortIndex: 3),
                _tableHeader(
                  l10n?.distributorStock ?? 'Stock',
                  2,
                  isDark,
                  sortIndex: 4,
                ),
              ],
            ),
          );
        }

        final productIndex = index - 1;
        final product = products[productIndex];
        final isLast = productIndex == products.length - 1;

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.mdl,
            vertical: AlhaiSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.getSurface(isDark),
            border: Border(
              left: BorderSide(color: AppColors.getBorder(isDark)),
              right: BorderSide(color: AppColors.getBorder(isDark)),
              bottom: BorderSide(
                color: AppColors.getBorder(
                  isDark,
                ).withValues(alpha: isLast ? 1.0 : 0.5),
              ),
            ),
            borderRadius: isLast
                ? const BorderRadius.vertical(bottom: Radius.circular(16))
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AlhaiRadius.sm),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  product.barcode ?? '-',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AlhaiRadius.sm - 2),
                  ),
                  child: Text(
                    product.category,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${NumberFormat('#,##0.00').format(product.price)} ${l10n?.distributorSar ?? 'SAR'}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: _stockBadge(product.stock, isDark, l10n),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tableHeader(String text, int flex, bool isDark, {int? sortIndex}) {
    final isSorted = sortIndex != null && _sortColumnIndex == sortIndex;
    return Expanded(
      flex: flex,
      child: sortIndex != null
          ? InkWell(
              onTap: () {
                setState(() {
                  if (_sortColumnIndex == sortIndex) {
                    _sortAscending = !_sortAscending;
                  } else {
                    _sortColumnIndex = sortIndex;
                    _sortAscending = true;
                  }
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSorted
                          ? AppColors.primary
                          : AppColors.getTextSecondary(isDark),
                    ),
                  ),
                  if (isSorted)
                    Icon(
                      _sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 14,
                      color: AppColors.primary,
                    ),
                ],
              ),
            )
          : Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
    );
  }

  Widget _buildProductCards(
    List<DistributorProduct> products,
    bool isDark,
    bool isMedium,
    AppLocalizations? l10n,
  ) {
    return ListView.separated(
      padding: EdgeInsets.all(isMedium ? AlhaiSpacing.mdl : AlhaiSpacing.md),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: AlhaiSpacing.xs + 2),
      itemBuilder: (_, index) {
        final product = products[index];
        return Semantics(
          label:
              '${product.name}, ${product.category}, ${NumberFormat('#,##0.00').format(product.price)} ${l10n?.distributorSar ?? 'SAR'}',
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              borderRadius: BorderRadius.circular(AlhaiRadius.md + 2),
              border: Border.all(color: AppColors.getBorder(isDark)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AlhaiRadius.sm + 2),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
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
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: AlhaiSpacing.xxs),
                      Row(
                        children: [
                          if (product.barcode != null)
                            Text(
                              product.barcode!,
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: AppColors.getTextMuted(isDark),
                              ),
                            ),
                          if (product.barcode != null)
                            const SizedBox(width: AlhaiSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(
                                AlhaiRadius.xs,
                              ),
                            ),
                            child: Text(
                              product.category,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppColors.info,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '${NumberFormat('#,##0.00').format(product.price)} ${l10n?.distributorSar ?? 'SAR'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const Spacer(),
                          _stockBadge(product.stock, isDark, l10n),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _stockBadge(int stock, bool isDark, AppLocalizations? l10n) {
    final Color color;
    final String label;
    if (stock <= 0) {
      color = AppColors.error;
      label = l10n?.distributorStockEmpty ?? 'Out';
    } else if (stock < 100) {
      color = AppColors.warning;
      label = '${l10n?.distributorStockLow ?? 'Low'} ($stock)';
    } else {
      color = AppColors.success;
      label = '$stock';
    }

    return Semantics(
      label: 'Stock: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.xs,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(AlhaiRadius.sm - 2),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    bool isDark,
    AppLocalizations? l10n,
    bool hasActiveFilter,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.getTextMuted(isDark),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            l10n?.distributorNoProducts ?? 'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Text(
            l10n?.distributorChangeSearch ??
                'Try changing your search criteria',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
          // Action button to clear filter when filtered results are empty
          if (hasActiveFilter) ...[
            const SizedBox(height: AlhaiSpacing.md),
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                _debounceTimer?.cancel();
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = '';
                });
              },
              icon: const Icon(Icons.filter_alt_off, size: 18),
              label: const Text('Clear filters'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.md,
                  vertical: AlhaiSpacing.sm,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
