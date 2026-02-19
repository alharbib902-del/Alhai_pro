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
  String get lowStock => 'Low Stock';

  @override
  String get outOfStock => 'Out of Stock';

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
  String get revenue => 'Revenue';

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
  String invoiceNumberLabel(String number) {
    return 'نمبر:';
  }

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
  String get expenseAmount => 'Amount';

  @override
  String get expenseDate => 'Date';

  @override
  String get expenseCategory => 'Category';

  @override
  String get expenseNotes => 'Notes';

  @override
  String get noExpenses => 'کوئی اخراجات درج نہیں';

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
  String get shiftsTitle => 'شفٹیں';

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
  String get purchasesTitle => 'خریداری';

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
  String get suppliersTitle => 'سپلائرز';

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
  String get discountsTitle => 'چھوٹ';

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
  String get couponsTitle => 'کوپن';

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
  String get specialOffersTitle => 'خصوصی آفرز';

  @override
  String get addOffer => 'Add Offer';

  @override
  String get offerName => 'Offer Name';

  @override
  String get offerStartDate => 'Start Date';

  @override
  String get offerEndDate => 'End Date';

  @override
  String get smartPromotionsTitle => 'سمارٹ پروموشنز';

  @override
  String get activePromotions => 'Active Promotions';

  @override
  String get suggestedPromotions => 'AI Suggestions';

  @override
  String get loyaltyTitle => 'وفاداری پروگرام';

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
  String get notificationsTitle => 'اطلاعات';

  @override
  String get markAllRead => 'Mark All Read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get printQueueTitle => 'پرنٹ قطار';

  @override
  String get printAll => 'Print All';

  @override
  String get cancelAll => 'Cancel All';

  @override
  String get noPrintJobs => 'No print jobs';

  @override
  String get syncStatusTitle => 'سنک اسٹیٹس';

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
  String get driversTitle => 'ڈرائیورز';

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
  String get branchesTitle => 'شاخیں';

  @override
  String get addBranchAction => 'Add Branch';

  @override
  String get branchName => 'Branch Name';

  @override
  String get branchEmployees => 'Employees';

  @override
  String get branchSales => 'Today\'s Sales';

  @override
  String get profileTitle => 'پروفائل';

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
  String get settingsTitle => 'ترتیبات';

  @override
  String get storeSettings => 'اسٹور ترتیبات';

  @override
  String get posSettings => 'POS ترتیبات';

  @override
  String get printerSettings => 'پرنٹر ترتیبات';

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
  String get notificationSettings => 'Notifications';

  @override
  String get zatcaCompliance => 'ZATCA تعمیل';

  @override
  String get helpSupport => 'مدد اور سپورٹ';

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
  String get aiTrend => 'رجحان';

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
  String get aiInvestigation => 'تحقیقات';

  @override
  String get aiAssociationRules => 'Association Rules';

  @override
  String get aiBundleSuggestions => 'بنڈل تجاویز';

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
  String get aiMarketPosition => 'مارکیٹ پوزیشن';

  @override
  String get aiQueryInput => 'Ask anything about your data...';

  @override
  String get aiReportTemplate => 'Report Template';

  @override
  String get aiStaffPerformance => 'Staff Performance';

  @override
  String get aiShiftOptimization => 'شفٹ کی بہتری';

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
  String get noteOptional => 'نوٹ (اختیاری)';

  @override
  String get suspendInvoice => 'انوائس معطل کریں';

  @override
  String get invoiceSuspended => 'انوائس معطل ہو گئی';

  @override
  String nItems(int count) {
    return '$count آئٹم';
  }

  @override
  String saveSaleError(String error) {
    return 'فروخت محفوظ کرنے میں خرابی: $error';
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
  String get copyCode => 'کاپی';

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
  String get pasteCode => 'کوڈ پیسٹ کریں';

  @override
  String devOtpMessage(String otp) {
    return 'ڈیو OTP: $otp';
  }

  @override
  String get orderHistory => 'سجل الطلبات';

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
    return '$productA + $productB: $frequency بار دہرایا گیا';
  }

  @override
  String aiBundleActivated(String name) {
    return 'بنڈل فعال ہوا: $name';
  }

  @override
  String aiPromotionsGeneratedCount(int count) {
    return 'اسٹور ڈیٹا تجزیے کی بنیاد پر $count پروموشنز تیار ہوئیں';
  }

  @override
  String aiPromotionApplied(String title) {
    return 'لاگو ہوا: $title';
  }

  @override
  String aiConfidencePercent(String percent) {
    return 'اعتماد: $percent%';
  }

  @override
  String aiAlertsWithCount(int count) {
    return 'انتباہات ($count)';
  }

  @override
  String aiStaffCurrentSuggested(int current, int suggested) {
    return 'فی الحال $current عملہ → $suggested تجویز کردہ';
  }

  @override
  String aiMinutesAgo(int minutes) {
    return '$minutes منٹ پہلے';
  }

  @override
  String aiHoursAgo(int hours) {
    return '$hours گھنٹے پہلے';
  }

  @override
  String aiDaysAgo(int days) {
    return '$days دن پہلے';
  }

  @override
  String aiDetectedCount(int count) {
    return 'دریافت: $count';
  }

  @override
  String aiMatchedCount(int count) {
    return 'مماثل: $count';
  }

  @override
  String aiAccuracyPercent(String percent) {
    return 'درستگی: $percent%';
  }

  @override
  String aiProductAccepted(String name) {
    return '$name قبول ہوا';
  }

  @override
  String aiErrorOccurred(String error) {
    return 'خرابی واقع ہوئی: $error';
  }

  @override
  String aiErrorWithMessage(String error) {
    return 'خرابی: $error';
  }

  @override
  String get aiBasketAnalysis => 'AI ٹوکری تجزیہ';

  @override
  String get aiAssociations => 'وابستگیاں';

  @override
  String get aiCrossSell => 'کراس سیل';

  @override
  String get aiAvgBasketSize => 'اوسط ٹوکری سائز';

  @override
  String get aiProductUnit => 'مصنوعات';

  @override
  String get aiAvgBasketValue => 'اوسط ٹوکری قیمت';

  @override
  String get aiSaudiRiyal => 'SAR';

  @override
  String get aiStrongestAssociation => 'مضبوط ترین وابستگی';

  @override
  String get aiConversionRate => 'تبادلے کی شرح';

  @override
  String get aiFromSuggestions => 'تجاویز سے';

  @override
  String get aiAssistant => 'AI معاون';

  @override
  String get aiAskAboutStore => 'اپنی دکان کے بارے میں کوئی بھی سوال پوچھیں';

  @override
  String get aiClearChat => 'چیٹ صاف کریں';

  @override
  String get aiAssistantReady => 'AI معاون مدد کے لیے تیار ہے!';

  @override
  String get aiAskAboutSalesStock =>
      'فروخت، اسٹاک، گاہکوں، یا اپنی دکان کے بارے میں کچھ بھی پوچھیں';

  @override
  String get aiCompetitorAnalysis => 'حریف تجزیہ';

  @override
  String get aiPriceComparison => 'قیمت کا موازنہ';

  @override
  String get aiTrackedProducts => 'ٹریک کی گئی مصنوعات';

  @override
  String get aiCheaperThanCompetitors => 'حریفوں سے سستا';

  @override
  String get aiMoreExpensive => 'حریفوں سے مہنگا';

  @override
  String get aiAvgPriceDiff => 'اوسط قیمت فرق';

  @override
  String get aiSortByName => 'نام کے مطابق ترتیب';

  @override
  String get aiSortByPriceDiff => 'قیمت فرق کے مطابق ترتیب';

  @override
  String get aiSortByOurPrice => 'ہماری قیمت کے مطابق ترتیب';

  @override
  String get aiSortByCategory => 'زمرے کے مطابق ترتیب';

  @override
  String get aiSortLabel => 'ترتیب';

  @override
  String get aiPriceIndex => 'قیمت اشاریہ';

  @override
  String get aiQuality => 'معیار';

  @override
  String get aiBranches => 'شاخیں';

  @override
  String get aiMarkAllRead => 'سب کو پڑھا ہوا نشان زد کریں';

  @override
  String get aiNoAlertsCurrently => 'فی الحال کوئی انتباہ نہیں';

  @override
  String get aiFraudDetection => 'AI دھوکہ دہی کا پتہ';

  @override
  String get aiTotalAlerts => 'کل انتباہات';

  @override
  String get aiCriticalAlerts => 'اہم انتباہات';

  @override
  String get aiNeedsReview => 'جائزے کی ضرورت';

  @override
  String get aiRiskLevel => 'خطرے کی سطح';

  @override
  String get aiBehaviorScores => 'طرز عمل اسکور';

  @override
  String get aiRiskMeter => 'خطرے کا پیمانہ';

  @override
  String get aiHighRisk => 'زیادہ خطرہ';

  @override
  String get aiLowRisk => 'کم خطرہ';

  @override
  String get aiPatternRefund => 'واپسی';

  @override
  String get aiPatternAfterHours => 'اوقات کار کے بعد';

  @override
  String get aiPatternVoid => 'منسوخ';

  @override
  String get aiPatternDiscount => 'رعایت';

  @override
  String get aiPatternSplit => 'تقسیم';

  @override
  String get aiPatternCashDrawer => 'کیش دراز';

  @override
  String get aiNoFraudAlerts => 'کوئی انتباہ نہیں';

  @override
  String get aiSelectAlertToInvestigate =>
      'تحقیقات کے لیے فہرست سے ایک انتباہ منتخب کریں';

  @override
  String get aiStaffAnalytics => 'عملے کا تجزیہ';

  @override
  String get aiLeaderboard => 'لیڈر بورڈ';

  @override
  String get aiIndividualPerformance => 'انفرادی کارکردگی';

  @override
  String get aiAvgPerformance => 'اوسط کارکردگی';

  @override
  String get aiTotalSalesLabel => 'کل فروخت';

  @override
  String get aiTotalTransactions => 'کل لین دین';

  @override
  String get aiAvgVoidRate => 'اوسط منسوخی شرح';

  @override
  String get aiTeamGrowth => 'ٹیم کی ترقی';

  @override
  String get aiLeaderboardThisWeek => 'لیڈر بورڈ - اس ہفتے';

  @override
  String get aiSalesForecasting => 'فروخت کی پیشگوئی';

  @override
  String get aiSmartForecastSubtitle =>
      'مستقبل کی فروخت کی پیشگوئی کے لیے ذہین تجزیہ';

  @override
  String get aiForecastAccuracy => 'پیشگوئی کی درستگی';

  @override
  String get aiTrendUp => 'بڑھتا ہوا';

  @override
  String get aiTrendDown => 'گھٹتا ہوا';

  @override
  String get aiTrendStable => 'مستحکم';

  @override
  String get aiNextWeekForecast => 'اگلے ہفتے کی پیشگوئی';

  @override
  String get aiMonthForecast => 'مہینے کی پیشگوئی';

  @override
  String get aiForecastSummary => 'پیشگوئی کا خلاصہ';

  @override
  String get aiSalesTrendingUp => 'فروخت بڑھ رہی ہے - جاری رکھیں!';

  @override
  String get aiSalesDeclining => 'فروخت گھٹ رہی ہے - آفرز فعال کریں';

  @override
  String get aiSalesStable => 'فروخت مستحکم ہے - کارکردگی برقرار رکھیں';

  @override
  String get aiProductRecognition => 'مصنوعات کی شناخت';

  @override
  String get aiSingleProduct => 'ایک مصنوعہ';

  @override
  String get aiShelfScan => 'شیلف اسکین';

  @override
  String get aiBarcodeOcr => 'بارکوڈ OCR';

  @override
  String get aiPriceTag => 'قیمت ٹیگ';

  @override
  String get aiCameraArea => 'کیمرا ایریا';

  @override
  String get aiPointCameraAtProduct => 'کیمرا مصنوعہ یا شیلف کی طرف کریں';

  @override
  String get aiStartScan => 'اسکین شروع کریں';

  @override
  String get aiAnalyzingImage => 'تصویر کا تجزیہ ہو رہا ہے...';

  @override
  String get aiStartScanToSeeResults => 'نتائج دیکھنے کے لیے اسکین شروع کریں';

  @override
  String get aiScanResults => 'اسکین نتائج';

  @override
  String get aiProductSaved => 'مصنوعہ کامیابی سے محفوظ ہوا';

  @override
  String get aiPromotionDesigner => 'AI پروموشن ڈیزائنر';

  @override
  String get aiSuggestedPromotions => 'تجویز کردہ پروموشنز';

  @override
  String get aiRoiAnalysis => 'ROI تجزیہ';

  @override
  String get aiAbTest => 'A/B ٹیسٹ';

  @override
  String get aiSmartPromotionDesigner => 'سمارٹ پروموشن ڈیزائنر';

  @override
  String get aiProjectedRevenue => 'متوقع آمدنی';

  @override
  String get aiAiConfidence => 'AI اعتماد';

  @override
  String get aiSelectPromotionForRoi =>
      'ROI تجزیہ دیکھنے کے لیے پہلے ٹیب سے ایک پروموشن منتخب کریں';

  @override
  String get aiRevenueLabel => 'آمدنی';

  @override
  String get aiCostLabel => 'لاگت';

  @override
  String get aiDiscountLabel => 'رعایت';

  @override
  String get aiAbTestDescription =>
      'A/B ٹیسٹ آپ کے گاہکوں کو دو گروپوں میں تقسیم کرتا ہے اور بہترین کارکردگی والے کو جاننے کے لیے ہر گروپ کو مختلف آفر دکھاتا ہے۔';

  @override
  String get aiAbTestLaunched => 'A/B ٹیسٹ کامیابی سے شروع ہو گیا!';

  @override
  String get aiChatWithData => 'ڈیٹا کے ساتھ چیٹ - AI';

  @override
  String get aiChatWithYourData => 'اپنے ڈیٹا کے ساتھ چیٹ کریں';

  @override
  String get aiAskAboutDataInArabic =>
      'اپنی فروخت، اسٹاک اور گاہکوں کے بارے میں کوئی بھی سوال پوچھیں';

  @override
  String get aiTrySampleQuestions => 'ان میں سے ایک سوال آزمائیں';

  @override
  String get aiTip => 'مشورہ';

  @override
  String get aiTipDescription =>
      'آپ اردو یا انگریزی میں پوچھ سکتے ہیں۔ AI سیاق و سباق سمجھتا ہے اور نتائج دکھانے کا بہترین طریقہ چنتا ہے: نمبر، ٹیبل، یا چارٹ۔';

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
  String get lowStockLabel => 'کم';

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
  String get soldOut => 'فروخت ہو گیا';

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
  String get now => 'ابھی';

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
}
