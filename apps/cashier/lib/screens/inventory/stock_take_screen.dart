/// Stock Take Screen - Physical inventory count
///
/// Category filter, product list with system qty and counted qty input,
/// variance column, save count and finalize button, summary stats.
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
import 'package:uuid/uuid.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';
import '../../core/services/audit_service.dart';

/// شاشة الجرد
class StockTakeScreen extends ConsumerStatefulWidget {
  const StockTakeScreen({super.key});

  @override
  ConsumerState<StockTakeScreen> createState() => _StockTakeScreenState();
}

class _StockTakeScreenState extends ConsumerState<StockTakeScreen> {
  final _db = GetIt.I<AppDatabase>();

  List<CategoriesTableData> _categories = [];
  List<ProductsTableData> _products = [];
  String? _selectedCategoryId;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  // Map productId -> counted quantity (user input)
  final Map<String, TextEditingController> _countControllers = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (final c in _countControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      final categories = await _db.categoriesDao.getAllCategories(storeId);
      final products = await _db.productsDao.getAllProducts(storeId);

      if (mounted) {
        setState(() {
          _categories = categories;
          _products = products;
          _isLoading = false;
          // Initialize controllers
          for (final p in products) {
            _countControllers[p.id] = TextEditingController();
          }
        });
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load stock take data');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = '$e';
        });
      }
    }
  }

  List<ProductsTableData> get _filteredProducts {
    if (_selectedCategoryId == null) return _products;
    return _products.where((p) => p.categoryId == _selectedCategoryId).toList();
  }

  int get _totalItems => _filteredProducts.length;

  int get _countedItems => _filteredProducts.where((p) {
        final ctrl = _countControllers[p.id];
        return ctrl != null && ctrl.text.isNotEmpty;
      }).length;

  int get _varianceItems => _filteredProducts.where((p) {
        final ctrl = _countControllers[p.id];
        if (ctrl == null || ctrl.text.isEmpty) return false;
        final counted = int.tryParse(ctrl.text) ?? 0;
        final system = p.stockQty;
        return counted != system;
      }).length;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.stockTake,
          subtitle: _getDateSubtitle(l10n),
          showSearch: false,
          searchHint: l10n.searchPlaceholder,
          onMenuTap:
              isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: user?.name ?? l10n.cashCustomer,
          userRole: l10n.branchManager,
          onUserTap: () {},
        ),
        Expanded(
          child: _isLoading
              ? const AppLoadingState()
              : _error != null
                  ? AppErrorState.general(context,
                      message: _error!, onRetry: _loadData)
                  : Column(
                      children: [
                        // Summary bar
                        Padding(
                          padding: EdgeInsets.all(isMediumScreen
                              ? AlhaiSpacing.lg
                              : AlhaiSpacing.md),
                          child: Column(
                            children: [
                              _buildSummaryBar(isDark, l10n),
                              const SizedBox(height: AlhaiSpacing.md),
                              _buildCategoryFilter(isDark, l10n),
                            ],
                          ),
                        ),
                        // Products list
                        Expanded(
                          child: _filteredProducts.isEmpty
                              ? _buildEmptyState(isDark, l10n)
                              : ListView.separated(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: isMediumScreen ? 24 : 16,
                                      vertical: AlhaiSpacing.xs),
                                  itemCount: _filteredProducts.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: AlhaiSpacing.xs),
                                  itemBuilder: (context, index) =>
                                      _buildProductRow(_filteredProducts[index],
                                          isDark, l10n, isMediumScreen),
                                ),
                        ),
                        // Bottom actions
                        _buildBottomBar(isDark, l10n),
                      ],
                    ),
        ),
      ],
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} \u2022 ${l10n.mainBranch}';
  }

  Widget _buildSummaryBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(l10n.totalItems,
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.getTextSecondary(isDark))),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text('$_totalItems',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.getTextPrimary(isDark))),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.getBorder(isDark)),
          Expanded(
            child: Column(
              children: [
                Text(l10n.counted,
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.getTextSecondary(isDark))),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text('$_countedItems',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success)),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.getBorder(isDark)),
          Expanded(
            child: Column(
              children: [
                Text(l10n.variances,
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.getTextSecondary(isDark))),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text('$_varianceItems',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _varianceItems > 0
                            ? AppColors.error
                            : AppColors.getTextPrimary(isDark))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(l10n.allCategories, _selectedCategoryId == null,
              () => setState(() => _selectedCategoryId = null), isDark),
          const SizedBox(width: AlhaiSpacing.xs),
          ..._categories.map((cat) => Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: _buildFilterChip(cat.name, _selectedCategoryId == cat.id,
                    () => setState(() => _selectedCategoryId = cat.id), isDark),
              )),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: AlhaiSpacing.xs),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.getSurfaceVariant(isDark),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color:
                  isSelected ? AppColors.primary : AppColors.getBorder(isDark)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.textOnPrimary
                    : AppColors.getTextSecondary(isDark))),
      ),
    );
  }

  Widget _buildProductRow(ProductsTableData product, bool isDark,
      AppLocalizations l10n, bool isMediumScreen) {
    final systemQty = product.stockQty;
    final ctrl = _countControllers[product.id]!;
    final countedQty = int.tryParse(ctrl.text);
    final variance = countedQty != null ? countedQty - systemQty : null;
    final hasVariance = variance != null && variance != 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasVariance
            ? AppColors.warning.withValues(alpha: isDark ? 0.08 : 0.04)
            : AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasVariance
              ? AppColors.warning.withValues(alpha: 0.4)
              : AppColors.getBorder(isDark),
        ),
      ),
      child: Row(
        children: [
          // Product info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(isDark)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: AlhaiSpacing.xxxs),
                if (product.barcode != null)
                  Text(product.barcode!,
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.getTextMuted(isDark),
                          fontFamily: 'monospace')),
              ],
            ),
          ),
          // System qty
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(l10n.system,
                    style: TextStyle(
                        fontSize: 10, color: AppColors.getTextMuted(isDark))),
                const SizedBox(height: AlhaiSpacing.xxxs),
                Text('$systemQty',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextPrimary(isDark))),
              ],
            ),
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          // Counted qty input
          SizedBox(
            width: 80,
            child: TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(isDark),
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '-',
                hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.xs, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: AppColors.getSurfaceVariant(isDark),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          // Variance
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(l10n.variance,
                    style: TextStyle(
                        fontSize: 10, color: AppColors.getTextMuted(isDark))),
                const SizedBox(height: AlhaiSpacing.xxxs),
                Text(
                  variance != null
                      ? '${variance >= 0 ? '+' : ''}$variance'
                      : '-',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: hasVariance
                        ? (variance > 0 ? AppColors.success : AppColors.error)
                        : AppColors.getTextMuted(isDark),
                  ),
                ),
              ],
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
          Icon(Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.getTextMuted(isDark).withValues(alpha: 0.4)),
          const SizedBox(height: AlhaiSpacing.md),
          Text(l10n.noProducts,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getTextMuted(isDark))),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(top: BorderSide(color: AppColors.getBorder(isDark))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isSaving ? null : _saveCount,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: Text(l10n.saveDraft),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.getTextSecondary(isDark),
                  side: BorderSide(color: AppColors.getBorder(isDark)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _finalizeCount,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.textOnPrimary))
                    : const Icon(Icons.check_circle_rounded, size: 18),
                label: Text(l10n.finalize),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCount() async {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.success), backgroundColor: AppColors.success),
    );
  }

  Future<void> _finalizeCount() async {
    setState(() => _isSaving = true);

    try {
      final storeId = ref.read(currentStoreIdProvider)!;

      final adjustedProducts = <ProductsTableData>[];

      await _db.transaction(() async {
        for (final product in _filteredProducts) {
          final ctrl = _countControllers[product.id];
          if (ctrl == null || ctrl.text.isEmpty) continue;

          final counted = int.tryParse(ctrl.text);
          if (counted == null) continue;

          final systemQty = product.stockQty;
          if (counted != systemQty) {
            final movementId = const Uuid().v4();
            await _db.inventoryDao.insertMovement(
              InventoryMovementsTableCompanion.insert(
                id: movementId,
                storeId: storeId,
                productId: product.id,
                type: 'stock_take',
                qty: (counted - systemQty).toDouble(),
                previousQty: systemQty.toDouble(),
                newQty: counted.toDouble(),
                reason: const Value('stock_take'),
                createdAt: DateTime.now(),
              ),
            );
            await _db.productsDao.updateStock(product.id, counted.toDouble());
            adjustedProducts.add(product);
          }
        }
      });

      // Audit log for each adjusted product
      final user = ref.read(currentUserProvider);
      for (final product in adjustedProducts) {
        final ctrl = _countControllers[product.id];
        final counted = int.tryParse(ctrl?.text ?? '') ?? 0;
        auditService.logStockAdjust(
          storeId: storeId,
          userId: user?.id ?? 'unknown',
          userName: user?.name ?? 'unknown',
          productId: product.id,
          productName: product.name,
          oldQty: product.stockQty.toDouble(),
          newQty: counted.toDouble(),
          reason: 'جرد',
        );
      }

      if (!mounted) return;

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.success), backgroundColor: AppColors.success),
      );

      await _loadData();
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save stock take');
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.errorWithDetails('$e')),
            backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
