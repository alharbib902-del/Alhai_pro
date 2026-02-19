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
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل المخزون'),
        actions: [
          // سجل التعديلات
          IconButton(
            onPressed: _showAdjustmentHistory,
            icon: const Icon(Icons.history),
            tooltip: 'سجل التعديلات',
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
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text('حدث خطأ أثناء تحميل المنتجات'),
                      const SizedBox(height: 8),
                      Text(_loadError!, style: const TextStyle(color: Colors.grey)),
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
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    children: [
                      // اختيار المنتج
                      _buildProductSelector(),
                      const SizedBox(height: AppSizes.lg),

                      // معلومات المخزون الحالي
                      if (_selectedProduct != null) ...[
                        _buildCurrentStockCard(),
                        const SizedBox(height: AppSizes.lg),
                      ],

                      // نوع التعديل
                      _buildAdjustmentTypeSelector(),
                      const SizedBox(height: AppSizes.lg),

                      // الكمية
                      _buildQuantityField(),
                      const SizedBox(height: AppSizes.lg),

                      // سبب التعديل
                      _buildReasonSelector(),
                      const SizedBox(height: AppSizes.lg),

                      // ملاحظات
                      _buildNotesField(),
                      const SizedBox(height: AppSizes.lg),

                      // ملخص التعديل
                      if (_selectedProduct != null && _quantityController.text.isNotEmpty)
                        _buildAdjustmentSummary(),
                      const SizedBox(height: AppSizes.xl),

                      // زر الحفظ
                      _buildSaveButton(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProductSelector() {
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
                  'اختيار المنتج',
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
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: AppColors.textMuted,
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
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'ابحث بالاسم أو الباركود...',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textMuted,
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
                        icon: const Icon(Icons.clear, color: AppColors.textMuted),
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
              label: const Text('مسح الباركود'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStockCard() {
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
              child: const Icon(
                Icons.inventory,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المخزون الحالي',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
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
                _getStockStatusText(),
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

  Widget _buildAdjustmentTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نوع التعديل',
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
                    label: 'إضافة',
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: _buildTypeOption(
                    type: AdjustmentType.subtract,
                    icon: Icons.remove_circle,
                    label: 'خصم',
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: _buildTypeOption(
                    type: AdjustmentType.set,
                    icon: Icons.edit,
                    label: 'تعيين',
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
            color: isSelected ? color : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textMuted,
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

  Widget _buildQuantityField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _adjustmentType == AdjustmentType.set
                  ? 'الكمية الجديدة'
                  : 'الكمية',
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
                    backgroundColor: AppColors.grey200,
                    foregroundColor: AppColors.textPrimary,
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
                      fillColor: AppColors.grey100,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                      suffixText: _selectedProduct?.unit ?? 'وحدة',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'أدخل الكمية';
                      }
                      final qty = int.tryParse(value);
                      if (qty == null || qty <= 0) {
                        return 'أدخل كمية صحيحة';
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
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'سبب التعديل',
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
                  label: Text(reason.label),
                  avatar: Icon(
                    reason.icon,
                    size: 18,
                    color: isSelected ? Colors.white : AppColors.textMuted,
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
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملاحظات (اختياري)',
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
                hintText: 'أدخل أي ملاحظات إضافية...',
                filled: true,
                fillColor: AppColors.grey100,
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

  Widget _buildAdjustmentSummary() {
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
                  'ملخص التعديل',
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
              'المخزون الحالي',
              '$currentStock ${_selectedProduct?.unit ?? ''}',
            ),

            // التعديل
            _buildSummaryRow(
              _adjustmentType.label,
              '${difference >= 0 ? '+' : ''}$difference ${_selectedProduct?.unit ?? ''}',
              valueColor: difference >= 0 ? AppColors.success : AppColors.error,
            ),

            const Divider(),

            // المخزون الجديد
            _buildSummaryRow(
              'المخزون الجديد',
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
                      'تحذير: المخزون سيصبح سالباً!',
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

  Widget _buildSaveButton() {
    return FilledButton.icon(
      onPressed: _selectedProduct != null && !_isLoading ? _saveAdjustment : null,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.save),
      label: Text(_isLoading ? 'جاري الحفظ...' : 'حفظ التعديل'),
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

  String _getStockStatusText() {
    final stock = _selectedProduct?.currentStock ?? 0;
    if (stock <= 10) return 'منخفض';
    if (stock <= 30) return 'متوسط';
    return 'جيد';
  }

  void _showProductSearch() {
    final searchController = TextEditingController();
    List<ProductForAdjust> filteredProducts = List.from(_products);

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
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                child: Row(
                  children: [
                    const Text(
                      'اختيار المنتج',
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
                    hintText: 'ابحث بالاسم أو SKU أو الباركود...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.grey100,
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
                    ? const Center(
                        child: Text('لا توجد منتجات مطابقة', style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppSizes.sm),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.grey100,
                                child: Icon(
                                  Icons.inventory_2,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              title: Text(
                                product.name,
                                style: AppTypography.titleSmall,
                              ),
                              subtitle: Text(
                                'SKU: ${product.sku} | المخزون: ${product.currentStock}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textMuted,
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
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: Row(
                children: [
                  const Text(
                    'سجل التعديلات',
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
              child: _buildHistoryList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) {
      return const Center(child: Text('لم يتم تحديد المتجر'));
    }

    final db = getIt<AppDatabase>();
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
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(height: 8),
                Text('حدث خطأ: ${snapshot.error}'),
              ],
            ),
          );
        }
        final movements = snapshot.data ?? [];
        if (movements.isEmpty) {
          return const Center(
            child: Text('لا توجد حركات مخزون', style: TextStyle(color: Colors.grey)),
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
                    '${isAddition ? '+' : ''}${movement.qty} وحدة (${movement.previousQty} -> ${movement.newQty})',
                    style: AppTypography.bodySmall.copyWith(
                      color: isAddition ? AppColors.success : AppColors.error,
                    ),
                  ),
                  Text(
                    movement.createdAt.toString().substring(0, 16),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
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
        reason: '${_selectedReason.label}: $sanitizedNotes',
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
          'reason': '${_selectedReason.label}: $sanitizedNotes',
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
          const SnackBar(
            content: Text('تم حفظ التعديل بنجاح'),
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
            content: Text('حدث خطأ أثناء الحفظ: $e'),
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

    return Scaffold(
      appBar: AppBar(title: const Text('مسح الباركود')),
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
              decoration: const InputDecoration(
                labelText: 'أدخل الباركود',
                prefixIcon: Icon(Icons.keyboard),
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
                      const SnackBar(
                        content: Text('لم يتم العثور على المنتج'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: const Text('بحث'),
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

  String get label {
    switch (this) {
      case AdjustmentType.add:
        return 'إضافة';
      case AdjustmentType.subtract:
        return 'خصم';
      case AdjustmentType.set:
        return 'تعيين';
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

  String get label {
    switch (this) {
      case AdjustmentReason.count:
        return 'جرد';
      case AdjustmentReason.damage:
        return 'تالف';
      case AdjustmentReason.expiry:
        return 'منتهي الصلاحية';
      case AdjustmentReason.theft:
        return 'سرقة';
      case AdjustmentReason.return_:
        return 'مرتجع';
      case AdjustmentReason.correction:
        return 'تصحيح خطأ';
      case AdjustmentReason.other:
        return 'أخرى';
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
