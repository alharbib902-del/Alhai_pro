/// Stock Take Screen - Physical inventory count
///
/// Category filter, product list with system qty and counted qty input,
/// variance column, save count and finalize button, summary stats.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_core/alhai_core.dart' show User;
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:uuid/uuid.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;
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

  // Map productId -> counted quantity (user input).
  //
  // P2: Controllers are created lazily on first lookup via
  // [_controllerFor] instead of up-front in [_loadData]. In a large
  // catalogue (10k+ SKUs) the previous eager construction allocated
  // one TextEditingController per row even though most products never
  // receive a manual count, burning memory and delaying the initial
  // frame. Lazy creation keeps the map sparse — only rows the operator
  // actually touches allocate a controller.
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
    _countControllers.clear();
    super.dispose();
  }

  /// Returns (and caches) the [TextEditingController] for a given
  /// product row. First access allocates; subsequent accesses reuse.
  TextEditingController _controllerFor(String productId) {
    return _countControllers.putIfAbsent(
      productId,
      () => TextEditingController(),
    );
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
          // Controllers are built lazily by _controllerFor on first
          // touch — skip the eager loop that used to allocate one per
          // product row.
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
    final counted = double.tryParse(ctrl.text) ?? 0.0;
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

    // P0-22: PopScope guard. Stock-takes can sit half-filled for many
    // minutes while the cashier walks the aisles; an accidental back
    // press without a confirm would discard everything silently. We
    // gate on `_hasPendingCounts()` so the dialog only appears when
    // there's actually something to lose.
    return PopScope(
      canPop: !_hasPendingCounts(),
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final shouldDiscard = await _confirmDiscardUnsaved();
        if (!mounted) return;
        if (shouldDiscard) {
          navigator.pop();
        }
      },
      child: _buildContent(
        context: context,
        isWideScreen: isWideScreen,
        isMediumScreen: isMediumScreen,
        isDark: isDark,
        l10n: l10n,
        user: user,
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required bool isWideScreen,
    required bool isMediumScreen,
    required bool isDark,
    required AppLocalizations l10n,
    required User? user,
  }) {
    return Column(
      children: [
        AppHeader(
          title: l10n.stockTake,
          subtitle: _getDateSubtitle(l10n),
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
              ? const AppLoadingState()
              : _error != null
              ? AppErrorState.general(
                  context,
                  message: _error!,
                  onRetry: _loadData,
                )
              : Column(
                  children: [
                    // Summary bar
                    Padding(
                      padding: EdgeInsets.all(
                        isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                      ),
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
                                vertical: AlhaiSpacing.xs,
                              ),
                              itemCount: _filteredProducts.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AlhaiSpacing.xs),
                              itemBuilder: (context, index) => _buildProductRow(
                                _filteredProducts[index],
                                isDark,
                                l10n,
                                isMediumScreen,
                              ),
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
                Text(
                  l10n.totalItems,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  '$_totalItems',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.getBorder(isDark)),
          Expanded(
            child: Column(
              children: [
                Text(
                  l10n.counted,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  '$_countedItems',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.getBorder(isDark)),
          Expanded(
            child: Column(
              children: [
                Text(
                  l10n.variances,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  '$_varianceItems',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _varianceItems > 0
                        ? AppColors.error
                        : AppColors.getTextPrimary(isDark),
                  ),
                ),
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
          _buildFilterChip(
            l10n.allCategories,
            _selectedCategoryId == null,
            () => setState(() => _selectedCategoryId = null),
            isDark,
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          ..._categories.map(
            (cat) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: _buildFilterChip(
                cat.name,
                _selectedCategoryId == cat.id,
                () => setState(() => _selectedCategoryId = cat.id),
                isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: AlhaiSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.getSurfaceVariant(isDark),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.getBorder(isDark),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? AppColors.textOnPrimary
                : AppColors.getTextSecondary(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildProductRow(
    ProductsTableData product,
    bool isDark,
    AppLocalizations l10n,
    bool isMediumScreen,
  ) {
    final double systemQty = product.stockQty;
    final ctrl = _controllerFor(product.id);
    final double? countedQty = double.tryParse(ctrl.text);
    final double? variance = countedQty != null ? countedQty - systemQty : null;
    final bool hasVariance = variance != null && variance != 0;

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
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AlhaiSpacing.xxxs),
                if (product.barcode != null)
                  Text(
                    product.barcode!,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.getTextMuted(isDark),
                      fontFamily: 'monospace',
                    ),
                  ),
              ],
            ),
          ),
          // System qty
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(
                  l10n.system,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.getTextMuted(isDark),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxxs),
                Text(
                  // Stock is a double — format consistently so a product
                  // sitting at 3.5 doesn't render "3.5" next to a whole
                  // "10" on the neighbour row.
                  systemQty.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          // Counted qty input
          SizedBox(
            width: 80,
            child: TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d+(\.\d{0,2})?$'),
                ),
              ],
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
                  horizontal: AlhaiSpacing.xs,
                  vertical: 10,
                ),
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
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
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
                Text(
                  l10n.variance,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.getTextMuted(isDark),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxxs),
                Text(
                  variance != null
                      ? '${variance >= 0 ? '+' : ''}${variance.toStringAsFixed(2)}'
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
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.getTextMuted(isDark).withValues(alpha: 0.4),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            l10n.noProducts,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                          strokeWidth: 2,
                          color: AppColors.textOnPrimary,
                        ),
                      )
                    : const Icon(Icons.check_circle_rounded, size: 18),
                label: Text(l10n.finalize),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
    setState(() => _isSaving = true);
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        setState(() => _isSaving = false);
        return;
      }

      // Build a draft payload from whatever the operator has keyed so
      // far. Kept as an "in_progress" stock_take row; finalise uses a
      // different path that actually mutates product stock.
      final drafts = <Map<String, dynamic>>[];
      int totalCounted = 0;
      int totalVariance = 0;
      for (final product in _filteredProducts) {
        final ctrl = _countControllers[product.id];
        if (ctrl == null || ctrl.text.isEmpty) continue;
        final counted = double.tryParse(ctrl.text);
        if (counted == null) continue;
        totalCounted += 1;
        if (counted != product.stockQty) totalVariance += 1;
        drafts.add({
          'productId': product.id,
          'name': product.name,
          'systemQty': product.stockQty,
          'countedQty': counted,
          'variance': counted - product.stockQty,
        });
      }

      if (drafts.isEmpty) {
        setState(() => _isSaving = false);
        AlhaiSnackbar.info(context, l10n.success);
        return;
      }

      final user = ref.read(currentUserProvider);
      final now = DateTime.now();
      final draftId = const Uuid().v4();

      await _db
          .into(_db.stockTakesTable)
          .insert(
            StockTakesTableCompanion.insert(
              id: draftId,
              storeId: storeId,
              name:
                  'جرد ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
              items: Value(jsonEncode(drafts)),
              totalItems: Value(_filteredProducts.length),
              countedItems: Value(totalCounted),
              varianceItems: Value(totalVariance),
              createdBy: Value(user?.id),
              startedAt: now,
              status: const Value('in_progress'),
            ),
          );

      if (!mounted) return;
      AlhaiSnackbar.success(context, l10n.success);
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save stock take draft');
      if (!mounted) return;
      AlhaiSnackbar.error(context, l10n.errorWithDetails('$e'));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _finalizeCount() async {
    final l10n = AppLocalizations.of(context);
    final user = ref.read(currentUserProvider);

    // P0-22: role gate. Stock-take adjustments mutate inventory in bulk
    // and feed margin reports; only managers/owners may finalize. The
    // server-side guarantee is the inventory_movements RLS policy from
    // Wave 9 — this is the matching client-side gate so the cashier
    // sees a clear "no permission" message instead of a silent server
    // rejection.
    if (!Permissions.canRunStockTake(user)) {
      AlhaiSnackbar.error(context, l10n.unauthorizedAction);
      return;
    }

    // P0-22: confirmation dialog before applying. A finalize on a 5000-
    // SKU store can't be undone in the UI — make the operator confirm
    // intent and surface the count of pending adjustments first.
    final pendingCounts = _entriesAcrossAllFilters();
    if (pendingCounts.isEmpty) {
      AlhaiSnackbar.info(context, l10n.noChangesToSave);
      return;
    }
    final confirmed = await _showFinalizeConfirmation(pendingCounts.length);
    if (confirmed != true) return;

    setState(() => _isSaving = true);

    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      final sessionId = const Uuid().v4();
      final startedAt = DateTime.now();
      final adjustedSnapshots = <_AdjustmentSnapshot>[];

      // P0-22 + Wave 7 (P0-19/20): single transaction wraps session-row
      // creation, every per-product TOCTOU re-read + delta movement +
      // stock update, and the session-row finalisation. If any single
      // product fails to apply, the whole stock-take rolls back so the
      // session row never enters a half-applied state.
      //
      // Filter-scope fix: iterate `_entriesAcrossAllFilters` (all
      // controllers with text), NOT `_filteredProducts`. Pre-fix the
      // cashier could enter counts in category A, switch to B, hit
      // finalise, and silently lose every count outside B.
      await _db.transaction(() async {
        // Open the session row up-front so the inventory_movements rows
        // can carry its id as referenceId. Status starts in_progress in
        // case a partial failure rolls everything back.
        await _db.into(_db.stockTakesTable).insert(
              StockTakesTableCompanion.insert(
                id: sessionId,
                storeId: storeId,
                name:
                    'جرد ${startedAt.year}-${startedAt.month.toString().padLeft(2, '0')}-${startedAt.day.toString().padLeft(2, '0')} ${startedAt.hour.toString().padLeft(2, '0')}:${startedAt.minute.toString().padLeft(2, '0')}',
                createdBy: Value(user?.id),
                startedAt: startedAt,
                status: const Value('in_progress'),
              ),
            );

        for (final entry in pendingCounts) {
          final fresh = await _db.productsDao.getProductById(entry.productId);
          if (fresh == null) continue;
          final double systemQty = fresh.stockQty;
          if (entry.counted == systemQty) continue;
          await _db.inventoryDao.recordStockTakeMovement(
            id: const Uuid().v4(),
            productId: entry.productId,
            storeId: storeId,
            delta: entry.counted - systemQty,
            previousQty: systemQty,
            reason: 'stock_take',
            userId: user?.id,
            referenceType: 'stock_take',
            referenceId: sessionId,
          );
          await _db.productsDao.updateStock(entry.productId, entry.counted);
          adjustedSnapshots.add(
            _AdjustmentSnapshot(
              productId: entry.productId,
              productName: fresh.name,
              oldQty: systemQty,
              newQty: entry.counted,
            ),
          );
        }

        // Stamp session as finalized with summary counts. Done inside
        // the same tx so a row marked `finalized` never points at
        // missing or half-applied movements.
        await (_db.update(_db.stockTakesTable)
              ..where((t) => t.id.equals(sessionId)))
            .write(
          StockTakesTableCompanion(
            status: const Value('finalized'),
            completedAt: Value(DateTime.now()),
            totalItems: Value(_products.length),
            countedItems: Value(pendingCounts.length),
            varianceItems: Value(adjustedSnapshots.length),
          ),
        );
      });

      // Audit log for each adjusted product (outside DB transaction —
      // non-transactional sink). Uses the FRESH oldQty captured during
      // the tx, NOT the cached `_products` snapshot — matches the
      // delta that was actually applied.
      for (final snap in adjustedSnapshots) {
        auditService.logStockAdjust(
          storeId: storeId,
          userId: user?.id ?? 'unknown',
          userName: user?.name ?? 'unknown',
          productId: snap.productId,
          productName: snap.productName,
          oldQty: snap.oldQty,
          newQty: snap.newQty,
          reason: 'جرد',
        );
      }

      if (!mounted) return;

      AlhaiSnackbar.success(context, l10n.success);

      await _loadData();
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save stock take');
      if (!mounted) return;
      AlhaiSnackbar.error(context, l10n.errorWithDetails('$e'));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// P0-22: collect every entered count, regardless of which category
  /// filter is currently selected. Replaces the pre-fix loop over
  /// `_filteredProducts` which silently dropped counts entered while
  /// other filters were active.
  ///
  /// Iteration is over the controller map (sparse — only products the
  /// cashier touched), then resolved against `_products` for the
  /// matching row. Products that were soft-deleted between load and
  /// finalize get skipped silently — the surrounding tx's TOCTOU re-
  /// read will surface the same condition for the survivors.
  List<_PendingCount> _entriesAcrossAllFilters() {
    final out = <_PendingCount>[];
    final byId = <String, ProductsTableData>{
      for (final p in _products) p.id: p,
    };
    for (final entry in _countControllers.entries) {
      final text = entry.value.text.trim();
      if (text.isEmpty) continue;
      final counted = double.tryParse(text);
      if (counted == null) continue;
      // Sanity guard: drop counts for products that were removed from
      // the catalogue between load and finalize. The TOCTOU re-read in
      // the tx covers the same case for survivors; no point inserting
      // a movement for a row that's gone.
      if (!byId.containsKey(entry.key)) continue;
      out.add(_PendingCount(productId: entry.key, counted: counted));
    }
    return out;
  }

  /// True if the operator has any unsaved counts in any filter view —
  /// used by the PopScope guard to gate back-button dismissal.
  bool _hasPendingCounts() => _entriesAcrossAllFilters().isNotEmpty;

  Future<bool?> _showFinalizeConfirmation(int adjustmentCount) async {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.inventory_2_outlined, size: 48),
        title: Text(l10n.stockTakeFinalizeConfirmTitle),
        content: Text(l10n.stockTakeFinalizeConfirmBody(adjustmentCount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.finalize),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDiscardUnsaved() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, size: 48),
        title: Text(l10n.stockTakeUnsavedTitle),
        content: Text(l10n.stockTakeUnsavedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );
    return ok ?? false;
  }
}

/// P0-22: pending count payload for one product. Internal to the screen.
class _PendingCount {
  final String productId;
  final double counted;
  const _PendingCount({required this.productId, required this.counted});
}

/// P0-22: snapshot of a successful stock-take adjustment, used to feed
/// the audit log AFTER the DB tx commits — so the audit row's `oldQty`
/// is the value that was actually replaced (re-read inside the tx),
/// NOT the stale `_products` cache the screen first loaded.
class _AdjustmentSnapshot {
  final String productId;
  final String productName;
  final double oldQty;
  final double newQty;
  const _AdjustmentSnapshot({
    required this.productId,
    required this.productName,
    required this.oldQty,
    required this.newQty,
  });
}
