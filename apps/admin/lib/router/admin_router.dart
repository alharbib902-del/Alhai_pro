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
import 'package:alhai_l10n/alhai_l10n.dart';

import '../core/constants/admin_permissions.dart';

// Package imports: Auth
import 'package:alhai_auth/alhai_auth.dart'
    show
        SplashScreen,
        LoginScreen,
        StoreSelectScreen,
        authStateProvider,
        AuthStatus,
        currentStoreIdProvider,
        userRoleProvider;

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
    show ReportsScreen, ComplaintsReportScreen;

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
        ProfileScreen;

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
import '../screens/settings/notifications_settings_screen.dart';
import '../screens/settings/help_support_screen.dart';
// Settings: system
import '../screens/settings/system/security_settings_screen.dart';
import '../screens/settings/system/roles_permissions_screen.dart';
import '../screens/settings/system/users_management_screen.dart';
import '../screens/settings/system/activity_log_screen.dart';
import '../screens/settings/system/backup_settings_screen.dart';
// Settings: business
import '../screens/settings/business/store_settings_screen.dart';
import '../screens/settings/business/tax_settings_screen.dart';
import '../screens/settings/business/interest_settings_screen.dart';
import '../screens/settings/business/discounts_settings_screen.dart';
// Settings: integrations
import '../screens/settings/integrations/payment_devices_settings_screen.dart';
import '../screens/settings/integrations/shipping_gateways_screen.dart';
import '../screens/settings/integrations/whatsapp_management_screen.dart';
import '../screens/settings/integrations/zatca_compliance_screen.dart';
// Settings: pos
import '../screens/settings/pos/pos_settings_screen.dart';
import '../screens/settings/pos/barcode_settings_screen.dart';
import '../screens/settings/pos/printer_settings_screen.dart';
import '../screens/settings/pos/receipt_template_screen.dart';

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

/// Standard transition duration for all admin routes (200ms for snappy feel)
const _kPageTransitionDuration = Duration(milliseconds: 200);

/// Build a [CustomTransitionPage] with a consistent fade transition.
///
/// Use this instead of manually constructing [CustomTransitionPage]
/// to ensure every route has the same 200ms fade animation.
CustomTransitionPage<void> _buildFadePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: _fadeTransition,
    transitionDuration: _kPageTransitionDuration,
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

/// Maps a [UserRole] to its default permission set from [AdminPermissions].
///
/// When a full RBAC system is in place (permissions stored per-user in the
/// `role_permissions` table), this helper should be replaced with a provider
/// that reads the authenticated user's actual permission list.
List<String> _permissionsForRole(UserRole? role) {
  return switch (role) {
    UserRole.superAdmin ||
    UserRole.storeOwner =>
      AdminPermissions.ownerDefaults,
    UserRole.employee => AdminPermissions.cashierDefaults,
    // delivery / customer / null → no admin permissions
    _ => const <String>[],
  };
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
  if (storeId == null && path != AppRoutes.storeSelect && !isPublic) {
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

  // ── Granular permission guards for sensitive routes ─────────────
  // Derive the user's permission set from their role using the
  // AdminPermissions defaults. When a full RBAC system is wired
  // (permissions stored per-user in the DB), replace
  // `_permissionsForRole` with a live permission-set lookup.
  if (authState.status == AuthStatus.authenticated && storeId != null) {
    final permissions = _permissionsForRole(role);

    // Helper: redirect to home if permission is missing
    bool lacks(String perm) => !permissions.contains(perm);

    // ── Users & Roles ──────────────────────────────────────────
    if (path == AppRoutes.settingsUsers &&
        lacks(AdminPermissions.usersManage)) {
      return AppRoutes.home;
    }
    if (path == AppRoutes.settingsRoles &&
        lacks(AdminPermissions.rolesManage)) {
      return AppRoutes.home;
    }
    if (path == AppRoutes.employees && lacks(AdminPermissions.staffManage)) {
      return AppRoutes.home;
    }
    if (path.startsWith('/employees/') && lacks(AdminPermissions.staffView)) {
      return AppRoutes.home;
    }

    // ── Settings (all sub-routes) ──────────────────────────────
    if (path == AppRoutes.settings && lacks(AdminPermissions.settingsManage)) {
      return AppRoutes.home;
    }
    if (path.startsWith('/settings/') &&
        path != AppRoutes.settingsLanguage &&
        path != AppRoutes.settingsTheme &&
        path != AppRoutes.settingsHelp &&
        lacks(AdminPermissions.settingsManage) &&
        lacks(AdminPermissions.settingsView)) {
      return AppRoutes.home;
    }

    // ── Reports ────────────────────────────────────────────────
    if ((path == AppRoutes.reports || path == AppRoutes.complaintsReport) &&
        lacks(AdminPermissions.reportsView)) {
      return AppRoutes.home;
    }

    // ── Purchases ──────────────────────────────────────────────
    if ((path == AppRoutes.purchaseForm ||
            path == AppRoutes.smartReorder ||
            path == AppRoutes.aiInvoiceImport ||
            path == AppRoutes.aiInvoiceReview ||
            path == AppRoutes.supplierReturns ||
            path.startsWith('/purchases/')) &&
        lacks(AdminPermissions.purchasesManage) &&
        lacks(AdminPermissions.purchasesView)) {
      return AppRoutes.home;
    }

    // ── Marketing ──────────────────────────────────────────────
    if ((path == AppRoutes.discounts ||
            path == AppRoutes.coupons ||
            path == AppRoutes.specialOffers ||
            path == AppRoutes.smartPromotions ||
            path == AppRoutes.loyalty ||
            path == AppRoutes.giftCards) &&
        lacks(AdminPermissions.marketingManage)) {
      return AppRoutes.home;
    }

    // ── Inventory ──────────────────────────────────────────────
    if ((path == AppRoutes.inventory ||
            path == AppRoutes.expiryTracking ||
            path == AppRoutes.damagedGoods) &&
        lacks(AdminPermissions.inventoryManage) &&
        lacks(AdminPermissions.inventoryView)) {
      return AppRoutes.home;
    }

    // ── Products ───────────────────────────────────────────────
    if ((path == AppRoutes.productsAdd || path.startsWith('/products/edit/')) &&
        lacks(AdminPermissions.productsManage)) {
      return AppRoutes.home;
    }

    // ── Customers ──────────────────────────────────────────────
    if ((path == AppRoutes.customerAnalytics ||
            path == AppRoutes.customerGroups) &&
        lacks(AdminPermissions.customersManage) &&
        lacks(AdminPermissions.customersView)) {
      return AppRoutes.home;
    }

    // ── Financial ──────────────────────────────────────────────
    if ((path == AppRoutes.expenses ||
            path == AppRoutes.expenseCategories ||
            path == AppRoutes.monthlyClose) &&
        lacks(AdminPermissions.financialManage)) {
      return AppRoutes.home;
    }

    // ── Backup & Audit ─────────────────────────────────────────
    if (path == AppRoutes.settingsBackup &&
        lacks(AdminPermissions.backupManage)) {
      return AppRoutes.home;
    }
    if (path == AppRoutes.settingsActivityLog &&
        lacks(AdminPermissions.auditLogView)) {
      return AppRoutes.home;
    }

    // ── Devices & Sync ─────────────────────────────────────────
    if ((path == AppRoutes.deviceLog ||
            path == AppRoutes.syncStatus ||
            path == AppRoutes.pendingTransactions ||
            path == AppRoutes.conflictResolution) &&
        lacks(AdminPermissions.devicesManage)) {
      return AppRoutes.home;
    }

    // ── Branches ───────────────────────────────────────────────
    if (path == AppRoutes.branches && lacks(AdminPermissions.settingsManage)) {
      return AppRoutes.home;
    }
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
  final l10n = AppLocalizations.of(context);
  return Scaffold(
    appBar: AppBar(title: Text(l10n.error)),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: AlhaiSpacing.md),
          Text(l10n.pageNotFoundPath(state.uri.path)),
          const SizedBox(height: AlhaiSpacing.lg),
          FilledButton(
            onPressed: () => context.go(AppRoutes.home),
            child: Text(l10n.home),
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
    pageBuilder: (context, state) => _buildFadePage(
      state: state,
      child: const SplashScreen(),
    ),
  ),
  GoRoute(
    path: AppRoutes.login,
    name: 'login',
    pageBuilder: (context, state) => _buildFadePage(
      state: state,
      child: const LoginScreen(),
    ),
  ),
  GoRoute(
    path: AppRoutes.storeSelect,
    name: 'store-select',
    pageBuilder: (context, state) => _buildFadePage(
      state: state,
      child: const StoreSelectScreen(),
    ),
  ),

  // ============================================================================
  // ONBOARDING (outside ShellRoute - no sidebar)
  // ============================================================================
  GoRoute(
    path: AppRoutes.onboarding,
    name: 'onboarding',
    pageBuilder: (context, state) => _buildFadePage(
      state: state,
      child: const OnboardingScreen(),
    ),
  ),

  // ============================================================================
  // POS OVERLAY SCREENS (outside ShellRoute - no sidebar)
  // ============================================================================
  GoRoute(
    path: AppRoutes.posPayment,
    name: 'pos-payment',
    pageBuilder: (context, state) => _buildFadePage(
      state: state,
      child: const PaymentScreen(),
    ),
  ),
  GoRoute(
    path: AppRoutes.posReceipt,
    name: 'pos-receipt',
    pageBuilder: (context, state) => _buildFadePage(
      state: state,
      child: const ReceiptScreen(),
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
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const AdminHomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const DashboardScreen(),
        ),
      ),

      // ====================================================================
      // POS ROUTES (from alhai_pos package)
      // ====================================================================
      GoRoute(
        path: AppRoutes.pos,
        name: 'pos',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const PosScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.posSearch,
        name: 'pos-search',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const PosScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.posCart,
        name: 'pos-cart',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const PosScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.quickSale,
        name: 'quick-sale',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const QuickSaleScreen(),
        ),
      ),

      // ====================================================================
      // PRODUCTS ROUTES (from alhai_shared_ui)
      // ====================================================================
      GoRoute(
        path: AppRoutes.products,
        name: 'products',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const ProductsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.productsAdd,
        name: 'products-add',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const ProductFormScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.productsEdit,
        name: 'products-edit',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: ProductFormScreen(productId: state.pathId()),
        ),
      ),
      GoRoute(
        path: AppRoutes.productDetail,
        name: 'product-detail',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return _buildFadePage(
            state: state,
            child: ProductDetailScreen(productId: id),
          );
        },
      ),

      // ====================================================================
      // CATEGORIES ROUTE
      // ====================================================================
      GoRoute(
        path: AppRoutes.categories,
        name: 'categories',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const CategoriesScreen(),
        ),
      ),

      // ====================================================================
      // INVENTORY ROUTES (from alhai_shared_ui)
      // ====================================================================
      GoRoute(
        path: AppRoutes.inventory,
        name: 'inventory',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const InventoryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.expiryTracking,
        name: 'expiry-tracking',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const ExpiryTrackingScreen(),
        ),
      ),

      // ====================================================================
      // CUSTOMERS ROUTES (from alhai_shared_ui)
      // ====================================================================
      GoRoute(
        path: AppRoutes.customers,
        name: 'customers',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const CustomersScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.customerDetail,
        name: 'customer-detail',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return _buildFadePage(
            state: state,
            child: CustomerDetailScreen(customerId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.customerLedger,
        name: 'customer-ledger',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return _buildFadePage(
            state: state,
            child: CustomerLedgerScreen(customerId: id),
          );
        },
      ),

      // ====================================================================
      // SUPPLIERS ROUTES (from alhai_shared_ui)
      // ====================================================================
      GoRoute(
        path: AppRoutes.suppliers,
        name: 'suppliers',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const SuppliersScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.supplierForm,
        name: 'supplier-form',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const SupplierFormScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.supplierDetail,
        name: 'supplier-detail',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return _buildFadePage(
            state: state,
            child: SupplierDetailScreen(supplierId: id),
          );
        },
      ),

      // ====================================================================
      // ORDERS ROUTES (from alhai_shared_ui)
      // ====================================================================
      GoRoute(
        path: AppRoutes.orders,
        name: 'orders',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const OrdersScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.orderTracking,
        name: 'order-tracking',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const OrderTrackingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.orderHistory,
        name: 'order-history',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const OrderHistoryScreen(),
        ),
      ),

      // ====================================================================
      // CUSTOMER ANALYTICS ROUTE (from alhai_shared_ui)
      // ====================================================================
      GoRoute(
        path: AppRoutes.customerAnalytics,
        name: 'customer-analytics',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const CustomerAnalyticsScreen(),
        ),
      ),

      // ====================================================================
      // SALES ROUTE (alias for invoices)
      // ====================================================================
      GoRoute(
        path: AppRoutes.sales,
        name: 'sales',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const InvoicesScreen(),
        ),
      ),

      // ====================================================================
      // INVOICES ROUTES (from alhai_shared_ui)
      // ====================================================================
      GoRoute(
        path: AppRoutes.invoices,
        name: 'invoices',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const InvoicesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.invoiceDetail,
        name: 'invoice-detail',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return _buildFadePage(
            state: state,
            child: InvoiceDetailScreen(invoiceId: id),
          );
        },
      ),

      // ====================================================================
      // RETURNS ROUTES (from alhai_pos package)
      // ====================================================================
      GoRoute(
        path: AppRoutes.returns,
        name: 'returns',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const ReturnsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.refundRequest,
        name: 'refund-request',
        pageBuilder: (context, state) {
          final orderId = state.queryParam('orderId');
          return _buildFadePage(
            state: state,
            child:
                RefundRequestScreen(orderId: orderId.isEmpty ? null : orderId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.refundReason,
        name: 'refund-reason',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const RefundReasonScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.refundReceipt,
        name: 'refund-receipt',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return _buildFadePage(
            state: state,
            child: RefundReceiptScreen(refundId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.voidTransaction,
        name: 'void-transaction',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const VoidTransactionScreen(),
        ),
      ),

      // ====================================================================
      // EXPENSES ROUTES (from alhai_shared_ui)
      // ====================================================================
      GoRoute(
        path: AppRoutes.expenses,
        name: 'expenses',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const ExpensesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.expenseCategories,
        name: 'expense-categories',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const ExpenseCategoriesScreen(),
        ),
      ),

      // ====================================================================
      // CASH DRAWER ROUTE (from alhai_pos)
      // ====================================================================
      GoRoute(
        path: AppRoutes.cashDrawer,
        name: 'cash-drawer',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const CashDrawerScreen(),
        ),
      ),

      // ====================================================================
      // DEBTS ROUTES
      // ====================================================================
      GoRoute(
        path: AppRoutes.monthlyClose,
        name: 'monthly-close',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const MonthlyCloseScreen(),
        ),
      ),

      // ====================================================================
      // SHIFTS ROUTES (from alhai_shared_ui)
      // ====================================================================
      GoRoute(
        path: AppRoutes.shifts,
        name: 'shifts',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const ShiftsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.shiftOpen,
        name: 'shift-open',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const ShiftOpenScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.shiftClose,
        name: 'shift-close',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const ShiftCloseScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.shiftSummary,
        name: 'shift-summary',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const ShiftSummaryScreen(),
        ),
      ),

      // ====================================================================
      // PURCHASES ROUTES (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.purchaseForm,
        name: 'purchase-form',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const PurchaseFormScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.smartReorder,
        name: 'smart-reorder',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const SmartReorderScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiInvoiceImport,
        name: 'ai-invoice-import',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const AiInvoiceImportScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiInvoiceReview,
        name: 'ai-invoice-review',
        pageBuilder: (context, state) {
          final l10n = AppLocalizations.of(context);
          final invoiceData = state.extra as AiInvoiceResult?;
          final child = invoiceData == null
              ? Scaffold(
                  appBar: AppBar(title: Text(l10n.aiInvoiceReview)),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long,
                            size: 64, color: Theme.of(context).hintColor),
                        const SizedBox(height: AlhaiSpacing.md),
                        Text(l10n.noInvoiceDataAvailable,
                            style:
                                TextStyle(color: Theme.of(context).hintColor)),
                      ],
                    ),
                  ),
                )
              : AiInvoiceReviewScreen(invoiceData: invoiceData);
          return _buildFadePage(
            state: state,
            child: child,
          );
        },
      ),

      // ====================================================================
      // MARKETING ROUTES (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.discounts,
        name: 'discounts',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const DiscountsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.coupons,
        name: 'coupons',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const CouponManagementScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.specialOffers,
        name: 'special-offers',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const SpecialOffersScreen(),
        ),
      ),

      // ====================================================================
      // PROMOTIONS ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.smartPromotions,
        name: 'smart-promotions',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const SmartPromotionsScreen(),
        ),
      ),

      // ====================================================================
      // LOYALTY ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.loyalty,
        name: 'loyalty',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const LoyaltyProgramScreen(),
        ),
      ),

      // ====================================================================
      // NOTIFICATIONS ROUTE
      // ====================================================================
      GoRoute(
        path: AppRoutes.notificationsCenter,
        name: 'notifications',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const NotificationsScreen(),
        ),
      ),

      // ====================================================================
      // PRINTING ROUTE
      // ====================================================================
      GoRoute(
        path: AppRoutes.printQueue,
        name: 'print-queue',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const PrintQueueScreen(),
        ),
      ),

      // ====================================================================
      // SYNC ROUTES (from alhai_shared_ui)
      // ====================================================================
      GoRoute(
        path: AppRoutes.syncStatus,
        name: 'sync-status',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const SyncStatusScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.pendingTransactions,
        name: 'pending-transactions',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const PendingTransactionsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.conflictResolution,
        name: 'conflict-resolution',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const ConflictResolutionScreen(),
        ),
      ),

      // ====================================================================
      // DRIVERS ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.drivers,
        name: 'drivers',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const DriverManagementScreen(),
        ),
      ),

      // ====================================================================
      // BRANCHES ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.branches,
        name: 'branches',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const BranchManagementScreen(),
        ),
      ),

      // ====================================================================
      // EMPLOYEES ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.employees,
        name: 'employees',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const UsersManagementScreen(),
        ),
      ),

      // ====================================================================
      // PROFILE ROUTE (from alhai_shared_ui)
      // ====================================================================
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const ProfileScreen(),
        ),
      ),

      // ====================================================================
      // REPORTS ROUTES (from alhai_reports package)
      // ====================================================================
      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const ReportsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.complaintsReport,
        name: 'complaints-report',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const ComplaintsReportScreen(),
        ),
      ),

      // ====================================================================
      // SETTINGS ROUTES
      // ====================================================================
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsPrinter,
        name: 'settings-printer',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const PrinterSettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsLanguage,
        name: 'settings-language',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const LanguageScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsTheme,
        name: 'settings-theme',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const ThemeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsStore,
        name: 'settings-store',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const StoreSettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsPos,
        name: 'settings-pos',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const PosSettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsPaymentDevices,
        name: 'settings-payment-devices',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const PaymentDevicesSettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsBarcode,
        name: 'settings-barcode',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const BarcodeSettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsReceipt,
        name: 'settings-receipt',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const ReceiptTemplateScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsTax,
        name: 'settings-tax',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const TaxSettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsDiscounts,
        name: 'settings-discounts',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const DiscountsSettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsInterest,
        name: 'settings-interest',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const InterestSettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsSecurity,
        name: 'settings-security',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const SecuritySettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsUsers,
        name: 'settings-users',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const UsersManagementScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsRoles,
        name: 'settings-roles',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const RolesPermissionsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsActivityLog,
        name: 'settings-activity-log',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const ActivityLogScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsBackup,
        name: 'settings-backup',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const BackupSettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsNotifications,
        name: 'settings-notifications',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const NotificationsSettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsZatca,
        name: 'settings-zatca',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const ZatcaComplianceScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsHelp,
        name: 'settings-help',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const HelpSupportScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsShipping,
        name: 'settings-shipping',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const ShippingGatewaysScreen(),
        ),
      ),

      // ====================================================================
      // AI ROUTES (from alhai_ai package)
      // ====================================================================
      GoRoute(
        path: AppRoutes.aiAssistant,
        name: 'ai-assistant',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const AiAssistantScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiSalesForecasting,
        name: 'ai-sales-forecasting',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const AiSalesForecastingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiSmartPricing,
        name: 'ai-smart-pricing',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const AiSmartPricingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiFraudDetection,
        name: 'ai-fraud-detection',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const AiFraudDetectionScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiBasketAnalysis,
        name: 'ai-basket-analysis',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const AiBasketAnalysisScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiCustomerRecommendations,
        name: 'ai-customer-recommendations',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const AiCustomerRecommendationsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiSmartInventory,
        name: 'ai-smart-inventory',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const AiSmartInventoryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiCompetitorAnalysis,
        name: 'ai-competitor-analysis',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const AiCompetitorAnalysisScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiSmartReports,
        name: 'ai-smart-reports',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const AiSmartReportsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiStaffAnalytics,
        name: 'ai-staff-analytics',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const AiStaffAnalyticsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiProductRecognition,
        name: 'ai-product-recognition',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const AiProductRecognitionScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiSentimentAnalysis,
        name: 'ai-sentiment-analysis',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const AiSentimentAnalysisScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiReturnPrediction,
        name: 'ai-return-prediction',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const AiReturnPredictionScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiPromotionDesigner,
        name: 'ai-promotion-designer',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const AiPromotionDesignerScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiChatWithData,
        name: 'ai-chat-with-data',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const AiChatWithDataScreen(),
        ),
      ),

      // ====================================================================
      // ECOMMERCE ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.ecommerce,
        name: 'ecommerce',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const EcommerceScreen(),
        ),
      ),

      // ====================================================================
      // WALLET ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.wallet,
        name: 'wallet',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const WalletScreen(),
        ),
      ),

      // ====================================================================
      // SUBSCRIPTION ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.subscription,
        name: 'subscription',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const SubscriptionScreen(),
        ),
      ),

      // ====================================================================
      // MEDIA LIBRARY ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.mediaLibrary,
        name: 'media-library',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const MediaLibraryScreen(),
        ),
      ),

      // ====================================================================
      // DEVICE LOG ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.deviceLog,
        name: 'device-log',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const DeviceLogScreen(),
        ),
      ),

      // ====================================================================
      // NEW SCREENS (added)
      // ====================================================================
      GoRoute(
        path: AppRoutes.supplierReturns,
        name: 'supplier-returns',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const SupplierReturnScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.purchasesList,
        name: 'purchases-list',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const PurchasesListScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.purchaseDetail,
        name: 'purchase-detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _buildFadePage(
            state: state,
            child: PurchaseDetailScreen(purchaseId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.receivingGoods,
        name: 'receiving-goods',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _buildFadePage(
            state: state,
            child: ReceivingGoodsScreen(purchaseId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.sendToDistributor,
        name: 'send-to-distributor',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _buildFadePage(
            state: state,
            child: SendToDistributorScreen(purchaseId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.giftCards,
        name: 'gift-cards',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const GiftCardsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.employeeAttendance,
        name: 'employee-attendance',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const AttendanceScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.employeeCommissions,
        name: 'employee-commissions',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const CommissionScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onlineOrders,
        name: 'online-orders',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const OnlineOrdersScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.damagedGoods,
        name: 'damaged-goods',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const DamagedGoodsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.priceLists,
        name: 'price-lists',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const PriceListsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.customerGroups,
        name: 'customer-groups',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const CustomerGroupsScreen(),
        ),
      ),

      // ====================================================================
      // DELIVERY ZONES ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.deliveryZones,
        name: 'delivery-zones',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const DeliveryZonesScreen(),
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
          return _buildFadePage(
            state: state,
            child: EmployeeProfileScreen(userId: userId),
          );
        },
      ),

      // ====================================================================
      // WHATSAPP MANAGEMENT ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.settingsWhatsApp,
        name: 'whatsapp-management',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const WhatsAppManagementScreen(),
        ),
      ),

      // ====================================================================
      // KIOSK MODE ROUTE (admin-only)
      // ====================================================================
      GoRoute(
        path: AppRoutes.kioskMode,
        name: 'kiosk',
        pageBuilder: (context, state) => _buildFadePage(
          state: state,
          child: const KioskScreen(),
        ),
      ),
    ],
  ),
];
