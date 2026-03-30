/// Dashboard Shell - الغلاف الرئيسي مع القائمة الجانبية
///
/// يوفر ShellRoute يحتوي على القائمة الجانبية الدائمة
/// بدلاً من إعادة بناء القائمة في كل شاشة
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/routes.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';
import '../../providers/print_providers.dart';
import 'app_sidebar.dart';

/// غلاف الداشبورد مع القائمة الجانبية الدائمة
class DashboardShell extends ConsumerStatefulWidget {
  final Widget child;

  const DashboardShell({super.key, required this.child});

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell> {
  final bool _sidebarCollapsed = false;
  List<SidebarGroup>? _cachedGroups;
  Locale? _cachedLocale;

  List<SidebarGroup> _getSidebarGroups(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);
    if (_cachedGroups == null || _cachedLocale != currentLocale) {
      _cachedGroups = DefaultSidebarItems.getGroups(context);
      _cachedLocale = currentLocale;
    }
    return _cachedGroups!;
  }

  /// تحديد العنصر المحدد من المسار الحالي
  String _getSelectedNavId(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    // AI routes
    if (location.startsWith('/ai/assistant')) return 'ai-assistant';
    if (location.startsWith('/ai/sales-forecasting')) return 'ai-sales-forecasting';
    if (location.startsWith('/ai/smart-pricing')) return 'ai-smart-pricing';
    if (location.startsWith('/ai/fraud-detection')) return 'ai-fraud-detection';
    if (location.startsWith('/ai/basket-analysis')) return 'ai-basket-analysis';
    if (location.startsWith('/ai/customer-recommendations')) return 'ai-customer-recommendations';
    if (location.startsWith('/ai/smart-inventory')) return 'ai-smart-inventory';
    if (location.startsWith('/ai/competitor-analysis')) return 'ai-competitor-analysis';
    if (location.startsWith('/ai/smart-reports')) return 'ai-smart-reports';
    if (location.startsWith('/ai/staff-analytics')) return 'ai-staff-analytics';
    if (location.startsWith('/ai/product-recognition')) return 'ai-product-recognition';
    if (location.startsWith('/ai/sentiment-analysis')) return 'ai-sentiment-analysis';
    if (location.startsWith('/ai/return-prediction')) return 'ai-return-prediction';
    if (location.startsWith('/ai/promotion-designer')) return 'ai-promotion-designer';
    if (location.startsWith('/ai/chat-with-data')) return 'ai-chat-with-data';

    // New feature routes (must come before generic matches)
    if (location.startsWith('/ecommerce')) return 'ecommerce';
    if (location.startsWith('/wallet')) return 'wallet';
    if (location.startsWith('/subscription')) return 'subscription';
    if (location.startsWith('/reports/complaints')) return 'complaints-report';
    if (location.startsWith('/media')) return 'media-library';
    if (location.startsWith('/devices')) return 'device-log';
    if (location.startsWith('/settings/shipping')) return 'shipping-gateways';

    // Main routes
    if (location.startsWith('/pos')) return 'pos';
    if (location.startsWith('/products')) return 'products';
    if (location.startsWith('/categories')) return 'categories';
    if (location.startsWith('/inventory')) return 'inventory';
    if (location.startsWith('/customers')) return 'customers';
    if (location.startsWith('/suppliers')) return 'suppliers';
    if (location.startsWith('/invoices')) return 'invoices';
    if (location.startsWith('/sales')) return 'sales';
    if (location.startsWith('/orders')) return 'orders';
    if (location.startsWith('/returns')) return 'returns';
    if (location.startsWith('/void-transaction')) return 'void-transaction';
    if (location.startsWith('/expenses')) return 'expenses';
    if (location.startsWith('/reports')) return 'reports';
    if (location.startsWith('/employees')) return 'employees';
    if (location.startsWith('/loyalty')) return 'loyalty';
    if (location.startsWith('/shifts')) return 'shifts';
    if (location.startsWith('/settings')) return 'settings';
    if (location.startsWith('/marketing') || location.startsWith('/promotions')) return 'marketing';
    if (location.startsWith('/sync')) return 'sync';
    if (location.startsWith('/drivers')) return 'drivers';
    if (location.startsWith('/branches')) return 'branches';
    if (location.startsWith('/notifications')) return 'notifications';
    if (location.startsWith('/print-queue')) return 'print-queue';
    if (location.startsWith('/purchases')) return 'purchases';
    if (location.startsWith('/cash-drawer')) return 'cash-drawer';
    if (location.startsWith('/debts')) return 'debts';
    if (location.startsWith('/profile')) return 'profile';
    if (location == '/dashboard' || location == '/home') return 'dashboard';

    return 'dashboard';
  }

  /// التنقل حسب معرف العنصر
  void _handleNavigation(String itemId) {
    switch (itemId) {
      case 'dashboard':
        context.go(AppRoutes.dashboard);
      case 'pos':
        context.go(AppRoutes.pos);
      case 'products':
        context.go(AppRoutes.products);
      case 'categories':
        context.go(AppRoutes.categories);
      case 'inventory':
        context.go(AppRoutes.inventory);
      case 'customers':
        context.go(AppRoutes.customers);
      case 'suppliers':
        context.go(AppRoutes.suppliers);
      case 'invoices':
        context.go(AppRoutes.invoices);
      case 'sales':
        context.go(AppRoutes.sales);
      case 'orders':
        context.go(AppRoutes.orders);
      case 'returns':
        context.go(AppRoutes.returns);
      case 'void-transaction':
        context.go(AppRoutes.voidTransaction);
      case 'expenses':
        context.go(AppRoutes.expenses);
      case 'reports':
        context.go(AppRoutes.reports);
      case 'employees':
        context.go(AppRoutes.employees);
      case 'loyalty':
        context.go(AppRoutes.loyalty);
      case 'shifts':
        context.go(AppRoutes.shifts);
      case 'purchases':
        context.go(AppRoutes.purchaseForm);
      case 'ai-assistant':
        context.go(AppRoutes.aiAssistant);
      case 'ai-sales-forecasting':
        context.go(AppRoutes.aiSalesForecasting);
      case 'ai-smart-pricing':
        context.go(AppRoutes.aiSmartPricing);
      case 'ai-fraud-detection':
        context.go(AppRoutes.aiFraudDetection);
      case 'ai-basket-analysis':
        context.go(AppRoutes.aiBasketAnalysis);
      case 'ai-customer-recommendations':
        context.go(AppRoutes.aiCustomerRecommendations);
      case 'ai-smart-inventory':
        context.go(AppRoutes.aiSmartInventory);
      case 'ai-competitor-analysis':
        context.go(AppRoutes.aiCompetitorAnalysis);
      case 'ai-smart-reports':
        context.go(AppRoutes.aiSmartReports);
      case 'ai-staff-analytics':
        context.go(AppRoutes.aiStaffAnalytics);
      case 'ai-product-recognition':
        context.go(AppRoutes.aiProductRecognition);
      case 'ai-sentiment-analysis':
        context.go(AppRoutes.aiSentimentAnalysis);
      case 'ai-return-prediction':
        context.go(AppRoutes.aiReturnPrediction);
      case 'ai-promotion-designer':
        context.go(AppRoutes.aiPromotionDesigner);
      case 'ai-chat-with-data':
        context.go(AppRoutes.aiChatWithData);
      case 'print-queue':
        context.go(AppRoutes.printQueue);
      case 'ecommerce':
        context.go(AppRoutes.ecommerce);
      case 'wallet':
        context.go(AppRoutes.wallet);
      case 'subscription':
        context.go(AppRoutes.subscription);
      case 'complaints-report':
        context.go(AppRoutes.complaintsReport);
      case 'media-library':
        context.go(AppRoutes.mediaLibrary);
      case 'device-log':
        context.go(AppRoutes.deviceLog);
      case 'shipping-gateways':
        context.go(AppRoutes.settingsShipping);
    }
  }

  /// تطبيق شارة عدد مهام الطباعة على مجموعات القائمة الجانبية
  List<SidebarGroup> _applyPrintQueueBadge(
      List<SidebarGroup> groups, int printCount) {
    if (printCount <= 0) return groups;

    return groups.map((group) {
      final updatedItems = group.items.map((item) {
        if (item.id == 'print-queue') {
          return AppSidebarItem(
            id: item.id,
            title: item.title,
            icon: item.icon,
            activeIcon: item.activeIcon,
            badge: '$printCount',
            badgeColor: AppColors.error,
            isNew: item.isNew,
          );
        }
        return item;
      }).toList();
      return SidebarGroup(title: group.title, items: updatedItems);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // M115: Use shared breakpoint from design system (905px)
    final isDesktop = context.screenWidth >= AlhaiBreakpoints.desktop;
    final selectedNavId = _getSelectedNavId(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pendingPrintCount = ref.watch(pendingPrintCountProvider);

    final sidebarGroups =
        _applyPrintQueueBadge(_getSidebarGroups(context), pendingPrintCount);

    final sidebar = AppSidebar(
      storeName: l10n.brandName,
      groups: sidebarGroups,
      selectedId: selectedNavId,
      onItemTap: (item) => _handleNavigation(item.id),
      onSettingsTap: () => context.go(AppRoutes.settings),
      onSupportTap: () => context.go(AppRoutes.settingsHelp),
      onLogoutTap: () async {
        await ref.read(authStateProvider.notifier).logout();
        if (context.mounted) context.go(AppRoutes.login);
      },
      collapsed: _sidebarCollapsed,
      userName: 'User', // TODO: Get from auth provider
      userRole: l10n.branchManager,
      onUserTap: () => context.go(AppRoutes.profile),
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundSecondary,
        body: Row(
          children: [
            sidebar,
            Expanded(child: widget.child),
          ],
        ),
      );
    } else {
      // Mobile: drawer sidebar
      return Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundSecondary,
        drawer: Drawer(
          child: AppSidebar(
            storeName: l10n.brandName,
            groups: sidebarGroups,
            selectedId: selectedNavId,
            onItemTap: (item) {
              Navigator.pop(context); // close drawer
              _handleNavigation(item.id);
            },
            onSettingsTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.settings);
            },
            onSupportTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.settingsHelp);
            },
            onLogoutTap: () async {
              Navigator.pop(context);
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
            userName: 'User',
            userRole: l10n.branchManager,
            onUserTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.profile);
            },
          ),
        ),
        body: widget.child,
      );
    }
  }
}
