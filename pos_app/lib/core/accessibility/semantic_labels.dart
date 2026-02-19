/// Semantic Labels - تسميات دلالية للـ Accessibility
///
/// يوفر:
/// - تسميات عربية واضحة لجميع العناصر
/// - دعم قارئات الشاشة
/// - تحسين تجربة ذوي الاحتياجات الخاصة
library semantic_labels;

// ============================================================================
// NAVIGATION LABELS
// ============================================================================

/// تسميات التنقل
abstract class NavigationLabels {
  /// الشاشة الرئيسية
  static const String home = 'الشاشة الرئيسية';

  /// نقطة البيع
  static const String pos = 'شاشة نقطة البيع';

  /// المنتجات
  static const String products = 'قائمة المنتجات';

  /// المخزون
  static const String inventory = 'إدارة المخزون';

  /// التقارير
  static const String reports = 'التقارير والإحصائيات';

  /// الإعدادات
  static const String settings = 'إعدادات التطبيق';

  /// تسجيل الخروج
  static const String logout = 'تسجيل الخروج من الحساب';

  /// رجوع
  static const String back = 'رجوع للصفحة السابقة';

  /// إغلاق
  static const String close = 'إغلاق';

  /// القائمة الجانبية
  static const String drawer = 'القائمة الجانبية';
}

// ============================================================================
// POS LABELS
// ============================================================================

/// تسميات نقطة البيع
abstract class POSLabels {
  /// البحث عن منتج
  static const String searchProduct = 'البحث عن منتج بالاسم أو الباركود';

  /// ماسح الباركود
  static const String barcodeScanner = 'فتح ماسح الباركود';

  /// إضافة للسلة
  static String addToCart(String productName) =>
    'إضافة $productName إلى السلة';

  /// إزالة من السلة
  static String removeFromCart(String productName) =>
    'إزالة $productName من السلة';

  /// زيادة الكمية
  static String increaseQuantity(String productName, int currentQty) =>
    'زيادة كمية $productName، الكمية الحالية $currentQty';

  /// تقليل الكمية
  static String decreaseQuantity(String productName, int currentQty) =>
    'تقليل كمية $productName، الكمية الحالية $currentQty';

  /// سعر المنتج
  static String productPrice(double price) =>
    'السعر ${price.toStringAsFixed(2)} ريال';

  /// الكمية المتاحة
  static String availableStock(int qty) =>
    'الكمية المتاحة $qty قطعة';

  /// السلة
  static const String cart = 'سلة المشتريات';

  /// السلة فارغة
  static const String emptyCart = 'السلة فارغة، أضف منتجات للبدء';

  /// إجمالي السلة
  static String cartTotal(double total, int itemCount) =>
    'إجمالي السلة ${total.toStringAsFixed(2)} ريال، $itemCount منتج';

  /// إفراغ السلة
  static const String clearCart = 'إفراغ السلة بالكامل';

  /// تعليق الفاتورة
  static const String holdInvoice = 'تعليق الفاتورة للاستلام لاحقاً';

  /// استرجاع فاتورة
  static const String retrieveInvoice = 'استرجاع فاتورة معلقة';

  /// الدفع
  static const String checkout = 'الانتقال للدفع';

  /// اختيار طريقة الدفع
  static const String selectPaymentMethod = 'اختيار طريقة الدفع';

  /// نقدي
  static const String cash = 'الدفع نقداً';

  /// بطاقة
  static const String card = 'الدفع بالبطاقة';

  /// مدى
  static const String mada = 'الدفع ببطاقة مدى';

  /// تأكيد الدفع
  static String confirmPayment(double amount) =>
    'تأكيد الدفع بمبلغ ${amount.toStringAsFixed(2)} ريال';

  /// طباعة الفاتورة
  static const String printReceipt = 'طباعة الفاتورة';

  /// فاتورة جديدة
  static const String newSale = 'بدء فاتورة جديدة';
}

// ============================================================================
// PRODUCT LABELS
// ============================================================================

/// تسميات المنتجات
abstract class ProductLabels {
  /// بطاقة المنتج
  static String productCard(String name, double price) =>
    '$name، السعر ${price.toStringAsFixed(2)} ريال';

  /// صورة المنتج
  static String productImage(String name) => 'صورة $name';

  /// لا توجد صورة
  static String noImage(String name) => '$name، لا توجد صورة';

  /// فئة المنتج
  static String category(String categoryName) => 'الفئة: $categoryName';

  /// نفد من المخزون
  static const String outOfStock = 'نفد من المخزون';

  /// كمية منخفضة
  static String lowStock(int qty) => 'كمية منخفضة، متبقي $qty فقط';

  /// تحرير المنتج
  static String editProduct(String name) => 'تحرير بيانات $name';

  /// حذف المنتج
  static String deleteProduct(String name) => 'حذف $name';
}

// ============================================================================
// FORM LABELS
// ============================================================================

/// تسميات النماذج
abstract class FormLabels {
  /// حقل الاسم
  static const String nameField = 'حقل الاسم، مطلوب';

  /// حقل السعر
  static const String priceField = 'حقل السعر بالريال، مطلوب';

  /// حقل الكمية
  static const String quantityField = 'حقل الكمية، مطلوب';

  /// حقل الباركود
  static const String barcodeField = 'حقل الباركود، اختياري';

  /// حقل الوصف
  static const String descriptionField = 'حقل الوصف، اختياري';

  /// حقل البحث
  static const String searchField = 'حقل البحث';

  /// زر الحفظ
  static const String saveButton = 'حفظ التغييرات';

  /// زر الإلغاء
  static const String cancelButton = 'إلغاء والعودة';

  /// زر الحذف
  static const String deleteButton = 'حذف نهائي';

  /// خطأ في الحقل
  static String fieldError(String error) => 'خطأ: $error';

  /// حقل مطلوب
  static const String requiredField = 'هذا الحقل مطلوب';
}

// ============================================================================
// DIALOG LABELS
// ============================================================================

/// تسميات الحوارات
abstract class DialogLabels {
  /// تأكيد
  static const String confirm = 'تأكيد';

  /// إلغاء
  static const String cancel = 'إلغاء';

  /// موافق
  static const String ok = 'موافق';

  /// نعم
  static const String yes = 'نعم';

  /// لا
  static const String no = 'لا';

  /// تحذير
  static const String warning = 'تحذير';

  /// خطأ
  static const String error = 'خطأ';

  /// نجاح
  static const String success = 'تمت العملية بنجاح';

  /// تحميل
  static const String loading = 'جاري التحميل، يرجى الانتظار';

  /// تأكيد الحذف
  static String confirmDelete(String item) =>
    'هل أنت متأكد من حذف $item؟ لا يمكن التراجع عن هذا الإجراء';

  /// تأكيد الخروج
  static const String confirmExit =
    'هل أنت متأكد من تسجيل الخروج؟';
}

// ============================================================================
// STATUS LABELS
// ============================================================================

/// تسميات الحالات
abstract class StatusLabels {
  /// متصل بالإنترنت
  static const String online = 'متصل بالإنترنت';

  /// غير متصل
  static const String offline = 'غير متصل بالإنترنت';

  /// جاري المزامنة
  static String syncing(int count) =>
    'جاري مزامنة $count عملية';

  /// عمليات معلقة
  static String pendingSync(int count) =>
    '$count عملية في انتظار المزامنة';

  /// تم المزامنة
  static const String synced = 'تم المزامنة';

  /// فشلت المزامنة
  static const String syncFailed = 'فشلت المزامنة، سيتم إعادة المحاولة';

  /// الذاكرة منخفضة
  static const String lowMemory = 'الذاكرة منخفضة، جاري التنظيف';
}

// ============================================================================
// REPORT LABELS
// ============================================================================

/// تسميات التقارير
abstract class ReportLabels {
  /// مبيعات اليوم
  static String todaySales(double total, int count) =>
    'مبيعات اليوم ${total.toStringAsFixed(2)} ريال من $count عملية';

  /// أفضل المنتجات
  static const String topProducts = 'قائمة أفضل المنتجات مبيعاً';

  /// تصدير التقرير
  static const String exportReport = 'تصدير التقرير';

  /// طباعة التقرير
  static const String printReport = 'طباعة التقرير';

  /// اختيار الفترة
  static const String selectPeriod = 'اختيار الفترة الزمنية للتقرير';
}

// ============================================================================
// CUSTOMER LABELS
// ============================================================================

/// تسميات العملاء
abstract class CustomerLabels {
  /// اختيار عميل
  static const String selectCustomer = 'اختيار عميل';

  /// عميل افتراضي
  static const String defaultCustomer = 'عميل افتراضي، بدون تسجيل';

  /// إضافة عميل جديد
  static const String addCustomer = 'إضافة عميل جديد';

  /// رقم الجوال
  static const String phoneField = 'رقم جوال العميل';

  /// نقاط الولاء
  static String loyaltyPoints(int points) =>
    'نقاط الولاء: $points نقطة';

  /// مستوى العميل
  static String customerLevel(String level) => 'المستوى: $level';
}

// ============================================================================
// ACCESSIBILITY HINTS
// ============================================================================

/// تلميحات إضافية
abstract class AccessibilityHints {
  /// انقر مرتين للتفعيل
  static const String doubleTapToActivate = 'انقر مرتين للتفعيل';

  /// اسحب لليمين للخيارات
  static const String swipeRightForOptions = 'اسحب لليمين لعرض الخيارات';

  /// اسحب لليسار للحذف
  static const String swipeLeftToDelete = 'اسحب لليسار للحذف';

  /// انقر مطولاً للخيارات
  static const String longPressForOptions = 'انقر مطولاً لعرض الخيارات';

  /// استخدم زر الصوت لتغيير الكمية
  static const String volumeToChangeQty = 'استخدم أزرار الصوت لتغيير الكمية';
}
