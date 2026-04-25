// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get vatNumberMissing => 'VAT number not configured';

  @override
  String get appTitle => 'पॉइंट ऑफ सेल';

  @override
  String get login => 'लॉग इन';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get welcome => 'स्वागत है';

  @override
  String get welcomeBack => 'वापसी पर स्वागत है';

  @override
  String get phone => 'फ़ोन नंबर';

  @override
  String get phoneHint => '05xxxxxxxx';

  @override
  String get phoneRequired => 'फ़ोन नंबर आवश्यक है';

  @override
  String get phoneInvalid => 'अमान्य फ़ोन नंबर';

  @override
  String get otp => 'सत्यापन कोड';

  @override
  String get otpHint => 'सत्यापन कोड दर्ज करें';

  @override
  String get otpSent => 'सत्यापन कोड भेजा गया';

  @override
  String get otpResend => 'कोड पुनः भेजें';

  @override
  String get otpExpired => 'सत्यापन कोड समाप्त हो गया';

  @override
  String get otpInvalid => 'अमान्य सत्यापन कोड';

  @override
  String otpResendIn(int seconds) {
    return '$seconds सेकंड में पुनः भेजें';
  }

  @override
  String get pin => 'पिन कोड';

  @override
  String get pinHint => 'पिन कोड दर्ज करें';

  @override
  String get pinRequired => 'पिन कोड आवश्यक है';

  @override
  String get pinInvalid => 'अमान्य पिन कोड';

  @override
  String pinAttemptsRemaining(int count) {
    return 'शेष प्रयास: $count';
  }

  @override
  String pinLocked(int minutes) {
    return 'खाता लॉक हो गया। $minutes मिनट बाद प्रयास करें';
  }

  @override
  String get home => 'होम';

  @override
  String get dashboard => 'डैशबोर्ड';

  @override
  String get pos => 'पॉइंट ऑफ सेल';

  @override
  String get products => 'उत्पाद';

  @override
  String get categories => 'श्रेणियाँ';

  @override
  String get inventory => 'इन्वेंटरी';

  @override
  String get customers => 'ग्राहक';

  @override
  String get orders => 'ऑर्डर';

  @override
  String get invoices => 'चालान';

  @override
  String get reports => 'रिपोर्ट';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get sales => 'बिक्री';

  @override
  String get salesAnalytics => 'बिक्री विश्लेषण';

  @override
  String get refund => 'वापसी';

  @override
  String get todaySales => 'आज की बिक्री';

  @override
  String get totalSales => 'कुल बिक्री';

  @override
  String get averageSale => 'औसत बिक्री';

  @override
  String get cart => 'कार्ट';

  @override
  String get cartEmpty => 'कार्ट खाली है';

  @override
  String get addToCart => 'कार्ट में जोड़ें';

  @override
  String get removeFromCart => 'कार्ट से हटाएं';

  @override
  String get clearCart => 'कार्ट साफ़ करें';

  @override
  String get checkout => 'चेकआउट';

  @override
  String get payment => 'भुगतान';

  @override
  String get paymentMethod => 'भुगतान का तरीका';

  @override
  String get cash => 'नकद';

  @override
  String get card => 'कार्ड';

  @override
  String get credit => 'उधार';

  @override
  String get transfer => 'ट्रांसफर';

  @override
  String get paymentSuccess => 'भुगतान सफल';

  @override
  String get paymentFailed => 'भुगतान विफल';

  @override
  String get price => 'मूल्य';

  @override
  String get quantity => 'मात्रा';

  @override
  String get total => 'कुल';

  @override
  String get subtotal => 'उप-योग';

  @override
  String get discount => 'छूट';

  @override
  String get tax => 'कर';

  @override
  String get vat => 'वैट';

  @override
  String get grandTotal => 'कुल योग';

  @override
  String get product => 'उत्पाद';

  @override
  String get productName => 'उत्पाद का नाम';

  @override
  String get productCode => 'उत्पाद कोड';

  @override
  String get barcode => 'बारकोड';

  @override
  String get sku => 'SKU';

  @override
  String get stock => 'स्टॉक';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String get inStock => 'उपलब्ध';

  @override
  String get customer => 'ग्राहक';

  @override
  String get customerName => 'ग्राहक का नाम';

  @override
  String get customerPhone => 'ग्राहक का फ़ोन';

  @override
  String get debt => 'कर्ज';

  @override
  String get balance => 'शेष राशि';

  @override
  String get search => 'खोज';

  @override
  String get searchHint => 'यहाँ खोजें...';

  @override
  String get filter => 'फ़िल्टर';

  @override
  String get sort => 'क्रमबद्ध करें';

  @override
  String get all => 'सभी';

  @override
  String get add => 'जोड़ें';

  @override
  String get edit => 'संपादित करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get save => 'सहेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get close => 'बंद करें';

  @override
  String get back => 'वापस';

  @override
  String get next => 'अगला';

  @override
  String get done => 'हो गया';

  @override
  String get submit => 'जमा करें';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get noData => 'कोई डेटा नहीं';

  @override
  String get noResults => 'कोई परिणाम नहीं';

  @override
  String get error => 'त्रुटि';

  @override
  String pageNotFoundPath(String path) {
    return 'Page not found: $path';
  }

  @override
  String get noInvoiceDataAvailable => 'No invoice data available';

  @override
  String get errorOccurred => 'एक त्रुटि हुई';

  @override
  String get tryAgain => 'पुनः प्रयास करें';

  @override
  String get connectionError => 'कनेक्शन त्रुटि';

  @override
  String get noInternet => 'इंटरनेट कनेक्शन नहीं';

  @override
  String get offline => 'ऑफ़लाइन';

  @override
  String get online => 'ऑनलाइन';

  @override
  String get success => 'सफलता';

  @override
  String get warning => 'चेतावनी';

  @override
  String get info => 'जानकारी';

  @override
  String get yes => 'हाँ';

  @override
  String get no => 'नहीं';

  @override
  String get today => 'आज';

  @override
  String get yesterday => 'कल';

  @override
  String get thisWeek => 'इस सप्ताह';

  @override
  String get thisMonth => 'इस महीने';

  @override
  String get shift => 'शिफ्ट';

  @override
  String get openShift => 'शिफ्ट शुरू करें';

  @override
  String get closeShift => 'शिफ्ट बंद करें';

  @override
  String get shiftSummary => 'शिफ्ट सारांश';

  @override
  String get cashDrawer => 'कैश ड्रॉअर';

  @override
  String get receipt => 'रसीद';

  @override
  String get printReceipt => 'रसीद प्रिंट करें';

  @override
  String get shareReceipt => 'रसीद शेयर करें';

  @override
  String get sync => 'सिंक';

  @override
  String get syncing => 'सिंक हो रहा है...';

  @override
  String get syncComplete => 'सिंक पूर्ण';

  @override
  String get syncFailed => 'सिंक विफल';

  @override
  String get lastSync => 'अंतिम सिंक';

  @override
  String get language => 'भाषा';

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
  String get theme => 'थीम';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get lightMode => 'लाइट मोड';

  @override
  String get systemMode => 'सिस्टम मोड';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get security => 'सुरक्षा';

  @override
  String get printer => 'प्रिंटर';

  @override
  String get backup => 'बैकअप';

  @override
  String get help => 'मदद';

  @override
  String get about => 'ऐप के बारे में';

  @override
  String get version => 'संस्करण';

  @override
  String get copyright => 'सर्वाधिकार सुरक्षित';

  @override
  String get deleteConfirmTitle => 'हटाने की पुष्टि';

  @override
  String get deleteConfirmMessage => 'क्या आप वाकई हटाना चाहते हैं?';

  @override
  String confirmDeleteItemMessage(String name) {
    return '\"$name\" हटाएँ?\nइस कार्रवाई को पूर्ववत नहीं किया जा सकता।';
  }

  @override
  String get logoutConfirmTitle => 'लॉग आउट की पुष्टि';

  @override
  String get logoutConfirmMessage => 'क्या आप वाकई लॉग आउट करना चाहते हैं?';

  @override
  String get requiredField => 'यह फ़ील्ड आवश्यक है';

  @override
  String get invalidFormat => 'अमान्य प्रारूप';

  @override
  String minLength(int min) {
    return 'कम से कम $min अक्षर होने चाहिए';
  }

  @override
  String maxLength(int max) {
    return '$max अक्षरों से कम होना चाहिए';
  }

  @override
  String get welcomeTitle => 'वापसी पर स्वागत है! 👋';

  @override
  String get welcomeSubtitle =>
      'अपनी दुकान को आसानी और तेज़ी से प्रबंधित करने के लिए साइन इन करें';

  @override
  String get welcomeSubtitleShort =>
      'अपनी दुकान प्रबंधित करने के लिए साइन इन करें';

  @override
  String get brandName => 'Al-Hal POS';

  @override
  String get brandTagline => 'स्मार्ट पॉइंट ऑफ सेल सिस्टम';

  @override
  String get enterPhoneToContinue => 'जारी रखने के लिए अपना फोन नंबर दर्ज करें';

  @override
  String get pleaseEnterValidPhone => 'कृपया वैध फोन नंबर दर्ज करें';

  @override
  String get otpSentViaWhatsApp => 'WhatsApp के माध्यम से सत्यापन कोड भेजा गया';

  @override
  String get otpResent => 'सत्यापन कोड पुनः भेजा गया';

  @override
  String get enterOtpFully => 'कृपया पूर्ण सत्यापन कोड दर्ज करें';

  @override
  String get maxAttemptsReached =>
      'अधिकतम प्रयास पूरे हो गए। कृपया नया कोड अनुरोध करें';

  @override
  String waitMinutes(int minutes) {
    return 'अधिकतम प्रयास पूरे हो गए। $minutes मिनट प्रतीक्षा करें';
  }

  @override
  String waitSeconds(int seconds) {
    return 'कृपया $seconds सेकंड प्रतीक्षा करें';
  }

  @override
  String resendIn(String time) {
    return 'पुनः भेजें ($time)';
  }

  @override
  String get resendCode => 'कोड पुनः भेजें';

  @override
  String get changeNumber => 'नंबर बदलें';

  @override
  String get verificationCode => 'सत्यापन कोड';

  @override
  String remainingAttempts(int count) {
    return 'शेष प्रयास: $count';
  }

  @override
  String get technicalSupport => 'तकनीकी सहायता';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get termsAndConditions => 'नियम और शर्तें';

  @override
  String get allRightsReserved => '© 2026 अल-हल सिस्टम। सर्वाधिकार सुरक्षित।';

  @override
  String get dayMode => 'दिन मोड';

  @override
  String get nightMode => 'रात मोड';

  @override
  String get selectBranch => 'शाखा चुनें';

  @override
  String get selectBranchDesc => 'वह शाखा चुनें जिस पर आप काम करना चाहते हैं';

  @override
  String get availableBranches => 'उपलब्ध शाखाएं';

  @override
  String branchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count शाखाएं',
      one: '1 शाखा',
      zero: 'कोई शाखा नहीं',
    );
    return '$_temp0';
  }

  @override
  String branchSelected(String name) {
    return '$name चुना गया';
  }

  @override
  String get addBranch => 'नई शाखा जोड़ें';

  @override
  String get comingSoon => 'यह सुविधा जल्द आ रही है';

  @override
  String get tryDifferentSearch => 'अलग शब्दों से खोजें';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get languageChangeInfo =>
      'अपनी पसंदीदा प्रदर्शन भाषा चुनें। परिवर्तन तुरंत लागू होंगे।';

  @override
  String get centralManagement => 'केंद्रीय प्रबंधन';

  @override
  String get centralManagementDesc =>
      'एक ही स्थान से अपनी सभी शाखाओं और गोदामों को नियंत्रित करें। सभी POS बिंदुओं पर तत्काल रिपोर्ट और इन्वेंट्री सिंक प्राप्त करें।';

  @override
  String get selectBranchToContinue => 'जारी रखने के लिए शाखा चुनें';

  @override
  String get youHaveAccessToBranches =>
      'आपके पास निम्नलिखित शाखाओं तक पहुंच है। शुरू करने के लिए एक चुनें।';

  @override
  String get searchForBranch => 'शाखा खोजें...';

  @override
  String get openNow => 'अभी खुला है';

  @override
  String closedOpensAt(String time) {
    return 'बंद (खुलता है $time)';
  }

  @override
  String get loggedInAs => 'लॉग इन के रूप में';

  @override
  String get support247 => '24/7 सहायता';

  @override
  String get analyticsTools => 'विश्लेषण उपकरण';

  @override
  String get uptime => 'अपटाइम';

  @override
  String get dashboardTitle => 'डैशबोर्ड';

  @override
  String get searchPlaceholder => 'सामान्य खोज...';

  @override
  String get mainBranch => 'मुख्य शाखा (रियाद)';

  @override
  String get todaySalesLabel => 'आज की बिक्री';

  @override
  String get ordersCountLabel => 'ऑर्डर की संख्या';

  @override
  String get newCustomersLabel => 'नए ग्राहक';

  @override
  String get stockAlertsLabel => 'स्टॉक अलर्ट';

  @override
  String get productsUnit => 'उत्पाद';

  @override
  String get salesAnalysis => 'बिक्री विश्लेषण';

  @override
  String get storePerformance => 'इस सप्ताह स्टोर का प्रदर्शन';

  @override
  String get weekly => 'साप्ताहिक';

  @override
  String get monthly => 'मासिक';

  @override
  String get yearly => 'वार्षिक';

  @override
  String get quickAction => 'त्वरित कार्रवाई';

  @override
  String get newSale => 'नई बिक्री';

  @override
  String get addProduct => 'उत्पाद जोड़ें';

  @override
  String get returnItem => 'वापसी';

  @override
  String get dailyReport => 'दैनिक रिपोर्ट';

  @override
  String get closeDay => 'दिन बंद करें';

  @override
  String get topSelling => 'सबसे ज्यादा बिकने वाले';

  @override
  String ordersToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'आज $count ऑर्डर',
      one: 'आज 1 ऑर्डर',
      zero: 'आज कोई ऑर्डर नहीं',
    );
    return '$_temp0';
  }

  @override
  String get recentTransactions => 'हालिया लेनदेन';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get orderNumber => 'ऑर्डर #';

  @override
  String get time => 'समय';

  @override
  String get status => 'स्थिति';

  @override
  String get amount => 'राशि';

  @override
  String get action => 'कार्रवाई';

  @override
  String get completed => 'पूर्ण';

  @override
  String get returned => 'लौटाया गया';

  @override
  String get pending => 'लंबित';

  @override
  String get cancelled => 'रद्द';

  @override
  String get guestCustomer => 'अतिथि ग्राहक';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मिनट पहले',
      one: '1 मिनट पहले',
    );
    return '$_temp0';
  }

  @override
  String get posSystem => 'पॉइंट ऑफ सेल सिस्टम';

  @override
  String get branchManager => 'शाखा प्रबंधक';

  @override
  String get settingsSection => 'सेटिंग्स';

  @override
  String get systemSettings => 'सिस्टम सेटिंग्स';

  @override
  String get sar => 'SAR';

  @override
  String get daily => 'दैनिक';

  @override
  String get goodMorning => 'सुप्रभात';

  @override
  String get goodEvening => 'शुभ संध्या';

  @override
  String get cashCustomer => 'नकद ग्राहक';

  @override
  String get noTransactionsToday => 'आज कोई लेन-देन नहीं';

  @override
  String get comparedToYesterday => 'कल की तुलना में';

  @override
  String get ordersText => 'आज के ऑर्डर';

  @override
  String get storeManagement => 'स्टोर प्रबंधन';

  @override
  String get finance => 'वित्त';

  @override
  String get teamSection => 'टीम';

  @override
  String get fullscreen => 'पूर्ण स्क्रीन';

  @override
  String goodMorningName(String name) {
    return 'सुप्रभात, $name!';
  }

  @override
  String goodEveningName(String name) {
    return 'शुभ संध्या, $name!';
  }

  @override
  String get shoppingCart => 'शॉपिंग कार्ट';

  @override
  String get selectOrSearchCustomer => 'ग्राहक चुनें या खोजें';

  @override
  String get newCustomer => 'नया';

  @override
  String get draft => 'ड्राफ्ट';

  @override
  String get pay => 'भुगतान';

  @override
  String get haveCoupon => 'क्या आपके पास डिस्काउंट कूपन है?';

  @override
  String discountPercent(String percent) {
    return 'छूट $percent%';
  }

  @override
  String get openDrawer => 'दराज खोलें';

  @override
  String get suspend => 'स्थगित';

  @override
  String get quantitySoldOut => 'स्टॉक खत्म';

  @override
  String get noProducts => 'कोई उत्पाद नहीं';

  @override
  String get addProductsToStart => 'शुरू करने के लिए उत्पाद जोड़ें';

  @override
  String get undoComingSoon => 'पूर्ववत करें (जल्द आ रहा है)';

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
  String get employees => 'कर्मचारी';

  @override
  String get loyaltyProgram => 'लॉयल्टी प्रोग्राम';

  @override
  String get newBadge => 'नया';

  @override
  String get technicalSupportShort => 'तकनीकी सहायता';

  @override
  String get productDetails => 'उत्पाद विवरण';

  @override
  String get stockMovements => 'स्टॉक गतिविधि';

  @override
  String get priceHistory => 'मूल्य इतिहास';

  @override
  String get salesHistory => 'बिक्री इतिहास';

  @override
  String get available => 'उपलब्ध';

  @override
  String get alertLevel => 'अलर्ट स्तर';

  @override
  String get reorderPoint => 'पुनः ऑर्डर बिंदु';

  @override
  String get revenue => 'Revenue';

  @override
  String get supplier => 'आपूर्तिकर्ता';

  @override
  String get lastSale => 'अंतिम बिक्री';

  @override
  String get printLabel => 'लेबल प्रिंट करें';

  @override
  String get copied => 'कॉपी हो गया';

  @override
  String copiedToClipboard(String label) {
    return '$label कॉपी हो गया';
  }

  @override
  String get active => 'सक्रिय';

  @override
  String get inactive => 'निष्क्रिय';

  @override
  String get profitMargin => 'लाभ मार्जिन';

  @override
  String get sellingPrice => 'बिक्री मूल्य';

  @override
  String get costPrice => 'लागत मूल्य';

  @override
  String get description => 'विवरण';

  @override
  String get noDescription => 'कोई विवरण नहीं';

  @override
  String get productNotFound => 'उत्पाद नहीं मिला';

  @override
  String get stockStatus => 'स्टॉक स्थिति';

  @override
  String get currentStock => 'वर्तमान स्टॉक';

  @override
  String get unit => 'इकाई';

  @override
  String get units => 'इकाइयाँ';

  @override
  String get date => 'तारीख';

  @override
  String get type => 'प्रकार';

  @override
  String get reference => 'संदर्भ';

  @override
  String get newBalance => 'नई शेष राशि';

  @override
  String get oldPrice => 'पुरानी कीमत';

  @override
  String get newPrice => 'नई कीमत';

  @override
  String get reason => 'कारण';

  @override
  String get invoiceNumber => 'चालान नंबर';

  @override
  String get categoryLabel => 'श्रेणी';

  @override
  String get uncategorized => 'बिना श्रेणी';

  @override
  String get noSupplier => 'कोई आपूर्तिकर्ता नहीं';

  @override
  String get moreOptions => 'अधिक विकल्प';

  @override
  String get noStockMovements => 'कोई स्टॉक गतिविधि नहीं';

  @override
  String get noPriceHistory => 'कोई मूल्य इतिहास नहीं';

  @override
  String get noSalesHistory => 'कोई बिक्री इतिहास नहीं';

  @override
  String get sale => 'बिक्री';

  @override
  String get purchase => 'खरीद';

  @override
  String get adjustment => 'समायोजन';

  @override
  String get returnText => 'वापसी';

  @override
  String get waste => 'बर्बाद';

  @override
  String get initialStock => 'प्रारंभिक स्टॉक';

  @override
  String get searchByNameOrBarcode => 'नाम या बारकोड से खोजें...';

  @override
  String get hideFilters => 'फ़िल्टर छुपाएं';

  @override
  String get showFilters => 'फ़िल्टर दिखाएं';

  @override
  String get sortByName => 'नाम';

  @override
  String get sortByPrice => 'मूल्य';

  @override
  String get sortByStock => 'स्टॉक';

  @override
  String get sortByRecent => 'हाल का';

  @override
  String get allItems => 'सभी';

  @override
  String get clearFilters => 'फ़िल्टर साफ़ करें';

  @override
  String get noBarcode => 'कोई बारकोड नहीं';

  @override
  String stockCount(int count) {
    return 'स्टॉक: $count';
  }

  @override
  String get saveChanges => 'परिवर्तन सहेजें';

  @override
  String get addTheProduct => 'उत्पाद जोड़ें';

  @override
  String get editProduct => 'उत्पाद संपादित करें';

  @override
  String get newProduct => 'नया उत्पाद';

  @override
  String get minimumQuantity => 'न्यूनतम मात्रा';

  @override
  String get selectCategory => 'श्रेणी चुनें';

  @override
  String get productImage => 'उत्पाद छवि';

  @override
  String get trackInventory => 'इन्वेंटरी ट्रैक करें';

  @override
  String get productSavedSuccess => 'उत्पाद सफलतापूर्वक सहेजा गया';

  @override
  String get productAddedSuccess => 'उत्पाद सफलतापूर्वक जोड़ा गया';

  @override
  String get deleteProduct => 'उत्पाद हटाएँ';

  @override
  String deleteProductConfirm(String name) {
    return '\"$name\" उत्पाद हटाएँ?\nइसे संग्रहित कर दिया जाएगा और बाद में पुनर्स्थापित किया जा सकता है।';
  }

  @override
  String get productDeletedSuccess => 'उत्पाद सफलतापूर्वक हटा दिया गया';

  @override
  String get scanBarcode => 'बारकोड स्कैन करें';

  @override
  String get activeProduct => 'सक्रिय उत्पाद';

  @override
  String get currency => 'SAR';

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count घंटे पहले',
      one: '1 घंटा पहले',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन पहले',
      one: '1 दिन पहले',
    );
    return '$_temp0';
  }

  @override
  String get supplierPriceUpdate => 'आपूर्तिकर्ता मूल्य अपडेट';

  @override
  String get costIncrease => 'लागत में वृद्धि';

  @override
  String get duplicateProduct => 'उत्पाद की प्रतिलिपि';

  @override
  String get categoriesManagement => 'श्रेणी प्रबंधन';

  @override
  String categoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count श्रेणियां',
      one: '1 श्रेणी',
      zero: 'कोई श्रेणी नहीं',
    );
    return '$_temp0';
  }

  @override
  String get addCategory => 'श्रेणी जोड़ें';

  @override
  String get editCategory => 'श्रेणी संपादित करें';

  @override
  String get deleteCategory => 'श्रेणी हटाएं';

  @override
  String get categoryName => 'श्रेणी का नाम';

  @override
  String get categoryNameAr => 'नाम (अरबी)';

  @override
  String get categoryNameEn => 'नाम (अंग्रेज़ी)';

  @override
  String get parentCategory => 'मूल श्रेणी';

  @override
  String get noParentCategory => 'कोई मूल श्रेणी नहीं (मुख्य)';

  @override
  String get sortOrder => 'क्रम';

  @override
  String get categoryColor => 'रंग';

  @override
  String get categoryIcon => 'आइकन';

  @override
  String get categoryDetails => 'श्रेणी विवरण';

  @override
  String get categoryCreatedAt => 'बनाने की तारीख';

  @override
  String get categoryProducts => 'श्रेणी उत्पाद';

  @override
  String get noCategorySelected => 'विवरण देखने के लिए श्रेणी चुनें';

  @override
  String get deleteCategoryConfirm =>
      'क्या आप वाकई इस श्रेणी को हटाना चाहते हैं?';

  @override
  String get categoryDeletedSuccess => 'श्रेणी सफलतापूर्वक हटा दी गई';

  @override
  String get categorySavedSuccess => 'श्रेणी सफलतापूर्वक सहेजी गई';

  @override
  String get searchCategories => 'श्रेणियां खोजें...';

  @override
  String get reorderCategories => 'क्रम बदलें';

  @override
  String get noCategories => 'कोई श्रेणी नहीं मिली';

  @override
  String get subcategories => 'उप-श्रेणियां';

  @override
  String get activeStatus => 'सक्रिय';

  @override
  String get inactiveStatus => 'निष्क्रिय';

  @override
  String get invoicesTitle => 'इनवॉइस';

  @override
  String get totalInvoices => 'कुल इनवॉइस';

  @override
  String get totalPaid => 'कुल भुगतान';

  @override
  String get totalPending => 'कुल लंबित';

  @override
  String get totalOverdue => 'कुल अतिदेय';

  @override
  String get comparedToLastMonth => 'पिछले महीने की तुलना में';

  @override
  String ofTotalDue(String percent) {
    return 'कुल बकाया का $percent%';
  }

  @override
  String invoicesWaitingPayment(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count इनवॉइस भुगतान की प्रतीक्षा में',
      one: '1 इनवॉइस भुगतान की प्रतीक्षा में',
      zero: 'कोई इनवॉइस प्रतीक्षा में नहीं',
    );
    return '$_temp0';
  }

  @override
  String get sendReminderNow => 'अभी रिमाइंडर भेजें';

  @override
  String get revenueAnalysis => 'राजस्व विश्लेषण';

  @override
  String get last7Days => 'पिछले 7 दिन';

  @override
  String get thisMonthPeriod => 'इस महीने';

  @override
  String get thisYearPeriod => 'इस साल';

  @override
  String get paymentMethods => 'भुगतान के तरीके';

  @override
  String get cashPayment => 'नकद';

  @override
  String get cardPayment => 'कार्ड';

  @override
  String get walletPayment => 'वॉलेट';

  @override
  String get saveCurrentFilter => 'वर्तमान फ़िल्टर सहेजें';

  @override
  String get statusAll => 'स्थिति: सभी';

  @override
  String get statusPaid => 'भुगतान किया';

  @override
  String get statusPending => 'लंबित';

  @override
  String get statusOverdue => 'अतिदेय';

  @override
  String get statusCancelled => 'रद्द';

  @override
  String get resetFilters => 'रीसेट';

  @override
  String get createInvoice => 'इनवॉइस बनाएं';

  @override
  String get invoiceNumberCol => 'इनवॉइस #';

  @override
  String get customerNameCol => 'ग्राहक का नाम';

  @override
  String get dateCol => 'तारीख';

  @override
  String get amountCol => 'राशि';

  @override
  String get statusCol => 'स्थिति';

  @override
  String get paymentCol => 'भुगतान';

  @override
  String get actionsCol => 'कार्यवाई';

  @override
  String get viewInvoice => 'देखें';

  @override
  String get printInvoice => 'प्रिंट';

  @override
  String get exportPdf => 'PDF';

  @override
  String get sendWhatsapp => 'व्हाट्सएप';

  @override
  String get deleteInvoice => 'हटाएं';

  @override
  String get reminder => 'रिमाइंडर';

  @override
  String get exportAll => 'सभी निर्यात';

  @override
  String get printReport => 'रिपोर्ट प्रिंट';

  @override
  String get more => 'अधिक';

  @override
  String showingResults(int from, int to, int total) {
    return '$total में से $from से $to दिखा रहे हैं';
  }

  @override
  String get newInvoice => 'नई इनवॉइस';

  @override
  String get selectCustomer => 'ग्राहक चुनें';

  @override
  String get cashCustomerGeneral => 'नकद ग्राहक (सामान्य)';

  @override
  String get addNewCustomer => '+ नया ग्राहक जोड़ें';

  @override
  String get productsSection => 'उत्पाद';

  @override
  String get addProductToInvoice => '+ उत्पाद जोड़ें';

  @override
  String get productCol => 'उत्पाद';

  @override
  String get quantityCol => 'मात्रा';

  @override
  String get priceCol => 'कीमत';

  @override
  String get dueDate => 'नियत तारीख';

  @override
  String get invoiceTotal => 'कुल:';

  @override
  String get saveInvoice => 'इनवॉइस सहेजें';

  @override
  String get deleteConfirm => 'क्या आप सुनिश्चित हैं?';

  @override
  String get deleteInvoiceMsg =>
      'क्या आप वाकई इस इनवॉइस को हटाना चाहते हैं? यह क्रिया पूर्ववत नहीं की जा सकती।';

  @override
  String get yesDelete => 'हां, हटाएं';

  @override
  String get copiedSuccess => 'सफलतापूर्वक कॉपी किया गया';

  @override
  String get invoiceDeleted => 'इनवॉइस सफलतापूर्वक हटाई गई';

  @override
  String get sat => 'शनि';

  @override
  String get sun => 'रवि';

  @override
  String get mon => 'सोम';

  @override
  String get tue => 'मंगल';

  @override
  String get wed => 'बुध';

  @override
  String get thu => 'गुरु';

  @override
  String get fri => 'शुक्र';

  @override
  String selected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चयनित',
      one: '1 चयनित',
      zero: 'कोई चयनित नहीं',
    );
    return '$_temp0';
  }

  @override
  String get bulkPrint => 'प्रिंट';

  @override
  String get bulkExportPdf => 'PDF निर्यात';

  @override
  String get allRightsReservedFooter =>
      '© 2026 Alhai POS. सर्वाधिकार सुरक्षित।';

  @override
  String get privacyPolicyFooter => 'गोपनीयता नीति';

  @override
  String get termsFooter => 'नियम और शर्तें';

  @override
  String get supportFooter => 'तकनीकी सहायता';

  @override
  String get paid => 'भुगतान किया';

  @override
  String get overdue => 'अतिदेय';

  @override
  String get creditCard => 'क्रेडिट कार्ड';

  @override
  String get electronicWallet => 'ई-वॉलेट';

  @override
  String get searchInvoiceHint => 'इनवॉइस नंबर, ग्राहक से खोजें...';

  @override
  String get customerDetails => 'ग्राहक विवरण';

  @override
  String get customerProfileAndTransactions => 'प्रोલाइल और लेन-देन का अवलोकन';

  @override
  String get customerDetailTitle => 'ग्राहक विवरण';

  @override
  String get totalPurchases => 'कुल खरीदारी';

  @override
  String get loyaltyPoints => 'लॉयल्टी पॉइंट्स';

  @override
  String get lastVisit => 'अंतिम विज़िट';

  @override
  String get newSaleAction => 'नई बिक्री';

  @override
  String get editInfo => 'जानकारी संपादित करें';

  @override
  String get whatsapp => 'व्हाट्सएप';

  @override
  String get blockCustomer => 'ग्राहक को ब्लॉक करें';

  @override
  String get purchasesTab => 'खरीदारी';

  @override
  String get accountTab => 'खाता';

  @override
  String get debtsTab => 'कर्ज़';

  @override
  String get analyticsTab => 'विश्लेषण';

  @override
  String get recentOrdersLog => 'हालिया ऑर्डर लॉग';

  @override
  String get exportCsv => 'CSV निर्यात';

  @override
  String get searchByInvoiceNumber => 'इनवॉइस नंबर से खोजें...';

  @override
  String get items => 'आइटम';

  @override
  String get viewDetails => 'विवरण देखें';

  @override
  String get financialLedger => 'वित्तीय लेनदेन रजिस्टर';

  @override
  String get cashPaymentEntry => 'नकद भुगतान';

  @override
  String get walletTopup => 'वॉलेट टॉप-अप';

  @override
  String get loyaltyPointsDeduction => 'लॉयल्टी पॉइंट्स कटौती';

  @override
  String redeemPoints(int count) {
    return '$count पॉइंट रिडीम';
  }

  @override
  String get viewFullLedger => 'पूरा देखें';

  @override
  String get currentBalance => 'वर्तमान शेष';

  @override
  String get creditLimit => 'क्रेडिट सीमा';

  @override
  String get used => 'उपयोग किया गया';

  @override
  String get topUpBalance => 'शेष राशि टॉप-अप';

  @override
  String get overdueDebt => 'अतिदेय';

  @override
  String get upcomingDebt => 'आगामी';

  @override
  String get payNow => 'अभी भुगतान करें';

  @override
  String get remind => 'रिमाइंडर';

  @override
  String get monthlySpending => 'मासिक खर्च';

  @override
  String get purchaseDistribution => 'श्रेणी के अनुसार खरीदारी वितरण';

  @override
  String get last6Months => 'पिछले 6 महीने';

  @override
  String get thisYear => 'इस साल';

  @override
  String get averageOrder => 'औसत ऑर्डर';

  @override
  String get purchaseFrequency => 'खरीदारी आवृत्ति';

  @override
  String everyNDays(int count) {
    return 'हर $count दिन';
  }

  @override
  String get spendingGrowth => 'खर्च वृद्धि';

  @override
  String get favoriteProduct => 'पसंदीदा उत्पाद';

  @override
  String get internalNotes => 'आंतरिक नोट्स (केवल कर्मचारियों के लिए दृश्य)';

  @override
  String get addNote => 'जोड़ें';

  @override
  String get addNewNote => 'नया नोट जोड़ें...';

  @override
  String joinedDate(String date) {
    return 'शामिल: $date';
  }

  @override
  String lastUpdated(String time) {
    return 'अंतिम अपडेट: $time';
  }

  @override
  String showingOrders(int from, int to, int total) {
    return '$total में से $from-$to दिखा रहे हैं';
  }

  @override
  String get vegetables => 'सब्ज़ीयां';

  @override
  String get dairy => 'डेयरी';

  @override
  String get meat => 'मांस';

  @override
  String get bakery => 'बेकरी';

  @override
  String get other => 'अन्य';

  @override
  String get returns => 'वापसी';

  @override
  String get salesReturns => 'बिक्री वापसी';

  @override
  String get purchaseReturns => 'खरीद वापसी';

  @override
  String get totalReturns => 'कुल वापसियां';

  @override
  String get totalRefundedAmount => 'कुल वापसी राशि';

  @override
  String get mostReturned => 'सबसे अधिक वापस';

  @override
  String get processed => 'वापस किया गया';

  @override
  String get newReturn => 'नई वापसी';

  @override
  String get createNewReturn => 'नई वापसी बनाएं';

  @override
  String get processReturnRequest => 'बिक्री वापसी अनुरोध';

  @override
  String get returnNumber => 'वापसी संख्या';

  @override
  String get originalInvoice => 'मूल बिल';

  @override
  String get returnReason => 'वापसी का कारण';

  @override
  String get returnAmount => 'वापसी राशि';

  @override
  String get returnStatus => 'स्थिति';

  @override
  String get returnDate => 'तारीख';

  @override
  String get returnActions => 'कार्रवाई';

  @override
  String get returnRefunded => 'वापस किया गया';

  @override
  String get returnRejected => 'अस्वीकृत';

  @override
  String get defectiveProduct => 'खराब उत्पाद';

  @override
  String get wrongProduct => 'गलत उत्पाद';

  @override
  String get customerRequest => 'ग्राहक अनुरोध';

  @override
  String get otherReason => 'अन्य';

  @override
  String get quickSearch => 'त्वरित खोज...';

  @override
  String get exportData => 'निर्यात';

  @override
  String get printData => 'प्रिंट';

  @override
  String get approve => 'मंजूर';

  @override
  String get reject => 'अस्वीकार';

  @override
  String get previous => 'पिछला';

  @override
  String get invoiceStep => 'बिल';

  @override
  String get itemsStep => 'आइटम';

  @override
  String get reasonStep => 'कारण';

  @override
  String get confirmStep => 'पुष्टि';

  @override
  String get enterInvoiceNumber => 'बिल नंबर';

  @override
  String get invoiceExample => 'उदाहरण: #INV-889';

  @override
  String get loadInvoice => 'लोड';

  @override
  String invoiceLoaded(String number) {
    return 'बिल #$number लोड हुआ';
  }

  @override
  String invoiceLoadedCustomer(String customer, String date) {
    return 'ग्राहक: $customer | तारीख: $date';
  }

  @override
  String get selectItemsInfo =>
      'वापसी के लिए आइटम चुनें। बिक्री से अधिक मात्रा वापस नहीं हो सकती।';

  @override
  String availableToReturn(int count) {
    return 'उपलब्ध: $count';
  }

  @override
  String get alreadyReturnedFully => 'पूरी मात्रा पहले ही वापस हो चुकी';

  @override
  String get returnReasonLabel => 'वापसी का कारण (चयनित आइटम के लिए)';

  @override
  String get additionalDetails => 'अतिरिक्त विवरण (अन्य के लिए आवश्यक)...';

  @override
  String get confirmReturn => 'वापसी की पुष्टि';

  @override
  String get refundAmount => 'वापसी राशि';

  @override
  String get refundMethod => 'वापसी का तरीका';

  @override
  String get cashRefund => 'नकद';

  @override
  String get storeCredit => 'स्टोर क्रेडिट';

  @override
  String get returnCreatedSuccess => 'वापसी सफलतापूर्वक बनाई गई';

  @override
  String get noReturns => 'कोई वापसी नहीं';

  @override
  String get noReturnsDesc => 'अभी तक कोई वापसी दर्ज नहीं हुई।';

  @override
  String timesReturned(int count, int percent) {
    return '$count बार ($percent% कुल में से)';
  }

  @override
  String get fromInvoice => 'बिल से';

  @override
  String get dateFromTo => 'तारीख से - तक';

  @override
  String get returnCopied => 'नंबर सफलतापूर्वक कॉपी हुआ';

  @override
  String ofTotalProcessed(int percent) {
    return '$percent% प्रोसेस हुआ';
  }

  @override
  String get invoiceDetails => 'इनवॉइस विवरण';

  @override
  String invoiceNumberLabel(String number) {
    return 'नंबर:';
  }

  @override
  String get additionalOptions => 'अतिरिक्त विकल्प';

  @override
  String get duplicateInvoice => 'डुप्लिकेट बनाएं';

  @override
  String get returnMerchandise => 'सामान वापसी';

  @override
  String get voidInvoice => 'इनवॉइस रद्द करें';

  @override
  String get printBtn => 'प्रिंट';

  @override
  String get downloadBtn => 'डाउनलोड';

  @override
  String get paidSuccessfully => 'भुगतान सफल';

  @override
  String get amountReceivedFull => 'पूरी राशि प्राप्त';

  @override
  String get completedStatus => 'पूर्ण';

  @override
  String get pendingStatus => 'लंबित';

  @override
  String get voidedStatus => 'रद्द';

  @override
  String get storeName => 'मोहल्ला सुपरमार्केट';

  @override
  String get storeAddress => 'रियाध, अल-मलज जिला, तखस्सुसी स्ट्रीट';

  @override
  String get simplifiedTaxInvoice => 'सरल कर इनवॉइस';

  @override
  String get dateAndTime => 'दिनांक और समय';

  @override
  String get cashierLabel => 'कैशियर';

  @override
  String get itemCol => 'आइटम';

  @override
  String get quantityColDetail => 'मात्रा';

  @override
  String get priceColDetail => 'कीमत';

  @override
  String get totalCol => 'कुल';

  @override
  String get subtotalLabel => 'उप-कुल';

  @override
  String get discountVip => 'छूट (VIP सदस्य)';

  @override
  String get vatLabel => 'वैट (15%)';

  @override
  String get grandTotalLabel => 'कुल योग';

  @override
  String get paymentMethodLabel => 'भुगतान विधि';

  @override
  String get amountPaidLabel => 'भुगतान राशि';

  @override
  String get zatcaElectronic => 'ZATCA - इलेक्ट्रॉनिक इनवॉइस';

  @override
  String get scanToVerify => 'सत्यापन के लिए स्कैन करें';

  @override
  String get includesVat15 => '15% वैट शामिल';

  @override
  String get thankYouVisit => 'आने के लिए धन्यवाद!';

  @override
  String get wishNiceDay => 'आपका दिन शुभ हो';

  @override
  String get customerInfo => 'ग्राहक जानकारी';

  @override
  String get editBtn => 'संपादित';

  @override
  String vipSince(String year) {
    return '$year से VIP ग्राहक';
  }

  @override
  String get activeStatusLabel => 'सक्रिय';

  @override
  String get callBtn => 'कॉल';

  @override
  String get recordBtn => 'रिकॉर्ड';

  @override
  String get quickActions => 'त्वरित कार्य';

  @override
  String get sendWhatsappAction => 'व्हाट्सएप भेजें';

  @override
  String get sendEmailAction => 'ईमेल भेजें';

  @override
  String get downloadPdfAction => 'PDF डाउनलोड';

  @override
  String get shareLinkAction => 'लिंक शेयर करें';

  @override
  String get eventLog => 'इवेंट लॉग';

  @override
  String get paymentCompleted => 'भुगतान पूर्ण';

  @override
  String get processedViaGateway => 'पेमेंट गेटवे से प्रोसेस';

  @override
  String minutesAgoDetail(int count) {
    return '$count मिनट पहले';
  }

  @override
  String get invoiceCreated => 'इनवॉइस बनाया गया';

  @override
  String byUser(String name) {
    return '$name द्वारा';
  }

  @override
  String todayAt(String time) {
    return 'आज, $time';
  }

  @override
  String get orderStarted => 'ऑर्डर शुरू';

  @override
  String get cashierSessionOpened => 'कैशियर सत्र खोला गया';

  @override
  String get technicalData => 'तकनीकी डेटा';

  @override
  String get deviceIdLabel => 'Device ID';

  @override
  String get terminalLabel => 'Terminal';

  @override
  String get softwareVersion => 'Software V';

  @override
  String get voidInvoiceConfirm => 'इनवॉइस रद्द करें?';

  @override
  String get voidInvoiceMsg =>
      'यह इनवॉइस स्थायी रूप से रद्द हो जाएगी। क्या आप सुनिश्चित हैं?';

  @override
  String get voidReasonLabel => 'रद्दीकरण कारण (आवश्यक)';

  @override
  String get voidReasonEntry => 'प्रविष्टि त्रुटि';

  @override
  String get voidReasonCustomer => 'ग्राहक अनुरोध';

  @override
  String get voidReasonDamaged => 'क्षतिग्रस्त उत्पाद';

  @override
  String get voidReasonOther => 'अन्य कारण...';

  @override
  String get confirmVoid => 'रद्दीकरण की पुष्टि';

  @override
  String get invoiceVoided => 'इनवॉइस सफलतापूर्वक रद्द';

  @override
  String copiedText(String text) {
    return 'कॉपी किया: $text';
  }

  @override
  String visaEnding(String digits) {
    return 'Visa अंतिम $digits';
  }

  @override
  String get mobileActionPrint => 'प्रिंट';

  @override
  String get mobileActionWhatsapp => 'व्हाट्सएप';

  @override
  String get mobileActionEmail => 'ईमेल';

  @override
  String get mobileActionMore => 'और';

  @override
  String get sarCurrency => 'ر.س';

  @override
  String skuLabel(String code) {
    return 'SKU: $code';
  }

  @override
  String get helpText => 'सहायता';

  @override
  String get customerLedger => 'ग्राहक खाता';

  @override
  String get accountStatement => 'खाता विवरण';

  @override
  String get allPeriods => 'सभी';

  @override
  String get threeMonths => '3 महीने';

  @override
  String get allMovements => 'सभी लेनदेन';

  @override
  String get adjustments => 'समायोजन';

  @override
  String get statementCol => 'विवरण';

  @override
  String get referenceCol => 'संदर्भ';

  @override
  String get debitCol => 'डेबिट';

  @override
  String get creditCol => 'क्रेडिट';

  @override
  String get balanceCol => 'शेष राशि';

  @override
  String get openingBalance => 'प्रारंभिक शेष';

  @override
  String get totalDebit => 'कुल डेबिट';

  @override
  String get totalCredit => 'कुल क्रेडिट';

  @override
  String get finalBalance => 'अंतिम शेष';

  @override
  String get manualAdjustment => 'मैनुअल समायोजन';

  @override
  String get adjustmentType => 'समायोजन प्रकार';

  @override
  String get debitAdjustment => 'डेबिट समायोजन';

  @override
  String get creditAdjustment => 'क्रेडिट समायोजन';

  @override
  String get adjustmentAmount => 'समायोजन राशि';

  @override
  String get adjustmentReason => 'समायोजन का कारण';

  @override
  String get adjustmentDate => 'समायोजन तिथि';

  @override
  String get saveAdjustment => 'समायोजन सहेजें';

  @override
  String get adjustmentSaved => 'समायोजन सफलतापूर्वक सहेजा गया';

  @override
  String get enterValidAmount => 'एक मान्य राशि दर्ज करें';

  @override
  String get dueOnCustomer => 'ग्राहक पर बकाया';

  @override
  String get customerHasCredit => 'ग्राहक का क्रेडिट शेष है';

  @override
  String get noTransactions => 'कोई लेनदेन नहीं';

  @override
  String get recordPaymentBtn => 'भुगतान दर्ज करें';

  @override
  String get returnEntry => 'वापसी';

  @override
  String get adjustmentEntry => 'समायोजन';

  @override
  String get ordersHistory => 'ऑर्डर हिस्ट्री';

  @override
  String get totalOrdersLabel => 'कुल ऑर्डर';

  @override
  String get completedOrders => 'पूर्ण';

  @override
  String get pendingOrders => 'लंबित';

  @override
  String get cancelledOrders => 'रद्द';

  @override
  String get searchOrderHint => 'ऑर्डर नंबर, ग्राहक, या फोन से खोजें...';

  @override
  String get channelLabel => 'चैनल';

  @override
  String get last30Days => 'पिछले 30 दिन';

  @override
  String get orderDetails => 'ऑर्डर विवरण';

  @override
  String get unpaidLabel => 'अवैतनिक';

  @override
  String get voidTransaction => 'लेनदेन रद्द करें';

  @override
  String get voidSaleTransaction => 'बिक्री लेनदेन रद्द करें';

  @override
  String get voidWarningTitle =>
      'महत्वपूर्ण चेतावनी: यह कार्रवाई पूर्ववत नहीं की जा सकती';

  @override
  String get voidWarningDesc =>
      'इस लेनदेन को रद्द करने से चालान पूरी तरह रद्द हो जाएगा।';

  @override
  String get voidWarningShort =>
      'यह कार्रवाई चालान को पूरी तरह रद्द कर देगी। पूर्ववत नहीं किया जा सकता।';

  @override
  String get enterInvoiceToVoid => 'रद्द करने के लिए चालान नंबर दर्ज करें';

  @override
  String get searchByInvoiceOrBarcode =>
      'चालान नंबर या बारकोड स्कैनर का उपयोग करें';

  @override
  String get invoiceExampleVoid => 'उदाहरण: #INV-2024-8892';

  @override
  String get activateBarcode => 'बारकोड स्कैनर सक्रिय करें';

  @override
  String get scanBarcodeMobile => 'बारकोड स्कैन करें';

  @override
  String get searchForInvoiceToVoid => 'रद्द करने के लिए चालान खोजें';

  @override
  String get enterNumberOrScan => 'नंबर दर्ज करें या बारकोड स्कैनर उपयोग करें।';

  @override
  String get salesInvoice => 'बिक्री चालान';

  @override
  String get invoiceCompleted => 'पूर्ण';

  @override
  String get paidCash => 'भुगतान: नकद';

  @override
  String get customerLabel => 'ग्राहक';

  @override
  String get dateAndTimeLabel => 'तिथि और समय';

  @override
  String get voidImpactSummary => 'रद्दीकरण प्रभाव सारांश';

  @override
  String voidImpactItemsReturn(int count) {
    return '$count वस्तुएं स्वचालित रूप से इन्वेंट्री में वापस होंगी।';
  }

  @override
  String voidImpactRefund(String amount, String currency) {
    return 'राशि $amount $currency काटी/वापस की जाएगी।';
  }

  @override
  String returnedItems(int count) {
    return 'वापसी वस्तुएं ($count)';
  }

  @override
  String get viewAllItems => 'सभी देखें';

  @override
  String moreItemsHint(int count, String amount, String currency) {
    return '+ $count और वस्तुएं (कुल: $amount $currency)';
  }

  @override
  String get voidReason => 'रद्द करने का कारण';

  @override
  String get voidReasonRequired => 'रद्द करने का कारण *';

  @override
  String get customerRequestReason => 'ग्राहक की अनुरोध';

  @override
  String get wrongItemsReason => 'गलत वस्तुएं';

  @override
  String get duplicateInvoiceReason => 'डुप्लिकेट चालान';

  @override
  String get systemErrorReason => 'सिस्टम त्रुटि';

  @override
  String get otherReasonVoid => 'अन्य';

  @override
  String get additionalNotesVoid => 'अतिरिक्त नोट्स...';

  @override
  String get additionalDetailsRequired =>
      'अतिरिक्त विवरण (अन्य के लिए आवश्यक)...';

  @override
  String get managerApproval => 'प्रबंधक की स्वीकृति';

  @override
  String get managerApprovalRequired => 'प्रबंधक की स्वीकृति आवश्यक';

  @override
  String amountExceedsLimit(String amount, String currency) {
    return 'राशि अनुमत सीमा ($amount $currency) से अधिक है, प्रबंधक PIN दर्ज करें।';
  }

  @override
  String get enterPinCode => 'PIN कोड दर्ज करें';

  @override
  String get pinSentToManager => 'अस्थायी कोड प्रबंधक के फोन पर भेजा गया';

  @override
  String get defaultManagerPin => 'डिफ़ॉल्ट प्रबंधक कोड: 1234';

  @override
  String get confirmVoidAction =>
      'मैं इस लेनदेन को रद्द करने की पुष्टि करता हूं';

  @override
  String get confirmVoidDesc =>
      'मैंने विवरण की समीक्षा की है और पूर्ण जिम्मेदारी लेता हूं।';

  @override
  String get cancelAction => 'रद्द करें';

  @override
  String get confirmFinalVoid => 'अंतिम रद्दीकरण की पुष्टि';

  @override
  String get invoiceNotFound => 'चालान नहीं मिला';

  @override
  String get invoiceNotFoundDesc =>
      'दर्ज किया गया नंबर सत्यापित करें या बारकोड उपयोग करें।';

  @override
  String get trySearchAgain => 'पुनः खोजने का प्रयास करें';

  @override
  String get voidSuccess => 'लेनदेन सफलतापूर्वक रद्द किया गया';

  @override
  String qtyLabel(int count) {
    return 'मात्रा: $count';
  }

  @override
  String get manageCustomersAndAccounts => 'ग्राहक और खाते प्रबंधित करें';

  @override
  String get totalCustomersCount => 'कुल ग्राहक';

  @override
  String get outstandingDebts => 'बकाया ऋण';

  @override
  String get creditBalance => 'ग्राहक क्रेडिट';

  @override
  String get filterByLabel => 'फ़िल्टर';

  @override
  String get debtors => 'कर्जदार';

  @override
  String get creditorsLabel => 'लेनदार';

  @override
  String get quickActionsLabel => 'त्वरित कार्य';

  @override
  String get sendDebtReminder => 'ऋण अनुस्मारक भेजें';

  @override
  String get exportAccountStatement => 'खाता विवरण निर्यात करें';

  @override
  String cancelSelectionCount(String count) {
    return 'चयन रद्द करें ($count)';
  }

  @override
  String get searchByNameOrPhone => 'नाम या फ़ोन से खोजें... (Ctrl+F)';

  @override
  String get sortByBalance => 'बैलेंस';

  @override
  String get refreshF5 => 'रिफ्रेश (F5)';

  @override
  String get loadingCustomers => 'ग्राहक लोड हो रहे हैं...';

  @override
  String get payDebt => 'ऋण भुगतान';

  @override
  String dueAmountLabel(String amount) {
    return 'बकाया: $amount रियाल';
  }

  @override
  String get paymentAmountLabel => 'भुगतान राशि';

  @override
  String get fullAmount => 'पूर्ण';

  @override
  String get payAction => 'भुगतान';

  @override
  String paymentRecorded(String amount) {
    return '$amount रियाल भुगतान दर्ज';
  }

  @override
  String customerAddedSuccess(String name) {
    return '$name जोड़ा गया';
  }

  @override
  String get customerNameRequired => 'ग्राहक का नाम *';

  @override
  String get owedLabel => 'बकाया';

  @override
  String get hasBalanceLabel => 'क्रेडिट';

  @override
  String get zeroLabel => 'शून्य';

  @override
  String get addAction => 'जोड़ें';

  @override
  String get expenses => 'खर्चे';

  @override
  String get expenseCategories => 'खर्च श्रेणियां';

  @override
  String get addExpense => 'खर्च जोड़ें';

  @override
  String get totalExpenses => 'कुल खर्चे';

  @override
  String get thisMonthExpenses => 'इस महीने';

  @override
  String get expenseAmount => 'Amount';

  @override
  String get expenseDate => 'Date';

  @override
  String get expenseCategory => 'Category';

  @override
  String get expenseNotes => 'Notes';

  @override
  String get noExpenses => 'कोई खर्च दर्ज नहीं';

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
  String get totalReceivables => 'Total Receivables';

  @override
  String get closeMonth => 'Close Month';

  @override
  String get shiftsTitle => 'शिफ्ट';

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
  String get purchasesTitle => 'खरीद';

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
  String get suppliersTitle => 'आपूर्तिकर्ता';

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
  String get discountsTitle => 'छूट';

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
  String get couponsTitle => 'कूपन';

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
  String get specialOffersTitle => 'विशेष ऑफर';

  @override
  String get addOffer => 'Add Offer';

  @override
  String get offerName => 'Offer Name';

  @override
  String get offerStartDate => 'Start Date';

  @override
  String get offerEndDate => 'End Date';

  @override
  String get smartPromotionsTitle => 'स्मार्ट प्रमोशन';

  @override
  String get activePromotions => 'Active Promotions';

  @override
  String get suggestedPromotions => 'AI Suggestions';

  @override
  String get loyaltyTitle => 'लॉयल्टी प्रोग्राम';

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
  String get notificationsTitle => 'सूचनाएं';

  @override
  String get markAllRead => 'Mark All Read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get printQueueTitle => 'प्रिंट कतार';

  @override
  String get printAll => 'Print All';

  @override
  String get cancelAll => 'Cancel All';

  @override
  String get noPrintJobs => 'No print jobs';

  @override
  String get syncStatusTitle => 'सिंक स्थिति';

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
  String get driversTitle => 'ड्राइवर';

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
  String get branchesTitle => 'शाखाएं';

  @override
  String get addBranchAction => 'Add Branch';

  @override
  String get branchName => 'Branch Name';

  @override
  String get branchEmployees => 'Employees';

  @override
  String get branchSales => 'Today\'s Sales';

  @override
  String get profileTitle => 'प्रोफाइल';

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
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get storeSettings => 'स्टोर सेटिंग्स';

  @override
  String get posSettings => 'POS सेटिंग्स';

  @override
  String get printerSettings => 'प्रिंटर सेटिंग्स';

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
  String get securitySettings => 'सुरक्षा';

  @override
  String get usersManagement => 'उपयोगकर्ता प्रबंधन';

  @override
  String get rolesPermissions => 'भूमिकाएं और अनुमतियां';

  @override
  String get activityLog => 'गतिविधि लॉग';

  @override
  String get backupSettings => 'बैकअप और रिस्टोर';

  @override
  String get notificationSettings => 'Notifications';

  @override
  String get zatcaCompliance => 'ZATCA अनुपालन';

  @override
  String get helpSupport => 'सहायता और समर्थन';

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
  String get liveChat => 'लाइव चैट';

  @override
  String get emailSupport => 'ईमेल सहायता';

  @override
  String get phoneSupport => 'फ़ोन सहायता';

  @override
  String get whatsappSupport => 'व्हाट्सएप सहायता';

  @override
  String get userGuide => 'उपयोगकर्ता गाइड';

  @override
  String get videoTutorials => 'वीडियो ट्यूटोरियल';

  @override
  String get changelog => 'परिवर्तन लॉग';

  @override
  String get appInfo => 'ऐप जानकारी';

  @override
  String get buildNumber => 'बिल्ड नंबर';

  @override
  String get notificationChannels => 'सूचना चैनल';

  @override
  String get alertTypes => 'अलर्ट के प्रकार';

  @override
  String get salesAlerts => 'बिक्री अलर्ट';

  @override
  String get inventoryAlerts => 'इन्वेंट्री अलर्ट';

  @override
  String get securityAlerts => 'सुरक्षा अलर्ट';

  @override
  String get reportAlerts => 'रिपोर्ट अलर्ट';

  @override
  String get users => 'उपयोगकर्ता';

  @override
  String get zatcaRegistered => 'ZATCA में पंजीकृत';

  @override
  String get zatcaPhase2Active => 'चरण 2 सक्रिय';

  @override
  String get zatcaQueueReportTitle => 'ZATCA जमा कतार';

  @override
  String get zatcaSent => 'भेजा गया';

  @override
  String get zatcaPendingLabel => 'लंबित';

  @override
  String get zatcaRejected => 'अस्वीकृत';

  @override
  String get zatcaPendingSection => 'लंबित चालान';

  @override
  String get zatcaRejectedSection => 'अस्वीकृत चालान';

  @override
  String get zatcaNoPendingInvoices => 'कोई लंबित चालान नहीं';

  @override
  String get zatcaNoRejectedInvoices => 'कोई अस्वीकृत चालान नहीं';

  @override
  String zatcaRetriesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पुनः प्रयास',
      one: '1 पुनः प्रयास',
      zero: 'कोई पुनः प्रयास नहीं',
    );
    return '$_temp0';
  }

  @override
  String get registrationInfo => 'पंजीकरण जानकारी';

  @override
  String get businessName => 'व्यवसाय का नाम';

  @override
  String get branchCode => 'शाखा कोड';

  @override
  String get qrCodeOnInvoice => 'इनवॉइस पर QR कोड';

  @override
  String get certificates => 'प्रमाणपत्र';

  @override
  String get csidCertificate => 'CSID प्रमाणपत्र';

  @override
  String get valid => 'मान्य';

  @override
  String get privateKey => 'निजी कुंजी';

  @override
  String get configured => 'कॉन्फ़िगर किया गया';

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
  String get aiTrend => 'प्रवृत्ति';

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
  String get aiInvestigation => 'जाँच';

  @override
  String get aiAssociationRules => 'Association Rules';

  @override
  String get aiBundleSuggestions => 'बंडल सुझाव';

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
  String get aiMarketPosition => 'बाजार स्थिति';

  @override
  String get aiQueryInput => 'Ask anything about your data...';

  @override
  String get aiReportTemplate => 'Report Template';

  @override
  String get aiStaffPerformance => 'Staff Performance';

  @override
  String get aiShiftOptimization => 'शिफ्ट अनुकूलन';

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
  String get noteOptional => 'नोट (वैकल्पिक)';

  @override
  String get suspendInvoice => 'इनवॉइस स्थगित करें';

  @override
  String get invoiceSuspended => 'इनवॉइस स्थगित हो गया';

  @override
  String nItems(int count) {
    return '$count आइटम';
  }

  @override
  String saveSaleError(String error) {
    return 'बिक्री सहेजने में त्रुटि: $error';
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
  String get copyCode => 'कॉपी';

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
  String get resetAction => 'रीसेट';

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
  String get animationsToggle => 'एनिमेशन';

  @override
  String get animationsToggleDesc => 'स्क्रीन परिवर्तन और गति';

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
  String get pasteCode => 'कोड पेस्ट करें';

  @override
  String devOtpMessage(String otp) {
    return 'डेव OTP: $otp';
  }

  @override
  String get orderHistory => 'ऑर्डर इतिहास';

  @override
  String get history => 'इतिहास';

  @override
  String get selectDateRange => 'अवधि चुनें';

  @override
  String get orderSearchHint => 'ऑर्डर नंबर या ग्राहक ID से खोजें...';

  @override
  String get noOrders => 'कोई ऑर्डर नहीं';

  @override
  String get orderStatusConfirmed => 'पुष्टि';

  @override
  String get orderStatusPreparing => 'तैयारी जारी';

  @override
  String get orderStatusReady => 'तैयार';

  @override
  String get orderStatusDelivering => 'डिलीवरी जारी';

  @override
  String get filterOrders => 'ऑर्डर फ़िल्टर करें';

  @override
  String get channelApp => 'ऐप';

  @override
  String get channelWhatsapp => 'व्हाट्सएप';

  @override
  String get channelPos => 'POS';

  @override
  String get paymentCashType => 'नकद';

  @override
  String get paymentMixed => 'मिश्रित';

  @override
  String get paymentOnline => 'ऑनलाइन';

  @override
  String get shareAction => 'शेयर';

  @override
  String get exportOrders => 'ऑर्डर निर्यात करें';

  @override
  String get selectExportFormat => 'निर्यात प्रारूप चुनें';

  @override
  String get exportedAsExcel => 'Excel के रूप में निर्यात';

  @override
  String get exportedAsPdf => 'PDF के रूप में निर्यात';

  @override
  String get alertSettings => 'अलर्ट सेटिंग्स';

  @override
  String get acknowledgeAll => 'सभी स्वीकार करें';

  @override
  String allWithCount(int count) {
    return 'सभी ($count)';
  }

  @override
  String lowStockWithCount(int count) {
    return 'कम स्टॉक ($count)';
  }

  @override
  String expiryWithCount(int count) {
    return 'समाप्ति निकट ($count)';
  }

  @override
  String get urgentAlerts => 'तत्काल अलर्ट';

  @override
  String get nearExpiry => 'समाप्ति निकट';

  @override
  String get noAlerts => 'कोई अलर्ट नहीं';

  @override
  String get alertDismissed => 'अलर्ट खारिज';

  @override
  String get undo => 'पूर्ववत करें';

  @override
  String get criticalPriority => 'गंभीर';

  @override
  String get highPriority => 'तत्काल';

  @override
  String stockAlertMessage(int current, int threshold) {
    return 'मात्रा: $current (न्यूनतम: $threshold)';
  }

  @override
  String get expiryAlertLabel => 'समाप्ति अलर्ट';

  @override
  String get currentQuantity => 'वर्तमान मात्रा';

  @override
  String get minimumThreshold => 'न्यूनतम';

  @override
  String get dismissAction => 'खारिज करें';

  @override
  String get lowStockNotifications => 'कम स्टॉक सूचनाएं';

  @override
  String get expiryNotifications => 'समाप्ति सूचनाएं';

  @override
  String get minimumStockLevel => 'न्यूनतम स्टॉक स्तर';

  @override
  String thresholdUnits(int count) {
    return '$count इकाई';
  }

  @override
  String get acknowledgeAllAlerts => 'सभी अलर्ट स्वीकार करें';

  @override
  String willDismissAlerts(int count) {
    return '$count अलर्ट खारिज होंगे';
  }

  @override
  String get allAlertsAcknowledged => 'सभी अलर्ट स्वीकार किए गए';

  @override
  String get createPurchaseOrder => 'खरीद ऑर्डर बनाएं';

  @override
  String productLabelName(String name) {
    return 'उत्पाद: $name';
  }

  @override
  String get requiredQuantity => 'आवश्यक मात्रा';

  @override
  String get createAction => 'बनाएं';

  @override
  String get purchaseOrderCreated => 'खरीद ऑर्डर बनाया गया';

  @override
  String get newCategory => 'नई श्रेणी';

  @override
  String productCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count उत्पाद',
      one: '1 उत्पाद',
      zero: 'कोई उत्पाद नहीं',
    );
    return '$_temp0';
  }

  @override
  String get iconLabel => 'आइकन:';

  @override
  String get colorLabel => 'रंग:';

  @override
  String deleteCategoryMessage(String name, int count) {
    return 'श्रेणी \"$name\" हटाएं?\n$count उत्पाद \"अवर्गीकृत\" में जाएंगे।';
  }

  @override
  String productNumber(int number) {
    return 'उत्पाद $number';
  }

  @override
  String priceWithCurrency(String price) {
    return '$price रियाल';
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
  String get selectedCustomers => 'Selected Customers';

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
    return '$productA + $productB: $frequency बार दोहराया गया';
  }

  @override
  String aiBundleActivated(String name) {
    return 'बंडल सक्रिय: $name';
  }

  @override
  String aiPromotionsGeneratedCount(int count) {
    return 'स्टोर डेटा विश्लेषण के आधार पर $count प्रचार तैयार किए गए';
  }

  @override
  String aiPromotionApplied(String title) {
    return 'लागू किया गया: $title';
  }

  @override
  String aiConfidencePercent(String percent) {
    return 'विश्वास: $percent%';
  }

  @override
  String aiAlertsWithCount(int count) {
    return 'अलर्ट ($count)';
  }

  @override
  String aiStaffCurrentSuggested(int current, int suggested) {
    return 'वर्तमान में $current कर्मचारी → $suggested सुझावित';
  }

  @override
  String aiMinutesAgo(int minutes) {
    return '$minutes मिनट पहले';
  }

  @override
  String aiHoursAgo(int hours) {
    return '$hours घंटे पहले';
  }

  @override
  String aiDaysAgo(int days) {
    return '$days दिन पहले';
  }

  @override
  String aiDetectedCount(int count) {
    return 'पता चला: $count';
  }

  @override
  String aiMatchedCount(int count) {
    return 'मिलान: $count';
  }

  @override
  String aiAccuracyPercent(String percent) {
    return 'सटीकता: $percent%';
  }

  @override
  String aiProductAccepted(String name) {
    return '$name स्वीकार किया गया';
  }

  @override
  String aiErrorOccurred(String error) {
    return 'त्रुटि हुई: $error';
  }

  @override
  String aiErrorWithMessage(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get aiBasketAnalysis => 'AI टोकरी विश्लेषण';

  @override
  String get aiAssociations => 'संबंध';

  @override
  String get aiCrossSell => 'क्रॉस-सेल';

  @override
  String get aiAvgBasketSize => 'औसत टोकरी आकार';

  @override
  String get aiProductUnit => 'उत्पाद';

  @override
  String get aiAvgBasketValue => 'औसत टोकरी मूल्य';

  @override
  String get aiSaudiRiyal => 'SAR';

  @override
  String get aiStrongestAssociation => 'सबसे मजबूत संबंध';

  @override
  String get aiConversionRate => 'रूपांतरण दर';

  @override
  String get aiFromSuggestions => 'सुझावों से';

  @override
  String get aiAssistant => 'AI सहायक';

  @override
  String get aiAskAboutStore => 'अपने स्टोर के बारे में कोई भी सवाल पूछें';

  @override
  String get aiClearChat => 'चैट साफ़ करें';

  @override
  String get aiAssistantReady => 'AI सहायक मदद के लिए तैयार है!';

  @override
  String get aiAskAboutSalesStock =>
      'बिक्री, स्टॉक, ग्राहकों या अपने स्टोर के बारे में कुछ भी पूछें';

  @override
  String get aiCompetitorAnalysis => 'प्रतिस्पर्धी विश्लेषण';

  @override
  String get aiPriceComparison => 'मूल्य तुलना';

  @override
  String get aiTrackedProducts => 'ट्रैक किए गए उत्पाद';

  @override
  String get aiCheaperThanCompetitors => 'प्रतिस्पर्धियों से सस्ता';

  @override
  String get aiMoreExpensive => 'प्रतिस्पर्धियों से अधिक महंगा';

  @override
  String get aiAvgPriceDiff => 'औसत मूल्य अंतर';

  @override
  String get aiSortByName => 'नाम से क्रमबद्ध करें';

  @override
  String get aiSortByPriceDiff => 'मूल्य अंतर से क्रमबद्ध करें';

  @override
  String get aiSortByOurPrice => 'हमारी कीमत से क्रमबद्ध करें';

  @override
  String get aiSortByCategory => 'श्रेणी से क्रमबद्ध करें';

  @override
  String get aiSortLabel => 'क्रमबद्ध';

  @override
  String get aiPriceIndex => 'मूल्य सूचकांक';

  @override
  String get aiQuality => 'गुणवत्ता';

  @override
  String get aiBranches => 'शाखाएँ';

  @override
  String get aiMarkAllRead => 'सभी को पढ़ा हुआ चिह्नित करें';

  @override
  String get aiNoAlertsCurrently => 'वर्तमान में कोई अलर्ट नहीं';

  @override
  String get aiFraudDetection => 'AI धोखाधड़ी पहचान';

  @override
  String get aiTotalAlerts => 'कुल अलर्ट';

  @override
  String get aiCriticalAlerts => 'गंभीर अलर्ट';

  @override
  String get aiNeedsReview => 'समीक्षा आवश्यक';

  @override
  String get aiRiskLevel => 'जोखिम स्तर';

  @override
  String get aiBehaviorScores => 'व्यवहार स्कोर';

  @override
  String get aiRiskMeter => 'जोखिम मीटर';

  @override
  String get aiHighRisk => 'उच्च जोखिम';

  @override
  String get aiLowRisk => 'कम जोखिम';

  @override
  String get aiPatternRefund => 'वापसी';

  @override
  String get aiPatternAfterHours => 'कार्य समय के बाद';

  @override
  String get aiPatternVoid => 'रद्द';

  @override
  String get aiPatternDiscount => 'छूट';

  @override
  String get aiPatternSplit => 'विभाजन';

  @override
  String get aiPatternCashDrawer => 'कैश ड्रॉअर';

  @override
  String get aiNoFraudAlerts => 'कोई अलर्ट नहीं';

  @override
  String get aiSelectAlertToInvestigate => 'जाँच के लिए सूची से एक अलर्ट चुनें';

  @override
  String get aiStaffAnalytics => 'कर्मचारी विश्लेषण';

  @override
  String get aiLeaderboard => 'लीडरबोर्ड';

  @override
  String get aiIndividualPerformance => 'व्यक्तिगत प्रदर्शन';

  @override
  String get aiAvgPerformance => 'औसत प्रदर्शन';

  @override
  String get aiTotalSalesLabel => 'कुल बिक्री';

  @override
  String get aiTotalTransactions => 'कुल लेनदेन';

  @override
  String get aiAvgVoidRate => 'औसत रद्द दर';

  @override
  String get aiTeamGrowth => 'टीम वृद्धि';

  @override
  String get aiLeaderboardThisWeek => 'लीडरबोर्ड - इस सप्ताह';

  @override
  String get aiSalesForecasting => 'बिक्री पूर्वानुमान';

  @override
  String get aiSmartForecastSubtitle =>
      'भविष्य की बिक्री पूर्वानुमान के लिए स्मार्ट विश्लेषण';

  @override
  String get aiForecastAccuracy => 'पूर्वानुमान सटीकता';

  @override
  String get aiTrendUp => 'ऊपर की ओर';

  @override
  String get aiTrendDown => 'नीचे की ओर';

  @override
  String get aiTrendStable => 'स्थिर';

  @override
  String get aiNextWeekForecast => 'अगले सप्ताह का पूर्वानुमान';

  @override
  String get aiMonthForecast => 'महीने का पूर्वानुमान';

  @override
  String get aiForecastSummary => 'पूर्वानुमान सारांश';

  @override
  String get aiSalesTrendingUp => 'बिक्री बढ़ रही है - जारी रखें!';

  @override
  String get aiSalesDeclining => 'बिक्री घट रही है - ऑफर सक्रिय करें';

  @override
  String get aiSalesStable => 'बिक्री स्थिर है - प्रदर्शन बनाए रखें';

  @override
  String get aiProductRecognition => 'उत्पाद पहचान';

  @override
  String get aiSingleProduct => 'एकल उत्पाद';

  @override
  String get aiShelfScan => 'शेल्फ स्कैन';

  @override
  String get aiBarcodeOcr => 'बारकोड OCR';

  @override
  String get aiPriceTag => 'मूल्य टैग';

  @override
  String get aiCameraArea => 'कैमरा क्षेत्र';

  @override
  String get aiPointCameraAtProduct => 'उत्पाद या शेल्फ की ओर कैमरा करें';

  @override
  String get aiStartScan => 'स्कैन शुरू करें';

  @override
  String get aiAnalyzingImage => 'छवि का विश्लेषण हो रहा है...';

  @override
  String get aiStartScanToSeeResults => 'परिणाम देखने के लिए स्कैन शुरू करें';

  @override
  String get aiScanResults => 'स्कैन परिणाम';

  @override
  String get aiProductSaved => 'उत्पाद सफलतापूर्वक सहेजा गया';

  @override
  String get aiPromotionDesigner => 'AI प्रचार डिज़ाइनर';

  @override
  String get aiSuggestedPromotions => 'सुझाए गए प्रचार';

  @override
  String get aiRoiAnalysis => 'ROI विश्लेषण';

  @override
  String get aiAbTest => 'A/B परीक्षण';

  @override
  String get aiSmartPromotionDesigner => 'स्मार्ट प्रचार डिज़ाइनर';

  @override
  String get aiProjectedRevenue => 'अनुमानित राजस्व';

  @override
  String get aiAiConfidence => 'AI विश्वास';

  @override
  String get aiSelectPromotionForRoi =>
      'ROI विश्लेषण देखने के लिए पहले टैब से एक प्रचार चुनें';

  @override
  String get aiRevenueLabel => 'राजस्व';

  @override
  String get aiCostLabel => 'लागत';

  @override
  String get aiDiscountLabel => 'छूट';

  @override
  String get aiAbTestDescription =>
      'A/B परीक्षण आपके ग्राहकों को दो समूहों में विभाजित करता है और सर्वश्रेष्ठ निर्धारित करने के लिए प्रत्येक समूह को अलग-अलग ऑफर दिखाता है।';

  @override
  String get aiAbTestLaunched => 'A/B परीक्षण सफलतापूर्वक लॉन्च हो गया!';

  @override
  String get aiChatWithData => 'डेटा के साथ चैट - AI';

  @override
  String get aiChatWithYourData => 'अपने डेटा के साथ चैट करें';

  @override
  String get aiAskAboutDataInArabic =>
      'अपनी बिक्री, स्टॉक और ग्राहकों के बारे में कोई भी सवाल पूछें';

  @override
  String get aiTrySampleQuestions => 'इन प्रश्नों में से एक आज़माएँ';

  @override
  String get aiTip => 'सुझाव';

  @override
  String get aiTipDescription =>
      'आप हिंदी या अंग्रेजी में पूछ सकते हैं। AI संदर्भ समझता है और परिणाम प्रदर्शित करने का सर्वोत्तम तरीका चुनता है: संख्याएँ, तालिकाएँ, या चार्ट।';

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
  String get noteLabel => 'नोट';

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
    return '$count आइटम';
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
  String get gotIt => 'समझ गए';

  @override
  String get print => 'प्रिंट';

  @override
  String get display => 'प्रदर्शन';

  @override
  String get item => 'आइटम';

  @override
  String get invoice => 'चालान';

  @override
  String get accept => 'स्वीकार करें';

  @override
  String get details => 'विवरण';

  @override
  String get newLabel => 'नया';

  @override
  String get mixed => 'मिश्रित';

  @override
  String get lowStockLabel => 'कम';

  @override
  String get stocktakingTitle => 'स्टॉक गिनती';

  @override
  String get expectedQty => 'अपेक्षित';

  @override
  String get countedQty => 'गिना गया';

  @override
  String get stockDelta => 'अंतर';

  @override
  String get saveAllAdjustments => 'समायोजन सहेजें';

  @override
  String stocktakingSavedSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count समायोजन सहेजे गए',
      one: '1 समायोजन सहेजा गया',
      zero: 'कोई समायोजन नहीं',
    );
    return '$_temp0';
  }

  @override
  String stocktakingAdjustedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count समायोजन',
      one: '1 समायोजन',
    );
    return '$_temp0';
  }

  @override
  String get stockTransfersTitle => 'शाखा-अंतरण';

  @override
  String get stockTransferNewTitle => 'नया स्टॉक ट्रांसफर';

  @override
  String get stockTransferTabOutgoing => 'बाहर जाने वाले';

  @override
  String get stockTransferTabIncoming => 'आने वाले';

  @override
  String get stockTransferFromStore => 'शाखा से';

  @override
  String get stockTransferToStore => 'शाखा को';

  @override
  String get stockTransferAddItem => 'आइटम जोड़ें';

  @override
  String get stockTransferNoItems => 'अभी कोई आइटम नहीं जोड़ा गया';

  @override
  String get stockTransferCreate => 'ट्रांसफर बनाएं';

  @override
  String get stockTransferApprove => 'मंजूर करें';

  @override
  String get stockTransferReceive => 'प्राप्त करें';

  @override
  String get stockTransferReject => 'अस्वीकार करें';

  @override
  String get stockTransferStatusPending => 'लंबित';

  @override
  String get stockTransferStatusApproved => 'मंजूर';

  @override
  String get stockTransferStatusInTransit => 'परिवहन में';

  @override
  String get stockTransferStatusReceived => 'प्राप्त';

  @override
  String get stockTransferStatusCancelled => 'रद्द';

  @override
  String get stockTransferNoOutgoing => 'कोई बाहर जाने वाला ट्रांसफर नहीं';

  @override
  String get stockTransferNoIncoming => 'कोई आने वाला ट्रांसफर नहीं';

  @override
  String get stockTransferCreatedSuccess => 'ट्रांसफर बनाया गया';

  @override
  String stockTransferItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम',
      one: '1 आइटम',
    );
    return '$_temp0';
  }

  @override
  String get debtor => 'ऋणी';

  @override
  String get creditor => 'लेनदार';

  @override
  String get balanceLabel => 'बैलेंस';

  @override
  String get returnLabel => 'वापसी';

  @override
  String get skip => 'छोड़ें';

  @override
  String get send => 'भेजें';

  @override
  String get cloud => 'क्लाउड';

  @override
  String get defaultLabel => 'डिफ़ॉल्ट';

  @override
  String get closed => 'बंद';

  @override
  String get owes => 'बकाया है';

  @override
  String get due => 'बकाया';

  @override
  String get balanced => 'संतुलित';

  @override
  String get offlineModeTitle => 'ऑफलाइन मोड';

  @override
  String get offlineModeDescription => 'आप ऐप का उपयोग जारी रख सकते हैं:';

  @override
  String get offlineCanSell => 'बिक्री करें';

  @override
  String get offlineCanAddToCart => 'उत्पाद कार्ट में जोड़ें';

  @override
  String get offlineCanPrint => 'रसीदें प्रिंट करें';

  @override
  String get offlineAutoSync => 'कनेक्शन बहाल होने पर डेटा स्वचालित सिंक होगा';

  @override
  String get offlineSavingLocally => 'ऑफलाइन - स्थानीय रूप से सहेज रहा है';

  @override
  String get seconds => 'सेकंड';

  @override
  String get errors => 'त्रुटियाँ';

  @override
  String get syncLabel => 'सिंक';

  @override
  String get slow => 'धीमा';

  @override
  String get myGrocery => 'मेरी ग्रॉसरी';

  @override
  String get cashier => 'कैशियर';

  @override
  String get goBack => 'वापस जाएं';

  @override
  String get menuLabel => 'मेनू';

  @override
  String get gold => 'स्वर्ण';

  @override
  String get silver => 'रजत';

  @override
  String get diamond => 'हीरा';

  @override
  String get bronze => 'कांस्य';

  @override
  String get saudiArabia => 'सऊदी अरब';

  @override
  String get uae => 'संयुक्त अरब अमीरात';

  @override
  String get kuwait => 'कुवैत';

  @override
  String get bahrain => 'बहरीन';

  @override
  String get qatar => 'कतर';

  @override
  String get oman => 'ओमान';

  @override
  String get control => 'नियंत्रण';

  @override
  String get strong => 'मजबूत';

  @override
  String get medium => 'मध्यम';

  @override
  String get weak => 'कमज़ोर';

  @override
  String get good => 'अच्छा';

  @override
  String get danger => 'खतरा';

  @override
  String get currentLabel => 'वर्तमान';

  @override
  String get suggested => 'सुझाया गया';

  @override
  String get actual => 'वास्तविक';

  @override
  String get forecast => 'पूर्वानुमान';

  @override
  String get critical => 'गंभीर';

  @override
  String get high => 'उच्च';

  @override
  String get low => 'कम';

  @override
  String get investigation => 'जांच';

  @override
  String get apply => 'लागू करें';

  @override
  String get run => 'चलाएं';

  @override
  String get positive => 'सकारात्मक';

  @override
  String get neutral => 'तटस्थ';

  @override
  String get negative => 'नकारात्मक';

  @override
  String get elastic => 'लचीला';

  @override
  String get demand => 'मांग';

  @override
  String get quality => 'गुणवत्ता';

  @override
  String get luxury => 'लक्जरी';

  @override
  String get economic => 'आर्थिक';

  @override
  String get ourStore => 'हमारा स्टोर';

  @override
  String get upcoming => 'आगामी';

  @override
  String get cost => 'लागत';

  @override
  String get duration => 'अवधि';

  @override
  String get quiet => 'शांत';

  @override
  String get busy => 'व्यस्त';

  @override
  String get outstanding => 'बकाया';

  @override
  String get donate => 'दान करें';

  @override
  String get day => 'दिन';

  @override
  String get days => 'दिन';

  @override
  String get projected => 'अनुमानित';

  @override
  String get analysis => 'विश्लेषण';

  @override
  String get review => 'समीक्षा';

  @override
  String get productCategory => 'श्रेणी';

  @override
  String get ourPrice => 'हमारी कीमत';

  @override
  String get position => 'पद';

  @override
  String get cheapest => 'सबसे सस्ता';

  @override
  String get mostExpensive => 'सबसे महंगा';

  @override
  String get soldOut => 'बिक चुका';

  @override
  String get noDataAvailable => 'कोई डेटा उपलब्ध नहीं';

  @override
  String get noDataFoundMessage => 'कोई डेटा नहीं मिला';

  @override
  String get noSearchResultsFound => 'कोई परिणाम नहीं मिला';

  @override
  String get noProductsFound => 'कोई उत्पाद नहीं मिला';

  @override
  String get noCustomers => 'कोई ग्राहक नहीं';

  @override
  String get addCustomersToStart => 'शुरू करने के लिए नए ग्राहक जोड़ें';

  @override
  String get noOrdersYet => 'अभी तक कोई ऑर्डर नहीं';

  @override
  String get noConnection => 'कनेक्शन नहीं';

  @override
  String get checkInternet => 'अपना इंटरनेट कनेक्शन जांचें';

  @override
  String get cartIsEmpty => 'कार्ट खाली है';

  @override
  String get browseProducts => 'उत्पाद ब्राउज़ करें';

  @override
  String noResultsFor(String query) {
    return '\"$query\" के लिए कोई परिणाम नहीं';
  }

  @override
  String get paidLabel => 'भुगतान किया';

  @override
  String get remainingLabel => 'शेष';

  @override
  String get completeLabel => 'पूर्ण';

  @override
  String get addPayment => 'जोड़ें';

  @override
  String get payments => 'भुगतान';

  @override
  String get now => 'अभी';

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
  String get averageInvoice => 'औसत चालान';

  @override
  String errorPrefix(String message, Object error) {
    return 'त्रुटि: $error';
  }

  @override
  String get vipMember => 'VIP सदस्य';

  @override
  String get activeSuppliers => 'सक्रिय आपूर्तिकर्ता';

  @override
  String get duePayments => 'बकाया भुगतान';

  @override
  String get productCatalog => 'उत्पाद कैटलॉग';

  @override
  String get comingSoonBrowseSuppliers =>
      'जल्द आ रहा है - आपूर्तिकर्ता उत्पाद ब्राउज़ करें';

  @override
  String get comingSoonTag => 'जल्द आ रहा है';

  @override
  String get supplierNotFound => 'आपूर्तिकर्ता नहीं मिला';

  @override
  String get viewAllPurchases => 'सभी खरीद देखें';

  @override
  String get completedLabel => 'पूर्ण';

  @override
  String get pendingStatusLabel => 'लंबित';

  @override
  String get registerPayment => 'भुगतान दर्ज करें';

  @override
  String errorLoadingSuppliers(Object error) {
    return 'आपूर्तिकर्ता लोड करने में त्रुटि: $error';
  }

  @override
  String get cancelLabel => 'रद्द करें';

  @override
  String get addLabel => 'जोड़ें';

  @override
  String get saveLabel => 'सहेजें';

  @override
  String purchaseInvoiceSaved(Object total) {
    return 'खरीद चालान सहेजा - कुल: $total रियाल';
  }

  @override
  String errorSavingPurchase(Object error) {
    return 'खरीद सहेजने में त्रुटि: $error';
  }

  @override
  String get smartReorderTitle => 'स्मार्ट री-ऑर्डर';

  @override
  String get smartReorderAiTitle => 'AI स्मार्ट री-ऑर्डर';

  @override
  String get budgetDescription =>
      'बजट सेट करें और सिस्टम टर्नओवर दर के आधार पर वितरित करेगा';

  @override
  String get enterValidBudget => 'कृपया वैध बजट दर्ज करें';

  @override
  String get confirmSendTitle => 'भेजने की पुष्टि';

  @override
  String sendOrderToMsg(Object supplier) {
    return 'ऑर्डर $supplier को भेजें?';
  }

  @override
  String get orderSentSuccessMsg => 'ऑर्डर सफलतापूर्वक भेजा गया';

  @override
  String sendingOrderVia(Object method) {
    return '$method के ज़रिए ऑर्डर भेजा जा रहा है...';
  }

  @override
  String stockQuantity(Object qty) {
    return 'स्टॉक: $qty';
  }

  @override
  String turnoverLabel(Object rate) {
    return 'टर्नओवर: $rate%';
  }

  @override
  String failedCapture(Object error) {
    return 'छवि लेने में विफल: $error';
  }

  @override
  String failedPickImage(Object error) {
    return 'छवि चुनने में विफल: $error';
  }

  @override
  String failedProcessInvoice(Object error) {
    return 'चालान प्रोसेस करने में विफल: $error';
  }

  @override
  String matchLabel(Object name) {
    return 'मिलान: $name';
  }

  @override
  String suggestedProduct(Object index) {
    return 'सुझाया गया उत्पाद $index';
  }

  @override
  String get barcodeLabel => 'बारकोड: 123456789';

  @override
  String get purchaseInvoiceSavedSuccess => 'खरीद चालान सफलतापूर्वक सहेजा';

  @override
  String get aiImportedInvoice => 'AI आयातित चालान';

  @override
  String aiInvoiceNote(Object number) {
    return 'AI चालान: $number';
  }

  @override
  String get supplierCanCreateOrders =>
      'इस आपूर्तिकर्ता से खरीद ऑर्डर बना सकते हैं';

  @override
  String get notesFieldHint => 'आपूर्तिकर्ता के बारे में अतिरिक्त नोट्स...';

  @override
  String get deleteConfirmCancel => 'रद्द करें';

  @override
  String get deleteConfirmBtn => 'हटाएं';

  @override
  String get supplierUpdatedMsg => 'आपूर्तिकर्ता डेटा अपडेट';

  @override
  String errorOccurredMsg(Object error) {
    return 'त्रुटि: $error';
  }

  @override
  String errorDuringDeleteMsg(Object error) {
    return 'हटाने के दौरान त्रुटि: $error';
  }

  @override
  String get fortyFiveDays => '45 दिन';

  @override
  String get expenseCategoriesTitle => 'व्यय श्रेणियाँ';

  @override
  String get noCategoriesFound => 'कोई व्यय श्रेणी नहीं मिली';

  @override
  String get monthlyBudget => 'मासिक बजट';

  @override
  String get spentAmount => 'खर्च';

  @override
  String get remainingAmount => 'शेष';

  @override
  String get overBudget => 'बजट से अधिक';

  @override
  String expenseCount(Object count) {
    return '$count व्यय';
  }

  @override
  String spentLabel(Object amount) {
    return 'खर्च: $amount रियाल';
  }

  @override
  String remainingLabel2(Object amount) {
    return 'शेष: $amount रियाल';
  }

  @override
  String expensesThisMonth(Object count) {
    return 'इस महीने $count व्यय';
  }

  @override
  String get recentExpenses => 'हालिया व्यय';

  @override
  String expenseNumber(Object id) {
    return 'व्यय #$id';
  }

  @override
  String get budgetLabel => 'बजट';

  @override
  String get monthlyBudgetLabel => 'मासिक बजट';

  @override
  String get categoryNameHint => 'उदाहरण: कर्मचारी वेतन';

  @override
  String get productNameLabel => 'उत्पाद नाम *';

  @override
  String get quantityLabel => 'मात्रा';

  @override
  String get purchasePriceLabel => 'खरीद मूल्य';

  @override
  String get saveInvoiceBtn => 'चालान सहेजें';

  @override
  String get ibanLabel => 'IBAN खाता नंबर';

  @override
  String get supplierActiveLabel => 'आपूर्तिकर्ता सक्रिय';

  @override
  String get notesLabel => 'नोट्स';

  @override
  String get deleteSupplierConfirm =>
      'क्या आप वाकई इस आपूर्तिकर्ता को हटाना चाहते हैं? सभी संबंधित डेटा हटा दिया जाएगा।';

  @override
  String get supplierDeletedMsg => 'आपूर्तिकर्ता हटाया गया';

  @override
  String get savingLabel => 'सहेजा जा रहा है...';

  @override
  String get supplierDetailTitle => 'आपूर्तिकर्ता विवरण';

  @override
  String get supplierNotFoundMsg => 'आपूर्तिकर्ता नहीं मिला';

  @override
  String get lastPurchaseLabel => 'अंतिम खरीद';

  @override
  String get recentPurchasesLabel => 'हालिया खरीद';

  @override
  String get noPurchasesLabel => 'अभी तक कोई खरीद नहीं';

  @override
  String get supplierAddedMsg => 'आपूर्तिकर्ता जोड़ा गया';

  @override
  String get openingCashLabel => 'शुरुआती नकद';

  @override
  String get importantNotes => 'महत्वपूर्ण नोट्स';

  @override
  String get countCashBeforeShift => 'शिफ्ट खोलने से पहले दराज में नकद गिनें';

  @override
  String get shiftTimeAutoRecorded =>
      'शिफ्ट खुलने का समय स्वचालित रिकॉर्ड होगा';

  @override
  String get oneShiftAtATime => 'एक समय में एक से अधिक शिफ्ट नहीं खोल सकते';

  @override
  String get pleaseEnterOpeningCash =>
      'कृपया शुरुआती नकद राशि दर्ज करें (शून्य से अधिक)';

  @override
  String shiftOpenedWithAmount(String amount, String currency) {
    return 'शिफ्ट $amount $currency से खुली';
  }

  @override
  String get errorOpeningShift => 'शिफ्ट खोलने में त्रुटि';

  @override
  String get noOpenShift => 'कोई खुली शिफ्ट नहीं';

  @override
  String get shiftInfoLabel => 'शिफ्ट जानकारी';

  @override
  String get salesSummaryLabel => 'बिक्री सारांश';

  @override
  String get cashRefundsLabel => 'नकद रिफंड';

  @override
  String get cashDepositLabel => 'नकद जमा';

  @override
  String get cashWithdrawalLabel => 'नकद निकासी';

  @override
  String get expectedInDrawer => 'दराज में अपेक्षित';

  @override
  String get actualCashInDrawer => 'दराज में वास्तविक नकद';

  @override
  String get drawerMatched => 'मिलान';

  @override
  String get surplusStatus => 'अधिशेष';

  @override
  String get deficitStatus => 'घाटा';

  @override
  String expectedAmountCurrency(String amount, String currency) {
    return 'अपेक्षित: $amount $currency';
  }

  @override
  String actualAmountCurrency(String amount, String currency) {
    return 'वास्तविक: $amount $currency';
  }

  @override
  String get drawerMatchedMessage => 'दराज मिलान है';

  @override
  String surplusAmount(String amount, String currency) {
    return 'अधिशेष: +$amount $currency';
  }

  @override
  String deficitAmount(String amount, String currency) {
    return 'घाटा: $amount $currency';
  }

  @override
  String get confirmCloseShift => 'क्या आप शिफ्ट बंद करना चाहते हैं?';

  @override
  String get errorClosingShift => 'शिफ्ट बंद करने में त्रुटि';

  @override
  String get shiftClosedSuccessfully => 'शिफ्ट सफलतापूर्वक बंद';

  @override
  String get shiftStatsLabel => 'शिफ्ट आंकड़े';

  @override
  String get shiftDurationLabel => 'शिफ्ट अवधि';

  @override
  String get invoiceCountLabel => 'चालान संख्या';

  @override
  String get invoiceUnit => 'चालान';

  @override
  String get cardSalesLabel => 'कार्ड बिक्री';

  @override
  String get cashSalesLabel => 'नकद बिक्री';

  @override
  String get refundsLabel => 'रिफंड';

  @override
  String get expectedInDrawerLabel => 'दराज में अपेक्षित';

  @override
  String get actualInDrawerLabel => 'दराज में वास्तविक';

  @override
  String get differenceLabel => 'अंतर';

  @override
  String get printingReport => 'रिपोर्ट प्रिंट हो रही है...';

  @override
  String get sharingInProgress => 'शेयर हो रहा है...';

  @override
  String get openNewShift => 'नई शिफ्ट खोलें';

  @override
  String hoursAndMinutes(int hours, int minutes) {
    return '$hours घंटे $minutes मिनट';
  }

  @override
  String hoursOnly(int hours) {
    return '$hours घंटे';
  }

  @override
  String minutesOnly(int minutes) {
    return '$minutes मिनट';
  }

  @override
  String get rejectedNotApproved => 'संचालन अस्वीकृत - स्वीकृत नहीं';

  @override
  String errorWithDetails(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get inventoryManagement => 'इन्वेंटरी प्रबंधित और ट्रैक करें';

  @override
  String get bulkEdit => 'बल्क संपादन';

  @override
  String get totalProducts => 'कुल उत्पाद';

  @override
  String get inventoryValue => 'इन्वेंटरी मूल्य';

  @override
  String get exportInventoryReport => 'इन्वेंटरी रिपोर्ट निर्यात करें';

  @override
  String get printOrderList => 'ऑर्डर सूची प्रिंट करें';

  @override
  String get inventoryMovementLog => 'इन्वेंटरी मूवमेंट लॉग';

  @override
  String get editSelected => 'चयनित संपादित करें';

  @override
  String get clearSelection => 'चयन साफ़ करें';

  @override
  String get noOutOfStockProducts => 'कोई स्टॉक-आउट उत्पाद नहीं';

  @override
  String get allProductsAvailable => 'सभी उत्पाद स्टॉक में उपलब्ध हैं';

  @override
  String get editStock => 'स्टॉक संपादित करें';

  @override
  String get newQuantity => 'नई मात्रा';

  @override
  String get receiveGoods => 'सामान प्राप्त करें';

  @override
  String get damaged => 'क्षतिग्रस्त';

  @override
  String get correction => 'सुधार';

  @override
  String get stockUpdatedTo => 'स्टॉक अपडेट हुआ';

  @override
  String get featureUnderDevelopment => 'यह सुविधा विकास में है...';

  @override
  String get newest => 'नवीनतम';

  @override
  String get adjustStock => 'स्टॉक समायोजित करें';

  @override
  String get adjustmentHistory => 'समायोजन इतिहास';

  @override
  String get errorLoadingProducts => 'उत्पाद लोड करने में त्रुटि';

  @override
  String get selectProduct => 'उत्पाद चुनें';

  @override
  String get subtract => 'घटाएं';

  @override
  String get setQuantity => 'सेट करें';

  @override
  String get enterQuantity => 'मात्रा दर्ज करें';

  @override
  String get enterValidQuantity => 'वैध मात्रा दर्ज करें';

  @override
  String get notesOptional => 'नोट्स (वैकल्पिक)';

  @override
  String get enterAdditionalNotes => 'अतिरिक्त नोट्स दर्ज करें...';

  @override
  String get adjustmentSummary => 'समायोजन सारांश';

  @override
  String get newStock => 'नया स्टॉक';

  @override
  String get warningNegativeStock => 'चेतावनी: स्टॉक नकारात्मक हो जाएगा!';

  @override
  String get saving => 'सहेजा जा रहा है...';

  @override
  String get storeNotSelected => 'स्टोर चयनित नहीं';

  @override
  String get noInventoryMovements => 'कोई इन्वेंटरी मूवमेंट नहीं';

  @override
  String get adjustmentSavedSuccess => 'समायोजन सफलतापूर्वक सहेजा गया';

  @override
  String get errorSaving => 'सहेजने में त्रुटि';

  @override
  String get enterBarcode => 'बारकोड दर्ज करें';

  @override
  String get theft => 'चोरी';

  @override
  String get noMatchingProducts => 'कोई मिलता उत्पाद नहीं';

  @override
  String get stockTransfer => 'स्टॉक स्थानांतरण';

  @override
  String get newTransfer => 'नया स्थानांतरण';

  @override
  String get fromBranch => 'शाखा से';

  @override
  String get toBranch => 'शाखा तक';

  @override
  String get selectSourceBranch => 'स्रोत शाखा चुनें';

  @override
  String get selectTargetBranch => 'लक्ष्य शाखा चुनें';

  @override
  String get selectProductsForTransfer => 'स्थानांतरण के लिए उत्पाद चुनें';

  @override
  String get creating => 'बनाया जा रहा है...';

  @override
  String get createTransferRequest => 'स्थानांतरण अनुरोध बनाएं';

  @override
  String get errorLoadingTransfers => 'स्थानांतरण लोड करने में त्रुटि';

  @override
  String get noPreviousTransfers => 'कोई पिछला स्थानांतरण नहीं';

  @override
  String get approved => 'स्वीकृत';

  @override
  String get inTransit => 'रास्ते में';

  @override
  String get complete => 'पूर्ण';

  @override
  String get completeTransfer => 'स्थानांतरण पूरा करें';

  @override
  String get completeTransferConfirm =>
      'क्या आप यह स्थानांतरण पूरा करना चाहते हैं? स्रोत से मात्रा घटेगी और लक्ष्य शाखा में जुड़ेगी।';

  @override
  String get transferCompletedSuccess => 'स्थानांतरण पूर्ण और स्टॉक अपडेट';

  @override
  String get errorCompletingTransfer => 'स्थानांतरण पूरा करने में त्रुटि';

  @override
  String get transferCreatedSuccess => 'स्थानांतरण अनुरोध सफलतापूर्वक बनाया';

  @override
  String get errorCreatingTransfer => 'स्थानांतरण बनाने में त्रुटि';

  @override
  String get stockTake => 'स्टॉक टेक';

  @override
  String get startStockTake => 'स्टॉक टेक शुरू करें';

  @override
  String get counted => 'गिना हुआ';

  @override
  String get variances => 'भिन्नताएं';

  @override
  String get of_ => 'का';

  @override
  String get system => 'सिस्टम';

  @override
  String get count => 'गिनती';

  @override
  String get finishStockTake => 'स्टॉक टेक पूरा करें';

  @override
  String get stockTakeDescription =>
      'स्टॉक उत्पाद गिनें और सिस्टम से तुलना करें';

  @override
  String get noProductsInStock => 'स्टॉक में कोई उत्पाद नहीं';

  @override
  String get noProductsToCount => 'गिनती शुरू करने के लिए कोई उत्पाद नहीं';

  @override
  String get errorCreatingStockTake => 'स्टॉक टेक बनाने में त्रुटि';

  @override
  String get saveStockTakeConfirm =>
      'स्टॉक टेक परिणाम सहेजें और इन्वेंटरी अपडेट करें?';

  @override
  String get stockTakeSavedSuccess => 'स्टॉक टेक सहेजा और इन्वेंटरी अपडेट हुई';

  @override
  String get errorCompletingStockTake => 'स्टॉक टेक पूरा करने में त्रुटि';

  @override
  String get stockTakeHistory => 'स्टॉक टेक इतिहास';

  @override
  String get errorLoadingHistory => 'इतिहास लोड करने में त्रुटि';

  @override
  String get noStockTakeHistory => 'कोई पिछला स्टॉक टेक इतिहास नहीं';

  @override
  String get inProgress => 'प्रगति में';

  @override
  String get expiryTracking => 'समाप्ति ट्रैकिंग';

  @override
  String get errorLoadingExpiryData => 'समाप्ति डेटा लोड करने में त्रुटि';

  @override
  String get withinMonth => 'एक महीने में';

  @override
  String get noProductsExpiringIn7Days => '7 दिनों में कोई उत्पाद समाप्त नहीं';

  @override
  String get noProductsExpiringInMonth => 'एक महीने में कोई उत्पाद समाप्त नहीं';

  @override
  String get noExpiredProducts => 'कोई समाप्त उत्पाद नहीं';

  @override
  String get batch => 'बैच';

  @override
  String expiredSinceDays(int days) {
    return '$days दिन पहले समाप्त';
  }

  @override
  String get remove => 'हटाएं';

  @override
  String get pressToAddExpiryTracking =>
      'नई समाप्ति ट्रैकिंग जोड़ने के लिए + दबाएं';

  @override
  String get applyDiscountTo => 'छूट लागू करें';

  @override
  String get confirmRemoval => 'हटाने की पुष्टि';

  @override
  String get removeExpiryTrackingFor => 'समाप्ति ट्रैकिंग हटाएं';

  @override
  String get expiryTrackingRemoved => 'समाप्ति ट्रैकिंग हटा दी गई';

  @override
  String get errorRemovingExpiryTracking => 'समाप्ति ट्रैकिंग हटाने में त्रुटि';

  @override
  String get addExpiryDate => 'समाप्ति तिथि जोड़ें';

  @override
  String get barcodeOrProductName => 'बारकोड या उत्पाद नाम';

  @override
  String get selectDate => 'तिथि चुनें';

  @override
  String get batchNumberOptional => 'बैच नंबर (वैकल्पिक)';

  @override
  String get expiryTrackingAdded => 'समाप्ति ट्रैकिंग सफलतापूर्वक जोड़ी गई';

  @override
  String get errorAddingExpiryTracking => 'समाप्ति ट्रैकिंग जोड़ने में त्रुटि';

  @override
  String get barcodeScanner2 => 'बारकोड स्कैनर';

  @override
  String get scanning => 'स्कैन हो रहा है...';

  @override
  String get pressToStart => 'शुरू करने के लिए दबाएं';

  @override
  String get stop => 'रुकें';

  @override
  String get startScanning => 'स्कैनिंग शुरू करें';

  @override
  String get enterBarcodeManually => 'मैन्युअल बारकोड दर्ज करें';

  @override
  String get noScannedProducts => 'कोई स्कैन किया उत्पाद नहीं';

  @override
  String get enterBarcodeToSearch => 'खोज के लिए बारकोड दर्ज करें';

  @override
  String get useManualInputToSearch =>
      'उत्पाद खोजने के लिए मैन्युअल इनपुट उपयोग करें';

  @override
  String get found => 'मिला';

  @override
  String get productNotFoundForBarcode => 'उत्पाद नहीं मिला';

  @override
  String get addNewProduct => 'नया उत्पाद जोड़ें';

  @override
  String get willOpenAddProductScreen => 'उत्पाद जोड़ें स्क्रीन खुलेगी';

  @override
  String get scanHistory => 'स्कैन इतिहास';

  @override
  String get addedToCart => 'जोड़ा गया';

  @override
  String get barcodePrint => 'बारकोड प्रिंट';

  @override
  String get noProductsWithBarcode => 'बारकोड वाला कोई उत्पाद नहीं';

  @override
  String get addBarcodeFirst => 'पहले उत्पादों में बारकोड जोड़ें';

  @override
  String get searchProduct => 'उत्पाद खोजें...';

  @override
  String get totalLabels => 'कुल लेबल';

  @override
  String get printLabels => 'लेबल प्रिंट करें';

  @override
  String get printList => 'सूची प्रिंट करें';

  @override
  String get selectProductsToPrint => 'प्रिंट के लिए उत्पाद चुनें';

  @override
  String get willPrint => 'प्रिंट होगा';

  @override
  String get label => 'लेबल';

  @override
  String get printing => 'प्रिंट हो रहा है...';

  @override
  String get messageAddedToQueue => 'संदेश भेजने की कतार में जोड़ा गया';

  @override
  String get messageSendFailed => 'संदेश भेजने में विफल';

  @override
  String get noPhoneForCustomer => 'ग्राहक का फोन नंबर नहीं';

  @override
  String get inputContainsDangerousContent => 'इनपुट में निषिद्ध सामग्री है';

  @override
  String whatsappGreeting(String name) {
    return 'नमस्ते $name\nहम आपकी कैसे मदद कर सकते हैं?';
  }

  @override
  String get segmentVip => 'VIP';

  @override
  String get segmentRegular => 'नियमित';

  @override
  String get segmentAtRisk => 'जोखिम में';

  @override
  String get segmentLost => 'खोए हुए';

  @override
  String get segmentNewCustomer => 'नया';

  @override
  String customerCount(int count) {
    return '$count ग्राहक';
  }

  @override
  String revenueK(String amount) {
    return '${amount}K रियाल';
  }

  @override
  String get tabRecommendations => 'सिफारिशें';

  @override
  String get tabRepurchase => 'पुनः खरीद';

  @override
  String get tabSegments => 'खंड';

  @override
  String lastVisitLabel(String time) {
    return 'अंतिम विज़िट: $time';
  }

  @override
  String visitCountLabel(int count) {
    return '$count विज़िट';
  }

  @override
  String avgSpendLabel(String amount) {
    return 'औसत: $amount रियाल';
  }

  @override
  String totalSpentLabel(String amount) {
    return 'कुल: ${amount}K रियाल';
  }

  @override
  String get recommendedProducts => 'अनुशंसित उत्पाद';

  @override
  String get sendWhatsAppOffer => 'व्हाट्सएप ऑफर भेजें';

  @override
  String get totalRevenueLabel => 'कुल राजस्व';

  @override
  String get avgSpendStat => 'औसत खर्च';

  @override
  String amountSar(String amount) {
    return '$amount रियाल';
  }

  @override
  String get specialOfferMissYou =>
      'आपके लिए विशेष ऑफर! हमें आपकी विज़िट याद आती है';

  @override
  String friendlyReminderPurchase(String product) {
    return '$product खरीदने की याद दिलाना';
  }

  @override
  String get timeAgoToday => 'आज';

  @override
  String get timeAgoYesterday => 'कल';

  @override
  String timeAgoDays(int days) {
    return '$days दिन पहले';
  }

  @override
  String get riskAnalysisTab => 'जोखिम विश्लेषण';

  @override
  String get preventiveActionsTab => 'निवारक कार्रवाई';

  @override
  String errorOccurredDetail(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get returnRateTitle => 'वापसी दर';

  @override
  String get avgLast6Months => 'पिछले 6 महीने का औसत';

  @override
  String get amountAtRiskTitle => 'जोखिम में राशि';

  @override
  String get highRiskOperations => 'उच्च जोखिम संचालन';

  @override
  String get needsImmediateAction => 'तत्काल कार्रवाई आवश्यक';

  @override
  String get returnTrendTitle => 'वापसी प्रवृत्ति';

  @override
  String operationsAtRiskCount(int count) {
    return 'जोखिम में संचालन ($count)';
  }

  @override
  String get riskFilterAll => 'सभी';

  @override
  String get riskFilterVeryHigh => 'बहुत उच्च';

  @override
  String get riskFilterHigh => 'उच्च';

  @override
  String get riskFilterMedium => 'मध्यम';

  @override
  String get riskFilterLow => 'कम';

  @override
  String get totalExpectedSavings => 'कुल अपेक्षित बचत';

  @override
  String fromPreventiveActions(int count) {
    return '$count निवारक कार्यों से';
  }

  @override
  String get suggestedPreventiveActions => 'सुझाए गए निवारक कदम';

  @override
  String get applyPreventiveHint =>
      'रिटर्न कम करने और ग्राहक संतुष्टि बढ़ाने के लिए ये कदम लागू करें';

  @override
  String actionApplied(String action) {
    return 'लागू: $action';
  }

  @override
  String actionDismissed(String action) {
    return 'खारिज: $action';
  }

  @override
  String get veryPositiveSentiment => 'बहुत सकारात्मक';

  @override
  String get positiveSentiment => 'सकारात्मक';

  @override
  String get neutralSentiment => 'तटस्थ';

  @override
  String get negativeSentiment => 'नकारात्मक';

  @override
  String get veryNegativeSentiment => 'बहुत नकारात्मक';

  @override
  String get ratingsDistribution => 'रेटिंग वितरण';

  @override
  String get sentimentTrendTitle => 'भावना प्रवृत्ति';

  @override
  String get sentimentIndicator => 'भावना संकेतक';

  @override
  String minutesAgoSentiment(int count) {
    return '$count मिनट पहले';
  }

  @override
  String hoursAgoSentiment(int count) {
    return '$count घंटे पहले';
  }

  @override
  String daysAgoSentiment(int count) {
    return '$count दिन पहले';
  }

  @override
  String get totalProductsTitle => 'कुल उत्पाद';

  @override
  String get categoryATitle => 'श्रेणी A';

  @override
  String get mostImportant => 'सबसे महत्वपूर्ण';

  @override
  String get withinDays => '7 दिनों में';

  @override
  String get needReorder => 'पुनः ऑर्डर आवश्यक';

  @override
  String estimatedLossSar(String amount) {
    return '$amount रियाल अनुमानित नुकसान';
  }

  @override
  String get tabAbcAnalysis => 'ABC विश्लेषण';

  @override
  String get tabWastePrediction => 'बर्बादी पूर्वानुमान';

  @override
  String get tabReorder => 'री-ऑर्डर';

  @override
  String get filterAllLabel => 'सभी';

  @override
  String get categoryALabel => 'श्रेणी A';

  @override
  String get categoryBLabel => 'श्रेणी B';

  @override
  String get categoryCLabel => 'श्रेणी C';

  @override
  String orderUnitsSnack(int qty, String name) {
    return '$name की $qty इकाइयाँ ऑर्डर करें';
  }

  @override
  String get urgencyCritical => 'गंभीर';

  @override
  String get urgencyHigh => 'उच्च';

  @override
  String get urgencyMedium => 'मध्यम';

  @override
  String get urgencyLow => 'कम';

  @override
  String get currentStockLabel => 'वर्तमान स्टॉक';

  @override
  String get reorderPointLabel => 'पुनः ऑर्डर बिंदु';

  @override
  String get suggestedQtyLabel => 'सुझाई गई मात्रा';

  @override
  String get daysOfStockLabel => 'स्टॉक के दिन';

  @override
  String estimatedCostLabel(String amount) {
    return 'अनुमानित लागत: $amount रियाल';
  }

  @override
  String purchaseOrderCreatedFor(String name) {
    return 'खरीद ऑर्डर बनाया: $name';
  }

  @override
  String orderUnitsButton(int qty) {
    return '$qty इकाइयाँ ऑर्डर करें';
  }

  @override
  String get actionDiscount => 'छूट';

  @override
  String get actionTransfer => 'स्थानांतरण';

  @override
  String get actionDonate => 'दान';

  @override
  String actionOnProduct(String name) {
    return 'कार्रवाई: $name';
  }

  @override
  String get totalSuggestionsLabel => 'कुल सुझाव';

  @override
  String get canIncreaseLabel => 'बढ़ा सकते हैं';

  @override
  String get shouldDecreaseLabel => 'कम होना चाहिए';

  @override
  String get expectedMonthlyImpact => 'अपेक्षित मासिक प्रभाव';

  @override
  String get noSuggestionsInFilter => 'इस फ़िल्टर में कोई सुझाव नहीं';

  @override
  String get selectProductForDetails => 'विवरण देखने के लिए उत्पाद चुनें';

  @override
  String get selectProductHint =>
      'प्रभाव कैलकुलेटर और मांग लोच देखने के लिए सूची से उत्पाद पर क्लिक करें';

  @override
  String priceApplied(String price, String product) {
    return 'कीमत $price रियाल $product पर लागू';
  }

  @override
  String errorOccurredShort(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get readyTemplates => 'तैयार टेम्पलेट';

  @override
  String get hideTemplates => 'टेम्पलेट छुपाएं';

  @override
  String get showTemplates => 'टेम्पलेट दिखाएं';

  @override
  String get askAboutStore => 'अपने स्टोर के बारे में कोई सवाल पूछें';

  @override
  String get writeQuestionHint =>
      'अपना सवाल लिखें और हम स्वचालित उपयुक्त रिपोर्ट बनाएंगे';

  @override
  String get quickActionTodaySales => 'आज कितनी बिक्री हुई?';

  @override
  String get quickActionTop10 => 'शीर्ष 10 उत्पाद';

  @override
  String get quickActionMonthlyCompare => 'मासिक तुलना';

  @override
  String get analyzingData => 'डेटा का विश्लेषण और रिपोर्ट तैयार हो रही है...';

  @override
  String get profileScreenTitle => 'प्रोफ़ाइल';

  @override
  String get unknownUserName => 'अज्ञात';

  @override
  String get defaultEmployeeRole => 'कर्मचारी';

  @override
  String get transactionUnit => 'लेन-देन';

  @override
  String get dayUnit => 'दिन';

  @override
  String get emailFieldLabel => 'ईमेल';

  @override
  String get phoneFieldLabel => 'फोन';

  @override
  String get branchFieldLabel => 'शाखा';

  @override
  String get mainBranchName => 'मुख्य शाखा';

  @override
  String get employeeNumberLabel => 'कर्मचारी नंबर';

  @override
  String get changePasswordLabel => 'पासवर्ड बदलें';

  @override
  String get activityLogLabel => 'गतिविधि लॉग';

  @override
  String get logoutDialogTitle => 'लॉगआउट';

  @override
  String get logoutDialogBody => 'क्या आप सिस्टम से लॉगआउट करना चाहते हैं?';

  @override
  String get cancelButton => 'रद्द करें';

  @override
  String get exitButton => 'बाहर निकलें';

  @override
  String get editProfileSnack => 'प्रोफ़ाइल संपादन';

  @override
  String get changePasswordSnack => 'पासवर्ड बदलें';

  @override
  String get roleAdmin => 'सिस्टम एडमिन';

  @override
  String get roleManager => 'प्रबंधक';

  @override
  String get roleCashier => 'कैशियर';

  @override
  String get roleEmployee => 'कर्मचारी';

  @override
  String get onboardingTitle1 => 'तेज़ पॉइंट ऑफ सेल';

  @override
  String get onboardingDesc1 =>
      'सरल और आरामदायक इंटरफ़ेस के साथ तेज़ी से बिक्री पूरी करें';

  @override
  String get onboardingTitle2 => 'ऑफलाइन काम करें';

  @override
  String get onboardingDesc2 =>
      'बिना कनेक्शन के काम जारी रखें, सिंक स्वचालित होगा';

  @override
  String get onboardingTitle3 => 'इन्वेंटरी प्रबंधन';

  @override
  String get onboardingDesc3 =>
      'कमी और समाप्ति अलर्ट के साथ इन्वेंटरी सटीक ट्रैक करें';

  @override
  String get onboardingTitle4 => 'स्मार्ट रिपोर्ट';

  @override
  String get onboardingDesc4 =>
      'स्टोर प्रदर्शन के लिए विस्तृत रिपोर्ट प्राप्त करें';

  @override
  String get startNow => 'अभी शुरू करें';

  @override
  String get favorites => 'पसंदीदा';

  @override
  String get editMode => 'संपादन';

  @override
  String get doneMode => 'हो गया';

  @override
  String get errorLoadingFavorites => 'पसंदीदा लोड करने में त्रुटि';

  @override
  String get noFavoriteProducts => 'कोई पसंदीदा उत्पाद नहीं';

  @override
  String get addFavoritesFromProducts => 'उत्पाद स्क्रीन से पसंदीदा में जोड़ें';

  @override
  String get tapProductToAddToCart =>
      'कार्ट में जोड़ने के लिए उत्पाद पर टैप करें';

  @override
  String addedProductToCart(String name) {
    return '$name कार्ट में जोड़ा गया';
  }

  @override
  String get addToCartAction => 'कार्ट में जोड़ें';

  @override
  String get removeFromFavorites => 'पसंदीदा से हटाएं';

  @override
  String removedProductFromFavorites(String name) {
    return '$name पसंदीदा से हटाया';
  }

  @override
  String get paymentMethodTitle => 'भुगतान विधि';

  @override
  String get backEsc => 'वापस (Esc)';

  @override
  String get completePayment => 'भुगतान पूरा करें';

  @override
  String get enterToConfirm => 'पुष्टि के लिए Enter दबाएं';

  @override
  String get cashOnlyOffline => 'ऑफलाइन मोड में केवल नकद';

  @override
  String get cardsDisabledInSettings => 'सेटिंग्स में कार्ड अक्षम हैं';

  @override
  String get creditPayment => 'उधार भुगतान';

  @override
  String get unavailableOffline => 'ऑफलाइन उपलब्ध नहीं';

  @override
  String get disabledInSettings => 'सेटिंग्स में अक्षम';

  @override
  String get amountReceived => 'प्राप्त राशि';

  @override
  String get quickAmounts => 'त्वरित राशियाँ';

  @override
  String get requiredAmount => 'आवश्यक राशि';

  @override
  String get changeLabel => 'वापसी:';

  @override
  String get insufficientAmount => 'अपर्याप्त राशि';

  @override
  String get rrnLabel => 'संदर्भ संख्या (RRN)';

  @override
  String get enterRrnFromDevice => 'डिवाइस से लेन-देन नंबर दर्ज करें';

  @override
  String get cardPaymentInstructions =>
      'ग्राहक से कार्ड टर्मिनल से भुगतान करवाएं, फिर रसीद से लेन-देन नंबर (RRN) दर्ज करें';

  @override
  String get creditSale => 'उधार बिक्री';

  @override
  String get creditSaleWarning =>
      'यह राशि ग्राहक के ऋण के रूप में दर्ज होगी। लेन-देन पूरा करने से पहले ग्राहक का चयन सुनिश्चित करें।';

  @override
  String get orderSummary => 'ऑर्डर सारांश';

  @override
  String get taxLabel => 'कर (15%)';

  @override
  String discountLabel(String value) {
    return 'छूट';
  }

  @override
  String get payCash => 'नकद भुगतान';

  @override
  String get payCard => 'कार्ड से भुगतान';

  @override
  String get payCreditSale => 'उधार बिक्री';

  @override
  String get confirmPayment => 'भुगतान की पुष्टि';

  @override
  String get processingPayment => 'भुगतान प्रोसेस हो रहा है...';

  @override
  String get pleaseWait => 'कृपया प्रतीक्षा करें';

  @override
  String get paymentSuccessful => 'भुगतान सफल!';

  @override
  String get printingReceipt => 'रसीद प्रिंट हो रही है...';

  @override
  String get whatsappReceipt => 'व्हाट्सएप रसीद';

  @override
  String get storeOrUserNotSet => 'स्टोर या उपयोगकर्ता सेट नहीं';

  @override
  String errorWithMessage(String message) {
    return 'त्रुटि: $message';
  }

  @override
  String get receiptTitle => 'रसीद';

  @override
  String get invoiceNotSpecified => 'चालान नंबर निर्दिष्ट नहीं';

  @override
  String get pendingSync => 'सिंक लंबित';

  @override
  String get notSynced => 'सिंक नहीं हुआ';

  @override
  String receiptNumberLabel(String number) {
    return 'नंबर: $number';
  }

  @override
  String get itemColumnHeader => 'आइटम';

  @override
  String totalAmount(String amount) {
    return 'कुल';
  }

  @override
  String get paymentMethodField => 'भुगतान विधि';

  @override
  String get zatcaQrCode => 'ZATCA कर QR कोड';

  @override
  String get whatsappSentLabel => 'भेजा गया';

  @override
  String get whatsappLabel => 'व्हाट्सएप';

  @override
  String get whatsappReceiptSent => 'रसीद व्हाट्सएप से भेजी गई';

  @override
  String whatsappSendFailed(String error) {
    return 'भेजने में विफल: $error';
  }

  @override
  String get cannotPrintNoInvoice =>
      'प्रिंट नहीं हो सकता - चालान नंबर उपलब्ध नहीं';

  @override
  String get invoiceAddedToPrintQueue => 'चालान प्रिंट कतार में जोड़ा गया';

  @override
  String get mixedMethod => 'मिश्रित';

  @override
  String get creditMethod => 'उधार';

  @override
  String get walletMethod => 'वॉलेट';

  @override
  String get bankTransferMethod => 'बैंक ट्रांसफर';

  @override
  String get scanBarcodeHint => 'बारकोड स्कैन करें या दर्ज करें (F1)';

  @override
  String get openCamera => 'कैमरा खोलें';

  @override
  String get searchProductHint => 'उत्पाद खोजें (F2)';

  @override
  String get hideCart => 'कार्ट छुपाएं';

  @override
  String get showCart => 'कार्ट दिखाएं';

  @override
  String get cartTitle => 'कार्ट';

  @override
  String get clearAction => 'साफ़ करें';

  @override
  String get allCategories => 'सभी';

  @override
  String get otherCategory => 'अन्य';

  @override
  String get storeNotSet => 'स्टोर सेट नहीं';

  @override
  String get retryAction => 'पुनः प्रयास';

  @override
  String get vatTax15 => 'VAT (15%)';

  @override
  String get totalGrand => 'कुल';

  @override
  String get holdOrder => 'होल्ड';

  @override
  String get payActionLabel => 'भुगतान';

  @override
  String get f12QuickPay => 'त्वरित भुगतान के लिए F12';

  @override
  String productNotFoundBarcode(String barcode) {
    return 'बारकोड के लिए उत्पाद नहीं मिला: $barcode';
  }

  @override
  String get clearCartTitle => 'कार्ट साफ़ करें';

  @override
  String get clearCartMessage => 'क्या आप कार्ट से सभी उत्पाद हटाना चाहते हैं?';

  @override
  String get orderOnHold => 'ऑर्डर होल्ड पर';

  @override
  String get deleteItem => 'हटाएं';

  @override
  String itemsCountPrice(int count, String price) {
    return '$count आइटम - $price रियाल';
  }

  @override
  String get taxReportTitle => 'कर रिपोर्ट';

  @override
  String get exportReportAction => 'रिपोर्ट निर्यात करें';

  @override
  String get printReportAction => 'रिपोर्ट प्रिंट करें';

  @override
  String get quarterly => 'त्रैमासिक';

  @override
  String get netTaxDue => 'बकाया शुद्ध कर';

  @override
  String get salesTaxCollected => 'बिक्री कर';

  @override
  String get salesTaxSubtitle => 'एकत्रित';

  @override
  String get purchasesTaxPaid => 'खरीद कर';

  @override
  String get purchasesTaxSubtitle => 'भुगतान';

  @override
  String get taxByPaymentMethod => 'भुगतान विधि के अनुसार कर';

  @override
  String invoiceCount(int count) {
    return '$count चालान';
  }

  @override
  String get taxDetailsTitle => 'कर विवरण';

  @override
  String get taxableSales => 'कर योग्य बिक्री';

  @override
  String get salesTax15 => 'बिक्री कर (15%)';

  @override
  String get taxablePurchases => 'कर योग्य खरीद';

  @override
  String get purchasesTax15 => 'खरीद कर (15%)';

  @override
  String get netTax => 'शुद्ध कर';

  @override
  String get zatcaReminder => 'ZATCA अनुस्मारक';

  @override
  String get zatcaDeadline => 'फाइलिंग की अंतिम तिथि: अगले महीने के अंत तक';

  @override
  String get historyAction => 'इतिहास';

  @override
  String get sendToAuthority => 'प्राधिकरण को भेजें';

  @override
  String get cashPaymentMethod => 'नकद';

  @override
  String get cardPaymentMethod => 'कार्ड';

  @override
  String get mixedPaymentMethod => 'मिश्रित';

  @override
  String get creditPaymentMethod => 'उधार';

  @override
  String get vatReportTitle => 'VAT रिपोर्ट';

  @override
  String get selectPeriod => 'अवधि चुनें';

  @override
  String get salesVat => 'बिक्री VAT';

  @override
  String get totalSalesIncVat => 'कुल बिक्री (VAT सहित)';

  @override
  String get vatCollected => 'एकत्रित VAT';

  @override
  String get purchasesVat => 'खरीद VAT';

  @override
  String get totalPurchasesIncVat => 'कुल खरीद (VAT सहित)';

  @override
  String get vatPaid => 'भुगतान VAT';

  @override
  String get netVatDue => 'बकाया शुद्ध VAT';

  @override
  String get dueToAuthority => 'प्राधिकरण को बकाया';

  @override
  String get dueFromAuthority => 'प्राधिकरण से बकाया';

  @override
  String get exportingPdfReport => 'रिपोर्ट निर्यात हो रही है...';

  @override
  String get debtsReportTitle => 'ऋण रिपोर्ट';

  @override
  String get sortByLastPayment => 'अंतिम भुगतान के अनुसार';

  @override
  String get customersCount => 'ग्राहक';

  @override
  String get noOutstandingDebts => 'कोई बकाया ऋण नहीं';

  @override
  String lastUpdate(String date) {
    return 'अंतिम अपडेट: $date';
  }

  @override
  String get paymentAmountField => 'भुगतान राशि';

  @override
  String get recordAction => 'रिकॉर्ड';

  @override
  String get paymentRecordedMsg => 'भुगतान दर्ज';

  @override
  String showDetails(String name) {
    return 'विवरण देखें: $name';
  }

  @override
  String get debtsReportPdf => 'ऋण रिपोर्ट';

  @override
  String dateFieldLabel(String date) {
    return 'तिथि: $date';
  }

  @override
  String get debtsDetails => 'ऋण विवरण:';

  @override
  String get customerCol => 'ग्राहक';

  @override
  String get phoneCol => 'फोन';

  @override
  String get refundReceiptTitle => 'रिफंड रसीद';

  @override
  String get noRefundId => 'कोई रिफंड ID नहीं';

  @override
  String get refundNotFound => 'रिफंड डेटा नहीं मिला';

  @override
  String get refundSuccessful => 'रिफंड सफल';

  @override
  String refundNumberLabel(String number) {
    return 'रिफंड नंबर: $number';
  }

  @override
  String get refundReceipt => 'रिफंड रसीद';

  @override
  String get originalInvoiceNumber => 'मूल चालान नंबर';

  @override
  String get refundDate => 'रिफंड तिथि';

  @override
  String get refundMethodField => 'रिफंड विधि';

  @override
  String get returnedProducts => 'वापस किए गए उत्पाद';

  @override
  String get totalRefund => 'कुल रिफंड';

  @override
  String get reasonLabel => 'कारण';

  @override
  String get homeAction => 'होम';

  @override
  String printError(String error) {
    return 'प्रिंट त्रुटि: $error';
  }

  @override
  String get damagedProduct => 'क्षतिग्रस्त उत्पाद';

  @override
  String get wrongOrder => 'गलत ऑर्डर';

  @override
  String get customerChangedMind => 'ग्राहक ने विचार बदला';

  @override
  String get expiredProduct => 'समाप्त उत्पाद';

  @override
  String get unsatisfactoryQuality => 'असंतोषजनक गुणवत्ता';

  @override
  String get cashRefundMethod => 'नकद';

  @override
  String get cardRefundMethod => 'कार्ड';

  @override
  String get walletRefundMethod => 'वॉलेट';

  @override
  String get refundReasonTitle => 'रिफंड कारण';

  @override
  String get noRefundData => 'कोई रिफंड डेटा नहीं। वापस जाएं और उत्पाद चुनें।';

  @override
  String invoiceFieldLabel(String receiptNo) {
    return 'चालान: $receiptNo';
  }

  @override
  String productsCountAmount(int count, String amount) {
    return '$count उत्पाद - $amount रियाल';
  }

  @override
  String get selectRefundReason => 'रिफंड कारण चुनें';

  @override
  String get additionalNotesOptional => 'अतिरिक्त नोट्स (वैकल्पिक)';

  @override
  String get addNotesHint => 'अतिरिक्त नोट्स जोड़ें...';

  @override
  String get processingAction => 'प्रोसेसिंग...';

  @override
  String get nextSupervisorApproval => 'अगला - पर्यवेक्षक अनुमोदन';

  @override
  String refundCreationError(String error) {
    return 'रिफंड बनाने में त्रुटि: $error';
  }

  @override
  String get refundRequestTitle => 'रिफंड अनुरोध';

  @override
  String get invoiceNumberHint => 'चालान नंबर';

  @override
  String get searchAction => 'खोजें';

  @override
  String get selectProductsForRefund => 'रिफंड के लिए उत्पाद चुनें';

  @override
  String get selectAll => 'सभी चुनें';

  @override
  String quantityTimesPrice(int qty, String price) {
    return 'मात्रा: $qty × $price रियाल';
  }

  @override
  String productsSelected(int count) {
    return '$count उत्पाद चयनित';
  }

  @override
  String refundAmountValue(String amount) {
    return 'राशि: $amount रियाल';
  }

  @override
  String get nextAction => 'अगला';

  @override
  String get enterInvoiceToSearch => 'खोज के लिए चालान नंबर दर्ज करें';

  @override
  String get invoiceNotFoundMsg => 'चालान नहीं मिला';

  @override
  String get shippingGatewaysTitle => 'शिपिंग गेटवे';

  @override
  String get availableShippingGateways => 'उपलब्ध शिपिंग गेटवे';

  @override
  String get activateShippingGateways =>
      'ऑर्डर डिलीवरी के लिए शिपिंग गेटवे सक्रिय और कॉन्फ़िगर करें';

  @override
  String get aramexName => 'आरामेक्स';

  @override
  String get aramexDesc => 'कई सेवाओं के साथ वैश्विक शिपिंग कंपनी';

  @override
  String get smsaDesc => 'तेज़ घरेलू शिपिंग';

  @override
  String get fastloName => 'फास्टलो';

  @override
  String get fastloDesc => 'उसी दिन तेज़ डिलीवरी';

  @override
  String get dhlDesc => 'तेज़ और विश्वसनीय अंतरराष्ट्रीय शिपिंग';

  @override
  String get jtDesc => 'किफायती शिपिंग';

  @override
  String get customDeliveryName => 'कस्टम डिलीवरी';

  @override
  String get customDeliveryDesc => 'अपने ड्राइवरों से डिलीवरी प्रबंधित करें';

  @override
  String get settingsAction => 'सेटिंग्स';

  @override
  String get hourlyView => 'प्रति घंटा';

  @override
  String get dailyView => 'दैनिक';

  @override
  String get peakHourLabel => 'पीक घंटा';

  @override
  String transactionsWithCount(int count) {
    return '$count लेन-देन';
  }

  @override
  String get peakDayLabel => 'पीक दिन';

  @override
  String get avgPerHour => 'औसत/घंटा';

  @override
  String get transactionWord => 'लेन-देन';

  @override
  String get transactionsByHour => 'घंटे के अनुसार लेन-देन';

  @override
  String get transactionsByDay => 'दिन के अनुसार लेन-देन';

  @override
  String get activityHeatmap => 'गतिविधि हीटमैप';

  @override
  String get lowLabel => 'कम';

  @override
  String get highLabel => 'उच्च';

  @override
  String get analysisRecommendations => 'विश्लेषण पर आधारित सिफारिशें';

  @override
  String get staffRecommendation => 'स्टाफ';

  @override
  String get staffRecommendationDesc =>
      '12:00-13:00 और 17:00-19:00 के दौरान कैशियर बढ़ाएं (पीक बिक्री)';

  @override
  String get offersRecommendation => 'ऑफर';

  @override
  String get offersRecommendationDesc =>
      '14:00-16:00 के दौरान विशेष डील पेश करें';

  @override
  String get inventoryRecommendation => 'इन्वेंटरी';

  @override
  String get inventoryRecommendationDesc =>
      'गुरुवार और शुक्रवार से पहले इन्वेंटरी तैयार करें (सबसे अधिक बिक्री के दिन)';

  @override
  String get shiftsRecommendation => 'शिफ्ट';

  @override
  String get shiftsRecommendationDesc =>
      'शिफ्ट वितरित करें: सुबह 8-15, शाम 15-22 पीक पर ओवरलैप';

  @override
  String get topProductsTab => 'शीर्ष उत्पाद';

  @override
  String get byCategoryTab => 'श्रेणी के अनुसार';

  @override
  String get performanceAnalysisTab => 'प्रदर्शन विश्लेषण';

  @override
  String get noSalesDataForPeriod => 'चयनित अवधि के लिए कोई बिक्री डेटा नहीं';

  @override
  String get categoryFilter => 'श्रेणी';

  @override
  String get allCategoriesFilter => 'सभी श्रेणियाँ';

  @override
  String get sortByField => 'क्रम';

  @override
  String get revenueSort => 'राजस्व';

  @override
  String get unitsSort => 'इकाइयाँ';

  @override
  String get profitSort => 'लाभ';

  @override
  String get revenueLabel => 'राजस्व';

  @override
  String get unitsLabel => 'इकाइयाँ';

  @override
  String get profitLabel => 'लाभ';

  @override
  String get stockLabel => 'स्टॉक';

  @override
  String get revenueByCategoryTitle => 'श्रेणी के अनुसार राजस्व वितरण';

  @override
  String get noRevenueForPeriod => 'इस अवधि के लिए कोई राजस्व नहीं';

  @override
  String get unclassified => 'अवर्गीकृत';

  @override
  String get productUnit => 'उत्पाद';

  @override
  String get unitsSoldUnit => 'इकाई';

  @override
  String get totalRevenueKpi => 'कुल राजस्व';

  @override
  String get unitsSoldKpi => 'बिकी इकाइयाँ';

  @override
  String get totalProfitKpi => 'कुल लाभ';

  @override
  String get profitMarginKpi => 'लाभ मार्जिन';

  @override
  String get performanceOverview => 'प्रदर्शन अवलोकन';

  @override
  String get trendingUpProducts => 'ऊपर प्रवृत्ति';

  @override
  String get stableProducts => 'स्थिर';

  @override
  String get trendingDownProducts => 'नीचे प्रवृत्ति';

  @override
  String noSalesProducts(int count) {
    return 'बिना बिक्री उत्पाद ($count)';
  }

  @override
  String inStockCount(int count) {
    return '$count स्टॉक में';
  }

  @override
  String get slowMovingLabel => 'धीमा';

  @override
  String needsReorder(int count) {
    return 'पुनः ऑर्डर ($count)';
  }

  @override
  String soldUnitsStock(int sold, int stock) {
    return 'बिक्री: $sold इकाई | स्टॉक: $stock';
  }

  @override
  String get reorderLabel => 'पुनः ऑर्डर';

  @override
  String get totalComplaintsLabel => 'कुल शिकायतें';

  @override
  String get openComplaints => 'खुली';

  @override
  String get closedComplaints => 'बंद';

  @override
  String get avgResolutionTime => 'औसत समाधान समय';

  @override
  String daysUnit(String count) {
    return '$count दिन';
  }

  @override
  String get fromDate => 'तिथि से';

  @override
  String get toDate => 'तिथि तक';

  @override
  String get statusFilter => 'स्थिति';

  @override
  String get departmentFilter => 'विभाग';

  @override
  String get paymentDepartment => 'भुगतान';

  @override
  String get technicalDepartment => 'तकनीकी';

  @override
  String get otherDepartment => 'अन्य';

  @override
  String get noComplaintsRecorded => 'अभी तक कोई शिकायत दर्ज नहीं';

  @override
  String get overviewTab => 'अवलोकन';

  @override
  String get topCustomersTab => 'शीर्ष ग्राहक';

  @override
  String get growthAnalysisTab => 'विकास विश्लेषण';

  @override
  String get loyaltyTab => 'लॉयल्टी';

  @override
  String get totalCustomersLabel => 'कुल ग्राहक';

  @override
  String get activeCustomersLabel => 'सक्रिय ग्राहक';

  @override
  String get avgOrderValueLabel => 'औसत ऑर्डर मूल्य';

  @override
  String get tierDistribution => 'स्तर के अनुसार ग्राहक वितरण';

  @override
  String get activitySummary => 'गतिविधि सारांश';

  @override
  String get totalRevenueFromCustomers => 'पंजीकृत ग्राहकों से कुल राजस्व';

  @override
  String get avgOrderPerCustomer => 'प्रति ग्राहक औसत ऑर्डर मूल्य';

  @override
  String get activeCustomersLast30 => 'सक्रिय ग्राहक (पिछले 30 दिन)';

  @override
  String get newCustomersLast30 => 'नए ग्राहक (पिछले 30 दिन)';

  @override
  String topCustomersTitle(int count) {
    return 'शीर्ष $count ग्राहक';
  }

  @override
  String get bySpending => 'खर्च के अनुसार';

  @override
  String get byOrders => 'ऑर्डर के अनुसार';

  @override
  String get byPoints => 'अंकों के अनुसार';

  @override
  String ordersCount(int count) {
    return '$count ऑर्डर';
  }

  @override
  String get avgOrderStat => 'औसत ऑर्डर';

  @override
  String get loyaltyPointsStat => 'लॉयल्टी अंक';

  @override
  String get lastOrderStat => 'अंतिम ऑर्डर';

  @override
  String get newCustomerGrowth => 'नए ग्राहक वृद्धि';

  @override
  String get customerRetentionRate => 'ग्राहक प्रतिधारण दर';

  @override
  String get monthlyPeriod => 'मासिक';

  @override
  String get totalCustomersPeriod => 'कुल ग्राहक';

  @override
  String get activePeriod => 'सक्रिय';

  @override
  String get activeCustomersInfo =>
      'सक्रिय ग्राहक: पिछले 30 दिनों में खरीदारी की';

  @override
  String get cohortAnalysis => 'समूह विश्लेषण';

  @override
  String get cohortDescription => 'पहली खरीदारी के बाद रिटर्न दर';

  @override
  String get cohortGroup => 'समूह';

  @override
  String get month1 => 'महीना 1';

  @override
  String get month2 => 'महीना 2';

  @override
  String get month3 => 'महीना 3';

  @override
  String get loyaltyProgramStats => 'लॉयल्टी कार्यक्रम आंकड़े';

  @override
  String get totalPointsGranted => 'दिए गए कुल अंक';

  @override
  String get remainingPoints => 'शेष अंक';

  @override
  String get pointsValue => 'अंकों का मूल्य';

  @override
  String get pointsByTier => 'स्तर के अनुसार अंक';

  @override
  String get pointsUnit => 'अंक';

  @override
  String get redemptionPatterns => 'रिडेम्पशन पैटर्न';

  @override
  String get purchaseDiscount => 'खरीद छूट';

  @override
  String get freeProducts => 'मुफ्त उत्पाद';

  @override
  String get couponsLabel => 'कूपन';

  @override
  String get diamondTier => 'हीरा';

  @override
  String get goldTier => 'स्वर्ण';

  @override
  String get silverTier => 'रजत';

  @override
  String get bronzeTier => 'कांस्य';

  @override
  String get todayDate => 'आज';

  @override
  String get yesterdayDate => 'कल';

  @override
  String daysCountLabel(int count) {
    return '$count दिन';
  }

  @override
  String ofTotalLabel(String active, String total) {
    return '$active में से $total';
  }

  @override
  String get exportingReportMsg => 'रिपोर्ट निर्यात हो रही है...';

  @override
  String get januaryMonth => 'जनवरी';

  @override
  String get februaryMonth => 'फरवरी';

  @override
  String get marchMonth => 'मार्च';

  @override
  String get aprilMonth => 'अप्रैल';

  @override
  String get mayMonth => 'मई';

  @override
  String get juneMonth => 'जून';

  @override
  String errorLabel(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get saturdayDay => 'शनिवार';

  @override
  String get sundayDay => 'रविवार';

  @override
  String get mondayDay => 'सोमवार';

  @override
  String get tuesdayDay => 'मंगलवार';

  @override
  String get wednesdayDay => 'बुधवार';

  @override
  String get thursdayDay => 'गुरुवार';

  @override
  String get fridayDay => 'शुक्रवार';

  @override
  String get satShort => 'शनि';

  @override
  String get sunShort => 'रवि';

  @override
  String get monShort => 'सोम';

  @override
  String get tueShort => 'मंगल';

  @override
  String get wedShort => 'बुध';

  @override
  String get thuShort => 'गुरु';

  @override
  String get friShort => 'शुक्र';

  @override
  String get errorLoadingVatReport => 'VAT रिपोर्ट लोड करने में त्रुटि';

  @override
  String get errorLoadingComplaints => 'शिकायतें लोड करने में त्रुटि';

  @override
  String get errorLoadingCustomerReport => 'ग्राहक रिपोर्ट लोड करने में त्रुटि';

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
  String get confirmOrder => 'ऑर्डर की पुष्टि करें';

  @override
  String get orderNow => 'अभी ऑर्डर करें';

  @override
  String get orderCart => 'ऑर्डर कार्ट';

  @override
  String get orderReceived => 'आपका ऑर्डर प्राप्त हो गया!';

  @override
  String get orderBeingPrepared => 'आपका ऑर्डर जल्द से जल्द तैयार किया जाएगा';

  @override
  String get redirectingToHome => 'स्वचालित रूप से होम पेज पर जा रहा है...';

  @override
  String get kioskOrderNote => 'कियोस्क ऑर्डर';

  @override
  String pricePerUnit(String price) {
    return '$price SAR प्रति इकाई';
  }

  @override
  String get selectFromMenu => 'मेनू से चुनें';

  @override
  String orderCartWithCount(int count) {
    return 'ऑर्डर कार्ट ($count आइटम)';
  }

  @override
  String amountWithSar(String amount) {
    return '$amount SAR';
  }

  @override
  String qtyTimesPrice(int qty, String price) {
    return '$qty × $price SAR';
  }

  @override
  String get applyCoupon => 'कूपन लागू करें';

  @override
  String get enterCouponCode => 'कूपन कोड दर्ज करें';

  @override
  String get invalidCoupon => 'अमान्य या न मिला कूपन';

  @override
  String get couponExpired => 'कूपन की अवधि समाप्त हो गई है';

  @override
  String minimumPurchaseRequired(String amount) {
    return 'न्यूनतम खरीदारी $amount रियाल';
  }

  @override
  String couponDiscountApplied(String amount) {
    return '$amount रियाल की छूट लागू';
  }

  @override
  String get couponInvalid => 'अमान्य कूपन';

  @override
  String get customerAddFailed => 'ग्राहक जोड़ने में विफल';

  @override
  String get quantityColon => 'मात्रा:';

  @override
  String get riyal => 'रियाल';

  @override
  String get mobileNumber => 'मोबाइल नंबर';

  @override
  String get banknotes => 'नोट';

  @override
  String get coins => 'सिक्के';

  @override
  String get totalAmountLabel => 'कुल राशि';

  @override
  String denominationRiyal(String amount) {
    return '$amount रियाल';
  }

  @override
  String denominationHalala(String amount) {
    return '$amount हलाला';
  }

  @override
  String get countCurrency => 'मुद्रा गिनें';

  @override
  String confirmAmountSar(String amount) {
    return 'पुष्टि: $amount SAR';
  }

  @override
  String amountRiyal(String amount) {
    return '$amount रियाल';
  }

  @override
  String get itemDeletedMsg => 'आइटम हटा दिया गया';

  @override
  String get pressBackAgainToExit => 'बाहर निकलने के लिए फिर से दबाएं';

  @override
  String get deleteHeldInvoiceConfirm => 'इस लंबित चालान को हटाएं?';

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
  String get reportSettings => 'Report Settings';

  @override
  String get reportType => 'Report Type';

  @override
  String get paymentDistribution => 'Payment Distribution';

  @override
  String get allAccountsSettled => 'All customer accounts are settled';

  @override
  String get selectCustomers => 'Select Customers';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get preview => 'Preview';

  @override
  String get totalDebt => 'Total Debt';

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
  String get customerAccounts => 'Customer Accounts';

  @override
  String get paymentHistory => 'Payment History';

  @override
  String get keyboardShortcutsHint =>
      'Use these keyboard shortcuts for faster operations';

  @override
  String get proceedToPayment => 'Proceed to Payment';

  @override
  String get searchProducts => 'Search Products';

  @override
  String get splitPayment => 'Split Payment';

  @override
  String get applyDiscount => 'Apply Discount';

  @override
  String get holdInvoice => 'Hold Invoice';

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
      'यह चालान रद्द है और इसकी वापसी नहीं हो सकती';

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
  String get reportBalanceSheetTitle => 'الميزانية العمومية';

  @override
  String reportBalanceSheetAsOf(String date) {
    return 'كما في $date';
  }

  @override
  String get reportAssets => 'الأصول';

  @override
  String get reportCurrentAssets => 'الأصول المتداولة';

  @override
  String get reportCashInDrawer => 'النقد في الصندوق';

  @override
  String get reportAccountsReceivable => 'ذمم مدينة (عملاء)';

  @override
  String get reportInventoryValue => 'قيمة المخزون';

  @override
  String get reportTotalCurrentAssets => 'إجمالي الأصول المتداولة';

  @override
  String get reportTotalAssets => 'إجمالي الأصول';

  @override
  String get reportLiabilities => 'الالتزامات';

  @override
  String get reportCurrentLiabilities => 'الالتزامات المتداولة';

  @override
  String get reportAccountsPayable => 'ذمم دائنة (موردون)';

  @override
  String get reportTotalCurrentLiabilities => 'إجمالي الالتزامات المتداولة';

  @override
  String get reportTotalLiabilities => 'إجمالي الالتزامات';

  @override
  String get reportEquity => 'حقوق الملكية';

  @override
  String get reportNetEquity => 'صافي حقوق الملكية';

  @override
  String get reportAccountingEquation => 'معادلة المحاسبة';

  @override
  String get reportAssetsEqualsLiabilitiesPlusEquity =>
      'الأصول = الالتزامات + حقوق الملكية';

  @override
  String get reportCashFlowTitle => 'قائمة التدفق النقدي';

  @override
  String get reportNetCashFlow => 'صافي التدفق النقدي';

  @override
  String get reportOperatingActivities => 'الأنشطة التشغيلية';

  @override
  String get reportSalesReceipts => 'إيرادات المبيعات';

  @override
  String get reportExpensesPaid => 'المصروفات المدفوعة';

  @override
  String get reportTaxesPaidVat => 'الضرائب المدفوعة (ضريبة القيمة المضافة)';

  @override
  String get reportInvestingActivities => 'الأنشطة الاستثمارية';

  @override
  String get reportPurchasePayments => 'مدفوعات المشتريات';

  @override
  String get reportFinancingActivities => 'الأنشطة التمويلية';

  @override
  String get reportCashDeposit => 'إيداع نقدي';

  @override
  String get reportCashWithdrawal => 'سحب نقدي';

  @override
  String get reportThisQuarter => 'هذا الربع';

  @override
  String get reportThisYear => 'هذه السنة';

  @override
  String get reportQuarterly => 'ربع سنوي';

  @override
  String get reportAnnual => 'سنوي';

  @override
  String get reportDebtAgingTitle => 'تقرير أعمار الديون';

  @override
  String get reportDebtBucket0to30 => '0-30 يوم';

  @override
  String get reportDebtBucket31to60 => '31-60 يوم';

  @override
  String get reportDebtBucket61to90 => '61-90 يوم';

  @override
  String get reportDebtBucket90plus => '+90 يوم';

  @override
  String get reportTotalDebts => 'إجمالي الديون';

  @override
  String reportNDays(int count) {
    return '$count يوم';
  }

  @override
  String get reportComparisonTitle => 'تقرير المقارنة';

  @override
  String get reportIndicator => 'المؤشر';

  @override
  String get reportChange => 'التغيير';

  @override
  String get reportLastMonth => 'الشهر الماضي';

  @override
  String get reportLastQuarter => 'الربع الماضي';

  @override
  String get reportLastYear => 'السنة الماضية';

  @override
  String get reportCurrentPeriod => 'الفترة الحالية';

  @override
  String get reportPreviousPeriod => 'الفترة السابقة';

  @override
  String get reportZakatTitle => 'حساب الزكاة';

  @override
  String get reportZakatDue => 'وجبت الزكاة';

  @override
  String get reportZakatBelowNisab => 'لم يبلغ النصاب';

  @override
  String get reportZakatAmountDue => 'مقدار الزكاة الواجبة';

  @override
  String reportZakatRateOf(String rate) {
    return 'بنسبة $rate% من وعاء الزكاة';
  }

  @override
  String reportNisabThreshold(String amount) {
    return 'النصاب الشرعي: $amount ر.س';
  }

  @override
  String reportCurrentZakatBase(String amount) {
    return 'وعاء الزكاة الحالي: $amount ر.س';
  }

  @override
  String reportNisabInfo(String amount) {
    return 'النصاب: $amount ر.س (قيمة 85 جرام من الذهب تقريباً)';
  }

  @override
  String get reportZakatAssets => 'أصول الزكاة (+)';

  @override
  String get reportGoodsAndInventory => 'قيمة البضاعة والمخزون';

  @override
  String get reportAvailableCash => 'النقد المتوفر';

  @override
  String get reportExpectedReceivables => 'الديون المتوقع تحصيلها';

  @override
  String get reportDeductions => 'الخصومات (-)';

  @override
  String get reportDebtsToSuppliers => 'الديون الواجبة للموردين';

  @override
  String get reportOtherLiabilities => 'التزامات أخرى';

  @override
  String get reportNetZakatBase => 'وعاء الزكاة الصافي';

  @override
  String get reportZakatDisclaimer =>
      'تنبيه: هذا الحساب تقريبي. يُنصح بمراجعة مختص شرعي لتحديد الزكاة الواجبة بدقة.';

  @override
  String get reportPurchaseTitle => 'تقرير المشتريات';

  @override
  String get reportPurchasesBySupplier => 'المشتريات حسب المورد';

  @override
  String get reportRecentInvoices => 'آخر الفواتير';

  @override
  String get reportNoPurchasesInPeriod => 'لا توجد مشتريات في هذه الفترة';

  @override
  String reportNInvoices(int count) {
    return '$count فاتورة';
  }

  @override
  String get reportTotalTax => 'إجمالي الضريبة';

  @override
  String get reportExportSuccess => 'تم تصدير التقرير بنجاح';

  @override
  String reportExportFailed(String error) {
    return 'فشل التصدير: $error';
  }

  @override
  String get saSaveChanges => 'حفظ التغييرات';

  @override
  String get saSaving => 'جاري الحفظ...';

  @override
  String get saDiscardChanges => 'تجاهل';

  @override
  String get saConfirmSave => 'حفظ';

  @override
  String get saPlatformSettingsConfirm =>
      'هذه التغييرات تؤثر على جميع المؤسسات في المنصة. هل تريد الحفظ؟';

  @override
  String get saPlatformSettingsSaved => 'تم حفظ إعدادات المنصة بنجاح';

  @override
  String get saPlatformSettingsSaveFailed => 'فشل حفظ إعدادات المنصة';

  @override
  String get saErrorLoadingSettings => 'خطأ في تحميل الإعدادات';

  @override
  String get saEnvProduction => 'الإنتاج';

  @override
  String get saEnvSandbox => 'بيئة الاختبار';

  @override
  String get saMoyasarDescription => 'معالجة بطاقات الائتمان والخصم';

  @override
  String get saHyperpayDescription => 'بوابة دفع متعددة الطرق';

  @override
  String get saTabbyDescription => 'اشترِ الآن وادفع لاحقاً';

  @override
  String get saTamaraDescription => 'دفعات بالتقسيط';

  @override
  String get saGeneral => 'عام';

  @override
  String get saLanguageArabic => 'العربية';

  @override
  String get saLanguageEnglish => 'الإنجليزية';

  @override
  String get saAuditLog => 'سجل التدقيق';

  @override
  String get saAuditLogRefresh => 'تحديث';

  @override
  String get saAuditFilterAll => 'الكل';

  @override
  String get saAuditFilterAuth => 'مصادقة';

  @override
  String get saAuditFilterStore => 'متجر';

  @override
  String get saAuditFilterUser => 'مستخدم';

  @override
  String get saAuditFilterSubscription => 'اشتراك';

  @override
  String get saAuditSearchHint => 'ابحث بالبريد أو المعرّف أو الإجراء...';

  @override
  String get saAuditLoadFailed => 'فشل تحميل سجل التدقيق';

  @override
  String get saAuditLoadRetry => 'إعادة المحاولة';

  @override
  String get saAuditNoEntries => 'لا توجد سجلات تدقيق';

  @override
  String saAuditEntryBy(String email) {
    return 'بواسطة $email';
  }

  @override
  String get saReportsExportComingSoon =>
      'التصدير غير متاح حالياً — سيضاف قريباً';

  @override
  String get saSystemHealthMetricsNote =>
      'مقاييس المعالج/الذاكرة/القرص تتطلب نقطة خادم مخصصة — غير متصلة بعد';

  @override
  String get saMfaScanQr => 'امسح رمز QR في تطبيق المصادقة';

  @override
  String get saMfaSecretFallback => 'أو أدخل هذا المفتاح يدوياً:';

  @override
  String get saMfaCopied => 'تم النسخ';

  @override
  String get saErrorGeneric => 'حدث خطأ ما';

  @override
  String get saErrorNetwork => 'خطأ في الشبكة — تحقق من اتصالك';

  @override
  String get saErrorRetry => 'إعادة المحاولة';

  @override
  String get saErrorTechnical => 'تفاصيل تقنية';

  @override
  String get saNext => 'التالي';

  @override
  String get saBackToLogin => 'العودة لتسجيل الدخول';

  @override
  String get saPopularBadge => 'الأكثر طلباً';

  @override
  String get saRefresh => 'تحديث';

  @override
  String get saPlanUpdated => 'تم تحديث الباقة';

  @override
  String get saRenewal => 'التجديد';

  @override
  String get saBusinessTypeGrocery => 'بقالة';

  @override
  String get saBusinessTypeRestaurant => 'مطعم';

  @override
  String get saBusinessTypeRetail => 'تجزئة';

  @override
  String get saBusinessTypeServices => 'خدمات';

  @override
  String get saNoPlanRevenueData => 'لا توجد بيانات إيرادات للباقات';

  @override
  String get saNoStoreRevenueData => 'لا توجد بيانات إيرادات للمتاجر';

  @override
  String get saNoActiveUserData => 'لا توجد بيانات للمستخدمين النشطين';

  @override
  String get saNoTransactionData => 'لا توجد بيانات معاملات';

  @override
  String get saMfaSetupTitle => 'إعداد المصادقة الثنائية';

  @override
  String get saMfaVerifyTitle => 'التحقق الثنائي';

  @override
  String get saMfaEnrollmentInstruction =>
      'امسح رمز QR بتطبيق المصادقة (Google Authenticator أو Authy وغيرها) ثم أدخل الرمز المكوّن من 6 أرقام لإكمال الإعداد.';

  @override
  String get saMfaVerifyInstruction =>
      'أدخل الرمز المكوّن من 6 أرقام من تطبيق المصادقة.';

  @override
  String get saMfaCopy => 'نسخ';

  @override
  String get saMfaCompleteSetup => 'إكمال الإعداد';

  @override
  String get saMfaVerifyButton => 'تحقق';

  @override
  String get saMfaEnterValidCode => 'أدخل رمزاً صحيحاً مكوّناً من 6 أرقام';

  @override
  String get saMfaTooManyAttempts =>
      'محاولات فاشلة كثيرة. تم القفل لمدة 30 دقيقة.';

  @override
  String saMfaAccountLocked(int minutes) {
    return 'تم قفل الحساب. حاول مجدداً خلال $minutes دقيقة.';
  }

  @override
  String saMfaInvalidCode(int remaining) {
    return 'رمز غير صحيح. $remaining محاولات متبقية.';
  }

  @override
  String get saMfaEnrollmentFailed =>
      'فشل تسجيل المصادقة الثنائية. تأكد من تفعيل MFA في مشروع Supabase.';

  @override
  String get saMfaEnrollmentNoData => 'لم ترجع عملية تسجيل TOTP أي بيانات.';

  @override
  String get exchangeTitle => 'استبدال';

  @override
  String get itemsToReturn => 'عناصر للإرجاع';

  @override
  String get newItemsToAdd => 'عناصر جديدة للإضافة';

  @override
  String get exchangeRequiresNewItem =>
      'الاستبدال يتطلب إضافة عنصر جديد واحد على الأقل. للاسترداد البحت، استخدم شاشة المرتجعات التي تربط الاسترداد بفاتورة البيع الأصلية.';

  @override
  String get selectOriginalSaleTitle => 'اختر الفاتورة الأصلية';

  @override
  String get originalSaleLabel => 'الفاتورة الأصلية';

  @override
  String get originalSaleRequired =>
      'اختر الفاتورة الأصلية قبل تأكيد الاستبدال';

  @override
  String get changeOriginalSale => 'تغيير';

  @override
  String get searchByReceiptNumber => 'ابحث برقم الإيصال…';

  @override
  String recentSalesLastNDays(int days) {
    return 'مبيعات آخر $days يوم';
  }

  @override
  String noEligibleSalesFound(int days) {
    return 'لا توجد مبيعات مؤهَّلة في آخر $days يوم';
  }

  @override
  String get silentLimitBadgeTitle => 'تم بلوغ الحد الأقصى للعرض';

  @override
  String silentLimitBadgeMessage(int limit) {
    return 'تم عرض $limit صف. قد توجد بيانات إضافية مخفية — ضيِّق الفلاتر للحصول على نتائج كاملة.';
  }

  @override
  String get silentLimitBadgeAction => 'تضييق الفلاتر';

  @override
  String get backupPassphraseTitle => 'كلمة سر النسخة الاحتياطية';

  @override
  String get backupPassphraseHelper =>
      'اختر كلمة سر قوية لتشفير النسخة. لا توجد طريقة لاستعادتها إن نُسيَت.';

  @override
  String get backupPassphraseLabel => 'كلمة السر';

  @override
  String get backupPassphraseConfirmLabel => 'تأكيد كلمة السر';

  @override
  String get backupPassphraseTooShort =>
      'كلمة السر يجب أن تكون 8 أحرف على الأقل';

  @override
  String get backupPassphraseMismatch => 'كلمتا السر غير متطابقتين';

  @override
  String get backupEncryptedNotice =>
      'النسخة مشفّرة بـ AES-256-GCM. لا يمكن قراءتها بدون كلمة السر — احفظها في مكان آمن.';

  @override
  String get saveBackupFile => 'حفظ كملف';

  @override
  String get openBackupFile => 'فتح ملف';

  @override
  String get backupShareSubject => 'نسخة احتياطية مُشفَّرة - الحاي POS';

  @override
  String get backupCopiedToClipboardMasked =>
      'تم النسخ — سيُمسَح من الحافظة بعد 60 ثانية';

  @override
  String get restoreSourcePrompt => 'اختر مصدر النسخة الاحتياطية:';

  @override
  String get restoreOverwriteWarning =>
      'سيتم استبدال البيانات الحالية. لا يمكن التراجع.';

  @override
  String get restorePassphraseTitle => 'أدخل كلمة سر النسخة';

  @override
  String get restoreBadPassphrase => 'كلمة السر خاطئة أو الملف تالف';

  @override
  String get restoreCorruptBackup =>
      'الملف ليس نسخة احتياطية صالحة من تطبيق الحاي';

  @override
  String get restoreSchemaMismatchTitle => 'إصدار قاعدة بيانات غير متوافق';

  @override
  String restoreSchemaMismatchBody(int backupVersion, int appVersion) {
    return 'النسخة من إصدار $backupVersion، التطبيق على إصدار $appVersion. حدِّث التطبيق أو ارجع لإصدار مطابق قبل الاستعادة.';
  }

  @override
  String get unitCostLabel => 'تكلفة الوحدة (اختياري)';

  @override
  String get unitCostHint => 'أدخل تكلفة الشراء لتحديث متوسط التكلفة المرجح';

  @override
  String get autoBackupHelper =>
      'تفعيل النسخ الاحتياطي التلقائي حسب الجدول المُحدَّد';

  @override
  String autoBackupLastFiredAt(String when) {
    return 'آخر تشغيل تلقائي: $when';
  }

  @override
  String get splitReceiptTitle => 'إيصال الدفع المجزأ';

  @override
  String get paymentBreakdown => 'تفاصيل الدفع';

  @override
  String get zatcaQrTitle => 'رمز QR للفوترة الإلكترونية';

  @override
  String get splitRefundTitle => 'استرداد مجزأ';

  @override
  String get refundByPaymentMethod => 'الاسترداد حسب طريقة الدفع';

  @override
  String get exceedsOriginalAmount => 'المبلغ يتجاوز الأصلي';

  @override
  String get refundSummary => 'ملخص الاسترداد';

  @override
  String get originalTotal => 'الإجمالي الأصلي';

  @override
  String refundLineLabel(String method) {
    return 'استرداد $method';
  }

  @override
  String get refundAmountExceedsOriginal =>
      'المبلغ المسترد يتجاوز المبلغ الأصلي';

  @override
  String get filterCompletedOnly => 'المكتملة فقط';

  @override
  String get filterCompletedOnlyDesc => 'المبيعات غير المكتملة مخفية';

  @override
  String get pullToRefresh => 'اسحب للتحديث';

  @override
  String creditLimitWarningSnackbar(int percent) {
    return 'تحذير: الرصيد سيصل إلى $percent% من حد الائتمان';
  }

  @override
  String get creditLimitExceededTitle => 'تجاوز حد الائتمان';

  @override
  String creditLimitExceededBody(
      String newBalance, String limit, String overBy) {
    return 'الرصيد الجديد ($newBalance ر.س) يتجاوز حد الائتمان ($limit ر.س) بمبلغ $overBy ر.س.';
  }

  @override
  String get creditLimitOverrideButton => 'تجاوز بموافقة المدير';

  @override
  String get creditLimitBlockButton => 'إلغاء العملية';

  @override
  String get creditLimitOverrideAction => 'تجاوز حد الائتمان';

  @override
  String get unauthorizedAction => 'ليست لديك صلاحية لإجراء هذه العملية';

  @override
  String get noChangesToSave => 'لا توجد تغييرات للحفظ';

  @override
  String get stockTakeFinalizeConfirmTitle => 'تأكيد إنهاء الجرد';

  @override
  String stockTakeFinalizeConfirmBody(int count) {
    return 'سيُطبَّق $count تعديل على المخزون. هذا الإجراء لا يمكن التراجع عنه.';
  }

  @override
  String get stockTakeUnsavedTitle => 'حفظ مسودة الجرد؟';

  @override
  String get stockTakeUnsavedBody =>
      'لديك إدخالات غير محفوظة. الخروج بدون حفظ سيفقدها.';

  @override
  String get discard => 'تجاهل';
}
