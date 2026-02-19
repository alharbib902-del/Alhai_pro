import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'routes.dart';
import '../../screens/screens.dart';
import '../../widgets/common/lazy_screen.dart';
import '../../services/ai_invoice_service.dart';

/// App Router Configuration
///
/// Central routing configuration for the POS app.
/// Uses GoRouter with all P0 routes configured.
///
/// Performance optimizations:
/// - Lazy loading for heavy screens
/// - Custom shimmer loading screens
/// - Screen preloading for critical paths
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

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // ============================================================================
      // AUTH ROUTES
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
      // MAIN ROUTES
      // ============================================================================
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
      
      // POS routes - استخدام lazy loading للشاشات الثقيلة
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
        path: AppRoutes.posPayment,
        name: 'pos-payment',
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: AppRoutes.posReceipt,
        name: 'pos-receipt',
        builder: (context, state) => const ReceiptScreen(),
      ),
      GoRoute(
        path: AppRoutes.posSearch,
        name: 'pos-search',
        builder: (context, state) => const PosScreen(), // TODO: Create search screen
      ),
      GoRoute(
        path: AppRoutes.quickSale,
        name: 'quick-sale',
        builder: (context, state) => const PosScreen(), // TODO: Create quick sale screen
      ),

      // ============================================================================
      // PRODUCTS ROUTES - مع lazy loading
      // ============================================================================
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
          final id = state.pathParameters['id'] ?? '';
          return ProductFormScreen(productId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.productDetail,
        name: 'product-detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ProductDetailScreen(productId: id);
        },
      ),

      // ============================================================================
      // CATEGORIES ROUTE
      // ============================================================================
      GoRoute(
        path: AppRoutes.categories,
        name: 'categories',
        builder: (context, state) => const CategoriesScreen(),
      ),

      // ============================================================================
      // RETURNS ROUTE
      // ============================================================================
      GoRoute(
        path: AppRoutes.returns,
        name: 'returns',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ReturnsScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ============================================================================
      // VOID TRANSACTION ROUTE
      // ============================================================================
      GoRoute(
        path: AppRoutes.voidTransaction,
        name: 'void-transaction',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const VoidTransactionScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ============================================================================
      // ORDERS ROUTE
      // ============================================================================
      GoRoute(
        path: AppRoutes.orders,
        name: 'orders',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OrdersScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ============================================================================
      // INVOICES ROUTE
      // ============================================================================
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
          final id = state.pathParameters['id'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: InvoiceDetailScreen(invoiceId: id),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),

      // ============================================================================
      // OTHER ROUTES - مع lazy loading
      // ============================================================================
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
          final id = state.pathParameters['id'] ?? '';
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
          final id = state.pathParameters['id'] ?? '';
          final name = state.uri.queryParameters['name'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: CustomerLedgerScreen(accountId: id, customerName: name),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
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

      // ============================================================================
      // SETTINGS ROUTES
      // ============================================================================
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

      // ============================================================================
      // EXPENSES ROUTES
      // ============================================================================
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

      // ============================================================================
      // CASH DRAWER ROUTES
      // ============================================================================
      GoRoute(
        path: AppRoutes.cashDrawer,
        name: 'cash-drawer',
        builder: (context, state) => const CashDrawerScreen(),
      ),

      // ============================================================================
      // DEBTS ROUTES
      // ============================================================================
      GoRoute(
        path: AppRoutes.monthlyClose,
        name: 'monthly-close',
        builder: (context, state) => const MonthlyCloseScreen(),
      ),

      // ============================================================================
      // SHIFTS ROUTES
      // ============================================================================
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

      // ============================================================================
      // PURCHASES ROUTES
      // ============================================================================
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
          final invoiceData = state.extra as AiInvoiceResult;
          return AiInvoiceReviewScreen(invoiceData: invoiceData);
        },
      ),

      // ============================================================================
      // SUPPLIERS ROUTES (extended)
      // ============================================================================
      GoRoute(
        path: AppRoutes.supplierForm,
        name: 'supplier-form',
        builder: (context, state) => const SupplierFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.supplierDetail,
        name: 'supplier-detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return SupplierDetailScreen(supplierId: id);
        },
      ),

      // ============================================================================
      // MARKETING ROUTES
      // ============================================================================
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

      // ============================================================================
      // PROMOTIONS ROUTES
      // ============================================================================
      GoRoute(
        path: AppRoutes.smartPromotions,
        name: 'smart-promotions',
        builder: (context, state) => const SmartPromotionsScreen(),
      ),

      // ============================================================================
      // LOYALTY ROUTES
      // ============================================================================
      GoRoute(
        path: AppRoutes.loyalty,
        name: 'loyalty',
        builder: (context, state) => const LoyaltyProgramScreen(),
      ),

      // ============================================================================
      // NOTIFICATIONS ROUTES
      // ============================================================================
      GoRoute(
        path: AppRoutes.notificationsCenter,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // ============================================================================
      // PRINTING ROUTES
      // ============================================================================
      GoRoute(
        path: AppRoutes.printQueue,
        name: 'print-queue',
        builder: (context, state) => const PrintQueueScreen(),
      ),

      // ============================================================================
      // SYNC ROUTES
      // ============================================================================
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

      // ============================================================================
      // DRIVERS ROUTES
      // ============================================================================
      GoRoute(
        path: AppRoutes.drivers,
        name: 'drivers',
        builder: (context, state) => const DriverManagementScreen(),
      ),

      // ============================================================================
      // BRANCHES ROUTES
      // ============================================================================
      GoRoute(
        path: AppRoutes.branches,
        name: 'branches',
        builder: (context, state) => const BranchManagementScreen(),
      ),

      // ============================================================================
      // PROFILE ROUTES
      // ============================================================================
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // ============================================================================
      // SETTINGS ROUTES (extended)
      // ============================================================================
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

      // ============================================================================
      // ONBOARDING ROUTES
      // ============================================================================
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => Scaffold(
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
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    ),
  );
}
