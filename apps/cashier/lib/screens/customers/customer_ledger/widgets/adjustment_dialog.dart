/// حوار التسوية اليدوية — ندخل نوع التسوية + المبلغ + السبب،
/// ثم نستدعي onSave للـ container.
///
/// استخدام:
/// ```dart
/// showAdjustmentDialog(context, onSave: (type, amount, reason, date) => ...);
/// ```
library;

import 'package:flutter/material.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiSnackbar, AlhaiSpacing;

import 'adjustment_type_option.dart';

/// callback عند حفظ التسوية
typedef AdjustmentSaveCallback =
    void Function(String type, double amount, String reason, DateTime date);

/// يعرض حوار التسوية اليدوية.
Future<void> showAdjustmentDialog(
  BuildContext context, {
  required AdjustmentSaveCallback onSave,
}) {
  return showDialog(
    context: context,
    builder: (_) => _AdjustmentDialogContent(onSave: onSave),
  );
}

class _AdjustmentDialogContent extends StatefulWidget {
  final AdjustmentSaveCallback onSave;
  const _AdjustmentDialogContent({required this.onSave});

  @override
  State<_AdjustmentDialogContent> createState() =>
      _AdjustmentDialogContentState();
}

class _AdjustmentDialogContentState extends State<_AdjustmentDialogContent> {
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  String _adjustmentType = 'debit';

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: colorScheme.surface,
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DialogHeader(l10n: l10n, colorScheme: colorScheme),
            const SizedBox(height: AlhaiSpacing.lg),
            _FieldLabel(l10n.adjustmentType),
            const SizedBox(height: AlhaiSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: AdjustmentTypeOption(
                    label: l10n.debitAdjustment,
                    icon: Icons.arrow_upward_rounded,
                    color: AppColors.error,
                    isSelected: _adjustmentType == 'debit',
                    onTap: () => setState(() => _adjustmentType = 'debit'),
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: AdjustmentTypeOption(
                    label: l10n.creditAdjustment,
                    icon: Icons.arrow_downward_rounded,
                    color: AppColors.success,
                    isSelected: _adjustmentType == 'credit',
                    onTap: () => setState(() => _adjustmentType = 'credit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.mdl),
            _FieldLabel(l10n.adjustmentAmount),
            const SizedBox(height: AlhaiSpacing.xs),
            _AmountField(
              controller: _amountController,
              prefix: l10n.sar,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: AlhaiSpacing.mdl),
            _FieldLabel(l10n.adjustmentReason),
            const SizedBox(height: AlhaiSpacing.xs),
            _ReasonField(
              controller: _reasonController,
              hint: l10n.adjustmentReason,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 28),
            _DialogActions(
              l10n: l10n,
              colorScheme: colorScheme,
              onSave: _onSavePressed,
            ),
          ],
        ),
      ),
    );
  }

  void _onSavePressed() {
    final l10n = AppLocalizations.of(context);
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      AlhaiSnackbar.error(context, l10n.enterValidAmount);
      return;
    }
    Navigator.pop(context);
    widget.onSave(
      _adjustmentType,
      amount,
      _reasonController.text,
      DateTime.now(),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme colorScheme;

  const _DialogHeader({required this.l10n, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.tune_rounded,
            size: 20,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AlhaiSpacing.sm),
        Text(
          l10n.manualAdjustment,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.close_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          tooltip: l10n.close,
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final String prefix;
  final ColorScheme colorScheme;

  const _AmountField({
    required this.controller,
    required this.prefix,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: '0.00',
        hintStyle: TextStyle(color: colorScheme.outline),
        prefixText: '$prefix ',
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.md,
          vertical: 14,
        ),
      ),
    );
  }
}

class _ReasonField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ColorScheme colorScheme;

  const _ReasonField({
    required this.controller,
    required this.hint,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 2,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colorScheme.outline),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.md,
          vertical: 14,
        ),
      ),
    );
  }
}

class _DialogActions extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme colorScheme;
  final VoidCallback onSave;

  const _DialogActions({
    required this.l10n,
    required this.colorScheme,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
              side: BorderSide(color: colorScheme.outlineVariant),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.cancel),
          ),
        ),
        const SizedBox(width: AlhaiSpacing.sm),
        Expanded(
          child: FilledButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: Text(l10n.saveAdjustment),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
