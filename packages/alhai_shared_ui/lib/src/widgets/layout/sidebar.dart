/// الشريط الجانبي للويب - Sidebar
///
/// شريط تنقل جانبي احترافي للتطبيقات الويب والتابلت
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../common/smart_offline_banner.dart';

/// عنصر القائمة الجانبية
class SidebarItem {
  final String id;
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final String? badge;
  final Color? badgeColor;
  final List<SidebarItem>? children;

  const SidebarItem({
    required this.id,
    required this.label,
    required this.icon,
    this.activeIcon,
    this.badge,
    this.badgeColor,
    this.children,
  });
}

/// الشريط الجانبي
class Sidebar extends StatefulWidget {
  /// عناصر القائمة
  final List<SidebarItem> items;

  /// العنصر المحدد
  final String selectedId;

  /// عند اختيار عنصر
  final ValueChanged<String> onItemSelected;

  /// هل مطوي؟
  final bool isCollapsed;

  /// عند تغيير حالة الطي
  final VoidCallback? onToggleCollapse;

  /// الهيدر (شعار + اسم المتجر)
  final Widget? header;

  /// الفوتر (معلومات المستخدم)
  final Widget? footer;

  const Sidebar({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onItemSelected,
    this.isCollapsed = false,
    this.onToggleCollapse,
    this.header,
    this.footer,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _widthAnimation = Tween<double>(
      begin: AppSidebarSize.width,
      end: AppSidebarSize.collapsedWidth,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.defaultCurve,
    ));

    if (widget.isCollapsed) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(Sidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      if (widget.isCollapsed) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) {
        return Container(
          width: _widthAnimation.value,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: const BorderDirectional(
              start: BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Divider
              const Divider(height: 1),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                    horizontal: widget.isCollapsed ? AppSpacing.xs : AppSpacing.sm,
                  ),
                  children: widget.items.map((item) {
                    return _SidebarItemWidget(
                      item: item,
                      isSelected: _isItemSelected(item),
                      isCollapsed: widget.isCollapsed,
                      onTap: () => widget.onItemSelected(item.id),
                    );
                  }).toList(),
                ),
              ),

              // Divider
              const Divider(height: 1),

              // Footer
              _buildFooter(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    if (widget.header != null) {
      return widget.header!;
    }

    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: AppTopBarSize.height,
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCollapsed ? AppSpacing.sm : AppSpacing.lg,
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.storefront,
              color: AppColors.white,
              size: 24,
            ),
          ),

          // Store Name (hidden when collapsed)
          if (!widget.isCollapsed) ...[
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.myGrocery,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    l10n.posSystemLabel,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Collapse Button
          if (widget.onToggleCollapse != null && !widget.isCollapsed)
            IconButton(
              onPressed: widget.onToggleCollapse,
              icon: const Icon(Icons.menu_open),
              iconSize: 20,
              color: AppColors.textMuted,
              tooltip: l10n.collapseMenu,
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    if (widget.footer != null) {
      return widget.footer!;
    }

    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(
        widget.isCollapsed ? AppSpacing.sm : AppSpacing.md,
      ),
      child: widget.isCollapsed
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Connection Status (dot only when collapsed)
                const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ConnectionStatusIndicator(size: 10),
                ),
                IconButton(
                  onPressed: widget.onToggleCollapse,
                  icon: const Icon(Icons.menu),
                  color: AppColors.textMuted,
                  tooltip: l10n.expandMenu,
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Connection Status (with label when expanded)
                const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ConnectionStatusIndicator(
                    size: 10,
                    showLabel: true,
                  ),
                ),
                Row(
                  children: [
                    // User Avatar
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primarySurface,
                      child: Icon(
                        Icons.person,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'أحمد محمد',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            l10n.cashier,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Settings
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings_outlined),
                      iconSize: 20,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  bool _isItemSelected(SidebarItem item) {
    if (item.id == widget.selectedId) return true;
    if (item.children != null) {
      return item.children!.any((child) => child.id == widget.selectedId);
    }
    return false;
  }
}

/// Widget عنصر القائمة
class _SidebarItemWidget extends StatefulWidget {
  final SidebarItem item;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _SidebarItemWidget({
    required this.item,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  State<_SidebarItemWidget> createState() => _SidebarItemWidgetState();
}

class _SidebarItemWidgetState extends State<_SidebarItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isSelected;
    final hasChildren = widget.item.children != null && widget.item.children!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Tooltip(
          message: widget.isCollapsed ? widget.item.label : '',
          preferBelow: false,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primarySurface
                  : _isHovered
                      ? AppColors.grey100
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: isActive
                  ? Border.all(color: AppColors.primaryBorder, width: 1)
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  height: AppSidebarSize.itemHeight,
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.isCollapsed
                        ? AppSpacing.sm
                        : AppSidebarSize.itemPadding,
                  ),
                  child: Row(
                    mainAxisAlignment: widget.isCollapsed
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    children: [
                      // Icon
                      Icon(
                        isActive
                            ? (widget.item.activeIcon ?? widget.item.icon)
                            : widget.item.icon,
                        size: AppIconSize.md,
                        color: isActive
                            ? AppColors.primary
                            : _isHovered
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                      ),

                      // Label & Badge (hidden when collapsed)
                      if (!widget.isCollapsed) ...[
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            widget.item.label,
                            style: AppTypography.labelLarge.copyWith(
                              color: isActive
                                  ? AppColors.primary
                                  : _isHovered
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),

                        // Badge
                        if (widget.item.badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: widget.item.badgeColor ?? AppColors.error,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              widget.item.badge!,
                              style: AppTypography.badge.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ),

                        // Expand Icon (for items with children)
                        if (hasChildren)
                          const Icon(
                            Icons.chevron_left,
                            size: AppIconSize.sm,
                            color: AppColors.textMuted,
                          ),
                      ],
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
