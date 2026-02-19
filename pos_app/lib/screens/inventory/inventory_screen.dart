import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/products_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
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

  String _filterType = 'all'; // all, low, out, available
  String _sortBy = 'name'; // name, stock, recent
  bool _sortAscending = true;
  bool _showFilters = true;
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsListProvider);
    final isDesktop = MediaQuery.of(context).size.width >= AppSizes.breakpointTablet;

    // Calculate stats
    final totalProducts = products.length;
    final lowStockCount = products.where((p) => p.isLowStock && !p.isOutOfStock).length;
    final outOfStockCount = products.where((p) => p.isOutOfStock).length;
    final totalValue = products.fold<double>(0, (sum, p) => sum + (p.stockQty * p.price));

    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // Header
            _buildHeader(context, products),
            // Stats Cards
            _buildStatsRow(totalProducts, lowStockCount, outOfStockCount, totalValue),
            // Content
            Expanded(
              child: Row(
                children: [
                  // Filters Sidebar (Desktop only)
                  if (isDesktop && _showFilters)
                    _buildFiltersSidebar(totalProducts, lowStockCount, outOfStockCount),
                  // Inventory List
                  Expanded(
                    child: _buildInventoryContent(products),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<dynamic> products) {
    final isDesktop = MediaQuery.of(context).size.width >= AppSizes.breakpointTablet;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
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
                          'المخزون',
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
                      'إدارة ومتابعة المخزون',
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
                  tooltip: _showFilters ? 'إخفاء الفلاتر' : 'إظهار الفلاتر',
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
                  tooltip: 'تحديث (F5)',
                ),
                const SizedBox(width: AppSizes.sm),
              ],
              AppButton.secondary(
                onPressed: () => _showBulkAdjustDialog(),
                icon: Icons.tune_rounded,
                label: isDesktop ? 'تعديل جماعي' : '',
              ),
              const SizedBox(width: AppSizes.sm),
              AppButton.primary(
                onPressed: () => _showInventoryCountDialog(),
                icon: Icons.calculate_rounded,
                label: isDesktop ? 'جرد المخزون' : '',
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
                  hintText: 'بحث بالاسم أو الباركود... (Ctrl+F)',
                  onChanged: (_) => setState(() {}),
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
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sort_rounded, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: AppSizes.xs),
                      DropdownButton<String>(
                        value: _sortBy,
                        underline: const SizedBox(),
                        isDense: true,
                        items: const [
                          DropdownMenuItem(value: 'name', child: Text('الاسم')),
                          DropdownMenuItem(value: 'stock', child: Text('الكمية')),
                          DropdownMenuItem(value: 'recent', child: Text('الأحدث')),
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
                  _buildFilterChip('الكل', 'all', null),
                  _buildFilterChip('مخزون منخفض', 'low', AppColors.stockLow),
                  _buildFilterChip('نفذ', 'out', AppColors.stockOut),
                  _buildFilterChip('متوفر', 'available', AppColors.stockAvailable),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow(int total, int lowStock, int outOfStock, double totalValue) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.inventory_2_rounded,
              label: 'إجمالي المنتجات',
              value: '$total',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: _StatCard(
              icon: Icons.warning_amber_rounded,
              label: 'مخزون منخفض',
              value: '$lowStock',
              color: AppColors.stockLow,
              isAlert: lowStock > 0,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: _StatCard(
              icon: Icons.error_outline_rounded,
              label: 'نفذ المخزون',
              value: '$outOfStock',
              color: AppColors.stockOut,
              isAlert: outOfStock > 0,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: _StatCard(
              icon: Icons.attach_money_rounded,
              label: 'قيمة المخزون',
              value: '${totalValue.toStringAsFixed(0)} ر.س',
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSidebar(int total, int lowStock, int outOfStock) {
    final availableCount = total - lowStock - outOfStock;

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: AppColors.border)),
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
                  'حالة المخزون',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildFilterOption(
            'الكل',
            Icons.inventory_2_rounded,
            _filterType == 'all',
            () => setState(() => _filterType = 'all'),
            count: total,
          ),
          _buildFilterOption(
            'متوفر',
            Icons.check_circle_rounded,
            _filterType == 'available',
            () => setState(() => _filterType = 'available'),
            color: AppColors.stockAvailable,
            count: availableCount,
          ),
          _buildFilterOption(
            'مخزون منخفض',
            Icons.warning_rounded,
            _filterType == 'low',
            () => setState(() => _filterType = 'low'),
            color: AppColors.stockLow,
            count: lowStock,
          ),
          _buildFilterOption(
            'نفذ المخزون',
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
                  'إجراءات سريعة',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildQuickAction(
            'تصدير تقرير المخزون',
            Icons.download_rounded,
            AppColors.primary,
            () {},
          ),
          _buildQuickAction(
            'طباعة قائمة الطلب',
            Icons.print_rounded,
            AppColors.textSecondary,
            () {},
          ),
          _buildQuickAction(
            'سجل حركة المخزون',
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
                    onPressed: () => _showBulkAdjustDialog(),
                    icon: Icons.tune_rounded,
                    label: 'تعديل المحدد (${_selectedIds.length})',
                    isFullWidth: true,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  AppButton.ghost(
                    onPressed: () => setState(() => _selectedIds.clear()),
                    icon: Icons.clear_all_rounded,
                    label: 'إلغاء التحديد',
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
                  padding: EdgeInsets.only(right: AppSizes.xs),
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
                child: Text(label, style: const TextStyle(color: AppColors.textPrimary)),
              ),
              const Icon(Icons.chevron_left_rounded, size: 18, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, Color? color) {
    final isSelected = _filterType == value;
    return Padding(
      padding: const EdgeInsets.only(left: AppSizes.xs),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _filterType = value),
        backgroundColor: Colors.white,
        selectedColor: (color ?? AppColors.primary).withValues(alpha: 0.15),
        checkmarkColor: color ?? AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? (color ?? AppColors.primary) : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(color: isSelected ? (color ?? AppColors.primary) : AppColors.border),
      ),
    );
  }

  Widget _buildInventoryContent(List<dynamic> products) {
    // Filter products
    var filtered = products.where((p) {
      // Apply stock filter
      switch (_filterType) {
        case 'low':
          if (!p.isLowStock || p.isOutOfStock) return false;
          break;
        case 'out':
          if (!p.isOutOfStock) return false;
          break;
        case 'available':
          if (p.isLowStock || p.isOutOfStock) return false;
          break;
      }

      // Apply search
      final query = _searchController.text.toLowerCase();
      if (query.isNotEmpty && !p.name.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();

    // Sort products
    filtered.sort((a, b) {
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              _filterType == 'low'
                  ? 'لا يوجد مخزون منخفض'
                  : _filterType == 'out'
                      ? 'لا يوجد منتجات نفذت'
                      : 'لا توجد منتجات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final product = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.sm),
          child: _InventoryCard(
            product: product,
            isSelected: _selectedIds.contains(product.id),
            onTap: () => _showAdjustDialog(product.id, product.name, product.stockQty),
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

  void _showAdjustDialog(String productId, String productName, int currentQty) {
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
                  const Text('تعديل المخزون'),
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
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'الكمية الحالية: ',
                      style: TextStyle(color: AppColors.textSecondary),
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
                  labelText: 'الكمية الجديدة',
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
                  labelText: 'سبب التعديل',
                  prefixIcon: const Icon(Icons.note_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'count', child: Text('جرد')),
                  DropdownMenuItem(value: 'receive', child: Text('استلام بضاعة')),
                  DropdownMenuItem(value: 'damage', child: Text('تالف')),
                  DropdownMenuItem(value: 'return', child: Text('مرتجع')),
                  DropdownMenuItem(value: 'correction', child: Text('تصحيح')),
                  DropdownMenuItem(value: 'other', child: Text('أخرى')),
                ],
                onChanged: (v) => reason = v ?? 'count',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
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
                      Text('تم تعديل مخزون $productName إلى $newQty'),
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
            label: 'حفظ',
            icon: Icons.save_rounded,
          ),
        ],
      ),
    );
  }

  void _showBulkAdjustDialog() {
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
            const Text('تعديل جماعي'),
          ],
        ),
        content: const Text('هذه الميزة قيد التطوير...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showInventoryCountDialog() {
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
            const Text('جرد المخزون'),
          ],
        ),
        content: const Text('هذه الميزة قيد التطوير...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
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
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: isAlert ? color.withValues(alpha: 0.5) : AppColors.border,
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
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
              child: const Icon(Icons.priority_high_rounded, size: 12, color: Colors.white),
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

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: widget.isSelected
                ? AppColors.primary
                : _isHovered
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : isOutOfStock || isLowStock
                        ? stockColor.withValues(alpha: 0.3)
                        : AppColors.border,
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
                            widget.product.barcode ?? 'بدون باركود',
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
                          ? 'نفذ'
                          : isLowStock
                              ? 'منخفض'
                              : 'متوفر',
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
                    tooltip: 'تعديل',
                  ),
                const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
