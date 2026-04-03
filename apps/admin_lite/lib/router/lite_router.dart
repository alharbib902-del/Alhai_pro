/// Admin Lite Router
///
/// GoRouter configuration with ~80 routes for the Lite admin app.
/// Uses BottomNavigationBar shell with 5 tabs:
/// Dashboard, Reports, AI, Monitoring, More
///
/// Includes 25 Lite-specific screens across 7 groups:
/// Dashboard (3), Quick Reports (6), Alerts (4),
/// Order Tracking (5), Quick Management (4), Settings (3).
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart' show UserRole;
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_reports/alhai_reports.dart';
import 'package:alhai_ai/alhai_ai.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../ui/lite_shell.dart';
import '../screens/dashboard/lite_dashboard_screen.dart';
import '../screens/dashboard/lite_sales_trend_screen.dart';
import '../screens/dashboard/lite_alerts_summary_screen.dart';
import '../screens/approvals/approval_center_screen.dart';
import '../screens/reports/lite_daily_sales_screen.dart';
import '../screens/reports/lite_weekly_comparison_screen.dart';
import '../screens/reports/lite_top_products_screen.dart';
import '../screens/reports/lite_low_stock_screen.dart';
import '../screens/reports/lite_employee_performance_screen.dart';
import '../screens/reports/lite_cash_flow_screen.dart';
import '../screens/alerts/lite_notifications_list_screen.dart';
import '../screens/alerts/lite_stock_alerts_screen.dart';
import '../screens/alerts/lite_order_alerts_screen.dart';
import '../screens/alerts/lite_system_alerts_screen.dart';
import '../screens/orders/lite_active_orders_screen.dart';
import '../screens/orders/lite_order_detail_screen.dart';
import '../screens/orders/lite_order_status_screen.dart';
import '../screens/orders/lite_delivery_tracking_screen.dart';
import '../screens/orders/lite_order_history_screen.dart';
import '../screens/management/lite_quick_price_screen.dart';
import '../screens/management/lite_stock_adjustment_screen.dart';
import '../screens/management/lite_employee_schedule_screen.dart';
import '../screens/management/lite_pending_approvals_screen.dart';
import '../screens/settings/lite_settings_screen.dart';
import '../screens/settings/lite_profile_screen.dart';
import '../screens/settings/lite_notification_prefs_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';

/// Route parameter extraction helper
extension GoRouterStateX on GoRouterState {
  /// Extract path parameter by key (defaults to 'id')
  String pathId([String key = 'id']) => pathParameters[key] ?? '';

  /// Extract query parameter by key
  String queryParam(String key) => uri.queryParameters[key] ?? '';
}

/// Notifier that triggers GoRouter redirect on auth/store changes.
///
/// NOTE [M144]: This pattern (_AuthNotifier + _guardRedirect) is duplicated
/// across lite_router, admin_router, and cashier_router. Each variant has
/// app-specific redirect logic (role checks, different home routes), so
/// extracting to a shared helper is not straightforward. If routers converge
/// further, consider extracting to alhai_auth as a configurable factory.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(Ref ref) {
    _subs = [
      ref.listen(authStateProvider, (_, __) => notifyListeners()),
      ref.listen(currentStoreIdProvider, (_, __) => notifyListeners()),
      ref.listen(liteOnboardingSeenProvider, (_, __) => notifyListeners()),
    ];
  }
  late final List<ProviderSubscription> _subs;

  @override
  void dispose() {
    for (final s in _subs) {
      s.close();
    }
    super.dispose();
  }
}

String? _guardRedirect(Ref ref, GoRouterState state) {
  final authState = ref.read(authStateProvider);
  final storeId = ref.read(currentStoreIdProvider);
  final onboardingSeen = ref.read(liteOnboardingSeenProvider);
  final path = state.uri.path;

  const publicPaths = [AppRoutes.splash, AppRoutes.login, AppRoutes.onboarding];
  final isPublic = publicPaths.contains(path);

  // Still resolving → stay on current page
  if (authState.status == AuthStatus.unknown) return null;

  // ── Onboarding guard (M56) ──────────────────────────────────────
  // If onboarding has not been seen yet, redirect to onboarding.
  // Skip if we're already on onboarding or splash (to avoid loops).
  if (onboardingSeen == false &&
      path != AppRoutes.onboarding &&
      path != AppRoutes.splash) {
    return AppRoutes.onboarding;
  }

  // If onboarding state is still loading (null), stay on current page
  if (onboardingSeen == null && path == AppRoutes.splash) {
    return null;
  }

  // If user completed onboarding and is still on the onboarding page,
  // redirect to login
  if (onboardingSeen == true && path == AppRoutes.onboarding) {
    return AppRoutes.login;
  }

  // Not authenticated → login
  if (authState.status == AuthStatus.unauthenticated ||
      authState.status == AuthStatus.sessionExpired) {
    return isPublic ? null : AppRoutes.login;
  }

  // Authenticated but no store selected
  if (storeId == null &&
      path != AppRoutes.storeSelect &&
      !isPublic) {
    return AppRoutes.storeSelect;
  }

  // Only admins can use admin lite app
  final role = ref.read(userRoleProvider);
  if (authState.status == AuthStatus.authenticated &&
      storeId != null &&
      !isPublic &&
      role != null &&
      role == UserRole.employee) {
    return AppRoutes.login;
  }

  // Already logged in & has store, trying to access login/splash/onboarding
  if (isPublic &&
      authState.status == AuthStatus.authenticated &&
      storeId != null) {
    return AppRoutes.dashboard;
  }

  return null;
}

/// Admin Lite Router Provider (with auth redirect)
final liteRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthNotifier(ref);
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,
    redirect: (context, state) => _guardRedirect(ref, state),
    routes: _routes,
    errorBuilder: _errorBuilder,
  );
});

Widget _errorBuilder(BuildContext context, GoRouterState state) {
  final l10n = AppLocalizations.of(context);
  return Scaffold(
    appBar: AppBar(title: Text(l10n?.error ?? 'Error')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: AlhaiSpacing.md),
          Text(l10n != null
              ? '${l10n.error}: ${state.uri.path}'
              : 'Page not found: ${state.uri.path}'),
          const SizedBox(height: AlhaiSpacing.lg),
          FilledButton(
            onPressed: () => context.go(AppRoutes.dashboard),
            child: Text(l10n?.home ?? 'Home'),
          ),
        ],
      ),
    ),
  );
}

final List<RouteBase> _routes = [
  // ============================================================================
  // AUTH ROUTES (outside shell - no bottom nav)
  // ============================================================================
  GoRoute(
    path: AppRoutes.splash,
    name: 'splash',
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    path: AppRoutes.login,
    name: 'login',
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: AppRoutes.storeSelect,
    name: 'store-select',
    builder: (context, state) => const StoreSelectScreen(),
  ),

  // ============================================================================
  // ONBOARDING (outside shell - no bottom nav) [M56]
  // ============================================================================
  GoRoute(
    path: AppRoutes.onboarding,
    name: 'onboarding',
    builder: (context, state) => const LiteOnboardingScreen(),
  ),

  // ============================================================================
  // SHELL ROUTE - Bottom Navigation Bar with 5 tabs
  // ============================================================================
  ShellRoute(
    builder: (context, state, child) => LiteShell(child: child),
    routes: [
      // ======================================================================
      // TAB 1: DASHBOARD
      // ======================================================================
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const LiteDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const LiteDashboardScreen(),
      ),
      GoRoute(
        path: '/approvals',
        name: 'approvals',
        builder: (context, state) => const ApprovalCenterScreen(),
      ),

      // ======================================================================
      // DASHBOARD: Sales Trend & Alerts Summary
      // ======================================================================
      GoRoute(
        path: '/lite/sales-trend',
        name: 'lite-sales-trend',
        builder: (context, state) => const LiteSalesTrendScreen(),
      ),
      GoRoute(
        path: '/lite/alerts-summary',
        name: 'lite-alerts-summary',
        builder: (context, state) => const LiteAlertsSummaryScreen(),
      ),

      // ======================================================================
      // QUICK REPORTS (6 screens)
      // ======================================================================
      GoRoute(
        path: '/lite/reports/daily-sales',
        name: 'lite-daily-sales',
        builder: (context, state) => const LiteDailySalesScreen(),
      ),
      GoRoute(
        path: '/lite/reports/weekly',
        name: 'lite-weekly-comparison',
        builder: (context, state) => const LiteWeeklyComparisonScreen(),
      ),
      GoRoute(
        path: '/lite/reports/top-products',
        name: 'lite-top-products',
        builder: (context, state) => const LiteTopProductsScreen(),
      ),
      GoRoute(
        path: '/lite/reports/low-stock',
        name: 'lite-low-stock',
        builder: (context, state) => const LiteLowStockScreen(),
      ),
      GoRoute(
        path: '/lite/reports/employee-performance',
        name: 'lite-employee-performance',
        builder: (context, state) => const LiteEmployeePerformanceScreen(),
      ),
      GoRoute(
        path: '/lite/reports/cash-flow',
        name: 'lite-cash-flow',
        builder: (context, state) => const LiteCashFlowScreen(),
      ),

      // ======================================================================
      // ALERTS & NOTIFICATIONS (4 screens)
      // ======================================================================
      GoRoute(
        path: '/lite/alerts/notifications',
        name: 'lite-notifications-list',
        builder: (context, state) => const LiteNotificationsListScreen(),
      ),
      GoRoute(
        path: '/lite/alerts/stock',
        name: 'lite-stock-alerts',
        builder: (context, state) => const LiteStockAlertsScreen(),
      ),
      GoRoute(
        path: '/lite/alerts/orders',
        name: 'lite-order-alerts',
        builder: (context, state) => const LiteOrderAlertsScreen(),
      ),
      GoRoute(
        path: '/lite/alerts/system',
        name: 'lite-system-alerts',
        builder: (context, state) => const LiteSystemAlertsScreen(),
      ),

      // ======================================================================
      // ORDER TRACKING (5 screens)
      // ======================================================================
      GoRoute(
        path: '/lite/orders',
        name: 'lite-active-orders',
        builder: (context, state) => const LiteActiveOrdersScreen(),
      ),
      GoRoute(
        path: '/lite/orders/:id',
        name: 'lite-order-detail',
        builder: (context, state) {
          final id = state.pathId();
          return LiteOrderDetailScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/lite/orders/:id/status',
        name: 'lite-order-status',
        builder: (context, state) {
          final id = state.pathId();
          return LiteOrderStatusScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/lite/delivery-tracking',
        name: 'lite-delivery-tracking',
        builder: (context, state) => const LiteDeliveryTrackingScreen(),
      ),
      GoRoute(
        path: '/lite/order-history',
        name: 'lite-order-history',
        builder: (context, state) => const LiteOrderHistoryScreen(),
      ),

      // ======================================================================
      // QUICK MANAGEMENT (4 screens)
      // ======================================================================
      GoRoute(
        path: '/lite/management/quick-price',
        name: 'lite-quick-price',
        builder: (context, state) => const LiteQuickPriceScreen(),
      ),
      GoRoute(
        path: '/lite/management/stock-adjustment',
        name: 'lite-stock-adjustment',
        builder: (context, state) => const LiteStockAdjustmentScreen(),
      ),
      GoRoute(
        path: '/lite/management/employee-schedule',
        name: 'lite-employee-schedule',
        builder: (context, state) => const LiteEmployeeScheduleScreen(),
      ),
      GoRoute(
        path: '/lite/management/pending-approvals',
        name: 'lite-pending-approvals',
        builder: (context, state) => const LitePendingApprovalsScreen(),
      ),

      // ======================================================================
      // SETTINGS: Profile & Notification Preferences
      // ======================================================================
      GoRoute(
        path: '/lite/profile',
        name: 'lite-profile',
        builder: (context, state) => const LiteProfileScreen(),
      ),
      GoRoute(
        path: '/lite/settings/notification-prefs',
        name: 'lite-notification-prefs',
        builder: (context, state) => const LiteNotificationPrefsScreen(),
      ),

      // ======================================================================
      // TAB 2: REPORTS (13 screens from alhai_reports)
      // ======================================================================
      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const ReportsScreen()),
      ),
      GoRoute(
        path: '/reports/daily-sales',
        name: 'daily-sales-report',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const DailySalesReportScreen()),
      ),
      GoRoute(
        path: '/reports/profit',
        name: 'profit-report',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const ProfitReportScreen()),
      ),
      GoRoute(
        path: '/reports/tax',
        name: 'tax-report',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const TaxReportScreen()),
      ),
      GoRoute(
        path: '/reports/vat',
        name: 'vat-report',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const VatReportScreen()),
      ),
      GoRoute(
        path: '/reports/inventory',
        name: 'inventory-report',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const InventoryReportScreen()),
      ),
      GoRoute(
        path: '/reports/customers',
        name: 'customer-report',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const CustomerReportScreen()),
      ),
      GoRoute(
        path: '/reports/top-products',
        name: 'top-products-report',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const TopProductsReportScreen()),
      ),
      GoRoute(
        path: '/reports/sales-analytics',
        name: 'sales-analytics',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const SalesAnalyticsScreen()),
      ),
      GoRoute(
        path: '/reports/staff-performance',
        name: 'staff-performance',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const StaffPerformanceScreen()),
      ),
      GoRoute(
        path: '/reports/peak-hours',
        name: 'peak-hours-report',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const PeakHoursReportScreen()),
      ),
      GoRoute(
        path: '/reports/debts',
        name: 'debts-report',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const DebtsReportScreen()),
      ),
      GoRoute(
        path: AppRoutes.complaintsReport,
        name: 'complaints-report',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const ComplaintsReportScreen()),
      ),

      // ======================================================================
      // TAB 3: AI (15 screens from alhai_ai)
      // ======================================================================
      GoRoute(
        path: AppRoutes.aiAssistant,
        name: 'ai-assistant',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const AiAssistantScreen()),
      ),
      GoRoute(
        path: AppRoutes.aiSalesForecasting,
        name: 'ai-sales-forecasting',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const AiSalesForecastingScreen()),
      ),
      GoRoute(
        path: AppRoutes.aiSmartPricing,
        name: 'ai-smart-pricing',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const AiSmartPricingScreen()),
      ),
      GoRoute(
        path: AppRoutes.aiFraudDetection,
        name: 'ai-fraud-detection',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const AiFraudDetectionScreen()),
      ),
      GoRoute(
        path: AppRoutes.aiBasketAnalysis,
        name: 'ai-basket-analysis',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const AiBasketAnalysisScreen()),
      ),
      GoRoute(
        path: AppRoutes.aiCustomerRecommendations,
        name: 'ai-customer-recommendations',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const AiCustomerRecommendationsScreen()),
      ),
      GoRoute(
        path: AppRoutes.aiSmartInventory,
        name: 'ai-smart-inventory',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const AiSmartInventoryScreen()),
      ),
      GoRoute(
        path: AppRoutes.aiCompetitorAnalysis,
        name: 'ai-competitor-analysis',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const AiCompetitorAnalysisScreen()),
      ),
      GoRoute(
        path: AppRoutes.aiSmartReports,
        name: 'ai-smart-reports',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const AiSmartReportsScreen()),
      ),
      GoRoute(
        path: AppRoutes.aiStaffAnalytics,
        name: 'ai-staff-analytics',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const AiStaffAnalyticsScreen()),
      ),
      GoRoute(
        path: AppRoutes.aiProductRecognition,
        name: 'ai-product-recognition',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const AiProductRecognitionScreen()),
      ),
      GoRoute(
        path: AppRoutes.aiSentimentAnalysis,
        name: 'ai-sentiment-analysis',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const AiSentimentAnalysisScreen()),
      ),
      GoRoute(
        path: AppRoutes.aiReturnPrediction,
        name: 'ai-return-prediction',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const AiReturnPredictionScreen()),
      ),
      GoRoute(
        path: AppRoutes.aiPromotionDesigner,
        name: 'ai-promotion-designer',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const AiPromotionDesignerScreen()),
      ),
      GoRoute(
        path: AppRoutes.aiChatWithData,
        name: 'ai-chat-with-data',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const AiChatWithDataScreen()),
      ),

      // ======================================================================
      // TAB 4: MONITORING (inventory alerts, expiry tracking, shifts)
      // ======================================================================
      GoRoute(
        path: '/monitoring',
        name: 'monitoring',
        builder: (context, state) => const _MonitoringHubScreen(),
      ),
      GoRoute(
        path: '/monitoring/inventory-alerts',
        name: 'inventory-alerts',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const InventoryAlertsScreen()),
      ),
      GoRoute(
        path: AppRoutes.inventory,
        name: 'inventory',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const InventoryScreen()),
      ),
      GoRoute(
        path: AppRoutes.expiryTracking,
        name: 'expiry-tracking',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const ExpiryTrackingScreen()),
      ),
      GoRoute(
        path: AppRoutes.shifts,
        name: 'shifts',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const ShiftsScreen()),
      ),
      GoRoute(
        path: AppRoutes.shiftSummary,
        name: 'shift-summary',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const ShiftSummaryScreen()),
      ),
      GoRoute(
        path: AppRoutes.products,
        name: 'products',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const ProductsScreen()),
      ),
      GoRoute(
        path: AppRoutes.productDetail,
        name: 'product-detail',
        builder: (context, state) {
          final id = state.pathId();
          return LazyScreen(screenBuilder: () async => ProductDetailScreen(productId: id));
        },
      ),

      // ======================================================================
      // TAB 5: MORE (customers, suppliers, orders, expenses, profile, settings)
      // ======================================================================
      GoRoute(
        path: '/more',
        name: 'more',
        builder: (context, state) => const _MoreMenuScreen(),
      ),
      GoRoute(
        path: AppRoutes.customers,
        name: 'customers',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const CustomersScreen()),
      ),
      GoRoute(
        path: AppRoutes.customerDetail,
        name: 'customer-detail',
        builder: (context, state) {
          final id = state.pathId();
          return LazyScreen(screenBuilder: () async => CustomerDetailScreen(customerId: id));
        },
      ),
      GoRoute(
        path: AppRoutes.suppliers,
        name: 'suppliers',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const SuppliersScreen()),
      ),
      GoRoute(
        path: AppRoutes.supplierDetail,
        name: 'supplier-detail',
        builder: (context, state) {
          final id = state.pathId();
          return LazyScreen(screenBuilder: () async => SupplierDetailScreen(supplierId: id));
        },
      ),
      GoRoute(
        path: AppRoutes.orders,
        name: 'orders',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const OrdersScreen()),
      ),
      GoRoute(
        path: AppRoutes.invoices,
        name: 'invoices',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const InvoicesScreen()),
      ),
      GoRoute(
        path: AppRoutes.invoiceDetail,
        name: 'invoice-detail',
        builder: (context, state) {
          final id = state.pathId();
          return LazyScreen(screenBuilder: () async => InvoiceDetailScreen(invoiceId: id));
        },
      ),
      GoRoute(
        path: AppRoutes.expenses,
        name: 'expenses',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const ExpensesScreen()),
      ),
      GoRoute(
        path: AppRoutes.expenseCategories,
        name: 'expense-categories',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const ExpenseCategoriesScreen()),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const LiteSettingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.settingsLanguage,
        name: 'settings-language',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const LanguageScreen()),
      ),
      GoRoute(
        path: AppRoutes.settingsTheme,
        name: 'settings-theme',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const ThemeScreen()),
      ),
      GoRoute(
        path: AppRoutes.syncStatus,
        name: 'sync-status',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const SyncStatusScreen()),
      ),
      GoRoute(
        path: AppRoutes.notificationsCenter,
        name: 'notifications',
        builder: (context, state) => LazyScreen(screenBuilder: () async => const NotificationsScreen()),
      ),
    ],
  ),
];

// =============================================================================
// LOCAL SCREENS (hub screens specific to Lite)
// =============================================================================

/// Monitoring hub screen - entry point for Tab 4
class _MonitoringHubScreen extends StatelessWidget {
  const _MonitoringHubScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monitoring')),
      body: ListView(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        children: [
          _MonitoringTile(
            icon: Icons.warning_amber_rounded,
            title: 'Inventory Alerts',
            subtitle: 'Low stock & out-of-stock items',
            onTap: () => context.go('/monitoring/inventory-alerts'),
          ),
          _MonitoringTile(
            icon: Icons.inventory_2_outlined,
            title: 'Inventory',
            subtitle: 'Full inventory overview',
            onTap: () => context.go(AppRoutes.inventory),
          ),
          _MonitoringTile(
            icon: Icons.calendar_today,
            title: 'Expiry Tracking',
            subtitle: 'Products nearing expiration',
            onTap: () => context.go(AppRoutes.expiryTracking),
          ),
          _MonitoringTile(
            icon: Icons.schedule,
            title: 'Shifts',
            subtitle: 'Shift management & summaries',
            onTap: () => context.go(AppRoutes.shifts),
          ),
          _MonitoringTile(
            icon: Icons.category_outlined,
            title: 'Products',
            subtitle: 'Browse product catalog',
            onTap: () => context.go(AppRoutes.products),
          ),
        ],
      ),
    );
  }
}

/// More menu screen - entry point for Tab 5
class _MoreMenuScreen extends StatelessWidget {
  const _MoreMenuScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        children: [
          _MonitoringTile(
            icon: Icons.people_outline,
            title: 'Customers',
            subtitle: 'Customer management',
            onTap: () => context.go(AppRoutes.customers),
          ),
          _MonitoringTile(
            icon: Icons.local_shipping_outlined,
            title: 'Suppliers',
            subtitle: 'Supplier management',
            onTap: () => context.go(AppRoutes.suppliers),
          ),
          _MonitoringTile(
            icon: Icons.receipt_long_outlined,
            title: 'Orders',
            subtitle: 'Order history',
            onTap: () => context.go(AppRoutes.orders),
          ),
          _MonitoringTile(
            icon: Icons.description_outlined,
            title: 'Invoices',
            subtitle: 'Invoice management',
            onTap: () => context.go(AppRoutes.invoices),
          ),
          _MonitoringTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Expenses',
            subtitle: 'Expense tracking',
            onTap: () => context.go(AppRoutes.expenses),
          ),
          const Divider(height: AlhaiSpacing.xl),
          _MonitoringTile(
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: 'Your account',
            onTap: () => context.go(AppRoutes.profile),
          ),
          _MonitoringTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'App preferences',
            onTap: () => context.go(AppRoutes.settings),
          ),
          _MonitoringTile(
            icon: Icons.sync,
            title: 'Sync Status',
            subtitle: 'Data synchronization',
            onTap: () => context.go(AppRoutes.syncStatus),
          ),
          _MonitoringTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Alerts & updates',
            onTap: () => context.go(AppRoutes.notificationsCenter),
          ),
        ],
      ),
    );
  }
}

/// Reusable monitoring tile widget
class _MonitoringTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MonitoringTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
