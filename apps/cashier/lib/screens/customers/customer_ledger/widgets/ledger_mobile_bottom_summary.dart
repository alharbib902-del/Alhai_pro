/// شريط ملخّص مبسّط أسفل شاشة الهاتف (مدين/دائن/رصيد نهائي)
library;

import 'package:flutter/material.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

class LedgerMobileBottomSummary extends StatelessWidget {
  final double totalDebit;
  final double totalCredit;

  const LedgerMobileBottomSummary({
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
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _col(
                l10n.totalDebit,
                totalDebit.toStringAsFixed(0),
                AppColors.error,
                colorScheme,
              ),
            ),
            Expanded(
              child: _col(
                l10n.totalCredit,
                totalCredit.toStringAsFixed(0),
                AppColors.success,
                colorScheme,
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.sm,
                  vertical: AlhaiSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color:
                      (finalBalance > 0 ? AppColors.error : AppColors.success)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.finalBalance,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.xxxs),
                    Text(
                      finalBalance.abs().toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: finalBalance > 0
                            ? AppColors.error
                            : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _col(
    String label,
    String value,
    Color valueColor,
    ColorScheme colorScheme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: colorScheme.outline,
          ),
        ),
        const SizedBox(height: AlhaiSpacing.xxxs),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
