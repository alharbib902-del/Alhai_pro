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
}
