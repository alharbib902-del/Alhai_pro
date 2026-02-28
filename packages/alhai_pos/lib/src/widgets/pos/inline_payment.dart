import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'customer_search_dialog.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart' show CurrencyFormatter;

/// طرق الدفع المتاحة
enum PaymentMethod {
  cash(Icons.payments, Color(0xFF4CAF50)),
  card(Icons.credit_card, Color(0xFF2196F3)),
  mixed(Icons.call_split, Colors.purple),
  credit(Icons.schedule, Color(0xFFFF9800));

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
  final VoidCallback? onCancel;
  final void Function(PaymentResult result)? onComplete;

  const InlinePayment({
    super.key,
    required this.total,
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
      _change = paid - widget.total;
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

  double get _splitTotalPaid =>
      _splits.fold(0.0, (sum, s) => sum + s.amount);

  double get _splitRemaining => widget.total - _splitTotalPaid;

  Future<void> _selectCustomer() async {
    final customer = await CustomerSearchDialog.show(context);
    if (customer != null && mounted) {
      setState(() {
        _selectedCustomer = customer;
        // التحقق من حد الدين
        final currentDebt = customer.balance.abs();
        _creditLimitExceeded = (currentDebt + widget.total) > widget.creditLimit;
      });
    }
  }

  void _addSplit() {
    final amount = double.tryParse(_splitAmountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('أدخل مبلغ صحيح'), backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }
    if (amount > 999999.99) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('المبلغ يجب أن لا يتجاوز 999,999.99'), backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }
    if (amount > _splitRemaining + 0.01) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('المبلغ أكبر من المتبقي'), backgroundColor: Theme.of(context).colorScheme.error),
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
            content: const Text('المبلغ يجب أن يكون بين 0 و 999,999.99'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      if (paid < widget.total) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('المبلغ المستلم أقل من الإجمالي'),
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
            content: const Text('يجب اختيار العميل أولاً'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      if (_creditLimitExceeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم تجاوز حد الدين للعميل'),
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
            content: const Text('أكمل الدفع أولاً'),
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
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // العنوان
          Row(
            children: [
              Icon(Icons.payment, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
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
                ),
            ],
          ),
          const SizedBox(height: 16),

          // الإجمالي
          Container(
            padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 16),

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
          const SizedBox(height: 16),

          // محتوى حسب طريقة الدفع
          if (_selectedMethod == PaymentMethod.cash) _buildCashSection(theme),
          if (_selectedMethod == PaymentMethod.credit) _buildCreditSection(theme, isDark),
          if (_selectedMethod == PaymentMethod.mixed) _buildMixedSection(theme, isDark),

          // زر إتمام الدفع
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _canComplete ? _completePayment : null,
            icon: const Icon(Icons.check_circle),
            label: const Text('إتمام الدفع'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            LengthLimitingTextInputFormatter(12),
          ],
          decoration: InputDecoration(
            labelText: 'المبلغ المستلم',
            prefixText: 'ر.س ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
          ),
          onSubmitted: (_) => _completePayment(),
        ),
        const SizedBox(height: 12),
        // أزرار المبالغ السريعة
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [50, 100, 200, 500].map((amount) {
            return ActionChip(
              label: Text('$amount ر.س'),
              onPressed: () {
                _amountController.text = amount.toStringAsFixed(2);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        if (_change > 0)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.currency_exchange, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.remainingLabel),
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
              color: isDark ? theme.colorScheme.surfaceContainerHighest : AppColors.grey50,
            ),
            child: Row(
              children: [
                Icon(
                  _selectedCustomer != null
                      ? Icons.person
                      : Icons.person_search,
                  color: _selectedCustomer != null
                      ? AppColors.primary
                      : (isDark ? theme.colorScheme.onSurface.withValues(alpha: 0.54) : AppColors.textMuted),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _selectedCustomer != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedCustomer!.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark ? theme.colorScheme.onSurface : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              _selectedCustomer!.phone,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? theme.colorScheme.onSurface.withValues(alpha: 0.54) : AppColors.textMuted,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'اختر العميل',
                          style: TextStyle(
                            color: isDark ? theme.colorScheme.onSurface.withValues(alpha: 0.54) : AppColors.textMuted,
                          ),
                        ),
                ),
                Icon(
                  Icons.chevron_left,
                  color: isDark ? theme.colorScheme.onSurface.withValues(alpha: 0.38) : AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),

        // معلومات الحساب
        if (_selectedCustomer != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
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
                    const Text('الرصيد الحالي'),
                    Text(
                      CurrencyFormatter.formatWithContext(context, _selectedCustomer!.balance),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedCustomer!.balance < 0 ? theme.colorScheme.error : AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('حد الائتمان'),
                    Text(
                      '500.00 ر.س',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? theme.colorScheme.onSurface.withValues(alpha: 0.7) : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (_creditLimitExceeded) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: theme.colorScheme.error, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'تجاوز حد الدين!',
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
        const SizedBox(height: 12),
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.paidLabel, style: const TextStyle(color: Colors.white70)),
                  Text(
                    CurrencyFormatter.formatWithContext(context, _splitTotalPaid),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _splitRemaining <= 0.01 ? AppLocalizations.of(context)!.completeLabel : AppLocalizations.of(context)!.remainingLabel,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _splitRemaining <= 0.01
                        ? '✓'
                        : CurrencyFormatter.formatWithContext(context, _splitRemaining),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // قائمة الدفعات المضافة
        if (_splits.isNotEmpty) ...[
          ...List.generate(_splits.length, (i) {
            final split = _splits[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? theme.colorScheme.surfaceContainerHighest : AppColors.grey50,
              ),
              child: Row(
                children: [
                  Icon(split.method.icon, color: split.method.color, size: 20),
                  const SizedBox(width: 8),
                  Text(split.method.localizedLabel(AppLocalizations.of(context)!)),
                  const Spacer(),
                  Text(
                    CurrencyFormatter.formatWithContext(context, split.amount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _removeSplit(i),
                    child: Icon(Icons.close, color: theme.colorScheme.error, size: 18),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
        ],

        // إضافة دفعة جديدة
        if (_splitRemaining > 0.01) ...[
          // طريقة الدفع للدفعة
          Row(
            children: [PaymentMethod.cash, PaymentMethod.card, PaymentMethod.credit].map((m) {
              final isSelected = _splitMethod == m;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Material(
                    color: isSelected
                        ? m.color.withValues(alpha: 0.15)
                        : (isDark ? theme.colorScheme.surfaceContainerHighest : AppColors.grey50),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () => setState(() => _splitMethod = m),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? m.color : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(m.icon, color: isSelected ? m.color : theme.hintColor, size: 20),
                            const SizedBox(height: 2),
                            Text(
                              m.localizedLabel(AppLocalizations.of(context)!),
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? m.color : theme.hintColor,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
          const SizedBox(height: 8),

          // حقل المبلغ + زر إضافة
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _splitAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    LengthLimitingTextInputFormatter(12),
                  ],
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.amount,
                    suffixText: 'ر.س',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _addSplit(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _addSplit,
                icon: const Icon(Icons.add, size: 18),
                label: Text(AppLocalizations.of(context)!.addPayment),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),

          // اختيار العميل (إذا كانت الدفعة آجل)
          if (_splitMethod == PaymentMethod.credit && _selectedCustomer == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton.icon(
                onPressed: _selectCustomer,
                icon: const Icon(Icons.person_search, size: 18),
                label: const Text('اختر العميل أولاً'),
              ),
            ),
        ],
        const SizedBox(height: 8),
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
      color: isSelected
          ? method.color.withValues(alpha: 0.2)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? method.color : theme.colorScheme.outline.withValues(alpha: 0.3),
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
                method.localizedLabel(AppLocalizations.of(context)!),
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
