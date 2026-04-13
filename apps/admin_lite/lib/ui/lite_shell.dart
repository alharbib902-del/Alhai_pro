/// Lite Shell - Bottom Navigation Layout
///
/// Provides a 5-tab bottom navigation bar for the Admin Lite app:
/// 1. Dashboard - Main overview
/// 2. Reports - Financial & operational reports
/// 3. AI - Artificial intelligence tools
/// 4. Monitoring - Inventory alerts, expiry, shifts
/// 5. More - Customers, suppliers, orders, expenses, profile, settings
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

import '../router/lite_router.dart' show LiteRoutes;

/// Bottom Navigation shell layout for Admin Lite
class LiteShell extends StatelessWidget {
  final Widget child;

  const LiteShell({super.key, required this.child});

  /// Determine selected tab index based on current route
  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    // Tab 2: Reports
    if (location.startsWith('/reports') ||
        location == AppRoutes.complaintsReport) {
      return 1;
    }

    // Tab 3: AI
    if (location.startsWith('/ai')) {
      return 2;
    }

    // Tab 4: Monitoring
    if (location.startsWith('/monitoring') ||
        location.startsWith('/inventory') ||
        location == AppRoutes.expiryTracking ||
        location.startsWith('/shifts') ||
        location.startsWith('/products')) {
      return 3;
    }

    // Tab 5: More
    if (location.startsWith('/more') ||
        location.startsWith('/customers') ||
        location.startsWith('/suppliers') ||
        location.startsWith('/orders') ||
        location.startsWith('/invoices') ||
        location.startsWith('/expenses') ||
        location == AppRoutes.profile ||
        location.startsWith('/settings') ||
        location == AppRoutes.syncStatus ||
        location == AppRoutes.notificationsCenter) {
      return 4;
    }

    // Tab 1: Dashboard (default)
    return 0;
  }

  /// Navigate to the appropriate tab root
  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        break;
      case 1:
        context.go(AppRoutes.reports);
        break;
      case 2:
        context.go(AppRoutes.aiAssistant);
        break;
      case 3:
        context.go(LiteRoutes.monitoring);
        break;
      case 4:
        context.go(LiteRoutes.more);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _selectedIndex(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTabTapped(context, index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
            tooltip: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart_outlined),
            activeIcon: const Icon(Icons.bar_chart),
            label: l10n.reports,
            tooltip: l10n.reports,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_awesome_outlined),
            activeIcon: const Icon(Icons.auto_awesome),
            label: l10n.aiAssistant,
            tooltip: l10n.aiAssistant,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.monitor_heart_outlined),
            activeIcon: const Icon(Icons.monitor_heart),
            label: l10n.inventory,
            tooltip: l10n.inventory,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.more_horiz),
            activeIcon: const Icon(Icons.more_horiz),
            label: l10n.more,
            tooltip: l10n.more,
          ),
        ],
      ),
    );
  }
}
