/// Distributor Portal Shell - main layout with sidebar/drawer navigation
///
/// Desktop: Sidebar + main content area
/// Mobile: Drawer navigation
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Navigation item model
class _NavItem {
  final String id;
  final String label;
  final IconData icon;
  final String route;

  const _NavItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
  });
}

/// Distributor shell with persistent sidebar/drawer navigation
class DistributorShell extends StatefulWidget {
  final Widget child;

  const DistributorShell({super.key, required this.child});

  @override
  State<DistributorShell> createState() => _DistributorShellState();
}

class _DistributorShellState extends State<DistributorShell> {
  static const _navItems = [
    _NavItem(
      id: 'dashboard',
      label: 'لوحة التحكم',
      icon: Icons.dashboard_outlined,
      route: '/dashboard',
    ),
    _NavItem(
      id: 'orders',
      label: 'الطلبات',
      icon: Icons.shopping_bag_outlined,
      route: '/orders',
    ),
    _NavItem(
      id: 'products',
      label: 'المنتجات',
      icon: Icons.inventory_2_outlined,
      route: '/products',
    ),
    _NavItem(
      id: 'pricing',
      label: 'الأسعار',
      icon: Icons.price_change_outlined,
      route: '/pricing',
    ),
    _NavItem(
      id: 'reports',
      label: 'التقارير',
      icon: Icons.bar_chart_outlined,
      route: '/reports',
    ),
    _NavItem(
      id: 'settings',
      label: 'الإعدادات',
      icon: Icons.settings_outlined,
      route: '/settings',
    ),
  ];

  String _getSelectedId(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/orders')) return 'orders';
    if (location.startsWith('/products')) return 'products';
    if (location.startsWith('/pricing')) return 'pricing';
    if (location.startsWith('/reports')) return 'reports';
    if (location.startsWith('/settings')) return 'settings';
    return 'dashboard';
  }

  void _onNavItemTapped(String route) {
    context.go(route);
  }

  Widget _buildSidebarContent(String selectedId, bool isDark) {
    return Column(
      children: [
        // Brand header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.mdl, vertical: AlhaiSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.store,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'بوابة الموزع',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Alhai Platform',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white54
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        const SizedBox(height: AlhaiSpacing.xs),
        // Nav items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm),
            children: _navItems.map((item) {
              final isSelected = item.id == selectedId;
              return Padding(
                padding: const EdgeInsets.only(bottom: AlhaiSpacing.xxs),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _onNavItemTapped(item.route),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.md,
                        vertical: AlhaiSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 22,
                            color: isSelected
                                ? AppColors.primary
                                : isDark
                                    ? Colors.white60
                                    : AppColors.textSecondary,
                          ),
                          const SizedBox(width: AlhaiSpacing.sm),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.primary
                                  : isDark
                                      ? Colors.white70
                                      : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Bottom user section
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الموزع',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'distributor@alhai.com',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white54
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // M115: Use shared breakpoint from design system (905px)
    final isDesktop = MediaQuery.sizeOf(context).width >= AlhaiBreakpoints.desktop;
    final selectedId = _getSelectedId(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sidebarBg = isDark
        ? const Color(0xFF1E293B)
        : Colors.white;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0F172A)
            : AppColors.backgroundSecondary,
        body: Row(
          children: [
            // Sidebar
            Container(
              width: 240,
              decoration: BoxDecoration(
                color: sidebarBg,
                border: Border(
                  left: BorderSide(
                    color: isDark
                        ? Colors.white10
                        : Theme.of(context).colorScheme.surfaceContainerLow,
                  ),
                ),
              ),
              child: SafeArea(
                child: _buildSidebarContent(selectedId, isDark),
              ),
            ),
            // Content
            Expanded(child: widget.child),
          ],
        ),
      );
    } else {
      // Mobile: drawer
      return Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0F172A)
            : AppColors.backgroundSecondary,
        appBar: AppBar(
          title: const Text('بوابة الموزع'),
          backgroundColor: sidebarBg,
          foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
          elevation: 0,
        ),
        drawer: Drawer(
          backgroundColor: sidebarBg,
          child: SafeArea(
            child: _buildSidebarContent(selectedId, isDark),
          ),
        ),
        body: widget.child,
      );
    }
  }
}
