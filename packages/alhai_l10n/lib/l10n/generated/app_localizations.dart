import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fil.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('en'),
    Locale('fil'),
    Locale('hi'),
    Locale('id'),
    Locale('ur')
  ];

  /// Warning on receipt widget when store taxNumber is null, empty, or fails VAT format validation
  ///
  /// In ar, this message translates to:
  /// **'الرقم الضريبي غير مُعدّ'**
  String get vatNumberMissing;

  /// اسم التطبيق
  ///
  /// In ar, this message translates to:
  /// **'نظام نقاط البيع'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @welcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً'**
  String get welcome;

  /// No description provided for @welcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بعودتك'**
  String get welcomeBack;

  /// No description provided for @phone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get phone;

  /// No description provided for @phoneHint.
  ///
  /// In ar, this message translates to:
  /// **'05xxxxxxxx'**
  String get phoneHint;

  /// No description provided for @phoneRequired.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال مطلوب'**
  String get phoneRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال غير صحيح'**
  String get phoneInvalid;

  /// No description provided for @otp.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق'**
  String get otp;

  /// No description provided for @otpHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز التحقق'**
  String get otpHint;

  /// No description provided for @otpSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رمز التحقق'**
  String get otpSent;

  /// No description provided for @otpResend.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get otpResend;

  /// No description provided for @otpExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت صلاحية رمز التحقق'**
  String get otpExpired;

  /// No description provided for @otpInvalid.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق غير صحيح'**
  String get otpInvalid;

  /// No description provided for @otpResendIn.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال خلال {seconds} ثانية'**
  String otpResendIn(int seconds);

  /// No description provided for @pin.
  ///
  /// In ar, this message translates to:
  /// **'رمز PIN'**
  String get pin;

  /// No description provided for @pinHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز PIN'**
  String get pinHint;

  /// No description provided for @pinRequired.
  ///
  /// In ar, this message translates to:
  /// **'رمز PIN مطلوب'**
  String get pinRequired;

  /// No description provided for @pinInvalid.
  ///
  /// In ar, this message translates to:
  /// **'رمز PIN غير صحيح'**
  String get pinInvalid;

  /// No description provided for @pinAttemptsRemaining.
  ///
  /// In ar, this message translates to:
  /// **'المحاولات المتبقية: {count}'**
  String pinAttemptsRemaining(int count);

  /// No description provided for @pinLocked.
  ///
  /// In ar, this message translates to:
  /// **'تم قفل الحساب. حاول بعد {minutes} دقيقة'**
  String pinLocked(int minutes);

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @dashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get dashboard;

  /// No description provided for @pos.
  ///
  /// In ar, this message translates to:
  /// **'نقطة البيع'**
  String get pos;

  /// No description provided for @products.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get products;

  /// No description provided for @categories.
  ///
  /// In ar, this message translates to:
  /// **'الفئات'**
  String get categories;

  /// No description provided for @inventory.
  ///
  /// In ar, this message translates to:
  /// **'المخزون'**
  String get inventory;

  /// No description provided for @customers.
  ///
  /// In ar, this message translates to:
  /// **'العملاء'**
  String get customers;

  /// No description provided for @orders.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات'**
  String get orders;

  /// No description provided for @invoices.
  ///
  /// In ar, this message translates to:
  /// **'الفواتير'**
  String get invoices;

  /// No description provided for @reports.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @sales.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات'**
  String get sales;

  /// No description provided for @salesAnalytics.
  ///
  /// In ar, this message translates to:
  /// **'تحليل المبيعات'**
  String get salesAnalytics;

  /// No description provided for @refund.
  ///
  /// In ar, this message translates to:
  /// **'استرجاع'**
  String get refund;

  /// No description provided for @todaySales.
  ///
  /// In ar, this message translates to:
  /// **'مبيعات اليوم'**
  String get todaySales;

  /// No description provided for @totalSales.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المبيعات'**
  String get totalSales;

  /// No description provided for @averageSale.
  ///
  /// In ar, this message translates to:
  /// **'متوسط البيع'**
  String get averageSale;

  /// No description provided for @cart.
  ///
  /// In ar, this message translates to:
  /// **'السلة'**
  String get cart;

  /// No description provided for @cartEmpty.
  ///
  /// In ar, this message translates to:
  /// **'السلة فارغة'**
  String get cartEmpty;

  /// No description provided for @addToCart.
  ///
  /// In ar, this message translates to:
  /// **'إضافة للسلة'**
  String get addToCart;

  /// No description provided for @removeFromCart.
  ///
  /// In ar, this message translates to:
  /// **'إزالة من السلة'**
  String get removeFromCart;

  /// No description provided for @clearCart.
  ///
  /// In ar, this message translates to:
  /// **'إفراغ السلة'**
  String get clearCart;

  /// No description provided for @checkout.
  ///
  /// In ar, this message translates to:
  /// **'إتمام الشراء'**
  String get checkout;

  /// No description provided for @payment.
  ///
  /// In ar, this message translates to:
  /// **'الدفع'**
  String get payment;

  /// No description provided for @paymentMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get paymentMethod;

  /// No description provided for @cash.
  ///
  /// In ar, this message translates to:
  /// **'نقداً'**
  String get cash;

  /// No description provided for @card.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة'**
  String get card;

  /// No description provided for @credit.
  ///
  /// In ar, this message translates to:
  /// **'آجل'**
  String get credit;

  /// No description provided for @transfer.
  ///
  /// In ar, this message translates to:
  /// **'تحويل'**
  String get transfer;

  /// No description provided for @paymentSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تمت العملية بنجاح'**
  String get paymentSuccess;

  /// No description provided for @paymentFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشلت العملية'**
  String get paymentFailed;

  /// No description provided for @price.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get price;

  /// No description provided for @quantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get quantity;

  /// No description provided for @total.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي'**
  String get total;

  /// No description provided for @subtotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع الفرعي'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In ar, this message translates to:
  /// **'خصم'**
  String get discount;

  /// No description provided for @tax.
  ///
  /// In ar, this message translates to:
  /// **'الضريبة'**
  String get tax;

  /// No description provided for @vat.
  ///
  /// In ar, this message translates to:
  /// **'ضريبة القيمة المضافة'**
  String get vat;

  /// No description provided for @grandTotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي الكلي'**
  String get grandTotal;

  /// No description provided for @product.
  ///
  /// In ar, this message translates to:
  /// **'منتج'**
  String get product;

  /// No description provided for @productName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المنتج'**
  String get productName;

  /// No description provided for @productCode.
  ///
  /// In ar, this message translates to:
  /// **'كود المنتج'**
  String get productCode;

  /// No description provided for @barcode.
  ///
  /// In ar, this message translates to:
  /// **'الباركود'**
  String get barcode;

  /// No description provided for @sku.
  ///
  /// In ar, this message translates to:
  /// **'رمز SKU'**
  String get sku;

  /// No description provided for @stock.
  ///
  /// In ar, this message translates to:
  /// **'المخزون'**
  String get stock;

  /// No description provided for @lowStock.
  ///
  /// In ar, this message translates to:
  /// **'مخزون منخفض'**
  String get lowStock;

  /// No description provided for @outOfStock.
  ///
  /// In ar, this message translates to:
  /// **'نفذ'**
  String get outOfStock;

  /// No description provided for @inStock.
  ///
  /// In ar, this message translates to:
  /// **'متوفر'**
  String get inStock;

  /// No description provided for @customer.
  ///
  /// In ar, this message translates to:
  /// **'العميل'**
  String get customer;

  /// No description provided for @customerName.
  ///
  /// In ar, this message translates to:
  /// **'اسم العميل'**
  String get customerName;

  /// No description provided for @customerPhone.
  ///
  /// In ar, this message translates to:
  /// **'هاتف العميل'**
  String get customerPhone;

  /// No description provided for @debt.
  ///
  /// In ar, this message translates to:
  /// **'دين'**
  String get debt;

  /// No description provided for @balance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد'**
  String get balance;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث هنا...'**
  String get searchHint;

  /// No description provided for @filter.
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب'**
  String get sort;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @done.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get done;

  /// No description provided for @submit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get submit;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get noData;

  /// No description provided for @noResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResults;

  /// No description provided for @error.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get error;

  /// No description provided for @pageNotFoundPath.
  ///
  /// In ar, this message translates to:
  /// **'الصفحة غير موجودة: {path}'**
  String pageNotFoundPath(String path);

  /// No description provided for @noInvoiceDataAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا تتوفر بيانات الفاتورة'**
  String get noInvoiceDataAvailable;

  /// No description provided for @errorOccurred.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get errorOccurred;

  /// No description provided for @tryAgain.
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة أخرى'**
  String get tryAgain;

  /// No description provided for @connectionError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الاتصال'**
  String get connectionError;

  /// No description provided for @noInternet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get noInternet;

  /// No description provided for @offline.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get offline;

  /// No description provided for @online.
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get online;

  /// No description provided for @success.
  ///
  /// In ar, this message translates to:
  /// **'نجاح'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In ar, this message translates to:
  /// **'تحذير'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In ar, this message translates to:
  /// **'معلومة'**
  String get info;

  /// No description provided for @yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In ar, this message translates to:
  /// **'هذا الأسبوع'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر'**
  String get thisMonth;

  /// No description provided for @shift.
  ///
  /// In ar, this message translates to:
  /// **'الوردية'**
  String get shift;

  /// No description provided for @openShift.
  ///
  /// In ar, this message translates to:
  /// **'فتح وردية'**
  String get openShift;

  /// No description provided for @closeShift.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق وردية'**
  String get closeShift;

  /// No description provided for @shiftSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الوردية'**
  String get shiftSummary;

  /// No description provided for @cashDrawer.
  ///
  /// In ar, this message translates to:
  /// **'درج النقد'**
  String get cashDrawer;

  /// No description provided for @receipt.
  ///
  /// In ar, this message translates to:
  /// **'الإيصال'**
  String get receipt;

  /// No description provided for @printReceipt.
  ///
  /// In ar, this message translates to:
  /// **'طباعة الإيصال'**
  String get printReceipt;

  /// No description provided for @shareReceipt.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة الإيصال'**
  String get shareReceipt;

  /// No description provided for @sync.
  ///
  /// In ar, this message translates to:
  /// **'مزامنة'**
  String get sync;

  /// No description provided for @syncing.
  ///
  /// In ar, this message translates to:
  /// **'جاري المزامنة...'**
  String get syncing;

  /// No description provided for @syncComplete.
  ///
  /// In ar, this message translates to:
  /// **'اكتملت المزامنة'**
  String get syncComplete;

  /// No description provided for @syncFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشلت المزامنة'**
  String get syncFailed;

  /// No description provided for @lastSync.
  ///
  /// In ar, this message translates to:
  /// **'آخر مزامنة'**
  String get lastSync;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @urdu.
  ///
  /// In ar, this message translates to:
  /// **'اردو'**
  String get urdu;

  /// No description provided for @hindi.
  ///
  /// In ar, this message translates to:
  /// **'हिन्दी'**
  String get hindi;

  /// No description provided for @filipino.
  ///
  /// In ar, this message translates to:
  /// **'Filipino'**
  String get filipino;

  /// No description provided for @bengali.
  ///
  /// In ar, this message translates to:
  /// **'বাংলা'**
  String get bengali;

  /// No description provided for @indonesian.
  ///
  /// In ar, this message translates to:
  /// **'Bahasa Indonesia'**
  String get indonesian;

  /// No description provided for @theme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع المظلم'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الفاتح'**
  String get lightMode;

  /// No description provided for @systemMode.
  ///
  /// In ar, this message translates to:
  /// **'وضع النظام'**
  String get systemMode;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @security.
  ///
  /// In ar, this message translates to:
  /// **'الأمان'**
  String get security;

  /// No description provided for @printer.
  ///
  /// In ar, this message translates to:
  /// **'الطابعة'**
  String get printer;

  /// No description provided for @backup.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي'**
  String get backup;

  /// No description provided for @help.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة'**
  String get help;

  /// No description provided for @about.
  ///
  /// In ar, this message translates to:
  /// **'حول التطبيق'**
  String get about;

  /// No description provided for @version.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار'**
  String get version;

  /// No description provided for @copyright.
  ///
  /// In ar, this message translates to:
  /// **'جميع الحقوق محفوظة'**
  String get copyright;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحذف'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من الحذف؟'**
  String get deleteConfirmMessage;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الخروج'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تسجيل الخروج؟'**
  String get logoutConfirmMessage;

  /// No description provided for @requiredField.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get requiredField;

  /// No description provided for @invalidFormat.
  ///
  /// In ar, this message translates to:
  /// **'صيغة غير صحيحة'**
  String get invalidFormat;

  /// No description provided for @minLength.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون {min} أحرف على الأقل'**
  String minLength(int min);

  /// No description provided for @maxLength.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون أقل من {max} حرف'**
  String maxLength(int max);

  /// No description provided for @welcomeTitle.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك مجدداً! 👋'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك لإدارة متجرك بسهولة وسرعة'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeSubtitleShort.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك لإدارة متجرك'**
  String get welcomeSubtitleShort;

  /// No description provided for @brandName.
  ///
  /// In ar, this message translates to:
  /// **'Al-Hal POS'**
  String get brandName;

  /// No description provided for @brandTagline.
  ///
  /// In ar, this message translates to:
  /// **'نظام نقاط البيع الذكي'**
  String get brandTagline;

  /// No description provided for @enterPhoneToContinue.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم جوالك للمتابعة'**
  String get enterPhoneToContinue;

  /// No description provided for @pleaseEnterValidPhone.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم جوال صحيح'**
  String get pleaseEnterValidPhone;

  /// No description provided for @otpSentViaWhatsApp.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رمز التحقق عبر WhatsApp'**
  String get otpSentViaWhatsApp;

  /// No description provided for @otpResent.
  ///
  /// In ar, this message translates to:
  /// **'تم إعادة إرسال رمز التحقق'**
  String get otpResent;

  /// No description provided for @enterOtpFully.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رمز التحقق كاملاً'**
  String get enterOtpFully;

  /// No description provided for @maxAttemptsReached.
  ///
  /// In ar, this message translates to:
  /// **'تم تجاوز الحد الأقصى. يرجى طلب رمز جديد'**
  String get maxAttemptsReached;

  /// No description provided for @waitMinutes.
  ///
  /// In ar, this message translates to:
  /// **'تم تجاوز الحد الأقصى. انتظر {minutes} دقيقة'**
  String waitMinutes(int minutes);

  /// No description provided for @waitSeconds.
  ///
  /// In ar, this message translates to:
  /// **'يرجى الانتظار {seconds} ثانية'**
  String waitSeconds(int seconds);

  /// No description provided for @resendIn.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال ({time})'**
  String resendIn(String time);

  /// No description provided for @resendCode.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get resendCode;

  /// No description provided for @changeNumber.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الرقم'**
  String get changeNumber;

  /// No description provided for @verificationCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق'**
  String get verificationCode;

  /// No description provided for @remainingAttempts.
  ///
  /// In ar, this message translates to:
  /// **'المحاولات المتبقية: {count}'**
  String remainingAttempts(int count);

  /// No description provided for @technicalSupport.
  ///
  /// In ar, this message translates to:
  /// **'الدعم الفني'**
  String get technicalSupport;

  /// No description provided for @privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// No description provided for @termsAndConditions.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام'**
  String get termsAndConditions;

  /// No description provided for @allRightsReserved.
  ///
  /// In ar, this message translates to:
  /// **'© 2026 نظام الحل. جميع الحقوق محفوظة.'**
  String get allRightsReserved;

  /// No description provided for @dayMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع النهاري'**
  String get dayMode;

  /// No description provided for @nightMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي'**
  String get nightMode;

  /// No description provided for @selectBranch.
  ///
  /// In ar, this message translates to:
  /// **'اختر فرعك'**
  String get selectBranch;

  /// No description provided for @selectBranchDesc.
  ///
  /// In ar, this message translates to:
  /// **'حدد الفرع الذي تريد العمل عليه'**
  String get selectBranchDesc;

  /// No description provided for @availableBranches.
  ///
  /// In ar, this message translates to:
  /// **'الفروع المتاحة'**
  String get availableBranches;

  /// No description provided for @branchCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا توجد فروع} one{فرع واحد} two{فرعان} few{{count} فروع} many{{count} فرعاً} other{{count} فرع}}'**
  String branchCount(int count);

  /// No description provided for @branchSelected.
  ///
  /// In ar, this message translates to:
  /// **'تم اختيار {name}'**
  String branchSelected(String name);

  /// No description provided for @addBranch.
  ///
  /// In ar, this message translates to:
  /// **'إضافة فرع جديد'**
  String get addBranch;

  /// No description provided for @comingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريباً'**
  String get comingSoon;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In ar, this message translates to:
  /// **'جرب البحث بكلمات مختلفة'**
  String get tryDifferentSearch;

  /// No description provided for @selectLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get selectLanguage;

  /// No description provided for @languageChangeInfo.
  ///
  /// In ar, this message translates to:
  /// **'اختر لغة العرض المفضلة لديك. سيتم تطبيق التغيير فوراً.'**
  String get languageChangeInfo;

  /// No description provided for @centralManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة مركزية شاملة'**
  String get centralManagement;

  /// No description provided for @centralManagementDesc.
  ///
  /// In ar, this message translates to:
  /// **'تحكم في جميع فروعك ومستودعاتك من مكان واحد. احصل على تقارير فورية ومزامنة للمخزون بين جميع نقاط البيع.'**
  String get centralManagementDesc;

  /// No description provided for @selectBranchToContinue.
  ///
  /// In ar, this message translates to:
  /// **'اختر الفرع للمتابعة'**
  String get selectBranchToContinue;

  /// No description provided for @youHaveAccessToBranches.
  ///
  /// In ar, this message translates to:
  /// **'لديك صلاحية الوصول إلى الفروع التالية. اختر فرعاً للبدء.'**
  String get youHaveAccessToBranches;

  /// No description provided for @searchForBranch.
  ///
  /// In ar, this message translates to:
  /// **'بحث عن فرع...'**
  String get searchForBranch;

  /// No description provided for @openNow.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح الآن'**
  String get openNow;

  /// No description provided for @closedOpensAt.
  ///
  /// In ar, this message translates to:
  /// **'مغلق (يفتح {time})'**
  String closedOpensAt(String time);

  /// No description provided for @loggedInAs.
  ///
  /// In ar, this message translates to:
  /// **'مسجل الدخول كـ'**
  String get loggedInAs;

  /// No description provided for @support247.
  ///
  /// In ar, this message translates to:
  /// **'دعم فني'**
  String get support247;

  /// No description provided for @analyticsTools.
  ///
  /// In ar, this message translates to:
  /// **'أدوات تحليل'**
  String get analyticsTools;

  /// No description provided for @uptime.
  ///
  /// In ar, this message translates to:
  /// **'وقت التشغيل'**
  String get uptime;

  /// No description provided for @dashboardTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get dashboardTitle;

  /// No description provided for @searchPlaceholder.
  ///
  /// In ar, this message translates to:
  /// **'بحث عام...'**
  String get searchPlaceholder;

  /// No description provided for @mainBranch.
  ///
  /// In ar, this message translates to:
  /// **'الفرع الرئيسي (الرياض)'**
  String get mainBranch;

  /// No description provided for @todaySalesLabel.
  ///
  /// In ar, this message translates to:
  /// **'مبيعات اليوم'**
  String get todaySalesLabel;

  /// No description provided for @ordersCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'عدد الطلبات'**
  String get ordersCountLabel;

  /// No description provided for @newCustomersLabel.
  ///
  /// In ar, this message translates to:
  /// **'عملاء جدد'**
  String get newCustomersLabel;

  /// No description provided for @stockAlertsLabel.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات المخزون'**
  String get stockAlertsLabel;

  /// No description provided for @productsUnit.
  ///
  /// In ar, this message translates to:
  /// **'منتجات'**
  String get productsUnit;

  /// No description provided for @salesAnalysis.
  ///
  /// In ar, this message translates to:
  /// **'تحليل المبيعات'**
  String get salesAnalysis;

  /// No description provided for @storePerformance.
  ///
  /// In ar, this message translates to:
  /// **'أداء المتجر خلال الأسبوع الحالي'**
  String get storePerformance;

  /// No description provided for @weekly.
  ///
  /// In ar, this message translates to:
  /// **'أسبوعي'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In ar, this message translates to:
  /// **'شهري'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In ar, this message translates to:
  /// **'سنوي'**
  String get yearly;

  /// No description provided for @quickAction.
  ///
  /// In ar, this message translates to:
  /// **'إجراء سريع'**
  String get quickAction;

  /// No description provided for @newSale.
  ///
  /// In ar, this message translates to:
  /// **'بيع جديد'**
  String get newSale;

  /// No description provided for @addProduct.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منتج'**
  String get addProduct;

  /// No description provided for @returnItem.
  ///
  /// In ar, this message translates to:
  /// **'استرجاع'**
  String get returnItem;

  /// No description provided for @dailyReport.
  ///
  /// In ar, this message translates to:
  /// **'تقرير يومي'**
  String get dailyReport;

  /// No description provided for @closeDay.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق اليوم'**
  String get closeDay;

  /// No description provided for @topSelling.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر مبيعاً'**
  String get topSelling;

  /// No description provided for @ordersToday.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا توجد طلبات اليوم} one{طلب واحد اليوم} two{طلبان اليوم} few{{count} طلبات اليوم} many{{count} طلباً اليوم} other{{count} طلب اليوم}}'**
  String ordersToday(int count);

  /// No description provided for @recentTransactions.
  ///
  /// In ar, this message translates to:
  /// **'أحدث العمليات'**
  String get recentTransactions;

  /// No description provided for @viewAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAll;

  /// No description provided for @orderNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الطلب'**
  String get orderNumber;

  /// No description provided for @time.
  ///
  /// In ar, this message translates to:
  /// **'الوقت'**
  String get time;

  /// No description provided for @status.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get status;

  /// No description provided for @amount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get amount;

  /// No description provided for @action.
  ///
  /// In ar, this message translates to:
  /// **'إجراء'**
  String get action;

  /// No description provided for @completed.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get completed;

  /// No description provided for @returned.
  ///
  /// In ar, this message translates to:
  /// **'مرتجع'**
  String get returned;

  /// No description provided for @pending.
  ///
  /// In ar, this message translates to:
  /// **'معلق'**
  String get pending;

  /// No description provided for @cancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get cancelled;

  /// No description provided for @guestCustomer.
  ///
  /// In ar, this message translates to:
  /// **'عميل زائر'**
  String get guestCustomer;

  /// No description provided for @minutesAgo.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{منذ دقيقة} two{منذ دقيقتين} few{منذ {count} دقائق} many{منذ {count} دقيقة} other{منذ {count} دقيقة}}'**
  String minutesAgo(int count);

  /// No description provided for @posSystem.
  ///
  /// In ar, this message translates to:
  /// **'نظام نقاط البيع'**
  String get posSystem;

  /// No description provided for @branchManager.
  ///
  /// In ar, this message translates to:
  /// **'المدير'**
  String get branchManager;

  /// No description provided for @settingsSection.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsSection;

  /// No description provided for @systemSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات النظام'**
  String get systemSettings;

  /// No description provided for @sar.
  ///
  /// In ar, this message translates to:
  /// **'ر.س'**
  String get sar;

  /// No description provided for @daily.
  ///
  /// In ar, this message translates to:
  /// **'يومي'**
  String get daily;

  /// No description provided for @goodMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get goodMorning;

  /// No description provided for @goodEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get goodEvening;

  /// No description provided for @cashCustomer.
  ///
  /// In ar, this message translates to:
  /// **'عميل نقدي'**
  String get cashCustomer;

  /// No description provided for @noTransactionsToday.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معاملات اليوم'**
  String get noTransactionsToday;

  /// No description provided for @comparedToYesterday.
  ///
  /// In ar, this message translates to:
  /// **'مقارنة بالأمس'**
  String get comparedToYesterday;

  /// No description provided for @ordersText.
  ///
  /// In ar, this message translates to:
  /// **'طلب اليوم'**
  String get ordersText;

  /// No description provided for @storeManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المتاجر'**
  String get storeManagement;

  /// No description provided for @finance.
  ///
  /// In ar, this message translates to:
  /// **'المالية'**
  String get finance;

  /// No description provided for @teamSection.
  ///
  /// In ar, this message translates to:
  /// **'الفريق'**
  String get teamSection;

  /// No description provided for @fullscreen.
  ///
  /// In ar, this message translates to:
  /// **'ملء الشاشة'**
  String get fullscreen;

  /// No description provided for @goodMorningName.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير، {name}!'**
  String goodMorningName(String name);

  /// No description provided for @goodEveningName.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير، {name}!'**
  String goodEveningName(String name);

  /// No description provided for @shoppingCart.
  ///
  /// In ar, this message translates to:
  /// **'سلة المشتريات'**
  String get shoppingCart;

  /// No description provided for @selectOrSearchCustomer.
  ///
  /// In ar, this message translates to:
  /// **'اختر أو ابحث عن عميل'**
  String get selectOrSearchCustomer;

  /// No description provided for @newCustomer.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get newCustomer;

  /// No description provided for @draft.
  ///
  /// In ar, this message translates to:
  /// **'مسودة'**
  String get draft;

  /// No description provided for @pay.
  ///
  /// In ar, this message translates to:
  /// **'الدفع'**
  String get pay;

  /// No description provided for @haveCoupon.
  ///
  /// In ar, this message translates to:
  /// **'لديك كوبون خصم؟'**
  String get haveCoupon;

  /// No description provided for @discountPercent.
  ///
  /// In ar, this message translates to:
  /// **'خصم {percent}%'**
  String discountPercent(String percent);

  /// No description provided for @openDrawer.
  ///
  /// In ar, this message translates to:
  /// **'فتح درج'**
  String get openDrawer;

  /// No description provided for @suspend.
  ///
  /// In ar, this message translates to:
  /// **'تعليق'**
  String get suspend;

  /// No description provided for @quantitySoldOut.
  ///
  /// In ar, this message translates to:
  /// **'نفذت الكمية'**
  String get quantitySoldOut;

  /// No description provided for @noProducts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات'**
  String get noProducts;

  /// No description provided for @addProductsToStart.
  ///
  /// In ar, this message translates to:
  /// **'أضف منتجات للبدء'**
  String get addProductsToStart;

  /// No description provided for @undoComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'تراجع (قريباً)'**
  String get undoComingSoon;

  /// No description provided for @undoneRemoved.
  ///
  /// In ar, this message translates to:
  /// **'تراجع: حُذف {name}'**
  String undoneRemoved(String name);

  /// No description provided for @undoneAdded.
  ///
  /// In ar, this message translates to:
  /// **'تراجع: أُعيد {name}'**
  String undoneAdded(String name);

  /// No description provided for @undoneQtyChanged.
  ///
  /// In ar, this message translates to:
  /// **'تراجع: {name} الكمية {from} → {to}'**
  String undoneQtyChanged(String name, int from, int to);

  /// No description provided for @nothingToUndo.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد شيء للتراجع'**
  String get nothingToUndo;

  /// No description provided for @employees.
  ///
  /// In ar, this message translates to:
  /// **'الموظفين'**
  String get employees;

  /// No description provided for @loyaltyProgram.
  ///
  /// In ar, this message translates to:
  /// **'برنامج الولاء'**
  String get loyaltyProgram;

  /// No description provided for @newBadge.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get newBadge;

  /// No description provided for @technicalSupportShort.
  ///
  /// In ar, this message translates to:
  /// **'الدعم الفني'**
  String get technicalSupportShort;

  /// No description provided for @productDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المنتج'**
  String get productDetails;

  /// No description provided for @stockMovements.
  ///
  /// In ar, this message translates to:
  /// **'حركات المخزون'**
  String get stockMovements;

  /// No description provided for @priceHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الأسعار'**
  String get priceHistory;

  /// No description provided for @salesHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل المبيعات'**
  String get salesHistory;

  /// No description provided for @available.
  ///
  /// In ar, this message translates to:
  /// **'متوفر'**
  String get available;

  /// No description provided for @alertLevel.
  ///
  /// In ar, this message translates to:
  /// **'حد التنبيه'**
  String get alertLevel;

  /// No description provided for @reorderPoint.
  ///
  /// In ar, this message translates to:
  /// **'نقطة إعادة الطلب'**
  String get reorderPoint;

  /// No description provided for @revenue.
  ///
  /// In ar, this message translates to:
  /// **'الإيرادات'**
  String get revenue;

  /// No description provided for @supplier.
  ///
  /// In ar, this message translates to:
  /// **'المورد'**
  String get supplier;

  /// No description provided for @lastSale.
  ///
  /// In ar, this message translates to:
  /// **'آخر عملية بيع'**
  String get lastSale;

  /// No description provided for @printLabel.
  ///
  /// In ar, this message translates to:
  /// **'طباعة ملصق'**
  String get printLabel;

  /// No description provided for @copied.
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ'**
  String get copied;

  /// No description provided for @copiedToClipboard.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ {label}'**
  String copiedToClipboard(String label);

  /// No description provided for @active.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In ar, this message translates to:
  /// **'غير نشط'**
  String get inactive;

  /// No description provided for @profitMargin.
  ///
  /// In ar, this message translates to:
  /// **'هامش الربح'**
  String get profitMargin;

  /// No description provided for @sellingPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر البيع'**
  String get sellingPrice;

  /// No description provided for @costPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر التكلفة'**
  String get costPrice;

  /// No description provided for @description.
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get description;

  /// No description provided for @noDescription.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد وصف'**
  String get noDescription;

  /// No description provided for @productNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على المنتج'**
  String get productNotFound;

  /// No description provided for @stockStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة المخزون'**
  String get stockStatus;

  /// No description provided for @currentStock.
  ///
  /// In ar, this message translates to:
  /// **'المخزون الحالي'**
  String get currentStock;

  /// No description provided for @unit.
  ///
  /// In ar, this message translates to:
  /// **'وحدة'**
  String get unit;

  /// No description provided for @units.
  ///
  /// In ar, this message translates to:
  /// **'وحدات'**
  String get units;

  /// No description provided for @date.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get date;

  /// No description provided for @type.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get type;

  /// No description provided for @reference.
  ///
  /// In ar, this message translates to:
  /// **'المرجع'**
  String get reference;

  /// No description provided for @newBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الجديد'**
  String get newBalance;

  /// No description provided for @oldPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر القديم'**
  String get oldPrice;

  /// No description provided for @newPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر الجديد'**
  String get newPrice;

  /// No description provided for @reason.
  ///
  /// In ar, this message translates to:
  /// **'السبب'**
  String get reason;

  /// No description provided for @invoiceNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الفاتورة'**
  String get invoiceNumber;

  /// No description provided for @categoryLabel.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get categoryLabel;

  /// No description provided for @uncategorized.
  ///
  /// In ar, this message translates to:
  /// **'بدون تصنيف'**
  String get uncategorized;

  /// No description provided for @noSupplier.
  ///
  /// In ar, this message translates to:
  /// **'بدون مورد'**
  String get noSupplier;

  /// No description provided for @moreOptions.
  ///
  /// In ar, this message translates to:
  /// **'خيارات أخرى'**
  String get moreOptions;

  /// No description provided for @noStockMovements.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حركات مخزون'**
  String get noStockMovements;

  /// No description provided for @noPriceHistory.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سجل أسعار'**
  String get noPriceHistory;

  /// No description provided for @noSalesHistory.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سجل مبيعات'**
  String get noSalesHistory;

  /// No description provided for @sale.
  ///
  /// In ar, this message translates to:
  /// **'بيع'**
  String get sale;

  /// No description provided for @purchase.
  ///
  /// In ar, this message translates to:
  /// **'شراء'**
  String get purchase;

  /// No description provided for @adjustment.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get adjustment;

  /// No description provided for @returnText.
  ///
  /// In ar, this message translates to:
  /// **'إرجاع'**
  String get returnText;

  /// No description provided for @waste.
  ///
  /// In ar, this message translates to:
  /// **'تالف'**
  String get waste;

  /// No description provided for @initialStock.
  ///
  /// In ar, this message translates to:
  /// **'مخزون أولي'**
  String get initialStock;

  /// No description provided for @searchByNameOrBarcode.
  ///
  /// In ar, this message translates to:
  /// **'بحث بالاسم أو الباركود...'**
  String get searchByNameOrBarcode;

  /// No description provided for @hideFilters.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء الفلاتر'**
  String get hideFilters;

  /// No description provided for @showFilters.
  ///
  /// In ar, this message translates to:
  /// **'إظهار الفلاتر'**
  String get showFilters;

  /// No description provided for @sortByName.
  ///
  /// In ar, this message translates to:
  /// **'حسب الاسم'**
  String get sortByName;

  /// No description provided for @sortByPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get sortByPrice;

  /// No description provided for @sortByStock.
  ///
  /// In ar, this message translates to:
  /// **'المخزون'**
  String get sortByStock;

  /// No description provided for @sortByRecent.
  ///
  /// In ar, this message translates to:
  /// **'الأحدث'**
  String get sortByRecent;

  /// No description provided for @allItems.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get allItems;

  /// No description provided for @clearFilters.
  ///
  /// In ar, this message translates to:
  /// **'مسح الفلاتر'**
  String get clearFilters;

  /// No description provided for @noBarcode.
  ///
  /// In ar, this message translates to:
  /// **'بدون باركود'**
  String get noBarcode;

  /// No description provided for @stockCount.
  ///
  /// In ar, this message translates to:
  /// **'المخزون: {count}'**
  String stockCount(int count);

  /// No description provided for @saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات'**
  String get saveChanges;

  /// No description provided for @addTheProduct.
  ///
  /// In ar, this message translates to:
  /// **'إضافة المنتج'**
  String get addTheProduct;

  /// No description provided for @editProduct.
  ///
  /// In ar, this message translates to:
  /// **'تعديل منتج'**
  String get editProduct;

  /// No description provided for @newProduct.
  ///
  /// In ar, this message translates to:
  /// **'منتج جديد'**
  String get newProduct;

  /// No description provided for @minimumQuantity.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى'**
  String get minimumQuantity;

  /// No description provided for @selectCategory.
  ///
  /// In ar, this message translates to:
  /// **'اختر التصنيف'**
  String get selectCategory;

  /// No description provided for @productImage.
  ///
  /// In ar, this message translates to:
  /// **'صورة المنتج'**
  String get productImage;

  /// No description provided for @trackInventory.
  ///
  /// In ar, this message translates to:
  /// **'تتبع المخزون'**
  String get trackInventory;

  /// No description provided for @productSavedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ المنتج بنجاح'**
  String get productSavedSuccess;

  /// No description provided for @productAddedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة المنتج بنجاح'**
  String get productAddedSuccess;

  /// No description provided for @scanBarcode.
  ///
  /// In ar, this message translates to:
  /// **'مسح الباركود'**
  String get scanBarcode;

  /// No description provided for @activeProduct.
  ///
  /// In ar, this message translates to:
  /// **'منتج نشط'**
  String get activeProduct;

  /// No description provided for @currency.
  ///
  /// In ar, this message translates to:
  /// **'ر.س'**
  String get currency;

  /// No description provided for @hoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{منذ ساعة} two{منذ ساعتين} few{منذ {count} ساعات} many{منذ {count} ساعة} other{منذ {count} ساعة}}'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{منذ يوم} two{منذ يومين} few{منذ {count} أيام} many{منذ {count} يوماً} other{منذ {count} يوم}}'**
  String daysAgo(int count);

  /// No description provided for @supplierPriceUpdate.
  ///
  /// In ar, this message translates to:
  /// **'تحديث أسعار الموردين'**
  String get supplierPriceUpdate;

  /// No description provided for @costIncrease.
  ///
  /// In ar, this message translates to:
  /// **'زيادة التكلفة'**
  String get costIncrease;

  /// No description provided for @duplicateProduct.
  ///
  /// In ar, this message translates to:
  /// **'نسخ المنتج'**
  String get duplicateProduct;

  /// No description provided for @categoriesManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة التصنيفات'**
  String get categoriesManagement;

  /// No description provided for @categoriesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا توجد تصنيفات} one{تصنيف واحد} two{تصنيفان} few{{count} تصنيفات} many{{count} تصنيفاً} other{{count} تصنيف}}'**
  String categoriesCount(int count);

  /// No description provided for @addCategory.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تصنيف'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In ar, this message translates to:
  /// **'تعديل تصنيف'**
  String get editCategory;

  /// No description provided for @deleteCategory.
  ///
  /// In ar, this message translates to:
  /// **'حذف التصنيف'**
  String get deleteCategory;

  /// No description provided for @categoryName.
  ///
  /// In ar, this message translates to:
  /// **'اسم التصنيف'**
  String get categoryName;

  /// No description provided for @categoryNameAr.
  ///
  /// In ar, this message translates to:
  /// **'الاسم (عربي)'**
  String get categoryNameAr;

  /// No description provided for @categoryNameEn.
  ///
  /// In ar, this message translates to:
  /// **'الاسم (إنجليزي)'**
  String get categoryNameEn;

  /// No description provided for @parentCategory.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف الأب'**
  String get parentCategory;

  /// No description provided for @noParentCategory.
  ///
  /// In ar, this message translates to:
  /// **'بدون تصنيف أب (رئيسي)'**
  String get noParentCategory;

  /// No description provided for @sortOrder.
  ///
  /// In ar, this message translates to:
  /// **'الترتيب'**
  String get sortOrder;

  /// No description provided for @categoryColor.
  ///
  /// In ar, this message translates to:
  /// **'اللون'**
  String get categoryColor;

  /// No description provided for @categoryIcon.
  ///
  /// In ar, this message translates to:
  /// **'الأيقونة'**
  String get categoryIcon;

  /// No description provided for @categoryDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل التصنيف'**
  String get categoryDetails;

  /// No description provided for @categoryCreatedAt.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإنشاء'**
  String get categoryCreatedAt;

  /// No description provided for @categoryProducts.
  ///
  /// In ar, this message translates to:
  /// **'منتجات التصنيف'**
  String get categoryProducts;

  /// No description provided for @noCategorySelected.
  ///
  /// In ar, this message translates to:
  /// **'اختر تصنيفاً لعرض تفاصيله'**
  String get noCategorySelected;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا التصنيف؟'**
  String get deleteCategoryConfirm;

  /// No description provided for @categoryDeletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف التصنيف بنجاح'**
  String get categoryDeletedSuccess;

  /// No description provided for @categorySavedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التصنيف بنجاح'**
  String get categorySavedSuccess;

  /// No description provided for @searchCategories.
  ///
  /// In ar, this message translates to:
  /// **'البحث في التصنيفات...'**
  String get searchCategories;

  /// No description provided for @reorderCategories.
  ///
  /// In ar, this message translates to:
  /// **'إعادة ترتيب'**
  String get reorderCategories;

  /// No description provided for @noCategories.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تصنيفات'**
  String get noCategories;

  /// No description provided for @subcategories.
  ///
  /// In ar, this message translates to:
  /// **'تصنيفات فرعية'**
  String get subcategories;

  /// No description provided for @activeStatus.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get activeStatus;

  /// No description provided for @inactiveStatus.
  ///
  /// In ar, this message translates to:
  /// **'غير نشط'**
  String get inactiveStatus;

  /// No description provided for @invoicesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الفواتير'**
  String get invoicesTitle;

  /// No description provided for @totalInvoices.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الفواتير'**
  String get totalInvoices;

  /// No description provided for @totalPaid.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المدفوع'**
  String get totalPaid;

  /// No description provided for @totalPending.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المعلق'**
  String get totalPending;

  /// No description provided for @totalOverdue.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المتأخر'**
  String get totalOverdue;

  /// No description provided for @comparedToLastMonth.
  ///
  /// In ar, this message translates to:
  /// **'مقارنة بالشهر الماضي'**
  String get comparedToLastMonth;

  /// No description provided for @ofTotalDue.
  ///
  /// In ar, this message translates to:
  /// **'{percent}% من الإجمالي المستحق'**
  String ofTotalDue(String percent);

  /// No description provided for @invoicesWaitingPayment.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا فواتير بانتظار الدفع} one{فاتورة واحدة بانتظار الدفع} two{فاتورتان بانتظار الدفع} few{{count} فواتير بانتظار الدفع} many{{count} فاتورة بانتظار الدفع} other{{count} فاتورة بانتظار الدفع}}'**
  String invoicesWaitingPayment(int count);

  /// No description provided for @sendReminderNow.
  ///
  /// In ar, this message translates to:
  /// **'إرسال تذكير الآن'**
  String get sendReminderNow;

  /// No description provided for @revenueAnalysis.
  ///
  /// In ar, this message translates to:
  /// **'تحليل الإيرادات'**
  String get revenueAnalysis;

  /// No description provided for @last7Days.
  ///
  /// In ar, this message translates to:
  /// **'آخر 7 أيام'**
  String get last7Days;

  /// No description provided for @thisMonthPeriod.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر'**
  String get thisMonthPeriod;

  /// No description provided for @thisYearPeriod.
  ///
  /// In ar, this message translates to:
  /// **'هذا العام'**
  String get thisYearPeriod;

  /// No description provided for @paymentMethods.
  ///
  /// In ar, this message translates to:
  /// **'طرق الدفع'**
  String get paymentMethods;

  /// No description provided for @cashPayment.
  ///
  /// In ar, this message translates to:
  /// **'نقدا'**
  String get cashPayment;

  /// No description provided for @cardPayment.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة'**
  String get cardPayment;

  /// No description provided for @walletPayment.
  ///
  /// In ar, this message translates to:
  /// **'محفظة'**
  String get walletPayment;

  /// No description provided for @saveCurrentFilter.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الفلتر الحالي'**
  String get saveCurrentFilter;

  /// No description provided for @statusAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get statusAll;

  /// No description provided for @statusPaid.
  ///
  /// In ar, this message translates to:
  /// **'مدفوعة'**
  String get statusPaid;

  /// No description provided for @statusPending.
  ///
  /// In ar, this message translates to:
  /// **'معلقة'**
  String get statusPending;

  /// No description provided for @statusOverdue.
  ///
  /// In ar, this message translates to:
  /// **'متأخرة'**
  String get statusOverdue;

  /// No description provided for @statusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get statusCancelled;

  /// No description provided for @resetFilters.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين'**
  String get resetFilters;

  /// No description provided for @createInvoice.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء فاتورة'**
  String get createInvoice;

  /// No description provided for @invoiceNumberCol.
  ///
  /// In ar, this message translates to:
  /// **'رقم الفاتورة'**
  String get invoiceNumberCol;

  /// No description provided for @customerNameCol.
  ///
  /// In ar, this message translates to:
  /// **'اسم العميل'**
  String get customerNameCol;

  /// No description provided for @dateCol.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get dateCol;

  /// No description provided for @amountCol.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get amountCol;

  /// No description provided for @statusCol.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get statusCol;

  /// No description provided for @paymentCol.
  ///
  /// In ar, this message translates to:
  /// **'الدفع'**
  String get paymentCol;

  /// No description provided for @actionsCol.
  ///
  /// In ar, this message translates to:
  /// **'الإجراءات'**
  String get actionsCol;

  /// No description provided for @viewInvoice.
  ///
  /// In ar, this message translates to:
  /// **'عرض'**
  String get viewInvoice;

  /// No description provided for @printInvoice.
  ///
  /// In ar, this message translates to:
  /// **'طباعة'**
  String get printInvoice;

  /// No description provided for @exportPdf.
  ///
  /// In ar, this message translates to:
  /// **'تصدير PDF'**
  String get exportPdf;

  /// No description provided for @sendWhatsapp.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get sendWhatsapp;

  /// No description provided for @deleteInvoice.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get deleteInvoice;

  /// No description provided for @reminder.
  ///
  /// In ar, this message translates to:
  /// **'تذكير'**
  String get reminder;

  /// No description provided for @exportAll.
  ///
  /// In ar, this message translates to:
  /// **'تصدير الكل'**
  String get exportAll;

  /// No description provided for @printReport.
  ///
  /// In ar, this message translates to:
  /// **'طباعة التقرير'**
  String get printReport;

  /// No description provided for @more.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get more;

  /// No description provided for @showingResults.
  ///
  /// In ar, this message translates to:
  /// **'عرض {from} إلى {to} من أصل {total} نتيجة'**
  String showingResults(int from, int to, int total);

  /// No description provided for @newInvoice.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة جديدة'**
  String get newInvoice;

  /// No description provided for @selectCustomer.
  ///
  /// In ar, this message translates to:
  /// **'اختر العميل'**
  String get selectCustomer;

  /// No description provided for @cashCustomerGeneral.
  ///
  /// In ar, this message translates to:
  /// **'عميل نقدي (عام)'**
  String get cashCustomerGeneral;

  /// No description provided for @addNewCustomer.
  ///
  /// In ar, this message translates to:
  /// **'+ إضافة عميل جديد'**
  String get addNewCustomer;

  /// No description provided for @productsSection.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get productsSection;

  /// No description provided for @addProductToInvoice.
  ///
  /// In ar, this message translates to:
  /// **'+ إضافة منتج'**
  String get addProductToInvoice;

  /// No description provided for @productCol.
  ///
  /// In ar, this message translates to:
  /// **'المنتج'**
  String get productCol;

  /// No description provided for @quantityCol.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get quantityCol;

  /// No description provided for @priceCol.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get priceCol;

  /// No description provided for @dueDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الاستحقاق'**
  String get dueDate;

  /// No description provided for @invoiceTotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي:'**
  String get invoiceTotal;

  /// No description provided for @saveInvoice.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الفاتورة'**
  String get saveInvoice;

  /// No description provided for @deleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد؟'**
  String get deleteConfirm;

  /// No description provided for @deleteInvoiceMsg.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حقاً حذف هذه الفاتورة؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get deleteInvoiceMsg;

  /// No description provided for @yesDelete.
  ///
  /// In ar, this message translates to:
  /// **'نعم، احذف'**
  String get yesDelete;

  /// No description provided for @copiedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ بنجاح'**
  String get copiedSuccess;

  /// No description provided for @invoiceDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الفاتورة بنجاح'**
  String get invoiceDeleted;

  /// No description provided for @sat.
  ///
  /// In ar, this message translates to:
  /// **'السبت'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In ar, this message translates to:
  /// **'الأحد'**
  String get sun;

  /// No description provided for @mon.
  ///
  /// In ar, this message translates to:
  /// **'الاثنين'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In ar, this message translates to:
  /// **'الثلاثاء'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In ar, this message translates to:
  /// **'الأربعاء'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In ar, this message translates to:
  /// **'الخميس'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In ar, this message translates to:
  /// **'الجمعة'**
  String get fri;

  /// No description provided for @selected.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لم يتم التحديد} one{محدد واحد} two{محددان} few{{count} محددة} many{{count} محدداً} other{{count} محدد}}'**
  String selected(int count);

  /// No description provided for @bulkPrint.
  ///
  /// In ar, this message translates to:
  /// **'طباعة'**
  String get bulkPrint;

  /// No description provided for @bulkExportPdf.
  ///
  /// In ar, this message translates to:
  /// **'تصدير PDF'**
  String get bulkExportPdf;

  /// No description provided for @allRightsReservedFooter.
  ///
  /// In ar, this message translates to:
  /// **'© 2026 Alhai POS. جميع الحقوق محفوظة.'**
  String get allRightsReservedFooter;

  /// No description provided for @privacyPolicyFooter.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicyFooter;

  /// No description provided for @termsFooter.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام'**
  String get termsFooter;

  /// No description provided for @supportFooter.
  ///
  /// In ar, this message translates to:
  /// **'الدعم الفني'**
  String get supportFooter;

  /// No description provided for @paid.
  ///
  /// In ar, this message translates to:
  /// **'مدفوعة'**
  String get paid;

  /// No description provided for @overdue.
  ///
  /// In ar, this message translates to:
  /// **'متأخرة'**
  String get overdue;

  /// No description provided for @creditCard.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة ائتمان'**
  String get creditCard;

  /// No description provided for @electronicWallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظة إلكترونية'**
  String get electronicWallet;

  /// No description provided for @searchInvoiceHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث برقم الفاتورة، العميل...'**
  String get searchInvoiceHint;

  /// No description provided for @customerDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل العميل'**
  String get customerDetails;

  /// No description provided for @customerProfileAndTransactions.
  ///
  /// In ar, this message translates to:
  /// **'نظرة عامة على الملف الشخصي والمعاملات'**
  String get customerProfileAndTransactions;

  /// No description provided for @customerDetailTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل العميل'**
  String get customerDetailTitle;

  /// No description provided for @totalPurchases.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المشتريات'**
  String get totalPurchases;

  /// No description provided for @loyaltyPoints.
  ///
  /// In ar, this message translates to:
  /// **'نقاط الولاء'**
  String get loyaltyPoints;

  /// No description provided for @lastVisit.
  ///
  /// In ar, this message translates to:
  /// **'آخر زيارة'**
  String get lastVisit;

  /// No description provided for @newSaleAction.
  ///
  /// In ar, this message translates to:
  /// **'بيع جديد'**
  String get newSaleAction;

  /// No description provided for @editInfo.
  ///
  /// In ar, this message translates to:
  /// **'تعديل البيانات'**
  String get editInfo;

  /// No description provided for @whatsapp.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get whatsapp;

  /// No description provided for @blockCustomer.
  ///
  /// In ar, this message translates to:
  /// **'حظر العميل'**
  String get blockCustomer;

  /// No description provided for @purchasesTab.
  ///
  /// In ar, this message translates to:
  /// **'المشتريات'**
  String get purchasesTab;

  /// No description provided for @accountTab.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get accountTab;

  /// No description provided for @debtsTab.
  ///
  /// In ar, this message translates to:
  /// **'الديون'**
  String get debtsTab;

  /// No description provided for @analyticsTab.
  ///
  /// In ar, this message translates to:
  /// **'التحليلات'**
  String get analyticsTab;

  /// No description provided for @recentOrdersLog.
  ///
  /// In ar, this message translates to:
  /// **'سجل الطلبات الأخير'**
  String get recentOrdersLog;

  /// No description provided for @exportCsv.
  ///
  /// In ar, this message translates to:
  /// **'تصدير CSV'**
  String get exportCsv;

  /// No description provided for @searchByInvoiceNumber.
  ///
  /// In ar, this message translates to:
  /// **'بحث برقم الفاتورة...'**
  String get searchByInvoiceNumber;

  /// No description provided for @items.
  ///
  /// In ar, this message translates to:
  /// **'البنود'**
  String get items;

  /// No description provided for @viewDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get viewDetails;

  /// No description provided for @financialLedger.
  ///
  /// In ar, this message translates to:
  /// **'سجل الحركات المالية'**
  String get financialLedger;

  /// No description provided for @cashPaymentEntry.
  ///
  /// In ar, this message translates to:
  /// **'دفعة نقدية'**
  String get cashPaymentEntry;

  /// No description provided for @walletTopup.
  ///
  /// In ar, this message translates to:
  /// **'شحن محفظة'**
  String get walletTopup;

  /// No description provided for @loyaltyPointsDeduction.
  ///
  /// In ar, this message translates to:
  /// **'خصم نقاط ولاء'**
  String get loyaltyPointsDeduction;

  /// No description provided for @redeemPoints.
  ///
  /// In ar, this message translates to:
  /// **'استبدال {count} نقطة'**
  String redeemPoints(int count);

  /// No description provided for @viewFullLedger.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكامل'**
  String get viewFullLedger;

  /// No description provided for @currentBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الحالي'**
  String get currentBalance;

  /// No description provided for @creditLimit.
  ///
  /// In ar, this message translates to:
  /// **'الحد الائتماني'**
  String get creditLimit;

  /// No description provided for @used.
  ///
  /// In ar, this message translates to:
  /// **'المستخدم'**
  String get used;

  /// No description provided for @topUpBalance.
  ///
  /// In ar, this message translates to:
  /// **'شحن الرصيد'**
  String get topUpBalance;

  /// No description provided for @overdueDebt.
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get overdueDebt;

  /// No description provided for @upcomingDebt.
  ///
  /// In ar, this message translates to:
  /// **'قريب'**
  String get upcomingDebt;

  /// No description provided for @payNow.
  ///
  /// In ar, this message translates to:
  /// **'تسديد الآن'**
  String get payNow;

  /// No description provided for @remind.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه'**
  String get remind;

  /// No description provided for @monthlySpending.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الإنفاق الشهري'**
  String get monthlySpending;

  /// No description provided for @purchaseDistribution.
  ///
  /// In ar, this message translates to:
  /// **'توزيع المشتريات حسب الفئة'**
  String get purchaseDistribution;

  /// No description provided for @last6Months.
  ///
  /// In ar, this message translates to:
  /// **'آخر 6 أشهر'**
  String get last6Months;

  /// No description provided for @thisYear.
  ///
  /// In ar, this message translates to:
  /// **'هذا العام'**
  String get thisYear;

  /// No description provided for @averageOrder.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الطلب'**
  String get averageOrder;

  /// No description provided for @purchaseFrequency.
  ///
  /// In ar, this message translates to:
  /// **'تكرار الشراء'**
  String get purchaseFrequency;

  /// No description provided for @everyNDays.
  ///
  /// In ar, this message translates to:
  /// **'كل {count} أيام'**
  String everyNDays(int count);

  /// No description provided for @spendingGrowth.
  ///
  /// In ar, this message translates to:
  /// **'نمو الإنفاق'**
  String get spendingGrowth;

  /// No description provided for @favoriteProduct.
  ///
  /// In ar, this message translates to:
  /// **'المنتج المفضل'**
  String get favoriteProduct;

  /// No description provided for @internalNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات داخلية (مرئية للموظفين فقط)'**
  String get internalNotes;

  /// No description provided for @addNote.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get addNote;

  /// No description provided for @addNewNote.
  ///
  /// In ar, this message translates to:
  /// **'أضف ملاحظة جديدة...'**
  String get addNewNote;

  /// No description provided for @joinedDate.
  ///
  /// In ar, this message translates to:
  /// **'انضم: {date}'**
  String joinedDate(String date);

  /// No description provided for @lastUpdated.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث: {time}'**
  String lastUpdated(String time);

  /// No description provided for @showingOrders.
  ///
  /// In ar, this message translates to:
  /// **'عرض {from}-{to} من {total} طلب'**
  String showingOrders(int from, int to, int total);

  /// No description provided for @vegetables.
  ///
  /// In ar, this message translates to:
  /// **'خضروات'**
  String get vegetables;

  /// No description provided for @dairy.
  ///
  /// In ar, this message translates to:
  /// **'منتجات ألبان'**
  String get dairy;

  /// No description provided for @meat.
  ///
  /// In ar, this message translates to:
  /// **'لحوم'**
  String get meat;

  /// No description provided for @bakery.
  ///
  /// In ar, this message translates to:
  /// **'مخبوزات'**
  String get bakery;

  /// No description provided for @other.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get other;

  /// No description provided for @returns.
  ///
  /// In ar, this message translates to:
  /// **'المرتجعات'**
  String get returns;

  /// No description provided for @salesReturns.
  ///
  /// In ar, this message translates to:
  /// **'مرتجعات المبيعات'**
  String get salesReturns;

  /// No description provided for @purchaseReturns.
  ///
  /// In ar, this message translates to:
  /// **'مرتجعات المشتريات'**
  String get purchaseReturns;

  /// No description provided for @totalReturns.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المرتجعات'**
  String get totalReturns;

  /// No description provided for @totalRefundedAmount.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المبالغ المرجعة'**
  String get totalRefundedAmount;

  /// No description provided for @mostReturned.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر إرجاعاً'**
  String get mostReturned;

  /// No description provided for @processed.
  ///
  /// In ar, this message translates to:
  /// **'مسترد'**
  String get processed;

  /// No description provided for @newReturn.
  ///
  /// In ar, this message translates to:
  /// **'مرتجع جديد'**
  String get newReturn;

  /// No description provided for @createNewReturn.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء مرتجع جديد'**
  String get createNewReturn;

  /// No description provided for @processReturnRequest.
  ///
  /// In ar, this message translates to:
  /// **'معالجة طلب إرجاع مبيعات'**
  String get processReturnRequest;

  /// No description provided for @returnNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم المرتجع'**
  String get returnNumber;

  /// No description provided for @originalInvoice.
  ///
  /// In ar, this message translates to:
  /// **'الفاتورة الأصلية'**
  String get originalInvoice;

  /// No description provided for @returnReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب الإرجاع'**
  String get returnReason;

  /// No description provided for @returnAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ الإرجاع'**
  String get returnAmount;

  /// No description provided for @returnStatus.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get returnStatus;

  /// No description provided for @returnDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get returnDate;

  /// No description provided for @returnActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات'**
  String get returnActions;

  /// No description provided for @returnRefunded.
  ///
  /// In ar, this message translates to:
  /// **'مسترد'**
  String get returnRefunded;

  /// No description provided for @returnRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get returnRejected;

  /// No description provided for @defectiveProduct.
  ///
  /// In ar, this message translates to:
  /// **'تلف في المنتج'**
  String get defectiveProduct;

  /// No description provided for @wrongProduct.
  ///
  /// In ar, this message translates to:
  /// **'منتج خاطئ'**
  String get wrongProduct;

  /// No description provided for @customerRequest.
  ///
  /// In ar, this message translates to:
  /// **'رغبة العميل'**
  String get customerRequest;

  /// No description provided for @otherReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب آخر'**
  String get otherReason;

  /// No description provided for @quickSearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث سريع...'**
  String get quickSearch;

  /// No description provided for @exportData.
  ///
  /// In ar, this message translates to:
  /// **'تصدير'**
  String get exportData;

  /// No description provided for @printData.
  ///
  /// In ar, this message translates to:
  /// **'طباعة'**
  String get printData;

  /// No description provided for @approve.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get reject;

  /// No description provided for @previous.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get previous;

  /// No description provided for @invoiceStep.
  ///
  /// In ar, this message translates to:
  /// **'الفاتورة'**
  String get invoiceStep;

  /// No description provided for @itemsStep.
  ///
  /// In ar, this message translates to:
  /// **'الأصناف'**
  String get itemsStep;

  /// No description provided for @reasonStep.
  ///
  /// In ar, this message translates to:
  /// **'السبب'**
  String get reasonStep;

  /// No description provided for @confirmStep.
  ///
  /// In ar, this message translates to:
  /// **'التأكيد'**
  String get confirmStep;

  /// No description provided for @enterInvoiceNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الفاتورة'**
  String get enterInvoiceNumber;

  /// No description provided for @invoiceExample.
  ///
  /// In ar, this message translates to:
  /// **'مثال: #INV-889'**
  String get invoiceExample;

  /// No description provided for @loadInvoice.
  ///
  /// In ar, this message translates to:
  /// **'تحميل'**
  String get loadInvoice;

  /// No description provided for @invoiceLoaded.
  ///
  /// In ar, this message translates to:
  /// **'تم تحميل الفاتورة #{number}'**
  String invoiceLoaded(String number);

  /// No description provided for @invoiceLoadedCustomer.
  ///
  /// In ar, this message translates to:
  /// **'العميل: {customer} | التاريخ: {date}'**
  String invoiceLoadedCustomer(String customer, String date);

  /// No description provided for @selectItemsInfo.
  ///
  /// In ar, this message translates to:
  /// **'حدد الأصناف المراد إرجاعها. لا يمكن إرجاع كمية أكبر مما تم بيعه.'**
  String get selectItemsInfo;

  /// No description provided for @availableToReturn.
  ///
  /// In ar, this message translates to:
  /// **'متاح الإرجاع: {count}'**
  String availableToReturn(int count);

  /// No description provided for @alreadyReturnedFully.
  ///
  /// In ar, this message translates to:
  /// **'تم إرجاع الكمية بالكامل سابقاً'**
  String get alreadyReturnedFully;

  /// No description provided for @returnReasonLabel.
  ///
  /// In ar, this message translates to:
  /// **'سبب الإرجاع (للأصناف المحددة)'**
  String get returnReasonLabel;

  /// No description provided for @additionalDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل إضافية (مطلوب عند اختيار أخرى)...'**
  String get additionalDetails;

  /// No description provided for @confirmReturn.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الإرجاع'**
  String get confirmReturn;

  /// No description provided for @refundAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المسترد'**
  String get refundAmount;

  /// No description provided for @refundMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الاسترداد'**
  String get refundMethod;

  /// No description provided for @cashRefund.
  ///
  /// In ar, this message translates to:
  /// **'نقداً'**
  String get cashRefund;

  /// No description provided for @storeCredit.
  ///
  /// In ar, this message translates to:
  /// **'رصيد المتجر'**
  String get storeCredit;

  /// No description provided for @returnCreatedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء المرتجع بنجاح'**
  String get returnCreatedSuccess;

  /// No description provided for @noReturns.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مرتجعات'**
  String get noReturns;

  /// No description provided for @noReturnsDesc.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تسجيل أي عمليات إرجاع حتى الآن.'**
  String get noReturnsDesc;

  /// No description provided for @timesReturned.
  ///
  /// In ar, this message translates to:
  /// **'{count} مرات ({percent}% من الإجمالي)'**
  String timesReturned(int count, int percent);

  /// No description provided for @fromInvoice.
  ///
  /// In ar, this message translates to:
  /// **'من فاتورة'**
  String get fromInvoice;

  /// No description provided for @dateFromTo.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ من - إلى'**
  String get dateFromTo;

  /// No description provided for @returnCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ الرقم بنجاح'**
  String get returnCopied;

  /// No description provided for @ofTotalProcessed.
  ///
  /// In ar, this message translates to:
  /// **'{percent}% تمت معالجته'**
  String ofTotalProcessed(int percent);

  /// No description provided for @invoiceDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الفاتورة'**
  String get invoiceDetails;

  /// No description provided for @invoiceNumberLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم:'**
  String invoiceNumberLabel(String number);

  /// No description provided for @additionalOptions.
  ///
  /// In ar, this message translates to:
  /// **'خيارات إضافية'**
  String get additionalOptions;

  /// No description provided for @duplicateInvoice.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء نسخة مكررة'**
  String get duplicateInvoice;

  /// No description provided for @returnMerchandise.
  ///
  /// In ar, this message translates to:
  /// **'إرجاع بضاعة'**
  String get returnMerchandise;

  /// No description provided for @voidInvoice.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الفاتورة (Void)'**
  String get voidInvoice;

  /// No description provided for @printBtn.
  ///
  /// In ar, this message translates to:
  /// **'طباعة'**
  String get printBtn;

  /// No description provided for @downloadBtn.
  ///
  /// In ar, this message translates to:
  /// **'تحميل'**
  String get downloadBtn;

  /// No description provided for @paidSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم الدفع بنجاح'**
  String get paidSuccessfully;

  /// No description provided for @amountReceivedFull.
  ///
  /// In ar, this message translates to:
  /// **'تم استلام المبلغ بالكامل'**
  String get amountReceivedFull;

  /// No description provided for @completedStatus.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get completedStatus;

  /// No description provided for @pendingStatus.
  ///
  /// In ar, this message translates to:
  /// **'انتظار'**
  String get pendingStatus;

  /// No description provided for @voidedStatus.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get voidedStatus;

  /// No description provided for @storeName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المتجر'**
  String get storeName;

  /// No description provided for @storeAddress.
  ///
  /// In ar, this message translates to:
  /// **'الرياض، حي الملز، شارع التخصصي'**
  String get storeAddress;

  /// No description provided for @simplifiedTaxInvoice.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة ضريبية مبسطة'**
  String get simplifiedTaxInvoice;

  /// No description provided for @dateAndTime.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ والوقت'**
  String get dateAndTime;

  /// No description provided for @cashierLabel.
  ///
  /// In ar, this message translates to:
  /// **'الكاشير'**
  String get cashierLabel;

  /// No description provided for @itemCol.
  ///
  /// In ar, this message translates to:
  /// **'الصنف'**
  String get itemCol;

  /// No description provided for @quantityColDetail.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get quantityColDetail;

  /// No description provided for @priceColDetail.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get priceColDetail;

  /// No description provided for @totalCol.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get totalCol;

  /// No description provided for @subtotalLabel.
  ///
  /// In ar, this message translates to:
  /// **'المجموع الفرعي'**
  String get subtotalLabel;

  /// No description provided for @discountVip.
  ///
  /// In ar, this message translates to:
  /// **'الخصم (عضو VIP)'**
  String get discountVip;

  /// No description provided for @vatLabel.
  ///
  /// In ar, this message translates to:
  /// **'ضريبة القيمة المضافة (15%)'**
  String get vatLabel;

  /// No description provided for @grandTotalLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي النهائي'**
  String get grandTotalLabel;

  /// No description provided for @paymentMethodLabel.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get paymentMethodLabel;

  /// No description provided for @amountPaidLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المدفوع'**
  String get amountPaidLabel;

  /// No description provided for @zatcaElectronic.
  ///
  /// In ar, this message translates to:
  /// **'ZATCA - فاتورة إلكترونية'**
  String get zatcaElectronic;

  /// No description provided for @scanToVerify.
  ///
  /// In ar, this message translates to:
  /// **'مسح للتحقق من صحة الفاتورة'**
  String get scanToVerify;

  /// No description provided for @includesVat15.
  ///
  /// In ar, this message translates to:
  /// **'يشمل ضريبة القيمة المضافة 15%'**
  String get includesVat15;

  /// No description provided for @thankYouVisit.
  ///
  /// In ar, this message translates to:
  /// **'شكراً لزيارتكم!'**
  String get thankYouVisit;

  /// No description provided for @wishNiceDay.
  ///
  /// In ar, this message translates to:
  /// **'نتمنى لكم يوماً سعيداً'**
  String get wishNiceDay;

  /// No description provided for @customerInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات العميل'**
  String get customerInfo;

  /// No description provided for @editBtn.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get editBtn;

  /// No description provided for @vipSince.
  ///
  /// In ar, this message translates to:
  /// **'عميل VIP منذ {year}'**
  String vipSince(String year);

  /// No description provided for @activeStatusLabel.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get activeStatusLabel;

  /// No description provided for @callBtn.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get callBtn;

  /// No description provided for @recordBtn.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get recordBtn;

  /// No description provided for @quickActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات سريعة'**
  String get quickActions;

  /// No description provided for @sendWhatsappAction.
  ///
  /// In ar, this message translates to:
  /// **'إرسال واتساب'**
  String get sendWhatsappAction;

  /// No description provided for @sendEmailAction.
  ///
  /// In ar, this message translates to:
  /// **'إرسال بالبريد'**
  String get sendEmailAction;

  /// No description provided for @downloadPdfAction.
  ///
  /// In ar, this message translates to:
  /// **'تحميل PDF'**
  String get downloadPdfAction;

  /// No description provided for @shareLinkAction.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة رابط'**
  String get shareLinkAction;

  /// No description provided for @eventLog.
  ///
  /// In ar, this message translates to:
  /// **'سجل الأحداث'**
  String get eventLog;

  /// No description provided for @paymentCompleted.
  ///
  /// In ar, this message translates to:
  /// **'تم الدفع'**
  String get paymentCompleted;

  /// No description provided for @processedViaGateway.
  ///
  /// In ar, this message translates to:
  /// **'تمت المعالجة عبر بوابة الدفع'**
  String get processedViaGateway;

  /// No description provided for @minutesAgoDetail.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} دقيقة'**
  String minutesAgoDetail(int count);

  /// No description provided for @invoiceCreated.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الفاتورة'**
  String get invoiceCreated;

  /// No description provided for @byUser.
  ///
  /// In ar, this message translates to:
  /// **'بواسطة {name}'**
  String byUser(String name);

  /// No description provided for @todayAt.
  ///
  /// In ar, this message translates to:
  /// **'اليوم، {time}'**
  String todayAt(String time);

  /// No description provided for @orderStarted.
  ///
  /// In ar, this message translates to:
  /// **'بداية الطلب'**
  String get orderStarted;

  /// No description provided for @cashierSessionOpened.
  ///
  /// In ar, this message translates to:
  /// **'فتح جلسة الكاشير'**
  String get cashierSessionOpened;

  /// No description provided for @technicalData.
  ///
  /// In ar, this message translates to:
  /// **'البيانات الفنية'**
  String get technicalData;

  /// No description provided for @deviceIdLabel.
  ///
  /// In ar, this message translates to:
  /// **'Device ID'**
  String get deviceIdLabel;

  /// No description provided for @terminalLabel.
  ///
  /// In ar, this message translates to:
  /// **'Terminal'**
  String get terminalLabel;

  /// No description provided for @softwareVersion.
  ///
  /// In ar, this message translates to:
  /// **'Software V'**
  String get softwareVersion;

  /// No description provided for @voidInvoiceConfirm.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الفاتورة؟'**
  String get voidInvoiceConfirm;

  /// No description provided for @voidInvoiceMsg.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إلغاء هذه الفاتورة نهائياً ولن يتم احتسابها في المبيعات اليومية. هل أنت متأكد؟'**
  String get voidInvoiceMsg;

  /// No description provided for @voidReasonLabel.
  ///
  /// In ar, this message translates to:
  /// **'سبب الإلغاء (مطلوب)'**
  String get voidReasonLabel;

  /// No description provided for @voidReasonEntry.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الإدخال'**
  String get voidReasonEntry;

  /// No description provided for @voidReasonCustomer.
  ///
  /// In ar, this message translates to:
  /// **'طلب العميل'**
  String get voidReasonCustomer;

  /// No description provided for @voidReasonDamaged.
  ///
  /// In ar, this message translates to:
  /// **'منتج تالف'**
  String get voidReasonDamaged;

  /// No description provided for @voidReasonOther.
  ///
  /// In ar, this message translates to:
  /// **'سبب آخر...'**
  String get voidReasonOther;

  /// No description provided for @confirmVoid.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الإلغاء'**
  String get confirmVoid;

  /// No description provided for @invoiceVoided.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الفاتورة بنجاح'**
  String get invoiceVoided;

  /// No description provided for @copiedText.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ: {text}'**
  String copiedText(String text);

  /// No description provided for @visaEnding.
  ///
  /// In ar, this message translates to:
  /// **'Visa ينتهي بـ {digits}'**
  String visaEnding(String digits);

  /// No description provided for @mobileActionPrint.
  ///
  /// In ar, this message translates to:
  /// **'طباعة'**
  String get mobileActionPrint;

  /// No description provided for @mobileActionWhatsapp.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get mobileActionWhatsapp;

  /// No description provided for @mobileActionEmail.
  ///
  /// In ar, this message translates to:
  /// **'بريد'**
  String get mobileActionEmail;

  /// No description provided for @mobileActionMore.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get mobileActionMore;

  /// No description provided for @sarCurrency.
  ///
  /// In ar, this message translates to:
  /// **'ر.س'**
  String get sarCurrency;

  /// No description provided for @skuLabel.
  ///
  /// In ar, this message translates to:
  /// **'SKU: {code}'**
  String skuLabel(String code);

  /// No description provided for @helpText.
  ///
  /// In ar, this message translates to:
  /// **'مساعدة'**
  String get helpText;

  /// No description provided for @customerLedger.
  ///
  /// In ar, this message translates to:
  /// **'كشف حساب العميل'**
  String get customerLedger;

  /// No description provided for @accountStatement.
  ///
  /// In ar, this message translates to:
  /// **'كشف حساب'**
  String get accountStatement;

  /// No description provided for @allPeriods.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get allPeriods;

  /// No description provided for @threeMonths.
  ///
  /// In ar, this message translates to:
  /// **'3 أشهر'**
  String get threeMonths;

  /// No description provided for @allMovements.
  ///
  /// In ar, this message translates to:
  /// **'كل الحركات'**
  String get allMovements;

  /// No description provided for @adjustments.
  ///
  /// In ar, this message translates to:
  /// **'تسويات'**
  String get adjustments;

  /// No description provided for @statementCol.
  ///
  /// In ar, this message translates to:
  /// **'البيان'**
  String get statementCol;

  /// No description provided for @referenceCol.
  ///
  /// In ar, this message translates to:
  /// **'المرجع'**
  String get referenceCol;

  /// No description provided for @debitCol.
  ///
  /// In ar, this message translates to:
  /// **'مدين'**
  String get debitCol;

  /// No description provided for @creditCol.
  ///
  /// In ar, this message translates to:
  /// **'دائن'**
  String get creditCol;

  /// No description provided for @balanceCol.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد'**
  String get balanceCol;

  /// No description provided for @openingBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيد افتتاحي'**
  String get openingBalance;

  /// No description provided for @totalDebit.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المدين'**
  String get totalDebit;

  /// No description provided for @totalCredit.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الدائن'**
  String get totalCredit;

  /// No description provided for @finalBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد النهائي'**
  String get finalBalance;

  /// No description provided for @manualAdjustment.
  ///
  /// In ar, this message translates to:
  /// **'تسوية يدوية'**
  String get manualAdjustment;

  /// No description provided for @adjustmentType.
  ///
  /// In ar, this message translates to:
  /// **'نوع التعديل'**
  String get adjustmentType;

  /// No description provided for @debitAdjustment.
  ///
  /// In ar, this message translates to:
  /// **'تسوية مدينة'**
  String get debitAdjustment;

  /// No description provided for @creditAdjustment.
  ///
  /// In ar, this message translates to:
  /// **'تسوية دائنة'**
  String get creditAdjustment;

  /// No description provided for @adjustmentAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ التسوية'**
  String get adjustmentAmount;

  /// No description provided for @adjustmentReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب التعديل'**
  String get adjustmentReason;

  /// No description provided for @adjustmentDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ التسوية'**
  String get adjustmentDate;

  /// No description provided for @saveAdjustment.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديل'**
  String get saveAdjustment;

  /// No description provided for @adjustmentSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التسوية بنجاح'**
  String get adjustmentSaved;

  /// No description provided for @enterValidAmount.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مبلغاً صحيحاً'**
  String get enterValidAmount;

  /// No description provided for @dueOnCustomer.
  ///
  /// In ar, this message translates to:
  /// **'مستحق على العميل'**
  String get dueOnCustomer;

  /// No description provided for @customerHasCredit.
  ///
  /// In ar, this message translates to:
  /// **'للعميل رصيد دائن'**
  String get customerHasCredit;

  /// No description provided for @noTransactions.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حركات'**
  String get noTransactions;

  /// No description provided for @recordPaymentBtn.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل دفعة'**
  String get recordPaymentBtn;

  /// No description provided for @returnEntry.
  ///
  /// In ar, this message translates to:
  /// **'مرتجع'**
  String get returnEntry;

  /// No description provided for @adjustmentEntry.
  ///
  /// In ar, this message translates to:
  /// **'تسوية'**
  String get adjustmentEntry;

  /// No description provided for @ordersHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الطلبات'**
  String get ordersHistory;

  /// No description provided for @totalOrdersLabel.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الطلبات'**
  String get totalOrdersLabel;

  /// No description provided for @completedOrders.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get completedOrders;

  /// No description provided for @pendingOrders.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get pendingOrders;

  /// No description provided for @cancelledOrders.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get cancelledOrders;

  /// No description provided for @searchOrderHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث برقم الطلب، اسم العميل، أو الهاتف...'**
  String get searchOrderHint;

  /// No description provided for @channelLabel.
  ///
  /// In ar, this message translates to:
  /// **'القناة'**
  String get channelLabel;

  /// No description provided for @last30Days.
  ///
  /// In ar, this message translates to:
  /// **'آخر 30 يوم'**
  String get last30Days;

  /// No description provided for @orderDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الطلب'**
  String get orderDetails;

  /// No description provided for @unpaidLabel.
  ///
  /// In ar, this message translates to:
  /// **'غير مدفوع'**
  String get unpaidLabel;

  /// No description provided for @voidTransaction.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء عملية'**
  String get voidTransaction;

  /// No description provided for @voidSaleTransaction.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء عملية بيع'**
  String get voidSaleTransaction;

  /// No description provided for @voidWarningTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحذير هام: هذا الإجراء لا يمكن التراجع عنه'**
  String get voidWarningTitle;

  /// No description provided for @voidWarningDesc.
  ///
  /// In ar, this message translates to:
  /// **'سيؤدي إلغاء هذه العملية إلى إلغاء الفاتورة بالكامل وإرجاع جميع الأصناف للمخزون. يرجى التأكد من صحة المعلومات قبل المتابعة.'**
  String get voidWarningDesc;

  /// No description provided for @voidWarningShort.
  ///
  /// In ar, this message translates to:
  /// **'هذا الإجراء سيلغي الفاتورة بالكامل ويعيد الأصناف للمخزون. لا يمكن التراجع عنه.'**
  String get voidWarningShort;

  /// No description provided for @enterInvoiceToVoid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم الفاتورة للإلغاء'**
  String get enterInvoiceToVoid;

  /// No description provided for @searchByInvoiceOrBarcode.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك البحث برقم الفاتورة أو استخدام الماسح الضوئي للباركود'**
  String get searchByInvoiceOrBarcode;

  /// No description provided for @invoiceExampleVoid.
  ///
  /// In ar, this message translates to:
  /// **'مثال: #INV-2024-8892'**
  String get invoiceExampleVoid;

  /// No description provided for @activateBarcode.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الماسح الضوئي'**
  String get activateBarcode;

  /// No description provided for @scanBarcodeMobile.
  ///
  /// In ar, this message translates to:
  /// **'مسح باركود'**
  String get scanBarcodeMobile;

  /// No description provided for @searchForInvoiceToVoid.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن فاتورة للإلغاء'**
  String get searchForInvoiceToVoid;

  /// No description provided for @enterNumberOrScan.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرقم يدوياً أو استخدم الماسح الضوئي.'**
  String get enterNumberOrScan;

  /// No description provided for @salesInvoice.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة مبيعات'**
  String get salesInvoice;

  /// No description provided for @invoiceCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get invoiceCompleted;

  /// No description provided for @paidCash.
  ///
  /// In ar, this message translates to:
  /// **'تم الدفع: نقداً'**
  String get paidCash;

  /// No description provided for @customerLabel.
  ///
  /// In ar, this message translates to:
  /// **'عميل'**
  String get customerLabel;

  /// No description provided for @dateAndTimeLabel.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ والوقت'**
  String get dateAndTimeLabel;

  /// No description provided for @voidImpactSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص أثر الإلغاء'**
  String get voidImpactSummary;

  /// No description provided for @voidImpactItemsReturn.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إعادة {count} أصناف للمخزون تلقائياً.'**
  String voidImpactItemsReturn(int count);

  /// No description provided for @voidImpactRefund.
  ///
  /// In ar, this message translates to:
  /// **'سيتم خصم/إرجاع مبلغ {amount} {currency}.'**
  String voidImpactRefund(String amount, String currency);

  /// No description provided for @returnedItems.
  ///
  /// In ar, this message translates to:
  /// **'الأصناف المرتجعة'**
  String returnedItems(int count);

  /// No description provided for @viewAllItems.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAllItems;

  /// No description provided for @moreItemsHint.
  ///
  /// In ar, this message translates to:
  /// **'+ {count} أصناف أخرى (مجموع: {amount} {currency})'**
  String moreItemsHint(int count, String amount, String currency);

  /// No description provided for @voidReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب الإلغاء'**
  String get voidReason;

  /// No description provided for @voidReasonRequired.
  ///
  /// In ar, this message translates to:
  /// **'سبب الإلغاء *'**
  String get voidReasonRequired;

  /// No description provided for @customerRequestReason.
  ///
  /// In ar, this message translates to:
  /// **'طلب من العميل'**
  String get customerRequestReason;

  /// No description provided for @wrongItemsReason.
  ///
  /// In ar, this message translates to:
  /// **'أصناف خاطئة'**
  String get wrongItemsReason;

  /// No description provided for @duplicateInvoiceReason.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة مكررة'**
  String get duplicateInvoiceReason;

  /// No description provided for @systemErrorReason.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في النظام'**
  String get systemErrorReason;

  /// No description provided for @otherReasonVoid.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get otherReasonVoid;

  /// No description provided for @additionalNotesVoid.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات إضافية...'**
  String get additionalNotesVoid;

  /// No description provided for @additionalDetailsRequired.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل إضافية (مطلوب عند اختيار أخرى)...'**
  String get additionalDetailsRequired;

  /// No description provided for @managerApproval.
  ///
  /// In ar, this message translates to:
  /// **'موافقة المدير'**
  String get managerApproval;

  /// No description provided for @managerApprovalRequired.
  ///
  /// In ar, this message translates to:
  /// **'موافقة المدير مطلوبة'**
  String get managerApprovalRequired;

  /// No description provided for @amountExceedsLimit.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ يتجاوز الحد المسموح به ({amount} {currency})، يرجى إدخال رمز PIN للمدير.'**
  String amountExceedsLimit(String amount, String currency);

  /// No description provided for @enterPinCode.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز PIN'**
  String get enterPinCode;

  /// No description provided for @pinSentToManager.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رمز مؤقت إلى جوال المدير'**
  String get pinSentToManager;

  /// No description provided for @defaultManagerPin.
  ///
  /// In ar, this message translates to:
  /// **'رمز المدير الافتراضي: 1234'**
  String get defaultManagerPin;

  /// No description provided for @confirmVoidAction.
  ///
  /// In ar, this message translates to:
  /// **'أؤكد إلغاء هذه العملية'**
  String get confirmVoidAction;

  /// No description provided for @confirmVoidDesc.
  ///
  /// In ar, this message translates to:
  /// **'لقد اطلعت على التفاصيل وأتحمل المسؤولية الكاملة.'**
  String get confirmVoidDesc;

  /// No description provided for @cancelAction.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancelAction;

  /// No description provided for @confirmFinalVoid.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الإلغاء النهائي'**
  String get confirmFinalVoid;

  /// No description provided for @invoiceNotFound.
  ///
  /// In ar, this message translates to:
  /// **'الفاتورة غير موجودة'**
  String get invoiceNotFound;

  /// No description provided for @invoiceNotFoundDesc.
  ///
  /// In ar, this message translates to:
  /// **'تأكد من صحة الرقم المدخل أو حاول البحث باستخدام الباركود.'**
  String get invoiceNotFoundDesc;

  /// No description provided for @trySearchAgain.
  ///
  /// In ar, this message translates to:
  /// **'محاولة البحث مرة أخرى'**
  String get trySearchAgain;

  /// No description provided for @voidSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء العملية بنجاح'**
  String get voidSuccess;

  /// No description provided for @qtyLabel.
  ///
  /// In ar, this message translates to:
  /// **'الكمية: {count}'**
  String qtyLabel(int count);

  /// No description provided for @manageCustomersAndAccounts.
  ///
  /// In ar, this message translates to:
  /// **'إدارة العملاء والحسابات'**
  String get manageCustomersAndAccounts;

  /// No description provided for @totalCustomersCount.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي العملاء'**
  String get totalCustomersCount;

  /// No description provided for @outstandingDebts.
  ///
  /// In ar, this message translates to:
  /// **'ديون مستحقة'**
  String get outstandingDebts;

  /// No description provided for @creditBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيد للعملاء'**
  String get creditBalance;

  /// No description provided for @filterByLabel.
  ///
  /// In ar, this message translates to:
  /// **'تصفية حسب'**
  String get filterByLabel;

  /// No description provided for @debtors.
  ///
  /// In ar, this message translates to:
  /// **'عليهم ديون'**
  String get debtors;

  /// No description provided for @creditorsLabel.
  ///
  /// In ar, this message translates to:
  /// **'لهم رصيد'**
  String get creditorsLabel;

  /// No description provided for @quickActionsLabel.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات سريعة'**
  String get quickActionsLabel;

  /// No description provided for @sendDebtReminder.
  ///
  /// In ar, this message translates to:
  /// **'إرسال تذكير للمديونين'**
  String get sendDebtReminder;

  /// No description provided for @exportAccountStatement.
  ///
  /// In ar, this message translates to:
  /// **'تصدير كشف الحسابات'**
  String get exportAccountStatement;

  /// No description provided for @cancelSelectionCount.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء التحديد ({count})'**
  String cancelSelectionCount(String count);

  /// No description provided for @searchByNameOrPhone.
  ///
  /// In ar, this message translates to:
  /// **'بحث بالاسم أو الهاتف... (Ctrl+F)'**
  String get searchByNameOrPhone;

  /// No description provided for @sortByBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد'**
  String get sortByBalance;

  /// No description provided for @refreshF5.
  ///
  /// In ar, this message translates to:
  /// **'تحديث (F5)'**
  String get refreshF5;

  /// No description provided for @loadingCustomers.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل العملاء...'**
  String get loadingCustomers;

  /// No description provided for @payDebt.
  ///
  /// In ar, this message translates to:
  /// **'تسديد دين'**
  String get payDebt;

  /// No description provided for @dueAmountLabel.
  ///
  /// In ar, this message translates to:
  /// **'المستحق: {amount} ر.س'**
  String dueAmountLabel(String amount);

  /// No description provided for @paymentAmountLabel.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ السداد'**
  String get paymentAmountLabel;

  /// No description provided for @fullAmount.
  ///
  /// In ar, this message translates to:
  /// **'كامل'**
  String get fullAmount;

  /// No description provided for @payAction.
  ///
  /// In ar, this message translates to:
  /// **'تسديد'**
  String get payAction;

  /// No description provided for @paymentRecorded.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل سداد {amount} ر.س'**
  String paymentRecorded(String amount);

  /// No description provided for @customerAddedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة {name}'**
  String customerAddedSuccess(String name);

  /// No description provided for @customerNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'اسم العميل *'**
  String get customerNameRequired;

  /// No description provided for @owedLabel.
  ///
  /// In ar, this message translates to:
  /// **'عليه'**
  String get owedLabel;

  /// No description provided for @hasBalanceLabel.
  ///
  /// In ar, this message translates to:
  /// **'له'**
  String get hasBalanceLabel;

  /// No description provided for @zeroLabel.
  ///
  /// In ar, this message translates to:
  /// **'صفر'**
  String get zeroLabel;

  /// No description provided for @addAction.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get addAction;

  /// No description provided for @expenses.
  ///
  /// In ar, this message translates to:
  /// **'المصروفات'**
  String get expenses;

  /// No description provided for @expenseCategories.
  ///
  /// In ar, this message translates to:
  /// **'تصنيفات المصروفات'**
  String get expenseCategories;

  /// No description provided for @addExpense.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مصروف'**
  String get addExpense;

  /// No description provided for @totalExpenses.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المصروفات'**
  String get totalExpenses;

  /// No description provided for @thisMonthExpenses.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر'**
  String get thisMonthExpenses;

  /// No description provided for @expenseAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get expenseAmount;

  /// No description provided for @expenseDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get expenseDate;

  /// No description provided for @expenseCategory.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get expenseCategory;

  /// No description provided for @expenseNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get expenseNotes;

  /// No description provided for @noExpenses.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مصروفات مسجلة'**
  String get noExpenses;

  /// No description provided for @drawerStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الدرج'**
  String get drawerStatus;

  /// No description provided for @drawerOpen.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح'**
  String get drawerOpen;

  /// No description provided for @drawerClosed.
  ///
  /// In ar, this message translates to:
  /// **'مغلق'**
  String get drawerClosed;

  /// No description provided for @cashIn.
  ///
  /// In ar, this message translates to:
  /// **'إيداع نقدي'**
  String get cashIn;

  /// No description provided for @cashOut.
  ///
  /// In ar, this message translates to:
  /// **'سحب نقدي'**
  String get cashOut;

  /// No description provided for @expectedAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المتوقع'**
  String get expectedAmount;

  /// No description provided for @countedAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المحسوب'**
  String get countedAmount;

  /// No description provided for @difference.
  ///
  /// In ar, this message translates to:
  /// **'الفرق'**
  String get difference;

  /// No description provided for @openDrawerAction.
  ///
  /// In ar, this message translates to:
  /// **'فتح الدرج'**
  String get openDrawerAction;

  /// No description provided for @closeDrawerAction.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق الدرج'**
  String get closeDrawerAction;

  /// No description provided for @monthlyCloseTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإغلاق الشهري'**
  String get monthlyCloseTitle;

  /// No description provided for @monthlyCloseDesc.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق الشهر وحساب المستحقات'**
  String get monthlyCloseDesc;

  /// No description provided for @totalReceivables.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المستحقات'**
  String get totalReceivables;

  /// No description provided for @interestRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الفائدة'**
  String get interestRate;

  /// No description provided for @closeMonth.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق الشهر'**
  String get closeMonth;

  /// No description provided for @shiftsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الورديات'**
  String get shiftsTitle;

  /// No description provided for @currentShift.
  ///
  /// In ar, this message translates to:
  /// **'الوردية الحالية'**
  String get currentShift;

  /// No description provided for @shiftHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الورديات'**
  String get shiftHistory;

  /// No description provided for @openShiftAction.
  ///
  /// In ar, this message translates to:
  /// **'فتح وردية'**
  String get openShiftAction;

  /// No description provided for @closeShiftAction.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق وردية'**
  String get closeShiftAction;

  /// No description provided for @shiftStartTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت البدء'**
  String get shiftStartTime;

  /// No description provided for @shiftEndTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت الانتهاء'**
  String get shiftEndTime;

  /// No description provided for @shiftTotalSales.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المبيعات'**
  String get shiftTotalSales;

  /// No description provided for @shiftTotalOrders.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الطلبات'**
  String get shiftTotalOrders;

  /// No description provided for @startingCash.
  ///
  /// In ar, this message translates to:
  /// **'النقد الابتدائي'**
  String get startingCash;

  /// No description provided for @cashierName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الكاشير'**
  String get cashierName;

  /// No description provided for @shiftDuration.
  ///
  /// In ar, this message translates to:
  /// **'المدة'**
  String get shiftDuration;

  /// No description provided for @noShifts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ورديات مسجلة'**
  String get noShifts;

  /// No description provided for @purchasesTitle.
  ///
  /// In ar, this message translates to:
  /// **'المشتريات'**
  String get purchasesTitle;

  /// No description provided for @newPurchase.
  ///
  /// In ar, this message translates to:
  /// **'مشترى جديد'**
  String get newPurchase;

  /// No description provided for @smartReorder.
  ///
  /// In ar, this message translates to:
  /// **'إعادة طلب ذكي'**
  String get smartReorder;

  /// No description provided for @aiInvoiceImport.
  ///
  /// In ar, this message translates to:
  /// **'استيراد فاتورة بالذكاء الاصطناعي'**
  String get aiInvoiceImport;

  /// No description provided for @aiInvoiceReview.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة فاتورة AI'**
  String get aiInvoiceReview;

  /// No description provided for @purchaseOrder.
  ///
  /// In ar, this message translates to:
  /// **'أمر شراء'**
  String get purchaseOrder;

  /// No description provided for @purchaseTotal.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المشتريات'**
  String get purchaseTotal;

  /// No description provided for @purchaseDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الشراء'**
  String get purchaseDate;

  /// No description provided for @suppliersTitle.
  ///
  /// In ar, this message translates to:
  /// **'الموردين'**
  String get suppliersTitle;

  /// No description provided for @addSupplier.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مورد'**
  String get addSupplier;

  /// No description provided for @supplierName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المورد'**
  String get supplierName;

  /// No description provided for @supplierPhone.
  ///
  /// In ar, this message translates to:
  /// **'الهاتف'**
  String get supplierPhone;

  /// No description provided for @supplierEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get supplierEmail;

  /// No description provided for @supplierAddress.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get supplierAddress;

  /// No description provided for @totalSuppliers.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الموردين'**
  String get totalSuppliers;

  /// No description provided for @supplierDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المورد'**
  String get supplierDetails;

  /// No description provided for @noSuppliers.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد موردين'**
  String get noSuppliers;

  /// No description provided for @discountsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخصومات'**
  String get discountsTitle;

  /// No description provided for @addDiscount.
  ///
  /// In ar, this message translates to:
  /// **'إضافة خصم'**
  String get addDiscount;

  /// No description provided for @discountName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الخصم'**
  String get discountName;

  /// No description provided for @discountType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الخصم'**
  String get discountType;

  /// No description provided for @discountValue.
  ///
  /// In ar, this message translates to:
  /// **'القيمة'**
  String get discountValue;

  /// No description provided for @percentageDiscount.
  ///
  /// In ar, this message translates to:
  /// **'نسبة مئوية'**
  String get percentageDiscount;

  /// No description provided for @fixedDiscount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ ثابت'**
  String get fixedDiscount;

  /// No description provided for @activeDiscounts.
  ///
  /// In ar, this message translates to:
  /// **'الخصومات النشطة'**
  String get activeDiscounts;

  /// No description provided for @couponsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الكوبونات'**
  String get couponsTitle;

  /// No description provided for @addCoupon.
  ///
  /// In ar, this message translates to:
  /// **'إضافة كوبون'**
  String get addCoupon;

  /// No description provided for @couponCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز الكوبون'**
  String get couponCode;

  /// No description provided for @couponUsage.
  ///
  /// In ar, this message translates to:
  /// **'الاستخدام'**
  String get couponUsage;

  /// No description provided for @couponExpiry.
  ///
  /// In ar, this message translates to:
  /// **'الصلاحية'**
  String get couponExpiry;

  /// No description provided for @totalCoupons.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الكوبونات'**
  String get totalCoupons;

  /// No description provided for @activeCoupons.
  ///
  /// In ar, this message translates to:
  /// **'نشطة'**
  String get activeCoupons;

  /// No description provided for @expiredCoupons.
  ///
  /// In ar, this message translates to:
  /// **'منتهية'**
  String get expiredCoupons;

  /// No description provided for @specialOffersTitle.
  ///
  /// In ar, this message translates to:
  /// **'العروض الخاصة'**
  String get specialOffersTitle;

  /// No description provided for @addOffer.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عرض'**
  String get addOffer;

  /// No description provided for @offerName.
  ///
  /// In ar, this message translates to:
  /// **'اسم العرض'**
  String get offerName;

  /// No description provided for @offerStartDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ البدء'**
  String get offerStartDate;

  /// No description provided for @offerEndDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانتهاء'**
  String get offerEndDate;

  /// No description provided for @smartPromotionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'العروض الذكية'**
  String get smartPromotionsTitle;

  /// No description provided for @activePromotions.
  ///
  /// In ar, this message translates to:
  /// **'العروض النشطة'**
  String get activePromotions;

  /// No description provided for @suggestedPromotions.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات AI'**
  String get suggestedPromotions;

  /// No description provided for @loyaltyTitle.
  ///
  /// In ar, this message translates to:
  /// **'برنامج الولاء'**
  String get loyaltyTitle;

  /// No description provided for @loyaltyMembers.
  ///
  /// In ar, this message translates to:
  /// **'الأعضاء'**
  String get loyaltyMembers;

  /// No description provided for @loyaltyRewards.
  ///
  /// In ar, this message translates to:
  /// **'المكافآت'**
  String get loyaltyRewards;

  /// No description provided for @loyaltyTiers.
  ///
  /// In ar, this message translates to:
  /// **'المستويات'**
  String get loyaltyTiers;

  /// No description provided for @totalMembers.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأعضاء'**
  String get totalMembers;

  /// No description provided for @pointsIssued.
  ///
  /// In ar, this message translates to:
  /// **'النقاط الممنوحة'**
  String get pointsIssued;

  /// No description provided for @pointsRedeemed.
  ///
  /// In ar, this message translates to:
  /// **'النقاط المستبدلة'**
  String get pointsRedeemed;

  /// No description provided for @notificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationsTitle;

  /// No description provided for @markAllRead.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل كمقروء'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات'**
  String get noNotifications;

  /// No description provided for @printQueueTitle.
  ///
  /// In ar, this message translates to:
  /// **'قائمة الطباعة'**
  String get printQueueTitle;

  /// No description provided for @printAll.
  ///
  /// In ar, this message translates to:
  /// **'طباعة الكل'**
  String get printAll;

  /// No description provided for @cancelAll.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الكل'**
  String get cancelAll;

  /// No description provided for @noPrintJobs.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام طباعة'**
  String get noPrintJobs;

  /// No description provided for @syncStatusTitle.
  ///
  /// In ar, this message translates to:
  /// **'حالة المزامنة'**
  String get syncStatusTitle;

  /// No description provided for @lastSyncTime.
  ///
  /// In ar, this message translates to:
  /// **'آخر مزامنة'**
  String get lastSyncTime;

  /// No description provided for @pendingItems.
  ///
  /// In ar, this message translates to:
  /// **'عناصر معلقة'**
  String get pendingItems;

  /// No description provided for @syncNow.
  ///
  /// In ar, this message translates to:
  /// **'مزامنة الآن'**
  String get syncNow;

  /// No description provided for @pendingTransactionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'العمليات المعلقة'**
  String get pendingTransactionsTitle;

  /// No description provided for @conflictResolutionTitle.
  ///
  /// In ar, this message translates to:
  /// **'حل التعارضات'**
  String get conflictResolutionTitle;

  /// No description provided for @localValue.
  ///
  /// In ar, this message translates to:
  /// **'محلي'**
  String get localValue;

  /// No description provided for @serverValue.
  ///
  /// In ar, this message translates to:
  /// **'الخادم'**
  String get serverValue;

  /// No description provided for @keepLocal.
  ///
  /// In ar, this message translates to:
  /// **'الاحتفاظ بالمحلي'**
  String get keepLocal;

  /// No description provided for @keepServer.
  ///
  /// In ar, this message translates to:
  /// **'الاحتفاظ بالخادم'**
  String get keepServer;

  /// No description provided for @driversTitle.
  ///
  /// In ar, this message translates to:
  /// **'السائقين'**
  String get driversTitle;

  /// No description provided for @addDriver.
  ///
  /// In ar, this message translates to:
  /// **'إضافة سائق'**
  String get addDriver;

  /// No description provided for @driverName.
  ///
  /// In ar, this message translates to:
  /// **'اسم السائق'**
  String get driverName;

  /// No description provided for @driverStatus.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get driverStatus;

  /// No description provided for @delivering.
  ///
  /// In ar, this message translates to:
  /// **'في التوصيل'**
  String get delivering;

  /// No description provided for @totalDeliveries.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي التوصيلات'**
  String get totalDeliveries;

  /// No description provided for @driverRating.
  ///
  /// In ar, this message translates to:
  /// **'التقييم'**
  String get driverRating;

  /// No description provided for @branchesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الفروع'**
  String get branchesTitle;

  /// No description provided for @addBranchAction.
  ///
  /// In ar, this message translates to:
  /// **'إضافة فرع'**
  String get addBranchAction;

  /// No description provided for @branchName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الفرع'**
  String get branchName;

  /// No description provided for @branchEmployees.
  ///
  /// In ar, this message translates to:
  /// **'الموظفين'**
  String get branchEmployees;

  /// No description provided for @branchSales.
  ///
  /// In ar, this message translates to:
  /// **'مبيعات اليوم'**
  String get branchSales;

  /// No description provided for @profileTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profileTitle;

  /// No description provided for @editProfile.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف'**
  String get editProfile;

  /// No description provided for @personalInfo.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الشخصية'**
  String get personalInfo;

  /// No description provided for @accountSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الحساب'**
  String get accountSettings;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// No description provided for @emailAddress.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get emailAddress;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// No description provided for @role.
  ///
  /// In ar, this message translates to:
  /// **'الدور'**
  String get role;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @storeSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات المتجر'**
  String get storeSettings;

  /// No description provided for @posSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات نقطة البيع'**
  String get posSettings;

  /// No description provided for @printerSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الطابعة'**
  String get printerSettings;

  /// No description provided for @paymentDevicesSettings.
  ///
  /// In ar, this message translates to:
  /// **'أجهزة الدفع'**
  String get paymentDevicesSettings;

  /// No description provided for @barcodeSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الباركود'**
  String get barcodeSettings;

  /// No description provided for @receiptTemplate.
  ///
  /// In ar, this message translates to:
  /// **'قالب الإيصال'**
  String get receiptTemplate;

  /// No description provided for @taxSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الضرائب'**
  String get taxSettings;

  /// No description provided for @discountSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الخصومات'**
  String get discountSettings;

  /// No description provided for @interestSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الفوائد'**
  String get interestSettings;

  /// No description provided for @languageSettings.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get languageSettings;

  /// No description provided for @themeSettings.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get themeSettings;

  /// No description provided for @securitySettings.
  ///
  /// In ar, this message translates to:
  /// **'الأمان'**
  String get securitySettings;

  /// No description provided for @usersManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المستخدمين'**
  String get usersManagement;

  /// No description provided for @rolesPermissions.
  ///
  /// In ar, this message translates to:
  /// **'الأدوار والصلاحيات'**
  String get rolesPermissions;

  /// No description provided for @activityLog.
  ///
  /// In ar, this message translates to:
  /// **'سجل النشاط'**
  String get activityLog;

  /// No description provided for @backupSettings.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي والاستعادة'**
  String get backupSettings;

  /// No description provided for @notificationSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationSettings;

  /// No description provided for @zatcaCompliance.
  ///
  /// In ar, this message translates to:
  /// **'امتثال هيئة الزكاة والضريبة'**
  String get zatcaCompliance;

  /// No description provided for @helpSupport.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة والدعم'**
  String get helpSupport;

  /// No description provided for @general.
  ///
  /// In ar, this message translates to:
  /// **'عام'**
  String get general;

  /// No description provided for @appearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearance;

  /// No description provided for @securitySection.
  ///
  /// In ar, this message translates to:
  /// **'الأمان'**
  String get securitySection;

  /// No description provided for @advanced.
  ///
  /// In ar, this message translates to:
  /// **'متقدم'**
  String get advanced;

  /// No description provided for @enabled.
  ///
  /// In ar, this message translates to:
  /// **'مفعّل'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In ar, this message translates to:
  /// **'معطّل'**
  String get disabled;

  /// No description provided for @configure.
  ///
  /// In ar, this message translates to:
  /// **'تهيئة'**
  String get configure;

  /// No description provided for @connected.
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get connected;

  /// No description provided for @notConnected.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get notConnected;

  /// No description provided for @testConnection.
  ///
  /// In ar, this message translates to:
  /// **'اختبار الاتصال'**
  String get testConnection;

  /// No description provided for @lastBackup.
  ///
  /// In ar, this message translates to:
  /// **'آخر نسخة احتياطية'**
  String get lastBackup;

  /// No description provided for @autoBackup.
  ///
  /// In ar, this message translates to:
  /// **'نسخ احتياطي تلقائي'**
  String get autoBackup;

  /// No description provided for @manualBackup.
  ///
  /// In ar, this message translates to:
  /// **'نسخ احتياطي الآن'**
  String get manualBackup;

  /// No description provided for @restoreBackup.
  ///
  /// In ar, this message translates to:
  /// **'استعادة'**
  String get restoreBackup;

  /// No description provided for @biometricAuth.
  ///
  /// In ar, this message translates to:
  /// **'المصادقة البيومترية'**
  String get biometricAuth;

  /// No description provided for @sessionTimeout.
  ///
  /// In ar, this message translates to:
  /// **'مهلة الجلسة'**
  String get sessionTimeout;

  /// No description provided for @changePin.
  ///
  /// In ar, this message translates to:
  /// **'تغيير رمز PIN'**
  String get changePin;

  /// No description provided for @twoFactorAuth.
  ///
  /// In ar, this message translates to:
  /// **'المصادقة الثنائية'**
  String get twoFactorAuth;

  /// No description provided for @addUser.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مستخدم'**
  String get addUser;

  /// No description provided for @userName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get userName;

  /// No description provided for @userEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get userEmail;

  /// No description provided for @userPhone.
  ///
  /// In ar, this message translates to:
  /// **'الهاتف'**
  String get userPhone;

  /// No description provided for @addRole.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دور'**
  String get addRole;

  /// No description provided for @roleName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الدور'**
  String get roleName;

  /// No description provided for @permissions.
  ///
  /// In ar, this message translates to:
  /// **'الصلاحيات'**
  String get permissions;

  /// No description provided for @faq.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة الشائعة'**
  String get faq;

  /// No description provided for @contactSupport.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع الدعم'**
  String get contactSupport;

  /// No description provided for @documentation.
  ///
  /// In ar, this message translates to:
  /// **'التوثيق'**
  String get documentation;

  /// No description provided for @reportBug.
  ///
  /// In ar, this message translates to:
  /// **'الإبلاغ عن خطأ'**
  String get reportBug;

  /// No description provided for @zatcaRegistration.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل هيئة الزكاة'**
  String get zatcaRegistration;

  /// No description provided for @eInvoicing.
  ///
  /// In ar, this message translates to:
  /// **'الفوترة الإلكترونية'**
  String get eInvoicing;

  /// No description provided for @qrCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز QR'**
  String get qrCode;

  /// No description provided for @vatNumber.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الضريبي'**
  String get vatNumber;

  /// No description provided for @taxNumber.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الضريبي'**
  String get taxNumber;

  /// No description provided for @pushNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات الدفع'**
  String get pushNotifications;

  /// No description provided for @emailNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات البريد'**
  String get emailNotifications;

  /// No description provided for @smsNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات SMS'**
  String get smsNotifications;

  /// No description provided for @orderNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات الطلبات'**
  String get orderNotifications;

  /// No description provided for @stockNotifications.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات المخزون'**
  String get stockNotifications;

  /// No description provided for @paymentNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات الدفع'**
  String get paymentNotifications;

  /// No description provided for @liveChat.
  ///
  /// In ar, this message translates to:
  /// **'محادثة مباشرة'**
  String get liveChat;

  /// No description provided for @emailSupport.
  ///
  /// In ar, this message translates to:
  /// **'دعم البريد الإلكتروني'**
  String get emailSupport;

  /// No description provided for @phoneSupport.
  ///
  /// In ar, this message translates to:
  /// **'دعم الهاتف'**
  String get phoneSupport;

  /// No description provided for @whatsappSupport.
  ///
  /// In ar, this message translates to:
  /// **'دعم واتساب'**
  String get whatsappSupport;

  /// No description provided for @userGuide.
  ///
  /// In ar, this message translates to:
  /// **'دليل المستخدم'**
  String get userGuide;

  /// No description provided for @videoTutorials.
  ///
  /// In ar, this message translates to:
  /// **'فيديوهات تعليمية'**
  String get videoTutorials;

  /// No description provided for @changelog.
  ///
  /// In ar, this message translates to:
  /// **'سجل التحديثات'**
  String get changelog;

  /// No description provided for @appInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات التطبيق'**
  String get appInfo;

  /// No description provided for @buildNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم البناء'**
  String get buildNumber;

  /// No description provided for @notificationChannels.
  ///
  /// In ar, this message translates to:
  /// **'قنوات الإشعارات'**
  String get notificationChannels;

  /// No description provided for @alertTypes.
  ///
  /// In ar, this message translates to:
  /// **'أنواع التنبيهات'**
  String get alertTypes;

  /// No description provided for @salesAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات المبيعات'**
  String get salesAlerts;

  /// No description provided for @inventoryAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات المخزون'**
  String get inventoryAlerts;

  /// No description provided for @securityAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الأمان'**
  String get securityAlerts;

  /// No description provided for @reportAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات التقارير'**
  String get reportAlerts;

  /// No description provided for @users.
  ///
  /// In ar, this message translates to:
  /// **'المستخدمون'**
  String get users;

  /// No description provided for @zatcaRegistered.
  ///
  /// In ar, this message translates to:
  /// **'مسجل في هيئة الزكاة والضريبة'**
  String get zatcaRegistered;

  /// No description provided for @zatcaPhase2Active.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة الثانية نشطة'**
  String get zatcaPhase2Active;

  /// No description provided for @registrationInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات التسجيل'**
  String get registrationInfo;

  /// No description provided for @businessName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المنشأة'**
  String get businessName;

  /// No description provided for @branchCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز الفرع'**
  String get branchCode;

  /// No description provided for @qrCodeOnInvoice.
  ///
  /// In ar, this message translates to:
  /// **'يظهر رمز QR على كل فاتورة'**
  String get qrCodeOnInvoice;

  /// No description provided for @certificates.
  ///
  /// In ar, this message translates to:
  /// **'الشهادات'**
  String get certificates;

  /// No description provided for @csidCertificate.
  ///
  /// In ar, this message translates to:
  /// **'شهادة CSID'**
  String get csidCertificate;

  /// No description provided for @valid.
  ///
  /// In ar, this message translates to:
  /// **'صالحة'**
  String get valid;

  /// No description provided for @privateKey.
  ///
  /// In ar, this message translates to:
  /// **'المفتاح الخاص'**
  String get privateKey;

  /// No description provided for @configured.
  ///
  /// In ar, this message translates to:
  /// **'مهيأ'**
  String get configured;

  /// No description provided for @aiSection.
  ///
  /// In ar, this message translates to:
  /// **'الذكاء الاصطناعي'**
  String get aiSection;

  /// No description provided for @aiAssistantTitle.
  ///
  /// In ar, this message translates to:
  /// **'المساعد الذكي'**
  String get aiAssistantTitle;

  /// No description provided for @aiAssistantSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اسأل مساعدك الذكي أي شيء عن متجرك'**
  String get aiAssistantSubtitle;

  /// No description provided for @aiSalesForecastingTitle.
  ///
  /// In ar, this message translates to:
  /// **'التنبؤ بالمبيعات'**
  String get aiSalesForecastingTitle;

  /// No description provided for @aiSalesForecastingSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'توقع المبيعات المستقبلية باستخدام البيانات التاريخية'**
  String get aiSalesForecastingSubtitle;

  /// No description provided for @aiSmartPricingTitle.
  ///
  /// In ar, this message translates to:
  /// **'التسعير الذكي'**
  String get aiSmartPricingTitle;

  /// No description provided for @aiSmartPricingSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات تحسين الأسعار بالذكاء الاصطناعي'**
  String get aiSmartPricingSubtitle;

  /// No description provided for @aiFraudDetectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'كشف الاحتيال'**
  String get aiFraudDetectionTitle;

  /// No description provided for @aiFraudDetectionSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'كشف الأنماط المشبوهة وحماية أعمالك'**
  String get aiFraudDetectionSubtitle;

  /// No description provided for @aiBasketAnalysisTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحليل السلة'**
  String get aiBasketAnalysisTitle;

  /// No description provided for @aiBasketAnalysisSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اكتشف المنتجات المُشتراة معاً بشكل متكرر'**
  String get aiBasketAnalysisSubtitle;

  /// No description provided for @aiCustomerRecommendationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'توصيات العملاء'**
  String get aiCustomerRecommendationsTitle;

  /// No description provided for @aiCustomerRecommendationsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات منتجات مخصصة لكل عميل'**
  String get aiCustomerRecommendationsSubtitle;

  /// No description provided for @aiSmartInventoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'المخزون الذكي'**
  String get aiSmartInventoryTitle;

  /// No description provided for @aiSmartInventorySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مستويات المخزون المثالية والتنبؤ بالهدر'**
  String get aiSmartInventorySubtitle;

  /// No description provided for @aiCompetitorAnalysisTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحليل المنافسين'**
  String get aiCompetitorAnalysisTitle;

  /// No description provided for @aiCompetitorAnalysisSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قارن أسعارك مع المنافسين'**
  String get aiCompetitorAnalysisSubtitle;

  /// No description provided for @aiSmartReportsTitle.
  ///
  /// In ar, this message translates to:
  /// **'التقارير الذكية'**
  String get aiSmartReportsTitle;

  /// No description provided for @aiSmartReportsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ تقارير باستخدام اللغة الطبيعية'**
  String get aiSmartReportsSubtitle;

  /// No description provided for @aiStaffAnalyticsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحليل الموظفين'**
  String get aiStaffAnalyticsTitle;

  /// No description provided for @aiStaffAnalyticsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تحليل أداء الموظفين وتحسين الجدولة'**
  String get aiStaffAnalyticsSubtitle;

  /// No description provided for @aiProductRecognitionTitle.
  ///
  /// In ar, this message translates to:
  /// **'التعرف على المنتجات'**
  String get aiProductRecognitionTitle;

  /// No description provided for @aiProductRecognitionSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تعرّف على المنتجات باستخدام الكاميرا'**
  String get aiProductRecognitionSubtitle;

  /// No description provided for @aiSentimentAnalysisTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحليل المشاعر'**
  String get aiSentimentAnalysisTitle;

  /// No description provided for @aiSentimentAnalysisSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تحليل ملاحظات العملاء ومستوى الرضا'**
  String get aiSentimentAnalysisSubtitle;

  /// No description provided for @aiReturnPredictionTitle.
  ///
  /// In ar, this message translates to:
  /// **'التنبؤ بالمرتجعات'**
  String get aiReturnPredictionTitle;

  /// No description provided for @aiReturnPredictionSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'توقع ومنع إرجاع المنتجات'**
  String get aiReturnPredictionSubtitle;

  /// No description provided for @aiPromotionDesignerTitle.
  ///
  /// In ar, this message translates to:
  /// **'مصمم العروض'**
  String get aiPromotionDesignerTitle;

  /// No description provided for @aiPromotionDesignerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'عروض مولّدة بالذكاء الاصطناعي مع توقع العائد'**
  String get aiPromotionDesignerSubtitle;

  /// No description provided for @aiChatWithDataTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدردشة مع البيانات'**
  String get aiChatWithDataTitle;

  /// No description provided for @aiChatWithDataSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استعلم عن بياناتك باللغة الطبيعية'**
  String get aiChatWithDataSubtitle;

  /// No description provided for @aiConfidence.
  ///
  /// In ar, this message translates to:
  /// **'الثقة'**
  String get aiConfidence;

  /// No description provided for @aiHighConfidence.
  ///
  /// In ar, this message translates to:
  /// **'ثقة عالية'**
  String get aiHighConfidence;

  /// No description provided for @aiMediumConfidence.
  ///
  /// In ar, this message translates to:
  /// **'ثقة متوسطة'**
  String get aiMediumConfidence;

  /// No description provided for @aiLowConfidence.
  ///
  /// In ar, this message translates to:
  /// **'ثقة منخفضة'**
  String get aiLowConfidence;

  /// No description provided for @aiAnalyzing.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحليل...'**
  String get aiAnalyzing;

  /// No description provided for @aiGenerating.
  ///
  /// In ar, this message translates to:
  /// **'جاري الإنشاء...'**
  String get aiGenerating;

  /// No description provided for @aiNoData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات كافية للتحليل'**
  String get aiNoData;

  /// No description provided for @aiRefresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث التحليل'**
  String get aiRefresh;

  /// No description provided for @aiExport.
  ///
  /// In ar, this message translates to:
  /// **'تصدير النتائج'**
  String get aiExport;

  /// No description provided for @aiApply.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق الاقتراحات'**
  String get aiApply;

  /// No description provided for @aiDismiss.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get aiDismiss;

  /// No description provided for @aiViewDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get aiViewDetails;

  /// No description provided for @aiSuggestions.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات AI'**
  String get aiSuggestions;

  /// No description provided for @aiInsights.
  ///
  /// In ar, this message translates to:
  /// **'رؤى AI'**
  String get aiInsights;

  /// No description provided for @aiPrediction.
  ///
  /// In ar, this message translates to:
  /// **'تنبؤ'**
  String get aiPrediction;

  /// No description provided for @aiRecommendation.
  ///
  /// In ar, this message translates to:
  /// **'توصية'**
  String get aiRecommendation;

  /// No description provided for @aiAlert.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه'**
  String get aiAlert;

  /// No description provided for @aiWarning.
  ///
  /// In ar, this message translates to:
  /// **'تحذير'**
  String get aiWarning;

  /// No description provided for @aiTrend.
  ///
  /// In ar, this message translates to:
  /// **'الاتجاه'**
  String get aiTrend;

  /// No description provided for @aiPositive.
  ///
  /// In ar, this message translates to:
  /// **'إيجابي'**
  String get aiPositive;

  /// No description provided for @aiNegative.
  ///
  /// In ar, this message translates to:
  /// **'سلبي'**
  String get aiNegative;

  /// No description provided for @aiNeutral.
  ///
  /// In ar, this message translates to:
  /// **'محايد'**
  String get aiNeutral;

  /// No description provided for @aiSendMessage.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رسالتك...'**
  String get aiSendMessage;

  /// No description provided for @aiQuickTemplates.
  ///
  /// In ar, this message translates to:
  /// **'قوالب سريعة'**
  String get aiQuickTemplates;

  /// No description provided for @aiForecastPeriod.
  ///
  /// In ar, this message translates to:
  /// **'فترة التنبؤ'**
  String get aiForecastPeriod;

  /// No description provided for @aiWeekly.
  ///
  /// In ar, this message translates to:
  /// **'أسبوعي'**
  String get aiWeekly;

  /// No description provided for @aiMonthly.
  ///
  /// In ar, this message translates to:
  /// **'شهري'**
  String get aiMonthly;

  /// No description provided for @aiQuarterly.
  ///
  /// In ar, this message translates to:
  /// **'ربع سنوي'**
  String get aiQuarterly;

  /// No description provided for @aiWhatIfScenario.
  ///
  /// In ar, this message translates to:
  /// **'سيناريو ماذا لو'**
  String get aiWhatIfScenario;

  /// No description provided for @aiSeasonalPatterns.
  ///
  /// In ar, this message translates to:
  /// **'الأنماط الموسمية'**
  String get aiSeasonalPatterns;

  /// No description provided for @aiPriceSuggestion.
  ///
  /// In ar, this message translates to:
  /// **'اقتراح السعر'**
  String get aiPriceSuggestion;

  /// No description provided for @aiCurrentPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر الحالي'**
  String get aiCurrentPrice;

  /// No description provided for @aiSuggestedPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر المقترح'**
  String get aiSuggestedPrice;

  /// No description provided for @aiPriceImpact.
  ///
  /// In ar, this message translates to:
  /// **'تأثير السعر'**
  String get aiPriceImpact;

  /// No description provided for @aiDemandElasticity.
  ///
  /// In ar, this message translates to:
  /// **'مرونة الطلب'**
  String get aiDemandElasticity;

  /// No description provided for @aiFraudAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الاحتيال'**
  String get aiFraudAlerts;

  /// No description provided for @aiFraudRiskScore.
  ///
  /// In ar, this message translates to:
  /// **'درجة الخطورة'**
  String get aiFraudRiskScore;

  /// No description provided for @aiBehaviorScore.
  ///
  /// In ar, this message translates to:
  /// **'درجة السلوك'**
  String get aiBehaviorScore;

  /// No description provided for @aiInvestigation.
  ///
  /// In ar, this message translates to:
  /// **'التحقيق'**
  String get aiInvestigation;

  /// No description provided for @aiAssociationRules.
  ///
  /// In ar, this message translates to:
  /// **'قواعد الارتباط'**
  String get aiAssociationRules;

  /// No description provided for @aiBundleSuggestions.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات الحزم'**
  String get aiBundleSuggestions;

  /// No description provided for @aiRepurchaseReminder.
  ///
  /// In ar, this message translates to:
  /// **'تذكير إعادة الشراء'**
  String get aiRepurchaseReminder;

  /// No description provided for @aiCustomerSegment.
  ///
  /// In ar, this message translates to:
  /// **'شريحة العميل'**
  String get aiCustomerSegment;

  /// No description provided for @aiEoqCalculator.
  ///
  /// In ar, this message translates to:
  /// **'حاسبة الكمية المثالية'**
  String get aiEoqCalculator;

  /// No description provided for @aiAbcAnalysis.
  ///
  /// In ar, this message translates to:
  /// **'تحليل ABC'**
  String get aiAbcAnalysis;

  /// No description provided for @aiWastePrediction.
  ///
  /// In ar, this message translates to:
  /// **'التنبؤ بالهدر'**
  String get aiWastePrediction;

  /// No description provided for @aiReorderPoint.
  ///
  /// In ar, this message translates to:
  /// **'نقطة إعادة الطلب'**
  String get aiReorderPoint;

  /// No description provided for @aiCompetitorPrices.
  ///
  /// In ar, this message translates to:
  /// **'أسعار المنافسين'**
  String get aiCompetitorPrices;

  /// No description provided for @aiMarketPosition.
  ///
  /// In ar, this message translates to:
  /// **'الموقع السوقي'**
  String get aiMarketPosition;

  /// No description provided for @aiQueryInput.
  ///
  /// In ar, this message translates to:
  /// **'اسأل أي شيء عن بياناتك...'**
  String get aiQueryInput;

  /// No description provided for @aiReportTemplate.
  ///
  /// In ar, this message translates to:
  /// **'قالب التقرير'**
  String get aiReportTemplate;

  /// No description provided for @aiStaffPerformance.
  ///
  /// In ar, this message translates to:
  /// **'أداء الموظفين'**
  String get aiStaffPerformance;

  /// No description provided for @aiShiftOptimization.
  ///
  /// In ar, this message translates to:
  /// **'تحسين الورديات'**
  String get aiShiftOptimization;

  /// No description provided for @aiProductScan.
  ///
  /// In ar, this message translates to:
  /// **'مسح المنتج'**
  String get aiProductScan;

  /// No description provided for @aiOcrResults.
  ///
  /// In ar, this message translates to:
  /// **'نتائج OCR'**
  String get aiOcrResults;

  /// No description provided for @aiSentimentScore.
  ///
  /// In ar, this message translates to:
  /// **'مؤشر المشاعر'**
  String get aiSentimentScore;

  /// No description provided for @aiKeywords.
  ///
  /// In ar, this message translates to:
  /// **'الكلمات المفتاحية'**
  String get aiKeywords;

  /// No description provided for @aiReturnRisk.
  ///
  /// In ar, this message translates to:
  /// **'خطر الإرجاع'**
  String get aiReturnRisk;

  /// No description provided for @aiPreventiveActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات وقائية'**
  String get aiPreventiveActions;

  /// No description provided for @aiRoiForecast.
  ///
  /// In ar, this message translates to:
  /// **'توقع العائد'**
  String get aiRoiForecast;

  /// No description provided for @aiAbTesting.
  ///
  /// In ar, this message translates to:
  /// **'اختبار A/B'**
  String get aiAbTesting;

  /// No description provided for @aiQueryHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الاستعلامات'**
  String get aiQueryHistory;

  /// No description provided for @aiApplied.
  ///
  /// In ar, this message translates to:
  /// **'مُطبّق'**
  String get aiApplied;

  /// No description provided for @aiPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get aiPending;

  /// No description provided for @aiHighPriority.
  ///
  /// In ar, this message translates to:
  /// **'أولوية عالية'**
  String get aiHighPriority;

  /// No description provided for @aiMediumPriority.
  ///
  /// In ar, this message translates to:
  /// **'أولوية متوسطة'**
  String get aiMediumPriority;

  /// No description provided for @aiLowPriority.
  ///
  /// In ar, this message translates to:
  /// **'أولوية منخفضة'**
  String get aiLowPriority;

  /// No description provided for @aiCritical.
  ///
  /// In ar, this message translates to:
  /// **'حرج'**
  String get aiCritical;

  /// No description provided for @aiSar.
  ///
  /// In ar, this message translates to:
  /// **'ر.س'**
  String get aiSar;

  /// No description provided for @aiPercentChange.
  ///
  /// In ar, this message translates to:
  /// **'{percent}% تغيير'**
  String aiPercentChange(String percent);

  /// No description provided for @aiItemsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} عنصر'**
  String aiItemsCount(int count);

  /// No description provided for @aiLastUpdated.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث: {time}'**
  String aiLastUpdated(String time);

  /// No description provided for @connectedToServer.
  ///
  /// In ar, this message translates to:
  /// **'متصل بالسيرفر'**
  String get connectedToServer;

  /// No description provided for @lastSyncAt.
  ///
  /// In ar, this message translates to:
  /// **'آخر مزامنة: {time}'**
  String lastSyncAt(String time);

  /// No description provided for @pendingOperations.
  ///
  /// In ar, this message translates to:
  /// **'العمليات المعلقة'**
  String get pendingOperations;

  /// No description provided for @nPendingOperations.
  ///
  /// In ar, this message translates to:
  /// **'{count} عملية تنتظر المزامنة'**
  String nPendingOperations(int count);

  /// No description provided for @noPendingOperations.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عمليات معلقة'**
  String get noPendingOperations;

  /// No description provided for @syncInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات المزامنة'**
  String get syncInfo;

  /// No description provided for @device.
  ///
  /// In ar, this message translates to:
  /// **'الجهاز'**
  String get device;

  /// No description provided for @appVersion.
  ///
  /// In ar, this message translates to:
  /// **'إصدار التطبيق'**
  String get appVersion;

  /// No description provided for @lastFullSync.
  ///
  /// In ar, this message translates to:
  /// **'آخر مزامنة كاملة'**
  String get lastFullSync;

  /// No description provided for @databaseStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة قاعدة البيانات'**
  String get databaseStatus;

  /// No description provided for @healthy.
  ///
  /// In ar, this message translates to:
  /// **'سليم'**
  String get healthy;

  /// No description provided for @syncSuccessful.
  ///
  /// In ar, this message translates to:
  /// **'تمت المزامنة بنجاح'**
  String get syncSuccessful;

  /// No description provided for @justNow.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get justNow;

  /// No description provided for @allOperationsSynced.
  ///
  /// In ar, this message translates to:
  /// **'جميع العمليات متزامنة'**
  String get allOperationsSynced;

  /// No description provided for @willSyncWhenOnline.
  ///
  /// In ar, this message translates to:
  /// **'سيتم مزامنتها عند الاتصال بالإنترنت'**
  String get willSyncWhenOnline;

  /// No description provided for @syncAll.
  ///
  /// In ar, this message translates to:
  /// **'مزامنة الكل'**
  String get syncAll;

  /// No description provided for @operationSynced.
  ///
  /// In ar, this message translates to:
  /// **'تمت مزامنة العملية'**
  String get operationSynced;

  /// No description provided for @deleteOperation.
  ///
  /// In ar, this message translates to:
  /// **'حذف العملية'**
  String get deleteOperation;

  /// No description provided for @deleteOperationConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذه العملية من قائمة الانتظار؟'**
  String get deleteOperationConfirm;

  /// No description provided for @insertOperation.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get insertOperation;

  /// No description provided for @updateOperation.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get updateOperation;

  /// No description provided for @operationLabel.
  ///
  /// In ar, this message translates to:
  /// **'عملية'**
  String get operationLabel;

  /// No description provided for @nPendingCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} عملية معلقة'**
  String nPendingCount(int count);

  /// No description provided for @conflictsNeedResolution.
  ///
  /// In ar, this message translates to:
  /// **'{count} تعارضات تحتاج حل'**
  String conflictsNeedResolution(int count);

  /// No description provided for @chooseCorrectValue.
  ///
  /// In ar, this message translates to:
  /// **'اختر القيمة الصحيحة لكل تعارض'**
  String get chooseCorrectValue;

  /// No description provided for @noConflicts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تعارضات'**
  String get noConflicts;

  /// No description provided for @productPriceConflict.
  ///
  /// In ar, this message translates to:
  /// **'تعارض في سعر المنتج'**
  String get productPriceConflict;

  /// No description provided for @stockQuantityConflict.
  ///
  /// In ar, this message translates to:
  /// **'تعارض في كمية المخزون'**
  String get stockQuantityConflict;

  /// No description provided for @useAllLocal.
  ///
  /// In ar, this message translates to:
  /// **'استخدام الكل المحلي'**
  String get useAllLocal;

  /// No description provided for @useAllServer.
  ///
  /// In ar, this message translates to:
  /// **'استخدام الكل من السيرفر'**
  String get useAllServer;

  /// No description provided for @conflictResolvedLocal.
  ///
  /// In ar, this message translates to:
  /// **'تم حل التعارض باستخدام القيمة المحلية'**
  String get conflictResolvedLocal;

  /// No description provided for @conflictResolvedServer.
  ///
  /// In ar, this message translates to:
  /// **'تم حل التعارض باستخدام القيمة من السيرفر'**
  String get conflictResolvedServer;

  /// No description provided for @useLocalValues.
  ///
  /// In ar, this message translates to:
  /// **'القيم المحلية'**
  String get useLocalValues;

  /// No description provided for @useServerValues.
  ///
  /// In ar, this message translates to:
  /// **'قيم السيرفر'**
  String get useServerValues;

  /// No description provided for @applyToAllConflicts.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تطبيق {choice} على جميع التعارضات'**
  String applyToAllConflicts(String choice);

  /// No description provided for @allConflictsResolved.
  ///
  /// In ar, this message translates to:
  /// **'تم حل جميع التعارضات'**
  String get allConflictsResolved;

  /// No description provided for @localValueLabel.
  ///
  /// In ar, this message translates to:
  /// **'القيمة المحلية'**
  String get localValueLabel;

  /// No description provided for @serverValueLabel.
  ///
  /// In ar, this message translates to:
  /// **'القيمة من السيرفر'**
  String get serverValueLabel;

  /// No description provided for @noteOptional.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة (اختياري)'**
  String get noteOptional;

  /// No description provided for @suspendInvoice.
  ///
  /// In ar, this message translates to:
  /// **'تعليق الفاتورة'**
  String get suspendInvoice;

  /// No description provided for @invoiceSuspended.
  ///
  /// In ar, this message translates to:
  /// **'تم تعليق الفاتورة'**
  String get invoiceSuspended;

  /// No description provided for @nItems.
  ///
  /// In ar, this message translates to:
  /// **'{count} عنصر'**
  String nItems(int count);

  /// No description provided for @saveSaleError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في حفظ البيع: {error}'**
  String saveSaleError(String error);

  /// No description provided for @refresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get refresh;

  /// No description provided for @stockGood.
  ///
  /// In ar, this message translates to:
  /// **'المخزون جيد!'**
  String get stockGood;

  /// No description provided for @manageInventory.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المخزون'**
  String get manageInventory;

  /// No description provided for @pendingSyncCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} قيد المزامنة'**
  String pendingSyncCount(int count);

  /// No description provided for @freshMilk.
  ///
  /// In ar, this message translates to:
  /// **'حليب طازج'**
  String get freshMilk;

  /// No description provided for @whiteBread.
  ///
  /// In ar, this message translates to:
  /// **'خبز أبيض'**
  String get whiteBread;

  /// No description provided for @localEggs.
  ///
  /// In ar, this message translates to:
  /// **'بيض بلدي'**
  String get localEggs;

  /// No description provided for @yogurt.
  ///
  /// In ar, this message translates to:
  /// **'زبادي'**
  String get yogurt;

  /// No description provided for @minQuantityLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى: {count}'**
  String minQuantityLabel(int count);

  /// No description provided for @manageDiscounts.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الخصومات'**
  String get manageDiscounts;

  /// No description provided for @newDiscount.
  ///
  /// In ar, this message translates to:
  /// **'خصم جديد'**
  String get newDiscount;

  /// No description provided for @totalLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get totalLabel;

  /// No description provided for @stopped.
  ///
  /// In ar, this message translates to:
  /// **'متوقف'**
  String get stopped;

  /// No description provided for @allProducts.
  ///
  /// In ar, this message translates to:
  /// **'جميع المنتجات'**
  String get allProducts;

  /// No description provided for @specificCategory.
  ///
  /// In ar, this message translates to:
  /// **'تصنيف محدد'**
  String get specificCategory;

  /// No description provided for @percentageLabel.
  ///
  /// In ar, this message translates to:
  /// **'نسبة %'**
  String get percentageLabel;

  /// No description provided for @fixedAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ ثابت'**
  String get fixedAmount;

  /// No description provided for @thePercentage.
  ///
  /// In ar, this message translates to:
  /// **'النسبة'**
  String get thePercentage;

  /// No description provided for @theAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get theAmount;

  /// No description provided for @discountOff.
  ///
  /// In ar, this message translates to:
  /// **'{value}% خصم'**
  String discountOff(String value);

  /// No description provided for @sarDiscountOff.
  ///
  /// In ar, this message translates to:
  /// **'{value} ر.س خصم'**
  String sarDiscountOff(String value);

  /// No description provided for @manageCoupons.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الكوبونات'**
  String get manageCoupons;

  /// No description provided for @newCoupon.
  ///
  /// In ar, this message translates to:
  /// **'كوبون جديد'**
  String get newCoupon;

  /// No description provided for @expired.
  ///
  /// In ar, this message translates to:
  /// **'منتهي الصلاحية'**
  String get expired;

  /// No description provided for @deactivated.
  ///
  /// In ar, this message translates to:
  /// **'معطل'**
  String get deactivated;

  /// No description provided for @usageCount.
  ///
  /// In ar, this message translates to:
  /// **'{used}/{max} استخدام'**
  String usageCount(int used, int max);

  /// No description provided for @freeDelivery.
  ///
  /// In ar, this message translates to:
  /// **'توصيل مجاني'**
  String get freeDelivery;

  /// No description provided for @percentageDiscountLabel.
  ///
  /// In ar, this message translates to:
  /// **'خصم {value}%'**
  String percentageDiscountLabel(int value);

  /// No description provided for @fixedDiscountLabel.
  ///
  /// In ar, this message translates to:
  /// **'خصم {value} ر.س'**
  String fixedDiscountLabel(int value);

  /// No description provided for @couponTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get couponTypeLabel;

  /// No description provided for @percentageRate.
  ///
  /// In ar, this message translates to:
  /// **'النسبة %'**
  String get percentageRate;

  /// No description provided for @minimumOrder.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى للطلب'**
  String get minimumOrder;

  /// No description provided for @expiryDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانتهاء'**
  String get expiryDate;

  /// No description provided for @copyCode.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get copyCode;

  /// No description provided for @usages.
  ///
  /// In ar, this message translates to:
  /// **'الاستخدامات'**
  String get usages;

  /// No description provided for @percentageDiscountOption.
  ///
  /// In ar, this message translates to:
  /// **'خصم نسبة'**
  String get percentageDiscountOption;

  /// No description provided for @fixedDiscountOption.
  ///
  /// In ar, this message translates to:
  /// **'خصم ثابت'**
  String get fixedDiscountOption;

  /// No description provided for @freeDeliveryOption.
  ///
  /// In ar, this message translates to:
  /// **'توصيل مجاني'**
  String get freeDeliveryOption;

  /// No description provided for @percentageField.
  ///
  /// In ar, this message translates to:
  /// **'النسبة %'**
  String get percentageField;

  /// No description provided for @manageSpecialOffers.
  ///
  /// In ar, this message translates to:
  /// **'إدارة العروض الخاصة'**
  String get manageSpecialOffers;

  /// No description provided for @newOffer.
  ///
  /// In ar, this message translates to:
  /// **'عرض جديد'**
  String get newOffer;

  /// No description provided for @expiringSoon.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي قريباً'**
  String get expiringSoon;

  /// No description provided for @offerExpired.
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get offerExpired;

  /// No description provided for @bundleDiscount.
  ///
  /// In ar, this message translates to:
  /// **'باقة - خصم {discount}%'**
  String bundleDiscount(String discount);

  /// No description provided for @buyAndGetFree.
  ///
  /// In ar, this message translates to:
  /// **'اشتري واحصل مجاناً'**
  String get buyAndGetFree;

  /// No description provided for @offerDiscountPercent.
  ///
  /// In ar, this message translates to:
  /// **'خصم {discount}%'**
  String offerDiscountPercent(String discount);

  /// No description provided for @offerDiscountFixed.
  ///
  /// In ar, this message translates to:
  /// **'خصم {discount} ر.س'**
  String offerDiscountFixed(String discount);

  /// No description provided for @bundleLabel.
  ///
  /// In ar, this message translates to:
  /// **'باقة'**
  String get bundleLabel;

  /// No description provided for @buyAndGet.
  ///
  /// In ar, this message translates to:
  /// **'اشترِ واحصل'**
  String get buyAndGet;

  /// No description provided for @startDateLabel.
  ///
  /// In ar, this message translates to:
  /// **'البداية'**
  String get startDateLabel;

  /// No description provided for @endDateLabel.
  ///
  /// In ar, this message translates to:
  /// **'النهاية'**
  String get endDateLabel;

  /// No description provided for @productsLabel.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get productsLabel;

  /// No description provided for @offerType.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get offerType;

  /// No description provided for @theDiscount.
  ///
  /// In ar, this message translates to:
  /// **'الخصم:'**
  String get theDiscount;

  /// No description provided for @smartSuggestions.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات ذكية'**
  String get smartSuggestions;

  /// No description provided for @suggestionsBasedOnAnalysis.
  ///
  /// In ar, this message translates to:
  /// **'عروض مقترحة بناءً على تحليل المبيعات والمخزون'**
  String get suggestionsBasedOnAnalysis;

  /// No description provided for @suggestedDiscountPercent.
  ///
  /// In ar, this message translates to:
  /// **'{percent}% خصم مقترح'**
  String suggestedDiscountPercent(int percent);

  /// No description provided for @stockLabelCount.
  ///
  /// In ar, this message translates to:
  /// **'المخزون: {count}'**
  String stockLabelCount(int count);

  /// No description provided for @validityDays.
  ///
  /// In ar, this message translates to:
  /// **'صلاحية (أيام)'**
  String validityDays(int days);

  /// No description provided for @ignore.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get ignore;

  /// No description provided for @applyAction.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get applyAction;

  /// No description provided for @usageCountTimes.
  ///
  /// In ar, this message translates to:
  /// **'استخدام: {count} مرة'**
  String usageCountTimes(int count);

  /// No description provided for @promotionHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل العروض السابقة'**
  String get promotionHistory;

  /// No description provided for @createNewPromotion.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء عرض جديد'**
  String get createNewPromotion;

  /// No description provided for @percentageDiscountType.
  ///
  /// In ar, this message translates to:
  /// **'خصم نسبة مئوية'**
  String get percentageDiscountType;

  /// No description provided for @percentageDiscountDesc.
  ///
  /// In ar, this message translates to:
  /// **'خصم 10%، 20%، إلخ'**
  String get percentageDiscountDesc;

  /// No description provided for @buyXGetY.
  ///
  /// In ar, this message translates to:
  /// **'اشتري X واحصل على Y'**
  String get buyXGetY;

  /// No description provided for @buyXGetYDesc.
  ///
  /// In ar, this message translates to:
  /// **'اشتري 2 واحصل على 1 مجاناً'**
  String get buyXGetYDesc;

  /// No description provided for @fixedAmountDiscount.
  ///
  /// In ar, this message translates to:
  /// **'خصم مبلغ ثابت'**
  String get fixedAmountDiscount;

  /// No description provided for @fixedAmountDiscountDesc.
  ///
  /// In ar, this message translates to:
  /// **'خصم 10 ر.س على المنتج'**
  String get fixedAmountDiscountDesc;

  /// No description provided for @promotionApplied.
  ///
  /// In ar, this message translates to:
  /// **'تم تطبيق العرض على {product}'**
  String promotionApplied(String product);

  /// No description provided for @promotionType.
  ///
  /// In ar, this message translates to:
  /// **'النوع: {type}'**
  String promotionType(String type);

  /// No description provided for @promotionValue.
  ///
  /// In ar, this message translates to:
  /// **'القيمة: {value}'**
  String promotionValue(String value);

  /// No description provided for @promotionUsage.
  ///
  /// In ar, this message translates to:
  /// **'الاستخدام: {count} مرة'**
  String promotionUsage(int count);

  /// No description provided for @percentageType.
  ///
  /// In ar, this message translates to:
  /// **'نسبة مئوية'**
  String get percentageType;

  /// No description provided for @buyXGetYType.
  ///
  /// In ar, this message translates to:
  /// **'اشتري واحصل'**
  String get buyXGetYType;

  /// No description provided for @fixedAmountType.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ ثابت'**
  String get fixedAmountType;

  /// No description provided for @closeAction.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get closeAction;

  /// No description provided for @holdInvoices.
  ///
  /// In ar, this message translates to:
  /// **'الفواتير المعلقة'**
  String get holdInvoices;

  /// No description provided for @clearAll.
  ///
  /// In ar, this message translates to:
  /// **'مسح الكل'**
  String get clearAll;

  /// No description provided for @noHoldInvoices.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فواتير معلقة'**
  String get noHoldInvoices;

  /// No description provided for @holdInvoicesDesc.
  ///
  /// In ar, this message translates to:
  /// **'عند تعليق فاتورة من نقطة البيع ستظهر هنا\nيمكنك تعليق عدة فواتير واستئنافها لاحقاً'**
  String get holdInvoicesDesc;

  /// No description provided for @deleteInvoiceTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الفاتورة'**
  String get deleteInvoiceTitle;

  /// No description provided for @deleteInvoiceConfirmMsg.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف \"{name}\"?\nهذا الإجراء لا يمكن التراجع عنه.'**
  String deleteInvoiceConfirmMsg(String name);

  /// No description provided for @cannotUndo.
  ///
  /// In ar, this message translates to:
  /// **'هذا الإجراء لا يمكن التراجع عنه.'**
  String get cannotUndo;

  /// No description provided for @deleteAllLabel.
  ///
  /// In ar, this message translates to:
  /// **'حذف الكل'**
  String get deleteAllLabel;

  /// No description provided for @deleteAllInvoices.
  ///
  /// In ar, this message translates to:
  /// **'حذف جميع الفواتير'**
  String get deleteAllInvoices;

  /// No description provided for @deleteAllInvoicesConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف جميع الفواتير المعلقة ({count} فاتورة)?\nهذا الإجراء لا يمكن التراجع عنه.'**
  String deleteAllInvoicesConfirm(int count);

  /// No description provided for @invoiceDeletedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الفاتورة'**
  String get invoiceDeletedMsg;

  /// No description provided for @allInvoicesDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف جميع الفواتير'**
  String get allInvoicesDeleted;

  /// No description provided for @resumedInvoice.
  ///
  /// In ar, this message translates to:
  /// **'تم استئناف: {name}'**
  String resumedInvoice(String name);

  /// No description provided for @itemLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count} عنصر'**
  String itemLabel(int count);

  /// No description provided for @moreItems.
  ///
  /// In ar, this message translates to:
  /// **'+{count} عناصر أخرى'**
  String moreItems(int count);

  /// No description provided for @resume.
  ///
  /// In ar, this message translates to:
  /// **'استئناف'**
  String get resume;

  /// No description provided for @justNowTime.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get justNowTime;

  /// No description provided for @minutesAgoTime.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} دقيقة'**
  String minutesAgoTime(int count);

  /// No description provided for @hoursAgoTime.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} ساعة'**
  String hoursAgoTime(int count);

  /// No description provided for @daysAgoTime.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} يوم'**
  String daysAgoTime(int count);

  /// No description provided for @debtManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الديون'**
  String get debtManagement;

  /// No description provided for @sortLabel.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب'**
  String get sortLabel;

  /// No description provided for @sortByAmount.
  ///
  /// In ar, this message translates to:
  /// **'حسب المبلغ'**
  String get sortByAmount;

  /// No description provided for @sortByDate.
  ///
  /// In ar, this message translates to:
  /// **'حسب التاريخ'**
  String get sortByDate;

  /// No description provided for @sendReminders.
  ///
  /// In ar, this message translates to:
  /// **'إرسال تذكيرات'**
  String get sendReminders;

  /// No description provided for @allTab.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get allTab;

  /// No description provided for @overdueTab.
  ///
  /// In ar, this message translates to:
  /// **'متأخرة'**
  String get overdueTab;

  /// No description provided for @upcomingTab.
  ///
  /// In ar, this message translates to:
  /// **'قادمة'**
  String get upcomingTab;

  /// No description provided for @totalDebts.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الديون'**
  String get totalDebts;

  /// No description provided for @overdueDebts.
  ///
  /// In ar, this message translates to:
  /// **'ديون متأخرة'**
  String get overdueDebts;

  /// No description provided for @debtorCustomers.
  ///
  /// In ar, this message translates to:
  /// **'عملاء مدينون'**
  String get debtorCustomers;

  /// No description provided for @noDebts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ديون'**
  String get noDebts;

  /// No description provided for @customerLabel2.
  ///
  /// In ar, this message translates to:
  /// **'{count} عميل'**
  String customerLabel2(int count);

  /// No description provided for @overdueDays.
  ///
  /// In ar, this message translates to:
  /// **'متأخر {days} يوم'**
  String overdueDays(int days);

  /// No description provided for @remainingDays.
  ///
  /// In ar, this message translates to:
  /// **'متبقي {days} يوم'**
  String remainingDays(int days);

  /// No description provided for @lastPaymentDate.
  ///
  /// In ar, this message translates to:
  /// **'آخر دفعة: {date}'**
  String lastPaymentDate(String date);

  /// No description provided for @recordPayment.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل دفعة'**
  String get recordPayment;

  /// No description provided for @amountDue.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المستحق'**
  String get amountDue;

  /// No description provided for @currentDebt.
  ///
  /// In ar, this message translates to:
  /// **'الدين الحالي: {amount} ر.س'**
  String currentDebt(String amount);

  /// No description provided for @paidAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المدفوع'**
  String get paidAmount;

  /// No description provided for @cashMethod.
  ///
  /// In ar, this message translates to:
  /// **'نقداً'**
  String get cashMethod;

  /// No description provided for @cardMethod.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة'**
  String get cardMethod;

  /// No description provided for @transferMethod.
  ///
  /// In ar, this message translates to:
  /// **'تحويل'**
  String get transferMethod;

  /// No description provided for @paymentRecordedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الدفعة بنجاح'**
  String get paymentRecordedSuccess;

  /// No description provided for @sendRemindersTitle.
  ///
  /// In ar, this message translates to:
  /// **'إرسال تذكيرات'**
  String get sendRemindersTitle;

  /// No description provided for @sendRemindersConfirm.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إرسال تذكير لـ {count} عميل لديهم ديون متأخرة'**
  String sendRemindersConfirm(int count);

  /// No description provided for @sendAction.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get sendAction;

  /// No description provided for @remindersSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال {count} تذكير'**
  String remindersSent(int count);

  /// No description provided for @recordPaymentFor.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل دفعة - {name}'**
  String recordPaymentFor(String name);

  /// No description provided for @sendReminder.
  ///
  /// In ar, this message translates to:
  /// **'إرسال تذكير'**
  String get sendReminder;

  /// No description provided for @tabAiSuggestions.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات AI'**
  String get tabAiSuggestions;

  /// No description provided for @tabActivePromotions.
  ///
  /// In ar, this message translates to:
  /// **'العروض النشطة'**
  String get tabActivePromotions;

  /// No description provided for @tabHistory.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get tabHistory;

  /// No description provided for @fruitYogurt.
  ///
  /// In ar, this message translates to:
  /// **'زبادي فواكه'**
  String get fruitYogurt;

  /// No description provided for @buttermilk.
  ///
  /// In ar, this message translates to:
  /// **'لبن رايب'**
  String get buttermilk;

  /// No description provided for @appleJuice.
  ///
  /// In ar, this message translates to:
  /// **'عصير تفاح'**
  String get appleJuice;

  /// No description provided for @whiteCheese.
  ///
  /// In ar, this message translates to:
  /// **'جبنة بيضاء'**
  String get whiteCheese;

  /// No description provided for @orangeJuice.
  ///
  /// In ar, this message translates to:
  /// **'عصير برتقال'**
  String get orangeJuice;

  /// No description provided for @slowMovementReason.
  ///
  /// In ar, this message translates to:
  /// **'حركة بطيئة - {days} يوم بدون بيع'**
  String slowMovementReason(String days);

  /// No description provided for @nearExpiryReason.
  ///
  /// In ar, this message translates to:
  /// **'قرب انتهاء الصلاحية'**
  String get nearExpiryReason;

  /// No description provided for @excessStockReason.
  ///
  /// In ar, this message translates to:
  /// **'مخزون زائد'**
  String get excessStockReason;

  /// No description provided for @weekendOffer.
  ///
  /// In ar, this message translates to:
  /// **'عرض نهاية الأسبوع'**
  String get weekendOffer;

  /// No description provided for @buy2Get1Free.
  ///
  /// In ar, this message translates to:
  /// **'اشتري 2 واحصل على 1 مجاناً'**
  String get buy2Get1Free;

  /// No description provided for @productsListLabel.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات:'**
  String get productsListLabel;

  /// No description provided for @paymentMethodLabel2.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get paymentMethodLabel2;

  /// No description provided for @lastPaymentLabel.
  ///
  /// In ar, this message translates to:
  /// **'آخر دفعة'**
  String get lastPaymentLabel;

  /// No description provided for @currencySAR.
  ///
  /// In ar, this message translates to:
  /// **'ر.س'**
  String get currencySAR;

  /// No description provided for @debtAmountWithCurrency.
  ///
  /// In ar, this message translates to:
  /// **'{amount} ر.س'**
  String debtAmountWithCurrency(String amount);

  /// No description provided for @defaultUserName.
  ///
  /// In ar, this message translates to:
  /// **'أحمد محمد'**
  String get defaultUserName;

  /// No description provided for @saveSettings.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الإعدادات'**
  String get saveSettings;

  /// No description provided for @settingsSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الإعدادات'**
  String get settingsSaved;

  /// No description provided for @settingsReset.
  ///
  /// In ar, this message translates to:
  /// **'تم إعادة ضبط الإعدادات'**
  String get settingsReset;

  /// No description provided for @resetSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعادة ضبط الإعدادات'**
  String get resetSettings;

  /// No description provided for @resetSettingsDesc.
  ///
  /// In ar, this message translates to:
  /// **'إعادة جميع الإعدادات للقيم الافتراضية'**
  String get resetSettingsDesc;

  /// No description provided for @resetSettingsConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من إعادة جميع إعدادات نقطة البيع للقيم الافتراضية؟'**
  String get resetSettingsConfirm;

  /// No description provided for @resetAction.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين'**
  String get resetAction;

  /// No description provided for @posSettingsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'العرض، السلة، الدفع، الإيصال'**
  String get posSettingsSubtitle;

  /// No description provided for @displaySettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات العرض'**
  String get displaySettings;

  /// No description provided for @productDisplayMode.
  ///
  /// In ar, this message translates to:
  /// **'طريقة عرض المنتجات'**
  String get productDisplayMode;

  /// No description provided for @productDisplayModeDesc.
  ///
  /// In ar, this message translates to:
  /// **'كيفية عرض المنتجات في شاشة POS'**
  String get productDisplayModeDesc;

  /// No description provided for @gridColumns.
  ///
  /// In ar, this message translates to:
  /// **'عدد الأعمدة'**
  String get gridColumns;

  /// No description provided for @nColumns.
  ///
  /// In ar, this message translates to:
  /// **'{count} أعمدة'**
  String nColumns(int count);

  /// No description provided for @showProductImages.
  ///
  /// In ar, this message translates to:
  /// **'عرض صور المنتجات'**
  String get showProductImages;

  /// No description provided for @showProductImagesDesc.
  ///
  /// In ar, this message translates to:
  /// **'إظهار الصور في بطاقات المنتجات'**
  String get showProductImagesDesc;

  /// No description provided for @showPrices.
  ///
  /// In ar, this message translates to:
  /// **'عرض الأسعار'**
  String get showPrices;

  /// No description provided for @showPricesDesc.
  ///
  /// In ar, this message translates to:
  /// **'إظهار السعر على بطاقة المنتج'**
  String get showPricesDesc;

  /// No description provided for @showStockLevel.
  ///
  /// In ar, this message translates to:
  /// **'عرض مستوى المخزون'**
  String get showStockLevel;

  /// No description provided for @showStockLevelDesc.
  ///
  /// In ar, this message translates to:
  /// **'إظهار الكمية المتاحة'**
  String get showStockLevelDesc;

  /// No description provided for @cartSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات السلة'**
  String get cartSettings;

  /// No description provided for @autoFocusBarcode.
  ///
  /// In ar, this message translates to:
  /// **'التركيز التلقائي على الباركود'**
  String get autoFocusBarcode;

  /// No description provided for @autoFocusBarcodeDesc.
  ///
  /// In ar, this message translates to:
  /// **'التركيز على حقل الباركود عند فتح الشاشة'**
  String get autoFocusBarcodeDesc;

  /// No description provided for @allowNegativeStock.
  ///
  /// In ar, this message translates to:
  /// **'السماح بالمخزون السالب'**
  String get allowNegativeStock;

  /// No description provided for @allowNegativeStockDesc.
  ///
  /// In ar, this message translates to:
  /// **'البيع حتى لو كان المخزون صفر'**
  String get allowNegativeStockDesc;

  /// No description provided for @confirmBeforeDelete.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد قبل الحذف'**
  String get confirmBeforeDelete;

  /// No description provided for @confirmBeforeDeleteDesc.
  ///
  /// In ar, this message translates to:
  /// **'طلب تأكيد عند حذف منتج من السلة'**
  String get confirmBeforeDeleteDesc;

  /// No description provided for @showItemNotes.
  ///
  /// In ar, this message translates to:
  /// **'عرض ملاحظات المنتج'**
  String get showItemNotes;

  /// No description provided for @showItemNotesDesc.
  ///
  /// In ar, this message translates to:
  /// **'إمكانية إضافة ملاحظات لكل منتج'**
  String get showItemNotesDesc;

  /// No description provided for @cashPaymentOption.
  ///
  /// In ar, this message translates to:
  /// **'الدفع نقداً'**
  String get cashPaymentOption;

  /// No description provided for @cardPaymentOption.
  ///
  /// In ar, this message translates to:
  /// **'الدفع بالبطاقة'**
  String get cardPaymentOption;

  /// No description provided for @creditPaymentOption.
  ///
  /// In ar, this message translates to:
  /// **'الدفع الآجل'**
  String get creditPaymentOption;

  /// No description provided for @bankTransferOption.
  ///
  /// In ar, this message translates to:
  /// **'التحويل البنكي'**
  String get bankTransferOption;

  /// No description provided for @allowSplitPayment.
  ///
  /// In ar, this message translates to:
  /// **'السماح بتقسيم الدفع'**
  String get allowSplitPayment;

  /// No description provided for @allowSplitPaymentDesc.
  ///
  /// In ar, this message translates to:
  /// **'الدفع بأكثر من طريقة'**
  String get allowSplitPaymentDesc;

  /// No description provided for @requireCustomerForCredit.
  ///
  /// In ar, this message translates to:
  /// **'اشتراط العميل للدفع الآجل'**
  String get requireCustomerForCredit;

  /// No description provided for @requireCustomerForCreditDesc.
  ///
  /// In ar, this message translates to:
  /// **'يجب تحديد عميل للدفع الآجل'**
  String get requireCustomerForCreditDesc;

  /// No description provided for @receiptSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الإيصال'**
  String get receiptSettings;

  /// No description provided for @autoPrintReceipt.
  ///
  /// In ar, this message translates to:
  /// **'طباعة الإيصال تلقائياً'**
  String get autoPrintReceipt;

  /// No description provided for @autoPrintReceiptDesc.
  ///
  /// In ar, this message translates to:
  /// **'طباعة فور إتمام العملية'**
  String get autoPrintReceiptDesc;

  /// No description provided for @receiptCopies.
  ///
  /// In ar, this message translates to:
  /// **'عدد نسخ الإيصال'**
  String get receiptCopies;

  /// No description provided for @emailReceiptOption.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الإيصال بالإيميل'**
  String get emailReceiptOption;

  /// No description provided for @emailReceiptDesc.
  ///
  /// In ar, this message translates to:
  /// **'إرسال نسخة للعميل'**
  String get emailReceiptDesc;

  /// No description provided for @smsReceiptOption.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الإيصال برسالة SMS'**
  String get smsReceiptOption;

  /// No description provided for @smsReceiptDesc.
  ///
  /// In ar, this message translates to:
  /// **'رسالة نصية للعميل'**
  String get smsReceiptDesc;

  /// No description provided for @printerSettingsDesc.
  ///
  /// In ar, this message translates to:
  /// **'اختيار الطابعة وإعداداتها'**
  String get printerSettingsDesc;

  /// No description provided for @receiptDesign.
  ///
  /// In ar, this message translates to:
  /// **'تصميم الإيصال'**
  String get receiptDesign;

  /// No description provided for @receiptDesignDesc.
  ///
  /// In ar, this message translates to:
  /// **'تخصيص شكل الإيصال'**
  String get receiptDesignDesc;

  /// No description provided for @advancedSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات متقدمة'**
  String get advancedSettings;

  /// No description provided for @allowHoldInvoices.
  ///
  /// In ar, this message translates to:
  /// **'السماح بتعليق الفواتير'**
  String get allowHoldInvoices;

  /// No description provided for @allowHoldInvoicesDesc.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الفاتورة مؤقتاً'**
  String get allowHoldInvoicesDesc;

  /// No description provided for @maxHoldInvoices.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى للفواتير المعلقة'**
  String get maxHoldInvoices;

  /// No description provided for @quickSaleMode.
  ///
  /// In ar, this message translates to:
  /// **'وضع البيع السريع'**
  String get quickSaleMode;

  /// No description provided for @quickSaleModeDesc.
  ///
  /// In ar, this message translates to:
  /// **'شاشة مبسطة للبيع السريع'**
  String get quickSaleModeDesc;

  /// No description provided for @soundEffects.
  ///
  /// In ar, this message translates to:
  /// **'المؤثرات الصوتية'**
  String get soundEffects;

  /// No description provided for @soundEffectsDesc.
  ///
  /// In ar, this message translates to:
  /// **'أصوات عند المسح والإضافة'**
  String get soundEffectsDesc;

  /// No description provided for @hapticFeedback.
  ///
  /// In ar, this message translates to:
  /// **'اهتزاز اللمس'**
  String get hapticFeedback;

  /// No description provided for @hapticFeedbackDesc.
  ///
  /// In ar, this message translates to:
  /// **'اهتزاز عند الضغط على الأزرار'**
  String get hapticFeedbackDesc;

  /// No description provided for @keyboardShortcuts.
  ///
  /// In ar, this message translates to:
  /// **'اختصارات لوحة المفاتيح'**
  String get keyboardShortcuts;

  /// No description provided for @customizeShortcuts.
  ///
  /// In ar, this message translates to:
  /// **'تخصيص الاختصارات'**
  String get customizeShortcuts;

  /// No description provided for @shortcutSearchProduct.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن منتج'**
  String get shortcutSearchProduct;

  /// No description provided for @shortcutSearchCustomer.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن عميل'**
  String get shortcutSearchCustomer;

  /// No description provided for @shortcutHoldInvoice.
  ///
  /// In ar, this message translates to:
  /// **'تعليق الفاتورة'**
  String get shortcutHoldInvoice;

  /// No description provided for @shortcutFavorites.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get shortcutFavorites;

  /// No description provided for @shortcutApplyDiscount.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق خصم'**
  String get shortcutApplyDiscount;

  /// No description provided for @shortcutPayment.
  ///
  /// In ar, this message translates to:
  /// **'الدفع'**
  String get shortcutPayment;

  /// No description provided for @shortcutCancelBack.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء / رجوع'**
  String get shortcutCancelBack;

  /// No description provided for @shortcutDeleteProduct.
  ///
  /// In ar, this message translates to:
  /// **'حذف منتج'**
  String get shortcutDeleteProduct;

  /// No description provided for @paymentDevicesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'mada, STC Pay, Apple Pay'**
  String get paymentDevicesSubtitle;

  /// No description provided for @supportedPaymentMethods.
  ///
  /// In ar, this message translates to:
  /// **'طرق الدفع المدعومة'**
  String get supportedPaymentMethods;

  /// No description provided for @madaLocalCards.
  ///
  /// In ar, this message translates to:
  /// **'بطاقات مدى المحلية'**
  String get madaLocalCards;

  /// No description provided for @internationalCards.
  ///
  /// In ar, this message translates to:
  /// **'البطاقات الدولية'**
  String get internationalCards;

  /// No description provided for @stcDigitalWallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظة STC الرقمية'**
  String get stcDigitalWallet;

  /// No description provided for @paymentTerminal.
  ///
  /// In ar, this message translates to:
  /// **'جهاز الدفع'**
  String get paymentTerminal;

  /// No description provided for @ingenicoDevices.
  ///
  /// In ar, this message translates to:
  /// **'أجهزة Ingenico'**
  String get ingenicoDevices;

  /// No description provided for @verifoneDevices.
  ///
  /// In ar, this message translates to:
  /// **'أجهزة Verifone'**
  String get verifoneDevices;

  /// No description provided for @paxDevices.
  ///
  /// In ar, this message translates to:
  /// **'أجهزة PAX'**
  String get paxDevices;

  /// No description provided for @settlement.
  ///
  /// In ar, this message translates to:
  /// **'التسوية'**
  String get settlement;

  /// No description provided for @autoSettlement.
  ///
  /// In ar, this message translates to:
  /// **'التسوية التلقائية'**
  String get autoSettlement;

  /// No description provided for @autoSettlementDesc.
  ///
  /// In ar, this message translates to:
  /// **'تسوية نهاية اليوم تلقائياً'**
  String get autoSettlementDesc;

  /// No description provided for @manualSettlement.
  ///
  /// In ar, this message translates to:
  /// **'تسوية يدوية'**
  String get manualSettlement;

  /// No description provided for @executeSettlementNow.
  ///
  /// In ar, this message translates to:
  /// **'تنفيذ التسوية الآن'**
  String get executeSettlementNow;

  /// No description provided for @settlingInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جاري التسوية...'**
  String get settlingInProgress;

  /// No description provided for @paymentDevicesSettingsSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ إعدادات أجهزة الدفع'**
  String get paymentDevicesSettingsSaved;

  /// No description provided for @printerType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الطابعة'**
  String get printerType;

  /// No description provided for @thermalUsbPrinter.
  ///
  /// In ar, this message translates to:
  /// **'طابعة حرارية USB'**
  String get thermalUsbPrinter;

  /// No description provided for @bluetoothPortablePrinter.
  ///
  /// In ar, this message translates to:
  /// **'طابعة بلوتوث محمولة'**
  String get bluetoothPortablePrinter;

  /// No description provided for @saveAsPdf.
  ///
  /// In ar, this message translates to:
  /// **'حفظ كملف PDF'**
  String get saveAsPdf;

  /// No description provided for @compactTemplate.
  ///
  /// In ar, this message translates to:
  /// **'مختصر'**
  String get compactTemplate;

  /// No description provided for @basicInfoOnly.
  ///
  /// In ar, this message translates to:
  /// **'معلومات أساسية فقط'**
  String get basicInfoOnly;

  /// No description provided for @detailedTemplate.
  ///
  /// In ar, this message translates to:
  /// **'تفصيلي'**
  String get detailedTemplate;

  /// No description provided for @allDetails.
  ///
  /// In ar, this message translates to:
  /// **'كل التفاصيل'**
  String get allDetails;

  /// No description provided for @printOptions.
  ///
  /// In ar, this message translates to:
  /// **'خيارات الطباعة'**
  String get printOptions;

  /// No description provided for @autoPrinting.
  ///
  /// In ar, this message translates to:
  /// **'الطباعة التلقائية'**
  String get autoPrinting;

  /// No description provided for @autoPrintAfterSale.
  ///
  /// In ar, this message translates to:
  /// **'طباعة الإيصال تلقائياً بعد كل عملية بيع'**
  String get autoPrintAfterSale;

  /// No description provided for @testPrintInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جاري الطباعة التجريبية...'**
  String get testPrintInProgress;

  /// No description provided for @testPrint.
  ///
  /// In ar, this message translates to:
  /// **'طباعة تجريبية'**
  String get testPrint;

  /// No description provided for @printerSettingsSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ إعدادات الطابعة'**
  String get printerSettingsSaved;

  /// No description provided for @printerSettingsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'نوع الطابعة، القالب، الطباعة التلقائية'**
  String get printerSettingsSubtitle;

  /// No description provided for @enableScanner.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الماسح'**
  String get enableScanner;

  /// No description provided for @barcodeScanner.
  ///
  /// In ar, this message translates to:
  /// **'الماسح الضوئي'**
  String get barcodeScanner;

  /// No description provided for @barcodeScannerDesc.
  ///
  /// In ar, this message translates to:
  /// **'استخدام ماسح الباركود لإضافة المنتجات'**
  String get barcodeScannerDesc;

  /// No description provided for @deviceCamera.
  ///
  /// In ar, this message translates to:
  /// **'كاميرا الجهاز'**
  String get deviceCamera;

  /// No description provided for @bluetoothScanner.
  ///
  /// In ar, this message translates to:
  /// **'ماسح Bluetooth'**
  String get bluetoothScanner;

  /// No description provided for @externalScannerConnected.
  ///
  /// In ar, this message translates to:
  /// **'ماسح خارجي متصل'**
  String get externalScannerConnected;

  /// No description provided for @alerts.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات'**
  String get alerts;

  /// No description provided for @beepOnScan.
  ///
  /// In ar, this message translates to:
  /// **'صوت عند المسح'**
  String get beepOnScan;

  /// No description provided for @vibrateOnScan.
  ///
  /// In ar, this message translates to:
  /// **'اهتزاز عند المسح'**
  String get vibrateOnScan;

  /// No description provided for @behavior.
  ///
  /// In ar, this message translates to:
  /// **'السلوك'**
  String get behavior;

  /// No description provided for @autoAddToCart.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تلقائية للسلة'**
  String get autoAddToCart;

  /// No description provided for @autoAddToCartDesc.
  ///
  /// In ar, this message translates to:
  /// **'عند مسح منتج موجود'**
  String get autoAddToCartDesc;

  /// No description provided for @barcodeFormats.
  ///
  /// In ar, this message translates to:
  /// **'صيغ الباركود'**
  String get barcodeFormats;

  /// No description provided for @allFormats.
  ///
  /// In ar, this message translates to:
  /// **'جميع الصيغ'**
  String get allFormats;

  /// No description provided for @unspecified.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get unspecified;

  /// No description provided for @qrCodeOnly.
  ///
  /// In ar, this message translates to:
  /// **'QR Code فقط'**
  String get qrCodeOnly;

  /// No description provided for @testing.
  ///
  /// In ar, this message translates to:
  /// **'الاختبار'**
  String get testing;

  /// No description provided for @testScanner.
  ///
  /// In ar, this message translates to:
  /// **'اختبار الماسح'**
  String get testScanner;

  /// No description provided for @testScanBarcode.
  ///
  /// In ar, this message translates to:
  /// **'تجربة مسح باركود'**
  String get testScanBarcode;

  /// No description provided for @pointCameraAtBarcode.
  ///
  /// In ar, this message translates to:
  /// **'وجه الكاميرا نحو الباركود'**
  String get pointCameraAtBarcode;

  /// No description provided for @scanArea.
  ///
  /// In ar, this message translates to:
  /// **'منطقة المسح'**
  String get scanArea;

  /// No description provided for @barcodeSettingsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الماسح الضوئي، التنبيهات، الصيغ'**
  String get barcodeSettingsSubtitle;

  /// No description provided for @taxSettingsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'VAT, ZATCA, الفوترة الإلكترونية'**
  String get taxSettingsSubtitle;

  /// No description provided for @vatSettings.
  ///
  /// In ar, this message translates to:
  /// **'ضريبة القيمة المضافة'**
  String get vatSettings;

  /// No description provided for @enableVat.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل ضريبة القيمة المضافة'**
  String get enableVat;

  /// No description provided for @enableVatDesc.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق VAT على جميع المبيعات'**
  String get enableVatDesc;

  /// No description provided for @taxRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الضريبة'**
  String get taxRate;

  /// No description provided for @taxNumberHint.
  ///
  /// In ar, this message translates to:
  /// **'15 رقم يبدأ بـ 3'**
  String get taxNumberHint;

  /// No description provided for @pricesIncludeTax.
  ///
  /// In ar, this message translates to:
  /// **'الأسعار شاملة الضريبة'**
  String get pricesIncludeTax;

  /// No description provided for @pricesIncludeTaxDesc.
  ///
  /// In ar, this message translates to:
  /// **'الأسعار المعروضة تتضمن الضريبة'**
  String get pricesIncludeTaxDesc;

  /// No description provided for @showTaxOnReceipt.
  ///
  /// In ar, this message translates to:
  /// **'إظهار الضريبة في الإيصال'**
  String get showTaxOnReceipt;

  /// No description provided for @showTaxOnReceiptDesc.
  ///
  /// In ar, this message translates to:
  /// **'عرض تفاصيل الضريبة'**
  String get showTaxOnReceiptDesc;

  /// No description provided for @zatcaEInvoicing.
  ///
  /// In ar, this message translates to:
  /// **'ZATCA - الفوترة الإلكترونية'**
  String get zatcaEInvoicing;

  /// No description provided for @enableZatca.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل ZATCA'**
  String get enableZatca;

  /// No description provided for @enableZatcaDesc.
  ///
  /// In ar, this message translates to:
  /// **'الامتثال لنظام الفوترة الإلكترونية'**
  String get enableZatcaDesc;

  /// No description provided for @phaseOne.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة الأولى'**
  String get phaseOne;

  /// No description provided for @phaseOneDesc.
  ///
  /// In ar, this message translates to:
  /// **'إصدار الفاتورة'**
  String get phaseOneDesc;

  /// No description provided for @phaseTwo.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة الثانية'**
  String get phaseTwo;

  /// No description provided for @phaseTwoDesc.
  ///
  /// In ar, this message translates to:
  /// **'الربط والتكامل'**
  String get phaseTwoDesc;

  /// No description provided for @taxSettingsSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ إعدادات الضرائب'**
  String get taxSettingsSaved;

  /// No description provided for @discountSettingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الخصومات'**
  String get discountSettingsTitle;

  /// No description provided for @discountSettingsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الخصم اليدوي، VIP، الكمية، الكوبونات'**
  String get discountSettingsSubtitle;

  /// No description provided for @generalDiscounts.
  ///
  /// In ar, this message translates to:
  /// **'الخصومات العامة'**
  String get generalDiscounts;

  /// No description provided for @enableDiscountsOption.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الخصومات'**
  String get enableDiscountsOption;

  /// No description provided for @enableDiscountsDesc.
  ///
  /// In ar, this message translates to:
  /// **'السماح بتطبيق الخصومات'**
  String get enableDiscountsDesc;

  /// No description provided for @manualDiscount.
  ///
  /// In ar, this message translates to:
  /// **'الخصم اليدوي'**
  String get manualDiscount;

  /// No description provided for @manualDiscountDesc.
  ///
  /// In ar, this message translates to:
  /// **'السماح للكاشير بإدخال خصم يدوي'**
  String get manualDiscountDesc;

  /// No description provided for @maxDiscountLimit.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى للخصم'**
  String get maxDiscountLimit;

  /// No description provided for @requireApproval.
  ///
  /// In ar, this message translates to:
  /// **'اشتراط الموافقة'**
  String get requireApproval;

  /// No description provided for @requireApprovalDesc.
  ///
  /// In ar, this message translates to:
  /// **'طلب موافقة المدير للخصم'**
  String get requireApprovalDesc;

  /// No description provided for @vipCustomerDiscount.
  ///
  /// In ar, this message translates to:
  /// **'خصم العملاء المميزين'**
  String get vipCustomerDiscount;

  /// No description provided for @vipDiscount.
  ///
  /// In ar, this message translates to:
  /// **'خصم VIP'**
  String get vipDiscount;

  /// No description provided for @vipDiscountDesc.
  ///
  /// In ar, this message translates to:
  /// **'خصم تلقائي للعملاء المميزين'**
  String get vipDiscountDesc;

  /// No description provided for @vipDiscountRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة خصم VIP'**
  String get vipDiscountRate;

  /// No description provided for @otherDiscounts.
  ///
  /// In ar, this message translates to:
  /// **'خصومات أخرى'**
  String get otherDiscounts;

  /// No description provided for @volumeDiscount.
  ///
  /// In ar, this message translates to:
  /// **'خصم الكمية'**
  String get volumeDiscount;

  /// No description provided for @volumeDiscountDesc.
  ///
  /// In ar, this message translates to:
  /// **'خصم تلقائي عند شراء كمية معينة'**
  String get volumeDiscountDesc;

  /// No description provided for @couponsOption.
  ///
  /// In ar, this message translates to:
  /// **'الكوبونات'**
  String get couponsOption;

  /// No description provided for @couponsDesc.
  ///
  /// In ar, this message translates to:
  /// **'دعم كوبونات الخصم'**
  String get couponsDesc;

  /// No description provided for @discountSettingsSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ إعدادات الخصومات'**
  String get discountSettingsSaved;

  /// No description provided for @interestSettingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الفوائد'**
  String get interestSettingsTitle;

  /// No description provided for @interestSettingsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'النسبة، فترة السماح، الحساب التلقائي'**
  String get interestSettingsSubtitle;

  /// No description provided for @monthlyInterest.
  ///
  /// In ar, this message translates to:
  /// **'الفوائد الشهرية'**
  String get monthlyInterest;

  /// No description provided for @enableInterest.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الفوائد'**
  String get enableInterest;

  /// No description provided for @enableInterestDesc.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق فوائد على الديون الآجلة'**
  String get enableInterestDesc;

  /// No description provided for @monthlyInterestRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الفائدة الشهرية'**
  String get monthlyInterestRate;

  /// No description provided for @maxInterestRateLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى للفائدة'**
  String get maxInterestRateLabel;

  /// No description provided for @gracePeriod.
  ///
  /// In ar, this message translates to:
  /// **'فترة السماح'**
  String get gracePeriod;

  /// No description provided for @graceDays.
  ///
  /// In ar, this message translates to:
  /// **'أيام السماح'**
  String get graceDays;

  /// No description provided for @graceDaysLabel.
  ///
  /// In ar, this message translates to:
  /// **'{days} يوم قبل احتساب الفائدة'**
  String graceDaysLabel(int days);

  /// No description provided for @compoundInterest.
  ///
  /// In ar, this message translates to:
  /// **'الفائدة المركبة'**
  String get compoundInterest;

  /// No description provided for @compoundInterestDesc.
  ///
  /// In ar, this message translates to:
  /// **'احتساب فائدة على الفائدة'**
  String get compoundInterestDesc;

  /// No description provided for @calculationAndAlerts.
  ///
  /// In ar, this message translates to:
  /// **'الحساب والتنبيهات'**
  String get calculationAndAlerts;

  /// No description provided for @autoCalculation.
  ///
  /// In ar, this message translates to:
  /// **'الحساب التلقائي'**
  String get autoCalculation;

  /// No description provided for @autoCalculationDesc.
  ///
  /// In ar, this message translates to:
  /// **'احتساب الفوائد تلقائياً نهاية كل شهر'**
  String get autoCalculationDesc;

  /// No description provided for @customerNotification.
  ///
  /// In ar, this message translates to:
  /// **'إشعار العميل'**
  String get customerNotification;

  /// No description provided for @customerNotificationDesc.
  ///
  /// In ar, this message translates to:
  /// **'إرسال إشعار عند احتساب الفائدة'**
  String get customerNotificationDesc;

  /// No description provided for @interestSettingsSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ إعدادات الفوائد'**
  String get interestSettingsSaved;

  /// No description provided for @receiptTemplateTitle.
  ///
  /// In ar, this message translates to:
  /// **'قالب الإيصال'**
  String get receiptTemplateTitle;

  /// No description provided for @receiptTemplateSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الرأس، التذييل، الحقول، حجم الورق'**
  String get receiptTemplateSubtitle;

  /// No description provided for @headerAndFooter.
  ///
  /// In ar, this message translates to:
  /// **'الرأس والتذييل'**
  String get headerAndFooter;

  /// No description provided for @receiptTitleField.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الإيصال'**
  String get receiptTitleField;

  /// No description provided for @footerText.
  ///
  /// In ar, this message translates to:
  /// **'نص التذييل'**
  String get footerText;

  /// No description provided for @displayedFields.
  ///
  /// In ar, this message translates to:
  /// **'الحقول المعروضة'**
  String get displayedFields;

  /// No description provided for @storeLogo.
  ///
  /// In ar, this message translates to:
  /// **'شعار المتجر'**
  String get storeLogo;

  /// No description provided for @addressField.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get addressField;

  /// No description provided for @phoneNumberField.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumberField;

  /// No description provided for @vatNumberField.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الضريبي'**
  String get vatNumberField;

  /// No description provided for @invoiceBarcode.
  ///
  /// In ar, this message translates to:
  /// **'باركود الفاتورة'**
  String get invoiceBarcode;

  /// No description provided for @qrCodeField.
  ///
  /// In ar, this message translates to:
  /// **'رمز QR'**
  String get qrCodeField;

  /// No description provided for @qrCodeEInvoice.
  ///
  /// In ar, this message translates to:
  /// **'رمز QR للفاتورة الإلكترونية'**
  String get qrCodeEInvoice;

  /// No description provided for @paperSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم الورق'**
  String get paperSize;

  /// No description provided for @standardSize.
  ///
  /// In ar, this message translates to:
  /// **'الحجم القياسي'**
  String get standardSize;

  /// No description provided for @smallSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم صغير'**
  String get smallSize;

  /// No description provided for @normalPrint.
  ///
  /// In ar, this message translates to:
  /// **'طباعة عادية'**
  String get normalPrint;

  /// No description provided for @receiptTemplateSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ قالب الإيصال'**
  String get receiptTemplateSaved;

  /// No description provided for @instantNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات فورية على الجهاز'**
  String get instantNotifications;

  /// No description provided for @emailNotificationsDesc.
  ///
  /// In ar, this message translates to:
  /// **'إرسال إشعارات عبر البريد'**
  String get emailNotificationsDesc;

  /// No description provided for @smsNotificationsDesc.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات عبر الرسائل النصية'**
  String get smsNotificationsDesc;

  /// No description provided for @salesAlertsDesc.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات المبيعات والفواتير'**
  String get salesAlertsDesc;

  /// No description provided for @inventoryAlertsDesc.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات المخزون المنخفض'**
  String get inventoryAlertsDesc;

  /// No description provided for @securityAlertsDesc.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الأمان وتسجيل الدخول'**
  String get securityAlertsDesc;

  /// No description provided for @reportAlertsDesc.
  ///
  /// In ar, this message translates to:
  /// **'تقارير يومية وأسبوعية'**
  String get reportAlertsDesc;

  /// No description provided for @contactSupportDesc.
  ///
  /// In ar, this message translates to:
  /// **'متاح 24/7'**
  String get contactSupportDesc;

  /// No description provided for @systemGuide.
  ///
  /// In ar, this message translates to:
  /// **'دليل استخدام النظام'**
  String get systemGuide;

  /// No description provided for @changeLog.
  ///
  /// In ar, this message translates to:
  /// **'سجل التحديثات'**
  String get changeLog;

  /// No description provided for @faqQuestion1.
  ///
  /// In ar, this message translates to:
  /// **'كيف أضيف منتج جديد؟'**
  String get faqQuestion1;

  /// No description provided for @faqAnswer1.
  ///
  /// In ar, this message translates to:
  /// **'اذهب إلى المنتجات > إضافة منتج واملأ التفاصيل'**
  String get faqAnswer1;

  /// No description provided for @faqQuestion2.
  ///
  /// In ar, this message translates to:
  /// **'كيف أطبع الفواتير؟'**
  String get faqQuestion2;

  /// No description provided for @faqAnswer2.
  ///
  /// In ar, this message translates to:
  /// **'بعد إتمام البيع، اضغط على طباعة الإيصال'**
  String get faqAnswer2;

  /// No description provided for @faqQuestion3.
  ///
  /// In ar, this message translates to:
  /// **'كيف أضبط الخصومات؟'**
  String get faqQuestion3;

  /// No description provided for @faqAnswer3.
  ///
  /// In ar, this message translates to:
  /// **'من الإعدادات > إعدادات الخصومات يمكنك ضبط الخصومات'**
  String get faqAnswer3;

  /// No description provided for @faqQuestion4.
  ///
  /// In ar, this message translates to:
  /// **'كيف أضيف مستخدم جديد؟'**
  String get faqQuestion4;

  /// No description provided for @faqAnswer4.
  ///
  /// In ar, this message translates to:
  /// **'من الإعدادات > إدارة المستخدمين > إضافة مستخدم'**
  String get faqAnswer4;

  /// No description provided for @faqQuestion5.
  ///
  /// In ar, this message translates to:
  /// **'كيف أشاهد التقارير؟'**
  String get faqQuestion5;

  /// No description provided for @faqAnswer5.
  ///
  /// In ar, this message translates to:
  /// **'من القائمة الرئيسية > التقارير، اختر نوع التقرير المطلوب'**
  String get faqAnswer5;

  /// No description provided for @businessNameValue.
  ///
  /// In ar, this message translates to:
  /// **'مؤسسة الهاي'**
  String get businessNameValue;

  /// No description provided for @disabledLabel.
  ///
  /// In ar, this message translates to:
  /// **'معطل'**
  String get disabledLabel;

  /// No description provided for @allFilter.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get allFilter;

  /// No description provided for @loginLogoutFilter.
  ///
  /// In ar, this message translates to:
  /// **'الدخول/الخروج'**
  String get loginLogoutFilter;

  /// No description provided for @salesFilter.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات'**
  String get salesFilter;

  /// No description provided for @productsFilter.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get productsFilter;

  /// No description provided for @usersFilter.
  ///
  /// In ar, this message translates to:
  /// **'المستخدمين'**
  String get usersFilter;

  /// No description provided for @systemFilter.
  ///
  /// In ar, this message translates to:
  /// **'النظام'**
  String get systemFilter;

  /// No description provided for @noActivities.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نشاطات'**
  String get noActivities;

  /// No description provided for @pinSection.
  ///
  /// In ar, this message translates to:
  /// **'رمز PIN'**
  String get pinSection;

  /// No description provided for @createPinOption.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء رمز PIN'**
  String get createPinOption;

  /// No description provided for @createPinDesc.
  ///
  /// In ar, this message translates to:
  /// **'تعيين رمز PIN من 4 أرقام للدخول السريع'**
  String get createPinDesc;

  /// No description provided for @changePinOption.
  ///
  /// In ar, this message translates to:
  /// **'تغيير رمز PIN'**
  String get changePinOption;

  /// No description provided for @changePinDesc.
  ///
  /// In ar, this message translates to:
  /// **'تحديث رمز PIN الحالي'**
  String get changePinDesc;

  /// No description provided for @removePinOption.
  ///
  /// In ar, this message translates to:
  /// **'إزالة رمز PIN'**
  String get removePinOption;

  /// No description provided for @removePinDesc.
  ///
  /// In ar, this message translates to:
  /// **'حذف PIN واستخدام دخول OTP'**
  String get removePinDesc;

  /// No description provided for @biometricSection.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول البيومتري'**
  String get biometricSection;

  /// No description provided for @fingerprintOption.
  ///
  /// In ar, this message translates to:
  /// **'بصمة الإصبع'**
  String get fingerprintOption;

  /// No description provided for @fingerprintDesc.
  ///
  /// In ar, this message translates to:
  /// **'الدخول باستخدام بصمة الإصبع'**
  String get fingerprintDesc;

  /// No description provided for @faceIdOption.
  ///
  /// In ar, this message translates to:
  /// **'التعرف على الوجه'**
  String get faceIdOption;

  /// No description provided for @faceIdDesc.
  ///
  /// In ar, this message translates to:
  /// **'الدخول باستخدام التعرف على الوجه'**
  String get faceIdDesc;

  /// No description provided for @sessionSection.
  ///
  /// In ar, this message translates to:
  /// **'الجلسة'**
  String get sessionSection;

  /// No description provided for @autoLockOption.
  ///
  /// In ar, this message translates to:
  /// **'القفل التلقائي'**
  String get autoLockOption;

  /// No description provided for @autoLockDesc.
  ///
  /// In ar, this message translates to:
  /// **'قفل الشاشة بعد عدم النشاط'**
  String get autoLockDesc;

  /// No description provided for @autoLockTimeout.
  ///
  /// In ar, this message translates to:
  /// **'مدة القفل التلقائي'**
  String get autoLockTimeout;

  /// No description provided for @dangerZone.
  ///
  /// In ar, this message translates to:
  /// **'منطقة الخطر'**
  String get dangerZone;

  /// No description provided for @logoutAllDevices.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج من كل الأجهزة'**
  String get logoutAllDevices;

  /// No description provided for @logoutAllDevicesDesc.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء جميع الجلسات النشطة'**
  String get logoutAllDevicesDesc;

  /// No description provided for @clearAllData.
  ///
  /// In ar, this message translates to:
  /// **'مسح جميع البيانات'**
  String get clearAllData;

  /// No description provided for @clearAllDataDesc.
  ///
  /// In ar, this message translates to:
  /// **'حذف جميع البيانات المحلية'**
  String get clearAllDataDesc;

  /// No description provided for @createPinTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء رمز PIN'**
  String get createPinTitle;

  /// No description provided for @enterNewPin.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز PIN جديد من 4 أرقام'**
  String get enterNewPin;

  /// No description provided for @changePinTitle.
  ///
  /// In ar, this message translates to:
  /// **'تغيير رمز PIN'**
  String get changePinTitle;

  /// No description provided for @enterCurrentPin.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز PIN الحالي'**
  String get enterCurrentPin;

  /// No description provided for @enterNewPinChange.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز PIN الجديد'**
  String get enterNewPinChange;

  /// No description provided for @removePinTitle.
  ///
  /// In ar, this message translates to:
  /// **'إزالة رمز PIN'**
  String get removePinTitle;

  /// No description provided for @removePinConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من إزالة تسجيل الدخول بـ PIN؟'**
  String get removePinConfirm;

  /// No description provided for @removeAction.
  ///
  /// In ar, this message translates to:
  /// **'إزالة'**
  String get removeAction;

  /// No description provided for @pinCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء رمز PIN بنجاح'**
  String get pinCreated;

  /// No description provided for @pinChangedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير رمز PIN بنجاح'**
  String get pinChangedSuccess;

  /// No description provided for @pinRemovedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إزالة رمز PIN'**
  String get pinRemovedSuccess;

  /// No description provided for @logoutAllTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج من كل الأجهزة'**
  String get logoutAllTitle;

  /// No description provided for @logoutAllConfirm.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إنهاء جميع الجلسات النشطة. ستحتاج لتسجيل الدخول مرة أخرى.'**
  String get logoutAllConfirm;

  /// No description provided for @logoutAllAction.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج من الكل'**
  String get logoutAllAction;

  /// No description provided for @loggedOutAll.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الخروج من جميع الأجهزة'**
  String get loggedOutAll;

  /// No description provided for @clearDataTitle.
  ///
  /// In ar, this message translates to:
  /// **'مسح جميع البيانات'**
  String get clearDataTitle;

  /// No description provided for @clearDataConfirm.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف جميع البيانات المحلية. هذا الإجراء لا يمكن التراجع عنه.'**
  String get clearDataConfirm;

  /// No description provided for @clearDataAction.
  ///
  /// In ar, this message translates to:
  /// **'مسح البيانات'**
  String get clearDataAction;

  /// No description provided for @dataCleared.
  ///
  /// In ar, this message translates to:
  /// **'تم مسح جميع البيانات'**
  String get dataCleared;

  /// No description provided for @afterMinutes.
  ///
  /// In ar, this message translates to:
  /// **'بعد {count} دقيقة'**
  String afterMinutes(int count);

  /// No description provided for @storeInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات المتجر'**
  String get storeInfo;

  /// No description provided for @storeNameField.
  ///
  /// In ar, this message translates to:
  /// **'اسم المتجر'**
  String get storeNameField;

  /// No description provided for @addressLabel.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get addressLabel;

  /// No description provided for @taxInfo.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الضريبية'**
  String get taxInfo;

  /// No description provided for @vatNumberFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الضريبي (VAT)'**
  String get vatNumberFieldLabel;

  /// No description provided for @vatNumberHintText.
  ///
  /// In ar, this message translates to:
  /// **'15 رقم يبدأ بـ 3'**
  String get vatNumberHintText;

  /// No description provided for @commercialRegister.
  ///
  /// In ar, this message translates to:
  /// **'السجل التجاري'**
  String get commercialRegister;

  /// No description provided for @enableVatOption.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل ضريبة القيمة المضافة'**
  String get enableVatOption;

  /// No description provided for @taxRateField.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الضريبة'**
  String get taxRateField;

  /// No description provided for @languageAndCurrency.
  ///
  /// In ar, this message translates to:
  /// **'اللغة والعملة'**
  String get languageAndCurrency;

  /// No description provided for @currencyFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'العملة'**
  String get currencyFieldLabel;

  /// No description provided for @saudiRiyal.
  ///
  /// In ar, this message translates to:
  /// **'ريال سعودي (SAR)'**
  String get saudiRiyal;

  /// No description provided for @usDollar.
  ///
  /// In ar, this message translates to:
  /// **'دولار أمريكي (USD)'**
  String get usDollar;

  /// No description provided for @storeLogoSection.
  ///
  /// In ar, this message translates to:
  /// **'شعار المتجر'**
  String get storeLogoSection;

  /// No description provided for @storeLogoDesc.
  ///
  /// In ar, this message translates to:
  /// **'يظهر في الفواتير والإيصالات'**
  String get storeLogoDesc;

  /// No description provided for @changeButton.
  ///
  /// In ar, this message translates to:
  /// **'تغيير'**
  String get changeButton;

  /// No description provided for @storeSettingsSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ إعدادات المتجر'**
  String get storeSettingsSaved;

  /// No description provided for @ownerRole.
  ///
  /// In ar, this message translates to:
  /// **'مالك'**
  String get ownerRole;

  /// No description provided for @managerRole.
  ///
  /// In ar, this message translates to:
  /// **'مدير'**
  String get managerRole;

  /// No description provided for @supervisorRole.
  ///
  /// In ar, this message translates to:
  /// **'مشرف'**
  String get supervisorRole;

  /// No description provided for @cashierRole.
  ///
  /// In ar, this message translates to:
  /// **'كاشير'**
  String get cashierRole;

  /// No description provided for @disabledStatus.
  ///
  /// In ar, this message translates to:
  /// **'معطّل'**
  String get disabledStatus;

  /// No description provided for @editMenuAction.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get editMenuAction;

  /// No description provided for @disableMenuAction.
  ///
  /// In ar, this message translates to:
  /// **'تعطيل'**
  String get disableMenuAction;

  /// No description provided for @enableMenuAction.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل'**
  String get enableMenuAction;

  /// No description provided for @addUserTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مستخدم'**
  String get addUserTitle;

  /// No description provided for @editUserTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المستخدم'**
  String get editUserTitle;

  /// No description provided for @nameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم *'**
  String get nameRequired;

  /// No description provided for @roleLabel.
  ///
  /// In ar, this message translates to:
  /// **'الصلاحية'**
  String get roleLabel;

  /// No description provided for @userDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المستخدم'**
  String get userDetailsTitle;

  /// No description provided for @rolesTab.
  ///
  /// In ar, this message translates to:
  /// **'الأدوار'**
  String get rolesTab;

  /// No description provided for @permissionsTab.
  ///
  /// In ar, this message translates to:
  /// **'الصلاحيات'**
  String get permissionsTab;

  /// No description provided for @newRoleButton.
  ///
  /// In ar, this message translates to:
  /// **'دور جديد'**
  String get newRoleButton;

  /// No description provided for @systemBadge.
  ///
  /// In ar, this message translates to:
  /// **'نظام'**
  String get systemBadge;

  /// No description provided for @userCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count} مستخدم'**
  String userCountLabel(int count);

  /// No description provided for @permissionCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count} صلاحية'**
  String permissionCountLabel(int count);

  /// No description provided for @editRoleMenu.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get editRoleMenu;

  /// No description provided for @duplicateRoleMenu.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get duplicateRoleMenu;

  /// No description provided for @deleteRoleMenu.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get deleteRoleMenu;

  /// No description provided for @addRoleTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دور'**
  String get addRoleTitle;

  /// No description provided for @editRoleTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الدور'**
  String get editRoleTitle;

  /// No description provided for @roleNameField.
  ///
  /// In ar, this message translates to:
  /// **'اسم الدور'**
  String get roleNameField;

  /// No description provided for @roleDescField.
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get roleDescField;

  /// No description provided for @rolePermissionsLabel.
  ///
  /// In ar, this message translates to:
  /// **'الصلاحيات'**
  String get rolePermissionsLabel;

  /// No description provided for @permViewSales.
  ///
  /// In ar, this message translates to:
  /// **'عرض المبيعات'**
  String get permViewSales;

  /// No description provided for @permViewSalesDesc.
  ///
  /// In ar, this message translates to:
  /// **'عرض المبيعات والفواتير'**
  String get permViewSalesDesc;

  /// No description provided for @permCreateSale.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء بيع'**
  String get permCreateSale;

  /// No description provided for @permCreateSaleDesc.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء عمليات بيع جديدة'**
  String get permCreateSaleDesc;

  /// No description provided for @permApplyDiscount.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق خصم'**
  String get permApplyDiscount;

  /// No description provided for @permApplyDiscountDesc.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق خصومات على الفواتير'**
  String get permApplyDiscountDesc;

  /// No description provided for @permVoidSale.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء بيع'**
  String get permVoidSale;

  /// No description provided for @permVoidSaleDesc.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء وحذف عمليات البيع'**
  String get permVoidSaleDesc;

  /// No description provided for @permViewProducts.
  ///
  /// In ar, this message translates to:
  /// **'عرض المنتجات'**
  String get permViewProducts;

  /// No description provided for @permViewProductsDesc.
  ///
  /// In ar, this message translates to:
  /// **'عرض قائمة المنتجات'**
  String get permViewProductsDesc;

  /// No description provided for @permEditProducts.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المنتجات'**
  String get permEditProducts;

  /// No description provided for @permEditProductsDesc.
  ///
  /// In ar, this message translates to:
  /// **'تعديل تفاصيل وأسعار المنتجات'**
  String get permEditProductsDesc;

  /// No description provided for @permManageInventory.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المخزون'**
  String get permManageInventory;

  /// No description provided for @permManageInventoryDesc.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المخزون والجرد'**
  String get permManageInventoryDesc;

  /// No description provided for @permViewReports.
  ///
  /// In ar, this message translates to:
  /// **'عرض التقارير'**
  String get permViewReports;

  /// No description provided for @permViewReportsDesc.
  ///
  /// In ar, this message translates to:
  /// **'عرض جميع التقارير'**
  String get permViewReportsDesc;

  /// No description provided for @permExportReports.
  ///
  /// In ar, this message translates to:
  /// **'تصدير التقارير'**
  String get permExportReports;

  /// No description provided for @permExportReportsDesc.
  ///
  /// In ar, this message translates to:
  /// **'تصدير التقارير كـ PDF/Excel'**
  String get permExportReportsDesc;

  /// No description provided for @permViewCustomers.
  ///
  /// In ar, this message translates to:
  /// **'عرض العملاء'**
  String get permViewCustomers;

  /// No description provided for @permViewCustomersDesc.
  ///
  /// In ar, this message translates to:
  /// **'عرض قائمة العملاء'**
  String get permViewCustomersDesc;

  /// No description provided for @permManageCustomers.
  ///
  /// In ar, this message translates to:
  /// **'إدارة العملاء'**
  String get permManageCustomers;

  /// No description provided for @permManageCustomersDesc.
  ///
  /// In ar, this message translates to:
  /// **'إضافة وتعديل العملاء'**
  String get permManageCustomersDesc;

  /// No description provided for @permManageDebts.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الديون'**
  String get permManageDebts;

  /// No description provided for @permManageDebtsDesc.
  ///
  /// In ar, this message translates to:
  /// **'إدارة ديون العملاء'**
  String get permManageDebtsDesc;

  /// No description provided for @permOpenCloseShift.
  ///
  /// In ar, this message translates to:
  /// **'فتح/إغلاق الوردية'**
  String get permOpenCloseShift;

  /// No description provided for @permOpenCloseShiftDesc.
  ///
  /// In ar, this message translates to:
  /// **'فتح وإغلاق ورديات العمل'**
  String get permOpenCloseShiftDesc;

  /// No description provided for @permManageCashDrawer.
  ///
  /// In ar, this message translates to:
  /// **'إدارة درج النقد'**
  String get permManageCashDrawer;

  /// No description provided for @permManageCashDrawerDesc.
  ///
  /// In ar, this message translates to:
  /// **'إضافة وسحب النقد'**
  String get permManageCashDrawerDesc;

  /// No description provided for @permManageUsers.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المستخدمين'**
  String get permManageUsers;

  /// No description provided for @permManageUsersDesc.
  ///
  /// In ar, this message translates to:
  /// **'إضافة وتعديل المستخدمين'**
  String get permManageUsersDesc;

  /// No description provided for @permManageRoles.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الأدوار'**
  String get permManageRoles;

  /// No description provided for @permManageRolesDesc.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الأدوار والصلاحيات'**
  String get permManageRolesDesc;

  /// No description provided for @permViewSettings.
  ///
  /// In ar, this message translates to:
  /// **'عرض الإعدادات'**
  String get permViewSettings;

  /// No description provided for @permViewSettingsDesc.
  ///
  /// In ar, this message translates to:
  /// **'عرض إعدادات النظام'**
  String get permViewSettingsDesc;

  /// No description provided for @permEditSettings.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الإعدادات'**
  String get permEditSettings;

  /// No description provided for @permEditSettingsDesc.
  ///
  /// In ar, this message translates to:
  /// **'تعديل إعدادات النظام'**
  String get permEditSettingsDesc;

  /// No description provided for @permViewAuditLog.
  ///
  /// In ar, this message translates to:
  /// **'عرض سجل النشاطات'**
  String get permViewAuditLog;

  /// No description provided for @permViewAuditLogDesc.
  ///
  /// In ar, this message translates to:
  /// **'عرض سجل النشاطات'**
  String get permViewAuditLogDesc;

  /// No description provided for @permManageBackup.
  ///
  /// In ar, this message translates to:
  /// **'إدارة النسخ الاحتياطي'**
  String get permManageBackup;

  /// No description provided for @permManageBackupDesc.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي والاستعادة'**
  String get permManageBackupDesc;

  /// No description provided for @permCategorySales.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات'**
  String get permCategorySales;

  /// No description provided for @permCategoryProducts.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get permCategoryProducts;

  /// No description provided for @permCategoryReports.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get permCategoryReports;

  /// No description provided for @permCategoryCustomers.
  ///
  /// In ar, this message translates to:
  /// **'العملاء'**
  String get permCategoryCustomers;

  /// No description provided for @permCategoryShifts.
  ///
  /// In ar, this message translates to:
  /// **'الورديات'**
  String get permCategoryShifts;

  /// No description provided for @permCategoryUsers.
  ///
  /// In ar, this message translates to:
  /// **'المستخدمين'**
  String get permCategoryUsers;

  /// No description provided for @permCategorySettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get permCategorySettings;

  /// No description provided for @permCategorySecurity.
  ///
  /// In ar, this message translates to:
  /// **'الأمان'**
  String get permCategorySecurity;

  /// No description provided for @autoBackupEnabled.
  ///
  /// In ar, this message translates to:
  /// **'يتم النسخ تلقائياً'**
  String get autoBackupEnabled;

  /// No description provided for @autoBackupDisabledLabel.
  ///
  /// In ar, this message translates to:
  /// **'معطل'**
  String get autoBackupDisabledLabel;

  /// No description provided for @backupFrequency.
  ///
  /// In ar, this message translates to:
  /// **'تكرار النسخ'**
  String get backupFrequency;

  /// No description provided for @everyHour.
  ///
  /// In ar, this message translates to:
  /// **'كل ساعة'**
  String get everyHour;

  /// No description provided for @dailyBackup.
  ///
  /// In ar, this message translates to:
  /// **'يومياً'**
  String get dailyBackup;

  /// No description provided for @weeklyBackup.
  ///
  /// In ar, this message translates to:
  /// **'أسبوعياً'**
  String get weeklyBackup;

  /// No description provided for @manualBackupSection.
  ///
  /// In ar, this message translates to:
  /// **'النسخ اليدوي'**
  String get manualBackupSection;

  /// No description provided for @createBackupNow.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء نسخة احتياطية الآن'**
  String get createBackupNow;

  /// No description provided for @lastBackupTime.
  ///
  /// In ar, this message translates to:
  /// **'آخر نسخة: منذ 3 ساعات'**
  String get lastBackupTime;

  /// No description provided for @restoreSection.
  ///
  /// In ar, this message translates to:
  /// **'الاستعادة'**
  String get restoreSection;

  /// No description provided for @restoreFromBackup.
  ///
  /// In ar, this message translates to:
  /// **'استعادة من نسخة احتياطية'**
  String get restoreFromBackup;

  /// No description provided for @restoreFromBackupDesc.
  ///
  /// In ar, this message translates to:
  /// **'استرجاع البيانات من نسخة سابقة'**
  String get restoreFromBackupDesc;

  /// No description provided for @backupHistoryLabel.
  ///
  /// In ar, this message translates to:
  /// **'سجل النسخ الاحتياطي'**
  String get backupHistoryLabel;

  /// No description provided for @backupInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جاري إنشاء النسخة الاحتياطية...'**
  String get backupInProgress;

  /// No description provided for @backupCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء النسخة الاحتياطية بنجاح'**
  String get backupCreated;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'استعادة من نسخة احتياطية'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'سيتم استبدال جميع البيانات الحالية. هذا الإجراء لا يمكن التراجع عنه.'**
  String get restoreConfirmMessage;

  /// No description provided for @restoreAction.
  ///
  /// In ar, this message translates to:
  /// **'استعادة'**
  String get restoreAction;

  /// No description provided for @restoreInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جاري الاستعادة...'**
  String get restoreInProgress;

  /// No description provided for @restoreComplete.
  ///
  /// In ar, this message translates to:
  /// **'تمت الاستعادة بنجاح'**
  String get restoreComplete;

  /// No description provided for @pasteCode.
  ///
  /// In ar, this message translates to:
  /// **'لصق الرمز'**
  String get pasteCode;

  /// No description provided for @devOtpMessage.
  ///
  /// In ar, this message translates to:
  /// **'رمز التطوير: {otp}'**
  String devOtpMessage(String otp);

  /// No description provided for @orderHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الطلبات'**
  String get orderHistory;

  /// No description provided for @history.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get history;

  /// No description provided for @selectDateRange.
  ///
  /// In ar, this message translates to:
  /// **'تحديد فترة'**
  String get selectDateRange;

  /// No description provided for @orderSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث برقم الطلب أو معرف العميل...'**
  String get orderSearchHint;

  /// No description provided for @noOrders.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات'**
  String get noOrders;

  /// No description provided for @orderStatusConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'مؤكد'**
  String get orderStatusConfirmed;

  /// No description provided for @orderStatusPreparing.
  ///
  /// In ar, this message translates to:
  /// **'قيد التحضير'**
  String get orderStatusPreparing;

  /// No description provided for @orderStatusReady.
  ///
  /// In ar, this message translates to:
  /// **'جاهز'**
  String get orderStatusReady;

  /// No description provided for @orderStatusDelivering.
  ///
  /// In ar, this message translates to:
  /// **'قيد التوصيل'**
  String get orderStatusDelivering;

  /// No description provided for @filterOrders.
  ///
  /// In ar, this message translates to:
  /// **'فلترة الطلبات'**
  String get filterOrders;

  /// No description provided for @channelApp.
  ///
  /// In ar, this message translates to:
  /// **'التطبيق'**
  String get channelApp;

  /// No description provided for @channelWhatsapp.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get channelWhatsapp;

  /// No description provided for @channelPos.
  ///
  /// In ar, this message translates to:
  /// **'نقطة البيع'**
  String get channelPos;

  /// No description provided for @paymentCashType.
  ///
  /// In ar, this message translates to:
  /// **'نقدي'**
  String get paymentCashType;

  /// No description provided for @paymentMixed.
  ///
  /// In ar, this message translates to:
  /// **'مختلط'**
  String get paymentMixed;

  /// No description provided for @paymentOnline.
  ///
  /// In ar, this message translates to:
  /// **'إلكتروني'**
  String get paymentOnline;

  /// No description provided for @shareAction.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get shareAction;

  /// No description provided for @exportOrders.
  ///
  /// In ar, this message translates to:
  /// **'تصدير الطلبات'**
  String get exportOrders;

  /// No description provided for @selectExportFormat.
  ///
  /// In ar, this message translates to:
  /// **'اختر صيغة التصدير'**
  String get selectExportFormat;

  /// No description provided for @exportedAsExcel.
  ///
  /// In ar, this message translates to:
  /// **'تم التصدير كـ Excel'**
  String get exportedAsExcel;

  /// No description provided for @exportedAsPdf.
  ///
  /// In ar, this message translates to:
  /// **'تم التصدير كـ PDF'**
  String get exportedAsPdf;

  /// No description provided for @alertSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات التنبيهات'**
  String get alertSettings;

  /// No description provided for @acknowledgeAll.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الكل'**
  String get acknowledgeAll;

  /// No description provided for @allWithCount.
  ///
  /// In ar, this message translates to:
  /// **'الكل ({count})'**
  String allWithCount(int count);

  /// No description provided for @lowStockWithCount.
  ///
  /// In ar, this message translates to:
  /// **'نفاد مخزون ({count})'**
  String lowStockWithCount(int count);

  /// No description provided for @expiryWithCount.
  ///
  /// In ar, this message translates to:
  /// **'انتهاء صلاحية ({count})'**
  String expiryWithCount(int count);

  /// No description provided for @urgentAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات عاجلة'**
  String get urgentAlerts;

  /// No description provided for @nearExpiry.
  ///
  /// In ar, this message translates to:
  /// **'قرب الانتهاء'**
  String get nearExpiry;

  /// No description provided for @noAlerts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تنبيهات'**
  String get noAlerts;

  /// No description provided for @alertDismissed.
  ///
  /// In ar, this message translates to:
  /// **'تم إخفاء التنبيه'**
  String get alertDismissed;

  /// No description provided for @undo.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get undo;

  /// No description provided for @criticalPriority.
  ///
  /// In ar, this message translates to:
  /// **'حرج'**
  String get criticalPriority;

  /// No description provided for @highPriority.
  ///
  /// In ar, this message translates to:
  /// **'عاجل'**
  String get highPriority;

  /// No description provided for @stockAlertMessage.
  ///
  /// In ar, this message translates to:
  /// **'الكمية: {current} (الحد الأدنى: {threshold})'**
  String stockAlertMessage(int current, int threshold);

  /// No description provided for @expiryAlertLabel.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه صلاحية'**
  String get expiryAlertLabel;

  /// No description provided for @currentQuantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية الحالية'**
  String get currentQuantity;

  /// No description provided for @minimumThreshold.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى'**
  String get minimumThreshold;

  /// No description provided for @dismissAction.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get dismissAction;

  /// No description provided for @lowStockNotifications.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات نفاد المخزون'**
  String get lowStockNotifications;

  /// No description provided for @expiryNotifications.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات انتهاء الصلاحية'**
  String get expiryNotifications;

  /// No description provided for @minimumStockLevel.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى للمخزون'**
  String get minimumStockLevel;

  /// No description provided for @thresholdUnits.
  ///
  /// In ar, this message translates to:
  /// **'{count} وحدة'**
  String thresholdUnits(int count);

  /// No description provided for @acknowledgeAllAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد جميع التنبيهات'**
  String get acknowledgeAllAlerts;

  /// No description provided for @willDismissAlerts.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إخفاء {count} تنبيه'**
  String willDismissAlerts(int count);

  /// No description provided for @allAlertsAcknowledged.
  ///
  /// In ar, this message translates to:
  /// **'تم تأكيد جميع التنبيهات'**
  String get allAlertsAcknowledged;

  /// No description provided for @createPurchaseOrder.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء طلب شراء'**
  String get createPurchaseOrder;

  /// No description provided for @productLabelName.
  ///
  /// In ar, this message translates to:
  /// **'المنتج: {name}'**
  String productLabelName(String name);

  /// No description provided for @requiredQuantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المطلوبة'**
  String get requiredQuantity;

  /// No description provided for @createAction.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء'**
  String get createAction;

  /// No description provided for @purchaseOrderCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء طلب الشراء'**
  String get purchaseOrderCreated;

  /// No description provided for @newCategory.
  ///
  /// In ar, this message translates to:
  /// **'فئة جديدة'**
  String get newCategory;

  /// No description provided for @productCountUnit.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا توجد منتجات} one{منتج واحد} two{منتجان} few{{count} منتجات} many{{count} منتجاً} other{{count} منتج}}'**
  String productCountUnit(int count);

  /// No description provided for @iconLabel.
  ///
  /// In ar, this message translates to:
  /// **'الأيقونة:'**
  String get iconLabel;

  /// No description provided for @colorLabel.
  ///
  /// In ar, this message translates to:
  /// **'اللون:'**
  String get colorLabel;

  /// No description provided for @deleteCategoryMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف فئة \"{name}\"؟\nسيتم نقل {count} منتج إلى \"بدون فئة\".'**
  String deleteCategoryMessage(String name, int count);

  /// No description provided for @productNumber.
  ///
  /// In ar, this message translates to:
  /// **'منتج {number}'**
  String productNumber(int number);

  /// No description provided for @priceWithCurrency.
  ///
  /// In ar, this message translates to:
  /// **'{price} ر.س'**
  String priceWithCurrency(String price);

  /// No description provided for @currentlyOpenShift.
  ///
  /// In ar, this message translates to:
  /// **'وردية مفتوحة حالياً'**
  String get currentlyOpenShift;

  /// No description provided for @since.
  ///
  /// In ar, this message translates to:
  /// **'منذ'**
  String get since;

  /// No description provided for @transaction.
  ///
  /// In ar, this message translates to:
  /// **'عملية'**
  String get transaction;

  /// No description provided for @totalTransactions.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي العمليات'**
  String get totalTransactions;

  /// No description provided for @openShifts.
  ///
  /// In ar, this message translates to:
  /// **'ورديات مفتوحة'**
  String get openShifts;

  /// No description provided for @closedShifts.
  ///
  /// In ar, this message translates to:
  /// **'ورديات مغلقة'**
  String get closedShifts;

  /// No description provided for @shiftsLog.
  ///
  /// In ar, this message translates to:
  /// **'سجل الورديات'**
  String get shiftsLog;

  /// No description provided for @noShiftsToday.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ورديات اليوم'**
  String get noShiftsToday;

  /// No description provided for @open.
  ///
  /// In ar, this message translates to:
  /// **'مفتوحة'**
  String get open;

  /// No description provided for @customPeriod.
  ///
  /// In ar, this message translates to:
  /// **'فترة مخصصة'**
  String get customPeriod;

  /// No description provided for @salesReport.
  ///
  /// In ar, this message translates to:
  /// **'تقرير المبيعات'**
  String get salesReport;

  /// No description provided for @salesReportDesc.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المبيعات والفواتير'**
  String get salesReportDesc;

  /// No description provided for @profitReport.
  ///
  /// In ar, this message translates to:
  /// **'تقرير الأرباح'**
  String get profitReport;

  /// No description provided for @profitReportDesc.
  ///
  /// In ar, this message translates to:
  /// **'صافي الربح والخسائر'**
  String get profitReportDesc;

  /// No description provided for @inventoryReport.
  ///
  /// In ar, this message translates to:
  /// **'تقرير المخزون'**
  String get inventoryReport;

  /// No description provided for @inventoryReportDesc.
  ///
  /// In ar, this message translates to:
  /// **'حركات المخزون والجرد'**
  String get inventoryReportDesc;

  /// No description provided for @vatReport.
  ///
  /// In ar, this message translates to:
  /// **'تقرير الضريبة (VAT)'**
  String get vatReport;

  /// No description provided for @vatReportDesc.
  ///
  /// In ar, this message translates to:
  /// **'ضريبة القيمة المضافة 15%'**
  String get vatReportDesc;

  /// No description provided for @customerReport.
  ///
  /// In ar, this message translates to:
  /// **'تقرير العملاء'**
  String get customerReport;

  /// No description provided for @customerReportDesc.
  ///
  /// In ar, this message translates to:
  /// **'نشاط العملاء والديون'**
  String get customerReportDesc;

  /// No description provided for @purchasesReport.
  ///
  /// In ar, this message translates to:
  /// **'تقرير المشتريات'**
  String get purchasesReport;

  /// No description provided for @purchasesReportDesc.
  ///
  /// In ar, this message translates to:
  /// **'فواتير الشراء والموردين'**
  String get purchasesReportDesc;

  /// No description provided for @costs.
  ///
  /// In ar, this message translates to:
  /// **'التكاليف'**
  String get costs;

  /// No description provided for @netProfit.
  ///
  /// In ar, this message translates to:
  /// **'صافي الربح'**
  String get netProfit;

  /// No description provided for @salesTax.
  ///
  /// In ar, this message translates to:
  /// **'ضريبة المبيعات'**
  String get salesTax;

  /// No description provided for @purchasesTax.
  ///
  /// In ar, this message translates to:
  /// **'ضريبة المشتريات'**
  String get purchasesTax;

  /// No description provided for @taxDue.
  ///
  /// In ar, this message translates to:
  /// **'المستحق'**
  String get taxDue;

  /// No description provided for @debts.
  ///
  /// In ar, this message translates to:
  /// **'الديون'**
  String get debts;

  /// No description provided for @paidDebts.
  ///
  /// In ar, this message translates to:
  /// **'المسددة'**
  String get paidDebts;

  /// No description provided for @averageAmount.
  ///
  /// In ar, this message translates to:
  /// **'المتوسط'**
  String get averageAmount;

  /// No description provided for @suppliers.
  ///
  /// In ar, this message translates to:
  /// **'الموردين'**
  String get suppliers;

  /// No description provided for @todayExpenses.
  ///
  /// In ar, this message translates to:
  /// **'مصروفات اليوم'**
  String get todayExpenses;

  /// No description provided for @transactionCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد العمليات'**
  String get transactionCount;

  /// No description provided for @salaries.
  ///
  /// In ar, this message translates to:
  /// **'رواتب'**
  String get salaries;

  /// No description provided for @rent.
  ///
  /// In ar, this message translates to:
  /// **'إيجار'**
  String get rent;

  /// No description provided for @purchases.
  ///
  /// In ar, this message translates to:
  /// **'المشتريات'**
  String get purchases;

  /// No description provided for @noDriversRegistered.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سائقون مسجلون'**
  String get noDriversRegistered;

  /// No description provided for @addDriversForDelivery.
  ///
  /// In ar, this message translates to:
  /// **'أضف سائقين لإدارة التوصيل'**
  String get addDriversForDelivery;

  /// No description provided for @onDelivery.
  ///
  /// In ar, this message translates to:
  /// **'في توصيلة'**
  String get onDelivery;

  /// No description provided for @unavailable.
  ///
  /// In ar, this message translates to:
  /// **'غير متاح'**
  String get unavailable;

  /// No description provided for @totalDrivers.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي السائقين'**
  String get totalDrivers;

  /// No description provided for @availableDrivers.
  ///
  /// In ar, this message translates to:
  /// **'سائقون متاحون'**
  String get availableDrivers;

  /// No description provided for @inDelivery.
  ///
  /// In ar, this message translates to:
  /// **'في التوصيل'**
  String get inDelivery;

  /// No description provided for @excellentRating.
  ///
  /// In ar, this message translates to:
  /// **'تقييم ممتاز'**
  String get excellentRating;

  /// No description provided for @delivery.
  ///
  /// In ar, this message translates to:
  /// **'توصيلة'**
  String get delivery;

  /// No description provided for @track.
  ///
  /// In ar, this message translates to:
  /// **'تتبع'**
  String get track;

  /// No description provided for @percentage.
  ///
  /// In ar, this message translates to:
  /// **'نسبة مئوية'**
  String get percentage;

  /// No description provided for @totalSavings.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي التوفير'**
  String get totalSavings;

  /// No description provided for @totalUsage.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الاستخدام'**
  String get totalUsage;

  /// No description provided for @times.
  ///
  /// In ar, this message translates to:
  /// **'مرات'**
  String get times;

  /// No description provided for @activeOffers.
  ///
  /// In ar, this message translates to:
  /// **'عروض فعالة'**
  String get activeOffers;

  /// No description provided for @upcomingOffers.
  ///
  /// In ar, this message translates to:
  /// **'عروض قادمة'**
  String get upcomingOffers;

  /// No description provided for @expiredOffers.
  ///
  /// In ar, this message translates to:
  /// **'عروض منتهية'**
  String get expiredOffers;

  /// No description provided for @bundle.
  ///
  /// In ar, this message translates to:
  /// **'باقة'**
  String get bundle;

  /// No description provided for @dueDebts.
  ///
  /// In ar, this message translates to:
  /// **'ديون مستحقة'**
  String get dueDebts;

  /// No description provided for @collected.
  ///
  /// In ar, this message translates to:
  /// **'تم التحصيل'**
  String get collected;

  /// No description provided for @newNotification.
  ///
  /// In ar, this message translates to:
  /// **'إشعار جديد'**
  String get newNotification;

  /// No description provided for @oneHourAgo.
  ///
  /// In ar, this message translates to:
  /// **'قبل ساعة'**
  String get oneHourAgo;

  /// No description provided for @twoHoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'قبل ساعتين'**
  String get twoHoursAgo;

  /// No description provided for @trackingMap.
  ///
  /// In ar, this message translates to:
  /// **'خريطة التتبع'**
  String get trackingMap;

  /// No description provided for @deliveriesToday.
  ///
  /// In ar, this message translates to:
  /// **'{count} توصيلة اليوم'**
  String deliveriesToday(int count);

  /// No description provided for @assignOrder.
  ///
  /// In ar, this message translates to:
  /// **'تعيين طلب'**
  String get assignOrder;

  /// No description provided for @driversTrackingMap.
  ///
  /// In ar, this message translates to:
  /// **'خريطة تتبع السائقين'**
  String get driversTrackingMap;

  /// No description provided for @gpsSubscriptionRequired.
  ///
  /// In ar, this message translates to:
  /// **'(يتطلب اشتراك GPS)'**
  String get gpsSubscriptionRequired;

  /// No description provided for @vehicleLabel.
  ///
  /// In ar, this message translates to:
  /// **'المركبة'**
  String get vehicleLabel;

  /// No description provided for @vehicleHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: هايلكس - أبيض'**
  String get vehicleHint;

  /// No description provided for @plateNumberLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم اللوحة'**
  String get plateNumberLabel;

  /// No description provided for @assignOrderTo.
  ///
  /// In ar, this message translates to:
  /// **'تعيين طلب لـ {name}'**
  String assignOrderTo(String name);

  /// No description provided for @orderLabel.
  ///
  /// In ar, this message translates to:
  /// **'طلب'**
  String get orderLabel;

  /// No description provided for @orderAssignedTo.
  ///
  /// In ar, this message translates to:
  /// **'تم تعيين الطلب لـ {name}'**
  String orderAssignedTo(String name);

  /// No description provided for @closingPeriod.
  ///
  /// In ar, this message translates to:
  /// **'فترة الإقفال: {period}'**
  String closingPeriod(String period);

  /// No description provided for @lastClosing.
  ///
  /// In ar, this message translates to:
  /// **'آخر إقفال: {date}'**
  String lastClosing(String date);

  /// No description provided for @interestRateAndGrace.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الفائدة: {rate}% | فترة السماح: {days} يوم'**
  String interestRateAndGrace(String rate, String days);

  /// No description provided for @selectedCustomers.
  ///
  /// In ar, this message translates to:
  /// **'العملاء المحددون'**
  String get selectedCustomers;

  /// No description provided for @expectedInterests.
  ///
  /// In ar, this message translates to:
  /// **'الفوائد المتوقعة'**
  String get expectedInterests;

  /// No description provided for @noDebtsNeedClosing.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ديون تحتاج إقفال'**
  String get noDebtsNeedClosing;

  /// No description provided for @allCustomersWithinGrace.
  ///
  /// In ar, this message translates to:
  /// **'جميع العملاء ضمن فترة السماح'**
  String get allCustomersWithinGrace;

  /// No description provided for @debtLabel.
  ///
  /// In ar, this message translates to:
  /// **'الدين: {amount} ر.س'**
  String debtLabel(String amount);

  /// No description provided for @expectedInterestLabel.
  ///
  /// In ar, this message translates to:
  /// **'الفائدة المتوقعة: {amount} ر.س'**
  String expectedInterestLabel(String amount);

  /// No description provided for @selectedCustomerCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} عميل مختار'**
  String selectedCustomerCount(int count);

  /// No description provided for @processingClose.
  ///
  /// In ar, this message translates to:
  /// **'جاري المعالجة...'**
  String get processingClose;

  /// No description provided for @executeClose.
  ///
  /// In ar, this message translates to:
  /// **'تنفيذ الإقفال'**
  String get executeClose;

  /// No description provided for @interestWillBeAdded.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إضافة فوائد على {count} عميل'**
  String interestWillBeAdded(int count);

  /// No description provided for @totalInterestsLabel.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الفوائد: {amount} ر.س'**
  String totalInterestsLabel(String amount);

  /// No description provided for @monthCloseSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إقفال الشهر لـ {count} عميل'**
  String monthCloseSuccess(int count);

  /// No description provided for @readAll.
  ///
  /// In ar, this message translates to:
  /// **'قراءة الكل'**
  String get readAll;

  /// No description provided for @averageExpense.
  ///
  /// In ar, this message translates to:
  /// **'متوسط المصروف'**
  String get averageExpense;

  /// No description provided for @expensesList.
  ///
  /// In ar, this message translates to:
  /// **'قائمة المصروفات'**
  String get expensesList;

  /// No description provided for @electricity.
  ///
  /// In ar, this message translates to:
  /// **'كهرباء'**
  String get electricity;

  /// No description provided for @maintenance.
  ///
  /// In ar, this message translates to:
  /// **'صيانة'**
  String get maintenance;

  /// No description provided for @services.
  ///
  /// In ar, this message translates to:
  /// **'خدمات'**
  String get services;

  /// No description provided for @expense.
  ///
  /// In ar, this message translates to:
  /// **'مصروف'**
  String get expense;

  /// No description provided for @filterExpenses.
  ///
  /// In ar, this message translates to:
  /// **'تصفية المصروفات'**
  String get filterExpenses;

  /// No description provided for @openedNotification.
  ///
  /// In ar, this message translates to:
  /// **'مفتوحة'**
  String get openedNotification;

  /// No description provided for @openTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت الفتح'**
  String get openTime;

  /// No description provided for @closeTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت الإغلاق'**
  String get closeTime;

  /// No description provided for @expectedCash.
  ///
  /// In ar, this message translates to:
  /// **'الصندوق المتوقع'**
  String get expectedCash;

  /// No description provided for @closingCash.
  ///
  /// In ar, this message translates to:
  /// **'صندوق الإغلاق'**
  String get closingCash;

  /// No description provided for @printAction.
  ///
  /// In ar, this message translates to:
  /// **'طباعة'**
  String get printAction;

  /// No description provided for @exportAction.
  ///
  /// In ar, this message translates to:
  /// **'تصدير'**
  String get exportAction;

  /// No description provided for @viewReport.
  ///
  /// In ar, this message translates to:
  /// **'عرض التقرير'**
  String get viewReport;

  /// No description provided for @exportingReport.
  ///
  /// In ar, this message translates to:
  /// **'جاري تصدير التقرير...'**
  String get exportingReport;

  /// No description provided for @chartsUnderDev.
  ///
  /// In ar, this message translates to:
  /// **'الرسوم البيانية قيد التطوير...'**
  String get chartsUnderDev;

  /// No description provided for @reportsAnalysis.
  ///
  /// In ar, this message translates to:
  /// **'تحليل الأداء والمبيعات'**
  String get reportsAnalysis;

  /// No description provided for @aiAssociationFrequency.
  ///
  /// In ar, this message translates to:
  /// **'{productA} + {productB}: تكرار {frequency} مرة'**
  String aiAssociationFrequency(
      String productA, String productB, int frequency);

  /// No description provided for @aiBundleActivated.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل حزمة: {name}'**
  String aiBundleActivated(String name);

  /// No description provided for @aiPromotionsGeneratedCount.
  ///
  /// In ar, this message translates to:
  /// **'تم توليد {count} عرض ترويجي بناءً على تحليل بيانات المتجر'**
  String aiPromotionsGeneratedCount(int count);

  /// No description provided for @aiPromotionApplied.
  ///
  /// In ar, this message translates to:
  /// **'تم تطبيق: {title}'**
  String aiPromotionApplied(String title);

  /// No description provided for @aiConfidencePercent.
  ///
  /// In ar, this message translates to:
  /// **'ثقة: {percent}%'**
  String aiConfidencePercent(String percent);

  /// No description provided for @aiAlertsWithCount.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات ({count})'**
  String aiAlertsWithCount(int count);

  /// No description provided for @aiStaffCurrentSuggested.
  ///
  /// In ar, this message translates to:
  /// **'{current} موظف حالياً → {suggested} مقترح'**
  String aiStaffCurrentSuggested(int current, int suggested);

  /// No description provided for @aiMinutesAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {minutes} دقيقة'**
  String aiMinutesAgo(int minutes);

  /// No description provided for @aiHoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {hours} ساعة'**
  String aiHoursAgo(int hours);

  /// No description provided for @aiDaysAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {days} يوم'**
  String aiDaysAgo(int days);

  /// No description provided for @aiDetectedCount.
  ///
  /// In ar, this message translates to:
  /// **'تم الكشف: {count}'**
  String aiDetectedCount(int count);

  /// No description provided for @aiMatchedCount.
  ///
  /// In ar, this message translates to:
  /// **'مطابق: {count}'**
  String aiMatchedCount(int count);

  /// No description provided for @aiAccuracyPercent.
  ///
  /// In ar, this message translates to:
  /// **'دقة: {percent}%'**
  String aiAccuracyPercent(String percent);

  /// No description provided for @aiProductAccepted.
  ///
  /// In ar, this message translates to:
  /// **'تم قبول {name}'**
  String aiProductAccepted(String name);

  /// No description provided for @aiErrorOccurred.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ: {error}'**
  String aiErrorOccurred(String error);

  /// No description provided for @aiErrorWithMessage.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: {error}'**
  String aiErrorWithMessage(String error);

  /// No description provided for @aiBasketAnalysis.
  ///
  /// In ar, this message translates to:
  /// **'تحليل السلة بالذكاء الاصطناعي'**
  String get aiBasketAnalysis;

  /// No description provided for @aiAssociations.
  ///
  /// In ar, this message translates to:
  /// **'الارتباطات'**
  String get aiAssociations;

  /// No description provided for @aiCrossSell.
  ///
  /// In ar, this message translates to:
  /// **'البيع المتقاطع'**
  String get aiCrossSell;

  /// No description provided for @aiAvgBasketSize.
  ///
  /// In ar, this message translates to:
  /// **'متوسط حجم السلة'**
  String get aiAvgBasketSize;

  /// No description provided for @aiProductUnit.
  ///
  /// In ar, this message translates to:
  /// **'منتج'**
  String get aiProductUnit;

  /// No description provided for @aiAvgBasketValue.
  ///
  /// In ar, this message translates to:
  /// **'متوسط قيمة السلة'**
  String get aiAvgBasketValue;

  /// No description provided for @aiSaudiRiyal.
  ///
  /// In ar, this message translates to:
  /// **'ريال سعودي'**
  String get aiSaudiRiyal;

  /// No description provided for @aiStrongestAssociation.
  ///
  /// In ar, this message translates to:
  /// **'أقوى ارتباط'**
  String get aiStrongestAssociation;

  /// No description provided for @aiConversionRate.
  ///
  /// In ar, this message translates to:
  /// **'معدل التحويل'**
  String get aiConversionRate;

  /// No description provided for @aiFromSuggestions.
  ///
  /// In ar, this message translates to:
  /// **'من الاقتراحات'**
  String get aiFromSuggestions;

  /// No description provided for @aiAssistant.
  ///
  /// In ar, this message translates to:
  /// **'المساعد الذكي'**
  String get aiAssistant;

  /// No description provided for @aiAskAboutStore.
  ///
  /// In ar, this message translates to:
  /// **'اسأل أي سؤال عن متجرك'**
  String get aiAskAboutStore;

  /// No description provided for @aiClearChat.
  ///
  /// In ar, this message translates to:
  /// **'مسح المحادثة'**
  String get aiClearChat;

  /// No description provided for @aiAssistantReady.
  ///
  /// In ar, this message translates to:
  /// **'المساعد الذكي جاهز لمساعدتك!'**
  String get aiAssistantReady;

  /// No description provided for @aiAskAboutSalesStock.
  ///
  /// In ar, this message translates to:
  /// **'اسأل عن المبيعات، المخزون، العملاء، أو أي شيء عن متجرك'**
  String get aiAskAboutSalesStock;

  /// No description provided for @aiCompetitorAnalysis.
  ///
  /// In ar, this message translates to:
  /// **'تحليل المنافسين'**
  String get aiCompetitorAnalysis;

  /// No description provided for @aiPriceComparison.
  ///
  /// In ar, this message translates to:
  /// **'مقارنة الأسعار'**
  String get aiPriceComparison;

  /// No description provided for @aiTrackedProducts.
  ///
  /// In ar, this message translates to:
  /// **'منتجات تحت المراقبة'**
  String get aiTrackedProducts;

  /// No description provided for @aiCheaperThanCompetitors.
  ///
  /// In ar, this message translates to:
  /// **'أرخص من المنافسين'**
  String get aiCheaperThanCompetitors;

  /// No description provided for @aiMoreExpensive.
  ///
  /// In ar, this message translates to:
  /// **'أغلى من المنافسين'**
  String get aiMoreExpensive;

  /// No description provided for @aiAvgPriceDiff.
  ///
  /// In ar, this message translates to:
  /// **'متوسط فرق السعر'**
  String get aiAvgPriceDiff;

  /// No description provided for @aiSortByName.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب بالاسم'**
  String get aiSortByName;

  /// No description provided for @aiSortByPriceDiff.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب بفرق السعر'**
  String get aiSortByPriceDiff;

  /// No description provided for @aiSortByOurPrice.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب بسعرنا'**
  String get aiSortByOurPrice;

  /// No description provided for @aiSortByCategory.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب بالتصنيف'**
  String get aiSortByCategory;

  /// No description provided for @aiSortLabel.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب'**
  String get aiSortLabel;

  /// No description provided for @aiPriceIndex.
  ///
  /// In ar, this message translates to:
  /// **'مؤشر السعر'**
  String get aiPriceIndex;

  /// No description provided for @aiQuality.
  ///
  /// In ar, this message translates to:
  /// **'الجودة'**
  String get aiQuality;

  /// No description provided for @aiBranches.
  ///
  /// In ar, this message translates to:
  /// **'الفروع'**
  String get aiBranches;

  /// No description provided for @aiMarkAllRead.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل كمقروء'**
  String get aiMarkAllRead;

  /// No description provided for @aiNoAlertsCurrently.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تنبيهات حالياً'**
  String get aiNoAlertsCurrently;

  /// No description provided for @aiFraudDetection.
  ///
  /// In ar, this message translates to:
  /// **'كشف الاحتيال بالذكاء الاصطناعي'**
  String get aiFraudDetection;

  /// No description provided for @aiTotalAlerts.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي التنبيهات'**
  String get aiTotalAlerts;

  /// No description provided for @aiCriticalAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات حرجة'**
  String get aiCriticalAlerts;

  /// No description provided for @aiNeedsReview.
  ///
  /// In ar, this message translates to:
  /// **'بحاجة مراجعة'**
  String get aiNeedsReview;

  /// No description provided for @aiRiskLevel.
  ///
  /// In ar, this message translates to:
  /// **'مستوى المخاطر'**
  String get aiRiskLevel;

  /// No description provided for @aiBehaviorScores.
  ///
  /// In ar, this message translates to:
  /// **'درجات السلوك'**
  String get aiBehaviorScores;

  /// No description provided for @aiRiskMeter.
  ///
  /// In ar, this message translates to:
  /// **'مقياس المخاطر'**
  String get aiRiskMeter;

  /// No description provided for @aiHighRisk.
  ///
  /// In ar, this message translates to:
  /// **'مخاطر عالية'**
  String get aiHighRisk;

  /// No description provided for @aiLowRisk.
  ///
  /// In ar, this message translates to:
  /// **'مخاطر منخفضة'**
  String get aiLowRisk;

  /// No description provided for @aiPatternRefund.
  ///
  /// In ar, this message translates to:
  /// **'استرجاع'**
  String get aiPatternRefund;

  /// No description provided for @aiPatternAfterHours.
  ///
  /// In ar, this message translates to:
  /// **'بعد الدوام'**
  String get aiPatternAfterHours;

  /// No description provided for @aiPatternVoid.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get aiPatternVoid;

  /// No description provided for @aiPatternDiscount.
  ///
  /// In ar, this message translates to:
  /// **'خصم'**
  String get aiPatternDiscount;

  /// No description provided for @aiPatternSplit.
  ///
  /// In ar, this message translates to:
  /// **'تقسيم'**
  String get aiPatternSplit;

  /// No description provided for @aiPatternCashDrawer.
  ///
  /// In ar, this message translates to:
  /// **'درج نقد'**
  String get aiPatternCashDrawer;

  /// No description provided for @aiNoFraudAlerts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تنبيهات'**
  String get aiNoFraudAlerts;

  /// No description provided for @aiSelectAlertToInvestigate.
  ///
  /// In ar, this message translates to:
  /// **'اختر تنبيهاً من القائمة للتحقيق'**
  String get aiSelectAlertToInvestigate;

  /// No description provided for @aiStaffAnalytics.
  ///
  /// In ar, this message translates to:
  /// **'تحليلات الموظفين'**
  String get aiStaffAnalytics;

  /// No description provided for @aiLeaderboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة الترتيب'**
  String get aiLeaderboard;

  /// No description provided for @aiIndividualPerformance.
  ///
  /// In ar, this message translates to:
  /// **'أداء فردي'**
  String get aiIndividualPerformance;

  /// No description provided for @aiAvgPerformance.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الأداء'**
  String get aiAvgPerformance;

  /// No description provided for @aiTotalSalesLabel.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المبيعات'**
  String get aiTotalSalesLabel;

  /// No description provided for @aiTotalTransactions.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي العمليات'**
  String get aiTotalTransactions;

  /// No description provided for @aiAvgVoidRate.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الإلغاء'**
  String get aiAvgVoidRate;

  /// No description provided for @aiTeamGrowth.
  ///
  /// In ar, this message translates to:
  /// **'نمو الفريق'**
  String get aiTeamGrowth;

  /// No description provided for @aiLeaderboardThisWeek.
  ///
  /// In ar, this message translates to:
  /// **'لوحة الترتيب - هذا الأسبوع'**
  String get aiLeaderboardThisWeek;

  /// No description provided for @aiSalesForecasting.
  ///
  /// In ar, this message translates to:
  /// **'توقع المبيعات'**
  String get aiSalesForecasting;

  /// No description provided for @aiSmartForecastSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تحليل ذكي لتوقع المبيعات المستقبلية'**
  String get aiSmartForecastSubtitle;

  /// No description provided for @aiForecastAccuracy.
  ///
  /// In ar, this message translates to:
  /// **'دقة التوقع'**
  String get aiForecastAccuracy;

  /// No description provided for @aiTrendUp.
  ///
  /// In ar, this message translates to:
  /// **'صاعد'**
  String get aiTrendUp;

  /// No description provided for @aiTrendDown.
  ///
  /// In ar, this message translates to:
  /// **'هابط'**
  String get aiTrendDown;

  /// No description provided for @aiTrendStable.
  ///
  /// In ar, this message translates to:
  /// **'مستقر'**
  String get aiTrendStable;

  /// No description provided for @aiNextWeekForecast.
  ///
  /// In ar, this message translates to:
  /// **'توقع الأسبوع القادم'**
  String get aiNextWeekForecast;

  /// No description provided for @aiMonthForecast.
  ///
  /// In ar, this message translates to:
  /// **'توقع الشهر'**
  String get aiMonthForecast;

  /// No description provided for @aiForecastSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص التوقعات'**
  String get aiForecastSummary;

  /// No description provided for @aiSalesTrendingUp.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات في اتجاه صاعد - استمر!'**
  String get aiSalesTrendingUp;

  /// No description provided for @aiSalesDeclining.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات في انخفاض - فعّل العروض'**
  String get aiSalesDeclining;

  /// No description provided for @aiSalesStable.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات مستقرة - حافظ على الأداء'**
  String get aiSalesStable;

  /// No description provided for @aiProductRecognition.
  ///
  /// In ar, this message translates to:
  /// **'التعرف على المنتجات'**
  String get aiProductRecognition;

  /// No description provided for @aiSingleProduct.
  ///
  /// In ar, this message translates to:
  /// **'منتج واحد'**
  String get aiSingleProduct;

  /// No description provided for @aiShelfScan.
  ///
  /// In ar, this message translates to:
  /// **'مسح الرف'**
  String get aiShelfScan;

  /// No description provided for @aiBarcodeOcr.
  ///
  /// In ar, this message translates to:
  /// **'باركود OCR'**
  String get aiBarcodeOcr;

  /// No description provided for @aiPriceTag.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة سعر'**
  String get aiPriceTag;

  /// No description provided for @aiCameraArea.
  ///
  /// In ar, this message translates to:
  /// **'منطقة الكاميرا'**
  String get aiCameraArea;

  /// No description provided for @aiPointCameraAtProduct.
  ///
  /// In ar, this message translates to:
  /// **'وجه الكاميرا نحو المنتج أو الرف'**
  String get aiPointCameraAtProduct;

  /// No description provided for @aiStartScan.
  ///
  /// In ar, this message translates to:
  /// **'بدء المسح'**
  String get aiStartScan;

  /// No description provided for @aiAnalyzingImage.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحليل الصورة...'**
  String get aiAnalyzingImage;

  /// No description provided for @aiStartScanToSeeResults.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ المسح لرؤية النتائج'**
  String get aiStartScanToSeeResults;

  /// No description provided for @aiScanResults.
  ///
  /// In ar, this message translates to:
  /// **'نتائج المسح'**
  String get aiScanResults;

  /// No description provided for @aiProductSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ المنتج بنجاح'**
  String get aiProductSaved;

  /// No description provided for @aiPromotionDesigner.
  ///
  /// In ar, this message translates to:
  /// **'مصمم العروض الذكي - AI'**
  String get aiPromotionDesigner;

  /// No description provided for @aiSuggestedPromotions.
  ///
  /// In ar, this message translates to:
  /// **'عروض مقترحة'**
  String get aiSuggestedPromotions;

  /// No description provided for @aiRoiAnalysis.
  ///
  /// In ar, this message translates to:
  /// **'تحليل ROI'**
  String get aiRoiAnalysis;

  /// No description provided for @aiAbTest.
  ///
  /// In ar, this message translates to:
  /// **'اختبار A/B'**
  String get aiAbTest;

  /// No description provided for @aiSmartPromotionDesigner.
  ///
  /// In ar, this message translates to:
  /// **'مصمم العروض الذكي'**
  String get aiSmartPromotionDesigner;

  /// No description provided for @aiProjectedRevenue.
  ///
  /// In ar, this message translates to:
  /// **'الإيرادات المتوقعة'**
  String get aiProjectedRevenue;

  /// No description provided for @aiAiConfidence.
  ///
  /// In ar, this message translates to:
  /// **'ثقة AI'**
  String get aiAiConfidence;

  /// No description provided for @aiSelectPromotionForRoi.
  ///
  /// In ar, this message translates to:
  /// **'اختر عرضاً من التبويب الأول لعرض تحليل ROI'**
  String get aiSelectPromotionForRoi;

  /// No description provided for @aiRevenueLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإيراد'**
  String get aiRevenueLabel;

  /// No description provided for @aiCostLabel.
  ///
  /// In ar, this message translates to:
  /// **'التكلفة'**
  String get aiCostLabel;

  /// No description provided for @aiDiscountLabel.
  ///
  /// In ar, this message translates to:
  /// **'الخصم'**
  String get aiDiscountLabel;

  /// No description provided for @aiAbTestDescription.
  ///
  /// In ar, this message translates to:
  /// **'اختبار A/B يقسم عملاءك لمجموعتين ويعرض كل مجموعة عرضاً مختلفاً لتحديد الأفضل أداءً.'**
  String get aiAbTestDescription;

  /// No description provided for @aiAbTestLaunched.
  ///
  /// In ar, this message translates to:
  /// **'تم إطلاق اختبار A/B بنجاح!'**
  String get aiAbTestLaunched;

  /// No description provided for @aiChatWithData.
  ///
  /// In ar, this message translates to:
  /// **'محادثة مع البيانات - AI'**
  String get aiChatWithData;

  /// No description provided for @aiChatWithYourData.
  ///
  /// In ar, this message translates to:
  /// **'محادثة مع بياناتك'**
  String get aiChatWithYourData;

  /// No description provided for @aiAskAboutDataInArabic.
  ///
  /// In ar, this message translates to:
  /// **'اسأل أي سؤال عن مبيعاتك ومخزونك وعملائك بالعربي'**
  String get aiAskAboutDataInArabic;

  /// No description provided for @aiTrySampleQuestions.
  ///
  /// In ar, this message translates to:
  /// **'جرّب أحد هذه الأسئلة'**
  String get aiTrySampleQuestions;

  /// No description provided for @aiTip.
  ///
  /// In ar, this message translates to:
  /// **'نصيحة'**
  String get aiTip;

  /// No description provided for @aiTipDescription.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك السؤال بالعربي أو الإنجليزي. AI يفهم السياق ويختار أفضل طريقة لعرض النتائج: أرقام، جداول، أو رسوم بيانية.'**
  String get aiTipDescription;

  /// No description provided for @loadingApp.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loadingApp;

  /// No description provided for @initializingSearch.
  ///
  /// In ar, this message translates to:
  /// **'تهيئة البحث...'**
  String get initializingSearch;

  /// No description provided for @loadingData.
  ///
  /// In ar, this message translates to:
  /// **'تحميل البيانات...'**
  String get loadingData;

  /// No description provided for @initializingDemoData.
  ///
  /// In ar, this message translates to:
  /// **'تهيئة البيانات التجريبية...'**
  String get initializingDemoData;

  /// No description provided for @pointOfSale.
  ///
  /// In ar, this message translates to:
  /// **'نقاط البيع'**
  String get pointOfSale;

  /// No description provided for @managerPinSetup.
  ///
  /// In ar, this message translates to:
  /// **'إعداد رمز المشرف'**
  String get managerPinSetup;

  /// No description provided for @confirmPin.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الرمز'**
  String get confirmPin;

  /// No description provided for @createNewPin.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء رمز جديد'**
  String get createNewPin;

  /// No description provided for @reenterPinToConfirm.
  ///
  /// In ar, this message translates to:
  /// **'أعد إدخال الرمز للتأكيد'**
  String get reenterPinToConfirm;

  /// No description provided for @enterFourDigitPin.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز PIN من 4 أرقام'**
  String get enterFourDigitPin;

  /// No description provided for @pinsMismatch.
  ///
  /// In ar, this message translates to:
  /// **'الرمزان غير متطابقين'**
  String get pinsMismatch;

  /// No description provided for @managerPinCreatedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء رمز المشرف بنجاح'**
  String get managerPinCreatedSuccess;

  /// No description provided for @enterManagerPin.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز المشرف'**
  String get enterManagerPin;

  /// No description provided for @operationRequiresApproval.
  ///
  /// In ar, this message translates to:
  /// **'هذه العملية تتطلب موافقة المشرف'**
  String get operationRequiresApproval;

  /// No description provided for @approvalGranted.
  ///
  /// In ar, this message translates to:
  /// **'تمت الموافقة'**
  String get approvalGranted;

  /// No description provided for @accountLockedWaitMinutes.
  ///
  /// In ar, this message translates to:
  /// **'تم قفل الحساب. انتظر {minutes} دقيقة'**
  String accountLockedWaitMinutes(int minutes);

  /// No description provided for @wrongPinAttemptsRemaining.
  ///
  /// In ar, this message translates to:
  /// **'رمز خاطئ. المحاولات المتبقية: {remaining}'**
  String wrongPinAttemptsRemaining(int remaining);

  /// No description provided for @selectYourBranchToContinue.
  ///
  /// In ar, this message translates to:
  /// **'اختر فرعك للمتابعة'**
  String get selectYourBranchToContinue;

  /// No description provided for @branchClosed.
  ///
  /// In ar, this message translates to:
  /// **'مغلق'**
  String get branchClosed;

  /// No description provided for @noResultsFoundSearch.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResultsFoundSearch;

  /// No description provided for @branchSelectedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم اختيار {branchName}'**
  String branchSelectedMessage(String branchName);

  /// No description provided for @shiftIsClosed.
  ///
  /// In ar, this message translates to:
  /// **'الوردية مغلقة'**
  String get shiftIsClosed;

  /// No description provided for @noOpenShiftCurrently.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد وردية مفتوحة حالياً'**
  String get noOpenShiftCurrently;

  /// No description provided for @shiftIsOpen.
  ///
  /// In ar, this message translates to:
  /// **'الوردية مفتوحة'**
  String get shiftIsOpen;

  /// No description provided for @shiftOpenSince.
  ///
  /// In ar, this message translates to:
  /// **'منذ: {time}'**
  String shiftOpenSince(String time);

  /// No description provided for @balanceSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الرصيد'**
  String get balanceSummary;

  /// No description provided for @cashIncoming.
  ///
  /// In ar, this message translates to:
  /// **'النقد الوارد'**
  String get cashIncoming;

  /// No description provided for @cashOutgoing.
  ///
  /// In ar, this message translates to:
  /// **'النقد الصادر'**
  String get cashOutgoing;

  /// No description provided for @expectedBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد المتوقع'**
  String get expectedBalance;

  /// No description provided for @noCashMovementsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حركات نقدية بعد'**
  String get noCashMovementsYet;

  /// No description provided for @noteLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة'**
  String get noteLabel;

  /// No description provided for @depositDone.
  ///
  /// In ar, this message translates to:
  /// **'تم الإيداع'**
  String get depositDone;

  /// No description provided for @withdrawalDone.
  ///
  /// In ar, this message translates to:
  /// **'تم السحب'**
  String get withdrawalDone;

  /// No description provided for @amPeriod.
  ///
  /// In ar, this message translates to:
  /// **'ص'**
  String get amPeriod;

  /// No description provided for @pmPeriod.
  ///
  /// In ar, this message translates to:
  /// **'م'**
  String get pmPeriod;

  /// No description provided for @newPurchaseInvoice.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة شراء جديدة'**
  String get newPurchaseInvoice;

  /// No description provided for @supplierData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات المورد'**
  String get supplierData;

  /// No description provided for @selectSupplierRequired.
  ///
  /// In ar, this message translates to:
  /// **'اختر المورد *'**
  String get selectSupplierRequired;

  /// No description provided for @supplierInvoiceNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم فاتورة المورد'**
  String get supplierInvoiceNumber;

  /// No description provided for @noProductsAddedYet.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم إضافة منتجات بعد'**
  String get noProductsAddedYet;

  /// No description provided for @paymentStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الدفع'**
  String get paymentStatus;

  /// No description provided for @paidStatus.
  ///
  /// In ar, this message translates to:
  /// **'مدفوعة'**
  String get paidStatus;

  /// No description provided for @deferredPayment.
  ///
  /// In ar, this message translates to:
  /// **'آجل'**
  String get deferredPayment;

  /// No description provided for @productNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'اسم المنتج *'**
  String get productNameRequired;

  /// No description provided for @purchasePrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر الشراء'**
  String get purchasePrice;

  /// No description provided for @pleaseSelectSupplier.
  ///
  /// In ar, this message translates to:
  /// **'يرجى اختيار المورد'**
  String get pleaseSelectSupplier;

  /// No description provided for @purchaseInvoiceSavedTotal.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ فاتورة الشراء بإجمالي {total} ر.س'**
  String purchaseInvoiceSavedTotal(String total);

  /// No description provided for @smartReorderAi.
  ///
  /// In ar, this message translates to:
  /// **'الطلب الذكي بالـ AI'**
  String get smartReorderAi;

  /// No description provided for @smartReorderDescription.
  ///
  /// In ar, this message translates to:
  /// **'حدد ميزانيتك ودع الذكاء الاصطناعي يوزع المشتريات بأفضل طريقة'**
  String get smartReorderDescription;

  /// No description provided for @orderSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الطلب'**
  String get orderSettings;

  /// No description provided for @availableBudget.
  ///
  /// In ar, this message translates to:
  /// **'الميزانية المتاحة'**
  String get availableBudget;

  /// No description provided for @enterAvailableAmount.
  ///
  /// In ar, this message translates to:
  /// **'أدخل المبلغ المتاح للشراء'**
  String get enterAvailableAmount;

  /// No description provided for @supplierLabel.
  ///
  /// In ar, this message translates to:
  /// **'المورد: {name}'**
  String supplierLabel(String name);

  /// No description provided for @calculating.
  ///
  /// In ar, this message translates to:
  /// **'جاري الحساب...'**
  String get calculating;

  /// No description provided for @calculateSmartDistribution.
  ///
  /// In ar, this message translates to:
  /// **'حساب التوزيع الذكي'**
  String get calculateSmartDistribution;

  /// No description provided for @setBudgetAndCalculate.
  ///
  /// In ar, this message translates to:
  /// **'حدد الميزانية واضغط حساب'**
  String get setBudgetAndCalculate;

  /// No description provided for @numberOfProducts.
  ///
  /// In ar, this message translates to:
  /// **'عدد المنتجات'**
  String get numberOfProducts;

  /// No description provided for @suggestedProducts.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات المقترحة'**
  String get suggestedProducts;

  /// No description provided for @sendOrder.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الطلب'**
  String get sendOrder;

  /// No description provided for @emailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get emailLabel;

  /// No description provided for @confirmSending.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الإرسال'**
  String get confirmSending;

  /// No description provided for @sendOrderToSupplier.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الطلب إلى {supplier}؟'**
  String sendOrderToSupplier(String supplier);

  /// No description provided for @orderSentSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الطلب للموزع بنجاح'**
  String get orderSentSuccess;

  /// No description provided for @turnoverRate.
  ///
  /// In ar, this message translates to:
  /// **'الدوران: {rate}%'**
  String turnoverRate(String rate);

  /// No description provided for @editSupplier.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المورد'**
  String get editSupplier;

  /// No description provided for @addNewSupplier.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مورد جديد'**
  String get addNewSupplier;

  /// No description provided for @basicInfo.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الأساسية'**
  String get basicInfo;

  /// No description provided for @supplierContactName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المورد / جهة الاتصال *'**
  String get supplierContactName;

  /// No description provided for @companyNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'اسم الشركة *'**
  String get companyNameRequired;

  /// No description provided for @generalCategory.
  ///
  /// In ar, this message translates to:
  /// **'عام'**
  String get generalCategory;

  /// No description provided for @foodMaterials.
  ///
  /// In ar, this message translates to:
  /// **'مواد غذائية'**
  String get foodMaterials;

  /// No description provided for @beverages.
  ///
  /// In ar, this message translates to:
  /// **'مشروبات'**
  String get beverages;

  /// No description provided for @vegetablesFruits.
  ///
  /// In ar, this message translates to:
  /// **'خضروات وفواكه'**
  String get vegetablesFruits;

  /// No description provided for @equipment.
  ///
  /// In ar, this message translates to:
  /// **'معدات'**
  String get equipment;

  /// No description provided for @contactInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات التواصل'**
  String get contactInfo;

  /// No description provided for @primaryPhoneRequired.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف الأساسي *'**
  String get primaryPhoneRequired;

  /// No description provided for @secondaryPhoneOptional.
  ///
  /// In ar, this message translates to:
  /// **'رقم هاتف ثانوي (اختياري)'**
  String get secondaryPhoneOptional;

  /// No description provided for @emailField.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get emailField;

  /// No description provided for @addressField2.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get addressField2;

  /// No description provided for @commercialInfo.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات التجارية'**
  String get commercialInfo;

  /// No description provided for @taxNumberVat.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الضريبي (VAT)'**
  String get taxNumberVat;

  /// No description provided for @commercialRegNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم السجل التجاري (CR)'**
  String get commercialRegNumber;

  /// No description provided for @financialInfo.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات المالية'**
  String get financialInfo;

  /// No description provided for @paymentTerms.
  ///
  /// In ar, this message translates to:
  /// **'شروط الدفع'**
  String get paymentTerms;

  /// No description provided for @payOnDelivery.
  ///
  /// In ar, this message translates to:
  /// **'الدفع عند الاستلام'**
  String get payOnDelivery;

  /// No description provided for @sevenDays.
  ///
  /// In ar, this message translates to:
  /// **'7 أيام'**
  String get sevenDays;

  /// No description provided for @fourteenDays.
  ///
  /// In ar, this message translates to:
  /// **'14 يوم'**
  String get fourteenDays;

  /// No description provided for @thirtyDays.
  ///
  /// In ar, this message translates to:
  /// **'30 يوم'**
  String get thirtyDays;

  /// No description provided for @sixtyDays.
  ///
  /// In ar, this message translates to:
  /// **'60 يوم'**
  String get sixtyDays;

  /// No description provided for @bankName.
  ///
  /// In ar, this message translates to:
  /// **'اسم البنك'**
  String get bankName;

  /// No description provided for @ibanNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الحساب IBAN'**
  String get ibanNumber;

  /// No description provided for @additionalSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات إضافية'**
  String get additionalSettings;

  /// No description provided for @supplierIsActive.
  ///
  /// In ar, this message translates to:
  /// **'المورد نشط'**
  String get supplierIsActive;

  /// No description provided for @notesField.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get notesField;

  /// No description provided for @savingData.
  ///
  /// In ar, this message translates to:
  /// **'جاري الحفظ...'**
  String get savingData;

  /// No description provided for @updateSupplier.
  ///
  /// In ar, this message translates to:
  /// **'تحديث المورد'**
  String get updateSupplier;

  /// No description provided for @addSupplierBtn.
  ///
  /// In ar, this message translates to:
  /// **'إضافة المورد'**
  String get addSupplierBtn;

  /// No description provided for @deleteSupplier.
  ///
  /// In ar, this message translates to:
  /// **'حذف المورد'**
  String get deleteSupplier;

  /// No description provided for @supplierUpdatedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث بيانات المورد'**
  String get supplierUpdatedSuccess;

  /// No description provided for @supplierAddedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة المورد بنجاح'**
  String get supplierAddedSuccess;

  /// No description provided for @supplierDeletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المورد'**
  String get supplierDeletedSuccess;

  /// No description provided for @deleteSupplierConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المورد'**
  String get deleteSupplierConfirmTitle;

  /// No description provided for @deleteSupplierConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا المورد؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get deleteSupplierConfirmMessage;

  /// No description provided for @supplierDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المورد'**
  String get supplierDetailsTitle;

  /// No description provided for @backButton.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get backButton;

  /// No description provided for @editButton.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get editButton;

  /// No description provided for @newPurchaseOrder.
  ///
  /// In ar, this message translates to:
  /// **'طلب شراء جديد'**
  String get newPurchaseOrder;

  /// No description provided for @deleteButton.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get deleteButton;

  /// No description provided for @phoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'الهاتف'**
  String get phoneLabel;

  /// No description provided for @supplierEmailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد'**
  String get supplierEmailLabel;

  /// No description provided for @supplierAddressLabel.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get supplierAddressLabel;

  /// No description provided for @dueToSupplier.
  ///
  /// In ar, this message translates to:
  /// **'مستحق للمورد'**
  String get dueToSupplier;

  /// No description provided for @balanceInOurFavor.
  ///
  /// In ar, this message translates to:
  /// **'رصيد لصالحنا'**
  String get balanceInOurFavor;

  /// No description provided for @paymentBtn.
  ///
  /// In ar, this message translates to:
  /// **'سداد'**
  String get paymentBtn;

  /// No description provided for @totalPurchasesLabel.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المشتريات'**
  String get totalPurchasesLabel;

  /// No description provided for @lastPurchaseDate.
  ///
  /// In ar, this message translates to:
  /// **'آخر شراء'**
  String get lastPurchaseDate;

  /// No description provided for @recentPurchases.
  ///
  /// In ar, this message translates to:
  /// **'آخر المشتريات'**
  String get recentPurchases;

  /// No description provided for @noPurchasesYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مشتريات'**
  String get noPurchasesYet;

  /// No description provided for @pendingLabel.
  ///
  /// In ar, this message translates to:
  /// **'معلق'**
  String get pendingLabel;

  /// No description provided for @deleteSupplierDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المورد'**
  String get deleteSupplierDialogTitle;

  /// No description provided for @deleteSupplierDialogMessage.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف جميع بيانات المورد. هل تريد المتابعة؟'**
  String get deleteSupplierDialogMessage;

  /// No description provided for @unknownUser.
  ///
  /// In ar, this message translates to:
  /// **'غير معروف'**
  String get unknownUser;

  /// No description provided for @employeeRole.
  ///
  /// In ar, this message translates to:
  /// **'موظف'**
  String get employeeRole;

  /// No description provided for @operationCount.
  ///
  /// In ar, this message translates to:
  /// **'عملية'**
  String get operationCount;

  /// No description provided for @dayCount.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get dayCount;

  /// No description provided for @personalInfoSection.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الشخصية'**
  String get personalInfoSection;

  /// No description provided for @emailInfoLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get emailInfoLabel;

  /// No description provided for @phoneInfoLabel.
  ///
  /// In ar, this message translates to:
  /// **'الهاتف'**
  String get phoneInfoLabel;

  /// No description provided for @branchInfoLabel.
  ///
  /// In ar, this message translates to:
  /// **'الفرع'**
  String get branchInfoLabel;

  /// No description provided for @employeeIdLabel.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الوظيفي'**
  String get employeeIdLabel;

  /// No description provided for @notSpecified.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get notSpecified;

  /// No description provided for @mainBranchDefault.
  ///
  /// In ar, this message translates to:
  /// **'الفرع الرئيسي'**
  String get mainBranchDefault;

  /// No description provided for @changePassword.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get changePassword;

  /// No description provided for @activityLogLink.
  ///
  /// In ar, this message translates to:
  /// **'سجل النشاط'**
  String get activityLogLink;

  /// No description provided for @logoutButton.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logoutButton;

  /// No description provided for @systemAdminRole.
  ///
  /// In ar, this message translates to:
  /// **'مدير النظام'**
  String get systemAdminRole;

  /// No description provided for @noBranchesRegistered.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فروع مسجلة'**
  String get noBranchesRegistered;

  /// No description provided for @branchEmailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد'**
  String get branchEmailLabel;

  /// No description provided for @branchCityLabel.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get branchCityLabel;

  /// No description provided for @importSupplierInvoice.
  ///
  /// In ar, this message translates to:
  /// **'استيراد فاتورة المورد'**
  String get importSupplierInvoice;

  /// No description provided for @captureOrSelectPhoto.
  ///
  /// In ar, this message translates to:
  /// **'التقط صورة أو اختر من المعرض\nسيتم استخراج البيانات تلقائياً'**
  String get captureOrSelectPhoto;

  /// No description provided for @captureImage.
  ///
  /// In ar, this message translates to:
  /// **'التقاط صورة'**
  String get captureImage;

  /// No description provided for @galleryPick.
  ///
  /// In ar, this message translates to:
  /// **'المعرض'**
  String get galleryPick;

  /// No description provided for @anotherImage.
  ///
  /// In ar, this message translates to:
  /// **'صورة أخرى'**
  String get anotherImage;

  /// No description provided for @aiProcessingBtn.
  ///
  /// In ar, this message translates to:
  /// **'معالجة AI'**
  String get aiProcessingBtn;

  /// No description provided for @processingInvoice.
  ///
  /// In ar, this message translates to:
  /// **'جاري معالجة الفاتورة...'**
  String get processingInvoice;

  /// No description provided for @extractingDataWithAi.
  ///
  /// In ar, this message translates to:
  /// **'يتم استخراج البيانات بالذكاء الاصطناعي'**
  String get extractingDataWithAi;

  /// No description provided for @dataExtracted.
  ///
  /// In ar, this message translates to:
  /// **'تم استخراج البيانات'**
  String get dataExtracted;

  /// No description provided for @purchaseInvoiceCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء فاتورة الشراء'**
  String get purchaseInvoiceCreated;

  /// No description provided for @reviewInvoice.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة الفاتورة'**
  String get reviewInvoice;

  /// No description provided for @confirmAllItems.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الكل'**
  String get confirmAllItems;

  /// No description provided for @unknownSupplier.
  ///
  /// In ar, this message translates to:
  /// **'مورد غير معروف'**
  String get unknownSupplier;

  /// No description provided for @itemCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الأصناف: {count}'**
  String itemCount(int count);

  /// No description provided for @progressLabel.
  ///
  /// In ar, this message translates to:
  /// **'التقدم: {confirmed} / {total}'**
  String progressLabel(int confirmed, int total);

  /// No description provided for @needsReviewCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} يحتاج مراجعة'**
  String needsReviewCount(int count);

  /// No description provided for @notMatchedStatus.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم المطابقة'**
  String get notMatchedStatus;

  /// No description provided for @matchedStatus.
  ///
  /// In ar, this message translates to:
  /// **'مطابقة'**
  String get matchedStatus;

  /// No description provided for @matchedProductLabel.
  ///
  /// In ar, this message translates to:
  /// **'منتج مطابق'**
  String get matchedProductLabel;

  /// No description provided for @matchedWithName.
  ///
  /// In ar, this message translates to:
  /// **'مطابقة: {name}'**
  String matchedWithName(String name);

  /// No description provided for @searchForProduct.
  ///
  /// In ar, this message translates to:
  /// **'بحث عن منتج...'**
  String get searchForProduct;

  /// No description provided for @createNewProduct.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء منتج جديد'**
  String get createNewProduct;

  /// No description provided for @savingInvoice.
  ///
  /// In ar, this message translates to:
  /// **'جاري الحفظ...'**
  String get savingInvoice;

  /// No description provided for @invoiceSavedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ فاتورة الشراء بنجاح'**
  String get invoiceSavedSuccess;

  /// No description provided for @customerAnalytics.
  ///
  /// In ar, this message translates to:
  /// **'تحليل العملاء'**
  String get customerAnalytics;

  /// No description provided for @weekPeriod.
  ///
  /// In ar, this message translates to:
  /// **'أسبوع'**
  String get weekPeriod;

  /// No description provided for @monthPeriod.
  ///
  /// In ar, this message translates to:
  /// **'شهر'**
  String get monthPeriod;

  /// No description provided for @yearPeriod.
  ///
  /// In ar, this message translates to:
  /// **'سنة'**
  String get yearPeriod;

  /// No description provided for @totalCustomers.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي العملاء'**
  String get totalCustomers;

  /// No description provided for @newCustomers.
  ///
  /// In ar, this message translates to:
  /// **'عملاء جدد'**
  String get newCustomers;

  /// No description provided for @returningCustomers.
  ///
  /// In ar, this message translates to:
  /// **'عملاء متكررون'**
  String get returningCustomers;

  /// No description provided for @averageSpending.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الإنفاق'**
  String get averageSpending;

  /// No description provided for @topCustomers.
  ///
  /// In ar, this message translates to:
  /// **'أفضل العملاء'**
  String get topCustomers;

  /// No description provided for @orderCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} طلب'**
  String orderCount(int count);

  /// No description provided for @customerDistribution.
  ///
  /// In ar, this message translates to:
  /// **'توزيع العملاء'**
  String get customerDistribution;

  /// No description provided for @vipCustomers.
  ///
  /// In ar, this message translates to:
  /// **'VIP (أكثر من 5000 ر.س)'**
  String get vipCustomers;

  /// No description provided for @regularCustomers.
  ///
  /// In ar, this message translates to:
  /// **'منتظمين (1000-5000 ر.س)'**
  String get regularCustomers;

  /// No description provided for @normalCustomers.
  ///
  /// In ar, this message translates to:
  /// **'عاديين (أقل من 1000 ر.س)'**
  String get normalCustomers;

  /// No description provided for @customerActivity.
  ///
  /// In ar, this message translates to:
  /// **'نشاط العملاء'**
  String get customerActivity;

  /// No description provided for @activeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get activeLabel;

  /// No description provided for @dormantLabel.
  ///
  /// In ar, this message translates to:
  /// **'خامل'**
  String get dormantLabel;

  /// No description provided for @inactiveLabel.
  ///
  /// In ar, this message translates to:
  /// **'غير نشط'**
  String get inactiveLabel;

  /// No description provided for @noPrintJobsPending.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام طباعة معلقة'**
  String get noPrintJobsPending;

  /// No description provided for @printerConnected.
  ///
  /// In ar, this message translates to:
  /// **'الطابعة متصلة'**
  String get printerConnected;

  /// No description provided for @totalPrintLabel.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي'**
  String get totalPrintLabel;

  /// No description provided for @waitingPrintLabel.
  ///
  /// In ar, this message translates to:
  /// **'في الانتظار'**
  String get waitingPrintLabel;

  /// No description provided for @failedPrintLabel.
  ///
  /// In ar, this message translates to:
  /// **'فشلت'**
  String get failedPrintLabel;

  /// No description provided for @pendingJobsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مهام معلقة'**
  String pendingJobsCount(int count);

  /// No description provided for @printingInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جاري الطباعة...'**
  String get printingInProgress;

  /// No description provided for @failedRetry.
  ///
  /// In ar, this message translates to:
  /// **'فشل - حاول مرة أخرى'**
  String get failedRetry;

  /// No description provided for @waitingStatus.
  ///
  /// In ar, this message translates to:
  /// **'في الانتظار'**
  String get waitingStatus;

  /// No description provided for @printingOrderId.
  ///
  /// In ar, this message translates to:
  /// **'جاري طباعة {orderId}...'**
  String printingOrderId(String orderId);

  /// No description provided for @allJobsPrinted.
  ///
  /// In ar, this message translates to:
  /// **'تم طباعة جميع المهام'**
  String get allJobsPrinted;

  /// No description provided for @clearPrintQueueTitle.
  ///
  /// In ar, this message translates to:
  /// **'مسح قائمة الطباعة'**
  String get clearPrintQueueTitle;

  /// No description provided for @clearPrintQueueConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد مسح جميع مهام الطباعة المعلقة؟'**
  String get clearPrintQueueConfirm;

  /// No description provided for @clearBtn.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get clearBtn;

  /// No description provided for @gotIt.
  ///
  /// In ar, this message translates to:
  /// **'فهمت'**
  String get gotIt;

  /// No description provided for @print.
  ///
  /// In ar, this message translates to:
  /// **'طباعة'**
  String get print;

  /// No description provided for @display.
  ///
  /// In ar, this message translates to:
  /// **'عرض'**
  String get display;

  /// No description provided for @item.
  ///
  /// In ar, this message translates to:
  /// **'عنصر'**
  String get item;

  /// No description provided for @invoice.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة'**
  String get invoice;

  /// No description provided for @accept.
  ///
  /// In ar, this message translates to:
  /// **'قبول'**
  String get accept;

  /// No description provided for @details.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل'**
  String get details;

  /// No description provided for @newLabel.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get newLabel;

  /// No description provided for @mixed.
  ///
  /// In ar, this message translates to:
  /// **'مختلط'**
  String get mixed;

  /// No description provided for @lowStockLabel.
  ///
  /// In ar, this message translates to:
  /// **'منخفض'**
  String get lowStockLabel;

  /// No description provided for @debtor.
  ///
  /// In ar, this message translates to:
  /// **'مدين'**
  String get debtor;

  /// No description provided for @creditor.
  ///
  /// In ar, this message translates to:
  /// **'دائن'**
  String get creditor;

  /// No description provided for @balanceLabel.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد'**
  String get balanceLabel;

  /// No description provided for @returnLabel.
  ///
  /// In ar, this message translates to:
  /// **'استرجاع'**
  String get returnLabel;

  /// No description provided for @skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get skip;

  /// No description provided for @send.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get send;

  /// No description provided for @cloud.
  ///
  /// In ar, this message translates to:
  /// **'سحابي'**
  String get cloud;

  /// No description provided for @defaultLabel.
  ///
  /// In ar, this message translates to:
  /// **'افتراضي'**
  String get defaultLabel;

  /// No description provided for @closed.
  ///
  /// In ar, this message translates to:
  /// **'مغلق'**
  String get closed;

  /// No description provided for @owes.
  ///
  /// In ar, this message translates to:
  /// **'عليه'**
  String get owes;

  /// No description provided for @due.
  ///
  /// In ar, this message translates to:
  /// **'له'**
  String get due;

  /// No description provided for @balanced.
  ///
  /// In ar, this message translates to:
  /// **'متوازن'**
  String get balanced;

  /// No description provided for @offlineModeTitle.
  ///
  /// In ar, this message translates to:
  /// **'الوضع غير المتصل'**
  String get offlineModeTitle;

  /// No description provided for @offlineModeDescription.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك الاستمرار في استخدام التطبيق:'**
  String get offlineModeDescription;

  /// No description provided for @offlineCanSell.
  ///
  /// In ar, this message translates to:
  /// **'إجراء عمليات البيع'**
  String get offlineCanSell;

  /// No description provided for @offlineCanAddToCart.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منتجات للسلة'**
  String get offlineCanAddToCart;

  /// No description provided for @offlineCanPrint.
  ///
  /// In ar, this message translates to:
  /// **'طباعة الإيصالات'**
  String get offlineCanPrint;

  /// No description provided for @offlineAutoSync.
  ///
  /// In ar, this message translates to:
  /// **'سيتم مزامنة البيانات تلقائياً عند عودة الاتصال.'**
  String get offlineAutoSync;

  /// No description provided for @offlineSavingLocally.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل - يتم حفظ العمليات محلياً'**
  String get offlineSavingLocally;

  /// No description provided for @seconds.
  ///
  /// In ar, this message translates to:
  /// **'ثانية'**
  String get seconds;

  /// No description provided for @errors.
  ///
  /// In ar, this message translates to:
  /// **'أخطاء'**
  String get errors;

  /// No description provided for @syncLabel.
  ///
  /// In ar, this message translates to:
  /// **'مزامنة'**
  String get syncLabel;

  /// No description provided for @slow.
  ///
  /// In ar, this message translates to:
  /// **'بطيئة'**
  String get slow;

  /// No description provided for @myGrocery.
  ///
  /// In ar, this message translates to:
  /// **'بقالتي'**
  String get myGrocery;

  /// No description provided for @cashier.
  ///
  /// In ar, this message translates to:
  /// **'كاشير'**
  String get cashier;

  /// No description provided for @goBack.
  ///
  /// In ar, this message translates to:
  /// **'العودة'**
  String get goBack;

  /// No description provided for @menuLabel.
  ///
  /// In ar, this message translates to:
  /// **'القائمة'**
  String get menuLabel;

  /// No description provided for @gold.
  ///
  /// In ar, this message translates to:
  /// **'ذهبي'**
  String get gold;

  /// No description provided for @silver.
  ///
  /// In ar, this message translates to:
  /// **'فضي'**
  String get silver;

  /// No description provided for @diamond.
  ///
  /// In ar, this message translates to:
  /// **'ماسي'**
  String get diamond;

  /// No description provided for @bronze.
  ///
  /// In ar, this message translates to:
  /// **'برونزي'**
  String get bronze;

  /// No description provided for @saudiArabia.
  ///
  /// In ar, this message translates to:
  /// **'السعودية'**
  String get saudiArabia;

  /// No description provided for @uae.
  ///
  /// In ar, this message translates to:
  /// **'الإمارات'**
  String get uae;

  /// No description provided for @kuwait.
  ///
  /// In ar, this message translates to:
  /// **'الكويت'**
  String get kuwait;

  /// No description provided for @bahrain.
  ///
  /// In ar, this message translates to:
  /// **'البحرين'**
  String get bahrain;

  /// No description provided for @qatar.
  ///
  /// In ar, this message translates to:
  /// **'قطر'**
  String get qatar;

  /// No description provided for @oman.
  ///
  /// In ar, this message translates to:
  /// **'عُمان'**
  String get oman;

  /// No description provided for @control.
  ///
  /// In ar, this message translates to:
  /// **'تحكم'**
  String get control;

  /// No description provided for @strong.
  ///
  /// In ar, this message translates to:
  /// **'قوي'**
  String get strong;

  /// No description provided for @medium.
  ///
  /// In ar, this message translates to:
  /// **'متوسط'**
  String get medium;

  /// No description provided for @weak.
  ///
  /// In ar, this message translates to:
  /// **'ضعيف'**
  String get weak;

  /// No description provided for @good.
  ///
  /// In ar, this message translates to:
  /// **'جيد'**
  String get good;

  /// No description provided for @danger.
  ///
  /// In ar, this message translates to:
  /// **'خطر'**
  String get danger;

  /// No description provided for @currentLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحالي'**
  String get currentLabel;

  /// No description provided for @suggested.
  ///
  /// In ar, this message translates to:
  /// **'المقترح'**
  String get suggested;

  /// No description provided for @actual.
  ///
  /// In ar, this message translates to:
  /// **'الفعلي'**
  String get actual;

  /// No description provided for @forecast.
  ///
  /// In ar, this message translates to:
  /// **'المتوقع'**
  String get forecast;

  /// No description provided for @critical.
  ///
  /// In ar, this message translates to:
  /// **'حرج'**
  String get critical;

  /// No description provided for @high.
  ///
  /// In ar, this message translates to:
  /// **'عالي'**
  String get high;

  /// No description provided for @low.
  ///
  /// In ar, this message translates to:
  /// **'منخفض'**
  String get low;

  /// No description provided for @investigation.
  ///
  /// In ar, this message translates to:
  /// **'التحقيق'**
  String get investigation;

  /// No description provided for @apply.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get apply;

  /// No description provided for @run.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل'**
  String get run;

  /// No description provided for @positive.
  ///
  /// In ar, this message translates to:
  /// **'إيجابي'**
  String get positive;

  /// No description provided for @neutral.
  ///
  /// In ar, this message translates to:
  /// **'محايد'**
  String get neutral;

  /// No description provided for @negative.
  ///
  /// In ar, this message translates to:
  /// **'سلبي'**
  String get negative;

  /// No description provided for @elastic.
  ///
  /// In ar, this message translates to:
  /// **'مرن'**
  String get elastic;

  /// No description provided for @demand.
  ///
  /// In ar, this message translates to:
  /// **'الطلب'**
  String get demand;

  /// No description provided for @quality.
  ///
  /// In ar, this message translates to:
  /// **'الجودة'**
  String get quality;

  /// No description provided for @luxury.
  ///
  /// In ar, this message translates to:
  /// **'فاخر'**
  String get luxury;

  /// No description provided for @economic.
  ///
  /// In ar, this message translates to:
  /// **'اقتصادي'**
  String get economic;

  /// No description provided for @ourStore.
  ///
  /// In ar, this message translates to:
  /// **'متجرنا'**
  String get ourStore;

  /// No description provided for @upcoming.
  ///
  /// In ar, this message translates to:
  /// **'قادم'**
  String get upcoming;

  /// No description provided for @cost.
  ///
  /// In ar, this message translates to:
  /// **'التكلفة'**
  String get cost;

  /// No description provided for @duration.
  ///
  /// In ar, this message translates to:
  /// **'المدة'**
  String get duration;

  /// No description provided for @quiet.
  ///
  /// In ar, this message translates to:
  /// **'هادئ'**
  String get quiet;

  /// No description provided for @busy.
  ///
  /// In ar, this message translates to:
  /// **'مزدحم'**
  String get busy;

  /// No description provided for @outstanding.
  ///
  /// In ar, this message translates to:
  /// **'متميز'**
  String get outstanding;

  /// No description provided for @donate.
  ///
  /// In ar, this message translates to:
  /// **'تبرع'**
  String get donate;

  /// No description provided for @day.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get day;

  /// No description provided for @days.
  ///
  /// In ar, this message translates to:
  /// **'أيام'**
  String get days;

  /// No description provided for @projected.
  ///
  /// In ar, this message translates to:
  /// **'المتوقع'**
  String get projected;

  /// No description provided for @analysis.
  ///
  /// In ar, this message translates to:
  /// **'تحليل'**
  String get analysis;

  /// No description provided for @review.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة'**
  String get review;

  /// No description provided for @productCategory.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get productCategory;

  /// No description provided for @ourPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعرنا'**
  String get ourPrice;

  /// No description provided for @position.
  ///
  /// In ar, this message translates to:
  /// **'الموقف'**
  String get position;

  /// No description provided for @cheapest.
  ///
  /// In ar, this message translates to:
  /// **'الأرخص'**
  String get cheapest;

  /// No description provided for @mostExpensive.
  ///
  /// In ar, this message translates to:
  /// **'الأغلى'**
  String get mostExpensive;

  /// No description provided for @soldOut.
  ///
  /// In ar, this message translates to:
  /// **'نفد'**
  String get soldOut;

  /// No description provided for @noDataAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get noDataAvailable;

  /// No description provided for @noDataFoundMessage.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على أي بيانات'**
  String get noDataFoundMessage;

  /// No description provided for @noSearchResultsFound.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noSearchResultsFound;

  /// No description provided for @noProductsFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على منتجات'**
  String get noProductsFound;

  /// No description provided for @noCustomers.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد عملاء'**
  String get noCustomers;

  /// No description provided for @addCustomersToStart.
  ///
  /// In ar, this message translates to:
  /// **'أضف عملاء جدد للبدء'**
  String get addCustomersToStart;

  /// No description provided for @noOrdersYet.
  ///
  /// In ar, this message translates to:
  /// **'لم تقم بأي طلبات بعد'**
  String get noOrdersYet;

  /// No description provided for @noConnection.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال'**
  String get noConnection;

  /// No description provided for @checkInternet.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من اتصالك بالإنترنت'**
  String get checkInternet;

  /// No description provided for @cartIsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'السلة فارغة'**
  String get cartIsEmpty;

  /// No description provided for @browseProducts.
  ///
  /// In ar, this message translates to:
  /// **'تصفح المنتجات'**
  String get browseProducts;

  /// No description provided for @noResultsFor.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على نتائج لـ \"{query}\"'**
  String noResultsFor(String query);

  /// No description provided for @paidLabel.
  ///
  /// In ar, this message translates to:
  /// **'المدفوع'**
  String get paidLabel;

  /// No description provided for @remainingLabel.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get remainingLabel;

  /// No description provided for @completeLabel.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل ✓'**
  String get completeLabel;

  /// No description provided for @addPayment.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get addPayment;

  /// No description provided for @payments.
  ///
  /// In ar, this message translates to:
  /// **'الدفعات'**
  String get payments;

  /// No description provided for @now.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get now;

  /// No description provided for @ecommerce.
  ///
  /// In ar, this message translates to:
  /// **'المتجر الإلكتروني'**
  String get ecommerce;

  /// No description provided for @ecommerceSection.
  ///
  /// In ar, this message translates to:
  /// **'التجارة الإلكترونية'**
  String get ecommerceSection;

  /// No description provided for @wallet.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get wallet;

  /// No description provided for @subscription.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراك'**
  String get subscription;

  /// No description provided for @complaintsReport.
  ///
  /// In ar, this message translates to:
  /// **'تقرير الشكاوى'**
  String get complaintsReport;

  /// No description provided for @mediaLibrary.
  ///
  /// In ar, this message translates to:
  /// **'مكتبة الوسائط'**
  String get mediaLibrary;

  /// No description provided for @deviceLog.
  ///
  /// In ar, this message translates to:
  /// **'سجل الأجهزة'**
  String get deviceLog;

  /// No description provided for @shippingGateways.
  ///
  /// In ar, this message translates to:
  /// **'بوابات الشحن'**
  String get shippingGateways;

  /// No description provided for @systemSection.
  ///
  /// In ar, this message translates to:
  /// **'النظام'**
  String get systemSection;

  /// No description provided for @averageInvoice.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الفاتورة'**
  String get averageInvoice;

  /// No description provided for @errorPrefix.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: {message}'**
  String errorPrefix(String message, Object error);

  /// No description provided for @vipMember.
  ///
  /// In ar, this message translates to:
  /// **'عضو VIP'**
  String get vipMember;

  /// No description provided for @activeSuppliers.
  ///
  /// In ar, this message translates to:
  /// **'موردين نشطين'**
  String get activeSuppliers;

  /// No description provided for @duePayments.
  ///
  /// In ar, this message translates to:
  /// **'المستحقات'**
  String get duePayments;

  /// No description provided for @productCatalog.
  ///
  /// In ar, this message translates to:
  /// **'كتالوج المنتجات'**
  String get productCatalog;

  /// No description provided for @comingSoonBrowseSuppliers.
  ///
  /// In ar, this message translates to:
  /// **'قريباً - تصفح منتجات الموردين'**
  String get comingSoonBrowseSuppliers;

  /// No description provided for @comingSoonTag.
  ///
  /// In ar, this message translates to:
  /// **'قريباً'**
  String get comingSoonTag;

  /// No description provided for @supplierNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على المورد'**
  String get supplierNotFound;

  /// No description provided for @viewAllPurchases.
  ///
  /// In ar, this message translates to:
  /// **'عرض جميع المشتريات'**
  String get viewAllPurchases;

  /// No description provided for @completedLabel.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get completedLabel;

  /// No description provided for @pendingStatusLabel.
  ///
  /// In ar, this message translates to:
  /// **'معلق'**
  String get pendingStatusLabel;

  /// No description provided for @registerPayment.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل دفعة للمورد'**
  String get registerPayment;

  /// No description provided for @errorLoadingSuppliers.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل الموردين: {error}'**
  String errorLoadingSuppliers(Object error);

  /// No description provided for @cancelLabel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancelLabel;

  /// No description provided for @addLabel.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get addLabel;

  /// No description provided for @saveLabel.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get saveLabel;

  /// No description provided for @purchaseInvoiceSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ فاتورة الشراء - الإجمالي: {total} ر.س'**
  String purchaseInvoiceSaved(Object total);

  /// No description provided for @errorSavingPurchase.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في حفظ المشتريات: {error}'**
  String errorSavingPurchase(Object error);

  /// No description provided for @smartReorderTitle.
  ///
  /// In ar, this message translates to:
  /// **'الطلب الذكي'**
  String get smartReorderTitle;

  /// No description provided for @smartReorderAiTitle.
  ///
  /// In ar, this message translates to:
  /// **'الطلب الذكي بالـ AI'**
  String get smartReorderAiTitle;

  /// No description provided for @budgetDescription.
  ///
  /// In ar, this message translates to:
  /// **'حدد الميزانية وسيقوم النظام بتوزيعها على المنتجات حسب معدل الدوران'**
  String get budgetDescription;

  /// No description provided for @enterValidBudget.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال ميزانية صحيحة'**
  String get enterValidBudget;

  /// No description provided for @confirmSendTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الإرسال'**
  String get confirmSendTitle;

  /// No description provided for @sendOrderToMsg.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الطلب إلى {supplier}؟'**
  String sendOrderToMsg(Object supplier);

  /// No description provided for @orderSentSuccessMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الطلب بنجاح'**
  String get orderSentSuccessMsg;

  /// No description provided for @sendingOrderVia.
  ///
  /// In ar, this message translates to:
  /// **'جاري إرسال الطلب عبر {method}...'**
  String sendingOrderVia(Object method);

  /// No description provided for @stockQuantity.
  ///
  /// In ar, this message translates to:
  /// **'المخزون: {qty}'**
  String stockQuantity(Object qty);

  /// No description provided for @turnoverLabel.
  ///
  /// In ar, this message translates to:
  /// **'الدوران: {rate}%'**
  String turnoverLabel(Object rate);

  /// No description provided for @failedCapture.
  ///
  /// In ar, this message translates to:
  /// **'فشل في التقاط الصورة: {error}'**
  String failedCapture(Object error);

  /// No description provided for @failedPickImage.
  ///
  /// In ar, this message translates to:
  /// **'فشل في اختيار الصورة: {error}'**
  String failedPickImage(Object error);

  /// No description provided for @failedProcessInvoice.
  ///
  /// In ar, this message translates to:
  /// **'فشل في معالجة الفاتورة: {error}'**
  String failedProcessInvoice(Object error);

  /// No description provided for @matchLabel.
  ///
  /// In ar, this message translates to:
  /// **'مطابقة: {name}'**
  String matchLabel(Object name);

  /// No description provided for @suggestedProduct.
  ///
  /// In ar, this message translates to:
  /// **'منتج مقترح {index}'**
  String suggestedProduct(Object index);

  /// No description provided for @barcodeLabel.
  ///
  /// In ar, this message translates to:
  /// **'باركود: 123456789'**
  String get barcodeLabel;

  /// No description provided for @purchaseInvoiceSavedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ فاتورة الشراء بنجاح'**
  String get purchaseInvoiceSavedSuccess;

  /// No description provided for @aiImportedInvoice.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة مستوردة بالذكاء الاصطناعي'**
  String get aiImportedInvoice;

  /// No description provided for @aiInvoiceNote.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة AI: {number}'**
  String aiInvoiceNote(Object number);

  /// No description provided for @supplierCanCreateOrders.
  ///
  /// In ar, this message translates to:
  /// **'يمكن إنشاء طلبات شراء من هذا المورد'**
  String get supplierCanCreateOrders;

  /// No description provided for @notesFieldHint.
  ///
  /// In ar, this message translates to:
  /// **'أي ملاحظات إضافية عن المورد...'**
  String get notesFieldHint;

  /// No description provided for @deleteConfirmCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get deleteConfirmCancel;

  /// No description provided for @deleteConfirmBtn.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get deleteConfirmBtn;

  /// No description provided for @supplierUpdatedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث بيانات المورد'**
  String get supplierUpdatedMsg;

  /// No description provided for @errorOccurredMsg.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ: {error}'**
  String errorOccurredMsg(Object error);

  /// No description provided for @errorDuringDeleteMsg.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء الحذف: {error}'**
  String errorDuringDeleteMsg(Object error);

  /// No description provided for @fortyFiveDays.
  ///
  /// In ar, this message translates to:
  /// **'45 يوم'**
  String get fortyFiveDays;

  /// No description provided for @expenseCategoriesTitle.
  ///
  /// In ar, this message translates to:
  /// **'فئات المصروفات'**
  String get expenseCategoriesTitle;

  /// No description provided for @noCategoriesFound.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فئات مصروفات'**
  String get noCategoriesFound;

  /// No description provided for @monthlyBudget.
  ///
  /// In ar, this message translates to:
  /// **'الميزانية الشهرية'**
  String get monthlyBudget;

  /// No description provided for @spentAmount.
  ///
  /// In ar, this message translates to:
  /// **'المصروف'**
  String get spentAmount;

  /// No description provided for @remainingAmount.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get remainingAmount;

  /// No description provided for @overBudget.
  ///
  /// In ar, this message translates to:
  /// **'تجاوز'**
  String get overBudget;

  /// No description provided for @expenseCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مصروف'**
  String expenseCount(Object count);

  /// No description provided for @spentLabel.
  ///
  /// In ar, this message translates to:
  /// **'المصروف: {amount} ر.س'**
  String spentLabel(Object amount);

  /// No description provided for @remainingLabel2.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي: {amount} ر.س'**
  String remainingLabel2(Object amount);

  /// No description provided for @expensesThisMonth.
  ///
  /// In ar, this message translates to:
  /// **'{count} مصروف هذا الشهر'**
  String expensesThisMonth(Object count);

  /// No description provided for @recentExpenses.
  ///
  /// In ar, this message translates to:
  /// **'آخر المصروفات'**
  String get recentExpenses;

  /// No description provided for @expenseNumber.
  ///
  /// In ar, this message translates to:
  /// **'مصروف #{id}'**
  String expenseNumber(Object id);

  /// No description provided for @budgetLabel.
  ///
  /// In ar, this message translates to:
  /// **'الميزانية'**
  String get budgetLabel;

  /// No description provided for @monthlyBudgetLabel.
  ///
  /// In ar, this message translates to:
  /// **'الميزانية الشهرية'**
  String get monthlyBudgetLabel;

  /// No description provided for @categoryNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: رواتب الموظفين'**
  String get categoryNameHint;

  /// No description provided for @productNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم المنتج'**
  String get productNameLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get quantityLabel;

  /// No description provided for @purchasePriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'سعر الشراء'**
  String get purchasePriceLabel;

  /// No description provided for @saveInvoiceBtn.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الفاتورة'**
  String get saveInvoiceBtn;

  /// No description provided for @ibanLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الحساب IBAN'**
  String get ibanLabel;

  /// No description provided for @supplierActiveLabel.
  ///
  /// In ar, this message translates to:
  /// **'المورد نشط'**
  String get supplierActiveLabel;

  /// No description provided for @notesLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get notesLabel;

  /// No description provided for @deleteSupplierConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا المورد؟ سيتم حذف جميع البيانات المرتبطة به.'**
  String get deleteSupplierConfirm;

  /// No description provided for @supplierDeletedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المورد'**
  String get supplierDeletedMsg;

  /// No description provided for @savingLabel.
  ///
  /// In ar, this message translates to:
  /// **'جاري الحفظ...'**
  String get savingLabel;

  /// No description provided for @supplierDetailTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المورد'**
  String get supplierDetailTitle;

  /// No description provided for @supplierNotFoundMsg.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على المورد'**
  String get supplierNotFoundMsg;

  /// No description provided for @lastPurchaseLabel.
  ///
  /// In ar, this message translates to:
  /// **'آخر عملية شراء'**
  String get lastPurchaseLabel;

  /// No description provided for @recentPurchasesLabel.
  ///
  /// In ar, this message translates to:
  /// **'آخر المشتريات'**
  String get recentPurchasesLabel;

  /// No description provided for @noPurchasesLabel.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مشتريات بعد'**
  String get noPurchasesLabel;

  /// No description provided for @supplierAddedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة المورد'**
  String get supplierAddedMsg;

  /// No description provided for @openingCashLabel.
  ///
  /// In ar, this message translates to:
  /// **'النقدية الافتتاحية'**
  String get openingCashLabel;

  /// No description provided for @importantNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات مهمة'**
  String get importantNotes;

  /// No description provided for @countCashBeforeShift.
  ///
  /// In ar, this message translates to:
  /// **'تأكد من عد النقدية في الصندوق قبل فتح الوردية'**
  String get countCashBeforeShift;

  /// No description provided for @shiftTimeAutoRecorded.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تسجيل وقت فتح الوردية تلقائياً'**
  String get shiftTimeAutoRecorded;

  /// No description provided for @oneShiftAtATime.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن فتح أكثر من وردية في نفس الوقت'**
  String get oneShiftAtATime;

  /// No description provided for @pleaseEnterOpeningCash.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال مبلغ النقدية الافتتاحية (أكبر من صفر)'**
  String get pleaseEnterOpeningCash;

  /// No description provided for @shiftOpenedWithAmount.
  ///
  /// In ar, this message translates to:
  /// **'تم فتح الوردية بمبلغ {amount} {currency}'**
  String shiftOpenedWithAmount(String amount, String currency);

  /// No description provided for @errorOpeningShift.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في فتح الوردية'**
  String get errorOpeningShift;

  /// No description provided for @noOpenShift.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد وردية مفتوحة'**
  String get noOpenShift;

  /// No description provided for @shiftInfoLabel.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الوردية'**
  String get shiftInfoLabel;

  /// No description provided for @salesSummaryLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملخص المبيعات'**
  String get salesSummaryLabel;

  /// No description provided for @cashRefundsLabel.
  ///
  /// In ar, this message translates to:
  /// **'مرتجعات نقدية'**
  String get cashRefundsLabel;

  /// No description provided for @cashDepositLabel.
  ///
  /// In ar, this message translates to:
  /// **'إدخال نقدي'**
  String get cashDepositLabel;

  /// No description provided for @cashWithdrawalLabel.
  ///
  /// In ar, this message translates to:
  /// **'سحب نقدي'**
  String get cashWithdrawalLabel;

  /// No description provided for @expectedInDrawer.
  ///
  /// In ar, this message translates to:
  /// **'المتوقع في الصندوق'**
  String get expectedInDrawer;

  /// No description provided for @actualCashInDrawer.
  ///
  /// In ar, this message translates to:
  /// **'النقدية الفعلية في الصندوق'**
  String get actualCashInDrawer;

  /// No description provided for @drawerMatched.
  ///
  /// In ar, this message translates to:
  /// **'متطابق'**
  String get drawerMatched;

  /// No description provided for @surplusStatus.
  ///
  /// In ar, this message translates to:
  /// **'فائض'**
  String get surplusStatus;

  /// No description provided for @deficitStatus.
  ///
  /// In ar, this message translates to:
  /// **'عجز'**
  String get deficitStatus;

  /// No description provided for @expectedAmountCurrency.
  ///
  /// In ar, this message translates to:
  /// **'المتوقع: {amount} {currency}'**
  String expectedAmountCurrency(String amount, String currency);

  /// No description provided for @actualAmountCurrency.
  ///
  /// In ar, this message translates to:
  /// **'الفعلي: {amount} {currency}'**
  String actualAmountCurrency(String amount, String currency);

  /// No description provided for @drawerMatchedMessage.
  ///
  /// In ar, this message translates to:
  /// **'الصندوق متطابق'**
  String get drawerMatchedMessage;

  /// No description provided for @surplusAmount.
  ///
  /// In ar, this message translates to:
  /// **'فائض: +{amount} {currency}'**
  String surplusAmount(String amount, String currency);

  /// No description provided for @deficitAmount.
  ///
  /// In ar, this message translates to:
  /// **'عجز: {amount} {currency}'**
  String deficitAmount(String amount, String currency);

  /// No description provided for @confirmCloseShift.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إغلاق الوردية؟'**
  String get confirmCloseShift;

  /// No description provided for @errorClosingShift.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في إغلاق الوردية'**
  String get errorClosingShift;

  /// No description provided for @shiftClosedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم إغلاق الوردية بنجاح'**
  String get shiftClosedSuccessfully;

  /// No description provided for @shiftStatsLabel.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات الوردية'**
  String get shiftStatsLabel;

  /// No description provided for @shiftDurationLabel.
  ///
  /// In ar, this message translates to:
  /// **'مدة الوردية'**
  String get shiftDurationLabel;

  /// No description provided for @invoiceCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'عدد الفواتير'**
  String get invoiceCountLabel;

  /// No description provided for @invoiceUnit.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة'**
  String get invoiceUnit;

  /// No description provided for @cardSalesLabel.
  ///
  /// In ar, this message translates to:
  /// **'مبيعات بطاقة'**
  String get cardSalesLabel;

  /// No description provided for @cashSalesLabel.
  ///
  /// In ar, this message translates to:
  /// **'مبيعات نقدية'**
  String get cashSalesLabel;

  /// No description provided for @refundsLabel.
  ///
  /// In ar, this message translates to:
  /// **'المرتجعات'**
  String get refundsLabel;

  /// No description provided for @expectedInDrawerLabel.
  ///
  /// In ar, this message translates to:
  /// **'المتوقع في الصندوق'**
  String get expectedInDrawerLabel;

  /// No description provided for @actualInDrawerLabel.
  ///
  /// In ar, this message translates to:
  /// **'الفعلي في الصندوق'**
  String get actualInDrawerLabel;

  /// No description provided for @differenceLabel.
  ///
  /// In ar, this message translates to:
  /// **'الفرق'**
  String get differenceLabel;

  /// No description provided for @printingReport.
  ///
  /// In ar, this message translates to:
  /// **'جاري طباعة التقرير...'**
  String get printingReport;

  /// No description provided for @sharingInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جاري المشاركة...'**
  String get sharingInProgress;

  /// No description provided for @openNewShift.
  ///
  /// In ar, this message translates to:
  /// **'فتح وردية جديدة'**
  String get openNewShift;

  /// No description provided for @hoursAndMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{hours} ساعات {minutes} دقيقة'**
  String hoursAndMinutes(int hours, int minutes);

  /// No description provided for @hoursOnly.
  ///
  /// In ar, this message translates to:
  /// **'{hours} ساعات'**
  String hoursOnly(int hours);

  /// No description provided for @minutesOnly.
  ///
  /// In ar, this message translates to:
  /// **'{minutes} دقيقة'**
  String minutesOnly(int minutes);

  /// No description provided for @rejectedNotApproved.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض العملية - لم تتم الموافقة'**
  String get rejectedNotApproved;

  /// No description provided for @errorWithDetails.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: {error}'**
  String errorWithDetails(String error);

  /// No description provided for @inventoryManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة ومتابعة المخزون'**
  String get inventoryManagement;

  /// No description provided for @bulkEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل جماعي'**
  String get bulkEdit;

  /// No description provided for @totalProducts.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المنتجات'**
  String get totalProducts;

  /// No description provided for @inventoryValue.
  ///
  /// In ar, this message translates to:
  /// **'قيمة المخزون'**
  String get inventoryValue;

  /// No description provided for @exportInventoryReport.
  ///
  /// In ar, this message translates to:
  /// **'تصدير تقرير المخزون'**
  String get exportInventoryReport;

  /// No description provided for @printOrderList.
  ///
  /// In ar, this message translates to:
  /// **'طباعة قائمة الطلب'**
  String get printOrderList;

  /// No description provided for @inventoryMovementLog.
  ///
  /// In ar, this message translates to:
  /// **'سجل حركة المخزون'**
  String get inventoryMovementLog;

  /// No description provided for @editSelected.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المحدد'**
  String get editSelected;

  /// No description provided for @clearSelection.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء التحديد'**
  String get clearSelection;

  /// No description provided for @noOutOfStockProducts.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد منتجات نفذت'**
  String get noOutOfStockProducts;

  /// No description provided for @allProductsAvailable.
  ///
  /// In ar, this message translates to:
  /// **'جميع المنتجات متوفرة في المخزون'**
  String get allProductsAvailable;

  /// No description provided for @editStock.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المخزون'**
  String get editStock;

  /// No description provided for @newQuantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية الجديدة'**
  String get newQuantity;

  /// No description provided for @receiveGoods.
  ///
  /// In ar, this message translates to:
  /// **'استلام البضاعة'**
  String get receiveGoods;

  /// No description provided for @damaged.
  ///
  /// In ar, this message translates to:
  /// **'تالف'**
  String get damaged;

  /// No description provided for @correction.
  ///
  /// In ar, this message translates to:
  /// **'تصحيح'**
  String get correction;

  /// No description provided for @stockUpdatedTo.
  ///
  /// In ar, this message translates to:
  /// **'تم تعديل مخزون'**
  String get stockUpdatedTo;

  /// No description provided for @featureUnderDevelopment.
  ///
  /// In ar, this message translates to:
  /// **'هذه الميزة قيد التطوير...'**
  String get featureUnderDevelopment;

  /// No description provided for @newest.
  ///
  /// In ar, this message translates to:
  /// **'الأحدث'**
  String get newest;

  /// No description provided for @adjustStock.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المخزون'**
  String get adjustStock;

  /// No description provided for @adjustmentHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل التعديلات'**
  String get adjustmentHistory;

  /// No description provided for @errorLoadingProducts.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء تحميل المنتجات'**
  String get errorLoadingProducts;

  /// No description provided for @selectProduct.
  ///
  /// In ar, this message translates to:
  /// **'اختيار المنتج'**
  String get selectProduct;

  /// No description provided for @subtract.
  ///
  /// In ar, this message translates to:
  /// **'خصم'**
  String get subtract;

  /// No description provided for @setQuantity.
  ///
  /// In ar, this message translates to:
  /// **'تعيين'**
  String get setQuantity;

  /// No description provided for @enterQuantity.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الكمية'**
  String get enterQuantity;

  /// No description provided for @enterValidQuantity.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كمية صحيحة'**
  String get enterValidQuantity;

  /// No description provided for @notesOptional.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات (اختياري)'**
  String get notesOptional;

  /// No description provided for @enterAdditionalNotes.
  ///
  /// In ar, this message translates to:
  /// **'أدخل أي ملاحظات إضافية...'**
  String get enterAdditionalNotes;

  /// No description provided for @adjustmentSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص التعديل'**
  String get adjustmentSummary;

  /// No description provided for @newStock.
  ///
  /// In ar, this message translates to:
  /// **'المخزون الجديد'**
  String get newStock;

  /// No description provided for @warningNegativeStock.
  ///
  /// In ar, this message translates to:
  /// **'تحذير: المخزون سيصبح سالباً!'**
  String get warningNegativeStock;

  /// No description provided for @saving.
  ///
  /// In ar, this message translates to:
  /// **'جاري الحفظ...'**
  String get saving;

  /// No description provided for @storeNotSelected.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تحديد المتجر'**
  String get storeNotSelected;

  /// No description provided for @noInventoryMovements.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حركات مخزون'**
  String get noInventoryMovements;

  /// No description provided for @adjustmentSavedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التعديل بنجاح'**
  String get adjustmentSavedSuccess;

  /// No description provided for @errorSaving.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء الحفظ'**
  String get errorSaving;

  /// No description provided for @enterBarcode.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الباركود'**
  String get enterBarcode;

  /// No description provided for @theft.
  ///
  /// In ar, this message translates to:
  /// **'سرقة'**
  String get theft;

  /// No description provided for @noMatchingProducts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات مطابقة'**
  String get noMatchingProducts;

  /// No description provided for @stockTransfer.
  ///
  /// In ar, this message translates to:
  /// **'تحويل المخزون'**
  String get stockTransfer;

  /// No description provided for @newTransfer.
  ///
  /// In ar, this message translates to:
  /// **'تحويل جديد'**
  String get newTransfer;

  /// No description provided for @fromBranch.
  ///
  /// In ar, this message translates to:
  /// **'من فرع'**
  String get fromBranch;

  /// No description provided for @toBranch.
  ///
  /// In ar, this message translates to:
  /// **'إلى فرع'**
  String get toBranch;

  /// No description provided for @selectSourceBranch.
  ///
  /// In ar, this message translates to:
  /// **'اختر الفرع المصدر'**
  String get selectSourceBranch;

  /// No description provided for @selectTargetBranch.
  ///
  /// In ar, this message translates to:
  /// **'اختر الفرع الهدف'**
  String get selectTargetBranch;

  /// No description provided for @selectProductsForTransfer.
  ///
  /// In ar, this message translates to:
  /// **'اختر منتجات للتحويل'**
  String get selectProductsForTransfer;

  /// No description provided for @creating.
  ///
  /// In ar, this message translates to:
  /// **'جاري الإنشاء...'**
  String get creating;

  /// No description provided for @createTransferRequest.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء طلب التحويل'**
  String get createTransferRequest;

  /// No description provided for @errorLoadingTransfers.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل التحويلات'**
  String get errorLoadingTransfers;

  /// No description provided for @noPreviousTransfers.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تحويلات سابقة'**
  String get noPreviousTransfers;

  /// No description provided for @approved.
  ///
  /// In ar, this message translates to:
  /// **'موافق عليه'**
  String get approved;

  /// No description provided for @inTransit.
  ///
  /// In ar, this message translates to:
  /// **'قيد النقل'**
  String get inTransit;

  /// No description provided for @complete.
  ///
  /// In ar, this message translates to:
  /// **'إكمال'**
  String get complete;

  /// No description provided for @completeTransfer.
  ///
  /// In ar, this message translates to:
  /// **'إكمال التحويل'**
  String get completeTransfer;

  /// No description provided for @completeTransferConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إكمال هذا التحويل؟ سيتم خصم الكميات من الفرع المصدر وإضافتها للفرع الهدف.'**
  String get completeTransferConfirm;

  /// No description provided for @transferCompletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إكمال التحويل وتحديث المخزون'**
  String get transferCompletedSuccess;

  /// No description provided for @errorCompletingTransfer.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في إكمال التحويل'**
  String get errorCompletingTransfer;

  /// No description provided for @transferCreatedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء طلب التحويل بنجاح'**
  String get transferCreatedSuccess;

  /// No description provided for @errorCreatingTransfer.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في إنشاء التحويل'**
  String get errorCreatingTransfer;

  /// No description provided for @stockTake.
  ///
  /// In ar, this message translates to:
  /// **'الجرد'**
  String get stockTake;

  /// No description provided for @startStockTake.
  ///
  /// In ar, this message translates to:
  /// **'بدء الجرد'**
  String get startStockTake;

  /// No description provided for @counted.
  ///
  /// In ar, this message translates to:
  /// **'تم عدها'**
  String get counted;

  /// No description provided for @variances.
  ///
  /// In ar, this message translates to:
  /// **'فروقات'**
  String get variances;

  /// No description provided for @of_.
  ///
  /// In ar, this message translates to:
  /// **'من'**
  String get of_;

  /// No description provided for @system.
  ///
  /// In ar, this message translates to:
  /// **'النظام'**
  String get system;

  /// No description provided for @count.
  ///
  /// In ar, this message translates to:
  /// **'العدد'**
  String get count;

  /// No description provided for @finishStockTake.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء الجرد'**
  String get finishStockTake;

  /// No description provided for @stockTakeDescription.
  ///
  /// In ar, this message translates to:
  /// **'قم بعد منتجات المخزون ومقارنتها بالنظام'**
  String get stockTakeDescription;

  /// No description provided for @noProductsInStock.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات في المخزون'**
  String get noProductsInStock;

  /// No description provided for @noProductsToCount.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات لبدء الجرد'**
  String get noProductsToCount;

  /// No description provided for @errorCreatingStockTake.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في إنشاء عملية الجرد'**
  String get errorCreatingStockTake;

  /// No description provided for @saveStockTakeConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حفظ نتائج الجرد وتحديث المخزون؟'**
  String get saveStockTakeConfirm;

  /// No description provided for @stockTakeSavedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الجرد وتحديث المخزون بنجاح'**
  String get stockTakeSavedSuccess;

  /// No description provided for @errorCompletingStockTake.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في إكمال الجرد'**
  String get errorCompletingStockTake;

  /// No description provided for @stockTakeHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الجرد'**
  String get stockTakeHistory;

  /// No description provided for @errorLoadingHistory.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل السجل'**
  String get errorLoadingHistory;

  /// No description provided for @noStockTakeHistory.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سجل جرد سابق'**
  String get noStockTakeHistory;

  /// No description provided for @inProgress.
  ///
  /// In ar, this message translates to:
  /// **'قيد التنفيذ'**
  String get inProgress;

  /// No description provided for @expiryTracking.
  ///
  /// In ar, this message translates to:
  /// **'تتبع الصلاحية'**
  String get expiryTracking;

  /// No description provided for @errorLoadingExpiryData.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل بيانات الصلاحية'**
  String get errorLoadingExpiryData;

  /// No description provided for @withinMonth.
  ///
  /// In ar, this message translates to:
  /// **'خلال شهر'**
  String get withinMonth;

  /// No description provided for @noProductsExpiringIn7Days.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات تنتهي خلال 7 أيام'**
  String get noProductsExpiringIn7Days;

  /// No description provided for @noProductsExpiringInMonth.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات تنتهي خلال شهر'**
  String get noProductsExpiringInMonth;

  /// No description provided for @noExpiredProducts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات منتهية الصلاحية'**
  String get noExpiredProducts;

  /// No description provided for @batch.
  ///
  /// In ar, this message translates to:
  /// **'باتش'**
  String get batch;

  /// No description provided for @expiredSinceDays.
  ///
  /// In ar, this message translates to:
  /// **'منتهي منذ {days} يوم'**
  String expiredSinceDays(int days);

  /// No description provided for @remove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة'**
  String get remove;

  /// No description provided for @pressToAddExpiryTracking.
  ///
  /// In ar, this message translates to:
  /// **'اضغط + لإضافة تتبع صلاحية جديد'**
  String get pressToAddExpiryTracking;

  /// No description provided for @applyDiscountTo.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق خصم على'**
  String get applyDiscountTo;

  /// No description provided for @confirmRemoval.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الإزالة'**
  String get confirmRemoval;

  /// No description provided for @removeExpiryTrackingFor.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إزالة تتبع صلاحية'**
  String get removeExpiryTrackingFor;

  /// No description provided for @expiryTrackingRemoved.
  ///
  /// In ar, this message translates to:
  /// **'تم إزالة تتبع الصلاحية'**
  String get expiryTrackingRemoved;

  /// No description provided for @errorRemovingExpiryTracking.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في إزالة تتبع الصلاحية'**
  String get errorRemovingExpiryTracking;

  /// No description provided for @addExpiryDate.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تاريخ صلاحية'**
  String get addExpiryDate;

  /// No description provided for @barcodeOrProductName.
  ///
  /// In ar, this message translates to:
  /// **'الباركود أو اسم المنتج'**
  String get barcodeOrProductName;

  /// No description provided for @selectDate.
  ///
  /// In ar, this message translates to:
  /// **'اختر التاريخ'**
  String get selectDate;

  /// No description provided for @batchNumberOptional.
  ///
  /// In ar, this message translates to:
  /// **'رقم الباتش (اختياري)'**
  String get batchNumberOptional;

  /// No description provided for @expiryTrackingAdded.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة تتبع الصلاحية بنجاح'**
  String get expiryTrackingAdded;

  /// No description provided for @errorAddingExpiryTracking.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في إضافة تتبع الصلاحية'**
  String get errorAddingExpiryTracking;

  /// No description provided for @barcodeScanner2.
  ///
  /// In ar, this message translates to:
  /// **'ماسح الباركود'**
  String get barcodeScanner2;

  /// No description provided for @scanning.
  ///
  /// In ar, this message translates to:
  /// **'جاري المسح...'**
  String get scanning;

  /// No description provided for @pressToStart.
  ///
  /// In ar, this message translates to:
  /// **'اضغط للبدء'**
  String get pressToStart;

  /// No description provided for @stop.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف'**
  String get stop;

  /// No description provided for @startScanning.
  ///
  /// In ar, this message translates to:
  /// **'بدء المسح'**
  String get startScanning;

  /// No description provided for @enterBarcodeManually.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الباركود يدوياً'**
  String get enterBarcodeManually;

  /// No description provided for @noScannedProducts.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم مسح أي منتج'**
  String get noScannedProducts;

  /// No description provided for @enterBarcodeToSearch.
  ///
  /// In ar, this message translates to:
  /// **'أدخل باركود للبحث في قاعدة البيانات'**
  String get enterBarcodeToSearch;

  /// No description provided for @useManualInputToSearch.
  ///
  /// In ar, this message translates to:
  /// **'استخدم الإدخال اليدوي للبحث عن المنتجات'**
  String get useManualInputToSearch;

  /// No description provided for @found.
  ///
  /// In ar, this message translates to:
  /// **'تم العثور على'**
  String get found;

  /// No description provided for @productNotFoundForBarcode.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على المنتج'**
  String get productNotFoundForBarcode;

  /// No description provided for @addNewProduct.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منتج جديد'**
  String get addNewProduct;

  /// No description provided for @willOpenAddProductScreen.
  ///
  /// In ar, this message translates to:
  /// **'سيتم فتح شاشة إضافة منتج جديد'**
  String get willOpenAddProductScreen;

  /// No description provided for @scanHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل المسح'**
  String get scanHistory;

  /// No description provided for @addedToCart.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة'**
  String get addedToCart;

  /// No description provided for @barcodePrint.
  ///
  /// In ar, this message translates to:
  /// **'طباعة الباركود'**
  String get barcodePrint;

  /// No description provided for @noProductsWithBarcode.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات بباركود'**
  String get noProductsWithBarcode;

  /// No description provided for @addBarcodeFirst.
  ///
  /// In ar, this message translates to:
  /// **'أضف باركود للمنتجات أولاً'**
  String get addBarcodeFirst;

  /// No description provided for @searchProduct.
  ///
  /// In ar, this message translates to:
  /// **'بحث عن منتج...'**
  String get searchProduct;

  /// No description provided for @totalLabels.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الملصقات'**
  String get totalLabels;

  /// No description provided for @printLabels.
  ///
  /// In ar, this message translates to:
  /// **'طباعة الملصقات'**
  String get printLabels;

  /// No description provided for @printList.
  ///
  /// In ar, this message translates to:
  /// **'قائمة الطباعة'**
  String get printList;

  /// No description provided for @selectProductsToPrint.
  ///
  /// In ar, this message translates to:
  /// **'اختر منتجات للطباعة'**
  String get selectProductsToPrint;

  /// No description provided for @willPrint.
  ///
  /// In ar, this message translates to:
  /// **'سيتم طباعة'**
  String get willPrint;

  /// No description provided for @label.
  ///
  /// In ar, this message translates to:
  /// **'ملصق'**
  String get label;

  /// No description provided for @printing.
  ///
  /// In ar, this message translates to:
  /// **'جاري الطباعة...'**
  String get printing;

  /// No description provided for @messageAddedToQueue.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة الرسالة لطابور الإرسال'**
  String get messageAddedToQueue;

  /// No description provided for @messageSendFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إرسال الرسالة'**
  String get messageSendFailed;

  /// No description provided for @noPhoneForCustomer.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد رقم هاتف للعميل'**
  String get noPhoneForCustomer;

  /// No description provided for @inputContainsDangerousContent.
  ///
  /// In ar, this message translates to:
  /// **'المدخل يحتوي على محتوى غير مسموح'**
  String get inputContainsDangerousContent;

  /// No description provided for @whatsappGreeting.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً {name}\nكيف يمكننا مساعدتك؟'**
  String whatsappGreeting(String name);

  /// No description provided for @segmentVip.
  ///
  /// In ar, this message translates to:
  /// **'VIP'**
  String get segmentVip;

  /// No description provided for @segmentRegular.
  ///
  /// In ar, this message translates to:
  /// **'منتظم'**
  String get segmentRegular;

  /// No description provided for @segmentAtRisk.
  ///
  /// In ar, this message translates to:
  /// **'معرض للخسارة'**
  String get segmentAtRisk;

  /// No description provided for @segmentLost.
  ///
  /// In ar, this message translates to:
  /// **'مفقود'**
  String get segmentLost;

  /// No description provided for @segmentNewCustomer.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get segmentNewCustomer;

  /// No description provided for @customerCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} عميل'**
  String customerCount(int count);

  /// No description provided for @revenueK.
  ///
  /// In ar, this message translates to:
  /// **'{amount}K ر.س'**
  String revenueK(String amount);

  /// No description provided for @tabRecommendations.
  ///
  /// In ar, this message translates to:
  /// **'التوصيات'**
  String get tabRecommendations;

  /// No description provided for @tabRepurchase.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الشراء'**
  String get tabRepurchase;

  /// No description provided for @tabSegments.
  ///
  /// In ar, this message translates to:
  /// **'الشرائح'**
  String get tabSegments;

  /// No description provided for @lastVisitLabel.
  ///
  /// In ar, this message translates to:
  /// **'آخر زيارة: {time}'**
  String lastVisitLabel(String time);

  /// No description provided for @visitCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count} زيارة'**
  String visitCountLabel(int count);

  /// No description provided for @avgSpendLabel.
  ///
  /// In ar, this message translates to:
  /// **'متوسط: {amount} ر.س'**
  String avgSpendLabel(String amount);

  /// No description provided for @totalSpentLabel.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي: {amount}K ر.س'**
  String totalSpentLabel(String amount);

  /// No description provided for @recommendedProducts.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات الموصى بها'**
  String get recommendedProducts;

  /// No description provided for @sendWhatsAppOffer.
  ///
  /// In ar, this message translates to:
  /// **'إرسال عرض واتساب'**
  String get sendWhatsAppOffer;

  /// No description provided for @totalRevenueLabel.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الإيراد'**
  String get totalRevenueLabel;

  /// No description provided for @avgSpendStat.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الإنفاق'**
  String get avgSpendStat;

  /// No description provided for @amountSar.
  ///
  /// In ar, this message translates to:
  /// **'{amount} ر.س'**
  String amountSar(String amount);

  /// No description provided for @specialOfferMissYou.
  ///
  /// In ar, this message translates to:
  /// **'عرض خاص لك! اشتقنا لزيارتك'**
  String get specialOfferMissYou;

  /// No description provided for @friendlyReminderPurchase.
  ///
  /// In ar, this message translates to:
  /// **'تذكير ودي بموعد شراء {product}'**
  String friendlyReminderPurchase(String product);

  /// No description provided for @timeAgoToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get timeAgoToday;

  /// No description provided for @timeAgoYesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get timeAgoYesterday;

  /// No description provided for @timeAgoDays.
  ///
  /// In ar, this message translates to:
  /// **'منذ {days} يوم'**
  String timeAgoDays(int days);

  /// No description provided for @riskAnalysisTab.
  ///
  /// In ar, this message translates to:
  /// **'تحليل المخاطر'**
  String get riskAnalysisTab;

  /// No description provided for @preventiveActionsTab.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات وقائية'**
  String get preventiveActionsTab;

  /// No description provided for @errorOccurredDetail.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ: {error}'**
  String errorOccurredDetail(String error);

  /// No description provided for @returnRateTitle.
  ///
  /// In ar, this message translates to:
  /// **'معدل الإرجاع'**
  String get returnRateTitle;

  /// No description provided for @avgLast6Months.
  ///
  /// In ar, this message translates to:
  /// **'متوسط آخر 6 أشهر'**
  String get avgLast6Months;

  /// No description provided for @amountAtRiskTitle.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ معرض للخطر'**
  String get amountAtRiskTitle;

  /// No description provided for @highRiskOperations.
  ///
  /// In ar, this message translates to:
  /// **'عمليات عالية الخطر'**
  String get highRiskOperations;

  /// No description provided for @needsImmediateAction.
  ///
  /// In ar, this message translates to:
  /// **'تحتاج تدخل فوري'**
  String get needsImmediateAction;

  /// No description provided for @returnTrendTitle.
  ///
  /// In ar, this message translates to:
  /// **'اتجاه المرتجعات'**
  String get returnTrendTitle;

  /// No description provided for @operationsAtRiskCount.
  ///
  /// In ar, this message translates to:
  /// **'العمليات المعرضة للإرجاع ({count})'**
  String operationsAtRiskCount(int count);

  /// No description provided for @riskFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get riskFilterAll;

  /// No description provided for @riskFilterVeryHigh.
  ///
  /// In ar, this message translates to:
  /// **'عالي جداً'**
  String get riskFilterVeryHigh;

  /// No description provided for @riskFilterHigh.
  ///
  /// In ar, this message translates to:
  /// **'عالي'**
  String get riskFilterHigh;

  /// No description provided for @riskFilterMedium.
  ///
  /// In ar, this message translates to:
  /// **'متوسط'**
  String get riskFilterMedium;

  /// No description provided for @riskFilterLow.
  ///
  /// In ar, this message translates to:
  /// **'منخفض'**
  String get riskFilterLow;

  /// No description provided for @totalExpectedSavings.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي التوفير المتوقع'**
  String get totalExpectedSavings;

  /// No description provided for @fromPreventiveActions.
  ///
  /// In ar, this message translates to:
  /// **'من {count} إجراء وقائي'**
  String fromPreventiveActions(int count);

  /// No description provided for @suggestedPreventiveActions.
  ///
  /// In ar, this message translates to:
  /// **'الإجراءات الوقائية المقترحة'**
  String get suggestedPreventiveActions;

  /// No description provided for @applyPreventiveHint.
  ///
  /// In ar, this message translates to:
  /// **'طبّق هذه الإجراءات لتقليل المرتجعات وزيادة رضا العملاء'**
  String get applyPreventiveHint;

  /// No description provided for @actionApplied.
  ///
  /// In ar, this message translates to:
  /// **'تم تطبيق: {action}'**
  String actionApplied(String action);

  /// No description provided for @actionDismissed.
  ///
  /// In ar, this message translates to:
  /// **'تم تجاهل: {action}'**
  String actionDismissed(String action);

  /// No description provided for @veryPositiveSentiment.
  ///
  /// In ar, this message translates to:
  /// **'إيجابي جداً'**
  String get veryPositiveSentiment;

  /// No description provided for @positiveSentiment.
  ///
  /// In ar, this message translates to:
  /// **'إيجابي'**
  String get positiveSentiment;

  /// No description provided for @neutralSentiment.
  ///
  /// In ar, this message translates to:
  /// **'محايد'**
  String get neutralSentiment;

  /// No description provided for @negativeSentiment.
  ///
  /// In ar, this message translates to:
  /// **'سلبي'**
  String get negativeSentiment;

  /// No description provided for @veryNegativeSentiment.
  ///
  /// In ar, this message translates to:
  /// **'سلبي جداً'**
  String get veryNegativeSentiment;

  /// No description provided for @ratingsDistribution.
  ///
  /// In ar, this message translates to:
  /// **'توزيع التقييمات'**
  String get ratingsDistribution;

  /// No description provided for @sentimentTrendTitle.
  ///
  /// In ar, this message translates to:
  /// **'اتجاه المشاعر'**
  String get sentimentTrendTitle;

  /// No description provided for @sentimentIndicator.
  ///
  /// In ar, this message translates to:
  /// **'مؤشر المشاعر'**
  String get sentimentIndicator;

  /// No description provided for @minutesAgoSentiment.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} دقيقة'**
  String minutesAgoSentiment(int count);

  /// No description provided for @hoursAgoSentiment.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} ساعة'**
  String hoursAgoSentiment(int count);

  /// No description provided for @daysAgoSentiment.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} يوم'**
  String daysAgoSentiment(int count);

  /// No description provided for @totalProductsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المنتجات'**
  String get totalProductsTitle;

  /// No description provided for @categoryATitle.
  ///
  /// In ar, this message translates to:
  /// **'فئة أ'**
  String get categoryATitle;

  /// No description provided for @mostImportant.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر أهمية'**
  String get mostImportant;

  /// No description provided for @withinDays.
  ///
  /// In ar, this message translates to:
  /// **'خلال 7 أيام'**
  String get withinDays;

  /// No description provided for @needReorder.
  ///
  /// In ar, this message translates to:
  /// **'بحاجة لطلب'**
  String get needReorder;

  /// No description provided for @estimatedLossSar.
  ///
  /// In ar, this message translates to:
  /// **'{amount} ر.س خسائر متوقعة'**
  String estimatedLossSar(String amount);

  /// No description provided for @tabAbcAnalysis.
  ///
  /// In ar, this message translates to:
  /// **'تحليل ABC'**
  String get tabAbcAnalysis;

  /// No description provided for @tabWastePrediction.
  ///
  /// In ar, this message translates to:
  /// **'توقع الهدر'**
  String get tabWastePrediction;

  /// No description provided for @tabReorder.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الطلب'**
  String get tabReorder;

  /// No description provided for @filterAllLabel.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get filterAllLabel;

  /// No description provided for @categoryALabel.
  ///
  /// In ar, this message translates to:
  /// **'فئة أ'**
  String get categoryALabel;

  /// No description provided for @categoryBLabel.
  ///
  /// In ar, this message translates to:
  /// **'فئة ب'**
  String get categoryBLabel;

  /// No description provided for @categoryCLabel.
  ///
  /// In ar, this message translates to:
  /// **'فئة ج'**
  String get categoryCLabel;

  /// No description provided for @orderUnitsSnack.
  ///
  /// In ar, this message translates to:
  /// **'طلب {qty} وحدة من {name}'**
  String orderUnitsSnack(int qty, String name);

  /// No description provided for @urgencyCritical.
  ///
  /// In ar, this message translates to:
  /// **'حرج'**
  String get urgencyCritical;

  /// No description provided for @urgencyHigh.
  ///
  /// In ar, this message translates to:
  /// **'عالي'**
  String get urgencyHigh;

  /// No description provided for @urgencyMedium.
  ///
  /// In ar, this message translates to:
  /// **'متوسط'**
  String get urgencyMedium;

  /// No description provided for @urgencyLow.
  ///
  /// In ar, this message translates to:
  /// **'منخفض'**
  String get urgencyLow;

  /// No description provided for @currentStockLabel.
  ///
  /// In ar, this message translates to:
  /// **'المخزون الحالي'**
  String get currentStockLabel;

  /// No description provided for @reorderPointLabel.
  ///
  /// In ar, this message translates to:
  /// **'نقطة الطلب'**
  String get reorderPointLabel;

  /// No description provided for @suggestedQtyLabel.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المقترحة'**
  String get suggestedQtyLabel;

  /// No description provided for @daysOfStockLabel.
  ///
  /// In ar, this message translates to:
  /// **'أيام المخزون'**
  String get daysOfStockLabel;

  /// No description provided for @estimatedCostLabel.
  ///
  /// In ar, this message translates to:
  /// **'التكلفة التقديرية: {amount} ر.س'**
  String estimatedCostLabel(String amount);

  /// No description provided for @purchaseOrderCreatedFor.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء طلب شراء: {name}'**
  String purchaseOrderCreatedFor(String name);

  /// No description provided for @orderUnitsButton.
  ///
  /// In ar, this message translates to:
  /// **'طلب {qty} وحدة'**
  String orderUnitsButton(int qty);

  /// No description provided for @actionDiscount.
  ///
  /// In ar, this message translates to:
  /// **'تخفيض'**
  String get actionDiscount;

  /// No description provided for @actionTransfer.
  ///
  /// In ar, this message translates to:
  /// **'نقل'**
  String get actionTransfer;

  /// No description provided for @actionDonate.
  ///
  /// In ar, this message translates to:
  /// **'تبرع'**
  String get actionDonate;

  /// No description provided for @actionOnProduct.
  ///
  /// In ar, this message translates to:
  /// **'إجراء على: {name}'**
  String actionOnProduct(String name);

  /// No description provided for @totalSuggestionsLabel.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الاقتراحات'**
  String get totalSuggestionsLabel;

  /// No description provided for @canIncreaseLabel.
  ///
  /// In ar, this message translates to:
  /// **'يمكن زيادتها'**
  String get canIncreaseLabel;

  /// No description provided for @shouldDecreaseLabel.
  ///
  /// In ar, this message translates to:
  /// **'يُنصح بخفضها'**
  String get shouldDecreaseLabel;

  /// No description provided for @expectedMonthlyImpact.
  ///
  /// In ar, this message translates to:
  /// **'التأثير الشهري المتوقع'**
  String get expectedMonthlyImpact;

  /// No description provided for @noSuggestionsInFilter.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد اقتراحات في هذا الفلتر'**
  String get noSuggestionsInFilter;

  /// No description provided for @selectProductForDetails.
  ///
  /// In ar, this message translates to:
  /// **'اختر منتجاً لعرض التفاصيل'**
  String get selectProductForDetails;

  /// No description provided for @selectProductHint.
  ///
  /// In ar, this message translates to:
  /// **'انقر على أحد المنتجات من القائمة لعرض حاسبة التأثير ومرونة الطلب'**
  String get selectProductHint;

  /// No description provided for @priceApplied.
  ///
  /// In ar, this message translates to:
  /// **'تم تطبيق السعر {price} ر.س على {product}'**
  String priceApplied(String price, String product);

  /// No description provided for @errorOccurredShort.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ: {error}'**
  String errorOccurredShort(String error);

  /// No description provided for @readyTemplates.
  ///
  /// In ar, this message translates to:
  /// **'القوالب الجاهزة'**
  String get readyTemplates;

  /// No description provided for @hideTemplates.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء القوالب'**
  String get hideTemplates;

  /// No description provided for @showTemplates.
  ///
  /// In ar, this message translates to:
  /// **'عرض القوالب'**
  String get showTemplates;

  /// No description provided for @askAboutStore.
  ///
  /// In ar, this message translates to:
  /// **'اسأل أي سؤال عن متجرك'**
  String get askAboutStore;

  /// No description provided for @writeQuestionHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سؤالك بالعربية وسنولد لك التقرير المناسب تلقائياً'**
  String get writeQuestionHint;

  /// No description provided for @quickActionTodaySales.
  ///
  /// In ar, this message translates to:
  /// **'كم مبيعات اليوم؟'**
  String get quickActionTodaySales;

  /// No description provided for @quickActionTop10.
  ///
  /// In ar, this message translates to:
  /// **'أفضل 10 منتجات'**
  String get quickActionTop10;

  /// No description provided for @quickActionMonthlyCompare.
  ///
  /// In ar, this message translates to:
  /// **'مقارنة شهرية'**
  String get quickActionMonthlyCompare;

  /// No description provided for @analyzingData.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحليل البيانات وتوليد التقرير...'**
  String get analyzingData;

  /// No description provided for @profileScreenTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profileScreenTitle;

  /// No description provided for @unknownUserName.
  ///
  /// In ar, this message translates to:
  /// **'غير معروف'**
  String get unknownUserName;

  /// No description provided for @defaultEmployeeRole.
  ///
  /// In ar, this message translates to:
  /// **'موظف'**
  String get defaultEmployeeRole;

  /// No description provided for @transactionUnit.
  ///
  /// In ar, this message translates to:
  /// **'عملية'**
  String get transactionUnit;

  /// No description provided for @dayUnit.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get dayUnit;

  /// No description provided for @emailFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get emailFieldLabel;

  /// No description provided for @phoneFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'الهاتف'**
  String get phoneFieldLabel;

  /// No description provided for @branchFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'الفرع'**
  String get branchFieldLabel;

  /// No description provided for @mainBranchName.
  ///
  /// In ar, this message translates to:
  /// **'الفرع الرئيسي'**
  String get mainBranchName;

  /// No description provided for @employeeNumberLabel.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الوظيفي'**
  String get employeeNumberLabel;

  /// No description provided for @changePasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get changePasswordLabel;

  /// No description provided for @activityLogLabel.
  ///
  /// In ar, this message translates to:
  /// **'سجل النشاط'**
  String get activityLogLabel;

  /// No description provided for @logoutDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logoutDialogTitle;

  /// No description provided for @logoutDialogBody.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تسجيل الخروج من النظام؟'**
  String get logoutDialogBody;

  /// No description provided for @cancelButton.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancelButton;

  /// No description provided for @exitButton.
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get exitButton;

  /// No description provided for @editProfileSnack.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get editProfileSnack;

  /// No description provided for @changePasswordSnack.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get changePasswordSnack;

  /// No description provided for @roleAdmin.
  ///
  /// In ar, this message translates to:
  /// **'مدير النظام'**
  String get roleAdmin;

  /// No description provided for @roleManager.
  ///
  /// In ar, this message translates to:
  /// **'مدير'**
  String get roleManager;

  /// No description provided for @roleCashier.
  ///
  /// In ar, this message translates to:
  /// **'كاشير'**
  String get roleCashier;

  /// No description provided for @roleEmployee.
  ///
  /// In ar, this message translates to:
  /// **'موظف'**
  String get roleEmployee;

  /// No description provided for @onboardingTitle1.
  ///
  /// In ar, this message translates to:
  /// **'نقطة بيع سريعة'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In ar, this message translates to:
  /// **'أتمم عمليات البيع بسرعة وسهولة مع واجهة بسيطة ومريحة'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In ar, this message translates to:
  /// **'العمل بدون إنترنت'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In ar, this message translates to:
  /// **'استمر في العمل حتى بدون اتصال، وستتم المزامنة تلقائياً'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المخزون'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In ar, this message translates to:
  /// **'تتبع مخزونك بدقة مع تنبيهات النقص والصلاحية'**
  String get onboardingDesc3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In ar, this message translates to:
  /// **'تقارير ذكية'**
  String get onboardingTitle4;

  /// No description provided for @onboardingDesc4.
  ///
  /// In ar, this message translates to:
  /// **'احصل على تقارير مفصلة وتحليلات لأداء متجرك'**
  String get onboardingDesc4;

  /// No description provided for @startNow.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get startNow;

  /// No description provided for @favorites.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favorites;

  /// No description provided for @editMode.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get editMode;

  /// No description provided for @doneMode.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get doneMode;

  /// No description provided for @errorLoadingFavorites.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل المفضلة'**
  String get errorLoadingFavorites;

  /// No description provided for @noFavoriteProducts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات مفضلة'**
  String get noFavoriteProducts;

  /// No description provided for @addFavoritesFromProducts.
  ///
  /// In ar, this message translates to:
  /// **'أضف منتجات للمفضلة من شاشة المنتجات'**
  String get addFavoritesFromProducts;

  /// No description provided for @tapProductToAddToCart.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على المنتج لإضافته للسلة'**
  String get tapProductToAddToCart;

  /// No description provided for @addedProductToCart.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة {name} للسلة'**
  String addedProductToCart(String name);

  /// No description provided for @addToCartAction.
  ///
  /// In ar, this message translates to:
  /// **'إضافة للسلة'**
  String get addToCartAction;

  /// No description provided for @removeFromFavorites.
  ///
  /// In ar, this message translates to:
  /// **'إزالة من المفضلة'**
  String get removeFromFavorites;

  /// No description provided for @removedProductFromFavorites.
  ///
  /// In ar, this message translates to:
  /// **'تمت إزالة {name} من المفضلة'**
  String removedProductFromFavorites(String name);

  /// No description provided for @paymentMethodTitle.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get paymentMethodTitle;

  /// No description provided for @backEsc.
  ///
  /// In ar, this message translates to:
  /// **'رجوع (Esc)'**
  String get backEsc;

  /// No description provided for @completePayment.
  ///
  /// In ar, this message translates to:
  /// **'إتمام الدفع'**
  String get completePayment;

  /// No description provided for @enterToConfirm.
  ///
  /// In ar, this message translates to:
  /// **'Enter للتأكيد'**
  String get enterToConfirm;

  /// No description provided for @cashOnlyOffline.
  ///
  /// In ar, this message translates to:
  /// **'نقد فقط في وضع عدم الاتصال'**
  String get cashOnlyOffline;

  /// No description provided for @cardsDisabledInSettings.
  ///
  /// In ar, this message translates to:
  /// **'البطاقات معطلة من الاعدادات'**
  String get cardsDisabledInSettings;

  /// No description provided for @creditPayment.
  ///
  /// In ar, this message translates to:
  /// **'آجل'**
  String get creditPayment;

  /// No description provided for @unavailableOffline.
  ///
  /// In ar, this message translates to:
  /// **'غير متاح بدون اتصال'**
  String get unavailableOffline;

  /// No description provided for @disabledInSettings.
  ///
  /// In ar, this message translates to:
  /// **'معطل من الاعدادات'**
  String get disabledInSettings;

  /// No description provided for @amountReceived.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المستلم'**
  String get amountReceived;

  /// No description provided for @quickAmounts.
  ///
  /// In ar, this message translates to:
  /// **'مبالغ سريعة'**
  String get quickAmounts;

  /// No description provided for @requiredAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المطلوب'**
  String get requiredAmount;

  /// No description provided for @changeLabel.
  ///
  /// In ar, this message translates to:
  /// **'الباقي:'**
  String get changeLabel;

  /// No description provided for @insufficientAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ غير كافي'**
  String get insufficientAmount;

  /// No description provided for @rrnLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم مرجع العملية (RRN)'**
  String get rrnLabel;

  /// No description provided for @enterRrnFromDevice.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم العملية من الجهاز'**
  String get enterRrnFromDevice;

  /// No description provided for @cardPaymentInstructions.
  ///
  /// In ar, this message translates to:
  /// **'اطلب من العميل الدفع عبر جهاز البطاقة، ثم أدخل رقم العملية (RRN) من الإيصال'**
  String get cardPaymentInstructions;

  /// No description provided for @creditSale.
  ///
  /// In ar, this message translates to:
  /// **'البيع الآجل'**
  String get creditSale;

  /// No description provided for @creditSaleWarning.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تسجيل هذا المبلغ كدين على العميل. تأكد من تحديد العميل قبل إتمام العملية.'**
  String get creditSaleWarning;

  /// No description provided for @orderSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الطلب'**
  String get orderSummary;

  /// No description provided for @taxLabel.
  ///
  /// In ar, this message translates to:
  /// **'الضريبة (15%)'**
  String get taxLabel;

  /// No description provided for @discountLabel.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الخصم: {value}%'**
  String discountLabel(String value);

  /// No description provided for @payCash.
  ///
  /// In ar, this message translates to:
  /// **'الدفع نقداً'**
  String get payCash;

  /// No description provided for @payCard.
  ///
  /// In ar, this message translates to:
  /// **'الدفع بالبطاقة'**
  String get payCard;

  /// No description provided for @payCreditSale.
  ///
  /// In ar, this message translates to:
  /// **'البيع الآجل'**
  String get payCreditSale;

  /// No description provided for @confirmPayment.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الدفع'**
  String get confirmPayment;

  /// No description provided for @processingPayment.
  ///
  /// In ar, this message translates to:
  /// **'جاري معالجة الدفع...'**
  String get processingPayment;

  /// No description provided for @pleaseWait.
  ///
  /// In ar, this message translates to:
  /// **'يرجى الانتظار'**
  String get pleaseWait;

  /// No description provided for @paymentSuccessful.
  ///
  /// In ar, this message translates to:
  /// **'تمت العملية بنجاح!'**
  String get paymentSuccessful;

  /// No description provided for @printingReceipt.
  ///
  /// In ar, this message translates to:
  /// **'جاري طباعة الإيصال...'**
  String get printingReceipt;

  /// No description provided for @whatsappReceipt.
  ///
  /// In ar, this message translates to:
  /// **'إيصال واتساب'**
  String get whatsappReceipt;

  /// No description provided for @storeOrUserNotSet.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تحديد المتجر أو المستخدم'**
  String get storeOrUserNotSet;

  /// No description provided for @errorWithMessage.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @receiptTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإيصال'**
  String get receiptTitle;

  /// No description provided for @invoiceNotSpecified.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تحديد رقم الفاتورة'**
  String get invoiceNotSpecified;

  /// No description provided for @pendingSync.
  ///
  /// In ar, this message translates to:
  /// **'في انتظار المزامنة'**
  String get pendingSync;

  /// No description provided for @notSynced.
  ///
  /// In ar, this message translates to:
  /// **'غير مزامنة'**
  String get notSynced;

  /// No description provided for @receiptNumberLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم: {number}'**
  String receiptNumberLabel(String number);

  /// No description provided for @itemColumnHeader.
  ///
  /// In ar, this message translates to:
  /// **'الصنف'**
  String get itemColumnHeader;

  /// No description provided for @totalAmount.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي: {amount} ر.س'**
  String totalAmount(String amount);

  /// No description provided for @paymentMethodField.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get paymentMethodField;

  /// No description provided for @zatcaQrCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز ZATCA الضريبي'**
  String get zatcaQrCode;

  /// No description provided for @whatsappSentLabel.
  ///
  /// In ar, this message translates to:
  /// **'تم الإرسال ✓'**
  String get whatsappSentLabel;

  /// No description provided for @whatsappLabel.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get whatsappLabel;

  /// No description provided for @whatsappReceiptSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الإيصال عبر واتساب ✓'**
  String get whatsappReceiptSent;

  /// No description provided for @whatsappSendFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل الإرسال: {error}'**
  String whatsappSendFailed(String error);

  /// No description provided for @cannotPrintNoInvoice.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن الطباعة - رقم الفاتورة غير متوفر'**
  String get cannotPrintNoInvoice;

  /// No description provided for @invoiceAddedToPrintQueue.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة الفاتورة لقائمة الطباعة'**
  String get invoiceAddedToPrintQueue;

  /// No description provided for @mixedMethod.
  ///
  /// In ar, this message translates to:
  /// **'مختلط'**
  String get mixedMethod;

  /// No description provided for @creditMethod.
  ///
  /// In ar, this message translates to:
  /// **'آجل'**
  String get creditMethod;

  /// No description provided for @walletMethod.
  ///
  /// In ar, this message translates to:
  /// **'محفظة'**
  String get walletMethod;

  /// No description provided for @bankTransferMethod.
  ///
  /// In ar, this message translates to:
  /// **'تحويل بنكي'**
  String get bankTransferMethod;

  /// No description provided for @scanBarcodeHint.
  ///
  /// In ar, this message translates to:
  /// **'امسح الباركود أو أدخله (F1)'**
  String get scanBarcodeHint;

  /// No description provided for @openCamera.
  ///
  /// In ar, this message translates to:
  /// **'فتح الكاميرا'**
  String get openCamera;

  /// No description provided for @searchProductHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث عن منتج (F2)'**
  String get searchProductHint;

  /// No description provided for @hideCart.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء السلة'**
  String get hideCart;

  /// No description provided for @showCart.
  ///
  /// In ar, this message translates to:
  /// **'إظهار السلة'**
  String get showCart;

  /// No description provided for @cartTitle.
  ///
  /// In ar, this message translates to:
  /// **'السلة'**
  String get cartTitle;

  /// No description provided for @clearAction.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get clearAction;

  /// No description provided for @allCategories.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get allCategories;

  /// No description provided for @otherCategory.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get otherCategory;

  /// No description provided for @storeNotSet.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تحديد المتجر'**
  String get storeNotSet;

  /// No description provided for @retryAction.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retryAction;

  /// No description provided for @vatTax15.
  ///
  /// In ar, this message translates to:
  /// **'ضريبة القيمة المضافة (15%)'**
  String get vatTax15;

  /// No description provided for @totalGrand.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get totalGrand;

  /// No description provided for @holdOrder.
  ///
  /// In ar, this message translates to:
  /// **'تعليق'**
  String get holdOrder;

  /// No description provided for @payActionLabel.
  ///
  /// In ar, this message translates to:
  /// **'الدفع'**
  String get payActionLabel;

  /// No description provided for @f12QuickPay.
  ///
  /// In ar, this message translates to:
  /// **'F12 للدفع السريع'**
  String get f12QuickPay;

  /// No description provided for @productNotFoundBarcode.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على منتج بالباركود: {barcode}'**
  String productNotFoundBarcode(String barcode);

  /// No description provided for @clearCartTitle.
  ///
  /// In ar, this message translates to:
  /// **'مسح السلة'**
  String get clearCartTitle;

  /// No description provided for @clearCartMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد مسح جميع المنتجات من السلة؟'**
  String get clearCartMessage;

  /// No description provided for @orderOnHold.
  ///
  /// In ar, this message translates to:
  /// **'تم تعليق الطلب'**
  String get orderOnHold;

  /// No description provided for @deleteItem.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get deleteItem;

  /// No description provided for @itemsCountPrice.
  ///
  /// In ar, this message translates to:
  /// **'{count} عنصر - {price} ر.س'**
  String itemsCountPrice(int count, String price);

  /// No description provided for @taxReportTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقرير الضرائب'**
  String get taxReportTitle;

  /// No description provided for @exportReportAction.
  ///
  /// In ar, this message translates to:
  /// **'تصدير التقرير'**
  String get exportReportAction;

  /// No description provided for @printReportAction.
  ///
  /// In ar, this message translates to:
  /// **'طباعة التقرير'**
  String get printReportAction;

  /// No description provided for @quarterly.
  ///
  /// In ar, this message translates to:
  /// **'ربع سنوي'**
  String get quarterly;

  /// No description provided for @netTaxDue.
  ///
  /// In ar, this message translates to:
  /// **'صافي الضريبة المستحقة'**
  String get netTaxDue;

  /// No description provided for @salesTaxCollected.
  ///
  /// In ar, this message translates to:
  /// **'ضريبة المبيعات'**
  String get salesTaxCollected;

  /// No description provided for @salesTaxSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'المحصلة'**
  String get salesTaxSubtitle;

  /// No description provided for @purchasesTaxPaid.
  ///
  /// In ar, this message translates to:
  /// **'ضريبة المشتريات'**
  String get purchasesTaxPaid;

  /// No description provided for @purchasesTaxSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'المدفوعة'**
  String get purchasesTaxSubtitle;

  /// No description provided for @taxByPaymentMethod.
  ///
  /// In ar, this message translates to:
  /// **'الضريبة حسب طريقة الدفع'**
  String get taxByPaymentMethod;

  /// No description provided for @invoiceCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} فاتورة'**
  String invoiceCount(int count);

  /// No description provided for @taxDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الضريبة'**
  String get taxDetailsTitle;

  /// No description provided for @taxableSales.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات الخاضعة للضريبة'**
  String get taxableSales;

  /// No description provided for @salesTax15.
  ///
  /// In ar, this message translates to:
  /// **'ضريبة المبيعات (15%)'**
  String get salesTax15;

  /// No description provided for @taxablePurchases.
  ///
  /// In ar, this message translates to:
  /// **'المشتريات الخاضعة للضريبة'**
  String get taxablePurchases;

  /// No description provided for @purchasesTax15.
  ///
  /// In ar, this message translates to:
  /// **'ضريبة المشتريات (15%)'**
  String get purchasesTax15;

  /// No description provided for @netTax.
  ///
  /// In ar, this message translates to:
  /// **'صافي الضريبة'**
  String get netTax;

  /// No description provided for @zatcaReminder.
  ///
  /// In ar, this message translates to:
  /// **'تذكير ZATCA'**
  String get zatcaReminder;

  /// No description provided for @zatcaDeadline.
  ///
  /// In ar, this message translates to:
  /// **'الموعد النهائي للإقرار: نهاية الشهر التالي'**
  String get zatcaDeadline;

  /// No description provided for @historyAction.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get historyAction;

  /// No description provided for @sendToAuthority.
  ///
  /// In ar, this message translates to:
  /// **'إرسال للهيئة'**
  String get sendToAuthority;

  /// No description provided for @cashPaymentMethod.
  ///
  /// In ar, this message translates to:
  /// **'نقدي'**
  String get cashPaymentMethod;

  /// No description provided for @cardPaymentMethod.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة'**
  String get cardPaymentMethod;

  /// No description provided for @mixedPaymentMethod.
  ///
  /// In ar, this message translates to:
  /// **'مختلط'**
  String get mixedPaymentMethod;

  /// No description provided for @creditPaymentMethod.
  ///
  /// In ar, this message translates to:
  /// **'آجل'**
  String get creditPaymentMethod;

  /// No description provided for @vatReportTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقرير الضريبة (VAT)'**
  String get vatReportTitle;

  /// No description provided for @selectPeriod.
  ///
  /// In ar, this message translates to:
  /// **'اختر الفترة'**
  String get selectPeriod;

  /// No description provided for @salesVat.
  ///
  /// In ar, this message translates to:
  /// **'ضريبة المبيعات'**
  String get salesVat;

  /// No description provided for @totalSalesIncVat.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المبيعات (شامل الضريبة)'**
  String get totalSalesIncVat;

  /// No description provided for @vatCollected.
  ///
  /// In ar, this message translates to:
  /// **'ضريبة القيمة المضافة المحصلة'**
  String get vatCollected;

  /// No description provided for @purchasesVat.
  ///
  /// In ar, this message translates to:
  /// **'ضريبة المشتريات'**
  String get purchasesVat;

  /// No description provided for @totalPurchasesIncVat.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المشتريات (شامل الضريبة)'**
  String get totalPurchasesIncVat;

  /// No description provided for @vatPaid.
  ///
  /// In ar, this message translates to:
  /// **'ضريبة القيمة المضافة المدفوعة'**
  String get vatPaid;

  /// No description provided for @netVatDue.
  ///
  /// In ar, this message translates to:
  /// **'صافي الضريبة المستحقة'**
  String get netVatDue;

  /// No description provided for @dueToAuthority.
  ///
  /// In ar, this message translates to:
  /// **'مستحق للهيئة'**
  String get dueToAuthority;

  /// No description provided for @dueFromAuthority.
  ///
  /// In ar, this message translates to:
  /// **'مستحق من الهيئة'**
  String get dueFromAuthority;

  /// No description provided for @exportingPdfReport.
  ///
  /// In ar, this message translates to:
  /// **'جاري تصدير التقرير...'**
  String get exportingPdfReport;

  /// No description provided for @debtsReportTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقرير الديون'**
  String get debtsReportTitle;

  /// No description provided for @sortByLastPayment.
  ///
  /// In ar, this message translates to:
  /// **'حسب آخر دفعة'**
  String get sortByLastPayment;

  /// No description provided for @customersCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد العملاء'**
  String get customersCount;

  /// No description provided for @noOutstandingDebts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ديون مستحقة'**
  String get noOutstandingDebts;

  /// No description provided for @lastUpdate.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث: {date}'**
  String lastUpdate(String date);

  /// No description provided for @paymentAmountField.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ الدفعة'**
  String get paymentAmountField;

  /// No description provided for @recordAction.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل'**
  String get recordAction;

  /// No description provided for @paymentRecordedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الدفعة'**
  String get paymentRecordedMsg;

  /// No description provided for @showDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض تفاصيل: {name}'**
  String showDetails(String name);

  /// No description provided for @debtsReportPdf.
  ///
  /// In ar, this message translates to:
  /// **'تقرير الديون'**
  String get debtsReportPdf;

  /// No description provided for @dateFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ: {date}'**
  String dateFieldLabel(String date);

  /// No description provided for @debtsDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الديون:'**
  String get debtsDetails;

  /// No description provided for @customerCol.
  ///
  /// In ar, this message translates to:
  /// **'العميل'**
  String get customerCol;

  /// No description provided for @phoneCol.
  ///
  /// In ar, this message translates to:
  /// **'الهاتف'**
  String get phoneCol;

  /// No description provided for @refundReceiptTitle.
  ///
  /// In ar, this message translates to:
  /// **'إيصال الإرجاع'**
  String get refundReceiptTitle;

  /// No description provided for @noRefundId.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد معرّف إرجاع'**
  String get noRefundId;

  /// No description provided for @refundNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على بيانات الإرجاع'**
  String get refundNotFound;

  /// No description provided for @refundSuccessful.
  ///
  /// In ar, this message translates to:
  /// **'تم الإرجاع بنجاح'**
  String get refundSuccessful;

  /// No description provided for @refundNumberLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الإرجاع: {number}'**
  String refundNumberLabel(String number);

  /// No description provided for @refundReceipt.
  ///
  /// In ar, this message translates to:
  /// **'إيصال إرجاع'**
  String get refundReceipt;

  /// No description provided for @originalInvoiceNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الفاتورة الأصلية'**
  String get originalInvoiceNumber;

  /// No description provided for @refundDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإرجاع'**
  String get refundDate;

  /// No description provided for @refundMethodField.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الاسترداد'**
  String get refundMethodField;

  /// No description provided for @returnedProducts.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات المرتجعة'**
  String get returnedProducts;

  /// No description provided for @totalRefund.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الإرجاع'**
  String get totalRefund;

  /// No description provided for @reasonLabel.
  ///
  /// In ar, this message translates to:
  /// **'السبب'**
  String get reasonLabel;

  /// No description provided for @homeAction.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get homeAction;

  /// No description provided for @printError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الطباعة: {error}'**
  String printError(String error);

  /// No description provided for @damagedProduct.
  ///
  /// In ar, this message translates to:
  /// **'منتج تالف'**
  String get damagedProduct;

  /// No description provided for @wrongOrder.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الطلب'**
  String get wrongOrder;

  /// No description provided for @customerChangedMind.
  ///
  /// In ar, this message translates to:
  /// **'تغيير رأي العميل'**
  String get customerChangedMind;

  /// No description provided for @expiredProduct.
  ///
  /// In ar, this message translates to:
  /// **'منتهي الصلاحية'**
  String get expiredProduct;

  /// No description provided for @unsatisfactoryQuality.
  ///
  /// In ar, this message translates to:
  /// **'جودة غير مرضية'**
  String get unsatisfactoryQuality;

  /// No description provided for @cashRefundMethod.
  ///
  /// In ar, this message translates to:
  /// **'نقدي'**
  String get cashRefundMethod;

  /// No description provided for @cardRefundMethod.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة'**
  String get cardRefundMethod;

  /// No description provided for @walletRefundMethod.
  ///
  /// In ar, this message translates to:
  /// **'محفظة'**
  String get walletRefundMethod;

  /// No description provided for @refundReasonTitle.
  ///
  /// In ar, this message translates to:
  /// **'سبب الإرجاع'**
  String get refundReasonTitle;

  /// No description provided for @noRefundData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات إرجاع. يرجى العودة واختيار المنتجات.'**
  String get noRefundData;

  /// No description provided for @invoiceFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة: {receiptNo}'**
  String invoiceFieldLabel(String receiptNo);

  /// No description provided for @productsCountAmount.
  ///
  /// In ar, this message translates to:
  /// **'{count} منتج - {amount} ر.س'**
  String productsCountAmount(int count, String amount);

  /// No description provided for @selectRefundReason.
  ///
  /// In ar, this message translates to:
  /// **'اختر سبب الإرجاع'**
  String get selectRefundReason;

  /// No description provided for @additionalNotesOptional.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات إضافية (اختياري)'**
  String get additionalNotesOptional;

  /// No description provided for @addNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف أي ملاحظات إضافية...'**
  String get addNotesHint;

  /// No description provided for @processingAction.
  ///
  /// In ar, this message translates to:
  /// **'جاري المعالجة...'**
  String get processingAction;

  /// No description provided for @nextSupervisorApproval.
  ///
  /// In ar, this message translates to:
  /// **'التالي - موافقة المشرف'**
  String get nextSupervisorApproval;

  /// No description provided for @refundCreationError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في إنشاء الإرجاع: {error}'**
  String refundCreationError(String error);

  /// No description provided for @refundRequestTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب إرجاع'**
  String get refundRequestTitle;

  /// No description provided for @invoiceNumberHint.
  ///
  /// In ar, this message translates to:
  /// **'رقم الفاتورة'**
  String get invoiceNumberHint;

  /// No description provided for @searchAction.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get searchAction;

  /// No description provided for @selectProductsForRefund.
  ///
  /// In ar, this message translates to:
  /// **'اختر المنتجات للإرجاع'**
  String get selectProductsForRefund;

  /// No description provided for @selectAll.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل'**
  String get selectAll;

  /// No description provided for @quantityTimesPrice.
  ///
  /// In ar, this message translates to:
  /// **'الكمية: {qty} × {price} ر.س'**
  String quantityTimesPrice(int qty, String price);

  /// No description provided for @productsSelected.
  ///
  /// In ar, this message translates to:
  /// **'{count} منتج محدد'**
  String productsSelected(int count);

  /// No description provided for @refundAmountValue.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ: {amount} ر.س'**
  String refundAmountValue(String amount);

  /// No description provided for @nextAction.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get nextAction;

  /// No description provided for @enterInvoiceToSearch.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم الفاتورة للبحث'**
  String get enterInvoiceToSearch;

  /// No description provided for @invoiceNotFoundMsg.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على الفاتورة'**
  String get invoiceNotFoundMsg;

  /// No description provided for @shippingGatewaysTitle.
  ///
  /// In ar, this message translates to:
  /// **'بوابات الشحن'**
  String get shippingGatewaysTitle;

  /// No description provided for @availableShippingGateways.
  ///
  /// In ar, this message translates to:
  /// **'بوابات الشحن المتاحة'**
  String get availableShippingGateways;

  /// No description provided for @activateShippingGateways.
  ///
  /// In ar, this message translates to:
  /// **'قم بتفعيل وإعداد بوابات الشحن لتوصيل الطلبات'**
  String get activateShippingGateways;

  /// No description provided for @aramexName.
  ///
  /// In ar, this message translates to:
  /// **'أرامكس'**
  String get aramexName;

  /// No description provided for @aramexDesc.
  ///
  /// In ar, this message translates to:
  /// **'شركة شحن عالمية بخدمات متعددة'**
  String get aramexDesc;

  /// No description provided for @smsaDesc.
  ///
  /// In ar, this message translates to:
  /// **'شحن سريع داخل المملكة'**
  String get smsaDesc;

  /// No description provided for @fastloName.
  ///
  /// In ar, this message translates to:
  /// **'فاستلو'**
  String get fastloName;

  /// No description provided for @fastloDesc.
  ///
  /// In ar, this message translates to:
  /// **'توصيل سريع في نفس اليوم'**
  String get fastloDesc;

  /// No description provided for @dhlDesc.
  ///
  /// In ar, this message translates to:
  /// **'شحن دولي سريع وموثوق'**
  String get dhlDesc;

  /// No description provided for @jtDesc.
  ///
  /// In ar, this message translates to:
  /// **'شحن اقتصادي'**
  String get jtDesc;

  /// No description provided for @customDeliveryName.
  ///
  /// In ar, this message translates to:
  /// **'توصيل خاص'**
  String get customDeliveryName;

  /// No description provided for @customDeliveryDesc.
  ///
  /// In ar, this message translates to:
  /// **'إدارة التوصيل بسائقيك الخاصين'**
  String get customDeliveryDesc;

  /// No description provided for @settingsAction.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات'**
  String get settingsAction;

  /// No description provided for @hourlyView.
  ///
  /// In ar, this message translates to:
  /// **'ساعي'**
  String get hourlyView;

  /// No description provided for @dailyView.
  ///
  /// In ar, this message translates to:
  /// **'يومي'**
  String get dailyView;

  /// No description provided for @peakHourLabel.
  ///
  /// In ar, this message translates to:
  /// **'ساعة الذروة'**
  String get peakHourLabel;

  /// No description provided for @transactionsWithCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} معاملة'**
  String transactionsWithCount(int count);

  /// No description provided for @peakDayLabel.
  ///
  /// In ar, this message translates to:
  /// **'يوم الذروة'**
  String get peakDayLabel;

  /// No description provided for @avgPerHour.
  ///
  /// In ar, this message translates to:
  /// **'متوسط/ساعة'**
  String get avgPerHour;

  /// No description provided for @transactionWord.
  ///
  /// In ar, this message translates to:
  /// **'معاملة'**
  String get transactionWord;

  /// No description provided for @transactionsByHour.
  ///
  /// In ar, this message translates to:
  /// **'المعاملات حسب الساعة'**
  String get transactionsByHour;

  /// No description provided for @transactionsByDay.
  ///
  /// In ar, this message translates to:
  /// **'المعاملات حسب اليوم'**
  String get transactionsByDay;

  /// No description provided for @activityHeatmap.
  ///
  /// In ar, this message translates to:
  /// **'خريطة النشاط الحراري'**
  String get activityHeatmap;

  /// No description provided for @lowLabel.
  ///
  /// In ar, this message translates to:
  /// **'منخفض'**
  String get lowLabel;

  /// No description provided for @highLabel.
  ///
  /// In ar, this message translates to:
  /// **'عالي'**
  String get highLabel;

  /// No description provided for @analysisRecommendations.
  ///
  /// In ar, this message translates to:
  /// **'توصيات بناءً على التحليل'**
  String get analysisRecommendations;

  /// No description provided for @staffRecommendation.
  ///
  /// In ar, this message translates to:
  /// **'الموظفين'**
  String get staffRecommendation;

  /// No description provided for @staffRecommendationDesc.
  ///
  /// In ar, this message translates to:
  /// **'زيادة عدد الكاشير في الفترة 12:00-13:00 و 17:00-19:00 (ذروة المبيعات)'**
  String get staffRecommendationDesc;

  /// No description provided for @offersRecommendation.
  ///
  /// In ar, this message translates to:
  /// **'العروض'**
  String get offersRecommendation;

  /// No description provided for @offersRecommendationDesc.
  ///
  /// In ar, this message translates to:
  /// **'تقديم عروض خاصة في الفترة 14:00-16:00 لزيادة المبيعات في الفترة الهادئة'**
  String get offersRecommendationDesc;

  /// No description provided for @inventoryRecommendation.
  ///
  /// In ar, this message translates to:
  /// **'المخزون'**
  String get inventoryRecommendation;

  /// No description provided for @inventoryRecommendationDesc.
  ///
  /// In ar, this message translates to:
  /// **'تجهيز المخزون قبل يومي الخميس والجمعة (أعلى أيام المبيعات)'**
  String get inventoryRecommendationDesc;

  /// No description provided for @shiftsRecommendation.
  ///
  /// In ar, this message translates to:
  /// **'الورديات'**
  String get shiftsRecommendation;

  /// No description provided for @shiftsRecommendationDesc.
  ///
  /// In ar, this message translates to:
  /// **'توزيع الورديات: صباحية 8-15، مسائية 15-22 مع تداخل في الذروة'**
  String get shiftsRecommendationDesc;

  /// No description provided for @topProductsTab.
  ///
  /// In ar, this message translates to:
  /// **'أفضل المنتجات'**
  String get topProductsTab;

  /// No description provided for @byCategoryTab.
  ///
  /// In ar, this message translates to:
  /// **'حسب الفئة'**
  String get byCategoryTab;

  /// No description provided for @performanceAnalysisTab.
  ///
  /// In ar, this message translates to:
  /// **'تحليل الأداء'**
  String get performanceAnalysisTab;

  /// No description provided for @noSalesDataForPeriod.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات مبيعات للفترة المحددة'**
  String get noSalesDataForPeriod;

  /// No description provided for @categoryFilter.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get categoryFilter;

  /// No description provided for @allCategoriesFilter.
  ///
  /// In ar, this message translates to:
  /// **'جميع الفئات'**
  String get allCategoriesFilter;

  /// No description provided for @sortByField.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب حسب'**
  String get sortByField;

  /// No description provided for @revenueSort.
  ///
  /// In ar, this message translates to:
  /// **'الإيرادات'**
  String get revenueSort;

  /// No description provided for @unitsSort.
  ///
  /// In ar, this message translates to:
  /// **'الوحدات'**
  String get unitsSort;

  /// No description provided for @profitSort.
  ///
  /// In ar, this message translates to:
  /// **'الأرباح'**
  String get profitSort;

  /// No description provided for @revenueLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإيرادات'**
  String get revenueLabel;

  /// No description provided for @unitsLabel.
  ///
  /// In ar, this message translates to:
  /// **'الوحدات'**
  String get unitsLabel;

  /// No description provided for @profitLabel.
  ///
  /// In ar, this message translates to:
  /// **'الربح'**
  String get profitLabel;

  /// No description provided for @stockLabel.
  ///
  /// In ar, this message translates to:
  /// **'المخزون'**
  String get stockLabel;

  /// No description provided for @revenueByCategoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'توزيع الإيرادات حسب الفئة'**
  String get revenueByCategoryTitle;

  /// No description provided for @noRevenueForPeriod.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إيرادات في هذه الفترة'**
  String get noRevenueForPeriod;

  /// No description provided for @unclassified.
  ///
  /// In ar, this message translates to:
  /// **'غير مصنف'**
  String get unclassified;

  /// No description provided for @productUnit.
  ///
  /// In ar, this message translates to:
  /// **'منتج'**
  String get productUnit;

  /// No description provided for @unitsSoldUnit.
  ///
  /// In ar, this message translates to:
  /// **'وحدة'**
  String get unitsSoldUnit;

  /// No description provided for @totalRevenueKpi.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الإيرادات'**
  String get totalRevenueKpi;

  /// No description provided for @unitsSoldKpi.
  ///
  /// In ar, this message translates to:
  /// **'الوحدات المباعة'**
  String get unitsSoldKpi;

  /// No description provided for @totalProfitKpi.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الربح'**
  String get totalProfitKpi;

  /// No description provided for @profitMarginKpi.
  ///
  /// In ar, this message translates to:
  /// **'هامش الربح'**
  String get profitMarginKpi;

  /// No description provided for @performanceOverview.
  ///
  /// In ar, this message translates to:
  /// **'نظرة عامة على الأداء'**
  String get performanceOverview;

  /// No description provided for @trendingUpProducts.
  ///
  /// In ar, this message translates to:
  /// **'منتجات متصاعدة'**
  String get trendingUpProducts;

  /// No description provided for @stableProducts.
  ///
  /// In ar, this message translates to:
  /// **'منتجات مستقرة'**
  String get stableProducts;

  /// No description provided for @trendingDownProducts.
  ///
  /// In ar, this message translates to:
  /// **'منتجات متراجعة'**
  String get trendingDownProducts;

  /// No description provided for @noSalesProducts.
  ///
  /// In ar, this message translates to:
  /// **'منتجات بدون مبيعات ({count})'**
  String noSalesProducts(int count);

  /// No description provided for @inStockCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} في المخزون'**
  String inStockCount(int count);

  /// No description provided for @slowMovingLabel.
  ///
  /// In ar, this message translates to:
  /// **'بطيء'**
  String get slowMovingLabel;

  /// No description provided for @needsReorder.
  ///
  /// In ar, this message translates to:
  /// **'تحتاج إعادة طلب ({count})'**
  String needsReorder(int count);

  /// No description provided for @soldUnitsStock.
  ///
  /// In ar, this message translates to:
  /// **'بيع: {sold} وحدة | مخزون: {stock}'**
  String soldUnitsStock(int sold, int stock);

  /// No description provided for @reorderLabel.
  ///
  /// In ar, this message translates to:
  /// **'أعد الطلب'**
  String get reorderLabel;

  /// No description provided for @totalComplaintsLabel.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الشكاوى'**
  String get totalComplaintsLabel;

  /// No description provided for @openComplaints.
  ///
  /// In ar, this message translates to:
  /// **'مفتوحة'**
  String get openComplaints;

  /// No description provided for @closedComplaints.
  ///
  /// In ar, this message translates to:
  /// **'مغلقة'**
  String get closedComplaints;

  /// No description provided for @avgResolutionTime.
  ///
  /// In ar, this message translates to:
  /// **'متوسط وقت الحل'**
  String get avgResolutionTime;

  /// No description provided for @daysUnit.
  ///
  /// In ar, this message translates to:
  /// **'{count} يوم'**
  String daysUnit(String count);

  /// No description provided for @fromDate.
  ///
  /// In ar, this message translates to:
  /// **'من تاريخ'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In ar, this message translates to:
  /// **'إلى تاريخ'**
  String get toDate;

  /// No description provided for @statusFilter.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get statusFilter;

  /// No description provided for @departmentFilter.
  ///
  /// In ar, this message translates to:
  /// **'القسم'**
  String get departmentFilter;

  /// No description provided for @paymentDepartment.
  ///
  /// In ar, this message translates to:
  /// **'الدفع'**
  String get paymentDepartment;

  /// No description provided for @technicalDepartment.
  ///
  /// In ar, this message translates to:
  /// **'تقني'**
  String get technicalDepartment;

  /// No description provided for @otherDepartment.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get otherDepartment;

  /// No description provided for @noComplaintsRecorded.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تسجيل أي شكاوى حتى الآن'**
  String get noComplaintsRecorded;

  /// No description provided for @overviewTab.
  ///
  /// In ar, this message translates to:
  /// **'نظرة عامة'**
  String get overviewTab;

  /// No description provided for @topCustomersTab.
  ///
  /// In ar, this message translates to:
  /// **'أفضل العملاء'**
  String get topCustomersTab;

  /// No description provided for @growthAnalysisTab.
  ///
  /// In ar, this message translates to:
  /// **'تحليل النمو'**
  String get growthAnalysisTab;

  /// No description provided for @loyaltyTab.
  ///
  /// In ar, this message translates to:
  /// **'الولاء'**
  String get loyaltyTab;

  /// No description provided for @totalCustomersLabel.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي العملاء'**
  String get totalCustomersLabel;

  /// No description provided for @activeCustomersLabel.
  ///
  /// In ar, this message translates to:
  /// **'عملاء نشطين'**
  String get activeCustomersLabel;

  /// No description provided for @avgOrderValueLabel.
  ///
  /// In ar, this message translates to:
  /// **'متوسط قيمة الطلب'**
  String get avgOrderValueLabel;

  /// No description provided for @tierDistribution.
  ///
  /// In ar, this message translates to:
  /// **'توزيع العملاء حسب المستوى'**
  String get tierDistribution;

  /// No description provided for @activitySummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص النشاط'**
  String get activitySummary;

  /// No description provided for @totalRevenueFromCustomers.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الإيرادات من العملاء المسجلين'**
  String get totalRevenueFromCustomers;

  /// No description provided for @avgOrderPerCustomer.
  ///
  /// In ar, this message translates to:
  /// **'متوسط قيمة الطلب لكل عميل'**
  String get avgOrderPerCustomer;

  /// No description provided for @activeCustomersLast30.
  ///
  /// In ar, this message translates to:
  /// **'عملاء نشطين (آخر 30 يوم)'**
  String get activeCustomersLast30;

  /// No description provided for @newCustomersLast30.
  ///
  /// In ar, this message translates to:
  /// **'عملاء جدد (آخر 30 يوم)'**
  String get newCustomersLast30;

  /// No description provided for @topCustomersTitle.
  ///
  /// In ar, this message translates to:
  /// **'أفضل {count} عملاء'**
  String topCustomersTitle(int count);

  /// No description provided for @bySpending.
  ///
  /// In ar, this message translates to:
  /// **'حسب الإنفاق'**
  String get bySpending;

  /// No description provided for @byOrders.
  ///
  /// In ar, this message translates to:
  /// **'حسب الطلبات'**
  String get byOrders;

  /// No description provided for @byPoints.
  ///
  /// In ar, this message translates to:
  /// **'حسب النقاط'**
  String get byPoints;

  /// No description provided for @ordersCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} طلب'**
  String ordersCount(int count);

  /// No description provided for @avgOrderStat.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الطلب'**
  String get avgOrderStat;

  /// No description provided for @loyaltyPointsStat.
  ///
  /// In ar, this message translates to:
  /// **'نقاط الولاء'**
  String get loyaltyPointsStat;

  /// No description provided for @lastOrderStat.
  ///
  /// In ar, this message translates to:
  /// **'آخر طلب'**
  String get lastOrderStat;

  /// No description provided for @newCustomerGrowth.
  ///
  /// In ar, this message translates to:
  /// **'نمو العملاء الجدد'**
  String get newCustomerGrowth;

  /// No description provided for @customerRetentionRate.
  ///
  /// In ar, this message translates to:
  /// **'معدل الاحتفاظ بالعملاء'**
  String get customerRetentionRate;

  /// No description provided for @monthlyPeriod.
  ///
  /// In ar, this message translates to:
  /// **'شهري'**
  String get monthlyPeriod;

  /// No description provided for @totalCustomersPeriod.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي العملاء'**
  String get totalCustomersPeriod;

  /// No description provided for @activePeriod.
  ///
  /// In ar, this message translates to:
  /// **'نشطين'**
  String get activePeriod;

  /// No description provided for @activeCustomersInfo.
  ///
  /// In ar, this message translates to:
  /// **'العملاء النشطين: من اشترى خلال آخر 30 يوم'**
  String get activeCustomersInfo;

  /// No description provided for @cohortAnalysis.
  ///
  /// In ar, this message translates to:
  /// **'تحليل Cohort (مجموعات العملاء)'**
  String get cohortAnalysis;

  /// No description provided for @cohortDescription.
  ///
  /// In ar, this message translates to:
  /// **'نسبة العودة للشراء بعد الشراء الأول'**
  String get cohortDescription;

  /// No description provided for @cohortGroup.
  ///
  /// In ar, this message translates to:
  /// **'المجموعة'**
  String get cohortGroup;

  /// No description provided for @month1.
  ///
  /// In ar, this message translates to:
  /// **'شهر 1'**
  String get month1;

  /// No description provided for @month2.
  ///
  /// In ar, this message translates to:
  /// **'شهر 2'**
  String get month2;

  /// No description provided for @month3.
  ///
  /// In ar, this message translates to:
  /// **'شهر 3'**
  String get month3;

  /// No description provided for @loyaltyProgramStats.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات برنامج الولاء'**
  String get loyaltyProgramStats;

  /// No description provided for @totalPointsGranted.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي النقاط الممنوحة'**
  String get totalPointsGranted;

  /// No description provided for @remainingPoints.
  ///
  /// In ar, this message translates to:
  /// **'النقاط المتبقية'**
  String get remainingPoints;

  /// No description provided for @pointsValue.
  ///
  /// In ar, this message translates to:
  /// **'قيمة النقاط'**
  String get pointsValue;

  /// No description provided for @pointsByTier.
  ///
  /// In ar, this message translates to:
  /// **'توزيع النقاط حسب المستوى'**
  String get pointsByTier;

  /// No description provided for @pointsUnit.
  ///
  /// In ar, this message translates to:
  /// **'نقطة'**
  String get pointsUnit;

  /// No description provided for @redemptionPatterns.
  ///
  /// In ar, this message translates to:
  /// **'أنماط استبدال النقاط'**
  String get redemptionPatterns;

  /// No description provided for @purchaseDiscount.
  ///
  /// In ar, this message translates to:
  /// **'خصم على المشتريات'**
  String get purchaseDiscount;

  /// No description provided for @freeProducts.
  ///
  /// In ar, this message translates to:
  /// **'منتجات مجانية'**
  String get freeProducts;

  /// No description provided for @couponsLabel.
  ///
  /// In ar, this message translates to:
  /// **'كوبونات'**
  String get couponsLabel;

  /// No description provided for @diamondTier.
  ///
  /// In ar, this message translates to:
  /// **'ماسي'**
  String get diamondTier;

  /// No description provided for @goldTier.
  ///
  /// In ar, this message translates to:
  /// **'ذهبي'**
  String get goldTier;

  /// No description provided for @silverTier.
  ///
  /// In ar, this message translates to:
  /// **'فضي'**
  String get silverTier;

  /// No description provided for @bronzeTier.
  ///
  /// In ar, this message translates to:
  /// **'برونزي'**
  String get bronzeTier;

  /// No description provided for @todayDate.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get todayDate;

  /// No description provided for @yesterdayDate.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get yesterdayDate;

  /// No description provided for @daysCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count} يوم'**
  String daysCountLabel(int count);

  /// No description provided for @ofTotalLabel.
  ///
  /// In ar, this message translates to:
  /// **'{active} من {total}'**
  String ofTotalLabel(String active, String total);

  /// No description provided for @exportingReportMsg.
  ///
  /// In ar, this message translates to:
  /// **'جاري تصدير التقرير...'**
  String get exportingReportMsg;

  /// No description provided for @januaryMonth.
  ///
  /// In ar, this message translates to:
  /// **'يناير'**
  String get januaryMonth;

  /// No description provided for @februaryMonth.
  ///
  /// In ar, this message translates to:
  /// **'فبراير'**
  String get februaryMonth;

  /// No description provided for @marchMonth.
  ///
  /// In ar, this message translates to:
  /// **'مارس'**
  String get marchMonth;

  /// No description provided for @aprilMonth.
  ///
  /// In ar, this message translates to:
  /// **'أبريل'**
  String get aprilMonth;

  /// No description provided for @mayMonth.
  ///
  /// In ar, this message translates to:
  /// **'مايو'**
  String get mayMonth;

  /// No description provided for @juneMonth.
  ///
  /// In ar, this message translates to:
  /// **'يونيو'**
  String get juneMonth;

  /// No description provided for @errorLabel.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: {error}'**
  String errorLabel(String error);

  /// No description provided for @saturdayDay.
  ///
  /// In ar, this message translates to:
  /// **'السبت'**
  String get saturdayDay;

  /// No description provided for @sundayDay.
  ///
  /// In ar, this message translates to:
  /// **'الأحد'**
  String get sundayDay;

  /// No description provided for @mondayDay.
  ///
  /// In ar, this message translates to:
  /// **'الاثنين'**
  String get mondayDay;

  /// No description provided for @tuesdayDay.
  ///
  /// In ar, this message translates to:
  /// **'الثلاثاء'**
  String get tuesdayDay;

  /// No description provided for @wednesdayDay.
  ///
  /// In ar, this message translates to:
  /// **'الأربعاء'**
  String get wednesdayDay;

  /// No description provided for @thursdayDay.
  ///
  /// In ar, this message translates to:
  /// **'الخميس'**
  String get thursdayDay;

  /// No description provided for @fridayDay.
  ///
  /// In ar, this message translates to:
  /// **'الجمعة'**
  String get fridayDay;

  /// No description provided for @satShort.
  ///
  /// In ar, this message translates to:
  /// **'سبت'**
  String get satShort;

  /// No description provided for @sunShort.
  ///
  /// In ar, this message translates to:
  /// **'أحد'**
  String get sunShort;

  /// No description provided for @monShort.
  ///
  /// In ar, this message translates to:
  /// **'اثن'**
  String get monShort;

  /// No description provided for @tueShort.
  ///
  /// In ar, this message translates to:
  /// **'ثلا'**
  String get tueShort;

  /// No description provided for @wedShort.
  ///
  /// In ar, this message translates to:
  /// **'أرب'**
  String get wedShort;

  /// No description provided for @thuShort.
  ///
  /// In ar, this message translates to:
  /// **'خمي'**
  String get thuShort;

  /// No description provided for @friShort.
  ///
  /// In ar, this message translates to:
  /// **'جمع'**
  String get friShort;

  /// No description provided for @errorLoadingVatReport.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في تحميل تقرير الضريبة'**
  String get errorLoadingVatReport;

  /// No description provided for @errorLoadingComplaints.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في تحميل الشكاوى'**
  String get errorLoadingComplaints;

  /// No description provided for @errorLoadingCustomerReport.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في تحميل تقرير العملاء'**
  String get errorLoadingCustomerReport;

  /// No description provided for @reprintReceipt.
  ///
  /// In ar, this message translates to:
  /// **'إعادة طباعة الفاتورة'**
  String get reprintReceipt;

  /// No description provided for @searchByInvoiceOrCustomer.
  ///
  /// In ar, this message translates to:
  /// **'بحث برقم الفاتورة أو اسم العميل...'**
  String get searchByInvoiceOrCustomer;

  /// No description provided for @selectInvoiceToPrint.
  ///
  /// In ar, this message translates to:
  /// **'اختر فاتورة لإعادة الطباعة'**
  String get selectInvoiceToPrint;

  /// No description provided for @receiptPreview.
  ///
  /// In ar, this message translates to:
  /// **'معاينة الفاتورة'**
  String get receiptPreview;

  /// No description provided for @receiptPrinted.
  ///
  /// In ar, this message translates to:
  /// **'تمت طباعة الفاتورة بنجاح'**
  String get receiptPrinted;

  /// No description provided for @refunded.
  ///
  /// In ar, this message translates to:
  /// **'مسترجع'**
  String get refunded;

  /// No description provided for @cashMovement.
  ///
  /// In ar, this message translates to:
  /// **'حركة نقدية'**
  String get cashMovement;

  /// No description provided for @movementType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الحركة'**
  String get movementType;

  /// No description provided for @reasonHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل السبب...'**
  String get reasonHint;

  /// No description provided for @bankDeposit.
  ///
  /// In ar, this message translates to:
  /// **'إيداع بنكي'**
  String get bankDeposit;

  /// No description provided for @bankWithdrawal.
  ///
  /// In ar, this message translates to:
  /// **'سحب بنكي'**
  String get bankWithdrawal;

  /// No description provided for @changeForDrawer.
  ///
  /// In ar, this message translates to:
  /// **'فكة للدرج'**
  String get changeForDrawer;

  /// No description provided for @confirmDeposit.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الإيداع'**
  String get confirmDeposit;

  /// No description provided for @confirmWithdrawal.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد السحب'**
  String get confirmWithdrawal;

  /// No description provided for @dailySummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص اليوم'**
  String get dailySummary;

  /// No description provided for @netRevenue.
  ///
  /// In ar, this message translates to:
  /// **'صافي الإيرادات'**
  String get netRevenue;

  /// No description provided for @afterRefunds.
  ///
  /// In ar, this message translates to:
  /// **'بعد المرتجعات'**
  String get afterRefunds;

  /// No description provided for @shiftsCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الورديات'**
  String get shiftsCount;

  /// No description provided for @todayShifts.
  ///
  /// In ar, this message translates to:
  /// **'ورديات اليوم'**
  String get todayShifts;

  /// No description provided for @ongoing.
  ///
  /// In ar, this message translates to:
  /// **'جارية'**
  String get ongoing;

  /// No description provided for @confirmOrder.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الطلب'**
  String get confirmOrder;

  /// No description provided for @orderNow.
  ///
  /// In ar, this message translates to:
  /// **'اطلب الآن'**
  String get orderNow;

  /// No description provided for @orderCart.
  ///
  /// In ar, this message translates to:
  /// **'سلة الطلب'**
  String get orderCart;

  /// No description provided for @orderReceived.
  ///
  /// In ar, this message translates to:
  /// **'تم استلام طلبك!'**
  String get orderReceived;

  /// No description provided for @orderBeingPrepared.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تحضير طلبك في أقرب وقت ممكن'**
  String get orderBeingPrepared;

  /// No description provided for @redirectingToHome.
  ///
  /// In ar, this message translates to:
  /// **'سيتم الانتقال للصفحة الرئيسية تلقائياً...'**
  String get redirectingToHome;

  /// No description provided for @kioskOrderNote.
  ///
  /// In ar, this message translates to:
  /// **'طلب كشك'**
  String get kioskOrderNote;

  /// No description provided for @pricePerUnit.
  ///
  /// In ar, this message translates to:
  /// **'{price} ر.س/وحدة'**
  String pricePerUnit(String price);

  /// No description provided for @selectFromMenu.
  ///
  /// In ar, this message translates to:
  /// **'اختر من القائمة'**
  String get selectFromMenu;

  /// No description provided for @orderCartWithCount.
  ///
  /// In ar, this message translates to:
  /// **'سلة الطلب ({count} صنف)'**
  String orderCartWithCount(int count);

  /// No description provided for @amountWithSar.
  ///
  /// In ar, this message translates to:
  /// **'{amount} ر.س'**
  String amountWithSar(String amount);

  /// No description provided for @qtyTimesPrice.
  ///
  /// In ar, this message translates to:
  /// **'{qty} × {price} ر.س'**
  String qtyTimesPrice(int qty, String price);

  /// No description provided for @applyCoupon.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق كوبون'**
  String get applyCoupon;

  /// No description provided for @enterCouponCode.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كود الكوبون'**
  String get enterCouponCode;

  /// No description provided for @invalidCoupon.
  ///
  /// In ar, this message translates to:
  /// **'كوبون غير صالح أو غير موجود'**
  String get invalidCoupon;

  /// No description provided for @couponExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت صلاحية الكوبون'**
  String get couponExpired;

  /// No description provided for @minimumPurchaseRequired.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى {amount} ريال'**
  String minimumPurchaseRequired(String amount);

  /// No description provided for @couponDiscountApplied.
  ///
  /// In ar, this message translates to:
  /// **'تم خصم {amount} ريال'**
  String couponDiscountApplied(String amount);

  /// No description provided for @couponInvalid.
  ///
  /// In ar, this message translates to:
  /// **'كوبون غير صالح'**
  String get couponInvalid;

  /// No description provided for @customerAddFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل في إضافة العميل'**
  String get customerAddFailed;

  /// No description provided for @quantityColon.
  ///
  /// In ar, this message translates to:
  /// **'الكمية:'**
  String get quantityColon;

  /// No description provided for @riyal.
  ///
  /// In ar, this message translates to:
  /// **'ريال'**
  String get riyal;

  /// No description provided for @mobileNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get mobileNumber;

  /// No description provided for @banknotes.
  ///
  /// In ar, this message translates to:
  /// **'أوراق نقدية'**
  String get banknotes;

  /// No description provided for @coins.
  ///
  /// In ar, this message translates to:
  /// **'عملات معدنية'**
  String get coins;

  /// No description provided for @totalAmountLabel.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المبلغ'**
  String get totalAmountLabel;

  /// No description provided for @denominationRiyal.
  ///
  /// In ar, this message translates to:
  /// **'{amount} ريال'**
  String denominationRiyal(String amount);

  /// No description provided for @denominationHalala.
  ///
  /// In ar, this message translates to:
  /// **'{amount} هللة'**
  String denominationHalala(String amount);

  /// No description provided for @countCurrency.
  ///
  /// In ar, this message translates to:
  /// **'عد العملات'**
  String get countCurrency;

  /// No description provided for @confirmAmountSar.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد: {amount} ر.س'**
  String confirmAmountSar(String amount);

  /// No description provided for @amountRiyal.
  ///
  /// In ar, this message translates to:
  /// **'{amount} ريال'**
  String amountRiyal(String amount);

  /// No description provided for @itemDeletedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم الحذف'**
  String get itemDeletedMsg;

  /// No description provided for @pressBackAgainToExit.
  ///
  /// In ar, this message translates to:
  /// **'اضغط مرة أخرى للخروج'**
  String get pressBackAgainToExit;

  /// No description provided for @deleteHeldInvoiceConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذه الفاتورة المعلقة؟'**
  String get deleteHeldInvoiceConfirm;

  /// No description provided for @clearSearch.
  ///
  /// In ar, this message translates to:
  /// **'مسح البحث'**
  String get clearSearch;

  /// No description provided for @addCustomer.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عميل'**
  String get addCustomer;

  /// No description provided for @noInvoices.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فواتير'**
  String get noInvoices;

  /// No description provided for @noReports.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تقارير'**
  String get noReports;

  /// No description provided for @noOffers.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عروض'**
  String get noOffers;

  /// No description provided for @emptyStateStartAddProducts.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بإضافة منتجاتك الآن'**
  String get emptyStateStartAddProducts;

  /// No description provided for @emptyStateStartAddCustomers.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بإضافة عملائك الآن'**
  String get emptyStateStartAddCustomers;

  /// No description provided for @emptyStateAddProductsToCart.
  ///
  /// In ar, this message translates to:
  /// **'أضف منتجات للسلة لبدء البيع'**
  String get emptyStateAddProductsToCart;

  /// No description provided for @emptyStateInvoicesAppearAfterSale.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر الفواتير هنا بعد إتمام عمليات البيع'**
  String get emptyStateInvoicesAppearAfterSale;

  /// No description provided for @emptyStateNewOrdersAppearHere.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر الطلبات الجديدة هنا'**
  String get emptyStateNewOrdersAppearHere;

  /// No description provided for @emptyStateNewNotificationsAppearHere.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر الإشعارات الجديدة هنا'**
  String get emptyStateNewNotificationsAppearHere;

  /// No description provided for @emptyStateCheckYourConnection.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من اتصالك بالإنترنت'**
  String get emptyStateCheckYourConnection;

  /// No description provided for @emptyStateReportsAppearAfterSale.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر التقارير بعد إتمام عمليات البيع'**
  String get emptyStateReportsAppearAfterSale;

  /// No description provided for @emptyStateNoNeedToRestock.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات تحتاج إعادة تعبئة'**
  String get emptyStateNoNeedToRestock;

  /// No description provided for @emptyStateAllCustomersPaid.
  ///
  /// In ar, this message translates to:
  /// **'جميع العملاء قاموا بالسداد'**
  String get emptyStateAllCustomersPaid;

  /// No description provided for @emptyStateReturnsAppearHere.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر المرتجعات هنا'**
  String get emptyStateReturnsAppearHere;

  /// No description provided for @emptyStateAddOffersToAttract.
  ///
  /// In ar, this message translates to:
  /// **'أضف عروضاً لجذب المزيد من العملاء'**
  String get emptyStateAddOffersToAttract;

  /// No description provided for @errorNoInternetConnection.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get errorNoInternetConnection;

  /// No description provided for @errorCheckConnectionAndRetry.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من اتصالك بالإنترنت وحاول مرة أخرى'**
  String get errorCheckConnectionAndRetry;

  /// No description provided for @errorServerError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الخادم'**
  String get errorServerError;

  /// No description provided for @errorServerConnectionFailed.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء الاتصال بالخادم'**
  String get errorServerConnectionFailed;

  /// No description provided for @errorUnexpectedError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع'**
  String get errorUnexpectedError;

  /// No description provided for @customerGroups.
  ///
  /// In ar, this message translates to:
  /// **'مجموعات العملاء'**
  String get customerGroups;

  /// No description provided for @allCustomersGroup.
  ///
  /// In ar, this message translates to:
  /// **'كل العملاء'**
  String get allCustomersGroup;

  /// No description provided for @vipCustomersGroup.
  ///
  /// In ar, this message translates to:
  /// **'عملاء VIP'**
  String get vipCustomersGroup;

  /// No description provided for @regularCustomersGroup.
  ///
  /// In ar, this message translates to:
  /// **'عملاء منتظمون'**
  String get regularCustomersGroup;

  /// No description provided for @newCustomersGroup.
  ///
  /// In ar, this message translates to:
  /// **'عملاء جدد'**
  String get newCustomersGroup;

  /// No description provided for @newCustomers30Days.
  ///
  /// In ar, this message translates to:
  /// **'عملاء جدد (30 يوم)'**
  String get newCustomers30Days;

  /// No description provided for @customersWithDebt.
  ///
  /// In ar, this message translates to:
  /// **'عملاء لديهم ديون'**
  String get customersWithDebt;

  /// No description provided for @haveDebts.
  ///
  /// In ar, this message translates to:
  /// **'لديهم ديون'**
  String get haveDebts;

  /// No description provided for @inactive90Days.
  ///
  /// In ar, this message translates to:
  /// **'غير نشطين (90+ يوم)'**
  String get inactive90Days;

  /// No description provided for @customerCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count} عميل'**
  String customerCountLabel(int count);

  /// No description provided for @selectGroupToViewCustomers.
  ///
  /// In ar, this message translates to:
  /// **'اختر مجموعة لعرض العملاء'**
  String get selectGroupToViewCustomers;

  /// No description provided for @noCustomersInGroup.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد عملاء في هذه المجموعة'**
  String get noCustomersInGroup;

  /// No description provided for @debtWord.
  ///
  /// In ar, this message translates to:
  /// **'دين'**
  String get debtWord;

  /// No description provided for @employeeProfile.
  ///
  /// In ar, this message translates to:
  /// **'ملف الموظف'**
  String get employeeProfile;

  /// No description provided for @employeeNotFound.
  ///
  /// In ar, this message translates to:
  /// **'الموظف غير موجود'**
  String get employeeNotFound;

  /// No description provided for @profileTab.
  ///
  /// In ar, this message translates to:
  /// **'الملف'**
  String get profileTab;

  /// No description provided for @salesTab.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات'**
  String get salesTab;

  /// No description provided for @shiftsTab.
  ///
  /// In ar, this message translates to:
  /// **'الورديات'**
  String get shiftsTab;

  /// No description provided for @permissionsTab2.
  ///
  /// In ar, this message translates to:
  /// **'الصلاحيات'**
  String get permissionsTab2;

  /// No description provided for @mobilePhone.
  ///
  /// In ar, this message translates to:
  /// **'الجوال'**
  String get mobilePhone;

  /// No description provided for @joinDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانضمام'**
  String get joinDate;

  /// No description provided for @lastLogin.
  ///
  /// In ar, this message translates to:
  /// **'آخر دخول'**
  String get lastLogin;

  /// No description provided for @neverLoggedIn.
  ///
  /// In ar, this message translates to:
  /// **'لم يدخل بعد'**
  String get neverLoggedIn;

  /// No description provided for @accountActive.
  ///
  /// In ar, this message translates to:
  /// **'الحساب نشط'**
  String get accountActive;

  /// No description provided for @canLogin.
  ///
  /// In ar, this message translates to:
  /// **'يمكنه تسجيل الدخول'**
  String get canLogin;

  /// No description provided for @blockedFromLogin.
  ///
  /// In ar, this message translates to:
  /// **'محظور من الدخول'**
  String get blockedFromLogin;

  /// No description provided for @employeeFallback.
  ///
  /// In ar, this message translates to:
  /// **'موظف'**
  String get employeeFallback;

  /// No description provided for @weekLabel.
  ///
  /// In ar, this message translates to:
  /// **'أسبوع'**
  String get weekLabel;

  /// No description provided for @monthLabel.
  ///
  /// In ar, this message translates to:
  /// **'شهر'**
  String get monthLabel;

  /// No description provided for @loadSalesData.
  ///
  /// In ar, this message translates to:
  /// **'تحميل بيانات المبيعات'**
  String get loadSalesData;

  /// No description provided for @invoiceCountLabel2.
  ///
  /// In ar, this message translates to:
  /// **'عدد الفواتير'**
  String get invoiceCountLabel2;

  /// No description provided for @hourlySalesDistribution.
  ///
  /// In ar, this message translates to:
  /// **'توزيع المبيعات بالساعة'**
  String get hourlySalesDistribution;

  /// No description provided for @shiftOpenTime.
  ///
  /// In ar, this message translates to:
  /// **'فتح: {time}'**
  String shiftOpenTime(String time);

  /// No description provided for @shiftCloseTime.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق: {time}'**
  String shiftCloseTime(String time);

  /// No description provided for @hoursMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{hours}س {minutes}د'**
  String hoursMinutes(int hours, int minutes);

  /// No description provided for @shiftOpenStatus.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح'**
  String get shiftOpenStatus;

  /// No description provided for @invoiceCountWithNum.
  ///
  /// In ar, this message translates to:
  /// **'{count} فاتورة'**
  String invoiceCountWithNum(int count);

  /// No description provided for @permissionsSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الصلاحيات'**
  String get permissionsSaved;

  /// No description provided for @jobRole.
  ///
  /// In ar, this message translates to:
  /// **'الدور الوظيفي'**
  String get jobRole;

  /// No description provided for @manageProducts.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المنتجات'**
  String get manageProducts;

  /// No description provided for @viewReports.
  ///
  /// In ar, this message translates to:
  /// **'عرض التقارير'**
  String get viewReports;

  /// No description provided for @refundOperations.
  ///
  /// In ar, this message translates to:
  /// **'عمليات الاسترداد'**
  String get refundOperations;

  /// No description provided for @manageCustomersPermission.
  ///
  /// In ar, this message translates to:
  /// **'إدارة العملاء'**
  String get manageCustomersPermission;

  /// No description provided for @manageOffers.
  ///
  /// In ar, this message translates to:
  /// **'إدارة العروض'**
  String get manageOffers;

  /// No description provided for @savePermissions.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الصلاحيات'**
  String get savePermissions;

  /// No description provided for @deactivateAccount.
  ///
  /// In ar, this message translates to:
  /// **'تعطيل الحساب'**
  String get deactivateAccount;

  /// No description provided for @activateAccount.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الحساب'**
  String get activateAccount;

  /// No description provided for @confirmDeactivateAccount.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تعطيل حساب {name}؟'**
  String confirmDeactivateAccount(String name);

  /// No description provided for @confirmActivateAccount.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تفعيل حساب {name}؟'**
  String confirmActivateAccount(String name);

  /// No description provided for @deactivate.
  ///
  /// In ar, this message translates to:
  /// **'تعطيل'**
  String get deactivate;

  /// No description provided for @activate.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل'**
  String get activate;

  /// No description provided for @accountActivated.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل الحساب'**
  String get accountActivated;

  /// No description provided for @accountDeactivated.
  ///
  /// In ar, this message translates to:
  /// **'تم تعطيل الحساب'**
  String get accountDeactivated;

  /// No description provided for @employeeAttendance.
  ///
  /// In ar, this message translates to:
  /// **'حضور وانصراف الموظفين'**
  String get employeeAttendance;

  /// No description provided for @presentLabel.
  ///
  /// In ar, this message translates to:
  /// **'حاضر'**
  String get presentLabel;

  /// No description provided for @absentLabel.
  ///
  /// In ar, this message translates to:
  /// **'غائب'**
  String get absentLabel;

  /// No description provided for @attendanceCount.
  ///
  /// In ar, this message translates to:
  /// **'الحضور'**
  String get attendanceCount;

  /// No description provided for @absencesCount.
  ///
  /// In ar, this message translates to:
  /// **'الغياب'**
  String get absencesCount;

  /// No description provided for @lateCount.
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get lateCount;

  /// No description provided for @totalEmployees.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الموظفين'**
  String get totalEmployees;

  /// No description provided for @noAttendanceRecordsForDay.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سجلات حضور ليوم {day}/{month}'**
  String noAttendanceRecordsForDay(int day, int month);

  /// No description provided for @workingNow.
  ///
  /// In ar, this message translates to:
  /// **'يعمل الآن'**
  String get workingNow;

  /// No description provided for @loyaltyTierCustomizeHint.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك تخصيص مستويات برنامج الولاء وتحديد النقاط والمزايا لكل مستوى.'**
  String get loyaltyTierCustomizeHint;

  /// No description provided for @memberCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} عضو'**
  String memberCount(int count);

  /// No description provided for @pointsRequired.
  ///
  /// In ar, this message translates to:
  /// **'النقاط المطلوبة'**
  String get pointsRequired;

  /// No description provided for @discountPercentage.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الخصم'**
  String get discountPercentage;

  /// No description provided for @pointsMultiplier.
  ///
  /// In ar, this message translates to:
  /// **'مضاعف النقاط'**
  String get pointsMultiplier;

  /// No description provided for @addTier.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مستوى'**
  String get addTier;

  /// No description provided for @addNewTier.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مستوى جديد'**
  String get addNewTier;

  /// No description provided for @nameArabic.
  ///
  /// In ar, this message translates to:
  /// **'الاسم (عربي)'**
  String get nameArabic;

  /// No description provided for @nameEnglish.
  ///
  /// In ar, this message translates to:
  /// **'Name (English)'**
  String get nameEnglish;

  /// No description provided for @minPoints.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى من النقاط'**
  String get minPoints;

  /// No description provided for @maxPointsHint.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى (اتركه فارغاً = غير محدود)'**
  String get maxPointsHint;

  /// No description provided for @multiplierLabel.
  ///
  /// In ar, this message translates to:
  /// **'مضاعف النقاط: {value}x'**
  String multiplierLabel(String value);

  /// No description provided for @tierBenefits.
  ///
  /// In ar, this message translates to:
  /// **'مزايا مستوى {tier}'**
  String tierBenefits(String tier);

  /// No description provided for @discountOnPurchases.
  ///
  /// In ar, this message translates to:
  /// **'• خصم {value}% على المشتريات'**
  String discountOnPurchases(String value);

  /// No description provided for @pointsPerPurchase.
  ///
  /// In ar, this message translates to:
  /// **'• {value}x نقاط على كل عملية شراء'**
  String pointsPerPurchase(String value);

  /// No description provided for @whatsappManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة WhatsApp'**
  String get whatsappManagement;

  /// No description provided for @messageQueue.
  ///
  /// In ar, this message translates to:
  /// **'قائمة الانتظار'**
  String get messageQueue;

  /// No description provided for @templates.
  ///
  /// In ar, this message translates to:
  /// **'القوالب'**
  String get templates;

  /// No description provided for @sentStatus.
  ///
  /// In ar, this message translates to:
  /// **'مُرسل'**
  String get sentStatus;

  /// No description provided for @failedStatus.
  ///
  /// In ar, this message translates to:
  /// **'فشل'**
  String get failedStatus;

  /// No description provided for @noMessages.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رسائل'**
  String get noMessages;

  /// No description provided for @retrySend.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال'**
  String get retrySend;

  /// No description provided for @requeuedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تمت إعادة الإرسال إلى قائمة الانتظار'**
  String get requeuedMessage;

  /// No description provided for @templateCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} قالب'**
  String templateCount(int count);

  /// No description provided for @newTemplate.
  ///
  /// In ar, this message translates to:
  /// **'قالب جديد'**
  String get newTemplate;

  /// No description provided for @editTemplate.
  ///
  /// In ar, this message translates to:
  /// **'تعديل القالب'**
  String get editTemplate;

  /// No description provided for @templateName.
  ///
  /// In ar, this message translates to:
  /// **'اسم القالب'**
  String get templateName;

  /// No description provided for @messageText.
  ///
  /// In ar, this message translates to:
  /// **'نص الرسالة'**
  String get messageText;

  /// No description provided for @templateVariablesHint.
  ///
  /// In ar, this message translates to:
  /// **'استخدم {store_name} {customer_name} {total} كمتغيرات'**
  String templateVariablesHint(
      Object customer_name, Object store_name, Object total);

  /// No description provided for @apiSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات API'**
  String get apiSettings;

  /// No description provided for @apiKey.
  ///
  /// In ar, this message translates to:
  /// **'مفتاح API'**
  String get apiKey;

  /// No description provided for @testingConnection.
  ///
  /// In ar, this message translates to:
  /// **'جاري اختبار الاتصال...'**
  String get testingConnection;

  /// No description provided for @sendSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الإرسال'**
  String get sendSettings;

  /// No description provided for @autoSend.
  ///
  /// In ar, this message translates to:
  /// **'الإرسال التلقائي'**
  String get autoSend;

  /// No description provided for @autoSendDescription.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الرسائل تلقائياً بعد كل عملية'**
  String get autoSendDescription;

  /// No description provided for @dailyMessageLimit.
  ///
  /// In ar, this message translates to:
  /// **'الحد اليومي للرسائل'**
  String get dailyMessageLimit;

  /// No description provided for @messagesPerDay.
  ///
  /// In ar, this message translates to:
  /// **'{count} رسالة/يوم'**
  String messagesPerDay(int count);

  /// No description provided for @salesInvoiceTemplate.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة البيع'**
  String get salesInvoiceTemplate;

  /// No description provided for @debtReminderTemplate.
  ///
  /// In ar, this message translates to:
  /// **'تذكير الدين'**
  String get debtReminderTemplate;

  /// No description provided for @newCustomerWelcomeTemplate.
  ///
  /// In ar, this message translates to:
  /// **'ترحيب بالعميل الجديد'**
  String get newCustomerWelcomeTemplate;

  /// No description provided for @supplierReturns.
  ///
  /// In ar, this message translates to:
  /// **'مرتجعات المشتريات'**
  String get supplierReturns;

  /// No description provided for @addItemForReturn.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صنف للإرجاع'**
  String get addItemForReturn;

  /// No description provided for @itemName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الصنف'**
  String get itemName;

  /// No description provided for @unitPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر الوحدة'**
  String get unitPrice;

  /// No description provided for @sarSuffix.
  ///
  /// In ar, this message translates to:
  /// **'ر.س'**
  String get sarSuffix;

  /// No description provided for @pleaseAddItems.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إضافة أصناف للإرجاع'**
  String get pleaseAddItems;

  /// No description provided for @creditNoteWillBeRecorded.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تسجيل إشعار خصم وتعديل المخزون.'**
  String get creditNoteWillBeRecorded;

  /// No description provided for @issueCreditNote.
  ///
  /// In ar, this message translates to:
  /// **'إصدار إشعار خصم'**
  String get issueCreditNote;

  /// No description provided for @returnRecordedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل المرتجع بنجاح - إشعار خصم: {amount} ر.س'**
  String returnRecordedSuccess(String amount);

  /// No description provided for @selectSupplier.
  ///
  /// In ar, this message translates to:
  /// **'اختر المورد'**
  String get selectSupplier;

  /// No description provided for @damagedDefective.
  ///
  /// In ar, this message translates to:
  /// **'تالف / معيب'**
  String get damagedDefective;

  /// No description provided for @wrongItem.
  ///
  /// In ar, this message translates to:
  /// **'صنف خاطئ'**
  String get wrongItem;

  /// No description provided for @overstockExcess.
  ///
  /// In ar, this message translates to:
  /// **'فائض عن الحاجة'**
  String get overstockExcess;

  /// No description provided for @addItem.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صنف'**
  String get addItem;

  /// No description provided for @noItemsAddedYet.
  ///
  /// In ar, this message translates to:
  /// **'لم تتم إضافة أصناف بعد'**
  String get noItemsAddedYet;

  /// No description provided for @notes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get notes;

  /// No description provided for @additionalNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'أي ملاحظات إضافية...'**
  String get additionalNotesHint;

  /// No description provided for @totalReturn.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المرتجع'**
  String get totalReturn;

  /// No description provided for @issueCreditNoteWithAmount.
  ///
  /// In ar, this message translates to:
  /// **'إصدار إشعار خصم ({amount} ر.س)'**
  String issueCreditNoteWithAmount(String amount);

  /// No description provided for @deliveryZones.
  ///
  /// In ar, this message translates to:
  /// **'مناطق التوصيل'**
  String get deliveryZones;

  /// No description provided for @addDeliveryZone.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منطقة'**
  String get addDeliveryZone;

  /// No description provided for @editDeliveryZone.
  ///
  /// In ar, this message translates to:
  /// **'تعديل منطقة التوصيل'**
  String get editDeliveryZone;

  /// No description provided for @addDeliveryZoneTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منطقة توصيل'**
  String get addDeliveryZoneTitle;

  /// No description provided for @zoneName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المنطقة'**
  String get zoneName;

  /// No description provided for @fromKm.
  ///
  /// In ar, this message translates to:
  /// **'من (كم)'**
  String get fromKm;

  /// No description provided for @toKm.
  ///
  /// In ar, this message translates to:
  /// **'إلى (كم)'**
  String get toKm;

  /// No description provided for @kmUnit.
  ///
  /// In ar, this message translates to:
  /// **'كم'**
  String get kmUnit;

  /// No description provided for @deliveryFee.
  ///
  /// In ar, this message translates to:
  /// **'رسوم التوصيل'**
  String get deliveryFee;

  /// No description provided for @minOrderAmount.
  ///
  /// In ar, this message translates to:
  /// **'حد أدنى للطلب'**
  String get minOrderAmount;

  /// No description provided for @estimatedDeliveryTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت التوصيل التقديري'**
  String get estimatedDeliveryTime;

  /// No description provided for @minuteUnit.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة'**
  String get minuteUnit;

  /// No description provided for @zoneUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث المنطقة'**
  String get zoneUpdated;

  /// No description provided for @zoneAdded.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة المنطقة'**
  String get zoneAdded;

  /// No description provided for @deleteZone.
  ///
  /// In ar, this message translates to:
  /// **'حذف المنطقة'**
  String get deleteZone;

  /// No description provided for @deleteZoneConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذه المنطقة؟'**
  String get deleteZoneConfirm;

  /// No description provided for @activeZones.
  ///
  /// In ar, this message translates to:
  /// **'مناطق نشطة'**
  String get activeZones;

  /// No description provided for @lowestFee.
  ///
  /// In ar, this message translates to:
  /// **'أقل رسوم'**
  String get lowestFee;

  /// No description provided for @highestFee.
  ///
  /// In ar, this message translates to:
  /// **'أعلى رسوم'**
  String get highestFee;

  /// No description provided for @noDeliveryZones.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مناطق توصيل'**
  String get noDeliveryZones;

  /// No description provided for @addDeliveryZonesDescription.
  ///
  /// In ar, this message translates to:
  /// **'أضف مناطق التوصيل لتحديد أسعار ونطاقات التوصيل'**
  String get addDeliveryZonesDescription;

  /// No description provided for @deliveryTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت التوصيل'**
  String get deliveryTime;

  /// No description provided for @minuteAbbr.
  ///
  /// In ar, this message translates to:
  /// **'د'**
  String get minuteAbbr;

  /// No description provided for @giftCards.
  ///
  /// In ar, this message translates to:
  /// **'بطاقات الهدايا'**
  String get giftCards;

  /// No description provided for @redeemCard.
  ///
  /// In ar, this message translates to:
  /// **'صرف بطاقة'**
  String get redeemCard;

  /// No description provided for @issueGiftCard.
  ///
  /// In ar, this message translates to:
  /// **'إصدار بطاقة هدية'**
  String get issueGiftCard;

  /// No description provided for @cardValue.
  ///
  /// In ar, this message translates to:
  /// **'قيمة البطاقة (ر.س)'**
  String get cardValue;

  /// No description provided for @giftCardIssued.
  ///
  /// In ar, this message translates to:
  /// **'تم إصدار بطاقة هدية بقيمة {amount} ر.س'**
  String giftCardIssued(String amount);

  /// No description provided for @issueCard.
  ///
  /// In ar, this message translates to:
  /// **'إصدار البطاقة'**
  String get issueCard;

  /// No description provided for @redeemGiftCard.
  ///
  /// In ar, this message translates to:
  /// **'صرف بطاقة هدية'**
  String get redeemGiftCard;

  /// No description provided for @cardCode.
  ///
  /// In ar, this message translates to:
  /// **'كود البطاقة'**
  String get cardCode;

  /// No description provided for @noCardWithCode.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بطاقة بهذا الكود'**
  String get noCardWithCode;

  /// No description provided for @cardBalanceZero.
  ///
  /// In ar, this message translates to:
  /// **'رصيد البطاقة صفر'**
  String get cardBalanceZero;

  /// No description provided for @cardBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيد البطاقة: {amount} ر.س'**
  String cardBalance(String amount);

  /// No description provided for @verify.
  ///
  /// In ar, this message translates to:
  /// **'تحقق'**
  String get verify;

  /// No description provided for @cardsTab.
  ///
  /// In ar, this message translates to:
  /// **'البطاقات'**
  String get cardsTab;

  /// No description provided for @statisticsTab.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get statisticsTab;

  /// No description provided for @searchByCode.
  ///
  /// In ar, this message translates to:
  /// **'بحث بالكود...'**
  String get searchByCode;

  /// No description provided for @activeFilter.
  ///
  /// In ar, this message translates to:
  /// **'نشطة'**
  String get activeFilter;

  /// No description provided for @usedFilter.
  ///
  /// In ar, this message translates to:
  /// **'مستخدمة'**
  String get usedFilter;

  /// No description provided for @expiredFilter.
  ///
  /// In ar, this message translates to:
  /// **'منتهية'**
  String get expiredFilter;

  /// No description provided for @noGiftCards.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بطاقات هدايا'**
  String get noGiftCards;

  /// No description provided for @issueGiftCardsDescription.
  ///
  /// In ar, this message translates to:
  /// **'أصدر بطاقات هدايا لعملائك'**
  String get issueGiftCardsDescription;

  /// No description provided for @totalActiveBalance.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الرصيد النشط'**
  String get totalActiveBalance;

  /// No description provided for @totalIssuedValue.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي القيمة المصدرة'**
  String get totalIssuedValue;

  /// No description provided for @activeCards.
  ///
  /// In ar, this message translates to:
  /// **'البطاقات النشطة'**
  String get activeCards;

  /// No description provided for @usedCards.
  ///
  /// In ar, this message translates to:
  /// **'البطاقات المستخدمة'**
  String get usedCards;

  /// No description provided for @giftCardStatusActive.
  ///
  /// In ar, this message translates to:
  /// **'نشطة'**
  String get giftCardStatusActive;

  /// No description provided for @giftCardStatusPartiallyUsed.
  ///
  /// In ar, this message translates to:
  /// **'مستخدمة جزئياً'**
  String get giftCardStatusPartiallyUsed;

  /// No description provided for @giftCardStatusFullyUsed.
  ///
  /// In ar, this message translates to:
  /// **'مستخدمة بالكامل'**
  String get giftCardStatusFullyUsed;

  /// No description provided for @giftCardStatusExpired.
  ///
  /// In ar, this message translates to:
  /// **'منتهية الصلاحية'**
  String get giftCardStatusExpired;

  /// No description provided for @balanceDisplay.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد: {balance}/{total} ر.س'**
  String balanceDisplay(String balance, String total);

  /// No description provided for @expiresOn.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي: {date}'**
  String expiresOn(String date);

  /// No description provided for @onlineOrders.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات الإلكترونية'**
  String get onlineOrders;

  /// No description provided for @statusNew.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get statusNew;

  /// No description provided for @statusPreparing.
  ///
  /// In ar, this message translates to:
  /// **'قيد التجهيز'**
  String get statusPreparing;

  /// No description provided for @statusReady.
  ///
  /// In ar, this message translates to:
  /// **'جاهز'**
  String get statusReady;

  /// No description provided for @statusShipped.
  ///
  /// In ar, this message translates to:
  /// **'تم الشحن'**
  String get statusShipped;

  /// No description provided for @statusDelivered.
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم'**
  String get statusDelivered;

  /// No description provided for @statusReadyForPickup.
  ///
  /// In ar, this message translates to:
  /// **'جاهز للاستلام'**
  String get statusReadyForPickup;

  /// No description provided for @nextStatusAcceptOrder.
  ///
  /// In ar, this message translates to:
  /// **'قبول الطلب'**
  String get nextStatusAcceptOrder;

  /// No description provided for @nextStatusReady.
  ///
  /// In ar, this message translates to:
  /// **'جاهز'**
  String get nextStatusReady;

  /// No description provided for @nextStatusShipped.
  ///
  /// In ar, this message translates to:
  /// **'تم الشحن'**
  String get nextStatusShipped;

  /// No description provided for @nextStatusDelivered.
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم'**
  String get nextStatusDelivered;

  /// No description provided for @timeAgoMinutes.
  ///
  /// In ar, this message translates to:
  /// **'منذ {minutes} دقيقة'**
  String timeAgoMinutes(int minutes);

  /// No description provided for @timeAgoHours.
  ///
  /// In ar, this message translates to:
  /// **'منذ {hours} ساعة'**
  String timeAgoHours(int hours);

  /// No description provided for @damagedAndLostGoods.
  ///
  /// In ar, this message translates to:
  /// **'البضاعة التالفة والمفقودة'**
  String get damagedAndLostGoods;

  /// No description provided for @damagedDefectiveShort.
  ///
  /// In ar, this message translates to:
  /// **'تالف / معيب'**
  String get damagedDefectiveShort;

  /// No description provided for @expiredShort.
  ///
  /// In ar, this message translates to:
  /// **'منتهي الصلاحية'**
  String get expiredShort;

  /// No description provided for @theftLoss.
  ///
  /// In ar, this message translates to:
  /// **'سرقة / فقدان'**
  String get theftLoss;

  /// No description provided for @wasteBreakage.
  ///
  /// In ar, this message translates to:
  /// **'هدر / كسر'**
  String get wasteBreakage;

  /// No description provided for @unknownProduct.
  ///
  /// In ar, this message translates to:
  /// **'منتج غير محدد'**
  String get unknownProduct;

  /// No description provided for @recordDamagedGoods.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل بضاعة تالفة'**
  String get recordDamagedGoods;

  /// No description provided for @costPerUnit.
  ///
  /// In ar, this message translates to:
  /// **'التكلفة/وحدة'**
  String get costPerUnit;

  /// No description provided for @lossType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الخسارة'**
  String get lossType;

  /// No description provided for @damagedGoodsRecorded.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل البضاعة التالفة بنجاح'**
  String get damagedGoodsRecorded;

  /// No description provided for @periodLabel.
  ///
  /// In ar, this message translates to:
  /// **'الفترة'**
  String get periodLabel;

  /// No description provided for @totalLosses.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الخسائر'**
  String get totalLosses;

  /// No description provided for @noDamagedGoods.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بضاعة تالفة'**
  String get noDamagedGoods;

  /// No description provided for @noDamagedGoodsInPeriod.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بضاعة تالفة في هذه الفترة'**
  String get noDamagedGoodsInPeriod;

  /// No description provided for @recordDamagedGoodsFab.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل بضاعة تالفة'**
  String get recordDamagedGoodsFab;

  /// No description provided for @quantityWithValue.
  ///
  /// In ar, this message translates to:
  /// **'الكمية: {qty}'**
  String quantityWithValue(String qty);

  /// No description provided for @purchaseDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل طلب الشراء'**
  String get purchaseDetails;

  /// No description provided for @purchaseNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على طلب الشراء'**
  String get purchaseNotFound;

  /// No description provided for @backToList.
  ///
  /// In ar, this message translates to:
  /// **'العودة للقائمة'**
  String get backToList;

  /// No description provided for @statusDraft.
  ///
  /// In ar, this message translates to:
  /// **'مسودة'**
  String get statusDraft;

  /// No description provided for @statusSent.
  ///
  /// In ar, this message translates to:
  /// **'مُرسل'**
  String get statusSent;

  /// No description provided for @statusApproved.
  ///
  /// In ar, this message translates to:
  /// **'موافق عليه'**
  String get statusApproved;

  /// No description provided for @statusReceived.
  ///
  /// In ar, this message translates to:
  /// **'مستلم'**
  String get statusReceived;

  /// No description provided for @statusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get statusCompleted;

  /// No description provided for @supplierInfoLabel.
  ///
  /// In ar, this message translates to:
  /// **'المورد'**
  String get supplierInfoLabel;

  /// No description provided for @dateLabel.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get dateLabel;

  /// No description provided for @orderTimeline.
  ///
  /// In ar, this message translates to:
  /// **'مسار الطلب'**
  String get orderTimeline;

  /// No description provided for @actionsLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإجراءات'**
  String get actionsLabel;

  /// No description provided for @sendToDistributor.
  ///
  /// In ar, this message translates to:
  /// **'إرسال للموزع'**
  String get sendToDistributor;

  /// No description provided for @awaitingDistributorResponse.
  ///
  /// In ar, this message translates to:
  /// **'في انتظار رد الموزع'**
  String get awaitingDistributorResponse;

  /// No description provided for @goodsReceived.
  ///
  /// In ar, this message translates to:
  /// **'تم استلام البضاعة'**
  String get goodsReceived;

  /// No description provided for @orderItems.
  ///
  /// In ar, this message translates to:
  /// **'أصناف الطلب'**
  String get orderItems;

  /// No description provided for @itemCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count} صنف'**
  String itemCountLabel(int count);

  /// No description provided for @productColumn.
  ///
  /// In ar, this message translates to:
  /// **'المنتج'**
  String get productColumn;

  /// No description provided for @quantityColumn.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get quantityColumn;

  /// No description provided for @receivedColumn.
  ///
  /// In ar, this message translates to:
  /// **'المستلم'**
  String get receivedColumn;

  /// No description provided for @unitPriceColumn.
  ///
  /// In ar, this message translates to:
  /// **'سعر الوحدة'**
  String get unitPriceColumn;

  /// No description provided for @totalColumn.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get totalColumn;

  /// No description provided for @quantityInfo.
  ///
  /// In ar, this message translates to:
  /// **'الكمية: {qty}  |  المستلم: {received}  |  {price} ر.س'**
  String quantityInfo(int qty, int received, String price);

  /// No description provided for @receivingGoods.
  ///
  /// In ar, this message translates to:
  /// **'استلام البضاعة'**
  String get receivingGoods;

  /// No description provided for @unsavedChanges.
  ///
  /// In ar, this message translates to:
  /// **'تغييرات غير محفوظة'**
  String get unsavedChanges;

  /// No description provided for @leaveWithoutSaving.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد المغادرة بدون حفظ التغييرات؟'**
  String get leaveWithoutSaving;

  /// No description provided for @leave.
  ///
  /// In ar, this message translates to:
  /// **'مغادرة'**
  String get leave;

  /// No description provided for @receivingGoodsTitle.
  ///
  /// In ar, this message translates to:
  /// **'استلام البضاعة - {number}'**
  String receivingGoodsTitle(String number);

  /// No description provided for @orderData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الطلب'**
  String get orderData;

  /// No description provided for @receivedItems.
  ///
  /// In ar, this message translates to:
  /// **'الأصناف المستلمة'**
  String get receivedItems;

  /// No description provided for @orderedQty.
  ///
  /// In ar, this message translates to:
  /// **'الطلب: {qty}'**
  String orderedQty(int qty);

  /// No description provided for @receivedQtyLabel.
  ///
  /// In ar, this message translates to:
  /// **'المستلم'**
  String get receivedQtyLabel;

  /// No description provided for @receivingInfo.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الاستلام'**
  String get receivingInfo;

  /// No description provided for @receiverName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستلم *'**
  String get receiverName;

  /// No description provided for @receivingNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات الاستلام'**
  String get receivingNotes;

  /// No description provided for @confirmingReceipt.
  ///
  /// In ar, this message translates to:
  /// **'جاري التأكيد...'**
  String get confirmingReceipt;

  /// No description provided for @confirmReceipt.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الاستلام'**
  String get confirmReceipt;

  /// No description provided for @purchaseOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الشراء'**
  String get purchaseOrders;

  /// No description provided for @statusApprovedShort.
  ///
  /// In ar, this message translates to:
  /// **'موافق'**
  String get statusApprovedShort;

  /// No description provided for @orderNumberColumn.
  ///
  /// In ar, this message translates to:
  /// **'رقم الطلب'**
  String get orderNumberColumn;

  /// No description provided for @statusColumn.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get statusColumn;

  /// No description provided for @noPurchaseOrders.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات شراء'**
  String get noPurchaseOrders;

  /// No description provided for @createPurchaseToStart.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ طلب شراء جديد للبدء'**
  String get createPurchaseToStart;

  /// No description provided for @errorLoadingData.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في تحميل البيانات'**
  String get errorLoadingData;

  /// No description provided for @sendToDistributorTitle.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الطلب للموزع'**
  String get sendToDistributorTitle;

  /// No description provided for @orderInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الطلب'**
  String get orderInfo;

  /// No description provided for @currentSupplier.
  ///
  /// In ar, this message translates to:
  /// **'المورد الحالي'**
  String get currentSupplier;

  /// No description provided for @itemsSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الأصناف'**
  String get itemsSummary;

  /// No description provided for @distributorSupplier.
  ///
  /// In ar, this message translates to:
  /// **'الموزع / المورد'**
  String get distributorSupplier;

  /// No description provided for @additionalMessage.
  ///
  /// In ar, this message translates to:
  /// **'رسالة إضافية'**
  String get additionalMessage;

  /// No description provided for @addNotesForDistributor.
  ///
  /// In ar, this message translates to:
  /// **'أضف ملاحظات أو رسالة للموزع...'**
  String get addNotesForDistributor;

  /// No description provided for @sending.
  ///
  /// In ar, this message translates to:
  /// **'جاري الإرسال...'**
  String get sending;

  /// No description provided for @pleaseSelectDistributor.
  ///
  /// In ar, this message translates to:
  /// **'يرجى اختيار الموزع'**
  String get pleaseSelectDistributor;

  /// No description provided for @errorSendingOrder.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في إرسال الطلب: {message}'**
  String errorSendingOrder(String message);

  /// No description provided for @employeeCommissions.
  ///
  /// In ar, this message translates to:
  /// **'عمولات الموظفين'**
  String get employeeCommissions;

  /// No description provided for @totalDueCommissions.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي العمولات المستحقة'**
  String get totalDueCommissions;

  /// No description provided for @forEmployees.
  ///
  /// In ar, this message translates to:
  /// **'لـ {count} موظف'**
  String forEmployees(int count);

  /// No description provided for @noCommissions.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عمولات'**
  String get noCommissions;

  /// No description provided for @noSalesInPeriod.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مبيعات في هذه الفترة'**
  String get noSalesInPeriod;

  /// No description provided for @invoicesSales.
  ///
  /// In ar, this message translates to:
  /// **'{count} فاتورة - مبيعات: {amount} ر.س'**
  String invoicesSales(int count, String amount);

  /// No description provided for @commissionLabel.
  ///
  /// In ar, this message translates to:
  /// **'عمولة'**
  String get commissionLabel;

  /// No description provided for @targetLabel.
  ///
  /// In ar, this message translates to:
  /// **'الهدف: {amount} ر.س'**
  String targetLabel(String amount);

  /// No description provided for @achievedPercent.
  ///
  /// In ar, this message translates to:
  /// **'{percent}% مُحقق'**
  String achievedPercent(String percent);

  /// No description provided for @commissionRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة العمولة: {percent}%'**
  String commissionRate(String percent);

  /// No description provided for @priceLists.
  ///
  /// In ar, this message translates to:
  /// **'قوائم الأسعار'**
  String get priceLists;

  /// No description provided for @retailPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر التجزئة'**
  String get retailPrice;

  /// No description provided for @retailPriceDesc.
  ///
  /// In ar, this message translates to:
  /// **'السعر العادي للعملاء الأفراد'**
  String get retailPriceDesc;

  /// No description provided for @wholesalePrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر الجملة'**
  String get wholesalePrice;

  /// No description provided for @wholesalePriceDesc.
  ///
  /// In ar, this message translates to:
  /// **'أسعار مخفضة لكميات كبيرة'**
  String get wholesalePriceDesc;

  /// No description provided for @vipPrice.
  ///
  /// In ar, this message translates to:
  /// **'أسعار VIP'**
  String get vipPrice;

  /// No description provided for @vipPriceDesc.
  ///
  /// In ar, this message translates to:
  /// **'أسعار خاصة للعملاء المميزين'**
  String get vipPriceDesc;

  /// No description provided for @costPriceList.
  ///
  /// In ar, this message translates to:
  /// **'سعر التكلفة'**
  String get costPriceList;

  /// No description provided for @costPriceDesc.
  ///
  /// In ar, this message translates to:
  /// **'للاستخدام الداخلي فقط'**
  String get costPriceDesc;

  /// No description provided for @editPrice.
  ///
  /// In ar, this message translates to:
  /// **'تعديل السعر - {name}'**
  String editPrice(String name);

  /// No description provided for @basePriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعر الأساسي: {price} ر.س'**
  String basePriceLabel(String price);

  /// No description provided for @costPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'سعر التكلفة: {price} ر.س'**
  String costPriceLabel(String price);

  /// No description provided for @newPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعر الجديد ({listName})'**
  String newPriceLabel(String listName);

  /// No description provided for @priceUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث سعر \"{name}\" إلى {price} ر.س'**
  String priceUpdated(String name, String price);

  /// No description provided for @productCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} منتج'**
  String productCount(int count);

  /// No description provided for @baseLabel.
  ///
  /// In ar, this message translates to:
  /// **'أساسي: {price} ر.س'**
  String baseLabel(String price);

  /// No description provided for @errorLoadingHeldInvoices.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل الفواتير المعلقة'**
  String get errorLoadingHeldInvoices;

  /// No description provided for @saleSaveFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل حفظ البيع'**
  String get saleSaveFailed;

  /// No description provided for @errorSavingSaleMessage.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء حفظ عملية البيع. السلة لم تُمسح.\n\n{error}'**
  String errorSavingSaleMessage(String error);

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'حسناً'**
  String get ok;

  /// No description provided for @invoiceNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة على الفاتورة'**
  String get invoiceNote;

  /// No description provided for @addNoteHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف ملاحظة...'**
  String get addNoteHint;

  /// No description provided for @clearNote.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get clearNote;

  /// No description provided for @quickNoteDelivery.
  ///
  /// In ar, this message translates to:
  /// **'توصيل'**
  String get quickNoteDelivery;

  /// No description provided for @quickNoteGiftWrap.
  ///
  /// In ar, this message translates to:
  /// **'تغليف هدية'**
  String get quickNoteGiftWrap;

  /// No description provided for @quickNoteFragile.
  ///
  /// In ar, this message translates to:
  /// **'هش - حساس'**
  String get quickNoteFragile;

  /// No description provided for @quickNoteUrgent.
  ///
  /// In ar, this message translates to:
  /// **'عاجل'**
  String get quickNoteUrgent;

  /// No description provided for @quickNoteReservation.
  ///
  /// In ar, this message translates to:
  /// **'حجز'**
  String get quickNoteReservation;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم الجوال'**
  String get enterPhoneNumber;

  /// No description provided for @whatsappSendError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إرسال واتساب: {error}'**
  String whatsappSendError(String error);

  /// No description provided for @sendReceiptViaWhatsapp.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الفاتورة عبر واتساب'**
  String get sendReceiptViaWhatsapp;

  /// No description provided for @invoiceNumberTitle.
  ///
  /// In ar, this message translates to:
  /// **'رقم الفاتورة'**
  String get invoiceNumberTitle;

  /// No description provided for @amountPaidTitle.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المدفوع'**
  String get amountPaidTitle;

  /// No description provided for @sentLabel.
  ///
  /// In ar, this message translates to:
  /// **'تم الإرسال'**
  String get sentLabel;

  /// No description provided for @newSaleButton.
  ///
  /// In ar, this message translates to:
  /// **'بيع جديدة'**
  String get newSaleButton;

  /// No description provided for @enterValidAmountError.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مبلغ صحيح'**
  String get enterValidAmountError;

  /// No description provided for @amountExceedsMaxError.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ يجب أن لا يتجاوز 999,999.99'**
  String get amountExceedsMaxError;

  /// No description provided for @amountExceedsRemainingError.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ أكبر من المتبقي'**
  String get amountExceedsRemainingError;

  /// No description provided for @amountBetweenZeroAndMax.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ يجب أن يكون بين 0 و 999,999.99'**
  String get amountBetweenZeroAndMax;

  /// No description provided for @amountLessThanTotal.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المستلم أقل من الإجمالي'**
  String get amountLessThanTotal;

  /// No description provided for @selectCustomerFirstError.
  ///
  /// In ar, this message translates to:
  /// **'يجب اختيار العميل أولاً'**
  String get selectCustomerFirstError;

  /// No description provided for @debtLimitExceededError.
  ///
  /// In ar, this message translates to:
  /// **'تم تجاوز حد الدين للعميل'**
  String get debtLimitExceededError;

  /// No description provided for @completePaymentFirstError.
  ///
  /// In ar, this message translates to:
  /// **'أكمل الدفع أولاً'**
  String get completePaymentFirstError;

  /// No description provided for @completePaymentLabel.
  ///
  /// In ar, this message translates to:
  /// **'إتمام الدفع'**
  String get completePaymentLabel;

  /// No description provided for @receivedAmountLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المستلم'**
  String get receivedAmountLabel;

  /// No description provided for @sarPrefix.
  ///
  /// In ar, this message translates to:
  /// **'ر.س '**
  String get sarPrefix;

  /// No description provided for @selectCustomerLabel.
  ///
  /// In ar, this message translates to:
  /// **'اختر العميل'**
  String get selectCustomerLabel;

  /// No description provided for @currentBalanceTitle.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الحالي'**
  String get currentBalanceTitle;

  /// No description provided for @creditLimitTitle.
  ///
  /// In ar, this message translates to:
  /// **'حد الائتمان'**
  String get creditLimitTitle;

  /// No description provided for @creditLimitAmount.
  ///
  /// In ar, this message translates to:
  /// **'500.00 ر.س'**
  String get creditLimitAmount;

  /// No description provided for @debtLimitExceededWarning.
  ///
  /// In ar, this message translates to:
  /// **'تجاوز حد الدين!'**
  String get debtLimitExceededWarning;

  /// No description provided for @selectCustomerFirstButton.
  ///
  /// In ar, this message translates to:
  /// **'اختر العميل أولاً'**
  String get selectCustomerFirstButton;

  /// No description provided for @splitPaymentTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدفع المقسم'**
  String get splitPaymentTitle;

  /// No description provided for @splitPaymentDone.
  ///
  /// In ar, this message translates to:
  /// **'دفع مقسم ✅ ({count} طرق)'**
  String splitPaymentDone(int count);

  /// No description provided for @splitPaymentLabel.
  ///
  /// In ar, this message translates to:
  /// **'دفع مقسم'**
  String get splitPaymentLabel;

  /// No description provided for @addPaymentEntry.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دفعة'**
  String get addPaymentEntry;

  /// No description provided for @confirmSplitPayment.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الدفع'**
  String get confirmSplitPayment;

  /// No description provided for @completePaymentToConfirm.
  ///
  /// In ar, this message translates to:
  /// **'أكمل الدفع أولاً'**
  String get completePaymentToConfirm;

  /// No description provided for @enterValidAmountSplit.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مبلغ صحيح'**
  String get enterValidAmountSplit;

  /// No description provided for @amountExceedsSplit.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ أكبر من المتبقي'**
  String get amountExceedsSplit;

  /// No description provided for @bestSellingPress19.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر مبيعاً (اضغط 1-9)'**
  String get bestSellingPress19;

  /// No description provided for @quickSearchHintFull.
  ///
  /// In ar, this message translates to:
  /// **'بحث سريع (اسم / كود / باركود)...'**
  String get quickSearchHintFull;

  /// No description provided for @noResultsForQuery.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج لـ \"{query}\"'**
  String noResultsForQuery(String query);

  /// No description provided for @addQtyToCart.
  ///
  /// In ar, this message translates to:
  /// **'إضافة {qty} للسلة'**
  String addQtyToCart(int qty);

  /// No description provided for @availableStock.
  ///
  /// In ar, this message translates to:
  /// **'المتوفر: {qty}'**
  String availableStock(String qty);

  /// No description provided for @priceSar.
  ///
  /// In ar, this message translates to:
  /// **'{price} ر.س'**
  String priceSar(String price);

  /// No description provided for @loyaltyPointsDiscountLabel.
  ///
  /// In ar, this message translates to:
  /// **'خصم نقاط الولاء ({points} نقطة)'**
  String loyaltyPointsDiscountLabel(int points);

  /// No description provided for @pointsRedemptionInvoice.
  ///
  /// In ar, this message translates to:
  /// **'استبدال نقاط - فاتورة {id}'**
  String pointsRedemptionInvoice(String id);

  /// No description provided for @pointsEarnedInvoice.
  ///
  /// In ar, this message translates to:
  /// **'نقاط مكتسبة - فاتورة {id}'**
  String pointsEarnedInvoice(String id);

  /// No description provided for @availableLoyaltyPoints.
  ///
  /// In ar, this message translates to:
  /// **'نقاط الولاء المتاحة: {points} نقطة (تساوي {amount} ريال)'**
  String availableLoyaltyPoints(String points, String amount);

  /// No description provided for @useLoyaltyPoints.
  ///
  /// In ar, this message translates to:
  /// **'استخدام نقاط الولاء'**
  String get useLoyaltyPoints;

  /// No description provided for @pointsCountHint.
  ///
  /// In ar, this message translates to:
  /// **'عدد النقاط (الحد الأقصى {max})'**
  String pointsCountHint(String max);

  /// No description provided for @pointsUnitLabel.
  ///
  /// In ar, this message translates to:
  /// **'نقطة'**
  String get pointsUnitLabel;

  /// No description provided for @discountAmountSar.
  ///
  /// In ar, this message translates to:
  /// **'خصم: {amount} ريال'**
  String discountAmountSar(String amount);

  /// No description provided for @allPointsLabel.
  ///
  /// In ar, this message translates to:
  /// **'كل النقاط'**
  String get allPointsLabel;

  /// No description provided for @pointsCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count} نقطة'**
  String pointsCountLabel(String count);

  /// No description provided for @newOrderNotification.
  ///
  /// In ar, this message translates to:
  /// **'طلب جديد #{id}'**
  String newOrderNotification(String id);

  /// No description provided for @onlineOrdersTooltip.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات الأونلاين'**
  String get onlineOrdersTooltip;

  /// No description provided for @productCountItems.
  ///
  /// In ar, this message translates to:
  /// **'{count} منتج'**
  String productCountItems(int count);

  /// No description provided for @acceptAndPrint.
  ///
  /// In ar, this message translates to:
  /// **'قبول وطباعة'**
  String get acceptAndPrint;

  /// No description provided for @deliverToDriver.
  ///
  /// In ar, this message translates to:
  /// **'تسليم للسائق'**
  String get deliverToDriver;

  /// No description provided for @onTheWayStatus.
  ///
  /// In ar, this message translates to:
  /// **'في الطريق'**
  String get onTheWayStatus;

  /// No description provided for @driverNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'السائق: {name}'**
  String driverNameLabel(String name);

  /// No description provided for @deliveredStatus.
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم'**
  String get deliveredStatus;

  /// No description provided for @agoMinutes.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} دقيقة'**
  String agoMinutes(int count);

  /// No description provided for @agoHours.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} ساعة'**
  String agoHours(int count);

  /// No description provided for @moreProductsLabel.
  ///
  /// In ar, this message translates to:
  /// **'+ {count} منتجات أخرى'**
  String moreProductsLabel(int count);

  /// No description provided for @onlineOrdersTitle.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات الأونلاين'**
  String get onlineOrdersTitle;

  /// No description provided for @pendingOrdersCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} طلب بانتظار القبول'**
  String pendingOrdersCount(int count);

  /// No description provided for @inPreparationTab.
  ///
  /// In ar, this message translates to:
  /// **'قيد التجهيز'**
  String get inPreparationTab;

  /// No description provided for @inDeliveryTab.
  ///
  /// In ar, this message translates to:
  /// **'في التوصيل'**
  String get inDeliveryTab;

  /// No description provided for @noOrdersMessage.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات'**
  String get noOrdersMessage;

  /// No description provided for @newOrdersAppearHere.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات الجديدة ستظهر هنا'**
  String get newOrdersAppearHere;

  /// No description provided for @rejectOrderTitle.
  ///
  /// In ar, this message translates to:
  /// **'رفض الطلب'**
  String get rejectOrderTitle;

  /// No description provided for @rejectOrderConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رفض هذا الطلب؟'**
  String get rejectOrderConfirm;

  /// No description provided for @rejectedBySeller.
  ///
  /// In ar, this message translates to:
  /// **'رفض من البائع'**
  String get rejectedBySeller;

  /// No description provided for @printingOrderMessage.
  ///
  /// In ar, this message translates to:
  /// **'طباعة الطلب {id}...'**
  String printingOrderMessage(String id);

  /// No description provided for @selectDriverTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر السائق'**
  String get selectDriverTitle;

  /// No description provided for @orderDeliveredToDriver.
  ///
  /// In ar, this message translates to:
  /// **'تم تسليم الطلب للسائق {name}'**
  String orderDeliveredToDriver(String name);

  /// No description provided for @walkInCustomerLabel.
  ///
  /// In ar, this message translates to:
  /// **'عميل عابر'**
  String get walkInCustomerLabel;

  /// No description provided for @continueWithoutCustomer.
  ///
  /// In ar, this message translates to:
  /// **'متابعة بدون تحديد عميل'**
  String get continueWithoutCustomer;

  /// No description provided for @addNewCustomerButton.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عميل جديد'**
  String get addNewCustomerButton;

  /// No description provided for @loyaltyPointsCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count} نقطة'**
  String loyaltyPointsCountLabel(String count);

  /// No description provided for @customerBalanceAmount.
  ///
  /// In ar, this message translates to:
  /// **'{amount} ر.س'**
  String customerBalanceAmount(String amount);

  /// No description provided for @noResultsFoundTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResultsFoundTitle;

  /// No description provided for @tryAnotherSearch.
  ///
  /// In ar, this message translates to:
  /// **'جرب البحث بكلمة أخرى'**
  String get tryAnotherSearch;

  /// No description provided for @selectCustomerTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختيار عميل'**
  String get selectCustomerTitle;

  /// No description provided for @searchByNameOrPhoneHint.
  ///
  /// In ar, this message translates to:
  /// **'البحث بالاسم أو رقم الهاتف...'**
  String get searchByNameOrPhoneHint;

  /// No description provided for @quickSaleHold.
  ///
  /// In ar, this message translates to:
  /// **'بيع سريع {time}'**
  String quickSaleHold(String time);

  /// No description provided for @holdInvoiceTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعليق الفاتورة'**
  String get holdInvoiceTitle;

  /// No description provided for @holdInvoiceNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم الفاتورة المعلقة'**
  String get holdInvoiceNameLabel;

  /// No description provided for @holdAction.
  ///
  /// In ar, this message translates to:
  /// **'تعليق'**
  String get holdAction;

  /// No description provided for @heldMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم تعليق: {name}'**
  String heldMessage(String name);

  /// No description provided for @holdError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في التعليق: {error}'**
  String holdError(String error);

  /// No description provided for @storeLabel.
  ///
  /// In ar, this message translates to:
  /// **'المتجر'**
  String get storeLabel;

  /// No description provided for @featureNotAvailableNow.
  ///
  /// In ar, this message translates to:
  /// **'هذه الميزة غير متاحة حالياً'**
  String get featureNotAvailableNow;

  /// No description provided for @cancelInvoiceError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء إلغاء الفاتورة'**
  String get cancelInvoiceError;

  /// No description provided for @invoiceLoadError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في تحميل الفاتورة'**
  String get invoiceLoadError;

  /// No description provided for @syncConflicts.
  ///
  /// In ar, this message translates to:
  /// **'تعارضات المزامنة'**
  String get syncConflicts;

  /// No description provided for @itemsNeedReview.
  ///
  /// In ar, this message translates to:
  /// **'{count} عنصر يحتاج مراجعة'**
  String itemsNeedReview(int count);

  /// No description provided for @needsAttention.
  ///
  /// In ar, this message translates to:
  /// **'يحتاج اهتمام'**
  String get needsAttention;

  /// No description provided for @seriousProblems.
  ///
  /// In ar, this message translates to:
  /// **'مشاكل خطيرة'**
  String get seriousProblems;

  /// No description provided for @syncPartialSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تمت مزامنة {success} عنصر، فشل {failed}'**
  String syncPartialSuccess(int success, int failed);

  /// No description provided for @syncErrorMessage.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في المزامنة: {error}'**
  String syncErrorMessage(String error);

  /// No description provided for @networkError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الاتصال بالخادم'**
  String get networkError;

  /// No description provided for @dataLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل تحميل البيانات'**
  String get dataLoadFailed;

  /// No description provided for @unexpectedError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع'**
  String get unexpectedError;

  /// No description provided for @cashierPerformance.
  ///
  /// In ar, this message translates to:
  /// **'أداء الكاشير'**
  String get cashierPerformance;

  /// No description provided for @resetStatsAction.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين'**
  String get resetStatsAction;

  /// No description provided for @statsReset.
  ///
  /// In ar, this message translates to:
  /// **'تم إعادة تعيين الإحصائيات'**
  String get statsReset;

  /// No description provided for @averageSaleTime.
  ///
  /// In ar, this message translates to:
  /// **'متوسط وقت البيع'**
  String get averageSaleTime;

  /// No description provided for @operationsPerHour.
  ///
  /// In ar, this message translates to:
  /// **'عمليات/ساعة'**
  String get operationsPerHour;

  /// No description provided for @errorRateLabel.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الأخطاء'**
  String get errorRateLabel;

  /// No description provided for @completedOperations.
  ///
  /// In ar, this message translates to:
  /// **'عمليات مكتملة'**
  String get completedOperations;

  /// No description provided for @noInternetConnection.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get noInternetConnection;

  /// No description provided for @operationsPendingSync.
  ///
  /// In ar, this message translates to:
  /// **'{count} عملية في انتظار المزامنة'**
  String operationsPendingSync(int count);

  /// No description provided for @connectionRestored.
  ///
  /// In ar, this message translates to:
  /// **'تم استعادة الاتصال'**
  String get connectionRestored;

  /// No description provided for @connectedLabel.
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get connectedLabel;

  /// No description provided for @disconnectedLabel.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get disconnectedLabel;

  /// No description provided for @offlineWithPending.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل - {count} عمليات في الانتظار'**
  String offlineWithPending(int count);

  /// No description provided for @syncingWithCount.
  ///
  /// In ar, this message translates to:
  /// **'جاري المزامنة... ({count} عمليات)'**
  String syncingWithCount(int count);

  /// No description provided for @syncErrorWithCount.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في المزامنة - {count} عمليات معلقة'**
  String syncErrorWithCount(int count);

  /// No description provided for @pendingSyncWithCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} عمليات في انتظار المزامنة'**
  String pendingSyncWithCount(int count);

  /// No description provided for @connectedAllSynced.
  ///
  /// In ar, this message translates to:
  /// **'متصل - كل البيانات مزامنة'**
  String get connectedAllSynced;

  /// No description provided for @dataSavedLocally.
  ///
  /// In ar, this message translates to:
  /// **'البيانات محفوظة محلياً وستتم مزامنتها عند الاتصال'**
  String get dataSavedLocally;

  /// No description provided for @uploadingData.
  ///
  /// In ar, this message translates to:
  /// **'يتم رفع البيانات إلى السيرفر...'**
  String get uploadingData;

  /// No description provided for @errorWillRetry.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ، ستتم إعادة المحاولة تلقائياً'**
  String get errorWillRetry;

  /// No description provided for @syncSoon.
  ///
  /// In ar, this message translates to:
  /// **'ستتم المزامنة خلال ثوان'**
  String get syncSoon;

  /// No description provided for @allDataSynced.
  ///
  /// In ar, this message translates to:
  /// **'كل البيانات محدثة ومزامنة'**
  String get allDataSynced;

  /// No description provided for @cashierMode.
  ///
  /// In ar, this message translates to:
  /// **'وضع الكاشير'**
  String get cashierMode;

  /// No description provided for @collapseMenu.
  ///
  /// In ar, this message translates to:
  /// **'طي القائمة'**
  String get collapseMenu;

  /// No description provided for @expandMenu.
  ///
  /// In ar, this message translates to:
  /// **'توسيع القائمة'**
  String get expandMenu;

  /// No description provided for @screenLoadError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء تحميل الشاشة'**
  String get screenLoadError;

  /// No description provided for @screenLoadTimeout.
  ///
  /// In ar, this message translates to:
  /// **'تجاوز وقت تحميل الشاشة'**
  String get screenLoadTimeout;

  /// No description provided for @timeoutCheckConnection.
  ///
  /// In ar, this message translates to:
  /// **'انتهى وقت الانتظار. تحقق من اتصالك بالإنترنت.'**
  String get timeoutCheckConnection;

  /// No description provided for @retryLaterMessage.
  ///
  /// In ar, this message translates to:
  /// **'يرجى المحاولة مرة أخرى لاحقاً.'**
  String get retryLaterMessage;

  /// No description provided for @howWasOperation.
  ///
  /// In ar, this message translates to:
  /// **'كيف كانت هذه العملية؟'**
  String get howWasOperation;

  /// No description provided for @fastLabel.
  ///
  /// In ar, this message translates to:
  /// **'سريعة ✓'**
  String get fastLabel;

  /// No description provided for @whatToImprove.
  ///
  /// In ar, this message translates to:
  /// **'ما الذي يمكن تحسينه؟'**
  String get whatToImprove;

  /// No description provided for @helpUsImprove.
  ///
  /// In ar, this message translates to:
  /// **'مساعدتك تفيدنا في تحسين التطبيق'**
  String get helpUsImprove;

  /// No description provided for @writeNoteOptional.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ملاحظتك (اختياري)...'**
  String get writeNoteOptional;

  /// No description provided for @thanksFeedback.
  ///
  /// In ar, this message translates to:
  /// **'شكراً لتقييمك! 👍'**
  String get thanksFeedback;

  /// No description provided for @thanksWillImprove.
  ///
  /// In ar, this message translates to:
  /// **'شكراً! سنعمل على التحسين 🙏'**
  String get thanksWillImprove;

  /// No description provided for @noRatingsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تقييمات بعد'**
  String get noRatingsYet;

  /// No description provided for @customerRatings.
  ///
  /// In ar, this message translates to:
  /// **'تقييمات العملاء'**
  String get customerRatings;

  /// No description provided for @fastOperations.
  ///
  /// In ar, this message translates to:
  /// **'عمليات سريعة'**
  String get fastOperations;

  /// No description provided for @averageRating.
  ///
  /// In ar, this message translates to:
  /// **'متوسط التقييم'**
  String get averageRating;

  /// No description provided for @totalRatings.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي التقييمات'**
  String get totalRatings;

  /// No description provided for @undoCompleted.
  ///
  /// In ar, this message translates to:
  /// **'تم التراجع: {description}'**
  String undoCompleted(String description);

  /// No description provided for @payables.
  ///
  /// In ar, this message translates to:
  /// **'المستحقات'**
  String get payables;

  /// No description provided for @notAvailableLabel.
  ///
  /// In ar, this message translates to:
  /// **'غير متاح'**
  String get notAvailableLabel;

  /// No description provided for @browseSupplierCatalogNotAvailable.
  ///
  /// In ar, this message translates to:
  /// **'تصفح كتالوج الموردين - هذه الميزة غير متاحة حالياً'**
  String get browseSupplierCatalogNotAvailable;

  /// No description provided for @selectedSuffix.
  ///
  /// In ar, this message translates to:
  /// **'، محدد'**
  String get selectedSuffix;

  /// No description provided for @disabledSuffix.
  ///
  /// In ar, this message translates to:
  /// **'، معطل'**
  String get disabledSuffix;

  /// No description provided for @doubleTapToToggle.
  ///
  /// In ar, this message translates to:
  /// **'انقر مرتين لتغيير الحالة'**
  String get doubleTapToToggle;

  /// No description provided for @loadingPleaseWait.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loadingPleaseWait;

  /// No description provided for @posSystemLabel.
  ///
  /// In ar, this message translates to:
  /// **'نظام نقطة البيع'**
  String get posSystemLabel;

  /// No description provided for @pageNotFoundTitle.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get pageNotFoundTitle;

  /// No description provided for @pageNotFoundMessage.
  ///
  /// In ar, this message translates to:
  /// **'الصفحة غير موجودة: {path}'**
  String pageNotFoundMessage(String path);

  /// No description provided for @noShipmentsToReceive.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد شحنات للاستلام'**
  String get noShipmentsToReceive;

  /// No description provided for @approvedOrdersAppearHere.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر هنا الطلبات المعتمدة الجاهزة للاستلام'**
  String get approvedOrdersAppearHere;

  /// No description provided for @unspecifiedSupplier.
  ///
  /// In ar, this message translates to:
  /// **'مورد غير محدد'**
  String get unspecifiedSupplier;

  /// No description provided for @viewItems.
  ///
  /// In ar, this message translates to:
  /// **'عرض البنود'**
  String get viewItems;

  /// No description provided for @receivingInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الاستلام...'**
  String get receivingInProgress;

  /// No description provided for @confirmReceivingBtn.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الاستلام'**
  String get confirmReceivingBtn;

  /// No description provided for @orderItemsTitle.
  ///
  /// In ar, this message translates to:
  /// **'بنود الطلب {number}'**
  String orderItemsTitle(String number);

  /// No description provided for @noOrderItems.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بنود'**
  String get noOrderItems;

  /// No description provided for @confirmReceiveGoodsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد استلام البضاعة'**
  String get confirmReceiveGoodsTitle;

  /// No description provided for @confirmReceiveGoodsBody.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من استلام الطلب {number}؟\nسيتم تحديث المخزون تلقائياً.'**
  String confirmReceiveGoodsBody(String number);

  /// No description provided for @orderReceivedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم استلام الطلب {number} بنجاح'**
  String orderReceivedSuccess(String number);

  /// No description provided for @quickPurchaseRequest.
  ///
  /// In ar, this message translates to:
  /// **'طلب شراء سريع'**
  String get quickPurchaseRequest;

  /// No description provided for @searchAndAddProducts.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن منتجات وأضفها للطلب'**
  String get searchAndAddProducts;

  /// No description provided for @requestedProducts.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات المطلوبة'**
  String get requestedProducts;

  /// No description provided for @productCountSummary.
  ///
  /// In ar, this message translates to:
  /// **'عدد المنتجات'**
  String get productCountSummary;

  /// No description provided for @totalQuantitySummary.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الكمية'**
  String get totalQuantitySummary;

  /// No description provided for @addNotesForManager.
  ///
  /// In ar, this message translates to:
  /// **'أضف ملاحظات للمدير (اختياري)...'**
  String get addNotesForManager;

  /// No description provided for @sendRequestBtn.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الطلب'**
  String get sendRequestBtn;

  /// No description provided for @validQuantityRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال كمية صحيحة لجميع المنتجات'**
  String get validQuantityRequired;

  /// No description provided for @requestSentToManager.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الطلب للمدير'**
  String get requestSentToManager;

  /// No description provided for @connectionSuccessMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم الاتصال بنجاح'**
  String get connectionSuccessMsg;

  /// No description provided for @connectionFailedMsgErr.
  ///
  /// In ar, this message translates to:
  /// **'فشل الاتصال: {error}'**
  String connectionFailedMsgErr(String error);

  /// No description provided for @deviceSavedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الجهاز'**
  String get deviceSavedMsg;

  /// No description provided for @saveErrorMsg.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في حفظ الإعدادات: {error}'**
  String saveErrorMsg(String error);

  /// No description provided for @addPaymentDeviceTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة جهاز دفع'**
  String get addPaymentDeviceTitle;

  /// No description provided for @setupNewDeviceSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إعداد جهاز جديد'**
  String get setupNewDeviceSubtitle;

  /// No description provided for @quickAccessKeysSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مفاتيح الوصول السريع'**
  String get quickAccessKeysSubtitle;

  /// No description provided for @devicesAddedCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} أجهزة مضافة'**
  String devicesAddedCount(int count);

  /// No description provided for @managePreferencesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة التفضيلات'**
  String get managePreferencesSubtitle;

  /// No description provided for @storeNameAddressLogo.
  ///
  /// In ar, this message translates to:
  /// **'الاسم، العنوان والشعار'**
  String get storeNameAddressLogo;

  /// No description provided for @receiptHeaderFooterLogo.
  ///
  /// In ar, this message translates to:
  /// **'رأس وتذييل الفاتورة والشعار'**
  String get receiptHeaderFooterLogo;

  /// No description provided for @posPaymentNavSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'نقطة البيع، الدفع والتنقل'**
  String get posPaymentNavSubtitle;

  /// No description provided for @usersAndPermissions.
  ///
  /// In ar, this message translates to:
  /// **'المستخدمين والصلاحيات'**
  String get usersAndPermissions;

  /// No description provided for @rolesAndAccess.
  ///
  /// In ar, this message translates to:
  /// **'الأدوار والوصول'**
  String get rolesAndAccess;

  /// No description provided for @backupAutoRestore.
  ///
  /// In ar, this message translates to:
  /// **'نسخ احتياطي واستعادة تلقائية'**
  String get backupAutoRestore;

  /// No description provided for @privacyAndDataRights.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية وحقوق البيانات'**
  String get privacyAndDataRights;

  /// No description provided for @arabicEnglish.
  ///
  /// In ar, this message translates to:
  /// **'عربي/إنجليزي'**
  String get arabicEnglish;

  /// No description provided for @darkLightMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن/الفاتح'**
  String get darkLightMode;

  /// No description provided for @clearCacheTitle.
  ///
  /// In ar, this message translates to:
  /// **'مسح الذاكرة المؤقتة'**
  String get clearCacheTitle;

  /// No description provided for @clearCacheSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'حل مشاكل التحميل والبيانات'**
  String get clearCacheSubtitle;

  /// No description provided for @clearCacheDialogBody.
  ///
  /// In ar, this message translates to:
  /// **'سيتم مسح جميع البيانات المؤقتة وإعادة تحميلها من السيرفر.\n\nسيتم تسجيل خروجك وإعادة تشغيل التطبيق.\n\nهل تريد المتابعة؟'**
  String get clearCacheDialogBody;

  /// No description provided for @clearAndRestart.
  ///
  /// In ar, this message translates to:
  /// **'مسح وإعادة التشغيل'**
  String get clearAndRestart;

  /// No description provided for @clearingCacheProgress.
  ///
  /// In ar, this message translates to:
  /// **'جاري مسح الذاكرة المؤقتة...'**
  String get clearingCacheProgress;

  /// No description provided for @printerInitFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل تهيئة خدمة الطباعة'**
  String get printerInitFailed;

  /// No description provided for @noPrintersFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على طابعات'**
  String get noPrintersFound;

  /// No description provided for @searchErrorMsg.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في البحث: {error}'**
  String searchErrorMsg(String error);

  /// No description provided for @connectedToPrinterName.
  ///
  /// In ar, this message translates to:
  /// **'تم الاتصال بـ {name}'**
  String connectedToPrinterName(String name);

  /// No description provided for @connectionFailedToPrinter.
  ///
  /// In ar, this message translates to:
  /// **'فشل الاتصال بـ {name}'**
  String connectionFailedToPrinter(String name);

  /// No description provided for @enterPrinterIpAddress.
  ///
  /// In ar, this message translates to:
  /// **'أدخل عنوان IP للطابعة'**
  String get enterPrinterIpAddress;

  /// No description provided for @printerNotConnectedMsg.
  ///
  /// In ar, this message translates to:
  /// **'الطابعة غير متصلة'**
  String get printerNotConnectedMsg;

  /// No description provided for @testPageSentSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال صفحة الاختبار بنجاح'**
  String get testPageSentSuccess;

  /// No description provided for @testFailedMsg.
  ///
  /// In ar, this message translates to:
  /// **'فشل الاختبار: {error}'**
  String testFailedMsg(String error);

  /// No description provided for @errorMsgGeneric.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: {error}'**
  String errorMsgGeneric(String error);

  /// No description provided for @cashDrawerOpened.
  ///
  /// In ar, this message translates to:
  /// **'تم فتح درج النقود'**
  String get cashDrawerOpened;

  /// No description provided for @cashDrawerFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل: {error}'**
  String cashDrawerFailed(String error);

  /// No description provided for @disconnectedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم قطع الاتصال'**
  String get disconnectedMsg;

  /// No description provided for @connectedPrinterStatus.
  ///
  /// In ar, this message translates to:
  /// **'متصل: {name}'**
  String connectedPrinterStatus(String name);

  /// No description provided for @notConnectedStatus.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get notConnectedStatus;

  /// No description provided for @connectedToPrinterMsg.
  ///
  /// In ar, this message translates to:
  /// **'متصل بالطابعة'**
  String get connectedToPrinterMsg;

  /// No description provided for @noPrinterConnectedMsg.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طابعة متصلة'**
  String get noPrinterConnectedMsg;

  /// No description provided for @openDrawerBtn.
  ///
  /// In ar, this message translates to:
  /// **'فتح الدرج'**
  String get openDrawerBtn;

  /// No description provided for @disconnectBtn.
  ///
  /// In ar, this message translates to:
  /// **'قطع'**
  String get disconnectBtn;

  /// No description provided for @connectPrinterTitle.
  ///
  /// In ar, this message translates to:
  /// **'اتصال بطابعة'**
  String get connectPrinterTitle;

  /// No description provided for @connectionTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع الاتصال'**
  String get connectionTypeLabel;

  /// No description provided for @bluetoothLabel.
  ///
  /// In ar, this message translates to:
  /// **'بلوتوث'**
  String get bluetoothLabel;

  /// No description provided for @networkLabel.
  ///
  /// In ar, this message translates to:
  /// **'شبكة'**
  String get networkLabel;

  /// No description provided for @printerIpAddressLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان IP للطابعة'**
  String get printerIpAddressLabel;

  /// No description provided for @connectBtn.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get connectBtn;

  /// No description provided for @searchingPrintersLabel.
  ///
  /// In ar, this message translates to:
  /// **'جاري البحث...'**
  String get searchingPrintersLabel;

  /// No description provided for @searchPrintersBtn.
  ///
  /// In ar, this message translates to:
  /// **'بحث عن طابعات'**
  String get searchPrintersBtn;

  /// No description provided for @discoveredPrintersTitle.
  ///
  /// In ar, this message translates to:
  /// **'الطابعات المكتشفة ({count})'**
  String discoveredPrintersTitle(int count);

  /// No description provided for @connectedBadge.
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get connectedBadge;

  /// No description provided for @printSettingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الطباعة'**
  String get printSettingsTitle;

  /// No description provided for @autoPrintTitle.
  ///
  /// In ar, this message translates to:
  /// **'طباعة تلقائية'**
  String get autoPrintTitle;

  /// No description provided for @autoPrintSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'طباعة الفاتورة تلقائياً بعد كل عملية بيع'**
  String get autoPrintSubtitle;

  /// No description provided for @paperSizeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'عرض ورق الطباعة الحرارية'**
  String get paperSizeSubtitle;

  /// No description provided for @customizeReceiptSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تخصيص الإيصال'**
  String get customizeReceiptSubtitle;

  /// No description provided for @viewStoreDetailsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'عرض تفاصيل المتجر'**
  String get viewStoreDetailsSubtitle;

  /// No description provided for @usersAndPermissionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المستخدمين والصلاحيات'**
  String get usersAndPermissionsTitle;

  /// No description provided for @usersCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count} مستخدم'**
  String usersCountLabel(int count);

  /// No description provided for @noPrinterSetup.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم إعداد طابعة'**
  String get noPrinterSetup;

  /// No description provided for @printerNotConnectedErr.
  ///
  /// In ar, this message translates to:
  /// **'الطابعة غير متصلة'**
  String get printerNotConnectedErr;

  /// No description provided for @transactionRecordedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل المعاملة بنجاح'**
  String get transactionRecordedSuccess;

  /// No description provided for @productSearchFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل البحث عن المنتج: {error}'**
  String productSearchFailed(String error);

  /// No description provided for @customerSearchFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل البحث عن العميل: {error}'**
  String customerSearchFailed(String error);

  /// No description provided for @inventoryUpdatedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث المخزون'**
  String get inventoryUpdatedMsg;

  /// No description provided for @scanOrEnterBarcode.
  ///
  /// In ar, this message translates to:
  /// **'امسح أو أدخل الباركود'**
  String get scanOrEnterBarcode;

  /// No description provided for @priceUpdatedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث السعر'**
  String get priceUpdatedMsg;

  /// No description provided for @exchangeSuccessMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم الاستبدال بنجاح'**
  String get exchangeSuccessMsg;

  /// No description provided for @refundProcessedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تمت معالجة الاسترجاع بنجاح'**
  String get refundProcessedSuccess;

  /// No description provided for @backupCompletedTitle.
  ///
  /// In ar, this message translates to:
  /// **'اكتمل النسخ الاحتياطي'**
  String get backupCompletedTitle;

  /// No description provided for @backupCompletedBody.
  ///
  /// In ar, this message translates to:
  /// **'اكتمل النسخ الاحتياطي — {rows} صف، {size} ميجابايت'**
  String backupCompletedBody(int rows, String size);

  /// No description provided for @backupFailedMsg.
  ///
  /// In ar, this message translates to:
  /// **'فشل النسخ الاحتياطي: {error}'**
  String backupFailedMsg(String error);

  /// No description provided for @copyBackupInstructions.
  ///
  /// In ar, this message translates to:
  /// **'انسخ بيانات النسخ الاحتياطي للحافظة لحفظها أو مشاركتها.'**
  String get copyBackupInstructions;

  /// No description provided for @closeBtn.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get closeBtn;

  /// No description provided for @backupCopiedToClipboard.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ النسخة الاحتياطية للحافظة'**
  String get backupCopiedToClipboard;

  /// No description provided for @copyToClipboardBtn.
  ///
  /// In ar, this message translates to:
  /// **'نسخ للحافظة'**
  String get copyToClipboardBtn;

  /// No description provided for @countDenominationsBtn.
  ///
  /// In ar, this message translates to:
  /// **'عد العملات بالفئات'**
  String get countDenominationsBtn;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية وحقوق البيانات'**
  String get privacyPolicySubtitle;

  /// No description provided for @privacyIntroTitle.
  ///
  /// In ar, this message translates to:
  /// **'مقدمة'**
  String get privacyIntroTitle;

  /// No description provided for @privacyIntroBody.
  ///
  /// In ar, this message translates to:
  /// **'نحن في الحي نلتزم بحماية خصوصيتك وبياناتك الشخصية. توضح هذه السياسة كيف نجمع ونستخدم ونحمي بياناتك عند استخدام تطبيق نقطة البيع.'**
  String get privacyIntroBody;

  /// No description provided for @privacyLastUpdated.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث: مارس 2026'**
  String get privacyLastUpdated;

  /// No description provided for @privacyDataCollectedTitle.
  ///
  /// In ar, this message translates to:
  /// **'البيانات التي نجمعها'**
  String get privacyDataCollectedTitle;

  /// No description provided for @privacyStoreData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات المتجر: اسم المتجر، العنوان، الرقم الضريبي، الشعار.'**
  String get privacyStoreData;

  /// No description provided for @privacyProductData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات المنتجات: أسماء المنتجات، الأسعار، الباركود، المخزون.'**
  String get privacyProductData;

  /// No description provided for @privacySalesData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات المبيعات: الفواتير، طرق الدفع، المبالغ، التاريخ والوقت.'**
  String get privacySalesData;

  /// No description provided for @privacyCustomerData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات العملاء: الاسم، رقم الهاتف، البريد الإلكتروني (اختياري)، سجل المشتريات.'**
  String get privacyCustomerData;

  /// No description provided for @privacyEmployeeData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الموظفين: اسم المستخدم، الدور، سجل الورديات.'**
  String get privacyEmployeeData;

  /// No description provided for @privacyDeviceData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الجهاز: نوع الجهاز، نظام التشغيل (لأغراض الدعم الفني فقط).'**
  String get privacyDeviceData;

  /// No description provided for @privacyHowWeUseTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيف نستخدم بياناتك'**
  String get privacyHowWeUseTitle;

  /// No description provided for @privacyUsePOS.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل نظام نقطة البيع ومعالجة المبيعات والمدفوعات.'**
  String get privacyUsePOS;

  /// No description provided for @privacyUseReports.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء التقارير والإحصائيات لمساعدتك في إدارة متجرك.'**
  String get privacyUseReports;

  /// No description provided for @privacyUseAccounts.
  ///
  /// In ar, this message translates to:
  /// **'إدارة حسابات العملاء والديون والولاء.'**
  String get privacyUseAccounts;

  /// No description provided for @privacyUseInventory.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المخزون وتتبع المنتجات.'**
  String get privacyUseInventory;

  /// No description provided for @privacyUseBackup.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي واستعادة البيانات.'**
  String get privacyUseBackup;

  /// No description provided for @privacyUsePerformance.
  ///
  /// In ar, this message translates to:
  /// **'تحسين أداء التطبيق وإصلاح الأخطاء.'**
  String get privacyUsePerformance;

  /// No description provided for @privacyNoSellData.
  ///
  /// In ar, this message translates to:
  /// **'لا نبيع بياناتك لأطراف ثالثة. لا نستخدم بياناتك لأغراض إعلانية.'**
  String get privacyNoSellData;

  /// No description provided for @privacyProtectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيف نحمي بياناتك'**
  String get privacyProtectionTitle;

  /// No description provided for @privacyLocalStorage.
  ///
  /// In ar, this message translates to:
  /// **'التخزين المحلي: جميع بيانات المبيعات والعملاء تُخزن محلياً على جهازك.'**
  String get privacyLocalStorage;

  /// No description provided for @privacyEncryption.
  ///
  /// In ar, this message translates to:
  /// **'التشفير: البيانات الحساسة مشفرة باستخدام تقنيات التشفير الحديثة.'**
  String get privacyEncryption;

  /// No description provided for @privacyBackupProtection.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي: يمكنك إنشاء نسخ احتياطية مشفرة من بياناتك.'**
  String get privacyBackupProtection;

  /// No description provided for @privacyAuthentication.
  ///
  /// In ar, this message translates to:
  /// **'المصادقة: الوصول محمي بكلمة مرور وصلاحيات المستخدمين.'**
  String get privacyAuthentication;

  /// No description provided for @privacyOffline.
  ///
  /// In ar, this message translates to:
  /// **'العمل بدون إنترنت: التطبيق يعمل 100% بدون اتصال، بياناتك لا تُرسل لخوادم خارجية.'**
  String get privacyOffline;

  /// No description provided for @privacyRightsTitle.
  ///
  /// In ar, this message translates to:
  /// **'حقوقك'**
  String get privacyRightsTitle;

  /// No description provided for @privacyRightAccess.
  ///
  /// In ar, this message translates to:
  /// **'حق الوصول'**
  String get privacyRightAccess;

  /// No description provided for @privacyRightAccessDesc.
  ///
  /// In ar, this message translates to:
  /// **'يحق لك الاطلاع على جميع بياناتك المخزنة في التطبيق في أي وقت.'**
  String get privacyRightAccessDesc;

  /// No description provided for @privacyRightCorrection.
  ///
  /// In ar, this message translates to:
  /// **'حق التصحيح'**
  String get privacyRightCorrection;

  /// No description provided for @privacyRightCorrectionDesc.
  ///
  /// In ar, this message translates to:
  /// **'يحق لك تعديل أو تصحيح أي بيانات غير دقيقة.'**
  String get privacyRightCorrectionDesc;

  /// No description provided for @privacyRightDeletion.
  ///
  /// In ar, this message translates to:
  /// **'حق الحذف'**
  String get privacyRightDeletion;

  /// No description provided for @privacyRightDeletionDesc.
  ///
  /// In ar, this message translates to:
  /// **'يحق لك طلب حذف بياناتك الشخصية. يمكنك حذف بيانات العملاء من شاشة إدارة العملاء.'**
  String get privacyRightDeletionDesc;

  /// No description provided for @privacyRightExport.
  ///
  /// In ar, this message translates to:
  /// **'حق التصدير'**
  String get privacyRightExport;

  /// No description provided for @privacyRightExportDesc.
  ///
  /// In ar, this message translates to:
  /// **'يحق لك تصدير نسخة من بياناتك بصيغة JSON.'**
  String get privacyRightExportDesc;

  /// No description provided for @privacyRightWithdrawal.
  ///
  /// In ar, this message translates to:
  /// **'حق الإلغاء'**
  String get privacyRightWithdrawal;

  /// No description provided for @privacyRightWithdrawalDesc.
  ///
  /// In ar, this message translates to:
  /// **'يحق لك إلغاء أي موافقة سابقة على معالجة بياناتك.'**
  String get privacyRightWithdrawalDesc;

  /// No description provided for @privacyDataDeletionTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف البيانات'**
  String get privacyDataDeletionTitle;

  /// No description provided for @privacyDataDeletionIntro.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك حذف بيانات العملاء من خلال إعدادات التطبيق. عند حذف بيانات عميل:'**
  String get privacyDataDeletionIntro;

  /// No description provided for @privacyDataDeletionPersonal.
  ///
  /// In ar, this message translates to:
  /// **'يتم حذف المعلومات الشخصية (الاسم، الهاتف، البريد) بشكل نهائي.'**
  String get privacyDataDeletionPersonal;

  /// No description provided for @privacyDataDeletionAnonymize.
  ///
  /// In ar, this message translates to:
  /// **'يتم إخفاء هوية العميل في سجلات المبيعات السابقة (تظهر كـ \"عميل محذوف\").'**
  String get privacyDataDeletionAnonymize;

  /// No description provided for @privacyDataDeletionAccounts.
  ///
  /// In ar, this message translates to:
  /// **'يتم حذف حسابات الديون والعناوين المرتبطة.'**
  String get privacyDataDeletionAccounts;

  /// No description provided for @privacyDataDeletionWarning.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة: لا يمكن التراجع عن حذف البيانات بعد تنفيذه.'**
  String get privacyDataDeletionWarning;

  /// No description provided for @privacyContactTitle.
  ///
  /// In ar, this message translates to:
  /// **'التواصل معنا'**
  String get privacyContactTitle;

  /// No description provided for @privacyContactIntro.
  ///
  /// In ar, this message translates to:
  /// **'إذا كان لديك أي أسئلة حول سياسة الخصوصية أو ترغب في ممارسة حقوقك، يمكنك التواصل معنا عبر:'**
  String get privacyContactIntro;

  /// No description provided for @privacyContactEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني: privacy@alhai.app'**
  String get privacyContactEmail;

  /// No description provided for @privacyContactSupport.
  ///
  /// In ar, this message translates to:
  /// **'الدعم الفني داخل التطبيق'**
  String get privacyContactSupport;

  /// No description provided for @onboardingPrivacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية | Privacy Policy'**
  String get onboardingPrivacyPolicy;

  /// No description provided for @cashierDefaultName.
  ///
  /// In ar, this message translates to:
  /// **'كاشير'**
  String get cashierDefaultName;

  /// No description provided for @defaultAddress.
  ///
  /// In ar, this message translates to:
  /// **'الرياض - المملكة العربية السعودية'**
  String get defaultAddress;

  /// No description provided for @loadMoreBtn.
  ///
  /// In ar, this message translates to:
  /// **'تحميل المزيد'**
  String get loadMoreBtn;

  /// No description provided for @countCurrencyBtn.
  ///
  /// In ar, this message translates to:
  /// **'عد العملات'**
  String get countCurrencyBtn;

  /// No description provided for @searchLogsHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث في السجلات...'**
  String get searchLogsHint;

  /// No description provided for @noSearchResultsForQuery.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج للبحث'**
  String get noSearchResultsForQuery;

  /// No description provided for @noLogsToDisplay.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سجلات للعرض'**
  String get noLogsToDisplay;

  /// No description provided for @auditActionLogin.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل دخول'**
  String get auditActionLogin;

  /// No description provided for @auditActionLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل خروج'**
  String get auditActionLogout;

  /// No description provided for @auditActionSale.
  ///
  /// In ar, this message translates to:
  /// **'بيع'**
  String get auditActionSale;

  /// No description provided for @auditActionCancelSale.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء بيع'**
  String get auditActionCancelSale;

  /// No description provided for @auditActionRefund.
  ///
  /// In ar, this message translates to:
  /// **'استرجاع'**
  String get auditActionRefund;

  /// No description provided for @auditActionAddProduct.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منتج'**
  String get auditActionAddProduct;

  /// No description provided for @auditActionEditProduct.
  ///
  /// In ar, this message translates to:
  /// **'تعديل منتج'**
  String get auditActionEditProduct;

  /// No description provided for @auditActionDeleteProduct.
  ///
  /// In ar, this message translates to:
  /// **'حذف منتج'**
  String get auditActionDeleteProduct;

  /// No description provided for @auditActionPriceChange.
  ///
  /// In ar, this message translates to:
  /// **'تغيير سعر'**
  String get auditActionPriceChange;

  /// No description provided for @auditActionStockAdjust.
  ///
  /// In ar, this message translates to:
  /// **'تعديل مخزون'**
  String get auditActionStockAdjust;

  /// No description provided for @auditActionStockReceive.
  ///
  /// In ar, this message translates to:
  /// **'استلام مخزون'**
  String get auditActionStockReceive;

  /// No description provided for @auditActionOpenShift.
  ///
  /// In ar, this message translates to:
  /// **'فتح وردية'**
  String get auditActionOpenShift;

  /// No description provided for @auditActionCloseShift.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق وردية'**
  String get auditActionCloseShift;

  /// No description provided for @auditActionSettingsChange.
  ///
  /// In ar, this message translates to:
  /// **'تغيير إعدادات'**
  String get auditActionSettingsChange;

  /// No description provided for @auditActionCashDrawer.
  ///
  /// In ar, this message translates to:
  /// **'درج النقد'**
  String get auditActionCashDrawer;

  /// No description provided for @permCategoryPosLabel.
  ///
  /// In ar, this message translates to:
  /// **'نقطة البيع'**
  String get permCategoryPosLabel;

  /// No description provided for @permCategoryProductsLabel.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get permCategoryProductsLabel;

  /// No description provided for @permCategoryInventoryLabel.
  ///
  /// In ar, this message translates to:
  /// **'المخزون'**
  String get permCategoryInventoryLabel;

  /// No description provided for @permCategoryCustomersLabel.
  ///
  /// In ar, this message translates to:
  /// **'العملاء'**
  String get permCategoryCustomersLabel;

  /// No description provided for @permCategorySalesLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات'**
  String get permCategorySalesLabel;

  /// No description provided for @permCategoryReportsLabel.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get permCategoryReportsLabel;

  /// No description provided for @permCategorySettingsLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get permCategorySettingsLabel;

  /// No description provided for @permCategoryStaffLabel.
  ///
  /// In ar, this message translates to:
  /// **'الموظفين'**
  String get permCategoryStaffLabel;

  /// No description provided for @permPosAccess.
  ///
  /// In ar, this message translates to:
  /// **'الوصول لنقطة البيع'**
  String get permPosAccess;

  /// No description provided for @permPosAccessDesc.
  ///
  /// In ar, this message translates to:
  /// **'الوصول إلى شاشة نقطة البيع'**
  String get permPosAccessDesc;

  /// No description provided for @permPosHold.
  ///
  /// In ar, this message translates to:
  /// **'تعليق الفواتير'**
  String get permPosHold;

  /// No description provided for @permPosHoldDesc.
  ///
  /// In ar, this message translates to:
  /// **'تعليق الفواتير واستكمالها لاحقاً'**
  String get permPosHoldDesc;

  /// No description provided for @permPosSplitPayment.
  ///
  /// In ar, this message translates to:
  /// **'تقسيم الدفع'**
  String get permPosSplitPayment;

  /// No description provided for @permPosSplitPaymentDesc.
  ///
  /// In ar, this message translates to:
  /// **'تقسيم الدفع بين طرق مختلفة'**
  String get permPosSplitPaymentDesc;

  /// No description provided for @permProductsView.
  ///
  /// In ar, this message translates to:
  /// **'عرض المنتجات'**
  String get permProductsView;

  /// No description provided for @permProductsViewDesc.
  ///
  /// In ar, this message translates to:
  /// **'عرض قائمة المنتجات وتفاصيلها'**
  String get permProductsViewDesc;

  /// No description provided for @permProductsManage.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المنتجات'**
  String get permProductsManage;

  /// No description provided for @permProductsManageDesc.
  ///
  /// In ar, this message translates to:
  /// **'إضافة وتعديل المنتجات'**
  String get permProductsManageDesc;

  /// No description provided for @permProductsDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف المنتجات'**
  String get permProductsDelete;

  /// No description provided for @permProductsDeleteDesc.
  ///
  /// In ar, this message translates to:
  /// **'حذف المنتجات من النظام'**
  String get permProductsDeleteDesc;

  /// No description provided for @permInventoryView.
  ///
  /// In ar, this message translates to:
  /// **'عرض المخزون'**
  String get permInventoryView;

  /// No description provided for @permInventoryViewDesc.
  ///
  /// In ar, this message translates to:
  /// **'عرض كميات المخزون'**
  String get permInventoryViewDesc;

  /// No description provided for @permInventoryManage.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المخزون'**
  String get permInventoryManage;

  /// No description provided for @permInventoryManageDesc.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المخزون والنقل'**
  String get permInventoryManageDesc;

  /// No description provided for @permInventoryAdjust.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المخزون'**
  String get permInventoryAdjust;

  /// No description provided for @permInventoryAdjustDesc.
  ///
  /// In ar, this message translates to:
  /// **'تعديل كميات المخزون يدوياً'**
  String get permInventoryAdjustDesc;

  /// No description provided for @permCustomersView.
  ///
  /// In ar, this message translates to:
  /// **'عرض العملاء'**
  String get permCustomersView;

  /// No description provided for @permCustomersViewDesc.
  ///
  /// In ar, this message translates to:
  /// **'عرض بيانات العملاء'**
  String get permCustomersViewDesc;

  /// No description provided for @permCustomersManage.
  ///
  /// In ar, this message translates to:
  /// **'إدارة العملاء'**
  String get permCustomersManage;

  /// No description provided for @permCustomersManageDesc.
  ///
  /// In ar, this message translates to:
  /// **'إضافة وتعديل العملاء'**
  String get permCustomersManageDesc;

  /// No description provided for @permCustomersDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف العملاء'**
  String get permCustomersDelete;

  /// No description provided for @permCustomersDeleteDesc.
  ///
  /// In ar, this message translates to:
  /// **'حذف العملاء من النظام'**
  String get permCustomersDeleteDesc;

  /// No description provided for @permDiscountsApply.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق الخصومات'**
  String get permDiscountsApply;

  /// No description provided for @permDiscountsApplyDesc.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق خصومات موجودة'**
  String get permDiscountsApplyDesc;

  /// No description provided for @permDiscountsCreate.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الخصومات'**
  String get permDiscountsCreate;

  /// No description provided for @permDiscountsCreateDesc.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء خصومات جديدة'**
  String get permDiscountsCreateDesc;

  /// No description provided for @permRefundsRequest.
  ///
  /// In ar, this message translates to:
  /// **'طلب استرجاع'**
  String get permRefundsRequest;

  /// No description provided for @permRefundsRequestDesc.
  ///
  /// In ar, this message translates to:
  /// **'طلب استرجاع للمنتجات'**
  String get permRefundsRequestDesc;

  /// No description provided for @permRefundsApprove.
  ///
  /// In ar, this message translates to:
  /// **'الموافقة على استرجاع'**
  String get permRefundsApprove;

  /// No description provided for @permRefundsApproveDesc.
  ///
  /// In ar, this message translates to:
  /// **'الموافقة على طلبات الاسترجاع'**
  String get permRefundsApproveDesc;

  /// No description provided for @permReportsView.
  ///
  /// In ar, this message translates to:
  /// **'عرض التقارير'**
  String get permReportsView;

  /// No description provided for @permReportsViewDesc.
  ///
  /// In ar, this message translates to:
  /// **'عرض التقارير والإحصائيات'**
  String get permReportsViewDesc;

  /// No description provided for @permReportsExport.
  ///
  /// In ar, this message translates to:
  /// **'تصدير التقارير'**
  String get permReportsExport;

  /// No description provided for @permReportsExportDesc.
  ///
  /// In ar, this message translates to:
  /// **'تصدير التقارير بصيغ مختلفة'**
  String get permReportsExportDesc;

  /// No description provided for @permSettingsView.
  ///
  /// In ar, this message translates to:
  /// **'عرض الإعدادات'**
  String get permSettingsView;

  /// No description provided for @permSettingsViewDesc.
  ///
  /// In ar, this message translates to:
  /// **'عرض إعدادات النظام'**
  String get permSettingsViewDesc;

  /// No description provided for @permSettingsManage.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الإعدادات'**
  String get permSettingsManage;

  /// No description provided for @permSettingsManageDesc.
  ///
  /// In ar, this message translates to:
  /// **'تعديل إعدادات النظام'**
  String get permSettingsManageDesc;

  /// No description provided for @permStaffView.
  ///
  /// In ar, this message translates to:
  /// **'عرض الموظفين'**
  String get permStaffView;

  /// No description provided for @permStaffViewDesc.
  ///
  /// In ar, this message translates to:
  /// **'عرض قائمة الموظفين'**
  String get permStaffViewDesc;

  /// No description provided for @permStaffManage.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الموظفين'**
  String get permStaffManage;

  /// No description provided for @permStaffManageDesc.
  ///
  /// In ar, this message translates to:
  /// **'إضافة وتعديل الموظفين'**
  String get permStaffManageDesc;

  /// No description provided for @roleSystemAdmin.
  ///
  /// In ar, this message translates to:
  /// **'مدير النظام'**
  String get roleSystemAdmin;

  /// No description provided for @roleSystemAdminDesc.
  ///
  /// In ar, this message translates to:
  /// **'صلاحيات كاملة للنظام'**
  String get roleSystemAdminDesc;

  /// No description provided for @roleStoreManager.
  ///
  /// In ar, this message translates to:
  /// **'مدير المتجر'**
  String get roleStoreManager;

  /// No description provided for @roleStoreManagerDesc.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المتجر والموظفين'**
  String get roleStoreManagerDesc;

  /// No description provided for @roleCashierDesc.
  ///
  /// In ar, this message translates to:
  /// **'عمليات البيع والدفع'**
  String get roleCashierDesc;

  /// No description provided for @roleWarehouseKeeper.
  ///
  /// In ar, this message translates to:
  /// **'أمين مخزن'**
  String get roleWarehouseKeeper;

  /// No description provided for @roleWarehouseKeeperDesc.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المخزون والمنتجات'**
  String get roleWarehouseKeeperDesc;

  /// No description provided for @roleAccountant.
  ///
  /// In ar, this message translates to:
  /// **'محاسب'**
  String get roleAccountant;

  /// No description provided for @roleAccountantDesc.
  ///
  /// In ar, this message translates to:
  /// **'التقارير المالية والحسابات'**
  String get roleAccountantDesc;

  /// No description provided for @connectionFailedMsg.
  ///
  /// In ar, this message translates to:
  /// **'فشل الاتصال: {error}'**
  String connectionFailedMsg(String error);

  /// No description provided for @settingsSaveErrorMsg.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في حفظ الإعدادات: {error}'**
  String settingsSaveErrorMsg(String error);

  /// No description provided for @cutPaperBtn.
  ///
  /// In ar, this message translates to:
  /// **'قطع'**
  String get cutPaperBtn;

  /// No description provided for @upgradeToPlan.
  ///
  /// In ar, this message translates to:
  /// **'الترقية إلى {name}'**
  String upgradeToPlan(String name);

  /// No description provided for @manageDeliveryZonesAndPricing.
  ///
  /// In ar, this message translates to:
  /// **'إدارة مناطق التوصيل وأسعارها'**
  String get manageDeliveryZonesAndPricing;

  /// No description provided for @settingsForName.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات {name}'**
  String settingsForName(String name);

  /// No description provided for @settingsSavedForName.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ إعدادات {name}'**
  String settingsSavedForName(String name);

  /// No description provided for @jobProfile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الوظيفي'**
  String get jobProfile;

  /// No description provided for @submitToZatcaAuthority.
  ///
  /// In ar, this message translates to:
  /// **'إرسال للهيئة الزكاة والضريبة'**
  String get submitToZatcaAuthority;

  /// No description provided for @submitBtn.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get submitBtn;

  /// No description provided for @submitToAuthority.
  ///
  /// In ar, this message translates to:
  /// **'إرسال للهيئة'**
  String get submitToAuthority;

  /// No description provided for @shareError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في المشاركة: {error}'**
  String shareError(String error);

  /// No description provided for @upgradePlanPriceBody.
  ///
  /// In ar, this message translates to:
  /// **'سعر الخطة: {price} ريال/شهر\n\nهل تريد المتابعة؟'**
  String upgradePlanPriceBody(String price);

  /// No description provided for @upgradeContactMsg.
  ///
  /// In ar, this message translates to:
  /// **'سيتم التواصل معك لإتمام عملية الترقية'**
  String get upgradeContactMsg;

  /// No description provided for @zatcaSubmitBody.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إرسال بيانات الفوترة الإلكترونية للهيئة. تأكد من صحة بياناتك أولاً.'**
  String get zatcaSubmitBody;

  /// No description provided for @zatcaLinkComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'سيتم الربط بنظام ZATCA قريباً - تأكد من إعداد الشهادة الرقمية'**
  String get zatcaLinkComingSoon;

  /// No description provided for @enterApiKey.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مفتاح API'**
  String get enterApiKey;

  /// No description provided for @accountNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الحساب'**
  String get accountNumber;

  /// No description provided for @superAdmin.
  ///
  /// In ar, this message translates to:
  /// **'المشرف العام'**
  String get superAdmin;

  /// No description provided for @platformOverview.
  ///
  /// In ar, this message translates to:
  /// **'نظرة عامة على المنصة'**
  String get platformOverview;

  /// No description provided for @activeStores.
  ///
  /// In ar, this message translates to:
  /// **'المتاجر النشطة'**
  String get activeStores;

  /// No description provided for @totalRevenue.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الإيرادات'**
  String get totalRevenue;

  /// No description provided for @subscriptionStats.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات الاشتراكات'**
  String get subscriptionStats;

  /// No description provided for @churnRate.
  ///
  /// In ar, this message translates to:
  /// **'معدل التسرب'**
  String get churnRate;

  /// No description provided for @conversionRate.
  ///
  /// In ar, this message translates to:
  /// **'معدل التحويل'**
  String get conversionRate;

  /// No description provided for @trialConversion.
  ///
  /// In ar, this message translates to:
  /// **'تحويل التجربة'**
  String get trialConversion;

  /// No description provided for @newSignups.
  ///
  /// In ar, this message translates to:
  /// **'اشتراكات جديدة'**
  String get newSignups;

  /// No description provided for @monthlyRecurringRevenue.
  ///
  /// In ar, this message translates to:
  /// **'الإيرادات الشهرية المتكررة'**
  String get monthlyRecurringRevenue;

  /// No description provided for @annualRecurringRevenue.
  ///
  /// In ar, this message translates to:
  /// **'الإيرادات السنوية المتكررة'**
  String get annualRecurringRevenue;

  /// No description provided for @storesList.
  ///
  /// In ar, this message translates to:
  /// **'المتاجر'**
  String get storesList;

  /// No description provided for @storeDetail.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المتجر'**
  String get storeDetail;

  /// No description provided for @createStore.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء متجر'**
  String get createStore;

  /// No description provided for @storeOwner.
  ///
  /// In ar, this message translates to:
  /// **'مالك المتجر'**
  String get storeOwner;

  /// No description provided for @storeStatus.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get storeStatus;

  /// No description provided for @storeCreatedAt.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإنشاء'**
  String get storeCreatedAt;

  /// No description provided for @storePlan.
  ///
  /// In ar, this message translates to:
  /// **'الخطة'**
  String get storePlan;

  /// No description provided for @suspendStore.
  ///
  /// In ar, this message translates to:
  /// **'تعليق المتجر'**
  String get suspendStore;

  /// No description provided for @activateStore.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل المتجر'**
  String get activateStore;

  /// No description provided for @upgradePlan.
  ///
  /// In ar, this message translates to:
  /// **'ترقية الخطة'**
  String get upgradePlan;

  /// No description provided for @downgradePlan.
  ///
  /// In ar, this message translates to:
  /// **'تخفيض الخطة'**
  String get downgradePlan;

  /// No description provided for @storeUsageStats.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات الاستخدام'**
  String get storeUsageStats;

  /// No description provided for @storeTransactions.
  ///
  /// In ar, this message translates to:
  /// **'المعاملات'**
  String get storeTransactions;

  /// No description provided for @storeProducts.
  ///
  /// In ar, this message translates to:
  /// **'عدد المنتجات'**
  String get storeProducts;

  /// No description provided for @storeEmployees.
  ///
  /// In ar, this message translates to:
  /// **'الموظفين'**
  String get storeEmployees;

  /// No description provided for @onboardingForm.
  ///
  /// In ar, this message translates to:
  /// **'نموذج التسجيل'**
  String get onboardingForm;

  /// No description provided for @ownerName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المالك'**
  String get ownerName;

  /// No description provided for @ownerPhone.
  ///
  /// In ar, this message translates to:
  /// **'هاتف المالك'**
  String get ownerPhone;

  /// No description provided for @ownerEmail.
  ///
  /// In ar, this message translates to:
  /// **'بريد المالك'**
  String get ownerEmail;

  /// No description provided for @businessType.
  ///
  /// In ar, this message translates to:
  /// **'نوع النشاط'**
  String get businessType;

  /// No description provided for @branchCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'عدد الفروع'**
  String get branchCountLabel;

  /// No description provided for @subscriptionManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الاشتراكات'**
  String get subscriptionManagement;

  /// No description provided for @plansManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الخطط'**
  String get plansManagement;

  /// No description provided for @subscriptionList.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراكات'**
  String get subscriptionList;

  /// No description provided for @billingAndInvoices.
  ///
  /// In ar, this message translates to:
  /// **'الفوترة والفواتير'**
  String get billingAndInvoices;

  /// No description provided for @planName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الخطة'**
  String get planName;

  /// No description provided for @planPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get planPrice;

  /// No description provided for @planFeatures.
  ///
  /// In ar, this message translates to:
  /// **'المميزات'**
  String get planFeatures;

  /// No description provided for @basicPlan.
  ///
  /// In ar, this message translates to:
  /// **'أساسي'**
  String get basicPlan;

  /// No description provided for @advancedPlan.
  ///
  /// In ar, this message translates to:
  /// **'متقدم'**
  String get advancedPlan;

  /// No description provided for @professionalPlan.
  ///
  /// In ar, this message translates to:
  /// **'احترافي'**
  String get professionalPlan;

  /// No description provided for @monthlyPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر الشهري'**
  String get monthlyPrice;

  /// No description provided for @yearlyPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر السنوي'**
  String get yearlyPrice;

  /// No description provided for @maxBranches.
  ///
  /// In ar, this message translates to:
  /// **'أقصى عدد فروع'**
  String get maxBranches;

  /// No description provided for @maxProducts.
  ///
  /// In ar, this message translates to:
  /// **'أقصى عدد منتجات'**
  String get maxProducts;

  /// No description provided for @maxUsers.
  ///
  /// In ar, this message translates to:
  /// **'أقصى عدد مستخدمين'**
  String get maxUsers;

  /// No description provided for @createPlan.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء خطة'**
  String get createPlan;

  /// No description provided for @editPlan.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الخطة'**
  String get editPlan;

  /// No description provided for @selectPlan.
  ///
  /// In ar, this message translates to:
  /// **'اختر الخطة'**
  String get selectPlan;

  /// No description provided for @currentPlan.
  ///
  /// In ar, this message translates to:
  /// **'الخطة الحالية'**
  String get currentPlan;

  /// No description provided for @noPlansAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد خطط متاحة'**
  String get noPlansAvailable;

  /// No description provided for @alreadyOnHighestPlan.
  ///
  /// In ar, this message translates to:
  /// **'أنت على أعلى خطة بالفعل'**
  String get alreadyOnHighestPlan;

  /// No description provided for @alreadyOnLowestPlan.
  ///
  /// In ar, this message translates to:
  /// **'أنت على أدنى خطة بالفعل'**
  String get alreadyOnLowestPlan;

  /// No description provided for @activeSubscriptions.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراكات النشطة'**
  String get activeSubscriptions;

  /// No description provided for @expiredSubscriptions.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراكات المنتهية'**
  String get expiredSubscriptions;

  /// No description provided for @trialSubscriptions.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراكات التجريبية'**
  String get trialSubscriptions;

  /// No description provided for @billingHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الفوترة'**
  String get billingHistory;

  /// No description provided for @invoiceDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get invoiceDate;

  /// No description provided for @invoiceAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get invoiceAmount;

  /// No description provided for @invoiceStatus.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get invoiceStatus;

  /// No description provided for @unpaid.
  ///
  /// In ar, this message translates to:
  /// **'غير مدفوعة'**
  String get unpaid;

  /// No description provided for @platformUsers.
  ///
  /// In ar, this message translates to:
  /// **'مستخدمو المنصة'**
  String get platformUsers;

  /// No description provided for @userDetail.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المستخدم'**
  String get userDetail;

  /// No description provided for @roleManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الأدوار'**
  String get roleManagement;

  /// No description provided for @userRole.
  ///
  /// In ar, this message translates to:
  /// **'الدور'**
  String get userRole;

  /// No description provided for @userLastActive.
  ///
  /// In ar, this message translates to:
  /// **'آخر نشاط'**
  String get userLastActive;

  /// No description provided for @superAdminRole.
  ///
  /// In ar, this message translates to:
  /// **'مشرف عام'**
  String get superAdminRole;

  /// No description provided for @supportRole.
  ///
  /// In ar, this message translates to:
  /// **'دعم فني'**
  String get supportRole;

  /// No description provided for @viewerRole.
  ///
  /// In ar, this message translates to:
  /// **'مشاهد'**
  String get viewerRole;

  /// No description provided for @assignRole.
  ///
  /// In ar, this message translates to:
  /// **'تعيين دور'**
  String get assignRole;

  /// No description provided for @analytics.
  ///
  /// In ar, this message translates to:
  /// **'التحليلات'**
  String get analytics;

  /// No description provided for @revenueAnalytics.
  ///
  /// In ar, this message translates to:
  /// **'تحليلات الإيرادات'**
  String get revenueAnalytics;

  /// No description provided for @usageAnalytics.
  ///
  /// In ar, this message translates to:
  /// **'تحليلات الاستخدام'**
  String get usageAnalytics;

  /// No description provided for @mrrGrowth.
  ///
  /// In ar, this message translates to:
  /// **'نمو الإيرادات الشهرية'**
  String get mrrGrowth;

  /// No description provided for @arrGrowth.
  ///
  /// In ar, this message translates to:
  /// **'نمو الإيرادات السنوية'**
  String get arrGrowth;

  /// No description provided for @revenueByPlan.
  ///
  /// In ar, this message translates to:
  /// **'الإيرادات حسب الخطة'**
  String get revenueByPlan;

  /// No description provided for @revenueByMonth.
  ///
  /// In ar, this message translates to:
  /// **'الإيرادات حسب الشهر'**
  String get revenueByMonth;

  /// No description provided for @activeUsersPerStore.
  ///
  /// In ar, this message translates to:
  /// **'المستخدمون النشطون لكل متجر'**
  String get activeUsersPerStore;

  /// No description provided for @transactionsPerStore.
  ///
  /// In ar, this message translates to:
  /// **'المعاملات لكل متجر'**
  String get transactionsPerStore;

  /// No description provided for @avgTransactionsPerDay.
  ///
  /// In ar, this message translates to:
  /// **'متوسط المعاملات/يوم'**
  String get avgTransactionsPerDay;

  /// No description provided for @topStoresByRevenue.
  ///
  /// In ar, this message translates to:
  /// **'أفضل المتاجر حسب الإيرادات'**
  String get topStoresByRevenue;

  /// No description provided for @topStoresByTransactions.
  ///
  /// In ar, this message translates to:
  /// **'أفضل المتاجر حسب المعاملات'**
  String get topStoresByTransactions;

  /// No description provided for @platformSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات المنصة'**
  String get platformSettings;

  /// No description provided for @zatcaConfig.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات ZATCA'**
  String get zatcaConfig;

  /// No description provided for @paymentGateways.
  ///
  /// In ar, this message translates to:
  /// **'بوابات الدفع'**
  String get paymentGateways;

  /// No description provided for @systemHealth.
  ///
  /// In ar, this message translates to:
  /// **'صحة النظام'**
  String get systemHealth;

  /// No description provided for @systemMonitoring.
  ///
  /// In ar, this message translates to:
  /// **'مراقبة النظام'**
  String get systemMonitoring;

  /// No description provided for @serverStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الخادم'**
  String get serverStatus;

  /// No description provided for @apiLatency.
  ///
  /// In ar, this message translates to:
  /// **'زمن استجابة API'**
  String get apiLatency;

  /// No description provided for @errorRate.
  ///
  /// In ar, this message translates to:
  /// **'معدل الأخطاء'**
  String get errorRate;

  /// No description provided for @cpuUsage.
  ///
  /// In ar, this message translates to:
  /// **'استخدام المعالج'**
  String get cpuUsage;

  /// No description provided for @memoryUsage.
  ///
  /// In ar, this message translates to:
  /// **'استخدام الذاكرة'**
  String get memoryUsage;

  /// No description provided for @diskUsage.
  ///
  /// In ar, this message translates to:
  /// **'استخدام القرص'**
  String get diskUsage;

  /// No description provided for @degraded.
  ///
  /// In ar, this message translates to:
  /// **'متدهور'**
  String get degraded;

  /// No description provided for @down.
  ///
  /// In ar, this message translates to:
  /// **'متوقف'**
  String get down;

  /// No description provided for @lastChecked.
  ///
  /// In ar, this message translates to:
  /// **'آخر فحص'**
  String get lastChecked;

  /// No description provided for @filterByStatus.
  ///
  /// In ar, this message translates to:
  /// **'تصفية حسب الحالة'**
  String get filterByStatus;

  /// No description provided for @filterByPlan.
  ///
  /// In ar, this message translates to:
  /// **'تصفية حسب الخطة'**
  String get filterByPlan;

  /// No description provided for @allStatuses.
  ///
  /// In ar, this message translates to:
  /// **'جميع الحالات'**
  String get allStatuses;

  /// No description provided for @allPlans.
  ///
  /// In ar, this message translates to:
  /// **'جميع الخطط'**
  String get allPlans;

  /// No description provided for @suspended.
  ///
  /// In ar, this message translates to:
  /// **'معلق'**
  String get suspended;

  /// No description provided for @trial.
  ///
  /// In ar, this message translates to:
  /// **'تجريبي'**
  String get trial;

  /// No description provided for @searchStores.
  ///
  /// In ar, this message translates to:
  /// **'البحث في المتاجر...'**
  String get searchStores;

  /// No description provided for @searchUsers.
  ///
  /// In ar, this message translates to:
  /// **'البحث في المستخدمين...'**
  String get searchUsers;

  /// No description provided for @noStoresFound.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد متاجر'**
  String get noStoresFound;

  /// No description provided for @noUsersFound.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مستخدمون'**
  String get noUsersFound;

  /// No description provided for @confirmSuspend.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تعليق هذا المتجر؟'**
  String get confirmSuspend;

  /// No description provided for @confirmActivate.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تفعيل هذا المتجر؟'**
  String get confirmActivate;

  /// No description provided for @storeCreatedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء المتجر بنجاح'**
  String get storeCreatedSuccess;

  /// No description provided for @storeSuspendedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تعليق المتجر بنجاح'**
  String get storeSuspendedSuccess;

  /// No description provided for @storeActivatedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل المتجر بنجاح'**
  String get storeActivatedSuccess;

  /// No description provided for @perMonth.
  ///
  /// In ar, this message translates to:
  /// **'/شهر'**
  String get perMonth;

  /// No description provided for @perYear.
  ///
  /// In ar, this message translates to:
  /// **'/سنة'**
  String get perYear;

  /// No description provided for @last90Days.
  ///
  /// In ar, this message translates to:
  /// **'آخر 90 يوم'**
  String get last90Days;

  /// No description provided for @last12Months.
  ///
  /// In ar, this message translates to:
  /// **'آخر 12 شهر'**
  String get last12Months;

  /// No description provided for @growth.
  ///
  /// In ar, this message translates to:
  /// **'النمو'**
  String get growth;

  /// No description provided for @stores.
  ///
  /// In ar, this message translates to:
  /// **'المتاجر'**
  String get stores;

  /// No description provided for @distributorPortal.
  ///
  /// In ar, this message translates to:
  /// **'بوابة الموزع'**
  String get distributorPortal;

  /// No description provided for @distributorDashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get distributorDashboard;

  /// No description provided for @distributorDashboardSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'نظرة عامة على أداء التوزيع'**
  String get distributorDashboardSubtitle;

  /// No description provided for @distributorOrders.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات الواردة'**
  String get distributorOrders;

  /// No description provided for @distributorProducts.
  ///
  /// In ar, this message translates to:
  /// **'كتالوج المنتجات'**
  String get distributorProducts;

  /// No description provided for @distributorPricing.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الأسعار'**
  String get distributorPricing;

  /// No description provided for @distributorReports.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get distributorReports;

  /// No description provided for @distributorSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get distributorSettings;

  /// No description provided for @distributorTotalOrders.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الطلبات'**
  String get distributorTotalOrders;

  /// No description provided for @distributorPendingOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلبات منتظرة'**
  String get distributorPendingOrders;

  /// No description provided for @distributorApprovedOrders.
  ///
  /// In ar, this message translates to:
  /// **'تمت الموافقة'**
  String get distributorApprovedOrders;

  /// No description provided for @distributorRevenue.
  ///
  /// In ar, this message translates to:
  /// **'الإيرادات'**
  String get distributorRevenue;

  /// No description provided for @distributorMonthlySales.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات الشهرية'**
  String get distributorMonthlySales;

  /// No description provided for @distributorRecentOrders.
  ///
  /// In ar, this message translates to:
  /// **'آخر الطلبات'**
  String get distributorRecentOrders;

  /// No description provided for @distributorOrderNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الطلب'**
  String get distributorOrderNumber;

  /// No description provided for @distributorStore.
  ///
  /// In ar, this message translates to:
  /// **'المتجر'**
  String get distributorStore;

  /// No description provided for @distributorDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get distributorDate;

  /// No description provided for @distributorAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get distributorAmount;

  /// No description provided for @distributorStatusPending.
  ///
  /// In ar, this message translates to:
  /// **'منتظر'**
  String get distributorStatusPending;

  /// No description provided for @distributorStatusApproved.
  ///
  /// In ar, this message translates to:
  /// **'موافق'**
  String get distributorStatusApproved;

  /// No description provided for @distributorStatusReceived.
  ///
  /// In ar, this message translates to:
  /// **'مستلم'**
  String get distributorStatusReceived;

  /// No description provided for @distributorStatusRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get distributorStatusRejected;

  /// No description provided for @distributorStatusDraft.
  ///
  /// In ar, this message translates to:
  /// **'مسودة'**
  String get distributorStatusDraft;

  /// No description provided for @distributorNoOrders.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات'**
  String get distributorNoOrders;

  /// No description provided for @distributorAllOrders.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get distributorAllOrders;

  /// No description provided for @distributorPendingTab.
  ///
  /// In ar, this message translates to:
  /// **'منتظرة'**
  String get distributorPendingTab;

  /// No description provided for @distributorApprovedTab.
  ///
  /// In ar, this message translates to:
  /// **'موافق عليها'**
  String get distributorApprovedTab;

  /// No description provided for @distributorRejectedTab.
  ///
  /// In ar, this message translates to:
  /// **'مرفوضة'**
  String get distributorRejectedTab;

  /// No description provided for @distributorAddProduct.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منتج'**
  String get distributorAddProduct;

  /// No description provided for @distributorSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالاسم أو الباركود...'**
  String get distributorSearchHint;

  /// No description provided for @distributorNoProducts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات'**
  String get distributorNoProducts;

  /// No description provided for @distributorChangeSearch.
  ///
  /// In ar, this message translates to:
  /// **'جرب تغيير معايير البحث'**
  String get distributorChangeSearch;

  /// No description provided for @distributorBarcode.
  ///
  /// In ar, this message translates to:
  /// **'الباركود'**
  String get distributorBarcode;

  /// No description provided for @distributorCategory.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get distributorCategory;

  /// No description provided for @distributorStock.
  ///
  /// In ar, this message translates to:
  /// **'المخزون'**
  String get distributorStock;

  /// No description provided for @distributorStockEmpty.
  ///
  /// In ar, this message translates to:
  /// **'نفذ'**
  String get distributorStockEmpty;

  /// No description provided for @distributorStockLow.
  ///
  /// In ar, this message translates to:
  /// **'منخفض'**
  String get distributorStockLow;

  /// No description provided for @distributorActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات'**
  String get distributorActions;

  /// No description provided for @distributorEditProduct.
  ///
  /// In ar, this message translates to:
  /// **'تعديل {name}'**
  String distributorEditProduct(String name);

  /// No description provided for @distributorCurrentPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر الحالي'**
  String get distributorCurrentPrice;

  /// No description provided for @distributorNewPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر الجديد'**
  String get distributorNewPrice;

  /// No description provided for @distributorLastUpdated.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث'**
  String get distributorLastUpdated;

  /// No description provided for @distributorDifference.
  ///
  /// In ar, this message translates to:
  /// **'الفرق'**
  String get distributorDifference;

  /// No description provided for @distributorTotalProducts.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المنتجات'**
  String get distributorTotalProducts;

  /// No description provided for @distributorPendingChanges.
  ///
  /// In ar, this message translates to:
  /// **'تغييرات معلقة'**
  String get distributorPendingChanges;

  /// No description provided for @distributorProductsWillUpdate.
  ///
  /// In ar, this message translates to:
  /// **'{count} منتج سيتم تحديث سعره'**
  String distributorProductsWillUpdate(int count);

  /// No description provided for @distributorSaveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التغييرات'**
  String get distributorSaveChanges;

  /// No description provided for @distributorChangesSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التغييرات بنجاح'**
  String get distributorChangesSaved;

  /// No description provided for @distributorChangesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} تغيير'**
  String distributorChangesCount(int count);

  /// No description provided for @distributorExport.
  ///
  /// In ar, this message translates to:
  /// **'تصدير'**
  String get distributorExport;

  /// No description provided for @distributorExportReport.
  ///
  /// In ar, this message translates to:
  /// **'تصدير التقرير'**
  String get distributorExportReport;

  /// No description provided for @distributorDailySales.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات اليومية'**
  String get distributorDailySales;

  /// No description provided for @distributorOrderCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الطلبات'**
  String get distributorOrderCount;

  /// No description provided for @distributorAvgOrderValue.
  ///
  /// In ar, this message translates to:
  /// **'متوسط قيمة الطلب'**
  String get distributorAvgOrderValue;

  /// No description provided for @distributorTopProduct.
  ///
  /// In ar, this message translates to:
  /// **'أفضل منتج'**
  String get distributorTopProduct;

  /// No description provided for @distributorTopProducts.
  ///
  /// In ar, this message translates to:
  /// **'أفضل المنتجات'**
  String get distributorTopProducts;

  /// No description provided for @distributorOrdersUnit.
  ///
  /// In ar, this message translates to:
  /// **'طلب'**
  String get distributorOrdersUnit;

  /// No description provided for @distributorPeriodDay.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get distributorPeriodDay;

  /// No description provided for @distributorPeriodWeek.
  ///
  /// In ar, this message translates to:
  /// **'أسبوع'**
  String get distributorPeriodWeek;

  /// No description provided for @distributorPeriodMonth.
  ///
  /// In ar, this message translates to:
  /// **'شهر'**
  String get distributorPeriodMonth;

  /// No description provided for @distributorPeriodYear.
  ///
  /// In ar, this message translates to:
  /// **'سنة'**
  String get distributorPeriodYear;

  /// No description provided for @distributorCompanyInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الشركة'**
  String get distributorCompanyInfo;

  /// No description provided for @distributorCompanyName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الشركة'**
  String get distributorCompanyName;

  /// No description provided for @distributorPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get distributorPhone;

  /// No description provided for @distributorEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get distributorEmail;

  /// No description provided for @distributorAddress.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get distributorAddress;

  /// No description provided for @distributorNotificationSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الإشعارات'**
  String get distributorNotificationSettings;

  /// No description provided for @distributorNotificationChannels.
  ///
  /// In ar, this message translates to:
  /// **'قنوات الإشعارات'**
  String get distributorNotificationChannels;

  /// No description provided for @distributorEmailNotifications.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get distributorEmailNotifications;

  /// No description provided for @distributorPushNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات الجوال'**
  String get distributorPushNotifications;

  /// No description provided for @distributorSmsNotifications.
  ///
  /// In ar, this message translates to:
  /// **'رسائل SMS'**
  String get distributorSmsNotifications;

  /// No description provided for @distributorNotificationTypes.
  ///
  /// In ar, this message translates to:
  /// **'أنواع الإشعارات'**
  String get distributorNotificationTypes;

  /// No description provided for @distributorNewOrderNotification.
  ///
  /// In ar, this message translates to:
  /// **'طلبات جديدة'**
  String get distributorNewOrderNotification;

  /// No description provided for @distributorOrderStatusNotification.
  ///
  /// In ar, this message translates to:
  /// **'تحديث حالة الطلب'**
  String get distributorOrderStatusNotification;

  /// No description provided for @distributorPaymentNotification.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات الدفع'**
  String get distributorPaymentNotification;

  /// No description provided for @distributorDeliverySettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات التسليم'**
  String get distributorDeliverySettings;

  /// No description provided for @distributorDeliveryZones.
  ///
  /// In ar, this message translates to:
  /// **'مناطق التوصيل'**
  String get distributorDeliveryZones;

  /// No description provided for @distributorDeliveryZonesHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل المدن مفصولة بفاصلة'**
  String get distributorDeliveryZonesHint;

  /// No description provided for @distributorMinOrder.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى للطلب (ر.س)'**
  String get distributorMinOrder;

  /// No description provided for @distributorDeliveryFee.
  ///
  /// In ar, this message translates to:
  /// **'رسوم التوصيل (ر.س)'**
  String get distributorDeliveryFee;

  /// No description provided for @distributorFreeDelivery.
  ///
  /// In ar, this message translates to:
  /// **'توصيل مجاني'**
  String get distributorFreeDelivery;

  /// No description provided for @distributorFreeDeliveryMin.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى للتوصيل المجاني (ر.س)'**
  String get distributorFreeDeliveryMin;

  /// No description provided for @distributorSaveSettings.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الإعدادات'**
  String get distributorSaveSettings;

  /// No description provided for @distributorSettingsSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الإعدادات بنجاح'**
  String get distributorSettingsSaved;

  /// No description provided for @distributorPurchaseOrder.
  ///
  /// In ar, this message translates to:
  /// **'طلب شراء #{number}'**
  String distributorPurchaseOrder(String number);

  /// No description provided for @distributorProposedAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المقترح:'**
  String get distributorProposedAmount;

  /// No description provided for @distributorOrderItems.
  ///
  /// In ar, this message translates to:
  /// **'بنود الطلب'**
  String get distributorOrderItems;

  /// No description provided for @distributorProductCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} منتجات'**
  String distributorProductCount(int count);

  /// No description provided for @distributorSuggestedPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر المقترح'**
  String get distributorSuggestedPrice;

  /// No description provided for @distributorYourPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعرك'**
  String get distributorYourPrice;

  /// No description provided for @distributorYourTotal.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي سعرك'**
  String get distributorYourTotal;

  /// No description provided for @distributorNotesForStore.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات للمتجر'**
  String get distributorNotesForStore;

  /// No description provided for @distributorNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف ملاحظات حول العرض (اختياري)...'**
  String get distributorNotesHint;

  /// No description provided for @distributorRejectOrder.
  ///
  /// In ar, this message translates to:
  /// **'رفض الطلب'**
  String get distributorRejectOrder;

  /// No description provided for @distributorAcceptSendQuote.
  ///
  /// In ar, this message translates to:
  /// **'قبول وإرسال العرض'**
  String get distributorAcceptSendQuote;

  /// No description provided for @distributorOrderRejected.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض الطلب بنجاح'**
  String get distributorOrderRejected;

  /// No description provided for @distributorOrderAccepted.
  ///
  /// In ar, this message translates to:
  /// **'تم قبول الطلب وإرسال العرض بمبلغ {amount} ريال'**
  String distributorOrderAccepted(String amount);

  /// No description provided for @distributorLowerThanProposed.
  ///
  /// In ar, this message translates to:
  /// **'{percent}% أقل من المقترح'**
  String distributorLowerThanProposed(String percent);

  /// No description provided for @distributorHigherThanProposed.
  ///
  /// In ar, this message translates to:
  /// **'+{percent}% أعلى من المقترح'**
  String distributorHigherThanProposed(String percent);

  /// No description provided for @distributorComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريباً'**
  String get distributorComingSoon;

  /// No description provided for @distributorLoadError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في تحميل البيانات'**
  String get distributorLoadError;

  /// No description provided for @distributorRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get distributorRetry;

  /// No description provided for @distributorLogin.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل دخول الموزع'**
  String get distributorLogin;

  /// No description provided for @distributorLoginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني وكلمة المرور'**
  String get distributorLoginSubtitle;

  /// No description provided for @distributorEmailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get distributorEmailLabel;

  /// No description provided for @distributorPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get distributorPasswordLabel;

  /// No description provided for @distributorLoginButton.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get distributorLoginButton;

  /// No description provided for @distributorLoginError.
  ///
  /// In ar, this message translates to:
  /// **'فشل تسجيل الدخول'**
  String get distributorLoginError;

  /// No description provided for @distributorLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get distributorLogout;

  /// No description provided for @distributorSar.
  ///
  /// In ar, this message translates to:
  /// **'ر.س'**
  String get distributorSar;

  /// No description provided for @distributorRiyal.
  ///
  /// In ar, this message translates to:
  /// **'ريال'**
  String get distributorRiyal;

  /// No description provided for @distributorUnsavedChanges.
  ///
  /// In ar, this message translates to:
  /// **'تغييرات غير محفوظة'**
  String get distributorUnsavedChanges;

  /// No description provided for @distributorUnsavedChangesMessage.
  ///
  /// In ar, this message translates to:
  /// **'لديك تغييرات غير محفوظة. هل تريد المغادرة بدون حفظ؟'**
  String get distributorUnsavedChangesMessage;

  /// No description provided for @distributorStay.
  ///
  /// In ar, this message translates to:
  /// **'البقاء'**
  String get distributorStay;

  /// No description provided for @distributorLeave.
  ///
  /// In ar, this message translates to:
  /// **'مغادرة'**
  String get distributorLeave;

  /// No description provided for @distributorNoDataToExport.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات للتصدير'**
  String get distributorNoDataToExport;

  /// No description provided for @distributorReportExported.
  ///
  /// In ar, this message translates to:
  /// **'تم تصدير التقرير بنجاح'**
  String get distributorReportExported;

  /// No description provided for @distributorExportWebOnly.
  ///
  /// In ar, this message translates to:
  /// **'التصدير متاح فقط على الويب'**
  String get distributorExportWebOnly;

  /// No description provided for @distributorPrintWebOnly.
  ///
  /// In ar, this message translates to:
  /// **'الطباعة متاحة فقط على الويب'**
  String get distributorPrintWebOnly;

  /// No description provided for @distributorSaveError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء الحفظ'**
  String get distributorSaveError;

  /// No description provided for @distributorInvalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال بريد إلكتروني صحيح'**
  String get distributorInvalidEmail;

  /// No description provided for @distributorInvalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم هاتف صحيح'**
  String get distributorInvalidPhone;

  /// No description provided for @distributorActionUndone.
  ///
  /// In ar, this message translates to:
  /// **'تم التراجع عن الإجراء'**
  String get distributorActionUndone;

  /// No description provided for @distributorSessionExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجلسة بسبب عدم النشاط. يرجى تسجيل الدخول مرة أخرى.'**
  String get distributorSessionExpired;

  /// No description provided for @distributorWelcomePortal.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً في بوابة الموزع!'**
  String get distributorWelcomePortal;

  /// No description provided for @distributorGetStarted.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ باستكشاف هذه الميزات الرئيسية:'**
  String get distributorGetStarted;

  /// No description provided for @distributorManagePrices.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الأسعار'**
  String get distributorManagePrices;

  /// No description provided for @distributorManagePricesDesc.
  ///
  /// In ar, this message translates to:
  /// **'تحديد وتحديث أسعار منتجاتك'**
  String get distributorManagePricesDesc;

  /// No description provided for @distributorViewReports.
  ///
  /// In ar, this message translates to:
  /// **'عرض التقارير'**
  String get distributorViewReports;

  /// No description provided for @distributorViewReportsDesc.
  ///
  /// In ar, this message translates to:
  /// **'تتبع أداء المبيعات والتحليلات'**
  String get distributorViewReportsDesc;

  /// No description provided for @distributorUpdateSettings.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الإعدادات'**
  String get distributorUpdateSettings;

  /// No description provided for @distributorUpdateSettingsDesc.
  ///
  /// In ar, this message translates to:
  /// **'إعداد معلومات الشركة ومناطق التوصيل والإشعارات'**
  String get distributorUpdateSettingsDesc;

  /// No description provided for @distributorReviewOrdersDesc.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة وإدارة طلبات الشراء الواردة'**
  String get distributorReviewOrdersDesc;

  /// No description provided for @distributorMonthlySalesSar.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات الشهرية (ر.س)'**
  String get distributorMonthlySalesSar;

  /// No description provided for @distributorPrintReport.
  ///
  /// In ar, this message translates to:
  /// **'طباعة التقرير'**
  String get distributorPrintReport;

  /// No description provided for @distributorPrint.
  ///
  /// In ar, this message translates to:
  /// **'طباعة'**
  String get distributorPrint;

  /// No description provided for @distributorExportCsv.
  ///
  /// In ar, this message translates to:
  /// **'تصدير التقرير كملف CSV'**
  String get distributorExportCsv;

  /// No description provided for @distributorExportCsvShort.
  ///
  /// In ar, this message translates to:
  /// **'تصدير CSV'**
  String get distributorExportCsvShort;

  /// No description provided for @distributorSaveCtrlS.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التغييرات (Ctrl+S)'**
  String get distributorSaveCtrlS;

  /// No description provided for @scanCouponBarcode.
  ///
  /// In ar, this message translates to:
  /// **'مسح باركود الكوبون'**
  String get scanCouponBarcode;

  /// No description provided for @validateCoupon.
  ///
  /// In ar, this message translates to:
  /// **'تحقق'**
  String get validateCoupon;

  /// No description provided for @couponValid.
  ///
  /// In ar, this message translates to:
  /// **'الكوبون صالح'**
  String get couponValid;

  /// No description provided for @recentCoupons.
  ///
  /// In ar, this message translates to:
  /// **'الكوبونات الأخيرة'**
  String get recentCoupons;

  /// No description provided for @noRecentCoupons.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد كوبونات حديثة'**
  String get noRecentCoupons;

  /// No description provided for @noExpiry.
  ///
  /// In ar, this message translates to:
  /// **'بدون انتهاء'**
  String get noExpiry;

  /// No description provided for @invalidCouponCode.
  ///
  /// In ar, this message translates to:
  /// **'كود كوبون غير صالح'**
  String get invalidCouponCode;

  /// No description provided for @percentageOff.
  ///
  /// In ar, this message translates to:
  /// **'خصم نسبة مئوية'**
  String get percentageOff;

  /// No description provided for @bundleDeals.
  ///
  /// In ar, this message translates to:
  /// **'عروض الباقات'**
  String get bundleDeals;

  /// No description provided for @includedProducts.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات المشمولة'**
  String get includedProducts;

  /// No description provided for @individualTotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع الفردي'**
  String get individualTotal;

  /// No description provided for @bundlePrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر الباقة'**
  String get bundlePrice;

  /// No description provided for @youSave.
  ///
  /// In ar, this message translates to:
  /// **'توفيرك'**
  String get youSave;

  /// No description provided for @noBundleDeals.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عروض باقات'**
  String get noBundleDeals;

  /// No description provided for @bundleDealsWillAppear.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر عروض الباقات هنا'**
  String get bundleDealsWillAppear;

  /// No description provided for @validUntilDate.
  ///
  /// In ar, this message translates to:
  /// **'صالح حتى: {date}'**
  String validUntilDate(String date);

  /// No description provided for @validFromDate.
  ///
  /// In ar, this message translates to:
  /// **'صالح من: {date}'**
  String validFromDate(String date);

  /// No description provided for @autoApplied.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق تلقائي'**
  String get autoApplied;

  /// No description provided for @noActiveOffers.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عروض نشطة'**
  String get noActiveOffers;

  /// No description provided for @wastage.
  ///
  /// In ar, this message translates to:
  /// **'الهدر والتالف'**
  String get wastage;

  /// No description provided for @quantityWasted.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المهدرة'**
  String get quantityWasted;

  /// No description provided for @photoLabel.
  ///
  /// In ar, this message translates to:
  /// **'صورة'**
  String get photoLabel;

  /// No description provided for @photoAttached.
  ///
  /// In ar, this message translates to:
  /// **'تم إرفاق الصورة'**
  String get photoAttached;

  /// No description provided for @tapToTakePhoto.
  ///
  /// In ar, this message translates to:
  /// **'انقر لالتقاط صورة'**
  String get tapToTakePhoto;

  /// No description provided for @optionalLabel.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get optionalLabel;

  /// No description provided for @recordWastage.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الهدر'**
  String get recordWastage;

  /// No description provided for @spillage.
  ///
  /// In ar, this message translates to:
  /// **'انسكاب'**
  String get spillage;

  /// No description provided for @transferInventory.
  ///
  /// In ar, this message translates to:
  /// **'نقل المخزون'**
  String get transferInventory;

  /// No description provided for @transferDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل النقل'**
  String get transferDetails;

  /// No description provided for @fromStore.
  ///
  /// In ar, this message translates to:
  /// **'من الفرع'**
  String get fromStore;

  /// No description provided for @toStore.
  ///
  /// In ar, this message translates to:
  /// **'إلى الفرع'**
  String get toStore;

  /// No description provided for @selectStore.
  ///
  /// In ar, this message translates to:
  /// **'اختر الفرع'**
  String get selectStore;

  /// No description provided for @submitTransfer.
  ///
  /// In ar, this message translates to:
  /// **'إرسال النقل'**
  String get submitTransfer;

  /// No description provided for @optionalNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة اختيارية'**
  String get optionalNote;

  /// No description provided for @addInventory.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مخزون'**
  String get addInventory;

  /// No description provided for @scanLabel.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get scanLabel;

  /// No description provided for @quantityToAdd.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المراد إضافتها'**
  String get quantityToAdd;

  /// No description provided for @supplierReference.
  ///
  /// In ar, this message translates to:
  /// **'مرجع المورد'**
  String get supplierReference;

  /// No description provided for @removeInventory.
  ///
  /// In ar, this message translates to:
  /// **'سحب مخزون'**
  String get removeInventory;

  /// No description provided for @quantityToRemove.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المراد سحبها'**
  String get quantityToRemove;

  /// No description provided for @sold.
  ///
  /// In ar, this message translates to:
  /// **'مباع'**
  String get sold;

  /// No description provided for @transferred.
  ///
  /// In ar, this message translates to:
  /// **'منقول'**
  String get transferred;

  /// No description provided for @fieldRequired.
  ///
  /// In ar, this message translates to:
  /// **'الحقل مطلوب'**
  String get fieldRequired;

  /// No description provided for @deviceInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الجهاز'**
  String get deviceInfo;

  /// No description provided for @deviceName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الجهاز'**
  String get deviceName;

  /// No description provided for @deviceType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الجهاز'**
  String get deviceType;

  /// No description provided for @connectionMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الاتصال'**
  String get connectionMethod;

  /// No description provided for @networkSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الشبكة'**
  String get networkSettings;

  /// No description provided for @ipAddress.
  ///
  /// In ar, this message translates to:
  /// **'عنوان IP'**
  String get ipAddress;

  /// No description provided for @port.
  ///
  /// In ar, this message translates to:
  /// **'المنفذ'**
  String get port;

  /// No description provided for @connectionTestPassed.
  ///
  /// In ar, this message translates to:
  /// **'نجح اختبار الاتصال'**
  String get connectionTestPassed;

  /// No description provided for @saveDevice.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الجهاز'**
  String get saveDevice;

  /// No description provided for @addDevice.
  ///
  /// In ar, this message translates to:
  /// **'إضافة جهاز'**
  String get addDevice;

  /// No description provided for @noPaymentDevices.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أجهزة دفع'**
  String get noPaymentDevices;

  /// No description provided for @addFirstPaymentDevice.
  ///
  /// In ar, this message translates to:
  /// **'أضف أول جهاز دفع'**
  String get addFirstPaymentDevice;

  /// No description provided for @totalDevices.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأجهزة'**
  String get totalDevices;

  /// No description provided for @disconnected.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get disconnected;

  /// No description provided for @testingConnectionName.
  ///
  /// In ar, this message translates to:
  /// **'جاري اختبار الاتصال {name}...'**
  String testingConnectionName(String name);

  /// No description provided for @connectionSuccessful.
  ///
  /// In ar, this message translates to:
  /// **'{name} - تم الاتصال بنجاح'**
  String connectionSuccessful(String name);

  /// No description provided for @pasteFromClipboard.
  ///
  /// In ar, this message translates to:
  /// **'لصق من الحافظة'**
  String get pasteFromClipboard;

  /// No description provided for @confirmRestore.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الاستعادة'**
  String get confirmRestore;

  /// No description provided for @saleNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على البيع'**
  String get saleNotFound;

  /// No description provided for @noItems.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عناصر'**
  String get noItems;

  /// No description provided for @customerPaysExtra.
  ///
  /// In ar, this message translates to:
  /// **'العميل يدفع إضافي'**
  String get customerPaysExtra;

  /// No description provided for @submitExchange.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الاستبدال'**
  String get submitExchange;

  /// No description provided for @applyInterest.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق الفائدة'**
  String get applyInterest;

  /// No description provided for @reportSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات التقرير'**
  String get reportSettings;

  /// No description provided for @reportType.
  ///
  /// In ar, this message translates to:
  /// **'نوع التقرير'**
  String get reportType;

  /// No description provided for @paymentDistribution.
  ///
  /// In ar, this message translates to:
  /// **'توزيع المدفوعات'**
  String get paymentDistribution;

  /// No description provided for @allAccountsSettled.
  ///
  /// In ar, this message translates to:
  /// **'جميع حسابات العملاء مسددة'**
  String get allAccountsSettled;

  /// No description provided for @confirmInterest.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الفائدة'**
  String get confirmInterest;

  /// No description provided for @confirmInterestMessage.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق {rate}% فائدة على {count} حسابات؟\nإجمالي الفائدة: {amount} {currency}'**
  String confirmInterestMessage(
      String rate, int count, String amount, String currency);

  /// No description provided for @selectCustomers.
  ///
  /// In ar, this message translates to:
  /// **'اختيار العملاء'**
  String get selectCustomers;

  /// No description provided for @deselectAll.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء تحديد الكل'**
  String get deselectAll;

  /// No description provided for @preview.
  ///
  /// In ar, this message translates to:
  /// **'معاينة'**
  String get preview;

  /// No description provided for @totalDebt.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الديون'**
  String get totalDebt;

  /// No description provided for @totalInterest.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الفائدة'**
  String get totalInterest;

  /// No description provided for @finalizeInvoice.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء الفاتورة'**
  String get finalizeInvoice;

  /// No description provided for @saveAsDraft.
  ///
  /// In ar, this message translates to:
  /// **'حفظ كمسودة'**
  String get saveAsDraft;

  /// No description provided for @saveDraft.
  ///
  /// In ar, this message translates to:
  /// **'حفظ المسودة'**
  String get saveDraft;

  /// No description provided for @finalize.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء'**
  String get finalize;

  /// No description provided for @adjustQuantity.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الكمية'**
  String get adjustQuantity;

  /// No description provided for @totalItems.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي العناصر'**
  String get totalItems;

  /// No description provided for @variance.
  ///
  /// In ar, this message translates to:
  /// **'الفرق'**
  String get variance;

  /// No description provided for @orderNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على الطلب'**
  String get orderNotFound;

  /// No description provided for @share.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get share;

  /// No description provided for @full.
  ///
  /// In ar, this message translates to:
  /// **'كامل'**
  String get full;

  /// No description provided for @processRefund.
  ///
  /// In ar, this message translates to:
  /// **'معالجة الاسترداد'**
  String get processRefund;

  /// No description provided for @refundToCustomer.
  ///
  /// In ar, this message translates to:
  /// **'استرداد للعميل'**
  String get refundToCustomer;

  /// No description provided for @breakdown.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get breakdown;

  /// No description provided for @nTransactions.
  ///
  /// In ar, this message translates to:
  /// **'{count} معاملات'**
  String nTransactions(int count);

  /// No description provided for @customReport.
  ///
  /// In ar, this message translates to:
  /// **'تقرير مخصص'**
  String get customReport;

  /// No description provided for @reportBuilder.
  ///
  /// In ar, this message translates to:
  /// **'منشئ التقارير'**
  String get reportBuilder;

  /// No description provided for @groupBy.
  ///
  /// In ar, this message translates to:
  /// **'تجميع حسب'**
  String get groupBy;

  /// No description provided for @dateRange.
  ///
  /// In ar, this message translates to:
  /// **'النطاق الزمني'**
  String get dateRange;

  /// No description provided for @fromLabel.
  ///
  /// In ar, this message translates to:
  /// **'من'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In ar, this message translates to:
  /// **'إلى'**
  String get toLabel;

  /// No description provided for @generateReport.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء التقرير'**
  String get generateReport;

  /// No description provided for @lastMonth.
  ///
  /// In ar, this message translates to:
  /// **'الشهر الماضي'**
  String get lastMonth;

  /// No description provided for @periods.
  ///
  /// In ar, this message translates to:
  /// **'الفترات'**
  String get periods;

  /// No description provided for @valueLabel.
  ///
  /// In ar, this message translates to:
  /// **'القيمة'**
  String get valueLabel;

  /// No description provided for @tryDifferentFilters.
  ///
  /// In ar, this message translates to:
  /// **'جرّب فلاتر مختلفة'**
  String get tryDifferentFilters;

  /// No description provided for @scan.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get scan;

  /// No description provided for @selectProductFirst.
  ///
  /// In ar, this message translates to:
  /// **'اختر منتج أولاً'**
  String get selectProductFirst;

  /// No description provided for @selectProductsForLabels.
  ///
  /// In ar, this message translates to:
  /// **'اختر منتجات للملصقات'**
  String get selectProductsForLabels;

  /// No description provided for @printJobSentForLabels.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طباعة {count} ملصق'**
  String printJobSentForLabels(int count);

  /// No description provided for @test.
  ///
  /// In ar, this message translates to:
  /// **'اختبار'**
  String get test;

  /// No description provided for @paperSize58mm.
  ///
  /// In ar, this message translates to:
  /// **'58مم'**
  String get paperSize58mm;

  /// No description provided for @paperSize80mm.
  ///
  /// In ar, this message translates to:
  /// **'80مم'**
  String get paperSize80mm;

  /// No description provided for @errorSavingSettings.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في حفظ الإعدادات: {error}'**
  String errorSavingSettings(String error);

  /// No description provided for @restoreFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل الاستعادة: {error}'**
  String restoreFailed(String error);

  /// No description provided for @address.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get address;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @crNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم السجل التجاري'**
  String get crNumber;

  /// No description provided for @city.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get city;

  /// No description provided for @optional.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get optional;

  /// No description provided for @optionalNoteHint.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة اختيارية...'**
  String get optionalNoteHint;

  /// No description provided for @clearField.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get clearField;

  /// No description provided for @decreaseQuantity.
  ///
  /// In ar, this message translates to:
  /// **'تقليل الكمية'**
  String get decreaseQuantity;

  /// No description provided for @increaseQuantity.
  ///
  /// In ar, this message translates to:
  /// **'زيادة الكمية'**
  String get increaseQuantity;

  /// No description provided for @copyToClipboard.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get copyToClipboard;

  /// No description provided for @invoiceAlreadyRefunded.
  ///
  /// In ar, this message translates to:
  /// **'تم إرجاع هذه الفاتورة بالكامل مسبقاً'**
  String get invoiceAlreadyRefunded;

  /// No description provided for @invoicePartiallyRefunded.
  ///
  /// In ar, this message translates to:
  /// **'تم إرجاع بعض المنتجات مسبقاً - يتم عرض المتبقي فقط'**
  String get invoicePartiallyRefunded;

  /// No description provided for @invoiceVoidedCannotRefund.
  ///
  /// In ar, this message translates to:
  /// **'هذه الفاتورة ملغاة ولا يمكن إرجاعها'**
  String get invoiceVoidedCannotRefund;

  /// No description provided for @deviceClockInaccurate.
  ///
  /// In ar, this message translates to:
  /// **'ساعة الجهاز غير دقيقة - يرجى ضبط الوقت (فرق: {minutes} دقيقة)'**
  String deviceClockInaccurate(int minutes);

  /// No description provided for @saSignInFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل تسجيل الدخول'**
  String get saSignInFailed;

  /// No description provided for @saAccessDenied.
  ///
  /// In ar, this message translates to:
  /// **'الوصول مرفوض. يلزم صلاحية المشرف العام.'**
  String get saAccessDenied;

  /// No description provided for @saPlatformManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة منصة الحي نقطة البيع'**
  String get saPlatformManagement;

  /// No description provided for @saSuperAdmin.
  ///
  /// In ar, this message translates to:
  /// **'المشرف العام'**
  String get saSuperAdmin;

  /// No description provided for @saEnterCredentials.
  ///
  /// In ar, this message translates to:
  /// **'أدخل البريد الإلكتروني وكلمة المرور'**
  String get saEnterCredentials;

  /// No description provided for @saSignIn.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get saSignIn;

  /// No description provided for @saSuperAdminOnly.
  ///
  /// In ar, this message translates to:
  /// **'فقط المستخدمين بصلاحية المشرف العام يمكنهم الوصول لهذه اللوحة.'**
  String get saSuperAdminOnly;

  /// No description provided for @saNoSubscriptionsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد اشتراكات بعد'**
  String get saNoSubscriptionsYet;

  /// No description provided for @saNoRevenueData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات إيرادات'**
  String get saNoRevenueData;

  /// No description provided for @saNoLogsFound.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سجلات'**
  String get saNoLogsFound;

  /// No description provided for @saPlatformSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص المنصة'**
  String get saPlatformSummary;

  /// No description provided for @saSubscriptionStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الاشتراكات'**
  String get saSubscriptionStatus;

  /// No description provided for @saExportData.
  ///
  /// In ar, this message translates to:
  /// **'تصدير البيانات'**
  String get saExportData;

  /// No description provided for @saExportComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'التصدير قريباً'**
  String get saExportComingSoon;

  /// No description provided for @saStoresReport.
  ///
  /// In ar, this message translates to:
  /// **'تقرير المتاجر'**
  String get saStoresReport;

  /// No description provided for @saUsersReport.
  ///
  /// In ar, this message translates to:
  /// **'تقرير المستخدمين'**
  String get saUsersReport;

  /// No description provided for @saRevenueReport.
  ///
  /// In ar, this message translates to:
  /// **'تقرير الإيرادات'**
  String get saRevenueReport;

  /// No description provided for @saActivityLogs.
  ///
  /// In ar, this message translates to:
  /// **'سجل النشاط'**
  String get saActivityLogs;

  /// No description provided for @saWarnings.
  ///
  /// In ar, this message translates to:
  /// **'تحذيرات'**
  String get saWarnings;

  /// No description provided for @saZatcaEInvoicing.
  ///
  /// In ar, this message translates to:
  /// **'الفوترة الإلكترونية ZATCA'**
  String get saZatcaEInvoicing;

  /// No description provided for @saEnableEInvoicing.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الفوترة الإلكترونية لجميع المتاجر'**
  String get saEnableEInvoicing;

  /// No description provided for @saApiEnvironment.
  ///
  /// In ar, this message translates to:
  /// **'بيئة API'**
  String get saApiEnvironment;

  /// No description provided for @saTaxRateVat.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الضريبة (VAT)'**
  String get saTaxRateVat;

  /// No description provided for @saDefaultLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة الافتراضية'**
  String get saDefaultLanguage;

  /// No description provided for @saDefaultCurrency.
  ///
  /// In ar, this message translates to:
  /// **'العملة الافتراضية'**
  String get saDefaultCurrency;

  /// No description provided for @saTrialPeriodDays.
  ///
  /// In ar, this message translates to:
  /// **'فترة التجربة (أيام)'**
  String get saTrialPeriodDays;

  /// No description provided for @saResourceUsage.
  ///
  /// In ar, this message translates to:
  /// **'استخدام الموارد'**
  String get saResourceUsage;

  /// No description provided for @saResponseTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت الاستجابة'**
  String get saResponseTime;

  /// No description provided for @saDbRoundTrip.
  ///
  /// In ar, this message translates to:
  /// **'رحلة قاعدة البيانات'**
  String get saDbRoundTrip;

  /// No description provided for @saExcellent.
  ///
  /// In ar, this message translates to:
  /// **'ممتاز'**
  String get saExcellent;

  /// No description provided for @saGood.
  ///
  /// In ar, this message translates to:
  /// **'جيد'**
  String get saGood;

  /// No description provided for @saSlow.
  ///
  /// In ar, this message translates to:
  /// **'بطيء'**
  String get saSlow;

  /// No description provided for @saRoleUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الصلاحية'**
  String get saRoleUpdated;

  /// No description provided for @saNoInvoices.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فواتير'**
  String get saNoInvoices;

  /// No description provided for @saErrorLoading.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل البيانات'**
  String get saErrorLoading;

  /// No description provided for @saUpgradePlan.
  ///
  /// In ar, this message translates to:
  /// **'ترقية الخطة'**
  String get saUpgradePlan;

  /// No description provided for @saDowngradePlan.
  ///
  /// In ar, this message translates to:
  /// **'تخفيض الخطة'**
  String get saDowngradePlan;

  /// No description provided for @saEditPlan.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الخطة'**
  String get saEditPlan;

  /// No description provided for @saPaymentGateways.
  ///
  /// In ar, this message translates to:
  /// **'بوابات الدفع'**
  String get saPaymentGateways;

  /// No description provided for @saCreditDebitProcessing.
  ///
  /// In ar, this message translates to:
  /// **'معالجة بطاقات الائتمان والخصم'**
  String get saCreditDebitProcessing;

  /// No description provided for @saMultiMethodGateway.
  ///
  /// In ar, this message translates to:
  /// **'بوابة دفع متعددة الطرق'**
  String get saMultiMethodGateway;

  /// No description provided for @saBuyNowPayLater.
  ///
  /// In ar, this message translates to:
  /// **'اشتر الآن وادفع لاحقاً'**
  String get saBuyNowPayLater;

  /// No description provided for @saInstallmentPayments.
  ///
  /// In ar, this message translates to:
  /// **'الدفع بالتقسيط'**
  String get saInstallmentPayments;

  /// No description provided for @saActiveStores.
  ///
  /// In ar, this message translates to:
  /// **'المتاجر النشطة'**
  String get saActiveStores;

  /// No description provided for @saActiveSubscriptions.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراكات النشطة'**
  String get saActiveSubscriptions;

  /// No description provided for @saTrialSubscriptions.
  ///
  /// In ar, this message translates to:
  /// **'اشتراكات تجريبية'**
  String get saTrialSubscriptions;

  /// No description provided for @saNewSignups30d.
  ///
  /// In ar, this message translates to:
  /// **'تسجيلات جديدة (30 يوم)'**
  String get saNewSignups30d;

  /// No description provided for @saSubscribers.
  ///
  /// In ar, this message translates to:
  /// **'المشتركون'**
  String get saSubscribers;

  /// No description provided for @saPercentOfTotal.
  ///
  /// In ar, this message translates to:
  /// **'% من الإجمالي'**
  String get saPercentOfTotal;

  /// No description provided for @saDeactivateUserConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تعطيل هذا المستخدم؟ سيتم إلغاء وصوله فوراً.'**
  String get saDeactivateUserConfirm;

  /// No description provided for @saSuspendStoreConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من إيقاف هذا المتجر؟ سيتم تعطيل الوصول لجميع المستخدمين فوراً.'**
  String get saSuspendStoreConfirm;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @saReportsTitle.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get saReportsTitle;

  /// No description provided for @startDate.
  ///
  /// In ar, this message translates to:
  /// **'البداية'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In ar, this message translates to:
  /// **'النهاية'**
  String get endDate;

  /// No description provided for @customerPhoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم جوال العميل'**
  String get customerPhoneNumber;

  /// No description provided for @continueAction.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continueAction;

  /// No description provided for @continueWithCustomer.
  ///
  /// In ar, this message translates to:
  /// **'متابعة مع العميل'**
  String get continueWithCustomer;

  /// No description provided for @existingCustomers.
  ///
  /// In ar, this message translates to:
  /// **'عملاء موجودون'**
  String get existingCustomers;

  /// No description provided for @digitsRemaining.
  ///
  /// In ar, this message translates to:
  /// **'أرقام متبقية'**
  String get digitsRemaining;

  /// No description provided for @phoneNumberTooLong.
  ///
  /// In ar, this message translates to:
  /// **'الرقم طويل جداً'**
  String get phoneNumberTooLong;

  /// No description provided for @enterValidPhoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتف صحيح'**
  String get enterValidPhoneNumber;

  /// No description provided for @cancelledByAdmin.
  ///
  /// In ar, this message translates to:
  /// **'ألغاه المسؤول'**
  String get cancelledByAdmin;

  /// No description provided for @shiftOpenCloseReminders.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات فتح/إغلاق الورديات'**
  String get shiftOpenCloseReminders;

  /// No description provided for @setOrChangeManagerPin.
  ///
  /// In ar, this message translates to:
  /// **'تعيين أو تغيير رمز PIN للمدير'**
  String get setOrChangeManagerPin;

  /// No description provided for @dataSynchronizationStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة مزامنة البيانات'**
  String get dataSynchronizationStatus;

  /// No description provided for @reportBalanceSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'الميزانية العمومية'**
  String get reportBalanceSheetTitle;

  /// No description provided for @reportBalanceSheetAsOf.
  ///
  /// In ar, this message translates to:
  /// **'كما في {date}'**
  String reportBalanceSheetAsOf(String date);

  /// No description provided for @reportAssets.
  ///
  /// In ar, this message translates to:
  /// **'الأصول'**
  String get reportAssets;

  /// No description provided for @reportCurrentAssets.
  ///
  /// In ar, this message translates to:
  /// **'الأصول المتداولة'**
  String get reportCurrentAssets;

  /// No description provided for @reportCashInDrawer.
  ///
  /// In ar, this message translates to:
  /// **'النقد في الصندوق'**
  String get reportCashInDrawer;

  /// No description provided for @reportAccountsReceivable.
  ///
  /// In ar, this message translates to:
  /// **'ذمم مدينة (عملاء)'**
  String get reportAccountsReceivable;

  /// No description provided for @reportInventoryValue.
  ///
  /// In ar, this message translates to:
  /// **'قيمة المخزون'**
  String get reportInventoryValue;

  /// No description provided for @reportTotalCurrentAssets.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأصول المتداولة'**
  String get reportTotalCurrentAssets;

  /// No description provided for @reportTotalAssets.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأصول'**
  String get reportTotalAssets;

  /// No description provided for @reportLiabilities.
  ///
  /// In ar, this message translates to:
  /// **'الالتزامات'**
  String get reportLiabilities;

  /// No description provided for @reportCurrentLiabilities.
  ///
  /// In ar, this message translates to:
  /// **'الالتزامات المتداولة'**
  String get reportCurrentLiabilities;

  /// No description provided for @reportAccountsPayable.
  ///
  /// In ar, this message translates to:
  /// **'ذمم دائنة (موردون)'**
  String get reportAccountsPayable;

  /// No description provided for @reportTotalCurrentLiabilities.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الالتزامات المتداولة'**
  String get reportTotalCurrentLiabilities;

  /// No description provided for @reportTotalLiabilities.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الالتزامات'**
  String get reportTotalLiabilities;

  /// No description provided for @reportEquity.
  ///
  /// In ar, this message translates to:
  /// **'حقوق الملكية'**
  String get reportEquity;

  /// No description provided for @reportNetEquity.
  ///
  /// In ar, this message translates to:
  /// **'صافي حقوق الملكية'**
  String get reportNetEquity;

  /// No description provided for @reportAccountingEquation.
  ///
  /// In ar, this message translates to:
  /// **'معادلة المحاسبة'**
  String get reportAccountingEquation;

  /// No description provided for @reportAssetsEqualsLiabilitiesPlusEquity.
  ///
  /// In ar, this message translates to:
  /// **'الأصول = الالتزامات + حقوق الملكية'**
  String get reportAssetsEqualsLiabilitiesPlusEquity;

  /// No description provided for @reportCashFlowTitle.
  ///
  /// In ar, this message translates to:
  /// **'قائمة التدفق النقدي'**
  String get reportCashFlowTitle;

  /// No description provided for @reportNetCashFlow.
  ///
  /// In ar, this message translates to:
  /// **'صافي التدفق النقدي'**
  String get reportNetCashFlow;

  /// No description provided for @reportOperatingActivities.
  ///
  /// In ar, this message translates to:
  /// **'الأنشطة التشغيلية'**
  String get reportOperatingActivities;

  /// No description provided for @reportSalesReceipts.
  ///
  /// In ar, this message translates to:
  /// **'إيرادات المبيعات'**
  String get reportSalesReceipts;

  /// No description provided for @reportExpensesPaid.
  ///
  /// In ar, this message translates to:
  /// **'المصروفات المدفوعة'**
  String get reportExpensesPaid;

  /// No description provided for @reportTaxesPaidVat.
  ///
  /// In ar, this message translates to:
  /// **'الضرائب المدفوعة (ضريبة القيمة المضافة)'**
  String get reportTaxesPaidVat;

  /// No description provided for @reportInvestingActivities.
  ///
  /// In ar, this message translates to:
  /// **'الأنشطة الاستثمارية'**
  String get reportInvestingActivities;

  /// No description provided for @reportPurchasePayments.
  ///
  /// In ar, this message translates to:
  /// **'مدفوعات المشتريات'**
  String get reportPurchasePayments;

  /// No description provided for @reportFinancingActivities.
  ///
  /// In ar, this message translates to:
  /// **'الأنشطة التمويلية'**
  String get reportFinancingActivities;

  /// No description provided for @reportCashDeposit.
  ///
  /// In ar, this message translates to:
  /// **'إيداع نقدي'**
  String get reportCashDeposit;

  /// No description provided for @reportCashWithdrawal.
  ///
  /// In ar, this message translates to:
  /// **'سحب نقدي'**
  String get reportCashWithdrawal;

  /// No description provided for @reportThisQuarter.
  ///
  /// In ar, this message translates to:
  /// **'هذا الربع'**
  String get reportThisQuarter;

  /// No description provided for @reportThisYear.
  ///
  /// In ar, this message translates to:
  /// **'هذه السنة'**
  String get reportThisYear;

  /// No description provided for @reportQuarterly.
  ///
  /// In ar, this message translates to:
  /// **'ربع سنوي'**
  String get reportQuarterly;

  /// No description provided for @reportAnnual.
  ///
  /// In ar, this message translates to:
  /// **'سنوي'**
  String get reportAnnual;

  /// No description provided for @reportDebtAgingTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقرير أعمار الديون'**
  String get reportDebtAgingTitle;

  /// No description provided for @reportDebtBucket0to30.
  ///
  /// In ar, this message translates to:
  /// **'0-30 يوم'**
  String get reportDebtBucket0to30;

  /// No description provided for @reportDebtBucket31to60.
  ///
  /// In ar, this message translates to:
  /// **'31-60 يوم'**
  String get reportDebtBucket31to60;

  /// No description provided for @reportDebtBucket61to90.
  ///
  /// In ar, this message translates to:
  /// **'61-90 يوم'**
  String get reportDebtBucket61to90;

  /// No description provided for @reportDebtBucket90plus.
  ///
  /// In ar, this message translates to:
  /// **'+90 يوم'**
  String get reportDebtBucket90plus;

  /// No description provided for @reportTotalDebts.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الديون'**
  String get reportTotalDebts;

  /// No description provided for @reportNDays.
  ///
  /// In ar, this message translates to:
  /// **'{count} يوم'**
  String reportNDays(int count);

  /// No description provided for @reportComparisonTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقرير المقارنة'**
  String get reportComparisonTitle;

  /// No description provided for @reportIndicator.
  ///
  /// In ar, this message translates to:
  /// **'المؤشر'**
  String get reportIndicator;

  /// No description provided for @reportChange.
  ///
  /// In ar, this message translates to:
  /// **'التغيير'**
  String get reportChange;

  /// No description provided for @reportLastMonth.
  ///
  /// In ar, this message translates to:
  /// **'الشهر الماضي'**
  String get reportLastMonth;

  /// No description provided for @reportLastQuarter.
  ///
  /// In ar, this message translates to:
  /// **'الربع الماضي'**
  String get reportLastQuarter;

  /// No description provided for @reportLastYear.
  ///
  /// In ar, this message translates to:
  /// **'السنة الماضية'**
  String get reportLastYear;

  /// No description provided for @reportCurrentPeriod.
  ///
  /// In ar, this message translates to:
  /// **'الفترة الحالية'**
  String get reportCurrentPeriod;

  /// No description provided for @reportPreviousPeriod.
  ///
  /// In ar, this message translates to:
  /// **'الفترة السابقة'**
  String get reportPreviousPeriod;

  /// No description provided for @reportZakatTitle.
  ///
  /// In ar, this message translates to:
  /// **'حساب الزكاة'**
  String get reportZakatTitle;

  /// No description provided for @reportZakatDue.
  ///
  /// In ar, this message translates to:
  /// **'وجبت الزكاة'**
  String get reportZakatDue;

  /// No description provided for @reportZakatBelowNisab.
  ///
  /// In ar, this message translates to:
  /// **'لم يبلغ النصاب'**
  String get reportZakatBelowNisab;

  /// No description provided for @reportZakatAmountDue.
  ///
  /// In ar, this message translates to:
  /// **'مقدار الزكاة الواجبة'**
  String get reportZakatAmountDue;

  /// No description provided for @reportZakatRateOf.
  ///
  /// In ar, this message translates to:
  /// **'بنسبة {rate}% من وعاء الزكاة'**
  String reportZakatRateOf(String rate);

  /// No description provided for @reportNisabThreshold.
  ///
  /// In ar, this message translates to:
  /// **'النصاب الشرعي: {amount} ر.س'**
  String reportNisabThreshold(String amount);

  /// No description provided for @reportCurrentZakatBase.
  ///
  /// In ar, this message translates to:
  /// **'وعاء الزكاة الحالي: {amount} ر.س'**
  String reportCurrentZakatBase(String amount);

  /// No description provided for @reportNisabInfo.
  ///
  /// In ar, this message translates to:
  /// **'النصاب: {amount} ر.س (قيمة 85 جرام من الذهب تقريباً)'**
  String reportNisabInfo(String amount);

  /// No description provided for @reportZakatAssets.
  ///
  /// In ar, this message translates to:
  /// **'أصول الزكاة (+)'**
  String get reportZakatAssets;

  /// No description provided for @reportGoodsAndInventory.
  ///
  /// In ar, this message translates to:
  /// **'قيمة البضاعة والمخزون'**
  String get reportGoodsAndInventory;

  /// No description provided for @reportAvailableCash.
  ///
  /// In ar, this message translates to:
  /// **'النقد المتوفر'**
  String get reportAvailableCash;

  /// No description provided for @reportExpectedReceivables.
  ///
  /// In ar, this message translates to:
  /// **'الديون المتوقع تحصيلها'**
  String get reportExpectedReceivables;

  /// No description provided for @reportDeductions.
  ///
  /// In ar, this message translates to:
  /// **'الخصومات (-)'**
  String get reportDeductions;

  /// No description provided for @reportDebtsToSuppliers.
  ///
  /// In ar, this message translates to:
  /// **'الديون الواجبة للموردين'**
  String get reportDebtsToSuppliers;

  /// No description provided for @reportOtherLiabilities.
  ///
  /// In ar, this message translates to:
  /// **'التزامات أخرى'**
  String get reportOtherLiabilities;

  /// No description provided for @reportNetZakatBase.
  ///
  /// In ar, this message translates to:
  /// **'وعاء الزكاة الصافي'**
  String get reportNetZakatBase;

  /// No description provided for @reportZakatDisclaimer.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه: هذا الحساب تقريبي. يُنصح بمراجعة مختص شرعي لتحديد الزكاة الواجبة بدقة.'**
  String get reportZakatDisclaimer;

  /// No description provided for @reportPurchaseTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقرير المشتريات'**
  String get reportPurchaseTitle;

  /// No description provided for @reportPurchasesBySupplier.
  ///
  /// In ar, this message translates to:
  /// **'المشتريات حسب المورد'**
  String get reportPurchasesBySupplier;

  /// No description provided for @reportRecentInvoices.
  ///
  /// In ar, this message translates to:
  /// **'آخر الفواتير'**
  String get reportRecentInvoices;

  /// No description provided for @reportNoPurchasesInPeriod.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مشتريات في هذه الفترة'**
  String get reportNoPurchasesInPeriod;

  /// No description provided for @reportNInvoices.
  ///
  /// In ar, this message translates to:
  /// **'{count} فاتورة'**
  String reportNInvoices(int count);

  /// No description provided for @reportTotalTax.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الضريبة'**
  String get reportTotalTax;

  /// No description provided for @reportExportSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تصدير التقرير بنجاح'**
  String get reportExportSuccess;

  /// No description provided for @reportExportFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل التصدير: {error}'**
  String reportExportFailed(String error);

  /// No description provided for @saSaveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التغييرات'**
  String get saSaveChanges;

  /// No description provided for @saSaving.
  ///
  /// In ar, this message translates to:
  /// **'جاري الحفظ...'**
  String get saSaving;

  /// No description provided for @saDiscardChanges.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get saDiscardChanges;

  /// No description provided for @saConfirmSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get saConfirmSave;

  /// No description provided for @saPlatformSettingsConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هذه التغييرات تؤثر على جميع المؤسسات في المنصة. هل تريد الحفظ؟'**
  String get saPlatformSettingsConfirm;

  /// No description provided for @saPlatformSettingsSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ إعدادات المنصة بنجاح'**
  String get saPlatformSettingsSaved;

  /// No description provided for @saPlatformSettingsSaveFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل حفظ إعدادات المنصة'**
  String get saPlatformSettingsSaveFailed;

  /// No description provided for @saErrorLoadingSettings.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل الإعدادات'**
  String get saErrorLoadingSettings;

  /// No description provided for @saEnvProduction.
  ///
  /// In ar, this message translates to:
  /// **'الإنتاج'**
  String get saEnvProduction;

  /// No description provided for @saEnvSandbox.
  ///
  /// In ar, this message translates to:
  /// **'بيئة الاختبار'**
  String get saEnvSandbox;

  /// No description provided for @saMoyasarDescription.
  ///
  /// In ar, this message translates to:
  /// **'معالجة بطاقات الائتمان والخصم'**
  String get saMoyasarDescription;

  /// No description provided for @saHyperpayDescription.
  ///
  /// In ar, this message translates to:
  /// **'بوابة دفع متعددة الطرق'**
  String get saHyperpayDescription;

  /// No description provided for @saTabbyDescription.
  ///
  /// In ar, this message translates to:
  /// **'اشترِ الآن وادفع لاحقاً'**
  String get saTabbyDescription;

  /// No description provided for @saTamaraDescription.
  ///
  /// In ar, this message translates to:
  /// **'دفعات بالتقسيط'**
  String get saTamaraDescription;

  /// No description provided for @saGeneral.
  ///
  /// In ar, this message translates to:
  /// **'عام'**
  String get saGeneral;

  /// No description provided for @saLanguageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get saLanguageArabic;

  /// No description provided for @saLanguageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'الإنجليزية'**
  String get saLanguageEnglish;

  /// No description provided for @saAuditLog.
  ///
  /// In ar, this message translates to:
  /// **'سجل التدقيق'**
  String get saAuditLog;

  /// No description provided for @saAuditLogRefresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get saAuditLogRefresh;

  /// No description provided for @saAuditFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get saAuditFilterAll;

  /// No description provided for @saAuditFilterAuth.
  ///
  /// In ar, this message translates to:
  /// **'مصادقة'**
  String get saAuditFilterAuth;

  /// No description provided for @saAuditFilterStore.
  ///
  /// In ar, this message translates to:
  /// **'متجر'**
  String get saAuditFilterStore;

  /// No description provided for @saAuditFilterUser.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم'**
  String get saAuditFilterUser;

  /// No description provided for @saAuditFilterSubscription.
  ///
  /// In ar, this message translates to:
  /// **'اشتراك'**
  String get saAuditFilterSubscription;

  /// No description provided for @saAuditSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالبريد أو المعرّف أو الإجراء...'**
  String get saAuditSearchHint;

  /// No description provided for @saAuditLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل تحميل سجل التدقيق'**
  String get saAuditLoadFailed;

  /// No description provided for @saAuditLoadRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get saAuditLoadRetry;

  /// No description provided for @saAuditNoEntries.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سجلات تدقيق'**
  String get saAuditNoEntries;

  /// No description provided for @saAuditEntryBy.
  ///
  /// In ar, this message translates to:
  /// **'بواسطة {email}'**
  String saAuditEntryBy(String email);

  /// No description provided for @saReportsExportComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'التصدير غير متاح حالياً — سيضاف قريباً'**
  String get saReportsExportComingSoon;

  /// No description provided for @saSystemHealthMetricsNote.
  ///
  /// In ar, this message translates to:
  /// **'مقاييس المعالج/الذاكرة/القرص تتطلب نقطة خادم مخصصة — غير متصلة بعد'**
  String get saSystemHealthMetricsNote;

  /// No description provided for @saMfaScanQr.
  ///
  /// In ar, this message translates to:
  /// **'امسح رمز QR في تطبيق المصادقة'**
  String get saMfaScanQr;

  /// No description provided for @saMfaSecretFallback.
  ///
  /// In ar, this message translates to:
  /// **'أو أدخل هذا المفتاح يدوياً:'**
  String get saMfaSecretFallback;

  /// No description provided for @saMfaCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ'**
  String get saMfaCopied;

  /// No description provided for @saErrorGeneric.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ ما'**
  String get saErrorGeneric;

  /// No description provided for @saErrorNetwork.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الشبكة — تحقق من اتصالك'**
  String get saErrorNetwork;

  /// No description provided for @saErrorRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get saErrorRetry;

  /// No description provided for @saErrorTechnical.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل تقنية'**
  String get saErrorTechnical;

  /// No description provided for @saNext.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get saNext;

  /// No description provided for @saBackToLogin.
  ///
  /// In ar, this message translates to:
  /// **'العودة لتسجيل الدخول'**
  String get saBackToLogin;

  /// No description provided for @saPopularBadge.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر طلباً'**
  String get saPopularBadge;

  /// No description provided for @saRefresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get saRefresh;

  /// No description provided for @saPlanUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الباقة'**
  String get saPlanUpdated;

  /// No description provided for @saRenewal.
  ///
  /// In ar, this message translates to:
  /// **'التجديد'**
  String get saRenewal;

  /// No description provided for @saBusinessTypeGrocery.
  ///
  /// In ar, this message translates to:
  /// **'بقالة'**
  String get saBusinessTypeGrocery;

  /// No description provided for @saBusinessTypeRestaurant.
  ///
  /// In ar, this message translates to:
  /// **'مطعم'**
  String get saBusinessTypeRestaurant;

  /// No description provided for @saBusinessTypeRetail.
  ///
  /// In ar, this message translates to:
  /// **'تجزئة'**
  String get saBusinessTypeRetail;

  /// No description provided for @saBusinessTypeServices.
  ///
  /// In ar, this message translates to:
  /// **'خدمات'**
  String get saBusinessTypeServices;

  /// No description provided for @saNoPlanRevenueData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات إيرادات للباقات'**
  String get saNoPlanRevenueData;

  /// No description provided for @saNoStoreRevenueData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات إيرادات للمتاجر'**
  String get saNoStoreRevenueData;

  /// No description provided for @saNoActiveUserData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات للمستخدمين النشطين'**
  String get saNoActiveUserData;

  /// No description provided for @saNoTransactionData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات معاملات'**
  String get saNoTransactionData;

  /// No description provided for @saMfaSetupTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعداد المصادقة الثنائية'**
  String get saMfaSetupTitle;

  /// No description provided for @saMfaVerifyTitle.
  ///
  /// In ar, this message translates to:
  /// **'التحقق الثنائي'**
  String get saMfaVerifyTitle;

  /// No description provided for @saMfaEnrollmentInstruction.
  ///
  /// In ar, this message translates to:
  /// **'امسح رمز QR بتطبيق المصادقة (Google Authenticator أو Authy وغيرها) ثم أدخل الرمز المكوّن من 6 أرقام لإكمال الإعداد.'**
  String get saMfaEnrollmentInstruction;

  /// No description provided for @saMfaVerifyInstruction.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز المكوّن من 6 أرقام من تطبيق المصادقة.'**
  String get saMfaVerifyInstruction;

  /// No description provided for @saMfaCopy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get saMfaCopy;

  /// No description provided for @saMfaCompleteSetup.
  ///
  /// In ar, this message translates to:
  /// **'إكمال الإعداد'**
  String get saMfaCompleteSetup;

  /// No description provided for @saMfaVerifyButton.
  ///
  /// In ar, this message translates to:
  /// **'تحقق'**
  String get saMfaVerifyButton;

  /// No description provided for @saMfaEnterValidCode.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمزاً صحيحاً مكوّناً من 6 أرقام'**
  String get saMfaEnterValidCode;

  /// No description provided for @saMfaTooManyAttempts.
  ///
  /// In ar, this message translates to:
  /// **'محاولات فاشلة كثيرة. تم القفل لمدة 30 دقيقة.'**
  String get saMfaTooManyAttempts;

  /// No description provided for @saMfaAccountLocked.
  ///
  /// In ar, this message translates to:
  /// **'تم قفل الحساب. حاول مجدداً خلال {minutes} دقيقة.'**
  String saMfaAccountLocked(int minutes);

  /// No description provided for @saMfaInvalidCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز غير صحيح. {remaining} محاولات متبقية.'**
  String saMfaInvalidCode(int remaining);

  /// No description provided for @saMfaEnrollmentFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل تسجيل المصادقة الثنائية. تأكد من تفعيل MFA في مشروع Supabase.'**
  String get saMfaEnrollmentFailed;

  /// No description provided for @saMfaEnrollmentNoData.
  ///
  /// In ar, this message translates to:
  /// **'لم ترجع عملية تسجيل TOTP أي بيانات.'**
  String get saMfaEnrollmentNoData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'bn',
        'en',
        'fil',
        'hi',
        'id',
        'ur'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'fil':
      return AppLocalizationsFil();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
