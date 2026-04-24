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
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_pos/alhai_pos.dart';
import 'package:alhai_reports/alhai_reports.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
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
import '../screens/settings/store/store_info_screen.dart';
import '../screens/settings/store/tax_settings_screen.dart';
import '../screens/settings/store/receipt_settings_screen.dart';
import '../screens/settings/devices/payment_devices_screen.dart';
import '../screens/settings/devices/add_payment_device_screen.dart';
import '../screens/settings/devices/printer_settings_screen.dart';
import '../screens/settings/account/keyboard_shortcuts_screen.dart';
import '../screens/settings/account/users_permissions_screen.dart';
import '../screens/settings/system/backup_screen.dart';
import '../screens/settings/system/privacy_policy_screen.dart';
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
import '../screens/settings/devices/cashier_features_settings_screen.dart';

/// Route parameter extraction helper
extension GoRouterStateX on GoRouterState {
  /// Extract path parameter by key (defaults to 'id')
  String pathId([String key = 'id']) => pathParameters[key] ?? '';

  /// Extract query parameter by key
  String queryParam(String key) => uri.queryParameters[key] ?? '';
}

/// Phase 4.4 — SharedPreferences key that controls page-transition animations.
///
/// When the user disables "Animations" from `CashierSettingsScreen`, this key
/// becomes `false`. The router reads the value at app startup (into
/// [_animationsEnabled]) and each settings toggle refreshes it via
/// [refreshAnimationsFlag]. When animations are OFF every [CustomTransitionPage]
/// uses `Duration.zero`, effectively disabling the transition while leaving
/// the page swap intact (no visual regression for the rest of the app).
const String kPrefAnimationsEnabled = 'settings_animations_enabled';

/// Router-local cached flag. Read synchronously during a `pageBuilder`, so we
/// mirror the SharedPreferences value here instead of reading from disk on
/// every navigation. Default: animations enabled (true).
bool _animationsEnabled = true;

/// Load the animations-enabled flag from SharedPreferences. Call once from
/// `main.dart` after prefs are available so the first build already honours
/// the user's preference. Also called from the settings screen to refresh.
Future<void> refreshAnimationsFlag() async {
  final prefs = await SharedPreferences.getInstance();
  _animationsEnabled = prefs.getBool(kPrefAnimationsEnabled) ?? true;
}

/// Phase 4.4 — Combined slide + fade transition (200 ms).
///
/// Moves the incoming route in from the end (right on LTR, left on RTL) while
/// fading it in. Replaces the previous pure-fade transition which felt heavy
/// at 300 ms. When the user disables animations the caller passes
/// `Duration.zero` via [_transitionDuration] so the animation collapses to
/// an instant swap — this helper still builds the tween but `animation` jumps
/// straight to 1.0 so users see no motion.
Widget _alhaiTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  // Subtle 5% offset — enough to signal direction without feeling sluggish
  // for a cashier tapping rapidly between screens.
  final beginOffset = Offset(isRtl ? -0.05 : 0.05, 0);

  return FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: beginOffset,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: AlhaiMotion.standardDecelerate),
      ),
      child: child,
    ),
  );
}

/// Returns the transition duration to use for [CustomTransitionPage]. When
/// animations are disabled globally, returns [Duration.zero] — the page swap
/// still happens but without motion. 200 ms is the default (short enough for
/// a desktop cashier, long enough to read as intentional motion).
Duration _transitionDuration() {
  return _animationsEnabled
      ? const Duration(milliseconds: 200)
      : Duration.zero;
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
  if (storeId == null && path != AppRoutes.storeSelect && !isPublic) {
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
    debugLogDiagnostics: kDebugMode,
    refreshListenable: authNotifier,
    redirect: (context, state) => _guardRedirect(ref, state),
    observers: [SentryNavigatorObserver()],
    routes: _routes,
    errorBuilder: _errorBuilder,
  );
});

Widget _errorBuilder(BuildContext context, GoRouterState state) {
  final l10n = AppLocalizations.of(context);
  return Scaffold(
    appBar: AppBar(title: Text(l10n.pageNotFoundTitle)),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: AlhaiSpacing.md),
          Text(l10n.pageNotFoundMessage(state.uri.path)),
          const SizedBox(height: AlhaiSpacing.lg),
          FilledButton(
            onPressed: () => GoRouter.of(context).go(AppRoutes.pos),
            child: Text(l10n.pointOfSale),
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
      transitionsBuilder: _alhaiTransition,
      transitionDuration: _transitionDuration(),
      reverseTransitionDuration: _transitionDuration(),
    ),
  ),
  GoRoute(
    path: AppRoutes.login,
    name: 'login',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: const LoginScreen(),
      transitionsBuilder: _alhaiTransition,
      transitionDuration: _transitionDuration(),
      reverseTransitionDuration: _transitionDuration(),
    ),
  ),
  GoRoute(
    path: AppRoutes.storeSelect,
    name: 'store-select',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: const StoreSelectScreen(),
      transitionsBuilder: _alhaiTransition,
      transitionDuration: _transitionDuration(),
      reverseTransitionDuration: _transitionDuration(),
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
      transitionsBuilder: _alhaiTransition,
      transitionDuration: _transitionDuration(),
      reverseTransitionDuration: _transitionDuration(),
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
      transitionsBuilder: _alhaiTransition,
      transitionDuration: _transitionDuration(),
      reverseTransitionDuration: _transitionDuration(),
    ),
  ),
  GoRoute(
    path: AppRoutes.posReceipt,
    name: 'pos-receipt',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: const ReceiptScreen(),
      transitionsBuilder: _alhaiTransition,
      transitionDuration: _transitionDuration(),
      reverseTransitionDuration: _transitionDuration(),
    ),
  ),
  GoRoute(
    path: AppRoutes.managerApproval,
    name: 'manager-approval',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: const ManagerApprovalScreen(),
      transitionsBuilder: _alhaiTransition,
      transitionDuration: _transitionDuration(),
      reverseTransitionDuration: _transitionDuration(),
    ),
  ),
  GoRoute(
    path: AppRoutes.kioskMode,
    name: 'kiosk-mode',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: const KioskScreen(),
      transitionsBuilder: _alhaiTransition,
      transitionDuration: _transitionDuration(),
      reverseTransitionDuration: _transitionDuration(),
    ),
  ),
  GoRoute(
    path: '/customer-display',
    name: 'customer-display',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: const CustomerDisplayScreen(),
      transitionsBuilder: _alhaiTransition,
      transitionDuration: _transitionDuration(),
      reverseTransitionDuration: _transitionDuration(),
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
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.quickSale,
        name: 'quick-sale',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const QuickSaleScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: '/pos/favorites',
        name: 'pos-favorites',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const FavoritesScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: '/pos/hold-invoices',
        name: 'pos-hold-invoices',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HoldInvoicesScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: '/pos/barcode-scanner',
        name: 'pos-barcode-scanner',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const BarcodeScannerScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.cashDrawer,
        name: 'cash-drawer',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CashDrawerScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
          child: const CashierReceivingScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.cashierPurchaseRequest,
        name: 'purchase-request',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CashierPurchaseRequestScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.refundReason,
        name: 'refund-reason',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RefundReasonScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
            transitionsBuilder: _alhaiTransition,
            transitionDuration: _transitionDuration(),
            reverseTransitionDuration: _transitionDuration(),
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
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
            transitionsBuilder: _alhaiTransition,
            transitionDuration: _transitionDuration(),
            reverseTransitionDuration: _transitionDuration(),
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
            transitionsBuilder: _alhaiTransition,
            transitionDuration: _transitionDuration(),
            reverseTransitionDuration: _transitionDuration(),
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
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.shiftOpen,
        name: 'shift-open',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ShiftOpenScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.shiftClose,
        name: 'shift-close',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ShiftCloseScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.shiftSummary,
        name: 'shift-summary',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ShiftSummaryScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
          child: const SalesHistoryScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: '/sales/reprint',
        name: 'reprint-receipt',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ReprintReceiptScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
          child: const DailySummaryScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: '/shifts/cash-in-out',
        name: 'cash-in-out',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CashInOutScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
            transitionsBuilder: _alhaiTransition,
            transitionDuration: _transitionDuration(),
            reverseTransitionDuration: _transitionDuration(),
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
          child: const InventoryScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.inventoryAlerts,
        name: 'inventory-alerts',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const InventoryAlertsScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.expiryTracking,
        name: 'expiry-tracking',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ExpiryTrackingScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
            transitionsBuilder: _alhaiTransition,
            transitionDuration: _transitionDuration(),
            reverseTransitionDuration: _transitionDuration(),
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
          child: const VoidTransactionScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
          child: const CustomerDebtScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
          child: const OrderTrackingScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.orderHistory,
        name: 'order-history',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OrderHistoryScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
          child: const CustomerAnalyticsScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
          child: const ReportsScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.dailySalesReport,
        name: 'daily-sales-report',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DailySalesReportScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.topProductsReport,
        name: 'top-products-report',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const TopProductsReportScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.cashFlowReport,
        name: 'cash-flow-report',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CashFlowScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.customerReport,
        name: 'customer-report',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CustomerReportScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.inventoryReport,
        name: 'inventory-report',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const InventoryReportScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
          child: const SyncStatusScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
          child: const LanguageScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsTheme,
        name: 'theme',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ThemeScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
            child: SaleDetailScreen(saleId: id),
            transitionsBuilder: _alhaiTransition,
            transitionDuration: _transitionDuration(),
            reverseTransitionDuration: _transitionDuration(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.exchange,
        name: 'exchange',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ExchangeScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
            child: SplitReceiptScreen(orderId: id),
            transitionsBuilder: _alhaiTransition,
            transitionDuration: _transitionDuration(),
            reverseTransitionDuration: _transitionDuration(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.paymentHistory,
        name: 'payment-history',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PaymentHistoryScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.splitRefund,
        name: 'split-refund',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return CustomTransitionPage(
            key: state.pageKey,
            child: SplitRefundScreen(orderId: id),
            transitionsBuilder: _alhaiTransition,
            transitionDuration: _transitionDuration(),
            reverseTransitionDuration: _transitionDuration(),
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
          child: const CustomerAccountsScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.newTransaction,
        name: 'new-transaction',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: NewTransactionScreen(
            customerId: state.queryParam('customerId').isEmpty
                ? null
                : state.queryParam('customerId'),
          ),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.applyInterest,
        name: 'apply-interest',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ApplyInterestScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.createInvoice,
        name: 'create-invoice',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CreateInvoiceScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
          child: const CashierSettingsScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsStore,
        name: 'store-info',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const StoreInfoScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsTax,
        name: 'tax-settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const TaxSettingsScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsReceipt,
        name: 'receipt-settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ReceiptSettingsScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsPaymentDevices,
        name: 'payment-devices',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PaymentDevicesScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.addPaymentDevice,
        name: 'add-payment-device',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddPaymentDeviceScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsPrinter,
        name: 'printer-settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PrinterSettingsScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsKeyboardShortcuts,
        name: 'keyboard-shortcuts',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const KeyboardShortcutsScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsUsers,
        name: 'users-permissions',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const UsersPermissionsScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsBackup,
        name: 'backup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const BackupScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsPrivacy,
        name: 'privacy-policy',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PrivacyPolicyScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: '/settings/features',
        name: 'features-settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CashierFeaturesSettingsScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
          child: const QuickAddProductScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.editPrice,
        name: 'edit-price',
        pageBuilder: (context, state) {
          final id = state.pathId();
          return CustomTransitionPage(
            key: state.pageKey,
            child: EditPriceScreen(productId: id),
            transitionsBuilder: _alhaiTransition,
            transitionDuration: _transitionDuration(),
            reverseTransitionDuration: _transitionDuration(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.printBarcode,
        name: 'print-barcode',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PrintBarcodeScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.cashierCategories,
        name: 'cashier-categories',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CashierCategoriesScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.priceLabels,
        name: 'price-labels',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PriceLabelsScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
            child: EditInventoryScreen(productId: id),
            transitionsBuilder: _alhaiTransition,
            transitionDuration: _transitionDuration(),
            reverseTransitionDuration: _transitionDuration(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.addInventory,
        name: 'add-inventory',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddInventoryScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.removeInventory,
        name: 'remove-inventory',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RemoveInventoryScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.transferInventory,
        name: 'transfer-inventory',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const TransferInventoryScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.stockTake,
        name: 'stock-take',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const StockTakeScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.wastage,
        name: 'wastage',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const WastageScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
          child: const ActiveOffersScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.couponCode,
        name: 'coupon-code',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CouponCodeScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.bundleDeals,
        name: 'bundle-deals',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const BundleDealsScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
          child: const PaymentReportsScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.customReport,
        name: 'custom-report',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CustomReportScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
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
          child: const NotificationsScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileScreen(),
          transitionsBuilder: _alhaiTransition,
          transitionDuration: _transitionDuration(),
          reverseTransitionDuration: _transitionDuration(),
        ),
      ),
    ],
  ),
];
