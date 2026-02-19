import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../screens/screens.dart';
import '../../widgets/common/lazy_screen.dart';
import '../../widgets/layout/dashboard_shell.dart';
import '../../services/ai_invoice_service.dart';
import '../../providers/auth_providers.dart';

/// Route parameter extraction helper
extension GoRouterStateX on GoRouterState {
  /// Extract path parameter by key (defaults to 'id')
  String pathId([String key = 'id']) => pathParameters[key] ?? '';

  /// Extract query parameter by key
  String queryParam(String key) => uri.queryParameters[key] ?? '';
}

/// App Router Configuration
///
/// Central routing configuration for the POS app.
/// Uses GoRouter with ShellRoute for persistent sidebar layout.
///
/// Architecture:
/// - Auth routes (splash, login, storeSelect) are top-level (no sidebar)
/// - Onboarding is top-level (no sidebar)
/// - POS overlay screens (payment, receipt) are top-level (no sidebar)
/// - All other routes are wrapped in a ShellRoute with DashboardShell
///   providing a persistent sidebar that doesn't rebuild on navigation
///
/// Performance optimizations:
/// - Lazy loading for heavy screens
/// - Custom shimmer loading screens
/// - Screen preloading for critical paths
/// - Persistent sidebar via ShellRoute (no rebuild on navigation)
class AppRouter {
  AppRouter._();

  /// تحميل الشاشات الحرجة مسبقاً
  static Future<void> preloadCriticalScreens() async {
    // تحميل شاشة POS مسبقاً لأنها الأكثر استخداماً
    ScreenPreloader.preload('pos', () async => const PosScreen());
  }

  /// Fade transition للتحويل السلس بين الشاشات
  static Widget _fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
      child: child,
    );
  }

  /// المسارات التي لا تحتاج مصادقة
  static const _publicRoutes = [
    AppRoutes.splash,
    AppRoutes.login,
    AppRoutes.storeSelect,
    AppRoutes.onboarding,
  ];

  /// إنشاء GoRouter مع حماية redirect
  static GoRouter createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,
      redirect: (context, state) {
        final authState = ref.read(authStateProvider);
        final isAuthenticated = authState.isAuthenticated;
        final currentPath = state.uri.path;
        final isPublicRoute = _publicRoutes.contains(currentPath);

        // إذا لم يكن مصادقاً ويحاول الوصول لصفحة محمية
        if (!isAuthenticated && !isPublicRoute) {
          return AppRoutes.login;
        }

        // إذا كان مصادقاً ويحاول الوصول لصفحة تسجيل الدخول
        if (isAuthenticated && currentPath == AppRoutes.login) {
          return AppRoutes.home;
        }

        return null; // لا يوجد redirect
      },
      routes: _routes,
      errorBuilder: _errorBuilder,
    );
  }

  static Widget _errorBuilder(BuildContext context, GoRouterState state) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n?.error ?? 'Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(l10n != null
              ? '${l10n.error}: ${state.uri.path}'
              : 'Page not found: ${state.uri.path}'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go(AppRoutes.home),
              child: Text(l10n?.home ?? 'Home'),
            ),
          ],
        ),
      ),
    );
  }

  /// الـ router الافتراضي (بدون حماية - يُستخدم كـ fallback)
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: _routes,
    errorBuilder: _errorBuilder,
  );

  static final List<RouteBase> _routes = [
      // ============================================================================
      // AUTH ROUTES (outside ShellRoute - no sidebar)
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
      // ONBOARDING (outside ShellRoute - no sidebar)
      // ============================================================================
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ============================================================================
      // POS OVERLAY SCREENS (outside ShellRoute - no sidebar)
      // ============================================================================
      GoRoute(
        path: AppRoutes.posPayment,
        name: 'pos-payment',
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: AppRoutes.posReceipt,
        name: 'pos-receipt',
        builder: (context, state) => const ReceiptScreen(),
      ),

      // ============================================================================
      // SHELL ROUTE - All sidebar screens wrapped in DashboardShell
      // ============================================================================
      ShellRoute(
        builder: (context, state, child) => DashboardShell(child: child),
        routes: [
          // ====================================================================
          // MAIN ROUTES
          // ====================================================================
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),

          // POS main screen - with lazy loading
          GoRoute(
            path: AppRoutes.pos,
            name: 'pos',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: ScreenPreloader.isLoaded('pos')
                  ? ScreenPreloader.get('pos')!
                  : LazyScreen(
                      screenBuilder: () async => const PosScreen(),
                      loadingWidget: const PosLoadingScreen(),
                    ),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.posSearch,
            name: 'pos-search',
            builder: (context, state) => const PosScreen(),
          ),
          GoRoute(
            path: AppRoutes.quickSale,
            name: 'quick-sale',
            builder: (context, state) => const QuickSaleScreen(),
          ),

          // ====================================================================
          // PRODUCTS ROUTES - with lazy loading
          // ====================================================================
          GoRoute(
            path: AppRoutes.products,
            name: 'products',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: LazyScreen(
                screenBuilder: () async => const ProductsScreen(),
                loadingWidget: const ProductsLoadingScreen(),
              ),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.productsAdd,
            name: 'products-add',
            builder: (context, state) => const ProductFormScreen(),
          ),
          GoRoute(
            path: AppRoutes.productsEdit,
            name: 'products-edit',
            builder: (context, state) {
              final id = state.pathId();
              return ProductFormScreen(productId: id);
            },
          ),
          GoRoute(
            path: AppRoutes.productDetail,
            name: 'product-detail',
            builder: (context, state) {
              final id = state.pathId();
              return ProductDetailScreen(productId: id);
            },
          ),

          // ====================================================================
          // CATEGORIES ROUTE
          // ====================================================================
          GoRoute(
            path: AppRoutes.categories,
            name: 'categories',
            builder: (context, state) => const CategoriesScreen(),
          ),

          // ====================================================================
          // INVENTORY ROUTE - with lazy loading
          // ====================================================================
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

          // ====================================================================
          // EXPIRY TRACKING ROUTE
          // ====================================================================
          GoRoute(
            path: AppRoutes.expiryTracking,
            name: 'expiry-tracking',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ExpiryTrackingScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),

          // ====================================================================
          // CUSTOMERS ROUTES - with lazy loading
          // ====================================================================
          GoRoute(
            path: AppRoutes.customers,
            name: 'customers',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: LazyScreen(
                screenBuilder: () async => const CustomersScreen(),
                loadingWidget: const CustomersLoadingScreen(),
              ),
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
              final name = state.queryParam('name');
              return CustomTransitionPage(
                key: state.pageKey,
                child: CustomerLedgerScreen(accountId: id, customerName: name),
                transitionsBuilder: _fadeTransition,
              );
            },
          ),

          // ====================================================================
          // SUPPLIERS ROUTES - with lazy loading
          // ====================================================================
          GoRoute(
            path: AppRoutes.suppliers,
            name: 'suppliers',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: LazyScreen(
                screenBuilder: () async => const SuppliersScreen(),
                loadingWidget: const SuppliersLoadingScreen(),
              ),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.supplierForm,
            name: 'supplier-form',
            builder: (context, state) => const SupplierFormScreen(),
          ),
          GoRoute(
            path: AppRoutes.supplierDetail,
            name: 'supplier-detail',
            builder: (context, state) {
              final id = state.pathId();
              return SupplierDetailScreen(supplierId: id);
            },
          ),

          // ====================================================================
          // ORDERS ROUTE
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
          // INVOICES ROUTES
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
          // RETURNS ROUTES
          // ====================================================================
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
              child: RefundRequestScreen(orderId: state.queryParam('orderId').isEmpty ? null : state.queryParam('orderId')),
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
          GoRoute(
            path: AppRoutes.voidTransaction,
            name: 'void-transaction',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const VoidTransactionScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),

          // ====================================================================
          // EXPENSES ROUTES
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
            builder: (context, state) => const ExpenseCategoriesScreen(),
          ),

          // ====================================================================
          // CASH DRAWER ROUTE
          // ====================================================================
          GoRoute(
            path: AppRoutes.cashDrawer,
            name: 'cash-drawer',
            builder: (context, state) => const CashDrawerScreen(),
          ),

          // ====================================================================
          // DEBTS ROUTES
          // ====================================================================
          GoRoute(
            path: AppRoutes.monthlyClose,
            name: 'monthly-close',
            builder: (context, state) => const MonthlyCloseScreen(),
          ),

          // ====================================================================
          // SHIFTS ROUTES
          // ====================================================================
          GoRoute(
            path: AppRoutes.shifts,
            name: 'shifts',
            builder: (context, state) => const ShiftsScreen(),
          ),
          GoRoute(
            path: AppRoutes.shiftOpen,
            name: 'shift-open',
            builder: (context, state) => const ShiftOpenScreen(),
          ),
          GoRoute(
            path: AppRoutes.shiftClose,
            name: 'shift-close',
            builder: (context, state) => const ShiftCloseScreen(),
          ),
          GoRoute(
            path: AppRoutes.shiftSummary,
            name: 'shift-summary',
            builder: (context, state) => const ShiftSummaryScreen(),
          ),

          // ====================================================================
          // PURCHASES ROUTES
          // ====================================================================
          GoRoute(
            path: AppRoutes.purchaseForm,
            name: 'purchase-form',
            builder: (context, state) => const PurchaseFormScreen(),
          ),
          GoRoute(
            path: AppRoutes.smartReorder,
            name: 'smart-reorder',
            builder: (context, state) => const SmartReorderScreen(),
          ),
          GoRoute(
            path: AppRoutes.aiInvoiceImport,
            name: 'ai-invoice-import',
            builder: (context, state) => const AiInvoiceImportScreen(),
          ),
          GoRoute(
            path: AppRoutes.aiInvoiceReview,
            name: 'ai-invoice-review',
            builder: (context, state) {
              final invoiceData = state.extra as AiInvoiceResult?;
              if (invoiceData == null) {
                return const AiInvoiceImportScreen();
              }
              return AiInvoiceReviewScreen(invoiceData: invoiceData);
            },
          ),

          // ====================================================================
          // MARKETING ROUTES
          // ====================================================================
          GoRoute(
            path: AppRoutes.discounts,
            name: 'discounts',
            builder: (context, state) => const DiscountsScreen(),
          ),
          GoRoute(
            path: AppRoutes.coupons,
            name: 'coupons',
            builder: (context, state) => const CouponManagementScreen(),
          ),
          GoRoute(
            path: AppRoutes.specialOffers,
            name: 'special-offers',
            builder: (context, state) => const SpecialOffersScreen(),
          ),

          // ====================================================================
          // PROMOTIONS ROUTE
          // ====================================================================
          GoRoute(
            path: AppRoutes.smartPromotions,
            name: 'smart-promotions',
            builder: (context, state) => const SmartPromotionsScreen(),
          ),

          // ====================================================================
          // LOYALTY ROUTE
          // ====================================================================
          GoRoute(
            path: AppRoutes.loyalty,
            name: 'loyalty',
            builder: (context, state) => const LoyaltyProgramScreen(),
          ),

          // ====================================================================
          // NOTIFICATIONS ROUTE
          // ====================================================================
          GoRoute(
            path: AppRoutes.notificationsCenter,
            name: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),

          // ====================================================================
          // PRINTING ROUTE
          // ====================================================================
          GoRoute(
            path: AppRoutes.printQueue,
            name: 'print-queue',
            builder: (context, state) => const PrintQueueScreen(),
          ),

          // ====================================================================
          // SYNC ROUTES
          // ====================================================================
          GoRoute(
            path: AppRoutes.syncStatus,
            name: 'sync-status',
            builder: (context, state) => const SyncStatusScreen(),
          ),
          GoRoute(
            path: AppRoutes.pendingTransactions,
            name: 'pending-transactions',
            builder: (context, state) => const PendingTransactionsScreen(),
          ),
          GoRoute(
            path: AppRoutes.conflictResolution,
            name: 'conflict-resolution',
            builder: (context, state) => const ConflictResolutionScreen(),
          ),

          // ====================================================================
          // DRIVERS ROUTE
          // ====================================================================
          GoRoute(
            path: AppRoutes.drivers,
            name: 'drivers',
            builder: (context, state) => const DriverManagementScreen(),
          ),

          // ====================================================================
          // BRANCHES ROUTE
          // ====================================================================
          GoRoute(
            path: AppRoutes.branches,
            name: 'branches',
            builder: (context, state) => const BranchManagementScreen(),
          ),

          // ====================================================================
          // EMPLOYEES ROUTE
          // ====================================================================
          GoRoute(
            path: AppRoutes.employees,
            name: 'employees',
            builder: (context, state) => const UsersManagementScreen(),
          ),

          // ====================================================================
          // PROFILE ROUTE
          // ====================================================================
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),

          // ====================================================================
          // REPORTS ROUTE - with lazy loading
          // ====================================================================
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

          // ====================================================================
          // SETTINGS ROUTES
          // ====================================================================
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsPrinter,
            name: 'settings-printer',
            builder: (context, state) => const PrinterSettingsScreen(),
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
            path: AppRoutes.settingsStore,
            name: 'settings-store',
            builder: (context, state) => const StoreSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsPos,
            name: 'settings-pos',
            builder: (context, state) => const PosSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsPaymentDevices,
            name: 'settings-payment-devices',
            builder: (context, state) => const PaymentDevicesSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsBarcode,
            name: 'settings-barcode',
            builder: (context, state) => const BarcodeSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsReceipt,
            name: 'settings-receipt',
            builder: (context, state) => const ReceiptTemplateScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsTax,
            name: 'settings-tax',
            builder: (context, state) => const TaxSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsDiscounts,
            name: 'settings-discounts',
            builder: (context, state) => const DiscountsSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsInterest,
            name: 'settings-interest',
            builder: (context, state) => const InterestSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsSecurity,
            name: 'settings-security',
            builder: (context, state) => const SecuritySettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsUsers,
            name: 'settings-users',
            builder: (context, state) => const UsersManagementScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsRoles,
            name: 'settings-roles',
            builder: (context, state) => const RolesPermissionsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsActivityLog,
            name: 'settings-activity-log',
            builder: (context, state) => const ActivityLogScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsBackup,
            name: 'settings-backup',
            builder: (context, state) => const BackupSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsNotifications,
            name: 'settings-notifications',
            builder: (context, state) => const NotificationsSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsZatca,
            name: 'settings-zatca',
            builder: (context, state) => const ZatcaComplianceScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsHelp,
            name: 'settings-help',
            builder: (context, state) => const HelpSupportScreen(),
          ),

          // ====================================================================
          // AI ROUTES
          // ====================================================================
          GoRoute(
            path: AppRoutes.aiAssistant,
            name: 'ai-assistant',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: LazyScreen(
                screenBuilder: () async => const AiAssistantScreen(),
              ),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.aiSalesForecasting,
            name: 'ai-sales-forecasting',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: LazyScreen(
                screenBuilder: () async => const AiSalesForecastingScreen(),
              ),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.aiSmartPricing,
            name: 'ai-smart-pricing',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: LazyScreen(
                screenBuilder: () async => const AiSmartPricingScreen(),
              ),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.aiFraudDetection,
            name: 'ai-fraud-detection',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: LazyScreen(
                screenBuilder: () async => const AiFraudDetectionScreen(),
              ),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.aiBasketAnalysis,
            name: 'ai-basket-analysis',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: LazyScreen(
                screenBuilder: () async => const AiBasketAnalysisScreen(),
              ),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.aiCustomerRecommendations,
            name: 'ai-customer-recommendations',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: LazyScreen(
                screenBuilder: () async => const AiCustomerRecommendationsScreen(),
              ),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.aiSmartInventory,
            name: 'ai-smart-inventory',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: LazyScreen(
                screenBuilder: () async => const AiSmartInventoryScreen(),
              ),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.aiCompetitorAnalysis,
            name: 'ai-competitor-analysis',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: LazyScreen(
                screenBuilder: () async => const AiCompetitorAnalysisScreen(),
              ),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.aiSmartReports,
            name: 'ai-smart-reports',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: LazyScreen(
                screenBuilder: () async => const AiSmartReportsScreen(),
              ),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.aiStaffAnalytics,
            name: 'ai-staff-analytics',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: LazyScreen(
                screenBuilder: () async => const AiStaffAnalyticsScreen(),
              ),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.aiProductRecognition,
            name: 'ai-product-recognition',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: LazyScreen(
                screenBuilder: () async => const AiProductRecognitionScreen(),
              ),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.aiSentimentAnalysis,
            name: 'ai-sentiment-analysis',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: LazyScreen(
                screenBuilder: () async => const AiSentimentAnalysisScreen(),
              ),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.aiReturnPrediction,
            name: 'ai-return-prediction',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: LazyScreen(
                screenBuilder: () async => const AiReturnPredictionScreen(),
              ),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.aiPromotionDesigner,
            name: 'ai-promotion-designer',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: LazyScreen(
                screenBuilder: () async => const AiPromotionDesignerScreen(),
              ),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.aiChatWithData,
            name: 'ai-chat-with-data',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: LazyScreen(
                screenBuilder: () async => const AiChatWithDataScreen(),
              ),
              transitionsBuilder: _fadeTransition,
            ),
          ),

          // ====================================================================
          // ECOMMERCE ROUTE
          // ====================================================================
          GoRoute(
            path: AppRoutes.ecommerce,
            name: 'ecommerce',
            builder: (context, state) => const EcommerceScreen(),
          ),

          // ====================================================================
          // WALLET ROUTE
          // ====================================================================
          GoRoute(
            path: AppRoutes.wallet,
            name: 'wallet',
            builder: (context, state) => const WalletScreen(),
          ),

          // ====================================================================
          // SUBSCRIPTION ROUTE
          // ====================================================================
          GoRoute(
            path: AppRoutes.subscription,
            name: 'subscription',
            builder: (context, state) => const SubscriptionScreen(),
          ),

          // ====================================================================
          // COMPLAINTS REPORT ROUTE
          // ====================================================================
          GoRoute(
            path: AppRoutes.complaintsReport,
            name: 'complaints-report',
            builder: (context, state) => const ComplaintsReportScreen(),
          ),

          // ====================================================================
          // MEDIA LIBRARY ROUTE
          // ====================================================================
          GoRoute(
            path: AppRoutes.mediaLibrary,
            name: 'media-library',
            builder: (context, state) => const MediaLibraryScreen(),
          ),

          // ====================================================================
          // DEVICE LOG ROUTE
          // ====================================================================
          GoRoute(
            path: AppRoutes.deviceLog,
            name: 'device-log',
            builder: (context, state) => const DeviceLogScreen(),
          ),

          // ====================================================================
          // SHIPPING GATEWAYS ROUTE
          // ====================================================================
          GoRoute(
            path: AppRoutes.settingsShipping,
            name: 'settings-shipping',
            builder: (context, state) => const ShippingGatewaysScreen(),
          ),
        ],
      ),
    ];
}
