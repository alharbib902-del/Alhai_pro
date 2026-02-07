/// App Sidebar Widget - القائمة الجانبية
///
/// القائمة الجانبية الرئيسية للتطبيق مع التصميم الجديد
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// عنصر في القائمة الجانبية
class AppSidebarItem {
  final String id;
  final String title;
  final IconData icon;
  final IconData? activeIcon;
  final String? badge;
  final Color? badgeColor;
  final bool isNew;

  const AppSidebarItem({
    required this.id,
    required this.title,
    required this.icon,
    this.activeIcon,
    this.badge,
    this.badgeColor,
    this.isNew = false,
  });
}

/// مجموعة عناصر
class SidebarGroup {
  final String? title;
  final List<AppSidebarItem> items;

  const SidebarGroup({
    this.title,
    required this.items,
  });
}

/// القائمة الجانبية
class AppSidebar extends StatelessWidget {
  final String? storeName;
  final String? storeLogoUrl;
  final List<SidebarGroup> groups;
  final String? selectedId;
  final ValueChanged<AppSidebarItem>? onItemTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onSupportTap;
  final VoidCallback? onLogoutTap;
  final bool collapsed;
  final String? userName;
  final String? userRole;
  final String? userAvatarUrl;
  final VoidCallback? onUserTap;

  const AppSidebar({
    super.key,
    this.storeName,
    this.storeLogoUrl,
    required this.groups,
    this.selectedId,
    this.onItemTap,
    this.onSettingsTap,
    this.onSupportTap,
    this.onLogoutTap,
    this.collapsed = false,
    this.userName,
    this.userRole,
    this.userAvatarUrl,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: collapsed ? 80 : 280,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          left: BorderSide(
            color: isDarkMode 
                ? Colors.white.withAlpha(26) 
                : AppColors.border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDarkMode ? 51 : 8),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // الهيدر (اسم المتجر وشعاره)
          _SidebarHeader(
            storeName: storeName,
            storeLogoUrl: storeLogoUrl,
            collapsed: collapsed,
          ),

          // القائمة
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                for (final group in groups) ...[
                  if (group.title != null && !collapsed) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(
                        group.title!,
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                  ...group.items.map((item) => _SidebarItemWidget(
                        item: item,
                        isSelected: item.id == selectedId,
                        collapsed: collapsed,
                        onTap: () => onItemTap?.call(item),
                      )),
                ],
              ],
            ),
          ),

          // الفاصل
          Divider(color: AppColors.border, height: 1),

          // بطاقة المستخدم
          if (userName != null)
            _UserProfileCard(
              name: userName!,
              role: userRole,
              avatarUrl: userAvatarUrl,
              collapsed: collapsed,
              onTap: onUserTap,
            ),

          // الفاصل
          if (userName != null)
            Divider(color: AppColors.border, height: 1),

          // الأزرار السفلية
          _SidebarFooter(
            collapsed: collapsed,
            onSettingsTap: onSettingsTap,
            onSupportTap: onSupportTap,
            onLogoutTap: onLogoutTap,
          ),
        ],
      ),
    );
  }
}

/// هيدر القائمة الجانبية
class _SidebarHeader extends StatelessWidget {
  final String? storeName;
  final String? storeLogoUrl;
  final bool collapsed;

  const _SidebarHeader({
    this.storeName,
    this.storeLogoUrl,
    required this.collapsed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      height: 96,
      padding: EdgeInsets.all(collapsed ? 16 : 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode 
                ? Colors.white.withOpacity(0.1) 
                : AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          // الشعار مع تدرج لوني
          Container(
            width: collapsed ? 48 : 40,
            height: collapsed ? 48 : 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, Color(0xFF047857)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: storeLogoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      storeLogoUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.point_of_sale_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
          ),

          if (!collapsed) ...[
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    storeName ?? 'متجر الحل',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'نظام نقاط البيع',
                    style: TextStyle(
                      color: isDarkMode 
                          ? Colors.white.withOpacity(0.5)
                          : AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}


/// عنصر في القائمة
class _SidebarItemWidget extends StatefulWidget {
  final AppSidebarItem item;
  final bool isSelected;
  final bool collapsed;
  final VoidCallback? onTap;

  const _SidebarItemWidget({
    required this.item,
    required this.isSelected,
    required this.collapsed,
    this.onTap,
  });

  @override
  State<_SidebarItemWidget> createState() => _SidebarItemWidgetState();
}

class _SidebarItemWidgetState extends State<_SidebarItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.collapsed ? 16 : 12,
          vertical: 2,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                horizontal: widget.collapsed ? 12 : 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : _isHovered
                        ? (isDarkMode 
                            ? Colors.white.withOpacity(0.05) 
                            : AppColors.backgroundSecondary)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: widget.isSelected
                    ? Border(
                        right: BorderSide(
                          color: AppColors.primary,
                          width: 3,
                        ),
                      )
                    : null,
              ),
              child: Row(
                mainAxisAlignment: widget.collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  // الأيقونة
                  Icon(
                    widget.isSelected
                        ? (widget.item.activeIcon ?? widget.item.icon)
                        : widget.item.icon,
                    color: widget.isSelected
                        ? AppColors.primary
                        : (isDarkMode 
                            ? Colors.white.withOpacity(0.6) 
                            : AppColors.textSecondary),
                    size: 20,
                  ),

                  if (!widget.collapsed) ...[
                    const SizedBox(width: 16),

                    // العنوان
                    Expanded(
                      child: Text(
                        widget.item.title,
                        style: TextStyle(
                          color: widget.isSelected
                              ? AppColors.primary
                              : (isDarkMode 
                                  ? Colors.white.withOpacity(0.7) 
                                  : AppColors.textPrimary),
                          fontSize: 14,
                          fontWeight: widget.isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),

                    // الشارة (Badge)
                    if (widget.item.badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.item.badge!,
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    // علامة جديد
                    if (widget.item.isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'جديد',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// بطاقة المستخدم في القائمة الجانبية
class _UserProfileCard extends StatefulWidget {
  final String name;
  final String? role;
  final String? avatarUrl;
  final bool collapsed;
  final VoidCallback? onTap;

  const _UserProfileCard({
    required this.name,
    this.role,
    this.avatarUrl,
    required this.collapsed,
    this.onTap,
  });

  @override
  State<_UserProfileCard> createState() => _UserProfileCardState();
}

class _UserProfileCardState extends State<_UserProfileCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.all(widget.collapsed ? 12 : 16),
            decoration: BoxDecoration(
              color: _isHovered
                  ? (isDark ? Colors.white.withOpacity(0.05) : AppColors.backgroundSecondary)
                  : Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: widget.collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                // الصورة الشخصية مع نقطة الحالة
                Stack(
                  children: [
                    CircleAvatar(
                      radius: widget.collapsed ? 20 : 18,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      backgroundImage: widget.avatarUrl != null
                          ? NetworkImage(widget.avatarUrl!)
                          : null,
                      child: widget.avatarUrl == null
                          ? Text(
                              widget.name.isNotEmpty
                                  ? widget.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: widget.collapsed ? 16 : 14,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    // نقطة الحالة (متصل)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (!widget.collapsed) ...[
                  const SizedBox(width: 12),

                  // الاسم والدور
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.name,
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.role != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.role!,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withOpacity(0.5)
                                  : AppColors.textTertiary,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // سهم
                  Icon(
                    Icons.chevron_left_rounded,
                    color: isDark
                        ? Colors.white.withOpacity(0.3)
                        : AppColors.textTertiary,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// فوتر القائمة الجانبية
class _SidebarFooter extends StatelessWidget {
  final bool collapsed;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onSupportTap;
  final VoidCallback? onLogoutTap;

  const _SidebarFooter({
    required this.collapsed,
    this.onSettingsTap,
    this.onSupportTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(collapsed ? 12 : 16),
      child: Column(
        children: [
          // الإعدادات
          _FooterButton(
            icon: Icons.settings_outlined,
            title: 'الإعدادات',
            collapsed: collapsed,
            onTap: onSettingsTap,
          ),

          const SizedBox(height: 4),

          // الدعم
          _FooterButton(
            icon: Icons.help_outline_rounded,
            title: 'الدعم الفني',
            collapsed: collapsed,
            onTap: onSupportTap,
          ),

          const SizedBox(height: 4),

          // تسجيل الخروج
          _FooterButton(
            icon: Icons.logout_rounded,
            title: 'تسجيل الخروج',
            collapsed: collapsed,
            onTap: onLogoutTap,
            isDestructive: true,
          ),
        ],
      ),
    );
  }
}

/// زر في فوتر القائمة
class _FooterButton extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool collapsed;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _FooterButton({
    required this.icon,
    required this.title,
    required this.collapsed,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_FooterButton> createState() => _FooterButtonState();
}

class _FooterButtonState extends State<_FooterButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDestructive
        ? AppColors.error
        : AppColors.textSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? 12 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: _isHovered
                  ? (widget.isDestructive
                      ? AppColors.error.withOpacity(0.05)
                      : AppColors.backgroundSecondary)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: widget.collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  widget.icon,
                  color: color,
                  size: 20,
                ),
                if (!widget.collapsed) ...[
                  const SizedBox(width: 12),
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// القائمة الجانبية الافتراضية
class DefaultSidebarItems {
  static const dashboard = AppSidebarItem(
    id: 'dashboard',
    title: 'لوحة التحكم',
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard_rounded,
  );

  static const pos = AppSidebarItem(
    id: 'pos',
    title: 'نقطة البيع',
    icon: Icons.point_of_sale_outlined,
    activeIcon: Icons.point_of_sale_rounded,
  );

  static const products = AppSidebarItem(
    id: 'products',
    title: 'المنتجات',
    icon: Icons.inventory_2_outlined,
    activeIcon: Icons.inventory_2_rounded,
  );

  static const inventory = AppSidebarItem(
    id: 'inventory',
    title: 'المخزون',
    icon: Icons.warehouse_outlined,
    activeIcon: Icons.warehouse_rounded,
    badge: '5',
    badgeColor: Color(0xFFF59E0B),
  );

  static const customers = AppSidebarItem(
    id: 'customers',
    title: 'العملاء',
    icon: Icons.people_outline_rounded,
    activeIcon: Icons.people_rounded,
  );

  static const sales = AppSidebarItem(
    id: 'sales',
    title: 'المبيعات',
    icon: Icons.receipt_long_outlined,
    activeIcon: Icons.receipt_long_rounded,
  );

  static const reports = AppSidebarItem(
    id: 'reports',
    title: 'التقارير',
    icon: Icons.analytics_outlined,
    activeIcon: Icons.analytics_rounded,
  );

  static const employees = AppSidebarItem(
    id: 'employees',
    title: 'الموظفين',
    icon: Icons.badge_outlined,
    activeIcon: Icons.badge_rounded,
  );

  static const loyalty = AppSidebarItem(
    id: 'loyalty',
    title: 'برنامج الولاء',
    icon: Icons.card_giftcard_outlined,
    activeIcon: Icons.card_giftcard_rounded,
    isNew: true,
  );

  static const List<SidebarGroup> defaultGroups = [
    SidebarGroup(
      items: [dashboard, pos],
    ),
    SidebarGroup(
      title: 'إدارة المتجر',
      items: [products, inventory, customers],
    ),
    SidebarGroup(
      title: 'المالية',
      items: [sales, reports],
    ),
    SidebarGroup(
      title: 'الفريق',
      items: [employees, loyalty],
    ),
  ];
}
