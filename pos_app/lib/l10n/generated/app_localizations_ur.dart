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

  @override
  String get shoppingCart => 'شاپنگ کارٹ';

  @override
  String get selectOrSearchCustomer => 'گاہک منتخب کریں یا تلاش کریں';

  @override
  String get newCustomer => 'نیا';

  @override
  String get draft => 'مسودہ';

  @override
  String get pay => 'ادائیگی';

  @override
  String get haveCoupon => 'کیا آپ کے پاس ڈسکاؤنٹ کوپن ہے؟';

  @override
  String discountPercent(String percent) {
    return 'ڈسکاؤنٹ $percent%';
  }

  @override
  String get openDrawer => 'دراز کھولیں';

  @override
  String get suspend => 'معطل';

  @override
  String get quantitySoldOut => 'ختم ہو گیا';

  @override
  String get noProducts => 'کوئی مصنوعات نہیں';

  @override
  String get addProductsToStart => 'شروع کرنے کے لیے مصنوعات شامل کریں';

  @override
  String get undoComingSoon => 'واپس (جلد آ رہا ہے)';

  @override
  String get employees => 'ملازمین';

  @override
  String get loyaltyProgram => 'لائلٹی پروگرام';

  @override
  String get newBadge => 'نیا';

  @override
  String get technicalSupportShort => 'تکنیکی معاونت';

  @override
  String get productDetails => 'مصنوعات کی تفصیلات';

  @override
  String get stockMovements => 'اسٹاک کی نقل و حرکت';

  @override
  String get priceHistory => 'قیمت کی تاریخ';

  @override
  String get salesHistory => 'فروخت کی تاریخ';

  @override
  String get available => 'دستیاب';

  @override
  String get alertLevel => 'الرٹ لیول';

  @override
  String get reorderPoint => 'دوبارہ آرڈر پوائنٹ';

  @override
  String get revenue => 'آمدنی';

  @override
  String get supplier => 'سپلائر';

  @override
  String get lastSale => 'آخری فروخت';

  @override
  String get printLabel => 'لیبل پرنٹ کریں';

  @override
  String get copied => 'کاپی ہو گیا';

  @override
  String copiedToClipboard(String label) {
    return '$label کاپی ہو گیا';
  }

  @override
  String get active => 'فعال';

  @override
  String get inactive => 'غیر فعال';

  @override
  String get profitMargin => 'منافع کا مارجن';

  @override
  String get sellingPrice => 'فروخت کی قیمت';

  @override
  String get costPrice => 'لاگت کی قیمت';

  @override
  String get description => 'تفصیل';

  @override
  String get noDescription => 'کوئی تفصیل نہیں';

  @override
  String get productNotFound => 'مصنوعات نہیں ملی';

  @override
  String get stockStatus => 'اسٹاک کی حالت';

  @override
  String get currentStock => 'موجودہ اسٹاک';

  @override
  String get unit => 'یونٹ';

  @override
  String get units => 'یونٹس';

  @override
  String get date => 'تاریخ';

  @override
  String get type => 'قسم';

  @override
  String get reference => 'حوالہ';

  @override
  String get newBalance => 'نیا بیلنس';

  @override
  String get oldPrice => 'پرانی قیمت';

  @override
  String get newPrice => 'نئی قیمت';

  @override
  String get reason => 'وجہ';

  @override
  String get invoiceNumber => 'انوائس نمبر';

  @override
  String get categoryLabel => 'زمرہ';

  @override
  String get uncategorized => 'غیر زمرہ بند';

  @override
  String get noSupplier => 'کوئی سپلائر نہیں';

  @override
  String get moreOptions => 'مزید آپشنز';

  @override
  String get noStockMovements => 'کوئی اسٹاک حرکت نہیں';

  @override
  String get noPriceHistory => 'قیمت کی تاریخ نہیں';

  @override
  String get noSalesHistory => 'فروخت کی تاریخ نہیں';

  @override
  String get sale => 'فروخت';

  @override
  String get purchase => 'خریداری';

  @override
  String get adjustment => 'ایڈجسٹمنٹ';

  @override
  String get returnText => 'واپسی';

  @override
  String get waste => 'ضائع';

  @override
  String get initialStock => 'ابتدائی اسٹاک';

  @override
  String get searchByNameOrBarcode => 'نام یا بارکوڈ سے تلاش کریں...';

  @override
  String get hideFilters => 'فلٹرز چھپائیں';

  @override
  String get showFilters => 'فلٹرز دکھائیں';

  @override
  String get sortByName => 'نام';

  @override
  String get sortByPrice => 'قیمت';

  @override
  String get sortByStock => 'اسٹاک';

  @override
  String get sortByRecent => 'حالیہ';

  @override
  String get allItems => 'سب';

  @override
  String get clearFilters => 'فلٹرز صاف کریں';

  @override
  String get noBarcode => 'بارکوڈ نہیں';

  @override
  String stockCount(int count) {
    return 'اسٹاک: $count';
  }

  @override
  String get saveChanges => 'تبدیلیاں محفوظ کریں';

  @override
  String get addTheProduct => 'مصنوعات شامل کریں';

  @override
  String get editProduct => 'مصنوعات میں ترمیم';

  @override
  String get newProduct => 'نئی مصنوعات';

  @override
  String get minimumQuantity => 'کم از کم مقدار';

  @override
  String get selectCategory => 'زمرہ منتخب کریں';

  @override
  String get productImage => 'مصنوعات کی تصویر';

  @override
  String get trackInventory => 'انوینٹری ٹریک کریں';

  @override
  String get productSavedSuccess => 'مصنوعات کامیابی سے محفوظ ہو گئی';

  @override
  String get productAddedSuccess => 'مصنوعات کامیابی سے شامل ہو گئی';

  @override
  String get scanBarcode => 'بارکوڈ اسکین کریں';

  @override
  String get activeProduct => 'فعال مصنوعات';

  @override
  String get currency => 'ر.س';

  @override
  String hoursAgo(int count) {
    return '$count گھنٹے پہلے';
  }

  @override
  String daysAgo(int count) {
    return '$count دن پہلے';
  }

  @override
  String get supplierPriceUpdate => 'سپلائر کی قیمتوں کی تجدید';

  @override
  String get costIncrease => 'لاگت میں اضافہ';

  @override
  String get duplicateProduct => 'مصنوعات کی نقل';

  @override
  String get categoriesManagement => 'زمرہ جات کا انتظام';

  @override
  String categoriesCount(int count) {
    return '$count زمرے';
  }

  @override
  String get addCategory => 'زمرہ شامل کریں';

  @override
  String get editCategory => 'زمرہ ترمیم کریں';

  @override
  String get deleteCategory => 'زمرہ حذف کریں';

  @override
  String get categoryName => 'زمرے کا نام';

  @override
  String get categoryNameAr => 'نام (عربی)';

  @override
  String get categoryNameEn => 'نام (انگریزی)';

  @override
  String get parentCategory => 'بالائی زمرہ';

  @override
  String get noParentCategory => 'بالائی زمرہ نہیں (اصل)';

  @override
  String get sortOrder => 'ترتیب';

  @override
  String get categoryColor => 'رنگ';

  @override
  String get categoryIcon => 'آئیکن';

  @override
  String get categoryDetails => 'زمرے کی تفصیلات';

  @override
  String get categoryCreatedAt => 'تخلیق کی تاریخ';

  @override
  String get categoryProducts => 'زمرے کی مصنوعات';

  @override
  String get noCategorySelected => 'تفصیلات دیکھنے کے لیے زمرہ منتخب کریں';

  @override
  String get deleteCategoryConfirm =>
      'کیا آپ واقعی اس زمرے کو حذف کرنا چاہتے ہیں؟';

  @override
  String get categoryDeletedSuccess => 'زمرہ کامیابی سے حذف ہو گیا';

  @override
  String get categorySavedSuccess => 'زمرہ کامیابی سے محفوظ ہو گیا';

  @override
  String get searchCategories => 'زمرے تلاش کریں...';

  @override
  String get reorderCategories => 'ترتیب تبدیل کریں';

  @override
  String get noCategories => 'کوئی زمرے نہیں ملے';

  @override
  String get subcategories => 'ذیلی زمرے';

  @override
  String get activeStatus => 'فعال';

  @override
  String get inactiveStatus => 'غیر فعال';

  @override
  String get invoicesTitle => 'انوائسز';

  @override
  String get totalInvoices => 'کل انوائسز';

  @override
  String get totalPaid => 'کل ادا شدہ';

  @override
  String get totalPending => 'کل زیر التوا';

  @override
  String get totalOverdue => 'کل تاخیر شدہ';

  @override
  String get comparedToLastMonth => 'پچھلے مہینے کے مقابلے میں';

  @override
  String ofTotalDue(String percent) {
    return 'کل واجبات کا $percent%';
  }

  @override
  String invoicesWaitingPayment(int count) {
    return '$count انوائسز ادائیگی کے منتظر';
  }

  @override
  String get sendReminderNow => 'ابھی یاددہانی بھیجیں';

  @override
  String get revenueAnalysis => 'آمدنی کا تجزیہ';

  @override
  String get last7Days => 'آخری 7 دن';

  @override
  String get thisMonthPeriod => 'اس مہینے';

  @override
  String get thisYearPeriod => 'اس سال';

  @override
  String get paymentMethods => 'ادائیگی کے طریقے';

  @override
  String get cashPayment => 'نقد';

  @override
  String get cardPayment => 'کارڈ';

  @override
  String get walletPayment => 'والیٹ';

  @override
  String get saveCurrentFilter => 'موجودہ فلٹر محفوظ کریں';

  @override
  String get statusAll => 'حالت: سب';

  @override
  String get statusPaid => 'ادا شدہ';

  @override
  String get statusPending => 'زیر التوا';

  @override
  String get statusOverdue => 'تاخیر شدہ';

  @override
  String get statusCancelled => 'منسوخ';

  @override
  String get resetFilters => 'ری سیٹ';

  @override
  String get createInvoice => 'انوائس بنائیں';

  @override
  String get invoiceNumberCol => 'انوائس نمبر';

  @override
  String get customerNameCol => 'گاہک کا نام';

  @override
  String get dateCol => 'تاریخ';

  @override
  String get amountCol => 'رقم';

  @override
  String get statusCol => 'حالت';

  @override
  String get paymentCol => 'ادائیگی';

  @override
  String get actionsCol => 'ایکشنز';

  @override
  String get viewInvoice => 'دیکھیں';

  @override
  String get printInvoice => 'پرنٹ';

  @override
  String get exportPdf => 'PDF';

  @override
  String get sendWhatsapp => 'واٹس ایپ';

  @override
  String get deleteInvoice => 'حذف';

  @override
  String get reminder => 'یاددہانی';

  @override
  String get exportAll => 'سب ایکسپورٹ';

  @override
  String get printReport => 'رپورٹ پرنٹ';

  @override
  String get more => 'مزید';

  @override
  String showingResults(int from, int to, int total) {
    return '$total میں سے $from سے $to دکھا رہے ہیں';
  }

  @override
  String get newInvoice => 'نئی انوائس';

  @override
  String get selectCustomer => 'گاہک منتخب کریں';

  @override
  String get cashCustomerGeneral => 'نقد گاہک (عام)';

  @override
  String get addNewCustomer => '+ نیا گاہک شامل کریں';

  @override
  String get productsSection => 'مصنوعات';

  @override
  String get addProductToInvoice => '+ مصنوعات شامل کریں';

  @override
  String get productCol => 'مصنوعات';

  @override
  String get quantityCol => 'مقدار';

  @override
  String get priceCol => 'قیمت';

  @override
  String get dueDate => 'مقررہ تاریخ';

  @override
  String get invoiceTotal => 'کل:';

  @override
  String get saveInvoice => 'انوائس محفوظ کریں';

  @override
  String get deleteConfirm => 'کیا آپ کو یقین ہے؟';

  @override
  String get deleteInvoiceMsg =>
      'کیا آپ واقعی یہ انوائس حذف کرنا چاہتے ہیں؟ یہ عمل واپس نہیں ہو سکتا۔';

  @override
  String get yesDelete => 'ہاں، حذف کریں';

  @override
  String get copiedSuccess => 'کامیابی سے کاپی ہوا';

  @override
  String get invoiceDeleted => 'انوائس کامیابی سے حذف ہوئی';

  @override
  String get sat => 'ہفتہ';

  @override
  String get sun => 'اتوار';

  @override
  String get mon => 'پیر';

  @override
  String get tue => 'منگل';

  @override
  String get wed => 'بدھ';

  @override
  String get thu => 'جمعرات';

  @override
  String get fri => 'جمعہ';

  @override
  String selected(int count) {
    return '$count منتخب';
  }

  @override
  String get bulkPrint => 'پرنٹ';

  @override
  String get bulkExportPdf => 'PDF ایکسپورٹ';

  @override
  String get allRightsReservedFooter =>
      '© 2026 Alhai POS. تمام حقوق محفوظ ہیں۔';

  @override
  String get privacyPolicyFooter => 'رازداری کی پالیسی';

  @override
  String get termsFooter => 'شرائط و ضوابط';

  @override
  String get supportFooter => 'تکنیکی مدد';

  @override
  String get paid => 'ادا شدہ';

  @override
  String get overdue => 'تاخیر شدہ';

  @override
  String get creditCard => 'کریڈٹ کارڈ';

  @override
  String get electronicWallet => 'الیکٹرانک والیٹ';

  @override
  String get searchInvoiceHint => 'انوائس نمبر، گاہک سے تلاش...';

  @override
  String get customerDetails => 'گاہک کی تفصیلات';

  @override
  String get customerProfileAndTransactions => 'پروفائل اور لین دین کا جائزہ';

  @override
  String get customerDetailTitle => 'گاہک کی تفصیلات';

  @override
  String get totalPurchases => 'کل خریداری';

  @override
  String get loyaltyPoints => 'لائلٹی پوائنٹس';

  @override
  String get lastVisit => 'آخری دورہ';

  @override
  String get newSaleAction => 'نئی فروخت';

  @override
  String get editInfo => 'معلومات میں ترمیم';

  @override
  String get whatsapp => 'واٹس ایپ';

  @override
  String get blockCustomer => 'گاہک کو بلاک کریں';

  @override
  String get purchasesTab => 'خریداریاں';

  @override
  String get accountTab => 'اکاؤنٹ';

  @override
  String get debtsTab => 'قرضے';

  @override
  String get analyticsTab => 'تجزیات';

  @override
  String get recentOrdersLog => 'حالیہ آرڈرز کا ریکارڈ';

  @override
  String get exportCsv => 'CSV ایکسپورٹ';

  @override
  String get searchByInvoiceNumber => 'انوائس نمبر سے تلاش...';

  @override
  String get items => 'اشیاء';

  @override
  String get viewDetails => 'تفصیلات دیکھیں';

  @override
  String get financialLedger => 'مالی لین دین کا ریکارڈ';

  @override
  String get cashPaymentEntry => 'نقد ادائیگی';

  @override
  String get walletTopup => 'والیٹ ٹاپ اپ';

  @override
  String get loyaltyPointsDeduction => 'لائلٹی پوائنٹس کی کٹوتی';

  @override
  String redeemPoints(int count) {
    return '$count پوائنٹس ریڈیم';
  }

  @override
  String get viewFullLedger => 'مکمل دیکھیں';

  @override
  String get currentBalance => 'موجودہ بیلنس';

  @override
  String get creditLimit => 'کریڈٹ لمٹ';

  @override
  String get used => 'استعمال شدہ';

  @override
  String get topUpBalance => 'بیلنس ٹاپ اپ';

  @override
  String get overdueDebt => 'تاخیر شدہ';

  @override
  String get upcomingDebt => 'آنے والا';

  @override
  String get payNow => 'ابھی ادا کریں';

  @override
  String get remind => 'یاد دہانی';

  @override
  String get monthlySpending => 'ماہانہ اخراجات';

  @override
  String get purchaseDistribution => 'زمرے کے مطابق خریداری کی تقسیم';

  @override
  String get last6Months => 'آخری 6 ماہ';

  @override
  String get thisYear => 'اس سال';

  @override
  String get averageOrder => 'اوسط آرڈر';

  @override
  String get purchaseFrequency => 'خریداری کی تعدد';

  @override
  String everyNDays(int count) {
    return 'ہر $count دن';
  }

  @override
  String get spendingGrowth => 'اخراجات میں اضافہ';

  @override
  String get favoriteProduct => 'پسندیدہ مصنوعات';

  @override
  String get internalNotes => 'اندرونی نوٹس (صرف عملے کے لیے)';

  @override
  String get addNote => 'شامل کریں';

  @override
  String get addNewNote => 'نیا نوٹ شامل کریں...';

  @override
  String joinedDate(String date) {
    return 'شمولیت: $date';
  }

  @override
  String lastUpdated(String time) {
    return 'آخری اپڈیٹ: $time';
  }

  @override
  String showingOrders(int from, int to, int total) {
    return '$total میں سے $from-$to دکھا رہے ہیں';
  }

  @override
  String get vegetables => 'سبزیاں';

  @override
  String get dairy => 'ڈیری';

  @override
  String get meat => 'گوشت';

  @override
  String get bakery => 'بیکری';

  @override
  String get other => 'دیگر';

  @override
  String get returns => 'واپسی';

  @override
  String get salesReturns => 'فروخت کی واپسی';

  @override
  String get purchaseReturns => 'خریداری کی واپسی';

  @override
  String get totalReturns => 'کل واپسیاں';

  @override
  String get totalRefundedAmount => 'کل واپس کی گئی رقم';

  @override
  String get mostReturned => 'سب سے زیادہ واپس';

  @override
  String get processed => 'واپس کیا گیا';

  @override
  String get newReturn => 'نئی واپسی';

  @override
  String get createNewReturn => 'نئی واپسی بنائیں';

  @override
  String get processReturnRequest => 'فروخت واپسی کی درخواست';

  @override
  String get returnNumber => 'واپسی نمبر';

  @override
  String get originalInvoice => 'اصل بل';

  @override
  String get returnReason => 'واپسی کی وجہ';

  @override
  String get returnAmount => 'واپسی رقم';

  @override
  String get returnStatus => 'حالت';

  @override
  String get returnDate => 'تاریخ';

  @override
  String get returnActions => 'کارروائیاں';

  @override
  String get returnRefunded => 'واپس کیا گیا';

  @override
  String get returnRejected => 'مسترد';

  @override
  String get defectiveProduct => 'خراب پروڈکٹ';

  @override
  String get wrongProduct => 'غلط پروڈکٹ';

  @override
  String get customerRequest => 'گاہک کی درخواست';

  @override
  String get otherReason => 'دیگر';

  @override
  String get quickSearch => 'فوری تلاش...';

  @override
  String get exportData => 'ایکسپورٹ';

  @override
  String get printData => 'پرنٹ';

  @override
  String get approve => 'منظور';

  @override
  String get reject => 'مسترد';

  @override
  String get previous => 'پچھلا';

  @override
  String get invoiceStep => 'بل';

  @override
  String get itemsStep => 'آئٹمز';

  @override
  String get reasonStep => 'وجہ';

  @override
  String get confirmStep => 'تصدیق';

  @override
  String get enterInvoiceNumber => 'بل نمبر';

  @override
  String get invoiceExample => 'مثال: #INV-889';

  @override
  String get loadInvoice => 'لوڈ';

  @override
  String invoiceLoaded(String number) {
    return 'بل #$number لوڈ ہو گیا';
  }

  @override
  String invoiceLoadedCustomer(String customer, String date) {
    return 'گاہک: $customer | تاریخ: $date';
  }

  @override
  String get selectItemsInfo =>
      'واپسی کے لیے آئٹمز منتخب کریں۔ فروخت سے زیادہ مقدار واپس نہیں ہو سکتی۔';

  @override
  String availableToReturn(int count) {
    return 'دستیاب: $count';
  }

  @override
  String get alreadyReturnedFully => 'پوری مقدار پہلے ہی واپس ہو چکی';

  @override
  String get returnReasonLabel => 'واپسی کی وجہ (منتخب آئٹمز کے لیے)';

  @override
  String get additionalDetails => 'اضافی تفصیلات (دیگر کے لیے ضروری)...';

  @override
  String get confirmReturn => 'واپسی کی تصدیق';

  @override
  String get refundAmount => 'واپسی رقم';

  @override
  String get refundMethod => 'واپسی کا طریقہ';

  @override
  String get cashRefund => 'نقد';

  @override
  String get storeCredit => 'سٹور کریڈٹ';

  @override
  String get returnCreatedSuccess => 'واپسی کامیابی سے بنائی گئی';

  @override
  String get noReturns => 'کوئی واپسی نہیں';

  @override
  String get noReturnsDesc => 'ابھی تک کوئی واپسی ریکارڈ نہیں ہوئی۔';

  @override
  String timesReturned(int count, int percent) {
    return '$count بار ($percent% کل میں سے)';
  }

  @override
  String get fromInvoice => 'بل سے';

  @override
  String get dateFromTo => 'تاریخ سے - تک';

  @override
  String get returnCopied => 'نمبر کامیابی سے کاپی ہوا';

  @override
  String ofTotalProcessed(int percent) {
    return '$percent% پروسیس ہوا';
  }

  @override
  String get invoiceDetails => 'انوائس کی تفصیلات';

  @override
  String get invoiceNumberLabel => 'نمبر:';

  @override
  String get additionalOptions => 'اضافی اختیارات';

  @override
  String get duplicateInvoice => 'ڈپلیکیٹ بنائیں';

  @override
  String get returnMerchandise => 'سامان واپسی';

  @override
  String get voidInvoice => 'انوائس منسوخ کریں';

  @override
  String get printBtn => 'پرنٹ';

  @override
  String get downloadBtn => 'ڈاؤن لوڈ';

  @override
  String get paidSuccessfully => 'ادائیگی کامیاب';

  @override
  String get amountReceivedFull => 'پوری رقم موصول ہوئی';

  @override
  String get completedStatus => 'مکمل';

  @override
  String get pendingStatus => 'زیر التوا';

  @override
  String get voidedStatus => 'منسوخ';

  @override
  String get storeName => 'محلے کا سپر مارکیٹ';

  @override
  String get storeAddress => 'ریاض، الملز ضلع، تخصصی سڑک';

  @override
  String get simplifiedTaxInvoice => 'آسان ٹیکس انوائس';

  @override
  String get dateAndTime => 'تاریخ اور وقت';

  @override
  String get cashierLabel => 'کیشیئر';

  @override
  String get itemCol => 'آئٹم';

  @override
  String get quantityColDetail => 'مقدار';

  @override
  String get priceColDetail => 'قیمت';

  @override
  String get totalCol => 'کل';

  @override
  String get subtotalLabel => 'ذیلی کل';

  @override
  String get discountVip => 'رعایت (VIP ممبر)';

  @override
  String get vatLabel => 'ویلیو ایڈڈ ٹیکس (15%)';

  @override
  String get grandTotalLabel => 'مجموعی کل';

  @override
  String get paymentMethodLabel => 'ادائیگی کا طریقہ';

  @override
  String get amountPaidLabel => 'ادا شدہ رقم';

  @override
  String get zatcaElectronic => 'ZATCA - الیکٹرانک انوائس';

  @override
  String get scanToVerify => 'تصدیق کے لیے اسکین کریں';

  @override
  String get includesVat15 => '15% VAT شامل ہے';

  @override
  String get thankYouVisit => 'آپ کی آمد کا شکریہ!';

  @override
  String get wishNiceDay => 'آپ کا دن اچھا گزرے';

  @override
  String get customerInfo => 'گاہک کی معلومات';

  @override
  String get editBtn => 'ترمیم';

  @override
  String vipSince(String year) {
    return '$year سے VIP گاہک';
  }

  @override
  String get activeStatusLabel => 'فعال';

  @override
  String get callBtn => 'کال';

  @override
  String get recordBtn => 'ریکارڈ';

  @override
  String get quickActions => 'فوری اقدامات';

  @override
  String get sendWhatsappAction => 'واٹس ایپ بھیجیں';

  @override
  String get sendEmailAction => 'ای میل بھیجیں';

  @override
  String get downloadPdfAction => 'PDF ڈاؤن لوڈ';

  @override
  String get shareLinkAction => 'لنک شیئر کریں';

  @override
  String get eventLog => 'ایونٹ لاگ';

  @override
  String get paymentCompleted => 'ادائیگی مکمل';

  @override
  String get processedViaGateway => 'پیمنٹ گیٹ وے سے پروسیس';

  @override
  String minutesAgoDetail(int count) {
    return '$count منٹ پہلے';
  }

  @override
  String get invoiceCreated => 'انوائس بنائی گئی';

  @override
  String byUser(String name) {
    return '$name کے ذریعے';
  }

  @override
  String todayAt(String time) {
    return 'آج، $time';
  }

  @override
  String get orderStarted => 'آرڈر شروع ہوا';

  @override
  String get cashierSessionOpened => 'کیشیئر سیشن کھولا گیا';

  @override
  String get technicalData => 'تکنیکی ڈیٹا';

  @override
  String get deviceIdLabel => 'Device ID';

  @override
  String get terminalLabel => 'Terminal';

  @override
  String get softwareVersion => 'Software V';

  @override
  String get voidInvoiceConfirm => 'انوائس منسوخ کریں؟';

  @override
  String get voidInvoiceMsg =>
      'یہ انوائس مستقل طور پر منسوخ ہو جائے گی۔ کیا آپ کو یقین ہے؟';

  @override
  String get voidReasonLabel => 'منسوخی کی وجہ (ضروری)';

  @override
  String get voidReasonEntry => 'اندراج کی غلطی';

  @override
  String get voidReasonCustomer => 'گاہک کی درخواست';

  @override
  String get voidReasonDamaged => 'خراب پروڈکٹ';

  @override
  String get voidReasonOther => 'دیگر وجہ...';

  @override
  String get confirmVoid => 'منسوخی کی تصدیق';

  @override
  String get invoiceVoided => 'انوائس کامیابی سے منسوخ ہو گئی';

  @override
  String copiedText(String text) {
    return 'کاپی ہوا: $text';
  }

  @override
  String visaEnding(String digits) {
    return 'Visa ختم ہوتا ہے $digits';
  }

  @override
  String get mobileActionPrint => 'پرنٹ';

  @override
  String get mobileActionWhatsapp => 'واٹس ایپ';

  @override
  String get mobileActionEmail => 'ای میل';

  @override
  String get mobileActionMore => 'مزید';

  @override
  String get sarCurrency => 'ر.س';

  @override
  String skuLabel(String code) {
    return 'SKU: $code';
  }

  @override
  String get helpText => 'مدد';

  @override
  String get customerLedger => 'کسٹمر لیجر';

  @override
  String get accountStatement => 'اکاؤنٹ اسٹیٹمنٹ';

  @override
  String get allPeriods => 'سب';

  @override
  String get threeMonths => '3 ماہ';

  @override
  String get allMovements => 'تمام لین دین';

  @override
  String get adjustments => 'ایڈجسٹمنٹس';

  @override
  String get statementCol => 'تفصیل';

  @override
  String get referenceCol => 'حوالہ';

  @override
  String get debitCol => 'ڈیبٹ';

  @override
  String get creditCol => 'کریڈٹ';

  @override
  String get balanceCol => 'بیلنس';

  @override
  String get openingBalance => 'ابتدائی بیلنس';

  @override
  String get totalDebit => 'کل ڈیبٹ';

  @override
  String get totalCredit => 'کل کریڈٹ';

  @override
  String get finalBalance => 'حتمی بیلنس';

  @override
  String get manualAdjustment => 'دستی ایڈجسٹمنٹ';

  @override
  String get adjustmentType => 'ایڈجسٹمنٹ کی قسم';

  @override
  String get debitAdjustment => 'ڈیبٹ ایڈجسٹمنٹ';

  @override
  String get creditAdjustment => 'کریڈٹ ایڈجسٹمنٹ';

  @override
  String get adjustmentAmount => 'ایڈجسٹمنٹ کی رقم';

  @override
  String get adjustmentReason => 'ایڈجسٹمنٹ کی وجہ';

  @override
  String get adjustmentDate => 'ایڈجسٹمنٹ کی تاریخ';

  @override
  String get saveAdjustment => 'ایڈجسٹمنٹ محفوظ کریں';

  @override
  String get adjustmentSaved => 'ایڈجسٹمنٹ کامیابی سے محفوظ ہو گئی';

  @override
  String get enterValidAmount => 'درست رقم درج کریں';

  @override
  String get dueOnCustomer => 'کسٹمر پر واجب الادا';

  @override
  String get customerHasCredit => 'کسٹمر کا کریڈٹ بیلنس ہے';

  @override
  String get noTransactions => 'کوئی لین دین نہیں';

  @override
  String get recordPaymentBtn => 'ادائیگی ریکارڈ کریں';

  @override
  String get returnEntry => 'واپسی';

  @override
  String get adjustmentEntry => 'ایڈجسٹمنٹ';

  @override
  String get ordersHistory => 'آرڈرز کی تاریخ';

  @override
  String get totalOrdersLabel => 'کل آرڈرز';

  @override
  String get completedOrders => 'مکمل';

  @override
  String get pendingOrders => 'زیر التوا';

  @override
  String get cancelledOrders => 'منسوخ';

  @override
  String get searchOrderHint => 'آرڈر نمبر، کسٹمر، یا فون سے تلاش...';

  @override
  String get channelLabel => 'چینل';

  @override
  String get last30Days => 'آخری 30 دن';

  @override
  String get orderDetails => 'آرڈر کی تفصیلات';

  @override
  String get unpaidLabel => 'ادائیگی نہیں ہوئی';

  @override
  String get voidTransaction => 'لین دین منسوخ کریں';

  @override
  String get voidSaleTransaction => 'فروخت کا لین دین منسوخ کریں';

  @override
  String get voidWarningTitle => 'اہم تنبیہ: اس عمل کو واپس نہیں کیا جا سکتا';

  @override
  String get voidWarningDesc =>
      'اس لین دین کو منسوخ کرنے سے انوائس مکمل طور پر منسوخ ہو جائے گا۔';

  @override
  String get voidWarningShort =>
      'یہ عمل انوائس کو مکمل طور پر منسوخ کر دے گا۔ واپسی ممکن نہیں۔';

  @override
  String get enterInvoiceToVoid => 'منسوخی کے لیے انوائس نمبر درج کریں';

  @override
  String get searchByInvoiceOrBarcode =>
      'انوائس نمبر یا بارکوڈ اسکینر استعمال کریں';

  @override
  String get invoiceExampleVoid => 'مثال: #INV-2024-8892';

  @override
  String get activateBarcode => 'بارکوڈ اسکینر فعال کریں';

  @override
  String get scanBarcodeMobile => 'بارکوڈ اسکین کریں';

  @override
  String get searchForInvoiceToVoid => 'منسوخی کے لیے انوائس تلاش کریں';

  @override
  String get enterNumberOrScan =>
      'نمبر درج کریں یا بارکوڈ اسکینر استعمال کریں۔';

  @override
  String get salesInvoice => 'فروخت انوائس';

  @override
  String get invoiceCompleted => 'مکمل';

  @override
  String get paidCash => 'ادائیگی: نقد';

  @override
  String get customerLabel => 'صارف';

  @override
  String get dateAndTimeLabel => 'تاریخ اور وقت';

  @override
  String get voidImpactSummary => 'منسوخی کے اثرات کا خلاصہ';

  @override
  String voidImpactItemsReturn(int count) {
    return '$count اشیاء خود بخود اسٹاک میں واپس ہوں گی۔';
  }

  @override
  String voidImpactRefund(String amount, String currency) {
    return 'رقم $amount $currency کاٹی/واپس کی جائے گی۔';
  }

  @override
  String returnedItems(int count) {
    return 'واپس شدہ اشیاء ($count)';
  }

  @override
  String get viewAllItems => 'سب دیکھیں';

  @override
  String moreItemsHint(int count, String amount, String currency) {
    return '+ $count مزید اشیاء (کل: $amount $currency)';
  }

  @override
  String get voidReason => 'منسوخی کی وجہ';

  @override
  String get voidReasonRequired => 'منسوخی کی وجہ *';

  @override
  String get customerRequestReason => 'صارف کی درخواست';

  @override
  String get wrongItemsReason => 'غلط اشیاء';

  @override
  String get duplicateInvoiceReason => 'ڈپلیکیٹ انوائس';

  @override
  String get systemErrorReason => 'سسٹم کی خرابی';

  @override
  String get otherReasonVoid => 'دیگر';

  @override
  String get additionalNotesVoid => 'اضافی نوٹس...';

  @override
  String get additionalDetailsRequired =>
      'اضافی تفصیلات (دیگر کے لیے ضروری)...';

  @override
  String get managerApproval => 'مینیجر کی منظوری';

  @override
  String get managerApprovalRequired => 'مینیجر کی منظوری ضروری ہے';

  @override
  String amountExceedsLimit(String amount, String currency) {
    return 'رقم مجاز حد ($amount $currency) سے زیادہ ہے، مینیجر PIN درج کریں۔';
  }

  @override
  String get enterPinCode => 'PIN کوڈ درج کریں';

  @override
  String get pinSentToManager => 'عارضی کوڈ مینیجر کے فون پر بھیجا گیا';

  @override
  String get defaultManagerPin => 'مینیجر کا ڈیفالٹ کوڈ: 1234';

  @override
  String get confirmVoidAction => 'میں اس لین دین کی منسوخی کی تصدیق کرتا ہوں';

  @override
  String get confirmVoidDesc =>
      'میں نے تفصیلات کا جائزہ لیا ہے اور مکمل ذمہ داری لیتا ہوں۔';

  @override
  String get cancelAction => 'منسوخ';

  @override
  String get confirmFinalVoid => 'حتمی منسوخی کی تصدیق';

  @override
  String get invoiceNotFound => 'انوائس نہیں ملا';

  @override
  String get invoiceNotFoundDesc =>
      'درج کردہ نمبر کی تصدیق کریں یا بارکوڈ استعمال کریں۔';

  @override
  String get trySearchAgain => 'دوبارہ تلاش کریں';

  @override
  String get voidSuccess => 'لین دین کامیابی سے منسوخ ہو گیا';

  @override
  String qtyLabel(int count) {
    return 'مقدار: $count';
  }

  @override
  String get manageCustomersAndAccounts => 'صارفین اور اکاؤنٹس کا انتظام';

  @override
  String get totalCustomersCount => 'کل صارفین';

  @override
  String get outstandingDebts => 'واجب الادا قرضے';

  @override
  String customerCount(String count) {
    return '$count صارف';
  }

  @override
  String get creditBalance => 'صارف کریڈٹ';

  @override
  String get filterByLabel => 'فلٹر';

  @override
  String get debtors => 'مقروض';

  @override
  String get creditorsLabel => 'قرض دار';

  @override
  String get quickActionsLabel => 'فوری اقدامات';

  @override
  String get sendDebtReminder => 'قرض کی یاددہانی بھیجیں';

  @override
  String get exportAccountStatement => 'اکاؤنٹ اسٹیٹمنٹ برآمد';

  @override
  String cancelSelectionCount(String count) {
    return 'انتخاب منسوخ ($count)';
  }

  @override
  String get searchByNameOrPhone => 'نام یا فون سے تلاش... (Ctrl+F)';

  @override
  String get sortByBalance => 'بیلنس';

  @override
  String get refreshF5 => 'ریفریش (F5)';

  @override
  String get loadingCustomers => 'صارفین لوڈ ہو رہے ہیں...';

  @override
  String get payDebt => 'قرض ادائیگی';

  @override
  String dueAmountLabel(String amount) {
    return 'واجب الادا: $amount ریال';
  }

  @override
  String get paymentAmountLabel => 'ادائیگی کی رقم';

  @override
  String get fullAmount => 'مکمل';

  @override
  String get payAction => 'ادائیگی';

  @override
  String paymentRecorded(String amount) {
    return '$amount ریال ادائیگی درج';
  }

  @override
  String get customerAddedSuccess => 'صارف کامیابی سے شامل';

  @override
  String get customerNameRequired => 'صارف کا نام *';

  @override
  String get owedLabel => 'واجب الادا';

  @override
  String get hasBalanceLabel => 'کریڈٹ';

  @override
  String get zeroLabel => 'صفر';

  @override
  String get addAction => 'شامل کریں';

  @override
  String get expenses => 'اخراجات';

  @override
  String get expenseCategories => 'اخراجات کی اقسام';

  @override
  String get addExpense => 'اخراجات شامل کریں';

  @override
  String get totalExpenses => 'کل اخراجات';

  @override
  String get thisMonthExpenses => 'اس ماہ';

  @override
  String get expenseAmount => 'المبلغ';

  @override
  String get expenseDate => 'التاريخ';

  @override
  String get expenseCategory => 'التصنيف';

  @override
  String get expenseNotes => 'ملاحظات';

  @override
  String get noExpenses => 'کوئی اخراجات درج نہیں';

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
  String get shiftsTitle => 'شفٹیں';

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
  String get purchasesTitle => 'خریداری';

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
  String get suppliersTitle => 'سپلائرز';

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
  String get discountsTitle => 'چھوٹ';

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
  String get couponsTitle => 'کوپن';

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
  String get specialOffersTitle => 'خصوصی آفرز';

  @override
  String get addOffer => 'إضافة عرض';

  @override
  String get offerName => 'اسم العرض';

  @override
  String get offerStartDate => 'تاريخ البدء';

  @override
  String get offerEndDate => 'تاريخ الانتهاء';

  @override
  String get smartPromotionsTitle => 'سمارٹ پروموشنز';

  @override
  String get activePromotions => 'العروض النشطة';

  @override
  String get suggestedPromotions => 'اقتراحات AI';

  @override
  String get loyaltyTitle => 'وفاداری پروگرام';

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
  String get notificationsTitle => 'اطلاعات';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get printQueueTitle => 'پرنٹ قطار';

  @override
  String get printAll => 'طباعة الكل';

  @override
  String get cancelAll => 'إلغاء الكل';

  @override
  String get noPrintJobs => 'لا توجد مهام طباعة';

  @override
  String get syncStatusTitle => 'سنک اسٹیٹس';

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
  String get driversTitle => 'ڈرائیورز';

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
  String get branchesTitle => 'شاخیں';

  @override
  String get addBranchAction => 'إضافة فرع';

  @override
  String get branchName => 'اسم الفرع';

  @override
  String get branchEmployees => 'الموظفين';

  @override
  String get branchSales => 'مبيعات اليوم';

  @override
  String get profileTitle => 'پروفائل';

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
  String get settingsTitle => 'ترتیبات';

  @override
  String get storeSettings => 'اسٹور ترتیبات';

  @override
  String get posSettings => 'POS ترتیبات';

  @override
  String get printerSettings => 'پرنٹر ترتیبات';

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
  String get securitySettings => 'سکیورٹی';

  @override
  String get usersManagement => 'صارف انتظام';

  @override
  String get rolesPermissions => 'کردار اور اجازتیں';

  @override
  String get activityLog => 'سرگرمی لاگ';

  @override
  String get backupSettings => 'بیک اپ اور بحالی';

  @override
  String get notificationSettings => 'الإشعارات';

  @override
  String get zatcaCompliance => 'ZATCA تعمیل';

  @override
  String get helpSupport => 'مدد اور سپورٹ';

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
  String get liveChat => 'لائیو چیٹ';

  @override
  String get emailSupport => 'ای میل سپورٹ';

  @override
  String get phoneSupport => 'فون سپورٹ';

  @override
  String get whatsappSupport => 'واٹس ایپ سپورٹ';

  @override
  String get userGuide => 'صارف گائیڈ';

  @override
  String get videoTutorials => 'ویڈیو ٹیوٹوریلز';

  @override
  String get changelog => 'تبدیلیوں کا لاگ';

  @override
  String get appInfo => 'ایپ کی معلومات';

  @override
  String get buildNumber => 'بلڈ نمبر';

  @override
  String get notificationChannels => 'اطلاع کے چینلز';

  @override
  String get alertTypes => 'الرٹ کی اقسام';

  @override
  String get salesAlerts => 'فروخت الرٹس';

  @override
  String get inventoryAlerts => 'انوینٹری الرٹس';

  @override
  String get securityAlerts => 'سیکورٹی الرٹس';

  @override
  String get reportAlerts => 'رپورٹ الرٹس';

  @override
  String get users => 'صارفین';

  @override
  String get zatcaRegistered => 'ZATCA میں رجسٹرڈ';

  @override
  String get zatcaPhase2Active => 'مرحلہ 2 فعال';

  @override
  String get registrationInfo => 'رجسٹریشن کی معلومات';

  @override
  String get businessName => 'کاروبار کا نام';

  @override
  String get branchCode => 'برانچ کوڈ';

  @override
  String get qrCodeOnInvoice => 'انوائس پر QR کوڈ';

  @override
  String get certificates => 'سرٹیفکیٹس';

  @override
  String get csidCertificate => 'CSID سرٹیفکیٹ';

  @override
  String get valid => 'درست';

  @override
  String get privateKey => 'پرائیویٹ کی';

  @override
  String get configured => 'ترتیب شدہ';
}
