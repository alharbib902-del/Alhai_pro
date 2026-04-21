import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:alhai_core/alhai_core.dart';
import '../../core/router/routes.dart';
import '../../core/responsive/responsive_utils.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/validators/input_sanitizer.dart';
import '../../core/utils/currency_formatter.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/products_providers.dart';
import 'package:alhai_auth/alhai_auth.dart';
import '../../widgets/common/common.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة قائمة المنتجات - تصميم Web محسّن مع App Shell + Dark Mode
class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _keyboardFocusNode = FocusNode();
  final _scrollController = ScrollController();
  String? _selectedCategoryId;
  String _stockFilter = 'all'; // all, available, low, out
  bool _isGridView = true;
  String _sortBy = 'name'; // name, price, stock, recent
  bool _sortAscending = true;
  bool _showFilters = true;
  Timer? _searchDebounce;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId != null) {
        ref
            .read(productsStateProvider.notifier)
            .loadProducts(storeId: storeId, refresh: true);
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _keyboardFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Scroll-to-top FAB visibility
    final showFab = _scrollController.offset > 500;
    if (showFab != _showScrollToTop) {
      setState(() => _showScrollToTop = showFab);
    }
    // Load more pagination
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId != null) {
        ref.read(productsStateProvider.notifier).loadMore(storeId: storeId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsStateProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final isWideScreen = context.isDesktop;
    final isDesktop = context.screenWidth >= AppSizes.breakpointTablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        floatingActionButton: AnimatedScale(
          scale: _showScrollToTop ? 1.0 : 0.0,
          duration: AlhaiDurations.standard,
          child: FloatingActionButton.small(
            onPressed: () => _scrollController.animateTo(
              0,
              duration: AlhaiDurations.slow,
              curve: AlhaiMotion.standardDecelerate,
            ),
            child: const Icon(Icons.arrow_upward),
          ),
        ),
        body: Row(
          children: [
            // App Sidebar (Desktop only)
            // Main Content
            Expanded(
              child: Column(
                children: [
                  // App Header
                  AppHeader(
                    title: l10n.products,
                    subtitle:
                        '${productsState.products.length} ${l10n.product}',
                    showSearch: false,
                    onMenuTap: isWideScreen
                        ? null
                        : () => Scaffold.of(context).openDrawer(),
                    onNotificationsTap: () => context.push('/notifications'),
                    notificationsCount: 3,
                    userName: l10n.defaultUserName,
                    userRole: l10n.branchManager,
                    onUserTap: () {},
                    actions: [
                      AppButton.primary(
                        onPressed: () => context.push(AppRoutes.productsAdd),
                        icon: Icons.add_rounded,
                        label: isDesktop ? l10n.addProduct : '',
                      ),
                    ],
                  ),
                  // Toolbar: Search + Sort + View Toggle
                  _buildToolbar(isDark, isDesktop, categoriesAsync, l10n: l10n),
                  // Content
                  Expanded(
                    child: Row(
                      children: [
                        // Filters Sidebar (Desktop only)
                        if (isDesktop && _showFilters)
                          _buildFiltersSidebar(
                            categoriesAsync,
                            isDark,
                            l10n: l10n,
                          ),
                        // Products Grid/List
                        Expanded(child: _buildProductsContent(productsState)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(
    bool isDark,
    bool isDesktop,
    AsyncValue<List<Category>> categoriesAsync, {
    required AppLocalizations l10n,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        children: [
          // Search Row + Tools
          Row(
            children: [
              // Search Field
              Expanded(
                child: AppSearchField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  hintText: '${l10n.searchByNameOrBarcode} (Ctrl+F)',
                  maxLength: 100,
                  onChanged: (v) {
                    final sanitized = InputSanitizer.sanitize(v);
                    if (sanitized != v) {
                      _searchController.text = sanitized;
                      _searchController.selection = TextSelection.fromPosition(
                        TextPosition(offset: sanitized.length),
                      );
                    }
                    _searchDebounce?.cancel();
                    _searchDebounce = Timer(
                      const Duration(milliseconds: 300),
                      () {
                        _onSearch(sanitized);
                      },
                    );
                  },
                  onClear: () {
                    _searchDebounce?.cancel();
                    _onSearch('');
                  },
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: AppSizes.sm),
                // Toggle Filters
                AppIconButton(
                  icon: _showFilters
                      ? Icons.filter_list_off
                      : Icons.filter_list,
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                  tooltip: _showFilters ? l10n.hideFilters : l10n.showFilters,
                ),
                const SizedBox(width: AppSizes.xs),
                // View Toggle
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ViewToggleButton(
                        icon: Icons.grid_view_rounded,
                        isSelected: _isGridView,
                        onTap: () => setState(() => _isGridView = true),
                      ),
                      _ViewToggleButton(
                        icon: Icons.view_list_rounded,
                        isSelected: !_isGridView,
                        onTap: () => setState(() => _isGridView = false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.xs),
                // Sort Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sort_rounded,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSizes.xs),
                      DropdownButton<String>(
                        value: _sortBy,
                        underline: const SizedBox(),
                        isDense: true,
                        dropdownColor: colorScheme.surface,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 14,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'name',
                            child: Text(l10n.sortByName),
                          ),
                          DropdownMenuItem(
                            value: 'price',
                            child: Text(l10n.sortByPrice),
                          ),
                          DropdownMenuItem(
                            value: 'stock',
                            child: Text(l10n.sortByStock),
                          ),
                          DropdownMenuItem(
                            value: 'recent',
                            child: Text(l10n.sortByRecent),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _sortBy = value);
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _sortAscending
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () =>
                            setState(() => _sortAscending = !_sortAscending),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.xs),
                // Refresh
                AppIconButton(
                  icon: Icons.refresh_rounded,
                  onPressed: _refreshProducts,
                  tooltip: '${l10n.retry} (F5)',
                ),
              ],
            ],
          ),
          // Mobile Categories (horizontal scroll)
          if (!isDesktop) ...[
            const SizedBox(height: AppSizes.sm),
            SizedBox(
              height: 36,
              child: categoriesAsync.when(
                data: (categories) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildCategoryChip(l10n.allItems, null, isDark);
                    }
                    final c = categories[index - 1];
                    return _buildCategoryChip(c.name, c.id, isDark);
                  },
                ),
                loading: () => const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (_, __) => const SizedBox(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFiltersSidebar(
    AsyncValue<List<Category>> categoriesAsync,
    bool isDark, {
    AppLocalizations? l10n,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: BorderDirectional(
          start: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories Section Header
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                Icon(
                  Icons.category_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSizes.xs),
                Text(
                  l10n?.categories ?? 'Categories',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          // Categories List (scrollable)
          Expanded(
            child: categoriesAsync.when(
              data: (categories) => ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildFilterOption(
                      l10n?.allItems ?? 'All',
                      Icons.apps_rounded,
                      _selectedCategoryId == null,
                      () => _onCategorySelected(null),
                      isDark: isDark,
                      count: null,
                    );
                  }
                  final c = categories[index - 1];
                  return _buildFilterOption(
                    c.name,
                    Icons.folder_rounded,
                    _selectedCategoryId == c.id,
                    () => _onCategorySelected(c.id),
                    isDark: isDark,
                    count: null,
                  );
                },
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSizes.md),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox(),
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          // Stock Filter Section
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSizes.xs),
                Text(
                  l10n?.stockStatus ?? 'Stock Status',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          _buildFilterOption(
            l10n?.allItems ?? 'All',
            Icons.all_inclusive_rounded,
            _stockFilter == 'all',
            () => setState(() => _stockFilter = 'all'),
            isDark: isDark,
          ),
          _buildFilterOption(
            l10n?.available ?? 'Available',
            Icons.check_circle_rounded,
            _stockFilter == 'available',
            () => setState(() => _stockFilter = 'available'),
            color: AppColors.stockAvailable,
            isDark: isDark,
          ),
          _buildFilterOption(
            l10n?.lowStock ?? 'Low Stock',
            Icons.warning_rounded,
            _stockFilter == 'low',
            () => setState(() => _stockFilter = 'low'),
            color: AppColors.stockLow,
            isDark: isDark,
          ),
          _buildFilterOption(
            l10n?.outOfStock ?? 'Out of Stock',
            Icons.error_rounded,
            _stockFilter == 'out',
            () => setState(() => _stockFilter = 'out'),
            color: AppColors.stockOut,
            isDark: isDark,
          ),
          // Clear Filters
          if (_selectedCategoryId != null || _stockFilter != 'all')
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: AppButton.ghost(
                onPressed: () {
                  setState(() {
                    _selectedCategoryId = null;
                    _stockFilter = 'all';
                  });
                  final storeId = ref.read(currentStoreIdProvider);
                  if (storeId != null) {
                    ref
                        .read(productsStateProvider.notifier)
                        .filterByCategory(null, storeId: storeId);
                  }
                },
                icon: Icons.clear_all_rounded,
                label: l10n?.clearFilters ?? 'Clear Filters',
                isFullWidth: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap, {
    Color? color,
    int? count,
    bool isDark = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? AppColors.primary
                    : (color ?? colorScheme.onSurfaceVariant),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : colorScheme.onSurface,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (count != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.xs,
                    vertical: AlhaiSpacing.xxxs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              if (isSelected)
                const Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsContent(ProductsState state) {
    if (state.isLoading && state.products.isEmpty) {
      return _buildLoadingState();
    }

    if (state.error != null && state.products.isEmpty) {
      return AppErrorState(message: state.error!, onRetry: _refreshProducts);
    }

    // Filter products by stock
    final filteredProducts = _filterProductsByStock(state.products);

    if (filteredProducts.isEmpty) {
      if (_searchController.text.isNotEmpty) {
        return AppEmptyState.noSearchResults(
          context,
          query: _searchController.text,
          onClear: () {
            _searchController.clear();
            _onSearch('');
          },
        );
      }
      return AppEmptyState.noProducts(
        context,
        onAdd: () => context.push(AppRoutes.productsAdd),
      );
    }

    // Sort products
    final sortedProducts = _sortProducts(filteredProducts);

    return RefreshIndicator(
      onRefresh: () async => _refreshProducts(),
      color: AppColors.primary,
      child: _isGridView
          ? _buildGridView(sortedProducts)
          : _buildListView(sortedProducts),
    );
  }

  Widget _buildLoadingState() {
    return ResponsivePadding(
      child: _isGridView
          ? const ShimmerGrid(
              crossAxisCount: 4,
              itemCount: 8,
              childAspectRatio: 0.75,
            )
          : const ShimmerList(itemCount: 8, itemHeight: 80),
    );
  }

  Widget _buildGridView(List<Product> products) {
    final productsState = ref.watch(productsStateProvider);
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final isMobileDevice = context.screenWidth < AppSizes.breakpointTablet;
    // In landscape on phones, use smaller maxCrossAxisExtent to fit more columns
    final maxExtent = (isLandscape && isMobileDevice) ? 160.0 : 220.0;
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSizes.md),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxExtent,
        childAspectRatio: 0.72,
        crossAxisSpacing: AppSizes.md,
        mainAxisSpacing: AppSizes.md,
      ),
      itemCount: products.length + (productsState.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= products.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.md),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final product = products[index];
        return _ProductGridCard(
          product: product,
          onTap: () => context.push(AppRoutes.productDetailPath(product.id)),
          onQuickEdit: () => _showQuickEditDialog(product),
        );
      },
    );
  }

  Widget _buildListView(List<Product> products) {
    final productsState = ref.watch(productsStateProvider);
    return AnimatedListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: products.length + (productsState.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= products.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.md),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final product = products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.sm),
          child: _ProductListCard(
            product: product,
            onTap: () => context.push(AppRoutes.productDetailPath(product.id)),
            onQuickEdit: () => _showQuickEditDialog(product),
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String label, String? categoryId, bool isDark) {
    final isSelected = _selectedCategoryId == categoryId;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: AppSizes.xs),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _onCategorySelected(categoryId),
        backgroundColor: colorScheme.surface,
        selectedColor: AppColors.primary.withValues(
          alpha: isDark ? 0.25 : 0.15,
        ),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : colorScheme.outlineVariant,
        ),
      ),
    );
  }

  List<Product> _filterProductsByStock(List<Product> products) {
    switch (_stockFilter) {
      case 'available':
        return products.where((p) => !p.isOutOfStock && !p.isLowStock).toList();
      case 'low':
        return products.where((p) => p.isLowStock && !p.isOutOfStock).toList();
      case 'out':
        return products.where((p) => p.isOutOfStock).toList();
      default:
        return products;
    }
  }

  List<Product> _sortProducts(List<Product> products) {
    final sorted = List<Product>.from(products);
    sorted.sort((a, b) {
      int result;
      switch (_sortBy) {
        case 'price':
          result = a.price.compareTo(b.price);
          break;
        case 'stock':
          result = a.stockQty.compareTo(b.stockQty);
          break;
        case 'recent':
          result = b.createdAt.compareTo(a.createdAt);
          break;
        default:
          result = a.name.compareTo(b.name);
      }
      return _sortAscending ? result : -result;
    });
    return sorted;
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    // Ctrl+F: Focus search
    if (event.logicalKey == LogicalKeyboardKey.keyF &&
        HardwareKeyboard.instance.isControlPressed) {
      _searchFocusNode.requestFocus();
      return;
    }

    // F5: Refresh
    if (event.logicalKey == LogicalKeyboardKey.f5) {
      _refreshProducts();
      return;
    }

    // Ctrl+N: New product
    if (event.logicalKey == LogicalKeyboardKey.keyN &&
        HardwareKeyboard.instance.isControlPressed) {
      context.push(AppRoutes.productsAdd);
      return;
    }

    // G/L: Toggle Grid/List view
    if (event.logicalKey == LogicalKeyboardKey.keyG) {
      setState(() => _isGridView = true);
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyL) {
      setState(() => _isGridView = false);
      return;
    }
  }

  void _onSearch(String query) {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId != null) {
      ref.read(productsStateProvider.notifier).search(query, storeId: storeId);
    }
  }

  void _onCategorySelected(String? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId != null) {
      ref
          .read(productsStateProvider.notifier)
          .filterByCategory(categoryId, storeId: storeId);
    }
  }

  void _refreshProducts() {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId != null) {
      ref
          .read(productsStateProvider.notifier)
          .loadProducts(storeId: storeId, refresh: true);
    }
  }

  void _showQuickEditDialog(Product product) {
    showDialog(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text('${l10n.edit}: ${product.name}'),
          content: Text(l10n.featureNotAvailableNow),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }
}

/// Toggle button for Grid/List view
class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: isSelected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.sm),
          child: Icon(
            icon,
            size: 20,
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Product Grid Card
class _ProductGridCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onQuickEdit;

  const _ProductGridCard({
    required this.product,
    required this.onTap,
    required this.onQuickEdit,
  });

  @override
  State<_ProductGridCard> createState() => _ProductGridCardState();
}

class _ProductGridCardState extends State<_ProductGridCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AlhaiDurations.standard,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: _isHovered ? AppColors.primary : colorScheme.outlineVariant,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Hero(
                      tag: 'product-image-${widget.product.id}',
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppSizes.radiusLg),
                          ),
                        ),
                        child: widget.product.imageThumbnail != null
                            ? ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(AppSizes.radiusLg),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: widget.product.imageThumbnail!,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 200,
                                  memCacheHeight: 200,
                                  placeholder: (_, __) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (_, __, ___) =>
                                      _buildPlaceholder(),
                                ),
                              )
                            : _buildPlaceholder(),
                      ),
                    ),
                    // Stock Badge
                    PositionedDirectional(
                      top: AppSizes.xs,
                      end: AppSizes.xs,
                      child: _buildStockBadge(),
                    ),
                    // Quick Edit Button (on hover)
                    if (_isHovered)
                      PositionedDirectional(
                        top: AppSizes.xs,
                        start: AppSizes.xs,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusSm,
                            ),
                            boxShadow: AppShadows.of(
                              context,
                              size: ShadowSize.sm,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.edit_rounded,
                              size: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onPressed: widget.onQuickEdit,
                            padding: const EdgeInsets.all(AppSizes.xs),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Product Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Flexible(
                        child: Hero(
                          tag: 'product-name-${widget.product.id}',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Text(
                              widget.product.name,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.xxs),
                      // Barcode
                      if (widget.product.barcode != null)
                        Text(
                          widget.product.barcode!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const Spacer(),
                      // Price
                      Text(
                        CurrencyFormatter.formatWithContext(
                          context,
                          widget.product.price / 100.0,
                        ),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.image_rounded,
        size: 48,
        color: Theme.of(
          context,
        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildStockBadge() {
    if (widget.product.isOutOfStock) {
      return AppBadge.stock(context, 0);
    }
    if (widget.product.isLowStock) {
      return AppBadge.stock(
        context,
        widget.product.stockQty,
        minQuantity: widget.product.minQty,
      );
    }
    return const SizedBox.shrink();
  }
}

/// Product List Card
class _ProductListCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onQuickEdit;

  const _ProductListCard({
    required this.product,
    required this.onTap,
    required this.onQuickEdit,
  });

  @override
  State<_ProductListCard> createState() => _ProductListCardState();
}

class _ProductListCardState extends State<_ProductListCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AlhaiDurations.standard,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: _isHovered ? AppColors.primary : colorScheme.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.1 : 0.04),
              blurRadius: _isHovered ? 12 : 4,
              offset: Offset(0, _isHovered ? 4 : 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.sm),
            child: Row(
              children: [
                // Product Image
                Hero(
                  tag: 'product-image-${widget.product.id}',
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: widget.product.imageThumbnail != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                            child: CachedNetworkImage(
                              imageUrl: widget.product.imageThumbnail!,
                              fit: BoxFit.cover,
                              memCacheWidth: 128,
                              memCacheHeight: 128,
                              placeholder: (_, __) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (_, __, ___) => _buildPlaceholder(),
                            ),
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Hero(
                              tag: 'product-name-${widget.product.id}',
                              child: Material(
                                type: MaterialType.transparency,
                                child: Text(
                                  widget.product.name,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          _buildStockBadge(),
                        ],
                      ),
                      const SizedBox(height: AppSizes.xxs),
                      Text(
                        widget.product.barcode ??
                            AppLocalizations.of(context).noBarcode,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Row(
                        children: [
                          Text(
                            CurrencyFormatter.formatWithContext(
                              context,
                              widget.product.price / 100.0,
                            ),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            AppLocalizations.of(
                              context,
                            ).stockCount(widget.product.stockQty.toInt()),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                // Actions
                if (_isHovered)
                  IconButton(
                    icon: Icon(
                      Icons.edit_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: widget.onQuickEdit,
                  ),
                Icon(
                  Icons.chevron_left_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.image_rounded,
        size: 24,
        color: Theme.of(
          context,
        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildStockBadge() {
    if (widget.product.isOutOfStock) {
      return AppBadge.stock(context, 0);
    }
    if (widget.product.isLowStock) {
      return AppBadge.stock(
        context,
        widget.product.stockQty,
        minQuantity: widget.product.minQty,
      );
    }
    return AppBadge.stock(
      context,
      widget.product.stockQty,
      minQuantity: widget.product.minQty,
    );
  }
}
