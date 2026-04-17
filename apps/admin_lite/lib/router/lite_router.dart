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

import 'package:flutter/foundation.dart' show kDebugMode;
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
import '../screens/approval_center_screen.dart';
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
import '../screens/onboarding_screen.dart';

/// Admin Lite-specific route constants (not in shared AppRoutes).
class LiteRoutes {
  LiteRoutes._();

  /// Monitoring hub tab root
  static const String monitoring = '/monitoring';

  /// Inventory alerts (under monitoring)
  static const String inventoryAlerts = '/monitoring/inventory-alerts';

  /// More menu tab root
  static const String more = '/more';

  /// Lite-specific sub-routes
  static const String salesTrend = '/lite/sales-trend';
  static const String alertsSummary = '/lite/alerts-summary';
  static const String dailySales = '/lite/reports/daily-sales';
  static const String weeklyComparison = '/lite/reports/weekly';
  static const String topProducts = '/lite/reports/top-products';
  static const String lowStock = '/lite/reports/low-stock';
  static const String employeePerformance =
      '/lite/reports/employee-performance';
  static const String cashFlow = '/lite/reports/cash-flow';
  static const String notificationsList = '/lite/alerts/notifications';
  static const String stockAlerts = '/lite/alerts/stock';
  static const String orderAlerts = '/lite/alerts/orders';
  static const String systemAlerts = '/lite/alerts/system';
  static const String activeOrders = '/lite/orders';
  static const String orderDetail = '/lite/orders/:id';
  static const String orderStatus = '/lite/orders/:id/status';
  static const String deliveryTracking = '/lite/delivery-tracking';
  static const String orderHistory = '/lite/order-history';
  static const String quickPrice = '/lite/management/quick-price';
  static const String stockAdjustment = '/lite/management/stock-adjustment';
  static const String employeeSchedule = '/lite/management/employee-schedule';
  static const String pendingApprovals = '/lite/management/pending-approvals';
  static const String liteProfile = '/lite/profile';
  static const String notificationPrefs = '/lite/settings/notification-prefs';
  static const String approvals = '/approvals';

  /// Helper to build order detail path
  static String orderDetailPath(String id) => '/lite/orders/$id';

  /// Helper to build order status path
  static String orderStatusPath(String id) => '/lite/orders/$id/status';
}

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
      try {
        s.close();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('_AuthNotifier.dispose: $e');
        }
        // Non-critical: subscription may already be closed
      }
    }
    super.dispose();
  }
}

/// Routes that require admin role (not just non-employee).
const _sensitiveRoutes = {AppRoutes.settings, LiteRoutes.approvals};

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
  if (storeId == null && path != AppRoutes.storeSelect && !isPublic) {
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

  // Sensitive routes require admin role specifically
  if (_sensitiveRoutes.contains(path) &&
      authState.status == AuthStatus.authenticated &&
      storeId != null &&
      role != null &&
      role != UserRole.superAdmin &&
      role != UserRole.storeOwner) {
    return AppRoutes.dashboard;
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
    debugLogDiagnostics: kDebugMode,
    refreshListenable: authNotifier,
    redirect: (context, state) => _guardRedirect(ref, state),
    routes: _routes,
    errorBuilder: _errorBuilder,
  );
});

Widget _errorBuilder(BuildContext context, GoRouterState state) {
  final l10n = AppLocalizations.of(context);
  return Scaffold(
    appBar: AppBar(title: Text(l10n.error)),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: AlhaiSpacing.md),
          Text('${l10n.error}: ${state.uri.path}'),
          const SizedBox(height: AlhaiSpacing.lg),
          FilledButton(
            onPressed: () => context.go(AppRoutes.dashboard),
            child: Text(l10n.home),
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
        path: LiteRoutes.approvals,
        name: 'approvals',
        builder: (context, state) => const ApprovalCenterScreen(),
      ),

      // ======================================================================
      // DASHBOARD: Sales Trend & Alerts Summary
      // ======================================================================
      GoRoute(
        path: LiteRoutes.salesTrend,
        name: 'lite-sales-trend',
        builder: (context, state) => const LiteSalesTrendScreen(),
      ),
      GoRoute(
        path: LiteRoutes.alertsSummary,
        name: 'lite-alerts-summary',
        builder: (context, state) => const LiteAlertsSummaryScreen(),
      ),

      // ======================================================================
      // QUICK REPORTS (6 screens)
      // ======================================================================
      GoRoute(
        path: LiteRoutes.dailySales,
        name: 'lite-daily-sales',
        builder: (context, state) => const LiteDailySalesScreen(),
      ),
      GoRoute(
        path: LiteRoutes.weeklyComparison,
        name: 'lite-weekly-comparison',
        builder: (context, state) => const LiteWeeklyComparisonScreen(),
      ),
      GoRoute(
        path: LiteRoutes.topProducts,
        name: 'lite-top-products',
        builder: (context, state) => const LiteTopProductsScreen(),
      ),
      GoRoute(
        path: LiteRoutes.lowStock,
        name: 'lite-low-stock',
        builder: (context, state) => const LiteLowStockScreen(),
      ),
      GoRoute(
        path: LiteRoutes.employeePerformance,
        name: 'lite-employee-performance',
        builder: (context, state) => const LiteEmployeePerformanceScreen(),
      ),
      GoRoute(
        path: LiteRoutes.cashFlow,
        name: 'lite-cash-flow',
        builder: (context, state) => const LiteCashFlowScreen(),
      ),

      // ======================================================================
      // ALERTS & NOTIFICATIONS (4 screens)
      // ======================================================================
      GoRoute(
        path: LiteRoutes.notificationsList,
        name: 'lite-notifications-list',
        builder: (context, state) => const LiteNotificationsListScreen(),
      ),
      GoRoute(
        path: LiteRoutes.stockAlerts,
        name: 'lite-stock-alerts',
        builder: (context, state) => const LiteStockAlertsScreen(),
      ),
      GoRoute(
        path: LiteRoutes.orderAlerts,
        name: 'lite-order-alerts',
        builder: (context, state) => const LiteOrderAlertsScreen(),
      ),
      GoRoute(
        path: LiteRoutes.systemAlerts,
        name: 'lite-system-alerts',
        builder: (context, state) => const LiteSystemAlertsScreen(),
      ),

      // ======================================================================
      // ORDER TRACKING (5 screens)
      // ======================================================================
      GoRoute(
        path: LiteRoutes.activeOrders,
        name: 'lite-active-orders',
        builder: (context, state) => const LiteActiveOrdersScreen(),
      ),
      GoRoute(
        path: LiteRoutes.orderDetail,
        name: 'lite-order-detail',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return CustomTransitionPage(
            child: LiteOrderDetailScreen(orderId: id),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
          );
        },
      ),
      GoRoute(
        path: LiteRoutes.orderStatus,
        name: 'lite-order-status',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return CustomTransitionPage(
            child: LiteOrderStatusScreen(orderId: id),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
          );
        },
      ),
      GoRoute(
        path: LiteRoutes.deliveryTracking,
        name: 'lite-delivery-tracking',
        builder: (context, state) => const LiteDeliveryTrackingScreen(),
      ),
      GoRoute(
        path: LiteRoutes.orderHistory,
        name: 'lite-order-history',
        builder: (context, state) => const LiteOrderHistoryScreen(),
      ),

      // ======================================================================
      // QUICK MANAGEMENT (4 screens)
      // ======================================================================
      GoRoute(
        path: LiteRoutes.quickPrice,
        name: 'lite-quick-price',
        builder: (context, state) => const LiteQuickPriceScreen(),
      ),
      GoRoute(
        path: LiteRoutes.stockAdjustment,
        name: 'lite-stock-adjustment',
        builder: (context, state) => const LiteStockAdjustmentScreen(),
      ),
      GoRoute(
        path: LiteRoutes.employeeSchedule,
        name: 'lite-employee-schedule',
        builder: (context, state) => const LiteEmployeeScheduleScreen(),
      ),
      GoRoute(
        path: LiteRoutes.pendingApprovals,
        name: 'lite-pending-approvals',
        builder: (context, state) => const LitePendingApprovalsScreen(),
      ),

      // ======================================================================
      // SETTINGS: Profile & Notification Preferences
      // ======================================================================
      GoRoute(
        path: LiteRoutes.liteProfile,
        name: 'lite-profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LiteProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: LiteRoutes.notificationPrefs,
        name: 'lite-notification-prefs',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LiteNotificationPrefsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),

      // ======================================================================
      // TAB 2: REPORTS (13 screens from alhai_reports)
      // ======================================================================
      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/reports/daily-sales',
        name: 'daily-sales-report',
        builder: (context, state) => const DailySalesReportScreen(),
      ),
      GoRoute(
        path: '/reports/profit',
        name: 'profit-report',
        builder: (context, state) => const ProfitReportScreen(),
      ),
      GoRoute(
        path: '/reports/tax',
        name: 'tax-report',
        builder: (context, state) => const TaxReportScreen(),
      ),
      GoRoute(
        path: '/reports/vat',
        name: 'vat-report',
        builder: (context, state) => const VatReportScreen(),
      ),
      GoRoute(
        path: '/reports/inventory',
        name: 'inventory-report',
        builder: (context, state) => const InventoryReportScreen(),
      ),
      GoRoute(
        path: '/reports/customers',
        name: 'customer-report',
        builder: (context, state) => const CustomerReportScreen(),
      ),
      GoRoute(
        path: '/reports/top-products',
        name: 'top-products-report',
        builder: (context, state) => const TopProductsReportScreen(),
      ),
      GoRoute(
        path: '/reports/sales-analytics',
        name: 'sales-analytics',
        builder: (context, state) => const SalesAnalyticsScreen(),
      ),
      GoRoute(
        path: '/reports/staff-performance',
        name: 'staff-performance',
        builder: (context, state) => const StaffPerformanceScreen(),
      ),
      GoRoute(
        path: '/reports/peak-hours',
        name: 'peak-hours-report',
        builder: (context, state) => const PeakHoursReportScreen(),
      ),
      GoRoute(
        path: '/reports/debts',
        name: 'debts-report',
        builder: (context, state) => const DebtsReportScreen(),
      ),
      GoRoute(
        path: AppRoutes.complaintsReport,
        name: 'complaints-report',
        builder: (context, state) => const ComplaintsReportScreen(),
      ),

      // ======================================================================
      // TAB 3: AI (15 screens from alhai_ai)
      // ======================================================================
      GoRoute(
        path: AppRoutes.aiAssistant,
        name: 'ai-assistant',
        builder: (context, state) => const AiAssistantScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiSalesForecasting,
        name: 'ai-sales-forecasting',
        builder: (context, state) => const AiSalesForecastingScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiSmartPricing,
        name: 'ai-smart-pricing',
        builder: (context, state) => const AiSmartPricingScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiFraudDetection,
        name: 'ai-fraud-detection',
        builder: (context, state) => const AiFraudDetectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiBasketAnalysis,
        name: 'ai-basket-analysis',
        builder: (context, state) => const AiBasketAnalysisScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiCustomerRecommendations,
        name: 'ai-customer-recommendations',
        builder: (context, state) => const AiCustomerRecommendationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiSmartInventory,
        name: 'ai-smart-inventory',
        builder: (context, state) => const AiSmartInventoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiCompetitorAnalysis,
        name: 'ai-competitor-analysis',
        builder: (context, state) => const AiCompetitorAnalysisScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiSmartReports,
        name: 'ai-smart-reports',
        builder: (context, state) => const AiSmartReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiStaffAnalytics,
        name: 'ai-staff-analytics',
        builder: (context, state) => const AiStaffAnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiProductRecognition,
        name: 'ai-product-recognition',
        builder: (context, state) => const AiProductRecognitionScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiSentimentAnalysis,
        name: 'ai-sentiment-analysis',
        builder: (context, state) => const AiSentimentAnalysisScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiReturnPrediction,
        name: 'ai-return-prediction',
        builder: (context, state) => const AiReturnPredictionScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiPromotionDesigner,
        name: 'ai-promotion-designer',
        builder: (context, state) => const AiPromotionDesignerScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiChatWithData,
        name: 'ai-chat-with-data',
        builder: (context, state) => const AiChatWithDataScreen(),
      ),

      // ======================================================================
      // TAB 4: MONITORING (inventory alerts, expiry tracking, shifts)
      // ======================================================================
      GoRoute(
        path: LiteRoutes.monitoring,
        name: 'monitoring',
        builder: (context, state) => const _MonitoringHubScreen(),
      ),
      GoRoute(
        path: LiteRoutes.inventoryAlerts,
        name: 'inventory-alerts',
        builder: (context, state) => const InventoryAlertsScreen(),
      ),
      GoRoute(
        path: AppRoutes.inventory,
        name: 'inventory',
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.expiryTracking,
        name: 'expiry-tracking',
        builder: (context, state) => const ExpiryTrackingScreen(),
      ),
      GoRoute(
        path: AppRoutes.shifts,
        name: 'shifts',
        builder: (context, state) => const ShiftsScreen(),
      ),
      GoRoute(
        path: AppRoutes.shiftSummary,
        name: 'shift-summary',
        builder: (context, state) => const ShiftSummaryScreen(),
      ),
      GoRoute(
        path: AppRoutes.products,
        name: 'products',
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        path: AppRoutes.productDetail,
        name: 'product-detail',
        builder: (context, state) {
          final id = state.pathId();
          return ProductDetailScreen(productId: id);
        },
      ),

      // ======================================================================
      // TAB 5: MORE (customers, suppliers, orders, expenses, profile, settings)
      // ======================================================================
      GoRoute(
        path: LiteRoutes.more,
        name: 'more',
        builder: (context, state) => const _MoreMenuScreen(),
      ),
      GoRoute(
        path: AppRoutes.customers,
        name: 'customers',
        builder: (context, state) => const CustomersScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerDetail,
        name: 'customer-detail',
        builder: (context, state) {
          final id = state.pathId();
          return CustomerDetailScreen(customerId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.suppliers,
        name: 'suppliers',
        builder: (context, state) => const SuppliersScreen(),
      ),
      GoRoute(
        path: AppRoutes.supplierDetail,
        name: 'supplier-detail',
        builder: (context, state) {
          final id = state.pathId();
          return SupplierDetailScreen(supplierId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.orders,
        name: 'orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: AppRoutes.invoices,
        name: 'invoices',
        builder: (context, state) => const InvoicesScreen(),
      ),
      GoRoute(
        path: AppRoutes.invoiceDetail,
        name: 'invoice-detail',
        builder: (context, state) {
          final id = state.pathId();
          return InvoiceDetailScreen(invoiceId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.expenses,
        name: 'expenses',
        builder: (context, state) => const ExpensesScreen(),
      ),
      GoRoute(
        path: AppRoutes.expenseCategories,
        name: 'expense-categories',
        builder: (context, state) => const ExpenseCategoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const LiteSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsLanguage,
        name: 'settings-language',
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsTheme,
        name: 'settings-theme',
        builder: (context, state) => const ThemeScreen(),
      ),
      GoRoute(
        path: AppRoutes.syncStatus,
        name: 'sync-status',
        builder: (context, state) => const SyncStatusScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationsCenter,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.systemMonitoring)),
      body: ListView(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        children: [
          _MonitoringTile(
            icon: Icons.warning_amber_rounded,
            title: l10n.inventoryAlerts,
            subtitle: l10n.lowStockNotifications,
            onTap: () => context.go(LiteRoutes.inventoryAlerts),
          ),
          _MonitoringTile(
            icon: Icons.inventory_2_outlined,
            title: l10n.inventory,
            subtitle: l10n.inventoryManagement,
            onTap: () => context.go(AppRoutes.inventory),
          ),
          _MonitoringTile(
            icon: Icons.calendar_today,
            title: l10n.expiryTracking,
            subtitle: l10n.expiryNotifications,
            onTap: () => context.go(AppRoutes.expiryTracking),
          ),
          _MonitoringTile(
            icon: Icons.schedule,
            title: l10n.shiftsTitle,
            subtitle: l10n.shiftOpenCloseReminders,
            onTap: () => context.go(AppRoutes.shifts),
          ),
          _MonitoringTile(
            icon: Icons.category_outlined,
            title: l10n.products,
            subtitle: l10n.productCatalog,
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.more)),
      body: ListView(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        children: [
          _MonitoringTile(
            icon: Icons.people_outline,
            title: l10n.customers,
            subtitle: l10n.customers,
            onTap: () => context.go(AppRoutes.customers),
          ),
          _MonitoringTile(
            icon: Icons.local_shipping_outlined,
            title: l10n.suppliers,
            subtitle: l10n.suppliers,
            onTap: () => context.go(AppRoutes.suppliers),
          ),
          _MonitoringTile(
            icon: Icons.receipt_long_outlined,
            title: l10n.orders,
            subtitle: l10n.orderHistory,
            onTap: () => context.go(AppRoutes.orders),
          ),
          _MonitoringTile(
            icon: Icons.description_outlined,
            title: l10n.invoices,
            subtitle: l10n.invoices,
            onTap: () => context.go(AppRoutes.invoices),
          ),
          _MonitoringTile(
            icon: Icons.account_balance_wallet_outlined,
            title: l10n.expenses,
            subtitle: l10n.expenses,
            onTap: () => context.go(AppRoutes.expenses),
          ),
          const Divider(height: AlhaiSpacing.xl),
          _MonitoringTile(
            icon: Icons.person_outline,
            title: l10n.profileTitle,
            subtitle: l10n.profileTitle,
            onTap: () => context.go(AppRoutes.profile),
          ),
          _MonitoringTile(
            icon: Icons.settings_outlined,
            title: l10n.settings,
            subtitle: l10n.settings,
            onTap: () => context.go(AppRoutes.settings),
          ),
          _MonitoringTile(
            icon: Icons.sync,
            title: l10n.syncStatusTitle,
            subtitle: l10n.dataSynchronizationStatus,
            onTap: () => context.go(AppRoutes.syncStatus),
          ),
          _MonitoringTile(
            icon: Icons.notifications_outlined,
            title: l10n.notifications,
            subtitle: l10n.notifications,
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
        trailing: Icon(
          Directionality.of(context) == TextDirection.rtl
              ? Icons.chevron_left
              : Icons.chevron_right,
        ),
        onTap: onTap,
      ),
    );
  }
}
