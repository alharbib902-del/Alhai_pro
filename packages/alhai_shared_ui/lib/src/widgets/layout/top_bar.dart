/// الشريط العلوي للويب - Top Bar
///
/// شريط علوي احترافي للتطبيقات الويب والتابلت
library;

import '../common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// الشريط العلوي
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  /// عنوان الصفحة
  final String? title;

  /// عنوان فرعي
  final String? subtitle;

  /// أيقونة القائمة
  final VoidCallback? onMenuTap;

  /// ويدجت على اليمين
  final List<Widget>? actions;

  /// ويدجت البحث
  final Widget? searchWidget;

  /// هل يظهر شريط البحث؟
  final bool showSearch;

  /// ويدجت مخصص بدلاً من العنوان
  final Widget? titleWidget;

  /// ويدجت على اليسار
  final Widget? leading;

  /// إظهار زر الرجوع
  final bool showBackButton;

  /// عند الضغط على زر الرجوع
  final VoidCallback? onBackPressed;

  /// لون الخلفية
  final Color? backgroundColor;

  /// Elevation
  final double elevation;

  const TopBar({
    super.key,
    this.title,
    this.subtitle,
    this.onMenuTap,
    this.actions,
    this.searchWidget,
    this.showSearch = false,
    this.titleWidget,
    this.leading,
    this.showBackButton = false,
    this.onBackPressed,
    this.backgroundColor,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        showSearch ? AppBarSize.heightWithSearch : AppTopBarSize.height,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        border: const Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        boxShadow: elevation > 0 ? AppShadows.sm : null,
      ),
      child: Column(
        children: [
          // Main Bar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTopBarSize.paddingHorizontal,
              ),
              child: Row(
                children: [
                  // Leading / Back Button / Menu
                  if (leading != null)
                    leading!
                  else if (showBackButton)
                    _buildBackButton(context)
                  else if (onMenuTap != null)
                    _buildMenuButton(context),

                  const SizedBox(width: AppSpacing.md),

                  // Title
                  Expanded(
                    child: titleWidget ?? _buildTitle(),
                  ),

                  // Actions
                  if (actions != null) ...[
                    const SizedBox(width: AppSpacing.md),
                    ...actions!.map((action) => Padding(
                          padding: const EdgeInsetsDirectional.only(
                              end: AppSpacing.xs),
                          child: action,
                        )),
                  ],
                ],
              ),
            ),
          ),

          // Search Bar (if enabled)
          if (showSearch && searchWidget != null)
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTopBarSize.paddingHorizontal,
              ),
              child: searchWidget,
            ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IconButton(
      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      icon: const AdaptiveIcon(Icons.arrow_forward),
      iconSize: AppIconSize.md,
      color: AppColors.textPrimary,
      tooltip: l10n.goBack,
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IconButton(
      onPressed: onMenuTap,
      icon: const Icon(Icons.menu),
      iconSize: AppIconSize.md,
      color: AppColors.textPrimary,
      tooltip: l10n.menuLabel,
    );
  }

  Widget _buildTitle() {
    if (title == null && subtitle == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (title != null)
          Text(
            title!,
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        if (subtitle != null) ...[
          SizedBox(height: AlhaiSpacing.xxxs),
          Text(
            subtitle!,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

/// زر إشعارات للـ TopBar
class TopBarNotificationButton extends StatelessWidget {
  final int count;
  final VoidCallback? onPressed;

  const TopBarNotificationButton({
    super.key,
    this.count = 0,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.notifications_outlined),
          iconSize: AppIconSize.md,
          color: AppColors.textSecondary,
          tooltip: l10n.notifications,
        ),
        if (count > 0)
          PositionedDirectional(
            top: 8,
            start: 8,
            child: Container(
              padding: const EdgeInsets.all(AlhaiSpacing.xxs),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: AppTypography.badge.copyWith(
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

/// زر بحث للـ TopBar
class TopBarSearchButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? tooltip;

  const TopBarSearchButton({
    super.key,
    this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.search),
      iconSize: AppIconSize.md,
      color: AppColors.textSecondary,
      tooltip: tooltip ?? AppLocalizations.of(context).search,
    );
  }
}

/// زر مساعدة للـ TopBar
class TopBarHelpButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const TopBarHelpButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.help_outline),
      iconSize: AppIconSize.md,
      color: AppColors.textSecondary,
      tooltip: AppLocalizations.of(context).help,
    );
  }
}

/// Breadcrumb للـ TopBar
class TopBarBreadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const TopBarBreadcrumb({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Icon(
                Icons.chevron_left,
                size: AppIconSize.xs,
                color: AppColors.textMuted,
              ),
            ),
          _BreadcrumbItemWidget(
            item: items[i],
            isLast: i == items.length - 1,
          ),
        ],
      ],
    );
  }
}

/// عنصر Breadcrumb
class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  const BreadcrumbItem({
    required this.label,
    this.onTap,
    this.icon,
  });
}

class _BreadcrumbItemWidget extends StatelessWidget {
  final BreadcrumbItem item;
  final bool isLast;

  const _BreadcrumbItemWidget({
    required this.item,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = isLast ? AppColors.textPrimary : AppColors.textSecondary;
    final fontWeight = isLast ? FontWeight.w600 : FontWeight.w400;

    return InkWell(
      onTap: isLast ? null : item.onTap,
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: AppIconSize.xs,
                color: color,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              item.label,
              style: AppTypography.bodySmall.copyWith(
                color: color,
                fontWeight: fontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// شريط الحالة (Online/Offline)
class TopBarStatusIndicator extends StatelessWidget {
  final bool isOnline;
  final String? customText;

  const TopBarStatusIndicator({
    super.key,
    required this.isOnline,
    this.customText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: isOnline ? AppColors.successSurface : AppColors.warningSurface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: isOnline ? AppColors.success : AppColors.warning,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOnline ? AppColors.success : AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            customText ??
                (isOnline
                    ? AppLocalizations.of(context).online
                    : AppLocalizations.of(context).offline),
            style: AppTypography.labelSmall.copyWith(
              color: isOnline ? AppColors.success : AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
