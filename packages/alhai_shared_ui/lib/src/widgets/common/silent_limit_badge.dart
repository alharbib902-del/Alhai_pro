/// Silent-limit warning banner — Wave 8 / P0-33.
///
/// When a list-view DAO call returns exactly `limit` rows the UI can't tell
/// whether the store actually has that many or whether the silent ceiling
/// truncated the result. This badge sits above the list and tells the user
/// explicitly that more rows might be hidden, with an optional CTA to
/// refine filters.
///
/// The widget is intentionally cheap: a single banner-style row with an
/// amber background, info icon, message, and an optional action button.
/// Pair it with the SQL-aggregating DAO methods (e.g. `getSalesCount`,
/// `getTotalReceivable`, `aggregatePaymentBreakdownRaw`) for the actual
/// counts/sums — the badge surfaces the truncation, the aggregates give
/// the real numbers.
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

class SilentLimitBadge extends StatelessWidget {
  /// Number of rows actually returned. Badge only renders when this
  /// equals [limit]. Pass the raw `result.length` from the DAO call.
  final int rowCount;

  /// The DAO's limit value. Defaults to 1000 (matches `getAllSales`).
  final int limit;

  /// Optional action — typically opens a filter sheet or focuses the
  /// search input. When null the action button is hidden.
  final VoidCallback? onRefineFilters;

  /// Override the standard "refine filters" CTA label. Useful when the
  /// list has a different escape hatch (e.g. "switch to date range").
  final String? actionLabel;

  /// Override the message body. Useful when the screen wants to mention
  /// a domain-specific filter ("narrow the date window" instead of the
  /// generic "refine filters").
  final String? messageOverride;

  const SilentLimitBadge({
    super.key,
    required this.rowCount,
    this.limit = 1000,
    this.onRefineFilters,
    this.actionLabel,
    this.messageOverride,
  });

  @override
  Widget build(BuildContext context) {
    // Cheap guard — when the list isn't at the ceiling there's nothing to
    // surface. Returning SizedBox.shrink keeps the badge call sites simple
    // (`SilentLimitBadge(rowCount: rows.length)` always works).
    if (rowCount < limit) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.xs,
      ),
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 22,
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.silentLimitBadgeTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  messageOverride ?? l10n.silentLimitBadgeMessage(limit),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
          if (onRefineFilters != null) ...[
            const SizedBox(width: AlhaiSpacing.sm),
            TextButton(
              onPressed: onRefineFilters,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.warning,
                padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.sm,
                  vertical: AlhaiSpacing.xs,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel ?? l10n.silentLimitBadgeAction,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
