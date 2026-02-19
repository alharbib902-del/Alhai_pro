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
  String get lowStock => 'कम स्टॉक';

  @override
  String get outOfStock => 'स्टॉक समाप्त';

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
  String get revenue => 'राजस्व';

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
  String get invoiceNumberLabel => 'नंबर:';

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
  String get expenseAmount => 'المبلغ';

  @override
  String get expenseDate => 'التاريخ';

  @override
  String get expenseCategory => 'التصنيف';

  @override
  String get expenseNotes => 'ملاحظات';

  @override
  String get noExpenses => 'कोई खर्च दर्ज नहीं';

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
  String get shiftsTitle => 'शिफ्ट';

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
  String get purchasesTitle => 'खरीद';

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
  String get suppliersTitle => 'आपूर्तिकर्ता';

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
  String get discountsTitle => 'छूट';

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
  String get couponsTitle => 'कूपन';

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
  String get specialOffersTitle => 'विशेष ऑफर';

  @override
  String get addOffer => 'إضافة عرض';

  @override
  String get offerName => 'اسم العرض';

  @override
  String get offerStartDate => 'تاريخ البدء';

  @override
  String get offerEndDate => 'تاريخ الانتهاء';

  @override
  String get smartPromotionsTitle => 'स्मार्ट प्रमोशन';

  @override
  String get activePromotions => 'العروض النشطة';

  @override
  String get suggestedPromotions => 'اقتراحات AI';

  @override
  String get loyaltyTitle => 'लॉयल्टी प्रोग्राम';

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
  String get notificationsTitle => 'सूचनाएं';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get printQueueTitle => 'प्रिंट कतार';

  @override
  String get printAll => 'طباعة الكل';

  @override
  String get cancelAll => 'إلغاء الكل';

  @override
  String get noPrintJobs => 'لا توجد مهام طباعة';

  @override
  String get syncStatusTitle => 'सिंक स्थिति';

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
  String get driversTitle => 'ड्राइवर';

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
  String get branchesTitle => 'शाखाएं';

  @override
  String get addBranchAction => 'إضافة فرع';

  @override
  String get branchName => 'اسم الفرع';

  @override
  String get branchEmployees => 'الموظفين';

  @override
  String get branchSales => 'مبيعات اليوم';

  @override
  String get profileTitle => 'प्रोफाइल';

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
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get storeSettings => 'स्टोर सेटिंग्स';

  @override
  String get posSettings => 'POS सेटिंग्स';

  @override
  String get printerSettings => 'प्रिंटर सेटिंग्स';

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
  String get notificationSettings => 'الإشعارات';

  @override
  String get zatcaCompliance => 'ZATCA अनुपालन';

  @override
  String get helpSupport => 'सहायता और समर्थन';

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
}
