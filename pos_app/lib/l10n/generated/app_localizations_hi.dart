// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

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
    return '$count शाखाएं';
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
    return 'आज $count ऑर्डर';
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
    return '$count मिनट पहले';
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
  String get scanBarcode => 'बारकोड स्कैन करें';

  @override
  String get activeProduct => 'सक्रिय उत्पाद';

  @override
  String get currency => 'SAR';

  @override
  String hoursAgo(int count) {
    return '$count घंटे पहले';
  }

  @override
  String daysAgo(int count) {
    return '$count दिन पहले';
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
    return '$count श्रेणियां';
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
    return '$count इनवॉइस भुगतान की प्रतीक्षा में';
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
    return '$count चयनित';
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
  String customerCount(String count) {
    return '$count ग्राहक';
  }

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
  String get customerAddedSuccess => 'ग्राहक सफलतापूर्वक जोड़ा गया';

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
  String get pasteCode => 'कोड पेस्ट करें';

  @override
  String devOtpMessage(String otp) {
    return 'डेव OTP: $otp';
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
  String get nearExpiry => 'قريب الانتهاء';

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
  String get lowStockLabel => 'कम';

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
  String get soldOut => 'बिक चुका';

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
}
