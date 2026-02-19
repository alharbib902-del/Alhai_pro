import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_core/alhai_core.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/validators/input_sanitizer.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/products_providers.dart';
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
  String? _selectedCategoryId;
  String _stockFilter = 'all'; // all, available, low, out
  bool _isGridView = true;
  String _sortBy = 'name'; // name, price, stock, recent
  bool _sortAscending = true;
  bool _showFilters = true;


  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId != null) {
        ref.read(productsStateProvider.notifier).loadProducts(storeId: storeId, refresh: true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsStateProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isDesktop = size.width >= AppSizes.breakpointTablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
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
                    subtitle: '${productsState.products.length} ${l10n.product}',
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
                          _buildFiltersSidebar(categoriesAsync, isDark, l10n: l10n),
                        // Products Grid/List
                        Expanded(
                          child: _buildProductsContent(productsState),
                        ),
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

  Widget _buildToolbar(bool isDark, bool isDesktop, AsyncValue<List<Category>> categoriesAsync, {required AppLocalizations l10n}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
          ),
        ),
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
                    _onSearch(sanitized);
                  },
                  onClear: () => _onSearch(''),
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: AppSizes.sm),
                // Toggle Filters
                AppIconButton(
                  icon: _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                  tooltip: _showFilters ? l10n.hideFilters : l10n.showFilters,
                ),
                const SizedBox(width: AppSizes.xs),
                // View Toggle
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ViewToggleButton(
                        icon: Icons.grid_view_rounded,
                        isSelected: _isGridView,
                        onTap: () => setState(() => _isGridView = true),
                        isDark: isDark,
                      ),
                      _ViewToggleButton(
                        icon: Icons.view_list_rounded,
                        isSelected: !_isGridView,
                        onTap: () => setState(() => _isGridView = false),
                        isDark: isDark,
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
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sort_rounded,
                        size: 18,
                        color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSizes.xs),
                      DropdownButton<String>(
                        value: _sortBy,
                        underline: const SizedBox(),
                        isDense: true,
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        items: [
                          DropdownMenuItem(value: 'name', child: Text(l10n.sortByName)),
                          DropdownMenuItem(value: 'price', child: Text(l10n.sortByPrice)),
                          DropdownMenuItem(value: 'stock', child: Text(l10n.sortByStock)),
                          DropdownMenuItem(value: 'recent', child: Text(l10n.sortByRecent)),
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
                          color: isDark ? Colors.white.withValues(alpha: 0.7) : null,
                        ),
                        onPressed: () => setState(() => _sortAscending = !_sortAscending),
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
                data: (categories) => ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip(l10n.allItems, null, isDark),
                    ...categories.map((c) => _buildCategoryChip(c.name, c.id, isDark)),
                  ],
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

  Widget _buildFiltersSidebar(AsyncValue<List<Category>> categoriesAsync, bool isDark, {AppLocalizations? l10n}) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: BorderDirectional(
          start: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
          ),
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
                  color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSizes.xs),
                Text(
                  l10n?.categories ?? 'Categories',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : null,
                  ),
                ),
              ],
            ),
          ),
          // Categories List (scrollable)
          Expanded(
            child: categoriesAsync.when(
              data: (categories) => ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildFilterOption(
                    l10n?.allItems ?? 'All',
                    Icons.apps_rounded,
                    _selectedCategoryId == null,
                    () => _onCategorySelected(null),
                    isDark: isDark,
                    count: null,
                  ),
                  ...categories.map((c) => _buildFilterOption(
                    c.name,
                    Icons.folder_rounded,
                    _selectedCategoryId == c.id,
                    () => _onCategorySelected(c.id),
                    isDark: isDark,
                    count: null,
                  )),
                ],
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSizes.md),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox(),
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.1) : null,
          ),
          // Stock Filter Section
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_rounded,
                  size: 18,
                  color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSizes.xs),
                Text(
                  l10n?.stockStatus ?? 'Stock Status',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : null,
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
                    ref.read(productsStateProvider.notifier).filterByCategory(null, storeId: storeId);
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
                    : (color ?? (isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary)),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.textPrimary),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (count != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
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
      return AppErrorState(
        message: state.error!,
        onRetry: _refreshProducts,
      );
    }

    // Filter products by stock
    final filteredProducts = _filterProductsByStock(state.products);

    if (filteredProducts.isEmpty) {
      if (_searchController.text.isNotEmpty) {
        return AppEmptyState.noSearchResults(
          query: _searchController.text,
          onClear: () {
            _searchController.clear();
            _onSearch('');
          },
        );
      }
      return AppEmptyState.noProducts(
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
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: _isGridView
          ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                childAspectRatio: 0.75,
                crossAxisSpacing: AppSizes.md,
                mainAxisSpacing: AppSizes.md,
              ),
              itemCount: 8,
              itemBuilder: (_, __) => const ProductCardSkeleton(),
            )
          : ListView.builder(
              itemCount: 8,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(bottom: AppSizes.sm),
                child: ListItemSkeleton(),
              ),
            ),
    );
  }

  Widget _buildGridView(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        childAspectRatio: 0.72,
        crossAxisSpacing: AppSizes.md,
        mainAxisSpacing: AppSizes.md,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
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
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: products.length,
      itemBuilder: (context, index) {
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
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: AppSizes.xs),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _onCategorySelected(categoryId),
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedColor: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.15),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected
              ? AppColors.primary
              : (isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.textPrimary),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
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
      ref.read(productsStateProvider.notifier).filterByCategory(categoryId, storeId: storeId);
    }
  }

  void _refreshProducts() {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId != null) {
      ref.read(productsStateProvider.notifier).loadProducts(storeId: storeId, refresh: true);
    }
  }

  void _showQuickEditDialog(Product product) {
    // TODO: Implement quick edit dialog
    showDialog(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text('${l10n.edit}: ${product.name}'),
          content: Text(l10n.comingSoon),
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
  final bool isDark;

  const _ViewToggleButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
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
                ? Colors.white
                : (isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: _isHovered
                ? AppColors.primary
                : (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
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
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppSizes.radiusLg),
                        ),
                      ),
                      child: widget.product.imageThumbnail != null
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppSizes.radiusLg),
                              ),
                              child: Image.network(
                                widget.product.imageThumbnail!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildPlaceholder(isDark),
                              ),
                            )
                          : _buildPlaceholder(isDark),
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
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.edit_rounded,
                              size: 18,
                              color: isDark ? Colors.white.withValues(alpha: 0.7) : null,
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
                      Text(
                        widget.product.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSizes.xxs),
                      // Barcode
                      if (widget.product.barcode != null)
                        Text(
                          widget.product.barcode!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const Spacer(),
                      // Price
                      Text(
                        '${widget.product.price.toStringAsFixed(2)} ${AppLocalizations.of(context)!.sar}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

  Widget _buildPlaceholder(bool isDark) {
    return Center(
      child: Icon(
        Icons.image_rounded,
        size: 48,
        color: isDark
            ? Colors.white.withValues(alpha: 0.15)
            : AppColors.textSecondary.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildStockBadge() {
    if (widget.product.isOutOfStock) {
      return AppBadge.stock(context, 0);
    }
    if (widget.product.isLowStock) {
      return AppBadge.stock(context, widget.product.stockQty, minQuantity: widget.product.minQty);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: _isHovered
                ? AppColors.primary
                : (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? (_isHovered ? 0.3 : 0.2) : (_isHovered ? 0.1 : 0.04)),
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
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: widget.product.imageThumbnail != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          child: Image.network(
                            widget.product.imageThumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(isDark),
                          ),
                        )
                      : _buildPlaceholder(isDark),
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
                            child: Text(
                              widget.product.name,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStockBadge(),
                        ],
                      ),
                      const SizedBox(height: AppSizes.xxs),
                      Text(
                        widget.product.barcode ?? AppLocalizations.of(context)!.noBarcode,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Row(
                        children: [
                          Text(
                            '${widget.product.price.toStringAsFixed(2)} ${AppLocalizations.of(context)!.sar}',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            AppLocalizations.of(context)!.stockCount(widget.product.stockQty),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textSecondary,
                            ),
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
                      color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
                    ),
                    onPressed: widget.onQuickEdit,
                  ),
                Icon(
                  Icons.chevron_left_rounded,
                  color: isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Center(
      child: Icon(
        Icons.image_rounded,
        size: 24,
        color: isDark
            ? Colors.white.withValues(alpha: 0.15)
            : AppColors.textSecondary.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildStockBadge() {
    if (widget.product.isOutOfStock) {
      return AppBadge.stock(context, 0);
    }
    if (widget.product.isLowStock) {
      return AppBadge.stock(context, widget.product.stockQty, minQuantity: widget.product.minQty);
    }
    return AppBadge.stock(context, widget.product.stockQty, minQuantity: widget.product.minQty);
  }
}
