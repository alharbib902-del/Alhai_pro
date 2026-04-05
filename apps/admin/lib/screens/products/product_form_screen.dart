import 'dart:math' show min;

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/providers/unsaved_changes_provider.dart';

/// Admin Product Form Screen - Add/Edit product
class ProductFormScreen extends ConsumerStatefulWidget {
  final String? productId;

  const ProductFormScreen({super.key, this.productId});

  bool get isEditing => productId != null;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _minStockController = TextEditingController(text: '1');

  // Focus nodes for field navigation (M59)
  final _nameFocus = FocusNode();
  final _nameEnFocus = FocusNode();
  final _barcodeFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _costFocus = FocusNode();
  final _stockFocus = FocusNode();
  final _minStockFocus = FocusNode();

  // State
  String? _selectedCategoryId;
  bool _isActive = true;
  bool _trackInventory = true;
  bool _isSaving = false;
  bool _isLoadingProduct = false;
  bool _isDirty = false; // M65: unsaved changes tracking
  List<CategoriesTableData> _categories = [];

  void _setDirty(bool value) {
    if (_isDirty != value) {
      setState(() => _isDirty = value);
      ref.read(unsavedChangesProvider.notifier).state = value;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.isEditing) {
      _loadProduct();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? kDefaultStoreId;
      final cats = await db.categoriesDao.getAllCategories(storeId);
      if (mounted) {
        setState(() => _categories = cats);
      }
    } catch (_) {
      // Categories loading failed silently
    }
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoadingProduct = true);
    try {
      final db = getIt<AppDatabase>();
      final product = await db.productsDao.getProductById(widget.productId!);
      if (product != null && mounted) {
        setState(() {
          _nameController.text = product.name;
          _barcodeController.text = product.barcode ?? '';
          _priceController.text = product.price.toStringAsFixed(2);
          _costController.text = product.costPrice?.toStringAsFixed(2) ?? '';
          _stockController.text = product.stockQty.toString();
          _minStockController.text = product.minQty.toString();
          _selectedCategoryId = product.categoryId;
          _isActive = product.isActive;
          _trackInventory = product.trackInventory;
          _isLoadingProduct = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProduct = false);
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithDetails('$e'))),
        );
      }
    }
  }

  @override
  void dispose() {
    // Clear unsaved changes flag when leaving
    ref.read(unsavedChangesProvider.notifier).state = false;
    _nameController.dispose();
    _nameEnController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _nameFocus.dispose();
    _nameEnFocus.dispose();
    _barcodeFocus.dispose();
    _priceFocus.dispose();
    _costFocus.dispose();
    _stockFocus.dispose();
    _minStockFocus.dispose();
    super.dispose();
  }

  Future<bool> _showUnsavedDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: min(
            MediaQuery.of(context).size.width * 0.9,
            AlhaiBreakpoints.maxDialogWidth,
          ),
        ),
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
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop ||
        (isLandscape && size.width >= 600);
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
            const _SaveIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const _DismissFormIntent(),
      },
      child: Actions(
        actions: {
          _SaveIntent: CallbackAction<_SaveIntent>(
            onInvoke: (_) {
              _saveProduct();
              return null;
            },
          ),
          _DismissFormIntent: CallbackAction<_DismissFormIntent>(
            onInvoke: (_) async {
              if (_isDirty) {
                final shouldLeave = await _showUnsavedDialog();
                if (shouldLeave && mounted) context.pop();
              } else {
                if (mounted) context.pop();
              }
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: PopScope(
            canPop: !_isDirty,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              final shouldPop = await _showUnsavedDialog();
              if (shouldPop && context.mounted) Navigator.pop(context);
            },
            child: SafeArea(
              child: Column(
                children: [
                  AppHeader(
                    title:
                        widget.isEditing ? l10n.editProduct : l10n.addProduct,
                    onMenuTap: isWideScreen
                        ? null
                        : () => Scaffold.of(context).openDrawer(),
                    onNotificationsTap: () => context.push('/notifications'),
                    notificationsCount: 0,
                    userName: l10n.defaultUserName,
                    userRole: l10n.branchManager,
                  ),
                  Expanded(
                    child: _isLoadingProduct
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                            child: _buildContent(
                                isWideScreen, isMediumScreen, isDark, l10n),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button + title
        Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_forward_rounded
                  : Icons.arrow_back_rounded),
              tooltip: l10n.back,
            ),
            const SizedBox(width: AlhaiSpacing.xs),
            Expanded(
              child: Text(
                widget.isEditing ? l10n.editProduct : l10n.addProduct,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.md),

        // Form content - M121: constrain form width on desktop
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: isWideScreen
                  ? _buildWideLayout(isDark, l10n)
                  : _buildNarrowLayout(isDark, l10n),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout(bool isDark, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: basic info + pricing
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildImageSection(isDark, l10n),
              const SizedBox(height: AlhaiSpacing.mdl),
              _buildBasicInfoSection(isDark, l10n),
              const SizedBox(height: AlhaiSpacing.mdl),
              _buildPricingSection(isDark, l10n),
            ],
          ),
        ),
        const SizedBox(width: AlhaiSpacing.lg),
        // Right column: stock + settings + save
        Expanded(
          child: Column(
            children: [
              _buildStockSection(isDark, l10n),
              const SizedBox(height: AlhaiSpacing.mdl),
              _buildSettingsSection(isDark, l10n),
              const SizedBox(height: AlhaiSpacing.lg),
              _buildSaveButton(isDark, l10n),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        _buildImageSection(isDark, l10n),
        const SizedBox(height: AlhaiSpacing.md),
        _buildBasicInfoSection(isDark, l10n),
        const SizedBox(height: AlhaiSpacing.md),
        _buildPricingSection(isDark, l10n),
        const SizedBox(height: AlhaiSpacing.md),
        _buildStockSection(isDark, l10n),
        const SizedBox(height: AlhaiSpacing.md),
        _buildSettingsSection(isDark, l10n),
        const SizedBox(height: AlhaiSpacing.lg),
        _buildSaveButton(isDark, l10n),
        const SizedBox(height: AlhaiSpacing.lg),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // Sections
  // ──────────────────────────────────────────────────────────────────────

  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSizes.md),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          ...children,
        ],
      ),
    );
  }

  Widget _buildImageSection(bool isDark, AppLocalizations l10n) {
    return _buildSectionCard(
      isDark: isDark,
      title: l10n.productImage,
      icon: Icons.image_rounded,
      color: AppColors.info,
      children: [
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isDark
                  ? Theme.of(context).colorScheme.surface
                  : AppColors.border.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
            child: Icon(
              Icons.add_photo_alternate_rounded,
              size: 48,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : AppColors.textTertiary,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Center(
          child: Text(
            l10n.productImage,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection(bool isDark, AppLocalizations l10n) {
    return _buildSectionCard(
      isDark: isDark,
      title: l10n.productName,
      icon: Icons.info_outline_rounded,
      color: AppColors.primary,
      children: [
        // Product name (Arabic)
        _buildTextField(
          controller: _nameController,
          label: '${l10n.productName} *',
          icon: Icons.shopping_bag_rounded,
          isDark: isDark,
          maxLength: 150,
          validator: FormValidators.requiredField(maxLength: 150),
          focusNode: _nameFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _nameEnFocus.requestFocus(),
        ),
        const SizedBox(height: AppSizes.md),

        // Product name (English)
        _buildTextField(
          controller: _nameEnController,
          label: 'Product Name (English)',
          icon: Icons.translate_rounded,
          isDark: isDark,
          maxLength: 150,
          validator: FormValidators.notes(maxLength: 150),
          focusNode: _nameEnFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _barcodeFocus.requestFocus(),
        ),
        const SizedBox(height: AppSizes.md),

        // Barcode
        _buildTextField(
          controller: _barcodeController,
          label: l10n.barcode,
          icon: Icons.qr_code_rounded,
          isDark: isDark,
          maxLength: 50,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-]')),
          ],
          validator: FormValidators.barcode(required: false),
          focusNode: _barcodeFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _priceFocus.requestFocus(),
        ),
        const SizedBox(height: AppSizes.md),

        // Category dropdown
        _buildCategoryDropdown(isDark, l10n),
      ],
    );
  }

  Widget _buildPricingSection(bool isDark, AppLocalizations l10n) {
    return _buildSectionCard(
      isDark: isDark,
      title: l10n.sellingPrice,
      icon: Icons.payments_rounded,
      color: AppColors.success,
      children: [
        _buildTextField(
          controller: _priceController,
          label: '${l10n.sellingPrice} *',
          icon: Icons.sell_rounded,
          isDark: isDark,
          keyboardType: TextInputType.number,
          suffixText: l10n.sar,
          maxLength: 12,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          validator: FormValidators.price(allowZero: false),
          focusNode: _priceFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _costFocus.requestFocus(),
        ),
        const SizedBox(height: AppSizes.md),
        _buildTextField(
          controller: _costController,
          label: l10n.costPrice,
          icon: Icons.payments_rounded,
          isDark: isDark,
          keyboardType: TextInputType.number,
          suffixText: l10n.sar,
          maxLength: 12,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          validator: FormValidators.price(required: false),
          focusNode: _costFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _stockFocus.requestFocus(),
        ),
      ],
    );
  }

  Widget _buildStockSection(bool isDark, AppLocalizations l10n) {
    return _buildSectionCard(
      isDark: isDark,
      title: l10n.stock,
      icon: Icons.inventory_2_rounded,
      color: AppColors.warning,
      children: [
        _buildTextField(
          controller: _stockController,
          label: l10n.currentStock,
          icon: Icons.inventory_2_rounded,
          isDark: isDark,
          keyboardType: TextInputType.number,
          maxLength: 8,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: FormValidators.numeric(
              isRequired: false, max: 99999999, allowZero: true),
          focusNode: _stockFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _minStockFocus.requestFocus(),
        ),
        const SizedBox(height: AppSizes.md),
        _buildTextField(
          controller: _minStockController,
          label: l10n.minimumQuantity,
          icon: Icons.warning_amber_rounded,
          isDark: isDark,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: FormValidators.numeric(
              isRequired: false, max: 999999, allowZero: true),
          focusNode: _minStockFocus,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildSettingsSection(bool isDark, AppLocalizations l10n) {
    return _buildSectionCard(
      isDark: isDark,
      title: l10n.settings,
      icon: Icons.settings_rounded,
      color: AppColors.textSecondary,
      children: [
        // Track Inventory toggle
        _buildSwitchTile(
          title: l10n.trackInventory,
          subtitle: l10n.stock,
          icon: Icons.track_changes_rounded,
          value: _trackInventory,
          onChanged: (v) => setState(() => _trackInventory = v),
          isDark: isDark,
        ),
        const SizedBox(height: AppSizes.sm),
        // Active toggle
        _buildSwitchTile(
          title: l10n.activeProduct,
          subtitle: _isActive ? l10n.active : l10n.inactive,
          icon: Icons.visibility_rounded,
          value: _isActive,
          onChanged: (v) => setState(() => _isActive = v),
          isDark: isDark,
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // UI Helpers
  // ──────────────────────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    String? suffixText,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      validator: validator,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: (_) {
        if (!_isDirty) _setDirty(true);
      },
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixText: suffixText,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.border.withValues(alpha: 0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(bool isDark, AppLocalizations l10n) {
    return DropdownButtonFormField<String?>(
      value: _selectedCategoryId,
      isExpanded: true,
      dropdownColor: Theme.of(context).colorScheme.surface,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: l10n.selectCategory,
        prefixIcon: const Icon(Icons.category_rounded),
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.border.withValues(alpha: 0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      hint: Text(
        l10n.selectCategory,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(
            l10n.uncategorized,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ..._categories.map(
          (c) => DropdownMenuItem<String?>(
            value: c.id,
            child: Text(c.name),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() => _selectedCategoryId = value);
        _setDirty(true);
      },
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : AppColors.border.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
        ),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        secondary: Icon(
          icon,
          color: value ? AppColors.primary : AppColors.textTertiary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        activeColor: AppColors.primary,
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
                  color: Colors.white,
                ),
              )
            : Icon(widget.isEditing ? Icons.save_rounded : Icons.add_rounded),
        label: Text(
          widget.isEditing ? l10n.saveChanges : l10n.addTheProduct,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // Save Logic
  // ──────────────────────────────────────────────────────────────────────

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);

    // Security: Check for dangerous content in text fields
    final fieldsToCheck = [
      _nameController.text,
      _nameEnController.text,
    ];
    for (final value in fieldsToCheck) {
      if (value.trim().isNotEmpty &&
          InputSanitizer.containsDangerousContent(value)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.inputContainsDangerousContent),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? kDefaultStoreId;

      final name = InputSanitizer.sanitize(_nameController.text.trim());
      final barcode = InputSanitizer.sanitize(_barcodeController.text.trim());
      final priceText = _priceController.text.trim();
      final costText = _costController.text.trim();
      final stockText = _stockController.text.trim();
      final minStockText = _minStockController.text.trim();

      if (widget.isEditing) {
        final existing = await db.productsDao.getProductById(widget.productId!);
        if (existing == null) throw Exception('Product not found');

        final updated = existing.copyWith(
          name: name,
          barcode: drift.Value(barcode.isEmpty ? null : barcode),
          price: double.tryParse(priceText) ?? 0.0,
          costPrice:
              drift.Value(costText.isEmpty ? null : double.tryParse(costText)),
          stockQty: double.tryParse(stockText) ?? 0.0,
          minQty: double.tryParse(minStockText) ?? 1.0,
          categoryId: drift.Value(_selectedCategoryId),
          isActive: _isActive,
          trackInventory: _trackInventory,
          updatedAt: drift.Value(DateTime.now()),
        );

        await db.productsDao.updateProduct(updated);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.productSavedSuccess),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        final productId = 'prod_${DateTime.now().millisecondsSinceEpoch}';

        final companion = ProductsTableCompanion(
          id: drift.Value(productId),
          storeId: drift.Value(storeId),
          name: drift.Value(name),
          barcode: drift.Value(barcode.isEmpty ? null : barcode),
          price: drift.Value(double.tryParse(priceText) ?? 0.0),
          costPrice:
              drift.Value(costText.isEmpty ? null : double.tryParse(costText)),
          stockQty: drift.Value(double.tryParse(stockText) ?? 0.0),
          minQty: drift.Value(double.tryParse(minStockText) ?? 1.0),
          categoryId: drift.Value(_selectedCategoryId),
          isActive: drift.Value(_isActive),
          trackInventory: drift.Value(_trackInventory),
          createdAt: drift.Value(DateTime.now()),
        );

        await db.productsDao.insertProduct(companion);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.productAddedSuccess),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }

      if (mounted) {
        _setDirty(false);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithDetails('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _DismissFormIntent extends Intent {
  const _DismissFormIntent();
}
