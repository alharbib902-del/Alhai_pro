/// Cashier Categories Screen - Read-only category browser
///
/// Grid view of categories with icon, name, product count.
/// Tap shows products in that category. Read-only for cashier.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
// alhai_design_system is re-exported via alhai_shared_ui

/// شاشة التصنيفات للكاشير
class CashierCategoriesScreen extends ConsumerStatefulWidget {
  const CashierCategoriesScreen({super.key});

  @override
  ConsumerState<CashierCategoriesScreen> createState() =>
      _CashierCategoriesScreenState();
}

class _CashierCategoriesScreenState
    extends ConsumerState<CashierCategoriesScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _searchController = TextEditingController();

  List<CategoriesTableData> _categories = [];
  List<CategoriesTableData> _filteredCategories = [];
  Map<String, int> _productCounts = {};
  bool _isLoading = true;

  // Selected category for product view
  CategoriesTableData? _selectedCategory;
  List<ProductsTableData> _categoryProducts = [];
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _searchController.addListener(_applySearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      final categories = await _db.categoriesDao.getAllCategories(storeId);
      final counts = <String, int>{};

      for (final cat in categories) {
        try {
          final products =
              await _db.productsDao.getProductsByCategory(cat.id, storeId);
          counts[cat.id] = products.length;
        } catch (_) {
          counts[cat.id] = 0;
        }
      }

      if (mounted) {
        setState(() {
          _categories = categories;
          _filteredCategories = categories;
          _productCounts = counts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredCategories = query.isEmpty
          ? _categories
          : _categories
              .where((c) => c.name.toLowerCase().contains(query))
              .toList();
    });
  }

  Future<void> _loadCategoryProducts(CategoriesTableData category) async {
    setState(() {
      _selectedCategory = category;
      _isLoadingProducts = true;
    });
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final products =
          await _db.productsDao.getProductsByCategory(category.id, storeId);
      if (mounted) {
        setState(() {
          _categoryProducts = products;
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = context.isDesktop;
    final isMediumScreen = !context.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.categories,
          subtitle:
              '${_categories.length} ${l10n.categories} \u2022 ${l10n.mainBranch}',
          showSearch: false,
          searchHint: l10n.searchPlaceholder,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: user?.name ?? l10n.cashCustomer,
          userRole: l10n.branchManager,
          onUserTap: () {},
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
        ),
      ],
    );
  }

  Widget _buildContent(
      bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    if (isWideScreen && _selectedCategory != null) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildCategoriesPanel(isMediumScreen, isDark, l10n),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 4,
            child: _buildProductsPanel(isDark, l10n),
          ),
        ],
      );
    }

    if (_selectedCategory != null && !isWideScreen) {
      return _buildProductsPanel(isDark, l10n);
    }

    return _buildCategoriesPanel(isMediumScreen, isDark, l10n);
  }

  Widget _buildCategoriesPanel(
      bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            decoration: InputDecoration(
              hintText: l10n.searchCategories,
              hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
              prefixIcon: Icon(Icons.search_rounded,
                  color: AppColors.getTextMuted(isDark)),
              filled: true,
              fillColor: AppColors.getSurface(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
        ),
        // Grid
        Expanded(
          child: _filteredCategories.isEmpty
              ? _buildEmptyState(isDark, l10n)
              : GridView.builder(
                  padding: EdgeInsets.symmetric(
                      horizontal: isMediumScreen ? 24 : 16, vertical: 8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMediumScreen ? 3 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _filteredCategories.length,
                  itemBuilder: (context, index) => _buildCategoryCard(
                      _filteredCategories[index], isDark, l10n),
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
      CategoriesTableData category, bool isDark, AppLocalizations l10n) {
    final isSelected = _selectedCategory?.id == category.id;
    final count = _productCounts[category.id] ?? 0;
    final color = _getCategoryColor(category.name);

    return InkWell(
      onTap: () => _loadCategoryProducts(category),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.getBorder(isDark),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(_getCategoryIcon(category.name),
                  color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(isDark),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.getSurfaceVariant(isDark),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count ${l10n.products}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsPanel(bool isDark, AppLocalizations l10n) {
    final category = _selectedCategory!;

    return Column(
      children: [
        // Back button + category header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.getSurface(isDark),
            border: Border(
              bottom:
                  BorderSide(color: AppColors.getBorder(isDark), width: 1),
            ),
          ),
          child: Row(
            children: [
              if (!context.isDesktop)
                IconButton(
                  onPressed: () =>
                      setState(() => _selectedCategory = null),
                  icon: Icon(Icons.arrow_back_rounded,
                      color: AppColors.getTextPrimary(isDark)),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.getSurfaceVariant(isDark),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              if (!context.isDesktop)
                const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getCategoryColor(category.name)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(_getCategoryIcon(category.name),
                    color: _getCategoryColor(category.name), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.name,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.getTextPrimary(isDark))),
                    Text(
                      '${_categoryProducts.length} ${l10n.products}',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getTextSecondary(isDark)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Products list
        Expanded(
          child: _isLoadingProducts
              ? const Center(child: CircularProgressIndicator())
              : _categoryProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 48,
                              color: AppColors.getTextMuted(isDark)
                                  .withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text(l10n.noProducts,
                              style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      AppColors.getTextMuted(isDark))),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _categoryProducts.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) =>
                          _buildProductItem(
                              _categoryProducts[index], isDark, l10n),
                    ),
        ),
      ],
    );
  }

  Widget _buildProductItem(
      ProductsTableData product, bool isDark, AppLocalizations l10n) {
    final hasLowStock = product.stockQty < 5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.inventory_2_outlined,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(isDark))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (product.barcode != null) ...[
                      Icon(Icons.qr_code_rounded,
                          size: 12,
                          color: AppColors.getTextMuted(isDark)),
                      const SizedBox(width: 4),
                      Text(product.barcode!,
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.getTextMuted(isDark),
                              fontFamily: 'monospace')),
                      const SizedBox(width: 10),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (hasLowStock
                                ? AppColors.error
                                : AppColors.success)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${l10n.stock}: ${product.stockQty}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: hasLowStock
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${product.price.toStringAsFixed(2)} ${l10n.sar}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined,
              size: 64,
              color:
                  AppColors.getTextMuted(isDark).withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(l10n.noCategories,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getTextMuted(isDark))),
        ],
      ),
    );
  }

  Color _getCategoryColor(String name) {
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.info,
      AppColors.warning,
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFF97316),
      const Color(0xFF06B6D4),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  IconData _getCategoryIcon(String name) {
    final icons = [
      Icons.category_rounded,
      Icons.fastfood_rounded,
      Icons.local_drink_rounded,
      Icons.cleaning_services_rounded,
      Icons.devices_rounded,
      Icons.checkroom_rounded,
      Icons.health_and_safety_rounded,
      Icons.toys_rounded,
    ];
    return icons[name.hashCode.abs() % icons.length];
  }
}
