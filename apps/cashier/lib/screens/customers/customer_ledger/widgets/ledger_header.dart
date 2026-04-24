/// الشريط العلوي في شاشة كشف الحساب (زر رجوع، عنوان، زر تحديث)
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

class LedgerHeader extends StatelessWidget {
  final String customerName;
  final VoidCallback onRefresh;

  const LedgerHeader({
    super.key,
    required this.customerName,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: colorScheme.onSurface,
              ),
              tooltip: l10n.back,
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.customerLedger,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    customerName,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRefresh,
              icon: Icon(
                Icons.refresh_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              tooltip: l10n.refresh,
            ),
          ],
        ),
      ),
    );
  }
}
