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
  String get lowStock => 'Mababang Stock';

  @override
  String get outOfStock => 'Wala nang Stock';

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
  String get revenue => 'Kita';

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
  String get invoiceNumberLabel => 'Numero:';

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
  String customerCount(String count) {
    return '$count customer';
  }

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
  String get expenseAmount => 'المبلغ';

  @override
  String get expenseDate => 'التاريخ';

  @override
  String get expenseCategory => 'التصنيف';

  @override
  String get expenseNotes => 'ملاحظات';

  @override
  String get noExpenses => 'Walang naitatalang gastos';

  @override
  String get drawerStatus => 'حالة الدرج';

  @override
  String get drawerOpen => 'مفتوح';

  @override
  String get drawerClosed => 'مغلق';

  @override
  String get cashIn => 'إيداع نقدي';

  @override
  String get cashOut => 'سحب نقدي';

  @override
  String get expectedAmount => 'المبلغ المتوقع';

  @override
  String get countedAmount => 'المبلغ المحسوب';

  @override
  String get difference => 'الفرق';

  @override
  String get openDrawerAction => 'فتح الدرج';

  @override
  String get closeDrawerAction => 'إغلاق الدرج';

  @override
  String get monthlyCloseTitle => 'الإغلاق الشهري';

  @override
  String get monthlyCloseDesc => 'إغلاق الشهر وحساب المستحقات';

  @override
  String get totalReceivables => 'إجمالي المستحقات';

  @override
  String get interestRate => 'نسبة الفائدة';

  @override
  String get closeMonth => 'إغلاق الشهر';

  @override
  String get shiftsTitle => 'Mga Shift';

  @override
  String get currentShift => 'الوردية الحالية';

  @override
  String get shiftHistory => 'سجل الورديات';

  @override
  String get openShiftAction => 'فتح وردية';

  @override
  String get closeShiftAction => 'إغلاق وردية';

  @override
  String get shiftStartTime => 'وقت البدء';

  @override
  String get shiftEndTime => 'وقت الانتهاء';

  @override
  String get shiftTotalSales => 'إجمالي المبيعات';

  @override
  String get shiftTotalOrders => 'إجمالي الطلبات';

  @override
  String get startingCash => 'النقد الابتدائي';

  @override
  String get cashierName => 'الكاشير';

  @override
  String get shiftDuration => 'المدة';

  @override
  String get noShifts => 'لا توجد ورديات مسجلة';

  @override
  String get purchasesTitle => 'Mga Pagbili';

  @override
  String get newPurchase => 'مشترى جديد';

  @override
  String get smartReorder => 'إعادة طلب ذكي';

  @override
  String get aiInvoiceImport => 'استيراد فاتورة بالذكاء الاصطناعي';

  @override
  String get aiInvoiceReview => 'مراجعة فاتورة AI';

  @override
  String get purchaseOrder => 'أمر شراء';

  @override
  String get purchaseTotal => 'إجمالي المشتريات';

  @override
  String get purchaseDate => 'تاريخ الشراء';

  @override
  String get suppliersTitle => 'Mga Supplier';

  @override
  String get addSupplier => 'إضافة مورد';

  @override
  String get supplierName => 'اسم المورد';

  @override
  String get supplierPhone => 'الهاتف';

  @override
  String get supplierEmail => 'البريد الإلكتروني';

  @override
  String get supplierAddress => 'العنوان';

  @override
  String get totalSuppliers => 'إجمالي الموردين';

  @override
  String get supplierDetails => 'تفاصيل المورد';

  @override
  String get noSuppliers => 'لا يوجد موردين';

  @override
  String get discountsTitle => 'Mga Diskwento';

  @override
  String get addDiscount => 'إضافة خصم';

  @override
  String get discountName => 'اسم الخصم';

  @override
  String get discountType => 'نوع الخصم';

  @override
  String get discountValue => 'القيمة';

  @override
  String get percentageDiscount => 'نسبة مئوية';

  @override
  String get fixedDiscount => 'مبلغ ثابت';

  @override
  String get activeDiscounts => 'الخصومات النشطة';

  @override
  String get couponsTitle => 'Mga Kupon';

  @override
  String get addCoupon => 'إضافة كوبون';

  @override
  String get couponCode => 'رمز الكوبون';

  @override
  String get couponUsage => 'الاستخدام';

  @override
  String get couponExpiry => 'الصلاحية';

  @override
  String get totalCoupons => 'إجمالي الكوبونات';

  @override
  String get activeCoupons => 'نشطة';

  @override
  String get expiredCoupons => 'منتهية';

  @override
  String get specialOffersTitle => 'Mga Espesyal na Alok';

  @override
  String get addOffer => 'إضافة عرض';

  @override
  String get offerName => 'اسم العرض';

  @override
  String get offerStartDate => 'تاريخ البدء';

  @override
  String get offerEndDate => 'تاريخ الانتهاء';

  @override
  String get smartPromotionsTitle => 'Matalinong Promosyon';

  @override
  String get activePromotions => 'العروض النشطة';

  @override
  String get suggestedPromotions => 'اقتراحات AI';

  @override
  String get loyaltyTitle => 'Programa ng Katapatan';

  @override
  String get loyaltyMembers => 'الأعضاء';

  @override
  String get loyaltyRewards => 'المكافآت';

  @override
  String get loyaltyTiers => 'المستويات';

  @override
  String get totalMembers => 'إجمالي الأعضاء';

  @override
  String get pointsIssued => 'النقاط الممنوحة';

  @override
  String get pointsRedeemed => 'النقاط المستبدلة';

  @override
  String get notificationsTitle => 'Mga Abiso';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get printQueueTitle => 'Print Queue';

  @override
  String get printAll => 'طباعة الكل';

  @override
  String get cancelAll => 'إلغاء الكل';

  @override
  String get noPrintJobs => 'لا توجد مهام طباعة';

  @override
  String get syncStatusTitle => 'Estado ng Sync';

  @override
  String get lastSyncTime => 'آخر مزامنة';

  @override
  String get pendingItems => 'عناصر معلقة';

  @override
  String get syncNow => 'مزامنة الآن';

  @override
  String get pendingTransactionsTitle => 'العمليات المعلقة';

  @override
  String get conflictResolutionTitle => 'حل التعارضات';

  @override
  String get localValue => 'محلي';

  @override
  String get serverValue => 'الخادم';

  @override
  String get keepLocal => 'الاحتفاظ بالمحلي';

  @override
  String get keepServer => 'الاحتفاظ بالخادم';

  @override
  String get driversTitle => 'Mga Driver';

  @override
  String get addDriver => 'إضافة سائق';

  @override
  String get driverName => 'اسم السائق';

  @override
  String get driverStatus => 'الحالة';

  @override
  String get delivering => 'في التوصيل';

  @override
  String get totalDeliveries => 'إجمالي التوصيلات';

  @override
  String get driverRating => 'التقييم';

  @override
  String get branchesTitle => 'Mga Sangay';

  @override
  String get addBranchAction => 'إضافة فرع';

  @override
  String get branchName => 'اسم الفرع';

  @override
  String get branchEmployees => 'الموظفين';

  @override
  String get branchSales => 'مبيعات اليوم';

  @override
  String get profileTitle => 'Profile';

  @override
  String get editProfile => 'تعديل الملف';

  @override
  String get personalInfo => 'المعلومات الشخصية';

  @override
  String get accountSettings => 'إعدادات الحساب';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get role => 'الدور';

  @override
  String get settingsTitle => 'Mga Setting';

  @override
  String get storeSettings => 'Mga Setting ng Tindahan';

  @override
  String get posSettings => 'Mga Setting ng POS';

  @override
  String get printerSettings => 'Mga Setting ng Printer';

  @override
  String get paymentDevicesSettings => 'أجهزة الدفع';

  @override
  String get barcodeSettings => 'إعدادات الباركود';

  @override
  String get receiptTemplate => 'قالب الإيصال';

  @override
  String get taxSettings => 'إعدادات الضريبة';

  @override
  String get discountSettings => 'إعدادات الخصومات';

  @override
  String get interestSettings => 'إعدادات الفوائد';

  @override
  String get languageSettings => 'اللغة';

  @override
  String get themeSettings => 'المظهر';

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
  String get notificationSettings => 'الإشعارات';

  @override
  String get zatcaCompliance => 'ZATCA Compliance';

  @override
  String get helpSupport => 'Tulong at Suporta';

  @override
  String get general => 'عام';

  @override
  String get appearance => 'المظهر';

  @override
  String get securitySection => 'الأمان';

  @override
  String get advanced => 'متقدم';

  @override
  String get enabled => 'مفعّل';

  @override
  String get disabled => 'معطّل';

  @override
  String get configure => 'تهيئة';

  @override
  String get connected => 'متصل';

  @override
  String get notConnected => 'غير متصل';

  @override
  String get testConnection => 'اختبار الاتصال';

  @override
  String get lastBackup => 'آخر نسخة احتياطية';

  @override
  String get autoBackup => 'نسخ احتياطي تلقائي';

  @override
  String get manualBackup => 'نسخ احتياطي الآن';

  @override
  String get restoreBackup => 'استعادة';

  @override
  String get biometricAuth => 'المصادقة البيومترية';

  @override
  String get sessionTimeout => 'مهلة الجلسة';

  @override
  String get changePin => 'تغيير رمز PIN';

  @override
  String get twoFactorAuth => 'المصادقة الثنائية';

  @override
  String get addUser => 'إضافة مستخدم';

  @override
  String get userName => 'اسم المستخدم';

  @override
  String get userEmail => 'البريد الإلكتروني';

  @override
  String get userPhone => 'الهاتف';

  @override
  String get addRole => 'إضافة دور';

  @override
  String get roleName => 'اسم الدور';

  @override
  String get permissions => 'الصلاحيات';

  @override
  String get faq => 'الأسئلة الشائعة';

  @override
  String get contactSupport => 'تواصل مع الدعم';

  @override
  String get documentation => 'التوثيق';

  @override
  String get reportBug => 'الإبلاغ عن خطأ';

  @override
  String get zatcaRegistration => 'تسجيل هيئة الزكاة';

  @override
  String get eInvoicing => 'الفوترة الإلكترونية';

  @override
  String get qrCode => 'رمز QR';

  @override
  String get vatNumber => 'الرقم الضريبي';

  @override
  String get taxNumber => 'رقم الضريبة';

  @override
  String get pushNotifications => 'إشعارات الدفع';

  @override
  String get emailNotifications => 'إشعارات البريد';

  @override
  String get smsNotifications => 'إشعارات SMS';

  @override
  String get orderNotifications => 'إشعارات الطلبات';

  @override
  String get stockNotifications => 'تنبيهات المخزون';

  @override
  String get paymentNotifications => 'إشعارات الدفع';

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
}
