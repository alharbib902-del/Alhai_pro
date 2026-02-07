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
  String get branchManager => 'مدير الفرع';

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
}
