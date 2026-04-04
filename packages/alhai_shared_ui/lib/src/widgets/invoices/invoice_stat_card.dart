/// Invoice Stats Card Widget
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

class InvoiceStatData {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Color gradientColor;
  final String? subtitle;
  final String? changeValue;
  final bool isPositive;
  final double? progressValue;
  final String? actionText;
  final VoidCallback? onAction;

  const InvoiceStatData({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.gradientColor,
    this.subtitle,
    this.changeValue,
    this.isPositive = true,
    this.progressValue,
    this.actionText,
    this.onAction,
  });
}

class InvoiceStatCard extends StatefulWidget {
  final InvoiceStatData data;
  final bool compact;

  const InvoiceStatCard({super.key, required this.data, this.compact = false});

  @override
  State<InvoiceStatCard> createState() => _InvoiceStatCardState();
}

class _InvoiceStatCardState extends State<InvoiceStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final d = widget.data;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: context.prefersReducedMotion
            ? Duration.zero
            : AlhaiDurations.standard,
        padding: EdgeInsets.all(widget.compact ? 16 : 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? d.gradientColor.withValues(alpha: 0.5)
                : (Theme.of(context).dividerColor),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                      color: d.gradientColor.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.title,
                            style: TextStyle(
                              fontSize: widget.compact ? 12 : 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: AlhaiSpacing.xxs),
                          Text(
                            d.value,
                            style: TextStyle(
                              fontSize: widget.compact ? 20 : 28,
                              fontWeight: FontWeight.bold,
                              color: d.actionText != null &&
                                      d.gradientColor == AppColors.error
                                  ? AppColors.error
                                  : (Theme.of(context).colorScheme.onSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedScale(
                      scale: _isHovered ? 1.1 : 1.0,
                      duration: context.prefersReducedMotion
                          ? Duration.zero
                          : AlhaiDurations.standard,
                      child: Container(
                        width: widget.compact ? 40 : 48,
                        height: widget.compact ? 40 : 48,
                        decoration: BoxDecoration(
                          color: isDark
                              ? d.iconColor.withValues(alpha: 0.15)
                              : d.iconBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(d.icon,
                            color: d.iconColor, size: widget.compact ? 20 : 24),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AlhaiSpacing.sm),
                if (d.changeValue != null)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AlhaiSpacing.xs, vertical: 3),
                        decoration: BoxDecoration(
                          color: (d.isPositive
                                  ? AppColors.success
                                  : AppColors.error)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              d.isPositive
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              size: 14,
                              color: d.isPositive
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            SizedBox(width: AlhaiSpacing.xxs),
                            Text(
                              d.changeValue!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: d.isPositive
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AlhaiSpacing.xs),
                      if (d.subtitle != null)
                        Flexible(
                          child: Text(
                            d.subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                if (d.progressValue != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: d.progressValue!,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.backgroundSecondary,
                      valueColor: AlwaysStoppedAnimation(d.gradientColor),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (d.subtitle != null)
                    Text(d.subtitle!,
                        style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMuted)),
                ],
                if (d.actionText != null)
                  TextButton(
                    onPressed: d.onAction,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      d.actionText!,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: d.gradientColor),
                    ),
                  ),
                if (d.subtitle != null &&
                    d.changeValue == null &&
                    d.progressValue == null &&
                    d.actionText == null)
                  Text(d.subtitle!,
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMuted)),
              ],
            ),
            // Bottom gradient line
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    d.gradientColor,
                    d.gradientColor.withValues(alpha: 0)
                  ]),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
