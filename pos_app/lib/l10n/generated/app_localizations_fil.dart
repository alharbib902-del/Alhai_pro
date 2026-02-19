// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Filipino Pilipino (`fil`).
class AppLocalizationsFil extends AppLocalizations {
  AppLocalizationsFil([String locale = 'fil']) : super(locale);

  @override
  String get appTitle => 'Point of Sale System';

  @override
  String get login => 'Mag-login';

  @override
  String get logout => 'Mag-logout';

  @override
  String get welcome => 'Maligayang pagdating';

  @override
  String get welcomeBack => 'Maligayang pagbabalik';

  @override
  String get phone => 'Numero ng Telepono';

  @override
  String get phoneHint => '05xxxxxxxx';

  @override
  String get phoneRequired => 'Kailangan ang numero ng telepono';

  @override
  String get phoneInvalid => 'Hindi wastong numero ng telepono';

  @override
  String get otp => 'Verification Code';

  @override
  String get otpHint => 'Ilagay ang verification code';

  @override
  String get otpSent => 'Naipadala na ang verification code';

  @override
  String get otpResend => 'Ipadala muli ang code';

  @override
  String get otpExpired => 'Nag-expire na ang verification code';

  @override
  String get otpInvalid => 'Hindi wastong verification code';

  @override
  String otpResendIn(int seconds) {
    return 'Ipadala muli sa $seconds segundo';
  }

  @override
  String get pin => 'PIN Code';

  @override
  String get pinHint => 'Ilagay ang PIN code';

  @override
  String get pinRequired => 'Kailangan ang PIN code';

  @override
  String get pinInvalid => 'Hindi wastong PIN code';

  @override
  String pinAttemptsRemaining(int count) {
    return 'Natitirang pagtatangka: $count';
  }

  @override
  String pinLocked(int minutes) {
    return 'Naka-lock ang account. Subukan pagkatapos ng $minutes minuto';
  }

  @override
  String get home => 'Home';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get pos => 'Point of Sale';

  @override
  String get products => 'Mga Produkto';

  @override
  String get categories => 'Mga Kategorya';

  @override
  String get inventory => 'Imbentaryo';

  @override
  String get customers => 'Mga Customer';

  @override
  String get orders => 'Mga Order';

  @override
  String get invoices => 'Mga Invoice';

  @override
  String get reports => 'Mga Ulat';

  @override
  String get settings => 'Mga Setting';

  @override
  String get sales => 'Mga Benta';

  @override
  String get salesAnalytics => 'Pagsusuri ng Mga Benta';

  @override
  String get refund => 'Refund';

  @override
  String get todaySales => 'Benta Ngayong Araw';

  @override
  String get totalSales => 'Kabuuang Benta';

  @override
  String get averageSale => 'Average na Benta';

  @override
  String get cart => 'Cart';

  @override
  String get cartEmpty => 'Walang laman ang cart';

  @override
  String get addToCart => 'Idagdag sa Cart';

  @override
  String get removeFromCart => 'Alisin sa Cart';

  @override
  String get clearCart => 'I-clear ang Cart';

  @override
  String get checkout => 'Checkout';

  @override
  String get payment => 'Pagbabayad';

  @override
  String get paymentMethod => 'Paraan ng Pagbabayad';

  @override
  String get cash => 'Cash';

  @override
  String get card => 'Card';

  @override
  String get credit => 'Credit';

  @override
  String get transfer => 'Transfer';

  @override
  String get paymentSuccess => 'Matagumpay ang pagbabayad';

  @override
  String get paymentFailed => 'Nabigo ang pagbabayad';

  @override
  String get price => 'Presyo';

  @override
  String get quantity => 'Dami';

  @override
  String get total => 'Kabuuan';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discount => 'Diskwento';

  @override
  String get tax => 'Buwis';

  @override
  String get vat => 'VAT';

  @override
  String get grandTotal => 'Grand Total';

  @override
  String get product => 'Produkto';

  @override
  String get productName => 'Pangalan ng Produkto';

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
  String get inStock => 'May Stock';

  @override
  String get customer => 'Customer';

  @override
  String get customerName => 'Pangalan ng Customer';

  @override
  String get customerPhone => 'Telepono ng Customer';

  @override
  String get debt => 'Utang';

  @override
  String get balance => 'Balanse';

  @override
  String get search => 'Maghanap';

  @override
  String get searchHint => 'Maghanap dito...';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Ayusin';

  @override
  String get all => 'Lahat';

  @override
  String get add => 'Idagdag';

  @override
  String get edit => 'I-edit';

  @override
  String get delete => 'Tanggalin';

  @override
  String get save => 'I-save';

  @override
  String get cancel => 'Kanselahin';

  @override
  String get confirm => 'Kumpirmahin';

  @override
  String get close => 'Isara';

  @override
  String get back => 'Bumalik';

  @override
  String get next => 'Susunod';

  @override
  String get done => 'Tapos na';

  @override
  String get submit => 'Isumite';

  @override
  String get retry => 'Subukan Muli';

  @override
  String get loading => 'Nag-loload...';

  @override
  String get noData => 'Walang data';

  @override
  String get noResults => 'Walang mga resulta';

  @override
  String get error => 'Error';

  @override
  String get errorOccurred => 'May naganap na error';

  @override
  String get tryAgain => 'Subukan muli';

  @override
  String get connectionError => 'Error sa koneksyon';

  @override
  String get noInternet => 'Walang koneksyon sa internet';

  @override
  String get offline => 'Offline';

  @override
  String get online => 'Online';

  @override
  String get success => 'Tagumpay';

  @override
  String get warning => 'Babala';

  @override
  String get info => 'Impormasyon';

  @override
  String get yes => 'Oo';

  @override
  String get no => 'Hindi';

  @override
  String get today => 'Ngayon';

  @override
  String get yesterday => 'Kahapon';

  @override
  String get thisWeek => 'Ngayong Linggo';

  @override
  String get thisMonth => 'Ngayong Buwan';

  @override
  String get shift => 'Shift';

  @override
  String get openShift => 'Buksan ang Shift';

  @override
  String get closeShift => 'Isara ang Shift';

  @override
  String get shiftSummary => 'Buod ng Shift';

  @override
  String get cashDrawer => 'Cash Drawer';

  @override
  String get receipt => 'Resibo';

  @override
  String get printReceipt => 'I-print ang Resibo';

  @override
  String get shareReceipt => 'I-share ang Resibo';

  @override
  String get sync => 'Sync';

  @override
  String get syncing => 'Nagsi-sync...';

  @override
  String get syncComplete => 'Kumpleto na ang sync';

  @override
  String get syncFailed => 'Nabigo ang sync';

  @override
  String get lastSync => 'Huling sync';

  @override
  String get language => 'Wika';

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
  String get theme => 'Tema';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemMode => 'System Mode';

  @override
  String get notifications => 'Mga Notification';

  @override
  String get security => 'Seguridad';

  @override
  String get printer => 'Printer';

  @override
  String get backup => 'Backup';

  @override
  String get help => 'Tulong';

  @override
  String get about => 'Tungkol sa';

  @override
  String get version => 'Bersyon';

  @override
  String get copyright => 'Lahat ng karapatan ay nakalaan';

  @override
  String get deleteConfirmTitle => 'Kumpirmahin ang Pagtanggal';

  @override
  String get deleteConfirmMessage => 'Sigurado ka bang gusto mong tanggalin?';

  @override
  String get logoutConfirmTitle => 'Kumpirmahin ang Logout';

  @override
  String get logoutConfirmMessage => 'Sigurado ka bang gusto mong mag-logout?';

  @override
  String get requiredField => 'Kailangan ang field na ito';

  @override
  String get invalidFormat => 'Hindi wastong format';

  @override
  String minLength(int min) {
    return 'Dapat ay hindi bababa sa $min na character';
  }

  @override
  String maxLength(int max) {
    return 'Dapat ay mas mababa sa $max na character';
  }

  @override
  String get welcomeTitle => 'Maligayang Pagbabalik! 👋';

  @override
  String get welcomeSubtitle =>
      'Mag-sign in upang pamahalaan ang iyong tindahan nang madali at mabilis';

  @override
  String get welcomeSubtitleShort =>
      'Mag-sign in upang pamahalaan ang iyong tindahan';

  @override
  String get brandName => 'Al-Hal POS';

  @override
  String get brandTagline => 'Smart Point of Sale System';

  @override
  String get enterPhoneToContinue =>
      'Ilagay ang iyong numero ng telepono para magpatuloy';

  @override
  String get pleaseEnterValidPhone =>
      'Mangyaring maglagay ng valid na numero ng telepono';

  @override
  String get otpSentViaWhatsApp =>
      'Naipadala ang verification code sa WhatsApp';

  @override
  String get otpResent => 'Napadala muli ang verification code';

  @override
  String get enterOtpFully =>
      'Mangyaring ilagay ang kumpletong verification code';

  @override
  String get maxAttemptsReached =>
      'Naabot na ang maximum na pagtatangka. Mangyaring humingi ng bagong code';

  @override
  String waitMinutes(int minutes) {
    return 'Naabot na ang maximum na pagtatangka. Maghintay ng $minutes minuto';
  }

  @override
  String waitSeconds(int seconds) {
    return 'Mangyaring maghintay ng $seconds segundo';
  }

  @override
  String resendIn(String time) {
    return 'Ipadala muli ($time)';
  }

  @override
  String get resendCode => 'Ipadala muli ang code';

  @override
  String get changeNumber => 'Palitan ang numero';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String remainingAttempts(int count) {
    return 'Natitirang pagtatangka: $count';
  }

  @override
  String get technicalSupport => 'Teknikal na Suporta';

  @override
  String get privacyPolicy => 'Patakaran sa Privacy';

  @override
  String get termsAndConditions => 'Mga Tuntunin at Kundisyon';

  @override
  String get allRightsReserved =>
      '© 2026 Al-Hal System. Lahat ng karapatan ay nakalaan.';

  @override
  String get dayMode => 'Day Mode';

  @override
  String get nightMode => 'Night Mode';

  @override
  String get selectBranch => 'Pumili ng Branch';

  @override
  String get selectBranchDesc => 'Piliin ang branch na gusto mong pagtrabahuan';

  @override
  String get availableBranches => 'Mga Available na Branch';

  @override
  String branchCount(int count) {
    return '$count branches';
  }

  @override
  String branchSelected(String name) {
    return 'Napili ang $name';
  }

  @override
  String get addBranch => 'Magdagdag ng Bagong Branch';

  @override
  String get comingSoon => 'Darating na ang feature na ito';

  @override
  String get tryDifferentSearch => 'Subukan ang ibang salita sa paghahanap';

  @override
  String get selectLanguage => 'Pumili ng Wika';

  @override
  String get languageChangeInfo =>
      'Piliin ang iyong gustong wika sa pagpapakita. Ang mga pagbabago ay ilalapat kaagad.';

  @override
  String get centralManagement => 'Sentral na Pamamahala';

  @override
  String get centralManagementDesc =>
      'Kontrolin ang lahat ng iyong mga branch at warehouse mula sa isang lugar. Makakuha ng mga instant na ulat at inventory sync sa lahat ng POS points.';

  @override
  String get selectBranchToContinue => 'Pumili ng Branch para Magpatuloy';

  @override
  String get youHaveAccessToBranches =>
      'May access ka sa mga sumusunod na branch. Pumili ng isa para magsimula.';

  @override
  String get searchForBranch => 'Maghanap ng branch...';

  @override
  String get openNow => 'Bukas Ngayon';

  @override
  String closedOpensAt(String time) {
    return 'Sarado (Magbubukas $time)';
  }

  @override
  String get loggedInAs => 'Naka-login bilang';

  @override
  String get support247 => '24/7 Suporta';

  @override
  String get analyticsTools => 'Mga Analytics Tool';

  @override
  String get uptime => 'Uptime';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get searchPlaceholder => 'Pangkalahatang paghahanap...';

  @override
  String get mainBranch => 'Pangunahing Branch (Riyadh)';

  @override
  String get todaySalesLabel => 'Benta Ngayon';

  @override
  String get ordersCountLabel => 'Bilang ng Order';

  @override
  String get newCustomersLabel => 'Bagong Customer';

  @override
  String get stockAlertsLabel => 'Mga Alert sa Stock';

  @override
  String get productsUnit => 'produkto';

  @override
  String get salesAnalysis => 'Pagsusuri ng Benta';

  @override
  String get storePerformance => 'Performance ng tindahan ngayong linggo';

  @override
  String get weekly => 'Lingguhan';

  @override
  String get monthly => 'Buwanan';

  @override
  String get yearly => 'Taunan';

  @override
  String get quickAction => 'Mabilis na Aksyon';

  @override
  String get newSale => 'Bagong Benta';

  @override
  String get addProduct => 'Magdagdag ng Produkto';

  @override
  String get returnItem => 'Ibalik';

  @override
  String get dailyReport => 'Ulat Araw-araw';

  @override
  String get closeDay => 'Isara ang Araw';

  @override
  String get topSelling => 'Pinakabenta';

  @override
  String ordersToday(int count) {
    return '$count order ngayon';
  }

  @override
  String get recentTransactions => 'Kamakailang mga Transaksyon';

  @override
  String get viewAll => 'Tingnan Lahat';

  @override
  String get orderNumber => 'Order #';

  @override
  String get time => 'Oras';

  @override
  String get status => 'Status';

  @override
  String get amount => 'Halaga';

  @override
  String get action => 'Aksyon';

  @override
  String get completed => 'Kumpleto';

  @override
  String get returned => 'Ibinalik';

  @override
  String get pending => 'Nakabinbin';

  @override
  String get cancelled => 'Kinansela';

  @override
  String get guestCustomer => 'Guest Customer';

  @override
  String minutesAgo(int count) {
    return '$count minuto ang nakalipas';
  }

  @override
  String get posSystem => 'POS System';

  @override
  String get branchManager => 'Branch Manager';

  @override
  String get settingsSection => 'Mga Setting';

  @override
  String get systemSettings => 'Mga Setting ng System';

  @override
  String get sar => 'SAR';

  @override
  String get daily => 'Araw-araw';

  @override
  String get goodMorning => 'Magandang Umaga';

  @override
  String get goodEvening => 'Magandang Gabi';

  @override
  String get cashCustomer => 'Cash Customer';

  @override
  String get noTransactionsToday => 'Walang transaksyon ngayon';

  @override
  String get comparedToYesterday => 'Kumpara kahapon';

  @override
  String get ordersText => 'mga order ngayon';

  @override
  String get storeManagement => 'Pamamahala ng Tindahan';

  @override
  String get finance => 'Pananalapi';

  @override
  String get teamSection => 'Team';

  @override
  String get fullscreen => 'Buong Screen';

  @override
  String goodMorningName(String name) {
    return 'Magandang Umaga, $name!';
  }

  @override
  String goodEveningName(String name) {
    return 'Magandang Gabi, $name!';
  }

  @override
  String get shoppingCart => 'Shopping Cart';

  @override
  String get selectOrSearchCustomer => 'Pumili o maghanap ng customer';

  @override
  String get newCustomer => 'Bago';

  @override
  String get draft => 'Draft';

  @override
  String get pay => 'Bayaran';

  @override
  String get haveCoupon => 'May discount coupon ka ba?';

  @override
  String discountPercent(String percent) {
    return 'Discount $percent%';
  }

  @override
  String get openDrawer => 'Buksan Drawer';

  @override
  String get suspend => 'I-suspend';

  @override
  String get quantitySoldOut => 'Sold Out';

  @override
  String get noProducts => 'Walang produkto';

  @override
  String get addProductsToStart => 'Magdagdag ng produkto para magsimula';

  @override
  String get undoComingSoon => 'I-undo (malapit na)';

  @override
  String get employees => 'Empleyado';

  @override
  String get loyaltyProgram => 'Loyalty Program';

  @override
  String get newBadge => 'Bago';

  @override
  String get technicalSupportShort => 'Technical Support';

  @override
  String get productDetails => 'Detalye ng Produkto';

  @override
  String get stockMovements => 'Galaw ng Stock';

  @override
  String get priceHistory => 'Kasaysayan ng Presyo';

  @override
  String get salesHistory => 'Kasaysayan ng Benta';

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
  String get lastSale => 'Huling Benta';

  @override
  String get printLabel => 'I-print ang Label';

  @override
  String get copied => 'Nakopya';

  @override
  String copiedToClipboard(String label) {
    return 'Nakopya ang $label';
  }

  @override
  String get active => 'Aktibo';

  @override
  String get inactive => 'Hindi Aktibo';

  @override
  String get profitMargin => 'Margin ng Kita';

  @override
  String get sellingPrice => 'Presyo ng Benta';

  @override
  String get costPrice => 'Presyo ng Gastos';

  @override
  String get description => 'Paglalarawan';

  @override
  String get noDescription => 'Walang paglalarawan';

  @override
  String get productNotFound => 'Hindi natagpuan ang produkto';

  @override
  String get stockStatus => 'Status ng Stock';

  @override
  String get currentStock => 'Kasalukuyang Stock';

  @override
  String get unit => 'yunit';

  @override
  String get units => 'mga yunit';

  @override
  String get date => 'Petsa';

  @override
  String get type => 'Uri';

  @override
  String get reference => 'Sanggunian';

  @override
  String get newBalance => 'Bagong Balanse';

  @override
  String get oldPrice => 'Lumang Presyo';

  @override
  String get newPrice => 'Bagong Presyo';

  @override
  String get reason => 'Dahilan';

  @override
  String get invoiceNumber => 'Invoice #';

  @override
  String get categoryLabel => 'Kategorya';

  @override
  String get uncategorized => 'Walang kategorya';

  @override
  String get noSupplier => 'Walang supplier';

  @override
  String get moreOptions => 'Higit Pang Opsyon';

  @override
  String get noStockMovements => 'Walang galaw ng stock';

  @override
  String get noPriceHistory => 'Walang kasaysayan ng presyo';

  @override
  String get noSalesHistory => 'Walang kasaysayan ng benta';

  @override
  String get sale => 'Benta';

  @override
  String get purchase => 'Binili';

  @override
  String get adjustment => 'Pag-aayos';

  @override
  String get returnText => 'Ibalik';

  @override
  String get waste => 'Basura';

  @override
  String get initialStock => 'Paunang Stock';

  @override
  String get searchByNameOrBarcode => 'Maghanap sa pangalan o barcode...';

  @override
  String get hideFilters => 'Itago ang Mga Filter';

  @override
  String get showFilters => 'Ipakita ang Mga Filter';

  @override
  String get sortByName => 'Pangalan';

  @override
  String get sortByPrice => 'Presyo';

  @override
  String get sortByStock => 'Stock';

  @override
  String get sortByRecent => 'Kamakailan';

  @override
  String get allItems => 'Lahat';

  @override
  String get clearFilters => 'I-clear ang Mga Filter';

  @override
  String get noBarcode => 'Walang barcode';

  @override
  String stockCount(int count) {
    return 'Stock: $count';
  }

  @override
  String get saveChanges => 'I-save ang Mga Pagbabago';

  @override
  String get addTheProduct => 'Idagdag ang Produkto';

  @override
  String get editProduct => 'I-edit ang Produkto';

  @override
  String get newProduct => 'Bagong Produkto';

  @override
  String get minimumQuantity => 'Minimum na Dami';

  @override
  String get selectCategory => 'Pumili ng Kategorya';

  @override
  String get productImage => 'Larawan ng Produkto';

  @override
  String get trackInventory => 'I-track ang Imbentaryo';

  @override
  String get productSavedSuccess => 'Matagumpay na na-save ang produkto';

  @override
  String get productAddedSuccess => 'Matagumpay na naidagdag ang produkto';

  @override
  String get scanBarcode => 'I-scan ang Barcode';

  @override
  String get activeProduct => 'Aktibong Produkto';

  @override
  String get currency => 'SAR';

  @override
  String hoursAgo(int count) {
    return '$count oras ang nakalipas';
  }

  @override
  String daysAgo(int count) {
    return '$count araw ang nakalipas';
  }

  @override
  String get supplierPriceUpdate => 'Update sa presyo ng supplier';

  @override
  String get costIncrease => 'Pagtaas ng gastos';

  @override
  String get duplicateProduct => 'I-duplicate ang Produkto';

  @override
  String get categoriesManagement => 'Pamamahala ng Kategorya';

  @override
  String categoriesCount(int count) {
    return '$count kategorya';
  }

  @override
  String get addCategory => 'Magdagdag ng Kategorya';

  @override
  String get editCategory => 'I-edit ang Kategorya';

  @override
  String get deleteCategory => 'I-delete ang Kategorya';

  @override
  String get categoryName => 'Pangalan ng Kategorya';

  @override
  String get categoryNameAr => 'Pangalan (Arabic)';

  @override
  String get categoryNameEn => 'Pangalan (English)';

  @override
  String get parentCategory => 'Pangunahing Kategorya';

  @override
  String get noParentCategory => 'Walang pangunahing kategorya (Root)';

  @override
  String get sortOrder => 'Pagkakasunod';

  @override
  String get categoryColor => 'Kulay';

  @override
  String get categoryIcon => 'Icon';

  @override
  String get categoryDetails => 'Detalye ng Kategorya';

  @override
  String get categoryCreatedAt => 'Petsa ng Paglikha';

  @override
  String get categoryProducts => 'Mga Produkto ng Kategorya';

  @override
  String get noCategorySelected =>
      'Pumili ng kategorya para makita ang detalye';

  @override
  String get deleteCategoryConfirm =>
      'Sigurado ka bang gusto mong i-delete ang kategoryang ito?';

  @override
  String get categoryDeletedSuccess => 'Matagumpay na na-delete ang kategorya';

  @override
  String get categorySavedSuccess => 'Matagumpay na na-save ang kategorya';

  @override
  String get searchCategories => 'Maghanap ng kategorya...';

  @override
  String get reorderCategories => 'Ayusin ang pagkakasunod';

  @override
  String get noCategories => 'Walang nahanap na kategorya';

  @override
  String get subcategories => 'Mga sub-kategorya';

  @override
  String get activeStatus => 'Aktibo';

  @override
  String get inactiveStatus => 'Hindi Aktibo';

  @override
  String get invoicesTitle => 'Mga Invoice';

  @override
  String get totalInvoices => 'Kabuuang Invoice';

  @override
  String get totalPaid => 'Kabuuang Nabayaran';

  @override
  String get totalPending => 'Kabuuang Pending';

  @override
  String get totalOverdue => 'Kabuuang Overdue';

  @override
  String get comparedToLastMonth => 'Kumpara sa nakaraang buwan';

  @override
  String ofTotalDue(String percent) {
    return '$percent% ng kabuuang dapat bayaran';
  }

  @override
  String invoicesWaitingPayment(int count) {
    return '$count invoice naghihintay ng bayad';
  }

  @override
  String get sendReminderNow => 'Magpadala ng Paalala';

  @override
  String get revenueAnalysis => 'Pagsusuri ng Kita';

  @override
  String get last7Days => 'Huling 7 Araw';

  @override
  String get thisMonthPeriod => 'Ngayong Buwan';

  @override
  String get thisYearPeriod => 'Ngayong Taon';

  @override
  String get paymentMethods => 'Paraan ng Pagbayad';

  @override
  String get cashPayment => 'Cash';

  @override
  String get cardPayment => 'Card';

  @override
  String get walletPayment => 'Wallet';

  @override
  String get saveCurrentFilter => 'I-save ang Kasalukuyang Filter';

  @override
  String get statusAll => 'Status: Lahat';

  @override
  String get statusPaid => 'Nabayaran';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get statusCancelled => 'Kinansela';

  @override
  String get resetFilters => 'I-reset';

  @override
  String get createInvoice => 'Gumawa ng Invoice';

  @override
  String get invoiceNumberCol => 'Invoice #';

  @override
  String get customerNameCol => 'Pangalan ng Customer';

  @override
  String get dateCol => 'Petsa';

  @override
  String get amountCol => 'Halaga';

  @override
  String get statusCol => 'Status';

  @override
  String get paymentCol => 'Bayad';

  @override
  String get actionsCol => 'Aksyon';

  @override
  String get viewInvoice => 'Tingnan';

  @override
  String get printInvoice => 'I-print';

  @override
  String get exportPdf => 'PDF';

  @override
  String get sendWhatsapp => 'WhatsApp';

  @override
  String get deleteInvoice => 'Tanggalin';

  @override
  String get reminder => 'Paalala';

  @override
  String get exportAll => 'I-export Lahat';

  @override
  String get printReport => 'I-print Report';

  @override
  String get more => 'Higit pa';

  @override
  String showingResults(int from, int to, int total) {
    return 'Nagpapakita ng $from hanggang $to mula sa $total resulta';
  }

  @override
  String get newInvoice => 'Bagong Invoice';

  @override
  String get selectCustomer => 'Pumili ng Customer';

  @override
  String get cashCustomerGeneral => 'Cash Customer (General)';

  @override
  String get addNewCustomer => '+ Magdagdag ng Bagong Customer';

  @override
  String get productsSection => 'Mga Produkto';

  @override
  String get addProductToInvoice => '+ Magdagdag ng Produkto';

  @override
  String get productCol => 'Produkto';

  @override
  String get quantityCol => 'Qty';

  @override
  String get priceCol => 'Presyo';

  @override
  String get dueDate => 'Takdang Petsa';

  @override
  String get invoiceTotal => 'Kabuuan:';

  @override
  String get saveInvoice => 'I-save ang Invoice';

  @override
  String get deleteConfirm => 'Sigurado ka ba?';

  @override
  String get deleteInvoiceMsg =>
      'Gusto mo bang tanggalin ang invoice na ito? Hindi na ito maibabalik.';

  @override
  String get yesDelete => 'Oo, Tanggalin';

  @override
  String get copiedSuccess => 'Matagumpay na nakopya';

  @override
  String get invoiceDeleted => 'Matagumpay na natanggal ang invoice';

  @override
  String get sat => 'Sab';

  @override
  String get sun => 'Lin';

  @override
  String get mon => 'Lun';

  @override
  String get tue => 'Mar';

  @override
  String get wed => 'Miy';

  @override
  String get thu => 'Huw';

  @override
  String get fri => 'Biy';

  @override
  String selected(int count) {
    return '$count napili';
  }

  @override
  String get bulkPrint => 'I-print';

  @override
  String get bulkExportPdf => 'I-export PDF';

  @override
  String get allRightsReservedFooter =>
      '© 2026 Alhai POS. Lahat ng karapatan ay nakalaan.';

  @override
  String get privacyPolicyFooter => 'Patakaran sa Privacy';

  @override
  String get termsFooter => 'Mga Tuntunin at Kundisyon';

  @override
  String get supportFooter => 'Technical Support';

  @override
  String get paid => 'Nabayaran';

  @override
  String get overdue => 'Overdue';

  @override
  String get creditCard => 'Credit Card';

  @override
  String get electronicWallet => 'E-Wallet';

  @override
  String get searchInvoiceHint => 'Maghanap sa invoice number, customer...';

  @override
  String get customerDetails => 'Detalye ng Customer';

  @override
  String get customerProfileAndTransactions =>
      'Pangkalahatang-tanaw ng profile at transaksyon';

  @override
  String get customerDetailTitle => 'Detalye ng Customer';

  @override
  String get totalPurchases => 'Kabuuang Binili';

  @override
  String get loyaltyPoints => 'Loyalty Points';

  @override
  String get lastVisit => 'Huling Bisita';

  @override
  String get newSaleAction => 'Bagong Benta';

  @override
  String get editInfo => 'I-edit ang Info';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get blockCustomer => 'I-block ang Customer';

  @override
  String get purchasesTab => 'Mga Binili';

  @override
  String get accountTab => 'Account';

  @override
  String get debtsTab => 'Mga Utang';

  @override
  String get analyticsTab => 'Analytics';

  @override
  String get recentOrdersLog => 'Kamakailang Log ng Order';

  @override
  String get exportCsv => 'I-export CSV';

  @override
  String get searchByInvoiceNumber => 'Maghanap sa invoice number...';

  @override
  String get items => 'Items';

  @override
  String get viewDetails => 'Tingnan ang Detalye';

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
    return 'I-redeem $count points';
  }

  @override
  String get viewFullLedger => 'Tingnan Lahat';

  @override
  String get currentBalance => 'Kasalukuyang Balanse';

  @override
  String get creditLimit => 'Credit Limit';

  @override
  String get used => 'Nagamit';

  @override
  String get topUpBalance => 'Top Up Balanse';

  @override
  String get overdueDebt => 'Overdue';

  @override
  String get upcomingDebt => 'Paparating';

  @override
  String get payNow => 'Bayaran Ngayon';

  @override
  String get remind => 'Ipaalala';

  @override
  String get monthlySpending => 'Buwanang Gastusin';

  @override
  String get purchaseDistribution =>
      'Distribusyon ng Mga Binili ayon sa Kategorya';

  @override
  String get last6Months => 'Huling 6 na Buwan';

  @override
  String get thisYear => 'Ngayong Taon';

  @override
  String get averageOrder => 'Average na Order';

  @override
  String get purchaseFrequency => 'Dalas ng Pagbili';

  @override
  String everyNDays(int count) {
    return 'Tuwing $count araw';
  }

  @override
  String get spendingGrowth => 'Paglaki ng Gastusin';

  @override
  String get favoriteProduct => 'Paboritong Produkto';

  @override
  String get internalNotes => 'Mga Panloob na Nota (nakikita lamang ng staff)';

  @override
  String get addNote => 'Idagdag';

  @override
  String get addNewNote => 'Magdagdag ng bagong nota...';

  @override
  String joinedDate(String date) {
    return 'Sumali: $date';
  }

  @override
  String lastUpdated(String time) {
    return 'Huling na-update: $time';
  }

  @override
  String showingOrders(int from, int to, int total) {
    return 'Nagpapakita ng $from-$to mula sa $total order';
  }

  @override
  String get vegetables => 'Gulay';

  @override
  String get dairy => 'Dairy';

  @override
  String get meat => 'Karne';

  @override
  String get bakery => 'Bakery';

  @override
  String get other => 'Iba pa';

  @override
  String get returns => 'Mga Return';

  @override
  String get salesReturns => 'Sales Returns';

  @override
  String get purchaseReturns => 'Purchase Returns';

  @override
  String get totalReturns => 'Kabuuang Returns';

  @override
  String get totalRefundedAmount => 'Kabuuang Na-refund';

  @override
  String get mostReturned => 'Pinaka-maraming Return';

  @override
  String get processed => 'Na-refund';

  @override
  String get newReturn => 'Bagong Return';

  @override
  String get createNewReturn => 'Gumawa ng Bagong Return';

  @override
  String get processReturnRequest => 'Iproseso ang sales return';

  @override
  String get returnNumber => 'Return Number';

  @override
  String get originalInvoice => 'Orihinal na Invoice';

  @override
  String get returnReason => 'Dahilan ng Return';

  @override
  String get returnAmount => 'Halaga ng Return';

  @override
  String get returnStatus => 'Status';

  @override
  String get returnDate => 'Petsa';

  @override
  String get returnActions => 'Aksyon';

  @override
  String get returnRefunded => 'Na-refund';

  @override
  String get returnRejected => 'Tinanggihan';

  @override
  String get defectiveProduct => 'Sirang Produkto';

  @override
  String get wrongProduct => 'Maling Produkto';

  @override
  String get customerRequest => 'Kahilingan ng Customer';

  @override
  String get otherReason => 'Iba pa';

  @override
  String get quickSearch => 'Mabilis na paghahanap...';

  @override
  String get exportData => 'I-export';

  @override
  String get printData => 'I-print';

  @override
  String get approve => 'Aprubahan';

  @override
  String get reject => 'Tanggihan';

  @override
  String get previous => 'Nakaraan';

  @override
  String get invoiceStep => 'Invoice';

  @override
  String get itemsStep => 'Mga Item';

  @override
  String get reasonStep => 'Dahilan';

  @override
  String get confirmStep => 'Kumpirmasyon';

  @override
  String get enterInvoiceNumber => 'Invoice Number';

  @override
  String get invoiceExample => 'Halimbawa: #INV-889';

  @override
  String get loadInvoice => 'I-load';

  @override
  String invoiceLoaded(String number) {
    return 'Na-load ang Invoice #$number';
  }

  @override
  String invoiceLoadedCustomer(String customer, String date) {
    return 'Customer: $customer | Petsa: $date';
  }

  @override
  String get selectItemsInfo =>
      'Pumili ng mga item na ire-return. Hindi maaaring i-return ang higit sa nabili.';

  @override
  String availableToReturn(int count) {
    return 'Available: $count';
  }

  @override
  String get alreadyReturnedFully => 'Buong quantity na naibalik na';

  @override
  String get returnReasonLabel => 'Dahilan ng Return (para sa napiling items)';

  @override
  String get additionalDetails =>
      'Karagdagang detalye (kailangan para sa Iba pa)...';

  @override
  String get confirmReturn => 'Kumpirmahin ang Return';

  @override
  String get refundAmount => 'Halaga ng Refund';

  @override
  String get refundMethod => 'Paraan ng Refund';

  @override
  String get cashRefund => 'Cash';

  @override
  String get storeCredit => 'Store Credit';

  @override
  String get returnCreatedSuccess => 'Matagumpay na nagawa ang return';

  @override
  String get noReturns => 'Walang Returns';

  @override
  String get noReturnsDesc => 'Wala pang naitatalang return operations.';

  @override
  String timesReturned(int count, int percent) {
    return '$count beses ($percent% ng kabuuan)';
  }

  @override
  String get fromInvoice => 'Mula sa invoice';

  @override
  String get dateFromTo => 'Petsa mula - hanggang';

  @override
  String get returnCopied => 'Matagumpay na nakopya ang numero';

  @override
  String ofTotalProcessed(int percent) {
    return '$percent% na-proseso';
  }

  @override
  String get invoiceDetails => 'Detalye ng Invoice';

  @override
  String invoiceNumberLabel(String number) {
    return 'Numero:';
  }

  @override
  String get additionalOptions => 'Karagdagang Opsyon';

  @override
  String get duplicateInvoice => 'Gumawa ng Duplicate';

  @override
  String get returnMerchandise => 'Ibalik ang Produkto';

  @override
  String get voidInvoice => 'I-void ang Invoice';

  @override
  String get printBtn => 'I-print';

  @override
  String get downloadBtn => 'I-download';

  @override
  String get paidSuccessfully => 'Matagumpay na Nabayaran';

  @override
  String get amountReceivedFull => 'Buong halaga natanggap';

  @override
  String get completedStatus => 'Kumpleto';

  @override
  String get pendingStatus => 'Pending';

  @override
  String get voidedStatus => 'Na-void';

  @override
  String get storeName => 'Supermarket ng Barangay';

  @override
  String get storeAddress => 'Riyadh, Al-Malaz District, Takhassusi Street';

  @override
  String get simplifiedTaxInvoice => 'Simplified Tax Invoice';

  @override
  String get dateAndTime => 'Petsa at Oras';

  @override
  String get cashierLabel => 'Cashier';

  @override
  String get itemCol => 'Item';

  @override
  String get quantityColDetail => 'Qty';

  @override
  String get priceColDetail => 'Presyo';

  @override
  String get totalCol => 'Kabuuan';

  @override
  String get subtotalLabel => 'Subtotal';

  @override
  String get discountVip => 'Diskwento (VIP Member)';

  @override
  String get vatLabel => 'VAT (15%)';

  @override
  String get grandTotalLabel => 'Kabuuang Total';

  @override
  String get paymentMethodLabel => 'Paraan ng Bayad';

  @override
  String get amountPaidLabel => 'Halagang Binayaran';

  @override
  String get zatcaElectronic => 'ZATCA - Electronic Invoice';

  @override
  String get scanToVerify => 'I-scan para ma-verify';

  @override
  String get includesVat15 => 'Kasama ang 15% VAT';

  @override
  String get thankYouVisit => 'Salamat sa pagbisita!';

  @override
  String get wishNiceDay => 'Magandang araw sa inyo';

  @override
  String get customerInfo => 'Impormasyon ng Customer';

  @override
  String get editBtn => 'I-edit';

  @override
  String vipSince(String year) {
    return 'VIP Customer mula $year';
  }

  @override
  String get activeStatusLabel => 'Aktibo';

  @override
  String get callBtn => 'Tawag';

  @override
  String get recordBtn => 'Rekord';

  @override
  String get quickActions => 'Mabilis na Aksyon';

  @override
  String get sendWhatsappAction => 'Ipadala sa WhatsApp';

  @override
  String get sendEmailAction => 'Ipadala sa Email';

  @override
  String get downloadPdfAction => 'I-download PDF';

  @override
  String get shareLinkAction => 'Ibahagi Link';

  @override
  String get eventLog => 'Event Log';

  @override
  String get paymentCompleted => 'Bayad Kumpleto';

  @override
  String get processedViaGateway => 'Na-process sa payment gateway';

  @override
  String minutesAgoDetail(int count) {
    return '$count minuto na ang nakalipas';
  }

  @override
  String get invoiceCreated => 'Na-gawa ang Invoice';

  @override
  String byUser(String name) {
    return 'Ni $name';
  }

  @override
  String todayAt(String time) {
    return 'Ngayon, $time';
  }

  @override
  String get orderStarted => 'Nagsimula ang Order';

  @override
  String get cashierSessionOpened => 'Binuksan ang cashier session';

  @override
  String get technicalData => 'Teknikal na Data';

  @override
  String get deviceIdLabel => 'Device ID';

  @override
  String get terminalLabel => 'Terminal';

  @override
  String get softwareVersion => 'Software V';

  @override
  String get voidInvoiceConfirm => 'I-void ang Invoice?';

  @override
  String get voidInvoiceMsg =>
      'Permanenteng ma-void ang invoice na ito. Sigurado ka ba?';

  @override
  String get voidReasonLabel => 'Dahilan ng Void (Kinakailangan)';

  @override
  String get voidReasonEntry => 'Entry Error';

  @override
  String get voidReasonCustomer => 'Kahilingan ng Customer';

  @override
  String get voidReasonDamaged => 'Sirang Produkto';

  @override
  String get voidReasonOther => 'Ibang Dahilan...';

  @override
  String get confirmVoid => 'Kumpirmahin ang Void';

  @override
  String get invoiceVoided => 'Matagumpay na na-void ang invoice';

  @override
  String copiedText(String text) {
    return 'Nakopya: $text';
  }

  @override
  String visaEnding(String digits) {
    return 'Visa nagtatapos sa $digits';
  }

  @override
  String get mobileActionPrint => 'I-print';

  @override
  String get mobileActionWhatsapp => 'WhatsApp';

  @override
  String get mobileActionEmail => 'Email';

  @override
  String get mobileActionMore => 'Iba pa';

  @override
  String get sarCurrency => 'SAR';

  @override
  String skuLabel(String code) {
    return 'SKU: $code';
  }

  @override
  String get helpText => 'Tulong';

  @override
  String get customerLedger => 'Ledger ng Customer';

  @override
  String get accountStatement => 'Statement ng Account';

  @override
  String get allPeriods => 'Lahat';

  @override
  String get threeMonths => '3 Buwan';

  @override
  String get allMovements => 'Lahat ng Transaksyon';

  @override
  String get adjustments => 'Mga Adjustment';

  @override
  String get statementCol => 'Paglalarawan';

  @override
  String get referenceCol => 'Sanggunian';

  @override
  String get debitCol => 'Debit';

  @override
  String get creditCol => 'Credit';

  @override
  String get balanceCol => 'Balanse';

  @override
  String get openingBalance => 'Pambungad na Balanse';

  @override
  String get totalDebit => 'Kabuuang Debit';

  @override
  String get totalCredit => 'Kabuuang Credit';

  @override
  String get finalBalance => 'Huling Balanse';

  @override
  String get manualAdjustment => 'Manual na Adjustment';

  @override
  String get adjustmentType => 'Uri ng Adjustment';

  @override
  String get debitAdjustment => 'Debit Adjustment';

  @override
  String get creditAdjustment => 'Credit Adjustment';

  @override
  String get adjustmentAmount => 'Halaga ng Adjustment';

  @override
  String get adjustmentReason => 'Dahilan ng Adjustment';

  @override
  String get adjustmentDate => 'Petsa ng Adjustment';

  @override
  String get saveAdjustment => 'I-save ang Adjustment';

  @override
  String get adjustmentSaved => 'Matagumpay na na-save ang adjustment';

  @override
  String get enterValidAmount => 'Maglagay ng wastong halaga';

  @override
  String get dueOnCustomer => 'Utang ng customer';

  @override
  String get customerHasCredit => 'May credit balance ang customer';

  @override
  String get noTransactions => 'Walang transaksyon';

  @override
  String get recordPaymentBtn => 'Mag-record ng Bayad';

  @override
  String get returnEntry => 'Return';

  @override
  String get adjustmentEntry => 'Adjustment';

  @override
  String get ordersHistory => 'Kasaysayan ng Order';

  @override
  String get totalOrdersLabel => 'Kabuuang Order';

  @override
  String get completedOrders => 'Nakumpleto';

  @override
  String get pendingOrders => 'Nakabinbin';

  @override
  String get cancelledOrders => 'Kinansela';

  @override
  String get searchOrderHint =>
      'Maghanap sa numero ng order, customer, o telepono...';

  @override
  String get channelLabel => 'Channel';

  @override
  String get last30Days => 'Huling 30 araw';

  @override
  String get orderDetails => 'Detalye ng Order';

  @override
  String get unpaidLabel => 'Hindi Nabayaran';

  @override
  String get voidTransaction => 'I-void ang Transaksyon';

  @override
  String get voidSaleTransaction => 'I-void ang Sales Transaction';

  @override
  String get voidWarningTitle =>
      'Mahalagang Babala: Hindi na maaaring ibalik ang aksyon na ito';

  @override
  String get voidWarningDesc =>
      'Ang pag-void ng transaksyon na ito ay magkakansela ng invoice at ibabalik ang lahat ng item sa inventory.';

  @override
  String get voidWarningShort =>
      'Ang aksyon na ito ay magkakansela ng invoice. Hindi na maaaring bawiin.';

  @override
  String get enterInvoiceToVoid => 'Ilagay ang invoice number para i-void';

  @override
  String get searchByInvoiceOrBarcode =>
      'Maghanap gamit ang invoice number o barcode scanner';

  @override
  String get invoiceExampleVoid => 'Halimbawa: #INV-2024-8892';

  @override
  String get activateBarcode => 'I-activate ang barcode scanner';

  @override
  String get scanBarcodeMobile => 'I-scan ang barcode';

  @override
  String get searchForInvoiceToVoid => 'Maghanap ng invoice para i-void';

  @override
  String get enterNumberOrScan =>
      'Ilagay ang numero o gamitin ang barcode scanner.';

  @override
  String get salesInvoice => 'Sales Invoice';

  @override
  String get invoiceCompleted => 'Kumpleto';

  @override
  String get paidCash => 'Bayad: Cash';

  @override
  String get customerLabel => 'Customer';

  @override
  String get dateAndTimeLabel => 'Petsa at Oras';

  @override
  String get voidImpactSummary => 'Buod ng Epekto ng Void';

  @override
  String voidImpactItemsReturn(int count) {
    return '$count item ang ibabalik sa inventory.';
  }

  @override
  String voidImpactRefund(String amount, String currency) {
    return 'Halaga na $amount $currency ang ibabawas/ibabalik.';
  }

  @override
  String returnedItems(int count) {
    return 'Mga Ibinalik na Item ($count)';
  }

  @override
  String get viewAllItems => 'Tingnan Lahat';

  @override
  String moreItemsHint(int count, String amount, String currency) {
    return '+ $count pang item (kabuuan: $amount $currency)';
  }

  @override
  String get voidReason => 'Dahilan ng Void';

  @override
  String get voidReasonRequired => 'Dahilan ng Void *';

  @override
  String get customerRequestReason => 'Kahilingan ng customer';

  @override
  String get wrongItemsReason => 'Maling item';

  @override
  String get duplicateInvoiceReason => 'Duplicate na invoice';

  @override
  String get systemErrorReason => 'System error';

  @override
  String get otherReasonVoid => 'Iba pa';

  @override
  String get additionalNotesVoid => 'Karagdagang mga tala...';

  @override
  String get additionalDetailsRequired =>
      'Karagdagang detalye (kailangan para sa Iba pa)...';

  @override
  String get managerApproval => 'Pag-apruba ng Manager';

  @override
  String get managerApprovalRequired => 'Kailangan ng Pag-apruba ng Manager';

  @override
  String amountExceedsLimit(String amount, String currency) {
    return 'Ang halaga ay lumampas sa limit ($amount $currency), ilagay ang manager PIN.';
  }

  @override
  String get enterPinCode => 'Ilagay ang PIN code';

  @override
  String get pinSentToManager =>
      'Pansamantalang code ipinadala sa phone ng manager';

  @override
  String get defaultManagerPin => 'Default manager code: 1234';

  @override
  String get confirmVoidAction =>
      'Kinukumpirma ko ang pag-void ng transaksyon na ito';

  @override
  String get confirmVoidDesc =>
      'Narepaso ko na ang mga detalye at tinatanggap ko ang buong responsibilidad.';

  @override
  String get cancelAction => 'Kanselahin';

  @override
  String get confirmFinalVoid => 'Kumpirmahin ang Final na Void';

  @override
  String get invoiceNotFound => 'Hindi nahanap ang invoice';

  @override
  String get invoiceNotFoundDesc =>
      'I-verify ang inilagay na numero o subukan ang barcode.';

  @override
  String get trySearchAgain => 'Subukang maghanap muli';

  @override
  String get voidSuccess => 'Matagumpay na na-void ang transaksyon';

  @override
  String qtyLabel(int count) {
    return 'Qty: $count';
  }

  @override
  String get manageCustomersAndAccounts =>
      'Pamahalaan ang mga customer at account';

  @override
  String get totalCustomersCount => 'Kabuuang Customer';

  @override
  String get outstandingDebts => 'Natitirang Utang';

  @override
  String get creditBalance => 'Customer Credit';

  @override
  String get filterByLabel => 'I-filter ayon sa';

  @override
  String get debtors => 'May Utang';

  @override
  String get creditorsLabel => 'May Credit';

  @override
  String get quickActionsLabel => 'Mabilisang Aksyon';

  @override
  String get sendDebtReminder => 'Magpadala ng paalala sa utang';

  @override
  String get exportAccountStatement => 'I-export ang statement';

  @override
  String cancelSelectionCount(String count) {
    return 'Kanselahin ang pagpili ($count)';
  }

  @override
  String get searchByNameOrPhone =>
      'Maghanap sa pangalan o telepono... (Ctrl+F)';

  @override
  String get sortByBalance => 'Balanse';

  @override
  String get refreshF5 => 'I-refresh (F5)';

  @override
  String get loadingCustomers => 'Nilo-load ang mga customer...';

  @override
  String get payDebt => 'Bayaran ang Utang';

  @override
  String dueAmountLabel(String amount) {
    return 'Dapat bayaran: $amount SAR';
  }

  @override
  String get paymentAmountLabel => 'Halaga ng Bayad';

  @override
  String get fullAmount => 'Buo';

  @override
  String get payAction => 'Bayaran';

  @override
  String paymentRecorded(String amount) {
    return 'Naitala ang bayad na $amount SAR';
  }

  @override
  String get customerAddedSuccess => 'Matagumpay na naidagdag ang customer';

  @override
  String get customerNameRequired => 'Pangalan ng Customer *';

  @override
  String get owedLabel => 'May utang';

  @override
  String get hasBalanceLabel => 'Credit';

  @override
  String get zeroLabel => 'Zero';

  @override
  String get addAction => 'Idagdag';

  @override
  String get expenses => 'Mga Gastos';

  @override
  String get expenseCategories => 'Mga Kategorya ng Gastos';

  @override
  String get addExpense => 'Magdagdag ng Gastos';

  @override
  String get totalExpenses => 'Kabuuang Gastos';

  @override
  String get thisMonthExpenses => 'Ngayong Buwan';

  @override
  String get expenseAmount => 'Amount';

  @override
  String get expenseDate => 'Date';

  @override
  String get expenseCategory => 'Category';

  @override
  String get expenseNotes => 'Notes';

  @override
  String get noExpenses => 'Walang naitatalang gastos';

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
  String get shiftsTitle => 'Mga Shift';

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
  String get purchasesTitle => 'Mga Pagbili';

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
  String get suppliersTitle => 'Mga Supplier';

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
  String get discountsTitle => 'Mga Diskwento';

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
  String get couponsTitle => 'Mga Kupon';

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
  String get specialOffersTitle => 'Mga Espesyal na Alok';

  @override
  String get addOffer => 'Add Offer';

  @override
  String get offerName => 'Offer Name';

  @override
  String get offerStartDate => 'Start Date';

  @override
  String get offerEndDate => 'End Date';

  @override
  String get smartPromotionsTitle => 'Matalinong Promosyon';

  @override
  String get activePromotions => 'Active Promotions';

  @override
  String get suggestedPromotions => 'AI Suggestions';

  @override
  String get loyaltyTitle => 'Programa ng Katapatan';

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
  String get notificationsTitle => 'Mga Abiso';

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
  String get syncStatusTitle => 'Estado ng Sync';

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
  String get driversTitle => 'Mga Driver';

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
  String get branchesTitle => 'Mga Sangay';

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
  String get settingsTitle => 'Mga Setting';

  @override
  String get storeSettings => 'Mga Setting ng Tindahan';

  @override
  String get posSettings => 'Mga Setting ng POS';

  @override
  String get printerSettings => 'Mga Setting ng Printer';

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
  String get securitySettings => 'Seguridad';

  @override
  String get usersManagement => 'Pamamahala ng User';

  @override
  String get rolesPermissions => 'Mga Tungkulin at Pahintulot';

  @override
  String get activityLog => 'Log ng Aktibidad';

  @override
  String get backupSettings => 'Backup at Restore';

  @override
  String get notificationSettings => 'Notifications';

  @override
  String get zatcaCompliance => 'ZATCA Compliance';

  @override
  String get helpSupport => 'Tulong at Suporta';

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
  String get userGuide => 'Gabay ng Gumagamit';

  @override
  String get videoTutorials => 'Mga Video Tutorial';

  @override
  String get changelog => 'Changelog';

  @override
  String get appInfo => 'Impormasyon ng App';

  @override
  String get buildNumber => 'Build Number';

  @override
  String get notificationChannels => 'Mga Channel ng Notification';

  @override
  String get alertTypes => 'Mga Uri ng Alerto';

  @override
  String get salesAlerts => 'Mga Alerto sa Benta';

  @override
  String get inventoryAlerts => 'Mga Alerto sa Imbentaryo';

  @override
  String get securityAlerts => 'Mga Alerto sa Seguridad';

  @override
  String get reportAlerts => 'Mga Alerto sa Ulat';

  @override
  String get users => 'Mga Gumagamit';

  @override
  String get zatcaRegistered => 'Nakarehistro sa ZATCA';

  @override
  String get zatcaPhase2Active => 'Phase 2 Aktibo';

  @override
  String get registrationInfo => 'Impormasyon ng Pagpaparehistro';

  @override
  String get businessName => 'Pangalan ng Negosyo';

  @override
  String get branchCode => 'Code ng Sangay';

  @override
  String get qrCodeOnInvoice => 'QR Code sa Invoice';

  @override
  String get certificates => 'Mga Sertipiko';

  @override
  String get csidCertificate => 'CSID Certificate';

  @override
  String get valid => 'Valid';

  @override
  String get privateKey => 'Private Key';

  @override
  String get configured => 'Na-configure';

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
  String get aiInvestigation => 'Imbestigasyon';

  @override
  String get aiAssociationRules => 'Association Rules';

  @override
  String get aiBundleSuggestions => 'Mga Mungkahing Bundle';

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
  String get aiMarketPosition => 'Posisyon sa Merkado';

  @override
  String get aiQueryInput => 'Ask anything about your data...';

  @override
  String get aiReportTemplate => 'Report Template';

  @override
  String get aiStaffPerformance => 'Staff Performance';

  @override
  String get aiShiftOptimization => 'Pag-optimize ng Shift';

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
  String get noteOptional => 'Tala (opsyonal)';

  @override
  String get suspendInvoice => 'I-suspend ang Invoice';

  @override
  String get invoiceSuspended => 'Na-suspend ang invoice';

  @override
  String nItems(int count) {
    return '$count item(s)';
  }

  @override
  String saveSaleError(String error) {
    return 'Error sa pag-save ng benta: $error';
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
  String get copyCode => 'Kopyahin';

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
    return 'Validity: $days days';
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
  String get sortByAmount => 'By Amount';

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
  String get pasteCode => 'I-paste ang code';

  @override
  String devOtpMessage(String otp) {
    return 'Dev OTP: $otp';
  }

  @override
  String get orderHistory => 'سجل الطلبات';

  @override
  String get history => 'السجل';

  @override
  String get selectDateRange => 'تحديد فترة';

  @override
  String get orderSearchHint => 'بحث برقم الطلب أو معرف العميل...';

  @override
  String get noOrders => 'لا توجد طلبات';

  @override
  String get orderStatusConfirmed => 'مؤكد';

  @override
  String get orderStatusPreparing => 'قيد التحضير';

  @override
  String get orderStatusReady => 'جاهز';

  @override
  String get orderStatusDelivering => 'قيد التوصيل';

  @override
  String get filterOrders => 'فلترة الطلبات';

  @override
  String get channelApp => 'التطبيق';

  @override
  String get channelWhatsapp => 'واتساب';

  @override
  String get channelPos => 'نقطة البيع';

  @override
  String get paymentCashType => 'نقدي';

  @override
  String get paymentMixed => 'مختلط';

  @override
  String get paymentOnline => 'إلكتروني';

  @override
  String get shareAction => 'مشاركة';

  @override
  String get exportOrders => 'تصدير الطلبات';

  @override
  String get selectExportFormat => 'اختر صيغة التصدير';

  @override
  String get exportedAsExcel => 'تم التصدير كـ Excel';

  @override
  String get exportedAsPdf => 'تم التصدير كـ PDF';

  @override
  String get alertSettings => 'إعدادات التنبيهات';

  @override
  String get acknowledgeAll => 'تأكيد الكل';

  @override
  String allWithCount(int count) {
    return 'الكل ($count)';
  }

  @override
  String lowStockWithCount(int count) {
    return 'نفاد مخزون ($count)';
  }

  @override
  String expiryWithCount(int count) {
    return 'انتهاء صلاحية ($count)';
  }

  @override
  String get urgentAlerts => 'تنبيهات عاجلة';

  @override
  String get nearExpiry => 'قرب الانتهاء';

  @override
  String get noAlerts => 'لا توجد تنبيهات';

  @override
  String get alertDismissed => 'تم إخفاء التنبيه';

  @override
  String get undo => 'تراجع';

  @override
  String get criticalPriority => 'حرج';

  @override
  String get highPriority => 'عاجل';

  @override
  String stockAlertMessage(int current, int threshold) {
    return 'الكمية: $current (الحد الأدنى: $threshold)';
  }

  @override
  String get expiryAlertLabel => 'تنبيه صلاحية';

  @override
  String get currentQuantity => 'الكمية الحالية';

  @override
  String get minimumThreshold => 'الحد الأدنى';

  @override
  String get dismissAction => 'تجاهل';

  @override
  String get lowStockNotifications => 'تنبيهات نفاد المخزون';

  @override
  String get expiryNotifications => 'تنبيهات انتهاء الصلاحية';

  @override
  String get minimumStockLevel => 'الحد الأدنى للمخزون';

  @override
  String thresholdUnits(int count) {
    return '$count وحدة';
  }

  @override
  String get acknowledgeAllAlerts => 'تأكيد جميع التنبيهات';

  @override
  String willDismissAlerts(int count) {
    return 'سيتم إخفاء $count تنبيه';
  }

  @override
  String get allAlertsAcknowledged => 'تم تأكيد جميع التنبيهات';

  @override
  String get createPurchaseOrder => 'إنشاء طلب شراء';

  @override
  String productLabelName(String name) {
    return 'المنتج: $name';
  }

  @override
  String get requiredQuantity => 'الكمية المطلوبة';

  @override
  String get createAction => 'إنشاء';

  @override
  String get purchaseOrderCreated => 'تم إنشاء طلب الشراء';

  @override
  String get newCategory => 'فئة جديدة';

  @override
  String productCountUnit(int count) {
    return '$count منتج';
  }

  @override
  String get iconLabel => 'الأيقونة:';

  @override
  String get colorLabel => 'اللون:';

  @override
  String deleteCategoryMessage(String name, int count) {
    return 'هل تريد حذف فئة \"$name\"؟\nسيتم نقل $count منتج إلى \"بدون فئة\".';
  }

  @override
  String productNumber(int number) {
    return 'منتج $number';
  }

  @override
  String priceWithCurrency(String price) {
    return '$price ر.س';
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
    return '$productA + $productB: inulit $frequency beses';
  }

  @override
  String aiBundleActivated(String name) {
    return 'Na-activate ang bundle: $name';
  }

  @override
  String aiPromotionsGeneratedCount(int count) {
    return '$count promosyon ang nabuo batay sa pagsusuri ng data ng tindahan';
  }

  @override
  String aiPromotionApplied(String title) {
    return 'Inilapat: $title';
  }

  @override
  String aiConfidencePercent(String percent) {
    return 'Kumpiyansa: $percent%';
  }

  @override
  String aiAlertsWithCount(int count) {
    return 'Mga Alerto ($count)';
  }

  @override
  String aiStaffCurrentSuggested(int current, int suggested) {
    return '$current empleyado kasalukuyan → $suggested iminungkahi';
  }

  @override
  String aiMinutesAgo(int minutes) {
    return '$minutes minuto ang nakalipas';
  }

  @override
  String aiHoursAgo(int hours) {
    return '$hours oras ang nakalipas';
  }

  @override
  String aiDaysAgo(int days) {
    return '$days araw ang nakalipas';
  }

  @override
  String aiDetectedCount(int count) {
    return 'Na-detect: $count';
  }

  @override
  String aiMatchedCount(int count) {
    return 'Natugma: $count';
  }

  @override
  String aiAccuracyPercent(String percent) {
    return 'Katumpakan: $percent%';
  }

  @override
  String aiProductAccepted(String name) {
    return 'Tinanggap ang $name';
  }

  @override
  String aiErrorOccurred(String error) {
    return 'May naganap na error: $error';
  }

  @override
  String aiErrorWithMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get aiBasketAnalysis => 'AI Pagsusuri ng Basket';

  @override
  String get aiAssociations => 'Mga Kaugnayan';

  @override
  String get aiCrossSell => 'Cross-Sell';

  @override
  String get aiAvgBasketSize => 'Ave. Laki ng Basket';

  @override
  String get aiProductUnit => 'mga produkto';

  @override
  String get aiAvgBasketValue => 'Ave. Halaga ng Basket';

  @override
  String get aiSaudiRiyal => 'SAR';

  @override
  String get aiStrongestAssociation => 'Pinakamalakas na Kaugnayan';

  @override
  String get aiConversionRate => 'Rate ng Conversion';

  @override
  String get aiFromSuggestions => 'mula sa mga mungkahi';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get aiAskAboutStore =>
      'Magtanong ng kahit ano tungkol sa iyong tindahan';

  @override
  String get aiClearChat => 'Burahin ang Chat';

  @override
  String get aiAssistantReady => 'Handa na ang AI Assistant na tumulong!';

  @override
  String get aiAskAboutSalesStock =>
      'Magtanong tungkol sa benta, stock, customer, o kahit ano tungkol sa iyong tindahan';

  @override
  String get aiCompetitorAnalysis => 'Pagsusuri ng Kakumpitensya';

  @override
  String get aiPriceComparison => 'Paghahambing ng Presyo';

  @override
  String get aiTrackedProducts => 'Mga Sinusubaybayang Produkto';

  @override
  String get aiCheaperThanCompetitors => 'Mas mura kaysa sa kakumpitensya';

  @override
  String get aiMoreExpensive => 'Mas mahal kaysa sa kakumpitensya';

  @override
  String get aiAvgPriceDiff => 'Ave. Pagkakaiba ng Presyo';

  @override
  String get aiSortByName => 'Ayusin ayon sa pangalan';

  @override
  String get aiSortByPriceDiff => 'Ayusin ayon sa pagkakaiba ng presyo';

  @override
  String get aiSortByOurPrice => 'Ayusin ayon sa aming presyo';

  @override
  String get aiSortByCategory => 'Ayusin ayon sa kategorya';

  @override
  String get aiSortLabel => 'Ayusin';

  @override
  String get aiPriceIndex => 'Indeks ng Presyo';

  @override
  String get aiQuality => 'Kalidad';

  @override
  String get aiBranches => 'Mga Sangay';

  @override
  String get aiMarkAllRead => 'Markahan lahat bilang nabasa';

  @override
  String get aiNoAlertsCurrently => 'Walang mga alerto sa kasalukuyan';

  @override
  String get aiFraudDetection => 'AI Pagtukoy ng Panloloko';

  @override
  String get aiTotalAlerts => 'Kabuuang Alerto';

  @override
  String get aiCriticalAlerts => 'Mga Kritikal na Alerto';

  @override
  String get aiNeedsReview => 'Kailangan ng Pagsusuri';

  @override
  String get aiRiskLevel => 'Antas ng Panganib';

  @override
  String get aiBehaviorScores => 'Mga Iskor ng Gawi';

  @override
  String get aiRiskMeter => 'Panukat ng Panganib';

  @override
  String get aiHighRisk => 'Mataas na Panganib';

  @override
  String get aiLowRisk => 'Mababang Panganib';

  @override
  String get aiPatternRefund => 'Refund';

  @override
  String get aiPatternAfterHours => 'Pagkatapos ng Oras';

  @override
  String get aiPatternVoid => 'Void';

  @override
  String get aiPatternDiscount => 'Diskwento';

  @override
  String get aiPatternSplit => 'Hatiin';

  @override
  String get aiPatternCashDrawer => 'Cash Drawer';

  @override
  String get aiNoFraudAlerts => 'Walang mga alerto';

  @override
  String get aiSelectAlertToInvestigate =>
      'Pumili ng alerto mula sa listahan para imbestigahan';

  @override
  String get aiStaffAnalytics => 'Analytics ng Staff';

  @override
  String get aiLeaderboard => 'Leaderboard';

  @override
  String get aiIndividualPerformance => 'Indibidwal na Pagganap';

  @override
  String get aiAvgPerformance => 'Ave. Pagganap';

  @override
  String get aiTotalSalesLabel => 'Kabuuang Benta';

  @override
  String get aiTotalTransactions => 'Kabuuang Transaksyon';

  @override
  String get aiAvgVoidRate => 'Ave. Rate ng Void';

  @override
  String get aiTeamGrowth => 'Paglago ng Team';

  @override
  String get aiLeaderboardThisWeek => 'Leaderboard - Ngayong Linggo';

  @override
  String get aiSalesForecasting => 'Pagtataya ng Benta';

  @override
  String get aiSmartForecastSubtitle =>
      'Matalinong pagsusuri para sa pagtataya ng hinaharap na benta';

  @override
  String get aiForecastAccuracy => 'Katumpakan ng Pagtataya';

  @override
  String get aiTrendUp => 'Pataas';

  @override
  String get aiTrendDown => 'Pababa';

  @override
  String get aiTrendStable => 'Matatag';

  @override
  String get aiNextWeekForecast => 'Pagtataya sa Susunod na Linggo';

  @override
  String get aiMonthForecast => 'Pagtataya sa Buwan';

  @override
  String get aiForecastSummary => 'Buod ng Pagtataya';

  @override
  String get aiSalesTrendingUp => 'Pataas ang benta - ituloy mo!';

  @override
  String get aiSalesDeclining =>
      'Bumababa ang benta - mag-activate ng mga alok';

  @override
  String get aiSalesStable => 'Matatag ang benta - panatilihin ang pagganap';

  @override
  String get aiProductRecognition => 'Pagkilala sa Produkto';

  @override
  String get aiSingleProduct => 'Isang Produkto';

  @override
  String get aiShelfScan => 'Shelf Scan';

  @override
  String get aiBarcodeOcr => 'Barcode OCR';

  @override
  String get aiPriceTag => 'Tag ng Presyo';

  @override
  String get aiCameraArea => 'Lugar ng Camera';

  @override
  String get aiPointCameraAtProduct => 'Itutok ang camera sa produkto o shelf';

  @override
  String get aiStartScan => 'Simulan ang Scan';

  @override
  String get aiAnalyzingImage => 'Sinusuri ang larawan...';

  @override
  String get aiStartScanToSeeResults =>
      'Magsimulang mag-scan upang makita ang mga resulta';

  @override
  String get aiScanResults => 'Mga Resulta ng Scan';

  @override
  String get aiProductSaved => 'Matagumpay na na-save ang produkto';

  @override
  String get aiPromotionDesigner => 'AI Promotion Designer';

  @override
  String get aiSuggestedPromotions => 'Mga Iminungkahing Promosyon';

  @override
  String get aiRoiAnalysis => 'ROI Analysis';

  @override
  String get aiAbTest => 'A/B Test';

  @override
  String get aiSmartPromotionDesigner => 'Smart Promotion Designer';

  @override
  String get aiProjectedRevenue => 'Inaasahang Kita';

  @override
  String get aiAiConfidence => 'AI Confidence';

  @override
  String get aiSelectPromotionForRoi =>
      'Pumili ng promosyon mula sa unang tab upang makita ang ROI analysis';

  @override
  String get aiRevenueLabel => 'Kita';

  @override
  String get aiCostLabel => 'Gastos';

  @override
  String get aiDiscountLabel => 'Diskwento';

  @override
  String get aiAbTestDescription =>
      'Hinahati ng A/B test ang iyong mga customer sa dalawang grupo at nagpapakita ng magkaibang alok sa bawat grupo upang matukoy ang pinakamahusay.';

  @override
  String get aiAbTestLaunched => 'Matagumpay na na-launch ang A/B test!';

  @override
  String get aiChatWithData => 'Chat with Data - AI';

  @override
  String get aiChatWithYourData => 'Chat gamit ang iyong Data';

  @override
  String get aiAskAboutDataInArabic =>
      'Magtanong ng kahit ano tungkol sa iyong benta, stock, at mga customer';

  @override
  String get aiTrySampleQuestions => 'Subukan ang isa sa mga tanong na ito';

  @override
  String get aiTip => 'Tip';

  @override
  String get aiTipDescription =>
      'Maaari kang magtanong sa Filipino o Ingles. Naiintindihan ng AI ang konteksto at pipiliin ang pinakamahusay na paraan ng pagpapakita ng resulta: numero, talahanayan, o tsart.';

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
  String get pleaseSelectSupplier => 'Please select a supplier';

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
  String get supplierLabel => 'Supplier';

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
  String get orderSentSuccess => 'Order sent successfully';

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
    return '$count items';
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
  String get gotIt => 'فهمت';

  @override
  String get print => 'طباعة';

  @override
  String get display => 'عرض';

  @override
  String get item => 'عنصر';

  @override
  String get invoice => 'فاتورة';

  @override
  String get accept => 'قبول';

  @override
  String get details => 'تفاصيل';

  @override
  String get newLabel => 'جديد';

  @override
  String get mixed => 'مختلط';

  @override
  String get lowStockLabel => 'Mababa';

  @override
  String get debtor => 'مدين';

  @override
  String get creditor => 'دائن';

  @override
  String get balanceLabel => 'الرصيد';

  @override
  String get returnLabel => 'استرجاع';

  @override
  String get skip => 'تخطي';

  @override
  String get send => 'إرسال';

  @override
  String get cloud => 'سحابي';

  @override
  String get defaultLabel => 'افتراضي';

  @override
  String get closed => 'مغلق';

  @override
  String get owes => 'عليه';

  @override
  String get due => 'له';

  @override
  String get balanced => 'متوازن';

  @override
  String get offlineModeTitle => 'الوضع غير المتصل';

  @override
  String get offlineModeDescription => 'يمكنك الاستمرار في استخدام التطبيق:';

  @override
  String get offlineCanSell => 'إجراء عمليات البيع';

  @override
  String get offlineCanAddToCart => 'إضافة منتجات للسلة';

  @override
  String get offlineCanPrint => 'طباعة الإيصالات';

  @override
  String get offlineAutoSync =>
      'سيتم مزامنة البيانات تلقائياً عند عودة الاتصال.';

  @override
  String get offlineSavingLocally => 'غير متصل - يتم حفظ العمليات محلياً';

  @override
  String get seconds => 'ثانية';

  @override
  String get errors => 'أخطاء';

  @override
  String get syncLabel => 'مزامنة';

  @override
  String get slow => 'بطيئة';

  @override
  String get myGrocery => 'بقالتي';

  @override
  String get cashier => 'كاشير';

  @override
  String get goBack => 'رجوع';

  @override
  String get menuLabel => 'القائمة';

  @override
  String get gold => 'ذهبي';

  @override
  String get silver => 'فضي';

  @override
  String get diamond => 'ماسي';

  @override
  String get bronze => 'برونزي';

  @override
  String get saudiArabia => 'السعودية';

  @override
  String get uae => 'الإمارات';

  @override
  String get kuwait => 'الكويت';

  @override
  String get bahrain => 'البحرين';

  @override
  String get qatar => 'قطر';

  @override
  String get oman => 'عُمان';

  @override
  String get control => 'تحكم';

  @override
  String get strong => 'قوي';

  @override
  String get medium => 'متوسط';

  @override
  String get weak => 'ضعيف';

  @override
  String get good => 'جيد';

  @override
  String get danger => 'خطر';

  @override
  String get currentLabel => 'الحالي';

  @override
  String get suggested => 'المقترح';

  @override
  String get actual => 'الفعلي';

  @override
  String get forecast => 'المتوقع';

  @override
  String get critical => 'حرج';

  @override
  String get high => 'عالي';

  @override
  String get low => 'منخفض';

  @override
  String get investigation => 'التحقيق';

  @override
  String get apply => 'تطبيق';

  @override
  String get run => 'تشغيل';

  @override
  String get positive => 'إيجابي';

  @override
  String get neutral => 'محايد';

  @override
  String get negative => 'سلبي';

  @override
  String get elastic => 'مرن';

  @override
  String get demand => 'الطلب';

  @override
  String get quality => 'الجودة';

  @override
  String get luxury => 'فاخر';

  @override
  String get economic => 'اقتصادي';

  @override
  String get ourStore => 'متجرنا';

  @override
  String get upcoming => 'قادم';

  @override
  String get cost => 'التكلفة';

  @override
  String get duration => 'المدة';

  @override
  String get quiet => 'هادئ';

  @override
  String get busy => 'مزدحم';

  @override
  String get outstanding => 'متميز';

  @override
  String get donate => 'تبرع';

  @override
  String get day => 'يوم';

  @override
  String get days => 'أيام';

  @override
  String get projected => 'المتوقع';

  @override
  String get analysis => 'تحليل';

  @override
  String get review => 'مراجعة';

  @override
  String get productCategory => 'التصنيف';

  @override
  String get ourPrice => 'سعرنا';

  @override
  String get position => 'الموقف';

  @override
  String get cheapest => 'الأرخص';

  @override
  String get mostExpensive => 'الأغلى';

  @override
  String get soldOut => 'Sold Out';

  @override
  String get noDataAvailable => 'لا توجد بيانات';

  @override
  String get noDataFoundMessage => 'لم يتم العثور على أي بيانات';

  @override
  String get noSearchResultsFound => 'لا توجد نتائج';

  @override
  String get noProductsFound => 'لم يتم العثور على منتجات';

  @override
  String get noCustomers => 'لا يوجد عملاء';

  @override
  String get addCustomersToStart => 'أضف عملاء جدد للبدء';

  @override
  String get noOrdersYet => 'لم تقم بأي طلبات بعد';

  @override
  String get noConnection => 'لا يوجد اتصال';

  @override
  String get checkInternet => 'تحقق من اتصالك بالإنترنت';

  @override
  String get cartIsEmpty => 'السلة فارغة';

  @override
  String get browseProducts => 'تصفح المنتجات';

  @override
  String noResultsFor(String query) {
    return 'لم يتم العثور على نتائج لـ \"$query\"';
  }

  @override
  String get paidLabel => 'المدفوع';

  @override
  String get remainingLabel => 'المتبقي';

  @override
  String get completeLabel => 'مكتمل ✓';

  @override
  String get addPayment => 'إضافة';

  @override
  String get payments => 'الدفعات';

  @override
  String get now => 'Ngayon';

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
  String get averageInvoice => 'متوسط الفاتورة';

  @override
  String errorPrefix(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get vipMember => 'عضو VIP';

  @override
  String get activeSuppliers => 'موردين نشطين';

  @override
  String get duePayments => 'المستحقات';

  @override
  String get productCatalog => 'كتالوج المنتجات';

  @override
  String get comingSoonBrowseSuppliers => 'قريباً - تصفح منتجات الموردين';

  @override
  String get comingSoonTag => 'قريباً';

  @override
  String get supplierNotFound => 'لم يتم العثور على المورد';

  @override
  String get viewAllPurchases => 'عرض جميع المشتريات';

  @override
  String get completedLabel => 'مكتمل';

  @override
  String get pendingStatusLabel => 'معلق';

  @override
  String get registerPayment => 'تسجيل دفعة للمورد';

  @override
  String errorLoadingSuppliers(Object error) {
    return 'خطأ في تحميل الموردين: $error';
  }

  @override
  String get cancelLabel => 'إلغاء';

  @override
  String get addLabel => 'إضافة';

  @override
  String get saveLabel => 'حفظ';

  @override
  String purchaseInvoiceSaved(Object total) {
    return 'تم حفظ فاتورة الشراء - الإجمالي: $total ر.س';
  }

  @override
  String errorSavingPurchase(Object error) {
    return 'خطأ في حفظ المشتريات: $error';
  }

  @override
  String get smartReorderTitle => 'الطلب الذكي';

  @override
  String get smartReorderAiTitle => 'الطلب الذكي بالـ AI';

  @override
  String get budgetDescription =>
      'حدد الميزانية وسيقوم النظام بتوزيعها على المنتجات حسب معدل الدوران';

  @override
  String get enterValidBudget => 'الرجاء إدخال ميزانية صحيحة';

  @override
  String get confirmSendTitle => 'تأكيد الإرسال';

  @override
  String sendOrderToMsg(Object supplier) {
    return 'إرسال الطلب إلى $supplier؟';
  }

  @override
  String get orderSentSuccessMsg => 'تم إرسال الطلب بنجاح';

  @override
  String sendingOrderVia(Object method) {
    return 'جاري إرسال الطلب عبر $method...';
  }

  @override
  String stockQuantity(Object qty) {
    return 'المخزون: $qty';
  }

  @override
  String turnoverLabel(Object rate) {
    return 'الدوران: $rate%';
  }

  @override
  String failedCapture(Object error) {
    return 'فشل في التقاط الصورة: $error';
  }

  @override
  String failedPickImage(Object error) {
    return 'فشل في اختيار الصورة: $error';
  }

  @override
  String failedProcessInvoice(Object error) {
    return 'فشل في معالجة الفاتورة: $error';
  }

  @override
  String matchLabel(Object name) {
    return 'مطابقة: $name';
  }

  @override
  String suggestedProduct(Object index) {
    return 'منتج مقترح $index';
  }

  @override
  String get barcodeLabel => 'باركود: 123456789';

  @override
  String get purchaseInvoiceSavedSuccess => 'تم حفظ فاتورة الشراء بنجاح';

  @override
  String get aiImportedInvoice => 'فاتورة مستوردة بالذكاء الاصطناعي';

  @override
  String aiInvoiceNote(Object number) {
    return 'فاتورة AI: $number';
  }

  @override
  String get supplierCanCreateOrders => 'يمكن إنشاء طلبات شراء من هذا المورد';

  @override
  String get notesFieldHint => 'أي ملاحظات إضافية عن المورد...';

  @override
  String get deleteConfirmCancel => 'إلغاء';

  @override
  String get deleteConfirmBtn => 'حذف';

  @override
  String get supplierUpdatedMsg => 'تم تحديث بيانات المورد';

  @override
  String errorOccurredMsg(Object error) {
    return 'حدث خطأ: $error';
  }

  @override
  String errorDuringDeleteMsg(Object error) {
    return 'حدث خطأ أثناء الحذف: $error';
  }

  @override
  String get fortyFiveDays => '45 يوم';

  @override
  String get expenseCategoriesTitle => 'فئات المصروفات';

  @override
  String get noCategoriesFound => 'لا توجد فئات مصروفات';

  @override
  String get monthlyBudget => 'الميزانية الشهرية';

  @override
  String get spentAmount => 'المصروف';

  @override
  String get remainingAmount => 'المتبقي';

  @override
  String get overBudget => 'تجاوز';

  @override
  String expenseCount(Object count) {
    return '$count مصروف';
  }

  @override
  String spentLabel(Object amount) {
    return 'المصروف: $amount ر.س';
  }

  @override
  String remainingLabel2(Object amount) {
    return 'المتبقي: $amount ر.س';
  }

  @override
  String expensesThisMonth(Object count) {
    return '$count مصروف هذا الشهر';
  }

  @override
  String get recentExpenses => 'آخر المصروفات';

  @override
  String expenseNumber(Object id) {
    return 'مصروف #$id';
  }

  @override
  String get budgetLabel => 'الميزانية';

  @override
  String get monthlyBudgetLabel => 'الميزانية الشهرية';

  @override
  String get categoryNameHint => 'مثال: رواتب الموظفين';

  @override
  String get productNameLabel => 'اسم المنتج *';

  @override
  String get quantityLabel => 'الكمية';

  @override
  String get purchasePriceLabel => 'سعر الشراء';

  @override
  String get saveInvoiceBtn => 'حفظ الفاتورة';

  @override
  String get ibanLabel => 'رقم الحساب IBAN';

  @override
  String get supplierActiveLabel => 'المورد نشط';

  @override
  String get notesLabel => 'ملاحظات';

  @override
  String get deleteSupplierConfirm =>
      'هل أنت متأكد من حذف هذا المورد؟ سيتم حذف جميع البيانات المرتبطة به.';

  @override
  String get supplierDeletedMsg => 'تم حذف المورد';

  @override
  String get savingLabel => 'جاري الحفظ...';

  @override
  String get supplierDetailTitle => 'تفاصيل المورد';

  @override
  String get supplierNotFoundMsg => 'لم يتم العثور على المورد';

  @override
  String get lastPurchaseLabel => 'آخر عملية شراء';

  @override
  String get recentPurchasesLabel => 'آخر المشتريات';

  @override
  String get noPurchasesLabel => 'لا توجد مشتريات بعد';

  @override
  String get supplierAddedMsg => 'تم إضافة المورد';

  @override
  String get openingCashLabel => 'النقدية الافتتاحية';

  @override
  String get importantNotes => 'ملاحظات مهمة';

  @override
  String get countCashBeforeShift =>
      'تأكد من عد النقدية في الصندوق قبل فتح الوردية';

  @override
  String get shiftTimeAutoRecorded => 'سيتم تسجيل وقت فتح الوردية تلقائياً';

  @override
  String get oneShiftAtATime => 'لا يمكن فتح أكثر من وردية في نفس الوقت';

  @override
  String get pleaseEnterOpeningCash =>
      'يرجى إدخال مبلغ النقدية الافتتاحية (أكبر من صفر)';

  @override
  String shiftOpenedWithAmount(String amount, String currency) {
    return 'تم فتح الوردية بمبلغ $amount $currency';
  }

  @override
  String get errorOpeningShift => 'خطأ في فتح الوردية';

  @override
  String get noOpenShift => 'لا توجد وردية مفتوحة';

  @override
  String get shiftInfoLabel => 'معلومات الوردية';

  @override
  String get salesSummaryLabel => 'ملخص المبيعات';

  @override
  String get cashRefundsLabel => 'مرتجعات نقدية';

  @override
  String get cashDepositLabel => 'إدخال نقدي';

  @override
  String get cashWithdrawalLabel => 'سحب نقدي';

  @override
  String get expectedInDrawer => 'المتوقع في الصندوق';

  @override
  String get actualCashInDrawer => 'النقدية الفعلية في الصندوق';

  @override
  String get drawerMatched => 'متطابق';

  @override
  String get surplusStatus => 'فائض';

  @override
  String get deficitStatus => 'عجز';

  @override
  String expectedAmountCurrency(String amount, String currency) {
    return 'المتوقع: $amount $currency';
  }

  @override
  String actualAmountCurrency(String amount, String currency) {
    return 'الفعلي: $amount $currency';
  }

  @override
  String get drawerMatchedMessage => 'الصندوق متطابق';

  @override
  String surplusAmount(String amount, String currency) {
    return 'فائض: +$amount $currency';
  }

  @override
  String deficitAmount(String amount, String currency) {
    return 'عجز: $amount $currency';
  }

  @override
  String get confirmCloseShift => 'هل تريد إغلاق الوردية؟';

  @override
  String get errorClosingShift => 'خطأ في إغلاق الوردية';

  @override
  String get shiftClosedSuccessfully => 'تم إغلاق الوردية بنجاح';

  @override
  String get shiftStatsLabel => 'إحصائيات الوردية';

  @override
  String get shiftDurationLabel => 'مدة الوردية';

  @override
  String get invoiceCountLabel => 'عدد الفواتير';

  @override
  String get invoiceUnit => 'فاتورة';

  @override
  String get cardSalesLabel => 'مبيعات بطاقة';

  @override
  String get cashSalesLabel => 'مبيعات نقدية';

  @override
  String get refundsLabel => 'المرتجعات';

  @override
  String get expectedInDrawerLabel => 'المتوقع في الصندوق';

  @override
  String get actualInDrawerLabel => 'الفعلي في الصندوق';

  @override
  String get differenceLabel => 'الفرق';

  @override
  String get printingReport => 'جاري طباعة التقرير...';

  @override
  String get sharingInProgress => 'جاري المشاركة...';

  @override
  String get openNewShift => 'فتح وردية جديدة';

  @override
  String hoursAndMinutes(int hours, int minutes) {
    return '$hours ساعات $minutes دقيقة';
  }

  @override
  String hoursOnly(int hours) {
    return '$hours ساعات';
  }

  @override
  String minutesOnly(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get rejectedNotApproved => 'تم رفض العملية - لم تتم الموافقة';

  @override
  String errorWithDetails(String error) {
    return 'خطأ: $error';
  }

  @override
  String get inventoryManagement => 'إدارة ومتابعة المخزون';

  @override
  String get bulkEdit => 'تعديل جماعي';

  @override
  String get totalProducts => 'إجمالي المنتجات';

  @override
  String get inventoryValue => 'قيمة المخزون';

  @override
  String get exportInventoryReport => 'تصدير تقرير المخزون';

  @override
  String get printOrderList => 'طباعة قائمة الطلب';

  @override
  String get inventoryMovementLog => 'سجل حركة المخزون';

  @override
  String get editSelected => 'تعديل المحدد';

  @override
  String get clearSelection => 'إلغاء التحديد';

  @override
  String get noOutOfStockProducts => 'لا يوجد منتجات نفذت';

  @override
  String get allProductsAvailable => 'جميع المنتجات متوفرة في المخزون';

  @override
  String get editStock => 'تعديل المخزون';

  @override
  String get newQuantity => 'الكمية الجديدة';

  @override
  String get receiveGoods => 'استلام بضاعة';

  @override
  String get damaged => 'تالف';

  @override
  String get correction => 'تصحيح';

  @override
  String get stockUpdatedTo => 'تم تعديل مخزون';

  @override
  String get featureUnderDevelopment => 'هذه الميزة قيد التطوير...';

  @override
  String get newest => 'الأحدث';

  @override
  String get adjustStock => 'تعديل المخزون';

  @override
  String get adjustmentHistory => 'سجل التعديلات';

  @override
  String get errorLoadingProducts => 'حدث خطأ أثناء تحميل المنتجات';

  @override
  String get selectProduct => 'اختيار المنتج';

  @override
  String get subtract => 'خصم';

  @override
  String get setQuantity => 'تعيين';

  @override
  String get enterQuantity => 'أدخل الكمية';

  @override
  String get enterValidQuantity => 'أدخل كمية صحيحة';

  @override
  String get notesOptional => 'ملاحظات (اختياري)';

  @override
  String get enterAdditionalNotes => 'أدخل أي ملاحظات إضافية...';

  @override
  String get adjustmentSummary => 'ملخص التعديل';

  @override
  String get newStock => 'المخزون الجديد';

  @override
  String get warningNegativeStock => 'تحذير: المخزون سيصبح سالباً!';

  @override
  String get saving => 'جاري الحفظ...';

  @override
  String get storeNotSelected => 'لم يتم تحديد المتجر';

  @override
  String get noInventoryMovements => 'لا توجد حركات مخزون';

  @override
  String get adjustmentSavedSuccess => 'تم حفظ التعديل بنجاح';

  @override
  String get errorSaving => 'حدث خطأ أثناء الحفظ';

  @override
  String get enterBarcode => 'أدخل الباركود';

  @override
  String get theft => 'سرقة';

  @override
  String get noMatchingProducts => 'لا توجد منتجات مطابقة';

  @override
  String get stockTransfer => 'تحويل المخزون';

  @override
  String get newTransfer => 'تحويل جديد';

  @override
  String get fromBranch => 'من فرع';

  @override
  String get toBranch => 'إلى فرع';

  @override
  String get selectSourceBranch => 'اختر الفرع المصدر';

  @override
  String get selectTargetBranch => 'اختر الفرع الهدف';

  @override
  String get selectProductsForTransfer => 'اختر منتجات للتحويل';

  @override
  String get creating => 'جاري الإنشاء...';

  @override
  String get createTransferRequest => 'إنشاء طلب التحويل';

  @override
  String get errorLoadingTransfers => 'خطأ في تحميل التحويلات';

  @override
  String get noPreviousTransfers => 'لا توجد تحويلات سابقة';

  @override
  String get approved => 'موافق عليه';

  @override
  String get inTransit => 'قيد النقل';

  @override
  String get complete => 'إكمال';

  @override
  String get completeTransfer => 'إكمال التحويل';

  @override
  String get completeTransferConfirm =>
      'هل تريد إكمال هذا التحويل؟ سيتم خصم الكميات من الفرع المصدر وإضافتها للفرع الهدف.';

  @override
  String get transferCompletedSuccess => 'تم إكمال التحويل وتحديث المخزون';

  @override
  String get errorCompletingTransfer => 'خطأ في إكمال التحويل';

  @override
  String get transferCreatedSuccess => 'تم إنشاء طلب التحويل بنجاح';

  @override
  String get errorCreatingTransfer => 'خطأ في إنشاء التحويل';

  @override
  String get stockTake => 'الجرد';

  @override
  String get startStockTake => 'بدء الجرد';

  @override
  String get counted => 'تم عدها';

  @override
  String get variances => 'فروقات';

  @override
  String get of_ => 'من';

  @override
  String get system => 'النظام';

  @override
  String get count => 'العدد';

  @override
  String get finishStockTake => 'إنهاء الجرد';

  @override
  String get stockTakeDescription => 'قم بعد منتجات المخزون ومقارنتها بالنظام';

  @override
  String get noProductsInStock => 'لا توجد منتجات في المخزون';

  @override
  String get noProductsToCount => 'لا توجد منتجات لبدء الجرد';

  @override
  String get errorCreatingStockTake => 'خطأ في إنشاء عملية الجرد';

  @override
  String get saveStockTakeConfirm => 'هل تريد حفظ نتائج الجرد وتحديث المخزون؟';

  @override
  String get stockTakeSavedSuccess => 'تم حفظ الجرد وتحديث المخزون بنجاح';

  @override
  String get errorCompletingStockTake => 'خطأ في إكمال الجرد';

  @override
  String get stockTakeHistory => 'سجل الجرد';

  @override
  String get errorLoadingHistory => 'خطأ في تحميل السجل';

  @override
  String get noStockTakeHistory => 'لا يوجد سجل جرد سابق';

  @override
  String get inProgress => 'قيد التنفيذ';

  @override
  String get expiryTracking => 'تتبع الصلاحية';

  @override
  String get errorLoadingExpiryData => 'خطأ في تحميل بيانات الصلاحية';

  @override
  String get withinMonth => 'خلال شهر';

  @override
  String get noProductsExpiringIn7Days => 'لا توجد منتجات تنتهي خلال 7 أيام';

  @override
  String get noProductsExpiringInMonth => 'لا توجد منتجات تنتهي خلال شهر';

  @override
  String get noExpiredProducts => 'لا توجد منتجات منتهية الصلاحية';

  @override
  String get batch => 'باتش';

  @override
  String expiredSinceDays(int days) {
    return 'منتهي منذ $days يوم';
  }

  @override
  String get remove => 'إزالة';

  @override
  String get pressToAddExpiryTracking => 'اضغط + لإضافة تتبع صلاحية جديد';

  @override
  String get applyDiscountTo => 'تطبيق خصم على';

  @override
  String get confirmRemoval => 'تأكيد الإزالة';

  @override
  String get removeExpiryTrackingFor => 'هل تريد إزالة تتبع صلاحية';

  @override
  String get expiryTrackingRemoved => 'تم إزالة تتبع الصلاحية';

  @override
  String get errorRemovingExpiryTracking => 'خطأ في إزالة تتبع الصلاحية';

  @override
  String get addExpiryDate => 'إضافة تاريخ صلاحية';

  @override
  String get barcodeOrProductName => 'الباركود أو اسم المنتج';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get batchNumberOptional => 'رقم الباتش (اختياري)';

  @override
  String get expiryTrackingAdded => 'تم إضافة تتبع الصلاحية بنجاح';

  @override
  String get errorAddingExpiryTracking => 'خطأ في إضافة تتبع الصلاحية';

  @override
  String get barcodeScanner2 => 'ماسح الباركود';

  @override
  String get scanning => 'جاري المسح...';

  @override
  String get pressToStart => 'اضغط للبدء';

  @override
  String get stop => 'إيقاف';

  @override
  String get startScanning => 'بدء المسح';

  @override
  String get enterBarcodeManually => 'أدخل الباركود يدوياً';

  @override
  String get noScannedProducts => 'لم يتم مسح أي منتج';

  @override
  String get enterBarcodeToSearch => 'أدخل باركود للبحث في قاعدة البيانات';

  @override
  String get useManualInputToSearch =>
      'استخدم الإدخال اليدوي للبحث عن المنتجات';

  @override
  String get found => 'تم العثور على';

  @override
  String get productNotFoundForBarcode => 'لم يتم العثور على المنتج';

  @override
  String get addNewProduct => 'إضافة منتج جديد';

  @override
  String get willOpenAddProductScreen => 'سيتم فتح شاشة إضافة منتج جديد';

  @override
  String get scanHistory => 'سجل المسح';

  @override
  String get addedToCart => 'تمت إضافة';

  @override
  String get barcodePrint => 'طباعة الباركود';

  @override
  String get noProductsWithBarcode => 'لا توجد منتجات بباركود';

  @override
  String get addBarcodeFirst => 'أضف باركود للمنتجات أولاً';

  @override
  String get searchProduct => 'بحث عن منتج...';

  @override
  String get totalLabels => 'إجمالي الملصقات';

  @override
  String get printLabels => 'طباعة الملصقات';

  @override
  String get printList => 'قائمة الطباعة';

  @override
  String get selectProductsToPrint => 'اختر منتجات للطباعة';

  @override
  String get willPrint => 'سيتم طباعة';

  @override
  String get label => 'ملصق';

  @override
  String get printing => 'جاري الطباعة...';

  @override
  String get messageAddedToQueue => 'تم إضافة الرسالة لطابور الإرسال';

  @override
  String get messageSendFailed => 'تعذر إرسال الرسالة';

  @override
  String get noPhoneForCustomer => 'لا يوجد رقم هاتف للعميل';

  @override
  String get inputContainsDangerousContent =>
      'المدخل يحتوي على محتوى غير مسموح';

  @override
  String whatsappGreeting(String name) {
    return 'مرحباً $name\nكيف يمكننا مساعدتك؟';
  }

  @override
  String get segmentVip => 'VIP';

  @override
  String get segmentRegular => 'منتظم';

  @override
  String get segmentAtRisk => 'معرض للخسارة';

  @override
  String get segmentLost => 'مفقود';

  @override
  String get segmentNewCustomer => 'جديد';

  @override
  String customerCount(int count) {
    return '$count customer';
  }

  @override
  String revenueK(String amount) {
    return '${amount}K ر.س';
  }

  @override
  String get tabRecommendations => 'التوصيات';

  @override
  String get tabRepurchase => 'إعادة الشراء';

  @override
  String get tabSegments => 'الشرائح';

  @override
  String lastVisitLabel(String time) {
    return 'آخر زيارة: $time';
  }

  @override
  String visitCountLabel(int count) {
    return '$count زيارة';
  }

  @override
  String avgSpendLabel(String amount) {
    return 'متوسط: $amount ر.س';
  }

  @override
  String totalSpentLabel(String amount) {
    return 'إجمالي: ${amount}K ر.س';
  }

  @override
  String get recommendedProducts => 'المنتجات الموصى بها';

  @override
  String get sendWhatsAppOffer => 'إرسال عرض واتساب';

  @override
  String get totalRevenueLabel => 'إجمالي الإيراد';

  @override
  String get avgSpendStat => 'متوسط الإنفاق';

  @override
  String amountSar(String amount) {
    return '$amount ر.س';
  }

  @override
  String get specialOfferMissYou => 'عرض خاص لك! اشتقنا لزيارتك';

  @override
  String friendlyReminderPurchase(String product) {
    return 'تذكير ودي بموعد شراء $product';
  }

  @override
  String get timeAgoToday => 'اليوم';

  @override
  String get timeAgoYesterday => 'أمس';

  @override
  String timeAgoDays(int days) {
    return 'منذ $days يوم';
  }

  @override
  String get riskAnalysisTab => 'تحليل المخاطر';

  @override
  String get preventiveActionsTab => 'إجراءات وقائية';

  @override
  String errorOccurredDetail(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String get returnRateTitle => 'معدل الإرجاع';

  @override
  String get avgLast6Months => 'متوسط آخر 6 أشهر';

  @override
  String get amountAtRiskTitle => 'مبلغ معرض للخطر';

  @override
  String get highRiskOperations => 'عمليات عالية الخطر';

  @override
  String get needsImmediateAction => 'تحتاج تدخل فوري';

  @override
  String get returnTrendTitle => 'اتجاه المرتجعات';

  @override
  String operationsAtRiskCount(int count) {
    return 'العمليات المعرضة للإرجاع ($count)';
  }

  @override
  String get riskFilterAll => 'الكل';

  @override
  String get riskFilterVeryHigh => 'عالي جداً';

  @override
  String get riskFilterHigh => 'عالي';

  @override
  String get riskFilterMedium => 'متوسط';

  @override
  String get riskFilterLow => 'منخفض';

  @override
  String get totalExpectedSavings => 'إجمالي التوفير المتوقع';

  @override
  String fromPreventiveActions(int count) {
    return 'من $count إجراء وقائي';
  }

  @override
  String get suggestedPreventiveActions => 'الإجراءات الوقائية المقترحة';

  @override
  String get applyPreventiveHint =>
      'طبّق هذه الإجراءات لتقليل المرتجعات وزيادة رضا العملاء';

  @override
  String actionApplied(String action) {
    return 'تم تطبيق: $action';
  }

  @override
  String actionDismissed(String action) {
    return 'تم تجاهل: $action';
  }

  @override
  String get veryPositiveSentiment => 'إيجابي جداً';

  @override
  String get positiveSentiment => 'إيجابي';

  @override
  String get neutralSentiment => 'محايد';

  @override
  String get negativeSentiment => 'سلبي';

  @override
  String get veryNegativeSentiment => 'سلبي جداً';

  @override
  String get ratingsDistribution => 'توزيع التقييمات';

  @override
  String get sentimentTrendTitle => 'اتجاه المشاعر';

  @override
  String get sentimentIndicator => 'مؤشر المشاعر';

  @override
  String minutesAgoSentiment(int count) {
    return 'منذ $count دقيقة';
  }

  @override
  String hoursAgoSentiment(int count) {
    return 'منذ $count ساعة';
  }

  @override
  String daysAgoSentiment(int count) {
    return 'منذ $count يوم';
  }

  @override
  String get totalProductsTitle => 'إجمالي المنتجات';

  @override
  String get categoryATitle => 'فئة أ';

  @override
  String get mostImportant => 'الأكثر أهمية';

  @override
  String get withinDays => 'خلال 7 أيام';

  @override
  String get needReorder => 'بحاجة لطلب';

  @override
  String estimatedLossSar(String amount) {
    return '$amount ر.س خسائر متوقعة';
  }

  @override
  String get tabAbcAnalysis => 'تحليل ABC';

  @override
  String get tabWastePrediction => 'توقع الهدر';

  @override
  String get tabReorder => 'إعادة الطلب';

  @override
  String get filterAllLabel => 'الكل';

  @override
  String get categoryALabel => 'فئة أ';

  @override
  String get categoryBLabel => 'فئة ب';

  @override
  String get categoryCLabel => 'فئة ج';

  @override
  String orderUnitsSnack(int qty, String name) {
    return 'طلب $qty وحدة من $name';
  }

  @override
  String get urgencyCritical => 'حرج';

  @override
  String get urgencyHigh => 'عالي';

  @override
  String get urgencyMedium => 'متوسط';

  @override
  String get urgencyLow => 'منخفض';

  @override
  String get currentStockLabel => 'المخزون الحالي';

  @override
  String get reorderPointLabel => 'نقطة الطلب';

  @override
  String get suggestedQtyLabel => 'الكمية المقترحة';

  @override
  String get daysOfStockLabel => 'أيام المخزون';

  @override
  String estimatedCostLabel(String amount) {
    return 'التكلفة التقديرية: $amount ر.س';
  }

  @override
  String purchaseOrderCreatedFor(String name) {
    return 'تم إنشاء طلب شراء: $name';
  }

  @override
  String orderUnitsButton(int qty) {
    return 'طلب $qty وحدة';
  }

  @override
  String get actionDiscount => 'تخفيض';

  @override
  String get actionTransfer => 'نقل';

  @override
  String get actionDonate => 'تبرع';

  @override
  String actionOnProduct(String name) {
    return 'إجراء على: $name';
  }

  @override
  String get totalSuggestionsLabel => 'إجمالي الاقتراحات';

  @override
  String get canIncreaseLabel => 'يمكن زيادتها';

  @override
  String get shouldDecreaseLabel => 'يُنصح بخفضها';

  @override
  String get expectedMonthlyImpact => 'التأثير الشهري المتوقع';

  @override
  String get noSuggestionsInFilter => 'لا توجد اقتراحات في هذا الفلتر';

  @override
  String get selectProductForDetails => 'اختر منتجاً لعرض التفاصيل';

  @override
  String get selectProductHint =>
      'انقر على أحد المنتجات من القائمة لعرض حاسبة التأثير ومرونة الطلب';

  @override
  String priceApplied(String price, String product) {
    return 'تم تطبيق السعر $price ر.س على $product';
  }

  @override
  String errorOccurredShort(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String get readyTemplates => 'القوالب الجاهزة';

  @override
  String get hideTemplates => 'إخفاء القوالب';

  @override
  String get showTemplates => 'عرض القوالب';

  @override
  String get askAboutStore => 'اسأل أي سؤال عن متجرك';

  @override
  String get writeQuestionHint =>
      'اكتب سؤالك بالعربية وسنولد لك التقرير المناسب تلقائياً';

  @override
  String get quickActionTodaySales => 'كم مبيعات اليوم؟';

  @override
  String get quickActionTop10 => 'أفضل 10 منتجات';

  @override
  String get quickActionMonthlyCompare => 'مقارنة شهرية';

  @override
  String get analyzingData => 'جاري تحليل البيانات وتوليد التقرير...';

  @override
  String get profileScreenTitle => 'الملف الشخصي';

  @override
  String get unknownUserName => 'غير معروف';

  @override
  String get defaultEmployeeRole => 'موظف';

  @override
  String get transactionUnit => 'عملية';

  @override
  String get dayUnit => 'يوم';

  @override
  String get emailFieldLabel => 'البريد الإلكتروني';

  @override
  String get phoneFieldLabel => 'الهاتف';

  @override
  String get branchFieldLabel => 'الفرع';

  @override
  String get mainBranchName => 'الفرع الرئيسي';

  @override
  String get employeeNumberLabel => 'الرقم الوظيفي';

  @override
  String get changePasswordLabel => 'تغيير كلمة المرور';

  @override
  String get activityLogLabel => 'سجل النشاط';

  @override
  String get logoutDialogTitle => 'تسجيل الخروج';

  @override
  String get logoutDialogBody => 'هل تريد تسجيل الخروج من النظام؟';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get exitButton => 'خروج';

  @override
  String get editProfileSnack => 'تعديل الملف الشخصي';

  @override
  String get changePasswordSnack => 'تغيير كلمة المرور';

  @override
  String get roleAdmin => 'مدير النظام';

  @override
  String get roleManager => 'مدير';

  @override
  String get roleCashier => 'كاشير';

  @override
  String get roleEmployee => 'موظف';

  @override
  String get onboardingTitle1 => 'نقطة بيع سريعة';

  @override
  String get onboardingDesc1 =>
      'أتمم عمليات البيع بسرعة وسهولة مع واجهة بسيطة ومريحة';

  @override
  String get onboardingTitle2 => 'العمل بدون إنترنت';

  @override
  String get onboardingDesc2 =>
      'استمر في العمل حتى بدون اتصال، وستتم المزامنة تلقائياً';

  @override
  String get onboardingTitle3 => 'إدارة المخزون';

  @override
  String get onboardingDesc3 => 'تتبع مخزونك بدقة مع تنبيهات النقص والصلاحية';

  @override
  String get onboardingTitle4 => 'تقارير ذكية';

  @override
  String get onboardingDesc4 => 'احصل على تقارير مفصلة وتحليلات لأداء متجرك';

  @override
  String get startNow => 'ابدأ الآن';

  @override
  String get favorites => 'المفضلة';

  @override
  String get editMode => 'تعديل';

  @override
  String get doneMode => 'تم';

  @override
  String get errorLoadingFavorites => 'خطأ في تحميل المفضلة';

  @override
  String get noFavoriteProducts => 'لا توجد منتجات مفضلة';

  @override
  String get addFavoritesFromProducts => 'أضف منتجات للمفضلة من شاشة المنتجات';

  @override
  String get tapProductToAddToCart => 'اضغط على المنتج لإضافته للسلة';

  @override
  String addedProductToCart(String name) {
    return 'تمت إضافة $name للسلة';
  }

  @override
  String get addToCartAction => 'إضافة للسلة';

  @override
  String get removeFromFavorites => 'إزالة من المفضلة';

  @override
  String removedProductFromFavorites(String name) {
    return 'تمت إزالة $name من المفضلة';
  }

  @override
  String get paymentMethodTitle => 'طريقة الدفع';

  @override
  String get backEsc => 'رجوع (Esc)';

  @override
  String get completePayment => 'إتمام الدفع';

  @override
  String get enterToConfirm => 'Enter للتأكيد';

  @override
  String get cashOnlyOffline => 'نقد فقط في وضع عدم الاتصال';

  @override
  String get cardsDisabledInSettings => 'البطاقات معطلة من الاعدادات';

  @override
  String get creditPayment => 'آجل';

  @override
  String get unavailableOffline => 'غير متاح بدون اتصال';

  @override
  String get disabledInSettings => 'معطل من الاعدادات';

  @override
  String get amountReceived => 'المبلغ المستلم';

  @override
  String get quickAmounts => 'مبالغ سريعة';

  @override
  String get requiredAmount => 'المبلغ المطلوب';

  @override
  String get changeLabel => 'الباقي:';

  @override
  String get insufficientAmount => 'المبلغ غير كافي';

  @override
  String get rrnLabel => 'رقم مرجع العملية (RRN)';

  @override
  String get enterRrnFromDevice => 'أدخل رقم العملية من الجهاز';

  @override
  String get cardPaymentInstructions =>
      'اطلب من العميل الدفع عبر جهاز البطاقة، ثم أدخل رقم العملية (RRN) من الإيصال';

  @override
  String get creditSale => 'البيع الآجل';

  @override
  String get creditSaleWarning =>
      'سيتم تسجيل هذا المبلغ كدين على العميل. تأكد من تحديد العميل قبل إتمام العملية.';

  @override
  String get orderSummary => 'ملخص الطلب';

  @override
  String get taxLabel => 'الضريبة (15%)';

  @override
  String get discountLabel => 'الخصم';

  @override
  String get payCash => 'الدفع نقداً';

  @override
  String get payCard => 'الدفع بالبطاقة';

  @override
  String get payCreditSale => 'البيع الآجل';

  @override
  String get confirmPayment => 'تأكيد الدفع';

  @override
  String get processingPayment => 'جاري معالجة الدفع...';

  @override
  String get pleaseWait => 'يرجى الانتظار';

  @override
  String get paymentSuccessful => 'تمت العملية بنجاح!';

  @override
  String get printingReceipt => 'جاري طباعة الإيصال...';

  @override
  String get whatsappReceipt => 'إيصال واتساب';

  @override
  String get storeOrUserNotSet => 'لم يتم تحديد المتجر أو المستخدم';

  @override
  String errorWithMessage(String message) {
    return 'خطأ: $message';
  }

  @override
  String get receiptTitle => 'الإيصال';

  @override
  String get invoiceNotSpecified => 'لم يتم تحديد رقم الفاتورة';

  @override
  String get pendingSync => 'في انتظار المزامنة';

  @override
  String get notSynced => 'غير مزامنة';

  @override
  String receiptNumberLabel(String number) {
    return 'رقم: $number';
  }

  @override
  String get itemColumnHeader => 'الصنف';

  @override
  String get totalAmount => 'الإجمالي';

  @override
  String get paymentMethodField => 'طريقة الدفع';

  @override
  String get zatcaQrCode => 'رمز ZATCA الضريبي';

  @override
  String get whatsappSentLabel => 'تم الإرسال ✓';

  @override
  String get whatsappLabel => 'واتساب';

  @override
  String get whatsappReceiptSent => 'تم إرسال الإيصال عبر واتساب ✓';

  @override
  String whatsappSendFailed(String error) {
    return 'فشل الإرسال: $error';
  }

  @override
  String get cannotPrintNoInvoice => 'لا يمكن الطباعة - رقم الفاتورة غير متوفر';

  @override
  String get invoiceAddedToPrintQueue => 'تمت إضافة الفاتورة لقائمة الطباعة';

  @override
  String get mixedMethod => 'مختلط';

  @override
  String get creditMethod => 'آجل';

  @override
  String get walletMethod => 'محفظة';

  @override
  String get bankTransferMethod => 'تحويل بنكي';

  @override
  String get scanBarcodeHint => 'امسح الباركود أو أدخله (F1)';

  @override
  String get openCamera => 'فتح الكاميرا';

  @override
  String get searchProductHint => 'بحث عن منتج (F2)';

  @override
  String get hideCart => 'إخفاء السلة';

  @override
  String get showCart => 'إظهار السلة';

  @override
  String get cartTitle => 'السلة';

  @override
  String get clearAction => 'مسح';

  @override
  String get allCategories => 'الكل';

  @override
  String get otherCategory => 'أخرى';

  @override
  String get storeNotSet => 'لم يتم تحديد المتجر';

  @override
  String get retryAction => 'إعادة المحاولة';

  @override
  String get vatTax15 => 'ضريبة القيمة المضافة (15%)';

  @override
  String get totalGrand => 'الإجمالي';

  @override
  String get holdOrder => 'تعليق';

  @override
  String get payActionLabel => 'الدفع';

  @override
  String get f12QuickPay => 'F12 للدفع السريع';

  @override
  String productNotFoundBarcode(String barcode) {
    return 'لم يتم العثور على منتج بالباركود: $barcode';
  }

  @override
  String get clearCartTitle => 'مسح السلة';

  @override
  String get clearCartMessage => 'هل تريد مسح جميع المنتجات من السلة؟';

  @override
  String get orderOnHold => 'تم تعليق الطلب';

  @override
  String get deleteItem => 'حذف';

  @override
  String itemsCountPrice(int count, String price) {
    return '$count عنصر - $price ر.س';
  }

  @override
  String get taxReportTitle => 'تقرير الضرائب';

  @override
  String get exportReportAction => 'تصدير التقرير';

  @override
  String get printReportAction => 'طباعة التقرير';

  @override
  String get quarterly => 'ربع سنوي';

  @override
  String get netTaxDue => 'صافي الضريبة المستحقة';

  @override
  String get salesTaxCollected => 'ضريبة المبيعات';

  @override
  String get salesTaxSubtitle => 'المحصلة';

  @override
  String get purchasesTaxPaid => 'ضريبة المشتريات';

  @override
  String get purchasesTaxSubtitle => 'المدفوعة';

  @override
  String get taxByPaymentMethod => 'الضريبة حسب طريقة الدفع';

  @override
  String invoiceCount(int count) {
    return '$count فاتورة';
  }

  @override
  String get taxDetailsTitle => 'تفاصيل الضريبة';

  @override
  String get taxableSales => 'المبيعات الخاضعة للضريبة';

  @override
  String get salesTax15 => 'ضريبة المبيعات (15%)';

  @override
  String get taxablePurchases => 'المشتريات الخاضعة للضريبة';

  @override
  String get purchasesTax15 => 'ضريبة المشتريات (15%)';

  @override
  String get netTax => 'صافي الضريبة';

  @override
  String get zatcaReminder => 'تذكير ZATCA';

  @override
  String get zatcaDeadline => 'الموعد النهائي للإقرار: نهاية الشهر التالي';

  @override
  String get historyAction => 'السجل';

  @override
  String get sendToAuthority => 'إرسال للهيئة';

  @override
  String get cashPaymentMethod => 'نقدي';

  @override
  String get cardPaymentMethod => 'بطاقة';

  @override
  String get mixedPaymentMethod => 'مختلط';

  @override
  String get creditPaymentMethod => 'آجل';

  @override
  String get vatReportTitle => 'تقرير الضريبة (VAT)';

  @override
  String get selectPeriod => 'اختر الفترة';

  @override
  String get salesVat => 'ضريبة المبيعات';

  @override
  String get totalSalesIncVat => 'إجمالي المبيعات (شامل الضريبة)';

  @override
  String get vatCollected => 'ضريبة القيمة المضافة المحصلة';

  @override
  String get purchasesVat => 'ضريبة المشتريات';

  @override
  String get totalPurchasesIncVat => 'إجمالي المشتريات (شامل الضريبة)';

  @override
  String get vatPaid => 'ضريبة القيمة المضافة المدفوعة';

  @override
  String get netVatDue => 'صافي الضريبة المستحقة';

  @override
  String get dueToAuthority => 'مستحق للهيئة';

  @override
  String get dueFromAuthority => 'مستحق من الهيئة';

  @override
  String get exportingPdfReport => 'جاري تصدير التقرير...';

  @override
  String get debtsReportTitle => 'تقرير الديون';

  @override
  String get sortByLastPayment => 'حسب آخر دفعة';

  @override
  String get customersCount => 'عدد العملاء';

  @override
  String get noOutstandingDebts => 'لا توجد ديون مستحقة';

  @override
  String lastUpdate(String date) {
    return 'آخر تحديث: $date';
  }

  @override
  String get paymentAmountField => 'مبلغ الدفعة';

  @override
  String get recordAction => 'تسجيل';

  @override
  String get paymentRecordedMsg => 'تم تسجيل الدفعة';

  @override
  String showDetails(String name) {
    return 'عرض تفاصيل: $name';
  }

  @override
  String get debtsReportPdf => 'تقرير الديون';

  @override
  String dateFieldLabel(String date) {
    return 'التاريخ: $date';
  }

  @override
  String get debtsDetails => 'تفاصيل الديون:';

  @override
  String get customerCol => 'العميل';

  @override
  String get phoneCol => 'الهاتف';

  @override
  String get refundReceiptTitle => 'إيصال الإرجاع';

  @override
  String get noRefundId => 'لا يوجد معرّف إرجاع';

  @override
  String get refundNotFound => 'لم يتم العثور على بيانات الإرجاع';

  @override
  String get refundSuccessful => 'تم الإرجاع بنجاح';

  @override
  String refundNumberLabel(String number) {
    return 'رقم الإرجاع: $number';
  }

  @override
  String get refundReceipt => 'إيصال إرجاع';

  @override
  String get originalInvoiceNumber => 'رقم الفاتورة الأصلية';

  @override
  String get refundDate => 'تاريخ الإرجاع';

  @override
  String get refundMethodField => 'طريقة الاسترداد';

  @override
  String get returnedProducts => 'المنتجات المرتجعة';

  @override
  String get totalRefund => 'إجمالي الإرجاع';

  @override
  String get reasonLabel => 'السبب';

  @override
  String get homeAction => 'الرئيسية';

  @override
  String printError(String error) {
    return 'خطأ في الطباعة: $error';
  }

  @override
  String get damagedProduct => 'منتج تالف';

  @override
  String get wrongOrder => 'خطأ في الطلب';

  @override
  String get customerChangedMind => 'تغيير رأي العميل';

  @override
  String get expiredProduct => 'منتج منتهي الصلاحية';

  @override
  String get unsatisfactoryQuality => 'جودة غير مرضية';

  @override
  String get cashRefundMethod => 'نقدي';

  @override
  String get cardRefundMethod => 'بطاقة';

  @override
  String get walletRefundMethod => 'محفظة';

  @override
  String get refundReasonTitle => 'سبب الإرجاع';

  @override
  String get noRefundData =>
      'لا توجد بيانات إرجاع. يرجى العودة واختيار المنتجات.';

  @override
  String invoiceFieldLabel(String receiptNo) {
    return 'فاتورة: $receiptNo';
  }

  @override
  String productsCountAmount(int count, String amount) {
    return '$count منتج - $amount ر.س';
  }

  @override
  String get selectRefundReason => 'اختر سبب الإرجاع';

  @override
  String get additionalNotesOptional => 'ملاحظات إضافية (اختياري)';

  @override
  String get addNotesHint => 'أضف أي ملاحظات إضافية...';

  @override
  String get processingAction => 'جاري المعالجة...';

  @override
  String get nextSupervisorApproval => 'التالي - موافقة المشرف';

  @override
  String refundCreationError(String error) {
    return 'خطأ في إنشاء الإرجاع: $error';
  }

  @override
  String get refundRequestTitle => 'طلب إرجاع';

  @override
  String get invoiceNumberHint => 'رقم الفاتورة';

  @override
  String get searchAction => 'بحث';

  @override
  String get selectProductsForRefund => 'اختر المنتجات للإرجاع';

  @override
  String get selectAll => 'تحديد الكل';

  @override
  String quantityTimesPrice(int qty, String price) {
    return 'الكمية: $qty × $price ر.س';
  }

  @override
  String productsSelected(int count) {
    return '$count منتج محدد';
  }

  @override
  String refundAmountValue(String amount) {
    return 'المبلغ: $amount ر.س';
  }

  @override
  String get nextAction => 'التالي';

  @override
  String get enterInvoiceToSearch => 'أدخل رقم الفاتورة للبحث';

  @override
  String get invoiceNotFoundMsg => 'لم يتم العثور على الفاتورة';

  @override
  String get shippingGatewaysTitle => 'بوابات الشحن';

  @override
  String get availableShippingGateways => 'بوابات الشحن المتاحة';

  @override
  String get activateShippingGateways =>
      'قم بتفعيل وإعداد بوابات الشحن لتوصيل الطلبات';

  @override
  String get aramexName => 'أرامكس';

  @override
  String get aramexDesc => 'شركة شحن عالمية بخدمات متعددة';

  @override
  String get smsaDesc => 'شحن سريع داخل المملكة';

  @override
  String get fastloName => 'فاستلو';

  @override
  String get fastloDesc => 'توصيل سريع في نفس اليوم';

  @override
  String get dhlDesc => 'شحن دولي سريع وموثوق';

  @override
  String get jtDesc => 'شحن اقتصادي';

  @override
  String get customDeliveryName => 'توصيل خاص';

  @override
  String get customDeliveryDesc => 'إدارة التوصيل بسائقيك الخاصين';

  @override
  String get settingsAction => 'إعدادات';

  @override
  String get hourlyView => 'ساعي';

  @override
  String get dailyView => 'يومي';

  @override
  String get peakHourLabel => 'ساعة الذروة';

  @override
  String transactionsWithCount(int count) {
    return '$count معاملة';
  }

  @override
  String get peakDayLabel => 'يوم الذروة';

  @override
  String get avgPerHour => 'متوسط/ساعة';

  @override
  String get transactionWord => 'معاملة';

  @override
  String get transactionsByHour => 'المعاملات حسب الساعة';

  @override
  String get transactionsByDay => 'المعاملات حسب اليوم';

  @override
  String get activityHeatmap => 'خريطة النشاط الحراري';

  @override
  String get lowLabel => 'منخفض';

  @override
  String get highLabel => 'عالي';

  @override
  String get analysisRecommendations => 'توصيات بناءً على التحليل';

  @override
  String get staffRecommendation => 'الموظفين';

  @override
  String get staffRecommendationDesc =>
      'زيادة عدد الكاشير في الفترة 12:00-13:00 و 17:00-19:00 (ذروة المبيعات)';

  @override
  String get offersRecommendation => 'العروض';

  @override
  String get offersRecommendationDesc =>
      'تقديم عروض خاصة في الفترة 14:00-16:00 لزيادة المبيعات في الفترة الهادئة';

  @override
  String get inventoryRecommendation => 'المخزون';

  @override
  String get inventoryRecommendationDesc =>
      'تجهيز المخزون قبل يومي الخميس والجمعة (أعلى أيام المبيعات)';

  @override
  String get shiftsRecommendation => 'الورديات';

  @override
  String get shiftsRecommendationDesc =>
      'توزيع الورديات: صباحية 8-15، مسائية 15-22 مع تداخل في الذروة';

  @override
  String get topProductsTab => 'أفضل المنتجات';

  @override
  String get byCategoryTab => 'حسب الفئة';

  @override
  String get performanceAnalysisTab => 'تحليل الأداء';

  @override
  String get noSalesDataForPeriod => 'لا توجد بيانات مبيعات للفترة المحددة';

  @override
  String get categoryFilter => 'الفئة';

  @override
  String get allCategoriesFilter => 'جميع الفئات';

  @override
  String get sortByField => 'ترتيب حسب';

  @override
  String get revenueSort => 'الإيرادات';

  @override
  String get unitsSort => 'الوحدات';

  @override
  String get profitSort => 'الأرباح';

  @override
  String get revenueLabel => 'الإيرادات';

  @override
  String get unitsLabel => 'الوحدات';

  @override
  String get profitLabel => 'الربح';

  @override
  String get stockLabel => 'المخزون';

  @override
  String get revenueByCategoryTitle => 'توزيع الإيرادات حسب الفئة';

  @override
  String get noRevenueForPeriod => 'لا توجد إيرادات في هذه الفترة';

  @override
  String get unclassified => 'غير مصنف';

  @override
  String get productUnit => 'منتج';

  @override
  String get unitsSoldUnit => 'وحدة';

  @override
  String get totalRevenueKpi => 'إجمالي الإيرادات';

  @override
  String get unitsSoldKpi => 'الوحدات المباعة';

  @override
  String get totalProfitKpi => 'إجمالي الربح';

  @override
  String get profitMarginKpi => 'هامش الربح';

  @override
  String get performanceOverview => 'نظرة عامة على الأداء';

  @override
  String get trendingUpProducts => 'منتجات متصاعدة';

  @override
  String get stableProducts => 'منتجات مستقرة';

  @override
  String get trendingDownProducts => 'منتجات متراجعة';

  @override
  String noSalesProducts(int count) {
    return 'منتجات بدون مبيعات ($count)';
  }

  @override
  String inStockCount(int count) {
    return '$count في المخزون';
  }

  @override
  String get slowMovingLabel => 'بطيء';

  @override
  String needsReorder(int count) {
    return 'تحتاج إعادة طلب ($count)';
  }

  @override
  String soldUnitsStock(int sold, int stock) {
    return 'بيع: $sold وحدة | مخزون: $stock';
  }

  @override
  String get reorderLabel => 'أعد الطلب';

  @override
  String get totalComplaintsLabel => 'إجمالي الشكاوى';

  @override
  String get openComplaints => 'مفتوحة';

  @override
  String get closedComplaints => 'مغلقة';

  @override
  String get avgResolutionTime => 'متوسط وقت الحل';

  @override
  String daysUnit(String count) {
    return '$count يوم';
  }

  @override
  String get fromDate => 'من تاريخ';

  @override
  String get toDate => 'إلى تاريخ';

  @override
  String get statusFilter => 'الحالة';

  @override
  String get departmentFilter => 'القسم';

  @override
  String get paymentDepartment => 'الدفع';

  @override
  String get technicalDepartment => 'تقني';

  @override
  String get otherDepartment => 'أخرى';

  @override
  String get noComplaintsRecorded => 'لم يتم تسجيل أي شكاوى حتى الآن';

  @override
  String get overviewTab => 'نظرة عامة';

  @override
  String get topCustomersTab => 'أفضل العملاء';

  @override
  String get growthAnalysisTab => 'تحليل النمو';

  @override
  String get loyaltyTab => 'الولاء';

  @override
  String get totalCustomersLabel => 'إجمالي العملاء';

  @override
  String get activeCustomersLabel => 'عملاء نشطين';

  @override
  String get avgOrderValueLabel => 'متوسط قيمة الطلب';

  @override
  String get tierDistribution => 'توزيع العملاء حسب المستوى';

  @override
  String get activitySummary => 'ملخص النشاط';

  @override
  String get totalRevenueFromCustomers =>
      'إجمالي الإيرادات من العملاء المسجلين';

  @override
  String get avgOrderPerCustomer => 'متوسط قيمة الطلب لكل عميل';

  @override
  String get activeCustomersLast30 => 'عملاء نشطين (آخر 30 يوم)';

  @override
  String get newCustomersLast30 => 'عملاء جدد (آخر 30 يوم)';

  @override
  String topCustomersTitle(int count) {
    return 'أفضل $count عملاء';
  }

  @override
  String get bySpending => 'حسب الإنفاق';

  @override
  String get byOrders => 'حسب الطلبات';

  @override
  String get byPoints => 'حسب النقاط';

  @override
  String ordersCount(int count) {
    return '$count طلب';
  }

  @override
  String get avgOrderStat => 'متوسط الطلب';

  @override
  String get loyaltyPointsStat => 'نقاط الولاء';

  @override
  String get lastOrderStat => 'آخر طلب';

  @override
  String get newCustomerGrowth => 'نمو العملاء الجدد';

  @override
  String get customerRetentionRate => 'معدل الاحتفاظ بالعملاء';

  @override
  String get monthlyPeriod => 'شهري';

  @override
  String get totalCustomersPeriod => 'إجمالي العملاء';

  @override
  String get activePeriod => 'نشطين';

  @override
  String get activeCustomersInfo => 'العملاء النشطين: من اشترى خلال آخر 30 يوم';

  @override
  String get cohortAnalysis => 'تحليل Cohort (مجموعات العملاء)';

  @override
  String get cohortDescription => 'نسبة العودة للشراء بعد الشراء الأول';

  @override
  String get cohortGroup => 'المجموعة';

  @override
  String get month1 => 'شهر 1';

  @override
  String get month2 => 'شهر 2';

  @override
  String get month3 => 'شهر 3';

  @override
  String get loyaltyProgramStats => 'إحصائيات برنامج الولاء';

  @override
  String get totalPointsGranted => 'إجمالي النقاط الممنوحة';

  @override
  String get remainingPoints => 'النقاط المتبقية';

  @override
  String get pointsValue => 'قيمة النقاط';

  @override
  String get pointsByTier => 'توزيع النقاط حسب المستوى';

  @override
  String get pointsUnit => 'نقطة';

  @override
  String get redemptionPatterns => 'أنماط استبدال النقاط';

  @override
  String get purchaseDiscount => 'خصم على المشتريات';

  @override
  String get freeProducts => 'منتجات مجانية';

  @override
  String get couponsLabel => 'كوبونات';

  @override
  String get diamondTier => 'ماسي';

  @override
  String get goldTier => 'ذهبي';

  @override
  String get silverTier => 'فضي';

  @override
  String get bronzeTier => 'برونزي';

  @override
  String get todayDate => 'اليوم';

  @override
  String get yesterdayDate => 'أمس';

  @override
  String daysCountLabel(int count) {
    return '$count يوم';
  }

  @override
  String ofTotalLabel(String active, String total) {
    return '$active من $total';
  }

  @override
  String get exportingReportMsg => 'جاري تصدير التقرير...';

  @override
  String get januaryMonth => 'يناير';

  @override
  String get februaryMonth => 'فبراير';

  @override
  String get marchMonth => 'مارس';

  @override
  String get aprilMonth => 'أبريل';

  @override
  String get mayMonth => 'مايو';

  @override
  String get juneMonth => 'يونيو';

  @override
  String errorLabel(String error) {
    return 'خطأ: $error';
  }

  @override
  String get saturdayDay => 'السبت';

  @override
  String get sundayDay => 'الأحد';

  @override
  String get mondayDay => 'الاثنين';

  @override
  String get tuesdayDay => 'الثلاثاء';

  @override
  String get wednesdayDay => 'الأربعاء';

  @override
  String get thursdayDay => 'الخميس';

  @override
  String get fridayDay => 'الجمعة';

  @override
  String get satShort => 'سبت';

  @override
  String get sunShort => 'أحد';

  @override
  String get monShort => 'اثن';

  @override
  String get tueShort => 'ثلا';

  @override
  String get wedShort => 'أرب';

  @override
  String get thuShort => 'خمي';

  @override
  String get friShort => 'جمع';

  @override
  String get errorLoadingVatReport => 'حدث خطأ في تحميل تقرير الضريبة';

  @override
  String get errorLoadingComplaints => 'حدث خطأ في تحميل الشكاوى';

  @override
  String get errorLoadingCustomerReport => 'حدث خطأ في تحميل تقرير العملاء';
}
