/// درج إنشاء مرتجع جديد - Create Return Drawer
///
/// wizard من 4 خطوات:
/// 1. إدخال رقم الفاتورة
/// 2. اختيار الأصناف
/// 3. تحديد السبب
/// 4. التأكيد والدفع
///
/// يعمل كـ drawer على الديسكتوب و bottom sheet على الموبايل
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

class CreateReturnDrawer extends ConsumerStatefulWidget {
  final VoidCallback? onSuccess;
  final ScrollController? scrollController;

  const CreateReturnDrawer({
    super.key,
    this.onSuccess,
    this.scrollController,
  });

  @override
  ConsumerState<CreateReturnDrawer> createState() => _CreateReturnDrawerState();
}

class _CreateReturnDrawerState extends ConsumerState<CreateReturnDrawer> {
  int _currentStep = 0;
  final _invoiceController = TextEditingController();
  bool _invoiceLoaded = false;
  String _selectedReason = 'defective';
  String _refundMethod = 'cash';
  final Set<int> _selectedItems = {};
  final Map<int, int> _itemQuantities = {};

  // Demo invoice items
  final List<_InvoiceItem> _items = [
    const _InvoiceItem(name: 'حليب كامل الدسم 1ل', sku: 'SKU: 882910', price: 12.00, maxReturn: 2),
    const _InvoiceItem(name: 'خبز أبيض', sku: 'SKU: 771202', price: 5.00, maxReturn: 0),
    const _InvoiceItem(name: 'جبن شيدر', sku: 'SKU: 661003', price: 18.50, maxReturn: 1),
  ];

  double get _totalRefund {
    double total = 0;
    for (final idx in _selectedItems) {
      total += _items[idx].price * (_itemQuantities[idx] ?? 1);
    }
    return total;
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _loadInvoice() {
    if (_invoiceController.text.trim().isNotEmpty) {
      setState(() => _invoiceLoaded = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _nextStep();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = context.isDesktop;

    return Container(
      width: isDesktop ? 500 : double.infinity,
      height: isDesktop ? double.infinity : null,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: isDesktop
            ? null
            : const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(l10n, isDark, isDesktop, colorScheme),
          // Content
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(AlhaiSpacing.mdl),
              children: [
                // Wizard steps
                _buildStepIndicator(l10n, isDark, colorScheme),
                const SizedBox(height: AlhaiSpacing.lg),
                // Step content
                AnimatedSwitcher(
                  duration: AlhaiDurations.standard,
                  child: _buildStepContent(l10n, isDark, colorScheme),
                ),
              ],
            ),
          ),
          // Footer buttons
          _buildFooter(l10n, isDark, colorScheme),
        ],
      ),
    );
  }

  // ============================================================================
  // HEADER
  // ============================================================================

  Widget _buildHeader(AppLocalizations l10n, bool isDark, bool isDesktop, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.mdl, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey900.withValues(alpha: 0.5) : colorScheme.surfaceContainerLow,
        borderRadius: isDesktop
            ? null
            : const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.createNewReturn, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text(l10n.processReturnRequest, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surface,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
              ),
              child: Icon(Icons.close, size: 16, color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // STEP INDICATOR
  // ============================================================================

  Widget _buildStepIndicator(AppLocalizations l10n, bool isDark, ColorScheme colorScheme) {
    final steps = [l10n.invoiceStep, l10n.itemsStep, l10n.reasonStep, l10n.confirmStep];

    return Row(
      children: List.generate(steps.length, (i) {
        final isActive = i == _currentStep;
        final isCompleted = i < _currentStep;

        return Expanded(
          child: Row(
            children: [
              // Step circle
              Column(
                children: [
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? AppColors.primary
                          : isCompleted
                              ? AppColors.success
                              : (isDark ? AppColors.surfaceVariantDark : colorScheme.surfaceContainer),
                      border: Border.all(
                        color: isActive || isCompleted ? Colors.transparent : colorScheme.outlineVariant,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(Icons.check, size: 16, color: colorScheme.onPrimary)
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xxs),
                  Text(
                    steps[i],
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive
                          ? AppColors.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              // Connector line
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsetsDirectional.only(bottom: 18, start: AlhaiSpacing.xxs, end: AlhaiSpacing.xxs),
                    color: isCompleted
                        ? AppColors.success
                        : (isDark ? AppColors.surfaceVariantDark : colorScheme.surfaceContainer),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  // ============================================================================
  // STEP CONTENT
  // ============================================================================

  Widget _buildStepContent(AppLocalizations l10n, bool isDark, ColorScheme colorScheme) {
    switch (_currentStep) {
      case 0:
        return _buildStep1Invoice(l10n, isDark, colorScheme);
      case 1:
        return _buildStep2Items(l10n, isDark, colorScheme);
      case 2:
        return _buildStep3Reason(l10n, isDark, colorScheme);
      case 3:
        return _buildStep4Confirm(l10n, isDark, colorScheme);
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 1: Invoice Number
  Widget _buildStep1Invoice(AppLocalizations l10n, bool isDark, ColorScheme colorScheme) {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.enterInvoiceNumber, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        const SizedBox(height: AlhaiSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _invoiceController,
                decoration: InputDecoration(
                  hintText: l10n.invoiceExample,
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(Icons.receipt_long, color: colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: isDark ? AppColors.grey900 : colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                ),
                style: TextStyle(fontSize: 16, fontFamily: 'Courier', color: colorScheme.onSurface),
              ),
            ),
            const SizedBox(width: AlhaiSpacing.xs),
            FilledButton(
              onPressed: _loadInvoice,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.loadInvoice, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        if (_invoiceLoaded) ...[
          const SizedBox(height: AlhaiSpacing.md),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.success.withValues(alpha: 0.1) : AppColors.successSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.success.withValues(alpha: 0.3) : const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? AppColors.success.withValues(alpha: 0.2) : const Color(0xFFBBF7D0),
                  ),
                  child: const Icon(Icons.check, size: 18, color: AppColors.success),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.invoiceLoaded(_invoiceController.text.isNotEmpty ? _invoiceController.text : 'INV-889'),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.invoiceLoadedCustomer('أحمد محمد', '2024/08/10'),
                        style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF166534)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Step 2: Select Items
  Widget _buildStep2Items(AppLocalizations l10n, bool isDark, ColorScheme colorScheme) {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.sm),
          decoration: BoxDecoration(
            color: isDark ? AppColors.info.withValues(alpha: 0.1) : AppColors.infoSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: isDark ? const Color(0xFF60A5FA) : AppColors.info),
              const SizedBox(width: AlhaiSpacing.xs),
              Expanded(
                child: Text(
                  l10n.selectItemsInfo,
                  style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF), height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AlhaiSpacing.md),
        ...List.generate(_items.length, (i) => _buildItemCard(i, l10n, isDark, colorScheme)),
      ],
    );
  }

  Widget _buildItemCard(int index, AppLocalizations l10n, bool isDark, ColorScheme colorScheme) {
    final item = _items[index];
    final isDisabled = item.maxReturn == 0;
    final isSelected = _selectedItems.contains(index);

    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : colorScheme.outlineVariant,
        ),
        boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 8)] : null,
      ),
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: isDisabled ? null : (v) {
                    setState(() {
                      if (v == true) {
                        _selectedItems.add(index);
                        _itemQuantities[index] = 1;
                      } else {
                        _selectedItems.remove(index);
                        _itemQuantities.remove(index);
                      }
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                      Text(item.sku, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant, fontFamily: 'Courier')),
                    ],
                  ),
                ),
                Text('${item.price.toStringAsFixed(2)} ${l10n.sar}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              ],
            ),
            if (!isDisabled && isSelected) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: colorScheme.outlineVariant))),
                child: Row(
                  children: [
                    // Quantity controls
                    _quantityButton(Icons.remove, () {
                      if ((_itemQuantities[index] ?? 1) > 1) {
                        setState(() => _itemQuantities[index] = (_itemQuantities[index] ?? 1) - 1);
                      }
                    }, isDark, colorScheme),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text('${_itemQuantities[index] ?? 1}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                    ),
                    _quantityButton(Icons.add, () {
                      if ((_itemQuantities[index] ?? 1) < item.maxReturn) {
                        setState(() => _itemQuantities[index] = (_itemQuantities[index] ?? 1) + 1);
                      }
                    }, isDark, colorScheme),
                    const Spacer(),
                    Text(l10n.availableToReturn(item.maxReturn), style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
            if (isDisabled) ...[
              const SizedBox(height: AlhaiSpacing.xs),
              Container(
                padding: const EdgeInsets.only(top: AlhaiSpacing.xs),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: colorScheme.outlineVariant))),
                child: Text(l10n.alreadyReturnedFully, style: const TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w500)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap, bool isDark, ColorScheme colorScheme) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: isDark ? AppColors.borderDark : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: colorScheme.onSurface),
      ),
    );
  }

  // Step 3: Reason
  Widget _buildStep3Reason(AppLocalizations l10n, bool isDark, ColorScheme colorScheme) {
    return Column(
      key: const ValueKey('step3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.returnReasonLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        const SizedBox(height: AlhaiSpacing.sm),
        _buildReasonOption('defective', Icons.broken_image_outlined, l10n.defectiveProduct, isDark, colorScheme),
        _buildReasonOption('wrong', Icons.warning_amber, l10n.wrongProduct, isDark, colorScheme),
        _buildReasonOption('customer_request', Icons.assignment_return_outlined, l10n.customerRequest, isDark, colorScheme),
        _buildReasonOption('other', Icons.edit_note, l10n.otherReason, isDark, colorScheme),
        const SizedBox(height: AlhaiSpacing.md),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: l10n.additionalDetails,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
            filled: true,
            fillColor: isDark ? AppColors.grey900 : colorScheme.surfaceContainerLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
          style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildReasonOption(String value, IconData icon, String label, bool isDark, ColorScheme colorScheme) {
    final isSelected = _selectedReason == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedReason = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: AlhaiSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primary.withValues(alpha: 0.1) : AppColors.primarySurface)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            // Custom radio indicator to avoid deprecated Radio.groupValue/onChanged
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : colorScheme.outline,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }

  // Step 4: Confirmation
  Widget _buildStep4Confirm(AppLocalizations l10n, bool isDark, ColorScheme colorScheme) {
    final reasonText = switch (_selectedReason) {
      'defective' => l10n.defectiveProduct,
      'wrong' => l10n.wrongProduct,
      'customer_request' => l10n.customerRequest,
      _ => l10n.otherReason,
    };

    return Column(
      key: const ValueKey('step4'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.grey900 : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _buildSummaryRow(l10n.enterInvoiceNumber, '#${_invoiceController.text.isNotEmpty ? _invoiceController.text : "INV-889"}', isDark, colorScheme),
              const SizedBox(height: 10),
              _buildSummaryRow(l10n.customer, 'أحمد محمد', isDark, colorScheme),
              const SizedBox(height: 10),
              _buildSummaryRow(l10n.returnReason, reasonText, isDark, colorScheme),
              const SizedBox(height: 10),
              Divider(color: colorScheme.outlineVariant),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.refundAmount, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  Text(
                    '${_totalRefund.toStringAsFixed(2)} ${l10n.sar}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AlhaiSpacing.mdl),
        // Refund method
        Text(l10n.refundMethod, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        const SizedBox(height: AlhaiSpacing.sm),
        Row(
          children: [
            Expanded(child: _buildRefundMethodButton('cash', Icons.wallet, l10n.cashRefund, isDark, colorScheme)),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(child: _buildRefundMethodButton('credit', Icons.credit_card_outlined, l10n.storeCredit, isDark, colorScheme)),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontFamily: value.startsWith('#') ? 'Courier' : null)),
      ],
    );
  }

  Widget _buildRefundMethodButton(String method, IconData icon, String label, bool isDark, ColorScheme colorScheme) {
    final isSelected = _refundMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _refundMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primary.withValues(alpha: 0.1) : AppColors.primarySurface)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: isSelected ? AppColors.primary : colorScheme.onSurfaceVariant),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // FOOTER
  // ============================================================================

  Widget _buildFooter(AppLocalizations l10n, bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey900.withValues(alpha: 0.5) : colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          // Previous button
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: Text(l10n.previous, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AlhaiSpacing.sm),
          // Next / Submit button
          Expanded(
            child: FilledButton.icon(
              onPressed: _currentStep == 3 ? () => widget.onSuccess?.call() : _nextStep,
              icon: Icon(_currentStep == 3 ? Icons.check : Icons.arrow_back, size: 18),
              label: Text(
                _currentStep == 3 ? l10n.confirmReturn : l10n.next,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// نموذج صنف الفاتورة
class _InvoiceItem {
  final String name;
  final String sku;
  final double price;
  final int maxReturn;

  const _InvoiceItem({
    required this.name,
    required this.sku,
    required this.price,
    required this.maxReturn,
  });
}
