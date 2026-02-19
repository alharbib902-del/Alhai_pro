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
  String get product => 'Product';

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
    return '$count branches';
  }

  @override
  String branchSelected(String name) {
    return 'Selected $name';
  }

  @override
  String get addBranch => 'Add New Branch';

  @override
  String get comingSoon => 'This feature coming soon';

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
    return '$count orders today';
  }

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get viewAll => 'View All';

  @override
  String get orderNumber => 'Order #';

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
    return '$count minutes ago';
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
  String get unit => 'unit';

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
  String get sortByName => 'Name';

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
    return '$count hours ago';
  }

  @override
  String daysAgo(int count) {
    return '$count days ago';
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
    return '$count categories';
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
    return '$count invoices waiting payment';
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
  String get statusAll => 'Status: All';

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
  String get exportPdf => 'PDF';

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
    return '$count selected';
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
  String get otherReason => 'Other';

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
  String get invoiceNumberLabel => 'Number:';

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
  String get storeName => 'Neighborhood Supermarket';

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
  String get last30Days => 'Last 30 days';

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
    return 'Returned Items ($count)';
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
  String customerCount(String count) {
    return '$count customer(s)';
  }

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
  String get customerAddedSuccess => 'Customer added successfully';

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
  String get cashierName => 'Cashier';

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
  String get userName => 'Username';

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
  String get qrCodeOnInvoice => 'QR Code on Invoice';

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
}
