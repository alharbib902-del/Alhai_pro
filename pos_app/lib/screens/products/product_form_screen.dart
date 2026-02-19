import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:alhai_core/alhai_core.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../data/local/app_database.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/products_providers.dart';

/// شاشة إضافة/تعديل منتج — كاملة مع Dark Mode + l10n + Save Logic
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
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _stockController = TextEditingController();
  final _minQtyController = TextEditingController(text: '1');
  final _unitController = TextEditingController();
  final _descriptionController = TextEditingController();

  // State
  String? _selectedCategoryId;
  bool _isActive = true;
  bool _trackInventory = true;
  bool _isSaving = false;
  bool _isLoadingProduct = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadProduct();
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
          _skuController.text = product.sku ?? '';
          _barcodeController.text = product.barcode ?? '';
          _priceController.text = product.price.toStringAsFixed(2);
          _costController.text = product.costPrice?.toStringAsFixed(2) ?? '';
          _stockController.text = product.stockQty.toString();
          _minQtyController.text = product.minQty.toString();
          _unitController.text = product.unit ?? '';
          _descriptionController.text = product.description ?? '';
          _selectedCategoryId = product.categoryId;
          _isActive = product.isActive;
          _trackInventory = product.trackInventory;
          _isLoadingProduct = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProduct = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _stockController.dispose();
    _minQtyController.dispose();
    _unitController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(categoriesProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= AppSizes.breakpointTablet;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
        elevation: 0,
        title: Text(widget.isEditing ? l10n.editProduct : l10n.newProduct),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
          ),
        ),
      ),
      body: _isLoadingProduct
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? size.width * 0.15 : AppSizes.lg,
                vertical: AppSizes.lg,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Product Image ──
                      _buildImageSection(isDark, l10n),
                      const SizedBox(height: AppSizes.xl),

                      // ── Basic Info Section ──
                      _buildSectionTitle(Icons.info_outline_rounded, l10n.productName, isDark),
                      const SizedBox(height: AppSizes.md),

                      // Name *
                      _buildTextField(
                        controller: _nameController,
                        label: '${l10n.productName} *',
                        icon: Icons.shopping_bag_rounded,
                        isDark: isDark,
                        validator: (v) => v!.isEmpty ? l10n.requiredField : null,
                      ),
                      const SizedBox(height: AppSizes.md),

                      // SKU & Barcode Row
                      _buildResponsiveRow(
                        isDesktop: isDesktop,
                        children: [
                          _buildTextField(
                            controller: _skuController,
                            label: l10n.sku,
                            icon: Icons.tag_rounded,
                            isDark: isDark,
                          ),
                          _buildTextField(
                            controller: _barcodeController,
                            label: l10n.barcode,
                            icon: Icons.qr_code_rounded,
                            isDark: isDark,
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.qr_code_scanner_rounded,
                                color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
                              ),
                              onPressed: () {
                                // TODO: Scan barcode
                              },
                              tooltip: l10n.scanBarcode,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Category
                      _buildCategoryDropdown(categoriesAsync, isDark, l10n),
                      const SizedBox(height: AppSizes.xl),

                      // ── Pricing Section ──
                      _buildSectionTitle(Icons.payments_rounded, l10n.sellingPrice, isDark),
                      const SizedBox(height: AppSizes.md),

                      _buildResponsiveRow(
                        isDesktop: isDesktop,
                        children: [
                          _buildTextField(
                            controller: _priceController,
                            label: '${l10n.sellingPrice} *',
                            icon: Icons.sell_rounded,
                            isDark: isDark,
                            keyboardType: TextInputType.number,
                            suffixText: l10n.sar,
                            validator: (v) {
                              if (v == null || v.isEmpty) return l10n.requiredField;
                              if (double.tryParse(v) == null) return l10n.invalidFormat;
                              return null;
                            },
                          ),
                          _buildTextField(
                            controller: _costController,
                            label: l10n.costPrice,
                            icon: Icons.payments_rounded,
                            isDark: isDark,
                            keyboardType: TextInputType.number,
                            suffixText: l10n.sar,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.xl),

                      // ── Stock Section ──
                      _buildSectionTitle(Icons.inventory_2_rounded, l10n.stock, isDark),
                      const SizedBox(height: AppSizes.md),

                      _buildResponsiveRow(
                        isDesktop: isDesktop,
                        children: [
                          _buildTextField(
                            controller: _stockController,
                            label: l10n.currentStock,
                            icon: Icons.inventory_2_rounded,
                            isDark: isDark,
                            keyboardType: TextInputType.number,
                          ),
                          _buildTextField(
                            controller: _minQtyController,
                            label: l10n.minimumQuantity,
                            icon: Icons.warning_amber_rounded,
                            isDark: isDark,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Unit
                      _buildTextField(
                        controller: _unitController,
                        label: l10n.unit,
                        icon: Icons.straighten_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(height: AppSizes.xl),

                      // ── Description Section ──
                      _buildSectionTitle(Icons.description_rounded, l10n.description, isDark),
                      const SizedBox(height: AppSizes.md),

                      _buildTextField(
                        controller: _descriptionController,
                        label: l10n.description,
                        icon: Icons.notes_rounded,
                        isDark: isDark,
                        maxLines: 4,
                      ),
                      const SizedBox(height: AppSizes.xl),

                      // ── Toggles ──
                      _buildSectionTitle(Icons.settings_rounded, l10n.settings, isDark),
                      const SizedBox(height: AppSizes.md),

                      // Track Inventory
                      _buildSwitchTile(
                        title: l10n.trackInventory,
                        subtitle: l10n.stock,
                        icon: Icons.track_changes_rounded,
                        value: _trackInventory,
                        onChanged: (v) => setState(() => _trackInventory = v),
                        isDark: isDark,
                      ),
                      const SizedBox(height: AppSizes.sm),

                      // Active
                      _buildSwitchTile(
                        title: l10n.activeProduct,
                        subtitle: _isActive ? l10n.active : l10n.inactive,
                        icon: Icons.visibility_rounded,
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                        isDark: isDark,
                      ),
                      const SizedBox(height: AppSizes.xl),

                      // ── Submit Button ──
                      FilledButton.icon(
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
                          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // UI Helpers
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildImageSection(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
                  ),
                ),
                child: Icon(
                  Icons.image_rounded,
                  size: 48,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.textSecondary.withValues(alpha: 0.3),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      width: 3,
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            l10n.productImage,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: AppSizes.sm),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Divider(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    String? suffixText,
    Widget? suffixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
        ),
        suffixText: suffixText,
        suffixIcon: suffixIcon,
        labelStyle: TextStyle(
          color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF0F172A) : AppColors.surfaceVariant.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildResponsiveRow({
    required bool isDesktop,
    required List<Widget> children,
  }) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((child) {
          final index = children.indexOf(child);
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index > 0 ? AppSizes.md / 2 : 0,
                right: index < children.length - 1 ? AppSizes.md / 2 : 0,
              ),
              child: child,
            ),
          );
        }).toList(),
      );
    } else {
      return Column(
        children: children.map((child) {
          final index = children.indexOf(child);
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < children.length - 1 ? AppSizes.md : 0,
            ),
            child: child,
          );
        }).toList(),
      );
    }
  }

  Widget _buildCategoryDropdown(
    AsyncValue<List<Category>> categoriesAsync,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return categoriesAsync.when(
      data: (categories) {
        return DropdownButtonFormField<String>(
          initialValue: _selectedCategoryId,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: l10n.selectCategory,
            prefixIcon: Icon(
              Icons.category_rounded,
              color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
            ),
            labelStyle: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF0F172A) : AppColors.surfaceVariant.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          hint: Text(
            l10n.selectCategory,
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textSecondary,
            ),
          ),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                l10n.uncategorized,
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
                ),
              ),
            ),
            ...categories.map((c) => DropdownMenuItem<String>(
              value: c.id,
              child: Text(c.name),
            )),
          ],
          onChanged: (value) => setState(() => _selectedCategoryId = value),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox(),
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
        color: isDark ? const Color(0xFF0F172A) : AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
        ),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textSecondary,
          ),
        ),
        secondary: Icon(
          icon,
          color: value ? AppColors.primary : (isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.textSecondary),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Save Logic
  // ─────────────────────────────────────────────────────────────────────

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);

      if (storeId == null) {
        throw Exception('Store ID is null');
      }

      if (widget.isEditing) {
        // ── Update existing product ──
        final existing = await db.productsDao.getProductById(widget.productId!);
        if (existing == null) throw Exception('Product not found');

        final updated = existing.copyWith(
          name: _nameController.text.trim(),
          sku: drift.Value(_skuController.text.trim().isEmpty ? null : _skuController.text.trim()),
          barcode: drift.Value(_barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim()),
          price: double.parse(_priceController.text.trim()),
          costPrice: drift.Value(_costController.text.trim().isEmpty ? null : double.tryParse(_costController.text.trim())),
          stockQty: int.tryParse(_stockController.text.trim()) ?? 0,
          minQty: int.tryParse(_minQtyController.text.trim()) ?? 1,
          unit: drift.Value(_unitController.text.trim().isEmpty ? null : _unitController.text.trim()),
          description: drift.Value(_descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim()),
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
        // ── Insert new product ──
        const uuid = Uuid();
        final companion = ProductsTableCompanion(
          id: drift.Value(uuid.v4()),
          storeId: drift.Value(storeId),
          name: drift.Value(_nameController.text.trim()),
          sku: drift.Value(_skuController.text.trim().isEmpty ? null : _skuController.text.trim()),
          barcode: drift.Value(_barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim()),
          price: drift.Value(double.parse(_priceController.text.trim())),
          costPrice: drift.Value(_costController.text.trim().isEmpty ? null : double.tryParse(_costController.text.trim())),
          stockQty: drift.Value(int.tryParse(_stockController.text.trim()) ?? 0),
          minQty: drift.Value(int.tryParse(_minQtyController.text.trim()) ?? 1),
          unit: drift.Value(_unitController.text.trim().isEmpty ? null : _unitController.text.trim()),
          description: drift.Value(_descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim()),
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

      // Refresh products list
      final stId = ref.read(currentStoreIdProvider);
      if (stId != null) {
        ref.read(productsStateProvider.notifier).loadProducts(storeId: stId, refresh: true);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
