/// Cashier Shell - main layout with sidebar/drawer navigation
///
/// Desktop: Sidebar + main content area
/// Mobile: Drawer navigation
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiBreakpoints;

/// Navigation item model for the cashier shell
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

/// Cashier shell with persistent sidebar/drawer navigation
class CashierShell extends StatefulWidget {
  final Widget child;

  const CashierShell({super.key, required this.child});

  @override
  State<CashierShell> createState() => _CashierShellState();
}

class _CashierShellState extends State<CashierShell> {
  DateTime? _lastBackPress;

  static const _navItems = [
    _NavItem(
      id: 'pos',
      label: 'POS',
      icon: Icons.point_of_sale,
      route: AppRoutes.pos,
    ),
    _NavItem(
      id: 'sales',
      label: 'Sales',
      icon: Icons.receipt_long_outlined,
      route: AppRoutes.sales,
    ),
    _NavItem(
      id: 'dashboard',
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      route: AppRoutes.dashboard,
    ),
    _NavItem(
      id: 'customers',
      label: 'Customers',
      icon: Icons.people_outline,
      route: AppRoutes.customers,
    ),
    _NavItem(
      id: 'shifts',
      label: 'Shifts',
      icon: Icons.schedule,
      route: AppRoutes.shifts,
    ),
    _NavItem(
      id: 'cash-drawer',
      label: 'Cash Drawer',
      icon: Icons.point_of_sale_outlined,
      route: AppRoutes.cashDrawer,
    ),
    _NavItem(
      id: 'products',
      label: 'Products',
      icon: Icons.inventory_2_outlined,
      route: AppRoutes.products,
    ),
    _NavItem(
      id: 'inventory',
      label: 'Inventory',
      icon: Icons.warehouse_outlined,
      route: AppRoutes.inventory,
    ),
    _NavItem(
      id: 'purchases',
      label: 'Purchases',
      icon: Icons.shopping_cart_checkout,
      route: AppRoutes.cashierReceiving,
    ),
    _NavItem(
      id: 'returns',
      label: 'Returns',
      icon: Icons.assignment_return_outlined,
      route: AppRoutes.returns,
    ),
    _NavItem(
      id: 'invoices',
      label: 'Invoices',
      icon: Icons.receipt_outlined,
      route: AppRoutes.invoices,
    ),
    _NavItem(
      id: 'reports',
      label: 'Reports',
      icon: Icons.bar_chart_outlined,
      route: AppRoutes.reports,
    ),
    _NavItem(
      id: 'sync',
      label: 'Sync',
      icon: Icons.sync_outlined,
      route: AppRoutes.syncStatus,
    ),
    _NavItem(
      id: 'notifications',
      label: 'Notifications',
      icon: Icons.notifications_outlined,
      route: AppRoutes.notificationsCenter,
    ),
    _NavItem(
      id: 'profile',
      label: 'Profile',
      icon: Icons.person_outline,
      route: AppRoutes.profile,
    ),
  ];

  /// الحصول على النص المترجم لعنصر القائمة
  String _getLocalizedLabel(BuildContext context, _NavItem item) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return item.label;
    switch (item.id) {
      case 'pos': return l10n.pos;
      case 'sales': return l10n.salesHistory;
      case 'dashboard': return l10n.dashboard;
      case 'customers': return l10n.customers;
      case 'shifts': return l10n.shiftsTitle;
      case 'cash-drawer': return l10n.cashDrawer;
      case 'products': return l10n.products;
      case 'inventory': return l10n.inventory;
      case 'purchases': return l10n.purchases;
      case 'returns': return l10n.returns;
      case 'invoices': return l10n.invoices;
      case 'reports': return l10n.reports;
      case 'sync': return l10n.syncStatusTitle;
      case 'notifications': return l10n.notifications;
      case 'profile': return l10n.profileTitle;
      default: return item.label;
    }
  }

  /// Determine selected nav item from current route
  String _getSelectedId(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/cash-drawer')) return 'cash-drawer';
    if (location.startsWith('/notifications')) return 'notifications';
    if (location.startsWith('/sales')) return 'sales';
    if (location.startsWith('/dashboard')) return 'dashboard';
    if (location.startsWith('/pos')) return 'pos';
    if (location.startsWith('/customers')) return 'customers';
    if (location.startsWith('/shifts')) return 'shifts';
    if (location.startsWith('/products')) return 'products';
    if (location.startsWith('/inventory')) return 'inventory';
    if (location.startsWith('/cashier-receiving') || location.startsWith('/purchase-request')) return 'purchases';
    if (location.startsWith('/returns')) return 'returns';
    if (location.startsWith('/invoices')) return 'invoices';
    if (location.startsWith('/reports')) return 'reports';
    if (location.startsWith('/sync')) return 'sync';
    if (location.startsWith('/profile')) return 'profile';
    if (location.startsWith('/settings')) return 'profile';

    return 'pos'; // default
  }

  void _onNavItemTapped(String route) {
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    // M115: Use shared breakpoint from design system (905px)
    final isDesktop = MediaQuery.sizeOf(context).width >= AlhaiBreakpoints.desktop;
    final selectedId = _getSelectedId(context);

    final layout = isDesktop
        ? _buildDesktopLayout(selectedId)
        : _buildMobileLayout(selectedId);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastBackPress != null &&
            now.difference(_lastBackPress!) < const Duration(seconds: 2)) {
          SystemNavigator.pop();
        } else {
          _lastBackPress = now;
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.pressBackAgainToExit),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: layout,
    );
  }

  /// Desktop layout: Sidebar + main content
  Widget _buildDesktopLayout(String selectedId) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.point_of_sale,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Al-HAI Cashier',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Nav items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: _navItems.map((item) {
                      final isSelected = item.id == selectedId;
                      return _buildSidebarItem(item, isSelected);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  /// Sidebar navigation item
  Widget _buildSidebarItem(_NavItem item, bool isSelected) {
    final label = _getLocalizedLabel(context, item);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _onNavItemTapped(item.route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 22,
                  color: isSelected
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Mobile layout: Drawer + main content
  Widget _buildMobileLayout(String selectedId) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.point_of_sale, color: AppColors.primary, size: 24),
            SizedBox(width: 8),
            Text('Al-HAI Cashier'),
          ],
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // Drawer header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.point_of_sale,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Al-HAI Cashier',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Nav items
              Expanded(
                child: ListView(
                  children: _navItems.map((item) {
                    final isSelected = item.id == selectedId;
                    final label = _getLocalizedLabel(context, item);
                    return ListTile(
                      leading: Icon(
                        item.icon,
                        color: isSelected ? AppColors.primary : null,
                      ),
                      title: Text(
                        label,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? AppColors.primary : null,
                        ),
                      ),
                      selected: isSelected,
                      selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
                      onTap: () {
                        Navigator.of(context).pop(); // close drawer
                        _onNavItemTapped(item.route);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: widget.child,
    );
  }
}
