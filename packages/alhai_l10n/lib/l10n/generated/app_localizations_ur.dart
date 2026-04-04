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
  String pageNotFoundPath(String path) {
    return 'الصفحة غير موجودة: $path';
  }

  @override
  String get noInvoiceDataAvailable => 'لا تتوفر بيانات الفاتورة';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شاخیں',
      many: '$count شاخیں',
      few: '$count شاخیں',
      two: '2 شاخیں',
      one: '1 شاخ',
      zero: 'کوئی شاخ نہیں',
    );
    return '$_temp0';
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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'آج $count آرڈرز',
      many: 'آج $count آرڈرز',
      few: 'آج $count آرڈرز',
      two: 'آج 2 آرڈرز',
      one: 'آج 1 آرڈر',
      zero: 'آج کوئی آرڈر نہیں',
    );
    return '$_temp0';
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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منٹ پہلے',
      many: '$count منٹ پہلے',
      few: '$count منٹ پہلے',
      two: '2 منٹ پہلے',
      one: '1 منٹ پہلے',
    );
    return '$_temp0';
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
  String undoneRemoved(String name) {
    return 'تراجع: حُذف $name';
  }

  @override
  String undoneAdded(String name) {
    return 'تراجع: أُعيد $name';
  }

  @override
  String undoneQtyChanged(String name, int from, int to) {
    return 'تراجع: $name الكمية $from → $to';
  }

  @override
  String get nothingToUndo => 'لا يوجد شيء للتراجع';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count گھنٹے پہلے',
      many: '$count گھنٹے پہلے',
      few: '$count گھنٹے پہلے',
      two: '2 گھنٹے پہلے',
      one: '1 گھنٹہ پہلے',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دن پہلے',
      many: '$count دن پہلے',
      few: '$count دن پہلے',
      two: '2 دن پہلے',
      one: '1 دن پہلے',
    );
    return '$_temp0';
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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count زمرے',
      many: '$count زمرے',
      few: '$count زمرے',
      two: '2 زمرے',
      one: '1 زمرہ',
      zero: 'کوئی زمرہ نہیں',
    );
    return '$_temp0';
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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count انوائسز ادائیگی کے منتظر',
      many: '$count انوائسز ادائیگی کے منتظر',
      few: '$count انوائسز ادائیگی کے منتظر',
      two: '2 انوائسز ادائیگی کے منتظر',
      one: '1 انوائس ادائیگی کے منتظر',
      zero: 'کوئی انوائس زیر التوا نہیں',
    );
    return '$_temp0';
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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منتخب',
      many: '$count منتخب',
      few: '$count منتخب',
      two: '2 منتخب',
      one: '1 منتخب',
      zero: 'کوئی منتخب نہیں',
    );
    return '$_temp0';
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
  String customerAddedSuccess(String name) {
    return '$name شامل کر دیا گیا';
  }

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
  String get resetAction => 'ری سیٹ';

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
  String get orderHistory => 'آرڈر کی تاریخ';

  @override
  String get history => 'تاریخ';

  @override
  String get selectDateRange => 'مدت منتخب کریں';

  @override
  String get orderSearchHint => 'آرڈر نمبر یا گاہک ID سے تلاش کریں...';

  @override
  String get noOrders => 'کوئی آرڈرز نہیں';

  @override
  String get orderStatusConfirmed => 'تصدیق شدہ';

  @override
  String get orderStatusPreparing => 'تیاری جاری';

  @override
  String get orderStatusReady => 'تیار';

  @override
  String get orderStatusDelivering => 'ڈیلیوری جاری';

  @override
  String get filterOrders => 'آرڈرز فلٹر کریں';

  @override
  String get channelApp => 'ایپ';

  @override
  String get channelWhatsapp => 'واٹس ایپ';

  @override
  String get channelPos => 'POS';

  @override
  String get paymentCashType => 'نقد';

  @override
  String get paymentMixed => 'مخلوط';

  @override
  String get paymentOnline => 'آن لائن';

  @override
  String get shareAction => 'شیئر';

  @override
  String get exportOrders => 'آرڈرز برآمد کریں';

  @override
  String get selectExportFormat => 'برآمد فارمیٹ منتخب کریں';

  @override
  String get exportedAsExcel => 'ایکسل کے طور پر برآمد';

  @override
  String get exportedAsPdf => 'PDF کے طور پر برآمد';

  @override
  String get alertSettings => 'الرٹ سیٹنگز';

  @override
  String get acknowledgeAll => 'سب تسلیم کریں';

  @override
  String allWithCount(int count) {
    return 'سب ($count)';
  }

  @override
  String lowStockWithCount(int count) {
    return 'کم اسٹاک ($count)';
  }

  @override
  String expiryWithCount(int count) {
    return 'قریب المیعاد ($count)';
  }

  @override
  String get urgentAlerts => 'فوری الرٹس';

  @override
  String get nearExpiry => 'قریب المیعاد';

  @override
  String get noAlerts => 'کوئی الرٹ نہیں';

  @override
  String get alertDismissed => 'الرٹ خارج';

  @override
  String get undo => 'واپس';

  @override
  String get criticalPriority => 'نازک';

  @override
  String get highPriority => 'فوری';

  @override
  String stockAlertMessage(int current, int threshold) {
    return 'مقدار: $current (کم از کم: $threshold)';
  }

  @override
  String get expiryAlertLabel => 'میعاد الرٹ';

  @override
  String get currentQuantity => 'موجودہ مقدار';

  @override
  String get minimumThreshold => 'کم از کم';

  @override
  String get dismissAction => 'خارج کریں';

  @override
  String get lowStockNotifications => 'کم اسٹاک اطلاعات';

  @override
  String get expiryNotifications => 'میعاد کی اطلاعات';

  @override
  String get minimumStockLevel => 'کم از کم اسٹاک سطح';

  @override
  String thresholdUnits(int count) {
    return '$count یونٹ';
  }

  @override
  String get acknowledgeAllAlerts => 'تمام الرٹس تسلیم کریں';

  @override
  String willDismissAlerts(int count) {
    return '$count الرٹس خارج ہوں گے';
  }

  @override
  String get allAlertsAcknowledged => 'تمام الرٹس تسلیم';

  @override
  String get createPurchaseOrder => 'خریداری آرڈر بنائیں';

  @override
  String productLabelName(String name) {
    return 'پروڈکٹ: $name';
  }

  @override
  String get requiredQuantity => 'مطلوبہ مقدار';

  @override
  String get createAction => 'بنائیں';

  @override
  String get purchaseOrderCreated => 'خریداری آرڈر بنایا گیا';

  @override
  String get newCategory => 'نیا زمرہ';

  @override
  String productCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مصنوعات',
      many: '$count مصنوعات',
      few: '$count مصنوعات',
      two: '2 مصنوعات',
      one: '1 مصنوعہ',
      zero: 'کوئی مصنوعات نہیں',
    );
    return '$_temp0';
  }

  @override
  String get iconLabel => 'آئیکن:';

  @override
  String get colorLabel => 'رنگ:';

  @override
  String deleteCategoryMessage(String name, int count) {
    return 'زمرہ \"$name\" حذف کریں؟\n$count مصنوعات \"غیر زمرہ بند\" میں منتقل ہوں گی۔';
  }

  @override
  String productNumber(int number) {
    return 'پروڈکٹ $number';
  }

  @override
  String priceWithCurrency(String price) {
    return '$price ریال';
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
  String get noteLabel => 'نوٹ';

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
    return '$count آئٹم';
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
  String get gotIt => 'سمجھ آ گیا';

  @override
  String get print => 'پرنٹ';

  @override
  String get display => 'ڈسپلے';

  @override
  String get item => 'آئٹم';

  @override
  String get invoice => 'انوائس';

  @override
  String get accept => 'قبول کریں';

  @override
  String get details => 'تفصیلات';

  @override
  String get newLabel => 'نیا';

  @override
  String get mixed => 'مخلوط';

  @override
  String get lowStockLabel => 'کم';

  @override
  String get debtor => 'مقروض';

  @override
  String get creditor => 'قرض دہندہ';

  @override
  String get balanceLabel => 'بیلنس';

  @override
  String get returnLabel => 'واپسی';

  @override
  String get skip => 'چھوڑیں';

  @override
  String get send => 'بھیجیں';

  @override
  String get cloud => 'کلاؤڈ';

  @override
  String get defaultLabel => 'ڈیفالٹ';

  @override
  String get closed => 'بند';

  @override
  String get owes => 'واجب الادا';

  @override
  String get due => 'واجب الادا';

  @override
  String get balanced => 'متوازن';

  @override
  String get offlineModeTitle => 'آف لائن موڈ';

  @override
  String get offlineModeDescription => 'آپ ایپ استعمال جاری رکھ سکتے ہیں:';

  @override
  String get offlineCanSell => 'فروخت کریں';

  @override
  String get offlineCanAddToCart => 'مصنوعات کارٹ میں شامل کریں';

  @override
  String get offlineCanPrint => 'رسیدیں پرنٹ کریں';

  @override
  String get offlineAutoSync => 'کنکشن بحال ہونے پر ڈیٹا خودکار مطابقت ہوگا';

  @override
  String get offlineSavingLocally => 'آف لائن - مقامی طور پر محفوظ ہو رہا ہے';

  @override
  String get seconds => 'سیکنڈ';

  @override
  String get errors => 'خرابیاں';

  @override
  String get syncLabel => 'مطابقت';

  @override
  String get slow => 'سست';

  @override
  String get myGrocery => 'میری گروسری';

  @override
  String get cashier => 'کیشیئر';

  @override
  String get goBack => 'واپس جائیں';

  @override
  String get menuLabel => 'مینو';

  @override
  String get gold => 'گولڈ';

  @override
  String get silver => 'سلور';

  @override
  String get diamond => 'ڈائمنڈ';

  @override
  String get bronze => 'برونز';

  @override
  String get saudiArabia => 'سعودی عرب';

  @override
  String get uae => 'متحدہ عرب امارات';

  @override
  String get kuwait => 'کویت';

  @override
  String get bahrain => 'بحرین';

  @override
  String get qatar => 'قطر';

  @override
  String get oman => 'عمان';

  @override
  String get control => 'کنٹرول';

  @override
  String get strong => 'مضبوط';

  @override
  String get medium => 'درمیانہ';

  @override
  String get weak => 'کمزور';

  @override
  String get good => 'اچھا';

  @override
  String get danger => 'خطرہ';

  @override
  String get currentLabel => 'موجودہ';

  @override
  String get suggested => 'تجویز کردہ';

  @override
  String get actual => 'اصل';

  @override
  String get forecast => 'پیشن گوئی';

  @override
  String get critical => 'نازک';

  @override
  String get high => 'زیادہ';

  @override
  String get low => 'کم';

  @override
  String get investigation => 'تحقیقات';

  @override
  String get apply => 'لاگو کریں';

  @override
  String get run => 'چلائیں';

  @override
  String get positive => 'مثبت';

  @override
  String get neutral => 'غیر جانبدار';

  @override
  String get negative => 'منفی';

  @override
  String get elastic => 'لچکدار';

  @override
  String get demand => 'طلب';

  @override
  String get quality => 'کوالٹی';

  @override
  String get luxury => 'لگژری';

  @override
  String get economic => 'اقتصادی';

  @override
  String get ourStore => 'ہماری دکان';

  @override
  String get upcoming => 'آنے والے';

  @override
  String get cost => 'لاگت';

  @override
  String get duration => 'مدت';

  @override
  String get quiet => 'پرسکون';

  @override
  String get busy => 'مصروف';

  @override
  String get outstanding => 'بقایا';

  @override
  String get donate => 'عطیہ';

  @override
  String get day => 'دن';

  @override
  String get days => 'دن';

  @override
  String get projected => 'متوقع';

  @override
  String get analysis => 'تجزیہ';

  @override
  String get review => 'جائزہ';

  @override
  String get productCategory => 'زمرہ';

  @override
  String get ourPrice => 'ہماری قیمت';

  @override
  String get position => 'عہدہ';

  @override
  String get cheapest => 'سستا ترین';

  @override
  String get mostExpensive => 'مہنگا ترین';

  @override
  String get soldOut => 'فروخت ہو گیا';

  @override
  String get noDataAvailable => 'کوئی ڈیٹا دستیاب نہیں';

  @override
  String get noDataFoundMessage => 'کوئی ڈیٹا نہیں ملا';

  @override
  String get noSearchResultsFound => 'کوئی نتائج نہیں ملے';

  @override
  String get noProductsFound => 'کوئی مصنوعات نہیں ملیں';

  @override
  String get noCustomers => 'کوئی گاہک نہیں';

  @override
  String get addCustomersToStart => 'شروع کرنے کے لیے نئے گاہک شامل کریں';

  @override
  String get noOrdersYet => 'ابھی تک کوئی آرڈر نہیں';

  @override
  String get noConnection => 'کنکشن نہیں';

  @override
  String get checkInternet => 'اپنا انٹرنیٹ کنکشن چیک کریں';

  @override
  String get cartIsEmpty => 'کارٹ خالی ہے';

  @override
  String get browseProducts => 'مصنوعات براؤز کریں';

  @override
  String noResultsFor(String query) {
    return '\"$query\" کے لیے کوئی نتائج نہیں';
  }

  @override
  String get paidLabel => 'ادا شدہ';

  @override
  String get remainingLabel => 'باقی';

  @override
  String get completeLabel => 'مکمل';

  @override
  String get addPayment => 'شامل کریں';

  @override
  String get payments => 'ادائیگیاں';

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

  @override
  String get averageInvoice => 'اوسط انوائس';

  @override
  String errorPrefix(String message, Object error) {
    return 'خرابی: $error';
  }

  @override
  String get vipMember => 'VIP رکن';

  @override
  String get activeSuppliers => 'فعال سپلائرز';

  @override
  String get duePayments => 'واجب ادائیگیاں';

  @override
  String get productCatalog => 'مصنوعات کیٹلاگ';

  @override
  String get comingSoonBrowseSuppliers =>
      'جلد آ رہا ہے - سپلائر مصنوعات براؤز کریں';

  @override
  String get comingSoonTag => 'جلد آ رہا ہے';

  @override
  String get supplierNotFound => 'سپلائر نہیں ملا';

  @override
  String get viewAllPurchases => 'تمام خریداری دیکھیں';

  @override
  String get completedLabel => 'مکمل';

  @override
  String get pendingStatusLabel => 'زیر التوا';

  @override
  String get registerPayment => 'ادائیگی رجسٹر کریں';

  @override
  String errorLoadingSuppliers(Object error) {
    return 'سپلائرز لوڈ کرنے میں خرابی: $error';
  }

  @override
  String get cancelLabel => 'منسوخ';

  @override
  String get addLabel => 'شامل کریں';

  @override
  String get saveLabel => 'محفوظ کریں';

  @override
  String purchaseInvoiceSaved(Object total) {
    return 'خریداری انوائس محفوظ - کل: $total ریال';
  }

  @override
  String errorSavingPurchase(Object error) {
    return 'خریداری محفوظ کرنے میں خرابی: $error';
  }

  @override
  String get smartReorderTitle => 'سمارٹ ری آرڈر';

  @override
  String get smartReorderAiTitle => 'AI سمارٹ ری آرڈر';

  @override
  String get budgetDescription =>
      'بجٹ مقرر کریں اور سسٹم ٹرن اوور ریٹ کی بنیاد پر تقسیم کرے گا';

  @override
  String get enterValidBudget => 'براہ کرم درست بجٹ درج کریں';

  @override
  String get confirmSendTitle => 'بھیجنے کی تصدیق';

  @override
  String sendOrderToMsg(Object supplier) {
    return 'آرڈر $supplier کو بھیجیں؟';
  }

  @override
  String get orderSentSuccessMsg => 'آرڈر کامیابی سے بھیجا گیا';

  @override
  String sendingOrderVia(Object method) {
    return '$method کے ذریعے آرڈر بھیجا جا رہا ہے...';
  }

  @override
  String stockQuantity(Object qty) {
    return 'اسٹاک: $qty';
  }

  @override
  String turnoverLabel(Object rate) {
    return 'ٹرن اوور: $rate%';
  }

  @override
  String failedCapture(Object error) {
    return 'تصویر لینے میں ناکام: $error';
  }

  @override
  String failedPickImage(Object error) {
    return 'تصویر منتخب کرنے میں ناکام: $error';
  }

  @override
  String failedProcessInvoice(Object error) {
    return 'انوائس پروسیس کرنے میں ناکام: $error';
  }

  @override
  String matchLabel(Object name) {
    return 'ملان: $name';
  }

  @override
  String suggestedProduct(Object index) {
    return 'تجویز کردہ پروڈکٹ $index';
  }

  @override
  String get barcodeLabel => 'بارکوڈ: 123456789';

  @override
  String get purchaseInvoiceSavedSuccess => 'خریداری انوائس کامیابی سے محفوظ';

  @override
  String get aiImportedInvoice => 'AI درآمد شدہ انوائس';

  @override
  String aiInvoiceNote(Object number) {
    return 'AI انوائس: $number';
  }

  @override
  String get supplierCanCreateOrders =>
      'اس سپلائر سے خریداری آرڈرز بنا سکتے ہیں';

  @override
  String get notesFieldHint => 'سپلائر کے بارے میں اضافی نوٹس...';

  @override
  String get deleteConfirmCancel => 'منسوخ';

  @override
  String get deleteConfirmBtn => 'حذف کریں';

  @override
  String get supplierUpdatedMsg => 'سپلائر ڈیٹا اپڈیٹ';

  @override
  String errorOccurredMsg(Object error) {
    return 'خرابی: $error';
  }

  @override
  String errorDuringDeleteMsg(Object error) {
    return 'حذف کے دوران خرابی: $error';
  }

  @override
  String get fortyFiveDays => '45 دن';

  @override
  String get expenseCategoriesTitle => 'اخراجات کے زمرے';

  @override
  String get noCategoriesFound => 'کوئی اخراجات کے زمرے نہیں ملے';

  @override
  String get monthlyBudget => 'ماہانہ بجٹ';

  @override
  String get spentAmount => 'خرچ';

  @override
  String get remainingAmount => 'باقی';

  @override
  String get overBudget => 'بجٹ سے زیادہ';

  @override
  String expenseCount(Object count) {
    return '$count اخراجات';
  }

  @override
  String spentLabel(Object amount) {
    return 'خرچ: $amount ریال';
  }

  @override
  String remainingLabel2(Object amount) {
    return 'باقی: $amount ریال';
  }

  @override
  String expensesThisMonth(Object count) {
    return 'اس مہینے $count اخراجات';
  }

  @override
  String get recentExpenses => 'حالیہ اخراجات';

  @override
  String expenseNumber(Object id) {
    return 'خرچ #$id';
  }

  @override
  String get budgetLabel => 'بجٹ';

  @override
  String get monthlyBudgetLabel => 'ماہانہ بجٹ';

  @override
  String get categoryNameHint => 'مثال: ملازمین کی تنخواہیں';

  @override
  String get productNameLabel => 'پروڈکٹ کا نام *';

  @override
  String get quantityLabel => 'مقدار';

  @override
  String get purchasePriceLabel => 'خریداری قیمت';

  @override
  String get saveInvoiceBtn => 'انوائس محفوظ کریں';

  @override
  String get ibanLabel => 'IBAN اکاؤنٹ نمبر';

  @override
  String get supplierActiveLabel => 'سپلائر فعال';

  @override
  String get notesLabel => 'نوٹس';

  @override
  String get deleteSupplierConfirm =>
      'کیا آپ واقعی اس سپلائر کو حذف کرنا چاہتے ہیں؟ تمام متعلقہ ڈیٹا حذف ہو جائے گا۔';

  @override
  String get supplierDeletedMsg => 'سپلائر حذف';

  @override
  String get savingLabel => 'محفوظ ہو رہا ہے...';

  @override
  String get supplierDetailTitle => 'سپلائر تفصیلات';

  @override
  String get supplierNotFoundMsg => 'سپلائر نہیں ملا';

  @override
  String get lastPurchaseLabel => 'آخری خریداری';

  @override
  String get recentPurchasesLabel => 'حالیہ خریداری';

  @override
  String get noPurchasesLabel => 'ابھی تک کوئی خریداری نہیں';

  @override
  String get supplierAddedMsg => 'سپلائر شامل';

  @override
  String get openingCashLabel => 'ابتدائی نقدی';

  @override
  String get importantNotes => 'اہم نوٹس';

  @override
  String get countCashBeforeShift => 'شفٹ کھولنے سے پہلے دراز میں نقدی گنیں';

  @override
  String get shiftTimeAutoRecorded => 'شفٹ کھلنے کا وقت خودکار ریکارڈ ہوگا';

  @override
  String get oneShiftAtATime => 'ایک وقت میں ایک سے زیادہ شفٹ نہیں کھل سکتی';

  @override
  String get pleaseEnterOpeningCash =>
      'براہ کرم ابتدائی نقدی رقم درج کریں (صفر سے زیادہ)';

  @override
  String shiftOpenedWithAmount(String amount, String currency) {
    return 'شفٹ $amount $currency سے کھلی';
  }

  @override
  String get errorOpeningShift => 'شفٹ کھولنے میں خرابی';

  @override
  String get noOpenShift => 'کوئی کھلی شفٹ نہیں';

  @override
  String get shiftInfoLabel => 'شفٹ کی معلومات';

  @override
  String get salesSummaryLabel => 'فروخت کا خلاصہ';

  @override
  String get cashRefundsLabel => 'نقد واپسی';

  @override
  String get cashDepositLabel => 'نقد جمع';

  @override
  String get cashWithdrawalLabel => 'نقد نکلوانا';

  @override
  String get expectedInDrawer => 'دراز میں متوقع';

  @override
  String get actualCashInDrawer => 'دراز میں اصل نقدی';

  @override
  String get drawerMatched => 'ملان';

  @override
  String get surplusStatus => 'فاضل';

  @override
  String get deficitStatus => 'خسارہ';

  @override
  String expectedAmountCurrency(String amount, String currency) {
    return 'متوقع: $amount $currency';
  }

  @override
  String actualAmountCurrency(String amount, String currency) {
    return 'اصل: $amount $currency';
  }

  @override
  String get drawerMatchedMessage => 'دراز ملان ہے';

  @override
  String surplusAmount(String amount, String currency) {
    return 'فاضل: +$amount $currency';
  }

  @override
  String deficitAmount(String amount, String currency) {
    return 'خسارہ: $amount $currency';
  }

  @override
  String get confirmCloseShift => 'کیا آپ شفٹ بند کرنا چاہتے ہیں؟';

  @override
  String get errorClosingShift => 'شفٹ بند کرنے میں خرابی';

  @override
  String get shiftClosedSuccessfully => 'شفٹ کامیابی سے بند';

  @override
  String get shiftStatsLabel => 'شفٹ کے اعداد و شمار';

  @override
  String get shiftDurationLabel => 'شفٹ کا دورانیہ';

  @override
  String get invoiceCountLabel => 'انوائس تعداد';

  @override
  String get invoiceUnit => 'انوائس';

  @override
  String get cardSalesLabel => 'کارڈ فروخت';

  @override
  String get cashSalesLabel => 'نقد فروخت';

  @override
  String get refundsLabel => 'واپسیاں';

  @override
  String get expectedInDrawerLabel => 'دراز میں متوقع';

  @override
  String get actualInDrawerLabel => 'دراز میں اصل';

  @override
  String get differenceLabel => 'فرق';

  @override
  String get printingReport => 'رپورٹ پرنٹ ہو رہی ہے...';

  @override
  String get sharingInProgress => 'شیئر ہو رہا ہے...';

  @override
  String get openNewShift => 'نئی شفٹ کھولیں';

  @override
  String hoursAndMinutes(int hours, int minutes) {
    return '$hours گھنٹے $minutes منٹ';
  }

  @override
  String hoursOnly(int hours) {
    return '$hours گھنٹے';
  }

  @override
  String minutesOnly(int minutes) {
    return '$minutes منٹ';
  }

  @override
  String get rejectedNotApproved => 'آپریشن مسترد - منظور نہیں';

  @override
  String errorWithDetails(String error) {
    return 'خرابی: $error';
  }

  @override
  String get inventoryManagement => 'انوینٹری کا انتظام اور ٹریکنگ';

  @override
  String get bulkEdit => 'بلک ایڈٹ';

  @override
  String get totalProducts => 'کل مصنوعات';

  @override
  String get inventoryValue => 'انوینٹری کی قیمت';

  @override
  String get exportInventoryReport => 'انوینٹری رپورٹ برآمد کریں';

  @override
  String get printOrderList => 'آرڈر فہرست پرنٹ کریں';

  @override
  String get inventoryMovementLog => 'انوینٹری حرکت لاگ';

  @override
  String get editSelected => 'منتخب ترمیم';

  @override
  String get clearSelection => 'انتخاب صاف کریں';

  @override
  String get noOutOfStockProducts => 'کوئی اسٹاک ختم مصنوعات نہیں';

  @override
  String get allProductsAvailable => 'تمام مصنوعات اسٹاک میں دستیاب ہیں';

  @override
  String get editStock => 'اسٹاک ترمیم';

  @override
  String get newQuantity => 'نئی مقدار';

  @override
  String get receiveGoods => 'سامان وصول کریں';

  @override
  String get damaged => 'خراب';

  @override
  String get correction => 'اصلاح';

  @override
  String get stockUpdatedTo => 'اسٹاک اپڈیٹ ہو گیا';

  @override
  String get featureUnderDevelopment => 'یہ فیچر زیر تعمیر ہے...';

  @override
  String get newest => 'جدید ترین';

  @override
  String get adjustStock => 'اسٹاک ایڈجسٹ کریں';

  @override
  String get adjustmentHistory => 'ایڈجسٹمنٹ کی تاریخ';

  @override
  String get errorLoadingProducts => 'مصنوعات لوڈ کرنے میں خرابی';

  @override
  String get selectProduct => 'پروڈکٹ منتخب کریں';

  @override
  String get subtract => 'منہا';

  @override
  String get setQuantity => 'مقرر کریں';

  @override
  String get enterQuantity => 'مقدار درج کریں';

  @override
  String get enterValidQuantity => 'درست مقدار درج کریں';

  @override
  String get notesOptional => 'نوٹس (اختیاری)';

  @override
  String get enterAdditionalNotes => 'اضافی نوٹس درج کریں...';

  @override
  String get adjustmentSummary => 'ایڈجسٹمنٹ کا خلاصہ';

  @override
  String get newStock => 'نیا اسٹاک';

  @override
  String get warningNegativeStock => 'انتباہ: اسٹاک منفی ہو جائے گا!';

  @override
  String get saving => 'محفوظ ہو رہا ہے...';

  @override
  String get storeNotSelected => 'اسٹور منتخب نہیں';

  @override
  String get noInventoryMovements => 'کوئی انوینٹری حرکات نہیں';

  @override
  String get adjustmentSavedSuccess => 'ایڈجسٹمنٹ کامیابی سے محفوظ';

  @override
  String get errorSaving => 'محفوظ کرنے میں خرابی';

  @override
  String get enterBarcode => 'بارکوڈ درج کریں';

  @override
  String get theft => 'چوری';

  @override
  String get noMatchingProducts => 'کوئی مماثل مصنوعات نہیں';

  @override
  String get stockTransfer => 'اسٹاک منتقلی';

  @override
  String get newTransfer => 'نئی منتقلی';

  @override
  String get fromBranch => 'شاخ سے';

  @override
  String get toBranch => 'شاخ تک';

  @override
  String get selectSourceBranch => 'ذریعہ شاخ منتخب کریں';

  @override
  String get selectTargetBranch => 'ہدف شاخ منتخب کریں';

  @override
  String get selectProductsForTransfer => 'منتقلی کے لیے مصنوعات منتخب کریں';

  @override
  String get creating => 'بنایا جا رہا ہے...';

  @override
  String get createTransferRequest => 'منتقلی کی درخواست بنائیں';

  @override
  String get errorLoadingTransfers => 'منتقلیاں لوڈ کرنے میں خرابی';

  @override
  String get noPreviousTransfers => 'کوئی پچھلی منتقلیاں نہیں';

  @override
  String get approved => 'منظور';

  @override
  String get inTransit => 'راستے میں';

  @override
  String get complete => 'مکمل';

  @override
  String get completeTransfer => 'منتقلی مکمل کریں';

  @override
  String get completeTransferConfirm =>
      'کیا آپ یہ منتقلی مکمل کرنا چاہتے ہیں؟ ذریعہ سے مقدار کم اور ہدف شاخ میں شامل ہو گی۔';

  @override
  String get transferCompletedSuccess => 'منتقلی مکمل اور اسٹاک اپڈیٹ';

  @override
  String get errorCompletingTransfer => 'منتقلی مکمل کرنے میں خرابی';

  @override
  String get transferCreatedSuccess => 'منتقلی کی درخواست کامیابی سے بنائی گئی';

  @override
  String get errorCreatingTransfer => 'منتقلی بنانے میں خرابی';

  @override
  String get stockTake => 'اسٹاک ٹیک';

  @override
  String get startStockTake => 'اسٹاک ٹیک شروع کریں';

  @override
  String get counted => 'گنا ہوا';

  @override
  String get variances => 'فرق';

  @override
  String get of_ => 'از';

  @override
  String get system => 'سسٹم';

  @override
  String get count => 'تعداد';

  @override
  String get finishStockTake => 'اسٹاک ٹیک مکمل کریں';

  @override
  String get stockTakeDescription =>
      'اسٹاک مصنوعات گنیں اور سسٹم سے موازنہ کریں';

  @override
  String get noProductsInStock => 'اسٹاک میں کوئی مصنوعات نہیں';

  @override
  String get noProductsToCount => 'گنتی شروع کرنے کے لیے کوئی مصنوعات نہیں';

  @override
  String get errorCreatingStockTake => 'اسٹاک ٹیک بنانے میں خرابی';

  @override
  String get saveStockTakeConfirm =>
      'اسٹاک ٹیک نتائج محفوظ اور انوینٹری اپڈیٹ کریں؟';

  @override
  String get stockTakeSavedSuccess =>
      'اسٹاک ٹیک محفوظ اور انوینٹری اپڈیٹ ہو گئی';

  @override
  String get errorCompletingStockTake => 'اسٹاک ٹیک مکمل کرنے میں خرابی';

  @override
  String get stockTakeHistory => 'اسٹاک ٹیک تاریخ';

  @override
  String get errorLoadingHistory => 'تاریخ لوڈ کرنے میں خرابی';

  @override
  String get noStockTakeHistory => 'کوئی پچھلی اسٹاک ٹیک تاریخ نہیں';

  @override
  String get inProgress => 'جاری';

  @override
  String get expiryTracking => 'میعاد ٹریکنگ';

  @override
  String get errorLoadingExpiryData => 'میعاد ڈیٹا لوڈ کرنے میں خرابی';

  @override
  String get withinMonth => 'ایک مہینے میں';

  @override
  String get noProductsExpiringIn7Days =>
      '7 دنوں میں کوئی مصنوعات کی میعاد ختم نہیں';

  @override
  String get noProductsExpiringInMonth =>
      'ایک مہینے میں کوئی مصنوعات کی میعاد ختم نہیں';

  @override
  String get noExpiredProducts => 'کوئی میعاد ختم مصنوعات نہیں';

  @override
  String get batch => 'بیچ';

  @override
  String expiredSinceDays(int days) {
    return '$days دن پہلے میعاد ختم ہوئی';
  }

  @override
  String get remove => 'ہٹائیں';

  @override
  String get pressToAddExpiryTracking =>
      'نئی میعاد ٹریکنگ شامل کرنے کے لیے + دبائیں';

  @override
  String get applyDiscountTo => 'رعایت لاگو کریں';

  @override
  String get confirmRemoval => 'ہٹانے کی تصدیق';

  @override
  String get removeExpiryTrackingFor => 'میعاد ٹریکنگ ہٹائیں';

  @override
  String get expiryTrackingRemoved => 'میعاد ٹریکنگ ہٹا دی گئی';

  @override
  String get errorRemovingExpiryTracking => 'میعاد ٹریکنگ ہٹانے میں خرابی';

  @override
  String get addExpiryDate => 'میعاد ختم ہونے کی تاریخ شامل کریں';

  @override
  String get barcodeOrProductName => 'بارکوڈ یا پروڈکٹ کا نام';

  @override
  String get selectDate => 'تاریخ منتخب کریں';

  @override
  String get batchNumberOptional => 'بیچ نمبر (اختیاری)';

  @override
  String get expiryTrackingAdded => 'میعاد ٹریکنگ کامیابی سے شامل';

  @override
  String get errorAddingExpiryTracking => 'میعاد ٹریکنگ شامل کرنے میں خرابی';

  @override
  String get barcodeScanner2 => 'بارکوڈ اسکینر';

  @override
  String get scanning => 'اسکین ہو رہا ہے...';

  @override
  String get pressToStart => 'شروع کرنے کے لیے دبائیں';

  @override
  String get stop => 'رکیں';

  @override
  String get startScanning => 'اسکیننگ شروع کریں';

  @override
  String get enterBarcodeManually => 'دستی بارکوڈ درج کریں';

  @override
  String get noScannedProducts => 'کوئی اسکین شدہ مصنوعات نہیں';

  @override
  String get enterBarcodeToSearch => 'تلاش کے لیے بارکوڈ درج کریں';

  @override
  String get useManualInputToSearch =>
      'مصنوعات تلاش کرنے کے لیے دستی ان پٹ استعمال کریں';

  @override
  String get found => 'ملا';

  @override
  String get productNotFoundForBarcode => 'پروڈکٹ نہیں ملی';

  @override
  String get addNewProduct => 'نئی پروڈکٹ شامل کریں';

  @override
  String get willOpenAddProductScreen => 'پروڈکٹ شامل اسکرین کھلے گی';

  @override
  String get scanHistory => 'اسکین تاریخ';

  @override
  String get addedToCart => 'شامل ہو گئی';

  @override
  String get barcodePrint => 'بارکوڈ پرنٹ';

  @override
  String get noProductsWithBarcode => 'بارکوڈ والی کوئی مصنوعات نہیں';

  @override
  String get addBarcodeFirst => 'پہلے پروڈکٹس میں بارکوڈ شامل کریں';

  @override
  String get searchProduct => 'پروڈکٹ تلاش کریں...';

  @override
  String get totalLabels => 'کل لیبلز';

  @override
  String get printLabels => 'لیبلز پرنٹ کریں';

  @override
  String get printList => 'فہرست پرنٹ کریں';

  @override
  String get selectProductsToPrint => 'پرنٹ کے لیے مصنوعات منتخب کریں';

  @override
  String get willPrint => 'پرنٹ ہوگا';

  @override
  String get label => 'لیبل';

  @override
  String get printing => 'پرنٹ ہو رہا ہے...';

  @override
  String get messageAddedToQueue => 'پیغام بھیجنے کی قطار میں شامل';

  @override
  String get messageSendFailed => 'پیغام بھیجنے میں ناکام';

  @override
  String get noPhoneForCustomer => 'گاہک کا فون نمبر نہیں';

  @override
  String get inputContainsDangerousContent => 'ان پٹ میں ممنوعہ مواد ہے';

  @override
  String whatsappGreeting(String name) {
    return 'سلام $name\nہم آپ کی کیا مدد کر سکتے ہیں؟';
  }

  @override
  String get segmentVip => 'VIP';

  @override
  String get segmentRegular => 'باقاعدہ';

  @override
  String get segmentAtRisk => 'خطرے میں';

  @override
  String get segmentLost => 'کھوئے ہوئے';

  @override
  String get segmentNewCustomer => 'نیا';

  @override
  String customerCount(int count) {
    return '$count صارف';
  }

  @override
  String revenueK(String amount) {
    return '${amount}K ریال';
  }

  @override
  String get tabRecommendations => 'سفارشات';

  @override
  String get tabRepurchase => 'دوبارہ خریداری';

  @override
  String get tabSegments => 'حصے';

  @override
  String lastVisitLabel(String time) {
    return 'آخری وزٹ: $time';
  }

  @override
  String visitCountLabel(int count) {
    return '$count وزٹس';
  }

  @override
  String avgSpendLabel(String amount) {
    return 'اوسط: $amount ریال';
  }

  @override
  String totalSpentLabel(String amount) {
    return 'کل: ${amount}K ریال';
  }

  @override
  String get recommendedProducts => 'تجویز کردہ مصنوعات';

  @override
  String get sendWhatsAppOffer => 'واٹس ایپ آفر بھیجیں';

  @override
  String get totalRevenueLabel => 'کل آمدنی';

  @override
  String get avgSpendStat => 'اوسط خرچ';

  @override
  String amountSar(String amount) {
    return '$amount ریال';
  }

  @override
  String get specialOfferMissYou =>
      'آپ کے لیے خاص آفر! ہمیں آپ کی وزٹ یاد آتی ہے';

  @override
  String friendlyReminderPurchase(String product) {
    return '$product خریدنے کی یاد دہانی';
  }

  @override
  String get timeAgoToday => 'آج';

  @override
  String get timeAgoYesterday => 'کل';

  @override
  String timeAgoDays(int days) {
    return '$days دن پہلے';
  }

  @override
  String get riskAnalysisTab => 'خطرے کا تجزیہ';

  @override
  String get preventiveActionsTab => 'احتیاطی اقدامات';

  @override
  String errorOccurredDetail(String error) {
    return 'خرابی: $error';
  }

  @override
  String get returnRateTitle => 'واپسی کی شرح';

  @override
  String get avgLast6Months => 'آخری 6 ماہ کی اوسط';

  @override
  String get amountAtRiskTitle => 'خطرے میں رقم';

  @override
  String get highRiskOperations => 'زیادہ خطرے والے آپریشنز';

  @override
  String get needsImmediateAction => 'فوری کارروائی درکار';

  @override
  String get returnTrendTitle => 'واپسی کا رجحان';

  @override
  String operationsAtRiskCount(int count) {
    return 'خطرے میں آپریشنز ($count)';
  }

  @override
  String get riskFilterAll => 'سب';

  @override
  String get riskFilterVeryHigh => 'بہت زیادہ';

  @override
  String get riskFilterHigh => 'زیادہ';

  @override
  String get riskFilterMedium => 'درمیانہ';

  @override
  String get riskFilterLow => 'کم';

  @override
  String get totalExpectedSavings => 'کل متوقع بچت';

  @override
  String fromPreventiveActions(int count) {
    return '$count احتیاطی اقدامات سے';
  }

  @override
  String get suggestedPreventiveActions => 'تجویز کردہ احتیاطی اقدامات';

  @override
  String get applyPreventiveHint =>
      'واپسی کم کرنے اور گاہک کی اطمینان بڑھانے کے لیے یہ اقدامات لاگو کریں';

  @override
  String actionApplied(String action) {
    return 'لاگو: $action';
  }

  @override
  String actionDismissed(String action) {
    return 'خارج: $action';
  }

  @override
  String get veryPositiveSentiment => 'بہت مثبت';

  @override
  String get positiveSentiment => 'مثبت';

  @override
  String get neutralSentiment => 'غیر جانبدار';

  @override
  String get negativeSentiment => 'منفی';

  @override
  String get veryNegativeSentiment => 'بہت منفی';

  @override
  String get ratingsDistribution => 'درجہ بندی کی تقسیم';

  @override
  String get sentimentTrendTitle => 'جذبات رجحان';

  @override
  String get sentimentIndicator => 'جذبات اشارہ';

  @override
  String minutesAgoSentiment(int count) {
    return '$count منٹ پہلے';
  }

  @override
  String hoursAgoSentiment(int count) {
    return '$count گھنٹے پہلے';
  }

  @override
  String daysAgoSentiment(int count) {
    return '$count دن پہلے';
  }

  @override
  String get totalProductsTitle => 'کل مصنوعات';

  @override
  String get categoryATitle => 'زمرہ A';

  @override
  String get mostImportant => 'اہم ترین';

  @override
  String get withinDays => '7 دنوں میں';

  @override
  String get needReorder => 'دوبارہ آرڈر درکار';

  @override
  String estimatedLossSar(String amount) {
    return '$amount ریال تخمینی نقصان';
  }

  @override
  String get tabAbcAnalysis => 'ABC تجزیہ';

  @override
  String get tabWastePrediction => 'ضیاع کی پیشن گوئی';

  @override
  String get tabReorder => 'ری آرڈر';

  @override
  String get filterAllLabel => 'سب';

  @override
  String get categoryALabel => 'زمرہ A';

  @override
  String get categoryBLabel => 'زمرہ B';

  @override
  String get categoryCLabel => 'زمرہ C';

  @override
  String orderUnitsSnack(int qty, String name) {
    return '$name کی $qty یونٹس آرڈر کریں';
  }

  @override
  String get urgencyCritical => 'نازک';

  @override
  String get urgencyHigh => 'زیادہ';

  @override
  String get urgencyMedium => 'درمیانہ';

  @override
  String get urgencyLow => 'کم';

  @override
  String get currentStockLabel => 'موجودہ اسٹاک';

  @override
  String get reorderPointLabel => 'دوبارہ آرڈر پوائنٹ';

  @override
  String get suggestedQtyLabel => 'تجویز کردہ مقدار';

  @override
  String get daysOfStockLabel => 'اسٹاک کے دن';

  @override
  String estimatedCostLabel(String amount) {
    return 'تخمینی لاگت: $amount ریال';
  }

  @override
  String purchaseOrderCreatedFor(String name) {
    return 'خریداری آرڈر بنایا: $name';
  }

  @override
  String orderUnitsButton(int qty) {
    return '$qty یونٹس آرڈر کریں';
  }

  @override
  String get actionDiscount => 'رعایت';

  @override
  String get actionTransfer => 'منتقلی';

  @override
  String get actionDonate => 'عطیہ';

  @override
  String actionOnProduct(String name) {
    return 'کارروائی: $name';
  }

  @override
  String get totalSuggestionsLabel => 'کل تجاویز';

  @override
  String get canIncreaseLabel => 'بڑھا سکتے ہیں';

  @override
  String get shouldDecreaseLabel => 'کم ہونا چاہیے';

  @override
  String get expectedMonthlyImpact => 'متوقع ماہانہ اثر';

  @override
  String get noSuggestionsInFilter => 'اس فلٹر میں کوئی تجاویز نہیں';

  @override
  String get selectProductForDetails =>
      'تفصیلات دیکھنے کے لیے پروڈکٹ منتخب کریں';

  @override
  String get selectProductHint =>
      'اثر کیلکولیٹر اور طلب لچک دیکھنے کے لیے فہرست سے پروڈکٹ پر کلک کریں';

  @override
  String priceApplied(String price, String product) {
    return 'قیمت $price ریال $product پر لاگو';
  }

  @override
  String errorOccurredShort(String error) {
    return 'خرابی: $error';
  }

  @override
  String get readyTemplates => 'تیار ٹیمپلیٹس';

  @override
  String get hideTemplates => 'ٹیمپلیٹس چھپائیں';

  @override
  String get showTemplates => 'ٹیمپلیٹس دکھائیں';

  @override
  String get askAboutStore => 'اپنی دکان کے بارے میں کوئی سوال پوچھیں';

  @override
  String get writeQuestionHint =>
      'اپنا سوال لکھیں اور ہم خودکار مناسب رپورٹ بنائیں گے';

  @override
  String get quickActionTodaySales => 'آج کتنی فروخت ہوئی؟';

  @override
  String get quickActionTop10 => 'ٹاپ 10 مصنوعات';

  @override
  String get quickActionMonthlyCompare => 'ماہانہ موازنہ';

  @override
  String get analyzingData => 'ڈیٹا کا تجزیہ اور رپورٹ تیار ہو رہی ہے...';

  @override
  String get profileScreenTitle => 'پروفائل';

  @override
  String get unknownUserName => 'نامعلوم';

  @override
  String get defaultEmployeeRole => 'ملازم';

  @override
  String get transactionUnit => 'ٹرانزیکشن';

  @override
  String get dayUnit => 'دن';

  @override
  String get emailFieldLabel => 'ای میل';

  @override
  String get phoneFieldLabel => 'فون';

  @override
  String get branchFieldLabel => 'شاخ';

  @override
  String get mainBranchName => 'مرکزی شاخ';

  @override
  String get employeeNumberLabel => 'ملازم نمبر';

  @override
  String get changePasswordLabel => 'پاسورڈ تبدیل کریں';

  @override
  String get activityLogLabel => 'سرگرمی لاگ';

  @override
  String get logoutDialogTitle => 'لاگ آؤٹ';

  @override
  String get logoutDialogBody => 'کیا آپ سسٹم سے لاگ آؤٹ ہونا چاہتے ہیں؟';

  @override
  String get cancelButton => 'منسوخ';

  @override
  String get exitButton => 'باہر نکلیں';

  @override
  String get editProfileSnack => 'پروفائل ترمیم';

  @override
  String get changePasswordSnack => 'پاسورڈ تبدیل کریں';

  @override
  String get roleAdmin => 'سسٹم ایڈمن';

  @override
  String get roleManager => 'مینیجر';

  @override
  String get roleCashier => 'کیشیئر';

  @override
  String get roleEmployee => 'ملازم';

  @override
  String get onboardingTitle1 => 'تیز پوائنٹ آف سیل';

  @override
  String get onboardingDesc1 =>
      'سادہ اور آرام دہ انٹرفیس کے ساتھ تیزی سے فروخت مکمل کریں';

  @override
  String get onboardingTitle2 => 'آف لائن کام کریں';

  @override
  String get onboardingDesc2 =>
      'بغیر کنکشن کے کام جاری رکھیں، مطابقت خودکار ہوگی';

  @override
  String get onboardingTitle3 => 'انوینٹری مینجمنٹ';

  @override
  String get onboardingDesc3 =>
      'کمی اور میعاد الرٹس کے ساتھ اپنی انوینٹری کو درست طریقے سے ٹریک کریں';

  @override
  String get onboardingTitle4 => 'سمارٹ رپورٹس';

  @override
  String get onboardingDesc4 =>
      'اپنی دکان کی کارکردگی کے لیے تفصیلی رپورٹس حاصل کریں';

  @override
  String get startNow => 'ابھی شروع کریں';

  @override
  String get favorites => 'پسندیدہ';

  @override
  String get editMode => 'ترمیم';

  @override
  String get doneMode => 'ہو گیا';

  @override
  String get errorLoadingFavorites => 'پسندیدہ لوڈ کرنے میں خرابی';

  @override
  String get noFavoriteProducts => 'کوئی پسندیدہ مصنوعات نہیں';

  @override
  String get addFavoritesFromProducts =>
      'پروڈکٹس اسکرین سے پسندیدہ میں شامل کریں';

  @override
  String get tapProductToAddToCart =>
      'کارٹ میں شامل کرنے کے لیے پروڈکٹ پر ٹیپ کریں';

  @override
  String addedProductToCart(String name) {
    return '$name کارٹ میں شامل ہو گئی';
  }

  @override
  String get addToCartAction => 'کارٹ میں شامل کریں';

  @override
  String get removeFromFavorites => 'پسندیدہ سے ہٹائیں';

  @override
  String removedProductFromFavorites(String name) {
    return '$name پسندیدہ سے ہٹا دیا';
  }

  @override
  String get paymentMethodTitle => 'ادائیگی کا طریقہ';

  @override
  String get backEsc => 'واپس (Esc)';

  @override
  String get completePayment => 'ادائیگی مکمل کریں';

  @override
  String get enterToConfirm => 'تصدیق کے لیے Enter دبائیں';

  @override
  String get cashOnlyOffline => 'آف لائن موڈ میں صرف نقد';

  @override
  String get cardsDisabledInSettings => 'سیٹنگز میں کارڈز غیر فعال ہیں';

  @override
  String get creditPayment => 'ادھار ادائیگی';

  @override
  String get unavailableOffline => 'آف لائن دستیاب نہیں';

  @override
  String get disabledInSettings => 'سیٹنگز میں غیر فعال';

  @override
  String get amountReceived => 'موصول رقم';

  @override
  String get quickAmounts => 'فوری رقوم';

  @override
  String get requiredAmount => 'مطلوبہ رقم';

  @override
  String get changeLabel => 'واپسی:';

  @override
  String get insufficientAmount => 'ناکافی رقم';

  @override
  String get rrnLabel => 'حوالہ نمبر (RRN)';

  @override
  String get enterRrnFromDevice => 'ڈیوائس سے ٹرانزیکشن نمبر درج کریں';

  @override
  String get cardPaymentInstructions =>
      'گاہک سے کارڈ ٹرمینل سے ادائیگی کروائیں، پھر رسید سے ٹرانزیکشن نمبر (RRN) درج کریں';

  @override
  String get creditSale => 'ادھار فروخت';

  @override
  String get creditSaleWarning =>
      'یہ رقم گاہک کے قرض کے طور پر ریکارڈ ہوگی۔ لین دین مکمل کرنے سے پہلے گاہک کا انتخاب یقینی بنائیں۔';

  @override
  String get orderSummary => 'آرڈر کا خلاصہ';

  @override
  String get taxLabel => 'ٹیکس (15%)';

  @override
  String discountLabel(String value) {
    return 'رعایت';
  }

  @override
  String get payCash => 'نقد ادائیگی';

  @override
  String get payCard => 'کارڈ سے ادائیگی';

  @override
  String get payCreditSale => 'ادھار فروخت';

  @override
  String get confirmPayment => 'ادائیگی کی تصدیق';

  @override
  String get processingPayment => 'ادائیگی پروسیس ہو رہی ہے...';

  @override
  String get pleaseWait => 'براہ کرم انتظار کریں';

  @override
  String get paymentSuccessful => 'ادائیگی کامیاب!';

  @override
  String get printingReceipt => 'رسید پرنٹ ہو رہی ہے...';

  @override
  String get whatsappReceipt => 'واٹس ایپ رسید';

  @override
  String get storeOrUserNotSet => 'اسٹور یا صارف سیٹ نہیں';

  @override
  String errorWithMessage(String message) {
    return 'خرابی: $message';
  }

  @override
  String get receiptTitle => 'رسید';

  @override
  String get invoiceNotSpecified => 'انوائس نمبر مخصوص نہیں';

  @override
  String get pendingSync => 'مطابقت زیر التوا';

  @override
  String get notSynced => 'مطابقت نہیں ہوئی';

  @override
  String receiptNumberLabel(String number) {
    return 'نمبر: $number';
  }

  @override
  String get itemColumnHeader => 'آئٹم';

  @override
  String totalAmount(String amount) {
    return 'کل';
  }

  @override
  String get paymentMethodField => 'ادائیگی کا طریقہ';

  @override
  String get zatcaQrCode => 'ZATCA ٹیکس QR کوڈ';

  @override
  String get whatsappSentLabel => 'بھیج دیا گیا';

  @override
  String get whatsappLabel => 'واٹس ایپ';

  @override
  String get whatsappReceiptSent => 'رسید واٹس ایپ سے بھیج دی گئی';

  @override
  String whatsappSendFailed(String error) {
    return 'بھیجنے میں ناکام: $error';
  }

  @override
  String get cannotPrintNoInvoice =>
      'پرنٹ نہیں ہو سکتا - انوائس نمبر دستیاب نہیں';

  @override
  String get invoiceAddedToPrintQueue => 'انوائس پرنٹ قطار میں شامل';

  @override
  String get mixedMethod => 'مخلوط';

  @override
  String get creditMethod => 'ادھار';

  @override
  String get walletMethod => 'والٹ';

  @override
  String get bankTransferMethod => 'بینک ٹرانسفر';

  @override
  String get scanBarcodeHint => 'بارکوڈ اسکین کریں یا درج کریں (F1)';

  @override
  String get openCamera => 'کیمرہ کھولیں';

  @override
  String get searchProductHint => 'پروڈکٹ تلاش کریں (F2)';

  @override
  String get hideCart => 'کارٹ چھپائیں';

  @override
  String get showCart => 'کارٹ دکھائیں';

  @override
  String get cartTitle => 'کارٹ';

  @override
  String get clearAction => 'صاف کریں';

  @override
  String get allCategories => 'سب';

  @override
  String get otherCategory => 'دیگر';

  @override
  String get storeNotSet => 'اسٹور سیٹ نہیں';

  @override
  String get retryAction => 'دوبارہ کوشش';

  @override
  String get vatTax15 => 'VAT (15%)';

  @override
  String get totalGrand => 'کل';

  @override
  String get holdOrder => 'ہولڈ';

  @override
  String get payActionLabel => 'ادائیگی';

  @override
  String get f12QuickPay => 'فوری ادائیگی کے لیے F12';

  @override
  String productNotFoundBarcode(String barcode) {
    return 'بارکوڈ کے لیے پروڈکٹ نہیں ملی: $barcode';
  }

  @override
  String get clearCartTitle => 'کارٹ صاف کریں';

  @override
  String get clearCartMessage => 'کیا آپ کارٹ سے تمام مصنوعات ہٹانا چاہتے ہیں؟';

  @override
  String get orderOnHold => 'آرڈر ہولڈ پر';

  @override
  String get deleteItem => 'حذف کریں';

  @override
  String itemsCountPrice(int count, String price) {
    return '$count آئٹمز - $price ریال';
  }

  @override
  String get taxReportTitle => 'ٹیکس رپورٹ';

  @override
  String get exportReportAction => 'رپورٹ برآمد کریں';

  @override
  String get printReportAction => 'رپورٹ پرنٹ کریں';

  @override
  String get quarterly => 'سہ ماہی';

  @override
  String get netTaxDue => 'واجب خالص ٹیکس';

  @override
  String get salesTaxCollected => 'فروخت ٹیکس';

  @override
  String get salesTaxSubtitle => 'وصول شدہ';

  @override
  String get purchasesTaxPaid => 'خریداری ٹیکس';

  @override
  String get purchasesTaxSubtitle => 'ادا شدہ';

  @override
  String get taxByPaymentMethod => 'ادائیگی طریقے کے لحاظ سے ٹیکس';

  @override
  String invoiceCount(int count) {
    return '$count انوائسز';
  }

  @override
  String get taxDetailsTitle => 'ٹیکس تفصیلات';

  @override
  String get taxableSales => 'قابل ٹیکس فروخت';

  @override
  String get salesTax15 => 'فروخت ٹیکس (15%)';

  @override
  String get taxablePurchases => 'قابل ٹیکس خریداری';

  @override
  String get purchasesTax15 => 'خریداری ٹیکس (15%)';

  @override
  String get netTax => 'خالص ٹیکس';

  @override
  String get zatcaReminder => 'ZATCA یاد دہانی';

  @override
  String get zatcaDeadline => 'فائلنگ کی آخری تاریخ: اگلے مہینے کے آخر تک';

  @override
  String get historyAction => 'تاریخ';

  @override
  String get sendToAuthority => 'حکام کو بھیجیں';

  @override
  String get cashPaymentMethod => 'نقد';

  @override
  String get cardPaymentMethod => 'کارڈ';

  @override
  String get mixedPaymentMethod => 'مخلوط';

  @override
  String get creditPaymentMethod => 'ادھار';

  @override
  String get vatReportTitle => 'VAT رپورٹ';

  @override
  String get selectPeriod => 'مدت منتخب کریں';

  @override
  String get salesVat => 'فروخت VAT';

  @override
  String get totalSalesIncVat => 'کل فروخت (VAT شامل)';

  @override
  String get vatCollected => 'وصول VAT';

  @override
  String get purchasesVat => 'خریداری VAT';

  @override
  String get totalPurchasesIncVat => 'کل خریداری (VAT شامل)';

  @override
  String get vatPaid => 'ادا VAT';

  @override
  String get netVatDue => 'واجب خالص VAT';

  @override
  String get dueToAuthority => 'حکام کو واجب';

  @override
  String get dueFromAuthority => 'حکام سے واجب';

  @override
  String get exportingPdfReport => 'رپورٹ برآمد ہو رہی ہے...';

  @override
  String get debtsReportTitle => 'قرض کی رپورٹ';

  @override
  String get sortByLastPayment => 'آخری ادائیگی کے لحاظ سے';

  @override
  String get customersCount => 'گاہکین';

  @override
  String get noOutstandingDebts => 'کوئی بقایا قرض نہیں';

  @override
  String lastUpdate(String date) {
    return 'آخری اپڈیٹ: $date';
  }

  @override
  String get paymentAmountField => 'ادائیگی کی رقم';

  @override
  String get recordAction => 'ریکارڈ';

  @override
  String get paymentRecordedMsg => 'ادائیگی ریکارڈ ہو گئی';

  @override
  String showDetails(String name) {
    return 'تفصیلات دیکھیں: $name';
  }

  @override
  String get debtsReportPdf => 'قرض کی رپورٹ';

  @override
  String dateFieldLabel(String date) {
    return 'تاریخ: $date';
  }

  @override
  String get debtsDetails => 'قرض کی تفصیلات:';

  @override
  String get customerCol => 'گاہک';

  @override
  String get phoneCol => 'فون';

  @override
  String get refundReceiptTitle => 'واپسی رسید';

  @override
  String get noRefundId => 'کوئی واپسی ID نہیں';

  @override
  String get refundNotFound => 'واپسی ڈیٹا نہیں ملا';

  @override
  String get refundSuccessful => 'واپسی کامیاب';

  @override
  String refundNumberLabel(String number) {
    return 'واپسی نمبر: $number';
  }

  @override
  String get refundReceipt => 'واپسی رسید';

  @override
  String get originalInvoiceNumber => 'اصل انوائس نمبر';

  @override
  String get refundDate => 'واپسی کی تاریخ';

  @override
  String get refundMethodField => 'واپسی کا طریقہ';

  @override
  String get returnedProducts => 'واپس شدہ مصنوعات';

  @override
  String get totalRefund => 'کل واپسی';

  @override
  String get reasonLabel => 'وجہ';

  @override
  String get homeAction => 'ہوم';

  @override
  String printError(String error) {
    return 'پرنٹ خرابی: $error';
  }

  @override
  String get damagedProduct => 'خراب پروڈکٹ';

  @override
  String get wrongOrder => 'غلط آرڈر';

  @override
  String get customerChangedMind => 'گاہک نے ارادہ بدل دیا';

  @override
  String get expiredProduct => 'میعاد ختم پروڈکٹ';

  @override
  String get unsatisfactoryQuality => 'غیر تسلی بخش معیار';

  @override
  String get cashRefundMethod => 'نقد';

  @override
  String get cardRefundMethod => 'کارڈ';

  @override
  String get walletRefundMethod => 'والٹ';

  @override
  String get refundReasonTitle => 'واپسی کی وجہ';

  @override
  String get noRefundData =>
      'کوئی واپسی ڈیٹا نہیں۔ واپس جائیں اور مصنوعات منتخب کریں۔';

  @override
  String invoiceFieldLabel(String receiptNo) {
    return 'انوائس: $receiptNo';
  }

  @override
  String productsCountAmount(int count, String amount) {
    return '$count مصنوعات - $amount ریال';
  }

  @override
  String get selectRefundReason => 'واپسی کی وجہ منتخب کریں';

  @override
  String get additionalNotesOptional => 'اضافی نوٹس (اختیاری)';

  @override
  String get addNotesHint => 'اضافی نوٹس شامل کریں...';

  @override
  String get processingAction => 'پروسیسنگ...';

  @override
  String get nextSupervisorApproval => 'اگلا - سپروائزر منظوری';

  @override
  String refundCreationError(String error) {
    return 'واپسی بنانے میں خرابی: $error';
  }

  @override
  String get refundRequestTitle => 'واپسی کی درخواست';

  @override
  String get invoiceNumberHint => 'انوائس نمبر';

  @override
  String get searchAction => 'تلاش';

  @override
  String get selectProductsForRefund => 'واپسی کے لیے مصنوعات منتخب کریں';

  @override
  String get selectAll => 'سب منتخب کریں';

  @override
  String quantityTimesPrice(int qty, String price) {
    return 'مقدار: $qty × $price ریال';
  }

  @override
  String productsSelected(int count) {
    return '$count مصنوعات منتخب';
  }

  @override
  String refundAmountValue(String amount) {
    return 'رقم: $amount ریال';
  }

  @override
  String get nextAction => 'اگلا';

  @override
  String get enterInvoiceToSearch => 'تلاش کے لیے انوائس نمبر درج کریں';

  @override
  String get invoiceNotFoundMsg => 'انوائس نہیں ملی';

  @override
  String get shippingGatewaysTitle => 'شپنگ گیٹ ویز';

  @override
  String get availableShippingGateways => 'دستیاب شپنگ گیٹ ویز';

  @override
  String get activateShippingGateways =>
      'آرڈر ڈیلیوری کے لیے شپنگ گیٹ ویز کو فعال اور ترتیب دیں';

  @override
  String get aramexName => 'آرامیکس';

  @override
  String get aramexDesc => 'عالمی شپنگ کمپنی متعدد خدمات کے ساتھ';

  @override
  String get smsaDesc => 'تیز مقامی شپنگ';

  @override
  String get fastloName => 'فاسٹلو';

  @override
  String get fastloDesc => 'اسی دن تیز ڈیلیوری';

  @override
  String get dhlDesc => 'تیز اور قابل اعتماد بین الاقوامی شپنگ';

  @override
  String get jtDesc => 'اقتصادی شپنگ';

  @override
  String get customDeliveryName => 'کسٹم ڈیلیوری';

  @override
  String get customDeliveryDesc => 'اپنے ڈرائیوروں سے ڈیلیوری کا انتظام کریں';

  @override
  String get settingsAction => 'سیٹنگز';

  @override
  String get hourlyView => 'فی گھنٹہ';

  @override
  String get dailyView => 'روزانہ';

  @override
  String get peakHourLabel => 'پیک گھنٹہ';

  @override
  String transactionsWithCount(int count) {
    return '$count ٹرانزیکشنز';
  }

  @override
  String get peakDayLabel => 'پیک دن';

  @override
  String get avgPerHour => 'اوسط/گھنٹہ';

  @override
  String get transactionWord => 'ٹرانزیکشنز';

  @override
  String get transactionsByHour => 'گھنٹے کے لحاظ سے ٹرانزیکشنز';

  @override
  String get transactionsByDay => 'دن کے لحاظ سے ٹرانزیکشنز';

  @override
  String get activityHeatmap => 'سرگرمی ہیٹ میپ';

  @override
  String get lowLabel => 'کم';

  @override
  String get highLabel => 'زیادہ';

  @override
  String get analysisRecommendations => 'تجزیے کی بنیاد پر سفارشات';

  @override
  String get staffRecommendation => 'عملہ';

  @override
  String get staffRecommendationDesc =>
      '12:00-13:00 اور 17:00-19:00 کے دوران کیشیئرز بڑھائیں (پیک فروخت)';

  @override
  String get offersRecommendation => 'آفرز';

  @override
  String get offersRecommendationDesc =>
      '14:00-16:00 کے دوران خصوصی ڈیلز پیش کریں';

  @override
  String get inventoryRecommendation => 'انوینٹری';

  @override
  String get inventoryRecommendationDesc =>
      'جمعرات اور جمعہ سے پہلے انوینٹری تیار کریں (سب سے زیادہ فروخت کے دن)';

  @override
  String get shiftsRecommendation => 'شفٹس';

  @override
  String get shiftsRecommendationDesc =>
      'شفٹس تقسیم کریں: صبح 8-15، شام 15-22 پیک پر اوورلیپ';

  @override
  String get topProductsTab => 'ٹاپ مصنوعات';

  @override
  String get byCategoryTab => 'زمرے کے لحاظ سے';

  @override
  String get performanceAnalysisTab => 'کارکردگی تجزیہ';

  @override
  String get noSalesDataForPeriod => 'منتخب مدت کے لیے کوئی فروخت ڈیٹا نہیں';

  @override
  String get categoryFilter => 'زمرہ';

  @override
  String get allCategoriesFilter => 'تمام زمرے';

  @override
  String get sortByField => 'ترتیب بلحاظ';

  @override
  String get revenueSort => 'آمدنی';

  @override
  String get unitsSort => 'یونٹس';

  @override
  String get profitSort => 'منافع';

  @override
  String get revenueLabel => 'آمدنی';

  @override
  String get unitsLabel => 'یونٹس';

  @override
  String get profitLabel => 'منافع';

  @override
  String get stockLabel => 'اسٹاک';

  @override
  String get revenueByCategoryTitle => 'زمرے کے لحاظ سے آمدنی کی تقسیم';

  @override
  String get noRevenueForPeriod => 'اس مدت کے لیے کوئی آمدنی نہیں';

  @override
  String get unclassified => 'غیر درجہ بند';

  @override
  String get productUnit => 'پروڈکٹ';

  @override
  String get unitsSoldUnit => 'یونٹ';

  @override
  String get totalRevenueKpi => 'کل آمدنی';

  @override
  String get unitsSoldKpi => 'فروخت یونٹس';

  @override
  String get totalProfitKpi => 'کل منافع';

  @override
  String get profitMarginKpi => 'منافع مارجن';

  @override
  String get performanceOverview => 'کارکردگی کا جائزہ';

  @override
  String get trendingUpProducts => 'اوپر رجحان';

  @override
  String get stableProducts => 'مستحکم';

  @override
  String get trendingDownProducts => 'نیچے رجحان';

  @override
  String noSalesProducts(int count) {
    return 'بغیر فروخت مصنوعات ($count)';
  }

  @override
  String inStockCount(int count) {
    return '$count اسٹاک میں';
  }

  @override
  String get slowMovingLabel => 'سست';

  @override
  String needsReorder(int count) {
    return 'دوبارہ آرڈر ($count)';
  }

  @override
  String soldUnitsStock(int sold, int stock) {
    return 'فروخت: $sold یونٹ | اسٹاک: $stock';
  }

  @override
  String get reorderLabel => 'دوبارہ آرڈر';

  @override
  String get totalComplaintsLabel => 'کل شکایات';

  @override
  String get openComplaints => 'کھلی';

  @override
  String get closedComplaints => 'بند';

  @override
  String get avgResolutionTime => 'اوسط حل وقت';

  @override
  String daysUnit(String count) {
    return '$count دن';
  }

  @override
  String get fromDate => 'تاریخ سے';

  @override
  String get toDate => 'تاریخ تک';

  @override
  String get statusFilter => 'حیثیت';

  @override
  String get departmentFilter => 'شعبہ';

  @override
  String get paymentDepartment => 'ادائیگی';

  @override
  String get technicalDepartment => 'تکنیکی';

  @override
  String get otherDepartment => 'دیگر';

  @override
  String get noComplaintsRecorded => 'ابھی تک کوئی شکایات ریکارڈ نہیں';

  @override
  String get overviewTab => 'جائزہ';

  @override
  String get topCustomersTab => 'ٹاپ گاہک';

  @override
  String get growthAnalysisTab => 'نمو تجزیہ';

  @override
  String get loyaltyTab => 'لائلٹی';

  @override
  String get totalCustomersLabel => 'کل گاہک';

  @override
  String get activeCustomersLabel => 'فعال گاہک';

  @override
  String get avgOrderValueLabel => 'اوسط آرڈر قیمت';

  @override
  String get tierDistribution => 'درجے کے لحاظ سے گاہکوں کی تقسیم';

  @override
  String get activitySummary => 'سرگرمی کا خلاصہ';

  @override
  String get totalRevenueFromCustomers => 'رجسٹرڈ گاہکوں سے کل آمدنی';

  @override
  String get avgOrderPerCustomer => 'فی گاہک اوسط آرڈر قیمت';

  @override
  String get activeCustomersLast30 => 'فعال گاہک (آخری 30 دن)';

  @override
  String get newCustomersLast30 => 'نئے گاہک (آخری 30 دن)';

  @override
  String topCustomersTitle(int count) {
    return 'ٹاپ $count گاہک';
  }

  @override
  String get bySpending => 'خرچ کے لحاظ سے';

  @override
  String get byOrders => 'آرڈرز کے لحاظ سے';

  @override
  String get byPoints => 'پوائنٹس کے لحاظ سے';

  @override
  String ordersCount(int count) {
    return '$count آرڈرز';
  }

  @override
  String get avgOrderStat => 'اوسط آرڈر';

  @override
  String get loyaltyPointsStat => 'لائلٹی پوائنٹس';

  @override
  String get lastOrderStat => 'آخری آرڈر';

  @override
  String get newCustomerGrowth => 'نئے گاہکوں کی نمو';

  @override
  String get customerRetentionRate => 'گاہک برقراری کی شرح';

  @override
  String get monthlyPeriod => 'ماہانہ';

  @override
  String get totalCustomersPeriod => 'کل گاہک';

  @override
  String get activePeriod => 'فعال';

  @override
  String get activeCustomersInfo => 'فعال گاہک: گزشتہ 30 دنوں میں خریداری کی';

  @override
  String get cohortAnalysis => 'گروہ تجزیہ';

  @override
  String get cohortDescription => 'پہلی خریداری کے بعد واپسی کی شرح';

  @override
  String get cohortGroup => 'گروپ';

  @override
  String get month1 => 'مہینہ 1';

  @override
  String get month2 => 'مہینہ 2';

  @override
  String get month3 => 'مہینہ 3';

  @override
  String get loyaltyProgramStats => 'لائلٹی پروگرام کے اعداد';

  @override
  String get totalPointsGranted => 'دیے گئے کل پوائنٹس';

  @override
  String get remainingPoints => 'باقی پوائنٹس';

  @override
  String get pointsValue => 'پوائنٹس کی قیمت';

  @override
  String get pointsByTier => 'درجے کے لحاظ سے پوائنٹس';

  @override
  String get pointsUnit => 'پوائنٹس';

  @override
  String get redemptionPatterns => 'استعمال کے انداز';

  @override
  String get purchaseDiscount => 'خریداری رعایت';

  @override
  String get freeProducts => 'مفت مصنوعات';

  @override
  String get couponsLabel => 'کوپنز';

  @override
  String get diamondTier => 'ڈائمنڈ';

  @override
  String get goldTier => 'گولڈ';

  @override
  String get silverTier => 'سلور';

  @override
  String get bronzeTier => 'برونز';

  @override
  String get todayDate => 'آج';

  @override
  String get yesterdayDate => 'کل';

  @override
  String daysCountLabel(int count) {
    return '$count دن';
  }

  @override
  String ofTotalLabel(String active, String total) {
    return '$active از $total';
  }

  @override
  String get exportingReportMsg => 'رپورٹ برآمد ہو رہی ہے...';

  @override
  String get januaryMonth => 'جنوری';

  @override
  String get februaryMonth => 'فروری';

  @override
  String get marchMonth => 'مارچ';

  @override
  String get aprilMonth => 'اپریل';

  @override
  String get mayMonth => 'مئی';

  @override
  String get juneMonth => 'جون';

  @override
  String errorLabel(String error) {
    return 'خرابی: $error';
  }

  @override
  String get saturdayDay => 'ہفتہ';

  @override
  String get sundayDay => 'اتوار';

  @override
  String get mondayDay => 'پیر';

  @override
  String get tuesdayDay => 'منگل';

  @override
  String get wednesdayDay => 'بدھ';

  @override
  String get thursdayDay => 'جمعرات';

  @override
  String get fridayDay => 'جمعہ';

  @override
  String get satShort => 'ہفتہ';

  @override
  String get sunShort => 'اتوار';

  @override
  String get monShort => 'پیر';

  @override
  String get tueShort => 'منگل';

  @override
  String get wedShort => 'بدھ';

  @override
  String get thuShort => 'جمعرات';

  @override
  String get friShort => 'جمعہ';

  @override
  String get errorLoadingVatReport => 'VAT رپورٹ لوڈ کرنے میں خرابی';

  @override
  String get errorLoadingComplaints => 'شکایات لوڈ کرنے میں خرابی';

  @override
  String get errorLoadingCustomerReport => 'گاہک رپورٹ لوڈ کرنے میں خرابی';

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
  String get confirmOrder => 'آرڈر کی تصدیق';

  @override
  String get orderNow => 'ابھی آرڈر کریں';

  @override
  String get orderCart => 'آرڈر کارٹ';

  @override
  String get orderReceived => 'آپ کا آرڈر موصول ہو گیا!';

  @override
  String get orderBeingPrepared => 'آپ کا آرڈر جلد از جلد تیار کیا جائے گا';

  @override
  String get redirectingToHome => 'خود بخود ہوم پیج پر منتقل ہو رہا ہے...';

  @override
  String get kioskOrderNote => 'کیوسک آرڈر';

  @override
  String pricePerUnit(String price) {
    return '$price ر.س فی یونٹ';
  }

  @override
  String get selectFromMenu => 'مینو سے منتخب کریں';

  @override
  String orderCartWithCount(int count) {
    return 'آرڈر کارٹ ($count آئٹم)';
  }

  @override
  String amountWithSar(String amount) {
    return '$amount ر.س';
  }

  @override
  String qtyTimesPrice(int qty, String price) {
    return '$qty × $price ر.س';
  }

  @override
  String get applyCoupon => 'کوپن لگائیں';

  @override
  String get enterCouponCode => 'کوپن کوڈ درج کریں';

  @override
  String get invalidCoupon => 'غلط یا ناموجود کوپن';

  @override
  String get couponExpired => 'کوپن کی میعاد ختم ہو چکی ہے';

  @override
  String minimumPurchaseRequired(String amount) {
    return 'کم از کم خریداری $amount ریال';
  }

  @override
  String couponDiscountApplied(String amount) {
    return '$amount ریال کی رعایت لاگو';
  }

  @override
  String get couponInvalid => 'غلط کوپن';

  @override
  String get customerAddFailed => 'گاہک شامل کرنے میں ناکامی';

  @override
  String get quantityColon => 'مقدار:';

  @override
  String get riyal => 'ریال';

  @override
  String get mobileNumber => 'موبائل نمبر';

  @override
  String get banknotes => 'کرنسی نوٹ';

  @override
  String get coins => 'سکے';

  @override
  String get totalAmountLabel => 'کل رقم';

  @override
  String denominationRiyal(String amount) {
    return '$amount ریال';
  }

  @override
  String denominationHalala(String amount) {
    return '$amount ہللہ';
  }

  @override
  String get countCurrency => 'کرنسی گنیں';

  @override
  String confirmAmountSar(String amount) {
    return 'تصدیق: $amount ر.س';
  }

  @override
  String amountRiyal(String amount) {
    return '$amount ریال';
  }

  @override
  String get itemDeletedMsg => 'آئٹم حذف ہو گیا';

  @override
  String get pressBackAgainToExit => 'باہر نکلنے کے لیے دوبارہ دبائیں';

  @override
  String get deleteHeldInvoiceConfirm => 'یہ معلق انوائس حذف کریں؟';

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

  @override
  String get distributorPortal => 'بوابة الموزع';

  @override
  String get distributorDashboard => 'لوحة التحكم';

  @override
  String get distributorDashboardSubtitle => 'نظرة عامة على أداء التوزيع';

  @override
  String get distributorOrders => 'الطلبات الواردة';

  @override
  String get distributorProducts => 'كتالوج المنتجات';

  @override
  String get distributorPricing => 'إدارة الأسعار';

  @override
  String get distributorReports => 'التقارير';

  @override
  String get distributorSettings => 'الإعدادات';

  @override
  String get distributorTotalOrders => 'إجمالي الطلبات';

  @override
  String get distributorPendingOrders => 'طلبات منتظرة';

  @override
  String get distributorApprovedOrders => 'تمت الموافقة';

  @override
  String get distributorRevenue => 'الإيرادات';

  @override
  String get distributorMonthlySales => 'المبيعات الشهرية';

  @override
  String get distributorRecentOrders => 'آخر الطلبات';

  @override
  String get distributorOrderNumber => 'رقم الطلب';

  @override
  String get distributorStore => 'المتجر';

  @override
  String get distributorDate => 'التاريخ';

  @override
  String get distributorAmount => 'المبلغ';

  @override
  String get distributorStatusPending => 'منتظر';

  @override
  String get distributorStatusApproved => 'موافق';

  @override
  String get distributorStatusReceived => 'مستلم';

  @override
  String get distributorStatusRejected => 'مرفوض';

  @override
  String get distributorStatusDraft => 'مسودة';

  @override
  String get distributorNoOrders => 'لا توجد طلبات';

  @override
  String get distributorAllOrders => 'الكل';

  @override
  String get distributorPendingTab => 'منتظرة';

  @override
  String get distributorApprovedTab => 'موافق عليها';

  @override
  String get distributorRejectedTab => 'مرفوضة';

  @override
  String get distributorAddProduct => 'إضافة منتج';

  @override
  String get distributorSearchHint => 'ابحث بالاسم أو الباركود...';

  @override
  String get distributorNoProducts => 'لا توجد منتجات';

  @override
  String get distributorChangeSearch => 'جرب تغيير معايير البحث';

  @override
  String get distributorBarcode => 'الباركود';

  @override
  String get distributorCategory => 'التصنيف';

  @override
  String get distributorStock => 'المخزون';

  @override
  String get distributorStockEmpty => 'نفذ';

  @override
  String get distributorStockLow => 'منخفض';

  @override
  String get distributorActions => 'إجراءات';

  @override
  String distributorEditProduct(String name) {
    return 'تعديل $name';
  }

  @override
  String get distributorCurrentPrice => 'السعر الحالي';

  @override
  String get distributorNewPrice => 'السعر الجديد';

  @override
  String get distributorLastUpdated => 'آخر تحديث';

  @override
  String get distributorDifference => 'الفرق';

  @override
  String get distributorTotalProducts => 'إجمالي المنتجات';

  @override
  String get distributorPendingChanges => 'تغييرات معلقة';

  @override
  String distributorProductsWillUpdate(int count) {
    return '$count منتج سيتم تحديث سعره';
  }

  @override
  String get distributorSaveChanges => 'حفظ التغييرات';

  @override
  String get distributorChangesSaved => 'تم حفظ التغييرات بنجاح';

  @override
  String distributorChangesCount(int count) {
    return '$count تغيير';
  }

  @override
  String get distributorExport => 'تصدير';

  @override
  String get distributorExportReport => 'تصدير التقرير';

  @override
  String get distributorDailySales => 'المبيعات اليومية';

  @override
  String get distributorOrderCount => 'عدد الطلبات';

  @override
  String get distributorAvgOrderValue => 'متوسط قيمة الطلب';

  @override
  String get distributorTopProduct => 'أفضل منتج';

  @override
  String get distributorTopProducts => 'أفضل المنتجات';

  @override
  String get distributorOrdersUnit => 'طلب';

  @override
  String get distributorPeriodDay => 'يوم';

  @override
  String get distributorPeriodWeek => 'أسبوع';

  @override
  String get distributorPeriodMonth => 'شهر';

  @override
  String get distributorPeriodYear => 'سنة';

  @override
  String get distributorCompanyInfo => 'معلومات الشركة';

  @override
  String get distributorCompanyName => 'اسم الشركة';

  @override
  String get distributorPhone => 'رقم الهاتف';

  @override
  String get distributorEmail => 'البريد الإلكتروني';

  @override
  String get distributorAddress => 'العنوان';

  @override
  String get distributorNotificationSettings => 'إعدادات الإشعارات';

  @override
  String get distributorNotificationChannels => 'قنوات الإشعارات';

  @override
  String get distributorEmailNotifications => 'البريد الإلكتروني';

  @override
  String get distributorPushNotifications => 'إشعارات الجوال';

  @override
  String get distributorSmsNotifications => 'رسائل SMS';

  @override
  String get distributorNotificationTypes => 'أنواع الإشعارات';

  @override
  String get distributorNewOrderNotification => 'طلبات جديدة';

  @override
  String get distributorOrderStatusNotification => 'تحديث حالة الطلب';

  @override
  String get distributorPaymentNotification => 'إشعارات الدفع';

  @override
  String get distributorDeliverySettings => 'إعدادات التسليم';

  @override
  String get distributorDeliveryZones => 'مناطق التوصيل';

  @override
  String get distributorDeliveryZonesHint => 'أدخل المدن مفصولة بفاصلة';

  @override
  String get distributorMinOrder => 'الحد الأدنى للطلب (ر.س)';

  @override
  String get distributorDeliveryFee => 'رسوم التوصيل (ر.س)';

  @override
  String get distributorFreeDelivery => 'توصيل مجاني';

  @override
  String get distributorFreeDeliveryMin => 'الحد الأدنى للتوصيل المجاني (ر.س)';

  @override
  String get distributorSaveSettings => 'حفظ الإعدادات';

  @override
  String get distributorSettingsSaved => 'تم حفظ الإعدادات بنجاح';

  @override
  String distributorPurchaseOrder(String number) {
    return 'طلب شراء #$number';
  }

  @override
  String get distributorProposedAmount => 'المبلغ المقترح:';

  @override
  String get distributorOrderItems => 'بنود الطلب';

  @override
  String distributorProductCount(int count) {
    return '$count منتجات';
  }

  @override
  String get distributorSuggestedPrice => 'السعر المقترح';

  @override
  String get distributorYourPrice => 'سعرك';

  @override
  String get distributorYourTotal => 'إجمالي سعرك';

  @override
  String get distributorNotesForStore => 'ملاحظات للمتجر';

  @override
  String get distributorNotesHint => 'أضف ملاحظات حول العرض (اختياري)...';

  @override
  String get distributorRejectOrder => 'رفض الطلب';

  @override
  String get distributorAcceptSendQuote => 'قبول وإرسال العرض';

  @override
  String get distributorOrderRejected => 'تم رفض الطلب بنجاح';

  @override
  String distributorOrderAccepted(String amount) {
    return 'تم قبول الطلب وإرسال العرض بمبلغ $amount ريال';
  }

  @override
  String distributorLowerThanProposed(String percent) {
    return '$percent% أقل من المقترح';
  }

  @override
  String distributorHigherThanProposed(String percent) {
    return '+$percent% أعلى من المقترح';
  }

  @override
  String get distributorComingSoon => 'قريباً';

  @override
  String get distributorLoadError => 'حدث خطأ في تحميل البيانات';

  @override
  String get distributorRetry => 'إعادة المحاولة';

  @override
  String get distributorLogin => 'تسجيل دخول الموزع';

  @override
  String get distributorLoginSubtitle => 'أدخل بريدك الإلكتروني وكلمة المرور';

  @override
  String get distributorEmailLabel => 'البريد الإلكتروني';

  @override
  String get distributorPasswordLabel => 'كلمة المرور';

  @override
  String get distributorLoginButton => 'تسجيل الدخول';

  @override
  String get distributorLoginError => 'فشل تسجيل الدخول';

  @override
  String get distributorLogout => 'تسجيل الخروج';

  @override
  String get distributorSar => 'ر.س';

  @override
  String get distributorRiyal => 'ريال';

  @override
  String get scanCouponBarcode => 'مسح باركود الكوبون';

  @override
  String get validateCoupon => 'تحقق';

  @override
  String get couponValid => 'الكوبون صالح';

  @override
  String get recentCoupons => 'الكوبونات الأخيرة';

  @override
  String get noRecentCoupons => 'لا توجد كوبونات حديثة';

  @override
  String get noExpiry => 'بدون انتهاء';

  @override
  String get invalidCouponCode => 'كود كوبون غير صالح';

  @override
  String get percentageOff => 'خصم نسبة مئوية';

  @override
  String get bundleDeals => 'عروض الباقات';

  @override
  String get includedProducts => 'المنتجات المشمولة';

  @override
  String get individualTotal => 'المجموع الفردي';

  @override
  String get bundlePrice => 'سعر الباقة';

  @override
  String get youSave => 'توفيرك';

  @override
  String get noBundleDeals => 'لا توجد عروض باقات';

  @override
  String get bundleDealsWillAppear => 'ستظهر عروض الباقات هنا';

  @override
  String validUntilDate(String date) {
    return 'صالح حتى: $date';
  }

  @override
  String validFromDate(String date) {
    return 'صالح من: $date';
  }

  @override
  String get autoApplied => 'تطبيق تلقائي';

  @override
  String get noActiveOffers => 'لا توجد عروض نشطة';

  @override
  String get wastage => 'الهدر والتالف';

  @override
  String get quantityWasted => 'الكمية المهدرة';

  @override
  String get photoLabel => 'صورة';

  @override
  String get photoAttached => 'تم إرفاق الصورة';

  @override
  String get tapToTakePhoto => 'انقر لالتقاط صورة';

  @override
  String get optionalLabel => 'اختياري';

  @override
  String get recordWastage => 'تسجيل الهدر';

  @override
  String get spillage => 'انسكاب';

  @override
  String get transferInventory => 'نقل المخزون';

  @override
  String get transferDetails => 'تفاصيل النقل';

  @override
  String get fromStore => 'من الفرع';

  @override
  String get toStore => 'إلى الفرع';

  @override
  String get selectStore => 'اختر الفرع';

  @override
  String get submitTransfer => 'إرسال النقل';

  @override
  String get optionalNote => 'ملاحظة اختيارية';

  @override
  String get addInventory => 'إضافة مخزون';

  @override
  String get scanLabel => 'مسح';

  @override
  String get quantityToAdd => 'الكمية المراد إضافتها';

  @override
  String get supplierReference => 'مرجع المورد';

  @override
  String get removeInventory => 'سحب مخزون';

  @override
  String get quantityToRemove => 'الكمية المراد سحبها';

  @override
  String get sold => 'مباع';

  @override
  String get transferred => 'منقول';

  @override
  String get fieldRequired => 'الحقل مطلوب';

  @override
  String get deviceInfo => 'معلومات الجهاز';

  @override
  String get deviceName => 'اسم الجهاز';

  @override
  String get deviceType => 'نوع الجهاز';

  @override
  String get connectionMethod => 'طريقة الاتصال';

  @override
  String get networkSettings => 'إعدادات الشبكة';

  @override
  String get ipAddress => 'عنوان IP';

  @override
  String get port => 'المنفذ';

  @override
  String get connectionTestPassed => 'نجح اختبار الاتصال';

  @override
  String get saveDevice => 'حفظ الجهاز';

  @override
  String get addDevice => 'إضافة جهاز';

  @override
  String get noPaymentDevices => 'لا توجد أجهزة دفع';

  @override
  String get addFirstPaymentDevice => 'أضف أول جهاز دفع';

  @override
  String get totalDevices => 'إجمالي الأجهزة';

  @override
  String get disconnected => 'غير متصل';

  @override
  String testingConnectionName(String name) {
    return 'جاري اختبار الاتصال $name...';
  }

  @override
  String connectionSuccessful(String name) {
    return '$name - تم الاتصال بنجاح';
  }

  @override
  String get pasteFromClipboard => 'لصق من الحافظة';

  @override
  String get confirmRestore => 'تأكيد الاستعادة';

  @override
  String get saleNotFound => 'لم يتم العثور على البيع';

  @override
  String get noItems => 'لا توجد عناصر';

  @override
  String get customerPaysExtra => 'العميل يدفع إضافي';

  @override
  String get submitExchange => 'تأكيد الاستبدال';

  @override
  String get applyInterest => 'تطبيق الفائدة';

  @override
  String get reportSettings => 'إعدادات التقرير';

  @override
  String get reportType => 'نوع التقرير';

  @override
  String get paymentDistribution => 'توزيع المدفوعات';

  @override
  String get allAccountsSettled => 'جميع حسابات العملاء مسددة';

  @override
  String get confirmInterest => 'تأكيد الفائدة';

  @override
  String confirmInterestMessage(
      String rate, int count, String amount, String currency) {
    return 'تطبيق $rate% فائدة على $count حسابات؟\nإجمالي الفائدة: $amount $currency';
  }

  @override
  String get selectCustomers => 'اختيار العملاء';

  @override
  String get deselectAll => 'إلغاء تحديد الكل';

  @override
  String get preview => 'معاينة';

  @override
  String get totalDebt => 'إجمالي الديون';

  @override
  String get totalInterest => 'إجمالي الفائدة';

  @override
  String get finalizeInvoice => 'إنهاء الفاتورة';

  @override
  String get saveAsDraft => 'حفظ كمسودة';

  @override
  String get saveDraft => 'حفظ المسودة';

  @override
  String get finalize => 'إنهاء';

  @override
  String get adjustQuantity => 'تعديل الكمية';

  @override
  String get totalItems => 'إجمالي العناصر';

  @override
  String get variance => 'الفرق';

  @override
  String get orderNotFound => 'لم يتم العثور على الطلب';

  @override
  String get share => 'مشاركة';

  @override
  String get full => 'كامل';

  @override
  String get processRefund => 'معالجة الاسترداد';

  @override
  String get refundToCustomer => 'استرداد للعميل';

  @override
  String get breakdown => 'التفاصيل';

  @override
  String nTransactions(int count) {
    return '$count معاملات';
  }

  @override
  String get customReport => 'تقرير مخصص';

  @override
  String get reportBuilder => 'منشئ التقارير';

  @override
  String get groupBy => 'تجميع حسب';

  @override
  String get dateRange => 'النطاق الزمني';

  @override
  String get fromLabel => 'من';

  @override
  String get toLabel => 'إلى';

  @override
  String get generateReport => 'إنشاء التقرير';

  @override
  String get lastMonth => 'الشهر الماضي';

  @override
  String get periods => 'الفترات';

  @override
  String get valueLabel => 'القيمة';

  @override
  String get tryDifferentFilters => 'جرّب فلاتر مختلفة';

  @override
  String get scan => 'مسح';

  @override
  String get selectProductFirst => 'اختر منتج أولاً';

  @override
  String get selectProductsForLabels => 'اختر منتجات للملصقات';

  @override
  String printJobSentForLabels(int count) {
    return 'تم إرسال طباعة $count ملصق';
  }

  @override
  String get test => 'اختبار';

  @override
  String get paperSize58mm => '58مم';

  @override
  String get paperSize80mm => '80مم';

  @override
  String errorSavingSettings(String error) {
    return 'خطأ في حفظ الإعدادات: $error';
  }

  @override
  String restoreFailed(String error) {
    return 'فشل الاستعادة: $error';
  }

  @override
  String get address => 'العنوان';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get crNumber => 'رقم السجل التجاري';

  @override
  String get city => 'المدينة';

  @override
  String get optional => 'اختياري';

  @override
  String get optionalNoteHint => 'ملاحظة اختيارية...';

  @override
  String get clearField => 'مسح';

  @override
  String get decreaseQuantity => 'تقليل الكمية';

  @override
  String get increaseQuantity => 'زيادة الكمية';

  @override
  String get copyToClipboard => 'نسخ';
}
