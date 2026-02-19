/// Route constants for the POS App
/// 
/// All route paths should be defined here to avoid hardcoding strings.
library;

/// Route paths for navigation
class AppRoutes {
  AppRoutes._();

  // ============================================================================
  // AUTH ROUTES
  // ============================================================================
  
  /// Splash screen - entry point
  static const String splash = '/splash';
  
  /// Login with OTP
  static const String login = '/login';
  
  /// Store selection after login
  static const String storeSelect = '/store-select';

  // ============================================================================
  // MAIN ROUTES
  // ============================================================================
  
  /// Home dashboard
  static const String home = '/home';
  
  /// Dashboard (main)
  static const String dashboard = '/dashboard';
  
  /// POS main screen
  static const String pos = '/pos';
  
  /// Payment screen
  static const String posPayment = '/pos/payment';
  
  /// Receipt screen
  static const String posReceipt = '/pos/receipt';
  
  /// Product search
  static const String posSearch = '/pos/search';
  
  /// Cart screen
  static const String posCart = '/pos/cart';
  
  /// Quick sale
  static const String quickSale = '/pos/quick-sale';

  // ============================================================================
  // PRODUCTS ROUTES
  // ============================================================================
  
  /// Products list
  static const String products = '/products';
  
  /// Add new product
  static const String productsAdd = '/products/add';
  
  /// Edit product - use productsEditPath(id)
  static const String productsEdit = '/products/edit/:id';

  /// Helper to build product edit route
  static String productsEditPath(String id) => '/products/edit/$id';

  /// Product detail - use productDetail(id)
  static const String productDetail = '/products/:id';

  /// Helper to build product detail route
  static String productDetailPath(String id) => '/products/$id';

  /// Product categories
  static const String categories = '/categories';

  // ============================================================================
  // INVENTORY ROUTES
  // ============================================================================
  
  /// Inventory list
  static const String inventory = '/inventory';

  // ============================================================================
  // CUSTOMERS ROUTES
  // ============================================================================
  
  /// Customers list
  static const String customers = '/customers';

  /// Customer detail - use customerDetailPath(id)
  static const String customerDetail = '/customers/:id';

  /// Helper to build customer detail route
  static String customerDetailPath(String id) => '/customers/$id';

  /// Customer ledger - use customerLedgerPath(id)
  static const String customerLedger = '/customers/:id/ledger';

  /// Helper to build customer ledger route
  static String customerLedgerPath(String id) => '/customers/$id/ledger';

  // ============================================================================
  // RETURNS ROUTES
  // ============================================================================

  /// Returns list
  static const String returns = '/returns';

  /// Void Transaction
  static const String voidTransaction = '/void-transaction';

  // ============================================================================
  // ORDERS ROUTES
  // ============================================================================

  /// Orders history list
  static const String orders = '/orders';

  // ============================================================================
  // INVOICES ROUTES
  // ============================================================================

  /// Invoices list
  static const String invoices = '/invoices';

  /// Invoice detail - use invoiceDetailPath(id)
  static const String invoiceDetail = '/invoices/:id';

  /// Helper to build invoice detail route
  static String invoiceDetailPath(String id) => '/invoices/$id';

  // ============================================================================
  // REPORTS ROUTES
  // ============================================================================

  /// Reports list
  static const String reports = '/reports';

  // ============================================================================
  // SUPPLIERS ROUTES
  // ============================================================================
  
  /// Suppliers list
  static const String suppliers = '/suppliers';

  // ============================================================================
  // SETTINGS ROUTES
  // ============================================================================
  
  /// General settings
  static const String settings = '/settings';
  
  /// Printer settings
  static const String settingsPrinter = '/settings/printer';

  /// Language settings
  static const String settingsLanguage = '/settings/language';

  /// Theme settings
  static const String settingsTheme = '/settings/theme';

  // ============================================================================
  // EXPENSES ROUTES
  // ============================================================================

  /// Expenses list
  static const String expenses = '/expenses';

  /// Expense categories
  static const String expenseCategories = '/expenses/categories';

  // ============================================================================
  // CASH DRAWER ROUTES
  // ============================================================================

  /// Cash drawer management
  static const String cashDrawer = '/cash-drawer';

  // ============================================================================
  // DEBTS ROUTES
  // ============================================================================

  /// Monthly close
  static const String monthlyClose = '/debts/monthly-close';

  // ============================================================================
  // SHIFTS ROUTES
  // ============================================================================

  /// Shifts list
  static const String shifts = '/shifts';

  /// Open shift
  static const String shiftOpen = '/shifts/open';

  /// Close shift
  static const String shiftClose = '/shifts/close';

  /// Shift summary
  static const String shiftSummary = '/shifts/summary';

  // ============================================================================
  // PURCHASES ROUTES
  // ============================================================================

  /// Purchase form
  static const String purchaseForm = '/purchases/new';

  /// Smart reorder
  static const String smartReorder = '/purchases/smart-reorder';

  /// AI invoice import
  static const String aiInvoiceImport = '/purchases/ai-import';

  /// AI invoice review
  static const String aiInvoiceReview = '/purchases/ai-review';

  // ============================================================================
  // SUPPLIERS ROUTES (extended)
  // ============================================================================

  /// Supplier detail
  static const String supplierDetail = '/suppliers/:id';

  /// Helper to build supplier detail route
  static String supplierDetailPath(String id) => '/suppliers/$id';

  /// Supplier form
  static const String supplierForm = '/suppliers/new';

  // ============================================================================
  // MARKETING ROUTES
  // ============================================================================

  /// Discounts
  static const String discounts = '/marketing/discounts';

  /// Coupons
  static const String coupons = '/marketing/coupons';

  /// Special offers
  static const String specialOffers = '/marketing/offers';

  // ============================================================================
  // PROMOTIONS ROUTES
  // ============================================================================

  /// Smart promotions
  static const String smartPromotions = '/promotions';

  // ============================================================================
  // LOYALTY ROUTES
  // ============================================================================

  /// Loyalty program
  static const String loyalty = '/loyalty';

  // ============================================================================
  // NOTIFICATIONS ROUTES
  // ============================================================================

  /// Notifications center
  static const String notificationsCenter = '/notifications';

  // ============================================================================
  // PRINTING ROUTES
  // ============================================================================

  /// Print queue
  static const String printQueue = '/print-queue';

  // ============================================================================
  // SYNC ROUTES
  // ============================================================================

  /// Sync status
  static const String syncStatus = '/sync';

  /// Pending transactions
  static const String pendingTransactions = '/sync/pending';

  /// Conflict resolution
  static const String conflictResolution = '/sync/conflicts';

  // ============================================================================
  // DRIVERS ROUTES
  // ============================================================================

  /// Driver management
  static const String drivers = '/drivers';

  // ============================================================================
  // BRANCHES ROUTES
  // ============================================================================

  /// Branch management
  static const String branches = '/branches';

  // ============================================================================
  // PROFILE ROUTES
  // ============================================================================

  /// User profile
  static const String profile = '/profile';

  // ============================================================================
  // SETTINGS ROUTES (extended)
  // ============================================================================

  /// Store settings
  static const String settingsStore = '/settings/store';

  /// POS settings
  static const String settingsPos = '/settings/pos';

  /// Payment devices settings
  static const String settingsPaymentDevices = '/settings/payment-devices';

  /// Barcode settings
  static const String settingsBarcode = '/settings/barcode';

  /// Receipt template
  static const String settingsReceipt = '/settings/receipt';

  /// Tax settings
  static const String settingsTax = '/settings/tax';

  /// Discount settings
  static const String settingsDiscounts = '/settings/discounts';

  /// Interest settings
  static const String settingsInterest = '/settings/interest';

  /// Security settings
  static const String settingsSecurity = '/settings/security';

  /// Users management
  static const String settingsUsers = '/settings/users';

  /// Roles & permissions
  static const String settingsRoles = '/settings/roles';

  /// Activity log
  static const String settingsActivityLog = '/settings/activity-log';

  /// Backup settings
  static const String settingsBackup = '/settings/backup';

  /// Notifications settings
  static const String settingsNotifications = '/settings/notifications';

  /// ZATCA compliance
  static const String settingsZatca = '/settings/zatca';

  /// Help & support
  static const String settingsHelp = '/settings/help';

  // ============================================================================
  // ONBOARDING ROUTES
  // ============================================================================

  /// Onboarding screen - first time users
  static const String onboarding = '/onboarding';
}
