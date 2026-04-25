// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get vatNumberMissing => 'VAT number not configured';

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
    return 'Page not found: $path';
  }

  @override
  String get noInvoiceDataAvailable => 'No invoice data available';

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
  String confirmDeleteItemMessage(String name) {
    return '\"$name\" حذف کریں؟\nاس عمل کو واپس نہیں کیا جا سکتا۔';
  }

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
  String get deleteProduct => 'مصنوعہ حذف کریں';

  @override
  String deleteProductConfirm(String name) {
    return 'مصنوعہ \"$name\" حذف کریں؟\nاسے آرکائیو میں منتقل کیا جائے گا اور بعد میں بحال کیا جا سکتا ہے۔';
  }

  @override
  String get productDeletedSuccess => 'مصنوعہ کامیابی سے حذف ہو گیا';

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
  String get totalReceivables => 'Total Receivables';

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
  String get zatcaQueueReportTitle => 'ZATCA ارسال قطار';

  @override
  String get zatcaSent => 'ارسال کیا گیا';

  @override
  String get zatcaPendingLabel => 'زیر التوا';

  @override
  String get zatcaRejected => 'مسترد';

  @override
  String get zatcaPendingSection => 'زیر التوا انوائس';

  @override
  String get zatcaRejectedSection => 'مسترد انوائس';

  @override
  String get zatcaNoPendingInvoices => 'کوئی زیر التوا انوائس نہیں';

  @override
  String get zatcaNoRejectedInvoices => 'کوئی مسترد انوائس نہیں';

  @override
  String zatcaRetriesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کوششیں',
      one: '1 کوشش',
      zero: 'کوئی دوبارہ کوشش نہیں',
    );
    return '$_temp0';
  }

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
  String get animationsToggle => 'اینیمیشنز';

  @override
  String get animationsToggleDesc => 'اسکرین کی ہموار منتقلی اور حرکت';

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
  String get stocktakingTitle => 'اسٹاک کی گنتی';

  @override
  String get expectedQty => 'متوقع';

  @override
  String get countedQty => 'شمار شدہ';

  @override
  String get stockDelta => 'فرق';

  @override
  String get saveAllAdjustments => 'ایڈجسٹمنٹس محفوظ کریں';

  @override
  String stocktakingSavedSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ایڈجسٹمنٹس محفوظ',
      one: '1 ایڈجسٹمنٹ محفوظ',
      zero: 'کوئی ایڈجسٹمنٹ نہیں',
    );
    return '$_temp0';
  }

  @override
  String stocktakingAdjustedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ایڈجسٹمنٹس',
      one: '1 ایڈجسٹمنٹ',
    );
    return '$_temp0';
  }

  @override
  String get stockTransfersTitle => 'شاخوں کے درمیان ٹرانسفر';

  @override
  String get stockTransferNewTitle => 'نیا اسٹاک ٹرانسفر';

  @override
  String get stockTransferTabOutgoing => 'بھیجے گئے';

  @override
  String get stockTransferTabIncoming => 'وصول شدہ';

  @override
  String get stockTransferFromStore => 'شاخ سے';

  @override
  String get stockTransferToStore => 'شاخ تک';

  @override
  String get stockTransferAddItem => 'آئٹم شامل کریں';

  @override
  String get stockTransferNoItems => 'ابھی کوئی آئٹم شامل نہیں کیا گیا';

  @override
  String get stockTransferCreate => 'ٹرانسفر بنائیں';

  @override
  String get stockTransferApprove => 'منظور';

  @override
  String get stockTransferReceive => 'وصول کریں';

  @override
  String get stockTransferReject => 'مسترد';

  @override
  String get stockTransferStatusPending => 'زیر التواء';

  @override
  String get stockTransferStatusApproved => 'منظور شدہ';

  @override
  String get stockTransferStatusInTransit => 'راستے میں';

  @override
  String get stockTransferStatusReceived => 'وصول شدہ';

  @override
  String get stockTransferStatusCancelled => 'منسوخ';

  @override
  String get stockTransferNoOutgoing => 'کوئی بھیجا گیا ٹرانسفر نہیں';

  @override
  String get stockTransferNoIncoming => 'کوئی وصول شدہ ٹرانسفر نہیں';

  @override
  String get stockTransferCreatedSuccess => 'ٹرانسفر بن گیا';

  @override
  String stockTransferItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آئٹمز',
      one: '1 آئٹم',
    );
    return '$_temp0';
  }

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
      'یہ انوائس منسوخ ہے اور واپسی نہیں ہو سکتی';

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
}
