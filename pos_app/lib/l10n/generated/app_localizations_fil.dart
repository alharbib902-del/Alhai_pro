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
}
