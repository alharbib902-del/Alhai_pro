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
  String get total => 'الإجمالي';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get discount => 'الخصم';

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
  String get outOfStock => 'نفذ المخزون';

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
    return '$count فرع';
  }

  @override
  String branchSelected(String name) {
    return 'تم اختيار $name';
  }

  @override
  String get addBranch => 'إضافة فرع جديد';

  @override
  String get comingSoon => 'سيتم إضافة هذه الميزة قريباً';

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
    return '$count طلب اليوم';
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
  String get pending => 'قيد الانتظار';

  @override
  String get cancelled => 'ملغي';

  @override
  String get guestCustomer => 'عميل زائر';

  @override
  String minutesAgo(int count) {
    return 'منذ $count دقائق';
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
  String get productNotFound => 'المنتج غير موجود';

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
  String get sortByName => 'الاسم';

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
    return 'منذ $count ساعة';
  }

  @override
  String daysAgo(int count) {
    return 'منذ $count يوم';
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
    return '$count تصنيف';
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
    return '$count فاتورة بانتظار الدفع';
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
  String get cashPayment => 'نقداً';

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
  String get exportPdf => 'PDF';

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
    return 'تم تحديد $count';
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
  String get otherReason => 'أخرى';

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
  String get invoiceNumberLabel => 'رقم:';

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
  String get storeName => 'سوبرماركت الحي';

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
  String get adjustmentType => 'نوع التسوية';

  @override
  String get debitAdjustment => 'تسوية مدينة';

  @override
  String get creditAdjustment => 'تسوية دائنة';

  @override
  String get adjustmentAmount => 'مبلغ التسوية';

  @override
  String get adjustmentReason => 'سبب التسوية';

  @override
  String get adjustmentDate => 'تاريخ التسوية';

  @override
  String get saveAdjustment => 'حفظ التسوية';

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
  String get customerLabel => 'العميل';

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
  String get invoiceNotFound => 'لم يتم العثور على الفاتورة';

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
  String customerCount(String count) {
    return '$count عميل';
  }

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
  String get customerAddedSuccess => 'تم إضافة العميل بنجاح';

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
  String get cashierName => 'الكاشير';

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
  String get qrCodeOnInvoice => 'رمز QR على الفاتورة';

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
}
