/// Cashier Shell - main layout with sidebar/drawer navigation
///
/// Desktop: Sidebar + main content area
/// Mobile: Drawer navigation
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiBreakpoints, AlhaiSpacing;
import 'package:alhai_auth/alhai_auth.dart' show authStateProvider, AuthStatus;
import 'package:alhai_pos/alhai_pos.dart' show cartStateProvider, heldInvoicesProvider;
import '../widgets/clock_invalid_banner.dart';

/// Navigation item model for the cashier shell
class _NavItem {
  final String id;
  final String label;
  final IconData icon;
  final String route;
  final List<_NavItem> children;

  const _NavItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
    this.children = const [],
  });

  bool get hasChildren => children.isNotEmpty;
}

/// Cashier shell with persistent sidebar/drawer navigation
class CashierShell extends ConsumerStatefulWidget {
  final Widget child;

  const CashierShell({super.key, required this.child});

  @override
  ConsumerState<CashierShell> createState() => _CashierShellState();
}

class _CashierShellState extends ConsumerState<CashierShell> {
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    // تفعيل التزامن العام (InitialSync + Realtime) عند فتح أي شاشة
    // هذا يضمن تشغيل المزامنة بغض النظر عن الشاشة الأولى (/pos أو /sales أو غيرها)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(globalSyncActivationProvider);
      // تفعيل مدير المزامنة (Push) لدفع المبيعات والبيانات المحلية إلى Supabase
      // SyncManager يعمل كل 15 ثانية لرفع العناصر المعلقة في sync_queue
      ref.read(syncManagerProvider);
      // مزامنة العملاء الموجودين محليًا الذين لم يُرسلوا بعد
      ref.read(syncExistingCustomersProvider);

      // AUTH-GUARD: Clear user-specific state on logout (any logout path).
      // This catches logouts from profile_screen, dashboard_shell, session
      // timeout, etc. — all of which set authState to unauthenticated.
      ref.listenManual(authStateProvider, (previous, next) {
        if (previous?.status == AuthStatus.authenticated &&
            next.status != AuthStatus.authenticated) {
          // Cart must not survive across user sessions
          ref.read(cartStateProvider.notifier).clear();
          ref.invalidate(heldInvoicesProvider);
          ref.read(performanceProvider.notifier).resetSession();
        }
      });
    });
  }

  /// Grouped navigation: 9 top-level items (down from 16).
  /// Cash Drawer / Returns / Invoices live under POS.
  /// Products / Inventory / Purchases live under a Products group.
  /// Sync / Notifications are nested under Settings.
  static const _navItems = [
    _NavItem(
      id: 'pos',
      label: 'POS',
      icon: Icons.point_of_sale,
      route: AppRoutes.pos,
      children: [
        _NavItem(id: 'cash-drawer', label: 'Cash Drawer', icon: Icons.point_of_sale_outlined, route: AppRoutes.cashDrawer),
        _NavItem(id: 'returns', label: 'Returns', icon: Icons.assignment_return_outlined, route: AppRoutes.returns),
        _NavItem(id: 'invoices', label: 'Invoices', icon: Icons.receipt_outlined, route: AppRoutes.invoices),
      ],
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
      id: 'products',
      label: 'Products',
      icon: Icons.inventory_2_outlined,
      route: AppRoutes.products,
      children: [
        _NavItem(id: 'inventory', label: 'Inventory', icon: Icons.warehouse_outlined, route: AppRoutes.inventory),
        _NavItem(id: 'purchases', label: 'Purchases', icon: Icons.shopping_cart_checkout, route: AppRoutes.cashierReceiving),
      ],
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
      id: 'reports',
      label: 'Reports',
      icon: Icons.bar_chart_outlined,
      route: AppRoutes.reports,
    ),
    _NavItem(
      id: 'settings',
      label: 'Settings',
      icon: Icons.settings_outlined,
      route: AppRoutes.settings,
      children: [
        _NavItem(id: 'sync', label: 'Sync', icon: Icons.sync_outlined, route: AppRoutes.syncStatus),
        _NavItem(id: 'notifications', label: 'Notifications', icon: Icons.notifications_outlined, route: AppRoutes.notificationsCenter),
      ],
    ),
    _NavItem(
      id: 'profile',
      label: 'Profile',
      icon: Icons.person_outline,
      route: AppRoutes.profile,
    ),
  ];

  /// Track which groups are expanded in the sidebar
  final Set<String> _expandedGroups = {};

  /// الحصول على النص المترجم لعنصر القائمة
  String _getLocalizedLabel(BuildContext context, _NavItem item) {
    final l10n = AppLocalizations.of(context);
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
      case 'settings': return l10n.settings;
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
    if (location.startsWith('/settings')) return 'settings';
    if (location.startsWith('/profile')) return 'profile';

    return 'pos'; // default
  }

  /// Find which parent group contains the given child id
  String? _parentGroupOf(String childId) {
    for (final item in _navItems) {
      if (item.hasChildren && item.children.any((c) => c.id == childId)) {
        return item.id;
      }
    }
    return null;
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
          final l10n = AppLocalizations.of(context);
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
              border: BorderDirectional(
                end: BorderSide(
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
                    horizontal: AlhaiSpacing.md,
                    vertical: AlhaiSpacing.mdl,
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

                // Nav items (grouped)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
                    children: _buildSidebarItems(selectedId),
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Column(
              children: [
                // بانرات حالة الاتصال والمزامنة
                const StatusBanners(),
                // ZATCA: تحذير عند عدم دقة ساعة الجهاز
                const ClockInvalidBanner(),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build all sidebar items, auto-expanding groups that contain the selected child.
  List<Widget> _buildSidebarItems(String selectedId) {
    // Auto-expand the group that owns the currently selected child
    final parentId = _parentGroupOf(selectedId);
    if (parentId != null) {
      _expandedGroups.add(parentId);
    }

    final widgets = <Widget>[];
    for (final item in _navItems) {
      final isSelected = item.id == selectedId;
      final isGroupActive = isSelected ||
          item.children.any((c) => c.id == selectedId);

      widgets.add(_buildSidebarItem(item, isSelected || (isGroupActive && !item.hasChildren)));

      // Render children if group is expanded
      if (item.hasChildren && _expandedGroups.contains(item.id)) {
        for (final child in item.children) {
          final childSelected = child.id == selectedId;
          widgets.add(_buildSidebarChild(child, childSelected));
        }
      }
    }
    return widgets;
  }

  /// Sidebar navigation item (parent level)
  Widget _buildSidebarItem(_NavItem item, bool isSelected) {
    final label = _getLocalizedLabel(context, item);
    final isExpanded = _expandedGroups.contains(item.id);
    return Semantics(
      label: label,
      button: true,
      selected: isSelected,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxxs),
        child: Material(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (item.hasChildren) {
                setState(() {
                  if (isExpanded) {
                    _expandedGroups.remove(item.id);
                  } else {
                    _expandedGroups.add(item.id);
                  }
                });
              }
              _onNavItemTapped(item.route);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 22,
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (item.hasChildren)
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Sidebar child item (indented)
  Widget _buildSidebarChild(_NavItem item, bool isSelected) {
    final label = _getLocalizedLabel(context, item);
    return Semantics(
      label: label,
      button: true,
      selected: isSelected,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: AlhaiSpacing.mdl, end: AlhaiSpacing.xs,
          top: AlhaiSpacing.xxxs, bottom: AlhaiSpacing.xxxs,
        ),
        child: Material(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _onNavItemTapped(item.route),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 18,
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AlhaiSpacing.xs),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
            SizedBox(width: AlhaiSpacing.xs),
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
                padding: const EdgeInsets.all(AlhaiSpacing.mdl),
                child: Row(
                  children: [
                    Semantics(
                      label: AppLocalizations.of(context).pos,
                      child: const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(
                          Icons.point_of_sale,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AlhaiSpacing.sm),
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

              // Nav items (grouped)
              Expanded(
                child: ListView(
                  children: _navItems.map((item) {
                    final isSelected = item.id == selectedId;
                    final label = _getLocalizedLabel(context, item);
                    final isGroupActive = isSelected ||
                        item.children.any((c) => c.id == selectedId);

                    if (item.hasChildren) {
                      return ExpansionTile(
                        leading: Icon(
                          item.icon,
                          color: isGroupActive ? AppColors.primary : null,
                        ),
                        title: Text(
                          label,
                          style: TextStyle(
                            fontWeight: isGroupActive ? FontWeight.w600 : FontWeight.normal,
                            color: isGroupActive ? AppColors.primary : null,
                          ),
                        ),
                        initiallyExpanded: isGroupActive,
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                        childrenPadding: const EdgeInsetsDirectional.only(start: 16),
                        children: [
                          // Parent route itself
                          ListTile(
                            leading: Icon(item.icon, size: 20, color: isSelected ? AppColors.primary : null),
                            title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? AppColors.primary : null, fontSize: 14)),
                            dense: true,
                            selected: isSelected,
                            selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
                            onTap: () { Navigator.of(context).pop(); _onNavItemTapped(item.route); },
                          ),
                          ...item.children.map((child) {
                            final childSelected = child.id == selectedId;
                            final childLabel = _getLocalizedLabel(context, child);
                            return ListTile(
                              leading: Icon(child.icon, size: 20, color: childSelected ? AppColors.primary : null),
                              title: Text(childLabel, style: TextStyle(fontWeight: childSelected ? FontWeight.w600 : FontWeight.normal, color: childSelected ? AppColors.primary : null, fontSize: 14)),
                              dense: true,
                              selected: childSelected,
                              selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
                              onTap: () { Navigator.of(context).pop(); _onNavItemTapped(child.route); },
                            );
                          }),
                        ],
                      );
                    }

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
      body: Column(
        children: [
          // بانرات حالة الاتصال والمزامنة
          const StatusBanners(),
          // ZATCA: تحذير عند عدم دقة ساعة الجهاز
          const ClockInvalidBanner(),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
