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
import 'package:alhai_design_system/alhai_design_system.dart'
    show
        AlhaiBreakpoints,
        AlhaiSnackbar,
        AlhaiSnackbarVariant,
        AlhaiSpacing;
import 'package:alhai_auth/alhai_auth.dart' show authStateProvider, AuthStatus;
import '../core/constants/timing.dart';
import '../core/services/haptic_shim.dart';
import '../core/services/shortcuts_shim.dart' show ShortcutsShim;
import 'package:alhai_pos/alhai_pos.dart'
    show
        PosFocusController,
        cartStateProvider,
        heldInvoicesProvider,
        holdCurrentInvoice,
        showPosDiscountDialog;
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
          // Stop sync providers so background timers don't run after logout
          ref.invalidate(syncManagerProvider);
          ref.invalidate(globalSyncActivationProvider);
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
        _NavItem(
          id: 'cash-drawer',
          label: 'Cash Drawer',
          icon: Icons.point_of_sale_outlined,
          route: AppRoutes.cashDrawer,
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
      case 'pos':
        return l10n.pos;
      case 'sales':
        return l10n.salesHistory;
      case 'dashboard':
        return l10n.dashboard;
      case 'customers':
        return l10n.customers;
      case 'shifts':
        return l10n.shiftsTitle;
      case 'cash-drawer':
        return l10n.cashDrawer;
      case 'products':
        return l10n.products;
      case 'inventory':
        return l10n.inventory;
      case 'purchases':
        return l10n.purchases;
      case 'returns':
        return l10n.returns;
      case 'invoices':
        return l10n.invoices;
      case 'reports':
        return l10n.reports;
      case 'sync':
        return l10n.syncStatusTitle;
      case 'notifications':
        return l10n.notifications;
      case 'settings':
        return l10n.settings;
      case 'profile':
        return l10n.profileTitle;
      default:
        return item.label;
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
    if (location.startsWith('/cashier-receiving') ||
        location.startsWith('/purchase-request')) {
      return 'purchases';
    }
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
    // Phase 2 §2.6 — selection click haptic on navigation tab switch.
    HapticShim.selectionClick();
    context.go(route);
  }

  /// P0-11: iPad Mini portrait is 768 px wide, which is inside the shared
  /// tablet band (600–904) but below [AlhaiBreakpoints.desktop] (905). The
  /// shell previously fell back to a hamburger drawer for any tablet under
  /// 905 — so iPad Mini in portrait (an explicit target device) lost the
  /// sidebar full-time. Keep the sidebar from 768 px upward so narrow-tablet
  /// portrait orientations render the desktop layout; phones and truly
  /// small tablets (<768) still get the mobile drawer.
  static const double _sidebarBreakpoint = 768.0;

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.sizeOf(context).width >= _sidebarBreakpoint;
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
            now.difference(_lastBackPress!) < Timeouts.doubleBackExit) {
          SystemNavigator.pop();
        } else {
          _lastBackPress = now;
          final l10n = AppLocalizations.of(context);
          AlhaiSnackbar.show(
            context,
            message: l10n.pressBackAgainToExit,
            variant: AlhaiSnackbarVariant.neutral,
            duration: Timeouts.doubleBackExit,
            showCloseButton: false,
          );
        }
      },
      // Phase 4.5 — shell-level keyboard-shortcut scope.
      //
      // The shortcuts live here (not in [PosScreen]) because the cashier can
      // be on any shell route (sales history, invoices, etc.) and still want
      // to jump to payment or scan a barcode with one key. The POS-only
      // shortcuts (+/-, Delete) still fire from here — when the cashier is
      // NOT on the POS they degrade to no-ops because the active cart is
      // empty, which is the desired behaviour (no surprise actions).
      //
      // When the user turns keyboard shortcuts OFF (Settings →
      // Appearance & Input) we build with an empty bindings map rather than
      // conditionally wrapping [CallbackShortcuts] — this keeps the widget
      // tree stable across toggles and avoids focus churn.
      child: _CashierShortcutsScope(child: layout),
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
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
                    padding: const EdgeInsets.symmetric(
                      vertical: AlhaiSpacing.xs,
                    ),
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
      final isGroupActive =
          isSelected || item.children.any((c) => c.id == selectedId);

      widgets.add(
        _buildSidebarItem(
          item,
          isSelected || (isGroupActive && !item.hasChildren),
        ),
      );

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
        padding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.xs,
          vertical: AlhaiSpacing.xxxs,
        ),
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
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.sm,
                vertical: 10,
              ),
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
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
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
          start: AlhaiSpacing.mdl,
          end: AlhaiSpacing.xs,
          top: AlhaiSpacing.xxxs,
          bottom: AlhaiSpacing.xxxs,
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
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.sm,
                vertical: 8,
              ),
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
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
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
                    final isGroupActive =
                        isSelected ||
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
                            fontWeight: isGroupActive
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isGroupActive ? AppColors.primary : null,
                          ),
                        ),
                        initiallyExpanded: isGroupActive,
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                        childrenPadding: const EdgeInsetsDirectional.only(
                          start: 16,
                        ),
                        children: [
                          // Parent route itself
                          Semantics(
                            label: label,
                            button: true,
                            selected: isSelected,
                            child: ListTile(
                              leading: Icon(
                                item.icon,
                                size: 20,
                                color: isSelected ? AppColors.primary : null,
                              ),
                              title: Text(
                                label,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected ? AppColors.primary : null,
                                  fontSize: 14,
                                ),
                              ),
                              dense: true,
                              selected: isSelected,
                              selectedTileColor: AppColors.primary.withValues(
                                alpha: 0.08,
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                _onNavItemTapped(item.route);
                              },
                            ),
                          ),
                          ...item.children.map((child) {
                            final childSelected = child.id == selectedId;
                            final childLabel = _getLocalizedLabel(
                              context,
                              child,
                            );
                            return Semantics(
                              label: childLabel,
                              button: true,
                              selected: childSelected,
                              child: ListTile(
                                leading: Icon(
                                  child.icon,
                                  size: 20,
                                  color: childSelected
                                      ? AppColors.primary
                                      : null,
                                ),
                                title: Text(
                                  childLabel,
                                  style: TextStyle(
                                    fontWeight: childSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: childSelected
                                        ? AppColors.primary
                                        : null,
                                    fontSize: 14,
                                  ),
                                ),
                                dense: true,
                                selected: childSelected,
                                selectedTileColor: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _onNavItemTapped(child.route);
                                },
                              ),
                            );
                          }),
                        ],
                      );
                    }

                    return Semantics(
                      label: label,
                      button: true,
                      selected: isSelected,
                      child: ListTile(
                        leading: Icon(
                          item.icon,
                          color: isSelected ? AppColors.primary : null,
                        ),
                        title: Text(
                          label,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected ? AppColors.primary : null,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: AppColors.primary.withValues(
                          alpha: 0.08,
                        ),
                        onTap: () {
                          Navigator.of(context).pop(); // close drawer
                          _onNavItemTapped(item.route);
                        },
                      ),
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

// =============================================================================
// Phase 4.5 — Keyboard-shortcut scope (cashier shell level)
// =============================================================================

/// Wraps the shell body with [CallbackShortcuts] so the following keys work
/// from any cashier route:
///
/// | Key       | Action                                                         | Status |
/// |-----------|----------------------------------------------------------------|--------|
/// | F1        | (POS) toggle keyboard-shortcuts overlay                        | live (POS-scope) |
/// | F2        | (POS) focus search field                                       | live (POS-scope) |
/// | F3        | Hold the current invoice                                       | live |
/// | F4        | Open barcode scanner screen                                    | live |
/// | F5        | Proceed to payment                                             | live |
/// | F6        | Cash payment (opens payment screen preselected to cash)        | live |
/// | F7        | Card payment (opens payment screen preselected to card)        | live |
/// | F8        | Split payment (opens payment screen and auto-opens split)      | live |
/// | Ctrl+F    | Focus POS search field                                         | live |
/// | Ctrl+D    | Open discount dialog                                           | live |
/// | Ctrl+P    | Open reprint-receipt screen                                    | live |
/// | Ctrl+Del  | Clear cart                                                     | live |
/// | +         | Increase qty of active (last-added) item                       | live |
/// | -         | Decrease qty of active (last-added) item                       | live |
/// | Delete    | Remove active (last-added) item                                | live |
/// | Esc       | Close overlay / go home (handled inside POS)                   | live (POS-scope) |
///
/// The 15 shell-level bindings now all call concrete actions in `alhai_pos`
/// or `go_router`. Where the action is meaningful only on the POS route
/// (e.g. + / - / Delete — there is no cart elsewhere), the binding degrades
/// to a silent no-op on other routes; this matches the existing UX contract
/// (keyboard shortcuts should never surprise the cashier with a snackbar on
/// a screen where the key is not applicable).
///
/// Disabled state: when [ShortcutsShim.enabled] is `false` the widget builds
/// with an empty bindings map — the widget tree shape is unchanged, which
/// avoids focus scope churn when the user toggles the setting.
class _CashierShortcutsScope extends ConsumerStatefulWidget {
  const _CashierShortcutsScope({required this.child});

  final Widget child;

  @override
  ConsumerState<_CashierShortcutsScope> createState() =>
      _CashierShortcutsScopeState();
}

class _CashierShortcutsScopeState
    extends ConsumerState<_CashierShortcutsScope> {
  void _go(String route) => context.go(route);

  bool get _onPos =>
      GoRouterState.of(context).uri.path == AppRoutes.pos;

  /// F3 → hold the current invoice. No-op when the cart is empty; otherwise
  /// writes to the `held_invoices` table (via the public `holdCurrentInvoice`
  /// helper in alhai_pos) and clears the cart.
  Future<void> _holdInvoice() async {
    final cart = ref.read(cartStateProvider);
    if (cart.isEmpty) return; // silent — empty cart + F3 should do nothing
    await holdCurrentInvoice(ref);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    AlhaiSnackbar.show(
      context,
      message: l10n.invoiceSuspended,
      variant: AlhaiSnackbarVariant.success,
    );
    HapticShim.lightImpact();
  }

  /// F4 → navigate to the barcode-scanner screen. Unlike Ctrl+F (which just
  /// focuses the existing search field on the POS), this opens the dedicated
  /// camera/manual-entry screen — the button users would otherwise click
  /// from the POS products panel. Works from any route.
  void _openBarcodeScanner() => context.go('/pos/barcode-scanner');

  /// F5 / F6 / F7 / F8 — the happy-path payment shortcuts. All require a
  /// non-empty cart; on an empty cart they silently no-op (F5) or stay on
  /// the current route (F6/F7/F8 via navigation guard below).
  void _proceedToPayment() {
    final cart = ref.read(cartStateProvider);
    if (!_onPos) {
      _go(AppRoutes.pos);
      return; // Do NOT auto-chain — user can press F5 again when POS mounts.
    }
    if (cart.isEmpty) return; // nothing to pay for
    _go(AppRoutes.posPayment);
  }

  /// F6 / F7 / F8 — jump straight to the payment screen with a method
  /// preselected. The cashier router reads `?method=cash|card|split` and
  /// forwards to `PaymentScreen(preselectedMethod: ..., autoOpenSplit: ...)`.
  /// Empty cart → silent no-op (matches the F5 contract). Pressing F6/F7/F8
  /// from a non-POS route navigates to POS first and returns without
  /// auto-chaining (same `_onPos` guard pattern as F5) — the user can press
  /// the shortcut again once the POS mounts.
  void _jumpToPayment(String method) {
    if (!_onPos) {
      _go(AppRoutes.pos);
      return; // Do NOT auto-chain — user can press F6/F7/F8 again when POS mounts.
    }
    final cart = ref.read(cartStateProvider);
    if (cart.isEmpty) return;
    _go('${AppRoutes.posPayment}?method=$method');
  }

  /// Ctrl+F → focus the POS product-search field. When the POS is not mounted
  /// (controller returns false), navigate there first; on the next frame the
  /// POS will autofocus its own scope. We intentionally do NOT re-dispatch
  /// the keystroke — a second Ctrl+F after navigation focuses cleanly.
  void _focusPosSearch() {
    final handled = PosFocusController.requestSearchFocus();
    if (!handled) _go(AppRoutes.pos);
  }

  /// Ctrl+D → show the discount dialog. Delegates to the public
  /// `showPosDiscountDialog` helper, which itself no-ops when the cart is
  /// empty (so callers need no extra guard).
  void _applyDiscount() {
    if (!_onPos) {
      _go(AppRoutes.pos);
      return;
    }
    showPosDiscountDialog(context: context, ref: ref);
  }

  /// Ctrl+P → open the reprint-receipt screen so the cashier can search past
  /// sales and reprint any receipt. Not tied to the "last" sale because the
  /// POS does not retain a reference to it after the success dialog closes;
  /// the reprint screen gives the cashier explicit control.
  void _printReceipt() => _go('/sales/reprint');

  /// Ctrl+Del → clear cart. The cart provider is safe to call from here
  /// because it is a package-level StateNotifier.
  void _clearCart() {
    ref.read(cartStateProvider.notifier).clear();
    HapticShim.lightImpact();
  }

  /// + → increase qty of the active (last-added) item. Silent no-op when the
  /// cart is empty or when the item is already at the ceiling.
  void _increaseActiveQty() {
    ref.read(cartStateProvider.notifier).incrementActive();
  }

  /// - → decrease qty of the active item. When qty would drop to 0, the item
  /// is removed entirely (matching the cart notifier's `decrementQuantity`).
  void _decreaseActiveQty() {
    ref.read(cartStateProvider.notifier).decrementActive();
  }

  /// Delete → remove the active (last-added) item.
  void _removeActiveItem() {
    ref.read(cartStateProvider.notifier).removeActive();
    HapticShim.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    // Toggle respect: empty bindings disables every shortcut without
    // destroying the scope (keeps focus behaviour consistent).
    final bindings = !ShortcutsShim.enabled
        ? const <ShortcutActivator, VoidCallback>{}
        : <ShortcutActivator, VoidCallback>{
            // F3 — hold the current invoice (cart → held_invoices table).
            const SingleActivator(LogicalKeyboardKey.f3): _holdInvoice,
            // F4 — open barcode scanner screen.
            const SingleActivator(LogicalKeyboardKey.f4): _openBarcodeScanner,
            // F5 — proceed to payment (requires non-empty cart on POS).
            const SingleActivator(LogicalKeyboardKey.f5): _proceedToPayment,
            // F6 / F7 / F8 — payment screen with method preselected.
            const SingleActivator(LogicalKeyboardKey.f6): () =>
                _jumpToPayment('cash'),
            const SingleActivator(LogicalKeyboardKey.f7): () =>
                _jumpToPayment('card'),
            const SingleActivator(LogicalKeyboardKey.f8): () =>
                _jumpToPayment('split'),
            // Ctrl+F — focus POS search field (navigates to POS if elsewhere).
            const SingleActivator(LogicalKeyboardKey.keyF, control: true):
                _focusPosSearch,
            // Ctrl+D — apply discount (opens discount dialog).
            const SingleActivator(LogicalKeyboardKey.keyD, control: true):
                _applyDiscount,
            // Ctrl+P — reprint a past receipt (opens /sales/reprint).
            const SingleActivator(LogicalKeyboardKey.keyP, control: true):
                _printReceipt,
            // Ctrl+Del — clear cart.
            const SingleActivator(LogicalKeyboardKey.delete, control: true):
                _clearCart,
            // + / - — adjust qty of the active cart item. PosKeyboardListener
            // inside PosScreen may also handle these when a product is being
            // added; the shell bindings operate on the last cart item so they
            // stay useful on non-POS routes where the cart still exists.
            const SingleActivator(LogicalKeyboardKey.equal, shift: true):
                _increaseActiveQty,
            const SingleActivator(LogicalKeyboardKey.numpadAdd):
                _increaseActiveQty,
            const SingleActivator(LogicalKeyboardKey.minus): _decreaseActiveQty,
            const SingleActivator(LogicalKeyboardKey.numpadSubtract):
                _decreaseActiveQty,
            // Delete — remove the active cart item.
            const SingleActivator(LogicalKeyboardKey.delete): _removeActiveItem,
          };

    return CallbackShortcuts(
      bindings: bindings,
      child: Focus(
        autofocus: true,
        // The inner child owns its own focus (PosScreen has autofocus:true on
        // its own Focus wrapper). `canRequestFocus: false` on this outer node
        // means the inner nodes still grab focus naturally — we only need
        // this Focus to let the bindings receive events that bubble up.
        canRequestFocus: false,
        skipTraversal: true,
        child: widget.child,
      ),
    );
  }
}
