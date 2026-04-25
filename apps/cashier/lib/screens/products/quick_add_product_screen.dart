/// Quick Add Product Screen - Fast product entry for cashiers
///
/// Minimal form: name, barcode (scan), price, category, quantity.
/// Saves to productsDao for fast cashier entry.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
///
/// State model:
/// - Business state → [QuickAddProductState] via [_quickAddProductProvider]
///   (categories list, loading flag, saving flag, dirty flag, error, selected
///   categoryId). Immutable `copyWith` updates replace the historic
///   `setState` cascade.
/// - Pure UI transient state → local `TextEditingController` values only
///   (no setState needed to rebuild; controllers already notify listeners
///   bound through `ValueListenableBuilder` where a visual chip highlight
///   must follow the typed value).
library;

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

/// Immutable state for the Quick-Add-Product form.
@immutable
class QuickAddProductState {
  final List<CategoriesTableData> categories;
  final String? selectedCategoryId;
  final bool isLoading;
  final bool isSaving;
  final bool isDirty;
  final String? error;

  const QuickAddProductState({
    this.categories = const [],
    this.selectedCategoryId,
    // Defaults to loading=true so the first frame shows the spinner while
    // `_loadCategories()` runs via addPostFrameCallback. Matches the pre-
    // refactor behaviour where setState(isLoading=true) fired synchronously
    // in initState (see `shows loading indicator while loading categories`).
    this.isLoading = true,
    this.isSaving = false,
    this.isDirty = false,
    this.error,
  });

  QuickAddProductState copyWith({
    List<CategoriesTableData>? categories,
    String? selectedCategoryId,
    bool clearCategoryId = false,
    bool? isLoading,
    bool? isSaving,
    bool? isDirty,
    String? error,
    bool clearError = false,
  }) => QuickAddProductState(
    categories: categories ?? this.categories,
    selectedCategoryId: clearCategoryId
        ? null
        : (selectedCategoryId ?? this.selectedCategoryId),
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    isDirty: isDirty ?? this.isDirty,
    error: clearError ? null : (error ?? this.error),
  );
}

class QuickAddProductNotifier extends StateNotifier<QuickAddProductState> {
  QuickAddProductNotifier() : super(const QuickAddProductState());

  void setCategories(List<CategoriesTableData> categories) =>
      state = state.copyWith(categories: categories);

  void selectCategory(String? id) => state = id == null
      ? state.copyWith(clearCategoryId: true, isDirty: true)
      : state.copyWith(selectedCategoryId: id, isDirty: true);

  void markDirty() {
    if (!state.isDirty) state = state.copyWith(isDirty: true);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading, clearError: loading);
  }

  void setError(String err) =>
      state = state.copyWith(isLoading: false, error: err);

  void setSaving(bool saving) => state = state.copyWith(isSaving: saving);

  /// Reset after a successful save — keeps categories so the next product
  /// entry doesn't re-fetch. Clears category selection + dirty flag.
  void resetAfterSave() => state = state.copyWith(
    clearCategoryId: true,
    isDirty: false,
    isSaving: false,
  );
}

final _quickAddProductProvider =
    StateNotifierProvider.autoDispose<
      QuickAddProductNotifier,
      QuickAddProductState
    >((ref) => QuickAddProductNotifier());

// ============================================================================
// Screen
// ============================================================================

/// شاشة إضافة منتج سريع
class QuickAddProductScreen extends ConsumerStatefulWidget {
  const QuickAddProductScreen({super.key});

  @override
  ConsumerState<QuickAddProductScreen> createState() =>
      _QuickAddProductScreenState();
}

class _QuickAddProductScreenState extends ConsumerState<QuickAddProductScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _formKey = GlobalKey<FormState>();

  // Focus nodes for field navigation (M59)
  final _nameFocus = FocusNode();
  final _barcodeFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _quantityFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCategories());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _nameFocus.dispose();
    _barcodeFocus.dispose();
    _priceFocus.dispose();
    _quantityFocus.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final notifier = ref.read(_quickAddProductProvider.notifier);
    notifier.setLoading(true);
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        notifier.setLoading(false);
        return;
      }
      final categories = await _db.categoriesDao.getAllCategories(storeId);
      if (!mounted) return;
      notifier.setCategories(categories);
      notifier.setLoading(false);
    } catch (e, stack) {
      reportError(
        e,
        stackTrace: stack,
        hint: 'Load categories for quick add product',
      );
      if (!mounted) return;
      notifier.setError('$e');
    }
  }

  void _markDirtyIfNeeded() =>
      ref.read(_quickAddProductProvider.notifier).markDirty();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final s = ref.watch(_quickAddProductProvider);

    return PopScope(
      canPop: !s.isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: AlertDialog(
              title: Text(AppLocalizations.of(context).unsavedChanges),
              content: Text(AppLocalizations.of(context).leaveWithoutSaving),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(AppLocalizations.of(context).cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(AppLocalizations.of(context).leave),
                ),
              ],
            ),
          ),
        );
        if (shouldPop == true && context.mounted) Navigator.pop(context);
      },
      child: Column(
        children: [
          AppHeader(
            // P2 #12 (2026-04-24): hardcoded English replaced with Arabic;
            // no dedicated l10n key exists yet and the Saudi market default
            // is Arabic.
            title: 'إضافة منتج سريعة',
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
                    onRetry: _loadCategories,
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.all(
                      isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: _buildContent(
                          isWideScreen,
                          isMediumScreen,
                          isDark,
                          l10n,
                          s,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} \u2022 ${l10n.mainBranch}';
  }

  Widget _buildContent(
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
    QuickAddProductState s,
  ) {
    if (isWideScreen) {
      return Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _buildBasicInfoCard(isDark, l10n, s),
                  const SizedBox(height: AlhaiSpacing.lg),
                  _buildBarcodeCard(isDark, l10n),
                ],
              ),
            ),
            const SizedBox(width: AlhaiSpacing.lg),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildPricingCard(isDark, l10n),
                  const SizedBox(height: AlhaiSpacing.lg),
                  _buildSaveButton(isDark, l10n, s),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBasicInfoCard(isDark, l10n, s),
          SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
          _buildBarcodeCard(isDark, l10n),
          SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
          _buildPricingCard(isDark, l10n),
          const SizedBox(height: AlhaiSpacing.lg),
          _buildSaveButton(isDark, l10n, s),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(
    bool isDark,
    AppLocalizations l10n,
    QuickAddProductState s,
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              // P2 #12 (2026-04-24): hardcoded English replaced with Arabic.
              Text(
                'معلومات المنتج',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          // Product name
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _barcodeFocus.requestFocus(),
            onChanged: (_) => _markDirtyIfNeeded(),
            style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            maxLength: 200,
            validator: FormValidators.requiredField(
              fieldName: l10n.productName,
            ),
            decoration: _inputDecoration(
              l10n.productName,
              Icons.label_rounded,
              isDark,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          // Category dropdown
          // P2 #12/#13 (2026-04-24): hardcoded hint replaced with Arabic and
          // validator added so the user is forced to pick a category before
          // saving — previously a null `selectedCategoryId` silently landed
          // in `categoryId` and was rolled up under 'uncategorized' in the
          // inventory report.
          DropdownButtonFormField<String>(
            initialValue: s.selectedCategoryId,
            style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            dropdownColor: AppColors.getSurface(isDark),
            decoration: _inputDecoration(
              'الفئة',
              Icons.category_rounded,
              isDark,
            ),
            items: s.categories.map((cat) {
              return DropdownMenuItem<String>(
                value: cat.id,
                child: Text(cat.name),
              );
            }).toList(),
            onChanged: (v) =>
                ref.read(_quickAddProductProvider.notifier).selectCategory(v),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'يرجى اختيار فئة' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeCard(bool isDark, AppLocalizations l10n) {
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
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.barcode,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _barcodeController,
                  focusNode: _barcodeFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _priceFocus.requestFocus(),
                  onChanged: (_) => _markDirtyIfNeeded(),
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                  validator: FormValidators.barcode(required: false),
                  decoration: _inputDecoration(
                    l10n.barcode,
                    Icons.qr_code_rounded,
                    isDark,
                  ),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              // P2 #11 (2026-04-24): barcode camera scan is still a
              // placeholder (no plugin wiring). Disable the button and add a
              // tooltip so cashiers can immediately see the feature is
              // pending rather than tapping and dismissing a transient
              // snackbar. Manual entry remains via the barcode text field.
              Tooltip(
                message: '${l10n.comingSoon} \u2014 مسح الباركود',
                child: SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.camera_alt_rounded, size: 20),
                    label: Text(l10n.scan),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.info,
                      foregroundColor: AppColors.textOnPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(bool isDark, AppLocalizations l10n) {
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
                  Icons.attach_money_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              // P2 #12 (2026-04-24): hardcoded English replaced with Arabic.
              Text(
                'معلومات التسعير',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          // Price
          TextFormField(
            controller: _priceController,
            focusNode: _priceFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _quantityFocus.requestFocus(),
            onChanged: (_) => _markDirtyIfNeeded(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            // P1 #14 (2026-04-24): constrain to decimal + 2 fractional digits
            // so the user can't paste arbitrary text. Mirrors edit_price_screen.
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'^\d*(?:\.\d{0,2})?'),
              ),
            ],
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
            // P1 #14: 100M SAR cap — FormValidators.price supports maxValue,
            // rejecting ridiculous amounts before they hit the DAO.
            validator: FormValidators.price(
              required: true,
              allowZero: false,
              maxValue: 100000000,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: TextStyle(
                color: AppColors.getTextMuted(isDark),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              suffixText: l10n.sar,
              suffixStyle: TextStyle(
                fontSize: 14,
                color: AppColors.getTextSecondary(isDark),
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(AlhaiSpacing.sm),
                child: Icon(
                  Icons.sell_rounded,
                  size: 24,
                  color: AppColors.success,
                ),
              ),
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.getSurfaceVariant(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          // Quantity — wrapped in ValueListenableBuilder so the chip highlight
          // below reacts to text changes without a setState rebuild.
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _quantityController,
            builder: (_, __, ___) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _quantityController,
                  focusNode: _quantityFocus,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => _markDirtyIfNeeded(),
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                  validator: FormValidators.quantity(
                    required: true,
                    allowZero: false,
                  ),
                  decoration: _inputDecoration(
                    l10n.quantity,
                    Icons.numbers_rounded,
                    isDark,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.md),
                // Quick quantity chips
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
                          _markDirtyIfNeeded();
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: AlhaiSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : AppColors.getSurfaceVariant(isDark),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.5)
                                  : AppColors.getBorder(isDark),
                            ),
                          ),
                          child: Text(
                            '$qty',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.getTextSecondary(isDark),
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

  Widget _buildSaveButton(
    bool isDark,
    AppLocalizations l10n,
    QuickAddProductState s,
  ) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: s.isSaving ? null : _saveProduct,
        icon: s.isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textOnPrimary,
                ),
              )
            : const Icon(Icons.save_rounded, size: 20),
        label: Text(
          l10n.save,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
      prefixIcon: Icon(icon, color: AppColors.getTextMuted(isDark)),
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
    );
  }

  // P2 #11 (2026-04-24): `_scanBarcode` is retired — the "scan" button is
  // disabled with a "coming soon" tooltip until the camera plugin is wired
  // up. Removing the method silences an `unused_element` analyzer warning.

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(_quickAddProductProvider.notifier);
    notifier.setSaving(true);
    final l10n = AppLocalizations.of(context);

    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) throw Exception('No store selected');

      final productId = const Uuid().v4();
      // C-4 Stage B: user-typed SAR → int cents for storage.
      final priceDouble =
          double.tryParse(
            InputSanitizer.sanitizeDecimal(_priceController.text),
          ) ??
          0.0;
      final price = (priceDouble * 100).round();
      final quantity =
          int.tryParse(
            InputSanitizer.sanitizeNumeric(_quantityController.text),
          ) ??
          0;
      final sanitizedName = InputSanitizer.sanitize(
        _nameController.text.trim(),
      );
      final sanitizedBarcode = InputSanitizer.sanitize(
        _barcodeController.text.trim(),
      );
      final selectedCategoryId = ref
          .read(_quickAddProductProvider)
          .selectedCategoryId;

      // P1 #13 (2026-04-24): reject duplicate barcodes before INSERT. Without
      // this check we could wind up with two products sharing a barcode which
      // breaks scanner-based POS (`quickFindByBarcode` returns a single row).
      // Only runs when a non-empty barcode was entered.
      if (sanitizedBarcode.isNotEmpty) {
        final existing = await _db.productsDao.getProductByBarcode(
          sanitizedBarcode,
          storeId,
        );
        if (existing != null) {
          if (!mounted) return;
          AlhaiSnackbar.warning(context, 'باركود مكرر');
          notifier.setSaving(false);
          return;
        }
      }

      // Wave 10 (P0-26): when the user enters opening stock > 0, the
      // legacy flow inserted the product with `stockQty` set but
      // recorded NO inventory_movement row. The audit ledger then
      // claimed the product had zero historical stock — COGS, FIFO
      // valuation, and stock-take reconciliation all started from a
      // false floor. Pair the product insert with a 'receive' movement
      // (canonical type from Wave 7) so the ledger faithfully shows
      // the opening balance entered the system on day one.
      final user = ref.read(currentUserProvider);
      final stockQtyDouble = quantity.toDouble();
      await _db.transaction(() async {
        await _db.productsDao.insertProduct(
          ProductsTableCompanion.insert(
            id: productId,
            storeId: storeId,
            name: sanitizedName,
            price: price,
            barcode: Value(
              sanitizedBarcode.isNotEmpty ? sanitizedBarcode : null,
            ),
            categoryId: Value(selectedCategoryId),
            stockQty: Value(stockQtyDouble),
            createdAt: DateTime.now(),
            updatedAt: Value(DateTime.now()),
          ),
        );

        if (stockQtyDouble > 0) {
          await _db.inventoryDao.recordReceiveMovement(
            id: const Uuid().v4(),
            productId: productId,
            storeId: storeId,
            qty: stockQtyDouble,
            previousQty: 0,
            referenceType: 'opening_stock',
            referenceId: productId,
            userId: user?.id,
            notes: 'Opening stock on product creation',
          );
        }
      });

      // Audit log — audit API uses double SAR; pass the pre-conversion value.
      auditService.logProductCreate(
        storeId: storeId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        productId: productId,
        productName: sanitizedName,
        price: priceDouble,
      );

      if (!mounted) return;

      AlhaiSnackbar.success(context, l10n.productAddedSuccess);

      // Clear form for next product
      _nameController.clear();
      _barcodeController.clear();
      _priceController.clear();
      _quantityController.text = '1';
      notifier.resetAfterSave();
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save quick add product');
      if (!mounted) return;
      AlhaiSnackbar.error(context, l10n.errorWithDetails('$e'));
      notifier.setSaving(false);
    }
  }
}
