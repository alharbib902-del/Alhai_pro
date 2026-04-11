/// Payment Sub-Widgets
///
/// Reusable sub-widgets used by the PaymentScreen:
/// - [PaymentMethodCard] - selectable card with hover effects
/// - [QuickAmountChip] - cash amount quick-select chip
/// - [PaymentSummaryRow] - summary label+value row
library;

import 'package:flutter/material.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiColors, AlhaiSpacing;
import 'package:alhai_l10n/alhai_l10n.dart';

// ============================================================================
// PaymentMethodCard
// ============================================================================

/// A selectable payment method card with hover and selection effects.
class PaymentMethodCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String shortcut;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;
  final bool disabled;
  final String? disabledLabel;

  const PaymentMethodCard({
    super.key,
    required this.icon,
    required this.label,
    required this.shortcut,
    required this.color,
    required this.selected,
    required this.onTap,
    this.disabled = false,
    this.disabledLabel,
  });

  @override
  State<PaymentMethodCard> createState() => _PaymentMethodCardState();
}

class _PaymentMethodCardState extends State<PaymentMethodCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.disabled;
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = isDisabled
        ? colorScheme.onSurfaceVariant
        : widget.color;

    return Semantics(
      label: isDisabled
          ? '${widget.label}, ${widget.disabledLabel ?? ''}'
          : '${widget.label}, ${widget.shortcut}',
      button: true,
      selected: widget.selected,
      enabled: !isDisabled,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: MouseRegion(
          onEnter: isDisabled ? null : (_) => setState(() => _isHovered = true),
          onExit: isDisabled ? null : (_) => setState(() => _isHovered = false),
          cursor: isDisabled
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            decoration: BoxDecoration(
              color: isDisabled
                  ? colorScheme.surfaceContainerLow
                  : widget.selected
                  ? widget.color.withValues(alpha: 0.1)
                  : _isHovered
                  ? colorScheme.surfaceContainerLow
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isDisabled
                    ? colorScheme.outlineVariant
                    : widget.selected
                    ? widget.color
                    : AppColors.border,
                width: widget.selected ? 2 : 1,
              ),
              boxShadow: isDisabled
                  ? null
                  : widget.selected || _isHovered
                  ? AppShadows.md
                  : AppShadows.sm,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isDisabled ? null : widget.onTap,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      // Icon
                      AnimatedContainer(
                        duration: AppDurations.fast,
                        width: widget.selected ? 72 : 64,
                        height: widget.selected ? 72 : 64,
                        decoration: BoxDecoration(
                          color: effectiveColor.withValues(
                            alpha: widget.selected ? 0.2 : 0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.icon,
                          size: widget.selected ? 36 : 32,
                          color: effectiveColor,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Label
                      Text(
                        widget.label,
                        style: AppTypography.titleMedium.copyWith(
                          color: isDisabled
                              ? AppColors.textMuted
                              : widget.selected
                              ? widget.color
                              : AppColors.textPrimary,
                          fontWeight: widget.selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      // Shortcut or disabled label
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: isDisabled
                              ? AlhaiColors.warning.withValues(alpha: 0.08)
                              : colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          isDisabled
                              ? (widget.disabledLabel ?? '')
                              : widget.shortcut,
                          style: AppTypography.labelSmall.copyWith(
                            color: isDisabled
                                ? AlhaiColors.warningDark
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// QuickAmountChip
// ============================================================================

/// A quick-select chip for cash amounts with hover effects.
class QuickAmountChip extends StatefulWidget {
  final double amount;
  final String? label;
  final Color? color;
  final VoidCallback onTap;

  const QuickAmountChip({
    super.key,
    required this.amount,
    this.label,
    this.color,
    required this.onTap,
  });

  @override
  State<QuickAmountChip> createState() => _QuickAmountChipState();
}

class _QuickAmountChipState extends State<QuickAmountChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = widget.color ?? colorScheme.outline;

    final displayText = widget.label ?? '${widget.amount.toInt()}';

    return Tooltip(
      message: displayText,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          child: Material(
            color: _isHovered
                ? color.withValues(alpha: 0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: _isHovered ? color : AppColors.border,
                  ),
                ),
                child: Text(
                  displayText,
                  style: AppTypography.labelLarge.copyWith(
                    color: _isHovered ? color : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PaymentSummaryRow
// ============================================================================

/// A summary row showing a label and formatted SAR value.
class PaymentSummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final Color? valueColor;
  final IconData? icon;

  const PaymentSummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: valueColor ?? AppColors.textSecondary,
              ),
              const SizedBox(width: AlhaiSpacing.xxs),
            ],
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          '${value < 0 ? '-' : ''}${value.abs().toStringAsFixed(2)} ${AppLocalizations.of(context).sar}',
          style: AppTypography.bodyMedium.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
