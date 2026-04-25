/// Add Inventory Screen - Add stock for a product
///
/// Search/scan product, quantity to add, supplier reference, note.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
///
/// State model:
/// - Business state → [AddInventoryState] via [_addInventoryProvider]
///   (search results, selectedProduct, searching, saving flags). Replaces
///   the historic six `setState` sites.
/// - Pure UI transient state → local `Timer? _searchDebounce` +
///   `TextEditingController` values only. The chip-highlight for the quick
///   quantity chips piggybacks on `ValueListenableBuilder` rather than
///   `setState(() {})`.
library;

import 'dart:async';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:uuid/uuid.dart';
import 'package:alhai_database/alhai_database.dart';
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';
import '../../core/services/audit_service.dart';

// ============================================================================
// State
// ============================================================================

@immutable
class AddInventoryState {
  final List<ProductsTableData> searchResults;
  final ProductsTableData? selectedProduct;
  final bool isSearching;
  final bool isSaving;

  const AddInventoryState({
    this.searchResults = const [],
    this.selectedProduct,
    this.isSearching = false,
    this.isSaving = false,
  });

  AddInventoryState copyWith({
    List<ProductsTableData>? searchResults,
    ProductsTableData? selectedProduct,
    bool clearProduct = false,
    bool? isSearching,
    bool? isSaving,
  }) => AddInventoryState(
    searchResults: searchResults ?? this.searchResults,
    selectedProduct: clearProduct
        ? null
        : (selectedProduct ?? this.selectedProduct),
    isSearching: isSearching ?? this.isSearching,
    isSaving: isSaving ?? this.isSaving,
  );
}

class AddInventoryNotifier extends StateNotifier<AddInventoryState> {
  AddInventoryNotifier() : super(const AddInventoryState());

  void clearResults() => state = state.copyWith(searchResults: const []);

  void setSearching(bool v) => state = state.copyWith(isSearching: v);

  void setSearchResults(List<ProductsTableData> list) =>
      state = state.copyWith(searchResults: list, isSearching: false);

  void selectProduct(ProductsTableData product) => state = state.copyWith(
    selectedProduct: product,
    searchResults: const [],
  );

  void clearSelectedProduct() => state = state.copyWith(clearProduct: true);

  void setSaving(bool v) => state = state.copyWith(isSaving: v);

  /// Full reset after a successful save.
  void resetAfterSave() => state = const AddInventoryState();
}

final _addInventoryProvider =
    StateNotifierProvider.autoDispose<AddInventoryNotifier, AddInventoryState>(
      (ref) => AddInventoryNotifier(),
    );

// ============================================================================
// Screen
// ============================================================================

/// شاشة إضافة مخزون
class AddInventoryScreen extends ConsumerStatefulWidget {
  const AddInventoryScreen({super.key});

  @override
  ConsumerState<AddInventoryScreen> createState() => _AddInventoryScreenState();
}

class _AddInventoryScreenState extends ConsumerState<AddInventoryScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _supplierRefController = TextEditingController();
  final _noteController = TextEditingController();
  // Wave 7 (P0-21): optional per-unit cost. When the cashier fills it,
  // the WAVG path on `applyReceiveAndRecomputeCost` recomputes
  // `products.cost_price` against the new receipt. Empty → fall back
  // to "stock-only" semantics (cost_price stays untouched).
  final _unitCostController = TextEditingController();

  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _quantityController.dispose();
    _supplierRefController.dispose();
    _noteController.dispose();
    _unitCostController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.isEmpty) {
      ref.read(_addInventoryProvider.notifier).clearResults();
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _searchProducts(query);
    });
  }

  Future<void> _searchProducts(String query) async {
    final notifier = ref.read(_addInventoryProvider.notifier);
    if (query.isEmpty) {
      notifier.clearResults();
      return;
    }
    notifier.setSearching(true);
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final products = await _db.productsDao.searchProducts(query, storeId);
      if (!mounted) return;
      notifier.setSearchResults(products);
    } catch (e, stack) {
      reportError(
        e,
        stackTrace: stack,
        hint: 'Search products in add inventory',
      );
      if (!mounted) return;
      notifier.setSearching(false);
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

    return Column(
      children: [
        AppHeader(
          title: l10n.addInventory,
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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
            ),
            child: _buildContent(
              isWideScreen,
              isMediumScreen,
              colorScheme,
              l10n,
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
  ) {
    final s = ref.watch(_addInventoryProvider);
    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildSearchCard(colorScheme, l10n, s),
                if (s.searchResults.isNotEmpty && s.selectedProduct == null) ...[
                  const SizedBox(height: AlhaiSpacing.md),
                  _buildSearchResults(colorScheme, l10n, s),
                ],
                if (s.selectedProduct != null) ...[
                  const SizedBox(height: AlhaiSpacing.lg),
                  _buildSelectedProductCard(colorScheme, l10n, s),
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
                _buildDetailsCard(colorScheme, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildSaveButton(colorScheme, l10n, s),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSearchCard(colorScheme, l10n, s),
        if (s.searchResults.isNotEmpty && s.selectedProduct == null) ...[
          SizedBox(height: isMediumScreen ? AlhaiSpacing.md : AlhaiSpacing.sm),
          _buildSearchResults(colorScheme, l10n, s),
        ],
        if (s.selectedProduct != null) ...[
          SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
          _buildSelectedProductCard(colorScheme, l10n, s),
        ],
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildQuantityCard(colorScheme, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildDetailsCard(colorScheme, l10n),
        const SizedBox(height: AlhaiSpacing.lg),
        _buildSaveButton(colorScheme, l10n, s),
      ],
    );
  }

  Widget _buildSearchCard(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    AddInventoryState s,
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.searchProduct,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: colorScheme.onSurface),
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: l10n.searchByNameOrBarcode,
                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLow,
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
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: () {
                    AlhaiSnackbar.info(
                      context,
                      AppLocalizations.of(context).scanOrEnterBarcode,
                    );
                  },
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                  label: Text(l10n.scanLabel),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (s.isSearching)
            const Padding(
              padding: EdgeInsetsDirectional.only(top: AlhaiSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    AddInventoryState s,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: s.searchResults.take(5).map((product) {
          return InkWell(
            onTap: () {
              _searchController.text = product.name;
              ref.read(_addInventoryProvider.notifier).selectProduct(product);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.mdl,
                vertical: 14,
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
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
                          '${l10n.stock}: ${product.stockQty}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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

  Widget _buildSelectedProductCard(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    AddInventoryState s,
  ) {
    final product = s.selectedProduct!;
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.05,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${l10n.currentStock}: ${product.stockQty}',
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
              ref.read(_addInventoryProvider.notifier).clearSelectedProduct();
            },
            icon: Icon(
              Icons.close_rounded,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add_circle_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.quantityToAdd,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          // Quantity field + chips — chip highlight tracks controller value
          // via ValueListenableBuilder (no setState rebuild needed).
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _quantityController,
            builder: (_, __, ___) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+(\.\d{0,2})?$'),
                    ),
                  ],
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 28,
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
                        color: AppColors.success,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLow,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.md),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [1, 5, 10, 25, 50, 100].map((qty) {
                    final isSelected =
                        _quantityController.text == qty.toString();
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _quantityController.text = qty.toString();
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: AlhaiSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.success.withValues(alpha: 0.1)
                                : colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.success.withValues(alpha: 0.5)
                                  : colorScheme.outlineVariant,
                            ),
                          ),
                          child: Text(
                            '$qty',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.success
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(ColorScheme colorScheme, AppLocalizations l10n) {
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
            l10n.supplierReference,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          TextField(
            controller: _supplierRefController,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: l10n.optional,
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              prefixIcon: Icon(
                Icons.business_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
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
          const SizedBox(height: AlhaiSpacing.md),
          // Wave 7 (P0-21): optional unit-cost input. Drives WAVG when
          // filled; left blank, the receipt only bumps stock.
          Text(
            l10n.unitCostLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          TextField(
            controller: _unitCostController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: l10n.unitCostHint,
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              prefixIcon: Icon(
                Icons.attach_money_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
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
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            l10n.noteLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          TextField(
            controller: _noteController,
            maxLines: 3,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: l10n.optionalNote,
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
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

  Widget _buildSaveButton(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    AddInventoryState s,
  ) {
    // Chip-style re-render is driven by quantity controller; here we wrap in
    // ValueListenableBuilder so the button's disabled state tracks typed text
    // without needing setState on the parent.
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _quantityController,
      builder: (_, __, ___) {
        final hasData =
            s.selectedProduct != null &&
            _quantityController.text.isNotEmpty &&
            (double.tryParse(_quantityController.text) ?? 0) > 0;
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: s.isSaving || !hasData ? null : _saveInventory,
            icon: s.isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.save_rounded, size: 20),
            label: Text(
              l10n.save,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
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

  Future<void> _saveInventory() async {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(_addInventoryProvider.notifier);
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final current = ref.read(_addInventoryProvider).selectedProduct;
    if (quantity <= 0 || current == null) return;

    notifier.setSaving(true);

    // Captured outside the tx so the audit log can report the true
    // starting value (read under the tx, not the stale UI snapshot).
    double previousQty = 0;
    double newStock = 0;

    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        notifier.setSaving(false);
        return;
      }
      final movementId = const Uuid().v4();
      final supplierRef = _supplierRefController.text.trim();
      final userNote = _noteController.text.trim();
      final combinedNote = () {
        final parts = <String>[];
        if (userNote.isNotEmpty) parts.add(userNote);
        if (supplierRef.isNotEmpty) parts.add('supplier_ref: $supplierRef');
        return parts.isEmpty ? null : parts.join(' / ');
      }();

      // Wave 7 (P0-21): parse the optional unit-cost field. We accept
      // SAR doubles in the input and convert to int cents at the
      // boundary — DB columns are int cents end-to-end. Empty input
      // → null → WAVG path skips the cost recompute, behaving exactly
      // like the legacy receive flow.
      final unitCostText = _unitCostController.text.trim();
      final int? unitCostCents = unitCostText.isEmpty
          ? null
          : ((double.tryParse(unitCostText) ?? 0) * 100).round();

      await _db.transaction(() async {
        // TOCTOU guard: re-read the product row inside the tx so the
        // movement's previousQty reflects true state, not the snapshot
        // captured when the screen was first opened. Without this,
        // concurrent edits from sync or another device produce
        // inconsistent ledger entries.
        final fresh = await _db.productsDao.getProductById(current.id);
        if (fresh == null) {
          throw StateError('المنتج لم يعد موجوداً');
        }
        previousQty = fresh.stockQty;
        newStock = previousQty + quantity;

        // Wave 7 (P0-19/20): canonical 'receive' type via the renamed
        // DAO helper. Carries the unit cost so the ledger row records
        // what the cashier actually paid; the WAVG roll-up below
        // updates `products.cost_price` separately.
        await _db.inventoryDao.recordReceiveMovement(
          id: movementId,
          productId: current.id,
          storeId: storeId,
          qty: quantity,
          previousQty: previousQty,
          unitCostCents: unitCostCents,
          notes: combinedNote,
          referenceType: 'manual_addition',
        );
        // Wave 7 (P0-21): WAVG cost roll-up. Re-reads the product
        // inside its own tx (transactions are nested via savepoints
        // in Drift) and writes the new stock+cost atomically.
        await _db.productsDao.applyReceiveAndRecomputeCost(
          productId: current.id,
          qty: quantity,
          unitCostCents: unitCostCents,
        );
      });

      // Audit log
      final user = ref.read(currentUserProvider);
      auditService.logStockAdjust(
        storeId: storeId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        productId: current.id,
        productName: current.name,
        oldQty: previousQty,
        newQty: newStock,
        reason: 'إضافة مخزون',
      );

      if (!mounted) return;

      AlhaiSnackbar.success(
        context,
        AppLocalizations.of(context).inventoryUpdatedMsg,
      );

      // Clear form
      _searchController.clear();
      _quantityController.clear();
      _supplierRefController.clear();
      _noteController.clear();
      notifier.resetAfterSave();
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save add inventory');
      if (!mounted) return;
      AlhaiSnackbar.error(context, l10n.errorWithDetails('$e'));
      notifier.setSaving(false);
    }
  }
}
