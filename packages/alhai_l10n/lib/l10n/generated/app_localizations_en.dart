// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'POS System';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get phone => 'Phone Number';

  @override
  String get phoneHint => '05xxxxxxxx';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get phoneInvalid => 'Invalid phone number';

  @override
  String get otp => 'Verification Code';

  @override
  String get otpHint => 'Enter verification code';

  @override
  String get otpSent => 'Verification code sent';

  @override
  String get otpResend => 'Resend code';

  @override
  String get otpExpired => 'Verification code expired';

  @override
  String get otpInvalid => 'Invalid verification code';

  @override
  String otpResendIn(int seconds) {
    return 'Resend in $seconds seconds';
  }

  @override
  String get pin => 'PIN Code';

  @override
  String get pinHint => 'Enter PIN code';

  @override
  String get pinRequired => 'PIN code is required';

  @override
  String get pinInvalid => 'Invalid PIN code';

  @override
  String pinAttemptsRemaining(int count) {
    return 'Attempts remaining: $count';
  }

  @override
  String pinLocked(int minutes) {
    return 'Account locked. Try after $minutes minutes';
  }

  @override
  String get home => 'Home';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get pos => 'Point of Sale';

  @override
  String get products => 'Products';

  @override
  String get categories => 'Categories';

  @override
  String get inventory => 'Inventory';

  @override
  String get customers => 'Customers';

  @override
  String get orders => 'Orders';

  @override
  String get invoices => 'Invoices';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get sales => 'Sales';

  @override
  String get salesAnalytics => 'Sales Analytics';

  @override
  String get refund => 'Refund';

  @override
  String get todaySales => 'Today\'s Sales';

  @override
  String get totalSales => 'Total Sales';

  @override
  String get averageSale => 'Average Sale';

  @override
  String get cart => 'Cart';

  @override
  String get cartEmpty => 'Cart is empty';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get removeFromCart => 'Remove from Cart';

  @override
  String get clearCart => 'Clear Cart';

  @override
  String get checkout => 'Checkout';

  @override
  String get payment => 'Payment';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get cash => 'Cash';

  @override
  String get card => 'Card';

  @override
  String get credit => 'Credit';

  @override
  String get transfer => 'Transfer';

  @override
  String get paymentSuccess => 'Payment successful';

  @override
  String get paymentFailed => 'Payment failed';

  @override
  String get price => 'Price';

  @override
  String get quantity => 'Quantity';

  @override
  String get total => 'Total';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discount => 'Discount';

  @override
  String get tax => 'Tax';

  @override
  String get vat => 'VAT';

  @override
  String get grandTotal => 'Grand Total';

  @override
  String get product => 'product';

  @override
  String get productName => 'Product Name';

  @override
  String get productCode => 'Product Code';

  @override
  String get barcode => 'Barcode';

  @override
  String get sku => 'SKU';

  @override
  String get stock => 'Stock';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String get inStock => 'In Stock';

  @override
  String get customer => 'Customer';

  @override
  String get customerName => 'Customer Name';

  @override
  String get customerPhone => 'Customer Phone';

  @override
  String get debt => 'Debt';

  @override
  String get balance => 'Balance';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Search here...';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get all => 'All';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get submit => 'Submit';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No data';

  @override
  String get noResults => 'No results';

  @override
  String get error => 'Error';

  @override
  String pageNotFoundPath(String path) {
    return 'Page not found: $path';
  }

  @override
  String get noInvoiceDataAvailable => 'No invoice data available';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get tryAgain => 'Try again';

  @override
  String get connectionError => 'Connection error';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get offline => 'Offline';

  @override
  String get online => 'Online';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get shift => 'Shift';

  @override
  String get openShift => 'Open Shift';

  @override
  String get closeShift => 'Close Shift';

  @override
  String get shiftSummary => 'Shift Summary';

  @override
  String get cashDrawer => 'Cash Drawer';

  @override
  String get receipt => 'Receipt';

  @override
  String get printReceipt => 'Print Receipt';

  @override
  String get shareReceipt => 'Share Receipt';

  @override
  String get sync => 'Sync';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncComplete => 'Sync complete';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get lastSync => 'Last sync';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get urdu => 'اردو';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get filipino => 'Filipino';

  @override
  String get bengali => 'বাংলা';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemMode => 'System Mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get security => 'Security';

  @override
  String get printer => 'Printer';

  @override
  String get backup => 'Backup';

  @override
  String get help => 'Help';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get copyright => 'All rights reserved';

  @override
  String get deleteConfirmTitle => 'Confirm Delete';

  @override
  String get deleteConfirmMessage => 'Are you sure you want to delete?';

  @override
  String get logoutConfirmTitle => 'Confirm Logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to logout?';

  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidFormat => 'Invalid format';

  @override
  String minLength(int min) {
    return 'Must be at least $min characters';
  }

  @override
  String maxLength(int max) {
    return 'Must be less than $max characters';
  }

  @override
  String get welcomeTitle => 'Welcome Back! 👋';

  @override
  String get welcomeSubtitle =>
      'Sign in to manage your store easily and quickly';

  @override
  String get welcomeSubtitleShort => 'Sign in to manage your store';

  @override
  String get brandName => 'Al-Hal POS';

  @override
  String get brandTagline => 'Smart Point of Sale System';

  @override
  String get enterPhoneToContinue => 'Enter your phone number to continue';

  @override
  String get pleaseEnterValidPhone => 'Please enter a valid phone number';

  @override
  String get otpSentViaWhatsApp => 'Verification code sent via WhatsApp';

  @override
  String get otpResent => 'Verification code resent';

  @override
  String get enterOtpFully => 'Please enter the complete verification code';

  @override
  String get maxAttemptsReached =>
      'Maximum attempts reached. Please request a new code';

  @override
  String waitMinutes(int minutes) {
    return 'Maximum attempts reached. Wait $minutes minutes';
  }

  @override
  String waitSeconds(int seconds) {
    return 'Please wait $seconds seconds';
  }

  @override
  String resendIn(String time) {
    return 'Resend ($time)';
  }

  @override
  String get resendCode => 'Resend code';

  @override
  String get changeNumber => 'Change number';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String remainingAttempts(int count) {
    return 'Remaining attempts: $count';
  }

  @override
  String get technicalSupport => 'Technical Support';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get allRightsReserved => '© 2026 Al-Hal System. All rights reserved.';

  @override
  String get dayMode => 'Day Mode';

  @override
  String get nightMode => 'Night Mode';

  @override
  String get selectBranch => 'Select Branch';

  @override
  String get selectBranchDesc => 'Select the branch you want to work on';

  @override
  String get availableBranches => 'Available Branches';

  @override
  String branchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count branches',
      one: '1 branch',
      zero: 'No branches',
    );
    return '$_temp0';
  }

  @override
  String branchSelected(String name) {
    return 'Selected $name';
  }

  @override
  String get addBranch => 'Add New Branch';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get tryDifferentSearch => 'Try different search terms';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageChangeInfo =>
      'Choose your preferred display language. Changes will be applied immediately.';

  @override
  String get centralManagement => 'Central Management';

  @override
  String get centralManagementDesc =>
      'Control all your branches and warehouses from one place. Get instant reports and inventory sync across all POS points.';

  @override
  String get selectBranchToContinue => 'Select Branch to Continue';

  @override
  String get youHaveAccessToBranches =>
      'You have access to the following branches. Select one to start.';

  @override
  String get searchForBranch => 'Search for branch...';

  @override
  String get openNow => 'Open Now';

  @override
  String closedOpensAt(String time) {
    return 'Closed (Opens $time)';
  }

  @override
  String get loggedInAs => 'Logged in as';

  @override
  String get support247 => '24/7 Support';

  @override
  String get analyticsTools => 'Analytics Tools';

  @override
  String get uptime => 'Uptime';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get searchPlaceholder => 'General search...';

  @override
  String get mainBranch => 'Main Branch (Riyadh)';

  @override
  String get todaySalesLabel => 'Today\'s Sales';

  @override
  String get ordersCountLabel => 'Orders Count';

  @override
  String get newCustomersLabel => 'New Customers';

  @override
  String get stockAlertsLabel => 'Stock Alerts';

  @override
  String get productsUnit => 'products';

  @override
  String get salesAnalysis => 'Sales Analysis';

  @override
  String get storePerformance => 'Store performance this week';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get quickAction => 'Quick Action';

  @override
  String get newSale => 'New Sale';

  @override
  String get addProduct => 'Add Product';

  @override
  String get returnItem => 'Return';

  @override
  String get dailyReport => 'Daily Report';

  @override
  String get closeDay => 'Close Day';

  @override
  String get topSelling => 'Top Selling';

  @override
  String ordersToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders today',
      one: '1 order today',
      zero: 'No orders today',
    );
    return '$_temp0';
  }

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get viewAll => 'View All';

  @override
  String get orderNumber => 'Order Number';

  @override
  String get time => 'Time';

  @override
  String get status => 'Status';

  @override
  String get amount => 'Amount';

  @override
  String get action => 'Action';

  @override
  String get completed => 'Completed';

  @override
  String get returned => 'Returned';

  @override
  String get pending => 'Pending';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get guestCustomer => 'Guest Customer';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String get posSystem => 'POS System';

  @override
  String get branchManager => 'Manager';

  @override
  String get settingsSection => 'Settings';

  @override
  String get systemSettings => 'System Settings';

  @override
  String get sar => 'SAR';

  @override
  String get daily => 'Daily';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get cashCustomer => 'Cash Customer';

  @override
  String get noTransactionsToday => 'No transactions today';

  @override
  String get comparedToYesterday => 'Compared to yesterday';

  @override
  String get ordersText => 'orders today';

  @override
  String get storeManagement => 'Store Management';

  @override
  String get finance => 'Finance';

  @override
  String get teamSection => 'Team';

  @override
  String get fullscreen => 'Fullscreen';

  @override
  String goodMorningName(String name) {
    return 'Good Morning, $name!';
  }

  @override
  String goodEveningName(String name) {
    return 'Good Evening, $name!';
  }

  @override
  String get shoppingCart => 'Shopping Cart';

  @override
  String get selectOrSearchCustomer => 'Select or search customer';

  @override
  String get newCustomer => 'New';

  @override
  String get draft => 'Draft';

  @override
  String get pay => 'Pay';

  @override
  String get haveCoupon => 'Have a discount coupon?';

  @override
  String discountPercent(String percent) {
    return 'Discount $percent%';
  }

  @override
  String get openDrawer => 'Open Drawer';

  @override
  String get suspend => 'Suspend';

  @override
  String get quantitySoldOut => 'Sold Out';

  @override
  String get noProducts => 'No products';

  @override
  String get addProductsToStart => 'Add products to start';

  @override
  String get undoComingSoon => 'Undo (coming soon)';

  @override
  String undoneRemoved(String name) {
    return 'Undone: removed $name';
  }

  @override
  String undoneAdded(String name) {
    return 'Undone: restored $name';
  }

  @override
  String undoneQtyChanged(String name, int from, int to) {
    return 'Undone: $name qty $from → $to';
  }

  @override
  String get nothingToUndo => 'Nothing to undo';

  @override
  String get employees => 'Employees';

  @override
  String get loyaltyProgram => 'Loyalty Program';

  @override
  String get newBadge => 'New';

  @override
  String get technicalSupportShort => 'Technical Support';

  @override
  String get productDetails => 'Product Details';

  @override
  String get stockMovements => 'Stock Movements';

  @override
  String get priceHistory => 'Price History';

  @override
  String get salesHistory => 'Sales History';

  @override
  String get available => 'Available';

  @override
  String get alertLevel => 'Alert Level';

  @override
  String get reorderPoint => 'Reorder Point';

  @override
  String get revenue => 'Revenue';

  @override
  String get supplier => 'Supplier';

  @override
  String get lastSale => 'Last Sale';

  @override
  String get printLabel => 'Print Label';

  @override
  String get copied => 'Copied';

  @override
  String copiedToClipboard(String label) {
    return '$label copied';
  }

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get profitMargin => 'Profit Margin';

  @override
  String get sellingPrice => 'Selling Price';

  @override
  String get costPrice => 'Cost Price';

  @override
  String get description => 'Description';

  @override
  String get noDescription => 'No description';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get stockStatus => 'Stock Status';

  @override
  String get currentStock => 'Current Stock';

  @override
  String get unit => 'Unit';

  @override
  String get units => 'units';

  @override
  String get date => 'Date';

  @override
  String get type => 'Type';

  @override
  String get reference => 'Reference';

  @override
  String get newBalance => 'New Balance';

  @override
  String get oldPrice => 'Old Price';

  @override
  String get newPrice => 'New Price';

  @override
  String get reason => 'Reason';

  @override
  String get invoiceNumber => 'Invoice #';

  @override
  String get categoryLabel => 'Category';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get noSupplier => 'No supplier';

  @override
  String get moreOptions => 'More Options';

  @override
  String get noStockMovements => 'No stock movements';

  @override
  String get noPriceHistory => 'No price history';

  @override
  String get noSalesHistory => 'No sales history';

  @override
  String get sale => 'Sale';

  @override
  String get purchase => 'Purchase';

  @override
  String get adjustment => 'Adjustment';

  @override
  String get returnText => 'Return';

  @override
  String get waste => 'Waste';

  @override
  String get initialStock => 'Initial Stock';

  @override
  String get searchByNameOrBarcode => 'Search by name or barcode...';

  @override
  String get hideFilters => 'Hide Filters';

  @override
  String get showFilters => 'Show Filters';

  @override
  String get sortByName => 'By name';

  @override
  String get sortByPrice => 'Price';

  @override
  String get sortByStock => 'Stock';

  @override
  String get sortByRecent => 'Recent';

  @override
  String get allItems => 'All';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get noBarcode => 'No barcode';

  @override
  String stockCount(int count) {
    return 'Stock: $count';
  }

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get addTheProduct => 'Add Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get newProduct => 'New Product';

  @override
  String get minimumQuantity => 'Minimum Qty';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get productImage => 'Product Image';

  @override
  String get trackInventory => 'Track Inventory';

  @override
  String get productSavedSuccess => 'Product saved successfully';

  @override
  String get productAddedSuccess => 'Product added successfully';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get activeProduct => 'Active Product';

  @override
  String get currency => 'SAR';

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get supplierPriceUpdate => 'Supplier price update';

  @override
  String get costIncrease => 'Cost increase';

  @override
  String get duplicateProduct => 'Duplicate Product';

  @override
  String get categoriesManagement => 'Categories Management';

  @override
  String categoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categories',
      one: '1 category',
      zero: 'No categories',
    );
    return '$_temp0';
  }

  @override
  String get addCategory => 'Add Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get categoryNameAr => 'Name (Arabic)';

  @override
  String get categoryNameEn => 'Name (English)';

  @override
  String get parentCategory => 'Parent Category';

  @override
  String get noParentCategory => 'No parent (Root)';

  @override
  String get sortOrder => 'Sort Order';

  @override
  String get categoryColor => 'Color';

  @override
  String get categoryIcon => 'Icon';

  @override
  String get categoryDetails => 'Category Details';

  @override
  String get categoryCreatedAt => 'Created At';

  @override
  String get categoryProducts => 'Category Products';

  @override
  String get noCategorySelected => 'Select a category to view its details';

  @override
  String get deleteCategoryConfirm =>
      'Are you sure you want to delete this category?';

  @override
  String get categoryDeletedSuccess => 'Category deleted successfully';

  @override
  String get categorySavedSuccess => 'Category saved successfully';

  @override
  String get searchCategories => 'Search categories...';

  @override
  String get reorderCategories => 'Reorder';

  @override
  String get noCategories => 'No categories found';

  @override
  String get subcategories => 'Subcategories';

  @override
  String get activeStatus => 'Active';

  @override
  String get inactiveStatus => 'Inactive';

  @override
  String get invoicesTitle => 'Invoices';

  @override
  String get totalInvoices => 'Total Invoices';

  @override
  String get totalPaid => 'Total Paid';

  @override
  String get totalPending => 'Total Pending';

  @override
  String get totalOverdue => 'Total Overdue';

  @override
  String get comparedToLastMonth => 'Compared to last month';

  @override
  String ofTotalDue(String percent) {
    return '$percent% of total due';
  }

  @override
  String invoicesWaitingPayment(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invoices waiting payment',
      one: '1 invoice waiting payment',
      zero: 'No invoices waiting',
    );
    return '$_temp0';
  }

  @override
  String get sendReminderNow => 'Send Reminder Now';

  @override
  String get revenueAnalysis => 'Revenue Analysis';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get thisMonthPeriod => 'This Month';

  @override
  String get thisYearPeriod => 'This Year';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get cashPayment => 'Cash';

  @override
  String get cardPayment => 'Card';

  @override
  String get walletPayment => 'Wallet';

  @override
  String get saveCurrentFilter => 'Save Current Filter';

  @override
  String get statusAll => 'All';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get resetFilters => 'Reset';

  @override
  String get createInvoice => 'Create Invoice';

  @override
  String get invoiceNumberCol => 'Invoice #';

  @override
  String get customerNameCol => 'Customer Name';

  @override
  String get dateCol => 'Date';

  @override
  String get amountCol => 'Amount';

  @override
  String get statusCol => 'Status';

  @override
  String get paymentCol => 'Payment';

  @override
  String get actionsCol => 'Actions';

  @override
  String get viewInvoice => 'View';

  @override
  String get printInvoice => 'Print';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get sendWhatsapp => 'WhatsApp';

  @override
  String get deleteInvoice => 'Delete';

  @override
  String get reminder => 'Reminder';

  @override
  String get exportAll => 'Export All';

  @override
  String get printReport => 'Print Report';

  @override
  String get more => 'More';

  @override
  String showingResults(int from, int to, int total) {
    return 'Showing $from to $to of $total results';
  }

  @override
  String get newInvoice => 'New Invoice';

  @override
  String get selectCustomer => 'Select Customer';

  @override
  String get cashCustomerGeneral => 'Cash Customer (General)';

  @override
  String get addNewCustomer => '+ Add New Customer';

  @override
  String get productsSection => 'Products';

  @override
  String get addProductToInvoice => '+ Add Product';

  @override
  String get productCol => 'Product';

  @override
  String get quantityCol => 'Qty';

  @override
  String get priceCol => 'Price';

  @override
  String get dueDate => 'Due Date';

  @override
  String get invoiceTotal => 'Total:';

  @override
  String get saveInvoice => 'Save Invoice';

  @override
  String get deleteConfirm => 'Are you sure?';

  @override
  String get deleteInvoiceMsg =>
      'Do you really want to delete this invoice? This action cannot be undone.';

  @override
  String get yesDelete => 'Yes, Delete';

  @override
  String get copiedSuccess => 'Copied successfully';

  @override
  String get invoiceDeleted => 'Invoice deleted successfully';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String selected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
      zero: 'None selected',
    );
    return '$_temp0';
  }

  @override
  String get bulkPrint => 'Print';

  @override
  String get bulkExportPdf => 'Export PDF';

  @override
  String get allRightsReservedFooter =>
      '© 2026 Alhai POS. All rights reserved.';

  @override
  String get privacyPolicyFooter => 'Privacy Policy';

  @override
  String get termsFooter => 'Terms & Conditions';

  @override
  String get supportFooter => 'Technical Support';

  @override
  String get paid => 'Paid';

  @override
  String get overdue => 'Overdue';

  @override
  String get creditCard => 'Credit Card';

  @override
  String get electronicWallet => 'E-Wallet';

  @override
  String get searchInvoiceHint => 'Search by invoice number, customer...';

  @override
  String get customerDetails => 'Customer Details';

  @override
  String get customerProfileAndTransactions =>
      'Overview of the profile and transactions';

  @override
  String get customerDetailTitle => 'Customer Details';

  @override
  String get totalPurchases => 'Total Purchases';

  @override
  String get loyaltyPoints => 'Loyalty Points';

  @override
  String get lastVisit => 'Last Visit';

  @override
  String get newSaleAction => 'New Sale';

  @override
  String get editInfo => 'Edit Info';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get blockCustomer => 'Block Customer';

  @override
  String get purchasesTab => 'Purchases';

  @override
  String get accountTab => 'Account';

  @override
  String get debtsTab => 'Debts';

  @override
  String get analyticsTab => 'Analytics';

  @override
  String get recentOrdersLog => 'Recent Orders Log';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get searchByInvoiceNumber => 'Search by invoice number...';

  @override
  String get items => 'Items';

  @override
  String get viewDetails => 'View Details';

  @override
  String get financialLedger => 'Financial Ledger';

  @override
  String get cashPaymentEntry => 'Cash Payment';

  @override
  String get walletTopup => 'Wallet Top-up';

  @override
  String get loyaltyPointsDeduction => 'Loyalty Points Deduction';

  @override
  String redeemPoints(int count) {
    return 'Redeem $count points';
  }

  @override
  String get viewFullLedger => 'View Full';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get creditLimit => 'Credit Limit';

  @override
  String get used => 'Used';

  @override
  String get topUpBalance => 'Top Up Balance';

  @override
  String get overdueDebt => 'Overdue';

  @override
  String get upcomingDebt => 'Upcoming';

  @override
  String get payNow => 'Pay Now';

  @override
  String get remind => 'Remind';

  @override
  String get monthlySpending => 'Monthly Spending';

  @override
  String get purchaseDistribution => 'Purchases Distribution by Category';

  @override
  String get last6Months => 'Last 6 months';

  @override
  String get thisYear => 'This Year';

  @override
  String get averageOrder => 'Average Order';

  @override
  String get purchaseFrequency => 'Purchase Frequency';

  @override
  String everyNDays(int count) {
    return 'Every $count days';
  }

  @override
  String get spendingGrowth => 'Spending Growth';

  @override
  String get favoriteProduct => 'Favorite Product';

  @override
  String get internalNotes => 'Internal Notes (visible to staff only)';

  @override
  String get addNote => 'Add';

  @override
  String get addNewNote => 'Add a new note...';

  @override
  String joinedDate(String date) {
    return 'Joined: $date';
  }

  @override
  String lastUpdated(String time) {
    return 'Last updated: $time';
  }

  @override
  String showingOrders(int from, int to, int total) {
    return 'Showing $from-$to of $total orders';
  }

  @override
  String get vegetables => 'Vegetables';

  @override
  String get dairy => 'Dairy';

  @override
  String get meat => 'Meat';

  @override
  String get bakery => 'Bakery';

  @override
  String get other => 'Other';

  @override
  String get returns => 'Returns';

  @override
  String get salesReturns => 'Sales Returns';

  @override
  String get purchaseReturns => 'Purchase Returns';

  @override
  String get totalReturns => 'Total Returns';

  @override
  String get totalRefundedAmount => 'Total Refunded Amount';

  @override
  String get mostReturned => 'Most Returned';

  @override
  String get processed => 'Processed';

  @override
  String get newReturn => 'New Return';

  @override
  String get createNewReturn => 'Create New Return';

  @override
  String get processReturnRequest => 'Process sales return request';

  @override
  String get returnNumber => 'Return Number';

  @override
  String get originalInvoice => 'Original Invoice';

  @override
  String get returnReason => 'Return Reason';

  @override
  String get returnAmount => 'Return Amount';

  @override
  String get returnStatus => 'Return Status';

  @override
  String get returnDate => 'Return Date';

  @override
  String get returnActions => 'Actions';

  @override
  String get returnRefunded => 'Refunded';

  @override
  String get returnRejected => 'Rejected';

  @override
  String get defectiveProduct => 'Defective Product';

  @override
  String get wrongProduct => 'Wrong Product';

  @override
  String get customerRequest => 'Customer Request';

  @override
  String get otherReason => 'Other Reason';

  @override
  String get quickSearch => 'Quick search...';

  @override
  String get exportData => 'Export';

  @override
  String get printData => 'Print';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get previous => 'Previous';

  @override
  String get invoiceStep => 'Invoice';

  @override
  String get itemsStep => 'Items';

  @override
  String get reasonStep => 'Reason';

  @override
  String get confirmStep => 'Confirmation';

  @override
  String get enterInvoiceNumber => 'Invoice Number';

  @override
  String get invoiceExample => 'Example: #INV-889';

  @override
  String get loadInvoice => 'Load';

  @override
  String invoiceLoaded(String number) {
    return 'Invoice #$number loaded';
  }

  @override
  String invoiceLoadedCustomer(String customer, String date) {
    return 'Customer: $customer | Date: $date';
  }

  @override
  String get selectItemsInfo =>
      'Select items to return. Cannot return more than sold quantity.';

  @override
  String availableToReturn(int count) {
    return 'Available: $count';
  }

  @override
  String get alreadyReturnedFully => 'Full quantity already returned';

  @override
  String get returnReasonLabel => 'Return Reason (for selected items)';

  @override
  String get additionalDetails => 'Additional details (required for Other)...';

  @override
  String get confirmReturn => 'Confirm Return';

  @override
  String get refundAmount => 'Refund Amount';

  @override
  String get refundMethod => 'Refund Method';

  @override
  String get cashRefund => 'Cash';

  @override
  String get storeCredit => 'Store Credit';

  @override
  String get returnCreatedSuccess => 'Return created successfully';

  @override
  String get noReturns => 'No Returns';

  @override
  String get noReturnsDesc => 'No return operations recorded yet.';

  @override
  String timesReturned(int count, int percent) {
    return '$count times ($percent% of total)';
  }

  @override
  String get fromInvoice => 'From invoice';

  @override
  String get dateFromTo => 'Date from - to';

  @override
  String get returnCopied => 'Number copied successfully';

  @override
  String ofTotalProcessed(int percent) {
    return '$percent% processed';
  }

  @override
  String get invoiceDetails => 'Invoice Details';

  @override
  String invoiceNumberLabel(String number) {
    return 'Number:';
  }

  @override
  String get additionalOptions => 'Additional Options';

  @override
  String get duplicateInvoice => 'Create Duplicate';

  @override
  String get returnMerchandise => 'Return Merchandise';

  @override
  String get voidInvoice => 'Void Invoice';

  @override
  String get printBtn => 'Print';

  @override
  String get downloadBtn => 'Download';

  @override
  String get paidSuccessfully => 'Payment Successful';

  @override
  String get amountReceivedFull => 'Full amount received';

  @override
  String get completedStatus => 'Completed';

  @override
  String get pendingStatus => 'Pending';

  @override
  String get voidedStatus => 'Voided';

  @override
  String get storeName => 'Store Name';

  @override
  String get storeAddress => 'Riyadh, Al-Malaz District, Takhassusi Street';

  @override
  String get simplifiedTaxInvoice => 'Simplified Tax Invoice';

  @override
  String get dateAndTime => 'Date & Time';

  @override
  String get cashierLabel => 'Cashier';

  @override
  String get itemCol => 'Item';

  @override
  String get quantityColDetail => 'Qty';

  @override
  String get priceColDetail => 'Price';

  @override
  String get totalCol => 'Total';

  @override
  String get subtotalLabel => 'Subtotal';

  @override
  String get discountVip => 'Discount (VIP Member)';

  @override
  String get vatLabel => 'VAT (15%)';

  @override
  String get grandTotalLabel => 'Grand Total';

  @override
  String get paymentMethodLabel => 'Payment Method';

  @override
  String get amountPaidLabel => 'Amount Paid';

  @override
  String get zatcaElectronic => 'ZATCA - Electronic Invoice';

  @override
  String get scanToVerify => 'Scan to verify invoice';

  @override
  String get includesVat15 => 'Includes 15% VAT';

  @override
  String get thankYouVisit => 'Thank you for your visit!';

  @override
  String get wishNiceDay => 'We wish you a wonderful day';

  @override
  String get customerInfo => 'Customer Information';

  @override
  String get editBtn => 'Edit';

  @override
  String vipSince(String year) {
    return 'VIP Customer since $year';
  }

  @override
  String get activeStatusLabel => 'Active';

  @override
  String get callBtn => 'Call';

  @override
  String get recordBtn => 'Record';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get sendWhatsappAction => 'Send WhatsApp';

  @override
  String get sendEmailAction => 'Send Email';

  @override
  String get downloadPdfAction => 'Download PDF';

  @override
  String get shareLinkAction => 'Share Link';

  @override
  String get eventLog => 'Event Log';

  @override
  String get paymentCompleted => 'Payment Completed';

  @override
  String get processedViaGateway => 'Processed via payment gateway';

  @override
  String minutesAgoDetail(int count) {
    return '$count minutes ago';
  }

  @override
  String get invoiceCreated => 'Invoice Created';

  @override
  String byUser(String name) {
    return 'By $name';
  }

  @override
  String todayAt(String time) {
    return 'Today, $time';
  }

  @override
  String get orderStarted => 'Order Started';

  @override
  String get cashierSessionOpened => 'Cashier session opened';

  @override
  String get technicalData => 'Technical Data';

  @override
  String get deviceIdLabel => 'Device ID';

  @override
  String get terminalLabel => 'Terminal';

  @override
  String get softwareVersion => 'Software V';

  @override
  String get voidInvoiceConfirm => 'Void Invoice?';

  @override
  String get voidInvoiceMsg =>
      'This invoice will be permanently voided and will not be counted in daily sales. Are you sure?';

  @override
  String get voidReasonLabel => 'Void Reason (Required)';

  @override
  String get voidReasonEntry => 'Entry Error';

  @override
  String get voidReasonCustomer => 'Customer Request';

  @override
  String get voidReasonDamaged => 'Damaged Product';

  @override
  String get voidReasonOther => 'Other Reason...';

  @override
  String get confirmVoid => 'Confirm Void';

  @override
  String get invoiceVoided => 'Invoice voided successfully';

  @override
  String copiedText(String text) {
    return 'Copied: $text';
  }

  @override
  String visaEnding(String digits) {
    return 'Visa ending $digits';
  }

  @override
  String get mobileActionPrint => 'Print';

  @override
  String get mobileActionWhatsapp => 'WhatsApp';

  @override
  String get mobileActionEmail => 'Email';

  @override
  String get mobileActionMore => 'More';

  @override
  String get sarCurrency => 'SAR';

  @override
  String skuLabel(String code) {
    return 'SKU: $code';
  }

  @override
  String get helpText => 'Help';

  @override
  String get customerLedger => 'Customer Ledger';

  @override
  String get accountStatement => 'Account Statement';

  @override
  String get allPeriods => 'All';

  @override
  String get threeMonths => '3 Months';

  @override
  String get allMovements => 'All Transactions';

  @override
  String get adjustments => 'Adjustments';

  @override
  String get statementCol => 'Description';

  @override
  String get referenceCol => 'Reference';

  @override
  String get debitCol => 'Debit';

  @override
  String get creditCol => 'Credit';

  @override
  String get balanceCol => 'Balance';

  @override
  String get openingBalance => 'Opening Balance';

  @override
  String get totalDebit => 'Total Debit';

  @override
  String get totalCredit => 'Total Credit';

  @override
  String get finalBalance => 'Final Balance';

  @override
  String get manualAdjustment => 'Manual Adjustment';

  @override
  String get adjustmentType => 'Adjustment Type';

  @override
  String get debitAdjustment => 'Debit Adjustment';

  @override
  String get creditAdjustment => 'Credit Adjustment';

  @override
  String get adjustmentAmount => 'Adjustment Amount';

  @override
  String get adjustmentReason => 'Adjustment Reason';

  @override
  String get adjustmentDate => 'Adjustment Date';

  @override
  String get saveAdjustment => 'Save Adjustment';

  @override
  String get adjustmentSaved => 'Adjustment saved successfully';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String get dueOnCustomer => 'Due on customer';

  @override
  String get customerHasCredit => 'Customer has credit balance';

  @override
  String get noTransactions => 'No transactions';

  @override
  String get recordPaymentBtn => 'Record Payment';

  @override
  String get returnEntry => 'Return';

  @override
  String get adjustmentEntry => 'Adjustment';

  @override
  String get ordersHistory => 'Orders History';

  @override
  String get totalOrdersLabel => 'Total Orders';

  @override
  String get completedOrders => 'Completed';

  @override
  String get pendingOrders => 'Pending';

  @override
  String get cancelledOrders => 'Cancelled';

  @override
  String get searchOrderHint => 'Search by order number, customer, or phone...';

  @override
  String get channelLabel => 'Channel';

  @override
  String get last30Days => 'Last 30 Days';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get unpaidLabel => 'Unpaid';

  @override
  String get voidTransaction => 'Void Transaction';

  @override
  String get voidSaleTransaction => 'Void Sale Transaction';

  @override
  String get voidWarningTitle =>
      'Important Warning: This action cannot be undone';

  @override
  String get voidWarningDesc =>
      'Voiding this transaction will cancel the invoice completely and return all items to inventory. Please verify the information before proceeding.';

  @override
  String get voidWarningShort =>
      'This action will cancel the invoice completely and return items to inventory. Cannot be undone.';

  @override
  String get enterInvoiceToVoid => 'Enter the invoice number to void';

  @override
  String get searchByInvoiceOrBarcode =>
      'You can search by invoice number or use the barcode scanner';

  @override
  String get invoiceExampleVoid => 'Example: #INV-2024-8892';

  @override
  String get activateBarcode => 'Activate barcode scanner';

  @override
  String get scanBarcodeMobile => 'Scan barcode';

  @override
  String get searchForInvoiceToVoid => 'Search for an invoice to void';

  @override
  String get enterNumberOrScan =>
      'Enter the number manually or use the barcode scanner.';

  @override
  String get salesInvoice => 'Sales Invoice';

  @override
  String get invoiceCompleted => 'Completed';

  @override
  String get paidCash => 'Paid: Cash';

  @override
  String get customerLabel => 'Customer';

  @override
  String get dateAndTimeLabel => 'Date & Time';

  @override
  String get voidImpactSummary => 'Void Impact Summary';

  @override
  String voidImpactItemsReturn(int count) {
    return 'Will return $count items to inventory automatically.';
  }

  @override
  String voidImpactRefund(String amount, String currency) {
    return 'Will deduct/refund amount of $amount $currency.';
  }

  @override
  String returnedItems(int count) {
    return 'Returned Items';
  }

  @override
  String get viewAllItems => 'View All';

  @override
  String moreItemsHint(int count, String amount, String currency) {
    return '+ $count more items (total: $amount $currency)';
  }

  @override
  String get voidReason => 'Void Reason';

  @override
  String get voidReasonRequired => 'Void Reason *';

  @override
  String get customerRequestReason => 'Customer request';

  @override
  String get wrongItemsReason => 'Wrong items';

  @override
  String get duplicateInvoiceReason => 'Duplicate invoice';

  @override
  String get systemErrorReason => 'System error';

  @override
  String get otherReasonVoid => 'Other';

  @override
  String get additionalNotesVoid => 'Additional notes...';

  @override
  String get additionalDetailsRequired =>
      'Additional details (required for Other)...';

  @override
  String get managerApproval => 'Manager Approval';

  @override
  String get managerApprovalRequired => 'Manager Approval Required';

  @override
  String amountExceedsLimit(String amount, String currency) {
    return 'Amount exceeds the allowed limit ($amount $currency), please enter manager PIN.';
  }

  @override
  String get enterPinCode => 'Enter PIN code';

  @override
  String get pinSentToManager => 'Temporary code sent to manager\'s phone';

  @override
  String get defaultManagerPin => 'Default manager code: 1234';

  @override
  String get confirmVoidAction => 'I confirm voiding this transaction';

  @override
  String get confirmVoidDesc =>
      'I have reviewed the details and take full responsibility.';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get confirmFinalVoid => 'Confirm Final Void';

  @override
  String get invoiceNotFound => 'Invoice not found';

  @override
  String get invoiceNotFoundDesc =>
      'Verify the entered number or try using the barcode.';

  @override
  String get trySearchAgain => 'Try searching again';

  @override
  String get voidSuccess => 'Transaction voided successfully';

  @override
  String qtyLabel(int count) {
    return 'Qty: $count';
  }

  @override
  String get manageCustomersAndAccounts => 'Manage customers and accounts';

  @override
  String get totalCustomersCount => 'Total Customers';

  @override
  String get outstandingDebts => 'Outstanding Debts';

  @override
  String get creditBalance => 'Customer Credit';

  @override
  String get filterByLabel => 'Filter by';

  @override
  String get debtors => 'Debtors';

  @override
  String get creditorsLabel => 'Creditors';

  @override
  String get quickActionsLabel => 'Quick Actions';

  @override
  String get sendDebtReminder => 'Send debt reminder';

  @override
  String get exportAccountStatement => 'Export account statement';

  @override
  String cancelSelectionCount(String count) {
    return 'Cancel selection ($count)';
  }

  @override
  String get searchByNameOrPhone => 'Search by name or phone... (Ctrl+F)';

  @override
  String get sortByBalance => 'Balance';

  @override
  String get refreshF5 => 'Refresh (F5)';

  @override
  String get loadingCustomers => 'Loading customers...';

  @override
  String get payDebt => 'Pay Debt';

  @override
  String dueAmountLabel(String amount) {
    return 'Due: $amount SAR';
  }

  @override
  String get paymentAmountLabel => 'Payment Amount';

  @override
  String get fullAmount => 'Full';

  @override
  String get payAction => 'Pay';

  @override
  String paymentRecorded(String amount) {
    return 'Payment of $amount SAR recorded';
  }

  @override
  String customerAddedSuccess(String name) {
    return '$name added successfully';
  }

  @override
  String get customerNameRequired => 'Customer Name *';

  @override
  String get owedLabel => 'Owes';

  @override
  String get hasBalanceLabel => 'Credit';

  @override
  String get zeroLabel => 'Zero';

  @override
  String get addAction => 'Add';

  @override
  String get expenses => 'Expenses';

  @override
  String get expenseCategories => 'Expense Categories';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get totalExpenses => 'Total Expenses';

  @override
  String get thisMonthExpenses => 'This Month';

  @override
  String get expenseAmount => 'Amount';

  @override
  String get expenseDate => 'Date';

  @override
  String get expenseCategory => 'Category';

  @override
  String get expenseNotes => 'Notes';

  @override
  String get noExpenses => 'No expenses recorded';

  @override
  String get drawerStatus => 'Drawer Status';

  @override
  String get drawerOpen => 'Open';

  @override
  String get drawerClosed => 'Closed';

  @override
  String get cashIn => 'Cash In';

  @override
  String get cashOut => 'Cash Out';

  @override
  String get expectedAmount => 'Expected Amount';

  @override
  String get countedAmount => 'Counted Amount';

  @override
  String get difference => 'Difference';

  @override
  String get openDrawerAction => 'Open Drawer';

  @override
  String get closeDrawerAction => 'Close Drawer';

  @override
  String get monthlyCloseTitle => 'Monthly Close';

  @override
  String get monthlyCloseDesc => 'Close month and calculate receivables';

  @override
  String get totalReceivables => 'Total Receivables';

  @override
  String get interestRate => 'Interest Rate';

  @override
  String get closeMonth => 'Close Month';

  @override
  String get shiftsTitle => 'Shifts';

  @override
  String get currentShift => 'Current Shift';

  @override
  String get shiftHistory => 'Shift History';

  @override
  String get openShiftAction => 'Open Shift';

  @override
  String get closeShiftAction => 'Close Shift';

  @override
  String get shiftStartTime => 'Start Time';

  @override
  String get shiftEndTime => 'End Time';

  @override
  String get shiftTotalSales => 'Total Sales';

  @override
  String get shiftTotalOrders => 'Total Orders';

  @override
  String get startingCash => 'Starting Cash';

  @override
  String get cashierName => 'Cashier Name';

  @override
  String get shiftDuration => 'Duration';

  @override
  String get noShifts => 'No shifts recorded';

  @override
  String get purchasesTitle => 'Purchases';

  @override
  String get newPurchase => 'New Purchase';

  @override
  String get smartReorder => 'Smart Reorder';

  @override
  String get aiInvoiceImport => 'AI Invoice Import';

  @override
  String get aiInvoiceReview => 'AI Invoice Review';

  @override
  String get purchaseOrder => 'Purchase Order';

  @override
  String get purchaseTotal => 'Purchase Total';

  @override
  String get purchaseDate => 'Purchase Date';

  @override
  String get suppliersTitle => 'Suppliers';

  @override
  String get addSupplier => 'Add Supplier';

  @override
  String get supplierName => 'Supplier Name';

  @override
  String get supplierPhone => 'Phone';

  @override
  String get supplierEmail => 'Email';

  @override
  String get supplierAddress => 'Address';

  @override
  String get totalSuppliers => 'Total Suppliers';

  @override
  String get supplierDetails => 'Supplier Details';

  @override
  String get noSuppliers => 'No suppliers found';

  @override
  String get discountsTitle => 'Discounts';

  @override
  String get addDiscount => 'Add Discount';

  @override
  String get discountName => 'Discount Name';

  @override
  String get discountType => 'Discount Type';

  @override
  String get discountValue => 'Value';

  @override
  String get percentageDiscount => 'Percentage';

  @override
  String get fixedDiscount => 'Fixed Amount';

  @override
  String get activeDiscounts => 'Active Discounts';

  @override
  String get couponsTitle => 'Coupons';

  @override
  String get addCoupon => 'Add Coupon';

  @override
  String get couponCode => 'Coupon Code';

  @override
  String get couponUsage => 'Usage';

  @override
  String get couponExpiry => 'Expiry';

  @override
  String get totalCoupons => 'Total Coupons';

  @override
  String get activeCoupons => 'Active';

  @override
  String get expiredCoupons => 'Expired';

  @override
  String get specialOffersTitle => 'Special Offers';

  @override
  String get addOffer => 'Add Offer';

  @override
  String get offerName => 'Offer Name';

  @override
  String get offerStartDate => 'Start Date';

  @override
  String get offerEndDate => 'End Date';

  @override
  String get smartPromotionsTitle => 'Smart Promotions';

  @override
  String get activePromotions => 'Active Promotions';

  @override
  String get suggestedPromotions => 'AI Suggestions';

  @override
  String get loyaltyTitle => 'Loyalty Program';

  @override
  String get loyaltyMembers => 'Members';

  @override
  String get loyaltyRewards => 'Rewards';

  @override
  String get loyaltyTiers => 'Tiers';

  @override
  String get totalMembers => 'Total Members';

  @override
  String get pointsIssued => 'Points Issued';

  @override
  String get pointsRedeemed => 'Points Redeemed';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Mark All Read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get printQueueTitle => 'Print Queue';

  @override
  String get printAll => 'Print All';

  @override
  String get cancelAll => 'Cancel All';

  @override
  String get noPrintJobs => 'No print jobs';

  @override
  String get syncStatusTitle => 'Sync Status';

  @override
  String get lastSyncTime => 'Last Sync';

  @override
  String get pendingItems => 'Pending Items';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get pendingTransactionsTitle => 'Pending Transactions';

  @override
  String get conflictResolutionTitle => 'Conflict Resolution';

  @override
  String get localValue => 'Local';

  @override
  String get serverValue => 'Server';

  @override
  String get keepLocal => 'Keep Local';

  @override
  String get keepServer => 'Keep Server';

  @override
  String get driversTitle => 'Drivers';

  @override
  String get addDriver => 'Add Driver';

  @override
  String get driverName => 'Driver Name';

  @override
  String get driverStatus => 'Status';

  @override
  String get delivering => 'Delivering';

  @override
  String get totalDeliveries => 'Total Deliveries';

  @override
  String get driverRating => 'Rating';

  @override
  String get branchesTitle => 'Branches';

  @override
  String get addBranchAction => 'Add Branch';

  @override
  String get branchName => 'Branch Name';

  @override
  String get branchEmployees => 'Employees';

  @override
  String get branchSales => 'Today\'s Sales';

  @override
  String get profileTitle => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailAddress => 'Email';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get role => 'Role';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get storeSettings => 'Store Settings';

  @override
  String get posSettings => 'POS Settings';

  @override
  String get printerSettings => 'Printer Settings';

  @override
  String get paymentDevicesSettings => 'Payment Devices';

  @override
  String get barcodeSettings => 'Barcode Settings';

  @override
  String get receiptTemplate => 'Receipt Template';

  @override
  String get taxSettings => 'Tax Settings';

  @override
  String get discountSettings => 'Discount Settings';

  @override
  String get interestSettings => 'Interest Settings';

  @override
  String get languageSettings => 'Language';

  @override
  String get themeSettings => 'Theme';

  @override
  String get securitySettings => 'Security';

  @override
  String get usersManagement => 'Users Management';

  @override
  String get rolesPermissions => 'Roles & Permissions';

  @override
  String get activityLog => 'Activity Log';

  @override
  String get backupSettings => 'Backup & Restore';

  @override
  String get notificationSettings => 'Notifications';

  @override
  String get zatcaCompliance => 'ZATCA Compliance';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get general => 'General';

  @override
  String get appearance => 'Appearance';

  @override
  String get securitySection => 'Security';

  @override
  String get advanced => 'Advanced';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get configure => 'Configure';

  @override
  String get connected => 'Connected';

  @override
  String get notConnected => 'Not Connected';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get lastBackup => 'Last Backup';

  @override
  String get autoBackup => 'Auto Backup';

  @override
  String get manualBackup => 'Backup Now';

  @override
  String get restoreBackup => 'Restore';

  @override
  String get biometricAuth => 'Biometric Authentication';

  @override
  String get sessionTimeout => 'Session Timeout';

  @override
  String get changePin => 'Change PIN';

  @override
  String get twoFactorAuth => 'Two-Factor Auth';

  @override
  String get addUser => 'Add User';

  @override
  String get userName => 'Name';

  @override
  String get userEmail => 'Email';

  @override
  String get userPhone => 'Phone';

  @override
  String get addRole => 'Add Role';

  @override
  String get roleName => 'Role Name';

  @override
  String get permissions => 'Permissions';

  @override
  String get faq => 'FAQ';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get documentation => 'Documentation';

  @override
  String get reportBug => 'Report a Bug';

  @override
  String get zatcaRegistration => 'ZATCA Registration';

  @override
  String get eInvoicing => 'E-Invoicing';

  @override
  String get qrCode => 'QR Code';

  @override
  String get vatNumber => 'VAT Number';

  @override
  String get taxNumber => 'Tax Number';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get smsNotifications => 'SMS Notifications';

  @override
  String get orderNotifications => 'Order Notifications';

  @override
  String get stockNotifications => 'Stock Alerts';

  @override
  String get paymentNotifications => 'Payment Notifications';

  @override
  String get liveChat => 'Live Chat';

  @override
  String get emailSupport => 'Email Support';

  @override
  String get phoneSupport => 'Phone Support';

  @override
  String get whatsappSupport => 'WhatsApp Support';

  @override
  String get userGuide => 'User Guide';

  @override
  String get videoTutorials => 'Video Tutorials';

  @override
  String get changelog => 'Changelog';

  @override
  String get appInfo => 'App Info';

  @override
  String get buildNumber => 'Build Number';

  @override
  String get notificationChannels => 'Notification Channels';

  @override
  String get alertTypes => 'Alert Types';

  @override
  String get salesAlerts => 'Sales Alerts';

  @override
  String get inventoryAlerts => 'Inventory Alerts';

  @override
  String get securityAlerts => 'Security Alerts';

  @override
  String get reportAlerts => 'Report Alerts';

  @override
  String get users => 'Users';

  @override
  String get zatcaRegistered => 'Registered with ZATCA';

  @override
  String get zatcaPhase2Active => 'Phase 2 Active';

  @override
  String get registrationInfo => 'Registration Info';

  @override
  String get businessName => 'Business Name';

  @override
  String get branchCode => 'Branch Code';

  @override
  String get qrCodeOnInvoice => 'QR code appears on every invoice';

  @override
  String get certificates => 'Certificates';

  @override
  String get csidCertificate => 'CSID Certificate';

  @override
  String get valid => 'Valid';

  @override
  String get privateKey => 'Private Key';

  @override
  String get configured => 'Configured';

  @override
  String get aiSection => 'Artificial Intelligence';

  @override
  String get aiAssistantTitle => 'AI Assistant';

  @override
  String get aiAssistantSubtitle =>
      'Ask your smart assistant anything about your store';

  @override
  String get aiSalesForecastingTitle => 'Sales Forecasting';

  @override
  String get aiSalesForecastingSubtitle =>
      'Predict future sales using historical data';

  @override
  String get aiSmartPricingTitle => 'Smart Pricing';

  @override
  String get aiSmartPricingSubtitle =>
      'AI-powered price optimization suggestions';

  @override
  String get aiFraudDetectionTitle => 'Fraud Detection';

  @override
  String get aiFraudDetectionSubtitle =>
      'Detect suspicious patterns and protect your business';

  @override
  String get aiBasketAnalysisTitle => 'Basket Analysis';

  @override
  String get aiBasketAnalysisSubtitle =>
      'Discover products frequently bought together';

  @override
  String get aiCustomerRecommendationsTitle => 'Customer Recommendations';

  @override
  String get aiCustomerRecommendationsSubtitle =>
      'Personalized product suggestions for customers';

  @override
  String get aiSmartInventoryTitle => 'Smart Inventory';

  @override
  String get aiSmartInventorySubtitle =>
      'Optimal stock levels and waste prediction';

  @override
  String get aiCompetitorAnalysisTitle => 'Competitor Analysis';

  @override
  String get aiCompetitorAnalysisSubtitle =>
      'Compare your prices with competitors';

  @override
  String get aiSmartReportsTitle => 'Smart Reports';

  @override
  String get aiSmartReportsSubtitle =>
      'Generate reports using natural language';

  @override
  String get aiStaffAnalyticsTitle => 'Staff Analytics';

  @override
  String get aiStaffAnalyticsSubtitle =>
      'Employee performance analysis and optimization';

  @override
  String get aiProductRecognitionTitle => 'Product Recognition';

  @override
  String get aiProductRecognitionSubtitle => 'Identify products using camera';

  @override
  String get aiSentimentAnalysisTitle => 'Sentiment Analysis';

  @override
  String get aiSentimentAnalysisSubtitle =>
      'Analyze customer feedback and satisfaction';

  @override
  String get aiReturnPredictionTitle => 'Return Prediction';

  @override
  String get aiReturnPredictionSubtitle =>
      'Predict and prevent product returns';

  @override
  String get aiPromotionDesignerTitle => 'Promotion Designer';

  @override
  String get aiPromotionDesignerSubtitle =>
      'AI-generated promotions with ROI forecasting';

  @override
  String get aiChatWithDataTitle => 'Chat with Data';

  @override
  String get aiChatWithDataSubtitle => 'Query your data using natural language';

  @override
  String get aiConfidence => 'Confidence';

  @override
  String get aiHighConfidence => 'High confidence';

  @override
  String get aiMediumConfidence => 'Medium confidence';

  @override
  String get aiLowConfidence => 'Low confidence';

  @override
  String get aiAnalyzing => 'Analyzing...';

  @override
  String get aiGenerating => 'Generating...';

  @override
  String get aiNoData => 'No data available for analysis';

  @override
  String get aiRefresh => 'Refresh Analysis';

  @override
  String get aiExport => 'Export Results';

  @override
  String get aiApply => 'Apply Suggestions';

  @override
  String get aiDismiss => 'Dismiss';

  @override
  String get aiViewDetails => 'View Details';

  @override
  String get aiSuggestions => 'AI Suggestions';

  @override
  String get aiInsights => 'AI Insights';

  @override
  String get aiPrediction => 'Prediction';

  @override
  String get aiRecommendation => 'Recommendation';

  @override
  String get aiAlert => 'Alert';

  @override
  String get aiWarning => 'Warning';

  @override
  String get aiTrend => 'Trend';

  @override
  String get aiPositive => 'Positive';

  @override
  String get aiNegative => 'Negative';

  @override
  String get aiNeutral => 'Neutral';

  @override
  String get aiSendMessage => 'Send message...';

  @override
  String get aiQuickTemplates => 'Quick Templates';

  @override
  String get aiForecastPeriod => 'Forecast Period';

  @override
  String get aiWeekly => 'Weekly';

  @override
  String get aiMonthly => 'Monthly';

  @override
  String get aiQuarterly => 'Quarterly';

  @override
  String get aiWhatIfScenario => 'What-If Scenario';

  @override
  String get aiSeasonalPatterns => 'Seasonal Patterns';

  @override
  String get aiPriceSuggestion => 'Price Suggestion';

  @override
  String get aiCurrentPrice => 'Current Price';

  @override
  String get aiSuggestedPrice => 'Suggested Price';

  @override
  String get aiPriceImpact => 'Price Impact';

  @override
  String get aiDemandElasticity => 'Demand Elasticity';

  @override
  String get aiFraudAlerts => 'Fraud Alerts';

  @override
  String get aiFraudRiskScore => 'Risk Score';

  @override
  String get aiBehaviorScore => 'Behavior Score';

  @override
  String get aiInvestigation => 'Investigation';

  @override
  String get aiAssociationRules => 'Association Rules';

  @override
  String get aiBundleSuggestions => 'Bundle Suggestions';

  @override
  String get aiRepurchaseReminder => 'Repurchase Reminder';

  @override
  String get aiCustomerSegment => 'Customer Segment';

  @override
  String get aiEoqCalculator => 'EOQ Calculator';

  @override
  String get aiAbcAnalysis => 'ABC Analysis';

  @override
  String get aiWastePrediction => 'Waste Prediction';

  @override
  String get aiReorderPoint => 'Reorder Point';

  @override
  String get aiCompetitorPrices => 'Competitor Prices';

  @override
  String get aiMarketPosition => 'Market Position';

  @override
  String get aiQueryInput => 'Ask anything about your data...';

  @override
  String get aiReportTemplate => 'Report Template';

  @override
  String get aiStaffPerformance => 'Staff Performance';

  @override
  String get aiShiftOptimization => 'Shift Optimization';

  @override
  String get aiProductScan => 'Scan Product';

  @override
  String get aiOcrResults => 'OCR Results';

  @override
  String get aiSentimentScore => 'Sentiment Score';

  @override
  String get aiKeywords => 'Keywords';

  @override
  String get aiReturnRisk => 'Return Risk';

  @override
  String get aiPreventiveActions => 'Preventive Actions';

  @override
  String get aiRoiForecast => 'ROI Forecast';

  @override
  String get aiAbTesting => 'A/B Testing';

  @override
  String get aiQueryHistory => 'Query History';

  @override
  String get aiApplied => 'Applied';

  @override
  String get aiPending => 'Pending';

  @override
  String get aiHighPriority => 'High Priority';

  @override
  String get aiMediumPriority => 'Medium Priority';

  @override
  String get aiLowPriority => 'Low Priority';

  @override
  String get aiCritical => 'Critical';

  @override
  String get aiSar => 'SAR';

  @override
  String aiPercentChange(String percent) {
    return '$percent% change';
  }

  @override
  String aiItemsCount(int count) {
    return '$count items';
  }

  @override
  String aiLastUpdated(String time) {
    return 'Last updated: $time';
  }

  @override
  String get connectedToServer => 'Connected to server';

  @override
  String lastSyncAt(String time) {
    return 'Last sync: $time';
  }

  @override
  String get pendingOperations => 'Pending Operations';

  @override
  String nPendingOperations(int count) {
    return '$count operations awaiting sync';
  }

  @override
  String get noPendingOperations => 'No pending operations';

  @override
  String get syncInfo => 'Sync Information';

  @override
  String get device => 'Device';

  @override
  String get appVersion => 'App Version';

  @override
  String get lastFullSync => 'Last Full Sync';

  @override
  String get databaseStatus => 'Database Status';

  @override
  String get healthy => 'Healthy';

  @override
  String get syncSuccessful => 'Sync completed successfully';

  @override
  String get justNow => 'Just now';

  @override
  String get allOperationsSynced => 'All operations synced';

  @override
  String get willSyncWhenOnline => 'Will sync when connected to internet';

  @override
  String get syncAll => 'Sync All';

  @override
  String get operationSynced => 'Operation synced';

  @override
  String get deleteOperation => 'Delete Operation';

  @override
  String get deleteOperationConfirm =>
      'Do you want to delete this operation from the queue?';

  @override
  String get insertOperation => 'Insert';

  @override
  String get updateOperation => 'Update';

  @override
  String get operationLabel => 'Operation';

  @override
  String nPendingCount(int count) {
    return '$count pending operation(s)';
  }

  @override
  String conflictsNeedResolution(int count) {
    return '$count conflicts need resolution';
  }

  @override
  String get chooseCorrectValue => 'Choose the correct value for each conflict';

  @override
  String get noConflicts => 'No conflicts';

  @override
  String get productPriceConflict => 'Product price conflict';

  @override
  String get stockQuantityConflict => 'Stock quantity conflict';

  @override
  String get useAllLocal => 'Use All Local';

  @override
  String get useAllServer => 'Use All from Server';

  @override
  String get conflictResolvedLocal => 'Conflict resolved using local value';

  @override
  String get conflictResolvedServer => 'Conflict resolved using server value';

  @override
  String get useLocalValues => 'Local values';

  @override
  String get useServerValues => 'Server values';

  @override
  String applyToAllConflicts(String choice) {
    return 'Will apply $choice to all conflicts';
  }

  @override
  String get allConflictsResolved => 'All conflicts resolved';

  @override
  String get localValueLabel => 'Local Value';

  @override
  String get serverValueLabel => 'Server Value';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get suspendInvoice => 'Suspend Invoice';

  @override
  String get invoiceSuspended => 'Invoice suspended';

  @override
  String nItems(int count) {
    return '$count item(s)';
  }

  @override
  String saveSaleError(String error) {
    return 'Error saving sale: $error';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get stockGood => 'Stock is Good!';

  @override
  String get manageInventory => 'Manage Inventory';

  @override
  String pendingSyncCount(int count) {
    return '$count pending sync';
  }

  @override
  String get freshMilk => 'Fresh Milk';

  @override
  String get whiteBread => 'White Bread';

  @override
  String get localEggs => 'Local Eggs';

  @override
  String get yogurt => 'Yogurt';

  @override
  String minQuantityLabel(int count) {
    return 'Min: $count';
  }

  @override
  String get manageDiscounts => 'Manage Discounts';

  @override
  String get newDiscount => 'New Discount';

  @override
  String get totalLabel => 'Total';

  @override
  String get stopped => 'Stopped';

  @override
  String get allProducts => 'All Products';

  @override
  String get specificCategory => 'Specific Category';

  @override
  String get percentageLabel => 'Percentage %';

  @override
  String get fixedAmount => 'Fixed Amount';

  @override
  String get thePercentage => 'Percentage';

  @override
  String get theAmount => 'Amount';

  @override
  String discountOff(String value) {
    return '$value% discount';
  }

  @override
  String sarDiscountOff(String value) {
    return '$value SAR discount';
  }

  @override
  String get manageCoupons => 'Manage Coupons';

  @override
  String get newCoupon => 'New Coupon';

  @override
  String get expired => 'Expired';

  @override
  String get deactivated => 'Deactivated';

  @override
  String usageCount(int used, int max) {
    return '$used/$max uses';
  }

  @override
  String get freeDelivery => 'Free Delivery';

  @override
  String percentageDiscountLabel(int value) {
    return '$value% discount';
  }

  @override
  String fixedDiscountLabel(int value) {
    return '$value SAR discount';
  }

  @override
  String get couponTypeLabel => 'Type';

  @override
  String get percentageRate => 'Percentage Rate';

  @override
  String get minimumOrder => 'Minimum Order';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get copyCode => 'Copy';

  @override
  String get usages => 'Uses';

  @override
  String get percentageDiscountOption => 'Percentage Discount';

  @override
  String get fixedDiscountOption => 'Fixed Discount';

  @override
  String get freeDeliveryOption => 'Free Delivery';

  @override
  String get percentageField => 'Percentage %';

  @override
  String get manageSpecialOffers => 'Manage Special Offers';

  @override
  String get newOffer => 'New Offer';

  @override
  String get expiringSoon => 'Expiring Soon';

  @override
  String get offerExpired => 'Expired';

  @override
  String bundleDiscount(String discount) {
    return 'Bundle - $discount% off';
  }

  @override
  String get buyAndGetFree => 'Buy & Get Free';

  @override
  String offerDiscountPercent(String discount) {
    return '$discount% discount';
  }

  @override
  String offerDiscountFixed(String discount) {
    return '$discount SAR discount';
  }

  @override
  String get bundleLabel => 'Bundle';

  @override
  String get buyAndGet => 'Buy & Get';

  @override
  String get startDateLabel => 'Start Date';

  @override
  String get endDateLabel => 'End Date';

  @override
  String get productsLabel => 'Products';

  @override
  String get offerType => 'Type';

  @override
  String get theDiscount => 'Discount:';

  @override
  String get smartSuggestions => 'Smart Suggestions';

  @override
  String get suggestionsBasedOnAnalysis =>
      'Suggested offers based on sales and inventory analysis';

  @override
  String suggestedDiscountPercent(int percent) {
    return '$percent% suggested discount';
  }

  @override
  String stockLabelCount(int count) {
    return 'Stock: $count';
  }

  @override
  String validityDays(int days) {
    return 'Validity (days)';
  }

  @override
  String get ignore => 'Ignore';

  @override
  String get applyAction => 'Apply';

  @override
  String usageCountTimes(int count) {
    return 'Usage: $count times';
  }

  @override
  String get promotionHistory => 'Previous Promotions History';

  @override
  String get createNewPromotion => 'Create New Promotion';

  @override
  String get percentageDiscountType => 'Percentage Discount';

  @override
  String get percentageDiscountDesc => '10%, 20%, etc.';

  @override
  String get buyXGetY => 'Buy X Get Y';

  @override
  String get buyXGetYDesc => 'Buy 2 Get 1 Free';

  @override
  String get fixedAmountDiscount => 'Fixed Amount Discount';

  @override
  String get fixedAmountDiscountDesc => '10 SAR off product';

  @override
  String promotionApplied(String product) {
    return 'Promotion applied to $product';
  }

  @override
  String promotionType(String type) {
    return 'Type: $type';
  }

  @override
  String promotionValue(String value) {
    return 'Value: $value';
  }

  @override
  String promotionUsage(int count) {
    return 'Usage: $count times';
  }

  @override
  String get percentageType => 'Percentage';

  @override
  String get buyXGetYType => 'Buy & Get';

  @override
  String get fixedAmountType => 'Fixed Amount';

  @override
  String get closeAction => 'Close';

  @override
  String get holdInvoices => 'Hold Invoices';

  @override
  String get clearAll => 'Clear All';

  @override
  String get noHoldInvoices => 'No Hold Invoices';

  @override
  String get holdInvoicesDesc =>
      'When you hold an invoice from POS, it will appear here\nYou can hold multiple invoices and resume them later';

  @override
  String get deleteInvoiceTitle => 'Delete Invoice';

  @override
  String deleteInvoiceConfirmMsg(String name) {
    return 'Do you want to delete \"$name\"?\nThis action cannot be undone.';
  }

  @override
  String get cannotUndo => 'This action cannot be undone.';

  @override
  String get deleteAllLabel => 'Delete All';

  @override
  String get deleteAllInvoices => 'Delete All Invoices';

  @override
  String deleteAllInvoicesConfirm(int count) {
    return 'Do you want to delete all hold invoices ($count invoices)?\nThis action cannot be undone.';
  }

  @override
  String get invoiceDeletedMsg => 'Invoice deleted';

  @override
  String get allInvoicesDeleted => 'All invoices deleted';

  @override
  String resumedInvoice(String name) {
    return 'Resumed: $name';
  }

  @override
  String itemLabel(int count) {
    return '$count item';
  }

  @override
  String moreItems(int count) {
    return '+$count more items';
  }

  @override
  String get resume => 'Resume';

  @override
  String get justNowTime => 'Just now';

  @override
  String minutesAgoTime(int count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgoTime(int count) {
    return '$count hours ago';
  }

  @override
  String daysAgoTime(int count) {
    return '$count days ago';
  }

  @override
  String get debtManagement => 'Debt Management';

  @override
  String get sortLabel => 'Sort';

  @override
  String get sortByAmount => 'By amount';

  @override
  String get sortByDate => 'By Date';

  @override
  String get sendReminders => 'Send Reminders';

  @override
  String get allTab => 'All';

  @override
  String get overdueTab => 'Overdue';

  @override
  String get upcomingTab => 'Upcoming';

  @override
  String get totalDebts => 'Total Debts';

  @override
  String get overdueDebts => 'Overdue Debts';

  @override
  String get debtorCustomers => 'Debtor Customers';

  @override
  String get noDebts => 'No Debts';

  @override
  String customerLabel2(int count) {
    return '$count customer';
  }

  @override
  String overdueDays(int days) {
    return 'Overdue $days days';
  }

  @override
  String remainingDays(int days) {
    return '$days days remaining';
  }

  @override
  String lastPaymentDate(String date) {
    return 'Last payment: $date';
  }

  @override
  String get recordPayment => 'Record Payment';

  @override
  String get amountDue => 'Amount Due';

  @override
  String currentDebt(String amount) {
    return 'Current debt: $amount SAR';
  }

  @override
  String get paidAmount => 'Paid Amount';

  @override
  String get cashMethod => 'Cash';

  @override
  String get cardMethod => 'Card';

  @override
  String get transferMethod => 'Transfer';

  @override
  String get paymentRecordedSuccess => 'Payment recorded successfully';

  @override
  String get sendRemindersTitle => 'Send Reminders';

  @override
  String sendRemindersConfirm(int count) {
    return 'A reminder will be sent to $count customers with overdue debts';
  }

  @override
  String get sendAction => 'Send';

  @override
  String remindersSent(int count) {
    return '$count reminders sent';
  }

  @override
  String recordPaymentFor(String name) {
    return 'Record Payment - $name';
  }

  @override
  String get sendReminder => 'Send Reminder';

  @override
  String get tabAiSuggestions => 'AI Suggestions';

  @override
  String get tabActivePromotions => 'Active Promotions';

  @override
  String get tabHistory => 'History';

  @override
  String get fruitYogurt => 'Fruit Yogurt';

  @override
  String get buttermilk => 'Buttermilk';

  @override
  String get appleJuice => 'Apple Juice';

  @override
  String get whiteCheese => 'White Cheese';

  @override
  String get orangeJuice => 'Orange Juice';

  @override
  String slowMovementReason(String days) {
    return 'Slow movement - $days days without sale';
  }

  @override
  String get nearExpiryReason => 'Near expiry date';

  @override
  String get excessStockReason => 'Excess stock';

  @override
  String get weekendOffer => 'Weekend Offer';

  @override
  String get buy2Get1Free => 'Buy 2 Get 1 Free';

  @override
  String get productsListLabel => 'Products:';

  @override
  String get paymentMethodLabel2 => 'Payment Method';

  @override
  String get lastPaymentLabel => 'Last Payment';

  @override
  String get currencySAR => 'SAR';

  @override
  String debtAmountWithCurrency(String amount) {
    return '$amount SAR';
  }

  @override
  String get defaultUserName => 'Ahmed Mohammed';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get settingsReset => 'Settings have been reset';

  @override
  String get resetSettings => 'Reset Settings';

  @override
  String get resetSettingsDesc => 'Reset all settings to default values';

  @override
  String get resetSettingsConfirm =>
      'Are you sure you want to reset all POS settings to default values?';

  @override
  String get resetAction => 'Reset';

  @override
  String get posSettingsSubtitle => 'Display, Cart, Payment, Receipt';

  @override
  String get displaySettings => 'Display Settings';

  @override
  String get productDisplayMode => 'Product Display Mode';

  @override
  String get productDisplayModeDesc =>
      'How products are displayed in POS screen';

  @override
  String get gridColumns => 'Number of Columns';

  @override
  String nColumns(int count) {
    return '$count columns';
  }

  @override
  String get showProductImages => 'Show Product Images';

  @override
  String get showProductImagesDesc => 'Show images on product cards';

  @override
  String get showPrices => 'Show Prices';

  @override
  String get showPricesDesc => 'Show price on product card';

  @override
  String get showStockLevel => 'Show Stock Level';

  @override
  String get showStockLevelDesc => 'Show available quantity';

  @override
  String get cartSettings => 'Cart Settings';

  @override
  String get autoFocusBarcode => 'Auto-focus Barcode Field';

  @override
  String get autoFocusBarcodeDesc => 'Focus on barcode field when screen opens';

  @override
  String get allowNegativeStock => 'Allow Negative Stock';

  @override
  String get allowNegativeStockDesc => 'Sell even when stock is zero';

  @override
  String get confirmBeforeDelete => 'Confirm Before Delete';

  @override
  String get confirmBeforeDeleteDesc =>
      'Ask for confirmation when removing product from cart';

  @override
  String get showItemNotes => 'Show Item Notes';

  @override
  String get showItemNotesDesc => 'Allow adding notes to each item';

  @override
  String get cashPaymentOption => 'Cash Payment';

  @override
  String get cardPaymentOption => 'Card Payment';

  @override
  String get creditPaymentOption => 'Credit Payment';

  @override
  String get bankTransferOption => 'Bank Transfer';

  @override
  String get allowSplitPayment => 'Allow Split Payment';

  @override
  String get allowSplitPaymentDesc => 'Pay with multiple methods';

  @override
  String get requireCustomerForCredit => 'Require Customer for Credit';

  @override
  String get requireCustomerForCreditDesc =>
      'Customer must be selected for credit payment';

  @override
  String get receiptSettings => 'Receipt Settings';

  @override
  String get autoPrintReceipt => 'Auto Print Receipt';

  @override
  String get autoPrintReceiptDesc => 'Print immediately after transaction';

  @override
  String get receiptCopies => 'Number of Receipt Copies';

  @override
  String get emailReceiptOption => 'Email Receipt';

  @override
  String get emailReceiptDesc => 'Send a copy to customer';

  @override
  String get smsReceiptOption => 'SMS Receipt';

  @override
  String get smsReceiptDesc => 'Text message to customer';

  @override
  String get printerSettingsDesc => 'Choose printer and its settings';

  @override
  String get receiptDesign => 'Receipt Design';

  @override
  String get receiptDesignDesc => 'Customize receipt appearance';

  @override
  String get advancedSettings => 'Advanced Settings';

  @override
  String get allowHoldInvoices => 'Allow Hold Invoices';

  @override
  String get allowHoldInvoicesDesc => 'Save invoice temporarily';

  @override
  String get maxHoldInvoices => 'Max Hold Invoices';

  @override
  String get quickSaleMode => 'Quick Sale Mode';

  @override
  String get quickSaleModeDesc => 'Simplified screen for quick sales';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get soundEffectsDesc => 'Sounds on scan and add';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get hapticFeedbackDesc => 'Vibrate on button press';

  @override
  String get keyboardShortcuts => 'Keyboard Shortcuts';

  @override
  String get customizeShortcuts => 'Customize shortcuts';

  @override
  String get shortcutSearchProduct => 'Search product';

  @override
  String get shortcutSearchCustomer => 'Search customer';

  @override
  String get shortcutHoldInvoice => 'Hold invoice';

  @override
  String get shortcutFavorites => 'Favorites';

  @override
  String get shortcutApplyDiscount => 'Apply discount';

  @override
  String get shortcutPayment => 'Payment';

  @override
  String get shortcutCancelBack => 'Cancel / Back';

  @override
  String get shortcutDeleteProduct => 'Delete product';

  @override
  String get paymentDevicesSubtitle => 'mada, STC Pay, Apple Pay';

  @override
  String get supportedPaymentMethods => 'Supported Payment Methods';

  @override
  String get madaLocalCards => 'Local mada cards';

  @override
  String get internationalCards => 'International cards';

  @override
  String get stcDigitalWallet => 'STC digital wallet';

  @override
  String get paymentTerminal => 'Payment Terminal';

  @override
  String get ingenicoDevices => 'Ingenico devices';

  @override
  String get verifoneDevices => 'Verifone devices';

  @override
  String get paxDevices => 'PAX devices';

  @override
  String get settlement => 'Settlement';

  @override
  String get autoSettlement => 'Auto Settlement';

  @override
  String get autoSettlementDesc => 'Automatic end-of-day settlement';

  @override
  String get manualSettlement => 'Manual Settlement';

  @override
  String get executeSettlementNow => 'Execute settlement now';

  @override
  String get settlingInProgress => 'Settling...';

  @override
  String get paymentDevicesSettingsSaved => 'Payment devices settings saved';

  @override
  String get printerType => 'Printer Type';

  @override
  String get thermalUsbPrinter => 'USB thermal printer';

  @override
  String get bluetoothPortablePrinter => 'Bluetooth portable printer';

  @override
  String get saveAsPdf => 'Save as PDF file';

  @override
  String get compactTemplate => 'Compact';

  @override
  String get basicInfoOnly => 'Basic info only';

  @override
  String get detailedTemplate => 'Detailed';

  @override
  String get allDetails => 'All details';

  @override
  String get printOptions => 'Print Options';

  @override
  String get autoPrinting => 'Auto Printing';

  @override
  String get autoPrintAfterSale => 'Auto print receipt after each sale';

  @override
  String get testPrintInProgress => 'Test printing...';

  @override
  String get testPrint => 'Test Print';

  @override
  String get printerSettingsSaved => 'Printer settings saved';

  @override
  String get printerSettingsSubtitle => 'Printer type, template, auto print';

  @override
  String get enableScanner => 'Enable Scanner';

  @override
  String get barcodeScanner => 'Barcode Scanner';

  @override
  String get barcodeScannerDesc => 'Use barcode scanner to add products';

  @override
  String get deviceCamera => 'Device Camera';

  @override
  String get bluetoothScanner => 'Bluetooth Scanner';

  @override
  String get externalScannerConnected => 'External scanner connected';

  @override
  String get alerts => 'Alerts';

  @override
  String get beepOnScan => 'Beep on Scan';

  @override
  String get vibrateOnScan => 'Vibrate on Scan';

  @override
  String get behavior => 'Behavior';

  @override
  String get autoAddToCart => 'Auto Add to Cart';

  @override
  String get autoAddToCartDesc => 'When scanning existing product';

  @override
  String get barcodeFormats => 'Barcode Formats';

  @override
  String get allFormats => 'All formats';

  @override
  String get unspecified => 'Unspecified';

  @override
  String get qrCodeOnly => 'QR Code only';

  @override
  String get testing => 'Testing';

  @override
  String get testScanner => 'Test Scanner';

  @override
  String get testScanBarcode => 'Try scanning a barcode';

  @override
  String get pointCameraAtBarcode => 'Point camera at the barcode';

  @override
  String get scanArea => 'Scan area';

  @override
  String get barcodeSettingsSubtitle => 'Scanner, alerts, formats';

  @override
  String get taxSettingsSubtitle => 'VAT, ZATCA, e-invoicing';

  @override
  String get vatSettings => 'Value Added Tax';

  @override
  String get enableVat => 'Enable VAT';

  @override
  String get enableVatDesc => 'Apply VAT on all sales';

  @override
  String get taxRate => 'Tax Rate';

  @override
  String get taxNumberHint => '15 digits starting with 3';

  @override
  String get pricesIncludeTax => 'Prices Include Tax';

  @override
  String get pricesIncludeTaxDesc => 'Displayed prices include tax';

  @override
  String get showTaxOnReceipt => 'Show Tax on Receipt';

  @override
  String get showTaxOnReceiptDesc => 'Show tax details';

  @override
  String get zatcaEInvoicing => 'ZATCA - E-Invoicing';

  @override
  String get enableZatca => 'Enable ZATCA';

  @override
  String get enableZatcaDesc => 'Comply with e-invoicing system';

  @override
  String get phaseOne => 'Phase 1';

  @override
  String get phaseOneDesc => 'Invoice issuance';

  @override
  String get phaseTwo => 'Phase 2';

  @override
  String get phaseTwoDesc => 'Integration and linking';

  @override
  String get taxSettingsSaved => 'Tax settings saved';

  @override
  String get discountSettingsTitle => 'Discount Settings';

  @override
  String get discountSettingsSubtitle => 'Manual, VIP, volume, coupons';

  @override
  String get generalDiscounts => 'General Discounts';

  @override
  String get enableDiscountsOption => 'Enable Discounts';

  @override
  String get enableDiscountsDesc => 'Allow applying discounts';

  @override
  String get manualDiscount => 'Manual Discount';

  @override
  String get manualDiscountDesc => 'Allow cashier to enter manual discount';

  @override
  String get maxDiscountLimit => 'Max Discount Limit';

  @override
  String get requireApproval => 'Require Approval';

  @override
  String get requireApprovalDesc => 'Require manager approval for discount';

  @override
  String get vipCustomerDiscount => 'VIP Customer Discount';

  @override
  String get vipDiscount => 'VIP Discount';

  @override
  String get vipDiscountDesc => 'Auto discount for VIP customers';

  @override
  String get vipDiscountRate => 'VIP Discount Rate';

  @override
  String get otherDiscounts => 'Other Discounts';

  @override
  String get volumeDiscount => 'Volume Discount';

  @override
  String get volumeDiscountDesc => 'Auto discount on certain quantities';

  @override
  String get couponsOption => 'Coupons';

  @override
  String get couponsDesc => 'Support discount coupons';

  @override
  String get discountSettingsSaved => 'Discount settings saved';

  @override
  String get interestSettingsTitle => 'Interest Settings';

  @override
  String get interestSettingsSubtitle => 'Rate, grace period, auto calculation';

  @override
  String get monthlyInterest => 'Monthly Interest';

  @override
  String get enableInterest => 'Enable Interest';

  @override
  String get enableInterestDesc => 'Apply interest on credit debts';

  @override
  String get monthlyInterestRate => 'Monthly Interest Rate';

  @override
  String get maxInterestRateLabel => 'Max Interest Rate';

  @override
  String get gracePeriod => 'Grace Period';

  @override
  String get graceDays => 'Grace Days';

  @override
  String graceDaysLabel(int days) {
    return '$days days before interest calculation';
  }

  @override
  String get compoundInterest => 'Compound Interest';

  @override
  String get compoundInterestDesc => 'Calculate interest on interest';

  @override
  String get calculationAndAlerts => 'Calculation & Alerts';

  @override
  String get autoCalculation => 'Auto Calculation';

  @override
  String get autoCalculationDesc =>
      'Auto calculate interest at end of each month';

  @override
  String get customerNotification => 'Customer Notification';

  @override
  String get customerNotificationDesc =>
      'Send notification when interest is calculated';

  @override
  String get interestSettingsSaved => 'Interest settings saved';

  @override
  String get receiptTemplateTitle => 'Receipt Template';

  @override
  String get receiptTemplateSubtitle => 'Header, footer, fields, paper size';

  @override
  String get headerAndFooter => 'Header & Footer';

  @override
  String get receiptTitleField => 'Receipt Title';

  @override
  String get footerText => 'Footer Text';

  @override
  String get displayedFields => 'Displayed Fields';

  @override
  String get storeLogo => 'Store Logo';

  @override
  String get addressField => 'Address';

  @override
  String get phoneNumberField => 'Phone Number';

  @override
  String get vatNumberField => 'VAT Number';

  @override
  String get invoiceBarcode => 'Invoice Barcode';

  @override
  String get qrCodeField => 'QR Code';

  @override
  String get qrCodeEInvoice => 'QR code for e-invoice';

  @override
  String get paperSize => 'Paper Size';

  @override
  String get standardSize => 'Standard size';

  @override
  String get smallSize => 'Small size';

  @override
  String get normalPrint => 'Normal print';

  @override
  String get receiptTemplateSaved => 'Receipt template saved';

  @override
  String get instantNotifications => 'Instant notifications on device';

  @override
  String get emailNotificationsDesc => 'Send notifications via email';

  @override
  String get smsNotificationsDesc => 'Notifications via text messages';

  @override
  String get salesAlertsDesc => 'Sales and invoices alerts';

  @override
  String get inventoryAlertsDesc => 'Low stock alerts';

  @override
  String get securityAlertsDesc => 'Security and login alerts';

  @override
  String get reportAlertsDesc => 'Daily and weekly reports';

  @override
  String get contactSupportDesc => 'Available 24/7';

  @override
  String get systemGuide => 'System Guide';

  @override
  String get changeLog => 'Change Log';

  @override
  String get faqQuestion1 => 'How to add a new product?';

  @override
  String get faqAnswer1 =>
      'Go to Products > Add Product and fill in the details';

  @override
  String get faqQuestion2 => 'How to print invoices?';

  @override
  String get faqAnswer2 => 'After completing the sale, click Print Receipt';

  @override
  String get faqQuestion3 => 'How to set discounts?';

  @override
  String get faqAnswer3 =>
      'From Settings > Discount Settings, you can configure discounts';

  @override
  String get faqQuestion4 => 'How to add a new user?';

  @override
  String get faqAnswer4 => 'From Settings > User Management > Add User';

  @override
  String get faqQuestion5 => 'How to view reports?';

  @override
  String get faqAnswer5 =>
      'From the main menu > Reports, choose the desired report type';

  @override
  String get businessNameValue => 'Al-Hai Business';

  @override
  String get disabledLabel => 'Disabled';

  @override
  String get allFilter => 'All';

  @override
  String get loginLogoutFilter => 'Login/Logout';

  @override
  String get salesFilter => 'Sales';

  @override
  String get productsFilter => 'Products';

  @override
  String get usersFilter => 'Users';

  @override
  String get systemFilter => 'System';

  @override
  String get noActivities => 'No activities';

  @override
  String get pinSection => 'PIN Code';

  @override
  String get createPinOption => 'Create PIN';

  @override
  String get createPinDesc => 'Set a 4-digit PIN for fast login';

  @override
  String get changePinOption => 'Change PIN';

  @override
  String get changePinDesc => 'Update your current PIN';

  @override
  String get removePinOption => 'Remove PIN';

  @override
  String get removePinDesc => 'Delete PIN and use OTP login';

  @override
  String get biometricSection => 'Biometric Login';

  @override
  String get fingerprintOption => 'Fingerprint';

  @override
  String get fingerprintDesc => 'Login using fingerprint';

  @override
  String get faceIdOption => 'Face ID';

  @override
  String get faceIdDesc => 'Login using face recognition';

  @override
  String get sessionSection => 'Session';

  @override
  String get autoLockOption => 'Auto Lock';

  @override
  String get autoLockDesc => 'Lock screen after inactivity';

  @override
  String get autoLockTimeout => 'Auto Lock Timeout';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get logoutAllDevices => 'Logout All Devices';

  @override
  String get logoutAllDevicesDesc => 'End all active sessions';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get clearAllDataDesc => 'Delete all local data';

  @override
  String get createPinTitle => 'Create PIN';

  @override
  String get enterNewPin => 'Enter new 4-digit PIN';

  @override
  String get changePinTitle => 'Change PIN';

  @override
  String get enterCurrentPin => 'Enter current PIN';

  @override
  String get enterNewPinChange => 'Enter new PIN';

  @override
  String get removePinTitle => 'Remove PIN';

  @override
  String get removePinConfirm => 'Are you sure you want to remove PIN login?';

  @override
  String get removeAction => 'Remove';

  @override
  String get pinCreated => 'PIN created successfully';

  @override
  String get pinChangedSuccess => 'PIN changed successfully';

  @override
  String get pinRemovedSuccess => 'PIN removed';

  @override
  String get logoutAllTitle => 'Logout All Devices';

  @override
  String get logoutAllConfirm =>
      'This will end all active sessions. You will need to login again.';

  @override
  String get logoutAllAction => 'Logout All';

  @override
  String get loggedOutAll => 'All devices logged out';

  @override
  String get clearDataTitle => 'Clear All Data';

  @override
  String get clearDataConfirm =>
      'This will delete all local data. This action cannot be undone.';

  @override
  String get clearDataAction => 'Clear Data';

  @override
  String get dataCleared => 'All data cleared';

  @override
  String afterMinutes(int count) {
    return 'After $count minutes';
  }

  @override
  String get storeInfo => 'Store Information';

  @override
  String get storeNameField => 'Store Name';

  @override
  String get addressLabel => 'Address';

  @override
  String get taxInfo => 'Tax Information';

  @override
  String get vatNumberFieldLabel => 'VAT Number (VAT)';

  @override
  String get vatNumberHintText => '15 digits starting with 3';

  @override
  String get commercialRegister => 'Commercial Register';

  @override
  String get enableVatOption => 'Enable VAT';

  @override
  String get taxRateField => 'Tax Rate';

  @override
  String get languageAndCurrency => 'Language & Currency';

  @override
  String get currencyFieldLabel => 'Currency';

  @override
  String get saudiRiyal => 'Saudi Riyal (SAR)';

  @override
  String get usDollar => 'US Dollar (USD)';

  @override
  String get storeLogoSection => 'Store Logo';

  @override
  String get storeLogoDesc => 'Appears on invoices and receipts';

  @override
  String get changeButton => 'Change';

  @override
  String get storeSettingsSaved => 'Store settings saved';

  @override
  String get ownerRole => 'Owner';

  @override
  String get managerRole => 'Manager';

  @override
  String get supervisorRole => 'Supervisor';

  @override
  String get cashierRole => 'Cashier';

  @override
  String get disabledStatus => 'Disabled';

  @override
  String get editMenuAction => 'Edit';

  @override
  String get disableMenuAction => 'Disable';

  @override
  String get enableMenuAction => 'Enable';

  @override
  String get addUserTitle => 'Add User';

  @override
  String get editUserTitle => 'Edit User';

  @override
  String get nameRequired => 'Name *';

  @override
  String get roleLabel => 'Role';

  @override
  String get userDetailsTitle => 'User Details';

  @override
  String get rolesTab => 'Roles';

  @override
  String get permissionsTab => 'Permissions';

  @override
  String get newRoleButton => 'New Role';

  @override
  String get systemBadge => 'System';

  @override
  String userCountLabel(int count) {
    return '$count users';
  }

  @override
  String permissionCountLabel(int count) {
    return '$count permissions';
  }

  @override
  String get editRoleMenu => 'Edit';

  @override
  String get duplicateRoleMenu => 'Duplicate';

  @override
  String get deleteRoleMenu => 'Delete';

  @override
  String get addRoleTitle => 'Add Role';

  @override
  String get editRoleTitle => 'Edit Role';

  @override
  String get roleNameField => 'Role Name';

  @override
  String get roleDescField => 'Description';

  @override
  String get rolePermissionsLabel => 'Permissions';

  @override
  String get permViewSales => 'View Sales';

  @override
  String get permViewSalesDesc => 'View sales and invoices';

  @override
  String get permCreateSale => 'Create Sale';

  @override
  String get permCreateSaleDesc => 'Create new sales';

  @override
  String get permApplyDiscount => 'Apply Discount';

  @override
  String get permApplyDiscountDesc => 'Apply discounts to invoices';

  @override
  String get permVoidSale => 'Void Sale';

  @override
  String get permVoidSaleDesc => 'Cancel and void sales';

  @override
  String get permViewProducts => 'View Products';

  @override
  String get permViewProductsDesc => 'View product list';

  @override
  String get permEditProducts => 'Edit Products';

  @override
  String get permEditProductsDesc => 'Edit product details and prices';

  @override
  String get permManageInventory => 'Manage Inventory';

  @override
  String get permManageInventoryDesc => 'Manage stock and inventory';

  @override
  String get permViewReports => 'View Reports';

  @override
  String get permViewReportsDesc => 'View all reports';

  @override
  String get permExportReports => 'Export Reports';

  @override
  String get permExportReportsDesc => 'Export reports as PDF/Excel';

  @override
  String get permViewCustomers => 'View Customers';

  @override
  String get permViewCustomersDesc => 'View customer list';

  @override
  String get permManageCustomers => 'Manage Customers';

  @override
  String get permManageCustomersDesc => 'Add and edit customers';

  @override
  String get permManageDebts => 'Manage Debts';

  @override
  String get permManageDebtsDesc => 'Manage customer debts';

  @override
  String get permOpenCloseShift => 'Open/Close Shift';

  @override
  String get permOpenCloseShiftDesc => 'Open and close work shifts';

  @override
  String get permManageCashDrawer => 'Manage Cash Drawer';

  @override
  String get permManageCashDrawerDesc => 'Add and withdraw cash';

  @override
  String get permManageUsers => 'Manage Users';

  @override
  String get permManageUsersDesc => 'Add and edit users';

  @override
  String get permManageRoles => 'Manage Roles';

  @override
  String get permManageRolesDesc => 'Manage roles and permissions';

  @override
  String get permViewSettings => 'View Settings';

  @override
  String get permViewSettingsDesc => 'View system settings';

  @override
  String get permEditSettings => 'Edit Settings';

  @override
  String get permEditSettingsDesc => 'Modify system settings';

  @override
  String get permViewAuditLog => 'View Audit Log';

  @override
  String get permViewAuditLogDesc => 'View activity log';

  @override
  String get permManageBackup => 'Manage Backup';

  @override
  String get permManageBackupDesc => 'Backup and restore';

  @override
  String get permCategorySales => 'Sales';

  @override
  String get permCategoryProducts => 'Products';

  @override
  String get permCategoryReports => 'Reports';

  @override
  String get permCategoryCustomers => 'Customers';

  @override
  String get permCategoryShifts => 'Shifts';

  @override
  String get permCategoryUsers => 'Users';

  @override
  String get permCategorySettings => 'Settings';

  @override
  String get permCategorySecurity => 'Security';

  @override
  String get autoBackupEnabled => 'Auto backup enabled';

  @override
  String get autoBackupDisabledLabel => 'Disabled';

  @override
  String get backupFrequency => 'Backup Frequency';

  @override
  String get everyHour => 'Every hour';

  @override
  String get dailyBackup => 'Daily';

  @override
  String get weeklyBackup => 'Weekly';

  @override
  String get manualBackupSection => 'Manual Backup';

  @override
  String get createBackupNow => 'Create Backup Now';

  @override
  String get lastBackupTime => 'Last backup: 3 hours ago';

  @override
  String get restoreSection => 'Restore';

  @override
  String get restoreFromBackup => 'Restore from Backup';

  @override
  String get restoreFromBackupDesc => 'Restore data from a previous backup';

  @override
  String get backupHistoryLabel => 'Backup History';

  @override
  String get backupInProgress => 'Creating backup...';

  @override
  String get backupCreated => 'Backup created successfully';

  @override
  String get restoreConfirmTitle => 'Restore from Backup';

  @override
  String get restoreConfirmMessage =>
      'This will replace all current data. This action cannot be undone.';

  @override
  String get restoreAction => 'Restore';

  @override
  String get restoreInProgress => 'Restoring...';

  @override
  String get restoreComplete => 'Restore complete';

  @override
  String get pasteCode => 'Paste code';

  @override
  String devOtpMessage(String otp) {
    return 'Dev OTP: $otp';
  }

  @override
  String get orderHistory => 'Order History';

  @override
  String get history => 'History';

  @override
  String get selectDateRange => 'Select Period';

  @override
  String get orderSearchHint => 'Search by order number or customer ID...';

  @override
  String get noOrders => 'No orders';

  @override
  String get orderStatusConfirmed => 'Confirmed';

  @override
  String get orderStatusPreparing => 'Preparing';

  @override
  String get orderStatusReady => 'Ready';

  @override
  String get orderStatusDelivering => 'Delivering';

  @override
  String get filterOrders => 'Filter Orders';

  @override
  String get channelApp => 'App';

  @override
  String get channelWhatsapp => 'WhatsApp';

  @override
  String get channelPos => 'POS';

  @override
  String get paymentCashType => 'Cash';

  @override
  String get paymentMixed => 'Mixed';

  @override
  String get paymentOnline => 'Online';

  @override
  String get shareAction => 'Share';

  @override
  String get exportOrders => 'Export Orders';

  @override
  String get selectExportFormat => 'Select export format';

  @override
  String get exportedAsExcel => 'Exported as Excel';

  @override
  String get exportedAsPdf => 'Exported as PDF';

  @override
  String get alertSettings => 'Alert Settings';

  @override
  String get acknowledgeAll => 'Acknowledge All';

  @override
  String allWithCount(int count) {
    return 'All ($count)';
  }

  @override
  String lowStockWithCount(int count) {
    return 'Low Stock ($count)';
  }

  @override
  String expiryWithCount(int count) {
    return 'Near Expiry ($count)';
  }

  @override
  String get urgentAlerts => 'Urgent Alerts';

  @override
  String get nearExpiry => 'Near Expiry';

  @override
  String get noAlerts => 'No alerts';

  @override
  String get alertDismissed => 'Alert dismissed';

  @override
  String get undo => 'Undo';

  @override
  String get criticalPriority => 'Critical';

  @override
  String get highPriority => 'Urgent';

  @override
  String stockAlertMessage(int current, int threshold) {
    return 'Quantity: $current (Minimum: $threshold)';
  }

  @override
  String get expiryAlertLabel => 'Expiry alert';

  @override
  String get currentQuantity => 'Current Quantity';

  @override
  String get minimumThreshold => 'Minimum';

  @override
  String get dismissAction => 'Dismiss';

  @override
  String get lowStockNotifications => 'Low Stock Notifications';

  @override
  String get expiryNotifications => 'Expiry Notifications';

  @override
  String get minimumStockLevel => 'Minimum Stock Level';

  @override
  String thresholdUnits(int count) {
    return '$count units';
  }

  @override
  String get acknowledgeAllAlerts => 'Acknowledge All Alerts';

  @override
  String willDismissAlerts(int count) {
    return 'Will dismiss $count alerts';
  }

  @override
  String get allAlertsAcknowledged => 'All alerts acknowledged';

  @override
  String get createPurchaseOrder => 'Create Purchase Order';

  @override
  String productLabelName(String name) {
    return 'Product: $name';
  }

  @override
  String get requiredQuantity => 'Required Quantity';

  @override
  String get createAction => 'Create';

  @override
  String get purchaseOrderCreated => 'Purchase order created';

  @override
  String get newCategory => 'New Category';

  @override
  String productCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
      zero: 'No products',
    );
    return '$_temp0';
  }

  @override
  String get iconLabel => 'Icon:';

  @override
  String get colorLabel => 'Color:';

  @override
  String deleteCategoryMessage(String name, int count) {
    return 'Delete category \"$name\"?\n$count products will be moved to \"Uncategorized\".';
  }

  @override
  String productNumber(int number) {
    return 'Product $number';
  }

  @override
  String priceWithCurrency(String price) {
    return '$price SAR';
  }

  @override
  String get currentlyOpenShift => 'Currently Open Shift';

  @override
  String get since => 'Since';

  @override
  String get transaction => 'transaction';

  @override
  String get totalTransactions => 'Total Transactions';

  @override
  String get openShifts => 'Open Shifts';

  @override
  String get closedShifts => 'Closed Shifts';

  @override
  String get shiftsLog => 'Shifts Log';

  @override
  String get noShiftsToday => 'No shifts today';

  @override
  String get open => 'Open';

  @override
  String get customPeriod => 'Custom Period';

  @override
  String get salesReport => 'Sales Report';

  @override
  String get salesReportDesc => 'Sales and invoices details';

  @override
  String get profitReport => 'Profit Report';

  @override
  String get profitReportDesc => 'Net profit and losses';

  @override
  String get inventoryReport => 'Inventory Report';

  @override
  String get inventoryReportDesc => 'Inventory movements and stocktaking';

  @override
  String get vatReport => 'VAT Report';

  @override
  String get vatReportDesc => 'Value Added Tax 15%';

  @override
  String get customerReport => 'Customer Report';

  @override
  String get customerReportDesc => 'Customer activity and debts';

  @override
  String get purchasesReport => 'Purchases Report';

  @override
  String get purchasesReportDesc => 'Purchase invoices and suppliers';

  @override
  String get costs => 'Costs';

  @override
  String get netProfit => 'Net Profit';

  @override
  String get salesTax => 'Sales Tax';

  @override
  String get purchasesTax => 'Purchases Tax';

  @override
  String get taxDue => 'Tax Due';

  @override
  String get debts => 'Debts';

  @override
  String get paidDebts => 'Paid';

  @override
  String get averageAmount => 'Average';

  @override
  String get suppliers => 'Suppliers';

  @override
  String get todayExpenses => 'Today\'s Expenses';

  @override
  String get transactionCount => 'Transactions Count';

  @override
  String get salaries => 'Salaries';

  @override
  String get rent => 'Rent';

  @override
  String get purchases => 'Purchases';

  @override
  String get noDriversRegistered => 'No drivers registered';

  @override
  String get addDriversForDelivery => 'Add drivers to manage delivery';

  @override
  String get onDelivery => 'On Delivery';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get totalDrivers => 'Total Drivers';

  @override
  String get availableDrivers => 'Available Drivers';

  @override
  String get inDelivery => 'In Delivery';

  @override
  String get excellentRating => 'Excellent Rating';

  @override
  String get delivery => 'delivery';

  @override
  String get track => 'Track';

  @override
  String get percentage => 'Percentage';

  @override
  String get totalSavings => 'Total Savings';

  @override
  String get totalUsage => 'Total Usage';

  @override
  String get times => 'times';

  @override
  String get activeOffers => 'Active Offers';

  @override
  String get upcomingOffers => 'Upcoming Offers';

  @override
  String get expiredOffers => 'Expired Offers';

  @override
  String get bundle => 'Bundle';

  @override
  String get dueDebts => 'Due Debts';

  @override
  String get collected => 'Collected';

  @override
  String get newNotification => 'New Notification';

  @override
  String get oneHourAgo => '1 hour ago';

  @override
  String get twoHoursAgo => '2 hours ago';

  @override
  String get trackingMap => 'Tracking Map';

  @override
  String deliveriesToday(int count) {
    return '$count deliveries today';
  }

  @override
  String get assignOrder => 'Assign Order';

  @override
  String get driversTrackingMap => 'Drivers Tracking Map';

  @override
  String get gpsSubscriptionRequired => '(Requires GPS subscription)';

  @override
  String get vehicleLabel => 'Vehicle';

  @override
  String get vehicleHint => 'e.g.: Hilux - White';

  @override
  String get plateNumberLabel => 'Plate Number';

  @override
  String assignOrderTo(String name) {
    return 'Assign order to $name';
  }

  @override
  String get orderLabel => 'Order';

  @override
  String orderAssignedTo(String name) {
    return 'Order assigned to $name';
  }

  @override
  String closingPeriod(String period) {
    return 'Closing period: $period';
  }

  @override
  String lastClosing(String date) {
    return 'Last closing: $date';
  }

  @override
  String interestRateAndGrace(String rate, String days) {
    return 'Interest rate: $rate% | Grace period: $days days';
  }

  @override
  String get selectedCustomers => 'Selected Customers';

  @override
  String get expectedInterests => 'Expected Interests';

  @override
  String get noDebtsNeedClosing => 'No debts need closing';

  @override
  String get allCustomersWithinGrace =>
      'All customers are within the grace period';

  @override
  String debtLabel(String amount) {
    return 'Debt: $amount SAR';
  }

  @override
  String expectedInterestLabel(String amount) {
    return 'Expected interest: $amount SAR';
  }

  @override
  String selectedCustomerCount(int count) {
    return '$count customer(s) selected';
  }

  @override
  String get processingClose => 'Processing...';

  @override
  String get executeClose => 'Execute Close';

  @override
  String interestWillBeAdded(int count) {
    return 'Interest will be added to $count customer(s)';
  }

  @override
  String totalInterestsLabel(String amount) {
    return 'Total interests: $amount SAR';
  }

  @override
  String monthCloseSuccess(int count) {
    return 'Month closed for $count customer(s)';
  }

  @override
  String get readAll => 'Read All';

  @override
  String get averageExpense => 'Average Expense';

  @override
  String get expensesList => 'Expenses List';

  @override
  String get electricity => 'Electricity';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get services => 'Services';

  @override
  String get expense => 'Expense';

  @override
  String get filterExpenses => 'Filter Expenses';

  @override
  String get openedNotification => 'Opened';

  @override
  String get openTime => 'Open Time';

  @override
  String get closeTime => 'Close Time';

  @override
  String get expectedCash => 'Expected Cash';

  @override
  String get closingCash => 'Closing Cash';

  @override
  String get printAction => 'Print';

  @override
  String get exportAction => 'Export';

  @override
  String get viewReport => 'View Report';

  @override
  String get exportingReport => 'Exporting report...';

  @override
  String get chartsUnderDev => 'Charts under development...';

  @override
  String get reportsAnalysis => 'Performance and sales analysis';

  @override
  String aiAssociationFrequency(
      String productA, String productB, int frequency) {
    return '$productA + $productB: repeated $frequency times';
  }

  @override
  String aiBundleActivated(String name) {
    return 'Bundle activated: $name';
  }

  @override
  String aiPromotionsGeneratedCount(int count) {
    return '$count promotions generated based on store data analysis';
  }

  @override
  String aiPromotionApplied(String title) {
    return 'Applied: $title';
  }

  @override
  String aiConfidencePercent(String percent) {
    return 'Confidence: $percent%';
  }

  @override
  String aiAlertsWithCount(int count) {
    return 'Alerts ($count)';
  }

  @override
  String aiStaffCurrentSuggested(int current, int suggested) {
    return '$current staff currently → $suggested suggested';
  }

  @override
  String aiMinutesAgo(int minutes) {
    return '$minutes minutes ago';
  }

  @override
  String aiHoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String aiDaysAgo(int days) {
    return '$days days ago';
  }

  @override
  String aiDetectedCount(int count) {
    return 'Detected: $count';
  }

  @override
  String aiMatchedCount(int count) {
    return 'Matched: $count';
  }

  @override
  String aiAccuracyPercent(String percent) {
    return 'Accuracy: $percent%';
  }

  @override
  String aiProductAccepted(String name) {
    return '$name accepted';
  }

  @override
  String aiErrorOccurred(String error) {
    return 'Error occurred: $error';
  }

  @override
  String aiErrorWithMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get aiBasketAnalysis => 'AI Basket Analysis';

  @override
  String get aiAssociations => 'Associations';

  @override
  String get aiCrossSell => 'Cross-Sell';

  @override
  String get aiAvgBasketSize => 'Avg Basket Size';

  @override
  String get aiProductUnit => 'products';

  @override
  String get aiAvgBasketValue => 'Avg Basket Value';

  @override
  String get aiSaudiRiyal => 'SAR';

  @override
  String get aiStrongestAssociation => 'Strongest Association';

  @override
  String get aiConversionRate => 'Conversion Rate';

  @override
  String get aiFromSuggestions => 'from suggestions';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get aiAskAboutStore => 'Ask any question about your store';

  @override
  String get aiClearChat => 'Clear Chat';

  @override
  String get aiAssistantReady => 'AI Assistant is ready to help!';

  @override
  String get aiAskAboutSalesStock =>
      'Ask about sales, stock, customers, or anything about your store';

  @override
  String get aiCompetitorAnalysis => 'Competitor Analysis';

  @override
  String get aiPriceComparison => 'Price Comparison';

  @override
  String get aiTrackedProducts => 'Tracked Products';

  @override
  String get aiCheaperThanCompetitors => 'Cheaper than competitors';

  @override
  String get aiMoreExpensive => 'More expensive than competitors';

  @override
  String get aiAvgPriceDiff => 'Avg Price Difference';

  @override
  String get aiSortByName => 'Sort by name';

  @override
  String get aiSortByPriceDiff => 'Sort by price difference';

  @override
  String get aiSortByOurPrice => 'Sort by our price';

  @override
  String get aiSortByCategory => 'Sort by category';

  @override
  String get aiSortLabel => 'Sort';

  @override
  String get aiPriceIndex => 'Price Index';

  @override
  String get aiQuality => 'Quality';

  @override
  String get aiBranches => 'Branches';

  @override
  String get aiMarkAllRead => 'Mark all as read';

  @override
  String get aiNoAlertsCurrently => 'No alerts currently';

  @override
  String get aiFraudDetection => 'AI Fraud Detection';

  @override
  String get aiTotalAlerts => 'Total Alerts';

  @override
  String get aiCriticalAlerts => 'Critical Alerts';

  @override
  String get aiNeedsReview => 'Needs Review';

  @override
  String get aiRiskLevel => 'Risk Level';

  @override
  String get aiBehaviorScores => 'Behavior Scores';

  @override
  String get aiRiskMeter => 'Risk Meter';

  @override
  String get aiHighRisk => 'High Risk';

  @override
  String get aiLowRisk => 'Low Risk';

  @override
  String get aiPatternRefund => 'Refund';

  @override
  String get aiPatternAfterHours => 'After Hours';

  @override
  String get aiPatternVoid => 'Void';

  @override
  String get aiPatternDiscount => 'Discount';

  @override
  String get aiPatternSplit => 'Split';

  @override
  String get aiPatternCashDrawer => 'Cash Drawer';

  @override
  String get aiNoFraudAlerts => 'No alerts';

  @override
  String get aiSelectAlertToInvestigate =>
      'Select an alert from the list to investigate';

  @override
  String get aiStaffAnalytics => 'Staff Analytics';

  @override
  String get aiLeaderboard => 'Leaderboard';

  @override
  String get aiIndividualPerformance => 'Individual Performance';

  @override
  String get aiAvgPerformance => 'Avg Performance';

  @override
  String get aiTotalSalesLabel => 'Total Sales';

  @override
  String get aiTotalTransactions => 'Total Transactions';

  @override
  String get aiAvgVoidRate => 'Avg Void Rate';

  @override
  String get aiTeamGrowth => 'Team Growth';

  @override
  String get aiLeaderboardThisWeek => 'Leaderboard - This Week';

  @override
  String get aiSalesForecasting => 'Sales Forecasting';

  @override
  String get aiSmartForecastSubtitle =>
      'Smart analysis for future sales prediction';

  @override
  String get aiForecastAccuracy => 'Forecast Accuracy';

  @override
  String get aiTrendUp => 'Upward';

  @override
  String get aiTrendDown => 'Downward';

  @override
  String get aiTrendStable => 'Stable';

  @override
  String get aiNextWeekForecast => 'Next Week Forecast';

  @override
  String get aiMonthForecast => 'Month Forecast';

  @override
  String get aiForecastSummary => 'Forecast Summary';

  @override
  String get aiSalesTrendingUp => 'Sales trending up - keep going!';

  @override
  String get aiSalesDeclining => 'Sales declining - activate offers';

  @override
  String get aiSalesStable => 'Sales stable - maintain performance';

  @override
  String get aiProductRecognition => 'Product Recognition';

  @override
  String get aiSingleProduct => 'Single Product';

  @override
  String get aiShelfScan => 'Shelf Scan';

  @override
  String get aiBarcodeOcr => 'Barcode OCR';

  @override
  String get aiPriceTag => 'Price Tag';

  @override
  String get aiCameraArea => 'Camera Area';

  @override
  String get aiPointCameraAtProduct =>
      'Point the camera at the product or shelf';

  @override
  String get aiStartScan => 'Start Scan';

  @override
  String get aiAnalyzingImage => 'Analyzing image...';

  @override
  String get aiStartScanToSeeResults => 'Start scanning to see results';

  @override
  String get aiScanResults => 'Scan Results';

  @override
  String get aiProductSaved => 'Product saved successfully';

  @override
  String get aiPromotionDesigner => 'AI Promotion Designer';

  @override
  String get aiSuggestedPromotions => 'Suggested Promotions';

  @override
  String get aiRoiAnalysis => 'ROI Analysis';

  @override
  String get aiAbTest => 'A/B Test';

  @override
  String get aiSmartPromotionDesigner => 'Smart Promotion Designer';

  @override
  String get aiProjectedRevenue => 'Projected Revenue';

  @override
  String get aiAiConfidence => 'AI Confidence';

  @override
  String get aiSelectPromotionForRoi =>
      'Select a promotion from the first tab to view ROI analysis';

  @override
  String get aiRevenueLabel => 'Revenue';

  @override
  String get aiCostLabel => 'Cost';

  @override
  String get aiDiscountLabel => 'Discount';

  @override
  String get aiAbTestDescription =>
      'A/B test splits your customers into two groups and shows each group a different offer to determine the best performer.';

  @override
  String get aiAbTestLaunched => 'A/B test launched successfully!';

  @override
  String get aiChatWithData => 'Chat with Data - AI';

  @override
  String get aiChatWithYourData => 'Chat with your Data';

  @override
  String get aiAskAboutDataInArabic =>
      'Ask any question about your sales, stock, and customers in Arabic';

  @override
  String get aiTrySampleQuestions => 'Try one of these questions';

  @override
  String get aiTip => 'Tip';

  @override
  String get aiTipDescription =>
      'You can ask in Arabic or English. AI understands context and chooses the best way to display results: numbers, tables, or charts.';

  @override
  String get loadingApp => 'Loading...';

  @override
  String get initializingSearch => 'Initializing search...';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get initializingDemoData => 'Initializing demo data...';

  @override
  String get pointOfSale => 'Point of Sale';

  @override
  String get managerPinSetup => 'Manager PIN Setup';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get createNewPin => 'Create New PIN';

  @override
  String get reenterPinToConfirm => 'Re-enter PIN to confirm';

  @override
  String get enterFourDigitPin => 'Enter a 4-digit PIN';

  @override
  String get pinsMismatch => 'PINs do not match';

  @override
  String get managerPinCreatedSuccess => 'Manager PIN created successfully';

  @override
  String get enterManagerPin => 'Enter manager PIN';

  @override
  String get operationRequiresApproval =>
      'This operation requires manager approval';

  @override
  String get approvalGranted => 'Approved';

  @override
  String accountLockedWaitMinutes(int minutes) {
    return 'Account locked. Wait $minutes minutes';
  }

  @override
  String wrongPinAttemptsRemaining(int remaining) {
    return 'Wrong PIN. Remaining attempts: $remaining';
  }

  @override
  String get selectYourBranchToContinue => 'Select your branch to continue';

  @override
  String get branchClosed => 'Closed';

  @override
  String get noResultsFoundSearch => 'No results found';

  @override
  String branchSelectedMessage(String branchName) {
    return '$branchName selected';
  }

  @override
  String get shiftIsClosed => 'Shift Closed';

  @override
  String get noOpenShiftCurrently => 'No open shift currently';

  @override
  String get shiftIsOpen => 'Shift Open';

  @override
  String shiftOpenSince(String time) {
    return 'Since: $time';
  }

  @override
  String get balanceSummary => 'Balance Summary';

  @override
  String get cashIncoming => 'Cash In';

  @override
  String get cashOutgoing => 'Cash Out';

  @override
  String get expectedBalance => 'Expected Balance';

  @override
  String get noCashMovementsYet => 'No cash movements yet';

  @override
  String get noteLabel => 'Note';

  @override
  String get depositDone => 'Deposit completed';

  @override
  String get withdrawalDone => 'Withdrawal completed';

  @override
  String get amPeriod => 'AM';

  @override
  String get pmPeriod => 'PM';

  @override
  String get newPurchaseInvoice => 'New Purchase Invoice';

  @override
  String get supplierData => 'Supplier Information';

  @override
  String get selectSupplierRequired => 'Select Supplier *';

  @override
  String get supplierInvoiceNumber => 'Supplier Invoice Number';

  @override
  String get noProductsAddedYet => 'No products added yet';

  @override
  String get paymentStatus => 'Payment Status';

  @override
  String get paidStatus => 'Paid';

  @override
  String get deferredPayment => 'Deferred';

  @override
  String get productNameRequired => 'Product Name *';

  @override
  String get purchasePrice => 'Purchase Price';

  @override
  String get pleaseSelectSupplier => 'Please select the supplier';

  @override
  String purchaseInvoiceSavedTotal(String total) {
    return 'Purchase invoice saved with total $total SAR';
  }

  @override
  String get smartReorderAi => 'AI Smart Reorder';

  @override
  String get smartReorderDescription =>
      'Set your budget and let AI optimize your purchases';

  @override
  String get orderSettings => 'Order Settings';

  @override
  String get availableBudget => 'Available Budget';

  @override
  String get enterAvailableAmount => 'Enter available purchase amount';

  @override
  String supplierLabel(String name) {
    return 'Supplier: $name';
  }

  @override
  String get calculating => 'Calculating...';

  @override
  String get calculateSmartDistribution => 'Calculate Smart Distribution';

  @override
  String get setBudgetAndCalculate => 'Set budget and press calculate';

  @override
  String get numberOfProducts => 'Number of Products';

  @override
  String get suggestedProducts => 'Suggested Products';

  @override
  String get sendOrder => 'Send Order';

  @override
  String get emailLabel => 'Email';

  @override
  String get confirmSending => 'Confirm Sending';

  @override
  String sendOrderToSupplier(String supplier) {
    return 'Send order to $supplier?';
  }

  @override
  String get orderSentSuccess => 'Order sent to distributor successfully';

  @override
  String turnoverRate(String rate) {
    return 'Turnover: $rate%';
  }

  @override
  String get editSupplier => 'Edit Supplier';

  @override
  String get addNewSupplier => 'Add New Supplier';

  @override
  String get basicInfo => 'Basic Information';

  @override
  String get supplierContactName => 'Supplier / Contact Name *';

  @override
  String get companyNameRequired => 'Company Name *';

  @override
  String get generalCategory => 'General';

  @override
  String get foodMaterials => 'Food Materials';

  @override
  String get beverages => 'Beverages';

  @override
  String get vegetablesFruits => 'Vegetables & Fruits';

  @override
  String get equipment => 'Equipment';

  @override
  String get contactInfo => 'Contact Information';

  @override
  String get primaryPhoneRequired => 'Primary Phone *';

  @override
  String get secondaryPhoneOptional => 'Secondary Phone (Optional)';

  @override
  String get emailField => 'Email';

  @override
  String get addressField2 => 'Address';

  @override
  String get commercialInfo => 'Commercial Information';

  @override
  String get taxNumberVat => 'Tax Number (VAT)';

  @override
  String get commercialRegNumber => 'Commercial Registration (CR)';

  @override
  String get financialInfo => 'Financial Information';

  @override
  String get paymentTerms => 'Payment Terms';

  @override
  String get payOnDelivery => 'Pay on Delivery';

  @override
  String get sevenDays => '7 Days';

  @override
  String get fourteenDays => '14 Days';

  @override
  String get thirtyDays => '30 Days';

  @override
  String get sixtyDays => '60 Days';

  @override
  String get bankName => 'Bank Name';

  @override
  String get ibanNumber => 'IBAN Number';

  @override
  String get additionalSettings => 'Additional Settings';

  @override
  String get supplierIsActive => 'Supplier Active';

  @override
  String get notesField => 'Notes';

  @override
  String get savingData => 'Saving...';

  @override
  String get updateSupplier => 'Update Supplier';

  @override
  String get addSupplierBtn => 'Add Supplier';

  @override
  String get deleteSupplier => 'Delete Supplier';

  @override
  String get supplierUpdatedSuccess => 'Supplier updated successfully';

  @override
  String get supplierAddedSuccess => 'Supplier added successfully';

  @override
  String get supplierDeletedSuccess => 'Supplier deleted';

  @override
  String get deleteSupplierConfirmTitle => 'Delete Supplier';

  @override
  String get deleteSupplierConfirmMessage =>
      'Are you sure you want to delete this supplier? This action cannot be undone.';

  @override
  String get supplierDetailsTitle => 'Supplier Details';

  @override
  String get backButton => 'Back';

  @override
  String get editButton => 'Edit';

  @override
  String get newPurchaseOrder => 'New Purchase Order';

  @override
  String get deleteButton => 'Delete';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get supplierEmailLabel => 'Email';

  @override
  String get supplierAddressLabel => 'Address';

  @override
  String get dueToSupplier => 'Due to Supplier';

  @override
  String get balanceInOurFavor => 'Balance in Our Favor';

  @override
  String get paymentBtn => 'Pay';

  @override
  String get totalPurchasesLabel => 'Total Purchases';

  @override
  String get lastPurchaseDate => 'Last Purchase';

  @override
  String get recentPurchases => 'Recent Purchases';

  @override
  String get noPurchasesYet => 'No purchases yet';

  @override
  String get pendingLabel => 'Pending';

  @override
  String get deleteSupplierDialogTitle => 'Delete Supplier';

  @override
  String get deleteSupplierDialogMessage =>
      'All supplier data will be deleted. Continue?';

  @override
  String get unknownUser => 'Unknown';

  @override
  String get employeeRole => 'Employee';

  @override
  String get operationCount => 'operation';

  @override
  String get dayCount => 'day';

  @override
  String get personalInfoSection => 'Personal Information';

  @override
  String get emailInfoLabel => 'Email';

  @override
  String get phoneInfoLabel => 'Phone';

  @override
  String get branchInfoLabel => 'Branch';

  @override
  String get employeeIdLabel => 'Employee ID';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get mainBranchDefault => 'Main Branch';

  @override
  String get changePassword => 'Change Password';

  @override
  String get activityLogLink => 'Activity Log';

  @override
  String get logoutButton => 'Logout';

  @override
  String get systemAdminRole => 'System Admin';

  @override
  String get noBranchesRegistered => 'No branches registered';

  @override
  String get branchEmailLabel => 'Email';

  @override
  String get branchCityLabel => 'City';

  @override
  String get importSupplierInvoice => 'Import Supplier Invoice';

  @override
  String get captureOrSelectPhoto =>
      'Capture a photo or select from gallery\nData will be extracted automatically';

  @override
  String get captureImage => 'Capture Image';

  @override
  String get galleryPick => 'Gallery';

  @override
  String get anotherImage => 'Another Image';

  @override
  String get aiProcessingBtn => 'AI Processing';

  @override
  String get processingInvoice => 'Processing invoice...';

  @override
  String get extractingDataWithAi => 'Extracting data with AI';

  @override
  String get dataExtracted => 'Data Extracted';

  @override
  String get purchaseInvoiceCreated => 'Purchase invoice created';

  @override
  String get reviewInvoice => 'Review Invoice';

  @override
  String get confirmAllItems => 'Confirm All';

  @override
  String get unknownSupplier => 'Unknown Supplier';

  @override
  String itemCount(int count) {
    return 'Items count: $count';
  }

  @override
  String progressLabel(int confirmed, int total) {
    return 'Progress: $confirmed / $total';
  }

  @override
  String needsReviewCount(int count) {
    return '$count needs review';
  }

  @override
  String get notMatchedStatus => 'Not Matched';

  @override
  String get matchedStatus => 'Matched';

  @override
  String get matchedProductLabel => 'Matched Product';

  @override
  String matchedWithName(String name) {
    return 'Matched: $name';
  }

  @override
  String get searchForProduct => 'Search for product...';

  @override
  String get createNewProduct => 'Create New Product';

  @override
  String get savingInvoice => 'Saving...';

  @override
  String get invoiceSavedSuccess => 'Purchase invoice saved successfully';

  @override
  String get customerAnalytics => 'Customer Analytics';

  @override
  String get weekPeriod => 'Week';

  @override
  String get monthPeriod => 'Month';

  @override
  String get yearPeriod => 'Year';

  @override
  String get totalCustomers => 'Total Customers';

  @override
  String get newCustomers => 'New Customers';

  @override
  String get returningCustomers => 'Returning Customers';

  @override
  String get averageSpending => 'Average Spending';

  @override
  String get topCustomers => 'Top Customers';

  @override
  String orderCount(int count) {
    return '$count orders';
  }

  @override
  String get customerDistribution => 'Customer Distribution';

  @override
  String get vipCustomers => 'VIP (over 5,000 SAR)';

  @override
  String get regularCustomers => 'Regular (1,000-5,000 SAR)';

  @override
  String get normalCustomers => 'Normal (under 1,000 SAR)';

  @override
  String get customerActivity => 'Customer Activity';

  @override
  String get activeLabel => 'Active';

  @override
  String get dormantLabel => 'Dormant';

  @override
  String get inactiveLabel => 'Inactive';

  @override
  String get noPrintJobsPending => 'No pending print jobs';

  @override
  String get printerConnected => 'Printer connected';

  @override
  String get totalPrintLabel => 'Total';

  @override
  String get waitingPrintLabel => 'Waiting';

  @override
  String get failedPrintLabel => 'Failed';

  @override
  String pendingJobsCount(int count) {
    return '$count pending jobs';
  }

  @override
  String get printingInProgress => 'Printing...';

  @override
  String get failedRetry => 'Failed - Try again';

  @override
  String get waitingStatus => 'Waiting';

  @override
  String printingOrderId(String orderId) {
    return 'Printing $orderId...';
  }

  @override
  String get allJobsPrinted => 'All jobs printed';

  @override
  String get clearPrintQueueTitle => 'Clear Print Queue';

  @override
  String get clearPrintQueueConfirm => 'Clear all pending print jobs?';

  @override
  String get clearBtn => 'Clear';

  @override
  String get gotIt => 'Got it';

  @override
  String get print => 'Print';

  @override
  String get display => 'Display';

  @override
  String get item => 'Item';

  @override
  String get invoice => 'Invoice';

  @override
  String get accept => 'Accept';

  @override
  String get details => 'Details';

  @override
  String get newLabel => 'New';

  @override
  String get mixed => 'Mixed';

  @override
  String get lowStockLabel => 'Low';

  @override
  String get debtor => 'Debtor';

  @override
  String get creditor => 'Creditor';

  @override
  String get balanceLabel => 'Balance';

  @override
  String get returnLabel => 'Return';

  @override
  String get skip => 'Skip';

  @override
  String get send => 'Send';

  @override
  String get cloud => 'Cloud';

  @override
  String get defaultLabel => 'Default';

  @override
  String get closed => 'Closed';

  @override
  String get owes => 'Owes';

  @override
  String get due => 'Due';

  @override
  String get balanced => 'Balanced';

  @override
  String get offlineModeTitle => 'Offline Mode';

  @override
  String get offlineModeDescription => 'You can continue using the app:';

  @override
  String get offlineCanSell => 'Make sales';

  @override
  String get offlineCanAddToCart => 'Add products to cart';

  @override
  String get offlineCanPrint => 'Print receipts';

  @override
  String get offlineAutoSync =>
      'Data will sync automatically when connection is restored.';

  @override
  String get offlineSavingLocally => 'Offline - saving operations locally';

  @override
  String get seconds => 'Seconds';

  @override
  String get errors => 'Errors';

  @override
  String get syncLabel => 'Sync';

  @override
  String get slow => 'Slow';

  @override
  String get myGrocery => 'My Grocery';

  @override
  String get cashier => 'Cashier';

  @override
  String get goBack => 'Go Back';

  @override
  String get menuLabel => 'Menu';

  @override
  String get gold => 'Gold';

  @override
  String get silver => 'Silver';

  @override
  String get diamond => 'Diamond';

  @override
  String get bronze => 'Bronze';

  @override
  String get saudiArabia => 'Saudi Arabia';

  @override
  String get uae => 'UAE';

  @override
  String get kuwait => 'Kuwait';

  @override
  String get bahrain => 'Bahrain';

  @override
  String get qatar => 'Qatar';

  @override
  String get oman => 'Oman';

  @override
  String get control => 'Control';

  @override
  String get strong => 'Strong';

  @override
  String get medium => 'Medium';

  @override
  String get weak => 'Weak';

  @override
  String get good => 'Good';

  @override
  String get danger => 'Danger';

  @override
  String get currentLabel => 'Current';

  @override
  String get suggested => 'Suggested';

  @override
  String get actual => 'Actual';

  @override
  String get forecast => 'Forecast';

  @override
  String get critical => 'Critical';

  @override
  String get high => 'High';

  @override
  String get low => 'Low';

  @override
  String get investigation => 'Investigation';

  @override
  String get apply => 'Apply';

  @override
  String get run => 'Run';

  @override
  String get positive => 'Positive';

  @override
  String get neutral => 'Neutral';

  @override
  String get negative => 'Negative';

  @override
  String get elastic => 'Elastic';

  @override
  String get demand => 'Demand';

  @override
  String get quality => 'Quality';

  @override
  String get luxury => 'Luxury';

  @override
  String get economic => 'Economic';

  @override
  String get ourStore => 'Our Store';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get cost => 'Cost';

  @override
  String get duration => 'Duration';

  @override
  String get quiet => 'Quiet';

  @override
  String get busy => 'Busy';

  @override
  String get outstanding => 'Outstanding';

  @override
  String get donate => 'Donate';

  @override
  String get day => 'Day';

  @override
  String get days => 'Days';

  @override
  String get projected => 'Projected';

  @override
  String get analysis => 'Analysis';

  @override
  String get review => 'Review';

  @override
  String get productCategory => 'Category';

  @override
  String get ourPrice => 'Our Price';

  @override
  String get position => 'Position';

  @override
  String get cheapest => 'Cheapest';

  @override
  String get mostExpensive => 'Most Expensive';

  @override
  String get soldOut => 'Sold Out';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get noDataFoundMessage => 'No data was found';

  @override
  String get noSearchResultsFound => 'No results found';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get noCustomers => 'No customers';

  @override
  String get addCustomersToStart => 'Add new customers to start';

  @override
  String get noOrdersYet => 'You haven\'t made any orders yet';

  @override
  String get noConnection => 'No connection';

  @override
  String get checkInternet => 'Check your internet connection';

  @override
  String get cartIsEmpty => 'Cart is empty';

  @override
  String get browseProducts => 'Browse Products';

  @override
  String noResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get paidLabel => 'Paid';

  @override
  String get remainingLabel => 'Remaining';

  @override
  String get completeLabel => 'Complete';

  @override
  String get addPayment => 'Add';

  @override
  String get payments => 'Payments';

  @override
  String get now => 'Now';

  @override
  String get ecommerce => 'Online Store';

  @override
  String get ecommerceSection => 'E-Commerce';

  @override
  String get wallet => 'Wallet';

  @override
  String get subscription => 'Subscription';

  @override
  String get complaintsReport => 'Complaints Report';

  @override
  String get mediaLibrary => 'Media Library';

  @override
  String get deviceLog => 'Device Log';

  @override
  String get shippingGateways => 'Shipping Gateways';

  @override
  String get systemSection => 'System';

  @override
  String get averageInvoice => 'Average Invoice';

  @override
  String errorPrefix(String message, Object error) {
    return 'Error: $message';
  }

  @override
  String get vipMember => 'VIP Member';

  @override
  String get activeSuppliers => 'Active Suppliers';

  @override
  String get duePayments => 'Due Payments';

  @override
  String get productCatalog => 'Product Catalog';

  @override
  String get comingSoonBrowseSuppliers =>
      'Coming Soon - Browse supplier products';

  @override
  String get comingSoonTag => 'Coming Soon';

  @override
  String get supplierNotFound => 'Supplier not found';

  @override
  String get viewAllPurchases => 'View All Purchases';

  @override
  String get completedLabel => 'Completed';

  @override
  String get pendingStatusLabel => 'Pending';

  @override
  String get registerPayment => 'Register Payment';

  @override
  String errorLoadingSuppliers(Object error) {
    return 'Error loading suppliers: $error';
  }

  @override
  String get cancelLabel => 'Cancel';

  @override
  String get addLabel => 'Add';

  @override
  String get saveLabel => 'Save';

  @override
  String purchaseInvoiceSaved(Object total) {
    return 'Purchase invoice saved - Total: $total SAR';
  }

  @override
  String errorSavingPurchase(Object error) {
    return 'Error saving purchase: $error';
  }

  @override
  String get smartReorderTitle => 'Smart Reorder';

  @override
  String get smartReorderAiTitle => 'AI Smart Reorder';

  @override
  String get budgetDescription =>
      'Set the budget and the system will distribute it based on turnover rate';

  @override
  String get enterValidBudget => 'Please enter a valid budget';

  @override
  String get confirmSendTitle => 'Confirm Send';

  @override
  String sendOrderToMsg(Object supplier) {
    return 'Send order to $supplier?';
  }

  @override
  String get orderSentSuccessMsg => 'Order sent successfully';

  @override
  String sendingOrderVia(Object method) {
    return 'Sending order via $method...';
  }

  @override
  String stockQuantity(Object qty) {
    return 'Stock: $qty';
  }

  @override
  String turnoverLabel(Object rate) {
    return 'Turnover: $rate%';
  }

  @override
  String failedCapture(Object error) {
    return 'Failed to capture image: $error';
  }

  @override
  String failedPickImage(Object error) {
    return 'Failed to pick image: $error';
  }

  @override
  String failedProcessInvoice(Object error) {
    return 'Failed to process invoice: $error';
  }

  @override
  String matchLabel(Object name) {
    return 'Match: $name';
  }

  @override
  String suggestedProduct(Object index) {
    return 'Suggested Product $index';
  }

  @override
  String get barcodeLabel => 'Barcode: 123456789';

  @override
  String get purchaseInvoiceSavedSuccess =>
      'Purchase invoice saved successfully';

  @override
  String get aiImportedInvoice => 'AI imported invoice';

  @override
  String aiInvoiceNote(Object number) {
    return 'AI Invoice: $number';
  }

  @override
  String get supplierCanCreateOrders =>
      'Can create purchase orders from this supplier';

  @override
  String get notesFieldHint => 'Any additional notes about the supplier...';

  @override
  String get deleteConfirmCancel => 'Cancel';

  @override
  String get deleteConfirmBtn => 'Delete';

  @override
  String get supplierUpdatedMsg => 'Supplier data updated';

  @override
  String errorOccurredMsg(Object error) {
    return 'Error occurred: $error';
  }

  @override
  String errorDuringDeleteMsg(Object error) {
    return 'Error during delete: $error';
  }

  @override
  String get fortyFiveDays => '45 Days';

  @override
  String get expenseCategoriesTitle => 'Expense Categories';

  @override
  String get noCategoriesFound => 'No expense categories found';

  @override
  String get monthlyBudget => 'Monthly Budget';

  @override
  String get spentAmount => 'Spent';

  @override
  String get remainingAmount => 'Remaining';

  @override
  String get overBudget => 'Over Budget';

  @override
  String expenseCount(Object count) {
    return '$count expenses';
  }

  @override
  String spentLabel(Object amount) {
    return 'Spent: $amount SAR';
  }

  @override
  String remainingLabel2(Object amount) {
    return 'Remaining: $amount SAR';
  }

  @override
  String expensesThisMonth(Object count) {
    return '$count expenses this month';
  }

  @override
  String get recentExpenses => 'Recent Expenses';

  @override
  String expenseNumber(Object id) {
    return 'Expense #$id';
  }

  @override
  String get budgetLabel => 'Budget';

  @override
  String get monthlyBudgetLabel => 'Monthly Budget';

  @override
  String get categoryNameHint => 'Example: Employee Salaries';

  @override
  String get productNameLabel => 'Product Name';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get purchasePriceLabel => 'Purchase Price';

  @override
  String get saveInvoiceBtn => 'Save Invoice';

  @override
  String get ibanLabel => 'IBAN Account Number';

  @override
  String get supplierActiveLabel => 'Supplier Active';

  @override
  String get notesLabel => 'Notes';

  @override
  String get deleteSupplierConfirm =>
      'Are you sure you want to delete this supplier? All associated data will be deleted.';

  @override
  String get supplierDeletedMsg => 'Supplier deleted';

  @override
  String get savingLabel => 'Saving...';

  @override
  String get supplierDetailTitle => 'Supplier Details';

  @override
  String get supplierNotFoundMsg => 'Supplier not found';

  @override
  String get lastPurchaseLabel => 'Last Purchase';

  @override
  String get recentPurchasesLabel => 'Recent Purchases';

  @override
  String get noPurchasesLabel => 'No purchases yet';

  @override
  String get supplierAddedMsg => 'Supplier added';

  @override
  String get openingCashLabel => 'Opening Cash';

  @override
  String get importantNotes => 'Important Notes';

  @override
  String get countCashBeforeShift =>
      'Make sure to count the cash in the drawer before opening the shift';

  @override
  String get shiftTimeAutoRecorded =>
      'Shift open time will be recorded automatically';

  @override
  String get oneShiftAtATime =>
      'Cannot open more than one shift at the same time';

  @override
  String get pleaseEnterOpeningCash =>
      'Please enter opening cash amount (greater than zero)';

  @override
  String shiftOpenedWithAmount(String amount, String currency) {
    return 'Shift opened with $amount $currency';
  }

  @override
  String get errorOpeningShift => 'Error opening shift';

  @override
  String get noOpenShift => 'No open shift';

  @override
  String get shiftInfoLabel => 'Shift Information';

  @override
  String get salesSummaryLabel => 'Sales Summary';

  @override
  String get cashRefundsLabel => 'Cash Refunds';

  @override
  String get cashDepositLabel => 'Cash Deposit';

  @override
  String get cashWithdrawalLabel => 'Cash Withdrawal';

  @override
  String get expectedInDrawer => 'Expected in Drawer';

  @override
  String get actualCashInDrawer => 'Actual Cash in Drawer';

  @override
  String get drawerMatched => 'Matched';

  @override
  String get surplusStatus => 'Surplus';

  @override
  String get deficitStatus => 'Deficit';

  @override
  String expectedAmountCurrency(String amount, String currency) {
    return 'Expected: $amount $currency';
  }

  @override
  String actualAmountCurrency(String amount, String currency) {
    return 'Actual: $amount $currency';
  }

  @override
  String get drawerMatchedMessage => 'Drawer is matched';

  @override
  String surplusAmount(String amount, String currency) {
    return 'Surplus: +$amount $currency';
  }

  @override
  String deficitAmount(String amount, String currency) {
    return 'Deficit: $amount $currency';
  }

  @override
  String get confirmCloseShift => 'Do you want to close the shift?';

  @override
  String get errorClosingShift => 'Error closing shift';

  @override
  String get shiftClosedSuccessfully => 'Shift closed successfully';

  @override
  String get shiftStatsLabel => 'Shift Statistics';

  @override
  String get shiftDurationLabel => 'Shift Duration';

  @override
  String get invoiceCountLabel => 'Invoice Count';

  @override
  String get invoiceUnit => 'invoice';

  @override
  String get cardSalesLabel => 'Card Sales';

  @override
  String get cashSalesLabel => 'Cash Sales';

  @override
  String get refundsLabel => 'Refunds';

  @override
  String get expectedInDrawerLabel => 'Expected in Drawer';

  @override
  String get actualInDrawerLabel => 'Actual in Drawer';

  @override
  String get differenceLabel => 'Difference';

  @override
  String get printingReport => 'Printing report...';

  @override
  String get sharingInProgress => 'Sharing...';

  @override
  String get openNewShift => 'Open New Shift';

  @override
  String hoursAndMinutes(int hours, int minutes) {
    return '$hours hours $minutes minutes';
  }

  @override
  String hoursOnly(int hours) {
    return '$hours hours';
  }

  @override
  String minutesOnly(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get rejectedNotApproved => 'Operation rejected - not approved';

  @override
  String errorWithDetails(String error) {
    return 'Error: $error';
  }

  @override
  String get inventoryManagement => 'Manage & track inventory';

  @override
  String get bulkEdit => 'Bulk Edit';

  @override
  String get totalProducts => 'Total Products';

  @override
  String get inventoryValue => 'Inventory Value';

  @override
  String get exportInventoryReport => 'Export Inventory Report';

  @override
  String get printOrderList => 'Print Order List';

  @override
  String get inventoryMovementLog => 'Inventory Movement Log';

  @override
  String get editSelected => 'Edit Selected';

  @override
  String get clearSelection => 'Clear Selection';

  @override
  String get noOutOfStockProducts => 'No out of stock products';

  @override
  String get allProductsAvailable => 'All products are available in stock';

  @override
  String get editStock => 'Edit Stock';

  @override
  String get newQuantity => 'New Quantity';

  @override
  String get receiveGoods => 'Receive Goods';

  @override
  String get damaged => 'Damaged';

  @override
  String get correction => 'Correction';

  @override
  String get stockUpdatedTo => 'Stock updated for';

  @override
  String get featureUnderDevelopment => 'This feature is under development...';

  @override
  String get newest => 'Newest';

  @override
  String get adjustStock => 'Adjust Stock';

  @override
  String get adjustmentHistory => 'Adjustment History';

  @override
  String get errorLoadingProducts => 'Error loading products';

  @override
  String get selectProduct => 'Select Product';

  @override
  String get subtract => 'Subtract';

  @override
  String get setQuantity => 'Set';

  @override
  String get enterQuantity => 'Enter quantity';

  @override
  String get enterValidQuantity => 'Enter valid quantity';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get enterAdditionalNotes => 'Enter any additional notes...';

  @override
  String get adjustmentSummary => 'Adjustment Summary';

  @override
  String get newStock => 'New Stock';

  @override
  String get warningNegativeStock => 'Warning: Stock will become negative!';

  @override
  String get saving => 'Saving...';

  @override
  String get storeNotSelected => 'Store not selected';

  @override
  String get noInventoryMovements => 'No inventory movements';

  @override
  String get adjustmentSavedSuccess => 'Adjustment saved successfully';

  @override
  String get errorSaving => 'Error saving';

  @override
  String get enterBarcode => 'Enter barcode';

  @override
  String get theft => 'Theft';

  @override
  String get noMatchingProducts => 'No matching products';

  @override
  String get stockTransfer => 'Stock Transfer';

  @override
  String get newTransfer => 'New Transfer';

  @override
  String get fromBranch => 'From Branch';

  @override
  String get toBranch => 'To Branch';

  @override
  String get selectSourceBranch => 'Select source branch';

  @override
  String get selectTargetBranch => 'Select target branch';

  @override
  String get selectProductsForTransfer => 'Select products for transfer';

  @override
  String get creating => 'Creating...';

  @override
  String get createTransferRequest => 'Create Transfer Request';

  @override
  String get errorLoadingTransfers => 'Error loading transfers';

  @override
  String get noPreviousTransfers => 'No previous transfers';

  @override
  String get approved => 'Approved';

  @override
  String get inTransit => 'In Transit';

  @override
  String get complete => 'Complete';

  @override
  String get completeTransfer => 'Complete Transfer';

  @override
  String get completeTransferConfirm =>
      'Do you want to complete this transfer? Quantities will be deducted from source and added to target branch.';

  @override
  String get transferCompletedSuccess => 'Transfer completed and stock updated';

  @override
  String get errorCompletingTransfer => 'Error completing transfer';

  @override
  String get transferCreatedSuccess => 'Transfer request created successfully';

  @override
  String get errorCreatingTransfer => 'Error creating transfer';

  @override
  String get stockTake => 'Stock Take';

  @override
  String get startStockTake => 'Start Stock Take';

  @override
  String get counted => 'Counted';

  @override
  String get variances => 'Variances';

  @override
  String get of_ => 'of';

  @override
  String get system => 'System';

  @override
  String get count => 'Count';

  @override
  String get finishStockTake => 'Finish Stock Take';

  @override
  String get stockTakeDescription =>
      'Count stock products and compare with system';

  @override
  String get noProductsInStock => 'No products in stock';

  @override
  String get noProductsToCount => 'No products to start counting';

  @override
  String get errorCreatingStockTake => 'Error creating stock take';

  @override
  String get saveStockTakeConfirm =>
      'Save stock take results and update inventory?';

  @override
  String get stockTakeSavedSuccess =>
      'Stock take saved and inventory updated successfully';

  @override
  String get errorCompletingStockTake => 'Error completing stock take';

  @override
  String get stockTakeHistory => 'Stock Take History';

  @override
  String get errorLoadingHistory => 'Error loading history';

  @override
  String get noStockTakeHistory => 'No previous stock take history';

  @override
  String get inProgress => 'In Progress';

  @override
  String get expiryTracking => 'Expiry Tracking';

  @override
  String get errorLoadingExpiryData => 'Error loading expiry data';

  @override
  String get withinMonth => 'Within Month';

  @override
  String get noProductsExpiringIn7Days => 'No products expiring in 7 days';

  @override
  String get noProductsExpiringInMonth => 'No products expiring in a month';

  @override
  String get noExpiredProducts => 'No expired products';

  @override
  String get batch => 'Batch';

  @override
  String expiredSinceDays(int days) {
    return 'Expired $days days ago';
  }

  @override
  String get remove => 'Remove';

  @override
  String get pressToAddExpiryTracking => 'Press + to add new expiry tracking';

  @override
  String get applyDiscountTo => 'Apply discount to';

  @override
  String get confirmRemoval => 'Confirm Removal';

  @override
  String get removeExpiryTrackingFor => 'Remove expiry tracking for';

  @override
  String get expiryTrackingRemoved => 'Expiry tracking removed';

  @override
  String get errorRemovingExpiryTracking => 'Error removing expiry tracking';

  @override
  String get addExpiryDate => 'Add Expiry Date';

  @override
  String get barcodeOrProductName => 'Barcode or product name';

  @override
  String get selectDate => 'Select date';

  @override
  String get batchNumberOptional => 'Batch number (optional)';

  @override
  String get expiryTrackingAdded => 'Expiry tracking added successfully';

  @override
  String get errorAddingExpiryTracking => 'Error adding expiry tracking';

  @override
  String get barcodeScanner2 => 'Barcode Scanner';

  @override
  String get scanning => 'Scanning...';

  @override
  String get pressToStart => 'Press to start';

  @override
  String get stop => 'Stop';

  @override
  String get startScanning => 'Start Scanning';

  @override
  String get enterBarcodeManually => 'Enter barcode manually';

  @override
  String get noScannedProducts => 'No scanned products';

  @override
  String get enterBarcodeToSearch => 'Enter barcode to search database';

  @override
  String get useManualInputToSearch =>
      'Use manual input to search for products';

  @override
  String get found => 'Found';

  @override
  String get productNotFoundForBarcode => 'Product not found';

  @override
  String get addNewProduct => 'Add New Product';

  @override
  String get willOpenAddProductScreen => 'Will open add product screen';

  @override
  String get scanHistory => 'Scan History';

  @override
  String get addedToCart => 'Added';

  @override
  String get barcodePrint => 'Barcode Print';

  @override
  String get noProductsWithBarcode => 'No products with barcode';

  @override
  String get addBarcodeFirst => 'Add barcode to products first';

  @override
  String get searchProduct => 'Search product...';

  @override
  String get totalLabels => 'Total Labels';

  @override
  String get printLabels => 'Print Labels';

  @override
  String get printList => 'Print List';

  @override
  String get selectProductsToPrint => 'Select products to print';

  @override
  String get willPrint => 'Will print';

  @override
  String get label => 'label';

  @override
  String get printing => 'Printing...';

  @override
  String get messageAddedToQueue => 'Message added to send queue';

  @override
  String get messageSendFailed => 'Failed to send message';

  @override
  String get noPhoneForCustomer => 'No phone number for customer';

  @override
  String get inputContainsDangerousContent =>
      'Input contains prohibited content';

  @override
  String whatsappGreeting(String name) {
    return 'Hello $name\nHow can we help you?';
  }

  @override
  String get segmentVip => 'VIP';

  @override
  String get segmentRegular => 'Regular';

  @override
  String get segmentAtRisk => 'At Risk';

  @override
  String get segmentLost => 'Lost';

  @override
  String get segmentNewCustomer => 'New';

  @override
  String customerCount(int count) {
    return '$count customer';
  }

  @override
  String revenueK(String amount) {
    return '${amount}K SAR';
  }

  @override
  String get tabRecommendations => 'Recommendations';

  @override
  String get tabRepurchase => 'Repurchase';

  @override
  String get tabSegments => 'Segments';

  @override
  String lastVisitLabel(String time) {
    return 'Last visit: $time';
  }

  @override
  String visitCountLabel(int count) {
    return '$count visits';
  }

  @override
  String avgSpendLabel(String amount) {
    return 'Avg: $amount SAR';
  }

  @override
  String totalSpentLabel(String amount) {
    return 'Total: ${amount}K SAR';
  }

  @override
  String get recommendedProducts => 'Recommended Products';

  @override
  String get sendWhatsAppOffer => 'Send WhatsApp Offer';

  @override
  String get totalRevenueLabel => 'Total Revenue';

  @override
  String get avgSpendStat => 'Average Spend';

  @override
  String amountSar(String amount) {
    return '$amount SAR';
  }

  @override
  String get specialOfferMissYou => 'Special offer for you! We miss your visit';

  @override
  String friendlyReminderPurchase(String product) {
    return 'Friendly reminder to purchase $product';
  }

  @override
  String get timeAgoToday => 'Today';

  @override
  String get timeAgoYesterday => 'Yesterday';

  @override
  String timeAgoDays(int days) {
    return '$days days ago';
  }

  @override
  String get riskAnalysisTab => 'Risk Analysis';

  @override
  String get preventiveActionsTab => 'Preventive Actions';

  @override
  String errorOccurredDetail(String error) {
    return 'Error occurred: $error';
  }

  @override
  String get returnRateTitle => 'Return Rate';

  @override
  String get avgLast6Months => 'Average last 6 months';

  @override
  String get amountAtRiskTitle => 'Amount at Risk';

  @override
  String get highRiskOperations => 'High Risk Operations';

  @override
  String get needsImmediateAction => 'Needs immediate action';

  @override
  String get returnTrendTitle => 'Return Trend';

  @override
  String operationsAtRiskCount(int count) {
    return 'Operations at risk ($count)';
  }

  @override
  String get riskFilterAll => 'All';

  @override
  String get riskFilterVeryHigh => 'Very High';

  @override
  String get riskFilterHigh => 'High';

  @override
  String get riskFilterMedium => 'Medium';

  @override
  String get riskFilterLow => 'Low';

  @override
  String get totalExpectedSavings => 'Total Expected Savings';

  @override
  String fromPreventiveActions(int count) {
    return 'From $count preventive actions';
  }

  @override
  String get suggestedPreventiveActions => 'Suggested Preventive Actions';

  @override
  String get applyPreventiveHint =>
      'Apply these actions to reduce returns and increase customer satisfaction';

  @override
  String actionApplied(String action) {
    return 'Applied: $action';
  }

  @override
  String actionDismissed(String action) {
    return 'Dismissed: $action';
  }

  @override
  String get veryPositiveSentiment => 'Very Positive';

  @override
  String get positiveSentiment => 'Positive';

  @override
  String get neutralSentiment => 'Neutral';

  @override
  String get negativeSentiment => 'Negative';

  @override
  String get veryNegativeSentiment => 'Very Negative';

  @override
  String get ratingsDistribution => 'Ratings Distribution';

  @override
  String get sentimentTrendTitle => 'Sentiment Trend';

  @override
  String get sentimentIndicator => 'Sentiment Indicator';

  @override
  String minutesAgoSentiment(int count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgoSentiment(int count) {
    return '$count hours ago';
  }

  @override
  String daysAgoSentiment(int count) {
    return '$count days ago';
  }

  @override
  String get totalProductsTitle => 'Total Products';

  @override
  String get categoryATitle => 'Category A';

  @override
  String get mostImportant => 'Most Important';

  @override
  String get withinDays => 'Within 7 days';

  @override
  String get needReorder => 'Need Reorder';

  @override
  String estimatedLossSar(String amount) {
    return '$amount SAR estimated loss';
  }

  @override
  String get tabAbcAnalysis => 'ABC Analysis';

  @override
  String get tabWastePrediction => 'Waste Prediction';

  @override
  String get tabReorder => 'Reorder';

  @override
  String get filterAllLabel => 'All';

  @override
  String get categoryALabel => 'Category A';

  @override
  String get categoryBLabel => 'Category B';

  @override
  String get categoryCLabel => 'Category C';

  @override
  String orderUnitsSnack(int qty, String name) {
    return 'Order $qty units of $name';
  }

  @override
  String get urgencyCritical => 'Critical';

  @override
  String get urgencyHigh => 'High';

  @override
  String get urgencyMedium => 'Medium';

  @override
  String get urgencyLow => 'Low';

  @override
  String get currentStockLabel => 'Current Stock';

  @override
  String get reorderPointLabel => 'Reorder Point';

  @override
  String get suggestedQtyLabel => 'Suggested Qty';

  @override
  String get daysOfStockLabel => 'Days of Stock';

  @override
  String estimatedCostLabel(String amount) {
    return 'Estimated cost: $amount SAR';
  }

  @override
  String purchaseOrderCreatedFor(String name) {
    return 'Purchase order created: $name';
  }

  @override
  String orderUnitsButton(int qty) {
    return 'Order $qty units';
  }

  @override
  String get actionDiscount => 'Discount';

  @override
  String get actionTransfer => 'Transfer';

  @override
  String get actionDonate => 'Donate';

  @override
  String actionOnProduct(String name) {
    return 'Action on: $name';
  }

  @override
  String get totalSuggestionsLabel => 'Total Suggestions';

  @override
  String get canIncreaseLabel => 'Can Increase';

  @override
  String get shouldDecreaseLabel => 'Should Decrease';

  @override
  String get expectedMonthlyImpact => 'Expected Monthly Impact';

  @override
  String get noSuggestionsInFilter => 'No suggestions in this filter';

  @override
  String get selectProductForDetails => 'Select a product to view details';

  @override
  String get selectProductHint =>
      'Click on a product from the list to view impact calculator and demand elasticity';

  @override
  String priceApplied(String price, String product) {
    return 'Price $price SAR applied to $product';
  }

  @override
  String errorOccurredShort(String error) {
    return 'Error: $error';
  }

  @override
  String get readyTemplates => 'Ready Templates';

  @override
  String get hideTemplates => 'Hide Templates';

  @override
  String get showTemplates => 'Show Templates';

  @override
  String get askAboutStore => 'Ask any question about your store';

  @override
  String get writeQuestionHint =>
      'Write your question and we will generate the appropriate report automatically';

  @override
  String get quickActionTodaySales => 'How much sales today?';

  @override
  String get quickActionTop10 => 'Top 10 products';

  @override
  String get quickActionMonthlyCompare => 'Monthly comparison';

  @override
  String get analyzingData => 'Analyzing data and generating report...';

  @override
  String get profileScreenTitle => 'Profile';

  @override
  String get unknownUserName => 'Unknown';

  @override
  String get defaultEmployeeRole => 'Employee';

  @override
  String get transactionUnit => 'transaction';

  @override
  String get dayUnit => 'day';

  @override
  String get emailFieldLabel => 'Email';

  @override
  String get phoneFieldLabel => 'Phone';

  @override
  String get branchFieldLabel => 'Branch';

  @override
  String get mainBranchName => 'Main Branch';

  @override
  String get employeeNumberLabel => 'Employee Number';

  @override
  String get changePasswordLabel => 'Change Password';

  @override
  String get activityLogLabel => 'Activity Log';

  @override
  String get logoutDialogTitle => 'Logout';

  @override
  String get logoutDialogBody => 'Do you want to logout from the system?';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get exitButton => 'Exit';

  @override
  String get editProfileSnack => 'Edit Profile';

  @override
  String get changePasswordSnack => 'Change Password';

  @override
  String get roleAdmin => 'System Admin';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleCashier => 'Cashier';

  @override
  String get roleEmployee => 'Employee';

  @override
  String get onboardingTitle1 => 'Fast Point of Sale';

  @override
  String get onboardingDesc1 =>
      'Complete sales quickly and easily with a simple and comfortable interface';

  @override
  String get onboardingTitle2 => 'Work Offline';

  @override
  String get onboardingDesc2 =>
      'Keep working even without connection, and sync will happen automatically';

  @override
  String get onboardingTitle3 => 'Inventory Management';

  @override
  String get onboardingDesc3 =>
      'Track your inventory accurately with shortage and expiry alerts';

  @override
  String get onboardingTitle4 => 'Smart Reports';

  @override
  String get onboardingDesc4 =>
      'Get detailed reports and analytics for your store performance';

  @override
  String get startNow => 'Start Now';

  @override
  String get favorites => 'Favorites';

  @override
  String get editMode => 'Edit';

  @override
  String get doneMode => 'Done';

  @override
  String get errorLoadingFavorites => 'Error loading favorites';

  @override
  String get noFavoriteProducts => 'No favorite products';

  @override
  String get addFavoritesFromProducts =>
      'Add products to favorites from the products screen';

  @override
  String get tapProductToAddToCart => 'Tap a product to add it to cart';

  @override
  String addedProductToCart(String name) {
    return '$name added to cart';
  }

  @override
  String get addToCartAction => 'Add to cart';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String removedProductFromFavorites(String name) {
    return '$name removed from favorites';
  }

  @override
  String get paymentMethodTitle => 'Payment Method';

  @override
  String get backEsc => 'Back (Esc)';

  @override
  String get completePayment => 'Complete Payment';

  @override
  String get enterToConfirm => 'Enter to confirm';

  @override
  String get cashOnlyOffline => 'Cash only in offline mode';

  @override
  String get cardsDisabledInSettings => 'Cards disabled in settings';

  @override
  String get creditPayment => 'Credit';

  @override
  String get unavailableOffline => 'Unavailable offline';

  @override
  String get disabledInSettings => 'Disabled in settings';

  @override
  String get amountReceived => 'Amount Received';

  @override
  String get quickAmounts => 'Quick Amounts';

  @override
  String get requiredAmount => 'Required Amount';

  @override
  String get changeLabel => 'Change:';

  @override
  String get insufficientAmount => 'Insufficient amount';

  @override
  String get rrnLabel => 'Reference Number (RRN)';

  @override
  String get enterRrnFromDevice => 'Enter transaction number from device';

  @override
  String get cardPaymentInstructions =>
      'Ask the customer to pay via card terminal, then enter the transaction number (RRN) from the receipt';

  @override
  String get creditSale => 'Credit Sale';

  @override
  String get creditSaleWarning =>
      'This amount will be recorded as a debt for the customer. Make sure to select the customer before completing the transaction.';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get taxLabel => 'Tax (15%)';

  @override
  String discountLabel(String value) {
    return 'Discount: $value%';
  }

  @override
  String get payCash => 'Pay Cash';

  @override
  String get payCard => 'Pay by Card';

  @override
  String get payCreditSale => 'Credit Sale';

  @override
  String get confirmPayment => 'Confirm Payment';

  @override
  String get processingPayment => 'Processing payment...';

  @override
  String get pleaseWait => 'Please wait';

  @override
  String get paymentSuccessful => 'Payment successful!';

  @override
  String get printingReceipt => 'Printing receipt...';

  @override
  String get whatsappReceipt => 'WhatsApp receipt';

  @override
  String get storeOrUserNotSet => 'Store or user not set';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get receiptTitle => 'Receipt';

  @override
  String get invoiceNotSpecified => 'Invoice number not specified';

  @override
  String get pendingSync => 'Pending sync';

  @override
  String get notSynced => 'Not synced';

  @override
  String receiptNumberLabel(String number) {
    return 'No: $number';
  }

  @override
  String get itemColumnHeader => 'Item';

  @override
  String totalAmount(String amount) {
    return 'Total: $amount SAR';
  }

  @override
  String get paymentMethodField => 'Payment Method';

  @override
  String get zatcaQrCode => 'ZATCA Tax QR Code';

  @override
  String get whatsappSentLabel => 'Sent ✓';

  @override
  String get whatsappLabel => 'WhatsApp';

  @override
  String get whatsappReceiptSent => 'Receipt sent via WhatsApp ✓';

  @override
  String whatsappSendFailed(String error) {
    return 'Send failed: $error';
  }

  @override
  String get cannotPrintNoInvoice =>
      'Cannot print - invoice number not available';

  @override
  String get invoiceAddedToPrintQueue => 'Invoice added to print queue';

  @override
  String get mixedMethod => 'Mixed';

  @override
  String get creditMethod => 'Credit';

  @override
  String get walletMethod => 'Wallet';

  @override
  String get bankTransferMethod => 'Bank Transfer';

  @override
  String get scanBarcodeHint => 'Scan barcode or enter it (F1)';

  @override
  String get openCamera => 'Open camera';

  @override
  String get searchProductHint => 'Search product (F2)';

  @override
  String get hideCart => 'Hide cart';

  @override
  String get showCart => 'Show cart';

  @override
  String get cartTitle => 'Cart';

  @override
  String get clearAction => 'Clear';

  @override
  String get allCategories => 'All';

  @override
  String get otherCategory => 'Other';

  @override
  String get storeNotSet => 'Store not set';

  @override
  String get retryAction => 'Retry';

  @override
  String get vatTax15 => 'VAT (15%)';

  @override
  String get totalGrand => 'Total';

  @override
  String get holdOrder => 'Hold';

  @override
  String get payActionLabel => 'Pay';

  @override
  String get f12QuickPay => 'F12 for quick pay';

  @override
  String productNotFoundBarcode(String barcode) {
    return 'Product not found for barcode: $barcode';
  }

  @override
  String get clearCartTitle => 'Clear Cart';

  @override
  String get clearCartMessage =>
      'Do you want to remove all products from the cart?';

  @override
  String get orderOnHold => 'Order on hold';

  @override
  String get deleteItem => 'Delete';

  @override
  String itemsCountPrice(int count, String price) {
    return '$count items - $price SAR';
  }

  @override
  String get taxReportTitle => 'Tax Report';

  @override
  String get exportReportAction => 'Export Report';

  @override
  String get printReportAction => 'Print Report';

  @override
  String get quarterly => 'Quarterly';

  @override
  String get netTaxDue => 'Net Tax Due';

  @override
  String get salesTaxCollected => 'Sales Tax';

  @override
  String get salesTaxSubtitle => 'Collected';

  @override
  String get purchasesTaxPaid => 'Purchases Tax';

  @override
  String get purchasesTaxSubtitle => 'Paid';

  @override
  String get taxByPaymentMethod => 'Tax by Payment Method';

  @override
  String invoiceCount(int count) {
    return '$count invoices';
  }

  @override
  String get taxDetailsTitle => 'Tax Details';

  @override
  String get taxableSales => 'Taxable Sales';

  @override
  String get salesTax15 => 'Sales Tax (15%)';

  @override
  String get taxablePurchases => 'Taxable Purchases';

  @override
  String get purchasesTax15 => 'Purchases Tax (15%)';

  @override
  String get netTax => 'Net Tax';

  @override
  String get zatcaReminder => 'ZATCA Reminder';

  @override
  String get zatcaDeadline => 'Filing deadline: end of next month';

  @override
  String get historyAction => 'History';

  @override
  String get sendToAuthority => 'Send to Authority';

  @override
  String get cashPaymentMethod => 'Cash';

  @override
  String get cardPaymentMethod => 'Card';

  @override
  String get mixedPaymentMethod => 'Mixed';

  @override
  String get creditPaymentMethod => 'Credit';

  @override
  String get vatReportTitle => 'VAT Report';

  @override
  String get selectPeriod => 'Select period';

  @override
  String get salesVat => 'Sales VAT';

  @override
  String get totalSalesIncVat => 'Total Sales (incl. VAT)';

  @override
  String get vatCollected => 'VAT Collected';

  @override
  String get purchasesVat => 'Purchases VAT';

  @override
  String get totalPurchasesIncVat => 'Total Purchases (incl. VAT)';

  @override
  String get vatPaid => 'VAT Paid';

  @override
  String get netVatDue => 'Net VAT Due';

  @override
  String get dueToAuthority => 'Due to authority';

  @override
  String get dueFromAuthority => 'Due from authority';

  @override
  String get exportingPdfReport => 'Exporting report...';

  @override
  String get debtsReportTitle => 'Debts Report';

  @override
  String get sortByLastPayment => 'By last payment';

  @override
  String get customersCount => 'Customers';

  @override
  String get noOutstandingDebts => 'No outstanding debts';

  @override
  String lastUpdate(String date) {
    return 'Last update: $date';
  }

  @override
  String get paymentAmountField => 'Payment Amount';

  @override
  String get recordAction => 'Record';

  @override
  String get paymentRecordedMsg => 'Payment recorded';

  @override
  String showDetails(String name) {
    return 'View details: $name';
  }

  @override
  String get debtsReportPdf => 'Debts Report';

  @override
  String dateFieldLabel(String date) {
    return 'Date: $date';
  }

  @override
  String get debtsDetails => 'Debt Details:';

  @override
  String get customerCol => 'Customer';

  @override
  String get phoneCol => 'Phone';

  @override
  String get refundReceiptTitle => 'Refund Receipt';

  @override
  String get noRefundId => 'No refund ID';

  @override
  String get refundNotFound => 'Refund data not found';

  @override
  String get refundSuccessful => 'Refund successful';

  @override
  String refundNumberLabel(String number) {
    return 'Refund No: $number';
  }

  @override
  String get refundReceipt => 'Refund Receipt';

  @override
  String get originalInvoiceNumber => 'Original Invoice Number';

  @override
  String get refundDate => 'Refund Date';

  @override
  String get refundMethodField => 'Refund Method';

  @override
  String get returnedProducts => 'Returned Products';

  @override
  String get totalRefund => 'Total Refund';

  @override
  String get reasonLabel => 'Reason';

  @override
  String get homeAction => 'Home';

  @override
  String printError(String error) {
    return 'Print error: $error';
  }

  @override
  String get damagedProduct => 'Damaged product';

  @override
  String get wrongOrder => 'Wrong order';

  @override
  String get customerChangedMind => 'Customer changed mind';

  @override
  String get expiredProduct => 'Expired';

  @override
  String get unsatisfactoryQuality => 'Unsatisfactory quality';

  @override
  String get cashRefundMethod => 'Cash';

  @override
  String get cardRefundMethod => 'Card';

  @override
  String get walletRefundMethod => 'Wallet';

  @override
  String get refundReasonTitle => 'Refund Reason';

  @override
  String get noRefundData =>
      'No refund data. Please go back and select products.';

  @override
  String invoiceFieldLabel(String receiptNo) {
    return 'Invoice: $receiptNo';
  }

  @override
  String productsCountAmount(int count, String amount) {
    return '$count products - $amount SAR';
  }

  @override
  String get selectRefundReason => 'Select refund reason';

  @override
  String get additionalNotesOptional => 'Additional notes (optional)';

  @override
  String get addNotesHint => 'Add any additional notes...';

  @override
  String get processingAction => 'Processing...';

  @override
  String get nextSupervisorApproval => 'Next - Supervisor Approval';

  @override
  String refundCreationError(String error) {
    return 'Error creating refund: $error';
  }

  @override
  String get refundRequestTitle => 'Refund Request';

  @override
  String get invoiceNumberHint => 'Invoice number';

  @override
  String get searchAction => 'Search';

  @override
  String get selectProductsForRefund => 'Select products to return';

  @override
  String get selectAll => 'Select all';

  @override
  String quantityTimesPrice(int qty, String price) {
    return 'Qty: $qty × $price SAR';
  }

  @override
  String productsSelected(int count) {
    return '$count products selected';
  }

  @override
  String refundAmountValue(String amount) {
    return 'Amount: $amount SAR';
  }

  @override
  String get nextAction => 'Next';

  @override
  String get enterInvoiceToSearch => 'Enter invoice number to search';

  @override
  String get invoiceNotFoundMsg => 'Invoice not found';

  @override
  String get shippingGatewaysTitle => 'Shipping Gateways';

  @override
  String get availableShippingGateways => 'Available Shipping Gateways';

  @override
  String get activateShippingGateways =>
      'Activate and configure shipping gateways for order delivery';

  @override
  String get aramexName => 'Aramex';

  @override
  String get aramexDesc => 'Global shipping company with multiple services';

  @override
  String get smsaDesc => 'Fast domestic shipping';

  @override
  String get fastloName => 'Fastlo';

  @override
  String get fastloDesc => 'Same day fast delivery';

  @override
  String get dhlDesc => 'Fast and reliable international shipping';

  @override
  String get jtDesc => 'Economy shipping';

  @override
  String get customDeliveryName => 'Custom Delivery';

  @override
  String get customDeliveryDesc => 'Manage delivery with your own drivers';

  @override
  String get settingsAction => 'Settings';

  @override
  String get hourlyView => 'Hourly';

  @override
  String get dailyView => 'Daily';

  @override
  String get peakHourLabel => 'Peak Hour';

  @override
  String transactionsWithCount(int count) {
    return '$count transactions';
  }

  @override
  String get peakDayLabel => 'Peak Day';

  @override
  String get avgPerHour => 'Avg/Hour';

  @override
  String get transactionWord => 'transactions';

  @override
  String get transactionsByHour => 'Transactions by Hour';

  @override
  String get transactionsByDay => 'Transactions by Day';

  @override
  String get activityHeatmap => 'Activity Heatmap';

  @override
  String get lowLabel => 'Low';

  @override
  String get highLabel => 'High';

  @override
  String get analysisRecommendations => 'Recommendations Based on Analysis';

  @override
  String get staffRecommendation => 'Staff';

  @override
  String get staffRecommendationDesc =>
      'Increase cashiers during 12:00-13:00 and 17:00-19:00 (peak sales)';

  @override
  String get offersRecommendation => 'Offers';

  @override
  String get offersRecommendationDesc =>
      'Offer special deals during 14:00-16:00 to boost sales in quiet period';

  @override
  String get inventoryRecommendation => 'Inventory';

  @override
  String get inventoryRecommendationDesc =>
      'Prepare inventory before Thursday and Friday (highest sales days)';

  @override
  String get shiftsRecommendation => 'Shifts';

  @override
  String get shiftsRecommendationDesc =>
      'Distribute shifts: morning 8-15, evening 15-22 with overlap at peak';

  @override
  String get topProductsTab => 'Top Products';

  @override
  String get byCategoryTab => 'By Category';

  @override
  String get performanceAnalysisTab => 'Performance Analysis';

  @override
  String get noSalesDataForPeriod => 'No sales data for the selected period';

  @override
  String get categoryFilter => 'Category';

  @override
  String get allCategoriesFilter => 'All Categories';

  @override
  String get sortByField => 'Sort by';

  @override
  String get revenueSort => 'Revenue';

  @override
  String get unitsSort => 'Units';

  @override
  String get profitSort => 'Profit';

  @override
  String get revenueLabel => 'Revenue';

  @override
  String get unitsLabel => 'Units';

  @override
  String get profitLabel => 'Profit';

  @override
  String get stockLabel => 'Stock';

  @override
  String get revenueByCategoryTitle => 'Revenue Distribution by Category';

  @override
  String get noRevenueForPeriod => 'No revenue for this period';

  @override
  String get unclassified => 'Unclassified';

  @override
  String get productUnit => 'product';

  @override
  String get unitsSoldUnit => 'units';

  @override
  String get totalRevenueKpi => 'Total Revenue';

  @override
  String get unitsSoldKpi => 'Units Sold';

  @override
  String get totalProfitKpi => 'Total Profit';

  @override
  String get profitMarginKpi => 'Profit Margin';

  @override
  String get performanceOverview => 'Performance Overview';

  @override
  String get trendingUpProducts => 'Trending Up';

  @override
  String get stableProducts => 'Stable';

  @override
  String get trendingDownProducts => 'Trending Down';

  @override
  String noSalesProducts(int count) {
    return 'No sales products ($count)';
  }

  @override
  String inStockCount(int count) {
    return '$count in stock';
  }

  @override
  String get slowMovingLabel => 'Slow';

  @override
  String needsReorder(int count) {
    return 'Needs reorder ($count)';
  }

  @override
  String soldUnitsStock(int sold, int stock) {
    return 'Sold: $sold units | Stock: $stock';
  }

  @override
  String get reorderLabel => 'Reorder';

  @override
  String get totalComplaintsLabel => 'Total Complaints';

  @override
  String get openComplaints => 'Open';

  @override
  String get closedComplaints => 'Closed';

  @override
  String get avgResolutionTime => 'Avg Resolution Time';

  @override
  String daysUnit(String count) {
    return '$count days';
  }

  @override
  String get fromDate => 'From date';

  @override
  String get toDate => 'To date';

  @override
  String get statusFilter => 'Status';

  @override
  String get departmentFilter => 'Department';

  @override
  String get paymentDepartment => 'Payment';

  @override
  String get technicalDepartment => 'Technical';

  @override
  String get otherDepartment => 'Other';

  @override
  String get noComplaintsRecorded => 'No complaints recorded yet';

  @override
  String get overviewTab => 'Overview';

  @override
  String get topCustomersTab => 'Top Customers';

  @override
  String get growthAnalysisTab => 'Growth Analysis';

  @override
  String get loyaltyTab => 'Loyalty';

  @override
  String get totalCustomersLabel => 'Total Customers';

  @override
  String get activeCustomersLabel => 'Active Customers';

  @override
  String get avgOrderValueLabel => 'Avg Order Value';

  @override
  String get tierDistribution => 'Customer Distribution by Tier';

  @override
  String get activitySummary => 'Activity Summary';

  @override
  String get totalRevenueFromCustomers =>
      'Total revenue from registered customers';

  @override
  String get avgOrderPerCustomer => 'Average order value per customer';

  @override
  String get activeCustomersLast30 => 'Active customers (last 30 days)';

  @override
  String get newCustomersLast30 => 'New customers (last 30 days)';

  @override
  String topCustomersTitle(int count) {
    return 'Top $count Customers';
  }

  @override
  String get bySpending => 'By Spending';

  @override
  String get byOrders => 'By Orders';

  @override
  String get byPoints => 'By Points';

  @override
  String ordersCount(int count) {
    return '$count orders';
  }

  @override
  String get avgOrderStat => 'Avg Order';

  @override
  String get loyaltyPointsStat => 'Loyalty Points';

  @override
  String get lastOrderStat => 'Last Order';

  @override
  String get newCustomerGrowth => 'New Customer Growth';

  @override
  String get customerRetentionRate => 'Customer Retention Rate';

  @override
  String get monthlyPeriod => 'Monthly';

  @override
  String get totalCustomersPeriod => 'Total Customers';

  @override
  String get activePeriod => 'Active';

  @override
  String get activeCustomersInfo =>
      'Active customers: purchased within the last 30 days';

  @override
  String get cohortAnalysis => 'Cohort Analysis';

  @override
  String get cohortDescription => 'Return rate after first purchase';

  @override
  String get cohortGroup => 'Group';

  @override
  String get month1 => 'Month 1';

  @override
  String get month2 => 'Month 2';

  @override
  String get month3 => 'Month 3';

  @override
  String get loyaltyProgramStats => 'Loyalty Program Stats';

  @override
  String get totalPointsGranted => 'Total Points Granted';

  @override
  String get remainingPoints => 'Remaining Points';

  @override
  String get pointsValue => 'Points Value';

  @override
  String get pointsByTier => 'Points by Tier';

  @override
  String get pointsUnit => 'points';

  @override
  String get redemptionPatterns => 'Redemption Patterns';

  @override
  String get purchaseDiscount => 'Purchase Discount';

  @override
  String get freeProducts => 'Free Products';

  @override
  String get couponsLabel => 'Coupons';

  @override
  String get diamondTier => 'Diamond';

  @override
  String get goldTier => 'Gold';

  @override
  String get silverTier => 'Silver';

  @override
  String get bronzeTier => 'Bronze';

  @override
  String get todayDate => 'Today';

  @override
  String get yesterdayDate => 'Yesterday';

  @override
  String daysCountLabel(int count) {
    return '$count days';
  }

  @override
  String ofTotalLabel(String active, String total) {
    return '$active of $total';
  }

  @override
  String get exportingReportMsg => 'Exporting report...';

  @override
  String get januaryMonth => 'January';

  @override
  String get februaryMonth => 'February';

  @override
  String get marchMonth => 'March';

  @override
  String get aprilMonth => 'April';

  @override
  String get mayMonth => 'May';

  @override
  String get juneMonth => 'June';

  @override
  String errorLabel(String error) {
    return 'Error: $error';
  }

  @override
  String get saturdayDay => 'Saturday';

  @override
  String get sundayDay => 'Sunday';

  @override
  String get mondayDay => 'Monday';

  @override
  String get tuesdayDay => 'Tuesday';

  @override
  String get wednesdayDay => 'Wednesday';

  @override
  String get thursdayDay => 'Thursday';

  @override
  String get fridayDay => 'Friday';

  @override
  String get satShort => 'Sat';

  @override
  String get sunShort => 'Sun';

  @override
  String get monShort => 'Mon';

  @override
  String get tueShort => 'Tue';

  @override
  String get wedShort => 'Wed';

  @override
  String get thuShort => 'Thu';

  @override
  String get friShort => 'Fri';

  @override
  String get errorLoadingVatReport => 'Error loading VAT report';

  @override
  String get errorLoadingComplaints => 'Error loading complaints';

  @override
  String get errorLoadingCustomerReport => 'Error loading customer report';

  @override
  String get reprintReceipt => 'Reprint Receipt';

  @override
  String get searchByInvoiceOrCustomer => 'Search by invoice or customer...';

  @override
  String get selectInvoiceToPrint => 'Select an invoice to reprint';

  @override
  String get receiptPreview => 'Receipt Preview';

  @override
  String get receiptPrinted => 'Receipt printed successfully';

  @override
  String get refunded => 'Refunded';

  @override
  String get cashMovement => 'Cash Movement';

  @override
  String get movementType => 'Movement Type';

  @override
  String get reasonHint => 'Enter reason...';

  @override
  String get bankDeposit => 'Bank Deposit';

  @override
  String get bankWithdrawal => 'Bank Withdrawal';

  @override
  String get changeForDrawer => 'Change for Drawer';

  @override
  String get confirmDeposit => 'Confirm Deposit';

  @override
  String get confirmWithdrawal => 'Confirm Withdrawal';

  @override
  String get dailySummary => 'Daily Summary';

  @override
  String get netRevenue => 'Net Revenue';

  @override
  String get afterRefunds => 'After Refunds';

  @override
  String get shiftsCount => 'Shifts Count';

  @override
  String get todayShifts => 'Today\'s Shifts';

  @override
  String get ongoing => 'Ongoing';

  @override
  String get confirmOrder => 'Confirm Order';

  @override
  String get orderNow => 'Order Now';

  @override
  String get orderCart => 'Order Cart';

  @override
  String get orderReceived => 'Your order has been received!';

  @override
  String get orderBeingPrepared =>
      'Your order will be prepared as soon as possible';

  @override
  String get redirectingToHome => 'Redirecting to home page automatically...';

  @override
  String get kioskOrderNote => 'Kiosk order';

  @override
  String pricePerUnit(String price) {
    return '$price SAR/unit';
  }

  @override
  String get selectFromMenu => 'Select from menu';

  @override
  String orderCartWithCount(int count) {
    return 'Order Cart ($count items)';
  }

  @override
  String amountWithSar(String amount) {
    return '$amount SAR';
  }

  @override
  String qtyTimesPrice(int qty, String price) {
    return '$qty x $price SAR';
  }

  @override
  String get applyCoupon => 'Apply Coupon';

  @override
  String get enterCouponCode => 'Enter coupon code';

  @override
  String get invalidCoupon => 'Invalid or not found coupon';

  @override
  String get couponExpired => 'Coupon has expired';

  @override
  String minimumPurchaseRequired(String amount) {
    return 'Minimum purchase $amount SAR';
  }

  @override
  String couponDiscountApplied(String amount) {
    return 'Discount of $amount SAR applied';
  }

  @override
  String get couponInvalid => 'Invalid coupon';

  @override
  String get customerAddFailed => 'Failed to add customer';

  @override
  String get quantityColon => 'Quantity:';

  @override
  String get riyal => 'SAR';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get banknotes => 'Banknotes';

  @override
  String get coins => 'Coins';

  @override
  String get totalAmountLabel => 'Total Amount';

  @override
  String denominationRiyal(String amount) {
    return '$amount SAR';
  }

  @override
  String denominationHalala(String amount) {
    return '$amount Halala';
  }

  @override
  String get countCurrency => 'Count Currency';

  @override
  String confirmAmountSar(String amount) {
    return 'Confirm: $amount SAR';
  }

  @override
  String amountRiyal(String amount) {
    return '$amount SAR';
  }

  @override
  String get itemDeletedMsg => 'Item deleted';

  @override
  String get pressBackAgainToExit => 'Press again to exit';

  @override
  String get deleteHeldInvoiceConfirm => 'Delete this held invoice?';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get addCustomer => 'Add Customer';

  @override
  String get noInvoices => 'No invoices';

  @override
  String get noReports => 'No reports';

  @override
  String get noOffers => 'No offers';

  @override
  String get emptyStateStartAddProducts => 'Start adding your products now';

  @override
  String get emptyStateStartAddCustomers => 'Start adding your customers now';

  @override
  String get emptyStateAddProductsToCart =>
      'Add products to cart to start selling';

  @override
  String get emptyStateInvoicesAppearAfterSale =>
      'Invoices will appear here after completing sales';

  @override
  String get emptyStateNewOrdersAppearHere => 'New orders will appear here';

  @override
  String get emptyStateNewNotificationsAppearHere =>
      'New notifications will appear here';

  @override
  String get emptyStateCheckYourConnection => 'Check your internet connection';

  @override
  String get emptyStateReportsAppearAfterSale =>
      'Reports will appear after completing sales';

  @override
  String get emptyStateNoNeedToRestock => 'No products need restocking';

  @override
  String get emptyStateAllCustomersPaid => 'All customers have paid';

  @override
  String get emptyStateReturnsAppearHere => 'Returns will appear here';

  @override
  String get emptyStateAddOffersToAttract =>
      'Add offers to attract more customers';

  @override
  String get errorNoInternetConnection => 'No internet connection';

  @override
  String get errorCheckConnectionAndRetry =>
      'Check your internet connection and try again';

  @override
  String get errorServerError => 'Server error';

  @override
  String get errorServerConnectionFailed =>
      'An error occurred while connecting to the server';

  @override
  String get errorUnexpectedError => 'An unexpected error occurred';

  @override
  String get customerGroups => 'Customer Groups';

  @override
  String get allCustomersGroup => 'All Customers';

  @override
  String get vipCustomersGroup => 'VIP Customers';

  @override
  String get regularCustomersGroup => 'Regular Customers';

  @override
  String get newCustomersGroup => 'New Customers';

  @override
  String get newCustomers30Days => 'New Customers (30 days)';

  @override
  String get customersWithDebt => 'Customers with Debts';

  @override
  String get haveDebts => 'Have Debts';

  @override
  String get inactive90Days => 'Inactive (90+ days)';

  @override
  String customerCountLabel(int count) {
    return '$count customer';
  }

  @override
  String get selectGroupToViewCustomers => 'Select a group to view customers';

  @override
  String get noCustomersInGroup => 'No customers in this group';

  @override
  String get debtWord => 'Debt';

  @override
  String get employeeProfile => 'Employee Profile';

  @override
  String get employeeNotFound => 'Employee not found';

  @override
  String get profileTab => 'Profile';

  @override
  String get salesTab => 'Sales';

  @override
  String get shiftsTab => 'Shifts';

  @override
  String get permissionsTab2 => 'Permissions';

  @override
  String get mobilePhone => 'Mobile';

  @override
  String get joinDate => 'Join Date';

  @override
  String get lastLogin => 'Last Login';

  @override
  String get neverLoggedIn => 'Never logged in';

  @override
  String get accountActive => 'Account Active';

  @override
  String get canLogin => 'Can log in';

  @override
  String get blockedFromLogin => 'Blocked from login';

  @override
  String get employeeFallback => 'Employee';

  @override
  String get weekLabel => 'Week';

  @override
  String get monthLabel => 'Month';

  @override
  String get loadSalesData => 'Load Sales Data';

  @override
  String get invoiceCountLabel2 => 'Invoice Count';

  @override
  String get hourlySalesDistribution => 'Hourly Sales Distribution';

  @override
  String shiftOpenTime(String time) {
    return 'Open: $time';
  }

  @override
  String shiftCloseTime(String time) {
    return 'Close: $time';
  }

  @override
  String hoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get shiftOpenStatus => 'Open';

  @override
  String invoiceCountWithNum(int count) {
    return '$count invoice';
  }

  @override
  String get permissionsSaved => 'Permissions saved';

  @override
  String get jobRole => 'Job Role';

  @override
  String get manageProducts => 'Manage Products';

  @override
  String get viewReports => 'View Reports';

  @override
  String get refundOperations => 'Refund Operations';

  @override
  String get manageCustomersPermission => 'Manage Customers';

  @override
  String get manageOffers => 'Manage Offers';

  @override
  String get savePermissions => 'Save Permissions';

  @override
  String get deactivateAccount => 'Deactivate Account';

  @override
  String get activateAccount => 'Activate Account';

  @override
  String confirmDeactivateAccount(String name) {
    return 'Do you want to deactivate $name\'s account?';
  }

  @override
  String confirmActivateAccount(String name) {
    return 'Do you want to activate $name\'s account?';
  }

  @override
  String get deactivate => 'Deactivate';

  @override
  String get activate => 'Activate';

  @override
  String get accountActivated => 'Account activated';

  @override
  String get accountDeactivated => 'Account deactivated';

  @override
  String get employeeAttendance => 'Employee Attendance';

  @override
  String get presentLabel => 'Present';

  @override
  String get absentLabel => 'Absent';

  @override
  String get attendanceCount => 'Attendance';

  @override
  String get absencesCount => 'Absences';

  @override
  String get lateCount => 'Late';

  @override
  String get totalEmployees => 'Total Employees';

  @override
  String noAttendanceRecordsForDay(int day, int month) {
    return 'No attendance records for $day/$month';
  }

  @override
  String get workingNow => 'Working Now';

  @override
  String get loyaltyTierCustomizeHint =>
      'You can customize loyalty program tiers and define points and benefits for each tier.';

  @override
  String memberCount(int count) {
    return '$count member';
  }

  @override
  String get pointsRequired => 'Points Required';

  @override
  String get discountPercentage => 'Discount Percentage';

  @override
  String get pointsMultiplier => 'Points Multiplier';

  @override
  String get addTier => 'Add Tier';

  @override
  String get addNewTier => 'Add New Tier';

  @override
  String get nameArabic => 'Name (Arabic)';

  @override
  String get nameEnglish => 'Name (English)';

  @override
  String get minPoints => 'Minimum Points';

  @override
  String get maxPointsHint => 'Maximum (leave empty = unlimited)';

  @override
  String multiplierLabel(String value) {
    return 'Points Multiplier: ${value}x';
  }

  @override
  String tierBenefits(String tier) {
    return 'Benefits of $tier tier';
  }

  @override
  String discountOnPurchases(String value) {
    return '• $value% discount on purchases';
  }

  @override
  String pointsPerPurchase(String value) {
    return '• ${value}x points on every purchase';
  }

  @override
  String get whatsappManagement => 'WhatsApp Management';

  @override
  String get messageQueue => 'Message Queue';

  @override
  String get templates => 'Templates';

  @override
  String get sentStatus => 'Sent';

  @override
  String get failedStatus => 'Failed';

  @override
  String get noMessages => 'No messages';

  @override
  String get retrySend => 'Retry Send';

  @override
  String get requeuedMessage => 'Message re-queued for sending';

  @override
  String templateCount(int count) {
    return '$count template';
  }

  @override
  String get newTemplate => 'New Template';

  @override
  String get editTemplate => 'Edit Template';

  @override
  String get templateName => 'Template Name';

  @override
  String get messageText => 'Message Text';

  @override
  String templateVariablesHint(
      Object customer_name, Object store_name, Object total) {
    return 'Use $store_name $customer_name $total as variables';
  }

  @override
  String get apiSettings => 'API Settings';

  @override
  String get apiKey => 'API Key';

  @override
  String get testingConnection => 'Testing connection...';

  @override
  String get sendSettings => 'Send Settings';

  @override
  String get autoSend => 'Auto Send';

  @override
  String get autoSendDescription =>
      'Automatically send messages after each transaction';

  @override
  String get dailyMessageLimit => 'Daily Message Limit';

  @override
  String messagesPerDay(int count) {
    return '$count messages/day';
  }

  @override
  String get salesInvoiceTemplate => 'Sales Invoice';

  @override
  String get debtReminderTemplate => 'Debt Reminder';

  @override
  String get newCustomerWelcomeTemplate => 'New Customer Welcome';

  @override
  String get supplierReturns => 'Purchase Returns';

  @override
  String get addItemForReturn => 'Add Item for Return';

  @override
  String get itemName => 'Item Name';

  @override
  String get unitPrice => 'Unit Price';

  @override
  String get sarSuffix => 'SAR';

  @override
  String get pleaseAddItems => 'Please add items for return';

  @override
  String get creditNoteWillBeRecorded =>
      'A credit note will be recorded and inventory adjusted.';

  @override
  String get issueCreditNote => 'Issue Credit Note';

  @override
  String returnRecordedSuccess(String amount) {
    return 'Return recorded successfully - Credit note: $amount SAR';
  }

  @override
  String get selectSupplier => 'Select Supplier';

  @override
  String get damagedDefective => 'Damaged / Defective';

  @override
  String get wrongItem => 'Wrong Item';

  @override
  String get overstockExcess => 'Overstock';

  @override
  String get addItem => 'Add Item';

  @override
  String get noItemsAddedYet => 'No items added yet';

  @override
  String get notes => 'Notes';

  @override
  String get additionalNotesHint => 'Any additional notes...';

  @override
  String get totalReturn => 'Total Return';

  @override
  String issueCreditNoteWithAmount(String amount) {
    return 'Issue Credit Note ($amount SAR)';
  }

  @override
  String get deliveryZones => 'Delivery Zones';

  @override
  String get addDeliveryZone => 'Add Zone';

  @override
  String get editDeliveryZone => 'Edit Delivery Zone';

  @override
  String get addDeliveryZoneTitle => 'Add Delivery Zone';

  @override
  String get zoneName => 'Zone Name';

  @override
  String get fromKm => 'From (km)';

  @override
  String get toKm => 'To (km)';

  @override
  String get kmUnit => 'km';

  @override
  String get deliveryFee => 'Delivery Fee';

  @override
  String get minOrderAmount => 'Minimum Order';

  @override
  String get estimatedDeliveryTime => 'Estimated Delivery Time';

  @override
  String get minuteUnit => 'min';

  @override
  String get zoneUpdated => 'Zone updated';

  @override
  String get zoneAdded => 'Zone added';

  @override
  String get deleteZone => 'Delete Zone';

  @override
  String get deleteZoneConfirm => 'Do you want to delete this zone?';

  @override
  String get activeZones => 'Active Zones';

  @override
  String get lowestFee => 'Lowest Fee';

  @override
  String get highestFee => 'Highest Fee';

  @override
  String get noDeliveryZones => 'No delivery zones';

  @override
  String get addDeliveryZonesDescription =>
      'Add delivery zones to define delivery prices and ranges';

  @override
  String get deliveryTime => 'Delivery Time';

  @override
  String get minuteAbbr => 'm';

  @override
  String get giftCards => 'Gift Cards';

  @override
  String get redeemCard => 'Redeem Card';

  @override
  String get issueGiftCard => 'Issue Gift Card';

  @override
  String get cardValue => 'Card Value (SAR)';

  @override
  String giftCardIssued(String amount) {
    return 'Gift card issued worth $amount SAR';
  }

  @override
  String get issueCard => 'Issue Card';

  @override
  String get redeemGiftCard => 'Redeem Gift Card';

  @override
  String get cardCode => 'Card Code';

  @override
  String get noCardWithCode => 'No card found with this code';

  @override
  String get cardBalanceZero => 'Card balance is zero';

  @override
  String cardBalance(String amount) {
    return 'Card balance: $amount SAR';
  }

  @override
  String get verify => 'Verify';

  @override
  String get cardsTab => 'Cards';

  @override
  String get statisticsTab => 'Statistics';

  @override
  String get searchByCode => 'Search by code...';

  @override
  String get activeFilter => 'Active';

  @override
  String get usedFilter => 'Used';

  @override
  String get expiredFilter => 'Expired';

  @override
  String get noGiftCards => 'No gift cards';

  @override
  String get issueGiftCardsDescription => 'Issue gift cards for your customers';

  @override
  String get totalActiveBalance => 'Total Active Balance';

  @override
  String get totalIssuedValue => 'Total Issued Value';

  @override
  String get activeCards => 'Active Cards';

  @override
  String get usedCards => 'Used Cards';

  @override
  String get giftCardStatusActive => 'Active';

  @override
  String get giftCardStatusPartiallyUsed => 'Partially Used';

  @override
  String get giftCardStatusFullyUsed => 'Fully Used';

  @override
  String get giftCardStatusExpired => 'Expired';

  @override
  String balanceDisplay(String balance, String total) {
    return 'Balance: $balance/$total SAR';
  }

  @override
  String expiresOn(String date) {
    return 'Expires: $date';
  }

  @override
  String get onlineOrders => 'Online Orders';

  @override
  String get statusNew => 'New';

  @override
  String get statusPreparing => 'Preparing';

  @override
  String get statusReady => 'Ready';

  @override
  String get statusShipped => 'Shipped';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusReadyForPickup => 'Ready for Pickup';

  @override
  String get nextStatusAcceptOrder => 'Accept Order';

  @override
  String get nextStatusReady => 'Ready';

  @override
  String get nextStatusShipped => 'Shipped';

  @override
  String get nextStatusDelivered => 'Delivered';

  @override
  String timeAgoMinutes(int minutes) {
    return '$minutes min ago';
  }

  @override
  String timeAgoHours(int hours) {
    return '$hours hr ago';
  }

  @override
  String get damagedAndLostGoods => 'Damaged & Lost Goods';

  @override
  String get damagedDefectiveShort => 'Damaged';

  @override
  String get expiredShort => 'Expired';

  @override
  String get theftLoss => 'Theft / Loss';

  @override
  String get wasteBreakage => 'Waste / Breakage';

  @override
  String get unknownProduct => 'Unknown product';

  @override
  String get recordDamagedGoods => 'Record Damaged Goods';

  @override
  String get costPerUnit => 'Cost/Unit';

  @override
  String get lossType => 'Loss Type';

  @override
  String get damagedGoodsRecorded => 'Damaged goods recorded successfully';

  @override
  String get periodLabel => 'Period';

  @override
  String get totalLosses => 'Total Losses';

  @override
  String get noDamagedGoods => 'No damaged goods';

  @override
  String get noDamagedGoodsInPeriod => 'No damaged goods in this period';

  @override
  String get recordDamagedGoodsFab => 'Record Damaged Goods';

  @override
  String quantityWithValue(String qty) {
    return 'Qty: $qty';
  }

  @override
  String get purchaseDetails => 'Purchase Details';

  @override
  String get purchaseNotFound => 'Purchase order not found';

  @override
  String get backToList => 'Back to List';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusSent => 'Sent';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusReceived => 'Received';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get supplierInfoLabel => 'Supplier';

  @override
  String get dateLabel => 'Date';

  @override
  String get orderTimeline => 'Order Timeline';

  @override
  String get actionsLabel => 'Actions';

  @override
  String get sendToDistributor => 'Send to Distributor';

  @override
  String get awaitingDistributorResponse => 'Awaiting distributor response';

  @override
  String get goodsReceived => 'Goods received';

  @override
  String get orderItems => 'Order Items';

  @override
  String itemCountLabel(int count) {
    return '$count item';
  }

  @override
  String get productColumn => 'Product';

  @override
  String get quantityColumn => 'Quantity';

  @override
  String get receivedColumn => 'Received';

  @override
  String get unitPriceColumn => 'Unit Price';

  @override
  String get totalColumn => 'Total';

  @override
  String quantityInfo(int qty, int received, String price) {
    return 'Qty: $qty  |  Received: $received  |  $price SAR';
  }

  @override
  String get receivingGoods => 'Receiving Goods';

  @override
  String get unsavedChanges => 'Unsaved Changes';

  @override
  String get leaveWithoutSaving =>
      'Do you want to leave without saving changes?';

  @override
  String get leave => 'Leave';

  @override
  String receivingGoodsTitle(String number) {
    return 'Receiving Goods - $number';
  }

  @override
  String get orderData => 'Order Data';

  @override
  String get receivedItems => 'Received Items';

  @override
  String orderedQty(int qty) {
    return 'Ordered: $qty';
  }

  @override
  String get receivedQtyLabel => 'Received';

  @override
  String get receivingInfo => 'Receiving Info';

  @override
  String get receiverName => 'Receiver Name *';

  @override
  String get receivingNotes => 'Receiving Notes';

  @override
  String get confirmingReceipt => 'Confirming...';

  @override
  String get confirmReceipt => 'Confirm Receipt';

  @override
  String get purchaseOrders => 'Purchase Orders';

  @override
  String get statusApprovedShort => 'Approved';

  @override
  String get orderNumberColumn => 'Order Number';

  @override
  String get statusColumn => 'Status';

  @override
  String get noPurchaseOrders => 'No purchase orders';

  @override
  String get createPurchaseToStart =>
      'Create a new purchase order to get started';

  @override
  String get errorLoadingData => 'An error occurred while loading data';

  @override
  String get sendToDistributorTitle => 'Send Order to Distributor';

  @override
  String get orderInfo => 'Order Information';

  @override
  String get currentSupplier => 'Current Supplier';

  @override
  String get itemsSummary => 'Items Summary';

  @override
  String get distributorSupplier => 'Distributor / Supplier';

  @override
  String get additionalMessage => 'Additional Message';

  @override
  String get addNotesForDistributor =>
      'Add notes or a message for the distributor...';

  @override
  String get sending => 'Sending...';

  @override
  String get pleaseSelectDistributor => 'Please select the distributor';

  @override
  String errorSendingOrder(String message) {
    return 'Error sending order: $message';
  }

  @override
  String get employeeCommissions => 'Employee Commissions';

  @override
  String get totalDueCommissions => 'Total Due Commissions';

  @override
  String forEmployees(int count) {
    return 'For $count employee';
  }

  @override
  String get noCommissions => 'No commissions';

  @override
  String get noSalesInPeriod => 'No sales in this period';

  @override
  String invoicesSales(int count, String amount) {
    return '$count invoice - Sales: $amount SAR';
  }

  @override
  String get commissionLabel => 'Commission';

  @override
  String targetLabel(String amount) {
    return 'Target: $amount SAR';
  }

  @override
  String achievedPercent(String percent) {
    return '$percent% achieved';
  }

  @override
  String commissionRate(String percent) {
    return 'Commission rate: $percent%';
  }

  @override
  String get priceLists => 'Price Lists';

  @override
  String get retailPrice => 'Retail Price';

  @override
  String get retailPriceDesc => 'Standard price for individual customers';

  @override
  String get wholesalePrice => 'Wholesale Price';

  @override
  String get wholesalePriceDesc => 'Discounted prices for bulk quantities';

  @override
  String get vipPrice => 'VIP Price';

  @override
  String get vipPriceDesc => 'Special prices for VIP customers';

  @override
  String get costPriceList => 'Cost Price';

  @override
  String get costPriceDesc => 'For internal use only';

  @override
  String editPrice(String name) {
    return 'Edit Price - $name';
  }

  @override
  String basePriceLabel(String price) {
    return 'Base price: $price SAR';
  }

  @override
  String costPriceLabel(String price) {
    return 'Cost price: $price SAR';
  }

  @override
  String newPriceLabel(String listName) {
    return 'New Price ($listName)';
  }

  @override
  String priceUpdated(String name, String price) {
    return 'Price of \"$name\" updated to $price SAR';
  }

  @override
  String productCount(int count) {
    return '$count product';
  }

  @override
  String baseLabel(String price) {
    return 'Base: $price SAR';
  }

  @override
  String get errorLoadingHeldInvoices => 'Error loading held invoices';

  @override
  String get saleSaveFailed => 'Sale save failed';

  @override
  String errorSavingSaleMessage(String error) {
    return 'An error occurred while saving the sale. Cart was not cleared.\n\n$error';
  }

  @override
  String get ok => 'OK';

  @override
  String get invoiceNote => 'Invoice Note';

  @override
  String get addNoteHint => 'Add a note...';

  @override
  String get clearNote => 'Clear';

  @override
  String get quickNoteDelivery => 'Delivery';

  @override
  String get quickNoteGiftWrap => 'Gift wrapping';

  @override
  String get quickNoteFragile => 'Fragile';

  @override
  String get quickNoteUrgent => 'Urgent';

  @override
  String get quickNoteReservation => 'Reservation';

  @override
  String get enterPhoneNumber => 'Enter phone number';

  @override
  String whatsappSendError(String error) {
    return 'Could not send WhatsApp: $error';
  }

  @override
  String get sendReceiptViaWhatsapp => 'Send receipt via WhatsApp';

  @override
  String get invoiceNumberTitle => 'Invoice Number';

  @override
  String get amountPaidTitle => 'Amount Paid';

  @override
  String get sentLabel => 'Sent';

  @override
  String get newSaleButton => 'New Sale';

  @override
  String get enterValidAmountError => 'Enter a valid amount';

  @override
  String get amountExceedsMaxError => 'Amount must not exceed 999,999.99';

  @override
  String get amountExceedsRemainingError => 'Amount exceeds remaining';

  @override
  String get amountBetweenZeroAndMax =>
      'Amount must be between 0 and 999,999.99';

  @override
  String get amountLessThanTotal => 'Amount received is less than total';

  @override
  String get selectCustomerFirstError => 'Select a customer first';

  @override
  String get debtLimitExceededError => 'Customer debt limit exceeded';

  @override
  String get completePaymentFirstError => 'Complete payment first';

  @override
  String get completePaymentLabel => 'Complete Payment';

  @override
  String get receivedAmountLabel => 'Amount Received';

  @override
  String get sarPrefix => 'SAR ';

  @override
  String get selectCustomerLabel => 'Select Customer';

  @override
  String get currentBalanceTitle => 'Current Balance';

  @override
  String get creditLimitTitle => 'Credit Limit';

  @override
  String get creditLimitAmount => '500.00 SAR';

  @override
  String get debtLimitExceededWarning => 'Debt limit exceeded!';

  @override
  String get selectCustomerFirstButton => 'Select customer first';

  @override
  String get splitPaymentTitle => 'Split Payment';

  @override
  String splitPaymentDone(int count) {
    return 'Split Payment done ($count methods)';
  }

  @override
  String get splitPaymentLabel => 'Split Payment';

  @override
  String get addPaymentEntry => 'Add Payment';

  @override
  String get confirmSplitPayment => 'Confirm Payment';

  @override
  String get completePaymentToConfirm => 'Complete payment first';

  @override
  String get enterValidAmountSplit => 'Enter a valid amount';

  @override
  String get amountExceedsSplit => 'Amount exceeds remaining';

  @override
  String get bestSellingPress19 => 'Best Selling (Press 1-9)';

  @override
  String get quickSearchHintFull => 'Quick search (name / code / barcode)...';

  @override
  String noResultsForQuery(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String addQtyToCart(int qty) {
    return 'Add $qty to cart';
  }

  @override
  String availableStock(String qty) {
    return 'Available: $qty';
  }

  @override
  String priceSar(String price) {
    return '$price SAR';
  }

  @override
  String loyaltyPointsDiscountLabel(int points) {
    return 'Loyalty points discount ($points points)';
  }

  @override
  String pointsRedemptionInvoice(String id) {
    return 'Points redemption - Invoice $id';
  }

  @override
  String pointsEarnedInvoice(String id) {
    return 'Points earned - Invoice $id';
  }

  @override
  String availableLoyaltyPoints(String points, String amount) {
    return 'Available loyalty points: $points points (equals $amount SAR)';
  }

  @override
  String get useLoyaltyPoints => 'Use Loyalty Points';

  @override
  String pointsCountHint(String max) {
    return 'Number of points (max $max)';
  }

  @override
  String get pointsUnitLabel => 'points';

  @override
  String discountAmountSar(String amount) {
    return 'Discount: $amount SAR';
  }

  @override
  String get allPointsLabel => 'All Points';

  @override
  String pointsCountLabel(String count) {
    return '$count points';
  }

  @override
  String newOrderNotification(String id) {
    return 'New order #$id';
  }

  @override
  String get onlineOrdersTooltip => 'Online Orders';

  @override
  String productCountItems(int count) {
    return '$count product';
  }

  @override
  String get acceptAndPrint => 'Accept & Print';

  @override
  String get deliverToDriver => 'Deliver to Driver';

  @override
  String get onTheWayStatus => 'On the way';

  @override
  String driverNameLabel(String name) {
    return 'Driver: $name';
  }

  @override
  String get deliveredStatus => 'Delivered';

  @override
  String agoMinutes(int count) {
    return '$count minutes ago';
  }

  @override
  String agoHours(int count) {
    return '$count hours ago';
  }

  @override
  String moreProductsLabel(int count) {
    return '+ $count more products';
  }

  @override
  String get onlineOrdersTitle => 'Online Orders';

  @override
  String pendingOrdersCount(int count) {
    return '$count orders pending acceptance';
  }

  @override
  String get inPreparationTab => 'In Preparation';

  @override
  String get inDeliveryTab => 'In Delivery';

  @override
  String get noOrdersMessage => 'No orders';

  @override
  String get newOrdersAppearHere => 'New orders will appear here';

  @override
  String get rejectOrderTitle => 'Reject Order';

  @override
  String get rejectOrderConfirm =>
      'Are you sure you want to reject this order?';

  @override
  String get rejectedBySeller => 'Rejected by seller';

  @override
  String printingOrderMessage(String id) {
    return 'Printing order $id...';
  }

  @override
  String get selectDriverTitle => 'Select Driver';

  @override
  String orderDeliveredToDriver(String name) {
    return 'Order delivered to driver $name';
  }

  @override
  String get walkInCustomerLabel => 'Walk-in Customer';

  @override
  String get continueWithoutCustomer => 'Continue without selecting a customer';

  @override
  String get addNewCustomerButton => 'Add New Customer';

  @override
  String loyaltyPointsCountLabel(String count) {
    return '$count points';
  }

  @override
  String customerBalanceAmount(String amount) {
    return '$amount SAR';
  }

  @override
  String get noResultsFoundTitle => 'No results found';

  @override
  String get tryAnotherSearch => 'Try searching with another keyword';

  @override
  String get selectCustomerTitle => 'Select Customer';

  @override
  String get searchByNameOrPhoneHint => 'Search by name or phone number...';

  @override
  String quickSaleHold(String time) {
    return 'Quick sale $time';
  }

  @override
  String get holdInvoiceTitle => 'Hold Invoice';

  @override
  String get holdInvoiceNameLabel => 'Held invoice name';

  @override
  String get holdAction => 'Hold';

  @override
  String heldMessage(String name) {
    return 'Held: $name';
  }

  @override
  String holdError(String error) {
    return 'Hold error: $error';
  }

  @override
  String get storeLabel => 'Store';

  @override
  String get featureNotAvailableNow => 'This feature is not available yet';

  @override
  String get cancelInvoiceError =>
      'An error occurred while canceling the invoice';

  @override
  String get invoiceLoadError => 'An error occurred while loading the invoice';

  @override
  String get syncConflicts => 'Sync conflicts';

  @override
  String itemsNeedReview(int count) {
    return '$count items need review';
  }

  @override
  String get needsAttention => 'Needs attention';

  @override
  String get seriousProblems => 'Serious problems';

  @override
  String syncPartialSuccess(int success, int failed) {
    return 'Synced $success items, $failed failed';
  }

  @override
  String syncErrorMessage(String error) {
    return 'Sync error: $error';
  }

  @override
  String get networkError => 'Server connection error';

  @override
  String get dataLoadFailed => 'Failed to load data';

  @override
  String get unexpectedError => 'An unexpected error occurred';

  @override
  String get cashierPerformance => 'Cashier Performance';

  @override
  String get resetStatsAction => 'Reset';

  @override
  String get statsReset => 'Statistics have been reset';

  @override
  String get averageSaleTime => 'Average sale time';

  @override
  String get operationsPerHour => 'Operations/hour';

  @override
  String get errorRateLabel => 'Error rate';

  @override
  String get completedOperations => 'Completed operations';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String operationsPendingSync(int count) {
    return '$count operations pending sync';
  }

  @override
  String get connectionRestored => 'Connection restored';

  @override
  String get connectedLabel => 'Connected';

  @override
  String get disconnectedLabel => 'Disconnected';

  @override
  String offlineWithPending(int count) {
    return 'Offline - $count operations pending';
  }

  @override
  String syncingWithCount(int count) {
    return 'Syncing... ($count operations)';
  }

  @override
  String syncErrorWithCount(int count) {
    return 'Sync error - $count operations pending';
  }

  @override
  String pendingSyncWithCount(int count) {
    return '$count operations pending sync';
  }

  @override
  String get connectedAllSynced => 'Connected - all data synced';

  @override
  String get dataSavedLocally =>
      'Data saved locally and will sync when connected';

  @override
  String get uploadingData => 'Uploading data to server...';

  @override
  String get errorWillRetry => 'An error occurred, will retry automatically';

  @override
  String get syncSoon => 'Will sync in seconds';

  @override
  String get allDataSynced => 'All data is up to date and synced';

  @override
  String get cashierMode => 'Cashier mode';

  @override
  String get collapseMenu => 'Collapse menu';

  @override
  String get expandMenu => 'Expand menu';

  @override
  String get screenLoadError => 'An error occurred while loading the screen';

  @override
  String get screenLoadTimeout => 'Screen loading timed out';

  @override
  String get timeoutCheckConnection =>
      'Timed out. Check your internet connection.';

  @override
  String get retryLaterMessage => 'Please try again later.';

  @override
  String get howWasOperation => 'How was this operation?';

  @override
  String get fastLabel => 'Fast';

  @override
  String get whatToImprove => 'What can be improved?';

  @override
  String get helpUsImprove => 'Your help improves the app';

  @override
  String get writeNoteOptional => 'Write your note (optional)...';

  @override
  String get thanksFeedback => 'Thanks for your feedback!';

  @override
  String get thanksWillImprove => 'Thanks! We will work on improving';

  @override
  String get noRatingsYet => 'No ratings yet';

  @override
  String get customerRatings => 'Customer ratings';

  @override
  String get fastOperations => 'Fast operations';

  @override
  String get averageRating => 'Average rating';

  @override
  String get totalRatings => 'Total ratings';

  @override
  String undoCompleted(String description) {
    return 'Undone: $description';
  }

  @override
  String get payables => 'Payables';

  @override
  String get notAvailableLabel => 'Not available';

  @override
  String get browseSupplierCatalogNotAvailable =>
      'Browse supplier catalog - not available yet';

  @override
  String get selectedSuffix => ', selected';

  @override
  String get disabledSuffix => ', disabled';

  @override
  String get doubleTapToToggle => 'Double tap to toggle';

  @override
  String get loadingPleaseWait => 'Loading...';

  @override
  String get posSystemLabel => 'POS System';

  @override
  String get pageNotFoundTitle => 'Error';

  @override
  String pageNotFoundMessage(String path) {
    return 'Page not found: $path';
  }

  @override
  String get noShipmentsToReceive => 'No shipments to receive';

  @override
  String get approvedOrdersAppearHere =>
      'Approved orders ready for receiving will appear here';

  @override
  String get unspecifiedSupplier => 'Unspecified supplier';

  @override
  String get viewItems => 'View Items';

  @override
  String get receivingInProgress => 'Receiving...';

  @override
  String get confirmReceivingBtn => 'Confirm Receiving';

  @override
  String orderItemsTitle(String number) {
    return 'Order Items $number';
  }

  @override
  String get noOrderItems => 'No items';

  @override
  String get confirmReceiveGoodsTitle => 'Confirm Receiving Goods';

  @override
  String confirmReceiveGoodsBody(String number) {
    return 'Are you sure you want to receive order $number?\nInventory will be updated automatically.';
  }

  @override
  String orderReceivedSuccess(String number) {
    return 'Order $number received successfully';
  }

  @override
  String get quickPurchaseRequest => 'Quick Purchase Request';

  @override
  String get searchAndAddProducts =>
      'Search for products and add them to the request';

  @override
  String get requestedProducts => 'Requested Products';

  @override
  String get productCountSummary => 'Product Count';

  @override
  String get totalQuantitySummary => 'Total Quantity';

  @override
  String get addNotesForManager => 'Add notes for manager (optional)...';

  @override
  String get sendRequestBtn => 'Send Request';

  @override
  String get validQuantityRequired =>
      'Please enter a valid quantity for all products';

  @override
  String get requestSentToManager => 'Request sent to manager';

  @override
  String get connectionSuccessMsg => 'Connected successfully';

  @override
  String connectionFailedMsgErr(String error) {
    return 'Connection failed: $error';
  }

  @override
  String get deviceSavedMsg => 'Device saved';

  @override
  String saveErrorMsg(String error) {
    return 'Error saving settings: $error';
  }

  @override
  String get addPaymentDeviceTitle => 'Add Payment Device';

  @override
  String get setupNewDeviceSubtitle => 'Set up a new device';

  @override
  String get quickAccessKeysSubtitle => 'Quick access keys';

  @override
  String devicesAddedCount(int count) {
    return '$count devices added';
  }

  @override
  String get managePreferencesSubtitle => 'Manage preferences';

  @override
  String get storeNameAddressLogo => 'Name, address and logo';

  @override
  String get receiptHeaderFooterLogo => 'Receipt header, footer and logo';

  @override
  String get posPaymentNavSubtitle => 'POS, payment and navigation';

  @override
  String get usersAndPermissions => 'Users & Permissions';

  @override
  String get rolesAndAccess => 'Roles and access';

  @override
  String get backupAutoRestore => 'Automatic backup and restore';

  @override
  String get privacyAndDataRights => 'Privacy and data rights';

  @override
  String get arabicEnglish => 'Arabic/English';

  @override
  String get darkLightMode => 'Dark/Light mode';

  @override
  String get clearCacheTitle => 'Clear Cache';

  @override
  String get clearCacheSubtitle => 'Fix loading and data issues';

  @override
  String get clearCacheDialogBody =>
      'All temporary data will be cleared and reloaded from the server.\n\nYou will be logged out and the app will restart.\n\nDo you want to continue?';

  @override
  String get clearAndRestart => 'Clear & Restart';

  @override
  String get clearingCacheProgress => 'Clearing cache...';

  @override
  String get printerInitFailed => 'Failed to initialize print service';

  @override
  String get noPrintersFound => 'No printers found';

  @override
  String searchErrorMsg(String error) {
    return 'Search error: $error';
  }

  @override
  String connectedToPrinterName(String name) {
    return 'Connected to $name';
  }

  @override
  String connectionFailedToPrinter(String name) {
    return 'Connection failed to $name';
  }

  @override
  String get enterPrinterIpAddress => 'Enter the printer IP address';

  @override
  String get printerNotConnectedMsg => 'Printer not connected';

  @override
  String get testPageSentSuccess => 'Test page sent successfully';

  @override
  String testFailedMsg(String error) {
    return 'Test failed: $error';
  }

  @override
  String errorMsgGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get cashDrawerOpened => 'Cash drawer opened';

  @override
  String cashDrawerFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get disconnectedMsg => 'Disconnected';

  @override
  String connectedPrinterStatus(String name) {
    return 'Connected: $name';
  }

  @override
  String get notConnectedStatus => 'Not connected';

  @override
  String get connectedToPrinterMsg => 'Connected to printer';

  @override
  String get noPrinterConnectedMsg => 'No printer connected';

  @override
  String get openDrawerBtn => 'Open Drawer';

  @override
  String get disconnectBtn => 'Disconnect';

  @override
  String get connectPrinterTitle => 'Connect Printer';

  @override
  String get connectionTypeLabel => 'Connection Type';

  @override
  String get bluetoothLabel => 'Bluetooth';

  @override
  String get networkLabel => 'Network';

  @override
  String get printerIpAddressLabel => 'Printer IP Address';

  @override
  String get connectBtn => 'Connect';

  @override
  String get searchingPrintersLabel => 'Searching...';

  @override
  String get searchPrintersBtn => 'Search for printers';

  @override
  String discoveredPrintersTitle(int count) {
    return 'Discovered Printers ($count)';
  }

  @override
  String get connectedBadge => 'Connected';

  @override
  String get printSettingsTitle => 'Print Settings';

  @override
  String get autoPrintTitle => 'Auto Print';

  @override
  String get autoPrintSubtitle => 'Automatically print receipt after each sale';

  @override
  String get paperSizeSubtitle => 'Thermal printer paper width';

  @override
  String get customizeReceiptSubtitle => 'Customize receipt';

  @override
  String get viewStoreDetailsSubtitle => 'View store details';

  @override
  String get usersAndPermissionsTitle => 'Users & Permissions';

  @override
  String usersCountLabel(int count) {
    return '$count user';
  }

  @override
  String get noPrinterSetup => 'No printer set up';

  @override
  String get printerNotConnectedErr => 'Printer not connected';

  @override
  String get transactionRecordedSuccess => 'Transaction recorded successfully';

  @override
  String productSearchFailed(String error) {
    return 'Product search failed: $error';
  }

  @override
  String customerSearchFailed(String error) {
    return 'Customer search failed: $error';
  }

  @override
  String get inventoryUpdatedMsg => 'Inventory updated';

  @override
  String get scanOrEnterBarcode => 'Scan or enter barcode';

  @override
  String get priceUpdatedMsg => 'Price updated';

  @override
  String get exchangeSuccessMsg => 'Exchange completed successfully';

  @override
  String get refundProcessedSuccess => 'Refund processed successfully';

  @override
  String get backupCompletedTitle => 'Backup Completed';

  @override
  String backupCompletedBody(int rows, String size) {
    return 'Backup completed - $rows rows, $size MB';
  }

  @override
  String backupFailedMsg(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get copyBackupInstructions =>
      'Copy backup data to clipboard to save or share it.';

  @override
  String get closeBtn => 'Close';

  @override
  String get backupCopiedToClipboard => 'Backup copied to clipboard';

  @override
  String get copyToClipboardBtn => 'Copy to Clipboard';

  @override
  String get countDenominationsBtn => 'Count by denominations';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'Privacy and data rights';

  @override
  String get privacyIntroTitle => 'Introduction';

  @override
  String get privacyIntroBody =>
      'At Alhai, we are committed to protecting your privacy and personal data. This policy explains how we collect, use, and protect your data when using the Point of Sale application.';

  @override
  String get privacyLastUpdated => 'Last updated: March 2026';

  @override
  String get privacyDataCollectedTitle => 'Data We Collect';

  @override
  String get privacyStoreData =>
      'Store data: store name, address, tax number, logo.';

  @override
  String get privacyProductData =>
      'Product data: product names, prices, barcodes, stock.';

  @override
  String get privacySalesData =>
      'Sales data: invoices, payment methods, amounts, date and time.';

  @override
  String get privacyCustomerData =>
      'Customer data: name, phone number, email (optional), purchase history.';

  @override
  String get privacyEmployeeData =>
      'Employee data: username, role, shift history.';

  @override
  String get privacyDeviceData =>
      'Device data: device type, operating system (for technical support only).';

  @override
  String get privacyHowWeUseTitle => 'How We Use Your Data';

  @override
  String get privacyUsePOS =>
      'Operating the POS system and processing sales and payments.';

  @override
  String get privacyUseReports =>
      'Creating reports and statistics to help you manage your store.';

  @override
  String get privacyUseAccounts =>
      'Managing customer accounts, debts, and loyalty.';

  @override
  String get privacyUseInventory => 'Managing inventory and tracking products.';

  @override
  String get privacyUseBackup => 'Backup and data restoration.';

  @override
  String get privacyUsePerformance =>
      'Improving app performance and fixing bugs.';

  @override
  String get privacyNoSellData =>
      'We do not sell your data to third parties. We do not use your data for advertising purposes.';

  @override
  String get privacyProtectionTitle => 'How We Protect Your Data';

  @override
  String get privacyLocalStorage =>
      'Local storage: All sales and customer data is stored locally on your device.';

  @override
  String get privacyEncryption =>
      'Encryption: Sensitive data is encrypted using modern encryption technologies.';

  @override
  String get privacyBackupProtection =>
      'Backup: You can create encrypted backups of your data.';

  @override
  String get privacyAuthentication =>
      'Authentication: Access is protected by password and user permissions.';

  @override
  String get privacyOffline =>
      'Offline operation: The app works 100% offline; your data is not sent to external servers.';

  @override
  String get privacyRightsTitle => 'Your Rights';

  @override
  String get privacyRightAccess => 'Right of Access';

  @override
  String get privacyRightAccessDesc =>
      'You have the right to view all your data stored in the app at any time.';

  @override
  String get privacyRightCorrection => 'Right of Correction';

  @override
  String get privacyRightCorrectionDesc =>
      'You have the right to modify or correct any inaccurate data.';

  @override
  String get privacyRightDeletion => 'Right of Deletion';

  @override
  String get privacyRightDeletionDesc =>
      'You have the right to request deletion of your personal data. You can delete customer data from the customer management screen.';

  @override
  String get privacyRightExport => 'Right of Export';

  @override
  String get privacyRightExportDesc =>
      'You have the right to export a copy of your data in JSON format.';

  @override
  String get privacyRightWithdrawal => 'Right of Withdrawal';

  @override
  String get privacyRightWithdrawalDesc =>
      'You have the right to withdraw any previous consent to process your data.';

  @override
  String get privacyDataDeletionTitle => 'Data Deletion';

  @override
  String get privacyDataDeletionIntro =>
      'You can delete customer data through the app settings. When deleting customer data:';

  @override
  String get privacyDataDeletionPersonal =>
      'Personal information (name, phone, email) is permanently deleted.';

  @override
  String get privacyDataDeletionAnonymize =>
      'Customer identity in previous sales records is anonymized (shown as \"Deleted Customer\").';

  @override
  String get privacyDataDeletionAccounts =>
      'Associated debt accounts and addresses are deleted.';

  @override
  String get privacyDataDeletionWarning =>
      'Note: Data deletion cannot be undone after execution.';

  @override
  String get privacyContactTitle => 'Contact Us';

  @override
  String get privacyContactIntro =>
      'If you have any questions about the privacy policy or wish to exercise your rights, you can contact us via:';

  @override
  String get privacyContactEmail => 'Email: privacy@alhai.app';

  @override
  String get privacyContactSupport => 'In-app technical support';

  @override
  String get onboardingPrivacyPolicy => 'Privacy Policy | Privacy Policy';

  @override
  String get cashierDefaultName => 'Cashier';

  @override
  String get defaultAddress => 'Riyadh - Kingdom of Saudi Arabia';

  @override
  String get loadMoreBtn => 'Load More';

  @override
  String get countCurrencyBtn => 'Count Currency';

  @override
  String get searchLogsHint => 'Search logs...';

  @override
  String get noSearchResultsForQuery => 'No results for search';

  @override
  String get noLogsToDisplay => 'No logs to display';

  @override
  String get auditActionLogin => 'Login';

  @override
  String get auditActionLogout => 'Logout';

  @override
  String get auditActionSale => 'Sale';

  @override
  String get auditActionCancelSale => 'Cancel Sale';

  @override
  String get auditActionRefund => 'Refund';

  @override
  String get auditActionAddProduct => 'Add Product';

  @override
  String get auditActionEditProduct => 'Edit Product';

  @override
  String get auditActionDeleteProduct => 'Delete Product';

  @override
  String get auditActionPriceChange => 'Price Change';

  @override
  String get auditActionStockAdjust => 'Stock Adjust';

  @override
  String get auditActionStockReceive => 'Stock Receive';

  @override
  String get auditActionOpenShift => 'Open Shift';

  @override
  String get auditActionCloseShift => 'Close Shift';

  @override
  String get auditActionSettingsChange => 'Settings Change';

  @override
  String get auditActionCashDrawer => 'Cash Drawer';

  @override
  String get permCategoryPosLabel => 'Point of Sale';

  @override
  String get permCategoryProductsLabel => 'Products';

  @override
  String get permCategoryInventoryLabel => 'Inventory';

  @override
  String get permCategoryCustomersLabel => 'Customers';

  @override
  String get permCategorySalesLabel => 'Sales';

  @override
  String get permCategoryReportsLabel => 'Reports';

  @override
  String get permCategorySettingsLabel => 'Settings';

  @override
  String get permCategoryStaffLabel => 'Staff';

  @override
  String get permPosAccess => 'POS Access';

  @override
  String get permPosAccessDesc => 'Access the point of sale screen';

  @override
  String get permPosHold => 'Hold Invoices';

  @override
  String get permPosHoldDesc => 'Hold invoices and complete later';

  @override
  String get permPosSplitPayment => 'Split Payment';

  @override
  String get permPosSplitPaymentDesc =>
      'Split payment between different methods';

  @override
  String get permProductsView => 'View Products';

  @override
  String get permProductsViewDesc => 'View product list and details';

  @override
  String get permProductsManage => 'Manage Products';

  @override
  String get permProductsManageDesc => 'Add and edit products';

  @override
  String get permProductsDelete => 'Delete Products';

  @override
  String get permProductsDeleteDesc => 'Delete products from the system';

  @override
  String get permInventoryView => 'View Inventory';

  @override
  String get permInventoryViewDesc => 'View stock quantities';

  @override
  String get permInventoryManage => 'Manage Inventory';

  @override
  String get permInventoryManageDesc => 'Manage stock and transfers';

  @override
  String get permInventoryAdjust => 'Adjust Inventory';

  @override
  String get permInventoryAdjustDesc => 'Manually adjust stock quantities';

  @override
  String get permCustomersView => 'View Customers';

  @override
  String get permCustomersViewDesc => 'View customer data';

  @override
  String get permCustomersManage => 'Manage Customers';

  @override
  String get permCustomersManageDesc => 'Add and edit customers';

  @override
  String get permCustomersDelete => 'Delete Customers';

  @override
  String get permCustomersDeleteDesc => 'Delete customers from the system';

  @override
  String get permDiscountsApply => 'Apply Discounts';

  @override
  String get permDiscountsApplyDesc => 'Apply existing discounts';

  @override
  String get permDiscountsCreate => 'Create Discounts';

  @override
  String get permDiscountsCreateDesc => 'Create new discounts';

  @override
  String get permRefundsRequest => 'Request Refund';

  @override
  String get permRefundsRequestDesc => 'Request product refunds';

  @override
  String get permRefundsApprove => 'Approve Refund';

  @override
  String get permRefundsApproveDesc => 'Approve refund requests';

  @override
  String get permReportsView => 'View Reports';

  @override
  String get permReportsViewDesc => 'View reports and statistics';

  @override
  String get permReportsExport => 'Export Reports';

  @override
  String get permReportsExportDesc => 'Export reports in various formats';

  @override
  String get permSettingsView => 'View Settings';

  @override
  String get permSettingsViewDesc => 'View system settings';

  @override
  String get permSettingsManage => 'Manage Settings';

  @override
  String get permSettingsManageDesc => 'Modify system settings';

  @override
  String get permStaffView => 'View Staff';

  @override
  String get permStaffViewDesc => 'View staff list';

  @override
  String get permStaffManage => 'Manage Staff';

  @override
  String get permStaffManageDesc => 'Add and edit staff';

  @override
  String get roleSystemAdmin => 'System Admin';

  @override
  String get roleSystemAdminDesc => 'Full system permissions';

  @override
  String get roleStoreManager => 'Store Manager';

  @override
  String get roleStoreManagerDesc => 'Manage store and employees';

  @override
  String get roleCashierDesc => 'Sales and payment operations';

  @override
  String get roleWarehouseKeeper => 'Warehouse Keeper';

  @override
  String get roleWarehouseKeeperDesc => 'Manage inventory and products';

  @override
  String get roleAccountant => 'Accountant';

  @override
  String get roleAccountantDesc => 'Financial reports and accounts';

  @override
  String connectionFailedMsg(String error) {
    return 'Connection failed: $error';
  }

  @override
  String settingsSaveErrorMsg(String error) {
    return 'Error saving settings: $error';
  }

  @override
  String get cutPaperBtn => 'Cut';

  @override
  String upgradeToPlan(String name) {
    return 'Upgrade to $name';
  }

  @override
  String get manageDeliveryZonesAndPricing =>
      'Manage delivery zones and pricing';

  @override
  String settingsForName(String name) {
    return 'Settings for $name';
  }

  @override
  String settingsSavedForName(String name) {
    return 'Settings for $name saved';
  }

  @override
  String get jobProfile => 'Job Profile';

  @override
  String get submitToZatcaAuthority => 'Submit to ZATCA Authority';

  @override
  String get submitBtn => 'Submit';

  @override
  String get submitToAuthority => 'Submit to Authority';

  @override
  String shareError(String error) {
    return 'Sharing error: $error';
  }

  @override
  String upgradePlanPriceBody(String price) {
    return 'Plan price: $price SAR/month\n\nDo you want to continue?';
  }

  @override
  String get upgradeContactMsg =>
      'We will contact you to complete the upgrade process';

  @override
  String get zatcaSubmitBody =>
      'Electronic invoicing data will be sent to the authority. Make sure your data is correct first.';

  @override
  String get zatcaLinkComingSoon =>
      'ZATCA system integration coming soon - make sure to set up the digital certificate';

  @override
  String get enterApiKey => 'Enter API key';

  @override
  String get accountNumber => 'Account Number';

  @override
  String get superAdmin => 'Super Admin';

  @override
  String get platformOverview => 'Platform Overview';

  @override
  String get activeStores => 'Active Stores';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get subscriptionStats => 'Subscription Stats';

  @override
  String get churnRate => 'Churn Rate';

  @override
  String get conversionRate => 'Conversion Rate';

  @override
  String get trialConversion => 'Trial Conversion';

  @override
  String get newSignups => 'New Signups';

  @override
  String get monthlyRecurringRevenue => 'Monthly Recurring Revenue';

  @override
  String get annualRecurringRevenue => 'Annual Recurring Revenue';

  @override
  String get storesList => 'Stores';

  @override
  String get storeDetail => 'Store Detail';

  @override
  String get createStore => 'Create Store';

  @override
  String get storeOwner => 'Store Owner';

  @override
  String get storeStatus => 'Status';

  @override
  String get storeCreatedAt => 'Created At';

  @override
  String get storePlan => 'Plan';

  @override
  String get suspendStore => 'Suspend Store';

  @override
  String get activateStore => 'Activate Store';

  @override
  String get upgradePlan => 'Upgrade Plan';

  @override
  String get downgradePlan => 'Downgrade Plan';

  @override
  String get storeUsageStats => 'Usage Stats';

  @override
  String get storeTransactions => 'Transactions';

  @override
  String get storeProducts => 'Products Count';

  @override
  String get storeEmployees => 'Employees';

  @override
  String get onboardingForm => 'Onboarding Form';

  @override
  String get ownerName => 'Owner Name';

  @override
  String get ownerPhone => 'Owner Phone';

  @override
  String get ownerEmail => 'Owner Email';

  @override
  String get businessType => 'Business Type';

  @override
  String get branchCountLabel => 'Branch Count';

  @override
  String get subscriptionManagement => 'Subscription Management';

  @override
  String get plansManagement => 'Plans Management';

  @override
  String get subscriptionList => 'Subscriptions';

  @override
  String get billingAndInvoices => 'Billing & Invoices';

  @override
  String get planName => 'Plan Name';

  @override
  String get planPrice => 'Price';

  @override
  String get planFeatures => 'Features';

  @override
  String get basicPlan => 'Basic';

  @override
  String get advancedPlan => 'Advanced';

  @override
  String get professionalPlan => 'Professional';

  @override
  String get monthlyPrice => 'Monthly Price';

  @override
  String get yearlyPrice => 'Yearly Price';

  @override
  String get maxBranches => 'Max Branches';

  @override
  String get maxProducts => 'Max Products';

  @override
  String get maxUsers => 'Max Users';

  @override
  String get createPlan => 'Create Plan';

  @override
  String get editPlan => 'Edit Plan';

  @override
  String get selectPlan => 'Select Plan';

  @override
  String get currentPlan => 'Current Plan';

  @override
  String get noPlansAvailable => 'No plans available';

  @override
  String get alreadyOnHighestPlan => 'Already on the highest plan';

  @override
  String get alreadyOnLowestPlan => 'Already on the lowest plan';

  @override
  String get activeSubscriptions => 'Active Subscriptions';

  @override
  String get expiredSubscriptions => 'Expired Subscriptions';

  @override
  String get trialSubscriptions => 'Trial Subscriptions';

  @override
  String get billingHistory => 'Billing History';

  @override
  String get invoiceDate => 'Date';

  @override
  String get invoiceAmount => 'Amount';

  @override
  String get invoiceStatus => 'Status';

  @override
  String get unpaid => 'Unpaid';

  @override
  String get platformUsers => 'Platform Users';

  @override
  String get userDetail => 'User Detail';

  @override
  String get roleManagement => 'Role Management';

  @override
  String get userRole => 'Role';

  @override
  String get userLastActive => 'Last Active';

  @override
  String get superAdminRole => 'Super Admin';

  @override
  String get supportRole => 'Support';

  @override
  String get viewerRole => 'Viewer';

  @override
  String get assignRole => 'Assign Role';

  @override
  String get analytics => 'Analytics';

  @override
  String get revenueAnalytics => 'Revenue Analytics';

  @override
  String get usageAnalytics => 'Usage Analytics';

  @override
  String get mrrGrowth => 'MRR Growth';

  @override
  String get arrGrowth => 'ARR Growth';

  @override
  String get revenueByPlan => 'Revenue by Plan';

  @override
  String get revenueByMonth => 'Revenue by Month';

  @override
  String get activeUsersPerStore => 'Active Users per Store';

  @override
  String get transactionsPerStore => 'Transactions per Store';

  @override
  String get avgTransactionsPerDay => 'Avg Transactions/Day';

  @override
  String get topStoresByRevenue => 'Top Stores by Revenue';

  @override
  String get topStoresByTransactions => 'Top Stores by Transactions';

  @override
  String get platformSettings => 'Platform Settings';

  @override
  String get zatcaConfig => 'ZATCA Configuration';

  @override
  String get paymentGateways => 'Payment Gateways';

  @override
  String get systemHealth => 'System Health';

  @override
  String get systemMonitoring => 'System Monitoring';

  @override
  String get serverStatus => 'Server Status';

  @override
  String get apiLatency => 'API Latency';

  @override
  String get errorRate => 'Error Rate';

  @override
  String get cpuUsage => 'CPU Usage';

  @override
  String get memoryUsage => 'Memory Usage';

  @override
  String get diskUsage => 'Disk Usage';

  @override
  String get degraded => 'Degraded';

  @override
  String get down => 'Down';

  @override
  String get lastChecked => 'Last Checked';

  @override
  String get filterByStatus => 'Filter by Status';

  @override
  String get filterByPlan => 'Filter by Plan';

  @override
  String get allStatuses => 'All Statuses';

  @override
  String get allPlans => 'All Plans';

  @override
  String get suspended => 'Suspended';

  @override
  String get trial => 'Trial';

  @override
  String get searchStores => 'Search stores...';

  @override
  String get searchUsers => 'Search users...';

  @override
  String get noStoresFound => 'No stores found';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get confirmSuspend => 'Are you sure you want to suspend this store?';

  @override
  String get confirmActivate => 'Are you sure you want to activate this store?';

  @override
  String get storeCreatedSuccess => 'Store created successfully';

  @override
  String get storeSuspendedSuccess => 'Store suspended successfully';

  @override
  String get storeActivatedSuccess => 'Store activated successfully';

  @override
  String get perMonth => '/month';

  @override
  String get perYear => '/year';

  @override
  String get last90Days => 'Last 90 Days';

  @override
  String get last12Months => 'Last 12 Months';

  @override
  String get growth => 'Growth';

  @override
  String get stores => 'Stores';

  @override
  String get distributorPortal => 'Distributor Portal';

  @override
  String get distributorDashboard => 'Dashboard';

  @override
  String get distributorDashboardSubtitle =>
      'Distribution performance overview';

  @override
  String get distributorOrders => 'Incoming Orders';

  @override
  String get distributorProducts => 'Product Catalog';

  @override
  String get distributorPricing => 'Price Management';

  @override
  String get distributorReports => 'Reports';

  @override
  String get distributorSettings => 'Settings';

  @override
  String get distributorTotalOrders => 'Total Orders';

  @override
  String get distributorPendingOrders => 'Pending Orders';

  @override
  String get distributorApprovedOrders => 'Approved';

  @override
  String get distributorRevenue => 'Revenue';

  @override
  String get distributorMonthlySales => 'Monthly Sales';

  @override
  String get distributorRecentOrders => 'Recent Orders';

  @override
  String get distributorOrderNumber => 'Order Number';

  @override
  String get distributorStore => 'Store';

  @override
  String get distributorDate => 'Date';

  @override
  String get distributorAmount => 'Amount';

  @override
  String get distributorStatusPending => 'Pending';

  @override
  String get distributorStatusApproved => 'Approved';

  @override
  String get distributorStatusReceived => 'Received';

  @override
  String get distributorStatusRejected => 'Rejected';

  @override
  String get distributorStatusDraft => 'Draft';

  @override
  String get distributorNoOrders => 'No orders found';

  @override
  String get distributorAllOrders => 'All';

  @override
  String get distributorPendingTab => 'Pending';

  @override
  String get distributorApprovedTab => 'Approved';

  @override
  String get distributorRejectedTab => 'Rejected';

  @override
  String get distributorAddProduct => 'Add Product';

  @override
  String get distributorSearchHint => 'Search by name or barcode...';

  @override
  String get distributorNoProducts => 'No products found';

  @override
  String get distributorChangeSearch => 'Try changing your search criteria';

  @override
  String get distributorBarcode => 'Barcode';

  @override
  String get distributorCategory => 'Category';

  @override
  String get distributorStock => 'Stock';

  @override
  String get distributorStockEmpty => 'Out';

  @override
  String get distributorStockLow => 'Low';

  @override
  String get distributorActions => 'Actions';

  @override
  String distributorEditProduct(String name) {
    return 'Edit $name';
  }

  @override
  String get distributorCurrentPrice => 'Current Price';

  @override
  String get distributorNewPrice => 'New Price';

  @override
  String get distributorLastUpdated => 'Last Updated';

  @override
  String get distributorDifference => 'Diff';

  @override
  String get distributorTotalProducts => 'Total Products';

  @override
  String get distributorPendingChanges => 'Pending Changes';

  @override
  String distributorProductsWillUpdate(int count) {
    return '$count products will be updated';
  }

  @override
  String get distributorSaveChanges => 'Save Changes';

  @override
  String get distributorChangesSaved => 'Changes saved successfully';

  @override
  String distributorChangesCount(int count) {
    return '$count changes';
  }

  @override
  String get distributorExport => 'Export';

  @override
  String get distributorExportReport => 'Export Report';

  @override
  String get distributorDailySales => 'Daily Sales';

  @override
  String get distributorOrderCount => 'Order Count';

  @override
  String get distributorAvgOrderValue => 'Avg Order Value';

  @override
  String get distributorTopProduct => 'Top Product';

  @override
  String get distributorTopProducts => 'Top Products';

  @override
  String get distributorOrdersUnit => 'orders';

  @override
  String get distributorPeriodDay => 'Day';

  @override
  String get distributorPeriodWeek => 'Week';

  @override
  String get distributorPeriodMonth => 'Month';

  @override
  String get distributorPeriodYear => 'Year';

  @override
  String get distributorCompanyInfo => 'Company Info';

  @override
  String get distributorCompanyName => 'Company Name';

  @override
  String get distributorPhone => 'Phone';

  @override
  String get distributorEmail => 'Email';

  @override
  String get distributorAddress => 'Address';

  @override
  String get distributorNotificationSettings => 'Notification Settings';

  @override
  String get distributorNotificationChannels => 'Notification Channels';

  @override
  String get distributorEmailNotifications => 'Email';

  @override
  String get distributorPushNotifications => 'Push Notifications';

  @override
  String get distributorSmsNotifications => 'SMS';

  @override
  String get distributorNotificationTypes => 'Notification Types';

  @override
  String get distributorNewOrderNotification => 'New Orders';

  @override
  String get distributorOrderStatusNotification => 'Order Status Updates';

  @override
  String get distributorPaymentNotification => 'Payment Notifications';

  @override
  String get distributorDeliverySettings => 'Delivery Settings';

  @override
  String get distributorDeliveryZones => 'Delivery Zones';

  @override
  String get distributorDeliveryZonesHint => 'Enter cities separated by commas';

  @override
  String get distributorMinOrder => 'Min Order Amount (SAR)';

  @override
  String get distributorDeliveryFee => 'Delivery Fee (SAR)';

  @override
  String get distributorFreeDelivery => 'Free Delivery';

  @override
  String get distributorFreeDeliveryMin => 'Free Delivery Minimum (SAR)';

  @override
  String get distributorSaveSettings => 'Save Settings';

  @override
  String get distributorSettingsSaved => 'Settings saved successfully';

  @override
  String distributorPurchaseOrder(String number) {
    return 'Purchase Order #$number';
  }

  @override
  String get distributorProposedAmount => 'Proposed Amount:';

  @override
  String get distributorOrderItems => 'Order Items';

  @override
  String distributorProductCount(int count) {
    return '$count products';
  }

  @override
  String get distributorSuggestedPrice => 'Suggested Price';

  @override
  String get distributorYourPrice => 'Your Price';

  @override
  String get distributorYourTotal => 'Your Total';

  @override
  String get distributorNotesForStore => 'Notes for Store';

  @override
  String get distributorNotesHint => 'Add notes about the offer (optional)...';

  @override
  String get distributorRejectOrder => 'Reject Order';

  @override
  String get distributorAcceptSendQuote => 'Accept & Send Quote';

  @override
  String get distributorOrderRejected => 'Order rejected successfully';

  @override
  String distributorOrderAccepted(String amount) {
    return 'Order accepted and quote sent for $amount SAR';
  }

  @override
  String distributorLowerThanProposed(String percent) {
    return '$percent% lower than proposed';
  }

  @override
  String distributorHigherThanProposed(String percent) {
    return '+$percent% higher than proposed';
  }

  @override
  String get distributorComingSoon => 'Coming soon';

  @override
  String get distributorLoadError => 'Error loading data';

  @override
  String get distributorRetry => 'Retry';

  @override
  String get distributorLogin => 'Distributor Login';

  @override
  String get distributorLoginSubtitle => 'Enter your email and password';

  @override
  String get distributorEmailLabel => 'Email';

  @override
  String get distributorPasswordLabel => 'Password';

  @override
  String get distributorLoginButton => 'Sign In';

  @override
  String get distributorLoginError => 'Login failed';

  @override
  String get distributorLogout => 'Sign Out';

  @override
  String get distributorSar => 'SAR';

  @override
  String get distributorRiyal => 'SAR';

  @override
  String get distributorUnsavedChanges => 'Unsaved Changes';

  @override
  String get distributorUnsavedChangesMessage =>
      'You have unsaved changes. Do you want to leave without saving?';

  @override
  String get distributorStay => 'Stay';

  @override
  String get distributorLeave => 'Leave';

  @override
  String get distributorNoDataToExport => 'No data to export';

  @override
  String get distributorReportExported => 'Report exported successfully';

  @override
  String get distributorExportWebOnly => 'Export is only available on web';

  @override
  String get distributorPrintWebOnly => 'Printing is only available on web';

  @override
  String get distributorSaveError => 'An error occurred while saving';

  @override
  String get distributorInvalidEmail => 'Please enter a valid email address';

  @override
  String get distributorInvalidPhone => 'Please enter a valid phone number';

  @override
  String get distributorActionUndone => 'Action undone';

  @override
  String get distributorSessionExpired =>
      'Session expired due to inactivity. Please log in again.';

  @override
  String get distributorWelcomePortal => 'Welcome to the Distributor Portal!';

  @override
  String get distributorGetStarted =>
      'Get started by exploring these key features:';

  @override
  String get distributorManagePrices => 'Manage Prices';

  @override
  String get distributorManagePricesDesc =>
      'Set and update product prices for your distribution';

  @override
  String get distributorViewReports => 'View Reports';

  @override
  String get distributorViewReportsDesc =>
      'Track sales performance and view analytics';

  @override
  String get distributorUpdateSettings => 'Update Settings';

  @override
  String get distributorUpdateSettingsDesc =>
      'Configure company info, delivery zones, and notifications';

  @override
  String get distributorReviewOrdersDesc =>
      'Review and manage incoming purchase orders from stores';

  @override
  String get distributorMonthlySalesSar => 'Monthly Sales (SAR)';

  @override
  String get distributorPrintReport => 'Print Report';

  @override
  String get distributorPrint => 'Print';

  @override
  String get distributorExportCsv => 'Export report as CSV';

  @override
  String get distributorExportCsvShort => 'Export CSV';

  @override
  String get distributorSaveCtrlS => 'Save Changes (Ctrl+S)';

  @override
  String get scanCouponBarcode => 'Scan Coupon Barcode';

  @override
  String get validateCoupon => 'Validate';

  @override
  String get couponValid => 'Coupon Valid';

  @override
  String get recentCoupons => 'Recent Coupons';

  @override
  String get noRecentCoupons => 'No recent coupons';

  @override
  String get noExpiry => 'No Expiry';

  @override
  String get invalidCouponCode => 'Invalid coupon code';

  @override
  String get percentageOff => 'Percentage Off';

  @override
  String get bundleDeals => 'Bundle Deals';

  @override
  String get includedProducts => 'Included Products';

  @override
  String get individualTotal => 'Individual Total';

  @override
  String get bundlePrice => 'Bundle Price';

  @override
  String get youSave => 'You Save';

  @override
  String get noBundleDeals => 'No bundle deals';

  @override
  String get bundleDealsWillAppear => 'Bundle deals will appear here';

  @override
  String validUntilDate(String date) {
    return 'Valid Until: $date';
  }

  @override
  String validFromDate(String date) {
    return 'Valid From: $date';
  }

  @override
  String get autoApplied => 'Auto Applied';

  @override
  String get noActiveOffers => 'No active offers';

  @override
  String get wastage => 'Wastage';

  @override
  String get quantityWasted => 'Quantity Wasted';

  @override
  String get photoLabel => 'Photo';

  @override
  String get photoAttached => 'Photo attached';

  @override
  String get tapToTakePhoto => 'Tap to take photo';

  @override
  String get optionalLabel => 'Optional';

  @override
  String get recordWastage => 'Record Wastage';

  @override
  String get spillage => 'Spillage';

  @override
  String get transferInventory => 'Transfer Inventory';

  @override
  String get transferDetails => 'Transfer Details';

  @override
  String get fromStore => 'From Store';

  @override
  String get toStore => 'To Store';

  @override
  String get selectStore => 'Select Store';

  @override
  String get submitTransfer => 'Submit Transfer';

  @override
  String get optionalNote => 'Optional note';

  @override
  String get addInventory => 'Add Inventory';

  @override
  String get scanLabel => 'Scan';

  @override
  String get quantityToAdd => 'Quantity to Add';

  @override
  String get supplierReference => 'Supplier Reference';

  @override
  String get removeInventory => 'Remove Inventory';

  @override
  String get quantityToRemove => 'Quantity to Remove';

  @override
  String get sold => 'Sold';

  @override
  String get transferred => 'Transferred';

  @override
  String get fieldRequired => 'Field required';

  @override
  String get deviceInfo => 'Device Info';

  @override
  String get deviceName => 'Device Name';

  @override
  String get deviceType => 'Device Type';

  @override
  String get connectionMethod => 'Connection Method';

  @override
  String get networkSettings => 'Network Settings';

  @override
  String get ipAddress => 'IP Address';

  @override
  String get port => 'Port';

  @override
  String get connectionTestPassed => 'Connection test passed';

  @override
  String get saveDevice => 'Save Device';

  @override
  String get addDevice => 'Add Device';

  @override
  String get noPaymentDevices => 'No payment devices';

  @override
  String get addFirstPaymentDevice => 'Add your first payment device';

  @override
  String get totalDevices => 'Total Devices';

  @override
  String get disconnected => 'Disconnected';

  @override
  String testingConnectionName(String name) {
    return 'Testing connection $name...';
  }

  @override
  String connectionSuccessful(String name) {
    return '$name - Connection successful';
  }

  @override
  String get pasteFromClipboard => 'Paste from Clipboard';

  @override
  String get confirmRestore => 'Confirm Restore';

  @override
  String get saleNotFound => 'Sale not found';

  @override
  String get noItems => 'No items';

  @override
  String get customerPaysExtra => 'Customer pays extra';

  @override
  String get submitExchange => 'Submit Exchange';

  @override
  String get applyInterest => 'Apply Interest';

  @override
  String get reportSettings => 'Report Settings';

  @override
  String get reportType => 'Report Type';

  @override
  String get paymentDistribution => 'Payment Distribution';

  @override
  String get allAccountsSettled => 'All customer accounts are settled';

  @override
  String get confirmInterest => 'Confirm Interest';

  @override
  String confirmInterestMessage(
      String rate, int count, String amount, String currency) {
    return 'Apply $rate% interest to $count accounts?\nTotal interest: $amount $currency';
  }

  @override
  String get selectCustomers => 'Select Customers';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get preview => 'Preview';

  @override
  String get totalDebt => 'Total Debt';

  @override
  String get totalInterest => 'Total Interest';

  @override
  String get finalizeInvoice => 'Finalize Invoice';

  @override
  String get saveAsDraft => 'Save as Draft';

  @override
  String get saveDraft => 'Save Draft';

  @override
  String get finalize => 'Finalize';

  @override
  String get adjustQuantity => 'Adjust Quantity';

  @override
  String get totalItems => 'Total Items';

  @override
  String get variance => 'Variance';

  @override
  String get orderNotFound => 'Order not found';

  @override
  String get share => 'Share';

  @override
  String get full => 'Full';

  @override
  String get processRefund => 'Process Refund';

  @override
  String get refundToCustomer => 'Refund to customer';

  @override
  String get breakdown => 'Breakdown';

  @override
  String nTransactions(int count) {
    return '$count Transactions';
  }

  @override
  String get customReport => 'Custom Report';

  @override
  String get reportBuilder => 'Report Builder';

  @override
  String get groupBy => 'Group By';

  @override
  String get dateRange => 'Date Range';

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String get generateReport => 'Generate Report';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get periods => 'Periods';

  @override
  String get valueLabel => 'Value';

  @override
  String get tryDifferentFilters => 'Try different filters';

  @override
  String get scan => 'Scan';

  @override
  String get selectProductFirst => 'Select a product first';

  @override
  String get selectProductsForLabels => 'Select products for labels';

  @override
  String printJobSentForLabels(int count) {
    return 'Print job sent for $count labels';
  }

  @override
  String get test => 'Test';

  @override
  String get paperSize58mm => '58mm';

  @override
  String get paperSize80mm => '80mm';

  @override
  String errorSavingSettings(String error) {
    return 'Error saving settings: $error';
  }

  @override
  String restoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get address => 'Address';

  @override
  String get email => 'Email';

  @override
  String get crNumber => 'CR Number';

  @override
  String get city => 'City';

  @override
  String get optional => 'Optional';

  @override
  String get optionalNoteHint => 'Optional note...';

  @override
  String get clearField => 'Clear';

  @override
  String get decreaseQuantity => 'Decrease quantity';

  @override
  String get increaseQuantity => 'Increase quantity';

  @override
  String get copyToClipboard => 'Copy';

  @override
  String get invoiceAlreadyRefunded =>
      'This invoice has already been fully refunded';

  @override
  String get invoicePartiallyRefunded =>
      'Some items were previously refunded - showing remaining items only';

  @override
  String get invoiceVoidedCannotRefund =>
      'This invoice is voided and cannot be refunded';

  @override
  String deviceClockInaccurate(int minutes) {
    return 'Device clock is inaccurate - please adjust the time (offset: $minutes min)';
  }

  @override
  String get saSignInFailed => 'Sign in failed';

  @override
  String get saAccessDenied => 'Access denied. Super Admin role required.';

  @override
  String get saPlatformManagement => 'Alhai POS Platform Management';

  @override
  String get saSuperAdmin => 'Super Admin';

  @override
  String get saEnterCredentials => 'Please enter email and password';

  @override
  String get saSignIn => 'Sign In';

  @override
  String get saSuperAdminOnly =>
      'Only users with Super Admin role can access this panel.';

  @override
  String get saNoSubscriptionsYet => 'No subscriptions yet';

  @override
  String get saNoRevenueData => 'No revenue data';

  @override
  String get saNoLogsFound => 'No logs found';

  @override
  String get saPlatformSummary => 'Platform Summary';

  @override
  String get saSubscriptionStatus => 'Subscription Status';

  @override
  String get saExportData => 'Export Data';

  @override
  String get saExportComingSoon => 'Export coming soon';

  @override
  String get saStoresReport => 'Stores Report';

  @override
  String get saUsersReport => 'Users Report';

  @override
  String get saRevenueReport => 'Revenue Report';

  @override
  String get saActivityLogs => 'Activity Logs';

  @override
  String get saWarnings => 'Warnings';

  @override
  String get saZatcaEInvoicing => 'ZATCA E-invoicing';

  @override
  String get saEnableEInvoicing =>
      'Enable electronic invoicing compliance for all stores';

  @override
  String get saApiEnvironment => 'API Environment';

  @override
  String get saTaxRateVat => 'Tax Rate (VAT)';

  @override
  String get saDefaultLanguage => 'Default Language';

  @override
  String get saDefaultCurrency => 'Default Currency';

  @override
  String get saTrialPeriodDays => 'Trial Period (Days)';

  @override
  String get saResourceUsage => 'Resource Usage';

  @override
  String get saResponseTime => 'Response Time';

  @override
  String get saDbRoundTrip => 'DB Round-trip';

  @override
  String get saExcellent => 'Excellent';

  @override
  String get saGood => 'Good';

  @override
  String get saSlow => 'Slow';

  @override
  String get saRoleUpdated => 'Role updated';

  @override
  String get saNoInvoices => 'No invoices found';

  @override
  String get saErrorLoading => 'Error loading data';

  @override
  String get saUpgradePlan => 'Upgrade Plan';

  @override
  String get saDowngradePlan => 'Downgrade Plan';

  @override
  String get saEditPlan => 'Edit Plan';

  @override
  String get saPaymentGateways => 'Payment Gateways';

  @override
  String get saCreditDebitProcessing => 'Credit/debit card processing';

  @override
  String get saMultiMethodGateway => 'Multi-method payment gateway';

  @override
  String get saBuyNowPayLater => 'Buy now, pay later';

  @override
  String get saInstallmentPayments => 'Installment payments';

  @override
  String get saActiveStores => 'Active Stores';

  @override
  String get saActiveSubscriptions => 'Active Subscriptions';

  @override
  String get saTrialSubscriptions => 'Trial Subscriptions';

  @override
  String get saNewSignups30d => 'New Signups (30d)';

  @override
  String get saSubscribers => 'Subscribers';

  @override
  String get saPercentOfTotal => '% of Total';

  @override
  String get saDeactivateUserConfirm =>
      'Are you sure you want to deactivate this user? Their access will be revoked immediately.';

  @override
  String get saSuspendStoreConfirm =>
      'Are you sure you want to suspend this store? All user access will be revoked immediately.';

  @override
  String get password => 'Password';

  @override
  String get saReportsTitle => 'Reports';

  @override
  String get startDate => 'Start';

  @override
  String get endDate => 'End';

  @override
  String get customerPhoneNumber => 'Customer Phone Number';

  @override
  String get continueAction => 'Continue';

  @override
  String get continueWithCustomer => 'Continue with Customer';

  @override
  String get existingCustomers => 'Existing Customers';

  @override
  String get digitsRemaining => 'digits remaining';

  @override
  String get phoneNumberTooLong => 'Number is too long';

  @override
  String get enterValidPhoneNumber => 'Enter a valid phone number';

  @override
  String get cancelledByAdmin => 'Cancelled by admin';

  @override
  String get shiftOpenCloseReminders => 'Shift open/close reminders';

  @override
  String get setOrChangeManagerPin => 'Set or change manager PIN';

  @override
  String get dataSynchronizationStatus => 'Data synchronization status';

  @override
  String get reportBalanceSheetTitle => 'Balance Sheet';

  @override
  String reportBalanceSheetAsOf(String date) {
    return 'As of $date';
  }

  @override
  String get reportAssets => 'Assets';

  @override
  String get reportCurrentAssets => 'Current Assets';

  @override
  String get reportCashInDrawer => 'Cash in Drawer';

  @override
  String get reportAccountsReceivable => 'Accounts Receivable (Customers)';

  @override
  String get reportInventoryValue => 'Inventory Value';

  @override
  String get reportTotalCurrentAssets => 'Total Current Assets';

  @override
  String get reportTotalAssets => 'Total Assets';

  @override
  String get reportLiabilities => 'Liabilities';

  @override
  String get reportCurrentLiabilities => 'Current Liabilities';

  @override
  String get reportAccountsPayable => 'Accounts Payable (Suppliers)';

  @override
  String get reportTotalCurrentLiabilities => 'Total Current Liabilities';

  @override
  String get reportTotalLiabilities => 'Total Liabilities';

  @override
  String get reportEquity => 'Equity';

  @override
  String get reportNetEquity => 'Net Equity';

  @override
  String get reportAccountingEquation => 'Accounting Equation';

  @override
  String get reportAssetsEqualsLiabilitiesPlusEquity =>
      'Assets = Liabilities + Equity';

  @override
  String get reportCashFlowTitle => 'Cash Flow Statement';

  @override
  String get reportNetCashFlow => 'Net Cash Flow';

  @override
  String get reportOperatingActivities => 'Operating Activities';

  @override
  String get reportSalesReceipts => 'Sales Receipts';

  @override
  String get reportExpensesPaid => 'Expenses Paid';

  @override
  String get reportTaxesPaidVat => 'Taxes Paid (VAT)';

  @override
  String get reportInvestingActivities => 'Investing Activities';

  @override
  String get reportPurchasePayments => 'Purchase Payments';

  @override
  String get reportFinancingActivities => 'Financing Activities';

  @override
  String get reportCashDeposit => 'Cash Deposit';

  @override
  String get reportCashWithdrawal => 'Cash Withdrawal';

  @override
  String get reportThisQuarter => 'This Quarter';

  @override
  String get reportThisYear => 'This Year';

  @override
  String get reportQuarterly => 'Quarterly';

  @override
  String get reportAnnual => 'Annual';

  @override
  String get reportDebtAgingTitle => 'Debt Aging Report';

  @override
  String get reportDebtBucket0to30 => '0-30 Days';

  @override
  String get reportDebtBucket31to60 => '31-60 Days';

  @override
  String get reportDebtBucket61to90 => '61-90 Days';

  @override
  String get reportDebtBucket90plus => '90+ Days';

  @override
  String get reportTotalDebts => 'Total Debts';

  @override
  String reportNDays(int count) {
    return '$count days';
  }

  @override
  String get reportComparisonTitle => 'Comparison Report';

  @override
  String get reportIndicator => 'Indicator';

  @override
  String get reportChange => 'Change';

  @override
  String get reportLastMonth => 'Last Month';

  @override
  String get reportLastQuarter => 'Last Quarter';

  @override
  String get reportLastYear => 'Last Year';

  @override
  String get reportCurrentPeriod => 'Current Period';

  @override
  String get reportPreviousPeriod => 'Previous Period';

  @override
  String get reportZakatTitle => 'Zakat Calculation';

  @override
  String get reportZakatDue => 'Zakat is Due';

  @override
  String get reportZakatBelowNisab => 'Below Nisab';

  @override
  String get reportZakatAmountDue => 'Zakat Amount Due';

  @override
  String reportZakatRateOf(String rate) {
    return 'At a rate of $rate% of the Zakat base';
  }

  @override
  String reportNisabThreshold(String amount) {
    return 'Nisab Threshold: $amount SAR';
  }

  @override
  String reportCurrentZakatBase(String amount) {
    return 'Current Zakat Base: $amount SAR';
  }

  @override
  String reportNisabInfo(String amount) {
    return 'Nisab: $amount SAR (approx. value of 85g of gold)';
  }

  @override
  String get reportZakatAssets => 'Zakat Assets (+)';

  @override
  String get reportGoodsAndInventory => 'Goods & Inventory Value';

  @override
  String get reportAvailableCash => 'Available Cash';

  @override
  String get reportExpectedReceivables => 'Expected Receivables';

  @override
  String get reportDeductions => 'Deductions (-)';

  @override
  String get reportDebtsToSuppliers => 'Debts Owed to Suppliers';

  @override
  String get reportOtherLiabilities => 'Other Liabilities';

  @override
  String get reportNetZakatBase => 'Net Zakat Base';

  @override
  String get reportZakatDisclaimer =>
      'Note: This is an approximate calculation. Consult a qualified scholar for precise Zakat determination.';

  @override
  String get reportPurchaseTitle => 'Purchase Report';

  @override
  String get reportPurchasesBySupplier => 'Purchases by Supplier';

  @override
  String get reportRecentInvoices => 'Recent Invoices';

  @override
  String get reportNoPurchasesInPeriod => 'No purchases in this period';

  @override
  String reportNInvoices(int count) {
    return '$count invoices';
  }

  @override
  String get reportTotalTax => 'Total Tax';

  @override
  String get reportExportSuccess => 'Report exported successfully';

  @override
  String reportExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get saSaveChanges => 'Save Changes';

  @override
  String get saSaving => 'Saving...';

  @override
  String get saDiscardChanges => 'Discard';

  @override
  String get saConfirmSave => 'Save';

  @override
  String get saPlatformSettingsConfirm =>
      'These changes affect all organizations on the platform. Save anyway?';

  @override
  String get saPlatformSettingsSaved => 'Platform settings saved successfully';

  @override
  String get saPlatformSettingsSaveFailed => 'Failed to save platform settings';

  @override
  String get saErrorLoadingSettings => 'Error loading settings';

  @override
  String get saEnvProduction => 'Production';

  @override
  String get saEnvSandbox => 'Sandbox';

  @override
  String get saMoyasarDescription => 'Credit/debit card processing';

  @override
  String get saHyperpayDescription => 'Multi-method payment gateway';

  @override
  String get saTabbyDescription => 'Buy now, pay later';

  @override
  String get saTamaraDescription => 'Installment payments';

  @override
  String get saGeneral => 'General';

  @override
  String get saLanguageArabic => 'Arabic';

  @override
  String get saLanguageEnglish => 'English';

  @override
  String get saAuditLog => 'Audit Log';

  @override
  String get saAuditLogRefresh => 'Refresh';

  @override
  String get saAuditFilterAll => 'All';

  @override
  String get saAuditFilterAuth => 'Auth';

  @override
  String get saAuditFilterStore => 'Store';

  @override
  String get saAuditFilterUser => 'User';

  @override
  String get saAuditFilterSubscription => 'Subscription';

  @override
  String get saAuditSearchHint => 'Search by email, ID, action...';

  @override
  String get saAuditLoadFailed => 'Failed to load audit log';

  @override
  String get saAuditLoadRetry => 'Retry';

  @override
  String get saAuditNoEntries => 'No audit entries found';

  @override
  String saAuditEntryBy(String email) {
    return 'by $email';
  }

  @override
  String get saReportsExportComingSoon =>
      'Export is not yet available — coming soon';

  @override
  String get saSystemHealthMetricsNote =>
      'CPU / Memory / Disk metrics require a backend health endpoint — not yet wired';

  @override
  String get saMfaScanQr => 'Scan this QR in your Authenticator app';

  @override
  String get saMfaSecretFallback => 'Or enter this key manually:';

  @override
  String get saMfaCopied => 'Copied to clipboard';

  @override
  String get saErrorGeneric => 'Something went wrong';

  @override
  String get saErrorNetwork => 'Network error — check your connection';

  @override
  String get saErrorRetry => 'Try Again';

  @override
  String get saErrorTechnical => 'Technical details';

  @override
  String get saNext => 'Next';

  @override
  String get saBackToLogin => 'Back to Login';

  @override
  String get saPopularBadge => 'POPULAR';

  @override
  String get saRefresh => 'Refresh';

  @override
  String get saPlanUpdated => 'Plan updated';

  @override
  String get saRenewal => 'Renewal';

  @override
  String get saBusinessTypeGrocery => 'Grocery';

  @override
  String get saBusinessTypeRestaurant => 'Restaurant';

  @override
  String get saBusinessTypeRetail => 'Retail';

  @override
  String get saBusinessTypeServices => 'Services';

  @override
  String get saNoPlanRevenueData => 'No plan revenue data';

  @override
  String get saNoStoreRevenueData => 'No store revenue data';

  @override
  String get saNoActiveUserData => 'No active user data';

  @override
  String get saNoTransactionData => 'No transaction data';

  @override
  String get saMfaSetupTitle => 'Set Up Two-Factor Authentication';

  @override
  String get saMfaVerifyTitle => 'Two-Factor Verification';

  @override
  String get saMfaEnrollmentInstruction =>
      'Scan the QR code with your authenticator app (Google Authenticator, Authy, etc.) then enter the 6-digit code to complete setup.';

  @override
  String get saMfaVerifyInstruction =>
      'Enter the 6-digit code from your authenticator app.';

  @override
  String get saMfaCopy => 'Copy';

  @override
  String get saMfaCompleteSetup => 'Complete Setup';

  @override
  String get saMfaVerifyButton => 'Verify';

  @override
  String get saMfaEnterValidCode => 'Enter a valid 6-digit code';

  @override
  String get saMfaTooManyAttempts =>
      'Too many failed attempts. Locked for 30 minutes.';

  @override
  String saMfaAccountLocked(int minutes) {
    return 'Account locked. Try again in $minutes minutes.';
  }

  @override
  String saMfaInvalidCode(int remaining) {
    return 'Invalid code. $remaining attempts remaining.';
  }

  @override
  String get saMfaEnrollmentFailed =>
      'MFA enrollment failed. Ensure MFA is enabled in your Supabase project.';

  @override
  String get saMfaEnrollmentNoData => 'TOTP enrollment returned no data.';
}
