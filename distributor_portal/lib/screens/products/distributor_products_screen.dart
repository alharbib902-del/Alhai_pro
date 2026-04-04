/// Distributor Products Catalog Screen
///
/// Displays real product catalog from Supabase with search and category filtering.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../data/models.dart';
import '../../providers/distributor_providers.dart';

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

  List<DistributorProduct> _filter(List<DistributorProduct> products) {
    var filtered = products;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) =>
              p.name.contains(_searchQuery) ||
              (p.barcode?.contains(_searchQuery) ?? false))
          .toList();
    }
    if (_selectedCategory.isNotEmpty) {
      filtered =
          filtered.where((p) => p.category == _selectedCategory).toList();
    }
    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final isMedium = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: Text(
          l10n?.distributorProducts ?? 'Product Catalog',
          style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
        ),
        centerTitle: false,
        actions: [
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n?.distributorComingSoon ?? 'Coming soon'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(l10n?.distributorAddProduct ?? 'Add Product'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.xs),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n?.distributorLoadError ?? 'Error loading data'),
              const SizedBox(height: AlhaiSpacing.md),
              FilledButton.icon(
                onPressed: () => ref.invalidate(productsProvider),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l10n?.distributorRetry ?? 'Retry'),
              ),
            ],
          ),
        ),
        data: (allProducts) {
          final products = _filter(allProducts);
          final categories = categoriesAsync.valueOrNull ?? [];

          return Column(
            children: [
              // Search & Filter Bar
              _buildSearchBar(isDark, isMedium, categories, l10n),

              // Products List
              Expanded(
                child: products.isEmpty
                    ? _buildEmptyState(isDark, l10n)
                    : isWide
                        ? _buildDataTable(products, isDark, l10n)
                        : _buildProductCards(products, isDark, isMedium, l10n),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, bool isMedium, List<String> categories,
      AppLocalizations? l10n) {
    final allCategories = ['', ...categories];

    return Container(
      padding: EdgeInsets.all(isMedium ? AlhaiSpacing.mdl : AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(
          bottom: BorderSide(color: AppColors.getBorder(isDark)),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            decoration: InputDecoration(
              hintText: l10n?.distributorSearchHint ?? 'Search by name or barcode...',
              hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
              prefixIcon: Icon(Icons.search_rounded,
                  color: AppColors.getTextMuted(isDark)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close_rounded,
                          color: AppColors.getTextMuted(isDark)),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.getSurfaceVariant(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.md, vertical: 14),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          SizedBox(
            height: 36,
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
                  onSelected: (_) =>
                      setState(() => _selectedCategory = cat),
                  selectedColor: AppColors.primary.withValues(alpha: 0.12),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.getTextSecondary(isDark),
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.getBorder(isDark),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<DistributorProduct> products, bool isDark,
      AppLocalizations? l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.getBorder(isDark)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.mdl, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.getSurfaceVariant(isDark),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  _tableHeader(l10n?.products ?? 'Product', 4, isDark),
                  _tableHeader(l10n?.distributorBarcode ?? 'Barcode', 2, isDark),
                  _tableHeader(l10n?.distributorCategory ?? 'Category', 2, isDark),
                  _tableHeader(l10n?.price ?? 'Price', 2, isDark),
                  _tableHeader(l10n?.distributorStock ?? 'Stock', 2, isDark),
                ],
              ),
            ),
            ...List.generate(products.length, (index) {
              final product = products[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.mdl, vertical: AlhaiSpacing.sm),
                decoration: BoxDecoration(
                  border: index < products.length - 1
                      ? Border(
                          bottom: BorderSide(
                            color: AppColors.getBorder(isDark)
                                .withValues(alpha: 0.5),
                          ),
                        )
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
                              color:
                                  AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.inventory_2_outlined,
                                color: AppColors.primary, size: 18),
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
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
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
            }),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String text, int flex, bool isDark) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.getTextSecondary(isDark),
        ),
      ),
    );
  }

  Widget _buildProductCards(List<DistributorProduct> products, bool isDark,
      bool isMedium, AppLocalizations? l10n) {
    return ListView.separated(
      padding: EdgeInsets.all(isMedium ? AlhaiSpacing.mdl : AlhaiSpacing.md),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final product = products[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.getSurface(isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.getBorder(isDark)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.inventory_2_outlined,
                    color: AppColors.primary, size: 22),
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
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
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

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
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
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations? l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 64, color: AppColors.getTextMuted(isDark)),
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
            l10n?.distributorChangeSearch ?? 'Try changing your search criteria',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }
}
