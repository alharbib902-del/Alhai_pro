/// شاشة تعديل المخزون - Inventory Adjustment Screen
///
/// شاشة لتعديل كميات المخزون يدوياً مع توثيق السبب
library;

import 'package:pos_app/widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../core/validators/validators.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/products_providers.dart';
import '../../providers/sync_providers.dart';

const _uuid = Uuid();

/// شاشة تعديل المخزون
class InventoryAdjustScreen extends ConsumerStatefulWidget {
  final String? productId;
  final String? productName;

  const InventoryAdjustScreen({
    super.key,
    this.productId,
    this.productName,
  });

  @override
  ConsumerState<InventoryAdjustScreen> createState() => _InventoryAdjustScreenState();
}

class _InventoryAdjustScreenState extends ConsumerState<InventoryAdjustScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  AdjustmentType _adjustmentType = AdjustmentType.add;
  AdjustmentReason _selectedReason = AdjustmentReason.count;
  ProductForAdjust? _selectedProduct;
  bool _isLoading = false;

  /// قائمة المنتجات المحملة من قاعدة البيانات
  List<ProductForAdjust> _products = [];
  bool _isLoadingProducts = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  /// تحميل المنتجات من قاعدة البيانات
  Future<void> _loadProducts() async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) {
      setState(() {
        _isLoadingProducts = false;
        _loadError = 'لم يتم تحديد المتجر';
      });
      return;
    }

    try {
      final db = getIt<AppDatabase>();
      final productsData = await db.productsDao.getAllProducts(storeId);

      if (mounted) {
        setState(() {
          _products = productsData.map((p) => ProductForAdjust(
            id: p.id,
            name: p.name,
            sku: p.sku ?? '',
            barcode: p.barcode ?? '',
            currentStock: p.stockQty,
            unit: p.unit ?? 'وحدة',
          )).toList();
          _isLoadingProducts = false;
        });

        // إذا تم تمرير معرف المنتج، اختره تلقائياً
        if (widget.productId != null) {
          final match = _products.where((p) => p.id == widget.productId);
          if (match.isNotEmpty) {
            setState(() {
              _selectedProduct = match.first;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
          _loadError = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adjustStock),
        actions: [
          // سجل التعديلات
          IconButton(
            onPressed: _showAdjustmentHistory,
            icon: const Icon(Icons.history),
            tooltip: l10n.adjustmentHistory,
          ),
        ],
      ),
      body: _isLoadingProducts
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                      const SizedBox(height: 16),
                      Text(l10n.errorLoadingProducts, style: TextStyle(color: colorScheme.onSurface)),
                      const SizedBox(height: 8),
                      Text(_loadError!, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          setState(() {
                            _isLoadingProducts = true;
                            _loadError = null;
                          });
                          _loadProducts();
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : _products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 64, color: colorScheme.onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text(l10n.noProducts, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16)),
                        ],
                      ),
                    )
                  : Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(AppSizes.lg),
                        children: [
                          // اختيار المنتج
                          _buildProductSelector(l10n),
                          const SizedBox(height: AppSizes.lg),

                          // معلومات المخزون الحالي
                          if (_selectedProduct != null) ...[
                            _buildCurrentStockCard(l10n),
                            const SizedBox(height: AppSizes.lg),
                          ],

                          // نوع التعديل
                          _buildAdjustmentTypeSelector(l10n),
                          const SizedBox(height: AppSizes.lg),

                          // الكمية
                          _buildQuantityField(l10n),
                          const SizedBox(height: AppSizes.lg),

                          // سبب التعديل
                          _buildReasonSelector(l10n),
                          const SizedBox(height: AppSizes.lg),

                          // ملاحظات
                          _buildNotesField(l10n),
                          const SizedBox(height: AppSizes.lg),

                          // ملخص التعديل
                          if (_selectedProduct != null && _quantityController.text.isNotEmpty)
                            _buildAdjustmentSummary(l10n),
                          const SizedBox(height: AppSizes.xl),

                          // زر الحفظ
                          _buildSaveButton(l10n),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildProductSelector(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2, color: AppColors.primary),
                const SizedBox(width: AppSizes.sm),
                Text(
                  l10n.selectProduct,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            // حقل البحث
            InkWell(
              onTap: _showProductSearch,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: _selectedProduct != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedProduct!.name,
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'SKU: ${_selectedProduct!.sku}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              l10n.searchByNameOrBarcode,
                              style: AppTypography.bodyMedium.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                    if (_selectedProduct != null)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedProduct = null;
                          });
                        },
                        icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),

            // زر مسح الباركود
            const SizedBox(height: AppSizes.sm),
            OutlinedButton.icon(
              onPressed: _scanBarcode,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(l10n.scanBarcode),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStockCard(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: AppColors.info.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.info,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(
                Icons.inventory,
                color: colorScheme.surface,
                size: 32,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.currentStock,
                    style: AppTypography.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${_selectedProduct!.currentStock} ${_selectedProduct!.unit}',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // حالة المخزون
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.xs,
              ),
              decoration: BoxDecoration(
                color: _getStockStatusColor().withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Text(
                _getStockStatusText(l10n),
                style: AppTypography.labelSmall.copyWith(
                  color: _getStockStatusColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustmentTypeSelector(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.adjustmentType,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Expanded(
                  child: _buildTypeOption(
                    type: AdjustmentType.add,
                    icon: Icons.add_circle,
                    label: l10n.add,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: _buildTypeOption(
                    type: AdjustmentType.subtract,
                    icon: Icons.remove_circle,
                    label: l10n.subtract,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: _buildTypeOption(
                    type: AdjustmentType.set,
                    icon: Icons.edit,
                    label: l10n.setQuantity,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required AdjustmentType type,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _adjustmentType == type;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _adjustmentType = type;
        });
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 28,
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityField(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _adjustmentType == AdjustmentType.set
                  ? l10n.newQuantity
                  : l10n.quantity,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                // زر الطرح
                IconButton.filled(
                  onPressed: () {
                    final current =
                        int.tryParse(_quantityController.text) ?? 0;
                    if (current > 0) {
                      _quantityController.text = (current - 1).toString();
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.remove),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    foregroundColor: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: AppSizes.md),

                // حقل الكمية
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLength: 8,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    decoration: InputDecoration(
                      hintText: '0',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                      suffixText: _selectedProduct?.unit ?? l10n.unit,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.enterQuantity;
                      }
                      final qty = int.tryParse(value);
                      if (qty == null || qty <= 0) {
                        return l10n.enterValidQuantity;
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: AppSizes.md),

                // زر الإضافة
                IconButton.filled(
                  onPressed: () {
                    final current =
                        int.tryParse(_quantityController.text) ?? 0;
                    _quantityController.text = (current + 1).toString();
                    setState(() {});
                  },
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: colorScheme.surface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonSelector(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.adjustmentReason,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: AdjustmentReason.values.map((reason) {
                final isSelected = _selectedReason == reason;
                return FilterChip(
                  selected: isSelected,
                  label: Text(reason.getLabel(l10n)),
                  avatar: Icon(
                    reason.icon,
                    size: 18,
                    color: isSelected ? colorScheme.surface : colorScheme.onSurfaceVariant,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedReason = reason;
                      });
                    }
                  },
                  selectedColor: AppColors.primary,
                  checkmarkColor: colorScheme.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? colorScheme.surface : colorScheme.onSurface,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notesOptional,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              maxLength: 500,
              validator: FormValidators.notes(),
              decoration: InputDecoration(
                hintText: l10n.enterAdditionalNotes,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustmentSummary(AppLocalizations l10n) {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final currentStock = _selectedProduct?.currentStock ?? 0;

    int newStock;
    switch (_adjustmentType) {
      case AdjustmentType.add:
        newStock = currentStock + quantity;
        break;
      case AdjustmentType.subtract:
        newStock = currentStock - quantity;
        break;
      case AdjustmentType.set:
        newStock = quantity;
        break;
    }

    final difference = newStock - currentStock;

    return Card(
      color: AppColors.warning.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.summarize, color: AppColors.warning),
                const SizedBox(width: AppSizes.sm),
                Text(
                  l10n.adjustmentSummary,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            const Divider(),
            const SizedBox(height: AppSizes.sm),

            // المخزون الحالي
            _buildSummaryRow(
              l10n.currentStock,
              '$currentStock ${_selectedProduct?.unit ?? ''}',
            ),

            // التعديل
            _buildSummaryRow(
              _adjustmentType.getLabel(l10n),
              '${difference >= 0 ? '+' : ''}$difference ${_selectedProduct?.unit ?? ''}',
              valueColor: difference >= 0 ? AppColors.success : AppColors.error,
            ),

            const Divider(),

            // المخزون الجديد
            _buildSummaryRow(
              l10n.newStock,
              '$newStock ${_selectedProduct?.unit ?? ''}',
              isTotal: true,
              valueColor: newStock < 0 ? AppColors.error : null,
            ),

            if (newStock < 0) ...[
              const SizedBox(height: AppSizes.sm),
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: AppColors.error, size: 20),
                    const SizedBox(width: AppSizes.xs),
                    Text(
                      l10n.warningNegativeStock,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)
                : AppTypography.bodyMedium,
          ),
          Text(
            value,
            style: (isTotal
                    ? AppTypography.titleMedium
                    : AppTypography.bodyMedium)
                .copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return FilledButton.icon(
      onPressed: _selectedProduct != null && !_isLoading ? _saveAdjustment : null,
      icon: _isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.surface,
              ),
            )
          : const Icon(Icons.save),
      label: Text(_isLoading ? l10n.saving : l10n.saveAdjustment),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
      ),
    );
  }

  Color _getStockStatusColor() {
    final stock = _selectedProduct?.currentStock ?? 0;
    if (stock <= 10) return AppColors.error;
    if (stock <= 30) return AppColors.warning;
    return AppColors.success;
  }

  String _getStockStatusText(AppLocalizations l10n) {
    final stock = _selectedProduct?.currentStock ?? 0;
    if (stock <= 10) return l10n.lowStock;
    if (stock <= 30) return l10n.medium;
    return l10n.good;
  }

  void _showProductSearch() {
    final searchController = TextEditingController();
    List<ProductForAdjust> filteredProducts = List.from(_products);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusXl),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsetsDirectional.only(start: AppSizes.lg, end: AppSizes.lg),
                child: Row(
                  children: [
                    Text(
                      l10n.selectProduct,
                      style: AppTypography.headlineSmall,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Search
              Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: TextField(
                  controller: searchController,
                  maxLength: 100,
                  decoration: InputDecoration(
                    hintText: l10n.searchByNameOrBarcode,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (query) async {
                    if (query.isEmpty) {
                      setSheetState(() {
                        filteredProducts = List.from(_products);
                      });
                    } else {
                      // البحث في قاعدة البيانات
                      final storeId = ref.read(currentStoreIdProvider);
                      if (storeId != null) {
                        final db = getIt<AppDatabase>();
                        final results = await db.productsDao.searchProducts(query, storeId);
                        setSheetState(() {
                          filteredProducts = results.map((p) => ProductForAdjust(
                            id: p.id,
                            name: p.name,
                            sku: p.sku ?? '',
                            barcode: p.barcode ?? '',
                            currentStock: p.stockQty,
                            unit: p.unit ?? 'وحدة',
                          )).toList();
                        });
                      }
                    }
                  },
                ),
              ),

              // Products List
              Expanded(
                child: filteredProducts.isEmpty
                    ? Center(
                        child: Text(l10n.noMatchingProducts, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsetsDirectional.only(start: AppSizes.lg, end: AppSizes.lg),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppSizes.sm),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.inventory_2,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              title: Text(
                                product.name,
                                style: AppTypography.titleSmall,
                              ),
                              subtitle: Text(
                                'SKU: ${product.sku} | ${l10n.stock}: ${product.currentStock}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              trailing: const AdaptiveIcon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                setState(() {
                                  _selectedProduct = product;
                                });
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scanBarcode() async {
    // فتح ماسح الباركود والحصول على النتيجة
    final result = await Navigator.push<ProductsTableData>(
      context,
      MaterialPageRoute(
        builder: (context) => const _BarcodeScannerForAdjust(),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedProduct = ProductForAdjust(
          id: result.id,
          name: result.name,
          sku: result.sku ?? '',
          barcode: result.barcode ?? '',
          currentStock: result.stockQty,
          unit: result.unit ?? 'وحدة',
        );
      });
    }
  }

  void _showAdjustmentHistory() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXl),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsetsDirectional.only(start: AppSizes.lg, end: AppSizes.lg),
              child: Row(
                children: [
                  Text(
                    l10n.adjustmentHistory,
                    style: AppTypography.headlineSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            const Divider(),

            // History List - تحميل من قاعدة البيانات
            Expanded(
              child: _buildHistoryList(l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(AppLocalizations l10n) {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) {
      return Center(child: Text(l10n.storeNotSelected));
    }

    final db = getIt<AppDatabase>();
    final colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<InventoryMovementsTableData>>(
      future: _selectedProduct != null
          ? db.inventoryDao.getMovementsByProduct(_selectedProduct!.id)
          : db.inventoryDao.getTodayMovements(storeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: colorScheme.error),
                const SizedBox(height: 8),
                Text('${l10n.errorOccurred}: ${snapshot.error}'),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          );
        }
        final movements = snapshot.data ?? [];
        if (movements.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 48, color: colorScheme.onSurfaceVariant),
                const SizedBox(height: 8),
                Text(l10n.noInventoryMovements, style: TextStyle(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.lg),
          itemCount: movements.length,
          itemBuilder: (context, index) {
            return _buildHistoryItem(movements[index]);
          },
        );
      },
    );
  }

  Widget _buildHistoryItem(InventoryMovementsTableData movement) {
    final isAddition = movement.qty > 0;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: (isAddition ? AppColors.success : AppColors.error)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(
                isAddition ? Icons.add_circle : Icons.remove_circle,
                color: isAddition ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${movement.type} - ${movement.reason ?? ''}',
                    style: AppTypography.titleSmall,
                  ),
                  Text(
                    '${isAddition ? '+' : ''}${movement.qty} (${movement.previousQty} -> ${movement.newQty})',
                    style: AppTypography.bodySmall.copyWith(
                      color: isAddition ? AppColors.success : AppColors.error,
                    ),
                  ),
                  Text(
                    movement.createdAt.toString().substring(0, 16),
                    style: AppTypography.labelSmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAdjustment() async {
    if (!_formKey.currentState!.validate()) return;

    final sanitizedNotes = InputSanitizer.sanitize(_notesController.text.trim());
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
    });

    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      final product = _selectedProduct!;
      final quantity = int.parse(_quantityController.text);

      // حساب المخزون الجديد
      int newStock;
      switch (_adjustmentType) {
        case AdjustmentType.add:
          newStock = product.currentStock + quantity;
          break;
        case AdjustmentType.subtract:
          newStock = product.currentStock - quantity;
          break;
        case AdjustmentType.set:
          newStock = quantity;
          break;
      }

      // إنشاء حركة مخزون
      final movementId = _uuid.v4();
      await db.inventoryDao.recordAdjustment(
        id: movementId,
        productId: product.id,
        storeId: storeId!,
        newQty: newStock,
        previousQty: product.currentStock,
        reason: '${_selectedReason.getLabel(l10n)}: $sanitizedNotes',
        userId: null, // سيتم تعيينه من المستخدم الحالي لاحقاً
      );

      // تحديث المخزون في المنتج
      await db.productsDao.updateStock(product.id, newStock);

      // مزامنة حركة المخزون
      ref.read(syncServiceProvider).enqueueCreate(
        tableName: 'inventory_movements',
        recordId: movementId,
        data: {
          'id': movementId,
          'product_id': product.id,
          'store_id': storeId,
          'type': 'adjustment',
          'qty': newStock - product.currentStock,
          'previous_qty': product.currentStock,
          'new_qty': newStock,
          'reason': '${_selectedReason.getLabel(l10n)}: $sanitizedNotes',
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      // مزامنة تحديث المنتج
      ref.read(syncServiceProvider).enqueueUpdate(
        tableName: 'products',
        recordId: product.id,
        changes: {
          'stock_qty': newStock,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        HapticFeedback.heavyImpact();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adjustmentSavedSuccess),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorSaving}: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

/// ماسح باركود داخلي لشاشة التعديل
class _BarcodeScannerForAdjust extends ConsumerWidget {
  const _BarcodeScannerForAdjust();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barcodeController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanBarcode)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            TextField(
              controller: barcodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.enterBarcode,
                prefixIcon: const Icon(Icons.keyboard),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                final barcode = barcodeController.text.trim();
                if (barcode.isEmpty) return;

                final storeId = ref.read(currentStoreIdProvider);
                if (storeId == null) return;

                final db = getIt<AppDatabase>();
                final product = await db.productsDao.getProductByBarcode(barcode, storeId);

                if (product != null) {
                  if (context.mounted) Navigator.pop(context, product);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.productNotFound),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: Text(l10n.search),
            ),
          ],
        ),
      ),
    );
  }
}

/// نوع التعديل
enum AdjustmentType {
  add,
  subtract,
  set;

  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case AdjustmentType.add:
        return l10n.add;
      case AdjustmentType.subtract:
        return l10n.subtract;
      case AdjustmentType.set:
        return l10n.setQuantity;
    }
  }
}

/// سبب التعديل
enum AdjustmentReason {
  count,
  damage,
  expiry,
  theft,
  return_,
  correction,
  other;

  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case AdjustmentReason.count:
        return l10n.stockTake;
      case AdjustmentReason.damage:
        return l10n.damaged;
      case AdjustmentReason.expiry:
        return l10n.expired;
      case AdjustmentReason.theft:
        return l10n.theft;
      case AdjustmentReason.return_:
        return l10n.returned;
      case AdjustmentReason.correction:
        return l10n.correction;
      case AdjustmentReason.other:
        return l10n.other;
    }
  }

  IconData get icon {
    switch (this) {
      case AdjustmentReason.count:
        return Icons.checklist;
      case AdjustmentReason.damage:
        return Icons.broken_image;
      case AdjustmentReason.expiry:
        return Icons.event_busy;
      case AdjustmentReason.theft:
        return Icons.warning;
      case AdjustmentReason.return_:
        return Icons.assignment_return;
      case AdjustmentReason.correction:
        return Icons.edit_note;
      case AdjustmentReason.other:
        return Icons.more_horiz;
    }
  }
}

/// نموذج المنتج للتعديل
class ProductForAdjust {
  final String id;
  final String name;
  final String sku;
  final String barcode;
  final int currentStock;
  final String unit;

  ProductForAdjust({
    required this.id,
    required this.name,
    required this.sku,
    required this.barcode,
    required this.currentStock,
    required this.unit,
  });
}
