import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'customer_search_dialog.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart' show CurrencyFormatter;

/// طرق الدفع المتاحة
enum PaymentMethod {
  cash(Icons.payments, AppColors.cash),
  card(Icons.credit_card, AppColors.card),
  mixed(Icons.call_split, AppColors.purple),
  credit(Icons.schedule, AppColors.secondary);

  const PaymentMethod(this.icon, this.color);
  final IconData icon;
  final Color color;

  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case PaymentMethod.cash:
        return l10n.cash;
      case PaymentMethod.card:
        return l10n.card;
      case PaymentMethod.mixed:
        return l10n.mixed;
      case PaymentMethod.credit:
        return l10n.credit;
    }
  }
}

/// تقسيم الدفع
class PaymentSplitEntry {
  final PaymentMethod method;
  final double amount;

  const PaymentSplitEntry({required this.method, required this.amount});
}

/// نتيجة عملية الدفع
class PaymentResult {
  final PaymentMethod method;
  final double amountPaid;
  final double change;
  final bool success;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final List<PaymentSplitEntry>? splits;

  const PaymentResult({
    required this.method,
    required this.amountPaid,
    required this.change,
    required this.success,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.splits,
  });
}

/// Widget للدفع المدمج داخل شاشة POS
///
/// يعرض خيارات الدفع (نقد/بطاقة/مختلط/آجل)
class InlinePayment extends StatefulWidget {
  final double total;
  final double creditLimit;
  final String storeId;
  final VoidCallback? onCancel;
  final void Function(PaymentResult result)? onComplete;

  const InlinePayment({
    super.key,
    required this.total,
    required this.storeId,
    this.creditLimit = 500.0,
    this.onCancel,
    this.onComplete,
  });

  @override
  State<InlinePayment> createState() => _InlinePaymentState();
}

class _InlinePaymentState extends State<InlinePayment> {
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  final _amountController = TextEditingController();
  final _focusNode = FocusNode();
  double _change = 0;

  // بيانات العميل (للدين)
  CustomerSearchResult? _selectedCustomer;
  bool _creditLimitExceeded = false;

  // بيانات الدفع المختلط
  final List<PaymentSplitEntry> _splits = [];
  PaymentMethod _splitMethod = PaymentMethod.cash;
  final _splitAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.total.toStringAsFixed(2);
    _amountController.addListener(_calculateChange);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _splitAmountController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _calculateChange() {
    final paid = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      final diff = paid - widget.total;
      // تجنب floating point: إذا الفرق أقل من 0.01 (هللة) يعتبر صفر
      _change = diff.abs() < 0.01 ? 0 : diff;
    });
  }

  void _onMethodSelected(PaymentMethod method) {
    setState(() {
      _selectedMethod = method;
      _selectedCustomer = null;
      _creditLimitExceeded = false;
      _splits.clear();

      if (method == PaymentMethod.mixed) {
        _splitAmountController.text = widget.total.toStringAsFixed(2);
      } else if (method != PaymentMethod.cash) {
        _amountController.text = widget.total.toStringAsFixed(2);
      }
    });
  }

  double get _splitTotalPaid => _splits.fold(0.0, (sum, s) => sum + s.amount);

  double get _splitRemaining => widget.total - _splitTotalPaid;

  Future<void> _selectCustomer() async {
    final customer =
        await CustomerSearchDialog.show(context, storeId: widget.storeId);
    if (customer != null && mounted) {
      setState(() {
        _selectedCustomer = customer;
        // التحقق من حد الدين
        final currentDebt = customer.balance.abs();
        _creditLimitExceeded =
            (currentDebt + widget.total) > widget.creditLimit;
      });
    }
  }

  void _addSplit() {
    final amount = double.tryParse(_splitAmountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).enterValidAmountError),
            backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }
    if (amount > 999999.99) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).amountExceedsMaxError),
            backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }
    if (amount > _splitRemaining + 0.01) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context).amountExceedsRemainingError),
            backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }

    // إذا كانت الدفعة آجل، يجب اختيار العميل أولاً
    if (_splitMethod == PaymentMethod.credit && _selectedCustomer == null) {
      _selectCustomer().then((_) {
        if (_selectedCustomer != null) _addSplit();
      });
      return;
    }

    setState(() {
      _splits.add(PaymentSplitEntry(method: _splitMethod, amount: amount));
      final remaining = _splitRemaining;
      _splitAmountController.text =
          remaining > 0 ? remaining.toStringAsFixed(2) : '0.00';
    });
  }

  void _removeSplit(int index) {
    setState(() {
      _splits.removeAt(index);
      _splitAmountController.text = _splitRemaining.toStringAsFixed(2);
    });
  }

  void _completePayment() {
    if (_selectedMethod == PaymentMethod.cash) {
      final paid = double.tryParse(_amountController.text) ?? 0;
      if (paid < 0 || paid > 999999.99) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).amountBetweenZeroAndMax),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      // tolerance 0.01 (هللة) لتجنب خطأ floating point
      // مثال: 166.70 يُقرأ 166.6999... وهو أقل تقنياً
      if (paid < widget.total - 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).amountLessThanTotal),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      widget.onComplete?.call(PaymentResult(
        method: PaymentMethod.cash,
        amountPaid: paid,
        change: _change > 0 ? _change : 0,
        success: true,
      ));
    } else if (_selectedMethod == PaymentMethod.card) {
      widget.onComplete?.call(PaymentResult(
        method: PaymentMethod.card,
        amountPaid: widget.total,
        change: 0,
        success: true,
      ));
    } else if (_selectedMethod == PaymentMethod.credit) {
      if (_selectedCustomer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context).selectCustomerFirstError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      if (_creditLimitExceeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).debtLimitExceededError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      widget.onComplete?.call(PaymentResult(
        method: PaymentMethod.credit,
        amountPaid: widget.total,
        change: 0,
        success: true,
        customerId: _selectedCustomer!.id,
        customerName: _selectedCustomer!.name,
        customerPhone: _selectedCustomer!.phone,
      ));
    } else if (_selectedMethod == PaymentMethod.mixed) {
      if (_splitRemaining > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context).completePaymentFirstError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      widget.onComplete?.call(PaymentResult(
        method: PaymentMethod.mixed,
        amountPaid: widget.total,
        change: 0,
        success: true,
        splits: List.from(_splits),
        customerId: _selectedCustomer?.id,
        customerName: _selectedCustomer?.name,
        customerPhone: _selectedCustomer?.phone,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // العنوان
            Row(
              children: [
                Icon(Icons.payment, color: theme.colorScheme.primary),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(
                  l10n.payment,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (widget.onCancel != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: widget.onCancel,
                    visualDensity: VisualDensity.compact,
                    tooltip: l10n.cancel,
                  ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.md),

            // الإجمالي
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.total, style: theme.textTheme.bodyLarge),
                  Text(
                    CurrencyFormatter.formatWithContext(context, widget.total),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),

            // طرق الدفع
            Row(
              children: PaymentMethod.values.map((method) {
                final isSelected = _selectedMethod == method;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _PaymentMethodButton(
                      method: method,
                      isSelected: isSelected,
                      onTap: () => _onMethodSelected(method),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AlhaiSpacing.md),

            // محتوى حسب طريقة الدفع
            if (_selectedMethod == PaymentMethod.cash) _buildCashSection(theme),
            if (_selectedMethod == PaymentMethod.credit)
              _buildCreditSection(theme, isDark),
            if (_selectedMethod == PaymentMethod.mixed)
              _buildMixedSection(theme, isDark),

            // زر إتمام الدفع
            const SizedBox(height: AlhaiSpacing.xs),
            FilledButton.icon(
              onPressed: _canComplete ? _completePayment : null,
              icon: const Icon(Icons.check_circle),
              label: Text(AppLocalizations.of(context).completePaymentLabel),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
                textStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canComplete {
    if (_selectedMethod == PaymentMethod.credit) {
      return _selectedCustomer != null && !_creditLimitExceeded;
    }
    if (_selectedMethod == PaymentMethod.mixed) {
      return _splitRemaining <= 0.01;
    }
    return true;
  }

  // ============================================================
  // قسم الدفع النقدي
  // ============================================================
  Widget _buildCashSection(ThemeData theme) {
    return Column(
      children: [
        TextField(
          controller: _amountController,
          focusNode: _focusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            LengthLimitingTextInputFormatter(12),
          ],
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).receivedAmountLabel,
            prefixText: AppLocalizations.of(context).sarPrefix,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
          ),
          onSubmitted: (_) => _completePayment(),
        ),
        const SizedBox(height: AlhaiSpacing.sm),
        // أزرار المبالغ السريعة
        Wrap(
          spacing: AlhaiSpacing.xs,
          runSpacing: AlhaiSpacing.xs,
          alignment: WrapAlignment.center,
          children: [50, 100, 200, 500].map((amount) {
            return ActionChip(
              label: Text(
                  AppLocalizations.of(context).amountSar(amount.toString())),
              onPressed: () {
                _amountController.text = amount.toStringAsFixed(2);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AlhaiSpacing.sm),
        if (_change > 0)
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.currency_exchange,
                        color: AppColors.success),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Text(AppLocalizations.of(context).remainingLabel),
                  ],
                ),
                Text(
                  CurrencyFormatter.formatWithContext(context, _change),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ============================================================
  // قسم الدفع الآجل (الدين)
  // ============================================================
  Widget _buildCreditSection(ThemeData theme, bool isDark) {
    return Column(
      children: [
        // زر اختيار العميل
        InkWell(
          onTap: _selectCustomer,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedCustomer != null
                    ? AppColors.primary
                    : (isDark ? theme.dividerColor : AppColors.border),
              ),
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : AppColors.grey50,
            ),
            child: Row(
              children: [
                Icon(
                  _selectedCustomer != null
                      ? Icons.person
                      : Icons.person_search,
                  color: _selectedCustomer != null
                      ? AppColors.primary
                      : (isDark
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.54)
                          : AppColors.textMuted),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: _selectedCustomer != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedCustomer!.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? theme.colorScheme.onSurface
                                    : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              _selectedCustomer!.phone,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? theme.colorScheme.onSurface
                                        .withValues(alpha: 0.54)
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          AppLocalizations.of(context).selectCustomerLabel,
                          style: TextStyle(
                            color: isDark
                                ? theme.colorScheme.onSurface
                                    .withValues(alpha: 0.54)
                                : AppColors.textMuted,
                          ),
                        ),
                ),
                Icon(
                  Icons.chevron_left,
                  color: isDark
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                      : AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),

        // معلومات الحساب
        if (_selectedCustomer != null) ...[
          const SizedBox(height: AlhaiSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _creditLimitExceeded
                  ? theme.colorScheme.error.withValues(alpha: 0.1)
                  : AppColors.success.withValues(alpha: 0.1),
              border: Border.all(
                color: _creditLimitExceeded
                    ? theme.colorScheme.error.withValues(alpha: 0.3)
                    : AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context).currentBalanceTitle),
                    Text(
                      CurrencyFormatter.formatWithContext(
                          context, _selectedCustomer!.balance),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedCustomer!.balance < 0
                            ? theme.colorScheme.error
                            : AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context).creditLimitTitle),
                    Text(
                      AppLocalizations.of(context).creditLimitAmount,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (_creditLimitExceeded) ...[
                  const SizedBox(height: AlhaiSpacing.xs),
                  Row(
                    children: [
                      Icon(Icons.warning_amber,
                          color: theme.colorScheme.error, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context).debtLimitExceededWarning,
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AlhaiSpacing.sm),
      ],
    );
  }

  // ============================================================
  // قسم الدفع المختلط
  // ============================================================
  Widget _buildMixedSection(ThemeData theme, bool isDark) {
    return Column(
      children: [
        // ملخص
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.sm),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8)
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context).paidLabel,
                      style: const TextStyle(color: Colors.white70)),
                  Text(
                    CurrencyFormatter.formatWithContext(
                        context, _splitTotalPaid),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: AlhaiSpacing.xxs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _splitRemaining <= 0.01
                        ? AppLocalizations.of(context).completeLabel
                        : AppLocalizations.of(context).remainingLabel,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _splitRemaining <= 0.01
                        ? '✓'
                        : CurrencyFormatter.formatWithContext(
                            context, _splitRemaining),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AlhaiSpacing.sm),

        // قائمة الدفعات المضافة
        if (_splits.isNotEmpty) ...[
          ...List.generate(_splits.length, (i) {
            final split = _splits[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.sm, vertical: AlhaiSpacing.xs),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : AppColors.grey50,
              ),
              child: Row(
                children: [
                  Icon(split.method.icon, color: split.method.color, size: 20),
                  const SizedBox(width: AlhaiSpacing.xs),
                  Text(split.method
                      .localizedLabel(AppLocalizations.of(context))),
                  const Spacer(),
                  Text(
                    CurrencyFormatter.formatWithContext(context, split.amount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: AlhaiSpacing.xxs),
                  InkWell(
                    onTap: () => _removeSplit(i),
                    child: Icon(Icons.close,
                        color: theme.colorScheme.error, size: 18),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AlhaiSpacing.xs),
        ],

        // إضافة دفعة جديدة
        if (_splitRemaining > 0.01) ...[
          // طريقة الدفع للدفعة
          Row(
            children: [
              PaymentMethod.cash,
              PaymentMethod.card,
              PaymentMethod.credit
            ].map((m) {
              final isSelected = _splitMethod == m;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Material(
                    color: isSelected
                        ? m.color.withValues(alpha: 0.15)
                        : (isDark
                            ? theme.colorScheme.surfaceContainerHighest
                            : AppColors.grey50),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () => setState(() => _splitMethod = m),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: AlhaiSpacing.xs),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? m.color : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(m.icon,
                                color: isSelected ? m.color : theme.hintColor,
                                size: 20),
                            const SizedBox(height: 2),
                            Text(
                              m.localizedLabel(AppLocalizations.of(context)),
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? m.color : theme.hintColor,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AlhaiSpacing.xs),

          // حقل المبلغ + زر إضافة
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _splitAmountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    LengthLimitingTextInputFormatter(12),
                  ],
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).amount,
                    suffixText: AppLocalizations.of(context).sarCurrency,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.sm, vertical: AlhaiSpacing.sm),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _addSplit(),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.xs),
              FilledButton.icon(
                onPressed: _addSplit,
                icon: const Icon(Icons.add, size: 18),
                label: Text(AppLocalizations.of(context).addPayment),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.sm, vertical: AlhaiSpacing.sm),
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),

          // اختيار العميل (إذا كانت الدفعة آجل)
          if (_splitMethod == PaymentMethod.credit && _selectedCustomer == null)
            Padding(
              padding: const EdgeInsets.only(top: AlhaiSpacing.xs),
              child: OutlinedButton.icon(
                onPressed: _selectCustomer,
                icon: const Icon(Icons.person_search, size: 18),
                label: Text(
                    AppLocalizations.of(context).selectCustomerFirstButton),
              ),
            ),
        ],
        const SizedBox(height: AlhaiSpacing.xs),
      ],
    );
  }
}

/// زر طريقة الدفع
class _PaymentMethodButton extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodButton({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color:
          isSelected ? method.color.withValues(alpha: 0.2) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? method.color
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                method.icon,
                color: isSelected ? method.color : theme.hintColor,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                method.localizedLabel(AppLocalizations.of(context)),
                style: TextStyle(
                  color: isSelected ? method.color : theme.hintColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
