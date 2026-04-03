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
  String pageNotFoundPath(String path) {
    return 'الصفحة غير موجودة: $path';
  }

  @override
  String get noInvoiceDataAvailable => 'لا تتوفر بيانات الفاتورة';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count branches',
      one: '1 branch',
      zero: 'Walang branch',
    );
    return '$_temp0';
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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count order ngayon',
      one: '1 order ngayon',
      zero: 'Walang order ngayon',
    );
    return '$_temp0';
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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuto ang nakalipas',
      one: '1 minuto ang nakalipas',
    );
    return '$_temp0';
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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count oras ang nakalipas',
      one: '1 oras ang nakalipas',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count araw ang nakalipas',
      one: '1 araw ang nakalipas',
    );
    return '$_temp0';
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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kategorya',
      one: '1 kategorya',
      zero: 'Walang kategorya',
    );
    return '$_temp0';
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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invoice naghihintay ng bayad',
      one: '1 invoice naghihintay ng bayad',
      zero: 'Walang invoice na naghihintay',
    );
    return '$_temp0';
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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count napili',
      one: '1 napili',
      zero: 'Walang napili',
    );
    return '$_temp0';
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
  String customerAddedSuccess(String name) {
    return 'Naidagdag si $name';
  }

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
  String get resetAction => 'I-reset';

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
  String get orderHistory => 'Kasaysayan ng Order';

  @override
  String get history => 'Kasaysayan';

  @override
  String get selectDateRange => 'Select Period';

  @override
  String get orderSearchHint => 'Search by order number or customer ID...';

  @override
  String get noOrders => 'Walang order';

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
  String get shareAction => 'I-share';

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
  String get acknowledgeAll => 'Kilalanin Lahat';

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
  String get noAlerts => 'Walang alerto';

  @override
  String get alertDismissed => 'Na-dismiss ang alerto';

  @override
  String get undo => 'I-undo';

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
  String get currentQuantity => 'Kasalukuyang Dami';

  @override
  String get minimumThreshold => 'Minimum';

  @override
  String get dismissAction => 'I-dismiss';

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
  String get acknowledgeAllAlerts => 'Kilalanin Lahat ng Alerto';

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
  String get createAction => 'Gumawa';

  @override
  String get purchaseOrderCreated => 'Purchase order created';

  @override
  String get newCategory => 'New Category';

  @override
  String productCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produkto',
      one: '1 produkto',
      zero: 'Walang produkto',
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
  String supplierLabel(String name) {
    return 'Supplier';
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
    return '$count item';
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
  String get gotIt => 'Naintindihan';

  @override
  String get print => 'I-print';

  @override
  String get display => 'Display';

  @override
  String get item => 'Item';

  @override
  String get invoice => 'Invoice';

  @override
  String get accept => 'Tanggapin';

  @override
  String get details => 'Detalye';

  @override
  String get newLabel => 'Bago';

  @override
  String get mixed => 'Halo-halo';

  @override
  String get lowStockLabel => 'Mababa';

  @override
  String get debtor => 'Debtor';

  @override
  String get creditor => 'Creditor';

  @override
  String get balanceLabel => 'Balanse';

  @override
  String get returnLabel => 'Ibalik';

  @override
  String get skip => 'Laktawan';

  @override
  String get send => 'Ipadala';

  @override
  String get cloud => 'Cloud';

  @override
  String get defaultLabel => 'Default';

  @override
  String get closed => 'Sarado';

  @override
  String get owes => 'Owes';

  @override
  String get due => 'Dapat bayaran';

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
  String get seconds => 'Segundo';

  @override
  String get errors => 'Mga Error';

  @override
  String get syncLabel => 'Sync';

  @override
  String get slow => 'Mabagal';

  @override
  String get myGrocery => 'My Grocery';

  @override
  String get cashier => 'Cashier';

  @override
  String get goBack => 'Bumalik';

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
  String get strong => 'Malakas';

  @override
  String get medium => 'Katamtaman';

  @override
  String get weak => 'Mahina';

  @override
  String get good => 'Mabuti';

  @override
  String get danger => 'Panganib';

  @override
  String get currentLabel => 'Kasalukuyan';

  @override
  String get suggested => 'Suggested';

  @override
  String get actual => 'Actual';

  @override
  String get forecast => 'Forecast';

  @override
  String get critical => 'Critical';

  @override
  String get high => 'Mataas';

  @override
  String get low => 'Mababa';

  @override
  String get investigation => 'Investigation';

  @override
  String get apply => 'I-apply';

  @override
  String get run => 'Patakbuhin';

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
  String get quality => 'Kalidad';

  @override
  String get luxury => 'Luxury';

  @override
  String get economic => 'Economic';

  @override
  String get ourStore => 'Our Store';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get cost => 'Gastos';

  @override
  String get duration => 'Tagal';

  @override
  String get quiet => 'Quiet';

  @override
  String get busy => 'Busy';

  @override
  String get outstanding => 'Balanse';

  @override
  String get donate => 'Donate';

  @override
  String get day => 'Araw';

  @override
  String get days => 'Mga araw';

  @override
  String get projected => 'Projected';

  @override
  String get analysis => 'Pagsusuri';

  @override
  String get review => 'Review';

  @override
  String get productCategory => 'Kategorya';

  @override
  String get ourPrice => 'Our Price';

  @override
  String get position => 'Posisyon';

  @override
  String get cheapest => 'Pinakamurang';

  @override
  String get mostExpensive => 'Most Expensive';

  @override
  String get soldOut => 'Sold Out';

  @override
  String get noDataAvailable => 'Walang data na available';

  @override
  String get noDataFoundMessage => 'No data was found';

  @override
  String get noSearchResultsFound => 'No results found';

  @override
  String get noProductsFound => 'Walang nahanap na produkto';

  @override
  String get noCustomers => 'Walang customer';

  @override
  String get addCustomersToStart => 'Add new customers to start';

  @override
  String get noOrdersYet => 'You haven\'t made any orders yet';

  @override
  String get noConnection => 'No connection';

  @override
  String get checkInternet => 'Suriin ang iyong koneksyon sa internet';

  @override
  String get cartIsEmpty => 'Walang laman ang cart';

  @override
  String get browseProducts => 'Mag-browse ng Produkto';

  @override
  String noResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get paidLabel => 'Bayad na';

  @override
  String get remainingLabel => 'Remaining';

  @override
  String get completeLabel => 'Complete';

  @override
  String get addPayment => 'Add';

  @override
  String get payments => 'Mga Bayad';

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
  String get averageInvoice => 'Average na Invoice';

  @override
  String errorPrefix(String message, Object error) {
    return 'Error: $error';
  }

  @override
  String get vipMember => 'VIP Member';

  @override
  String get activeSuppliers => 'Mga Aktibong Supplier';

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
  String get cancelLabel => 'Kanselahin';

  @override
  String get addLabel => 'Dagdagan';

  @override
  String get saveLabel => 'I-save';

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
  String get deleteConfirmBtn => 'Burahin';

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
  String get productNameLabel => 'Product Name *';

  @override
  String get quantityLabel => 'Dami';

  @override
  String get purchasePriceLabel => 'Purchase Price';

  @override
  String get saveInvoiceBtn => 'Save Invoice';

  @override
  String get ibanLabel => 'IBAN Account Number';

  @override
  String get supplierActiveLabel => 'Supplier Active';

  @override
  String get notesLabel => 'Mga Tala';

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
  String get damaged => 'Nasira';

  @override
  String get correction => 'Correction';

  @override
  String get stockUpdatedTo => 'Stock updated for';

  @override
  String get featureUnderDevelopment => 'This feature is under development...';

  @override
  String get newest => 'Newest';

  @override
  String get adjustStock => 'I-adjust ang Stock';

  @override
  String get adjustmentHistory => 'Adjustment History';

  @override
  String get errorLoadingProducts => 'Error loading products';

  @override
  String get selectProduct => 'Select Product';

  @override
  String get subtract => 'Ibawas';

  @override
  String get setQuantity => 'I-set';

  @override
  String get enterQuantity => 'Ilagay ang dami';

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
  String get errorSaving => 'Error sa pag-save';

  @override
  String get enterBarcode => 'Ilagay ang barcode';

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
  String get approved => 'Inaprubahan';

  @override
  String get inTransit => 'In Transit';

  @override
  String get complete => 'Kumpleto';

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
  String get system => 'Sistema';

  @override
  String get count => 'Bilang';

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
  String get remove => 'Alisin';

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
  String get selectDate => 'Pumili ng petsa';

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
  String get stop => 'Itigil';

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
  String get found => 'Natagpuan';

  @override
  String get productNotFoundForBarcode => 'Product not found';

  @override
  String get addNewProduct => 'Magdagdag ng Bagong Produkto';

  @override
  String get willOpenAddProductScreen => 'Will open add product screen';

  @override
  String get scanHistory => 'Scan History';

  @override
  String get addedToCart => 'Naidagdag';

  @override
  String get barcodePrint => 'Barcode Print';

  @override
  String get noProductsWithBarcode => 'No products with barcode';

  @override
  String get addBarcodeFirst => 'Add barcode to products first';

  @override
  String get searchProduct => 'Maghanap ng produkto...';

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
  String get filterAllLabel => 'Lahat';

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
  String get actionDiscount => 'Diskwento';

  @override
  String get actionTransfer => 'Ilipat';

  @override
  String get actionDonate => 'Mag-donate';

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
  String get phoneFieldLabel => 'Telepono';

  @override
  String get branchFieldLabel => 'Branch';

  @override
  String get mainBranchName => 'Main Branch';

  @override
  String get employeeNumberLabel => 'Employee Number';

  @override
  String get changePasswordLabel => 'Palitan ang Password';

  @override
  String get activityLogLabel => 'Activity Log';

  @override
  String get logoutDialogTitle => 'Logout';

  @override
  String get logoutDialogBody => 'Gusto mo bang mag-logout sa system?';

  @override
  String get cancelButton => 'Kanselahin';

  @override
  String get exitButton => 'Lumabas';

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
  String get startNow => 'Magsimula Ngayon';

  @override
  String get favorites => 'Mga Paborito';

  @override
  String get editMode => 'I-edit';

  @override
  String get doneMode => 'Tapos na';

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
  String get addToCartAction => 'Idagdag sa Cart';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String removedProductFromFavorites(String name) {
    return '$name removed from favorites';
  }

  @override
  String get paymentMethodTitle => 'Payment Method';

  @override
  String get backEsc => 'Bumalik (Esc)';

  @override
  String get completePayment => 'Kumpletuhin ang Bayad';

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
  String get amountReceived => 'Halagang Natanggap';

  @override
  String get quickAmounts => 'Quick Amounts';

  @override
  String get requiredAmount => 'Required Amount';

  @override
  String get changeLabel => 'Sukli:';

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
  String get creditSale => 'Utang na Benta';

  @override
  String get creditSaleWarning =>
      'This amount will be recorded as a debt for the customer. Make sure to select the customer before completing the transaction.';

  @override
  String get orderSummary => 'Buod ng Order';

  @override
  String get taxLabel => 'Tax (15%)';

  @override
  String discountLabel(String value) {
    return 'Diskwento';
  }

  @override
  String get payCash => 'Bayad ng Cash';

  @override
  String get payCard => 'Bayad sa Card';

  @override
  String get payCreditSale => 'Credit Sale';

  @override
  String get confirmPayment => 'Kumpirmahin ang Bayad';

  @override
  String get processingPayment => 'Processing payment...';

  @override
  String get pleaseWait => 'Mangyaring maghintay';

  @override
  String get paymentSuccessful => 'Matagumpay ang bayad!';

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
  String get receiptTitle => 'Resibo';

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
    return 'Kabuuan';
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
  String get clearAction => 'I-clear';

  @override
  String get allCategories => 'Lahat';

  @override
  String get otherCategory => 'Other';

  @override
  String get storeNotSet => 'Store not set';

  @override
  String get retryAction => 'Subukang Muli';

  @override
  String get vatTax15 => 'VAT (15%)';

  @override
  String get totalGrand => 'Total';

  @override
  String get holdOrder => 'I-hold';

  @override
  String get payActionLabel => 'Magbayad';

  @override
  String get f12QuickPay => 'F12 for quick pay';

  @override
  String productNotFoundBarcode(String barcode) {
    return 'Product not found for barcode: $barcode';
  }

  @override
  String get clearCartTitle => 'I-clear ang Cart';

  @override
  String get clearCartMessage =>
      'Do you want to remove all products from the cart?';

  @override
  String get orderOnHold => 'Order on hold';

  @override
  String get deleteItem => 'Burahin';

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
  String get customersCount => 'Mga Customer';

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
  String get phoneCol => 'Telepono';

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
  String get reasonLabel => 'Dahilan';

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
  String get expiredProduct => 'Expired product';

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
  String get searchAction => 'Maghanap';

  @override
  String get selectProductsForRefund => 'Select products to return';

  @override
  String get selectAll => 'Piliin lahat';

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
  String get nextAction => 'Susunod';

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
  String get dailyView => 'Araw-araw';

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
  String get categoryFilter => 'Kategorya';

  @override
  String get allCategoriesFilter => 'Lahat ng Kategorya';

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
  String get profitLabel => 'Kita';

  @override
  String get stockLabel => 'Stock';

  @override
  String get revenueByCategoryTitle => 'Revenue Distribution by Category';

  @override
  String get noRevenueForPeriod => 'No revenue for this period';

  @override
  String get unclassified => 'Unclassified';

  @override
  String get productUnit => 'produkto';

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
  String get activeCustomersLabel => 'Mga Aktibong Customer';

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
  String get lastOrderStat => 'Huling Order';

  @override
  String get newCustomerGrowth => 'New Customer Growth';

  @override
  String get customerRetentionRate => 'Customer Retention Rate';

  @override
  String get monthlyPeriod => 'Buwanan';

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
  String get todayDate => 'Ngayon';

  @override
  String get yesterdayDate => 'Kahapon';

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
  String get confirmOrder => 'Kumpirmahin ang Order';

  @override
  String get orderNow => 'Mag-order Na';

  @override
  String get orderCart => 'Order Cart';

  @override
  String get orderReceived => 'Natanggap na ang iyong order!';

  @override
  String get orderBeingPrepared =>
      'Ihahanda ang iyong order sa lalong madaling panahon';

  @override
  String get redirectingToHome => 'Awtomatikong pupunta sa home page...';

  @override
  String get kioskOrderNote => 'Kiosk order';

  @override
  String pricePerUnit(String price) {
    return '$price SAR bawat unit';
  }

  @override
  String get selectFromMenu => 'Pumili mula sa menu';

  @override
  String orderCartWithCount(int count) {
    return 'Order Cart ($count item)';
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
  String get applyCoupon => 'Mag-apply ng Coupon';

  @override
  String get enterCouponCode => 'Ilagay ang coupon code';

  @override
  String get invalidCoupon => 'Hindi valid o hindi nahanap ang coupon';

  @override
  String get couponExpired => 'Nag-expire na ang coupon';

  @override
  String minimumPurchaseRequired(String amount) {
    return 'Minimum na bilhin $amount SAR';
  }

  @override
  String couponDiscountApplied(String amount) {
    return 'Na-apply ang diskwento na $amount SAR';
  }

  @override
  String get couponInvalid => 'Hindi valid ang coupon';

  @override
  String get customerAddFailed => 'Hindi naidagdag ang customer';

  @override
  String get quantityColon => 'Dami:';

  @override
  String get riyal => 'SAR';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get banknotes => 'Banknotes';

  @override
  String get coins => 'Coins';

  @override
  String get totalAmountLabel => 'Kabuuang Halaga';

  @override
  String denominationRiyal(String amount) {
    return '$amount SAR';
  }

  @override
  String denominationHalala(String amount) {
    return '$amount Halala';
  }

  @override
  String get countCurrency => 'Bilangin ang Pera';

  @override
  String confirmAmountSar(String amount) {
    return 'Kumpirmahin: $amount SAR';
  }

  @override
  String amountRiyal(String amount) {
    return '$amount SAR';
  }

  @override
  String get itemDeletedMsg => 'Na-delete ang item';

  @override
  String get pressBackAgainToExit => 'Pindutin muli para lumabas';

  @override
  String get deleteHeldInvoiceConfirm => 'I-delete ang naka-hold na invoice?';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get addCustomer => 'إضافة عميل';

  @override
  String get noInvoices => 'لا توجد فواتير';

  @override
  String get noReports => 'لا توجد تقارير';

  @override
  String get noOffers => 'لا توجد عروض';

  @override
  String get emptyStateStartAddProducts => 'ابدأ بإضافة منتجاتك الآن';

  @override
  String get emptyStateStartAddCustomers => 'ابدأ بإضافة عملائك الآن';

  @override
  String get emptyStateAddProductsToCart => 'أضف منتجات للسلة لبدء البيع';

  @override
  String get emptyStateInvoicesAppearAfterSale =>
      'ستظهر الفواتير هنا بعد إتمام عمليات البيع';

  @override
  String get emptyStateNewOrdersAppearHere => 'ستظهر الطلبات الجديدة هنا';

  @override
  String get emptyStateNewNotificationsAppearHere =>
      'ستظهر الإشعارات الجديدة هنا';

  @override
  String get emptyStateCheckYourConnection => 'تحقق من اتصالك بالإنترنت';

  @override
  String get emptyStateReportsAppearAfterSale =>
      'ستظهر التقارير بعد إتمام عمليات البيع';

  @override
  String get emptyStateNoNeedToRestock => 'لا توجد منتجات تحتاج إعادة تعبئة';

  @override
  String get emptyStateAllCustomersPaid => 'جميع العملاء قاموا بالسداد';

  @override
  String get emptyStateReturnsAppearHere => 'ستظهر المرتجعات هنا';

  @override
  String get emptyStateAddOffersToAttract =>
      'أضف عروضاً لجذب المزيد من العملاء';

  @override
  String get errorNoInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String get errorCheckConnectionAndRetry =>
      'تحقق من اتصالك بالإنترنت وحاول مرة أخرى';

  @override
  String get errorServerError => 'خطأ في الخادم';

  @override
  String get errorServerConnectionFailed => 'حدث خطأ أثناء الاتصال بالخادم';

  @override
  String get errorUnexpectedError => 'حدث خطأ غير متوقع';

  @override
  String get customerGroups => 'مجموعات العملاء';

  @override
  String get allCustomersGroup => 'كل العملاء';

  @override
  String get vipCustomersGroup => 'عملاء VIP';

  @override
  String get regularCustomersGroup => 'عملاء منتظمون';

  @override
  String get newCustomersGroup => 'عملاء جدد';

  @override
  String get newCustomers30Days => 'عملاء جدد (30 يوم)';

  @override
  String get customersWithDebt => 'عملاء لديهم ديون';

  @override
  String get haveDebts => 'لديهم ديون';

  @override
  String get inactive90Days => 'غير نشطين (90+ يوم)';

  @override
  String customerCountLabel(int count) {
    return '$count عميل';
  }

  @override
  String get selectGroupToViewCustomers => 'اختر مجموعة لعرض العملاء';

  @override
  String get noCustomersInGroup => 'لا يوجد عملاء في هذه المجموعة';

  @override
  String get debtWord => 'دين';

  @override
  String get employeeProfile => 'ملف الموظف';

  @override
  String get employeeNotFound => 'الموظف غير موجود';

  @override
  String get profileTab => 'الملف';

  @override
  String get salesTab => 'المبيعات';

  @override
  String get shiftsTab => 'الورديات';

  @override
  String get permissionsTab2 => 'الصلاحيات';

  @override
  String get mobilePhone => 'الجوال';

  @override
  String get joinDate => 'تاريخ الانضمام';

  @override
  String get lastLogin => 'آخر دخول';

  @override
  String get neverLoggedIn => 'لم يدخل بعد';

  @override
  String get accountActive => 'الحساب نشط';

  @override
  String get canLogin => 'يمكنه تسجيل الدخول';

  @override
  String get blockedFromLogin => 'محظور من الدخول';

  @override
  String get employeeFallback => 'موظف';

  @override
  String get weekLabel => 'أسبوع';

  @override
  String get monthLabel => 'شهر';

  @override
  String get loadSalesData => 'تحميل بيانات المبيعات';

  @override
  String get invoiceCountLabel2 => 'عدد الفواتير';

  @override
  String get hourlySalesDistribution => 'توزيع المبيعات بالساعة';

  @override
  String shiftOpenTime(String time) {
    return 'فتح: $time';
  }

  @override
  String shiftCloseTime(String time) {
    return 'إغلاق: $time';
  }

  @override
  String hoursMinutes(int hours, int minutes) {
    return '$hoursس $minutesد';
  }

  @override
  String get shiftOpenStatus => 'مفتوح';

  @override
  String invoiceCountWithNum(int count) {
    return '$count فاتورة';
  }

  @override
  String get permissionsSaved => 'تم حفظ الصلاحيات';

  @override
  String get jobRole => 'الدور الوظيفي';

  @override
  String get manageProducts => 'إدارة المنتجات';

  @override
  String get viewReports => 'عرض التقارير';

  @override
  String get refundOperations => 'عمليات الاسترداد';

  @override
  String get manageCustomersPermission => 'إدارة العملاء';

  @override
  String get manageOffers => 'إدارة العروض';

  @override
  String get savePermissions => 'حفظ الصلاحيات';

  @override
  String get deactivateAccount => 'تعطيل الحساب';

  @override
  String get activateAccount => 'تفعيل الحساب';

  @override
  String confirmDeactivateAccount(String name) {
    return 'هل تريد تعطيل حساب $name؟';
  }

  @override
  String confirmActivateAccount(String name) {
    return 'هل تريد تفعيل حساب $name؟';
  }

  @override
  String get deactivate => 'تعطيل';

  @override
  String get activate => 'تفعيل';

  @override
  String get accountActivated => 'تم تفعيل الحساب';

  @override
  String get accountDeactivated => 'تم تعطيل الحساب';

  @override
  String get employeeAttendance => 'حضور وانصراف الموظفين';

  @override
  String get presentLabel => 'حاضر';

  @override
  String get absentLabel => 'غائب';

  @override
  String get attendanceCount => 'الحضور';

  @override
  String get absencesCount => 'الغياب';

  @override
  String get lateCount => 'متأخر';

  @override
  String get totalEmployees => 'إجمالي الموظفين';

  @override
  String noAttendanceRecordsForDay(int day, int month) {
    return 'لا يوجد سجلات حضور ليوم $day/$month';
  }

  @override
  String get workingNow => 'يعمل الآن';

  @override
  String get loyaltyTierCustomizeHint =>
      'يمكنك تخصيص مستويات برنامج الولاء وتحديد النقاط والمزايا لكل مستوى.';

  @override
  String memberCount(int count) {
    return '$count عضو';
  }

  @override
  String get pointsRequired => 'النقاط المطلوبة';

  @override
  String get discountPercentage => 'نسبة الخصم';

  @override
  String get pointsMultiplier => 'مضاعف النقاط';

  @override
  String get addTier => 'إضافة مستوى';

  @override
  String get addNewTier => 'إضافة مستوى جديد';

  @override
  String get nameArabic => 'الاسم (عربي)';

  @override
  String get nameEnglish => 'Name (English)';

  @override
  String get minPoints => 'الحد الأدنى من النقاط';

  @override
  String get maxPointsHint => 'الحد الأقصى (اتركه فارغاً = غير محدود)';

  @override
  String multiplierLabel(String value) {
    return 'مضاعف النقاط: ${value}x';
  }

  @override
  String tierBenefits(String tier) {
    return 'مزايا مستوى $tier';
  }

  @override
  String discountOnPurchases(String value) {
    return '• خصم $value% على المشتريات';
  }

  @override
  String pointsPerPurchase(String value) {
    return '• ${value}x نقاط على كل عملية شراء';
  }

  @override
  String get whatsappManagement => 'إدارة WhatsApp';

  @override
  String get messageQueue => 'قائمة الانتظار';

  @override
  String get templates => 'القوالب';

  @override
  String get sentStatus => 'مُرسل';

  @override
  String get failedStatus => 'فشل';

  @override
  String get noMessages => 'لا توجد رسائل';

  @override
  String get retrySend => 'إعادة الإرسال';

  @override
  String get requeuedMessage => 'تمت إعادة الإرسال إلى قائمة الانتظار';

  @override
  String templateCount(int count) {
    return '$count قالب';
  }

  @override
  String get newTemplate => 'قالب جديد';

  @override
  String get editTemplate => 'تعديل القالب';

  @override
  String get templateName => 'اسم القالب';

  @override
  String get messageText => 'نص الرسالة';

  @override
  String templateVariablesHint(
      Object customer_name, Object store_name, Object total) {
    return 'استخدم $store_name $customer_name $total كمتغيرات';
  }

  @override
  String get apiSettings => 'إعدادات API';

  @override
  String get apiKey => 'مفتاح API';

  @override
  String get testingConnection => 'جاري اختبار الاتصال...';

  @override
  String get sendSettings => 'إعدادات الإرسال';

  @override
  String get autoSend => 'الإرسال التلقائي';

  @override
  String get autoSendDescription => 'إرسال الرسائل تلقائياً بعد كل عملية';

  @override
  String get dailyMessageLimit => 'الحد اليومي للرسائل';

  @override
  String messagesPerDay(int count) {
    return '$count رسالة/يوم';
  }

  @override
  String get salesInvoiceTemplate => 'فاتورة البيع';

  @override
  String get debtReminderTemplate => 'تذكير الدين';

  @override
  String get newCustomerWelcomeTemplate => 'ترحيب بالعميل الجديد';

  @override
  String get supplierReturns => 'مرتجعات المشتريات';

  @override
  String get addItemForReturn => 'إضافة صنف للإرجاع';

  @override
  String get itemName => 'اسم الصنف';

  @override
  String get unitPrice => 'سعر الوحدة';

  @override
  String get sarSuffix => 'ر.س';

  @override
  String get pleaseAddItems => 'يرجى إضافة أصناف للإرجاع';

  @override
  String get creditNoteWillBeRecorded => 'سيتم تسجيل إشعار خصم وتعديل المخزون.';

  @override
  String get issueCreditNote => 'إصدار إشعار خصم';

  @override
  String returnRecordedSuccess(String amount) {
    return 'تم تسجيل المرتجع بنجاح - إشعار خصم: $amount ر.س';
  }

  @override
  String get selectSupplier => 'اختر المورد';

  @override
  String get damagedDefective => 'تالف / معيب';

  @override
  String get wrongItem => 'صنف خاطئ';

  @override
  String get overstockExcess => 'فائض عن الحاجة';

  @override
  String get addItem => 'إضافة صنف';

  @override
  String get noItemsAddedYet => 'لم تتم إضافة أصناف بعد';

  @override
  String get notes => 'ملاحظات';

  @override
  String get additionalNotesHint => 'أي ملاحظات إضافية...';

  @override
  String get totalReturn => 'إجمالي المرتجع';

  @override
  String issueCreditNoteWithAmount(String amount) {
    return 'إصدار إشعار خصم ($amount ر.س)';
  }

  @override
  String get deliveryZones => 'مناطق التوصيل';

  @override
  String get addDeliveryZone => 'إضافة منطقة';

  @override
  String get editDeliveryZone => 'تعديل منطقة التوصيل';

  @override
  String get addDeliveryZoneTitle => 'إضافة منطقة توصيل';

  @override
  String get zoneName => 'اسم المنطقة';

  @override
  String get fromKm => 'من (كم)';

  @override
  String get toKm => 'إلى (كم)';

  @override
  String get kmUnit => 'كم';

  @override
  String get deliveryFee => 'رسوم التوصيل';

  @override
  String get minOrderAmount => 'حد أدنى للطلب';

  @override
  String get estimatedDeliveryTime => 'وقت التوصيل التقديري';

  @override
  String get minuteUnit => 'دقيقة';

  @override
  String get zoneUpdated => 'تم تحديث المنطقة';

  @override
  String get zoneAdded => 'تمت إضافة المنطقة';

  @override
  String get deleteZone => 'حذف المنطقة';

  @override
  String get deleteZoneConfirm => 'هل تريد حذف هذه المنطقة؟';

  @override
  String get activeZones => 'مناطق نشطة';

  @override
  String get lowestFee => 'أقل رسوم';

  @override
  String get highestFee => 'أعلى رسوم';

  @override
  String get noDeliveryZones => 'لا توجد مناطق توصيل';

  @override
  String get addDeliveryZonesDescription =>
      'أضف مناطق التوصيل لتحديد أسعار ونطاقات التوصيل';

  @override
  String get deliveryTime => 'وقت التوصيل';

  @override
  String get minuteAbbr => 'د';

  @override
  String get giftCards => 'بطاقات الهدايا';

  @override
  String get redeemCard => 'صرف بطاقة';

  @override
  String get issueGiftCard => 'إصدار بطاقة هدية';

  @override
  String get cardValue => 'قيمة البطاقة (ر.س)';

  @override
  String giftCardIssued(String amount) {
    return 'تم إصدار بطاقة هدية بقيمة $amount ر.س';
  }

  @override
  String get issueCard => 'إصدار البطاقة';

  @override
  String get redeemGiftCard => 'صرف بطاقة هدية';

  @override
  String get cardCode => 'كود البطاقة';

  @override
  String get noCardWithCode => 'لا توجد بطاقة بهذا الكود';

  @override
  String get cardBalanceZero => 'رصيد البطاقة صفر';

  @override
  String cardBalance(String amount) {
    return 'رصيد البطاقة: $amount ر.س';
  }

  @override
  String get verify => 'تحقق';

  @override
  String get cardsTab => 'البطاقات';

  @override
  String get statisticsTab => 'الإحصائيات';

  @override
  String get searchByCode => 'بحث بالكود...';

  @override
  String get activeFilter => 'نشطة';

  @override
  String get usedFilter => 'مستخدمة';

  @override
  String get expiredFilter => 'منتهية';

  @override
  String get noGiftCards => 'لا توجد بطاقات هدايا';

  @override
  String get issueGiftCardsDescription => 'أصدر بطاقات هدايا لعملائك';

  @override
  String get totalActiveBalance => 'إجمالي الرصيد النشط';

  @override
  String get totalIssuedValue => 'إجمالي القيمة المصدرة';

  @override
  String get activeCards => 'البطاقات النشطة';

  @override
  String get usedCards => 'البطاقات المستخدمة';

  @override
  String get giftCardStatusActive => 'نشطة';

  @override
  String get giftCardStatusPartiallyUsed => 'مستخدمة جزئياً';

  @override
  String get giftCardStatusFullyUsed => 'مستخدمة بالكامل';

  @override
  String get giftCardStatusExpired => 'منتهية الصلاحية';

  @override
  String balanceDisplay(String balance, String total) {
    return 'الرصيد: $balance/$total ر.س';
  }

  @override
  String expiresOn(String date) {
    return 'ينتهي: $date';
  }

  @override
  String get onlineOrders => 'الطلبات الإلكترونية';

  @override
  String get statusNew => 'جديد';

  @override
  String get statusPreparing => 'قيد التجهيز';

  @override
  String get statusReady => 'جاهز';

  @override
  String get statusShipped => 'تم الشحن';

  @override
  String get statusDelivered => 'تم التسليم';

  @override
  String get statusReadyForPickup => 'جاهز للاستلام';

  @override
  String get nextStatusAcceptOrder => 'قبول الطلب';

  @override
  String get nextStatusReady => 'جاهز';

  @override
  String get nextStatusShipped => 'تم الشحن';

  @override
  String get nextStatusDelivered => 'تم التسليم';

  @override
  String timeAgoMinutes(int minutes) {
    return 'منذ $minutes دقيقة';
  }

  @override
  String timeAgoHours(int hours) {
    return 'منذ $hours ساعة';
  }

  @override
  String get damagedAndLostGoods => 'البضاعة التالفة والمفقودة';

  @override
  String get damagedDefectiveShort => 'تالف / معيب';

  @override
  String get expiredShort => 'منتهي الصلاحية';

  @override
  String get theftLoss => 'سرقة / فقدان';

  @override
  String get wasteBreakage => 'هدر / كسر';

  @override
  String get unknownProduct => 'منتج غير محدد';

  @override
  String get recordDamagedGoods => 'تسجيل بضاعة تالفة';

  @override
  String get costPerUnit => 'التكلفة/وحدة';

  @override
  String get lossType => 'نوع الخسارة';

  @override
  String get damagedGoodsRecorded => 'تم تسجيل البضاعة التالفة بنجاح';

  @override
  String get periodLabel => 'الفترة';

  @override
  String get totalLosses => 'إجمالي الخسائر';

  @override
  String get noDamagedGoods => 'لا توجد بضاعة تالفة';

  @override
  String get noDamagedGoodsInPeriod => 'لا توجد بضاعة تالفة في هذه الفترة';

  @override
  String get recordDamagedGoodsFab => 'تسجيل بضاعة تالفة';

  @override
  String quantityWithValue(String qty) {
    return 'الكمية: $qty';
  }

  @override
  String get purchaseDetails => 'تفاصيل طلب الشراء';

  @override
  String get purchaseNotFound => 'لم يتم العثور على طلب الشراء';

  @override
  String get backToList => 'العودة للقائمة';

  @override
  String get statusDraft => 'مسودة';

  @override
  String get statusSent => 'مُرسل';

  @override
  String get statusApproved => 'موافق عليه';

  @override
  String get statusReceived => 'مستلم';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get supplierInfoLabel => 'المورد';

  @override
  String get dateLabel => 'التاريخ';

  @override
  String get orderTimeline => 'مسار الطلب';

  @override
  String get actionsLabel => 'الإجراءات';

  @override
  String get sendToDistributor => 'إرسال للموزع';

  @override
  String get awaitingDistributorResponse => 'في انتظار رد الموزع';

  @override
  String get goodsReceived => 'تم استلام البضاعة';

  @override
  String get orderItems => 'أصناف الطلب';

  @override
  String itemCountLabel(int count) {
    return '$count صنف';
  }

  @override
  String get productColumn => 'المنتج';

  @override
  String get quantityColumn => 'الكمية';

  @override
  String get receivedColumn => 'المستلم';

  @override
  String get unitPriceColumn => 'سعر الوحدة';

  @override
  String get totalColumn => 'الإجمالي';

  @override
  String quantityInfo(int qty, int received, String price) {
    return 'الكمية: $qty  |  المستلم: $received  |  $price ر.س';
  }

  @override
  String get receivingGoods => 'استلام البضاعة';

  @override
  String get unsavedChanges => 'تغييرات غير محفوظة';

  @override
  String get leaveWithoutSaving => 'هل تريد المغادرة بدون حفظ التغييرات؟';

  @override
  String get leave => 'مغادرة';

  @override
  String receivingGoodsTitle(String number) {
    return 'استلام البضاعة - $number';
  }

  @override
  String get orderData => 'بيانات الطلب';

  @override
  String get receivedItems => 'الأصناف المستلمة';

  @override
  String orderedQty(int qty) {
    return 'الطلب: $qty';
  }

  @override
  String get receivedQtyLabel => 'المستلم';

  @override
  String get receivingInfo => 'بيانات الاستلام';

  @override
  String get receiverName => 'اسم المستلم *';

  @override
  String get receivingNotes => 'ملاحظات الاستلام';

  @override
  String get confirmingReceipt => 'جاري التأكيد...';

  @override
  String get confirmReceipt => 'تأكيد الاستلام';

  @override
  String get purchaseOrders => 'طلبات الشراء';

  @override
  String get statusApprovedShort => 'موافق';

  @override
  String get orderNumberColumn => 'رقم الطلب';

  @override
  String get statusColumn => 'الحالة';

  @override
  String get noPurchaseOrders => 'لا توجد طلبات شراء';

  @override
  String get createPurchaseToStart => 'أنشئ طلب شراء جديد للبدء';

  @override
  String get errorLoadingData => 'حدث خطأ في تحميل البيانات';

  @override
  String get sendToDistributorTitle => 'إرسال الطلب للموزع';

  @override
  String get orderInfo => 'معلومات الطلب';

  @override
  String get currentSupplier => 'المورد الحالي';

  @override
  String get itemsSummary => 'ملخص الأصناف';

  @override
  String get distributorSupplier => 'الموزع / المورد';

  @override
  String get additionalMessage => 'رسالة إضافية';

  @override
  String get addNotesForDistributor => 'أضف ملاحظات أو رسالة للموزع...';

  @override
  String get sending => 'جاري الإرسال...';

  @override
  String get pleaseSelectDistributor => 'يرجى اختيار الموزع';

  @override
  String errorSendingOrder(String message) {
    return 'خطأ في إرسال الطلب: $message';
  }

  @override
  String get employeeCommissions => 'عمولات الموظفين';

  @override
  String get totalDueCommissions => 'إجمالي العمولات المستحقة';

  @override
  String forEmployees(int count) {
    return 'لـ $count موظف';
  }

  @override
  String get noCommissions => 'لا توجد عمولات';

  @override
  String get noSalesInPeriod => 'لا توجد مبيعات في هذه الفترة';

  @override
  String invoicesSales(int count, String amount) {
    return '$count فاتورة - مبيعات: $amount ر.س';
  }

  @override
  String get commissionLabel => 'عمولة';

  @override
  String targetLabel(String amount) {
    return 'الهدف: $amount ر.س';
  }

  @override
  String achievedPercent(String percent) {
    return '$percent% مُحقق';
  }

  @override
  String commissionRate(String percent) {
    return 'نسبة العمولة: $percent%';
  }

  @override
  String get priceLists => 'قوائم الأسعار';

  @override
  String get retailPrice => 'سعر التجزئة';

  @override
  String get retailPriceDesc => 'السعر العادي للعملاء الأفراد';

  @override
  String get wholesalePrice => 'سعر الجملة';

  @override
  String get wholesalePriceDesc => 'أسعار مخفضة لكميات كبيرة';

  @override
  String get vipPrice => 'أسعار VIP';

  @override
  String get vipPriceDesc => 'أسعار خاصة للعملاء المميزين';

  @override
  String get costPriceList => 'سعر التكلفة';

  @override
  String get costPriceDesc => 'للاستخدام الداخلي فقط';

  @override
  String editPrice(String name) {
    return 'تعديل السعر - $name';
  }

  @override
  String basePriceLabel(String price) {
    return 'السعر الأساسي: $price ر.س';
  }

  @override
  String costPriceLabel(String price) {
    return 'سعر التكلفة: $price ر.س';
  }

  @override
  String newPriceLabel(String listName) {
    return 'السعر الجديد ($listName)';
  }

  @override
  String priceUpdated(String name, String price) {
    return 'تم تحديث سعر \"$name\" إلى $price ر.س';
  }

  @override
  String productCount(int count) {
    return '$count منتج';
  }

  @override
  String baseLabel(String price) {
    return 'أساسي: $price ر.س';
  }

  @override
  String get errorLoadingHeldInvoices => 'خطأ في تحميل الفواتير المعلقة';

  @override
  String get saleSaveFailed => 'فشل حفظ البيع';

  @override
  String errorSavingSaleMessage(String error) {
    return 'حدث خطأ أثناء حفظ عملية البيع. السلة لم تُمسح.\n\n$error';
  }

  @override
  String get ok => 'حسناً';

  @override
  String get invoiceNote => 'ملاحظة على الفاتورة';

  @override
  String get addNoteHint => 'أضف ملاحظة...';

  @override
  String get clearNote => 'مسح';

  @override
  String get quickNoteDelivery => 'توصيل';

  @override
  String get quickNoteGiftWrap => 'تغليف هدية';

  @override
  String get quickNoteFragile => 'هش - حساس';

  @override
  String get quickNoteUrgent => 'عاجل';

  @override
  String get quickNoteReservation => 'حجز';

  @override
  String get enterPhoneNumber => 'أدخل رقم الجوال';

  @override
  String whatsappSendError(String error) {
    return 'تعذر إرسال واتساب: $error';
  }

  @override
  String get sendReceiptViaWhatsapp => 'إرسال الفاتورة عبر واتساب';

  @override
  String get invoiceNumberTitle => 'رقم الفاتورة';

  @override
  String get amountPaidTitle => 'المبلغ المدفوع';

  @override
  String get sentLabel => 'تم الإرسال';

  @override
  String get newSaleButton => 'بيع جديدة';

  @override
  String get enterValidAmountError => 'أدخل مبلغ صحيح';

  @override
  String get amountExceedsMaxError => 'المبلغ يجب أن لا يتجاوز 999,999.99';

  @override
  String get amountExceedsRemainingError => 'المبلغ أكبر من المتبقي';

  @override
  String get amountBetweenZeroAndMax => 'المبلغ يجب أن يكون بين 0 و 999,999.99';

  @override
  String get amountLessThanTotal => 'المبلغ المستلم أقل من الإجمالي';

  @override
  String get selectCustomerFirstError => 'يجب اختيار العميل أولاً';

  @override
  String get debtLimitExceededError => 'تم تجاوز حد الدين للعميل';

  @override
  String get completePaymentFirstError => 'أكمل الدفع أولاً';

  @override
  String get completePaymentLabel => 'إتمام الدفع';

  @override
  String get receivedAmountLabel => 'المبلغ المستلم';

  @override
  String get sarPrefix => 'ر.س ';

  @override
  String get selectCustomerLabel => 'اختر العميل';

  @override
  String get currentBalanceTitle => 'الرصيد الحالي';

  @override
  String get creditLimitTitle => 'حد الائتمان';

  @override
  String get creditLimitAmount => '500.00 ر.س';

  @override
  String get debtLimitExceededWarning => 'تجاوز حد الدين!';

  @override
  String get selectCustomerFirstButton => 'اختر العميل أولاً';

  @override
  String get splitPaymentTitle => 'الدفع المقسم';

  @override
  String splitPaymentDone(int count) {
    return 'دفع مقسم ✅ ($count طرق)';
  }

  @override
  String get splitPaymentLabel => 'دفع مقسم';

  @override
  String get addPaymentEntry => 'إضافة دفعة';

  @override
  String get confirmSplitPayment => 'تأكيد الدفع';

  @override
  String get completePaymentToConfirm => 'أكمل الدفع أولاً';

  @override
  String get enterValidAmountSplit => 'أدخل مبلغ صحيح';

  @override
  String get amountExceedsSplit => 'المبلغ أكبر من المتبقي';

  @override
  String get bestSellingPress19 => 'الأكثر مبيعاً (اضغط 1-9)';

  @override
  String get quickSearchHintFull => 'بحث سريع (اسم / كود / باركود)...';

  @override
  String noResultsForQuery(String query) {
    return 'لا توجد نتائج لـ \"$query\"';
  }

  @override
  String addQtyToCart(int qty) {
    return 'إضافة $qty للسلة';
  }

  @override
  String availableStock(String qty) {
    return 'المتوفر: $qty';
  }

  @override
  String priceSar(String price) {
    return '$price ر.س';
  }

  @override
  String loyaltyPointsDiscountLabel(int points) {
    return 'خصم نقاط الولاء ($points نقطة)';
  }

  @override
  String pointsRedemptionInvoice(String id) {
    return 'استبدال نقاط - فاتورة $id';
  }

  @override
  String pointsEarnedInvoice(String id) {
    return 'نقاط مكتسبة - فاتورة $id';
  }

  @override
  String availableLoyaltyPoints(String points, String amount) {
    return 'نقاط الولاء المتاحة: $points نقطة (تساوي $amount ريال)';
  }

  @override
  String get useLoyaltyPoints => 'استخدام نقاط الولاء';

  @override
  String pointsCountHint(String max) {
    return 'عدد النقاط (الحد الأقصى $max)';
  }

  @override
  String get pointsUnitLabel => 'نقطة';

  @override
  String discountAmountSar(String amount) {
    return 'خصم: $amount ريال';
  }

  @override
  String get allPointsLabel => 'كل النقاط';

  @override
  String pointsCountLabel(String count) {
    return '$count نقطة';
  }

  @override
  String newOrderNotification(String id) {
    return 'طلب جديد #$id';
  }

  @override
  String get onlineOrdersTooltip => 'الطلبات الأونلاين';

  @override
  String productCountItems(int count) {
    return '$count منتج';
  }

  @override
  String get acceptAndPrint => 'قبول وطباعة';

  @override
  String get deliverToDriver => 'تسليم للسائق';

  @override
  String get onTheWayStatus => 'في الطريق';

  @override
  String driverNameLabel(String name) {
    return 'السائق: $name';
  }

  @override
  String get deliveredStatus => 'تم التسليم';

  @override
  String agoMinutes(int count) {
    return 'منذ $count دقيقة';
  }

  @override
  String agoHours(int count) {
    return 'منذ $count ساعة';
  }

  @override
  String moreProductsLabel(int count) {
    return '+ $count منتجات أخرى';
  }

  @override
  String get onlineOrdersTitle => 'الطلبات الأونلاين';

  @override
  String pendingOrdersCount(int count) {
    return '$count طلب بانتظار القبول';
  }

  @override
  String get inPreparationTab => 'قيد التجهيز';

  @override
  String get inDeliveryTab => 'في التوصيل';

  @override
  String get noOrdersMessage => 'لا توجد طلبات';

  @override
  String get newOrdersAppearHere => 'الطلبات الجديدة ستظهر هنا';

  @override
  String get rejectOrderTitle => 'رفض الطلب';

  @override
  String get rejectOrderConfirm => 'هل أنت متأكد من رفض هذا الطلب؟';

  @override
  String get rejectedBySeller => 'رفض من البائع';

  @override
  String printingOrderMessage(String id) {
    return 'طباعة الطلب $id...';
  }

  @override
  String get selectDriverTitle => 'اختر السائق';

  @override
  String orderDeliveredToDriver(String name) {
    return 'تم تسليم الطلب للسائق $name';
  }

  @override
  String get walkInCustomerLabel => 'عميل عابر';

  @override
  String get continueWithoutCustomer => 'متابعة بدون تحديد عميل';

  @override
  String get addNewCustomerButton => 'إضافة عميل جديد';

  @override
  String loyaltyPointsCountLabel(String count) {
    return '$count نقطة';
  }

  @override
  String customerBalanceAmount(String amount) {
    return '$amount ر.س';
  }

  @override
  String get noResultsFoundTitle => 'لا توجد نتائج';

  @override
  String get tryAnotherSearch => 'جرب البحث بكلمة أخرى';

  @override
  String get selectCustomerTitle => 'اختيار عميل';

  @override
  String get searchByNameOrPhoneHint => 'البحث بالاسم أو رقم الهاتف...';

  @override
  String quickSaleHold(String time) {
    return 'بيع سريع $time';
  }

  @override
  String get holdInvoiceTitle => 'تعليق الفاتورة';

  @override
  String get holdInvoiceNameLabel => 'اسم الفاتورة المعلقة';

  @override
  String get holdAction => 'تعليق';

  @override
  String heldMessage(String name) {
    return 'تم تعليق: $name';
  }

  @override
  String holdError(String error) {
    return 'خطأ في التعليق: $error';
  }

  @override
  String get storeLabel => 'المتجر';

  @override
  String get featureNotAvailableNow => 'هذه الميزة غير متاحة حالياً';

  @override
  String get cancelInvoiceError => 'حدث خطأ أثناء إلغاء الفاتورة';

  @override
  String get invoiceLoadError => 'حدث خطأ في تحميل الفاتورة';

  @override
  String get syncConflicts => 'تعارضات المزامنة';

  @override
  String itemsNeedReview(int count) {
    return '$count عنصر يحتاج مراجعة';
  }

  @override
  String get needsAttention => 'يحتاج اهتمام';

  @override
  String get seriousProblems => 'مشاكل خطيرة';

  @override
  String syncPartialSuccess(int success, int failed) {
    return 'تمت مزامنة $success عنصر، فشل $failed';
  }

  @override
  String syncErrorMessage(String error) {
    return 'خطأ في المزامنة: $error';
  }

  @override
  String get networkError => 'خطأ في الاتصال بالخادم';

  @override
  String get dataLoadFailed => 'فشل تحميل البيانات';

  @override
  String get unexpectedError => 'حدث خطأ غير متوقع';

  @override
  String get cashierPerformance => 'أداء الكاشير';

  @override
  String get resetStatsAction => 'إعادة تعيين';

  @override
  String get statsReset => 'تم إعادة تعيين الإحصائيات';

  @override
  String get averageSaleTime => 'متوسط وقت البيع';

  @override
  String get operationsPerHour => 'عمليات/ساعة';

  @override
  String get errorRateLabel => 'نسبة الأخطاء';

  @override
  String get completedOperations => 'عمليات مكتملة';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String operationsPendingSync(int count) {
    return '$count عملية في انتظار المزامنة';
  }

  @override
  String get connectionRestored => 'تم استعادة الاتصال';

  @override
  String get connectedLabel => 'متصل';

  @override
  String get disconnectedLabel => 'غير متصل';

  @override
  String offlineWithPending(int count) {
    return 'غير متصل - $count عمليات في الانتظار';
  }

  @override
  String syncingWithCount(int count) {
    return 'جاري المزامنة... ($count عمليات)';
  }

  @override
  String syncErrorWithCount(int count) {
    return 'خطأ في المزامنة - $count عمليات معلقة';
  }

  @override
  String pendingSyncWithCount(int count) {
    return '$count عمليات في انتظار المزامنة';
  }

  @override
  String get connectedAllSynced => 'متصل - كل البيانات مزامنة';

  @override
  String get dataSavedLocally =>
      'البيانات محفوظة محلياً وستتم مزامنتها عند الاتصال';

  @override
  String get uploadingData => 'يتم رفع البيانات إلى السيرفر...';

  @override
  String get errorWillRetry => 'حدث خطأ، ستتم إعادة المحاولة تلقائياً';

  @override
  String get syncSoon => 'ستتم المزامنة خلال ثوان';

  @override
  String get allDataSynced => 'كل البيانات محدثة ومزامنة';

  @override
  String get cashierMode => 'وضع الكاشير';

  @override
  String get collapseMenu => 'طي القائمة';

  @override
  String get expandMenu => 'توسيع القائمة';

  @override
  String get screenLoadError => 'حدث خطأ أثناء تحميل الشاشة';

  @override
  String get screenLoadTimeout => 'تجاوز وقت تحميل الشاشة';

  @override
  String get timeoutCheckConnection =>
      'انتهى وقت الانتظار. تحقق من اتصالك بالإنترنت.';

  @override
  String get retryLaterMessage => 'يرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get howWasOperation => 'كيف كانت هذه العملية؟';

  @override
  String get fastLabel => 'سريعة ✓';

  @override
  String get whatToImprove => 'ما الذي يمكن تحسينه؟';

  @override
  String get helpUsImprove => 'مساعدتك تفيدنا في تحسين التطبيق';

  @override
  String get writeNoteOptional => 'اكتب ملاحظتك (اختياري)...';

  @override
  String get thanksFeedback => 'شكراً لتقييمك! 👍';

  @override
  String get thanksWillImprove => 'شكراً! سنعمل على التحسين 🙏';

  @override
  String get noRatingsYet => 'لا توجد تقييمات بعد';

  @override
  String get customerRatings => 'تقييمات العملاء';

  @override
  String get fastOperations => 'عمليات سريعة';

  @override
  String get averageRating => 'متوسط التقييم';

  @override
  String get totalRatings => 'إجمالي التقييمات';

  @override
  String undoCompleted(String description) {
    return 'تم التراجع: $description';
  }

  @override
  String get payables => 'المستحقات';

  @override
  String get notAvailableLabel => 'غير متاح';

  @override
  String get browseSupplierCatalogNotAvailable =>
      'تصفح كتالوج الموردين - هذه الميزة غير متاحة حالياً';

  @override
  String get selectedSuffix => '، محدد';

  @override
  String get disabledSuffix => '، معطل';

  @override
  String get doubleTapToToggle => 'انقر مرتين لتغيير الحالة';

  @override
  String get loadingPleaseWait => 'جاري التحميل...';

  @override
  String get posSystemLabel => 'نظام نقطة البيع';

  @override
  String get pageNotFoundTitle => 'خطأ';

  @override
  String pageNotFoundMessage(String path) {
    return 'الصفحة غير موجودة: $path';
  }

  @override
  String get noShipmentsToReceive => 'لا توجد شحنات للاستلام';

  @override
  String get approvedOrdersAppearHere =>
      'ستظهر هنا الطلبات المعتمدة الجاهزة للاستلام';

  @override
  String get unspecifiedSupplier => 'مورد غير محدد';

  @override
  String get viewItems => 'عرض البنود';

  @override
  String get receivingInProgress => 'جارٍ الاستلام...';

  @override
  String get confirmReceivingBtn => 'تأكيد الاستلام';

  @override
  String orderItemsTitle(String number) {
    return 'بنود الطلب $number';
  }

  @override
  String get noOrderItems => 'لا توجد بنود';

  @override
  String get confirmReceiveGoodsTitle => 'تأكيد استلام البضاعة';

  @override
  String confirmReceiveGoodsBody(String number) {
    return 'هل أنت متأكد من استلام الطلب $number؟\nسيتم تحديث المخزون تلقائياً.';
  }

  @override
  String orderReceivedSuccess(String number) {
    return 'تم استلام الطلب $number بنجاح';
  }

  @override
  String get quickPurchaseRequest => 'طلب شراء سريع';

  @override
  String get searchAndAddProducts => 'ابحث عن منتجات وأضفها للطلب';

  @override
  String get requestedProducts => 'المنتجات المطلوبة';

  @override
  String get productCountSummary => 'عدد المنتجات';

  @override
  String get totalQuantitySummary => 'إجمالي الكمية';

  @override
  String get addNotesForManager => 'أضف ملاحظات للمدير (اختياري)...';

  @override
  String get sendRequestBtn => 'إرسال الطلب';

  @override
  String get validQuantityRequired => 'يرجى إدخال كمية صحيحة لجميع المنتجات';

  @override
  String get requestSentToManager => 'تم إرسال الطلب للمدير';

  @override
  String get connectionSuccessMsg => 'تم الاتصال بنجاح';

  @override
  String connectionFailedMsgErr(String error) {
    return 'فشل الاتصال: $error';
  }

  @override
  String get deviceSavedMsg => 'تم حفظ الجهاز';

  @override
  String saveErrorMsg(String error) {
    return 'خطأ في حفظ الإعدادات: $error';
  }

  @override
  String get addPaymentDeviceTitle => 'إضافة جهاز دفع';

  @override
  String get setupNewDeviceSubtitle => 'إعداد جهاز جديد';

  @override
  String get quickAccessKeysSubtitle => 'مفاتيح الوصول السريع';

  @override
  String devicesAddedCount(int count) {
    return '$count أجهزة مضافة';
  }

  @override
  String get managePreferencesSubtitle => 'إدارة التفضيلات';

  @override
  String get storeNameAddressLogo => 'الاسم، العنوان والشعار';

  @override
  String get receiptHeaderFooterLogo => 'رأس وتذييل الفاتورة والشعار';

  @override
  String get posPaymentNavSubtitle => 'نقطة البيع، الدفع والتنقل';

  @override
  String get usersAndPermissions => 'المستخدمين والصلاحيات';

  @override
  String get rolesAndAccess => 'الأدوار والوصول';

  @override
  String get backupAutoRestore => 'نسخ احتياطي واستعادة تلقائية';

  @override
  String get privacyAndDataRights => 'الخصوصية وحقوق البيانات';

  @override
  String get arabicEnglish => 'عربي/إنجليزي';

  @override
  String get darkLightMode => 'الوضع الداكن/الفاتح';

  @override
  String get clearCacheTitle => 'مسح الذاكرة المؤقتة';

  @override
  String get clearCacheSubtitle => 'حل مشاكل التحميل والبيانات';

  @override
  String get clearCacheDialogBody =>
      'سيتم مسح جميع البيانات المؤقتة وإعادة تحميلها من السيرفر.\n\nسيتم تسجيل خروجك وإعادة تشغيل التطبيق.\n\nهل تريد المتابعة؟';

  @override
  String get clearAndRestart => 'مسح وإعادة التشغيل';

  @override
  String get clearingCacheProgress => 'جاري مسح الذاكرة المؤقتة...';

  @override
  String get printerInitFailed => 'فشل تهيئة خدمة الطباعة';

  @override
  String get noPrintersFound => 'لم يتم العثور على طابعات';

  @override
  String searchErrorMsg(String error) {
    return 'خطأ في البحث: $error';
  }

  @override
  String connectedToPrinterName(String name) {
    return 'تم الاتصال بـ $name';
  }

  @override
  String connectionFailedToPrinter(String name) {
    return 'فشل الاتصال بـ $name';
  }

  @override
  String get enterPrinterIpAddress => 'أدخل عنوان IP للطابعة';

  @override
  String get printerNotConnectedMsg => 'الطابعة غير متصلة';

  @override
  String get testPageSentSuccess => 'تم إرسال صفحة الاختبار بنجاح';

  @override
  String testFailedMsg(String error) {
    return 'فشل الاختبار: $error';
  }

  @override
  String errorMsgGeneric(String error) {
    return 'خطأ: $error';
  }

  @override
  String get cashDrawerOpened => 'تم فتح درج النقود';

  @override
  String cashDrawerFailed(String error) {
    return 'فشل: $error';
  }

  @override
  String get disconnectedMsg => 'تم قطع الاتصال';

  @override
  String connectedPrinterStatus(String name) {
    return 'متصل: $name';
  }

  @override
  String get notConnectedStatus => 'غير متصل';

  @override
  String get connectedToPrinterMsg => 'متصل بالطابعة';

  @override
  String get noPrinterConnectedMsg => 'لا توجد طابعة متصلة';

  @override
  String get openDrawerBtn => 'فتح الدرج';

  @override
  String get disconnectBtn => 'قطع';

  @override
  String get connectPrinterTitle => 'اتصال بطابعة';

  @override
  String get connectionTypeLabel => 'نوع الاتصال';

  @override
  String get bluetoothLabel => 'بلوتوث';

  @override
  String get networkLabel => 'شبكة';

  @override
  String get printerIpAddressLabel => 'عنوان IP للطابعة';

  @override
  String get connectBtn => 'اتصال';

  @override
  String get searchingPrintersLabel => 'جاري البحث...';

  @override
  String get searchPrintersBtn => 'بحث عن طابعات';

  @override
  String discoveredPrintersTitle(int count) {
    return 'الطابعات المكتشفة ($count)';
  }

  @override
  String get connectedBadge => 'متصل';

  @override
  String get printSettingsTitle => 'إعدادات الطباعة';

  @override
  String get autoPrintTitle => 'طباعة تلقائية';

  @override
  String get autoPrintSubtitle => 'طباعة الفاتورة تلقائياً بعد كل عملية بيع';

  @override
  String get paperSizeSubtitle => 'عرض ورق الطباعة الحرارية';

  @override
  String get customizeReceiptSubtitle => 'تخصيص الإيصال';

  @override
  String get viewStoreDetailsSubtitle => 'عرض تفاصيل المتجر';

  @override
  String get usersAndPermissionsTitle => 'المستخدمين والصلاحيات';

  @override
  String usersCountLabel(int count) {
    return '$count مستخدم';
  }

  @override
  String get noPrinterSetup => 'لم يتم إعداد طابعة';

  @override
  String get printerNotConnectedErr => 'الطابعة غير متصلة';

  @override
  String get transactionRecordedSuccess => 'تم تسجيل المعاملة بنجاح';

  @override
  String productSearchFailed(String error) {
    return 'فشل البحث عن المنتج: $error';
  }

  @override
  String customerSearchFailed(String error) {
    return 'فشل البحث عن العميل: $error';
  }

  @override
  String get inventoryUpdatedMsg => 'تم تحديث المخزون';

  @override
  String get scanOrEnterBarcode => 'امسح أو أدخل الباركود';

  @override
  String get priceUpdatedMsg => 'تم تحديث السعر';

  @override
  String get exchangeSuccessMsg => 'تم الاستبدال بنجاح';

  @override
  String get refundProcessedSuccess => 'تمت معالجة الاسترجاع بنجاح';

  @override
  String get backupCompletedTitle => 'اكتمل النسخ الاحتياطي';

  @override
  String backupCompletedBody(int rows, String size) {
    return 'اكتمل النسخ الاحتياطي — $rows صف، $size ميجابايت';
  }

  @override
  String backupFailedMsg(String error) {
    return 'فشل النسخ الاحتياطي: $error';
  }

  @override
  String get copyBackupInstructions =>
      'انسخ بيانات النسخ الاحتياطي للحافظة لحفظها أو مشاركتها.';

  @override
  String get closeBtn => 'إغلاق';

  @override
  String get backupCopiedToClipboard => 'تم نسخ النسخة الاحتياطية للحافظة';

  @override
  String get copyToClipboardBtn => 'نسخ للحافظة';

  @override
  String get countDenominationsBtn => 'عد العملات بالفئات';

  @override
  String get privacyPolicyTitle => 'سياسة الخصوصية';

  @override
  String get privacyPolicySubtitle => 'الخصوصية وحقوق البيانات';

  @override
  String get privacyIntroTitle => 'مقدمة';

  @override
  String get privacyIntroBody =>
      'نحن في الحي نلتزم بحماية خصوصيتك وبياناتك الشخصية. توضح هذه السياسة كيف نجمع ونستخدم ونحمي بياناتك عند استخدام تطبيق نقطة البيع.';

  @override
  String get privacyLastUpdated => 'آخر تحديث: مارس 2026';

  @override
  String get privacyDataCollectedTitle => 'البيانات التي نجمعها';

  @override
  String get privacyStoreData =>
      'بيانات المتجر: اسم المتجر، العنوان، الرقم الضريبي، الشعار.';

  @override
  String get privacyProductData =>
      'بيانات المنتجات: أسماء المنتجات، الأسعار، الباركود، المخزون.';

  @override
  String get privacySalesData =>
      'بيانات المبيعات: الفواتير، طرق الدفع، المبالغ، التاريخ والوقت.';

  @override
  String get privacyCustomerData =>
      'بيانات العملاء: الاسم، رقم الهاتف، البريد الإلكتروني (اختياري)، سجل المشتريات.';

  @override
  String get privacyEmployeeData =>
      'بيانات الموظفين: اسم المستخدم، الدور، سجل الورديات.';

  @override
  String get privacyDeviceData =>
      'بيانات الجهاز: نوع الجهاز، نظام التشغيل (لأغراض الدعم الفني فقط).';

  @override
  String get privacyHowWeUseTitle => 'كيف نستخدم بياناتك';

  @override
  String get privacyUsePOS =>
      'تشغيل نظام نقطة البيع ومعالجة المبيعات والمدفوعات.';

  @override
  String get privacyUseReports =>
      'إنشاء التقارير والإحصائيات لمساعدتك في إدارة متجرك.';

  @override
  String get privacyUseAccounts => 'إدارة حسابات العملاء والديون والولاء.';

  @override
  String get privacyUseInventory => 'إدارة المخزون وتتبع المنتجات.';

  @override
  String get privacyUseBackup => 'النسخ الاحتياطي واستعادة البيانات.';

  @override
  String get privacyUsePerformance => 'تحسين أداء التطبيق وإصلاح الأخطاء.';

  @override
  String get privacyNoSellData =>
      'لا نبيع بياناتك لأطراف ثالثة. لا نستخدم بياناتك لأغراض إعلانية.';

  @override
  String get privacyProtectionTitle => 'كيف نحمي بياناتك';

  @override
  String get privacyLocalStorage =>
      'التخزين المحلي: جميع بيانات المبيعات والعملاء تُخزن محلياً على جهازك.';

  @override
  String get privacyEncryption =>
      'التشفير: البيانات الحساسة مشفرة باستخدام تقنيات التشفير الحديثة.';

  @override
  String get privacyBackupProtection =>
      'النسخ الاحتياطي: يمكنك إنشاء نسخ احتياطية مشفرة من بياناتك.';

  @override
  String get privacyAuthentication =>
      'المصادقة: الوصول محمي بكلمة مرور وصلاحيات المستخدمين.';

  @override
  String get privacyOffline =>
      'العمل بدون إنترنت: التطبيق يعمل 100% بدون اتصال، بياناتك لا تُرسل لخوادم خارجية.';

  @override
  String get privacyRightsTitle => 'حقوقك';

  @override
  String get privacyRightAccess => 'حق الوصول';

  @override
  String get privacyRightAccessDesc =>
      'يحق لك الاطلاع على جميع بياناتك المخزنة في التطبيق في أي وقت.';

  @override
  String get privacyRightCorrection => 'حق التصحيح';

  @override
  String get privacyRightCorrectionDesc =>
      'يحق لك تعديل أو تصحيح أي بيانات غير دقيقة.';

  @override
  String get privacyRightDeletion => 'حق الحذف';

  @override
  String get privacyRightDeletionDesc =>
      'يحق لك طلب حذف بياناتك الشخصية. يمكنك حذف بيانات العملاء من شاشة إدارة العملاء.';

  @override
  String get privacyRightExport => 'حق التصدير';

  @override
  String get privacyRightExportDesc =>
      'يحق لك تصدير نسخة من بياناتك بصيغة JSON.';

  @override
  String get privacyRightWithdrawal => 'حق الإلغاء';

  @override
  String get privacyRightWithdrawalDesc =>
      'يحق لك إلغاء أي موافقة سابقة على معالجة بياناتك.';

  @override
  String get privacyDataDeletionTitle => 'حذف البيانات';

  @override
  String get privacyDataDeletionIntro =>
      'يمكنك حذف بيانات العملاء من خلال إعدادات التطبيق. عند حذف بيانات عميل:';

  @override
  String get privacyDataDeletionPersonal =>
      'يتم حذف المعلومات الشخصية (الاسم، الهاتف، البريد) بشكل نهائي.';

  @override
  String get privacyDataDeletionAnonymize =>
      'يتم إخفاء هوية العميل في سجلات المبيعات السابقة (تظهر كـ \"عميل محذوف\").';

  @override
  String get privacyDataDeletionAccounts =>
      'يتم حذف حسابات الديون والعناوين المرتبطة.';

  @override
  String get privacyDataDeletionWarning =>
      'ملاحظة: لا يمكن التراجع عن حذف البيانات بعد تنفيذه.';

  @override
  String get privacyContactTitle => 'التواصل معنا';

  @override
  String get privacyContactIntro =>
      'إذا كان لديك أي أسئلة حول سياسة الخصوصية أو ترغب في ممارسة حقوقك، يمكنك التواصل معنا عبر:';

  @override
  String get privacyContactEmail => 'البريد الإلكتروني: privacy@alhai.app';

  @override
  String get privacyContactSupport => 'الدعم الفني داخل التطبيق';

  @override
  String get onboardingPrivacyPolicy => 'سياسة الخصوصية | Privacy Policy';

  @override
  String get cashierDefaultName => 'كاشير';

  @override
  String get defaultAddress => 'الرياض - المملكة العربية السعودية';

  @override
  String get loadMoreBtn => 'تحميل المزيد';

  @override
  String get countCurrencyBtn => 'عد العملات';

  @override
  String get searchLogsHint => 'بحث في السجلات...';

  @override
  String get noSearchResultsForQuery => 'لا توجد نتائج للبحث';

  @override
  String get noLogsToDisplay => 'لا توجد سجلات للعرض';

  @override
  String get auditActionLogin => 'تسجيل دخول';

  @override
  String get auditActionLogout => 'تسجيل خروج';

  @override
  String get auditActionSale => 'بيع';

  @override
  String get auditActionCancelSale => 'إلغاء بيع';

  @override
  String get auditActionRefund => 'استرجاع';

  @override
  String get auditActionAddProduct => 'إضافة منتج';

  @override
  String get auditActionEditProduct => 'تعديل منتج';

  @override
  String get auditActionDeleteProduct => 'حذف منتج';

  @override
  String get auditActionPriceChange => 'تغيير سعر';

  @override
  String get auditActionStockAdjust => 'تعديل مخزون';

  @override
  String get auditActionStockReceive => 'استلام مخزون';

  @override
  String get auditActionOpenShift => 'فتح وردية';

  @override
  String get auditActionCloseShift => 'إغلاق وردية';

  @override
  String get auditActionSettingsChange => 'تغيير إعدادات';

  @override
  String get auditActionCashDrawer => 'درج النقد';

  @override
  String get permCategoryPosLabel => 'نقطة البيع';

  @override
  String get permCategoryProductsLabel => 'المنتجات';

  @override
  String get permCategoryInventoryLabel => 'المخزون';

  @override
  String get permCategoryCustomersLabel => 'العملاء';

  @override
  String get permCategorySalesLabel => 'المبيعات';

  @override
  String get permCategoryReportsLabel => 'التقارير';

  @override
  String get permCategorySettingsLabel => 'الإعدادات';

  @override
  String get permCategoryStaffLabel => 'الموظفين';

  @override
  String get permPosAccess => 'الوصول لنقطة البيع';

  @override
  String get permPosAccessDesc => 'الوصول إلى شاشة نقطة البيع';

  @override
  String get permPosHold => 'تعليق الفواتير';

  @override
  String get permPosHoldDesc => 'تعليق الفواتير واستكمالها لاحقاً';

  @override
  String get permPosSplitPayment => 'تقسيم الدفع';

  @override
  String get permPosSplitPaymentDesc => 'تقسيم الدفع بين طرق مختلفة';

  @override
  String get permProductsView => 'عرض المنتجات';

  @override
  String get permProductsViewDesc => 'عرض قائمة المنتجات وتفاصيلها';

  @override
  String get permProductsManage => 'إدارة المنتجات';

  @override
  String get permProductsManageDesc => 'إضافة وتعديل المنتجات';

  @override
  String get permProductsDelete => 'حذف المنتجات';

  @override
  String get permProductsDeleteDesc => 'حذف المنتجات من النظام';

  @override
  String get permInventoryView => 'عرض المخزون';

  @override
  String get permInventoryViewDesc => 'عرض كميات المخزون';

  @override
  String get permInventoryManage => 'إدارة المخزون';

  @override
  String get permInventoryManageDesc => 'إدارة المخزون والنقل';

  @override
  String get permInventoryAdjust => 'تعديل المخزون';

  @override
  String get permInventoryAdjustDesc => 'تعديل كميات المخزون يدوياً';

  @override
  String get permCustomersView => 'عرض العملاء';

  @override
  String get permCustomersViewDesc => 'عرض بيانات العملاء';

  @override
  String get permCustomersManage => 'إدارة العملاء';

  @override
  String get permCustomersManageDesc => 'إضافة وتعديل العملاء';

  @override
  String get permCustomersDelete => 'حذف العملاء';

  @override
  String get permCustomersDeleteDesc => 'حذف العملاء من النظام';

  @override
  String get permDiscountsApply => 'تطبيق الخصومات';

  @override
  String get permDiscountsApplyDesc => 'تطبيق خصومات موجودة';

  @override
  String get permDiscountsCreate => 'إنشاء الخصومات';

  @override
  String get permDiscountsCreateDesc => 'إنشاء خصومات جديدة';

  @override
  String get permRefundsRequest => 'طلب استرجاع';

  @override
  String get permRefundsRequestDesc => 'طلب استرجاع للمنتجات';

  @override
  String get permRefundsApprove => 'الموافقة على استرجاع';

  @override
  String get permRefundsApproveDesc => 'الموافقة على طلبات الاسترجاع';

  @override
  String get permReportsView => 'عرض التقارير';

  @override
  String get permReportsViewDesc => 'عرض التقارير والإحصائيات';

  @override
  String get permReportsExport => 'تصدير التقارير';

  @override
  String get permReportsExportDesc => 'تصدير التقارير بصيغ مختلفة';

  @override
  String get permSettingsView => 'عرض الإعدادات';

  @override
  String get permSettingsViewDesc => 'عرض إعدادات النظام';

  @override
  String get permSettingsManage => 'إدارة الإعدادات';

  @override
  String get permSettingsManageDesc => 'تعديل إعدادات النظام';

  @override
  String get permStaffView => 'عرض الموظفين';

  @override
  String get permStaffViewDesc => 'عرض قائمة الموظفين';

  @override
  String get permStaffManage => 'إدارة الموظفين';

  @override
  String get permStaffManageDesc => 'إضافة وتعديل الموظفين';

  @override
  String get roleSystemAdmin => 'مدير النظام';

  @override
  String get roleSystemAdminDesc => 'صلاحيات كاملة للنظام';

  @override
  String get roleStoreManager => 'مدير المتجر';

  @override
  String get roleStoreManagerDesc => 'إدارة المتجر والموظفين';

  @override
  String get roleCashierDesc => 'عمليات البيع والدفع';

  @override
  String get roleWarehouseKeeper => 'أمين مخزن';

  @override
  String get roleWarehouseKeeperDesc => 'إدارة المخزون والمنتجات';

  @override
  String get roleAccountant => 'محاسب';

  @override
  String get roleAccountantDesc => 'التقارير المالية والحسابات';

  @override
  String connectionFailedMsg(String error) {
    return 'فشل الاتصال: $error';
  }

  @override
  String settingsSaveErrorMsg(String error) {
    return 'خطأ في حفظ الإعدادات: $error';
  }

  @override
  String get cutPaperBtn => 'قطع';

  @override
  String upgradeToPlan(String name) {
    return 'الترقية إلى $name';
  }

  @override
  String get manageDeliveryZonesAndPricing => 'إدارة مناطق التوصيل وأسعارها';

  @override
  String settingsForName(String name) {
    return 'إعدادات $name';
  }

  @override
  String settingsSavedForName(String name) {
    return 'تم حفظ إعدادات $name';
  }

  @override
  String get jobProfile => 'الملف الوظيفي';

  @override
  String get submitToZatcaAuthority => 'إرسال للهيئة الزكاة والضريبة';

  @override
  String get submitBtn => 'إرسال';

  @override
  String get submitToAuthority => 'إرسال للهيئة';

  @override
  String shareError(String error) {
    return 'خطأ في المشاركة: $error';
  }

  @override
  String upgradePlanPriceBody(String price) {
    return 'سعر الخطة: $price ريال/شهر\n\nهل تريد المتابعة؟';
  }

  @override
  String get upgradeContactMsg => 'سيتم التواصل معك لإتمام عملية الترقية';

  @override
  String get zatcaSubmitBody =>
      'سيتم إرسال بيانات الفوترة الإلكترونية للهيئة. تأكد من صحة بياناتك أولاً.';

  @override
  String get zatcaLinkComingSoon =>
      'سيتم الربط بنظام ZATCA قريباً - تأكد من إعداد الشهادة الرقمية';

  @override
  String get enterApiKey => 'أدخل مفتاح API';

  @override
  String get accountNumber => 'رقم الحساب';

  @override
  String get superAdmin => 'المشرف العام';

  @override
  String get platformOverview => 'نظرة عامة على المنصة';

  @override
  String get activeStores => 'المتاجر النشطة';

  @override
  String get totalRevenue => 'إجمالي الإيرادات';

  @override
  String get subscriptionStats => 'إحصائيات الاشتراكات';

  @override
  String get churnRate => 'معدل التسرب';

  @override
  String get conversionRate => 'معدل التحويل';

  @override
  String get trialConversion => 'تحويل التجربة';

  @override
  String get newSignups => 'اشتراكات جديدة';

  @override
  String get monthlyRecurringRevenue => 'الإيرادات الشهرية المتكررة';

  @override
  String get annualRecurringRevenue => 'الإيرادات السنوية المتكررة';

  @override
  String get storesList => 'المتاجر';

  @override
  String get storeDetail => 'تفاصيل المتجر';

  @override
  String get createStore => 'إنشاء متجر';

  @override
  String get storeOwner => 'مالك المتجر';

  @override
  String get storeStatus => 'الحالة';

  @override
  String get storeCreatedAt => 'تاريخ الإنشاء';

  @override
  String get storePlan => 'الخطة';

  @override
  String get suspendStore => 'تعليق المتجر';

  @override
  String get activateStore => 'تفعيل المتجر';

  @override
  String get upgradePlan => 'ترقية الخطة';

  @override
  String get downgradePlan => 'تخفيض الخطة';

  @override
  String get storeUsageStats => 'إحصائيات الاستخدام';

  @override
  String get storeTransactions => 'المعاملات';

  @override
  String get storeProducts => 'عدد المنتجات';

  @override
  String get storeEmployees => 'الموظفين';

  @override
  String get onboardingForm => 'نموذج التسجيل';

  @override
  String get ownerName => 'اسم المالك';

  @override
  String get ownerPhone => 'هاتف المالك';

  @override
  String get ownerEmail => 'بريد المالك';

  @override
  String get businessType => 'نوع النشاط';

  @override
  String get branchCountLabel => 'عدد الفروع';

  @override
  String get subscriptionManagement => 'إدارة الاشتراكات';

  @override
  String get plansManagement => 'إدارة الخطط';

  @override
  String get subscriptionList => 'الاشتراكات';

  @override
  String get billingAndInvoices => 'الفوترة والفواتير';

  @override
  String get planName => 'اسم الخطة';

  @override
  String get planPrice => 'السعر';

  @override
  String get planFeatures => 'المميزات';

  @override
  String get basicPlan => 'أساسي';

  @override
  String get advancedPlan => 'متقدم';

  @override
  String get professionalPlan => 'احترافي';

  @override
  String get monthlyPrice => 'السعر الشهري';

  @override
  String get yearlyPrice => 'السعر السنوي';

  @override
  String get maxBranches => 'أقصى عدد فروع';

  @override
  String get maxProducts => 'أقصى عدد منتجات';

  @override
  String get maxUsers => 'أقصى عدد مستخدمين';

  @override
  String get createPlan => 'إنشاء خطة';

  @override
  String get editPlan => 'تعديل الخطة';

  @override
  String get activeSubscriptions => 'الاشتراكات النشطة';

  @override
  String get expiredSubscriptions => 'الاشتراكات المنتهية';

  @override
  String get trialSubscriptions => 'الاشتراكات التجريبية';

  @override
  String get billingHistory => 'سجل الفوترة';

  @override
  String get invoiceDate => 'التاريخ';

  @override
  String get invoiceAmount => 'المبلغ';

  @override
  String get invoiceStatus => 'الحالة';

  @override
  String get unpaid => 'غير مدفوعة';

  @override
  String get platformUsers => 'مستخدمو المنصة';

  @override
  String get userDetail => 'تفاصيل المستخدم';

  @override
  String get roleManagement => 'إدارة الأدوار';

  @override
  String get userRole => 'الدور';

  @override
  String get userLastActive => 'آخر نشاط';

  @override
  String get superAdminRole => 'مشرف عام';

  @override
  String get supportRole => 'دعم فني';

  @override
  String get viewerRole => 'مشاهد';

  @override
  String get assignRole => 'تعيين دور';

  @override
  String get analytics => 'التحليلات';

  @override
  String get revenueAnalytics => 'تحليلات الإيرادات';

  @override
  String get usageAnalytics => 'تحليلات الاستخدام';

  @override
  String get mrrGrowth => 'نمو الإيرادات الشهرية';

  @override
  String get arrGrowth => 'نمو الإيرادات السنوية';

  @override
  String get revenueByPlan => 'الإيرادات حسب الخطة';

  @override
  String get revenueByMonth => 'الإيرادات حسب الشهر';

  @override
  String get activeUsersPerStore => 'المستخدمون النشطون لكل متجر';

  @override
  String get transactionsPerStore => 'المعاملات لكل متجر';

  @override
  String get avgTransactionsPerDay => 'متوسط المعاملات/يوم';

  @override
  String get topStoresByRevenue => 'أفضل المتاجر حسب الإيرادات';

  @override
  String get topStoresByTransactions => 'أفضل المتاجر حسب المعاملات';

  @override
  String get platformSettings => 'إعدادات المنصة';

  @override
  String get zatcaConfig => 'إعدادات ZATCA';

  @override
  String get paymentGateways => 'بوابات الدفع';

  @override
  String get systemHealth => 'صحة النظام';

  @override
  String get systemMonitoring => 'مراقبة النظام';

  @override
  String get serverStatus => 'حالة الخادم';

  @override
  String get apiLatency => 'زمن استجابة API';

  @override
  String get errorRate => 'معدل الأخطاء';

  @override
  String get cpuUsage => 'استخدام المعالج';

  @override
  String get memoryUsage => 'استخدام الذاكرة';

  @override
  String get diskUsage => 'استخدام القرص';

  @override
  String get degraded => 'متدهور';

  @override
  String get down => 'متوقف';

  @override
  String get lastChecked => 'آخر فحص';

  @override
  String get filterByStatus => 'تصفية حسب الحالة';

  @override
  String get filterByPlan => 'تصفية حسب الخطة';

  @override
  String get allStatuses => 'جميع الحالات';

  @override
  String get allPlans => 'جميع الخطط';

  @override
  String get suspended => 'معلق';

  @override
  String get trial => 'تجريبي';

  @override
  String get searchStores => 'البحث في المتاجر...';

  @override
  String get searchUsers => 'البحث في المستخدمين...';

  @override
  String get noStoresFound => 'لا توجد متاجر';

  @override
  String get noUsersFound => 'لا يوجد مستخدمون';

  @override
  String get confirmSuspend => 'هل أنت متأكد من تعليق هذا المتجر؟';

  @override
  String get confirmActivate => 'هل أنت متأكد من تفعيل هذا المتجر؟';

  @override
  String get storeCreatedSuccess => 'تم إنشاء المتجر بنجاح';

  @override
  String get storeSuspendedSuccess => 'تم تعليق المتجر بنجاح';

  @override
  String get storeActivatedSuccess => 'تم تفعيل المتجر بنجاح';

  @override
  String get perMonth => '/شهر';

  @override
  String get perYear => '/سنة';

  @override
  String get last90Days => 'آخر 90 يوم';

  @override
  String get last12Months => 'آخر 12 شهر';

  @override
  String get growth => 'النمو';

  @override
  String get stores => 'المتاجر';
}
