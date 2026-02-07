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
  String get branchManager => 'Branch Manager';

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
}
