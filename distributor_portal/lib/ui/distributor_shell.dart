/// Distributor Portal Shell - main layout with sidebar/drawer navigation
///
/// Desktop: Sidebar + main content area
/// Mobile: Drawer navigation
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import '../core/supabase/supabase_client.dart';
import '../providers/distributor_providers.dart';

/// Navigation item model
class _NavItem {
  final String id;
  final String Function(AppLocalizations? l10n) label;
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
class DistributorShell extends ConsumerStatefulWidget {
  final Widget child;

  const DistributorShell({super.key, required this.child});

  @override
  ConsumerState<DistributorShell> createState() => _DistributorShellState();
}

class _DistributorShellState extends ConsumerState<DistributorShell> {
  static final _navItems = [
    _NavItem(
      id: 'dashboard',
      label: (l10n) => l10n?.distributorDashboard ?? 'Dashboard',
      icon: Icons.dashboard_outlined,
      route: '/dashboard',
    ),
    _NavItem(
      id: 'orders',
      label: (l10n) => l10n?.orders ?? 'Orders',
      icon: Icons.shopping_bag_outlined,
      route: '/orders',
    ),
    _NavItem(
      id: 'products',
      label: (l10n) => l10n?.products ?? 'Products',
      icon: Icons.inventory_2_outlined,
      route: '/products',
    ),
    _NavItem(
      id: 'pricing',
      label: (l10n) => l10n?.price ?? 'Pricing',
      icon: Icons.price_change_outlined,
      route: '/pricing',
    ),
    _NavItem(
      id: 'reports',
      label: (l10n) => l10n?.reports ?? 'Reports',
      icon: Icons.bar_chart_outlined,
      route: '/reports',
    ),
    _NavItem(
      id: 'settings',
      label: (l10n) => l10n?.settings ?? 'Settings',
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

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.distributorLogout),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              l10n.distributorLogout,
              style: const TextStyle(color: AppColors.textOnPrimary),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    // Clear datasource cache on logout
    ref.read(distributorDatasourceProvider).clearCache();
    await AppSupabase.client.auth.signOut();
    if (!mounted) return;
    context.go('/login');
  }

  Widget _buildSidebarContent(
    String selectedId,
    bool isDark,
    AppLocalizations? l10n,
  ) {
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        // Brand header
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.mdl,
            vertical: AlhaiSpacing.lg,
          ),
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
                  color: AppColors.textOnPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.distributorPortal ?? 'Distributor Portal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      'Alhai Platform',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                child: Semantics(
                  button: true,
                  label: item.label(l10n),
                  selected: isSelected,
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
                            ExcludeSemantics(
                              child: Icon(
                                item.icon,
                                size: 22,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.getTextSecondary(isDark),
                              ),
                            ),
                            const SizedBox(width: AlhaiSpacing.sm),
                            Expanded(
                              child: Text(
                                item.label(l10n),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.getTextPrimary(isDark),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
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
                child: const Icon(
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
                      user?.email?.split('@').first ??
                          l10n?.distributorPortal ??
                          'Distributor',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: l10n?.distributorLogout ?? 'Sign out',
                child: IconButton(
                  onPressed: _logout,
                  icon: Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  tooltip: l10n?.distributorLogout ?? 'Sign out',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build a collapsed icon-only sidebar for tablet viewports.
  Widget _buildCollapsedSidebar(
    String selectedId,
    bool isDark,
    AppLocalizations? l10n,
  ) {
    return Column(
      children: [
        // Brand icon
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.lg),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.store,
              color: AppColors.textOnPrimary,
              size: 22,
            ),
          ),
        ),
        const Divider(height: 1),
        const SizedBox(height: AlhaiSpacing.xs),
        // Nav items (icon only)
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs),
            children: _navItems.map((item) {
              final isSelected = item.id == selectedId;
              return Padding(
                padding: const EdgeInsets.only(bottom: AlhaiSpacing.xxs),
                child: Tooltip(
                  message: item.label(l10n),
                  preferBelow: false,
                  child: Semantics(
                    button: true,
                    label: item.label(l10n),
                    selected: isSelected,
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _onNavItemTapped(item.route),
                        child: Container(
                          padding: const EdgeInsets.all(AlhaiSpacing.sm),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item.icon,
                            size: 22,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.getTextSecondary(isDark),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Bottom logout
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.sm),
          child: Semantics(
            button: true,
            label: l10n?.distributorLogout ?? 'Sign out',
            child: IconButton(
              onPressed: _logout,
              icon: Icon(
                Icons.logout_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              tooltip: l10n?.distributorLogout ?? 'Sign out',
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AlhaiBreakpoints.desktop;
    final isTablet = width >= 600 && width < AlhaiBreakpoints.desktop;
    final selectedId = _getSelectedId(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    // Prefetch dashboard data in parallel when shell loads
    ref.watch(prefetchDashboardDataProvider);

    final sidebarBg = Theme.of(context).colorScheme.surface;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        body: Row(
          children: [
            // Full sidebar
            Container(
              width: 240,
              decoration: BoxDecoration(
                color: sidebarBg,
                border: BorderDirectional(
                  start: BorderSide(
                    color: isDark
                        ? Theme.of(context).colorScheme.outlineVariant
                        : Theme.of(context).colorScheme.surfaceContainerLow,
                  ),
                ),
              ),
              child: SafeArea(
                child: _buildSidebarContent(selectedId, isDark, l10n),
              ),
            ),
            // Content
            Expanded(child: widget.child),
          ],
        ),
      );
    } else if (isTablet) {
      // Tablet: collapsed icon-only sidebar
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        body: Row(
          children: [
            Container(
              width: 72,
              decoration: BoxDecoration(
                color: sidebarBg,
                border: BorderDirectional(
                  start: BorderSide(
                    color: isDark
                        ? Theme.of(context).colorScheme.outlineVariant
                        : Theme.of(context).colorScheme.surfaceContainerLow,
                  ),
                ),
              ),
              child: SafeArea(
                child: _buildCollapsedSidebar(selectedId, isDark, l10n),
              ),
            ),
            Expanded(child: widget.child),
          ],
        ),
      );
    } else {
      // Mobile: drawer
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        appBar: AppBar(
          title: Text(
            l10n.distributorPortal,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          backgroundColor: sidebarBg,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
        ),
        drawer: Drawer(
          backgroundColor: sidebarBg,
          child: SafeArea(
            child: _buildSidebarContent(selectedId, isDark, l10n),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Ensure minimum width to prevent overflow on Galaxy Fold
            if (constraints.maxWidth < 280) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 280),
                  child: widget.child,
                ),
              );
            }
            return widget.child;
          },
        ),
      );
    }
  }
}
