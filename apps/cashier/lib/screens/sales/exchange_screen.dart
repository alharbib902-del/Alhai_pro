/// Exchange Screen - Return items and add new items in one transaction
///
/// Two sections: "Items to Return" and "New Items to Add".
/// Search/scan products for exchange, calculate difference.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
///
/// State model:
/// - Business state → `_ExchangeState` via `_exchangeProvider`. Tracks the
///   two search-result lists, the two exchange-item lists, and the
///   submitting flag. Replaces 11 historic `setState` sites with immutable
///   `copyWith` updates.
/// - The `_ExchangeItem` record stays as before (its `copyWithQty` continues
///   to power both return + new-item lists without change).
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_core/alhai_core.dart' show Product;
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_pos/alhai_pos.dart'
    show PosCartItem, createReturn, saleServiceProvider;
import '../../core/services/sentry_service.dart';
import '../../core/services/audit_service.dart';
import '../../core/services/haptic_shim.dart';
import '../../core/services/sound_service.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui

// ============================================================================
// State
// ============================================================================

@immutable
class _ExchangeState {
  final List<ProductsTableData> returnSearchResults;
  final List<ProductsTableData> newSearchResults;
  final List<_ExchangeItem> returnItems;
  final List<_ExchangeItem> newItems;
  final bool isSubmitting;

  const _ExchangeState({
    this.returnSearchResults = const [],
    this.newSearchResults = const [],
    this.returnItems = const [],
    this.newItems = const [],
    this.isSubmitting = false,
  });

  _ExchangeState copyWith({
    List<ProductsTableData>? returnSearchResults,
    List<ProductsTableData>? newSearchResults,
    List<_ExchangeItem>? returnItems,
    List<_ExchangeItem>? newItems,
    bool? isSubmitting,
  }) => _ExchangeState(
    returnSearchResults: returnSearchResults ?? this.returnSearchResults,
    newSearchResults: newSearchResults ?? this.newSearchResults,
    returnItems: returnItems ?? this.returnItems,
    newItems: newItems ?? this.newItems,
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );

  double get returnTotal =>
      returnItems.fold<double>(0, (sum, i) => sum + (i.price * i.qty));

  double get newTotal =>
      newItems.fold<double>(0, (sum, i) => sum + (i.price * i.qty));

  double get difference => newTotal - returnTotal;
}

class _ExchangeNotifier extends StateNotifier<_ExchangeState> {
  _ExchangeNotifier() : super(const _ExchangeState());

  void setReturnSearchResults(List<ProductsTableData> list) =>
      state = state.copyWith(returnSearchResults: list);

  void setNewSearchResults(List<ProductsTableData> list) =>
      state = state.copyWith(newSearchResults: list);

  void clearReturnSearchResults() =>
      state = state.copyWith(returnSearchResults: const []);

  void clearNewSearchResults() =>
      state = state.copyWith(newSearchResults: const []);

  /// Add a product to the return or new list. Bumps quantity if already present.
  /// Also clears the corresponding search results (the search row is reused
  /// as a quick "scanner" input: once a product is added the list collapses).
  void addItem(ProductsTableData product, {required bool isReturn}) {
    final list = isReturn
        ? List<_ExchangeItem>.from(state.returnItems)
        : List<_ExchangeItem>.from(state.newItems);
    final existing = list.indexWhere((i) => i.productId == product.id);
    if (existing >= 0) {
      list[existing] = list[existing].copyWithQty(list[existing].qty + 1);
    } else {
      list.add(
        _ExchangeItem(
          productId: product.id,
          productName: product.name,
          // C-4 Stage B: product.price is int cents; exchange item schema is double SAR.
          price: product.price / 100.0,
          qty: 1,
          product: product,
        ),
      );
    }
    state = isReturn
        ? state.copyWith(returnItems: list, returnSearchResults: const [])
        : state.copyWith(newItems: list, newSearchResults: const []);
  }

  void removeItem(int index, {required bool isReturn}) {
    final list = isReturn
        ? List<_ExchangeItem>.from(state.returnItems)
        : List<_ExchangeItem>.from(state.newItems);
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    state = isReturn
        ? state.copyWith(returnItems: list)
        : state.copyWith(newItems: list);
  }

  void updateQty(int index, int qty, {required bool isReturn}) {
    if (qty <= 0) {
      removeItem(index, isReturn: isReturn);
      return;
    }
    final list = isReturn
        ? List<_ExchangeItem>.from(state.returnItems)
        : List<_ExchangeItem>.from(state.newItems);
    if (index < 0 || index >= list.length) return;
    list[index] = list[index].copyWithQty(qty);
    state = isReturn
        ? state.copyWith(returnItems: list)
        : state.copyWith(newItems: list);
  }

  void setSubmitting(bool v) => state = state.copyWith(isSubmitting: v);

  void clearAllItems() => state = state.copyWith(
    returnItems: const [],
    newItems: const [],
  );
}

final _exchangeProvider =
    StateNotifierProvider.autoDispose<_ExchangeNotifier, _ExchangeState>(
      (ref) => _ExchangeNotifier(),
    );

// ============================================================================
// Screen
// ============================================================================

/// شاشة الاستبدال
class ExchangeScreen extends ConsumerStatefulWidget {
  const ExchangeScreen({super.key});

  @override
  ConsumerState<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends ConsumerState<ExchangeScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _returnSearchController = TextEditingController();
  final _newSearchController = TextEditingController();

  @override
  void dispose() {
    _returnSearchController.dispose();
    _newSearchController.dispose();
    super.dispose();
  }

  Future<void> _searchProducts(String query, bool isReturn) async {
    final notifier = ref.read(_exchangeProvider.notifier);
    if (query.trim().isEmpty) {
      if (isReturn) {
        notifier.clearReturnSearchResults();
      } else {
        notifier.clearNewSearchResults();
      }
      return;
    }
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final results = await _db.productsDao.searchProducts(query, storeId);
      if (!mounted) return;
      final top = results.take(5).toList();
      if (isReturn) {
        notifier.setReturnSearchResults(top);
      } else {
        notifier.setNewSearchResults(top);
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Exchange search');
      if (!mounted) return;
      HapticShim.vibrate();
      SoundService.instance.errorBuzz();
      AlhaiSnackbar.error(
        context,
        AppLocalizations.of(context).errorOccurred,
      );
    }
  }

  void _addItem(ProductsTableData product, bool isReturn) {
    ref.read(_exchangeProvider.notifier).addItem(product, isReturn: isReturn);
    if (isReturn) {
      _returnSearchController.clear();
    } else {
      _newSearchController.clear();
    }
  }

  void _removeItem(int index, bool isReturn) {
    ref
        .read(_exchangeProvider.notifier)
        .removeItem(index, isReturn: isReturn);
  }

  void _updateQty(int index, int qty, bool isReturn) {
    ref
        .read(_exchangeProvider.notifier)
        .updateQty(index, qty, isReturn: isReturn);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final s = ref.watch(_exchangeProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.exchangeTitle,
          subtitle: _getDateSubtitle(l10n),
          showSearch: false,
          searchHint: l10n.searchPlaceholder,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: ref.watch(unreadNotificationsCountProvider),
          userName: user?.name ?? l10n.cashCustomer,
          userRole: l10n.branchManager,
          onUserTap: () {},
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
            ),
            child: isWideScreen
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildReturnSection(isDark, l10n, s)),
                      const SizedBox(width: AlhaiSpacing.lg),
                      Expanded(child: _buildNewItemsSection(isDark, l10n, s)),
                    ],
                  )
                : Column(
                    children: [
                      _buildReturnSection(isDark, l10n, s),
                      SizedBox(
                        height: isMediumScreen
                            ? AlhaiSpacing.lg
                            : AlhaiSpacing.md,
                      ),
                      _buildNewItemsSection(isDark, l10n, s),
                    ],
                  ),
          ),
        ),
        _buildBottomBar(isDark, l10n, s),
      ],
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} \u2022 ${l10n.mainBranch}';
  }

  Widget _buildReturnSection(
    bool isDark,
    AppLocalizations l10n,
    _ExchangeState s,
  ) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.assignment_return_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.itemsToReturn,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _buildSearchBar(_returnSearchController, isDark, l10n, true),
          if (s.returnSearchResults.isNotEmpty)
            _buildSearchResults(s.returnSearchResults, isDark, true),
          const SizedBox(height: AlhaiSpacing.sm),
          ...s.returnItems.asMap().entries.map(
            (e) => _buildExchangeItemCard(e.value, e.key, isDark, l10n, true),
          ),
          if (s.returnItems.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: AlhaiSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.subtotal,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatWithContext(
                      context,
                      s.returnTotal,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNewItemsSection(
    bool isDark,
    AppLocalizations l10n,
    _ExchangeState s,
  ) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add_shopping_cart_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.newItemsToAdd,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _buildSearchBar(_newSearchController, isDark, l10n, false),
          if (s.newSearchResults.isNotEmpty)
            _buildSearchResults(s.newSearchResults, isDark, false),
          const SizedBox(height: AlhaiSpacing.sm),
          ...s.newItems.asMap().entries.map(
            (e) => _buildExchangeItemCard(e.value, e.key, isDark, l10n, false),
          ),
          if (s.newItems.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: AlhaiSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.subtotal,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatWithContext(
                      context,
                      s.newTotal,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    TextEditingController controller,
    bool isDark,
    AppLocalizations l10n,
    bool isReturn,
  ) {
    return TextField(
      controller: controller,
      style: TextStyle(color: AppColors.getTextPrimary(isDark)),
      onChanged: (v) => _searchProducts(v, isReturn),
      decoration: InputDecoration(
        hintText: l10n.searchPlaceholder,
        hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: AppColors.getTextMuted(isDark),
        ),
        filled: true,
        fillColor: AppColors.getSurfaceVariant(isDark),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.md,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    List<ProductsTableData> results,
    bool isDark,
    bool isReturn,
  ) {
    return Container(
      margin: const EdgeInsetsDirectional.only(top: AlhaiSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: results.map((product) {
          return InkWell(
            onTap: () => _addItem(product, isReturn),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.md,
                vertical: AlhaiSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: AppColors.getTextMuted(isDark),
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    // product.price is int cents; fromCentsWithContext divides
                    // by 100 + localises. Raw toStringAsFixed inflates 100×.
                    CurrencyFormatter.fromCentsWithContext(
                      context,
                      product.price,
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExchangeItemCard(
    _ExchangeItem item,
    int index,
    bool isDark,
    AppLocalizations l10n,
    bool isReturn,
  ) {
    final total = item.price * item.qty;
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: AlhaiSpacing.xs),
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceVariant(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.getBorder(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  CurrencyFormatter.formatWithContext(context, item.price),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _updateQty(index, item.qty - 1, isReturn),
                icon: const Icon(Icons.remove_circle_outline_rounded),
                iconSize: 22,
                color: AppColors.getTextSecondary(isDark),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                padding: EdgeInsets.zero,
                tooltip: l10n.decreaseQuantity,
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '${item.qty}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _updateQty(index, item.qty + 1, isReturn),
                icon: const Icon(Icons.add_circle_outline_rounded),
                iconSize: 22,
                color: AppColors.primary,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                padding: EdgeInsets.zero,
                tooltip: l10n.increaseQuantity,
              ),
            ],
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          Text(
            total.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          IconButton(
            onPressed: () => _removeItem(index, isReturn),
            icon: const Icon(Icons.close_rounded, size: 18),
            color: AppColors.error,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            padding: EdgeInsets.zero,
            tooltip: l10n.delete,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark, AppLocalizations l10n, _ExchangeState s) {
    final diff = s.difference;
    final diffColor = diff == 0
        ? AppColors.success
        : (diff > 0 ? AppColors.warning : AppColors.success);
    final hasItems = s.returnItems.isNotEmpty || s.newItems.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(
          top: BorderSide(color: AppColors.getBorder(isDark), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.difference,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                  Text(
                    '${diff >= 0 ? '+' : ''}${CurrencyFormatter.formatWithContext(context, diff)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: diffColor,
                    ),
                  ),
                  if (diff > 0)
                    Text(
                      l10n.customerPaysExtra,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.getTextMuted(isDark),
                      ),
                    )
                  else if (diff < 0)
                    Text(
                      l10n.refundToCustomer,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.getTextMuted(isDark),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AlhaiSpacing.md),
            Expanded(
              child: FilledButton.icon(
                onPressed: s.isSubmitting || !hasItems
                    ? null
                    : () => _submitExchange(l10n),
                icon: s.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textOnPrimary,
                        ),
                      )
                    : const Icon(Icons.swap_horiz_rounded, size: 20),
                label: Text(
                  l10n.submitExchange,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(
                    vertical: AlhaiSpacing.md,
                  ),
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

  /// تنفيذ عملية الاستبدال الفعلية.
  ///
  /// المنطق:
  /// 1. إذا وُجد [newItems] → إنشاء بيع جديد عبر [SaleService.createSale]
  ///    (يولّد receipt + stockDeltas + invoice + sync enqueue تلقائياً).
  /// 2. إذا وُجد [returnItems] → استدعاء [createReturn] على saleId
  ///    الجديد المُنشأ (أو رفض السيناريو إن لم يوجد بيع جديد —
  ///    المرتجع البحت يجب أن يمرّ عبر Returns screen حيث يُختار
  ///    البيع الأصلي، لأن FK returns.sale_id هو ON DELETE RESTRICT
  ///    ولا يقبل IDs مُخترعة).
  /// 3. balanceDiff = newTotal - returnTotal:
  ///    - موجب → العميل دفع الفرق cash (paymentMethod='cash').
  ///    - سالب → نُضيف الفرق إلى totalRefund في createReturn ليُرجع للعميل.
  ///    - صفر → استبدال متوازن (لا فرق).
  Future<void> _submitExchange(AppLocalizations l10n) async {
    final notifier = ref.read(_exchangeProvider.notifier);
    notifier.setSubmitting(true);
    HapticFeedback.mediumImpact();

    final user = ref.read(currentUserProvider);
    final storeId = ref.read(currentStoreIdProvider);

    if (storeId == null) {
      notifier.setSubmitting(false);
      AlhaiSnackbar.error(context, l10n.errorOccurred);
      return;
    }

    // Snapshot current lists — avoids reading the provider mid-async if
    // the user closes the screen; copies are immutable anyway.
    final snap = ref.read(_exchangeProvider);
    final returnItemsSnap = snap.returnItems;
    final newItemsSnap = snap.newItems;

    // احسب المبالغ (SAR doubles للـ UI/math).
    final returnTotal = snap.returnTotal;
    final newTotal = snap.newTotal;
    final balanceDiff = newTotal - returnTotal;

    // سيناريو مرفوض: لا newItems → ليس استبدالاً. وجّه المستخدم لشاشة
    // Returns المخصصة (التي تربط المرتجع بسجل بيع سابق).
    if (newItemsSnap.isEmpty && returnItemsSnap.isNotEmpty) {
      notifier.setSubmitting(false);
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.errorOccurred),
          content: Text(l10n.exchangeRequiresNewItem),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.close),
            ),
          ],
        ),
      );
      return;
    }

    // سيناريو رفض: لا newItems ولا returnItems — button معطّل أصلاً بهذا الشرط
    // لكن نحمي ضد race/state stale.
    if (newItemsSnap.isEmpty && returnItemsSnap.isEmpty) {
      notifier.setSubmitting(false);
      return;
    }

    String? createdSaleId;

    try {
      // ─── 1. إنشاء البيع الجديد (newItems غير فارغة بالضرورة هنا) ─────
      final saleService = ref.read(saleServiceProvider);

      // تحويل _ExchangeItem → PosCartItem. نبني Product domain model من
      // ProductsTableData المحفوظة وقت الإضافة. price هنا int cents (product).
      final posItems = newItemsSnap.map((ei) {
        final p = ei.product;
        final productModel = Product(
          id: p.id,
          storeId: p.storeId,
          name: p.name,
          sku: p.sku,
          barcode: p.barcode,
          price: p.price, // int cents (كما هو)
          costPrice: p.costPrice,
          stockQty: p.stockQty,
          minQty: p.minQty,
          unit: p.unit,
          description: p.description,
          imageThumbnail: p.imageThumbnail,
          imageMedium: p.imageMedium,
          imageLarge: p.imageLarge,
          imageHash: p.imageHash,
          categoryId: p.categoryId,
          isActive: p.isActive,
          trackInventory: p.trackInventory,
          createdAt: p.createdAt,
          updatedAt: p.updatedAt,
        );
        return PosCartItem(product: productModel, quantity: ei.qty);
      }).toList();

      // ضريبة القيمة المضافة 15% على إجمالي الـ newItems (نتبع نفس نمط POS).
      const vatRate = 0.15;
      final newSubtotal = newTotal; // SAR double
      final newTax = newSubtotal * vatRate;
      final newGrandTotal = newSubtotal + newTax;

      // paymentMethod: إن كان balanceDiff موجباً فالعميل يدفع cash للفرق
      // (وهو ما ندرجه كمبلغ مستلم للبيع). إن كان سالباً أو صفر فالبيع
      // مدفوع كاملاً من رصيد المرتجع — نضعه cash بنفس قيمة البيع لتجنب
      // تسجيل credit debt.
      final saleResult = await saleService.createSale(
        storeId: storeId,
        cashierId: user?.id ?? '',
        items: posItems,
        subtotal: newSubtotal,
        discount: 0,
        tax: newTax,
        total: newGrandTotal,
        paymentMethod: 'cash',
        amountReceived: newGrandTotal,
        changeAmount: 0,
        cashAmount: newGrandTotal,
        customerId: null,
        customerName: null,
        notes: returnItemsSnap.isNotEmpty
            ? 'Exchange sale — linked to return of '
                  '${returnItemsSnap.length} item(s), offset '
                  '${returnTotal.toStringAsFixed(2)} SAR'
            : null,
      );
      createdSaleId = saleResult.saleId;

      // ─── 2. إنشاء المرتجع (إن وُجدت عناصر مرتجعة) ─────────────────────
      if (returnItemsSnap.isNotEmpty) {
        // VAT consistency: per-line refundAmount carries VAT 15% (matches
        // refund_reason_screen.dart:356), so totalRefund must also be the
        // VAT-inclusive gross. Without this multiplier, the sum of
        // line refunds wouldn't equal the header refund — auditors and
        // ZATCA reconciliation would flag the mismatch.
        const vatRate = 0.15;
        final returnTotalWithVat = returnTotal * (1 + vatRate);

        final returnItemCompanions = returnItemsSnap.map((ei) {
          // unitPrice في return_items هو int cents.
          final unitPriceCents = (ei.price * 100).round();
          final lineRefundCents = (ei.qty * ei.price * (1 + vatRate) * 100)
              .round();
          return ReturnItemsTableCompanion(
            productId: Value(ei.productId),
            productName: Value(ei.productName),
            qty: Value(ei.qty.toDouble()),
            unitPrice: Value(unitPriceCents),
            refundAmount: Value(lineRefundCents),
          );
        }).toList();

        await createReturn(
          ref,
          saleId: createdSaleId,
          reason: 'exchange',
          totalRefund: returnTotalWithVat,
          refundMethod: 'cash',
          notes:
              'Exchange transaction — offsetting new items '
              '${newTotal.toStringAsFixed(2)} SAR '
              '(diff=${balanceDiff.toStringAsFixed(2)} SAR)',
          createdBy: user?.id,
          items: returnItemCompanions,
        );
      }

      // ─── 3. Audit log ─────────────────────────────────────────────────
      await auditService.logExchange(
        storeId: storeId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        returnCount: returnItemsSnap.length,
        newCount: newItemsSnap.length,
      );

      addBreadcrumb(
        message: 'Exchange completed',
        category: 'sale',
        data: {
          'saleId': createdSaleId,
          'returnItems': returnItemsSnap.length,
          'newItems': newItemsSnap.length,
          'returnTotal': returnTotal,
          'newTotal': newTotal,
          'balanceDiff': balanceDiff,
        },
      );

      if (!mounted) return;
      // Phase 2 §2.6 — upgrade to heavy haptic + sale success chime for
      // a completed exchange (treated as a sale event by the user).
      HapticShim.heavyImpact();
      SoundService.instance.saleSuccess();

      // رسالة نجاح مفصّلة تُوضح الفرق المالي.
      final diffMsg = balanceDiff > 0
          ? ' (+${balanceDiff.toStringAsFixed(2)} ${l10n.sar} ${l10n.customerPaysExtra})'
          : balanceDiff < 0
          ? ' (${balanceDiff.toStringAsFixed(2)} ${l10n.sar} ${l10n.refundToCustomer})'
          : '';
      AlhaiSnackbar.success(
        context,
        '${l10n.exchangeSuccessMsg}$diffMsg',
      );
      notifier.clearAllItems();
    } catch (e, stack) {
      // ملاحظة على استراتيجية الأخطاء: لا يمكن لفّ createSale + createReturn
      // في transaction واحد لأن كليهما يُدير transactions داخلية مستقلة +
      // يُضيف لسجل sync_queue. لذلك إن فشل createReturn بعد نجاح createSale،
      // سيبقى البيع محفوظاً محلياً (والعميل استلم بضاعة) لكن المرتجع لن
      // يُسجَّل — وهذا يعني أن مخزون المنتجات المرتجعة لن يُعاد. نبلّغ
      // المستخدم بصراحة عبر الحوار ونمرّر الـ saleId المُنشأ إلى Sentry
      // ليتمكن المسؤول من إعادة المحاولة عبر Returns screen يدوياً.
      reportError(
        e,
        stackTrace: stack,
        hint:
            'Submit exchange (partial-state possible; '
            'createdSaleId=$createdSaleId)',
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.errorOccurred),
          content: Text(
            createdSaleId != null
                ? 'Sale was created (id: $createdSaleId) but the return '
                      'step failed. Please process the return manually '
                      'from the Returns screen.\n\nError: $e'
                : l10n.errorWithDetails('$e'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.close),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        ref.read(_exchangeProvider.notifier).setSubmitting(false);
      }
    }
  }
}

class _ExchangeItem {
  final String productId;
  final String productName;
  // السعر بـ SAR double (UI math) — التحويل إلى int cents عند حدود DAO/Service.
  final double price;
  final int qty;
  // Reference للسجل الكامل لإعادة بناء `Product` domain model عند إنشاء البيع
  // الجديد عبر SaleService.createSale. بدون هذا سيلزمنا fetch ثانوي داخل
  // الـ submit، مما يُدخل احتمال race (تعديل المنتج بين الإضافة والاستبدال).
  final ProductsTableData product;

  const _ExchangeItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.qty,
    required this.product,
  });

  _ExchangeItem copyWithQty(int newQty) => _ExchangeItem(
    productId: productId,
    productName: productName,
    price: price,
    qty: newQty,
    product: product,
  );
}
