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
// Constants
// ============================================================================

/// Wave 3b-2a return-window policy. Sales older than this can't anchor a
/// new exchange. Hard-coded for now; promote to TaxSettings/StoreSettings
/// in a later wave when the admin wants per-store policies.
const int _kReturnPolicyDays = 30;

/// Hard cap on rows shown in the original-sale picker. The DAO returns
/// up to 5000 within the date range; client-side trimming keeps the
/// bottom sheet snappy on low-end Android.
const int _kPickerMaxResults = 50;

/// Marker that identifies a sale row that was itself created by a
/// previous exchange (see `_submitExchange.notes`). Used as a recursion
/// guard so the picker won't let the cashier "exchange against an
/// exchange" — the audit trail of nested exchanges is unreadable, and
/// the ZATCA credit-note chain only has meaning when refInvoiceId
/// points at a real customer purchase.
///
/// Heuristic by design: a future migration should add a typed
/// `sales.sale_type` column ('sale' | 'exchange' | 'credit_note') so
/// this stops depending on a free-text prefix.
const String _kExchangeSaleNotePrefix = 'Exchange sale —';

// ============================================================================
// State
// ============================================================================

@immutable
class _ExchangeState {
  final SalesTableData? originalSale;
  final List<ProductsTableData> returnSearchResults;
  final List<ProductsTableData> newSearchResults;
  final List<_ExchangeItem> returnItems;
  final List<_ExchangeItem> newItems;
  final bool isSubmitting;

  const _ExchangeState({
    this.originalSale,
    this.returnSearchResults = const [],
    this.newSearchResults = const [],
    this.returnItems = const [],
    this.newItems = const [],
    this.isSubmitting = false,
  });

  _ExchangeState copyWith({
    SalesTableData? originalSale,
    List<ProductsTableData>? returnSearchResults,
    List<ProductsTableData>? newSearchResults,
    List<_ExchangeItem>? returnItems,
    List<_ExchangeItem>? newItems,
    bool? isSubmitting,
  }) => _ExchangeState(
    originalSale: originalSale ?? this.originalSale,
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

  void setOriginalSale(SalesTableData sale) =>
      state = state.copyWith(originalSale: sale);

  /// Resets state including originalSale. Used after a successful submit
  /// — copyWith's nullable-default pattern can't unset originalSale, so
  /// we replace state wholesale.
  void resetAll() => state = const _ExchangeState();

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildOriginalSaleCard(isDark, l10n, s),
                SizedBox(
                  height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                ),
                if (isWideScreen)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildReturnSection(isDark, l10n, s)),
                      const SizedBox(width: AlhaiSpacing.lg),
                      Expanded(child: _buildNewItemsSection(isDark, l10n, s)),
                    ],
                  )
                else
                  Column(
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

  /// Header card for the original-sale anchor. Empty state = full-width
  /// CTA. Selected state = receipt summary chip with a "change" affordance.
  ///
  /// Wave 3b-2a context: every refund (the return half of an exchange)
  /// must FK to the customer's original sale, not the just-created
  /// exchange-output sale. The card is the only entry point for that
  /// linkage from this screen.
  Widget _buildOriginalSaleCard(
    bool isDark,
    AppLocalizations l10n,
    _ExchangeState s,
  ) {
    final selected = s.originalSale;
    if (selected == null) {
      return InkWell(
        onTap: () => _pickOriginalSale(l10n),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4),
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.md),
              Expanded(
                child: Text(
                  l10n.selectOriginalSaleTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      );
    }

    final receipt = selected.receiptNo;
    final totalSar = selected.total / 100.0;
    final dateStr =
        '${selected.createdAt.day}/${selected.createdAt.month}/${selected.createdAt.year}';
    final customerLine = selected.customerName?.trim().isNotEmpty == true
        ? selected.customerName!
        : l10n.cashCustomer;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 22,
            ),
          ),
          const SizedBox(width: AlhaiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.originalSaleLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextMuted(isDark),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$receipt \u2022 ${CurrencyFormatter.formatWithContext(context, totalSar)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$customerLine \u2022 $dateStr',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => _pickOriginalSale(l10n),
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: Text(l10n.changeOriginalSale),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.sm,
                vertical: AlhaiSpacing.xs,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Modal bottom sheet \u2014 recent eligible sales + receipt-number filter.
  /// Eligibility (applied client-side once the data is loaded):
  ///   * status \u2208 {'completed', 'paid'} \u2014 voided/refunded stay out.
  ///   * createdAt within `_kReturnPolicyDays` of now.
  ///   * notes does NOT begin with `_kExchangeSaleNotePrefix`
  ///     (recursion guard \u2014 see constant docstring).
  ///   * sumRefundedCents < total (skip fully-refunded sales).
  Future<void> _pickOriginalSale(AppLocalizations l10n) async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return;

    final now = DateTime.now();
    final start = now.subtract(const Duration(days: _kReturnPolicyDays));

    // Pull both feeds up-front. Parallel-await: sales and the small return
    // ledger of the same store. The aggregated refund map costs one pass.
    final salesFuture = _db.salesDao.getSalesByDateRange(storeId, start, now);
    final returnsFuture = _db.returnsDao.getAllReturns(storeId);
    final results = await Future.wait([salesFuture, returnsFuture]);
    final allSales = results[0] as List<SalesTableData>;
    final allReturns = results[1] as List<ReturnsTableData>;

    final refundedBySaleId = <String, int>{};
    for (final r in allReturns) {
      refundedBySaleId.update(
        r.saleId,
        (prev) => prev + r.totalRefund,
        ifAbsent: () => r.totalRefund,
      );
    }

    bool eligible(SalesTableData s) {
      if (s.status != 'completed' && s.status != 'paid') return false;
      final notes = s.notes;
      if (notes != null && notes.startsWith(_kExchangeSaleNotePrefix)) {
        return false;
      }
      final refunded = refundedBySaleId[s.id] ?? 0;
      if (refunded >= s.total) return false;
      return true;
    }

    final eligibleSales = allSales.where(eligible).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final initial = eligibleSales.take(_kPickerMaxResults).toList();

    if (!mounted) return;

    final picked = await showModalBottomSheet<SalesTableData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OriginalSalePickerSheet(
        all: initial,
        l10n: l10n,
        policyDays: _kReturnPolicyDays,
      ),
    );

    if (picked != null && mounted) {
      ref.read(_exchangeProvider.notifier).setOriginalSale(picked);
    }
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
    // Wave 3b-2a: when there are returnItems, the picker has to be
    // satisfied first. Disabling the button up-front beats letting the
    // user tap and then read the same fact from a dialog.
    final missingAnchor =
        s.returnItems.isNotEmpty && s.originalSale == null;

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
                onPressed: s.isSubmitting || !hasItems || missingAnchor
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

    // Wave 3b-2a: returnItems force a real anchor sale. The return's FK
    // now lands on the customer's original purchase, not the just-created
    // exchange-output sale, so the picker is mandatory whenever the
    // exchange involves a refund leg. (Pure-new-items happens only via
    // the "no returnItems" branch, where no anchor is needed.)
    final originalSale = snap.originalSale;
    if (returnItemsSnap.isNotEmpty && originalSale == null) {
      notifier.setSubmitting(false);
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.errorOccurred),
          content: Text(l10n.originalSaleRequired),
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
      // Inherit customer identity from the picked original sale so the
      // new exchange-output sale shows up in the same customer's history
      // (and any AR / loyalty pipeline keyed off customerId continues
      // to work). Falls back to null when the original was a walk-in or
      // when there's no return leg at all.
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
        customerId: originalSale?.customerId,
        customerName: originalSale?.customerName,
        notes: returnItemsSnap.isNotEmpty
            ? 'Exchange sale — linked to return of '
                  '${returnItemsSnap.length} item(s), offset '
                  '${returnTotal.toStringAsFixed(2)} SAR '
                  '(originalSaleId=${originalSale?.id})'
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

        // Wave 3b-2a: anchor the return to the customer's ORIGINAL sale
        // (picked via _OriginalSalePickerSheet), not the just-created
        // exchange-output sale. This is what makes the max-refund guard
        // in createReturn meaningful — the guard now compares against the
        // real prior purchase, and the ZATCA credit-note (issued inside
        // createReturn) references the right invoice on the portal.
        // `originalSale` is non-null here: enforced by the pre-flight
        // guard above when returnItems are present.
        await createReturn(
          ref,
          saleId: originalSale!.id,
          customerId: originalSale.customerId,
          customerName: originalSale.customerName,
          reason: 'exchange',
          totalRefund: returnTotalWithVat,
          refundMethod: 'cash',
          notes:
              'Exchange transaction — offsetting new items '
              '${newTotal.toStringAsFixed(2)} SAR '
              '(diff=${balanceDiff.toStringAsFixed(2)} SAR, '
              'newSaleId=$createdSaleId)',
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
      notifier.resetAll();
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

// ============================================================================
// Original-sale picker bottom sheet (Wave 3b-2a)
// ============================================================================

/// Stateless-from-the-outside picker. Receives a pre-filtered list of
/// eligible sales (parent applied recursion / status / refund-window
/// guards) and lets the cashier pick one. Returns the picked
/// [SalesTableData] via [Navigator.pop], or null if dismissed.
class _OriginalSalePickerSheet extends StatefulWidget {
  final List<SalesTableData> all;
  final AppLocalizations l10n;
  final int policyDays;

  const _OriginalSalePickerSheet({
    required this.all,
    required this.l10n,
    required this.policyDays,
  });

  @override
  State<_OriginalSalePickerSheet> createState() =>
      _OriginalSalePickerSheetState();
}

class _OriginalSalePickerSheetState extends State<_OriginalSalePickerSheet> {
  final _filterController = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filter = _filter.trim().toLowerCase();
    final visible = filter.isEmpty
        ? widget.all
        : widget.all.where((s) {
            if (s.receiptNo.toLowerCase().contains(filter)) return true;
            final cn = s.customerName?.toLowerCase();
            return cn != null && cn.contains(filter);
          }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: AlhaiSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.getTextMuted(isDark),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.l10n.selectOriginalSaleTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: widget.l10n.close,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.md,
                vertical: AlhaiSpacing.xs,
              ),
              child: TextField(
                controller: _filterController,
                onChanged: (v) => setState(() => _filter = v),
                decoration: InputDecoration(
                  hintText: widget.l10n.searchByReceiptNumber,
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: AppColors.getSurfaceVariant(isDark),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: AlhaiSpacing.md,
                end: AlhaiSpacing.md,
                top: AlhaiSpacing.sm,
                bottom: AlhaiSpacing.xs,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  widget.l10n.recentSalesLastNDays(widget.policyDays),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextSecondary(isDark),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            Expanded(
              child: visible.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AlhaiSpacing.lg),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 48,
                              color: AppColors.getTextMuted(isDark),
                            ),
                            const SizedBox(height: AlhaiSpacing.sm),
                            Text(
                              widget.l10n.noEligibleSalesFound(
                                widget.policyDays,
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.getTextSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.md,
                        vertical: AlhaiSpacing.xs,
                      ),
                      itemCount: visible.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AlhaiSpacing.xs),
                      itemBuilder: (_, i) => _buildSaleTile(visible[i], isDark),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleTile(SalesTableData sale, bool isDark) {
    final totalSar = sale.total / 100.0;
    final dateStr =
        '${sale.createdAt.day}/${sale.createdAt.month}/${sale.createdAt.year}';
    final time =
        '${sale.createdAt.hour.toString().padLeft(2, '0')}:${sale.createdAt.minute.toString().padLeft(2, '0')}';
    final customer = sale.customerName?.trim().isNotEmpty == true
        ? sale.customerName!
        : widget.l10n.cashCustomer;
    return InkWell(
      onTap: () => Navigator.of(context).pop(sale),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.getSurfaceVariant(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.getBorder(isDark).withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sale.receiptNo,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$customer • $dateStr $time',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              CurrencyFormatter.formatWithContext(context, totalSar),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
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
