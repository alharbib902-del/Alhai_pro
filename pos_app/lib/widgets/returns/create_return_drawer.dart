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
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

class CreateReturnDrawer extends StatefulWidget {
  final VoidCallback? onSuccess;
  final ScrollController? scrollController;

  const CreateReturnDrawer({
    super.key,
    this.onSuccess,
    this.scrollController,
  });

  @override
  State<CreateReturnDrawer> createState() => _CreateReturnDrawerState();
}

class _CreateReturnDrawerState extends State<CreateReturnDrawer> {
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
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      width: isDesktop ? 500 : double.infinity,
      height: isDesktop ? double.infinity : null,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: isDesktop
            ? null
            : const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(l10n, isDark, isDesktop),
          // Content
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                // Wizard steps
                _buildStepIndicator(l10n, isDark),
                const SizedBox(height: 24),
                // Step content
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _buildStepContent(l10n, isDark),
                ),
              ],
            ),
          ),
          // Footer buttons
          _buildFooter(l10n, isDark),
        ],
      ),
    );
  }

  // ============================================================================
  // HEADER
  // ============================================================================

  Widget _buildHeader(AppLocalizations l10n, bool isDark, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.5) : AppColors.grey50,
        borderRadius: isDesktop
            ? null
            : const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(bottom: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.createNewReturn, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(l10n.processReturnRequest, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
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
                color: isDark ? const Color(0xFF374151) : Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
              ),
              child: Icon(Icons.close, size: 16, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // STEP INDICATOR
  // ============================================================================

  Widget _buildStepIndicator(AppLocalizations l10n, bool isDark) {
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
                              : (isDark ? const Color(0xFF374151) : AppColors.grey200),
                      border: Border.all(
                        color: isActive || isCompleted ? Colors.transparent : (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.white : (isDark ? AppColors.textMutedDark : AppColors.textMuted),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[i],
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive
                          ? AppColors.primary
                          : (isDark ? AppColors.textMutedDark : AppColors.textMuted),
                    ),
                  ),
                ],
              ),
              // Connector line
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 18, left: 4, right: 4),
                    color: isCompleted
                        ? AppColors.success
                        : (isDark ? const Color(0xFF374151) : AppColors.grey200),
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

  Widget _buildStepContent(AppLocalizations l10n, bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildStep1Invoice(l10n, isDark);
      case 1:
        return _buildStep2Items(l10n, isDark);
      case 2:
        return _buildStep3Reason(l10n, isDark);
      case 3:
        return _buildStep4Confirm(l10n, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 1: Invoice Number
  Widget _buildStep1Invoice(AppLocalizations l10n, bool isDark) {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.enterInvoiceNumber, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _invoiceController,
                decoration: InputDecoration(
                  hintText: l10n.invoiceExample,
                  hintStyle: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                  prefixIcon: Icon(Icons.receipt_long, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : AppColors.grey50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                ),
                style: TextStyle(fontSize: 16, fontFamily: 'Courier', color: isDark ? Colors.white : AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _loadInvoice,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.loadInvoice, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        if (_invoiceLoaded) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.success.withValues(alpha: 0.1) : const Color(0xFFDCFCE7),
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
                const SizedBox(width: 12),
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
  Widget _buildStep2Items(AppLocalizations l10n, bool isDark) {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.info.withValues(alpha: 0.1) : const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: isDark ? const Color(0xFF60A5FA) : AppColors.info),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.selectItemsInfo,
                  style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF), height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_items.length, (i) => _buildItemCard(i, l10n, isDark)),
      ],
    );
  }

  Widget _buildItemCard(int index, AppLocalizations l10n, bool isDark) {
    final item = _items[index];
    final isDisabled = item.maxReturn == 0;
    final isSelected = _selectedItems.contains(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF374151) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
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
                      Text(item.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                      Text(item.sku, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMuted, fontFamily: 'Courier')),
                    ],
                  ),
                ),
                Text('${item.price.toStringAsFixed(2)} ${l10n.sar}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
              ],
            ),
            if (!isDisabled && isSelected) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.divider))),
                child: Row(
                  children: [
                    // Quantity controls
                    _quantityButton(Icons.remove, () {
                      if ((_itemQuantities[index] ?? 1) > 1) {
                        setState(() => _itemQuantities[index] = (_itemQuantities[index] ?? 1) - 1);
                      }
                    }, isDark),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text('${_itemQuantities[index] ?? 1}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                    ),
                    _quantityButton(Icons.add, () {
                      if ((_itemQuantities[index] ?? 1) < item.maxReturn) {
                        setState(() => _itemQuantities[index] = (_itemQuantities[index] ?? 1) + 1);
                      }
                    }, isDark),
                    const Spacer(),
                    Text(l10n.availableToReturn(item.maxReturn), style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
                  ],
                ),
              ),
            ],
            if (isDisabled) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.divider))),
                child: Text(l10n.alreadyReturnedFully, style: const TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w500)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF4B5563) : AppColors.grey100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: isDark ? Colors.white : AppColors.textSecondary),
      ),
    );
  }

  // Step 3: Reason
  Widget _buildStep3Reason(AppLocalizations l10n, bool isDark) {
    return Column(
      key: const ValueKey('step3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.returnReasonLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
        const SizedBox(height: 12),
        _buildReasonOption('defective', Icons.broken_image_outlined, l10n.defectiveProduct, isDark),
        _buildReasonOption('wrong', Icons.warning_amber, l10n.wrongProduct, isDark),
        _buildReasonOption('customer_request', Icons.assignment_return_outlined, l10n.customerRequest, isDark),
        _buildReasonOption('other', Icons.edit_note, l10n.otherReason, isDark),
        const SizedBox(height: 16),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: l10n.additionalDetails,
            hintStyle: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMuted, fontSize: 13),
            filled: true,
            fillColor: isDark ? const Color(0xFF0F172A) : AppColors.grey50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
          style: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildReasonOption(String value, IconData icon, String label, bool isDark) {
    final isSelected = _selectedReason == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedReason = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primary.withValues(alpha: 0.1) : AppColors.primarySurface)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          ),
        ),
        child: Row(
          children: [
            // Custom radio indicator to avoid deprecated Radio.groupValue/onChanged
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : (isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.grey400),
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
            Icon(icon, size: 18, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? Colors.white : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  // Step 4: Confirmation
  Widget _buildStep4Confirm(AppLocalizations l10n, bool isDark) {
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : AppColors.grey50,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _buildSummaryRow(l10n.enterInvoiceNumber, '#${_invoiceController.text.isNotEmpty ? _invoiceController.text : "INV-889"}', isDark),
              const SizedBox(height: 10),
              _buildSummaryRow(l10n.customer, 'أحمد محمد', isDark),
              const SizedBox(height: 10),
              _buildSummaryRow(l10n.returnReason, reasonText, isDark),
              const SizedBox(height: 10),
              Divider(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.refundAmount, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                  Text(
                    '${_totalRefund.toStringAsFixed(2)} ${l10n.sar}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Refund method
        Text(l10n.refundMethod, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildRefundMethodButton('cash', Icons.wallet, l10n.cashRefund, isDark)),
            const SizedBox(width: 12),
            Expanded(child: _buildRefundMethodButton('credit', Icons.credit_card_outlined, l10n.storeCredit, isDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary, fontFamily: value.startsWith('#') ? 'Courier' : null)),
      ],
    );
  }

  Widget _buildRefundMethodButton(String method, IconData icon, String label, bool isDark) {
    final isSelected = _refundMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _refundMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primary.withValues(alpha: 0.1) : AppColors.primarySurface)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: isSelected ? AppColors.primary : (isDark ? AppColors.textMutedDark : AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : (isDark ? AppColors.textMutedDark : AppColors.textSecondary),
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

  Widget _buildFooter(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.5) : AppColors.grey50,
        border: Border(top: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.divider)),
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
                  side: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.border),
                ),
                child: Text(l10n.previous, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
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
                foregroundColor: Colors.white,
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
