/// Stat Card Widget - كارت الإحصائيات
///
/// كروت عرض الإحصائيات في لوحة التحكم
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../utils/number_formatter.dart';

/// نوع التغيير
enum ChangeType {
  /// زيادة
  increase,

  /// نقصان
  decrease,

  /// بدون تغيير
  neutral,
}

/// كارت إحصائية واحدة
class DashboardStatCard extends StatefulWidget {
  final String title;
  final String value;
  final String? valueSuffix;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? change;
  final ChangeType? changeType;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    this.valueSuffix,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.change,
    this.changeType,
    this.onTap,
  });

  @override
  State<DashboardStatCard> createState() => _DashboardStatCardState();
}

class _DashboardStatCardState extends State<DashboardStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final effectiveIconColor = widget.iconColor ?? AppColors.primary;
    final isMobile = context.isMobile;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(
              isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
          child: AnimatedContainer(
            duration: context.prefersReducedMotion
                ? Duration.zero
                : AlhaiDurations.slow,
            padding:
                EdgeInsets.all(isMobile ? AlhaiSpacing.sm : AlhaiSpacing.mdl),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(
                  isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withAlpha(13)
                    : AppColors.border.withAlpha(128),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
                  blurRadius: _isHovered ? 20 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // الدائرة المتدرجة في الخلفية
                PositionedDirectional(
                  top: -40,
                  start: -40,
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: effectiveIconColor.withAlpha(13),
                    ),
                  ),
                ),

                // المحتوى
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الهيدر (الأيقونة ونسبة التغيير)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width:
                              isMobile ? AlhaiSpacing.xxl : AlhaiSpacing.xxxl,
                          height:
                              isMobile ? AlhaiSpacing.xxl : AlhaiSpacing.xxxl,
                          decoration: BoxDecoration(
                            color: effectiveIconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                isMobile ? AlhaiSpacing.sm : AlhaiSpacing.md),
                          ),
                          child: Icon(
                            widget.icon,
                            color: effectiveIconColor,
                            size: isMobile ? 18 : 22,
                          ),
                        ),
                        if (widget.change != null && widget.changeType != null)
                          Flexible(
                            child: _ChangeIndicator(
                              change: widget.change!,
                              type: widget.changeType!,
                              compact: isMobile,
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: isMobile ? 10 : 14),

                    // العنوان
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white.withAlpha(153)
                            : AppColors.textSecondary,
                        fontSize: isMobile ? 11 : 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: AlhaiSpacing.xxs),

                    // القيمة مع اللاحقة
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            widget.value,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: isMobile ? 20 : 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.valueSuffix != null) ...[
                            SizedBox(width: AlhaiSpacing.xxs),
                            Text(
                              widget.valueSuffix!,
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white.withAlpha(128)
                                    : AppColors.textTertiary,
                                fontSize: isMobile ? 12 : 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// مؤشر التغيير
class _ChangeIndicator extends StatelessWidget {
  final double change;
  final ChangeType type;
  final bool compact;

  const _ChangeIndicator({
    required this.change,
    required this.type,
    required this.compact,
  });

  Color get _color {
    switch (type) {
      case ChangeType.increase:
        return AppColors.success;
      case ChangeType.decrease:
        return AppColors.error;
      case ChangeType.neutral:
        return AppColors.textSecondary;
    }
  }

  IconData get _icon {
    switch (type) {
      case ChangeType.increase:
        return Icons.trending_up_rounded;
      case ChangeType.decrease:
        return Icons.trending_down_rounded;
      case ChangeType.neutral:
        return Icons.remove_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon,
            color: _color,
            size: compact ? 12 : 14,
          ),
          if (!compact) ...[
            SizedBox(width: AlhaiSpacing.xxxs),
            Text(
              '${change >= 0 ? '+' : ''}${AppNumberFormatter.currency(change, locale: Localizations.localeOf(context).toString(), decimals: 1)}%',
              style: TextStyle(
                color: _color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// كروت الإحصائيات الافتراضية - تستخدم l10n
class DefaultStatCards {
  static DashboardStatCard todaySales({
    required AppLocalizations l10n,
    required String value,
    double? change,
    VoidCallback? onTap,
  }) {
    return DashboardStatCard(
      title: l10n.todaySalesLabel,
      value: value,
      valueSuffix: l10n.sar,
      icon: Icons.attach_money_rounded,
      iconColor: AppColors.success,
      change: change,
      changeType: change != null
          ? (change >= 0 ? ChangeType.increase : ChangeType.decrease)
          : null,
      onTap: onTap,
    );
  }

  static DashboardStatCard ordersCount({
    required AppLocalizations l10n,
    required String value,
    double? change,
    VoidCallback? onTap,
  }) {
    return DashboardStatCard(
      title: l10n.ordersCountLabel,
      value: value,
      icon: Icons.receipt_long_rounded,
      iconColor: AppColors.info,
      change: change,
      changeType: change != null
          ? (change >= 0 ? ChangeType.increase : ChangeType.decrease)
          : null,
      onTap: onTap,
    );
  }

  static DashboardStatCard newCustomers({
    required AppLocalizations l10n,
    required String value,
    double? change,
    VoidCallback? onTap,
  }) {
    return DashboardStatCard(
      title: l10n.newCustomersLabel,
      value: value,
      icon: Icons.people_alt_rounded,
      iconColor: const Color(0xFF8B5CF6),
      change: change,
      changeType: change != null
          ? (change >= 0 ? ChangeType.increase : ChangeType.decrease)
          : ChangeType.neutral,
      onTap: onTap,
    );
  }

  static DashboardStatCard lowStock({
    required AppLocalizations l10n,
    required String value,
    int? alertIncrease,
    VoidCallback? onTap,
  }) {
    return DashboardStatCard(
      title: l10n.stockAlertsLabel,
      value: value,
      valueSuffix: l10n.productsUnit,
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.warning,
      change: alertIncrease?.toDouble(),
      changeType: alertIncrease != null ? ChangeType.decrease : null,
      onTap: onTap,
    );
  }
}
