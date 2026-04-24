/// حالة فارغة: لا توجد حركات في الفترة المفلترة
library;

import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

class LedgerEmptyState extends StatelessWidget {
  const LedgerEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.xxxl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: colorScheme.outline.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              l10n.noTransactions,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
