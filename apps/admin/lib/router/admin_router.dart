/// Admin Router Configuration
///
/// Central routing configuration for the Admin Dashboard app.
/// Contains ALL 123 screen routes for full management system.
/// Uses GoRouter with ShellRoute for persistent sidebar layout.
///
/// Architecture:
/// - Auth routes (splash, login, storeSelect) are top-level (no sidebar)
/// - POS overlay screens (payment, receipt) are top-level (no sidebar)
/// - All other routes are wrapped in a ShellRoute with DashboardShell
///   providing a persistent sidebar that doesn't rebuild on navigation
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart' show UserRole;
import 'package:alhai_design_system/alhai_design_system.dart';

// Package imports: Auth
import 'package:alhai_auth/alhai_auth.dart' show SplashScreen, LoginScreen, StoreSelectScreen, authStateProvider, AuthStatus, currentStoreIdProvider, userRoleProvider;

// Package imports: POS
import 'package:alhai_pos/alhai_pos.dart'
    show
        PosScreen,
        PaymentScreen,
        ReceiptScreen,
        QuickSaleScreen,
        ReturnsScreen,
        RefundRequestScreen,
        RefundReasonScreen,
        RefundReceiptScreen,
        VoidTransactionScreen,
        CashDrawerScreen,
        KioskScreen;

// Package imports: AI
import 'package:alhai_ai/alhai_ai.dart'
    show
        AiAssistantScreen,
        AiSalesForecastingScreen,
        AiSmartPricingScreen,
        AiFraudDetectionScreen,
        AiBasketAnalysisScreen,
        AiCustomerRecommendationsScreen,
        AiSmartInventoryScreen,
        AiCompetitorAnalysisScreen,
        AiSmartReportsScreen,
        AiStaffAnalyticsScreen,
        AiProductRecognitionScreen,
        AiSentimentAnalysisScreen,
        AiReturnPredictionScreen,
        AiPromotionDesignerScreen,
        AiChatWithDataScreen,
        AiInvoiceResult;

// Package imports: Reports
import 'package:alhai_reports/alhai_reports.dart'
    show
        ReportsScreen,
        ComplaintsReportScreen;

// Package imports: Shared UI
import 'package:alhai_shared_ui/alhai_shared_ui.dart'
    show
        AppRoutes,
        DashboardScreen,
        CustomersScreen,
        CustomerDetailScreen,
        CustomerAnalyticsScreen,
        ProductsScreen,
        ProductDetailScreen,
        InventoryScreen,
        ExpiryTrackingScreen,
        SuppliersScreen,
        SupplierDetailScreen,
        OrdersScreen,
        OrderTrackingScreen,
        OrderHistoryScreen,
        ExpensesScreen,
        ExpenseCategoriesScreen,
        ShiftsScreen,
        ShiftSummaryScreen,
        InvoicesScreen,
        InvoiceDetailScreen,
        NotificationsScreen,
        LanguageScreen,
        ThemeScreen,
        SyncStatusScreen,
        ProfileScreen,
        LazyScreen;

// Local screens
import '../screens/home_screen.dart';
import '../ui/dashboard_shell.dart';

// Marketing screens (admin-only)
import '../screens/marketing/discounts_screen.dart';
import '../screens/marketing/coupon_management_screen.dart';
import '../screens/marketing/special_offers_screen.dart';
import '../screens/marketing/smart_promotions_screen.dart';

// Purchases screens (admin-only)
import '../screens/purchases/purchase_form_screen.dart';
import '../screens/purchases/smart_reorder_screen.dart';
import '../screens/purchases/ai_invoice_import_screen.dart';
import '../screens/purchases/ai_invoice_review_screen.dart';
import '../screens/purchases/purchases_list_screen.dart';
import '../screens/purchases/purchase_detail_screen.dart';
import '../screens/purchases/receiving_goods_screen.dart';
import '../screens/purchases/send_to_distributor_screen.dart';

// Management screens (admin-only)
import '../screens/management/driver_management_screen.dart';
import '../screens/management/branch_management_screen.dart';
import '../screens/debts/monthly_close_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';

// Settings screens (admin-only)
import '../screens/settings/settings_screen.dart';
import '../screens/settings/store_settings_screen.dart';
import '../screens/settings/printer_settings_screen.dart';
import '../screens/settings/payment_devices_settings_screen.dart';
import '../screens/settings/pos_settings_screen.dart';
import '../screens/settings/barcode_settings_screen.dart';
import '../screens/settings/receipt_template_screen.dart';
import '../screens/settings/tax_settings_screen.dart';
import '../screens/settings/discounts_settings_screen.dart';
import '../screens/settings/interest_settings_screen.dart';
import '../screens/settings/security_settings_screen.dart';
import '../screens/settings/users_management_screen.dart';
import '../screens/settings/roles_permissions_screen.dart';
import '../screens/settings/activity_log_screen.dart';
import '../screens/settings/backup_settings_screen.dart';
import '../screens/settings/notifications_settings_screen.dart';
import '../screens/settings/zatca_compliance_screen.dart';
import '../screens/settings/help_support_screen.dart';
import '../screens/settings/shipping_gateways_screen.dart';

// Shifts screens (admin-only)
import '../screens/shifts/shift_open_screen.dart';
import '../screens/shifts/shift_close_screen.dart';

// Printing screens (admin-only)
import '../screens/printing/print_queue_screen.dart';

// Screens created by other agents (referenced by class name)
import '../screens/products/product_form_screen.dart';
import '../screens/products/categories_screen.dart';
import '../screens/suppliers/supplier_form_screen.dart';
import '../screens/customers/customer_ledger_screen.dart';
import '../screens/loyalty/loyalty_program_screen.dart';
import '../screens/sync/pending_transactions_screen.dart';
import '../screens/sync/conflict_resolution_screen.dart';
import '../screens/ecommerce/ecommerce_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/subscription/subscription_screen.dart';
import '../screens/media/media_library_screen.dart';
import '../screens/devices/device_log_screen.dart';
// New screens
import '../screens/purchases/supplier_return_screen.dart';
import '../screens/marketing/gift_cards_screen.dart';
import '../screens/employees/attendance_screen.dart';
import '../screens/employees/commission_screen.dart';
import '../screens/ecommerce/online_orders_screen.dart';
import '../screens/inventory/damaged_goods_screen.dart';
import '../screens/products/price_lists_screen.dart';
import '../screens/customers/customer_groups_screen.dart';
import '../screens/ecommerce/delivery_zones_screen.dart';
import '../screens/employees/employee_profile_screen.dart';
import '../screens/settings/whatsapp_management_screen.dart';

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
/// across admin_router, cashier_router, and lite_router. Each variant has
/// app-specific redirect logic (role checks, different home routes), so
/// extracting to a shared helper is not straightforward. If routers converge
/// further, consider extracting to alhai_auth as a configurable factory.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(Ref ref) {
    _subs = [
      ref.listen(authStateProvider, (_, __) => notifyListeners()),
      ref.listen(currentStoreIdProvider, (_, __) => notifyListeners()),
      ref.listen(adminOnboardingSeenProvider, (_, __) => notifyListeners()),
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
  final onboardingSeen = ref.read(adminOnboardingSeenProvider);
  final path = state.uri.path;

  const publicPaths = [AppRoutes.splash, AppRoutes.login, AppRoutes.onboarding];
  final isPublic = publicPaths.contains(path);

  // Still resolving → stay on current page
  if (authState.status == AuthStatus.unknown) return null;

  // ── Onboarding guard (M56) ──────────────────────────────────
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

  // Only admins can use admin app
  final role = ref.read(userRoleProvider);
  if (authState.status == AuthStatus.authenticated &&
      storeId != null &&
      !isPublic &&
      role != null &&
      role == UserRole.employee) {
    return AppRoutes.login;
  }

  // Already logged in & has store, trying to access login/splash
  if (isPublic &&
      authState.status == AuthStatus.authenticated &&
      storeId != null) {
    return AppRoutes.dashboard;
  }

  return null;
}

/// Admin Router Provider (with auth redirect)
final adminRouterProvider = Provider<GoRouter>((ref) {
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
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('الرئيسية'),
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
  // ONBOARDING (outside ShellRoute - no sidebar)
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

  // ============================================================================
  // SHELL ROUTE - All sidebar screens wrapped in AdminDashboardShell
  // ============================================================================
  ShellRoute(
    builder: (context, state, child) => AdminDashboardShell(child: child),
    routes: [
      // ====================================================================
      // MAIN ROUTES
      // ====================================================================
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AdminHomeScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DashboardScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // POS ROUTES (from alhai_pos package)
      // ====================================================================
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
        path: AppRoutes.posSearch,
        name: 'pos-search',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PosScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.posCart,
        name: 'pos-cart',
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

      // ====================================================================
      // PRODUCTS ROUTES (from alhai_shared_ui)
      // ====================================================================
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
        path: AppRoutes.productsAdd,
        name: 'products-add',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProductFormScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.productsEdit,
        name: 'products-edit',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: ProductFormScreen(productId: state.pathId()),
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

      // ====================================================================
      // CATEGORIES ROUTE
      // ====================================================================
      GoRoute(
        path: AppRoutes.categories,
        name: 'categories',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const CategoriesScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // INVENTORY ROUTES (from alhai_shared_ui)
      // ====================================================================
      GoRoute(
        path: AppRoutes.inventory,
        name: 'inventory',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const InventoryScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.expiryTracking,
        name: 'expiry-tracking',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const ExpiryTrackingScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // CUSTOMERS ROUTES (from alhai_shared_ui)
      // ====================================================================
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
            child: LazyScreen(screenBuilder: () async => CustomerLedgerScreen(customerId: id)),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),

      // ====================================================================
      // SUPPLIERS ROUTES (from alhai_shared_ui)
      // ====================================================================
      GoRoute(
        path: AppRoutes.suppliers,
        name: 'suppliers',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SuppliersScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.supplierForm,
        name: 'supplier-form',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const SupplierFormScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.supplierDetail,
        name: 'supplier-detail',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return CustomTransitionPage(
            key: state.pageKey,
            child: SupplierDetailScreen(supplierId: id),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),

      // ====================================================================
      // ORDERS ROUTES (from alhai_shared_ui)
      // ====================================================================
      GoRoute(
        path: AppRoutes.orders,
        name: 'orders',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OrdersScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.orderTracking,
        name: 'order-tracking',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const OrderTrackingScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.orderHistory,
        name: 'order-history',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const OrderHistoryScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // CUSTOMER ANALYTICS ROUTE (from alhai_shared_ui)
      // ====================================================================
      GoRoute(
        path: AppRoutes.customerAnalytics,
        name: 'customer-analytics',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const CustomerAnalyticsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // SALES ROUTE (alias for invoices)
      // ====================================================================
      GoRoute(
        path: AppRoutes.sales,
        name: 'sales',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const InvoicesScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // INVOICES ROUTES (from alhai_shared_ui)
      // ====================================================================
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

      // ====================================================================
      // RETURNS ROUTES (from alhai_pos package)
      // ====================================================================
      GoRoute(
        path: AppRoutes.returns,
        name: 'returns',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const ReturnsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.refundRequest,
        name: 'refund-request',
        pageBuilder: (context, state) {
          final orderId = state.queryParam('orderId');
          return CustomTransitionPage(
            key: state.pageKey,
            child: LazyScreen(screenBuilder: () async => RefundRequestScreen(
                orderId: orderId.isEmpty ? null : orderId)),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.refundReason,
        name: 'refund-reason',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const RefundReasonScreen()),
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
            child: LazyScreen(screenBuilder: () async => RefundReceiptScreen(refundId: id)),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.voidTransaction,
        name: 'void-transaction',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const VoidTransactionScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // EXPENSES ROUTES (from alhai_shared_ui)
      // ====================================================================
      GoRoute(
        path: AppRoutes.expenses,
        name: 'expenses',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ExpensesScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.expenseCategories,
        name: 'expense-categories',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const ExpenseCategoriesScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // CASH DRAWER ROUTE (from alhai_pos)
      // ====================================================================
      GoRoute(
        path: AppRoutes.cashDrawer,
        name: 'cash-drawer',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const CashDrawerScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // DEBTS ROUTES
      // ====================================================================
      GoRoute(
        path: AppRoutes.monthlyClose,
        name: 'monthly-close',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const MonthlyCloseScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // SHIFTS ROUTES (from alhai_shared_ui)
      // ====================================================================
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
          child: LazyScreen(screenBuilder: () async => const ShiftOpenScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.shiftClose,
        name: 'shift-close',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const ShiftCloseScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.shiftSummary,
        name: 'shift-summary',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const ShiftSummaryScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // PURCHASES ROUTES (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.purchaseForm,
        name: 'purchase-form',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const PurchaseFormScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.smartReorder,
        name: 'smart-reorder',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const SmartReorderScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.aiInvoiceImport,
        name: 'ai-invoice-import',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const AiInvoiceImportScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.aiInvoiceReview,
        name: 'ai-invoice-review',
        pageBuilder: (context, state) {
          final invoiceData = state.extra as AiInvoiceResult?;
          final child = invoiceData == null
              ? Scaffold(
                  appBar: AppBar(title: const Text('AI Invoice Review')),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Theme.of(context).hintColor),
                        const SizedBox(height: 16),
                        Text('No invoice data available', style: TextStyle(color: Theme.of(context).hintColor)),
                      ],
                    ),
                  ),
                )
              : AiInvoiceReviewScreen(invoiceData: invoiceData);
          return CustomTransitionPage(
            key: state.pageKey,
            child: LazyScreen(screenBuilder: () async => child),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),

      // ====================================================================
      // MARKETING ROUTES (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.discounts,
        name: 'discounts',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const DiscountsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.coupons,
        name: 'coupons',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const CouponManagementScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.specialOffers,
        name: 'special-offers',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const SpecialOffersScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // PROMOTIONS ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.smartPromotions,
        name: 'smart-promotions',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const SmartPromotionsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // LOYALTY ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.loyalty,
        name: 'loyalty',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const LoyaltyProgramScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // NOTIFICATIONS ROUTE
      // ====================================================================
      GoRoute(
        path: AppRoutes.notificationsCenter,
        name: 'notifications',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const NotificationsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // PRINTING ROUTE
      // ====================================================================
      GoRoute(
        path: AppRoutes.printQueue,
        name: 'print-queue',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const PrintQueueScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // SYNC ROUTES (from alhai_shared_ui)
      // ====================================================================
      GoRoute(
        path: AppRoutes.syncStatus,
        name: 'sync-status',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const SyncStatusScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.pendingTransactions,
        name: 'pending-transactions',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const PendingTransactionsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.conflictResolution,
        name: 'conflict-resolution',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const ConflictResolutionScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // DRIVERS ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.drivers,
        name: 'drivers',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const DriverManagementScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // BRANCHES ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.branches,
        name: 'branches',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const BranchManagementScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // EMPLOYEES ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.employees,
        name: 'employees',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const UsersManagementScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // PROFILE ROUTE (from alhai_shared_ui)
      // ====================================================================
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // REPORTS ROUTES (from alhai_reports package)
      // ====================================================================
      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const ReportsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.complaintsReport,
        name: 'complaints-report',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const ComplaintsReportScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // SETTINGS ROUTES
      // ====================================================================
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const SettingsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsPrinter,
        name: 'settings-printer',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const PrinterSettingsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsLanguage,
        name: 'settings-language',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const LanguageScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsTheme,
        name: 'settings-theme',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const ThemeScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsStore,
        name: 'settings-store',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const StoreSettingsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsPos,
        name: 'settings-pos',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const PosSettingsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsPaymentDevices,
        name: 'settings-payment-devices',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const PaymentDevicesSettingsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsBarcode,
        name: 'settings-barcode',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const BarcodeSettingsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsReceipt,
        name: 'settings-receipt',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const ReceiptTemplateScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsTax,
        name: 'settings-tax',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const TaxSettingsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsDiscounts,
        name: 'settings-discounts',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const DiscountsSettingsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsInterest,
        name: 'settings-interest',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const InterestSettingsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsSecurity,
        name: 'settings-security',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const SecuritySettingsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsUsers,
        name: 'settings-users',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const UsersManagementScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsRoles,
        name: 'settings-roles',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const RolesPermissionsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsActivityLog,
        name: 'settings-activity-log',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const ActivityLogScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsBackup,
        name: 'settings-backup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const BackupSettingsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsNotifications,
        name: 'settings-notifications',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const NotificationsSettingsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsZatca,
        name: 'settings-zatca',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const ZatcaComplianceScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsHelp,
        name: 'settings-help',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const HelpSupportScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsShipping,
        name: 'settings-shipping',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const ShippingGatewaysScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // AI ROUTES (from alhai_ai package)
      // ====================================================================
      GoRoute(
        path: AppRoutes.aiAssistant,
        name: 'ai-assistant',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const AiAssistantScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.aiSalesForecasting,
        name: 'ai-sales-forecasting',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const AiSalesForecastingScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.aiSmartPricing,
        name: 'ai-smart-pricing',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const AiSmartPricingScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.aiFraudDetection,
        name: 'ai-fraud-detection',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const AiFraudDetectionScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.aiBasketAnalysis,
        name: 'ai-basket-analysis',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const AiBasketAnalysisScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.aiCustomerRecommendations,
        name: 'ai-customer-recommendations',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const AiCustomerRecommendationsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.aiSmartInventory,
        name: 'ai-smart-inventory',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const AiSmartInventoryScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.aiCompetitorAnalysis,
        name: 'ai-competitor-analysis',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const AiCompetitorAnalysisScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.aiSmartReports,
        name: 'ai-smart-reports',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const AiSmartReportsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.aiStaffAnalytics,
        name: 'ai-staff-analytics',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const AiStaffAnalyticsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.aiProductRecognition,
        name: 'ai-product-recognition',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const AiProductRecognitionScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.aiSentimentAnalysis,
        name: 'ai-sentiment-analysis',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const AiSentimentAnalysisScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.aiReturnPrediction,
        name: 'ai-return-prediction',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const AiReturnPredictionScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.aiPromotionDesigner,
        name: 'ai-promotion-designer',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const AiPromotionDesignerScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.aiChatWithData,
        name: 'ai-chat-with-data',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const AiChatWithDataScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // ECOMMERCE ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.ecommerce,
        name: 'ecommerce',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const EcommerceScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // WALLET ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.wallet,
        name: 'wallet',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const WalletScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // SUBSCRIPTION ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.subscription,
        name: 'subscription',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const SubscriptionScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // MEDIA LIBRARY ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.mediaLibrary,
        name: 'media-library',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const MediaLibraryScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // DEVICE LOG ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.deviceLog,
        name: 'device-log',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const DeviceLogScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // NEW SCREENS (added)
      // ====================================================================
      GoRoute(
        path: AppRoutes.supplierReturns,
        name: 'supplier-returns',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const SupplierReturnScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.purchasesList,
        name: 'purchases-list',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const PurchasesListScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.purchaseDetail,
        name: 'purchase-detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: LazyScreen(screenBuilder: () async => PurchaseDetailScreen(purchaseId: id)),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.receivingGoods,
        name: 'receiving-goods',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: LazyScreen(screenBuilder: () async => ReceivingGoodsScreen(purchaseId: id)),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.sendToDistributor,
        name: 'send-to-distributor',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: LazyScreen(screenBuilder: () async => SendToDistributorScreen(purchaseId: id)),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.giftCards,
        name: 'gift-cards',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const GiftCardsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.employeeAttendance,
        name: 'employee-attendance',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const AttendanceScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.employeeCommissions,
        name: 'employee-commissions',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const CommissionScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.onlineOrders,
        name: 'online-orders',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const OnlineOrdersScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.damagedGoods,
        name: 'damaged-goods',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const DamagedGoodsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.priceLists,
        name: 'price-lists',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const PriceListsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.customerGroups,
        name: 'customer-groups',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const CustomerGroupsScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // DELIVERY ZONES ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.deliveryZones,
        name: 'delivery-zones',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const DeliveryZonesScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // EMPLOYEE PROFILE ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.employeeProfile,
        name: 'employee-profile',
        pageBuilder: (context, state) {
          final userId = state.pathParameters['userId'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: LazyScreen(screenBuilder: () async => EmployeeProfileScreen(userId: userId)),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),

      // ====================================================================
      // WHATSAPP MANAGEMENT ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.settingsWhatsApp,
        name: 'whatsapp-management',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const WhatsAppManagementScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ====================================================================
      // KIOSK MODE ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.kioskMode,
        name: 'kiosk',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LazyScreen(screenBuilder: () async => const KioskScreen()),
          transitionsBuilder: _fadeTransition,
        ),
      ),
    ],
  ),
];
