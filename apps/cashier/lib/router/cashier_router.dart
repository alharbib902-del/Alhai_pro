/// Cashier App Router Configuration
///
/// Simplified router for the Cashier app.
/// Only includes routes relevant to cashier operations:
/// - Auth (splash, login, store-select)
/// - POS (main, payment, receipt, quick sale, favorites, hold, barcode, cash drawer)
/// - Returns
/// - Customers
/// - Shifts (with cashier-specific open/close)
/// - Profile & Notifications
library;

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_pos/alhai_pos.dart';
import 'package:alhai_reports/alhai_reports.dart';
import '../ui/cashier_shell.dart';
import '../screens/purchases/cashier_receiving_screen.dart';
import '../screens/purchases/cashier_purchase_request_screen.dart';
import '../screens/shifts/shift_open_screen.dart';
import '../screens/shifts/shift_close_screen.dart';
import '../screens/shifts/daily_summary_screen.dart';
import '../screens/shifts/cash_in_out_screen.dart';
import '../screens/customers/customer_ledger_screen.dart';
import '../screens/sales/sales_history_screen.dart';
import '../screens/sales/reprint_receipt_screen.dart';
import '../screens/sales/sale_detail_screen.dart';
import '../screens/sales/exchange_screen.dart';
import '../screens/payment/split_receipt_screen.dart';
import '../screens/payment/payment_history_screen.dart';
import '../screens/payment/split_refund_screen.dart';
import '../screens/customers/customer_accounts_screen.dart';
import '../screens/customers/new_transaction_screen.dart';
import '../screens/customers/apply_interest_screen.dart';
import '../screens/customers/create_invoice_screen.dart';
import '../screens/settings/cashier_settings_screen.dart';
import '../screens/settings/store_info_screen.dart';
import '../screens/settings/tax_settings_screen.dart';
import '../screens/settings/receipt_settings_screen.dart';
import '../screens/settings/payment_devices_screen.dart';
import '../screens/settings/add_payment_device_screen.dart';
import '../screens/settings/printer_settings_screen.dart';
import '../screens/settings/keyboard_shortcuts_screen.dart';
import '../screens/settings/users_permissions_screen.dart';
import '../screens/settings/backup_screen.dart';
import '../screens/products/quick_add_product_screen.dart';
import '../screens/products/edit_price_screen.dart';
import '../screens/products/print_barcode_screen.dart';
import '../screens/products/cashier_categories_screen.dart';
import '../screens/products/price_labels_screen.dart';
import '../screens/inventory/edit_inventory_screen.dart';
import '../screens/inventory/add_inventory_screen.dart';
import '../screens/inventory/remove_inventory_screen.dart';
import '../screens/inventory/transfer_inventory_screen.dart';
import '../screens/inventory/stock_take_screen.dart';
import '../screens/inventory/wastage_screen.dart';
import '../screens/offers/active_offers_screen.dart';
import '../screens/offers/coupon_code_screen.dart';
import '../screens/offers/bundle_deals_screen.dart';
import '../screens/reports/payment_reports_screen.dart';
import '../screens/reports/custom_report_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';

/// Route parameter extraction helper
extension GoRouterStateX on GoRouterState {
  /// Extract path parameter by key (defaults to 'id')
  String pathId([String key = 'id']) => pathParameters[key] ?? '';

  /// Extract query parameter by key
  String queryParam(String key) => uri.queryParameters[key] ?? '';
}

/// Fade transition for smooth screen transitions
Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: AlhaiMotion.standard,
    ),
    child: child,
  );
}

/// Notifier that triggers GoRouter redirect on auth/store changes.
///
/// NOTE [M144]: This pattern (_AuthNotifier + _guardRedirect) is duplicated
/// across cashier_router, admin_router, and lite_router. Each variant has
/// app-specific redirect logic (different home routes, role checks), so
/// extracting to a shared helper is not straightforward without a config
/// abstraction. If routers converge further, consider extracting to
/// alhai_auth as a configurable factory.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(Ref ref) {
    _subs = [
      ref.listen(authStateProvider, (_, __) => notifyListeners()),
      ref.listen(currentStoreIdProvider, (_, __) => notifyListeners()),
      ref.listen(onboardingSeenProvider, (_, __) => notifyListeners()),
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
  final onboardingSeen = ref.read(onboardingSeenProvider);
  final path = state.uri.path;

  const publicPaths = [AppRoutes.splash, AppRoutes.login, AppRoutes.onboarding];
  final isPublic = publicPaths.contains(path);

  // Still resolving → stay on current page
  if (authState.status == AuthStatus.unknown) return null;

  // ── Onboarding guard (M57 fix) ──────────────────────────────────
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

  // Already logged in & has store, trying to access login/splash/onboarding
  if (isPublic &&
      authState.status == AuthStatus.authenticated &&
      storeId != null) {
    return AppRoutes.pos;
  }

  return null;
}

/// Cashier Router Provider (with auth redirect)
final cashierRouterProvider = Provider<GoRouter>((ref) {
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
  return Scaffold(
    appBar: AppBar(title: const Text('خطأ')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('الصفحة غير موجودة: ${state.uri.path}'),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => GoRouter.of(context).go(AppRoutes.pos),
            child: const Text('نقطة البيع'),
          ),
        ],
      ),
    ),
  );
}

final List<RouteBase> _routes = [
  // ============================================================================
  // AUTH ROUTES (outside ShellRoute - no sidebar)
  // ============================================================================
  GoRoute(
    path: AppRoutes.splash,
    name: 'splash',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: const SplashScreen(),
      transitionsBuilder: _fadeTransition,
    ),
  ),
  GoRoute(
    path: AppRoutes.login,
    name: 'login',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: const LoginScreen(),
      transitionsBuilder: _fadeTransition,
    ),
  ),
  GoRoute(
    path: AppRoutes.storeSelect,
    name: 'store-select',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: const StoreSelectScreen(),
      transitionsBuilder: _fadeTransition,
    ),
  ),

  // ============================================================================
  // ONBOARDING (outside ShellRoute - no sidebar) [M57]
  // ============================================================================
  GoRoute(
    path: AppRoutes.onboarding,
    name: 'onboarding',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: const OnboardingScreen(),
      transitionsBuilder: _fadeTransition,
    ),
  ),

  // ============================================================================
  // POS OVERLAY SCREENS (outside ShellRoute - no sidebar)
  // ============================================================================
  GoRoute(
    path: AppRoutes.posPayment,
    name: 'pos-payment',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: const PaymentScreen(),
      transitionsBuilder: _fadeTransition,
    ),
  ),
  GoRoute(
    path: AppRoutes.posReceipt,
    name: 'pos-receipt',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: const ReceiptScreen(),
      transitionsBuilder: _fadeTransition,
    ),
  ),
  GoRoute(
    path: AppRoutes.managerApproval,
    name: 'manager-approval',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: const ManagerApprovalScreen(),
      transitionsBuilder: _fadeTransition,
    ),
  ),

  // ============================================================================
  // CASHIER SHELL ROUTE - sidebar/drawer navigation
  // ============================================================================
  ShellRoute(
    builder: (context, state, child) => CashierShell(child: child),
    routes: [
      // ==================================================================
      // POS MAIN SCREEN
      // ==================================================================
      GoRoute(
        path: AppRoutes.pos,
        name: 'pos',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PosScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.quickSale,
        name: 'quick-sale',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const QuickSaleScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: '/pos/favorites',
        name: 'pos-favorites',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const FavoritesScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: '/pos/hold-invoices',
        name: 'pos-hold-invoices',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HoldInvoicesScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: '/pos/barcode-scanner',
        name: 'pos-barcode-scanner',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const BarcodeScannerScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.cashDrawer,
        name: 'cash-drawer',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CashDrawerScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // PURCHASES ROUTES (cashier)
      // ==================================================================
      GoRoute(
        path: AppRoutes.cashierReceiving,
        name: 'cashier-receiving',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const CashierReceivingScreen(),
            loadingWidget: const SuppliersLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.cashierPurchaseRequest,
        name: 'purchase-request',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const CashierPurchaseRequestScreen(),
            loadingWidget: const SuppliersLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // RETURNS ROUTES
      // ==================================================================
      GoRoute(
        path: AppRoutes.returns,
        name: 'returns',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ReturnsScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.refundRequest,
        name: 'refund-request',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: RefundRequestScreen(
            orderId: state.queryParam('orderId').isEmpty
                ? null
                : state.queryParam('orderId'),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.refundReason,
        name: 'refund-reason',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RefundReasonScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.refundReceipt,
        name: 'refund-receipt',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return CustomTransitionPage(
            key: state.pageKey,
            child: RefundReceiptScreen(refundId: id),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),

      // ==================================================================
      // CUSTOMERS ROUTES
      // ==================================================================
      GoRoute(
        path: AppRoutes.customers,
        name: 'customers',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CustomersScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.customerDetail,
        name: 'customer-detail',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return CustomTransitionPage(
            key: state.pageKey,
            child: CustomerDetailScreen(customerId: id),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.customerLedger,
        name: 'customer-ledger',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return CustomTransitionPage(
            key: state.pageKey,
            child: CustomerLedgerScreen(id: id),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),

      // ==================================================================
      // SHIFTS ROUTES
      // ==================================================================
      GoRoute(
        path: AppRoutes.shifts,
        name: 'shifts',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ShiftsScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.shiftOpen,
        name: 'shift-open',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ShiftOpenScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.shiftClose,
        name: 'shift-close',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ShiftCloseScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.shiftSummary,
        name: 'shift-summary',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ShiftSummaryScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // SALES ROUTES
      // ==================================================================
      GoRoute(
        path: AppRoutes.sales,
        name: 'sales-history',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const SalesHistoryScreen(),
            loadingWidget: const ReportsLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: '/sales/reprint',
        name: 'reprint-receipt',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const ReprintReceiptScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // DAILY SUMMARY & CASH IN/OUT ROUTES
      // ==================================================================
      GoRoute(
        path: '/shifts/daily-summary',
        name: 'daily-summary',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const DailySummaryScreen(),
            loadingWidget: const ReportsLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: '/shifts/cash-in-out',
        name: 'cash-in-out',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const CashInOutScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // DASHBOARD
      // ==================================================================
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DashboardScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // PRODUCTS ROUTES
      // ==================================================================
      GoRoute(
        path: AppRoutes.products,
        name: 'products',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProductsScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.productDetail,
        name: 'product-detail',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProductDetailScreen(productId: id),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),

      // ==================================================================
      // INVENTORY ROUTES
      // ==================================================================
      GoRoute(
        path: AppRoutes.inventory,
        name: 'inventory',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const InventoryScreen(),
            loadingWidget: const InventoryLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.inventoryAlerts,
        name: 'inventory-alerts',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const InventoryAlertsScreen(),
            loadingWidget: const InventoryLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.expiryTracking,
        name: 'expiry-tracking',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const ExpiryTrackingScreen(),
            loadingWidget: const InventoryLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // INVOICES ROUTES
      // ==================================================================
      GoRoute(
        path: AppRoutes.invoices,
        name: 'invoices',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const InvoicesScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.invoiceDetail,
        name: 'invoice-detail',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return CustomTransitionPage(
            key: state.pageKey,
            child: InvoiceDetailScreen(invoiceId: id),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),

      // ==================================================================
      // VOID TRANSACTION
      // ==================================================================
      GoRoute(
        path: AppRoutes.voidTransaction,
        name: 'void-transaction',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const VoidTransactionScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // CUSTOMER DEBT
      // ==================================================================
      GoRoute(
        path: AppRoutes.customerDebt,
        name: 'customer-debt',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const CustomerDebtScreen(),
            loadingWidget: const CustomersLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // ORDER TRACKING & HISTORY
      // ==================================================================
      GoRoute(
        path: AppRoutes.orderTracking,
        name: 'order-tracking',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const OrderTrackingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.orderHistory,
        name: 'order-history',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const OrderHistoryScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // CUSTOMER ANALYTICS
      // ==================================================================
      GoRoute(
        path: AppRoutes.customerAnalytics,
        name: 'customer-analytics',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const CustomerAnalyticsScreen(),
            loadingWidget: const CustomersLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // REPORTS ROUTES
      // ==================================================================
      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const ReportsScreen(),
            loadingWidget: const ReportsLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.dailySalesReport,
        name: 'daily-sales-report',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const DailySalesReportScreen(),
            loadingWidget: const ReportsLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.topProductsReport,
        name: 'top-products-report',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const TopProductsReportScreen(),
            loadingWidget: const ReportsLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.cashFlowReport,
        name: 'cash-flow-report',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const CashFlowScreen(),
            loadingWidget: const ReportsLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.customerReport,
        name: 'customer-report',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const CustomerReportScreen(),
            loadingWidget: const ReportsLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.inventoryReport,
        name: 'inventory-report',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const InventoryReportScreen(),
            loadingWidget: const ReportsLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // SYNC STATUS
      // ==================================================================
      GoRoute(
        path: AppRoutes.syncStatus,
        name: 'sync-status',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const SyncStatusScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // SETTINGS ROUTES
      // ==================================================================
      GoRoute(
        path: AppRoutes.settingsLanguage,
        name: 'language',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const LanguageScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsTheme,
        name: 'theme',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const ThemeScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // SALE DETAIL & EXCHANGE
      // ==================================================================
      GoRoute(
        path: AppRoutes.saleDetail,
        name: 'sale-detail',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return CustomTransitionPage(
            key: state.pageKey,
            child: LazyScreen(
              screenBuilder: () async => SaleDetailScreen(saleId: id),
              loadingWidget: const ReportsLoadingScreen(),
            ),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.exchange,
        name: 'exchange',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const ExchangeScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // PAYMENT SCREENS
      // ==================================================================
      GoRoute(
        path: AppRoutes.splitReceipt,
        name: 'split-receipt',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return CustomTransitionPage(
            key: state.pageKey,
            child: LazyScreen(
              screenBuilder: () async => SplitReceiptScreen(orderId: id),
            ),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.paymentHistory,
        name: 'payment-history',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const PaymentHistoryScreen(),
            loadingWidget: const ReportsLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.splitRefund,
        name: 'split-refund',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return CustomTransitionPage(
            key: state.pageKey,
            child: LazyScreen(
              screenBuilder: () async => SplitRefundScreen(orderId: id),
            ),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),

      // ==================================================================
      // CUSTOMER ACCOUNTS
      // ==================================================================
      GoRoute(
        path: AppRoutes.customerAccounts,
        name: 'customer-accounts',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const CustomerAccountsScreen(),
            loadingWidget: const CustomersLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.newTransaction,
        name: 'new-transaction',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => NewTransactionScreen(
              customerId: state.queryParam('customerId').isEmpty
                  ? null
                  : state.queryParam('customerId'),
            ),
            loadingWidget: const CustomersLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.applyInterest,
        name: 'apply-interest',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const ApplyInterestScreen(),
            loadingWidget: const CustomersLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.createInvoice,
        name: 'create-invoice',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const CreateInvoiceScreen(),
            loadingWidget: const CustomersLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // SETTINGS SCREENS
      // ==================================================================
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const CashierSettingsScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsStore,
        name: 'store-info',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const StoreInfoScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsTax,
        name: 'tax-settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const TaxSettingsScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsReceipt,
        name: 'receipt-settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const ReceiptSettingsScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsPaymentDevices,
        name: 'payment-devices',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const PaymentDevicesScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.addPaymentDevice,
        name: 'add-payment-device',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const AddPaymentDeviceScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsPrinter,
        name: 'printer-settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const PrinterSettingsScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsKeyboardShortcuts,
        name: 'keyboard-shortcuts',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const KeyboardShortcutsScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsUsers,
        name: 'users-permissions',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const UsersPermissionsScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsBackup,
        name: 'backup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const BackupScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // PRODUCT SCREENS
      // ==================================================================
      GoRoute(
        path: AppRoutes.quickAddProduct,
        name: 'quick-add-product',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const QuickAddProductScreen(),
            loadingWidget: const ProductsLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.editPrice,
        name: 'edit-price',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return CustomTransitionPage(
            key: state.pageKey,
            child: LazyScreen(
              screenBuilder: () async => EditPriceScreen(productId: id),
              loadingWidget: const ProductsLoadingScreen(),
            ),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.printBarcode,
        name: 'print-barcode',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const PrintBarcodeScreen(),
            loadingWidget: const ProductsLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.cashierCategories,
        name: 'cashier-categories',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const CashierCategoriesScreen(),
            loadingWidget: const ProductsLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.priceLabels,
        name: 'price-labels',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const PriceLabelsScreen(),
            loadingWidget: const ProductsLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // INVENTORY OPERATION SCREENS
      // ==================================================================
      GoRoute(
        path: AppRoutes.editInventory,
        name: 'edit-inventory',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return CustomTransitionPage(
            key: state.pageKey,
            child: LazyScreen(
              screenBuilder: () async => EditInventoryScreen(productId: id),
              loadingWidget: const InventoryLoadingScreen(),
            ),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.addInventory,
        name: 'add-inventory',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const AddInventoryScreen(),
            loadingWidget: const InventoryLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.removeInventory,
        name: 'remove-inventory',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const RemoveInventoryScreen(),
            loadingWidget: const InventoryLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.transferInventory,
        name: 'transfer-inventory',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const TransferInventoryScreen(),
            loadingWidget: const InventoryLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.stockTake,
        name: 'stock-take',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const StockTakeScreen(),
            loadingWidget: const InventoryLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.wastage,
        name: 'wastage',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const WastageScreen(),
            loadingWidget: const InventoryLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // OFFERS SCREENS
      // ==================================================================
      GoRoute(
        path: AppRoutes.activeOffers,
        name: 'active-offers',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const ActiveOffersScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.couponCode,
        name: 'coupon-code',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const CouponCodeScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.bundleDeals,
        name: 'bundle-deals',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const BundleDealsScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // ADDITIONAL REPORT SCREENS
      // ==================================================================
      GoRoute(
        path: AppRoutes.paymentReports,
        name: 'payment-reports',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const PaymentReportsScreen(),
            loadingWidget: const ReportsLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.customReport,
        name: 'custom-report',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const CustomReportScreen(),
            loadingWidget: const ReportsLoadingScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ==================================================================
      // COMMON ROUTES (Notifications, Profile)
      // ==================================================================
      GoRoute(
        path: AppRoutes.notificationsCenter,
        name: 'notifications',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const NotificationsScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(
            screenBuilder: () async => const ProfileScreen(),
          ),
          transitionsBuilder: _fadeTransition,
        ),
      ),
    ],
  ),
];
