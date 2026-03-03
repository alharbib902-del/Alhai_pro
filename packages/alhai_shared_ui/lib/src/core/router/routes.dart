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

  /// Expiry tracking
  static const String expiryTracking = '/inventory/expiry-tracking';

  /// Inventory alerts (low stock)
  static const String inventoryAlerts = '/inventory/alerts';

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

  /// Customer debt overview
  static const String customerDebt = '/customers/debt';

  /// Customer analytics dashboard
  static const String customerAnalytics = '/customers/analytics';

  // ============================================================================
  // RETURNS ROUTES
  // ============================================================================

  /// Returns list
  static const String returns = '/returns';

  /// Refund request (select items from sale)
  static const String refundRequest = '/returns/request';

  /// Refund reason selection
  static const String refundReason = '/returns/reason';

  /// Refund receipt - use refundReceiptPath(id)
  static const String refundReceipt = '/returns/receipt/:id';

  /// Helper to build refund receipt route
  static String refundReceiptPath(String id) => '/returns/receipt/$id';

  /// Void Transaction
  static const String voidTransaction = '/void-transaction';

  // ============================================================================
  // ORDERS ROUTES
  // ============================================================================

  /// Orders history list
  static const String orders = '/orders';

  /// Sales list (alias for invoices)
  static const String sales = '/sales';

  /// Order tracking (active orders)
  static const String orderTracking = '/orders/tracking';

  /// Order history
  static const String orderHistory = '/orders/history';

  /// Sale detail - use saleDetailPath(id)
  static const String saleDetail = '/sales/:id';

  /// Helper to build sale detail route
  static String saleDetailPath(String id) => '/sales/$id';

  /// Exchange screen
  static const String exchange = '/returns/exchange';

  /// Split receipt - use splitReceiptPath(orderId)
  static const String splitReceipt = '/sales/split-receipt/:id';

  /// Helper to build split receipt route
  static String splitReceiptPath(String id) => '/sales/split-receipt/$id';

  /// Payment history
  static const String paymentHistory = '/payments/history';

  /// Split refund - use splitRefundPath(orderId)
  static const String splitRefund = '/returns/split-refund/:id';

  /// Helper to build split refund route
  static String splitRefundPath(String id) => '/returns/split-refund/$id';

  /// Customer accounts
  static const String customerAccounts = '/customers/accounts';

  /// New transaction for customer
  static const String newTransaction = '/customers/transaction';

  /// Apply interest
  static const String applyInterest = '/customers/apply-interest';

  /// Create invoice
  static const String createInvoice = '/invoices/create';

  /// Quick add product
  static const String quickAddProduct = '/products/quick-add';

  /// Edit price - use editPricePath(id)
  static const String editPrice = '/products/edit-price/:id';

  /// Helper to build edit price route
  static String editPricePath(String id) => '/products/edit-price/$id';

  /// Print barcode
  static const String printBarcode = '/products/print-barcode';

  /// Cashier categories view
  static const String cashierCategories = '/products/categories-view';

  /// Price labels
  static const String priceLabels = '/products/price-labels';

  /// Edit inventory - use editInventoryPath(id)
  static const String editInventory = '/inventory/edit/:id';

  /// Helper to build edit inventory route
  static String editInventoryPath(String id) => '/inventory/edit/$id';

  /// Add inventory
  static const String addInventory = '/inventory/add';

  /// Remove inventory
  static const String removeInventory = '/inventory/remove';

  /// Transfer inventory
  static const String transferInventory = '/inventory/transfer';

  /// Stock take
  static const String stockTake = '/inventory/stock-take';

  /// Wastage
  static const String wastage = '/inventory/wastage';

  /// Active offers
  static const String activeOffers = '/offers/active';

  /// Coupon code
  static const String couponCode = '/offers/coupon';

  /// Bundle deals
  static const String bundleDeals = '/offers/bundles';

  /// Payment reports
  static const String paymentReports = '/reports/payments';

  /// Custom report
  static const String customReport = '/reports/custom';

  /// Add payment device
  static const String addPaymentDevice = '/settings/add-payment-device';

  /// Keyboard shortcuts
  static const String settingsKeyboardShortcuts = '/settings/keyboard-shortcuts';

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

  /// Daily sales report
  static const String dailySalesReport = '/reports/daily-sales';

  /// Top products report
  static const String topProductsReport = '/reports/top-products';

  /// Cash flow report
  static const String cashFlowReport = '/reports/cash-flow';

  /// Customer report
  static const String customerReport = '/reports/customers';

  /// Inventory report
  static const String inventoryReport = '/reports/inventory';

  /// Manager approval
  static const String managerApproval = '/manager-approval';

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

  /// Supplier purchase returns
  static const String supplierReturns = '/purchases/supplier-returns';

  // ============================================================================
  // PURCHASES LIST & DETAILS ROUTES (new)
  // ============================================================================

  /// Purchases list
  static const String purchasesList = '/purchases';

  /// Purchase detail
  static const String purchaseDetail = '/purchases/:id';

  /// Helper to build purchase detail route
  static String purchaseDetailPath(String id) => '/purchases/$id';

  /// Receiving goods
  static const String receivingGoods = '/purchases/:id/receive';

  /// Helper to build receiving goods route
  static String receivingGoodsPath(String id) => '/purchases/$id/receive';

  /// Send to distributor
  static const String sendToDistributor = '/purchases/:id/send';

  /// Helper to build send to distributor route
  static String sendToDistributorPath(String id) => '/purchases/$id/send';

  // ============================================================================
  // CASHIER PURCHASES ROUTES (new)
  // ============================================================================

  /// Cashier receiving goods
  static const String cashierReceiving = '/cashier-receiving';

  /// Cashier purchase request
  static const String cashierPurchaseRequest = '/purchase-request';

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
  // EMPLOYEES ROUTES
  // ============================================================================

  /// Employees management
  static const String employees = '/employees';

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

  /// Privacy policy
  static const String settingsPrivacy = '/settings/privacy';

  /// Help & support
  static const String settingsHelp = '/settings/help';

  // ============================================================================
  // AI ROUTES
  // ============================================================================

  /// AI Assistant - المساعد الذكي
  static const String aiAssistant = '/ai/assistant';

  /// AI Sales Forecasting - التنبؤ بالمبيعات
  static const String aiSalesForecasting = '/ai/sales-forecasting';

  /// AI Smart Pricing - التسعير الذكي
  static const String aiSmartPricing = '/ai/smart-pricing';

  /// AI Fraud Detection - كشف الاحتيال
  static const String aiFraudDetection = '/ai/fraud-detection';

  /// AI Basket Analysis - تحليل سلة المشتريات
  static const String aiBasketAnalysis = '/ai/basket-analysis';

  /// AI Customer Recommendations - توصيات العملاء
  static const String aiCustomerRecommendations = '/ai/customer-recommendations';

  /// AI Smart Inventory - المخزون الذكي
  static const String aiSmartInventory = '/ai/smart-inventory';

  /// AI Competitor Analysis - تحليل المنافسين
  static const String aiCompetitorAnalysis = '/ai/competitor-analysis';

  /// AI Smart Reports - التقارير الذكية
  static const String aiSmartReports = '/ai/smart-reports';

  /// AI Staff Analytics - تحليل الموظفين
  static const String aiStaffAnalytics = '/ai/staff-analytics';

  /// AI Product Recognition - التعرف على المنتجات
  static const String aiProductRecognition = '/ai/product-recognition';

  /// AI Sentiment Analysis - تحليل المشاعر
  static const String aiSentimentAnalysis = '/ai/sentiment-analysis';

  /// AI Return Prediction - التنبؤ بالمرتجعات
  static const String aiReturnPrediction = '/ai/return-prediction';

  /// AI Promotion Designer - تصميم العروض
  static const String aiPromotionDesigner = '/ai/promotion-designer';

  /// AI Chat with Data - الدردشة مع البيانات
  static const String aiChatWithData = '/ai/chat-with-data';

  // ============================================================================
  // ECOMMERCE ROUTES
  // ============================================================================

  /// E-Commerce / Online Store management
  static const String ecommerce = '/ecommerce';

  // ============================================================================
  // WALLET ROUTES
  // ============================================================================

  /// E-Wallet
  static const String wallet = '/wallet';

  // ============================================================================
  // SUBSCRIPTION ROUTES
  // ============================================================================

  /// Subscription management
  static const String subscription = '/subscription';

  // ============================================================================
  // COMPLAINTS ROUTES
  // ============================================================================

  /// Complaints report
  static const String complaintsReport = '/reports/complaints';

  // ============================================================================
  // MEDIA ROUTES
  // ============================================================================

  /// Media library
  static const String mediaLibrary = '/media';

  // ============================================================================
  // DEVICES ROUTES
  // ============================================================================

  /// Device log
  static const String deviceLog = '/devices';

  // ============================================================================
  // SHIPPING ROUTES
  // ============================================================================

  /// Shipping gateways settings
  static const String settingsShipping = '/settings/shipping';

  // ============================================================================
  // ONBOARDING ROUTES
  // ============================================================================

  /// Onboarding screen - first time users
  static const String onboarding = '/onboarding';

  // ============================================================================
  // NEW FEATURE ROUTES
  // ============================================================================

  /// Gift cards management
  static const String giftCards = '/marketing/gift-cards';

  /// Employee attendance tracking
  static const String employeeAttendance = '/employees/attendance';

  /// Employee commissions
  static const String employeeCommissions = '/employees/commissions';

  /// Employee profile detail - use employeeProfilePath(id)
  static const String employeeProfile = '/employees/profile/:userId';

  /// Helper to build employee profile route
  static String employeeProfilePath(String id) => '/employees/profile/$id';

  /// Online orders management
  static const String onlineOrders = '/ecommerce/online-orders';

  /// Damaged goods write-off
  static const String damagedGoods = '/inventory/damaged-goods';

  /// Price lists management
  static const String priceLists = '/products/price-lists';

  /// Customer groups management
  static const String customerGroups = '/customers/groups';

  /// Delivery zones management
  static const String deliveryZones = '/ecommerce/delivery-zones';

  /// WhatsApp management settings
  static const String settingsWhatsApp = '/settings/whatsapp';

  /// Kiosk mode (self-service POS)
  static const String kioskMode = '/pos/kiosk';
}
