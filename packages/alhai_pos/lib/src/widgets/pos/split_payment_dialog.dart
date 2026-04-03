/// مكون الدفع المقسم - Split Payment Dialog
///
/// نافذة منبثقة لاختيار طرق الدفع المتعددة
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// نافذة الدفع المقسم
class SplitPaymentDialog extends StatefulWidget {
  final double totalAmount;
  final String? customerName;
  final double? customerBalance;
  final Function(List<PaymentSplit>) onConfirm;

  const SplitPaymentDialog({
    super.key,
    required this.totalAmount,
    this.customerName,
    this.customerBalance,
    required this.onConfirm,
  });

  /// عرض النافذة
  static Future<List<PaymentSplit>?> show({
    required BuildContext context,
    required double totalAmount,
    String? customerName,
    double? customerBalance,
  }) {
    return showModalBottomSheet<List<PaymentSplit>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SplitPaymentDialog(
        totalAmount: totalAmount,
        customerName: customerName,
        customerBalance: customerBalance,
        onConfirm: (splits) => Navigator.pop(context, splits),
      ),
    );
  }

  @override
  State<SplitPaymentDialog> createState() => _SplitPaymentDialogState();
}

class _SplitPaymentDialogState extends State<SplitPaymentDialog> {
  final List<PaymentSplit> _splits = [];
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  final _amountController = TextEditingController();

  double get _totalPaid =>
      _splits.fold(0.0, (sum, split) => sum + split.amount);
  double get _remaining => widget.totalAmount - _totalPaid;
  bool get _isComplete => _remaining <= 0;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.totalAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
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
                    Text(
                      AppLocalizations.of(context)!.splitPaymentTitle,
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

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSizes.lg),
                  children: [
                    // Total & Remaining
                    _buildSummaryCard(),
                    const SizedBox(height: AppSizes.lg),

                    // Payment Methods
                    _buildPaymentMethods(),
                    const SizedBox(height: AppSizes.lg),

                    // Amount Input
                    _buildAmountInput(),
                    const SizedBox(height: AppSizes.md),

                    // Quick Amounts
                    _buildQuickAmounts(),
                    const SizedBox(height: AppSizes.lg),

                    // Add Button
                    if (!_isComplete) _buildAddButton(),
                    const SizedBox(height: AppSizes.lg),

                    // Splits List
                    if (_splits.isNotEmpty) _buildSplitsList(),
                  ],
                ),
              ),

              // Confirm Button
              _buildConfirmButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: AlignmentDirectional.topEnd,
          end: AlignmentDirectional.bottomStart,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.total,
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                AppLocalizations.of(context)!.priceSar(widget.totalAmount.toStringAsFixed(2)),
                style: AppTypography.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.paidLabel,
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                AppLocalizations.of(context)!.priceSar(_totalPaid.toStringAsFixed(2)),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: AppSizes.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isComplete ? AppLocalizations.of(context)!.completeLabel : AppLocalizations.of(context)!.remainingLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _isComplete
                    ? '✓'
                    : AppLocalizations.of(context)!.priceSar(_remaining.toStringAsFixed(2)),
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.paymentMethodTitle,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Row(
          children: PaymentMethod.values.map((method) {
            final isSelected = _selectedMethod == method;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xxs),
                child: _PaymentMethodCard(
                  method: method,
                  isSelected: isSelected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedMethod = method);
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.amount,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            suffixText: AppLocalizations.of(context)!.sarCurrency,
            filled: true,
            fillColor: AppColors.grey100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: BorderSide.none,
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAmounts() {
    final quickAmounts = [
      _remaining,
      50.0,
      100.0,
      200.0,
    ].where((a) => a > 0 && a <= widget.totalAmount).toList();

    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: quickAmounts.map((amount) {
        return ActionChip(
          label: Text(AppLocalizations.of(context)!.amountSar(amount.toStringAsFixed(0))),
          onPressed: () {
            _amountController.text = amount.toStringAsFixed(2);
          },
        );
      }).toList(),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      onPressed: _addSplit,
      icon: const Icon(Icons.add),
      label: Text(AppLocalizations.of(context)!.addPaymentEntry),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        minimumSize: const Size.fromHeight(48),
      ),
    );
  }

  Widget _buildSplitsList() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.payments,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        ...List.generate(_splits.length, (index) {
          final split = _splits[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppSizes.sm),
            child: ListTile(
              leading: Icon(
                split.method.icon,
                color: split.method.color,
              ),
              title: Text(split.method.localizedLabel(l10n)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.priceSar(split.amount.toStringAsFixed(2)),
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.error, size: 20),
                    onPressed: () => _removeSplit(index),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: ElevatedButton(
          onPressed: _isComplete ? _confirm : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            minimumSize: const Size.fromHeight(56),
          ),
          child: Text(
            _isComplete ? AppLocalizations.of(context)!.confirmSplitPayment : AppLocalizations.of(context)!.completePaymentToConfirm,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _addSplit() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.enterValidAmountSplit)),
      );
      return;
    }

    if (amount > _remaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.amountExceedsSplit)),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _splits.add(PaymentSplit(
        method: _selectedMethod,
        amount: amount,
      ));
      _amountController.text = _remaining > amount
          ? (_remaining - amount).toStringAsFixed(2)
          : '0.00';
    });
  }

  void _removeSplit(int index) {
    setState(() {
      _splits.removeAt(index);
      _amountController.text = _remaining.toStringAsFixed(2);
    });
  }

  void _confirm() {
    HapticFeedback.heavyImpact();
    widget.onConfirm(_splits);
  }
}

/// بطاقة طريقة الدفع
class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AlhaiDurations.standard,
      child: Material(
        color: isSelected ? method.color.withValues(alpha: 0.1) : AppColors.grey100,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.md,
              horizontal: AppSizes.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: isSelected ? method.color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  method.icon,
                  color: isSelected ? method.color : AppColors.textMuted,
                  size: 28,
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  method.localizedLabel(AppLocalizations.of(context)!),
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected ? method.color : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// طرق الدفع
enum PaymentMethod {
  cash,
  card,
  credit,
  transfer,
}

extension PaymentMethodExtension on PaymentMethod {
  String get label => _fallbackLabel;

  String get _fallbackLabel {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.credit:
        return 'Credit';
      case PaymentMethod.transfer:
        return 'Transfer';
    }
  }

  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case PaymentMethod.cash:
        return l10n.cash;
      case PaymentMethod.card:
        return l10n.card;
      case PaymentMethod.credit:
        return l10n.credit;
      case PaymentMethod.transfer:
        return l10n.transfer;
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return Icons.payments_outlined;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.credit:
        return Icons.access_time;
      case PaymentMethod.transfer:
        return Icons.sync_alt;
    }
  }

  Color get color {
    switch (this) {
      case PaymentMethod.cash:
        return AppColors.success;
      case PaymentMethod.card:
        return AppColors.primary;
      case PaymentMethod.credit:
        return AppColors.warning;
      case PaymentMethod.transfer:
        return Colors.purple;
    }
  }
}

/// نموذج الدفعة
class PaymentSplit {
  final PaymentMethod method;
  final double amount;

  PaymentSplit({
    required this.method,
    required this.amount,
  });
}
