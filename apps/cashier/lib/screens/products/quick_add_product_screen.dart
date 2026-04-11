/// Quick Add Product Screen - Fast product entry for cashiers
///
/// Minimal form: name, barcode (scan), price, category, quantity.
/// Saves to productsDao for fast cashier entry.
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

  List<CategoriesTableData> _categories = [];
  String? _selectedCategoryId;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDirty = false; // M65: unsaved changes tracking
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
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
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final categories = await _db.categoriesDao.getAllCategories(storeId);
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      reportError(
        e,
        stackTrace: stack,
        hint: 'Load categories for quick add product',
      );
      if (mounted) {
        setState(() {
          _error = '$e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    return PopScope(
      canPop: !_isDirty,
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
            title: 'Quick Add Product',
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
                  _buildBasicInfoCard(isDark, l10n),
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
                  _buildSaveButton(isDark, l10n),
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
          _buildBasicInfoCard(isDark, l10n),
          SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
          _buildBarcodeCard(isDark, l10n),
          SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
          _buildPricingCard(isDark, l10n),
          const SizedBox(height: AlhaiSpacing.lg),
          _buildSaveButton(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(bool isDark, AppLocalizations l10n) {
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
              Text(
                'Product Info',
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
            onChanged: (_) {
              if (!_isDirty) setState(() => _isDirty = true);
            },
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
          DropdownButtonFormField<String>(
            initialValue: _selectedCategoryId,
            style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            dropdownColor: AppColors.getSurface(isDark),
            decoration: _inputDecoration(
              'Category',
              Icons.category_rounded,
              isDark,
            ),
            items: _categories.map((cat) {
              return DropdownMenuItem<String>(
                value: cat.id,
                child: Text(cat.name),
              );
            }).toList(),
            onChanged: (v) => setState(() => _selectedCategoryId = v),
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
                  onChanged: (_) {
                    if (!_isDirty) setState(() => _isDirty = true);
                  },
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
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: _scanBarcode,
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
              Text(
                'Pricing Info',
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
            onChanged: (_) {
              if (!_isDirty) setState(() => _isDirty = true);
            },
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
            validator: FormValidators.price(required: true, allowZero: false),
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
          // Quantity
          TextFormField(
            controller: _quantityController,
            focusNode: _quantityFocus,
            textInputAction: TextInputAction.done,
            onChanged: (_) {
              if (!_isDirty) setState(() => _isDirty = true);
            },
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
              final isSelected = _quantityController.text == qty.toString();
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _quantityController.text = qty.toString();
                    setState(() {});
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
    );
  }

  Widget _buildSaveButton(bool isDark, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSaving ? null : _saveProduct,
        icon: _isSaving
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

  void _scanBarcode() {
    // Barcode scanning placeholder - will use camera/scanner
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.enterBarcodeManually),
        backgroundColor: AppColors.info,
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context);

    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) throw Exception('No store selected');

      final productId = const Uuid().v4();
      final price =
          double.tryParse(
            InputSanitizer.sanitizeDecimal(_priceController.text),
          ) ??
          0.0;
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

      await _db.productsDao.insertProduct(
        ProductsTableCompanion.insert(
          id: productId,
          storeId: storeId,
          name: sanitizedName,
          price: price,
          barcode: Value(sanitizedBarcode.isNotEmpty ? sanitizedBarcode : null),
          categoryId: Value(_selectedCategoryId),
          stockQty: Value(quantity.toDouble()),
          createdAt: DateTime.now(),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // Audit log
      final user = ref.read(currentUserProvider);
      auditService.logProductCreate(
        storeId: storeId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        productId: productId,
        productName: sanitizedName,
        price: price,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.productAddedSuccess),
          backgroundColor: AppColors.success,
        ),
      );

      // Clear form for next product
      _nameController.clear();
      _barcodeController.clear();
      _priceController.clear();
      _quantityController.text = '1';
      setState(() {
        _selectedCategoryId = null;
        _isDirty = false;
      });
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save quick add product');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorWithDetails('$e')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
