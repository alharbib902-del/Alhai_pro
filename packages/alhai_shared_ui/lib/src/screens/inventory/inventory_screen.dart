import '../../widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/validators/input_sanitizer.dart';
import '../../providers/products_providers.dart';
import '../../widgets/common/common.dart';

/// شاشة المخزون - تصميم Web محسّن مع عرض وتعديل كميات المخزون
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _keyboardFocusNode = FocusNode();

  String _filterType = 'all'; // all, low, out, available
  String _sortBy = 'name'; // name, stock, recent
  bool _sortAscending = true;
  bool _showFilters = true;
  final Set<String> _selectedIds = {};
  final _scrollController = ScrollController();
  bool _showScrollToTop = false;

  // Cached computation results
  List<dynamic>? _cachedFilteredProducts;
  String? _lastInventoryFilter;
  String? _lastInventorySort;
  bool? _lastInventorySortAsc;
  String? _lastInventorySearch;
  int? _lastProductsLength;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final show = _scrollController.offset > 300;
      if (show != _showScrollToTop) setState(() => _showScrollToTop = show);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _keyboardFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsStateProvider);
    final products = productsState.products;
    final isDesktop = context.screenWidth >= AppSizes.breakpointTablet;
    final l10n = AppLocalizations.of(context)!;

    // Calculate stats once per build
    final totalProducts = products.length;
    int lowStockCount = 0;
    int outOfStockCount = 0;
    double totalValue = 0;
    for (final p in products) {
      if (p.isOutOfStock) {
        outOfStockCount++;
      } else if (p.isLowStock) {
        lowStockCount++;
      }
      totalValue += p.stockQty * p.price;
    }

    // Compute filtered list once and pass down
    final filteredProducts = _getFilteredProducts(products);

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        floatingActionButton: _showScrollToTop
            ? FloatingActionButton.small(
                onPressed: () => _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                ),
                child: const Icon(Icons.arrow_upward),
              )
            : null,
        body: Column(
          children: [
            // Header
            _buildHeader(context, products, l10n),
            // Stats Cards
            _buildStatsRow(totalProducts, lowStockCount, outOfStockCount, totalValue, l10n),
            // Content
            Expanded(
              child: Row(
                children: [
                  // Filters Sidebar (Desktop only)
                  if (isDesktop && _showFilters)
                    _buildFiltersSidebar(totalProducts, lowStockCount, outOfStockCount, l10n),
                  // Inventory List
                  Expanded(
                    child: _buildInventoryContent(productsState, filteredProducts, l10n),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<dynamic> products, AppLocalizations l10n) {
    final isDesktop = context.screenWidth >= AppSizes.breakpointTablet;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        children: [
          // Title Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSizes.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          child: const Icon(
                            Icons.inventory_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Text(
                          l10n.inventory,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        AppCountBadge(
                          count: products.length,
                          backgroundColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      l10n.inventoryManagement,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              if (isDesktop) ...[
                AppIconButton(
                  icon: _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                  tooltip: _showFilters ? l10n.hideFilters : l10n.showFilters,
                ),
                const SizedBox(width: AppSizes.xs),
                AppIconButton(
                  icon: Icons.refresh_rounded,
                  onPressed: () {
                    final storeId = ref.read(currentStoreIdProvider);
                    if (storeId != null) {
                      ref.read(productsStateProvider.notifier).loadProducts(
                        storeId: storeId,
                        refresh: true,
                      );
                    }
                  },
                  tooltip: l10n.refresh,
                ),
                const SizedBox(width: AppSizes.sm),
              ],
              AppButton.secondary(
                onPressed: () => _showBulkAdjustDialog(l10n),
                icon: Icons.tune_rounded,
                label: isDesktop ? l10n.bulkEdit : '',
              ),
              const SizedBox(width: AppSizes.sm),
              AppButton.primary(
                onPressed: () => _showInventoryCountDialog(l10n),
                icon: Icons.calculate_rounded,
                label: isDesktop ? l10n.stockTake : '',
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          // Search Row
          Row(
            children: [
              Expanded(
                child: AppSearchField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  hintText: l10n.searchByNameOrBarcode,
                  maxLength: 100,
                  onChanged: (v) {
                    final sanitized = InputSanitizer.sanitize(v);
                    if (sanitized != v) {
                      _searchController.text = sanitized;
                      _searchController.selection = TextSelection.fromPosition(
                        TextPosition(offset: sanitized.length),
                      );
                    }
                    setState(() {});
                  },
                  onClear: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: AppSizes.md),
                // Sort Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sort_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: AppSizes.xs),
                      DropdownButton<String>(
                        value: _sortBy,
                        underline: const SizedBox(),
                        isDense: true,
                        items: [
                          DropdownMenuItem(value: 'name', child: Text(l10n.productName)),
                          DropdownMenuItem(value: 'stock', child: Text(l10n.quantity)),
                          DropdownMenuItem(value: 'recent', child: Text(l10n.newest)),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _sortBy = value);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _sortAscending
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 18,
                        ),
                        onPressed: () => setState(() => _sortAscending = !_sortAscending),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          // Mobile Filter Chips
          if (!isDesktop) ...[
            const SizedBox(height: AppSizes.sm),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip(l10n.all, 'all', null),
                  _buildFilterChip(l10n.lowStock, 'low', AppColors.stockLow),
                  _buildFilterChip(l10n.outOfStock, 'out', AppColors.stockOut),
                  _buildFilterChip(l10n.available, 'available', AppColors.stockAvailable),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow(int total, int lowStock, int outOfStock, double totalValue, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.inventory_2_rounded,
              label: l10n.totalProducts,
              value: '$total',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: _StatCard(
              icon: Icons.warning_amber_rounded,
              label: l10n.lowStock,
              value: '$lowStock',
              color: AppColors.stockLow,
              isAlert: lowStock > 0,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: _StatCard(
              icon: Icons.error_outline_rounded,
              label: l10n.outOfStock,
              value: '$outOfStock',
              color: AppColors.stockOut,
              isAlert: outOfStock > 0,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: _StatCard(
              icon: Icons.attach_money_rounded,
              label: l10n.inventoryValue,
              value: '${totalValue.toStringAsFixed(0)} ${l10n.sar}',
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSidebar(int total, int lowStock, int outOfStock, AppLocalizations l10n) {
    final availableCount = total - lowStock - outOfStock;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(left: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                const Icon(Icons.filter_alt_rounded, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppSizes.xs),
                Text(
                  l10n.stockStatus,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildFilterOption(
            l10n.all,
            Icons.inventory_2_rounded,
            _filterType == 'all',
            () => setState(() => _filterType = 'all'),
            count: total,
          ),
          _buildFilterOption(
            l10n.available,
            Icons.check_circle_rounded,
            _filterType == 'available',
            () => setState(() => _filterType = 'available'),
            color: AppColors.stockAvailable,
            count: availableCount,
          ),
          _buildFilterOption(
            l10n.lowStock,
            Icons.warning_rounded,
            _filterType == 'low',
            () => setState(() => _filterType = 'low'),
            color: AppColors.stockLow,
            count: lowStock,
          ),
          _buildFilterOption(
            l10n.outOfStock,
            Icons.error_rounded,
            _filterType == 'out',
            () => setState(() => _filterType = 'out'),
            color: AppColors.stockOut,
            count: outOfStock,
          ),
          const Divider(height: 1),
          // Quick Actions
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                const Icon(Icons.flash_on_rounded, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppSizes.xs),
                Text(
                  l10n.quickActions,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildQuickAction(
            l10n.exportInventoryReport,
            Icons.download_rounded,
            AppColors.primary,
            () {},
          ),
          _buildQuickAction(
            l10n.printOrderList,
            Icons.print_rounded,
            AppColors.textSecondary,
            () {},
          ),
          _buildQuickAction(
            l10n.inventoryMovementLog,
            Icons.history_rounded,
            AppColors.textSecondary,
            () {},
          ),
          const Spacer(),
          // Clear Selection
          if (_selectedIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                children: [
                  AppButton.primary(
                    onPressed: () => _showBulkAdjustDialog(l10n),
                    icon: Icons.tune_rounded,
                    label: '${l10n.editSelected} (${_selectedIds.length})',
                    isFullWidth: true,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  AppButton.ghost(
                    onPressed: () => setState(() => _selectedIds.clear()),
                    icon: Icons.clear_all_rounded,
                    label: l10n.clearSelection,
                    isFullWidth: true,
                  ),
                ],
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
  }) {
    return Material(
      color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
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
                color: isSelected ? AppColors.primary : (color ?? AppColors.textSecondary),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (count != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (isSelected)
                const Padding(
                  padding: EdgeInsetsDirectional.only(end: AppSizes.xs),
                  child: Icon(Icons.check_rounded, size: 18, color: AppColors.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              ),
              const AdaptiveIcon(Icons.chevron_left_rounded, size: 18, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, Color? color) {
    final isSelected = _filterType == value;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: AppSizes.xs),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _filterType = value),
        backgroundColor: colorScheme.surface,
        selectedColor: (color ?? AppColors.primary).withValues(alpha: 0.15),
        checkmarkColor: color ?? AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? (color ?? AppColors.primary) : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(color: isSelected ? (color ?? AppColors.primary) : Theme.of(context).dividerColor),
      ),
    );
  }

  List<dynamic> _getFilteredProducts(List<dynamic> products) {
    final currentSearch = _searchController.text.toLowerCase();
    if (_cachedFilteredProducts != null &&
        _lastInventoryFilter == _filterType &&
        _lastInventorySort == _sortBy &&
        _lastInventorySortAsc == _sortAscending &&
        _lastInventorySearch == currentSearch &&
        _lastProductsLength == products.length) {
      return _cachedFilteredProducts!;
    }

    var result = List<dynamic>.of(products);

    // Apply stock filter
    switch (_filterType) {
      case 'low':
        result = result.where((p) => p.isLowStock && !p.isOutOfStock).toList();
        break;
      case 'out':
        result = result.where((p) => p.isOutOfStock).toList();
        break;
      case 'available':
        result = result.where((p) => !p.isLowStock && !p.isOutOfStock).toList();
        break;
    }

    // Apply search
    if (currentSearch.isNotEmpty) {
      result = result.where((p) =>
        p.name.toLowerCase().contains(currentSearch) ||
        (p.barcode?.toLowerCase().contains(currentSearch) ?? false)
      ).toList();
    }

    // Apply sort
    result.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'stock':
          comparison = a.stockQty.compareTo(b.stockQty);
          break;
        case 'recent':
          comparison = 0; // Would need createdAt field
          break;
        default:
          comparison = a.name.compareTo(b.name);
      }
      return _sortAscending ? comparison : -comparison;
    });

    _cachedFilteredProducts = result;
    _lastInventoryFilter = _filterType;
    _lastInventorySort = _sortBy;
    _lastInventorySortAsc = _sortAscending;
    _lastInventorySearch = currentSearch;
    _lastProductsLength = products.length;

    return result;
  }

  Widget _buildInventoryContent(ProductsState state, List<dynamic> filtered, AppLocalizations l10n) {
    // Loading state
    if (state.isLoading && state.products.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: 8,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: AppSizes.sm),
          child: ListItemSkeleton(),
        ),
      );
    }

    // Error state
    if (state.error != null && state.products.isEmpty) {
      return AppErrorState(
        message: state.error!,
        onRetry: () {
          final storeId = ref.read(currentStoreIdProvider);
          if (storeId != null) {
            ref.read(productsStateProvider.notifier).loadProducts(
              storeId: storeId,
              refresh: true,
            );
          }
        },
      );
    }

    // Empty states
    if (filtered.isEmpty) {
      if (_searchController.text.isNotEmpty) {
        return AppEmptyState.noSearchResults(
          query: _searchController.text,
          onClear: () {
            _searchController.clear();
            setState(() {});
          },
        );
      }
      if (_filterType == 'low') {
        return AppEmptyState.noLowStock();
      }
      if (_filterType == 'out') {
        return AppEmptyState.noData(
          title: l10n.noOutOfStockProducts,
          description: l10n.allProductsAvailable,
        );
      }
      return AppEmptyState.noProducts(
        onAdd: () => _showInventoryCountDialog(l10n),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final storeId = ref.read(currentStoreIdProvider);
        if (storeId != null) {
          ref.read(productsStateProvider.notifier).loadProducts(
            storeId: storeId,
            refresh: true,
          );
        }
      },
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final product = filtered[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: _InventoryCard(
              product: product,
              isSelected: _selectedIds.contains(product.id),
              onTap: () => _showAdjustDialog(product.id, product.name, product.stockQty, l10n),
              onSelect: (selected) {
                setState(() {
                  if (selected) {
                    _selectedIds.add(product.id);
                  } else {
                    _selectedIds.remove(product.id);
                  }
                });
              },
            ),
          );
        },
      ),
    );
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
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId != null) {
        ref.read(productsStateProvider.notifier).loadProducts(
          storeId: storeId,
          refresh: true,
        );
      }
      return;
    }

    // Escape: Clear selection
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      setState(() => _selectedIds.clear());
      return;
    }
  }

  void _showAdjustDialog(String productId, String productName, int currentQty, AppLocalizations l10n) {
    final controller = TextEditingController(text: currentQty.toString());
    String reason = 'count';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: const Icon(Icons.edit_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.editStock),
                  Text(
                    productName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current Stock Display
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${l10n.currentQuantity}: ',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    Text(
                      '$currentQty',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: currentQty > 10
                            ? AppColors.stockAvailable
                            : currentQty > 0
                                ? AppColors.stockLow
                                : AppColors.stockOut,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              // New Quantity Input
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: l10n.newQuantity,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.remove_rounded),
                    onPressed: () {
                      final current = int.tryParse(controller.text) ?? 0;
                      if (current > 0) {
                        controller.text = (current - 1).toString();
                      }
                    },
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_rounded),
                    onPressed: () {
                      final current = int.tryParse(controller.text) ?? 0;
                      controller.text = (current + 1).toString();
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              // Quick Adjust Buttons
              Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                alignment: WrapAlignment.center,
                children: [-10, -5, -1, 1, 5, 10].map((delta) {
                  final isPositive = delta > 0;
                  return ActionChip(
                    label: Text(isPositive ? '+$delta' : '$delta'),
                    onPressed: () {
                      final current = int.tryParse(controller.text) ?? 0;
                      final newValue = (current + delta).clamp(0, 99999);
                      controller.text = newValue.toString();
                    },
                    backgroundColor: isPositive
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: isPositive ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.lg),
              // Reason Dropdown
              DropdownButtonFormField<String>(
                initialValue: reason,
                decoration: InputDecoration(
                  labelText: l10n.adjustmentReason,
                  prefixIcon: const Icon(Icons.note_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: 'count', child: Text(l10n.stockTake)),
                  DropdownMenuItem(value: 'receive', child: Text(l10n.receiveGoods)),
                  DropdownMenuItem(value: 'damage', child: Text(l10n.damaged)),
                  DropdownMenuItem(value: 'return', child: Text(l10n.returned)),
                  DropdownMenuItem(value: 'correction', child: Text(l10n.correction)),
                  DropdownMenuItem(value: 'other', child: Text(l10n.other)),
                ],
                onChanged: (v) => reason = v ?? 'count',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          AppButton.primary(
            onPressed: () async {
              final newQty = int.tryParse(controller.text);
              if (newQty == null || newQty < 0) return;

              // TODO: Update stock via InventoryDao
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.white),
                      const SizedBox(width: AppSizes.sm),
                      Text('${l10n.stockUpdatedTo} $productName: $newQty'),
                    ],
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
              );
            },
            label: l10n.save,
            icon: Icons.save_rounded,
          ),
        ],
      ),
    ).then((_) {
      controller.dispose();
    });
  }

  void _showBulkAdjustDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: const Icon(Icons.tune_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: AppSizes.sm),
            Text(l10n.bulkEdit),
          ],
        ),
        content: Text(l10n.featureUnderDevelopment),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showInventoryCountDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: const Icon(Icons.calculate_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: AppSizes.sm),
            Text(l10n.stockTake),
          ],
        ),
        content: Text(l10n.featureUnderDevelopment),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}

/// Stats Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isAlert;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: isAlert ? color.withValues(alpha: 0.5) : Theme.of(context).dividerColor,
          width: isAlert ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          if (isAlert)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.priority_high_rounded, size: 12, color: colorScheme.surface),
            ),
        ],
      ),
    );
  }
}

/// Inventory Card Widget
class _InventoryCard extends StatefulWidget {
  final dynamic product;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<bool> onSelect;

  const _InventoryCard({
    required this.product,
    required this.isSelected,
    required this.onTap,
    required this.onSelect,
  });

  @override
  State<_InventoryCard> createState() => _InventoryCardState();
}

class _InventoryCardState extends State<_InventoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isLowStock = widget.product.isLowStock;
    final isOutOfStock = widget.product.isOutOfStock;
    final stockColor = isOutOfStock
        ? AppColors.stockOut
        : isLowStock
            ? AppColors.stockLow
            : AppColors.stockAvailable;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AlhaiDurations.standard,
        decoration: BoxDecoration(
          color: widget.isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: widget.isSelected
                ? AppColors.primary
                : _isHovered
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : isOutOfStock || isLowStock
                        ? stockColor.withValues(alpha: 0.3)
                        : Theme.of(context).dividerColor,
            width: widget.isSelected ? 2 : 1,
          ),
          boxShadow: _isHovered ? AppSizes.shadowMd : AppSizes.shadowSm,
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                // Checkbox
                Checkbox(
                  value: widget.isSelected,
                  onChanged: (value) => widget.onSelect(value ?? false),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Stock Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: stockColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(
                    isOutOfStock
                        ? Icons.error_rounded
                        : isLowStock
                            ? Icons.warning_rounded
                            : Icons.check_circle_rounded,
                    color: stockColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xxs),
                      Row(
                        children: [
                          const Icon(
                            Icons.qr_code_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSizes.xxs),
                          Text(
                            widget.product.barcode ?? l10n.noBarcode,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Stock Quantity
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.product.stockQty}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: stockColor,
                      ),
                    ),
                    AppBadge(
                      label: isOutOfStock
                          ? l10n.outOfStock
                          : isLowStock
                              ? l10n.lowStock
                              : l10n.available,
                      color: stockColor,
                      variant: AppBadgeVariant.soft,
                    ),
                  ],
                ),
                const SizedBox(width: AppSizes.sm),
                // Edit Button
                if (_isHovered)
                  AppIconButton(
                    icon: Icons.edit_rounded,
                    onPressed: widget.onTap,
                    tooltip: l10n.edit,
                  ),
                const AdaptiveIcon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
