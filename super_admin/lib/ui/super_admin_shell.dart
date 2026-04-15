import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../core/router/app_router.dart';
import '../core/services/audit_log_service.dart';

/// Shell scaffold with persistent sidebar navigation for Super Admin.
/// Web-first responsive layout: expanded sidebar on desktop, rail on tablet,
/// bottom nav on mobile (unlikely for admin panel but handled).
class SuperAdminShell extends ConsumerStatefulWidget {
  final Widget child;
  const SuperAdminShell({super.key, required this.child});

  @override
  ConsumerState<SuperAdminShell> createState() => _SuperAdminShellState();
}

class _SuperAdminShellState extends ConsumerState<SuperAdminShell> {
  bool _sidebarCollapsed = false;

  int _currentIndex(String location) {
    if (location.startsWith('/stores')) return 1;
    if (location.startsWith('/subscriptions')) return 2;
    if (location.startsWith('/users')) return 3;
    if (location.startsWith('/analytics')) return 4;
    if (location.startsWith('/settings')) return 5;
    return 0; // dashboard
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go(SuperAdminRoutes.dashboard);
      case 1:
        context.go(SuperAdminRoutes.stores);
      case 2:
        context.go(SuperAdminRoutes.subscriptions);
      case 3:
        context.go(SuperAdminRoutes.users);
      case 4:
        context.go(SuperAdminRoutes.revenueAnalytics);
      case 5:
        context.go(SuperAdminRoutes.platformSettings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _currentIndex(location);
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AlhaiBreakpoints.desktop;
    final isTablet = width >= AlhaiBreakpoints.tablet && !isDesktop;

    final navItems = _buildNavItems(l10n);

    // Mobile: bottom nav (unlikely for admin but safe)
    if (!isDesktop && !isTablet) {
      return Scaffold(
        body: widget.child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: navItems
              .map(
                (item) => NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      );
    }

    // Tablet: NavigationRail
    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.only(bottom: AlhaiSpacing.md),
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),
              destinations: navItems
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: Text(item.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    // Desktop: full sidebar
    return Scaffold(
      body: Row(
        children: [
          _DesktopSidebar(
            items: navItems,
            selectedIndex: selectedIndex,
            onItemTapped: _onItemTapped,
            collapsed: _sidebarCollapsed,
            onToggleCollapse: () =>
                setState(() => _sidebarCollapsed = !_sidebarCollapsed),
            onLogout: _logout,
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final authState = ref.read(authStateProvider);
    // Audit log the logout event before signing out.
    try {
      ref.read(auditLogServiceProvider).log(
        action: 'auth.logout',
        targetType: 'user',
        targetId: authState.user?.id ?? 'unknown',
        metadata: {
          'email': authState.user?.email ?? '',
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (_) {}
    await ref.read(authStateProvider.notifier).logout();
  }

  List<_NavItem> _buildNavItems(AppLocalizations l10n) {
    return [
      _NavItem(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
        label: l10n.dashboard,
      ),
      _NavItem(
        icon: Icons.store_outlined,
        selectedIcon: Icons.store_rounded,
        label: l10n.storeManagement,
      ),
      _NavItem(
        icon: Icons.card_membership_outlined,
        selectedIcon: Icons.card_membership_rounded,
        label: l10n.subscriptionManagement,
      ),
      _NavItem(
        icon: Icons.people_outline,
        selectedIcon: Icons.people_rounded,
        label: l10n.usersManagement,
      ),
      _NavItem(
        icon: Icons.analytics_outlined,
        selectedIcon: Icons.analytics_rounded,
        label: l10n.analytics,
      ),
      _NavItem(
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings_rounded,
        label: l10n.settings,
      ),
    ];
  }
}

/// Desktop sidebar with expanded labels, section headers, and collapse toggle.
class _DesktopSidebar extends StatelessWidget {
  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final bool collapsed;
  final VoidCallback onToggleCollapse;
  final VoidCallback? onLogout;

  const _DesktopSidebar({
    required this.items,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.collapsed,
    required this.onToggleCollapse,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sidebarWidth = collapsed ? 72.0 : 260.0;

    return AnimatedContainer(
      duration: AlhaiDurations.medium,
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: BorderDirectional(
          end: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: AlhaiSpacing.strokeXs,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          _SidebarHeader(collapsed: collapsed),
          const Divider(height: 1),

          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: AlhaiSpacing.xs,
                horizontal: AlhaiSpacing.xs,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = index == selectedIndex;
                return _SidebarTile(
                  icon: isSelected ? item.selectedIcon : item.icon,
                  label: item.label,
                  isSelected: isSelected,
                  collapsed: collapsed,
                  onTap: () => onItemTapped(index),
                );
              },
            ),
          ),

          // Logout button
          const Divider(height: 1),
          _LogoutButton(collapsed: collapsed, onTap: onLogout),

          // Collapse toggle
          const Divider(height: 1),
          _CollapseButton(collapsed: collapsed, onTap: onToggleCollapse),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final bool collapsed;
  const _SidebarHeader({required this.collapsed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.lg,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(AlhaiRadius.sm),
            ),
            child: Icon(
              Icons.admin_panel_settings_rounded,
              color: theme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
          if (!collapsed) ...[
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alhai',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Super Admin',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
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

class _SidebarTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool collapsed;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    final bgColor = isSelected
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.xxxs),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(AlhaiRadius.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AlhaiRadius.sm),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? AlhaiSpacing.md : AlhaiSpacing.sm,
              vertical: AlhaiSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                if (!collapsed) ...[
                  const SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
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

class _LogoutButton extends StatelessWidget {
  final bool collapsed;
  final VoidCallback? onTap;
  const _LogoutButton({required this.collapsed, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.xs,
        vertical: AlhaiSpacing.xxxs,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AlhaiRadius.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AlhaiRadius.sm),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? AlhaiSpacing.md : AlhaiSpacing.sm,
              vertical: AlhaiSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: theme.colorScheme.error,
                  size: 22,
                ),
                if (!collapsed) ...[
                  const SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: Text(
                      'Logout',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      overflow: TextOverflow.ellipsis,
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

class _CollapseButton extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onTap;
  const _CollapseButton({required this.collapsed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AlhaiSpacing.xs),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          collapsed
              ? Icons.keyboard_double_arrow_right_rounded
              : Icons.keyboard_double_arrow_left_rounded,
        ),
        tooltip: collapsed ? 'Expand' : 'Collapse',
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
