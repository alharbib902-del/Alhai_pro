/// شاشة تعديل المخزون - Inventory Adjustment Screen
///
/// شاشة لتعديل كميات المخزون يدوياً مع توثيق السبب
library;

import 'package:pos_app/widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../core/validators/validators.dart';

/// شاشة تعديل المخزون
class InventoryAdjustScreen extends StatefulWidget {
  final String? productId;
  final String? productName;

  const InventoryAdjustScreen({
    super.key,
    this.productId,
    this.productName,
  });

  @override
  State<InventoryAdjustScreen> createState() => _InventoryAdjustScreenState();
}

class _InventoryAdjustScreenState extends State<InventoryAdjustScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  AdjustmentType _adjustmentType = AdjustmentType.add;
  AdjustmentReason _selectedReason = AdjustmentReason.count;
  ProductForAdjust? _selectedProduct;
  bool _isLoading = false;

  // بيانات تجريبية للمنتجات
  final List<ProductForAdjust> _products = [
    ProductForAdjust(
      id: '1',
      name: 'حليب المراعي كامل الدسم 1 لتر',
      sku: 'MLK001',
      barcode: '6281001234567',
      currentStock: 150,
      unit: 'كرتون',
    ),
    ProductForAdjust(
      id: '2',
      name: 'أرز بسمتي أبو كاس 5 كجم',
      sku: 'RIC001',
      barcode: '6281007654321',
      currentStock: 75,
      unit: 'كيس',
    ),
    ProductForAdjust(
      id: '3',
      name: 'زيت عافية نباتي 1.8 لتر',
      sku: 'OIL001',
      barcode: '6281009876543',
      currentStock: 45,
      unit: 'علبة',
    ),
    ProductForAdjust(
      id: '4',
      name: 'سكر أبيض 1 كجم',
      sku: 'SUG001',
      barcode: '6281005432167',
      currentStock: 200,
      unit: 'كيس',
    ),
    ProductForAdjust(
      id: '5',
      name: 'شاي ربيع 100 كيس',
      sku: 'TEA001',
      barcode: '6281003216549',
      currentStock: 120,
      unit: 'علبة',
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _selectedProduct = _products.firstWhere(
        (p) => p.id == widget.productId,
        orElse: () => _products.first,
      );
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
      body: Form(
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
              ),
            ),

            // Products List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
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
    );
  }

  void _scanBarcode() {
    // TODO: فتح ماسح الباركود
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم فتح ماسح الباركود...'),
      ),
    );
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

            // History List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSizes.lg),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return _buildHistoryItem(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(int index) {
    final isAddition = index % 2 == 0;
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
                  const Text(
                    'حليب المراعي كامل الدسم',
                    style: AppTypography.titleSmall,
                  ),
                  Text(
                    '${isAddition ? '+' : '-'}${(index + 1) * 10} وحدة • جرد',
                    style: AppTypography.bodySmall.copyWith(
                      color: isAddition ? AppColors.success : AppColors.error,
                    ),
                  ),
                  Text(
                    'أحمد محمد • ${DateTime.now().subtract(Duration(hours: index)).toString().substring(0, 16)}',
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

    // محاكاة الحفظ
    // Use sanitizedNotes instead of raw _notesController.text when persisting
    debugPrint('Notes (sanitized): $sanitizedNotes');
    await Future.delayed(const Duration(seconds: 1));

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
