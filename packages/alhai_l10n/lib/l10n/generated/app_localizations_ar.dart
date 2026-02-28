// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'نظام نقاط البيع';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get welcome => 'مرحباً';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get phone => 'رقم الجوال';

  @override
  String get phoneHint => '05xxxxxxxx';

  @override
  String get phoneRequired => 'رقم الجوال مطلوب';

  @override
  String get phoneInvalid => 'رقم الجوال غير صحيح';

  @override
  String get otp => 'رمز التحقق';

  @override
  String get otpHint => 'أدخل رمز التحقق';

  @override
  String get otpSent => 'تم إرسال رمز التحقق';

  @override
  String get otpResend => 'إعادة إرسال الرمز';

  @override
  String get otpExpired => 'انتهت صلاحية رمز التحقق';

  @override
  String get otpInvalid => 'رمز التحقق غير صحيح';

  @override
  String otpResendIn(int seconds) {
    return 'إعادة الإرسال خلال $seconds ثانية';
  }

  @override
  String get pin => 'رمز PIN';

  @override
  String get pinHint => 'أدخل رمز PIN';

  @override
  String get pinRequired => 'رمز PIN مطلوب';

  @override
  String get pinInvalid => 'رمز PIN غير صحيح';

  @override
  String pinAttemptsRemaining(int count) {
    return 'المحاولات المتبقية: $count';
  }

  @override
  String pinLocked(int minutes) {
    return 'تم قفل الحساب. حاول بعد $minutes دقيقة';
  }

  @override
  String get home => 'الرئيسية';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get pos => 'نقطة البيع';

  @override
  String get products => 'المنتجات';

  @override
  String get categories => 'الفئات';

  @override
  String get inventory => 'المخزون';

  @override
  String get customers => 'العملاء';

  @override
  String get orders => 'الطلبات';

  @override
  String get invoices => 'الفواتير';

  @override
  String get reports => 'التقارير';

  @override
  String get settings => 'الإعدادات';

  @override
  String get sales => 'المبيعات';

  @override
  String get salesAnalytics => 'تحليل المبيعات';

  @override
  String get refund => 'استرجاع';

  @override
  String get todaySales => 'مبيعات اليوم';

  @override
  String get totalSales => 'إجمالي المبيعات';

  @override
  String get averageSale => 'متوسط البيع';

  @override
  String get cart => 'السلة';

  @override
  String get cartEmpty => 'السلة فارغة';

  @override
  String get addToCart => 'إضافة للسلة';

  @override
  String get removeFromCart => 'إزالة من السلة';

  @override
  String get clearCart => 'إفراغ السلة';

  @override
  String get checkout => 'إتمام الشراء';

  @override
  String get payment => 'الدفع';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get cash => 'نقداً';

  @override
  String get card => 'بطاقة';

  @override
  String get credit => 'آجل';

  @override
  String get transfer => 'تحويل';

  @override
  String get paymentSuccess => 'تمت العملية بنجاح';

  @override
  String get paymentFailed => 'فشلت العملية';

  @override
  String get price => 'السعر';

  @override
  String get quantity => 'الكمية';

  @override
  String get total => 'إجمالي';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get discount => 'خصم';

  @override
  String get tax => 'الضريبة';

  @override
  String get vat => 'ضريبة القيمة المضافة';

  @override
  String get grandTotal => 'الإجمالي الكلي';

  @override
  String get product => 'منتج';

  @override
  String get productName => 'اسم المنتج';

  @override
  String get productCode => 'كود المنتج';

  @override
  String get barcode => 'الباركود';

  @override
  String get sku => 'رمز SKU';

  @override
  String get stock => 'المخزون';

  @override
  String get lowStock => 'مخزون منخفض';

  @override
  String get outOfStock => 'نفذ';

  @override
  String get inStock => 'متوفر';

  @override
  String get customer => 'العميل';

  @override
  String get customerName => 'اسم العميل';

  @override
  String get customerPhone => 'هاتف العميل';

  @override
  String get debt => 'دين';

  @override
  String get balance => 'الرصيد';

  @override
  String get search => 'بحث';

  @override
  String get searchHint => 'ابحث هنا...';

  @override
  String get filter => 'تصفية';

  @override
  String get sort => 'ترتيب';

  @override
  String get all => 'الكل';

  @override
  String get add => 'إضافة';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get close => 'إغلاق';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get done => 'تم';

  @override
  String get submit => 'إرسال';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get error => 'خطأ';

  @override
  String get errorOccurred => 'حدث خطأ';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get connectionError => 'خطأ في الاتصال';

  @override
  String get noInternet => 'لا يوجد اتصال بالإنترنت';

  @override
  String get offline => 'غير متصل';

  @override
  String get online => 'متصل';

  @override
  String get success => 'نجاح';

  @override
  String get warning => 'تحذير';

  @override
  String get info => 'معلومة';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get shift => 'الوردية';

  @override
  String get openShift => 'فتح وردية';

  @override
  String get closeShift => 'إغلاق وردية';

  @override
  String get shiftSummary => 'ملخص الوردية';

  @override
  String get cashDrawer => 'درج النقد';

  @override
  String get receipt => 'الإيصال';

  @override
  String get printReceipt => 'طباعة الإيصال';

  @override
  String get shareReceipt => 'مشاركة الإيصال';

  @override
  String get sync => 'مزامنة';

  @override
  String get syncing => 'جاري المزامنة...';

  @override
  String get syncComplete => 'اكتملت المزامنة';

  @override
  String get syncFailed => 'فشلت المزامنة';

  @override
  String get lastSync => 'آخر مزامنة';

  @override
  String get language => 'اللغة';

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
  String get theme => 'المظهر';

  @override
  String get darkMode => 'الوضع المظلم';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get systemMode => 'وضع النظام';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get security => 'الأمان';

  @override
  String get printer => 'الطابعة';

  @override
  String get backup => 'النسخ الاحتياطي';

  @override
  String get help => 'المساعدة';

  @override
  String get about => 'حول التطبيق';

  @override
  String get version => 'الإصدار';

  @override
  String get copyright => 'جميع الحقوق محفوظة';

  @override
  String get deleteConfirmTitle => 'تأكيد الحذف';

  @override
  String get deleteConfirmMessage => 'هل أنت متأكد من الحذف؟';

  @override
  String get logoutConfirmTitle => 'تأكيد الخروج';

  @override
  String get logoutConfirmMessage => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get requiredField => 'هذا الحقل مطلوب';

  @override
  String get invalidFormat => 'صيغة غير صحيحة';

  @override
  String minLength(int min) {
    return 'يجب أن يكون $min أحرف على الأقل';
  }

  @override
  String maxLength(int max) {
    return 'يجب أن يكون أقل من $max حرف';
  }

  @override
  String get welcomeTitle => 'مرحباً بك مجدداً! 👋';

  @override
  String get welcomeSubtitle => 'سجّل دخولك لإدارة متجرك بسهولة وسرعة';

  @override
  String get welcomeSubtitleShort => 'سجّل دخولك لإدارة متجرك';

  @override
  String get brandName => 'Al-Hal POS';

  @override
  String get brandTagline => 'نظام نقاط البيع الذكي';

  @override
  String get enterPhoneToContinue => 'أدخل رقم جوالك للمتابعة';

  @override
  String get pleaseEnterValidPhone => 'يرجى إدخال رقم جوال صحيح';

  @override
  String get otpSentViaWhatsApp => 'تم إرسال رمز التحقق عبر WhatsApp';

  @override
  String get otpResent => 'تم إعادة إرسال رمز التحقق';

  @override
  String get enterOtpFully => 'يرجى إدخال رمز التحقق كاملاً';

  @override
  String get maxAttemptsReached => 'تم تجاوز الحد الأقصى. يرجى طلب رمز جديد';

  @override
  String waitMinutes(int minutes) {
    return 'تم تجاوز الحد الأقصى. انتظر $minutes دقيقة';
  }

  @override
  String waitSeconds(int seconds) {
    return 'يرجى الانتظار $seconds ثانية';
  }

  @override
  String resendIn(String time) {
    return 'إعادة الإرسال ($time)';
  }

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get changeNumber => 'تغيير الرقم';

  @override
  String get verificationCode => 'رمز التحقق';

  @override
  String remainingAttempts(int count) {
    return 'المحاولات المتبقية: $count';
  }

  @override
  String get technicalSupport => 'الدعم الفني';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsAndConditions => 'الشروط والأحكام';

  @override
  String get allRightsReserved => '© 2026 نظام الحل. جميع الحقوق محفوظة.';

  @override
  String get dayMode => 'الوضع النهاري';

  @override
  String get nightMode => 'الوضع الليلي';

  @override
  String get selectBranch => 'اختر فرعك';

  @override
  String get selectBranchDesc => 'حدد الفرع الذي تريد العمل عليه';

  @override
  String get availableBranches => 'الفروع المتاحة';

  @override
  String branchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فرع',
      many: '$count فرعاً',
      few: '$count فروع',
      two: 'فرعان',
      one: 'فرع واحد',
      zero: 'لا توجد فروع',
    );
    return '$_temp0';
  }

  @override
  String branchSelected(String name) {
    return 'تم اختيار $name';
  }

  @override
  String get addBranch => 'إضافة فرع جديد';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get tryDifferentSearch => 'جرب البحث بكلمات مختلفة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get languageChangeInfo =>
      'اختر لغة العرض المفضلة لديك. سيتم تطبيق التغيير فوراً.';

  @override
  String get centralManagement => 'إدارة مركزية شاملة';

  @override
  String get centralManagementDesc =>
      'تحكم في جميع فروعك ومستودعاتك من مكان واحد. احصل على تقارير فورية ومزامنة للمخزون بين جميع نقاط البيع.';

  @override
  String get selectBranchToContinue => 'اختر الفرع للمتابعة';

  @override
  String get youHaveAccessToBranches =>
      'لديك صلاحية الوصول إلى الفروع التالية. اختر فرعاً للبدء.';

  @override
  String get searchForBranch => 'بحث عن فرع...';

  @override
  String get openNow => 'مفتوح الآن';

  @override
  String closedOpensAt(String time) {
    return 'مغلق (يفتح $time)';
  }

  @override
  String get loggedInAs => 'مسجل الدخول كـ';

  @override
  String get support247 => 'دعم فني';

  @override
  String get analyticsTools => 'أدوات تحليل';

  @override
  String get uptime => 'وقت التشغيل';

  @override
  String get dashboardTitle => 'لوحة التحكم';

  @override
  String get searchPlaceholder => 'بحث عام...';

  @override
  String get mainBranch => 'الفرع الرئيسي (الرياض)';

  @override
  String get todaySalesLabel => 'مبيعات اليوم';

  @override
  String get ordersCountLabel => 'عدد الطلبات';

  @override
  String get newCustomersLabel => 'عملاء جدد';

  @override
  String get stockAlertsLabel => 'تنبيهات المخزون';

  @override
  String get productsUnit => 'منتجات';

  @override
  String get salesAnalysis => 'تحليل المبيعات';

  @override
  String get storePerformance => 'أداء المتجر خلال الأسبوع الحالي';

  @override
  String get weekly => 'أسبوعي';

  @override
  String get monthly => 'شهري';

  @override
  String get yearly => 'سنوي';

  @override
  String get quickAction => 'إجراء سريع';

  @override
  String get newSale => 'بيع جديد';

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get returnItem => 'استرجاع';

  @override
  String get dailyReport => 'تقرير يومي';

  @override
  String get closeDay => 'إغلاق اليوم';

  @override
  String get topSelling => 'الأكثر مبيعاً';

  @override
  String ordersToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب اليوم',
      many: '$count طلباً اليوم',
      few: '$count طلبات اليوم',
      two: 'طلبان اليوم',
      one: 'طلب واحد اليوم',
      zero: 'لا توجد طلبات اليوم',
    );
    return '$_temp0';
  }

  @override
  String get recentTransactions => 'أحدث العمليات';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get orderNumber => 'رقم الطلب';

  @override
  String get time => 'الوقت';

  @override
  String get status => 'الحالة';

  @override
  String get amount => 'المبلغ';

  @override
  String get action => 'إجراء';

  @override
  String get completed => 'مكتمل';

  @override
  String get returned => 'مرتجع';

  @override
  String get pending => 'معلق';

  @override
  String get cancelled => 'ملغي';

  @override
  String get guestCustomer => 'عميل زائر';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count دقيقة',
      many: 'منذ $count دقيقة',
      few: 'منذ $count دقائق',
      two: 'منذ دقيقتين',
      one: 'منذ دقيقة',
    );
    return '$_temp0';
  }

  @override
  String get posSystem => 'نظام نقاط البيع';

  @override
  String get branchManager => 'المدير';

  @override
  String get settingsSection => 'الإعدادات';

  @override
  String get systemSettings => 'إعدادات النظام';

  @override
  String get sar => 'ر.س';

  @override
  String get daily => 'يومي';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get cashCustomer => 'عميل نقدي';

  @override
  String get noTransactionsToday => 'لا توجد معاملات اليوم';

  @override
  String get comparedToYesterday => 'مقارنة بالأمس';

  @override
  String get ordersText => 'طلب اليوم';

  @override
  String get storeManagement => 'إدارة المتجر';

  @override
  String get finance => 'المالية';

  @override
  String get teamSection => 'الفريق';

  @override
  String get fullscreen => 'ملء الشاشة';

  @override
  String goodMorningName(String name) {
    return 'صباح الخير، $name!';
  }

  @override
  String goodEveningName(String name) {
    return 'مساء الخير، $name!';
  }

  @override
  String get shoppingCart => 'سلة المشتريات';

  @override
  String get selectOrSearchCustomer => 'اختر أو ابحث عن عميل';

  @override
  String get newCustomer => 'جديد';

  @override
  String get draft => 'مسودة';

  @override
  String get pay => 'الدفع';

  @override
  String get haveCoupon => 'لديك كوبون خصم؟';

  @override
  String discountPercent(String percent) {
    return 'خصم $percent%';
  }

  @override
  String get openDrawer => 'فتح درج';

  @override
  String get suspend => 'تعليق';

  @override
  String get quantitySoldOut => 'نفذت الكمية';

  @override
  String get noProducts => 'لا توجد منتجات';

  @override
  String get addProductsToStart => 'أضف منتجات للبدء';

  @override
  String get undoComingSoon => 'تراجع (قريباً)';

  @override
  String get employees => 'الموظفين';

  @override
  String get loyaltyProgram => 'برنامج الولاء';

  @override
  String get newBadge => 'جديد';

  @override
  String get technicalSupportShort => 'الدعم الفني';

  @override
  String get productDetails => 'تفاصيل المنتج';

  @override
  String get stockMovements => 'حركات المخزون';

  @override
  String get priceHistory => 'سجل الأسعار';

  @override
  String get salesHistory => 'سجل المبيعات';

  @override
  String get available => 'متوفر';

  @override
  String get alertLevel => 'حد التنبيه';

  @override
  String get reorderPoint => 'نقطة إعادة الطلب';

  @override
  String get revenue => 'الإيرادات';

  @override
  String get supplier => 'المورد';

  @override
  String get lastSale => 'آخر عملية بيع';

  @override
  String get printLabel => 'طباعة ملصق';

  @override
  String get copied => 'تم النسخ';

  @override
  String copiedToClipboard(String label) {
    return 'تم نسخ $label';
  }

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get profitMargin => 'هامش الربح';

  @override
  String get sellingPrice => 'سعر البيع';

  @override
  String get costPrice => 'سعر التكلفة';

  @override
  String get description => 'الوصف';

  @override
  String get noDescription => 'لا يوجد وصف';

  @override
  String get productNotFound => 'لم يتم العثور على المنتج';

  @override
  String get stockStatus => 'حالة المخزون';

  @override
  String get currentStock => 'المخزون الحالي';

  @override
  String get unit => 'وحدة';

  @override
  String get units => 'وحدات';

  @override
  String get date => 'التاريخ';

  @override
  String get type => 'النوع';

  @override
  String get reference => 'المرجع';

  @override
  String get newBalance => 'الرصيد الجديد';

  @override
  String get oldPrice => 'السعر القديم';

  @override
  String get newPrice => 'السعر الجديد';

  @override
  String get reason => 'السبب';

  @override
  String get invoiceNumber => 'رقم الفاتورة';

  @override
  String get categoryLabel => 'التصنيف';

  @override
  String get uncategorized => 'بدون تصنيف';

  @override
  String get noSupplier => 'بدون مورد';

  @override
  String get moreOptions => 'خيارات أخرى';

  @override
  String get noStockMovements => 'لا توجد حركات مخزون';

  @override
  String get noPriceHistory => 'لا يوجد سجل أسعار';

  @override
  String get noSalesHistory => 'لا يوجد سجل مبيعات';

  @override
  String get sale => 'بيع';

  @override
  String get purchase => 'شراء';

  @override
  String get adjustment => 'تعديل';

  @override
  String get returnText => 'إرجاع';

  @override
  String get waste => 'تالف';

  @override
  String get initialStock => 'مخزون أولي';

  @override
  String get searchByNameOrBarcode => 'بحث بالاسم أو الباركود...';

  @override
  String get hideFilters => 'إخفاء الفلاتر';

  @override
  String get showFilters => 'إظهار الفلاتر';

  @override
  String get sortByName => 'حسب الاسم';

  @override
  String get sortByPrice => 'السعر';

  @override
  String get sortByStock => 'المخزون';

  @override
  String get sortByRecent => 'الأحدث';

  @override
  String get allItems => 'الكل';

  @override
  String get clearFilters => 'مسح الفلاتر';

  @override
  String get noBarcode => 'بدون باركود';

  @override
  String stockCount(int count) {
    return 'المخزون: $count';
  }

  @override
  String get saveChanges => 'حفظ التعديلات';

  @override
  String get addTheProduct => 'إضافة المنتج';

  @override
  String get editProduct => 'تعديل منتج';

  @override
  String get newProduct => 'منتج جديد';

  @override
  String get minimumQuantity => 'الحد الأدنى';

  @override
  String get selectCategory => 'اختر التصنيف';

  @override
  String get productImage => 'صورة المنتج';

  @override
  String get trackInventory => 'تتبع المخزون';

  @override
  String get productSavedSuccess => 'تم حفظ المنتج بنجاح';

  @override
  String get productAddedSuccess => 'تمت إضافة المنتج بنجاح';

  @override
  String get scanBarcode => 'مسح الباركود';

  @override
  String get activeProduct => 'منتج نشط';

  @override
  String get currency => 'ر.س';

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count ساعة',
      many: 'منذ $count ساعة',
      few: 'منذ $count ساعات',
      two: 'منذ ساعتين',
      one: 'منذ ساعة',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count يوم',
      many: 'منذ $count يوماً',
      few: 'منذ $count أيام',
      two: 'منذ يومين',
      one: 'منذ يوم',
    );
    return '$_temp0';
  }

  @override
  String get supplierPriceUpdate => 'تحديث أسعار الموردين';

  @override
  String get costIncrease => 'زيادة التكلفة';

  @override
  String get duplicateProduct => 'نسخ المنتج';

  @override
  String get categoriesManagement => 'إدارة التصنيفات';

  @override
  String categoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تصنيف',
      many: '$count تصنيفاً',
      few: '$count تصنيفات',
      two: 'تصنيفان',
      one: 'تصنيف واحد',
      zero: 'لا توجد تصنيفات',
    );
    return '$_temp0';
  }

  @override
  String get addCategory => 'إضافة تصنيف';

  @override
  String get editCategory => 'تعديل تصنيف';

  @override
  String get deleteCategory => 'حذف التصنيف';

  @override
  String get categoryName => 'اسم التصنيف';

  @override
  String get categoryNameAr => 'الاسم (عربي)';

  @override
  String get categoryNameEn => 'الاسم (إنجليزي)';

  @override
  String get parentCategory => 'التصنيف الأب';

  @override
  String get noParentCategory => 'بدون تصنيف أب (رئيسي)';

  @override
  String get sortOrder => 'الترتيب';

  @override
  String get categoryColor => 'اللون';

  @override
  String get categoryIcon => 'الأيقونة';

  @override
  String get categoryDetails => 'تفاصيل التصنيف';

  @override
  String get categoryCreatedAt => 'تاريخ الإنشاء';

  @override
  String get categoryProducts => 'منتجات التصنيف';

  @override
  String get noCategorySelected => 'اختر تصنيفاً لعرض تفاصيله';

  @override
  String get deleteCategoryConfirm => 'هل أنت متأكد من حذف هذا التصنيف؟';

  @override
  String get categoryDeletedSuccess => 'تم حذف التصنيف بنجاح';

  @override
  String get categorySavedSuccess => 'تم حفظ التصنيف بنجاح';

  @override
  String get searchCategories => 'البحث في التصنيفات...';

  @override
  String get reorderCategories => 'إعادة ترتيب';

  @override
  String get noCategories => 'لا توجد تصنيفات';

  @override
  String get subcategories => 'تصنيفات فرعية';

  @override
  String get activeStatus => 'نشط';

  @override
  String get inactiveStatus => 'غير نشط';

  @override
  String get invoicesTitle => 'الفواتير';

  @override
  String get totalInvoices => 'إجمالي الفواتير';

  @override
  String get totalPaid => 'إجمالي المدفوع';

  @override
  String get totalPending => 'إجمالي المعلق';

  @override
  String get totalOverdue => 'إجمالي المتأخر';

  @override
  String get comparedToLastMonth => 'مقارنة بالشهر الماضي';

  @override
  String ofTotalDue(String percent) {
    return '$percent% من الإجمالي المستحق';
  }

  @override
  String invoicesWaitingPayment(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فاتورة بانتظار الدفع',
      many: '$count فاتورة بانتظار الدفع',
      few: '$count فواتير بانتظار الدفع',
      two: 'فاتورتان بانتظار الدفع',
      one: 'فاتورة واحدة بانتظار الدفع',
      zero: 'لا فواتير بانتظار الدفع',
    );
    return '$_temp0';
  }

  @override
  String get sendReminderNow => 'إرسال تذكير الآن';

  @override
  String get revenueAnalysis => 'تحليل الإيرادات';

  @override
  String get last7Days => 'آخر 7 أيام';

  @override
  String get thisMonthPeriod => 'هذا الشهر';

  @override
  String get thisYearPeriod => 'هذا العام';

  @override
  String get paymentMethods => 'طرق الدفع';

  @override
  String get cashPayment => 'نقدا';

  @override
  String get cardPayment => 'بطاقة';

  @override
  String get walletPayment => 'محفظة';

  @override
  String get saveCurrentFilter => 'حفظ الفلتر الحالي';

  @override
  String get statusAll => 'الحالة: الكل';

  @override
  String get statusPaid => 'مدفوعة';

  @override
  String get statusPending => 'معلقة';

  @override
  String get statusOverdue => 'متأخرة';

  @override
  String get statusCancelled => 'ملغاة';

  @override
  String get resetFilters => 'إعادة تعيين';

  @override
  String get createInvoice => 'إنشاء فاتورة';

  @override
  String get invoiceNumberCol => 'رقم الفاتورة';

  @override
  String get customerNameCol => 'اسم العميل';

  @override
  String get dateCol => 'التاريخ';

  @override
  String get amountCol => 'المبلغ';

  @override
  String get statusCol => 'الحالة';

  @override
  String get paymentCol => 'الدفع';

  @override
  String get actionsCol => 'الإجراءات';

  @override
  String get viewInvoice => 'عرض';

  @override
  String get printInvoice => 'طباعة';

  @override
  String get exportPdf => 'تصدير PDF';

  @override
  String get sendWhatsapp => 'واتساب';

  @override
  String get deleteInvoice => 'حذف';

  @override
  String get reminder => 'تذكير';

  @override
  String get exportAll => 'تصدير الكل';

  @override
  String get printReport => 'طباعة التقرير';

  @override
  String get more => 'المزيد';

  @override
  String showingResults(int from, int to, int total) {
    return 'عرض $from إلى $to من أصل $total نتيجة';
  }

  @override
  String get newInvoice => 'فاتورة جديدة';

  @override
  String get selectCustomer => 'اختر العميل';

  @override
  String get cashCustomerGeneral => 'عميل نقدي (عام)';

  @override
  String get addNewCustomer => '+ إضافة عميل جديد';

  @override
  String get productsSection => 'المنتجات';

  @override
  String get addProductToInvoice => '+ إضافة منتج';

  @override
  String get productCol => 'المنتج';

  @override
  String get quantityCol => 'الكمية';

  @override
  String get priceCol => 'السعر';

  @override
  String get dueDate => 'تاريخ الاستحقاق';

  @override
  String get invoiceTotal => 'الإجمالي:';

  @override
  String get saveInvoice => 'حفظ الفاتورة';

  @override
  String get deleteConfirm => 'هل أنت متأكد؟';

  @override
  String get deleteInvoiceMsg =>
      'هل تريد حقاً حذف هذه الفاتورة؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get yesDelete => 'نعم، احذف';

  @override
  String get copiedSuccess => 'تم النسخ بنجاح';

  @override
  String get invoiceDeleted => 'تم حذف الفاتورة بنجاح';

  @override
  String get sat => 'السبت';

  @override
  String get sun => 'الأحد';

  @override
  String get mon => 'الاثنين';

  @override
  String get tue => 'الثلاثاء';

  @override
  String get wed => 'الأربعاء';

  @override
  String get thu => 'الخميس';

  @override
  String get fri => 'الجمعة';

  @override
  String selected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count محدد',
      many: '$count محدداً',
      few: '$count محددة',
      two: 'محددان',
      one: 'محدد واحد',
      zero: 'لم يتم التحديد',
    );
    return '$_temp0';
  }

  @override
  String get bulkPrint => 'طباعة';

  @override
  String get bulkExportPdf => 'تصدير PDF';

  @override
  String get allRightsReservedFooter => '© 2026 Alhai POS. جميع الحقوق محفوظة.';

  @override
  String get privacyPolicyFooter => 'سياسة الخصوصية';

  @override
  String get termsFooter => 'الشروط والأحكام';

  @override
  String get supportFooter => 'الدعم الفني';

  @override
  String get paid => 'مدفوعة';

  @override
  String get overdue => 'متأخرة';

  @override
  String get creditCard => 'بطاقة ائتمان';

  @override
  String get electronicWallet => 'محفظة إلكترونية';

  @override
  String get searchInvoiceHint => 'بحث برقم الفاتورة، العميل...';

  @override
  String get customerDetails => 'تفاصيل العميل';

  @override
  String get customerProfileAndTransactions =>
      'نظرة عامة على الملف الشخصي والمعاملات';

  @override
  String get customerDetailTitle => 'تفاصيل العميل';

  @override
  String get totalPurchases => 'إجمالي المشتريات';

  @override
  String get loyaltyPoints => 'نقاط الولاء';

  @override
  String get lastVisit => 'آخر زيارة';

  @override
  String get newSaleAction => 'بيع جديد';

  @override
  String get editInfo => 'تعديل البيانات';

  @override
  String get whatsapp => 'واتساب';

  @override
  String get blockCustomer => 'حظر العميل';

  @override
  String get purchasesTab => 'المشتريات';

  @override
  String get accountTab => 'الحساب';

  @override
  String get debtsTab => 'الديون';

  @override
  String get analyticsTab => 'التحليلات';

  @override
  String get recentOrdersLog => 'سجل الطلبات الأخير';

  @override
  String get exportCsv => 'تصدير CSV';

  @override
  String get searchByInvoiceNumber => 'بحث برقم الفاتورة...';

  @override
  String get items => 'البنود';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get financialLedger => 'سجل الحركات المالية';

  @override
  String get cashPaymentEntry => 'دفعة نقدية';

  @override
  String get walletTopup => 'شحن محفظة';

  @override
  String get loyaltyPointsDeduction => 'خصم نقاط ولاء';

  @override
  String redeemPoints(int count) {
    return 'استبدال $count نقطة';
  }

  @override
  String get viewFullLedger => 'عرض الكامل';

  @override
  String get currentBalance => 'الرصيد الحالي';

  @override
  String get creditLimit => 'الحد الائتماني';

  @override
  String get used => 'المستخدم';

  @override
  String get topUpBalance => 'شحن الرصيد';

  @override
  String get overdueDebt => 'متأخر';

  @override
  String get upcomingDebt => 'قريب';

  @override
  String get payNow => 'تسديد الآن';

  @override
  String get remind => 'تنبيه';

  @override
  String get monthlySpending => 'إجمالي الإنفاق الشهري';

  @override
  String get purchaseDistribution => 'توزيع المشتريات حسب الفئة';

  @override
  String get last6Months => 'آخر 6 أشهر';

  @override
  String get thisYear => 'هذا العام';

  @override
  String get averageOrder => 'متوسط الطلب';

  @override
  String get purchaseFrequency => 'تكرار الشراء';

  @override
  String everyNDays(int count) {
    return 'كل $count أيام';
  }

  @override
  String get spendingGrowth => 'نمو الإنفاق';

  @override
  String get favoriteProduct => 'المنتج المفضل';

  @override
  String get internalNotes => 'ملاحظات داخلية (مرئية للموظفين فقط)';

  @override
  String get addNote => 'إضافة';

  @override
  String get addNewNote => 'أضف ملاحظة جديدة...';

  @override
  String joinedDate(String date) {
    return 'انضم: $date';
  }

  @override
  String lastUpdated(String time) {
    return 'آخر تحديث: $time';
  }

  @override
  String showingOrders(int from, int to, int total) {
    return 'عرض $from-$to من $total طلب';
  }

  @override
  String get vegetables => 'خضروات';

  @override
  String get dairy => 'منتجات ألبان';

  @override
  String get meat => 'لحوم';

  @override
  String get bakery => 'مخبوزات';

  @override
  String get other => 'أخرى';

  @override
  String get returns => 'المرتجعات';

  @override
  String get salesReturns => 'مرتجعات المبيعات';

  @override
  String get purchaseReturns => 'مرتجعات المشتريات';

  @override
  String get totalReturns => 'إجمالي المرتجعات';

  @override
  String get totalRefundedAmount => 'إجمالي المبالغ المرجعة';

  @override
  String get mostReturned => 'الأكثر إرجاعاً';

  @override
  String get processed => 'مسترد';

  @override
  String get newReturn => 'مرتجع جديد';

  @override
  String get createNewReturn => 'إنشاء مرتجع جديد';

  @override
  String get processReturnRequest => 'معالجة طلب إرجاع مبيعات';

  @override
  String get returnNumber => 'رقم المرتجع';

  @override
  String get originalInvoice => 'الفاتورة الأصلية';

  @override
  String get returnReason => 'سبب الإرجاع';

  @override
  String get returnAmount => 'مبلغ الإرجاع';

  @override
  String get returnStatus => 'الحالة';

  @override
  String get returnDate => 'التاريخ';

  @override
  String get returnActions => 'إجراءات';

  @override
  String get returnRefunded => 'مسترد';

  @override
  String get returnRejected => 'مرفوض';

  @override
  String get defectiveProduct => 'تلف في المنتج';

  @override
  String get wrongProduct => 'منتج خاطئ';

  @override
  String get customerRequest => 'رغبة العميل';

  @override
  String get otherReason => 'سبب آخر';

  @override
  String get quickSearch => 'بحث سريع...';

  @override
  String get exportData => 'تصدير';

  @override
  String get printData => 'طباعة';

  @override
  String get approve => 'اعتماد';

  @override
  String get reject => 'رفض';

  @override
  String get previous => 'السابق';

  @override
  String get invoiceStep => 'الفاتورة';

  @override
  String get itemsStep => 'الأصناف';

  @override
  String get reasonStep => 'السبب';

  @override
  String get confirmStep => 'التأكيد';

  @override
  String get enterInvoiceNumber => 'رقم الفاتورة';

  @override
  String get invoiceExample => 'مثال: #INV-889';

  @override
  String get loadInvoice => 'تحميل';

  @override
  String invoiceLoaded(String number) {
    return 'تم تحميل الفاتورة #$number';
  }

  @override
  String invoiceLoadedCustomer(String customer, String date) {
    return 'العميل: $customer | التاريخ: $date';
  }

  @override
  String get selectItemsInfo =>
      'حدد الأصناف المراد إرجاعها. لا يمكن إرجاع كمية أكبر مما تم بيعه.';

  @override
  String availableToReturn(int count) {
    return 'متاح الإرجاع: $count';
  }

  @override
  String get alreadyReturnedFully => 'تم إرجاع الكمية بالكامل سابقاً';

  @override
  String get returnReasonLabel => 'سبب الإرجاع (للأصناف المحددة)';

  @override
  String get additionalDetails => 'تفاصيل إضافية (مطلوب عند اختيار أخرى)...';

  @override
  String get confirmReturn => 'تأكيد الإرجاع';

  @override
  String get refundAmount => 'المبلغ المسترد';

  @override
  String get refundMethod => 'طريقة الاسترداد';

  @override
  String get cashRefund => 'نقداً';

  @override
  String get storeCredit => 'رصيد المتجر';

  @override
  String get returnCreatedSuccess => 'تم إنشاء المرتجع بنجاح';

  @override
  String get noReturns => 'لا توجد مرتجعات';

  @override
  String get noReturnsDesc => 'لم يتم تسجيل أي عمليات إرجاع حتى الآن.';

  @override
  String timesReturned(int count, int percent) {
    return '$count مرات ($percent% من الإجمالي)';
  }

  @override
  String get fromInvoice => 'من فاتورة';

  @override
  String get dateFromTo => 'التاريخ من - إلى';

  @override
  String get returnCopied => 'تم نسخ الرقم بنجاح';

  @override
  String ofTotalProcessed(int percent) {
    return '$percent% تمت معالجته';
  }

  @override
  String get invoiceDetails => 'تفاصيل الفاتورة';

  @override
  String invoiceNumberLabel(String number) {
    return 'رقم:';
  }

  @override
  String get additionalOptions => 'خيارات إضافية';

  @override
  String get duplicateInvoice => 'إنشاء نسخة مكررة';

  @override
  String get returnMerchandise => 'إرجاع بضاعة';

  @override
  String get voidInvoice => 'إلغاء الفاتورة (Void)';

  @override
  String get printBtn => 'طباعة';

  @override
  String get downloadBtn => 'تحميل';

  @override
  String get paidSuccessfully => 'تم الدفع بنجاح';

  @override
  String get amountReceivedFull => 'تم استلام المبلغ بالكامل';

  @override
  String get completedStatus => 'مكتملة';

  @override
  String get pendingStatus => 'معلقة';

  @override
  String get voidedStatus => 'ملغاة';

  @override
  String get storeName => 'اسم المتجر';

  @override
  String get storeAddress => 'الرياض، حي الملز، شارع التخصصي';

  @override
  String get simplifiedTaxInvoice => 'فاتورة ضريبية مبسطة';

  @override
  String get dateAndTime => 'التاريخ والوقت';

  @override
  String get cashierLabel => 'الكاشير';

  @override
  String get itemCol => 'الصنف';

  @override
  String get quantityColDetail => 'الكمية';

  @override
  String get priceColDetail => 'السعر';

  @override
  String get totalCol => 'الإجمالي';

  @override
  String get subtotalLabel => 'المجموع الفرعي';

  @override
  String get discountVip => 'الخصم (عضو VIP)';

  @override
  String get vatLabel => 'ضريبة القيمة المضافة (15%)';

  @override
  String get grandTotalLabel => 'الإجمالي النهائي';

  @override
  String get paymentMethodLabel => 'طريقة الدفع';

  @override
  String get amountPaidLabel => 'المبلغ المدفوع';

  @override
  String get zatcaElectronic => 'ZATCA - فاتورة إلكترونية';

  @override
  String get scanToVerify => 'مسح للتحقق من صحة الفاتورة';

  @override
  String get includesVat15 => 'يشمل ضريبة القيمة المضافة 15%';

  @override
  String get thankYouVisit => 'شكراً لزيارتكم!';

  @override
  String get wishNiceDay => 'نتمنى لكم يوماً سعيداً';

  @override
  String get customerInfo => 'معلومات العميل';

  @override
  String get editBtn => 'تعديل';

  @override
  String vipSince(String year) {
    return 'عميل VIP منذ $year';
  }

  @override
  String get activeStatusLabel => 'نشط';

  @override
  String get callBtn => 'اتصال';

  @override
  String get recordBtn => 'السجل';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get sendWhatsappAction => 'إرسال واتساب';

  @override
  String get sendEmailAction => 'إرسال بالبريد';

  @override
  String get downloadPdfAction => 'تحميل PDF';

  @override
  String get shareLinkAction => 'مشاركة رابط';

  @override
  String get eventLog => 'سجل الأحداث';

  @override
  String get paymentCompleted => 'تم الدفع';

  @override
  String get processedViaGateway => 'تمت المعالجة عبر بوابة الدفع';

  @override
  String minutesAgoDetail(int count) {
    return 'منذ $count دقيقة';
  }

  @override
  String get invoiceCreated => 'إنشاء الفاتورة';

  @override
  String byUser(String name) {
    return 'بواسطة $name';
  }

  @override
  String todayAt(String time) {
    return 'اليوم، $time';
  }

  @override
  String get orderStarted => 'بداية الطلب';

  @override
  String get cashierSessionOpened => 'فتح جلسة الكاشير';

  @override
  String get technicalData => 'البيانات الفنية';

  @override
  String get deviceIdLabel => 'Device ID';

  @override
  String get terminalLabel => 'Terminal';

  @override
  String get softwareVersion => 'Software V';

  @override
  String get voidInvoiceConfirm => 'إلغاء الفاتورة؟';

  @override
  String get voidInvoiceMsg =>
      'سيتم إلغاء هذه الفاتورة نهائياً ولن يتم احتسابها في المبيعات اليومية. هل أنت متأكد؟';

  @override
  String get voidReasonLabel => 'سبب الإلغاء (مطلوب)';

  @override
  String get voidReasonEntry => 'خطأ في الإدخال';

  @override
  String get voidReasonCustomer => 'طلب العميل';

  @override
  String get voidReasonDamaged => 'منتج تالف';

  @override
  String get voidReasonOther => 'سبب آخر...';

  @override
  String get confirmVoid => 'تأكيد الإلغاء';

  @override
  String get invoiceVoided => 'تم إلغاء الفاتورة بنجاح';

  @override
  String copiedText(String text) {
    return 'تم نسخ: $text';
  }

  @override
  String visaEnding(String digits) {
    return 'Visa ينتهي بـ $digits';
  }

  @override
  String get mobileActionPrint => 'طباعة';

  @override
  String get mobileActionWhatsapp => 'واتساب';

  @override
  String get mobileActionEmail => 'بريد';

  @override
  String get mobileActionMore => 'المزيد';

  @override
  String get sarCurrency => 'ر.س';

  @override
  String skuLabel(String code) {
    return 'SKU: $code';
  }

  @override
  String get helpText => 'مساعدة';

  @override
  String get customerLedger => 'كشف حساب العميل';

  @override
  String get accountStatement => 'كشف حساب';

  @override
  String get allPeriods => 'الكل';

  @override
  String get threeMonths => '3 أشهر';

  @override
  String get allMovements => 'كل الحركات';

  @override
  String get adjustments => 'تسويات';

  @override
  String get statementCol => 'البيان';

  @override
  String get referenceCol => 'المرجع';

  @override
  String get debitCol => 'مدين';

  @override
  String get creditCol => 'دائن';

  @override
  String get balanceCol => 'الرصيد';

  @override
  String get openingBalance => 'رصيد افتتاحي';

  @override
  String get totalDebit => 'إجمالي المدين';

  @override
  String get totalCredit => 'إجمالي الدائن';

  @override
  String get finalBalance => 'الرصيد النهائي';

  @override
  String get manualAdjustment => 'تسوية يدوية';

  @override
  String get adjustmentType => 'نوع التعديل';

  @override
  String get debitAdjustment => 'تسوية مدينة';

  @override
  String get creditAdjustment => 'تسوية دائنة';

  @override
  String get adjustmentAmount => 'مبلغ التسوية';

  @override
  String get adjustmentReason => 'سبب التعديل';

  @override
  String get adjustmentDate => 'تاريخ التسوية';

  @override
  String get saveAdjustment => 'حفظ التعديل';

  @override
  String get adjustmentSaved => 'تم حفظ التسوية بنجاح';

  @override
  String get enterValidAmount => 'أدخل مبلغاً صحيحاً';

  @override
  String get dueOnCustomer => 'مستحق على العميل';

  @override
  String get customerHasCredit => 'للعميل رصيد دائن';

  @override
  String get noTransactions => 'لا توجد حركات';

  @override
  String get recordPaymentBtn => 'تسجيل دفعة';

  @override
  String get returnEntry => 'مرتجع';

  @override
  String get adjustmentEntry => 'تسوية';

  @override
  String get ordersHistory => 'سجل الطلبات';

  @override
  String get totalOrdersLabel => 'إجمالي الطلبات';

  @override
  String get completedOrders => 'مكتملة';

  @override
  String get pendingOrders => 'قيد الانتظار';

  @override
  String get cancelledOrders => 'ملغاة';

  @override
  String get searchOrderHint => 'بحث برقم الطلب، اسم العميل، أو الهاتف...';

  @override
  String get channelLabel => 'القناة';

  @override
  String get last30Days => 'آخر 30 يوم';

  @override
  String get orderDetails => 'تفاصيل الطلب';

  @override
  String get unpaidLabel => 'غير مدفوع';

  @override
  String get voidTransaction => 'إلغاء عملية';

  @override
  String get voidSaleTransaction => 'إلغاء عملية بيع';

  @override
  String get voidWarningTitle => 'تحذير هام: هذا الإجراء لا يمكن التراجع عنه';

  @override
  String get voidWarningDesc =>
      'سيؤدي إلغاء هذه العملية إلى إلغاء الفاتورة بالكامل وإرجاع جميع الأصناف للمخزون. يرجى التأكد من صحة المعلومات قبل المتابعة.';

  @override
  String get voidWarningShort =>
      'هذا الإجراء سيلغي الفاتورة بالكامل ويعيد الأصناف للمخزون. لا يمكن التراجع عنه.';

  @override
  String get enterInvoiceToVoid => 'أدخل رقم الفاتورة للإلغاء';

  @override
  String get searchByInvoiceOrBarcode =>
      'يمكنك البحث برقم الفاتورة أو استخدام الماسح الضوئي للباركود';

  @override
  String get invoiceExampleVoid => 'مثال: #INV-2024-8892';

  @override
  String get activateBarcode => 'تفعيل الماسح الضوئي';

  @override
  String get scanBarcodeMobile => 'مسح باركود';

  @override
  String get searchForInvoiceToVoid => 'ابحث عن فاتورة للإلغاء';

  @override
  String get enterNumberOrScan => 'أدخل الرقم يدوياً أو استخدم الماسح الضوئي.';

  @override
  String get salesInvoice => 'فاتورة مبيعات';

  @override
  String get invoiceCompleted => 'مكتملة';

  @override
  String get paidCash => 'تم الدفع: نقداً';

  @override
  String get customerLabel => 'عميل';

  @override
  String get dateAndTimeLabel => 'التاريخ والوقت';

  @override
  String get voidImpactSummary => 'ملخص أثر الإلغاء';

  @override
  String voidImpactItemsReturn(int count) {
    return 'سيتم إعادة $count أصناف للمخزون تلقائياً.';
  }

  @override
  String voidImpactRefund(String amount, String currency) {
    return 'سيتم خصم/إرجاع مبلغ $amount $currency.';
  }

  @override
  String returnedItems(int count) {
    return 'الأصناف المرتجعة ($count)';
  }

  @override
  String get viewAllItems => 'عرض الكل';

  @override
  String moreItemsHint(int count, String amount, String currency) {
    return '+ $count أصناف أخرى (مجموع: $amount $currency)';
  }

  @override
  String get voidReason => 'سبب الإلغاء';

  @override
  String get voidReasonRequired => 'سبب الإلغاء *';

  @override
  String get customerRequestReason => 'طلب من العميل';

  @override
  String get wrongItemsReason => 'أصناف خاطئة';

  @override
  String get duplicateInvoiceReason => 'فاتورة مكررة';

  @override
  String get systemErrorReason => 'خطأ في النظام';

  @override
  String get otherReasonVoid => 'أخرى';

  @override
  String get additionalNotesVoid => 'ملاحظات إضافية...';

  @override
  String get additionalDetailsRequired =>
      'تفاصيل إضافية (مطلوب عند اختيار أخرى)...';

  @override
  String get managerApproval => 'موافقة المدير';

  @override
  String get managerApprovalRequired => 'موافقة المدير مطلوبة';

  @override
  String amountExceedsLimit(String amount, String currency) {
    return 'المبلغ يتجاوز الحد المسموح به ($amount $currency)، يرجى إدخال رمز PIN للمدير.';
  }

  @override
  String get enterPinCode => 'أدخل رمز PIN';

  @override
  String get pinSentToManager => 'تم إرسال رمز مؤقت إلى جوال المدير';

  @override
  String get defaultManagerPin => 'رمز المدير الافتراضي: 1234';

  @override
  String get confirmVoidAction => 'أؤكد إلغاء هذه العملية';

  @override
  String get confirmVoidDesc =>
      'لقد اطلعت على التفاصيل وأتحمل المسؤولية الكاملة.';

  @override
  String get cancelAction => 'إلغاء';

  @override
  String get confirmFinalVoid => 'تأكيد الإلغاء النهائي';

  @override
  String get invoiceNotFound => 'الفاتورة غير موجودة';

  @override
  String get invoiceNotFoundDesc =>
      'تأكد من صحة الرقم المدخل أو حاول البحث باستخدام الباركود.';

  @override
  String get trySearchAgain => 'محاولة البحث مرة أخرى';

  @override
  String get voidSuccess => 'تم إلغاء العملية بنجاح';

  @override
  String qtyLabel(int count) {
    return 'الكمية: $count';
  }

  @override
  String get manageCustomersAndAccounts => 'إدارة العملاء والحسابات';

  @override
  String get totalCustomersCount => 'إجمالي العملاء';

  @override
  String get outstandingDebts => 'ديون مستحقة';

  @override
  String get creditBalance => 'رصيد للعملاء';

  @override
  String get filterByLabel => 'تصفية حسب';

  @override
  String get debtors => 'عليهم ديون';

  @override
  String get creditorsLabel => 'لهم رصيد';

  @override
  String get quickActionsLabel => 'إجراءات سريعة';

  @override
  String get sendDebtReminder => 'إرسال تذكير للمديونين';

  @override
  String get exportAccountStatement => 'تصدير كشف الحسابات';

  @override
  String cancelSelectionCount(String count) {
    return 'إلغاء التحديد ($count)';
  }

  @override
  String get searchByNameOrPhone => 'بحث بالاسم أو الهاتف... (Ctrl+F)';

  @override
  String get sortByBalance => 'الرصيد';

  @override
  String get refreshF5 => 'تحديث (F5)';

  @override
  String get loadingCustomers => 'جاري تحميل العملاء...';

  @override
  String get payDebt => 'تسديد دين';

  @override
  String dueAmountLabel(String amount) {
    return 'المستحق: $amount ر.س';
  }

  @override
  String get paymentAmountLabel => 'مبلغ السداد';

  @override
  String get fullAmount => 'كامل';

  @override
  String get payAction => 'تسديد';

  @override
  String paymentRecorded(String amount) {
    return 'تم تسجيل سداد $amount ر.س';
  }

  @override
  String customerAddedSuccess(String name) {
    return 'تم إضافة $name';
  }

  @override
  String get customerNameRequired => 'اسم العميل *';

  @override
  String get owedLabel => 'عليه';

  @override
  String get hasBalanceLabel => 'له';

  @override
  String get zeroLabel => 'صفر';

  @override
  String get addAction => 'إضافة';

  @override
  String get expenses => 'المصروفات';

  @override
  String get expenseCategories => 'تصنيفات المصروفات';

  @override
  String get addExpense => 'إضافة مصروف';

  @override
  String get totalExpenses => 'إجمالي المصروفات';

  @override
  String get thisMonthExpenses => 'هذا الشهر';

  @override
  String get expenseAmount => 'المبلغ';

  @override
  String get expenseDate => 'التاريخ';

  @override
  String get expenseCategory => 'التصنيف';

  @override
  String get expenseNotes => 'ملاحظات';

  @override
  String get noExpenses => 'لا توجد مصروفات مسجلة';

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
  String get shiftsTitle => 'الورديات';

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
  String get cashierName => 'اسم الكاشير';

  @override
  String get shiftDuration => 'المدة';

  @override
  String get noShifts => 'لا توجد ورديات مسجلة';

  @override
  String get purchasesTitle => 'المشتريات';

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
  String get suppliersTitle => 'الموردين';

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
  String get discountsTitle => 'الخصومات';

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
  String get couponsTitle => 'الكوبونات';

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
  String get specialOffersTitle => 'العروض الخاصة';

  @override
  String get addOffer => 'إضافة عرض';

  @override
  String get offerName => 'اسم العرض';

  @override
  String get offerStartDate => 'تاريخ البدء';

  @override
  String get offerEndDate => 'تاريخ الانتهاء';

  @override
  String get smartPromotionsTitle => 'العروض الذكية';

  @override
  String get activePromotions => 'العروض النشطة';

  @override
  String get suggestedPromotions => 'اقتراحات AI';

  @override
  String get loyaltyTitle => 'برنامج الولاء';

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
  String get notificationsTitle => 'الإشعارات';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get printQueueTitle => 'قائمة الطباعة';

  @override
  String get printAll => 'طباعة الكل';

  @override
  String get cancelAll => 'إلغاء الكل';

  @override
  String get noPrintJobs => 'لا توجد مهام طباعة';

  @override
  String get syncStatusTitle => 'حالة المزامنة';

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
  String get driversTitle => 'السائقين';

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
  String get branchesTitle => 'الفروع';

  @override
  String get addBranchAction => 'إضافة فرع';

  @override
  String get branchName => 'اسم الفرع';

  @override
  String get branchEmployees => 'الموظفين';

  @override
  String get branchSales => 'مبيعات اليوم';

  @override
  String get profileTitle => 'الملف الشخصي';

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
  String get settingsTitle => 'الإعدادات';

  @override
  String get storeSettings => 'إعدادات المتجر';

  @override
  String get posSettings => 'إعدادات نقطة البيع';

  @override
  String get printerSettings => 'إعدادات الطابعة';

  @override
  String get paymentDevicesSettings => 'أجهزة الدفع';

  @override
  String get barcodeSettings => 'إعدادات الباركود';

  @override
  String get receiptTemplate => 'قالب الإيصال';

  @override
  String get taxSettings => 'إعدادات الضرائب';

  @override
  String get discountSettings => 'إعدادات الخصومات';

  @override
  String get interestSettings => 'إعدادات الفوائد';

  @override
  String get languageSettings => 'اللغة';

  @override
  String get themeSettings => 'المظهر';

  @override
  String get securitySettings => 'الأمان';

  @override
  String get usersManagement => 'إدارة المستخدمين';

  @override
  String get rolesPermissions => 'الأدوار والصلاحيات';

  @override
  String get activityLog => 'سجل النشاط';

  @override
  String get backupSettings => 'النسخ الاحتياطي والاستعادة';

  @override
  String get notificationSettings => 'الإشعارات';

  @override
  String get zatcaCompliance => 'امتثال هيئة الزكاة والضريبة';

  @override
  String get helpSupport => 'المساعدة والدعم';

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
  String get taxNumber => 'الرقم الضريبي';

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
  String get liveChat => 'محادثة مباشرة';

  @override
  String get emailSupport => 'دعم البريد الإلكتروني';

  @override
  String get phoneSupport => 'دعم الهاتف';

  @override
  String get whatsappSupport => 'دعم واتساب';

  @override
  String get userGuide => 'دليل المستخدم';

  @override
  String get videoTutorials => 'فيديوهات تعليمية';

  @override
  String get changelog => 'سجل التحديثات';

  @override
  String get appInfo => 'معلومات التطبيق';

  @override
  String get buildNumber => 'رقم البناء';

  @override
  String get notificationChannels => 'قنوات الإشعارات';

  @override
  String get alertTypes => 'أنواع التنبيهات';

  @override
  String get salesAlerts => 'تنبيهات المبيعات';

  @override
  String get inventoryAlerts => 'تنبيهات المخزون';

  @override
  String get securityAlerts => 'تنبيهات الأمان';

  @override
  String get reportAlerts => 'تنبيهات التقارير';

  @override
  String get users => 'المستخدمون';

  @override
  String get zatcaRegistered => 'مسجل في هيئة الزكاة والضريبة';

  @override
  String get zatcaPhase2Active => 'المرحلة الثانية نشطة';

  @override
  String get registrationInfo => 'معلومات التسجيل';

  @override
  String get businessName => 'اسم المنشأة';

  @override
  String get branchCode => 'رمز الفرع';

  @override
  String get qrCodeOnInvoice => 'يظهر رمز QR على كل فاتورة';

  @override
  String get certificates => 'الشهادات';

  @override
  String get csidCertificate => 'شهادة CSID';

  @override
  String get valid => 'صالحة';

  @override
  String get privateKey => 'المفتاح الخاص';

  @override
  String get configured => 'مهيأ';

  @override
  String get aiSection => 'الذكاء الاصطناعي';

  @override
  String get aiAssistantTitle => 'المساعد الذكي';

  @override
  String get aiAssistantSubtitle => 'اسأل مساعدك الذكي أي شيء عن متجرك';

  @override
  String get aiSalesForecastingTitle => 'التنبؤ بالمبيعات';

  @override
  String get aiSalesForecastingSubtitle =>
      'توقع المبيعات المستقبلية باستخدام البيانات التاريخية';

  @override
  String get aiSmartPricingTitle => 'التسعير الذكي';

  @override
  String get aiSmartPricingSubtitle =>
      'اقتراحات تحسين الأسعار بالذكاء الاصطناعي';

  @override
  String get aiFraudDetectionTitle => 'كشف الاحتيال';

  @override
  String get aiFraudDetectionSubtitle => 'كشف الأنماط المشبوهة وحماية أعمالك';

  @override
  String get aiBasketAnalysisTitle => 'تحليل السلة';

  @override
  String get aiBasketAnalysisSubtitle =>
      'اكتشف المنتجات المُشتراة معاً بشكل متكرر';

  @override
  String get aiCustomerRecommendationsTitle => 'توصيات العملاء';

  @override
  String get aiCustomerRecommendationsSubtitle =>
      'اقتراحات منتجات مخصصة لكل عميل';

  @override
  String get aiSmartInventoryTitle => 'المخزون الذكي';

  @override
  String get aiSmartInventorySubtitle =>
      'مستويات المخزون المثالية والتنبؤ بالهدر';

  @override
  String get aiCompetitorAnalysisTitle => 'تحليل المنافسين';

  @override
  String get aiCompetitorAnalysisSubtitle => 'قارن أسعارك مع المنافسين';

  @override
  String get aiSmartReportsTitle => 'التقارير الذكية';

  @override
  String get aiSmartReportsSubtitle => 'أنشئ تقارير باستخدام اللغة الطبيعية';

  @override
  String get aiStaffAnalyticsTitle => 'تحليل الموظفين';

  @override
  String get aiStaffAnalyticsSubtitle => 'تحليل أداء الموظفين وتحسين الجدولة';

  @override
  String get aiProductRecognitionTitle => 'التعرف على المنتجات';

  @override
  String get aiProductRecognitionSubtitle =>
      'تعرّف على المنتجات باستخدام الكاميرا';

  @override
  String get aiSentimentAnalysisTitle => 'تحليل المشاعر';

  @override
  String get aiSentimentAnalysisSubtitle =>
      'تحليل ملاحظات العملاء ومستوى الرضا';

  @override
  String get aiReturnPredictionTitle => 'التنبؤ بالمرتجعات';

  @override
  String get aiReturnPredictionSubtitle => 'توقع ومنع إرجاع المنتجات';

  @override
  String get aiPromotionDesignerTitle => 'مصمم العروض';

  @override
  String get aiPromotionDesignerSubtitle =>
      'عروض مولّدة بالذكاء الاصطناعي مع توقع العائد';

  @override
  String get aiChatWithDataTitle => 'الدردشة مع البيانات';

  @override
  String get aiChatWithDataSubtitle => 'استعلم عن بياناتك باللغة الطبيعية';

  @override
  String get aiConfidence => 'الثقة';

  @override
  String get aiHighConfidence => 'ثقة عالية';

  @override
  String get aiMediumConfidence => 'ثقة متوسطة';

  @override
  String get aiLowConfidence => 'ثقة منخفضة';

  @override
  String get aiAnalyzing => 'جاري التحليل...';

  @override
  String get aiGenerating => 'جاري الإنشاء...';

  @override
  String get aiNoData => 'لا توجد بيانات كافية للتحليل';

  @override
  String get aiRefresh => 'تحديث التحليل';

  @override
  String get aiExport => 'تصدير النتائج';

  @override
  String get aiApply => 'تطبيق الاقتراحات';

  @override
  String get aiDismiss => 'تجاهل';

  @override
  String get aiViewDetails => 'عرض التفاصيل';

  @override
  String get aiSuggestions => 'اقتراحات AI';

  @override
  String get aiInsights => 'رؤى AI';

  @override
  String get aiPrediction => 'تنبؤ';

  @override
  String get aiRecommendation => 'توصية';

  @override
  String get aiAlert => 'تنبيه';

  @override
  String get aiWarning => 'تحذير';

  @override
  String get aiTrend => 'الاتجاه';

  @override
  String get aiPositive => 'إيجابي';

  @override
  String get aiNegative => 'سلبي';

  @override
  String get aiNeutral => 'محايد';

  @override
  String get aiSendMessage => 'اكتب رسالتك...';

  @override
  String get aiQuickTemplates => 'قوالب سريعة';

  @override
  String get aiForecastPeriod => 'فترة التنبؤ';

  @override
  String get aiWeekly => 'أسبوعي';

  @override
  String get aiMonthly => 'شهري';

  @override
  String get aiQuarterly => 'ربع سنوي';

  @override
  String get aiWhatIfScenario => 'سيناريو ماذا لو';

  @override
  String get aiSeasonalPatterns => 'الأنماط الموسمية';

  @override
  String get aiPriceSuggestion => 'اقتراح السعر';

  @override
  String get aiCurrentPrice => 'السعر الحالي';

  @override
  String get aiSuggestedPrice => 'السعر المقترح';

  @override
  String get aiPriceImpact => 'تأثير السعر';

  @override
  String get aiDemandElasticity => 'مرونة الطلب';

  @override
  String get aiFraudAlerts => 'تنبيهات الاحتيال';

  @override
  String get aiFraudRiskScore => 'درجة الخطورة';

  @override
  String get aiBehaviorScore => 'درجة السلوك';

  @override
  String get aiInvestigation => 'التحقيق';

  @override
  String get aiAssociationRules => 'قواعد الارتباط';

  @override
  String get aiBundleSuggestions => 'اقتراحات الحزم';

  @override
  String get aiRepurchaseReminder => 'تذكير إعادة الشراء';

  @override
  String get aiCustomerSegment => 'شريحة العميل';

  @override
  String get aiEoqCalculator => 'حاسبة الكمية المثالية';

  @override
  String get aiAbcAnalysis => 'تحليل ABC';

  @override
  String get aiWastePrediction => 'التنبؤ بالهدر';

  @override
  String get aiReorderPoint => 'نقطة إعادة الطلب';

  @override
  String get aiCompetitorPrices => 'أسعار المنافسين';

  @override
  String get aiMarketPosition => 'الموقع السوقي';

  @override
  String get aiQueryInput => 'اسأل أي شيء عن بياناتك...';

  @override
  String get aiReportTemplate => 'قالب التقرير';

  @override
  String get aiStaffPerformance => 'أداء الموظفين';

  @override
  String get aiShiftOptimization => 'تحسين الورديات';

  @override
  String get aiProductScan => 'مسح المنتج';

  @override
  String get aiOcrResults => 'نتائج OCR';

  @override
  String get aiSentimentScore => 'مؤشر المشاعر';

  @override
  String get aiKeywords => 'الكلمات المفتاحية';

  @override
  String get aiReturnRisk => 'خطر الإرجاع';

  @override
  String get aiPreventiveActions => 'إجراءات وقائية';

  @override
  String get aiRoiForecast => 'توقع العائد';

  @override
  String get aiAbTesting => 'اختبار A/B';

  @override
  String get aiQueryHistory => 'سجل الاستعلامات';

  @override
  String get aiApplied => 'مُطبّق';

  @override
  String get aiPending => 'قيد الانتظار';

  @override
  String get aiHighPriority => 'أولوية عالية';

  @override
  String get aiMediumPriority => 'أولوية متوسطة';

  @override
  String get aiLowPriority => 'أولوية منخفضة';

  @override
  String get aiCritical => 'حرج';

  @override
  String get aiSar => 'ر.س';

  @override
  String aiPercentChange(String percent) {
    return '$percent% تغيير';
  }

  @override
  String aiItemsCount(int count) {
    return '$count عنصر';
  }

  @override
  String aiLastUpdated(String time) {
    return 'آخر تحديث: $time';
  }

  @override
  String get connectedToServer => 'متصل بالسيرفر';

  @override
  String lastSyncAt(String time) {
    return 'آخر مزامنة: $time';
  }

  @override
  String get pendingOperations => 'العمليات المعلقة';

  @override
  String nPendingOperations(int count) {
    return '$count عملية تنتظر المزامنة';
  }

  @override
  String get noPendingOperations => 'لا توجد عمليات معلقة';

  @override
  String get syncInfo => 'معلومات المزامنة';

  @override
  String get device => 'الجهاز';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get lastFullSync => 'آخر مزامنة كاملة';

  @override
  String get databaseStatus => 'حالة قاعدة البيانات';

  @override
  String get healthy => 'سليمة';

  @override
  String get syncSuccessful => 'تمت المزامنة بنجاح';

  @override
  String get justNow => 'الآن';

  @override
  String get allOperationsSynced => 'جميع العمليات متزامنة';

  @override
  String get willSyncWhenOnline => 'سيتم مزامنتها عند الاتصال بالإنترنت';

  @override
  String get syncAll => 'مزامنة الكل';

  @override
  String get operationSynced => 'تمت مزامنة العملية';

  @override
  String get deleteOperation => 'حذف العملية';

  @override
  String get deleteOperationConfirm =>
      'هل تريد حذف هذه العملية من قائمة الانتظار؟';

  @override
  String get insertOperation => 'إضافة';

  @override
  String get updateOperation => 'تعديل';

  @override
  String get operationLabel => 'عملية';

  @override
  String nPendingCount(int count) {
    return '$count عملية معلقة';
  }

  @override
  String conflictsNeedResolution(int count) {
    return '$count تعارضات تحتاج حل';
  }

  @override
  String get chooseCorrectValue => 'اختر القيمة الصحيحة لكل تعارض';

  @override
  String get noConflicts => 'لا توجد تعارضات';

  @override
  String get productPriceConflict => 'تعارض في سعر المنتج';

  @override
  String get stockQuantityConflict => 'تعارض في كمية المخزون';

  @override
  String get useAllLocal => 'استخدام الكل المحلي';

  @override
  String get useAllServer => 'استخدام الكل من السيرفر';

  @override
  String get conflictResolvedLocal => 'تم حل التعارض باستخدام القيمة المحلية';

  @override
  String get conflictResolvedServer =>
      'تم حل التعارض باستخدام القيمة من السيرفر';

  @override
  String get useLocalValues => 'القيم المحلية';

  @override
  String get useServerValues => 'قيم السيرفر';

  @override
  String applyToAllConflicts(String choice) {
    return 'سيتم تطبيق $choice على جميع التعارضات';
  }

  @override
  String get allConflictsResolved => 'تم حل جميع التعارضات';

  @override
  String get localValueLabel => 'القيمة المحلية';

  @override
  String get serverValueLabel => 'القيمة من السيرفر';

  @override
  String get noteOptional => 'ملاحظة (اختياري)';

  @override
  String get suspendInvoice => 'تعليق الفاتورة';

  @override
  String get invoiceSuspended => 'تم تعليق الفاتورة';

  @override
  String nItems(int count) {
    return '$count عنصر';
  }

  @override
  String saveSaleError(String error) {
    return 'خطأ في حفظ البيع: $error';
  }

  @override
  String get refresh => 'تحديث';

  @override
  String get stockGood => 'المخزون جيد!';

  @override
  String get manageInventory => 'إدارة المخزون';

  @override
  String pendingSyncCount(int count) {
    return '$count قيد المزامنة';
  }

  @override
  String get freshMilk => 'حليب طازج';

  @override
  String get whiteBread => 'خبز أبيض';

  @override
  String get localEggs => 'بيض بلدي';

  @override
  String get yogurt => 'زبادي';

  @override
  String minQuantityLabel(int count) {
    return 'الحد الأدنى: $count';
  }

  @override
  String get manageDiscounts => 'إدارة الخصومات';

  @override
  String get newDiscount => 'خصم جديد';

  @override
  String get totalLabel => 'المجموع';

  @override
  String get stopped => 'متوقف';

  @override
  String get allProducts => 'جميع المنتجات';

  @override
  String get specificCategory => 'تصنيف محدد';

  @override
  String get percentageLabel => 'نسبة %';

  @override
  String get fixedAmount => 'مبلغ ثابت';

  @override
  String get thePercentage => 'النسبة';

  @override
  String get theAmount => 'المبلغ';

  @override
  String discountOff(String value) {
    return '$value% خصم';
  }

  @override
  String sarDiscountOff(String value) {
    return '$value ر.س خصم';
  }

  @override
  String get manageCoupons => 'إدارة الكوبونات';

  @override
  String get newCoupon => 'كوبون جديد';

  @override
  String get expired => 'منتهي الصلاحية';

  @override
  String get deactivated => 'معطل';

  @override
  String usageCount(int used, int max) {
    return '$used/$max استخدام';
  }

  @override
  String get freeDelivery => 'توصيل مجاني';

  @override
  String percentageDiscountLabel(int value) {
    return 'خصم $value%';
  }

  @override
  String fixedDiscountLabel(int value) {
    return 'خصم $value ر.س';
  }

  @override
  String get couponTypeLabel => 'النوع';

  @override
  String get percentageRate => 'النسبة %';

  @override
  String get minimumOrder => 'الحد الأدنى للطلب';

  @override
  String get expiryDate => 'تاريخ الانتهاء';

  @override
  String get copyCode => 'نسخ';

  @override
  String get usages => 'الاستخدامات';

  @override
  String get percentageDiscountOption => 'خصم نسبة';

  @override
  String get fixedDiscountOption => 'خصم ثابت';

  @override
  String get freeDeliveryOption => 'توصيل مجاني';

  @override
  String get percentageField => 'النسبة %';

  @override
  String get manageSpecialOffers => 'إدارة العروض الخاصة';

  @override
  String get newOffer => 'عرض جديد';

  @override
  String get expiringSoon => 'ينتهي قريباً';

  @override
  String get offerExpired => 'منتهي';

  @override
  String bundleDiscount(String discount) {
    return 'باقة - خصم $discount%';
  }

  @override
  String get buyAndGetFree => 'اشتري واحصل مجاناً';

  @override
  String offerDiscountPercent(String discount) {
    return 'خصم $discount%';
  }

  @override
  String offerDiscountFixed(String discount) {
    return 'خصم $discount ر.س';
  }

  @override
  String get bundleLabel => 'باقة';

  @override
  String get buyAndGet => 'اشترِ واحصل';

  @override
  String get startDateLabel => 'البداية';

  @override
  String get endDateLabel => 'النهاية';

  @override
  String get productsLabel => 'المنتجات';

  @override
  String get offerType => 'النوع';

  @override
  String get theDiscount => 'الخصم:';

  @override
  String get smartSuggestions => 'اقتراحات ذكية';

  @override
  String get suggestionsBasedOnAnalysis =>
      'عروض مقترحة بناءً على تحليل المبيعات والمخزون';

  @override
  String suggestedDiscountPercent(int percent) {
    return '$percent% خصم مقترح';
  }

  @override
  String stockLabelCount(int count) {
    return 'المخزون: $count';
  }

  @override
  String validityDays(int days) {
    return 'الصلاحية: $days يوم';
  }

  @override
  String get ignore => 'تجاهل';

  @override
  String get applyAction => 'تطبيق';

  @override
  String usageCountTimes(int count) {
    return 'استخدام: $count مرة';
  }

  @override
  String get promotionHistory => 'سجل العروض السابقة';

  @override
  String get createNewPromotion => 'إنشاء عرض جديد';

  @override
  String get percentageDiscountType => 'خصم نسبة مئوية';

  @override
  String get percentageDiscountDesc => 'خصم 10%، 20%، إلخ';

  @override
  String get buyXGetY => 'اشتري X واحصل على Y';

  @override
  String get buyXGetYDesc => 'اشتري 2 واحصل على 1 مجاناً';

  @override
  String get fixedAmountDiscount => 'خصم مبلغ ثابت';

  @override
  String get fixedAmountDiscountDesc => 'خصم 10 ر.س على المنتج';

  @override
  String promotionApplied(String product) {
    return 'تم تطبيق العرض على $product';
  }

  @override
  String promotionType(String type) {
    return 'النوع: $type';
  }

  @override
  String promotionValue(String value) {
    return 'القيمة: $value';
  }

  @override
  String promotionUsage(int count) {
    return 'الاستخدام: $count مرة';
  }

  @override
  String get percentageType => 'نسبة مئوية';

  @override
  String get buyXGetYType => 'اشتري واحصل';

  @override
  String get fixedAmountType => 'مبلغ ثابت';

  @override
  String get closeAction => 'إغلاق';

  @override
  String get holdInvoices => 'الفواتير المعلقة';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get noHoldInvoices => 'لا توجد فواتير معلقة';

  @override
  String get holdInvoicesDesc =>
      'عند تعليق فاتورة من نقطة البيع ستظهر هنا\nيمكنك تعليق عدة فواتير واستئنافها لاحقاً';

  @override
  String get deleteInvoiceTitle => 'حذف الفاتورة';

  @override
  String deleteInvoiceConfirmMsg(String name) {
    return 'هل تريد حذف \"$name\"?\nهذا الإجراء لا يمكن التراجع عنه.';
  }

  @override
  String get cannotUndo => 'هذا الإجراء لا يمكن التراجع عنه.';

  @override
  String get deleteAllLabel => 'حذف الكل';

  @override
  String get deleteAllInvoices => 'حذف جميع الفواتير';

  @override
  String deleteAllInvoicesConfirm(int count) {
    return 'هل تريد حذف جميع الفواتير المعلقة ($count فاتورة)?\nهذا الإجراء لا يمكن التراجع عنه.';
  }

  @override
  String get invoiceDeletedMsg => 'تم حذف الفاتورة';

  @override
  String get allInvoicesDeleted => 'تم حذف جميع الفواتير';

  @override
  String resumedInvoice(String name) {
    return 'تم استئناف: $name';
  }

  @override
  String itemLabel(int count) {
    return '$count عنصر';
  }

  @override
  String moreItems(int count) {
    return '+$count عناصر أخرى';
  }

  @override
  String get resume => 'استئناف';

  @override
  String get justNowTime => 'الآن';

  @override
  String minutesAgoTime(int count) {
    return 'منذ $count دقيقة';
  }

  @override
  String hoursAgoTime(int count) {
    return 'منذ $count ساعة';
  }

  @override
  String daysAgoTime(int count) {
    return 'منذ $count يوم';
  }

  @override
  String get debtManagement => 'إدارة الديون';

  @override
  String get sortLabel => 'ترتيب';

  @override
  String get sortByAmount => 'حسب المبلغ';

  @override
  String get sortByDate => 'حسب التاريخ';

  @override
  String get sendReminders => 'إرسال تذكيرات';

  @override
  String get allTab => 'الكل';

  @override
  String get overdueTab => 'متأخرة';

  @override
  String get upcomingTab => 'قادمة';

  @override
  String get totalDebts => 'إجمالي الديون';

  @override
  String get overdueDebts => 'ديون متأخرة';

  @override
  String get debtorCustomers => 'عملاء مدينون';

  @override
  String get noDebts => 'لا توجد ديون';

  @override
  String customerLabel2(int count) {
    return '$count عميل';
  }

  @override
  String overdueDays(int days) {
    return 'متأخر $days يوم';
  }

  @override
  String remainingDays(int days) {
    return 'متبقي $days يوم';
  }

  @override
  String lastPaymentDate(String date) {
    return 'آخر دفعة: $date';
  }

  @override
  String get recordPayment => 'تسجيل دفعة';

  @override
  String get amountDue => 'المبلغ المستحق';

  @override
  String currentDebt(String amount) {
    return 'الدين الحالي: $amount ر.س';
  }

  @override
  String get paidAmount => 'المبلغ المدفوع';

  @override
  String get cashMethod => 'نقداً';

  @override
  String get cardMethod => 'بطاقة';

  @override
  String get transferMethod => 'تحويل';

  @override
  String get paymentRecordedSuccess => 'تم تسجيل الدفعة بنجاح';

  @override
  String get sendRemindersTitle => 'إرسال تذكيرات';

  @override
  String sendRemindersConfirm(int count) {
    return 'سيتم إرسال تذكير لـ $count عميل لديهم ديون متأخرة';
  }

  @override
  String get sendAction => 'إرسال';

  @override
  String remindersSent(int count) {
    return 'تم إرسال $count تذكير';
  }

  @override
  String recordPaymentFor(String name) {
    return 'تسجيل دفعة - $name';
  }

  @override
  String get sendReminder => 'إرسال تذكير';

  @override
  String get tabAiSuggestions => 'اقتراحات AI';

  @override
  String get tabActivePromotions => 'العروض النشطة';

  @override
  String get tabHistory => 'السجل';

  @override
  String get fruitYogurt => 'زبادي فواكه';

  @override
  String get buttermilk => 'لبن رايب';

  @override
  String get appleJuice => 'عصير تفاح';

  @override
  String get whiteCheese => 'جبنة بيضاء';

  @override
  String get orangeJuice => 'عصير برتقال';

  @override
  String slowMovementReason(String days) {
    return 'حركة بطيئة - $days يوم بدون بيع';
  }

  @override
  String get nearExpiryReason => 'قرب انتهاء الصلاحية';

  @override
  String get excessStockReason => 'مخزون زائد';

  @override
  String get weekendOffer => 'عرض نهاية الأسبوع';

  @override
  String get buy2Get1Free => 'اشتري 2 واحصل على 1 مجاناً';

  @override
  String get productsListLabel => 'المنتجات:';

  @override
  String get paymentMethodLabel2 => 'طريقة الدفع';

  @override
  String get lastPaymentLabel => 'آخر دفعة';

  @override
  String get currencySAR => 'ر.س';

  @override
  String debtAmountWithCurrency(String amount) {
    return '$amount ر.س';
  }

  @override
  String get defaultUserName => 'أحمد محمد';

  @override
  String get saveSettings => 'حفظ الإعدادات';

  @override
  String get settingsSaved => 'تم حفظ الإعدادات';

  @override
  String get settingsReset => 'تم إعادة ضبط الإعدادات';

  @override
  String get resetSettings => 'إعادة ضبط الإعدادات';

  @override
  String get resetSettingsDesc => 'إعادة جميع الإعدادات للقيم الافتراضية';

  @override
  String get resetSettingsConfirm =>
      'هل أنت متأكد من إعادة جميع إعدادات نقطة البيع للقيم الافتراضية؟';

  @override
  String get resetAction => 'إعادة تعيين';

  @override
  String get posSettingsSubtitle => 'العرض، السلة، الدفع، الإيصال';

  @override
  String get displaySettings => 'إعدادات العرض';

  @override
  String get productDisplayMode => 'طريقة عرض المنتجات';

  @override
  String get productDisplayModeDesc => 'كيفية عرض المنتجات في شاشة POS';

  @override
  String get gridColumns => 'عدد الأعمدة';

  @override
  String nColumns(int count) {
    return '$count أعمدة';
  }

  @override
  String get showProductImages => 'عرض صور المنتجات';

  @override
  String get showProductImagesDesc => 'إظهار الصور في بطاقات المنتجات';

  @override
  String get showPrices => 'عرض الأسعار';

  @override
  String get showPricesDesc => 'إظهار السعر على بطاقة المنتج';

  @override
  String get showStockLevel => 'عرض مستوى المخزون';

  @override
  String get showStockLevelDesc => 'إظهار الكمية المتاحة';

  @override
  String get cartSettings => 'إعدادات السلة';

  @override
  String get autoFocusBarcode => 'التركيز التلقائي على الباركود';

  @override
  String get autoFocusBarcodeDesc => 'التركيز على حقل الباركود عند فتح الشاشة';

  @override
  String get allowNegativeStock => 'السماح بالمخزون السالب';

  @override
  String get allowNegativeStockDesc => 'البيع حتى لو كان المخزون صفر';

  @override
  String get confirmBeforeDelete => 'تأكيد قبل الحذف';

  @override
  String get confirmBeforeDeleteDesc => 'طلب تأكيد عند حذف منتج من السلة';

  @override
  String get showItemNotes => 'عرض ملاحظات المنتج';

  @override
  String get showItemNotesDesc => 'إمكانية إضافة ملاحظات لكل منتج';

  @override
  String get cashPaymentOption => 'الدفع نقداً';

  @override
  String get cardPaymentOption => 'الدفع بالبطاقة';

  @override
  String get creditPaymentOption => 'الدفع الآجل';

  @override
  String get bankTransferOption => 'التحويل البنكي';

  @override
  String get allowSplitPayment => 'السماح بتقسيم الدفع';

  @override
  String get allowSplitPaymentDesc => 'الدفع بأكثر من طريقة';

  @override
  String get requireCustomerForCredit => 'اشتراط العميل للدفع الآجل';

  @override
  String get requireCustomerForCreditDesc => 'يجب تحديد عميل للدفع الآجل';

  @override
  String get receiptSettings => 'إعدادات الإيصال';

  @override
  String get autoPrintReceipt => 'طباعة الإيصال تلقائياً';

  @override
  String get autoPrintReceiptDesc => 'طباعة فور إتمام العملية';

  @override
  String get receiptCopies => 'عدد نسخ الإيصال';

  @override
  String get emailReceiptOption => 'إرسال الإيصال بالإيميل';

  @override
  String get emailReceiptDesc => 'إرسال نسخة للعميل';

  @override
  String get smsReceiptOption => 'إرسال الإيصال برسالة SMS';

  @override
  String get smsReceiptDesc => 'رسالة نصية للعميل';

  @override
  String get printerSettingsDesc => 'اختيار الطابعة وإعداداتها';

  @override
  String get receiptDesign => 'تصميم الإيصال';

  @override
  String get receiptDesignDesc => 'تخصيص شكل الإيصال';

  @override
  String get advancedSettings => 'إعدادات متقدمة';

  @override
  String get allowHoldInvoices => 'السماح بتعليق الفواتير';

  @override
  String get allowHoldInvoicesDesc => 'حفظ الفاتورة مؤقتاً';

  @override
  String get maxHoldInvoices => 'الحد الأقصى للفواتير المعلقة';

  @override
  String get quickSaleMode => 'وضع البيع السريع';

  @override
  String get quickSaleModeDesc => 'شاشة مبسطة للبيع السريع';

  @override
  String get soundEffects => 'المؤثرات الصوتية';

  @override
  String get soundEffectsDesc => 'أصوات عند المسح والإضافة';

  @override
  String get hapticFeedback => 'اهتزاز اللمس';

  @override
  String get hapticFeedbackDesc => 'اهتزاز عند الضغط على الأزرار';

  @override
  String get keyboardShortcuts => 'اختصارات لوحة المفاتيح';

  @override
  String get customizeShortcuts => 'تخصيص الاختصارات';

  @override
  String get shortcutSearchProduct => 'البحث عن منتج';

  @override
  String get shortcutSearchCustomer => 'البحث عن عميل';

  @override
  String get shortcutHoldInvoice => 'تعليق الفاتورة';

  @override
  String get shortcutFavorites => 'المفضلة';

  @override
  String get shortcutApplyDiscount => 'تطبيق خصم';

  @override
  String get shortcutPayment => 'الدفع';

  @override
  String get shortcutCancelBack => 'إلغاء / رجوع';

  @override
  String get shortcutDeleteProduct => 'حذف منتج';

  @override
  String get paymentDevicesSubtitle => 'mada, STC Pay, Apple Pay';

  @override
  String get supportedPaymentMethods => 'طرق الدفع المدعومة';

  @override
  String get madaLocalCards => 'بطاقات مدى المحلية';

  @override
  String get internationalCards => 'البطاقات الدولية';

  @override
  String get stcDigitalWallet => 'محفظة STC الرقمية';

  @override
  String get paymentTerminal => 'جهاز الدفع';

  @override
  String get ingenicoDevices => 'أجهزة Ingenico';

  @override
  String get verifoneDevices => 'أجهزة Verifone';

  @override
  String get paxDevices => 'أجهزة PAX';

  @override
  String get settlement => 'التسوية';

  @override
  String get autoSettlement => 'التسوية التلقائية';

  @override
  String get autoSettlementDesc => 'تسوية نهاية اليوم تلقائياً';

  @override
  String get manualSettlement => 'تسوية يدوية';

  @override
  String get executeSettlementNow => 'تنفيذ التسوية الآن';

  @override
  String get settlingInProgress => 'جاري التسوية...';

  @override
  String get paymentDevicesSettingsSaved => 'تم حفظ إعدادات أجهزة الدفع';

  @override
  String get printerType => 'نوع الطابعة';

  @override
  String get thermalUsbPrinter => 'طابعة حرارية USB';

  @override
  String get bluetoothPortablePrinter => 'طابعة بلوتوث محمولة';

  @override
  String get saveAsPdf => 'حفظ كملف PDF';

  @override
  String get compactTemplate => 'مختصر';

  @override
  String get basicInfoOnly => 'معلومات أساسية فقط';

  @override
  String get detailedTemplate => 'تفصيلي';

  @override
  String get allDetails => 'كل التفاصيل';

  @override
  String get printOptions => 'خيارات الطباعة';

  @override
  String get autoPrinting => 'الطباعة التلقائية';

  @override
  String get autoPrintAfterSale => 'طباعة الإيصال تلقائياً بعد كل عملية بيع';

  @override
  String get testPrintInProgress => 'جاري الطباعة التجريبية...';

  @override
  String get testPrint => 'طباعة تجريبية';

  @override
  String get printerSettingsSaved => 'تم حفظ إعدادات الطابعة';

  @override
  String get printerSettingsSubtitle =>
      'نوع الطابعة، القالب، الطباعة التلقائية';

  @override
  String get enableScanner => 'تفعيل الماسح';

  @override
  String get barcodeScanner => 'الماسح الضوئي';

  @override
  String get barcodeScannerDesc => 'استخدام ماسح الباركود لإضافة المنتجات';

  @override
  String get deviceCamera => 'كاميرا الجهاز';

  @override
  String get bluetoothScanner => 'ماسح Bluetooth';

  @override
  String get externalScannerConnected => 'ماسح خارجي متصل';

  @override
  String get alerts => 'التنبيهات';

  @override
  String get beepOnScan => 'صوت عند المسح';

  @override
  String get vibrateOnScan => 'اهتزاز عند المسح';

  @override
  String get behavior => 'السلوك';

  @override
  String get autoAddToCart => 'إضافة تلقائية للسلة';

  @override
  String get autoAddToCartDesc => 'عند مسح منتج موجود';

  @override
  String get barcodeFormats => 'صيغ الباركود';

  @override
  String get allFormats => 'جميع الصيغ';

  @override
  String get unspecified => 'غير محدد';

  @override
  String get qrCodeOnly => 'QR Code فقط';

  @override
  String get testing => 'الاختبار';

  @override
  String get testScanner => 'اختبار الماسح';

  @override
  String get testScanBarcode => 'تجربة مسح باركود';

  @override
  String get pointCameraAtBarcode => 'وجه الكاميرا نحو الباركود';

  @override
  String get scanArea => 'منطقة المسح';

  @override
  String get barcodeSettingsSubtitle => 'الماسح الضوئي، التنبيهات، الصيغ';

  @override
  String get taxSettingsSubtitle => 'VAT, ZATCA, الفوترة الإلكترونية';

  @override
  String get vatSettings => 'ضريبة القيمة المضافة';

  @override
  String get enableVat => 'تفعيل ضريبة القيمة المضافة';

  @override
  String get enableVatDesc => 'تطبيق VAT على جميع المبيعات';

  @override
  String get taxRate => 'نسبة الضريبة';

  @override
  String get taxNumberHint => '15 رقم يبدأ بـ 3';

  @override
  String get pricesIncludeTax => 'الأسعار شاملة الضريبة';

  @override
  String get pricesIncludeTaxDesc => 'الأسعار المعروضة تتضمن الضريبة';

  @override
  String get showTaxOnReceipt => 'إظهار الضريبة في الإيصال';

  @override
  String get showTaxOnReceiptDesc => 'عرض تفاصيل الضريبة';

  @override
  String get zatcaEInvoicing => 'ZATCA - الفوترة الإلكترونية';

  @override
  String get enableZatca => 'تفعيل ZATCA';

  @override
  String get enableZatcaDesc => 'الامتثال لنظام الفوترة الإلكترونية';

  @override
  String get phaseOne => 'المرحلة الأولى';

  @override
  String get phaseOneDesc => 'إصدار الفاتورة';

  @override
  String get phaseTwo => 'المرحلة الثانية';

  @override
  String get phaseTwoDesc => 'الربط والتكامل';

  @override
  String get taxSettingsSaved => 'تم حفظ إعدادات الضرائب';

  @override
  String get discountSettingsTitle => 'إعدادات الخصومات';

  @override
  String get discountSettingsSubtitle => 'الخصم اليدوي، VIP، الكمية، الكوبونات';

  @override
  String get generalDiscounts => 'الخصومات العامة';

  @override
  String get enableDiscountsOption => 'تفعيل الخصومات';

  @override
  String get enableDiscountsDesc => 'السماح بتطبيق الخصومات';

  @override
  String get manualDiscount => 'الخصم اليدوي';

  @override
  String get manualDiscountDesc => 'السماح للكاشير بإدخال خصم يدوي';

  @override
  String get maxDiscountLimit => 'الحد الأقصى للخصم';

  @override
  String get requireApproval => 'اشتراط الموافقة';

  @override
  String get requireApprovalDesc => 'طلب موافقة المدير للخصم';

  @override
  String get vipCustomerDiscount => 'خصم العملاء المميزين';

  @override
  String get vipDiscount => 'خصم VIP';

  @override
  String get vipDiscountDesc => 'خصم تلقائي للعملاء المميزين';

  @override
  String get vipDiscountRate => 'نسبة خصم VIP';

  @override
  String get otherDiscounts => 'خصومات أخرى';

  @override
  String get volumeDiscount => 'خصم الكمية';

  @override
  String get volumeDiscountDesc => 'خصم تلقائي عند شراء كمية معينة';

  @override
  String get couponsOption => 'الكوبونات';

  @override
  String get couponsDesc => 'دعم كوبونات الخصم';

  @override
  String get discountSettingsSaved => 'تم حفظ إعدادات الخصومات';

  @override
  String get interestSettingsTitle => 'إعدادات الفوائد';

  @override
  String get interestSettingsSubtitle => 'النسبة، فترة السماح، الحساب التلقائي';

  @override
  String get monthlyInterest => 'الفوائد الشهرية';

  @override
  String get enableInterest => 'تفعيل الفوائد';

  @override
  String get enableInterestDesc => 'تطبيق فوائد على الديون الآجلة';

  @override
  String get monthlyInterestRate => 'نسبة الفائدة الشهرية';

  @override
  String get maxInterestRateLabel => 'الحد الأقصى للفائدة';

  @override
  String get gracePeriod => 'فترة السماح';

  @override
  String get graceDays => 'أيام السماح';

  @override
  String graceDaysLabel(int days) {
    return '$days يوم قبل احتساب الفائدة';
  }

  @override
  String get compoundInterest => 'الفائدة المركبة';

  @override
  String get compoundInterestDesc => 'احتساب فائدة على الفائدة';

  @override
  String get calculationAndAlerts => 'الحساب والتنبيهات';

  @override
  String get autoCalculation => 'الحساب التلقائي';

  @override
  String get autoCalculationDesc => 'احتساب الفوائد تلقائياً نهاية كل شهر';

  @override
  String get customerNotification => 'إشعار العميل';

  @override
  String get customerNotificationDesc => 'إرسال إشعار عند احتساب الفائدة';

  @override
  String get interestSettingsSaved => 'تم حفظ إعدادات الفوائد';

  @override
  String get receiptTemplateTitle => 'قالب الإيصال';

  @override
  String get receiptTemplateSubtitle => 'الرأس، التذييل، الحقول، حجم الورق';

  @override
  String get headerAndFooter => 'الرأس والتذييل';

  @override
  String get receiptTitleField => 'عنوان الإيصال';

  @override
  String get footerText => 'نص التذييل';

  @override
  String get displayedFields => 'الحقول المعروضة';

  @override
  String get storeLogo => 'شعار المتجر';

  @override
  String get addressField => 'العنوان';

  @override
  String get phoneNumberField => 'رقم الهاتف';

  @override
  String get vatNumberField => 'الرقم الضريبي';

  @override
  String get invoiceBarcode => 'باركود الفاتورة';

  @override
  String get qrCodeField => 'رمز QR';

  @override
  String get qrCodeEInvoice => 'رمز QR للفاتورة الإلكترونية';

  @override
  String get paperSize => 'حجم الورق';

  @override
  String get standardSize => 'الحجم القياسي';

  @override
  String get smallSize => 'حجم صغير';

  @override
  String get normalPrint => 'طباعة عادية';

  @override
  String get receiptTemplateSaved => 'تم حفظ قالب الإيصال';

  @override
  String get instantNotifications => 'إشعارات فورية على الجهاز';

  @override
  String get emailNotificationsDesc => 'إرسال إشعارات عبر البريد';

  @override
  String get smsNotificationsDesc => 'إشعارات عبر الرسائل النصية';

  @override
  String get salesAlertsDesc => 'تنبيهات المبيعات والفواتير';

  @override
  String get inventoryAlertsDesc => 'تنبيهات المخزون المنخفض';

  @override
  String get securityAlertsDesc => 'تنبيهات الأمان وتسجيل الدخول';

  @override
  String get reportAlertsDesc => 'تقارير يومية وأسبوعية';

  @override
  String get contactSupportDesc => 'متاح 24/7';

  @override
  String get systemGuide => 'دليل استخدام النظام';

  @override
  String get changeLog => 'سجل التحديثات';

  @override
  String get faqQuestion1 => 'كيف أضيف منتج جديد؟';

  @override
  String get faqAnswer1 => 'اذهب إلى المنتجات > إضافة منتج واملأ التفاصيل';

  @override
  String get faqQuestion2 => 'كيف أطبع الفواتير؟';

  @override
  String get faqAnswer2 => 'بعد إتمام البيع، اضغط على طباعة الإيصال';

  @override
  String get faqQuestion3 => 'كيف أضبط الخصومات؟';

  @override
  String get faqAnswer3 => 'من الإعدادات > إعدادات الخصومات يمكنك ضبط الخصومات';

  @override
  String get faqQuestion4 => 'كيف أضيف مستخدم جديد؟';

  @override
  String get faqAnswer4 => 'من الإعدادات > إدارة المستخدمين > إضافة مستخدم';

  @override
  String get faqQuestion5 => 'كيف أشاهد التقارير؟';

  @override
  String get faqAnswer5 =>
      'من القائمة الرئيسية > التقارير، اختر نوع التقرير المطلوب';

  @override
  String get businessNameValue => 'مؤسسة الهاي';

  @override
  String get disabledLabel => 'معطل';

  @override
  String get allFilter => 'الكل';

  @override
  String get loginLogoutFilter => 'الدخول/الخروج';

  @override
  String get salesFilter => 'المبيعات';

  @override
  String get productsFilter => 'المنتجات';

  @override
  String get usersFilter => 'المستخدمين';

  @override
  String get systemFilter => 'النظام';

  @override
  String get noActivities => 'لا توجد نشاطات';

  @override
  String get pinSection => 'رمز PIN';

  @override
  String get createPinOption => 'إنشاء رمز PIN';

  @override
  String get createPinDesc => 'تعيين رمز PIN من 4 أرقام للدخول السريع';

  @override
  String get changePinOption => 'تغيير رمز PIN';

  @override
  String get changePinDesc => 'تحديث رمز PIN الحالي';

  @override
  String get removePinOption => 'إزالة رمز PIN';

  @override
  String get removePinDesc => 'حذف PIN واستخدام دخول OTP';

  @override
  String get biometricSection => 'تسجيل الدخول البيومتري';

  @override
  String get fingerprintOption => 'بصمة الإصبع';

  @override
  String get fingerprintDesc => 'الدخول باستخدام بصمة الإصبع';

  @override
  String get faceIdOption => 'التعرف على الوجه';

  @override
  String get faceIdDesc => 'الدخول باستخدام التعرف على الوجه';

  @override
  String get sessionSection => 'الجلسة';

  @override
  String get autoLockOption => 'القفل التلقائي';

  @override
  String get autoLockDesc => 'قفل الشاشة بعد عدم النشاط';

  @override
  String get autoLockTimeout => 'مدة القفل التلقائي';

  @override
  String get dangerZone => 'منطقة الخطر';

  @override
  String get logoutAllDevices => 'تسجيل الخروج من كل الأجهزة';

  @override
  String get logoutAllDevicesDesc => 'إنهاء جميع الجلسات النشطة';

  @override
  String get clearAllData => 'مسح جميع البيانات';

  @override
  String get clearAllDataDesc => 'حذف جميع البيانات المحلية';

  @override
  String get createPinTitle => 'إنشاء رمز PIN';

  @override
  String get enterNewPin => 'أدخل رمز PIN جديد من 4 أرقام';

  @override
  String get changePinTitle => 'تغيير رمز PIN';

  @override
  String get enterCurrentPin => 'أدخل رمز PIN الحالي';

  @override
  String get enterNewPinChange => 'أدخل رمز PIN الجديد';

  @override
  String get removePinTitle => 'إزالة رمز PIN';

  @override
  String get removePinConfirm => 'هل أنت متأكد من إزالة تسجيل الدخول بـ PIN؟';

  @override
  String get removeAction => 'إزالة';

  @override
  String get pinCreated => 'تم إنشاء رمز PIN بنجاح';

  @override
  String get pinChangedSuccess => 'تم تغيير رمز PIN بنجاح';

  @override
  String get pinRemovedSuccess => 'تم إزالة رمز PIN';

  @override
  String get logoutAllTitle => 'تسجيل الخروج من كل الأجهزة';

  @override
  String get logoutAllConfirm =>
      'سيتم إنهاء جميع الجلسات النشطة. ستحتاج لتسجيل الدخول مرة أخرى.';

  @override
  String get logoutAllAction => 'تسجيل الخروج من الكل';

  @override
  String get loggedOutAll => 'تم تسجيل الخروج من جميع الأجهزة';

  @override
  String get clearDataTitle => 'مسح جميع البيانات';

  @override
  String get clearDataConfirm =>
      'سيتم حذف جميع البيانات المحلية. هذا الإجراء لا يمكن التراجع عنه.';

  @override
  String get clearDataAction => 'مسح البيانات';

  @override
  String get dataCleared => 'تم مسح جميع البيانات';

  @override
  String afterMinutes(int count) {
    return 'بعد $count دقيقة';
  }

  @override
  String get storeInfo => 'معلومات المتجر';

  @override
  String get storeNameField => 'اسم المتجر';

  @override
  String get addressLabel => 'العنوان';

  @override
  String get taxInfo => 'المعلومات الضريبية';

  @override
  String get vatNumberFieldLabel => 'الرقم الضريبي (VAT)';

  @override
  String get vatNumberHintText => '15 رقم يبدأ بـ 3';

  @override
  String get commercialRegister => 'السجل التجاري';

  @override
  String get enableVatOption => 'تفعيل ضريبة القيمة المضافة';

  @override
  String get taxRateField => 'نسبة الضريبة';

  @override
  String get languageAndCurrency => 'اللغة والعملة';

  @override
  String get currencyFieldLabel => 'العملة';

  @override
  String get saudiRiyal => 'ريال سعودي (SAR)';

  @override
  String get usDollar => 'دولار أمريكي (USD)';

  @override
  String get storeLogoSection => 'شعار المتجر';

  @override
  String get storeLogoDesc => 'يظهر في الفواتير والإيصالات';

  @override
  String get changeButton => 'تغيير';

  @override
  String get storeSettingsSaved => 'تم حفظ إعدادات المتجر';

  @override
  String get ownerRole => 'مالك';

  @override
  String get managerRole => 'مدير';

  @override
  String get supervisorRole => 'مشرف';

  @override
  String get cashierRole => 'كاشير';

  @override
  String get disabledStatus => 'معطل';

  @override
  String get editMenuAction => 'تعديل';

  @override
  String get disableMenuAction => 'تعطيل';

  @override
  String get enableMenuAction => 'تفعيل';

  @override
  String get addUserTitle => 'إضافة مستخدم';

  @override
  String get editUserTitle => 'تعديل المستخدم';

  @override
  String get nameRequired => 'الاسم *';

  @override
  String get roleLabel => 'الصلاحية';

  @override
  String get userDetailsTitle => 'تفاصيل المستخدم';

  @override
  String get rolesTab => 'الأدوار';

  @override
  String get permissionsTab => 'الصلاحيات';

  @override
  String get newRoleButton => 'دور جديد';

  @override
  String get systemBadge => 'نظام';

  @override
  String userCountLabel(int count) {
    return '$count مستخدم';
  }

  @override
  String permissionCountLabel(int count) {
    return '$count صلاحية';
  }

  @override
  String get editRoleMenu => 'تعديل';

  @override
  String get duplicateRoleMenu => 'نسخ';

  @override
  String get deleteRoleMenu => 'حذف';

  @override
  String get addRoleTitle => 'إضافة دور';

  @override
  String get editRoleTitle => 'تعديل الدور';

  @override
  String get roleNameField => 'اسم الدور';

  @override
  String get roleDescField => 'الوصف';

  @override
  String get rolePermissionsLabel => 'الصلاحيات';

  @override
  String get permViewSales => 'عرض المبيعات';

  @override
  String get permViewSalesDesc => 'عرض المبيعات والفواتير';

  @override
  String get permCreateSale => 'إنشاء بيع';

  @override
  String get permCreateSaleDesc => 'إنشاء عمليات بيع جديدة';

  @override
  String get permApplyDiscount => 'تطبيق خصم';

  @override
  String get permApplyDiscountDesc => 'تطبيق خصومات على الفواتير';

  @override
  String get permVoidSale => 'إلغاء بيع';

  @override
  String get permVoidSaleDesc => 'إلغاء وحذف عمليات البيع';

  @override
  String get permViewProducts => 'عرض المنتجات';

  @override
  String get permViewProductsDesc => 'عرض قائمة المنتجات';

  @override
  String get permEditProducts => 'تعديل المنتجات';

  @override
  String get permEditProductsDesc => 'تعديل تفاصيل وأسعار المنتجات';

  @override
  String get permManageInventory => 'إدارة المخزون';

  @override
  String get permManageInventoryDesc => 'إدارة المخزون والجرد';

  @override
  String get permViewReports => 'عرض التقارير';

  @override
  String get permViewReportsDesc => 'عرض جميع التقارير';

  @override
  String get permExportReports => 'تصدير التقارير';

  @override
  String get permExportReportsDesc => 'تصدير التقارير كـ PDF/Excel';

  @override
  String get permViewCustomers => 'عرض العملاء';

  @override
  String get permViewCustomersDesc => 'عرض قائمة العملاء';

  @override
  String get permManageCustomers => 'إدارة العملاء';

  @override
  String get permManageCustomersDesc => 'إضافة وتعديل العملاء';

  @override
  String get permManageDebts => 'إدارة الديون';

  @override
  String get permManageDebtsDesc => 'إدارة ديون العملاء';

  @override
  String get permOpenCloseShift => 'فتح/إغلاق الوردية';

  @override
  String get permOpenCloseShiftDesc => 'فتح وإغلاق ورديات العمل';

  @override
  String get permManageCashDrawer => 'إدارة درج النقد';

  @override
  String get permManageCashDrawerDesc => 'إضافة وسحب النقد';

  @override
  String get permManageUsers => 'إدارة المستخدمين';

  @override
  String get permManageUsersDesc => 'إضافة وتعديل المستخدمين';

  @override
  String get permManageRoles => 'إدارة الأدوار';

  @override
  String get permManageRolesDesc => 'إدارة الأدوار والصلاحيات';

  @override
  String get permViewSettings => 'عرض الإعدادات';

  @override
  String get permViewSettingsDesc => 'عرض إعدادات النظام';

  @override
  String get permEditSettings => 'تعديل الإعدادات';

  @override
  String get permEditSettingsDesc => 'تعديل إعدادات النظام';

  @override
  String get permViewAuditLog => 'عرض سجل النشاطات';

  @override
  String get permViewAuditLogDesc => 'عرض سجل النشاطات';

  @override
  String get permManageBackup => 'إدارة النسخ الاحتياطي';

  @override
  String get permManageBackupDesc => 'النسخ الاحتياطي والاستعادة';

  @override
  String get permCategorySales => 'المبيعات';

  @override
  String get permCategoryProducts => 'المنتجات';

  @override
  String get permCategoryReports => 'التقارير';

  @override
  String get permCategoryCustomers => 'العملاء';

  @override
  String get permCategoryShifts => 'الورديات';

  @override
  String get permCategoryUsers => 'المستخدمين';

  @override
  String get permCategorySettings => 'الإعدادات';

  @override
  String get permCategorySecurity => 'الأمان';

  @override
  String get autoBackupEnabled => 'يتم النسخ تلقائياً';

  @override
  String get autoBackupDisabledLabel => 'معطل';

  @override
  String get backupFrequency => 'تكرار النسخ';

  @override
  String get everyHour => 'كل ساعة';

  @override
  String get dailyBackup => 'يومياً';

  @override
  String get weeklyBackup => 'أسبوعياً';

  @override
  String get manualBackupSection => 'النسخ اليدوي';

  @override
  String get createBackupNow => 'إنشاء نسخة احتياطية الآن';

  @override
  String get lastBackupTime => 'آخر نسخة: منذ 3 ساعات';

  @override
  String get restoreSection => 'الاستعادة';

  @override
  String get restoreFromBackup => 'استعادة من نسخة احتياطية';

  @override
  String get restoreFromBackupDesc => 'استرجاع البيانات من نسخة سابقة';

  @override
  String get backupHistoryLabel => 'سجل النسخ الاحتياطي';

  @override
  String get backupInProgress => 'جاري إنشاء النسخة الاحتياطية...';

  @override
  String get backupCreated => 'تم إنشاء النسخة الاحتياطية بنجاح';

  @override
  String get restoreConfirmTitle => 'استعادة من نسخة احتياطية';

  @override
  String get restoreConfirmMessage =>
      'سيتم استبدال جميع البيانات الحالية. هذا الإجراء لا يمكن التراجع عنه.';

  @override
  String get restoreAction => 'استعادة';

  @override
  String get restoreInProgress => 'جاري الاستعادة...';

  @override
  String get restoreComplete => 'تمت الاستعادة بنجاح';

  @override
  String get pasteCode => 'لصق الرمز';

  @override
  String devOtpMessage(String otp) {
    return 'رمز التطوير: $otp';
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
  String get nearExpiry => 'قرب الانتهاء';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منتج',
      many: '$count منتجاً',
      few: '$count منتجات',
      two: 'منتجان',
      one: 'منتج واحد',
      zero: 'لا توجد منتجات',
    );
    return '$_temp0';
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
  String get currentlyOpenShift => 'وردية مفتوحة حالياً';

  @override
  String get since => 'منذ';

  @override
  String get transaction => 'عملية';

  @override
  String get totalTransactions => 'إجمالي العمليات';

  @override
  String get openShifts => 'ورديات مفتوحة';

  @override
  String get closedShifts => 'ورديات مغلقة';

  @override
  String get shiftsLog => 'سجل الورديات';

  @override
  String get noShiftsToday => 'لا توجد ورديات اليوم';

  @override
  String get open => 'مفتوحة';

  @override
  String get customPeriod => 'فترة مخصصة';

  @override
  String get salesReport => 'تقرير المبيعات';

  @override
  String get salesReportDesc => 'تفاصيل المبيعات والفواتير';

  @override
  String get profitReport => 'تقرير الأرباح';

  @override
  String get profitReportDesc => 'صافي الربح والخسائر';

  @override
  String get inventoryReport => 'تقرير المخزون';

  @override
  String get inventoryReportDesc => 'حركات المخزون والجرد';

  @override
  String get vatReport => 'تقرير الضريبة (VAT)';

  @override
  String get vatReportDesc => 'ضريبة القيمة المضافة 15%';

  @override
  String get customerReport => 'تقرير العملاء';

  @override
  String get customerReportDesc => 'نشاط العملاء والديون';

  @override
  String get purchasesReport => 'تقرير المشتريات';

  @override
  String get purchasesReportDesc => 'فواتير الشراء والموردين';

  @override
  String get costs => 'التكاليف';

  @override
  String get netProfit => 'صافي الربح';

  @override
  String get salesTax => 'ضريبة المبيعات';

  @override
  String get purchasesTax => 'ضريبة المشتريات';

  @override
  String get taxDue => 'المستحق';

  @override
  String get debts => 'الديون';

  @override
  String get paidDebts => 'المسددة';

  @override
  String get averageAmount => 'المتوسط';

  @override
  String get suppliers => 'الموردين';

  @override
  String get todayExpenses => 'مصروفات اليوم';

  @override
  String get transactionCount => 'عدد العمليات';

  @override
  String get salaries => 'رواتب';

  @override
  String get rent => 'إيجار';

  @override
  String get purchases => 'المشتريات';

  @override
  String get noDriversRegistered => 'لا يوجد سائقون مسجلون';

  @override
  String get addDriversForDelivery => 'أضف سائقين لإدارة التوصيل';

  @override
  String get onDelivery => 'في توصيلة';

  @override
  String get unavailable => 'غير متاح';

  @override
  String get totalDrivers => 'إجمالي السائقين';

  @override
  String get availableDrivers => 'سائقون متاحون';

  @override
  String get inDelivery => 'في التوصيل';

  @override
  String get excellentRating => 'تقييم ممتاز';

  @override
  String get delivery => 'توصيلة';

  @override
  String get track => 'تتبع';

  @override
  String get percentage => 'نسبة مئوية';

  @override
  String get totalSavings => 'إجمالي التوفير';

  @override
  String get totalUsage => 'إجمالي الاستخدام';

  @override
  String get times => 'مرات';

  @override
  String get activeOffers => 'عروض فعالة';

  @override
  String get upcomingOffers => 'عروض قادمة';

  @override
  String get expiredOffers => 'عروض منتهية';

  @override
  String get bundle => 'باقة';

  @override
  String get dueDebts => 'ديون مستحقة';

  @override
  String get collected => 'تم التحصيل';

  @override
  String get newNotification => 'إشعار جديد';

  @override
  String get oneHourAgo => 'قبل ساعة';

  @override
  String get twoHoursAgo => 'قبل ساعتين';

  @override
  String get trackingMap => 'خريطة التتبع';

  @override
  String deliveriesToday(int count) {
    return '$count توصيلة اليوم';
  }

  @override
  String get assignOrder => 'تعيين طلب';

  @override
  String get driversTrackingMap => 'خريطة تتبع السائقين';

  @override
  String get gpsSubscriptionRequired => '(يتطلب اشتراك GPS)';

  @override
  String get vehicleLabel => 'المركبة';

  @override
  String get vehicleHint => 'مثال: هايلكس - أبيض';

  @override
  String get plateNumberLabel => 'رقم اللوحة';

  @override
  String assignOrderTo(String name) {
    return 'تعيين طلب لـ $name';
  }

  @override
  String get orderLabel => 'طلب';

  @override
  String orderAssignedTo(String name) {
    return 'تم تعيين الطلب لـ $name';
  }

  @override
  String closingPeriod(String period) {
    return 'فترة الإقفال: $period';
  }

  @override
  String lastClosing(String date) {
    return 'آخر إقفال: $date';
  }

  @override
  String interestRateAndGrace(String rate, String days) {
    return 'نسبة الفائدة: $rate% | فترة السماح: $days يوم';
  }

  @override
  String get selectedCustomers => 'العملاء المختارين';

  @override
  String get expectedInterests => 'الفوائد المتوقعة';

  @override
  String get noDebtsNeedClosing => 'لا توجد ديون تحتاج إقفال';

  @override
  String get allCustomersWithinGrace => 'جميع العملاء ضمن فترة السماح';

  @override
  String debtLabel(String amount) {
    return 'الدين: $amount ر.س';
  }

  @override
  String expectedInterestLabel(String amount) {
    return 'الفائدة المتوقعة: $amount ر.س';
  }

  @override
  String selectedCustomerCount(int count) {
    return '$count عميل مختار';
  }

  @override
  String get processingClose => 'جاري المعالجة...';

  @override
  String get executeClose => 'تنفيذ الإقفال';

  @override
  String interestWillBeAdded(int count) {
    return 'سيتم إضافة فوائد على $count عميل';
  }

  @override
  String totalInterestsLabel(String amount) {
    return 'إجمالي الفوائد: $amount ر.س';
  }

  @override
  String monthCloseSuccess(int count) {
    return 'تم إقفال الشهر لـ $count عميل';
  }

  @override
  String get readAll => 'قراءة الكل';

  @override
  String get averageExpense => 'متوسط المصروف';

  @override
  String get expensesList => 'قائمة المصروفات';

  @override
  String get electricity => 'كهرباء';

  @override
  String get maintenance => 'صيانة';

  @override
  String get services => 'خدمات';

  @override
  String get expense => 'مصروف';

  @override
  String get filterExpenses => 'تصفية المصروفات';

  @override
  String get openedNotification => 'مفتوحة';

  @override
  String get openTime => 'وقت الفتح';

  @override
  String get closeTime => 'وقت الإغلاق';

  @override
  String get expectedCash => 'الصندوق المتوقع';

  @override
  String get closingCash => 'صندوق الإغلاق';

  @override
  String get printAction => 'طباعة';

  @override
  String get exportAction => 'تصدير';

  @override
  String get viewReport => 'عرض التقرير';

  @override
  String get exportingReport => 'جاري تصدير التقرير...';

  @override
  String get chartsUnderDev => 'الرسوم البيانية قيد التطوير...';

  @override
  String get reportsAnalysis => 'تحليل الأداء والمبيعات';

  @override
  String aiAssociationFrequency(
      String productA, String productB, int frequency) {
    return '$productA + $productB: تكرار $frequency مرة';
  }

  @override
  String aiBundleActivated(String name) {
    return 'تم تفعيل حزمة: $name';
  }

  @override
  String aiPromotionsGeneratedCount(int count) {
    return 'تم توليد $count عرض ترويجي بناءً على تحليل بيانات المتجر';
  }

  @override
  String aiPromotionApplied(String title) {
    return 'تم تطبيق: $title';
  }

  @override
  String aiConfidencePercent(String percent) {
    return 'ثقة: $percent%';
  }

  @override
  String aiAlertsWithCount(int count) {
    return 'التنبيهات ($count)';
  }

  @override
  String aiStaffCurrentSuggested(int current, int suggested) {
    return '$current موظف حالياً → $suggested مقترح';
  }

  @override
  String aiMinutesAgo(int minutes) {
    return 'منذ $minutes دقيقة';
  }

  @override
  String aiHoursAgo(int hours) {
    return 'منذ $hours ساعة';
  }

  @override
  String aiDaysAgo(int days) {
    return 'منذ $days يوم';
  }

  @override
  String aiDetectedCount(int count) {
    return 'تم الكشف: $count';
  }

  @override
  String aiMatchedCount(int count) {
    return 'مطابق: $count';
  }

  @override
  String aiAccuracyPercent(String percent) {
    return 'دقة: $percent%';
  }

  @override
  String aiProductAccepted(String name) {
    return 'تم قبول $name';
  }

  @override
  String aiErrorOccurred(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String aiErrorWithMessage(String error) {
    return 'خطأ: $error';
  }

  @override
  String get aiBasketAnalysis => 'تحليل السلة بالذكاء الاصطناعي';

  @override
  String get aiAssociations => 'الارتباطات';

  @override
  String get aiCrossSell => 'البيع المتقاطع';

  @override
  String get aiAvgBasketSize => 'متوسط حجم السلة';

  @override
  String get aiProductUnit => 'منتج';

  @override
  String get aiAvgBasketValue => 'متوسط قيمة السلة';

  @override
  String get aiSaudiRiyal => 'ريال سعودي';

  @override
  String get aiStrongestAssociation => 'أقوى ارتباط';

  @override
  String get aiConversionRate => 'معدل التحويل';

  @override
  String get aiFromSuggestions => 'من الاقتراحات';

  @override
  String get aiAssistant => 'المساعد الذكي';

  @override
  String get aiAskAboutStore => 'اسأل أي سؤال عن متجرك';

  @override
  String get aiClearChat => 'مسح المحادثة';

  @override
  String get aiAssistantReady => 'المساعد الذكي جاهز لمساعدتك!';

  @override
  String get aiAskAboutSalesStock =>
      'اسأل عن المبيعات، المخزون، العملاء، أو أي شيء عن متجرك';

  @override
  String get aiCompetitorAnalysis => 'تحليل المنافسين';

  @override
  String get aiPriceComparison => 'مقارنة الأسعار';

  @override
  String get aiTrackedProducts => 'منتجات تحت المراقبة';

  @override
  String get aiCheaperThanCompetitors => 'أرخص من المنافسين';

  @override
  String get aiMoreExpensive => 'أغلى من المنافسين';

  @override
  String get aiAvgPriceDiff => 'متوسط فرق السعر';

  @override
  String get aiSortByName => 'ترتيب بالاسم';

  @override
  String get aiSortByPriceDiff => 'ترتيب بفرق السعر';

  @override
  String get aiSortByOurPrice => 'ترتيب بسعرنا';

  @override
  String get aiSortByCategory => 'ترتيب بالتصنيف';

  @override
  String get aiSortLabel => 'ترتيب';

  @override
  String get aiPriceIndex => 'مؤشر السعر';

  @override
  String get aiQuality => 'الجودة';

  @override
  String get aiBranches => 'الفروع';

  @override
  String get aiMarkAllRead => 'تحديد الكل كمقروء';

  @override
  String get aiNoAlertsCurrently => 'لا توجد تنبيهات حالياً';

  @override
  String get aiFraudDetection => 'كشف الاحتيال بالذكاء الاصطناعي';

  @override
  String get aiTotalAlerts => 'إجمالي التنبيهات';

  @override
  String get aiCriticalAlerts => 'تنبيهات حرجة';

  @override
  String get aiNeedsReview => 'بحاجة مراجعة';

  @override
  String get aiRiskLevel => 'مستوى المخاطر';

  @override
  String get aiBehaviorScores => 'درجات السلوك';

  @override
  String get aiRiskMeter => 'مقياس المخاطر';

  @override
  String get aiHighRisk => 'مخاطر عالية';

  @override
  String get aiLowRisk => 'مخاطر منخفضة';

  @override
  String get aiPatternRefund => 'استرجاع';

  @override
  String get aiPatternAfterHours => 'بعد الدوام';

  @override
  String get aiPatternVoid => 'إلغاء';

  @override
  String get aiPatternDiscount => 'خصم';

  @override
  String get aiPatternSplit => 'تقسيم';

  @override
  String get aiPatternCashDrawer => 'درج نقد';

  @override
  String get aiNoFraudAlerts => 'لا توجد تنبيهات';

  @override
  String get aiSelectAlertToInvestigate => 'اختر تنبيهاً من القائمة للتحقيق';

  @override
  String get aiStaffAnalytics => 'تحليلات الموظفين';

  @override
  String get aiLeaderboard => 'لوحة الترتيب';

  @override
  String get aiIndividualPerformance => 'أداء فردي';

  @override
  String get aiAvgPerformance => 'متوسط الأداء';

  @override
  String get aiTotalSalesLabel => 'إجمالي المبيعات';

  @override
  String get aiTotalTransactions => 'إجمالي العمليات';

  @override
  String get aiAvgVoidRate => 'متوسط الإلغاء';

  @override
  String get aiTeamGrowth => 'نمو الفريق';

  @override
  String get aiLeaderboardThisWeek => 'لوحة الترتيب - هذا الأسبوع';

  @override
  String get aiSalesForecasting => 'توقع المبيعات';

  @override
  String get aiSmartForecastSubtitle => 'تحليل ذكي لتوقع المبيعات المستقبلية';

  @override
  String get aiForecastAccuracy => 'دقة التوقع';

  @override
  String get aiTrendUp => 'صاعد';

  @override
  String get aiTrendDown => 'هابط';

  @override
  String get aiTrendStable => 'مستقر';

  @override
  String get aiNextWeekForecast => 'توقع الأسبوع القادم';

  @override
  String get aiMonthForecast => 'توقع الشهر';

  @override
  String get aiForecastSummary => 'ملخص التوقعات';

  @override
  String get aiSalesTrendingUp => 'المبيعات في اتجاه صاعد - استمر!';

  @override
  String get aiSalesDeclining => 'المبيعات في انخفاض - فعّل العروض';

  @override
  String get aiSalesStable => 'المبيعات مستقرة - حافظ على الأداء';

  @override
  String get aiProductRecognition => 'التعرف على المنتجات';

  @override
  String get aiSingleProduct => 'منتج واحد';

  @override
  String get aiShelfScan => 'مسح الرف';

  @override
  String get aiBarcodeOcr => 'باركود OCR';

  @override
  String get aiPriceTag => 'بطاقة سعر';

  @override
  String get aiCameraArea => 'منطقة الكاميرا';

  @override
  String get aiPointCameraAtProduct => 'وجه الكاميرا نحو المنتج أو الرف';

  @override
  String get aiStartScan => 'بدء المسح';

  @override
  String get aiAnalyzingImage => 'جاري تحليل الصورة...';

  @override
  String get aiStartScanToSeeResults => 'ابدأ المسح لرؤية النتائج';

  @override
  String get aiScanResults => 'نتائج المسح';

  @override
  String get aiProductSaved => 'تم حفظ المنتج بنجاح';

  @override
  String get aiPromotionDesigner => 'مصمم العروض الذكي - AI';

  @override
  String get aiSuggestedPromotions => 'عروض مقترحة';

  @override
  String get aiRoiAnalysis => 'تحليل ROI';

  @override
  String get aiAbTest => 'اختبار A/B';

  @override
  String get aiSmartPromotionDesigner => 'مصمم العروض الذكي';

  @override
  String get aiProjectedRevenue => 'الإيرادات المتوقعة';

  @override
  String get aiAiConfidence => 'ثقة AI';

  @override
  String get aiSelectPromotionForRoi =>
      'اختر عرضاً من التبويب الأول لعرض تحليل ROI';

  @override
  String get aiRevenueLabel => 'الإيراد';

  @override
  String get aiCostLabel => 'التكلفة';

  @override
  String get aiDiscountLabel => 'الخصم';

  @override
  String get aiAbTestDescription =>
      'اختبار A/B يقسم عملاءك لمجموعتين ويعرض كل مجموعة عرضاً مختلفاً لتحديد الأفضل أداءً.';

  @override
  String get aiAbTestLaunched => 'تم إطلاق اختبار A/B بنجاح!';

  @override
  String get aiChatWithData => 'محادثة مع البيانات - AI';

  @override
  String get aiChatWithYourData => 'محادثة مع بياناتك';

  @override
  String get aiAskAboutDataInArabic =>
      'اسأل أي سؤال عن مبيعاتك ومخزونك وعملائك بالعربي';

  @override
  String get aiTrySampleQuestions => 'جرّب أحد هذه الأسئلة';

  @override
  String get aiTip => 'نصيحة';

  @override
  String get aiTipDescription =>
      'يمكنك السؤال بالعربي أو الإنجليزي. AI يفهم السياق ويختار أفضل طريقة لعرض النتائج: أرقام، جداول، أو رسوم بيانية.';

  @override
  String get loadingApp => 'جاري التحميل...';

  @override
  String get initializingSearch => 'تهيئة البحث...';

  @override
  String get loadingData => 'تحميل البيانات...';

  @override
  String get initializingDemoData => 'تهيئة البيانات التجريبية...';

  @override
  String get pointOfSale => 'نقاط البيع';

  @override
  String get managerPinSetup => 'إعداد رمز المشرف';

  @override
  String get confirmPin => 'تأكيد الرمز';

  @override
  String get createNewPin => 'إنشاء رمز جديد';

  @override
  String get reenterPinToConfirm => 'أعد إدخال الرمز للتأكيد';

  @override
  String get enterFourDigitPin => 'أدخل رمز PIN من 4 أرقام';

  @override
  String get pinsMismatch => 'الرمزان غير متطابقين';

  @override
  String get managerPinCreatedSuccess => 'تم إنشاء رمز المشرف بنجاح';

  @override
  String get enterManagerPin => 'أدخل رمز المشرف';

  @override
  String get operationRequiresApproval => 'هذه العملية تتطلب موافقة المشرف';

  @override
  String get approvalGranted => 'تمت الموافقة';

  @override
  String accountLockedWaitMinutes(int minutes) {
    return 'تم قفل الحساب. انتظر $minutes دقيقة';
  }

  @override
  String wrongPinAttemptsRemaining(int remaining) {
    return 'رمز خاطئ. المحاولات المتبقية: $remaining';
  }

  @override
  String get selectYourBranchToContinue => 'اختر فرعك للمتابعة';

  @override
  String get branchClosed => 'مغلق';

  @override
  String get noResultsFoundSearch => 'لا توجد نتائج';

  @override
  String branchSelectedMessage(String branchName) {
    return 'تم اختيار $branchName';
  }

  @override
  String get shiftIsClosed => 'الوردية مغلقة';

  @override
  String get noOpenShiftCurrently => 'لا توجد وردية مفتوحة حالياً';

  @override
  String get shiftIsOpen => 'الوردية مفتوحة';

  @override
  String shiftOpenSince(String time) {
    return 'منذ: $time';
  }

  @override
  String get balanceSummary => 'ملخص الرصيد';

  @override
  String get cashIncoming => 'النقد الوارد';

  @override
  String get cashOutgoing => 'النقد الصادر';

  @override
  String get expectedBalance => 'الرصيد المتوقع';

  @override
  String get noCashMovementsYet => 'لا توجد حركات نقدية بعد';

  @override
  String get noteLabel => 'ملاحظة';

  @override
  String get depositDone => 'تم الإيداع';

  @override
  String get withdrawalDone => 'تم السحب';

  @override
  String get amPeriod => 'ص';

  @override
  String get pmPeriod => 'م';

  @override
  String get newPurchaseInvoice => 'فاتورة شراء جديدة';

  @override
  String get supplierData => 'بيانات المورد';

  @override
  String get selectSupplierRequired => 'اختر المورد *';

  @override
  String get supplierInvoiceNumber => 'رقم فاتورة المورد';

  @override
  String get noProductsAddedYet => 'لم يتم إضافة منتجات بعد';

  @override
  String get paymentStatus => 'حالة الدفع';

  @override
  String get paidStatus => 'مدفوعة';

  @override
  String get deferredPayment => 'آجل';

  @override
  String get productNameRequired => 'اسم المنتج *';

  @override
  String get purchasePrice => 'سعر الشراء';

  @override
  String get pleaseSelectSupplier => 'يرجى اختيار المورد';

  @override
  String purchaseInvoiceSavedTotal(String total) {
    return 'تم حفظ فاتورة الشراء بإجمالي $total ر.س';
  }

  @override
  String get smartReorderAi => 'الطلب الذكي بالـ AI';

  @override
  String get smartReorderDescription =>
      'حدد ميزانيتك ودع الذكاء الاصطناعي يوزع المشتريات بأفضل طريقة';

  @override
  String get orderSettings => 'إعدادات الطلب';

  @override
  String get availableBudget => 'الميزانية المتاحة';

  @override
  String get enterAvailableAmount => 'أدخل المبلغ المتاح للشراء';

  @override
  String get supplierLabel => 'المورد';

  @override
  String get calculating => 'جاري الحساب...';

  @override
  String get calculateSmartDistribution => 'حساب التوزيع الذكي';

  @override
  String get setBudgetAndCalculate => 'حدد الميزانية واضغط حساب';

  @override
  String get numberOfProducts => 'عدد المنتجات';

  @override
  String get suggestedProducts => 'المنتجات المقترحة';

  @override
  String get sendOrder => 'إرسال الطلب';

  @override
  String get emailLabel => 'البريد';

  @override
  String get confirmSending => 'تأكيد الإرسال';

  @override
  String sendOrderToSupplier(String supplier) {
    return 'إرسال الطلب إلى $supplier؟';
  }

  @override
  String get orderSentSuccess => 'تم إرسال الطلب بنجاح';

  @override
  String turnoverRate(String rate) {
    return 'الدوران: $rate%';
  }

  @override
  String get editSupplier => 'تعديل المورد';

  @override
  String get addNewSupplier => 'إضافة مورد جديد';

  @override
  String get basicInfo => 'المعلومات الأساسية';

  @override
  String get supplierContactName => 'اسم المورد / جهة الاتصال *';

  @override
  String get companyNameRequired => 'اسم الشركة *';

  @override
  String get generalCategory => 'عام';

  @override
  String get foodMaterials => 'مواد غذائية';

  @override
  String get beverages => 'مشروبات';

  @override
  String get vegetablesFruits => 'خضروات وفواكه';

  @override
  String get equipment => 'معدات';

  @override
  String get contactInfo => 'معلومات التواصل';

  @override
  String get primaryPhoneRequired => 'رقم الهاتف الأساسي *';

  @override
  String get secondaryPhoneOptional => 'رقم هاتف ثانوي (اختياري)';

  @override
  String get emailField => 'البريد الإلكتروني';

  @override
  String get addressField2 => 'العنوان';

  @override
  String get commercialInfo => 'المعلومات التجارية';

  @override
  String get taxNumberVat => 'الرقم الضريبي (VAT)';

  @override
  String get commercialRegNumber => 'رقم السجل التجاري (CR)';

  @override
  String get financialInfo => 'المعلومات المالية';

  @override
  String get paymentTerms => 'شروط الدفع';

  @override
  String get payOnDelivery => 'الدفع عند الاستلام';

  @override
  String get sevenDays => '7 أيام';

  @override
  String get fourteenDays => '14 يوم';

  @override
  String get thirtyDays => '30 يوم';

  @override
  String get sixtyDays => '60 يوم';

  @override
  String get bankName => 'اسم البنك';

  @override
  String get ibanNumber => 'رقم الحساب IBAN';

  @override
  String get additionalSettings => 'إعدادات إضافية';

  @override
  String get supplierIsActive => 'المورد نشط';

  @override
  String get notesField => 'ملاحظات';

  @override
  String get savingData => 'جاري الحفظ...';

  @override
  String get updateSupplier => 'تحديث المورد';

  @override
  String get addSupplierBtn => 'إضافة المورد';

  @override
  String get deleteSupplier => 'حذف المورد';

  @override
  String get supplierUpdatedSuccess => 'تم تحديث بيانات المورد';

  @override
  String get supplierAddedSuccess => 'تم إضافة المورد بنجاح';

  @override
  String get supplierDeletedSuccess => 'تم حذف المورد';

  @override
  String get deleteSupplierConfirmTitle => 'حذف المورد';

  @override
  String get deleteSupplierConfirmMessage =>
      'هل أنت متأكد من حذف هذا المورد؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get supplierDetailsTitle => 'تفاصيل المورد';

  @override
  String get backButton => 'رجوع';

  @override
  String get editButton => 'تعديل';

  @override
  String get newPurchaseOrder => 'طلب شراء جديد';

  @override
  String get deleteButton => 'حذف';

  @override
  String get phoneLabel => 'الهاتف';

  @override
  String get supplierEmailLabel => 'البريد';

  @override
  String get supplierAddressLabel => 'العنوان';

  @override
  String get dueToSupplier => 'مستحق للمورد';

  @override
  String get balanceInOurFavor => 'رصيد لصالحنا';

  @override
  String get paymentBtn => 'سداد';

  @override
  String get totalPurchasesLabel => 'إجمالي المشتريات';

  @override
  String get lastPurchaseDate => 'آخر شراء';

  @override
  String get recentPurchases => 'آخر المشتريات';

  @override
  String get noPurchasesYet => 'لا توجد مشتريات';

  @override
  String get pendingLabel => 'معلق';

  @override
  String get deleteSupplierDialogTitle => 'حذف المورد';

  @override
  String get deleteSupplierDialogMessage =>
      'سيتم حذف جميع بيانات المورد. هل تريد المتابعة؟';

  @override
  String get unknownUser => 'غير معروف';

  @override
  String get employeeRole => 'موظف';

  @override
  String get operationCount => 'عملية';

  @override
  String get dayCount => 'يوم';

  @override
  String get personalInfoSection => 'المعلومات الشخصية';

  @override
  String get emailInfoLabel => 'البريد الإلكتروني';

  @override
  String get phoneInfoLabel => 'الهاتف';

  @override
  String get branchInfoLabel => 'الفرع';

  @override
  String get employeeIdLabel => 'الرقم الوظيفي';

  @override
  String get notSpecified => 'غير محدد';

  @override
  String get mainBranchDefault => 'الفرع الرئيسي';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get activityLogLink => 'سجل النشاط';

  @override
  String get logoutButton => 'تسجيل الخروج';

  @override
  String get systemAdminRole => 'مدير النظام';

  @override
  String get noBranchesRegistered => 'لا توجد فروع مسجلة';

  @override
  String get branchEmailLabel => 'البريد';

  @override
  String get branchCityLabel => 'المدينة';

  @override
  String get importSupplierInvoice => 'استيراد فاتورة المورد';

  @override
  String get captureOrSelectPhoto =>
      'التقط صورة أو اختر من المعرض\nسيتم استخراج البيانات تلقائياً';

  @override
  String get captureImage => 'التقاط صورة';

  @override
  String get galleryPick => 'المعرض';

  @override
  String get anotherImage => 'صورة أخرى';

  @override
  String get aiProcessingBtn => 'معالجة AI';

  @override
  String get processingInvoice => 'جاري معالجة الفاتورة...';

  @override
  String get extractingDataWithAi => 'يتم استخراج البيانات بالذكاء الاصطناعي';

  @override
  String get dataExtracted => 'تم استخراج البيانات';

  @override
  String get purchaseInvoiceCreated => 'تم إنشاء فاتورة الشراء';

  @override
  String get reviewInvoice => 'مراجعة الفاتورة';

  @override
  String get confirmAllItems => 'تأكيد الكل';

  @override
  String get unknownSupplier => 'مورد غير معروف';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصر',
      many: '$count عنصراً',
      few: '$count عناصر',
      two: 'عنصران',
      one: 'عنصر واحد',
      zero: 'لا توجد عناصر',
    );
    return '$_temp0';
  }

  @override
  String progressLabel(int confirmed, int total) {
    return 'التقدم: $confirmed / $total';
  }

  @override
  String needsReviewCount(int count) {
    return '$count يحتاج مراجعة';
  }

  @override
  String get notMatchedStatus => 'لم يتم المطابقة';

  @override
  String get matchedStatus => 'مطابقة';

  @override
  String get matchedProductLabel => 'منتج مطابق';

  @override
  String matchedWithName(String name) {
    return 'مطابقة: $name';
  }

  @override
  String get searchForProduct => 'بحث عن منتج...';

  @override
  String get createNewProduct => 'إنشاء منتج جديد';

  @override
  String get savingInvoice => 'جاري الحفظ...';

  @override
  String get invoiceSavedSuccess => 'تم حفظ فاتورة الشراء بنجاح';

  @override
  String get customerAnalytics => 'تحليل العملاء';

  @override
  String get weekPeriod => 'أسبوع';

  @override
  String get monthPeriod => 'شهر';

  @override
  String get yearPeriod => 'سنة';

  @override
  String get totalCustomers => 'إجمالي العملاء';

  @override
  String get newCustomers => 'عملاء جدد';

  @override
  String get returningCustomers => 'عملاء متكررون';

  @override
  String get averageSpending => 'متوسط الإنفاق';

  @override
  String get topCustomers => 'أفضل العملاء';

  @override
  String orderCount(int count) {
    return '$count طلب';
  }

  @override
  String get customerDistribution => 'توزيع العملاء';

  @override
  String get vipCustomers => 'VIP (أكثر من 5000 ر.س)';

  @override
  String get regularCustomers => 'منتظمين (1000-5000 ر.س)';

  @override
  String get normalCustomers => 'عاديين (أقل من 1000 ر.س)';

  @override
  String get customerActivity => 'نشاط العملاء';

  @override
  String get activeLabel => 'نشط';

  @override
  String get dormantLabel => 'خامل';

  @override
  String get inactiveLabel => 'غير نشط';

  @override
  String get noPrintJobsPending => 'لا توجد مهام طباعة معلقة';

  @override
  String get printerConnected => 'الطابعة متصلة';

  @override
  String get totalPrintLabel => 'إجمالي';

  @override
  String get waitingPrintLabel => 'في الانتظار';

  @override
  String get failedPrintLabel => 'فشلت';

  @override
  String pendingJobsCount(int count) {
    return '$count مهام معلقة';
  }

  @override
  String get printingInProgress => 'جاري الطباعة...';

  @override
  String get failedRetry => 'فشل - حاول مرة أخرى';

  @override
  String get waitingStatus => 'في الانتظار';

  @override
  String printingOrderId(String orderId) {
    return 'جاري طباعة $orderId...';
  }

  @override
  String get allJobsPrinted => 'تم طباعة جميع المهام';

  @override
  String get clearPrintQueueTitle => 'مسح قائمة الطباعة';

  @override
  String get clearPrintQueueConfirm => 'هل تريد مسح جميع مهام الطباعة المعلقة؟';

  @override
  String get clearBtn => 'مسح';

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
  String get lowStockLabel => 'منخفض';

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
  String get soldOut => 'نفد';

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
  String get now => 'الآن';

  @override
  String get ecommerce => 'المتجر الإلكتروني';

  @override
  String get ecommerceSection => 'التجارة الإلكترونية';

  @override
  String get wallet => 'المحفظة';

  @override
  String get subscription => 'الاشتراك';

  @override
  String get complaintsReport => 'تقرير الشكاوى';

  @override
  String get mediaLibrary => 'مكتبة الوسائط';

  @override
  String get deviceLog => 'سجل الأجهزة';

  @override
  String get shippingGateways => 'بوابات الشحن';

  @override
  String get systemSection => 'النظام';

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

  @override
  String get segmentVip => 'VIP';

  @override
  String get segmentRegular => 'منتظم';

  @override
  String get segmentAtRisk => 'معرض للخسارة';

  @override
  String get segmentLost => 'مفقود';

  @override
  String get segmentNewCustomer => 'جديد';

  @override
  String customerCount(int count) {
    return '$count عميل';
  }

  @override
  String revenueK(String amount) {
    return '${amount}K ر.س';
  }

  @override
  String get tabRecommendations => 'التوصيات';

  @override
  String get tabRepurchase => 'إعادة الشراء';

  @override
  String get tabSegments => 'الشرائح';

  @override
  String lastVisitLabel(String time) {
    return 'آخر زيارة: $time';
  }

  @override
  String visitCountLabel(int count) {
    return '$count زيارة';
  }

  @override
  String avgSpendLabel(String amount) {
    return 'متوسط: $amount ر.س';
  }

  @override
  String totalSpentLabel(String amount) {
    return 'إجمالي: ${amount}K ر.س';
  }

  @override
  String get recommendedProducts => 'المنتجات الموصى بها';

  @override
  String get sendWhatsAppOffer => 'إرسال عرض واتساب';

  @override
  String get totalRevenueLabel => 'إجمالي الإيراد';

  @override
  String get avgSpendStat => 'متوسط الإنفاق';

  @override
  String amountSar(String amount) {
    return '$amount ر.س';
  }

  @override
  String get specialOfferMissYou => 'عرض خاص لك! اشتقنا لزيارتك';

  @override
  String friendlyReminderPurchase(String product) {
    return 'تذكير ودي بموعد شراء $product';
  }

  @override
  String get timeAgoToday => 'اليوم';

  @override
  String get timeAgoYesterday => 'أمس';

  @override
  String timeAgoDays(int days) {
    return 'منذ $days يوم';
  }

  @override
  String get riskAnalysisTab => 'تحليل المخاطر';

  @override
  String get preventiveActionsTab => 'إجراءات وقائية';

  @override
  String errorOccurredDetail(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String get returnRateTitle => 'معدل الإرجاع';

  @override
  String get avgLast6Months => 'متوسط آخر 6 أشهر';

  @override
  String get amountAtRiskTitle => 'مبلغ معرض للخطر';

  @override
  String get highRiskOperations => 'عمليات عالية الخطر';

  @override
  String get needsImmediateAction => 'تحتاج تدخل فوري';

  @override
  String get returnTrendTitle => 'اتجاه المرتجعات';

  @override
  String operationsAtRiskCount(int count) {
    return 'العمليات المعرضة للإرجاع ($count)';
  }

  @override
  String get riskFilterAll => 'الكل';

  @override
  String get riskFilterVeryHigh => 'عالي جداً';

  @override
  String get riskFilterHigh => 'عالي';

  @override
  String get riskFilterMedium => 'متوسط';

  @override
  String get riskFilterLow => 'منخفض';

  @override
  String get totalExpectedSavings => 'إجمالي التوفير المتوقع';

  @override
  String fromPreventiveActions(int count) {
    return 'من $count إجراء وقائي';
  }

  @override
  String get suggestedPreventiveActions => 'الإجراءات الوقائية المقترحة';

  @override
  String get applyPreventiveHint =>
      'طبّق هذه الإجراءات لتقليل المرتجعات وزيادة رضا العملاء';

  @override
  String actionApplied(String action) {
    return 'تم تطبيق: $action';
  }

  @override
  String actionDismissed(String action) {
    return 'تم تجاهل: $action';
  }

  @override
  String get veryPositiveSentiment => 'إيجابي جداً';

  @override
  String get positiveSentiment => 'إيجابي';

  @override
  String get neutralSentiment => 'محايد';

  @override
  String get negativeSentiment => 'سلبي';

  @override
  String get veryNegativeSentiment => 'سلبي جداً';

  @override
  String get ratingsDistribution => 'توزيع التقييمات';

  @override
  String get sentimentTrendTitle => 'اتجاه المشاعر';

  @override
  String get sentimentIndicator => 'مؤشر المشاعر';

  @override
  String minutesAgoSentiment(int count) {
    return 'منذ $count دقيقة';
  }

  @override
  String hoursAgoSentiment(int count) {
    return 'منذ $count ساعة';
  }

  @override
  String daysAgoSentiment(int count) {
    return 'منذ $count يوم';
  }

  @override
  String get totalProductsTitle => 'إجمالي المنتجات';

  @override
  String get categoryATitle => 'فئة أ';

  @override
  String get mostImportant => 'الأكثر أهمية';

  @override
  String get withinDays => 'خلال 7 أيام';

  @override
  String get needReorder => 'بحاجة لطلب';

  @override
  String estimatedLossSar(String amount) {
    return '$amount ر.س خسائر متوقعة';
  }

  @override
  String get tabAbcAnalysis => 'تحليل ABC';

  @override
  String get tabWastePrediction => 'توقع الهدر';

  @override
  String get tabReorder => 'إعادة الطلب';

  @override
  String get filterAllLabel => 'الكل';

  @override
  String get categoryALabel => 'فئة أ';

  @override
  String get categoryBLabel => 'فئة ب';

  @override
  String get categoryCLabel => 'فئة ج';

  @override
  String orderUnitsSnack(int qty, String name) {
    return 'طلب $qty وحدة من $name';
  }

  @override
  String get urgencyCritical => 'حرج';

  @override
  String get urgencyHigh => 'عالي';

  @override
  String get urgencyMedium => 'متوسط';

  @override
  String get urgencyLow => 'منخفض';

  @override
  String get currentStockLabel => 'المخزون الحالي';

  @override
  String get reorderPointLabel => 'نقطة الطلب';

  @override
  String get suggestedQtyLabel => 'الكمية المقترحة';

  @override
  String get daysOfStockLabel => 'أيام المخزون';

  @override
  String estimatedCostLabel(String amount) {
    return 'التكلفة التقديرية: $amount ر.س';
  }

  @override
  String purchaseOrderCreatedFor(String name) {
    return 'تم إنشاء طلب شراء: $name';
  }

  @override
  String orderUnitsButton(int qty) {
    return 'طلب $qty وحدة';
  }

  @override
  String get actionDiscount => 'تخفيض';

  @override
  String get actionTransfer => 'نقل';

  @override
  String get actionDonate => 'تبرع';

  @override
  String actionOnProduct(String name) {
    return 'إجراء على: $name';
  }

  @override
  String get totalSuggestionsLabel => 'إجمالي الاقتراحات';

  @override
  String get canIncreaseLabel => 'يمكن زيادتها';

  @override
  String get shouldDecreaseLabel => 'يُنصح بخفضها';

  @override
  String get expectedMonthlyImpact => 'التأثير الشهري المتوقع';

  @override
  String get noSuggestionsInFilter => 'لا توجد اقتراحات في هذا الفلتر';

  @override
  String get selectProductForDetails => 'اختر منتجاً لعرض التفاصيل';

  @override
  String get selectProductHint =>
      'انقر على أحد المنتجات من القائمة لعرض حاسبة التأثير ومرونة الطلب';

  @override
  String priceApplied(String price, String product) {
    return 'تم تطبيق السعر $price ر.س على $product';
  }

  @override
  String errorOccurredShort(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String get readyTemplates => 'القوالب الجاهزة';

  @override
  String get hideTemplates => 'إخفاء القوالب';

  @override
  String get showTemplates => 'عرض القوالب';

  @override
  String get askAboutStore => 'اسأل أي سؤال عن متجرك';

  @override
  String get writeQuestionHint =>
      'اكتب سؤالك بالعربية وسنولد لك التقرير المناسب تلقائياً';

  @override
  String get quickActionTodaySales => 'كم مبيعات اليوم؟';

  @override
  String get quickActionTop10 => 'أفضل 10 منتجات';

  @override
  String get quickActionMonthlyCompare => 'مقارنة شهرية';

  @override
  String get analyzingData => 'جاري تحليل البيانات وتوليد التقرير...';

  @override
  String get profileScreenTitle => 'الملف الشخصي';

  @override
  String get unknownUserName => 'غير معروف';

  @override
  String get defaultEmployeeRole => 'موظف';

  @override
  String get transactionUnit => 'عملية';

  @override
  String get dayUnit => 'يوم';

  @override
  String get emailFieldLabel => 'البريد الإلكتروني';

  @override
  String get phoneFieldLabel => 'الهاتف';

  @override
  String get branchFieldLabel => 'الفرع';

  @override
  String get mainBranchName => 'الفرع الرئيسي';

  @override
  String get employeeNumberLabel => 'الرقم الوظيفي';

  @override
  String get changePasswordLabel => 'تغيير كلمة المرور';

  @override
  String get activityLogLabel => 'سجل النشاط';

  @override
  String get logoutDialogTitle => 'تسجيل الخروج';

  @override
  String get logoutDialogBody => 'هل تريد تسجيل الخروج من النظام؟';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get exitButton => 'خروج';

  @override
  String get editProfileSnack => 'تعديل الملف الشخصي';

  @override
  String get changePasswordSnack => 'تغيير كلمة المرور';

  @override
  String get roleAdmin => 'مدير النظام';

  @override
  String get roleManager => 'مدير';

  @override
  String get roleCashier => 'كاشير';

  @override
  String get roleEmployee => 'موظف';

  @override
  String get onboardingTitle1 => 'نقطة بيع سريعة';

  @override
  String get onboardingDesc1 =>
      'أتمم عمليات البيع بسرعة وسهولة مع واجهة بسيطة ومريحة';

  @override
  String get onboardingTitle2 => 'العمل بدون إنترنت';

  @override
  String get onboardingDesc2 =>
      'استمر في العمل حتى بدون اتصال، وستتم المزامنة تلقائياً';

  @override
  String get onboardingTitle3 => 'إدارة المخزون';

  @override
  String get onboardingDesc3 => 'تتبع مخزونك بدقة مع تنبيهات النقص والصلاحية';

  @override
  String get onboardingTitle4 => 'تقارير ذكية';

  @override
  String get onboardingDesc4 => 'احصل على تقارير مفصلة وتحليلات لأداء متجرك';

  @override
  String get startNow => 'ابدأ الآن';

  @override
  String get favorites => 'المفضلة';

  @override
  String get editMode => 'تعديل';

  @override
  String get doneMode => 'تم';

  @override
  String get errorLoadingFavorites => 'خطأ في تحميل المفضلة';

  @override
  String get noFavoriteProducts => 'لا توجد منتجات مفضلة';

  @override
  String get addFavoritesFromProducts => 'أضف منتجات للمفضلة من شاشة المنتجات';

  @override
  String get tapProductToAddToCart => 'اضغط على المنتج لإضافته للسلة';

  @override
  String addedProductToCart(String name) {
    return 'تمت إضافة $name للسلة';
  }

  @override
  String get addToCartAction => 'إضافة للسلة';

  @override
  String get removeFromFavorites => 'إزالة من المفضلة';

  @override
  String removedProductFromFavorites(String name) {
    return 'تمت إزالة $name من المفضلة';
  }

  @override
  String get paymentMethodTitle => 'طريقة الدفع';

  @override
  String get backEsc => 'رجوع (Esc)';

  @override
  String get completePayment => 'إتمام الدفع';

  @override
  String get enterToConfirm => 'Enter للتأكيد';

  @override
  String get cashOnlyOffline => 'نقد فقط في وضع عدم الاتصال';

  @override
  String get cardsDisabledInSettings => 'البطاقات معطلة من الاعدادات';

  @override
  String get creditPayment => 'آجل';

  @override
  String get unavailableOffline => 'غير متاح بدون اتصال';

  @override
  String get disabledInSettings => 'معطل من الاعدادات';

  @override
  String get amountReceived => 'المبلغ المستلم';

  @override
  String get quickAmounts => 'مبالغ سريعة';

  @override
  String get requiredAmount => 'المبلغ المطلوب';

  @override
  String get changeLabel => 'الباقي:';

  @override
  String get insufficientAmount => 'المبلغ غير كافي';

  @override
  String get rrnLabel => 'رقم مرجع العملية (RRN)';

  @override
  String get enterRrnFromDevice => 'أدخل رقم العملية من الجهاز';

  @override
  String get cardPaymentInstructions =>
      'اطلب من العميل الدفع عبر جهاز البطاقة، ثم أدخل رقم العملية (RRN) من الإيصال';

  @override
  String get creditSale => 'البيع الآجل';

  @override
  String get creditSaleWarning =>
      'سيتم تسجيل هذا المبلغ كدين على العميل. تأكد من تحديد العميل قبل إتمام العملية.';

  @override
  String get orderSummary => 'ملخص الطلب';

  @override
  String get taxLabel => 'الضريبة (15%)';

  @override
  String get discountLabel => 'الخصم';

  @override
  String get payCash => 'الدفع نقداً';

  @override
  String get payCard => 'الدفع بالبطاقة';

  @override
  String get payCreditSale => 'البيع الآجل';

  @override
  String get confirmPayment => 'تأكيد الدفع';

  @override
  String get processingPayment => 'جاري معالجة الدفع...';

  @override
  String get pleaseWait => 'يرجى الانتظار';

  @override
  String get paymentSuccessful => 'تمت العملية بنجاح!';

  @override
  String get printingReceipt => 'جاري طباعة الإيصال...';

  @override
  String get whatsappReceipt => 'إيصال واتساب';

  @override
  String get storeOrUserNotSet => 'لم يتم تحديد المتجر أو المستخدم';

  @override
  String errorWithMessage(String message) {
    return 'خطأ: $message';
  }

  @override
  String get receiptTitle => 'الإيصال';

  @override
  String get invoiceNotSpecified => 'لم يتم تحديد رقم الفاتورة';

  @override
  String get pendingSync => 'في انتظار المزامنة';

  @override
  String get notSynced => 'غير مزامنة';

  @override
  String receiptNumberLabel(String number) {
    return 'رقم: $number';
  }

  @override
  String get itemColumnHeader => 'الصنف';

  @override
  String get totalAmount => 'الإجمالي';

  @override
  String get paymentMethodField => 'طريقة الدفع';

  @override
  String get zatcaQrCode => 'رمز ZATCA الضريبي';

  @override
  String get whatsappSentLabel => 'تم الإرسال ✓';

  @override
  String get whatsappLabel => 'واتساب';

  @override
  String get whatsappReceiptSent => 'تم إرسال الإيصال عبر واتساب ✓';

  @override
  String whatsappSendFailed(String error) {
    return 'فشل الإرسال: $error';
  }

  @override
  String get cannotPrintNoInvoice => 'لا يمكن الطباعة - رقم الفاتورة غير متوفر';

  @override
  String get invoiceAddedToPrintQueue => 'تمت إضافة الفاتورة لقائمة الطباعة';

  @override
  String get mixedMethod => 'مختلط';

  @override
  String get creditMethod => 'آجل';

  @override
  String get walletMethod => 'محفظة';

  @override
  String get bankTransferMethod => 'تحويل بنكي';

  @override
  String get scanBarcodeHint => 'امسح الباركود أو أدخله (F1)';

  @override
  String get openCamera => 'فتح الكاميرا';

  @override
  String get searchProductHint => 'بحث عن منتج (F2)';

  @override
  String get hideCart => 'إخفاء السلة';

  @override
  String get showCart => 'إظهار السلة';

  @override
  String get cartTitle => 'السلة';

  @override
  String get clearAction => 'مسح';

  @override
  String get allCategories => 'الكل';

  @override
  String get otherCategory => 'أخرى';

  @override
  String get storeNotSet => 'لم يتم تحديد المتجر';

  @override
  String get retryAction => 'إعادة المحاولة';

  @override
  String get vatTax15 => 'ضريبة القيمة المضافة (15%)';

  @override
  String get totalGrand => 'الإجمالي';

  @override
  String get holdOrder => 'تعليق';

  @override
  String get payActionLabel => 'الدفع';

  @override
  String get f12QuickPay => 'F12 للدفع السريع';

  @override
  String productNotFoundBarcode(String barcode) {
    return 'لم يتم العثور على منتج بالباركود: $barcode';
  }

  @override
  String get clearCartTitle => 'مسح السلة';

  @override
  String get clearCartMessage => 'هل تريد مسح جميع المنتجات من السلة؟';

  @override
  String get orderOnHold => 'تم تعليق الطلب';

  @override
  String get deleteItem => 'حذف';

  @override
  String itemsCountPrice(int count, String price) {
    return '$count عنصر - $price ر.س';
  }

  @override
  String get taxReportTitle => 'تقرير الضرائب';

  @override
  String get exportReportAction => 'تصدير التقرير';

  @override
  String get printReportAction => 'طباعة التقرير';

  @override
  String get quarterly => 'ربع سنوي';

  @override
  String get netTaxDue => 'صافي الضريبة المستحقة';

  @override
  String get salesTaxCollected => 'ضريبة المبيعات';

  @override
  String get salesTaxSubtitle => 'المحصلة';

  @override
  String get purchasesTaxPaid => 'ضريبة المشتريات';

  @override
  String get purchasesTaxSubtitle => 'المدفوعة';

  @override
  String get taxByPaymentMethod => 'الضريبة حسب طريقة الدفع';

  @override
  String invoiceCount(int count) {
    return '$count فاتورة';
  }

  @override
  String get taxDetailsTitle => 'تفاصيل الضريبة';

  @override
  String get taxableSales => 'المبيعات الخاضعة للضريبة';

  @override
  String get salesTax15 => 'ضريبة المبيعات (15%)';

  @override
  String get taxablePurchases => 'المشتريات الخاضعة للضريبة';

  @override
  String get purchasesTax15 => 'ضريبة المشتريات (15%)';

  @override
  String get netTax => 'صافي الضريبة';

  @override
  String get zatcaReminder => 'تذكير ZATCA';

  @override
  String get zatcaDeadline => 'الموعد النهائي للإقرار: نهاية الشهر التالي';

  @override
  String get historyAction => 'السجل';

  @override
  String get sendToAuthority => 'إرسال للهيئة';

  @override
  String get cashPaymentMethod => 'نقدي';

  @override
  String get cardPaymentMethod => 'بطاقة';

  @override
  String get mixedPaymentMethod => 'مختلط';

  @override
  String get creditPaymentMethod => 'آجل';

  @override
  String get vatReportTitle => 'تقرير الضريبة (VAT)';

  @override
  String get selectPeriod => 'اختر الفترة';

  @override
  String get salesVat => 'ضريبة المبيعات';

  @override
  String get totalSalesIncVat => 'إجمالي المبيعات (شامل الضريبة)';

  @override
  String get vatCollected => 'ضريبة القيمة المضافة المحصلة';

  @override
  String get purchasesVat => 'ضريبة المشتريات';

  @override
  String get totalPurchasesIncVat => 'إجمالي المشتريات (شامل الضريبة)';

  @override
  String get vatPaid => 'ضريبة القيمة المضافة المدفوعة';

  @override
  String get netVatDue => 'صافي الضريبة المستحقة';

  @override
  String get dueToAuthority => 'مستحق للهيئة';

  @override
  String get dueFromAuthority => 'مستحق من الهيئة';

  @override
  String get exportingPdfReport => 'جاري تصدير التقرير...';

  @override
  String get debtsReportTitle => 'تقرير الديون';

  @override
  String get sortByLastPayment => 'حسب آخر دفعة';

  @override
  String get customersCount => 'عدد العملاء';

  @override
  String get noOutstandingDebts => 'لا توجد ديون مستحقة';

  @override
  String lastUpdate(String date) {
    return 'آخر تحديث: $date';
  }

  @override
  String get paymentAmountField => 'مبلغ الدفعة';

  @override
  String get recordAction => 'تسجيل';

  @override
  String get paymentRecordedMsg => 'تم تسجيل الدفعة';

  @override
  String showDetails(String name) {
    return 'عرض تفاصيل: $name';
  }

  @override
  String get debtsReportPdf => 'تقرير الديون';

  @override
  String dateFieldLabel(String date) {
    return 'التاريخ: $date';
  }

  @override
  String get debtsDetails => 'تفاصيل الديون:';

  @override
  String get customerCol => 'العميل';

  @override
  String get phoneCol => 'الهاتف';

  @override
  String get refundReceiptTitle => 'إيصال الإرجاع';

  @override
  String get noRefundId => 'لا يوجد معرّف إرجاع';

  @override
  String get refundNotFound => 'لم يتم العثور على بيانات الإرجاع';

  @override
  String get refundSuccessful => 'تم الإرجاع بنجاح';

  @override
  String refundNumberLabel(String number) {
    return 'رقم الإرجاع: $number';
  }

  @override
  String get refundReceipt => 'إيصال إرجاع';

  @override
  String get originalInvoiceNumber => 'رقم الفاتورة الأصلية';

  @override
  String get refundDate => 'تاريخ الإرجاع';

  @override
  String get refundMethodField => 'طريقة الاسترداد';

  @override
  String get returnedProducts => 'المنتجات المرتجعة';

  @override
  String get totalRefund => 'إجمالي الإرجاع';

  @override
  String get reasonLabel => 'السبب';

  @override
  String get homeAction => 'الرئيسية';

  @override
  String printError(String error) {
    return 'خطأ في الطباعة: $error';
  }

  @override
  String get damagedProduct => 'منتج تالف';

  @override
  String get wrongOrder => 'خطأ في الطلب';

  @override
  String get customerChangedMind => 'تغيير رأي العميل';

  @override
  String get expiredProduct => 'منتج منتهي الصلاحية';

  @override
  String get unsatisfactoryQuality => 'جودة غير مرضية';

  @override
  String get cashRefundMethod => 'نقدي';

  @override
  String get cardRefundMethod => 'بطاقة';

  @override
  String get walletRefundMethod => 'محفظة';

  @override
  String get refundReasonTitle => 'سبب الإرجاع';

  @override
  String get noRefundData =>
      'لا توجد بيانات إرجاع. يرجى العودة واختيار المنتجات.';

  @override
  String invoiceFieldLabel(String receiptNo) {
    return 'فاتورة: $receiptNo';
  }

  @override
  String productsCountAmount(int count, String amount) {
    return '$count منتج - $amount ر.س';
  }

  @override
  String get selectRefundReason => 'اختر سبب الإرجاع';

  @override
  String get additionalNotesOptional => 'ملاحظات إضافية (اختياري)';

  @override
  String get addNotesHint => 'أضف أي ملاحظات إضافية...';

  @override
  String get processingAction => 'جاري المعالجة...';

  @override
  String get nextSupervisorApproval => 'التالي - موافقة المشرف';

  @override
  String refundCreationError(String error) {
    return 'خطأ في إنشاء الإرجاع: $error';
  }

  @override
  String get refundRequestTitle => 'طلب إرجاع';

  @override
  String get invoiceNumberHint => 'رقم الفاتورة';

  @override
  String get searchAction => 'بحث';

  @override
  String get selectProductsForRefund => 'اختر المنتجات للإرجاع';

  @override
  String get selectAll => 'تحديد الكل';

  @override
  String quantityTimesPrice(int qty, String price) {
    return 'الكمية: $qty × $price ر.س';
  }

  @override
  String productsSelected(int count) {
    return '$count منتج محدد';
  }

  @override
  String refundAmountValue(String amount) {
    return 'المبلغ: $amount ر.س';
  }

  @override
  String get nextAction => 'التالي';

  @override
  String get enterInvoiceToSearch => 'أدخل رقم الفاتورة للبحث';

  @override
  String get invoiceNotFoundMsg => 'لم يتم العثور على الفاتورة';

  @override
  String get shippingGatewaysTitle => 'بوابات الشحن';

  @override
  String get availableShippingGateways => 'بوابات الشحن المتاحة';

  @override
  String get activateShippingGateways =>
      'قم بتفعيل وإعداد بوابات الشحن لتوصيل الطلبات';

  @override
  String get aramexName => 'أرامكس';

  @override
  String get aramexDesc => 'شركة شحن عالمية بخدمات متعددة';

  @override
  String get smsaDesc => 'شحن سريع داخل المملكة';

  @override
  String get fastloName => 'فاستلو';

  @override
  String get fastloDesc => 'توصيل سريع في نفس اليوم';

  @override
  String get dhlDesc => 'شحن دولي سريع وموثوق';

  @override
  String get jtDesc => 'شحن اقتصادي';

  @override
  String get customDeliveryName => 'توصيل خاص';

  @override
  String get customDeliveryDesc => 'إدارة التوصيل بسائقيك الخاصين';

  @override
  String get settingsAction => 'إعدادات';

  @override
  String get hourlyView => 'ساعي';

  @override
  String get dailyView => 'يومي';

  @override
  String get peakHourLabel => 'ساعة الذروة';

  @override
  String transactionsWithCount(int count) {
    return '$count معاملة';
  }

  @override
  String get peakDayLabel => 'يوم الذروة';

  @override
  String get avgPerHour => 'متوسط/ساعة';

  @override
  String get transactionWord => 'معاملة';

  @override
  String get transactionsByHour => 'المعاملات حسب الساعة';

  @override
  String get transactionsByDay => 'المعاملات حسب اليوم';

  @override
  String get activityHeatmap => 'خريطة النشاط الحراري';

  @override
  String get lowLabel => 'منخفض';

  @override
  String get highLabel => 'عالي';

  @override
  String get analysisRecommendations => 'توصيات بناءً على التحليل';

  @override
  String get staffRecommendation => 'الموظفين';

  @override
  String get staffRecommendationDesc =>
      'زيادة عدد الكاشير في الفترة 12:00-13:00 و 17:00-19:00 (ذروة المبيعات)';

  @override
  String get offersRecommendation => 'العروض';

  @override
  String get offersRecommendationDesc =>
      'تقديم عروض خاصة في الفترة 14:00-16:00 لزيادة المبيعات في الفترة الهادئة';

  @override
  String get inventoryRecommendation => 'المخزون';

  @override
  String get inventoryRecommendationDesc =>
      'تجهيز المخزون قبل يومي الخميس والجمعة (أعلى أيام المبيعات)';

  @override
  String get shiftsRecommendation => 'الورديات';

  @override
  String get shiftsRecommendationDesc =>
      'توزيع الورديات: صباحية 8-15، مسائية 15-22 مع تداخل في الذروة';

  @override
  String get topProductsTab => 'أفضل المنتجات';

  @override
  String get byCategoryTab => 'حسب الفئة';

  @override
  String get performanceAnalysisTab => 'تحليل الأداء';

  @override
  String get noSalesDataForPeriod => 'لا توجد بيانات مبيعات للفترة المحددة';

  @override
  String get categoryFilter => 'الفئة';

  @override
  String get allCategoriesFilter => 'جميع الفئات';

  @override
  String get sortByField => 'ترتيب حسب';

  @override
  String get revenueSort => 'الإيرادات';

  @override
  String get unitsSort => 'الوحدات';

  @override
  String get profitSort => 'الأرباح';

  @override
  String get revenueLabel => 'الإيرادات';

  @override
  String get unitsLabel => 'الوحدات';

  @override
  String get profitLabel => 'الربح';

  @override
  String get stockLabel => 'المخزون';

  @override
  String get revenueByCategoryTitle => 'توزيع الإيرادات حسب الفئة';

  @override
  String get noRevenueForPeriod => 'لا توجد إيرادات في هذه الفترة';

  @override
  String get unclassified => 'غير مصنف';

  @override
  String get productUnit => 'منتج';

  @override
  String get unitsSoldUnit => 'وحدة';

  @override
  String get totalRevenueKpi => 'إجمالي الإيرادات';

  @override
  String get unitsSoldKpi => 'الوحدات المباعة';

  @override
  String get totalProfitKpi => 'إجمالي الربح';

  @override
  String get profitMarginKpi => 'هامش الربح';

  @override
  String get performanceOverview => 'نظرة عامة على الأداء';

  @override
  String get trendingUpProducts => 'منتجات متصاعدة';

  @override
  String get stableProducts => 'منتجات مستقرة';

  @override
  String get trendingDownProducts => 'منتجات متراجعة';

  @override
  String noSalesProducts(int count) {
    return 'منتجات بدون مبيعات ($count)';
  }

  @override
  String inStockCount(int count) {
    return '$count في المخزون';
  }

  @override
  String get slowMovingLabel => 'بطيء';

  @override
  String needsReorder(int count) {
    return 'تحتاج إعادة طلب ($count)';
  }

  @override
  String soldUnitsStock(int sold, int stock) {
    return 'بيع: $sold وحدة | مخزون: $stock';
  }

  @override
  String get reorderLabel => 'أعد الطلب';

  @override
  String get totalComplaintsLabel => 'إجمالي الشكاوى';

  @override
  String get openComplaints => 'مفتوحة';

  @override
  String get closedComplaints => 'مغلقة';

  @override
  String get avgResolutionTime => 'متوسط وقت الحل';

  @override
  String daysUnit(String count) {
    return '$count يوم';
  }

  @override
  String get fromDate => 'من تاريخ';

  @override
  String get toDate => 'إلى تاريخ';

  @override
  String get statusFilter => 'الحالة';

  @override
  String get departmentFilter => 'القسم';

  @override
  String get paymentDepartment => 'الدفع';

  @override
  String get technicalDepartment => 'تقني';

  @override
  String get otherDepartment => 'أخرى';

  @override
  String get noComplaintsRecorded => 'لم يتم تسجيل أي شكاوى حتى الآن';

  @override
  String get overviewTab => 'نظرة عامة';

  @override
  String get topCustomersTab => 'أفضل العملاء';

  @override
  String get growthAnalysisTab => 'تحليل النمو';

  @override
  String get loyaltyTab => 'الولاء';

  @override
  String get totalCustomersLabel => 'إجمالي العملاء';

  @override
  String get activeCustomersLabel => 'عملاء نشطين';

  @override
  String get avgOrderValueLabel => 'متوسط قيمة الطلب';

  @override
  String get tierDistribution => 'توزيع العملاء حسب المستوى';

  @override
  String get activitySummary => 'ملخص النشاط';

  @override
  String get totalRevenueFromCustomers =>
      'إجمالي الإيرادات من العملاء المسجلين';

  @override
  String get avgOrderPerCustomer => 'متوسط قيمة الطلب لكل عميل';

  @override
  String get activeCustomersLast30 => 'عملاء نشطين (آخر 30 يوم)';

  @override
  String get newCustomersLast30 => 'عملاء جدد (آخر 30 يوم)';

  @override
  String topCustomersTitle(int count) {
    return 'أفضل $count عملاء';
  }

  @override
  String get bySpending => 'حسب الإنفاق';

  @override
  String get byOrders => 'حسب الطلبات';

  @override
  String get byPoints => 'حسب النقاط';

  @override
  String ordersCount(int count) {
    return '$count طلب';
  }

  @override
  String get avgOrderStat => 'متوسط الطلب';

  @override
  String get loyaltyPointsStat => 'نقاط الولاء';

  @override
  String get lastOrderStat => 'آخر طلب';

  @override
  String get newCustomerGrowth => 'نمو العملاء الجدد';

  @override
  String get customerRetentionRate => 'معدل الاحتفاظ بالعملاء';

  @override
  String get monthlyPeriod => 'شهري';

  @override
  String get totalCustomersPeriod => 'إجمالي العملاء';

  @override
  String get activePeriod => 'نشطين';

  @override
  String get activeCustomersInfo => 'العملاء النشطين: من اشترى خلال آخر 30 يوم';

  @override
  String get cohortAnalysis => 'تحليل Cohort (مجموعات العملاء)';

  @override
  String get cohortDescription => 'نسبة العودة للشراء بعد الشراء الأول';

  @override
  String get cohortGroup => 'المجموعة';

  @override
  String get month1 => 'شهر 1';

  @override
  String get month2 => 'شهر 2';

  @override
  String get month3 => 'شهر 3';

  @override
  String get loyaltyProgramStats => 'إحصائيات برنامج الولاء';

  @override
  String get totalPointsGranted => 'إجمالي النقاط الممنوحة';

  @override
  String get remainingPoints => 'النقاط المتبقية';

  @override
  String get pointsValue => 'قيمة النقاط';

  @override
  String get pointsByTier => 'توزيع النقاط حسب المستوى';

  @override
  String get pointsUnit => 'نقطة';

  @override
  String get redemptionPatterns => 'أنماط استبدال النقاط';

  @override
  String get purchaseDiscount => 'خصم على المشتريات';

  @override
  String get freeProducts => 'منتجات مجانية';

  @override
  String get couponsLabel => 'كوبونات';

  @override
  String get diamondTier => 'ماسي';

  @override
  String get goldTier => 'ذهبي';

  @override
  String get silverTier => 'فضي';

  @override
  String get bronzeTier => 'برونزي';

  @override
  String get todayDate => 'اليوم';

  @override
  String get yesterdayDate => 'أمس';

  @override
  String daysCountLabel(int count) {
    return '$count يوم';
  }

  @override
  String ofTotalLabel(String active, String total) {
    return '$active من $total';
  }

  @override
  String get exportingReportMsg => 'جاري تصدير التقرير...';

  @override
  String get januaryMonth => 'يناير';

  @override
  String get februaryMonth => 'فبراير';

  @override
  String get marchMonth => 'مارس';

  @override
  String get aprilMonth => 'أبريل';

  @override
  String get mayMonth => 'مايو';

  @override
  String get juneMonth => 'يونيو';

  @override
  String errorLabel(String error) {
    return 'خطأ: $error';
  }

  @override
  String get saturdayDay => 'السبت';

  @override
  String get sundayDay => 'الأحد';

  @override
  String get mondayDay => 'الاثنين';

  @override
  String get tuesdayDay => 'الثلاثاء';

  @override
  String get wednesdayDay => 'الأربعاء';

  @override
  String get thursdayDay => 'الخميس';

  @override
  String get fridayDay => 'الجمعة';

  @override
  String get satShort => 'سبت';

  @override
  String get sunShort => 'أحد';

  @override
  String get monShort => 'اثن';

  @override
  String get tueShort => 'ثلا';

  @override
  String get wedShort => 'أرب';

  @override
  String get thuShort => 'خمي';

  @override
  String get friShort => 'جمع';

  @override
  String get errorLoadingVatReport => 'حدث خطأ في تحميل تقرير الضريبة';

  @override
  String get errorLoadingComplaints => 'حدث خطأ في تحميل الشكاوى';

  @override
  String get errorLoadingCustomerReport => 'حدث خطأ في تحميل تقرير العملاء';

  @override
  String get reprintReceipt => 'إعادة طباعة الفاتورة';

  @override
  String get searchByInvoiceOrCustomer => 'بحث برقم الفاتورة أو اسم العميل...';

  @override
  String get selectInvoiceToPrint => 'اختر فاتورة لإعادة الطباعة';

  @override
  String get receiptPreview => 'معاينة الفاتورة';

  @override
  String get receiptPrinted => 'تمت طباعة الفاتورة بنجاح';

  @override
  String get refunded => 'مسترجع';

  @override
  String get cashMovement => 'حركة نقدية';

  @override
  String get movementType => 'نوع الحركة';

  @override
  String get reasonHint => 'أدخل السبب...';

  @override
  String get bankDeposit => 'إيداع بنكي';

  @override
  String get bankWithdrawal => 'سحب بنكي';

  @override
  String get changeForDrawer => 'فكة للدرج';

  @override
  String get confirmDeposit => 'تأكيد الإيداع';

  @override
  String get confirmWithdrawal => 'تأكيد السحب';

  @override
  String get dailySummary => 'ملخص اليوم';

  @override
  String get netRevenue => 'صافي الإيرادات';

  @override
  String get afterRefunds => 'بعد المرتجعات';

  @override
  String get shiftsCount => 'عدد الورديات';

  @override
  String get todayShifts => 'ورديات اليوم';

  @override
  String get ongoing => 'جارية';

  @override
  String get confirmOrder => 'تأكيد الطلب';

  @override
  String get orderNow => 'اطلب الآن';

  @override
  String get orderCart => 'سلة الطلب';

  @override
  String get orderReceived => 'تم استلام طلبك!';

  @override
  String get orderBeingPrepared => 'سيتم تحضير طلبك في أقرب وقت ممكن';

  @override
  String get redirectingToHome => 'سيتم الانتقال للصفحة الرئيسية تلقائياً...';

  @override
  String get kioskOrderNote => 'طلب كشك';

  @override
  String pricePerUnit(String price) {
    return '$price ر.س للوحدة';
  }

  @override
  String get selectFromMenu => 'اختر من القائمة';

  @override
  String orderCartWithCount(int count) {
    return 'سلة الطلب ($count صنف)';
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
  String get applyCoupon => 'تطبيق كوبون';

  @override
  String get enterCouponCode => 'أدخل كود الكوبون';

  @override
  String get invalidCoupon => 'كوبون غير صالح أو غير موجود';

  @override
  String get couponExpired => 'انتهت صلاحية الكوبون';

  @override
  String minimumPurchaseRequired(String amount) {
    return 'الحد الأدنى $amount ريال';
  }

  @override
  String couponDiscountApplied(String amount) {
    return 'تم خصم $amount ريال';
  }

  @override
  String get couponInvalid => 'كوبون غير صالح';

  @override
  String get customerAddFailed => 'فشل في إضافة العميل';

  @override
  String get quantityColon => 'الكمية:';

  @override
  String get riyal => 'ريال';

  @override
  String get mobileNumber => 'رقم الجوال';

  @override
  String get banknotes => 'أوراق نقدية';

  @override
  String get coins => 'عملات معدنية';

  @override
  String get totalAmountLabel => 'إجمالي المبلغ';

  @override
  String denominationRiyal(String amount) {
    return '$amount ريال';
  }

  @override
  String denominationHalala(String amount) {
    return '$amount هللة';
  }

  @override
  String get countCurrency => 'عد العملات';

  @override
  String confirmAmountSar(String amount) {
    return 'تأكيد: $amount ر.س';
  }

  @override
  String amountRiyal(String amount) {
    return '$amount ريال';
  }

  @override
  String get itemDeletedMsg => 'تم الحذف';

  @override
  String get pressBackAgainToExit => 'اضغط مرة أخرى للخروج';

  @override
  String get deleteHeldInvoiceConfirm => 'حذف هذه الفاتورة المعلقة؟';
}
