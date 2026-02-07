// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'پوائنٹ آف سیل';

  @override
  String get login => 'لاگ ان';

  @override
  String get logout => 'لاگ آؤٹ';

  @override
  String get welcome => 'خوش آمدید';

  @override
  String get welcomeBack => 'واپسی پر خوش آمدید';

  @override
  String get phone => 'فون نمبر';

  @override
  String get phoneHint => '05xxxxxxxx';

  @override
  String get phoneRequired => 'فون نمبر درکار ہے';

  @override
  String get phoneInvalid => 'غلط فون نمبر';

  @override
  String get otp => 'تصدیقی کوڈ';

  @override
  String get otpHint => 'تصدیقی کوڈ درج کریں';

  @override
  String get otpSent => 'تصدیقی کوڈ بھیج دیا گیا';

  @override
  String get otpResend => 'کوڈ دوبارہ بھیجیں';

  @override
  String get otpExpired => 'تصدیقی کوڈ ختم ہو گیا';

  @override
  String get otpInvalid => 'غلط تصدیقی کوڈ';

  @override
  String otpResendIn(int seconds) {
    return '$seconds سیکنڈ میں دوبارہ بھیجیں';
  }

  @override
  String get pin => 'پن کوڈ';

  @override
  String get pinHint => 'پن کوڈ درج کریں';

  @override
  String get pinRequired => 'پن کوڈ درکار ہے';

  @override
  String get pinInvalid => 'غلط پن کوڈ';

  @override
  String pinAttemptsRemaining(int count) {
    return 'باقی کوششیں: $count';
  }

  @override
  String pinLocked(int minutes) {
    return 'اکاؤنٹ لاک ہو گیا۔ $minutes منٹ بعد کوشش کریں';
  }

  @override
  String get home => 'ہوم';

  @override
  String get dashboard => 'ڈیش بورڈ';

  @override
  String get pos => 'پوائنٹ آف سیل';

  @override
  String get products => 'مصنوعات';

  @override
  String get categories => 'زمرے';

  @override
  String get inventory => 'انوینٹری';

  @override
  String get customers => 'گاہک';

  @override
  String get orders => 'آرڈرز';

  @override
  String get invoices => 'انوائسز';

  @override
  String get reports => 'رپورٹس';

  @override
  String get settings => 'ترتیبات';

  @override
  String get sales => 'فروخت';

  @override
  String get salesAnalytics => 'فروخت کا تجزیہ';

  @override
  String get refund => 'واپسی';

  @override
  String get todaySales => 'آج کی فروخت';

  @override
  String get totalSales => 'کل فروخت';

  @override
  String get averageSale => 'اوسط فروخت';

  @override
  String get cart => 'کارٹ';

  @override
  String get cartEmpty => 'کارٹ خالی ہے';

  @override
  String get addToCart => 'کارٹ میں شامل کریں';

  @override
  String get removeFromCart => 'کارٹ سے ہٹائیں';

  @override
  String get clearCart => 'کارٹ صاف کریں';

  @override
  String get checkout => 'چیک آؤٹ';

  @override
  String get payment => 'ادائیگی';

  @override
  String get paymentMethod => 'ادائیگی کا طریقہ';

  @override
  String get cash => 'نقد';

  @override
  String get card => 'کارڈ';

  @override
  String get credit => 'ادھار';

  @override
  String get transfer => 'ٹرانسفر';

  @override
  String get paymentSuccess => 'ادائیگی کامیاب';

  @override
  String get paymentFailed => 'ادائیگی ناکام';

  @override
  String get price => 'قیمت';

  @override
  String get quantity => 'مقدار';

  @override
  String get total => 'کل';

  @override
  String get subtotal => 'ذیلی کل';

  @override
  String get discount => 'رعایت';

  @override
  String get tax => 'ٹیکس';

  @override
  String get vat => 'ویلیو ایڈڈ ٹیکس';

  @override
  String get grandTotal => 'مجموعی کل';

  @override
  String get product => 'پروڈکٹ';

  @override
  String get productName => 'پروڈکٹ کا نام';

  @override
  String get productCode => 'پروڈکٹ کوڈ';

  @override
  String get barcode => 'بارکوڈ';

  @override
  String get sku => 'SKU';

  @override
  String get stock => 'اسٹاک';

  @override
  String get lowStock => 'کم اسٹاک';

  @override
  String get outOfStock => 'اسٹاک ختم';

  @override
  String get inStock => 'دستیاب';

  @override
  String get customer => 'گاہک';

  @override
  String get customerName => 'گاہک کا نام';

  @override
  String get customerPhone => 'گاہک کا فون';

  @override
  String get debt => 'قرض';

  @override
  String get balance => 'بیلنس';

  @override
  String get search => 'تلاش';

  @override
  String get searchHint => 'یہاں تلاش کریں...';

  @override
  String get filter => 'فلٹر';

  @override
  String get sort => 'ترتیب';

  @override
  String get all => 'سب';

  @override
  String get add => 'شامل کریں';

  @override
  String get edit => 'ترمیم';

  @override
  String get delete => 'حذف';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get cancel => 'منسوخ';

  @override
  String get confirm => 'تصدیق';

  @override
  String get close => 'بند کریں';

  @override
  String get back => 'واپس';

  @override
  String get next => 'اگلا';

  @override
  String get done => 'مکمل';

  @override
  String get submit => 'جمع کروائیں';

  @override
  String get retry => 'دوبارہ کوشش کریں';

  @override
  String get loading => 'لوڈ ہو رہا ہے...';

  @override
  String get noData => 'کوئی ڈیٹا نہیں';

  @override
  String get noResults => 'کوئی نتائج نہیں';

  @override
  String get error => 'خرابی';

  @override
  String get errorOccurred => 'ایک خرابی پیش آئی';

  @override
  String get tryAgain => 'دوبارہ کوشش کریں';

  @override
  String get connectionError => 'کنکشن کی خرابی';

  @override
  String get noInternet => 'انٹرنیٹ کنکشن نہیں';

  @override
  String get offline => 'آف لائن';

  @override
  String get online => 'آن لائن';

  @override
  String get success => 'کامیابی';

  @override
  String get warning => 'انتباہ';

  @override
  String get info => 'معلومات';

  @override
  String get yes => 'ہاں';

  @override
  String get no => 'نہیں';

  @override
  String get today => 'آج';

  @override
  String get yesterday => 'کل';

  @override
  String get thisWeek => 'اس ہفتے';

  @override
  String get thisMonth => 'اس مہینے';

  @override
  String get shift => 'شفٹ';

  @override
  String get openShift => 'شفٹ شروع کریں';

  @override
  String get closeShift => 'شفٹ بند کریں';

  @override
  String get shiftSummary => 'شفٹ کا خلاصہ';

  @override
  String get cashDrawer => 'کیش دراز';

  @override
  String get receipt => 'رسید';

  @override
  String get printReceipt => 'رسید پرنٹ کریں';

  @override
  String get shareReceipt => 'رسید شیئر کریں';

  @override
  String get sync => 'مطابقت پذیری';

  @override
  String get syncing => 'مطابقت ہو رہی ہے...';

  @override
  String get syncComplete => 'مطابقت مکمل';

  @override
  String get syncFailed => 'مطابقت ناکام';

  @override
  String get lastSync => 'آخری مطابقت';

  @override
  String get language => 'زبان';

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
  String get theme => 'تھیم';

  @override
  String get darkMode => 'ڈارک موڈ';

  @override
  String get lightMode => 'لائٹ موڈ';

  @override
  String get systemMode => 'سسٹم موڈ';

  @override
  String get notifications => 'اطلاعات';

  @override
  String get security => 'سیکیورٹی';

  @override
  String get printer => 'پرنٹر';

  @override
  String get backup => 'بیک اپ';

  @override
  String get help => 'مدد';

  @override
  String get about => 'ایپ کے بارے میں';

  @override
  String get version => 'ورژن';

  @override
  String get copyright => 'جملہ حقوق محفوظ ہیں';

  @override
  String get deleteConfirmTitle => 'حذف کی تصدیق';

  @override
  String get deleteConfirmMessage => 'کیا آپ واقعی حذف کرنا چاہتے ہیں؟';

  @override
  String get logoutConfirmTitle => 'لاگ آؤٹ کی تصدیق';

  @override
  String get logoutConfirmMessage => 'کیا آپ واقعی لاگ آؤٹ کرنا چاہتے ہیں؟';

  @override
  String get requiredField => 'یہ فیلڈ ضروری ہے';

  @override
  String get invalidFormat => 'غلط فارمیٹ';

  @override
  String minLength(int min) {
    return 'کم از کم $min حروف ہونے چاہئیں';
  }

  @override
  String maxLength(int max) {
    return '$max حروف سے کم ہونا چاہیے';
  }

  @override
  String get welcomeTitle => 'واپسی پر خوش آمدید! 👋';

  @override
  String get welcomeSubtitle =>
      'اپنی دکان کو آسانی اور تیزی سے چلانے کے لیے لاگ ان کریں';

  @override
  String get welcomeSubtitleShort => 'اپنی دکان چلانے کے لیے لاگ ان کریں';

  @override
  String get brandName => 'Al-Hal POS';

  @override
  String get brandTagline => 'سمارٹ پوائنٹ آف سیل سسٹم';

  @override
  String get enterPhoneToContinue => 'جاری رکھنے کے لیے اپنا فون نمبر درج کریں';

  @override
  String get pleaseEnterValidPhone => 'براہ کرم درست فون نمبر درج کریں';

  @override
  String get otpSentViaWhatsApp => 'واٹس ایپ کے ذریعے تصدیقی کوڈ بھیج دیا گیا';

  @override
  String get otpResent => 'تصدیقی کوڈ دوبارہ بھیج دیا گیا';

  @override
  String get enterOtpFully => 'براہ کرم مکمل تصدیقی کوڈ درج کریں';

  @override
  String get maxAttemptsReached =>
      'زیادہ سے زیادہ کوششیں ہو گئیں۔ براہ کرم نیا کوڈ طلب کریں';

  @override
  String waitMinutes(int minutes) {
    return 'زیادہ سے زیادہ کوششیں ہو گئیں۔ $minutes منٹ انتظار کریں';
  }

  @override
  String waitSeconds(int seconds) {
    return 'براہ کرم $seconds سیکنڈ انتظار کریں';
  }

  @override
  String resendIn(String time) {
    return 'دوبارہ بھیجیں ($time)';
  }

  @override
  String get resendCode => 'کوڈ دوبارہ بھیجیں';

  @override
  String get changeNumber => 'نمبر تبدیل کریں';

  @override
  String get verificationCode => 'تصدیقی کوڈ';

  @override
  String remainingAttempts(int count) {
    return 'باقی کوششیں: $count';
  }

  @override
  String get technicalSupport => 'تکنیکی معاونت';

  @override
  String get privacyPolicy => 'رازداری کی پالیسی';

  @override
  String get termsAndConditions => 'شرائط و ضوابط';

  @override
  String get allRightsReserved => '© 2026 الحل سسٹم۔ جملہ حقوق محفوظ ہیں۔';

  @override
  String get dayMode => 'دن کا موڈ';

  @override
  String get nightMode => 'رات کا موڈ';

  @override
  String get selectBranch => 'شاخ منتخب کریں';

  @override
  String get selectBranchDesc =>
      'وہ شاخ منتخب کریں جس پر آپ کام کرنا چاہتے ہیں';

  @override
  String get availableBranches => 'دستیاب شاخیں';

  @override
  String branchCount(int count) {
    return '$count شاخیں';
  }

  @override
  String branchSelected(String name) {
    return '$name منتخب کر لیا گیا';
  }

  @override
  String get addBranch => 'نئی شاخ شامل کریں';

  @override
  String get comingSoon => 'یہ فیچر جلد آ رہا ہے';

  @override
  String get tryDifferentSearch => 'مختلف الفاظ سے تلاش کریں';

  @override
  String get selectLanguage => 'زبان منتخب کریں';

  @override
  String get languageChangeInfo =>
      'اپنی پسندیدہ ڈسپلے زبان منتخب کریں۔ تبدیلیاں فوری طور پر لاگو ہوں گی۔';

  @override
  String get centralManagement => 'مرکزی انتظام';

  @override
  String get centralManagementDesc =>
      'ایک جگہ سے اپنی تمام شاخوں اور گوداموں کو کنٹرول کریں۔ تمام POS پوائنٹس پر فوری رپورٹس اور انوینٹری سنک حاصل کریں۔';

  @override
  String get selectBranchToContinue => 'جاری رکھنے کے لیے شاخ منتخب کریں';

  @override
  String get youHaveAccessToBranches =>
      'آپ کو درج ذیل شاخوں تک رسائی حاصل ہے۔ شروع کرنے کے لیے ایک منتخب کریں۔';

  @override
  String get searchForBranch => 'شاخ تلاش کریں...';

  @override
  String get openNow => 'ابھی کھلا ہے';

  @override
  String closedOpensAt(String time) {
    return 'بند (کھلتا ہے $time)';
  }

  @override
  String get loggedInAs => 'لاگ ان بطور';

  @override
  String get support247 => '24/7 معاونت';

  @override
  String get analyticsTools => 'تجزیاتی ٹولز';

  @override
  String get uptime => 'اپ ٹائم';

  @override
  String get dashboardTitle => 'ڈیش بورڈ';

  @override
  String get searchPlaceholder => 'عام تلاش...';

  @override
  String get mainBranch => 'مین برانچ (ریاض)';

  @override
  String get todaySalesLabel => 'آج کی فروخت';

  @override
  String get ordersCountLabel => 'آرڈرز کی تعداد';

  @override
  String get newCustomersLabel => 'نئے گاہک';

  @override
  String get stockAlertsLabel => 'اسٹاک الرٹس';

  @override
  String get productsUnit => 'مصنوعات';

  @override
  String get salesAnalysis => 'فروخت کا تجزیہ';

  @override
  String get storePerformance => 'اس ہفتے اسٹور کی کارکردگی';

  @override
  String get weekly => 'ہفتہ وار';

  @override
  String get monthly => 'ماہانہ';

  @override
  String get yearly => 'سالانہ';

  @override
  String get quickAction => 'فوری کارروائی';

  @override
  String get newSale => 'نئی فروخت';

  @override
  String get addProduct => 'مصنوعات شامل کریں';

  @override
  String get returnItem => 'واپسی';

  @override
  String get dailyReport => 'یومیہ رپورٹ';

  @override
  String get closeDay => 'دن بند کریں';

  @override
  String get topSelling => 'سب سے زیادہ فروخت';

  @override
  String ordersToday(int count) {
    return 'آج $count آرڈرز';
  }

  @override
  String get recentTransactions => 'حالیہ ٹرانزیکشنز';

  @override
  String get viewAll => 'سب دیکھیں';

  @override
  String get orderNumber => 'آرڈر نمبر';

  @override
  String get time => 'وقت';

  @override
  String get status => 'حیثیت';

  @override
  String get amount => 'رقم';

  @override
  String get action => 'کارروائی';

  @override
  String get completed => 'مکمل';

  @override
  String get returned => 'واپس';

  @override
  String get pending => 'زیر التواء';

  @override
  String get cancelled => 'منسوخ';

  @override
  String get guestCustomer => 'مہمان گاہک';

  @override
  String minutesAgo(int count) {
    return '$count منٹ پہلے';
  }

  @override
  String get posSystem => 'پوائنٹ آف سیل سسٹم';

  @override
  String get branchManager => 'برانچ مینیجر';

  @override
  String get settingsSection => 'ترتیبات';

  @override
  String get systemSettings => 'سسٹم ترتیبات';

  @override
  String get sar => 'ر.س';

  @override
  String get daily => 'روزانہ';

  @override
  String get goodMorning => 'صبح بخیر';

  @override
  String get goodEvening => 'شام بخیر';

  @override
  String get cashCustomer => 'نقد گاہک';

  @override
  String get noTransactionsToday => 'آج کوئی لین دین نہیں';

  @override
  String get comparedToYesterday => 'کل کے مقابلے میں';

  @override
  String get ordersText => 'آرڈرز آج';

  @override
  String get storeManagement => 'اسٹور مینجمنٹ';

  @override
  String get finance => 'مالیات';

  @override
  String get teamSection => 'ٹیم';

  @override
  String get fullscreen => 'فل اسکرین';

  @override
  String goodMorningName(String name) {
    return 'صبح بخیر، $name!';
  }

  @override
  String goodEveningName(String name) {
    return 'شام بخیر، $name!';
  }
}
