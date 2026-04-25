/// Transfer Inventory Screen - Transfer stock between stores
///
/// From store (current, read-only), to store dropdown, product search/scan,
/// quantity, note, submit button.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
///
/// State model:
/// - Business state → [TransferInventoryState] via [_transferInventoryProvider]
///   (stores list, selectedToStoreId, search results, selectedProduct,
///   loading/saving flags, error). Replaces 12 historic `setState` sites.
/// - Pure UI transient state → `TextEditingController` values only. The
///   submit button's enable-state tracks quantity text through
///   `ValueListenableBuilder`.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:uuid/uuid.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';
import '../../core/services/audit_service.dart';

// ============================================================================
// State
// ============================================================================

@immutable
class TransferInventoryState {
  final List<StoresTableData> stores;
  final String? toStoreId;
  final List<ProductsTableData> searchResults;
  final ProductsTableData? selectedProduct;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const TransferInventoryState({
    this.stores = const [],
    this.toStoreId,
    this.searchResults = const [],
    this.selectedProduct,
    this.isLoading = true,
    this.isSaving = false,
    this.error,
  });

  TransferInventoryState copyWith({
    List<StoresTableData>? stores,
    String? toStoreId,
    bool clearToStoreId = false,
    List<ProductsTableData>? searchResults,
    ProductsTableData? selectedProduct,
    bool clearSelectedProduct = false,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) => TransferInventoryState(
    stores: stores ?? this.stores,
    toStoreId: clearToStoreId ? null : (toStoreId ?? this.toStoreId),
    searchResults: searchResults ?? this.searchResults,
    selectedProduct: clearSelectedProduct
        ? null
        : (selectedProduct ?? this.selectedProduct),
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    error: clearError ? null : (error ?? this.error),
  );
}

class TransferInventoryNotifier
    extends StateNotifier<TransferInventoryState> {
  TransferInventoryNotifier() : super(const TransferInventoryState());

  void setLoading() =>
      state = state.copyWith(isLoading: true, clearError: true);

  void setStores(List<StoresTableData> list) =>
      state = state.copyWith(stores: list, isLoading: false);

  void setError(String err) =>
      state = state.copyWith(isLoading: false, error: err);

  void setToStoreId(String? id) => state = id == null
      ? state.copyWith(clearToStoreId: true)
      : state.copyWith(toStoreId: id);

  void setSearchResults(List<ProductsTableData> list) =>
      state = state.copyWith(searchResults: list);

  void clearSearchResults() =>
      state = state.copyWith(searchResults: const []);

  void selectProduct(ProductsTableData p) => state = state.copyWith(
    selectedProduct: p,
    searchResults: const [],
  );

  void clearSelectedProduct() =>
      state = state.copyWith(clearSelectedProduct: true);

  void setSaving(bool v) => state = state.copyWith(isSaving: v);

  /// Reset after a successful transfer. Keeps loaded stores + isLoading=false.
  void resetAfterSave() => state = state.copyWith(
    clearSelectedProduct: true,
    clearToStoreId: true,
    searchResults: const [],
    isSaving: false,
  );
}

final _transferInventoryProvider =
    StateNotifierProvider.autoDispose<
      TransferInventoryNotifier,
      TransferInventoryState
    >((ref) => TransferInventoryNotifier());

// ============================================================================
// Screen
// ============================================================================

/// شاشة نقل المخزون
class TransferInventoryScreen extends ConsumerStatefulWidget {
  const TransferInventoryScreen({super.key});

  @override
  ConsumerState<TransferInventoryScreen> createState() =>
      _TransferInventoryScreenState();
}

class _TransferInventoryScreenState
    extends ConsumerState<TransferInventoryScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();

  // P2: Debounce keystrokes on the product search so we don't spawn a
  // DB query per character. 300 ms matches the convention used in
  // add/edit/remove and purchase_request screens.
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStores());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadStores() async {
    final notifier = ref.read(_transferInventoryProvider.notifier);
    notifier.setLoading();
    try {
      final stores = await _db.storesDao.getAllStores();
      final currentStoreId = ref.read(currentStoreIdProvider);
      if (!mounted) return;
      notifier.setStores(
        stores.where((s) => s.id != currentStoreId).toList(),
      );
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load stores for transfer');
      if (!mounted) return;
      notifier.setError('$e');
    }
  }

  /// Debounced entry point wired to the TextField's onChanged. Actual
  /// DB hit is delegated to [_runProductSearch] after 300 ms of idle.
  void _searchProducts(String query) {
    _searchDebounce?.cancel();
    if (query.isEmpty) {
      ref.read(_transferInventoryProvider.notifier).clearSearchResults();
      return;
    }
    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
      () => _runProductSearch(query),
    );
  }

  Future<void> _runProductSearch(String query) async {
    final notifier = ref.read(_transferInventoryProvider.notifier);
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final products = await _db.productsDao.searchProducts(query, storeId);
      if (!mounted) return;
      notifier.setSearchResults(products);
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Search products in transfer');
      if (!mounted) return;
      AlhaiSnackbar.error(
        context,
        AppLocalizations.of(context).errorOccurred,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final s = ref.watch(_transferInventoryProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.transferInventory,
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
          child: s.isLoading
              ? const AppLoadingState()
              : s.error != null
              ? AppErrorState.general(
                  context,
                  message: s.error!,
                  onRetry: _loadStores,
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(
                    isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                  ),
                  child: _buildContent(
                    isWideScreen,
                    isMediumScreen,
                    colorScheme,
                    l10n,
                    s,
                  ),
                ),
        ),
      ],
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} \u2022 ${l10n.mainBranch}';
  }

  Widget _buildContent(
    bool isWideScreen,
    bool isMediumScreen,
    ColorScheme colorScheme,
    AppLocalizations l10n,
    TransferInventoryState s,
  ) {
    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildStoreSelectionCard(colorScheme, l10n, s),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildProductSearchCard(colorScheme, l10n),
                if (s.searchResults.isNotEmpty && s.selectedProduct == null) ...[
                  const SizedBox(height: AlhaiSpacing.md),
                  _buildSearchResults(colorScheme, l10n, s),
                ],
                if (s.selectedProduct != null) ...[
                  const SizedBox(height: AlhaiSpacing.md),
                  _buildSelectedCard(colorScheme, l10n, s),
                ],
              ],
            ),
          ),
          const SizedBox(width: AlhaiSpacing.lg),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildQuantityCard(colorScheme, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildNoteCard(colorScheme, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildSubmitButton(colorScheme, l10n, s),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStoreSelectionCard(colorScheme, l10n, s),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildProductSearchCard(colorScheme, l10n),
        if (s.searchResults.isNotEmpty && s.selectedProduct == null) ...[
          const SizedBox(height: AlhaiSpacing.sm),
          _buildSearchResults(colorScheme, l10n, s),
        ],
        if (s.selectedProduct != null) ...[
          const SizedBox(height: AlhaiSpacing.sm),
          _buildSelectedCard(colorScheme, l10n, s),
        ],
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildQuantityCard(colorScheme, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildNoteCard(colorScheme, l10n),
        const SizedBox(height: AlhaiSpacing.lg),
        _buildSubmitButton(colorScheme, l10n, s),
      ],
    );
  }

  Widget _buildStoreSelectionCard(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    TransferInventoryState s,
  ) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.transferDetails,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          // From store (read-only)
          Text(
            l10n.fromStore,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.store_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.mainBranch,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.xs,
                    vertical: AlhaiSpacing.xxxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.currentLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          // To store dropdown
          Text(
            l10n.toStore,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          DropdownButtonFormField<String>(
            initialValue: s.toStoreId,
            style: TextStyle(color: colorScheme.onSurface),
            dropdownColor: colorScheme.surface,
            decoration: InputDecoration(
              hintText: l10n.selectStore,
              hintStyle: TextStyle(color: colorScheme.outline),
              prefixIcon: Icon(
                Icons.store_mall_directory_rounded,
                color: colorScheme.outline,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.md,
                vertical: 14,
              ),
            ),
            items: s.stores.map((store) {
              return DropdownMenuItem<String>(
                value: store.id,
                child: Text(store.name),
              );
            }).toList(),
            onChanged: (v) =>
                ref.read(_transferInventoryProvider.notifier).setToStoreId(v),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSearchCard(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.searchProduct,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: colorScheme.onSurface),
                  onChanged: _searchProducts,
                  decoration: InputDecoration(
                    hintText: l10n.searchByNameOrBarcode,
                    hintStyle: TextStyle(color: colorScheme.outline),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: colorScheme.outline,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.md,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.info,
                ),
                tooltip: l10n.scanLabel,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.info.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    TransferInventoryState s,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: s.searchResults.take(5).map((product) {
          return InkWell(
            onTap: () {
              _searchController.text = product.name;
              ref
                  .read(_transferInventoryProvider.notifier)
                  .selectProduct(product);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.md,
                vertical: AlhaiSpacing.sm,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '${product.stockQty}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
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

  Widget _buildSelectedCard(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    TransferInventoryState s,
  ) {
    final product = s.selectedProduct!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.05,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.info,
            size: 22,
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
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${l10n.available}: ${product.stockQty}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _searchController.clear();
              ref
                  .read(_transferInventoryProvider.notifier)
                  .clearSelectedProduct();
            },
            icon: Icon(
              Icons.close_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            tooltip: l10n.clearField,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quantity,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          TextField(
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'^\d+(\.\d{0,2})?$'),
              ),
            ],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                color: colorScheme.outline,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.noteLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          TextField(
            controller: _noteController,
            maxLines: 3,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: l10n.optionalNote,
              hintStyle: TextStyle(color: colorScheme.outline),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(AlhaiSpacing.md),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    TransferInventoryState s,
  ) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _quantityController,
      builder: (_, __, ___) {
        final isValid =
            s.selectedProduct != null &&
            s.toStoreId != null &&
            (double.tryParse(_quantityController.text) ?? 0) > 0;
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: s.isSaving || !isValid ? null : _submitTransfer,
            icon: s.isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 20),
            label: Text(
              l10n.submitTransfer,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitTransfer() async {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(_transferInventoryProvider.notifier);
    final s = ref.read(_transferInventoryProvider);
    final qtyDouble = double.tryParse(_quantityController.text) ?? 0;
    if (qtyDouble <= 0 || s.selectedProduct == null || s.toStoreId == null) {
      return;
    }

    notifier.setSaving(true);

    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        notifier.setSaving(false);
        return;
      }
      final product = s.selectedProduct!;
      final toStoreId = s.toStoreId!;

      // Pre-flight: refuse a transfer that would leave the source negative.
      // (UI cap also enforced — defence-in-depth.)
      if (product.stockQty < qtyDouble) {
        notifier.setSaving(false);
        if (mounted) {
          AlhaiSnackbar.error(
            context,
            'الكمية المطلوبة (${qtyDouble.toStringAsFixed(2)}) أكبر من المخزون الحالي (${product.stockQty.toStringAsFixed(2)})',
          );
        }
        return;
      }

      late final ProductsTableData destProduct;
      late final double destPreviousQty;
      late final double destNewQty;
      late final double sourceNewStock;

      await _db.transaction(() async {
        // Re-read the source product inside the transaction to avoid
        // TOCTOU drift if another device adjusted stock since the UI loaded.
        final freshSource = await _db.productsDao.getProductById(product.id);
        if (freshSource == null) {
          throw StateError('المنتج لم يعد موجوداً في المتجر المصدر');
        }
        if (freshSource.stockQty < qtyDouble) {
          throw StateError(
            'المخزون غير كافٍ: المتاح ${freshSource.stockQty.toStringAsFixed(2)}، المطلوب ${qtyDouble.toStringAsFixed(2)}',
          );
        }

        // Match the destination product by SKU then barcode. Each store
        // owns its own product row (storeId-scoped), so a transfer must
        // land on a row that already exists in the destination — otherwise
        // the units would silently vanish.
        final dest = await _db.productsDao.findInStoreBySkuOrBarcode(
          storeId: toStoreId,
          sku: freshSource.sku,
          barcode: freshSource.barcode,
        );
        if (dest == null) {
          throw StateError(
            'المنتج "${freshSource.name}" غير موجود في الفرع المستقبِل — أضفه أولاً ثم أعد المحاولة',
          );
        }
        destProduct = dest;
        destPreviousQty = dest.stockQty;
        destNewQty = destPreviousQty + qtyDouble;
        sourceNewStock = freshSource.stockQty - qtyDouble;

        final userNote = _noteController.text.isNotEmpty
            ? _noteController.text
            : null;

        // Reason column carries a stable enum-style tag only. The
        // store-ids used to be baked into the reason string
        // (`transfer_to_<id>`), which polluted reports and made
        // reason-based aggregations impossible. Stash the counterpart
        // store in `notes` as a tagged prefix alongside the operator's
        // free-form note.
        String composeNotes(String counterpartTag, String counterpartId) {
          final tag = '[$counterpartTag:$counterpartId]';
          return userNote == null ? tag : '$tag $userNote';
        }

        // Wave 7 (P0-19/20/21): switch both legs to canonical DAO
        // helpers. The transfer carries the source product's cost so
        // the destination's WAVG reflects what was actually moved
        // (treat transfer as a zero-margin receive). Drift handles the
        // nested savepoint when applyReceiveAndRecomputeCost opens its
        // own tx inside our outer one.
        final outMovementId = const Uuid().v4();
        await _db.inventoryDao.recordTransferOutMovement(
          id: outMovementId,
          productId: freshSource.id,
          storeId: storeId,
          qty: qtyDouble,
          previousQty: freshSource.stockQty,
          transferId: outMovementId,
          notes: composeNotes('toStoreId', toStoreId),
        );
        await _db.productsDao.updateStock(freshSource.id, sourceNewStock);

        await _db.inventoryDao.recordTransferInMovement(
          id: const Uuid().v4(),
          productId: dest.id,
          storeId: toStoreId,
          qty: qtyDouble,
          previousQty: destPreviousQty,
          transferId: outMovementId,
          unitCostCents: freshSource.costPrice,
          notes: composeNotes('fromStoreId', storeId),
        );
        await _db.productsDao.applyReceiveAndRecomputeCost(
          productId: dest.id,
          qty: qtyDouble,
          unitCostCents: freshSource.costPrice,
        );
      });

      // Audit log (outside the DB transaction). Logs both legs so the
      // ledger reflects the true stock movement on each store.
      final user = ref.read(currentUserProvider);
      auditService.logStockAdjust(
        storeId: storeId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        productId: product.id,
        productName: product.name,
        oldQty: product.stockQty,
        newQty: sourceNewStock,
        reason: 'نقل إلى فرع آخر',
      );
      auditService.logStockAdjust(
        storeId: toStoreId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        productId: destProduct.id,
        productName: destProduct.name,
        oldQty: destPreviousQty,
        newQty: destNewQty,
        reason: 'استلام من فرع آخر',
      );

      if (!mounted) return;

      AlhaiSnackbar.success(context, l10n.transferCompletedSuccess);

      _searchController.clear();
      _quantityController.clear();
      _noteController.clear();
      notifier.resetAfterSave();
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save inventory transfer');
      if (!mounted) return;
      AlhaiSnackbar.error(context, l10n.errorWithDetails('$e'));
      notifier.setSaving(false);
    }
  }
}
