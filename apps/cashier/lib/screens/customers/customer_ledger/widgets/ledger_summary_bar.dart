/// شريط ملخّص الإجماليات للعرض الكامل (Desktop/Tablet)
///
/// يعرض: إجمالي المدين، إجمالي الدائن، الرصيد النهائي (بعد الفلترة).
library;

import 'package:flutter/material.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

class LedgerSummaryBar extends StatelessWidget {
  final double totalDebit;
  final double totalCredit;

  const LedgerSummaryBar({
    super.key,
    required this.totalDebit,
    required this.totalCredit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final finalBalance = totalDebit - totalCredit;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : AppSizes.shadowSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              label: l10n.totalDebit,
              value: totalDebit.toStringAsFixed(2),
              color: AppColors.error,
              icon: Icons.arrow_upward_rounded,
            ),
          ),
          _Divider(colorScheme: colorScheme),
          Expanded(
            child: _SummaryItem(
              label: l10n.totalCredit,
              value: totalCredit.toStringAsFixed(2),
              color: AppColors.success,
              icon: Icons.arrow_downward_rounded,
            ),
          ),
          _Divider(colorScheme: colorScheme),
          Expanded(
            child: _SummaryItem(
              label: l10n.finalBalance,
              value: finalBalance.abs().toStringAsFixed(2),
              color: finalBalance > 0 ? AppColors.error : AppColors.success,
              icon: Icons.account_balance_wallet_outlined,
              isBold: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final ColorScheme colorScheme;
  const _Divider({required this.colorScheme});

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 48,
    color: colorScheme.outlineVariant,
    margin: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
  );
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool isBold;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
