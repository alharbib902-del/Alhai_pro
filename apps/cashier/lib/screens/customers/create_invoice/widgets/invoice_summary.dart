/// Invoice Summary — بطاقة الإجمالي (subtotal + discount input + VAT + total)
///
/// تقرأ الحالة من [invoiceDraftProvider] مباشرة؛ إدخال الخصم يُحدّث الحالة
/// عبر `.notifier.setDiscount(double)`. ضريبة VAT ثابتة 15% (السعودية).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

import '../providers/invoice_draft_notifier.dart';

class InvoiceSummary extends ConsumerStatefulWidget {
  const InvoiceSummary({super.key});

  @override
  ConsumerState<InvoiceSummary> createState() => _InvoiceSummaryState();
}

class _InvoiceSummaryState extends ConsumerState<InvoiceSummary> {
  late final TextEditingController _discountController;

  @override
  void initState() {
    super.initState();
    final current = ref.read(invoiceDraftProvider).discount;
    _discountController = TextEditingController(
      text: current == 0 ? '0' : current.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  void _onDiscountChanged(String raw) {
    final parsed = double.tryParse(raw) ?? 0;
    ref.read(invoiceDraftProvider.notifier).setDiscount(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(invoiceDraftProvider);

    // Keep controller in sync if draft was reset elsewhere.
    //
    // Cursor-jump fix (P1 #6): while the user is typing "10.50", the
    // intermediate value "10.5" reaches the notifier; if we then unconditionally
    // overwrote `controller.text` with `"10.50"` the caret would jump to
    // position 0 between every keystroke. Guard: only rewrite when the
    // controller's parsed value is actually out of sync with the draft,
    // and preserve caret position when we do.
    final draftDiscountText = state.discount == 0
        ? '0'
        : state.discount.toStringAsFixed(2);
    final currentText = _discountController.text;
    final currentParsed = double.tryParse(currentText);
    final outOfSync = currentParsed != state.discount;
    // Only rewrite when:
    //  (a) parsed value differs (e.g. external reset),
    //  (b) text surface differs (avoid redundant assignment).
    // Preserve caret at a clamped offset so typing doesn't reset the cursor.
    if (outOfSync && currentText != draftDiscountText) {
      final clampedOffset = draftDiscountText.length <= currentText.length
          ? _discountController.selection.baseOffset.clamp(
              0,
              draftDiscountText.length,
            )
          : draftDiscountText.length;
      _discountController.value = TextEditingValue(
        text: draftDiscountText,
        selection: TextSelection.collapsed(offset: clampedOffset),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.totalAmountLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _Row(
            label: l10n.subtotal,
            value: CurrencyFormatter.formatWithContext(context, state.subtotal),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          // Discount input
          Row(
            children: [
              Text(
                l10n.discount,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  onChanged: _onDiscountChanged,
                  decoration: InputDecoration(
                    hintText: '0',
                    suffixText: l10n.sar,
                    suffixStyle: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.sm,
                      vertical: AlhaiSpacing.xs,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          _Row(
            label: '${l10n.tax} (15%)',
            value: CurrencyFormatter.formatWithContext(context, state.tax),
          ),
          Divider(height: 24, color: colorScheme.outlineVariant),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.totalAmountLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                CurrencyFormatter.formatWithContext(context, state.total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
