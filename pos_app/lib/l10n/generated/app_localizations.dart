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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  /// **'الإجمالي'**
  String get total;

  /// No description provided for @subtotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع الفرعي'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In ar, this message translates to:
  /// **'الخصم'**
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
  /// **'نفذ المخزون'**
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
  /// **'{count} فرع'**
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
  /// **'سيتم إضافة هذه الميزة قريباً'**
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
  /// **'{count} طلب اليوم'**
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
  /// **'قيد الانتظار'**
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
  /// **'منذ {count} دقائق'**
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
  /// **'إدارة المتجر'**
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
  /// **'المنتج غير موجود'**
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
  /// **'الاسم'**
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
  /// **'منذ {count} ساعة'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} يوم'**
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
  /// **'{count} تصنيف'**
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
  /// **'{count} فاتورة بانتظار الدفع'**
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
  /// **'نقداً'**
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
  /// **'الحالة: الكل'**
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
  /// **'ملغاة'**
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
  /// **'PDF'**
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
  /// **'تم تحديد {count}'**
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
  /// **'أخرى'**
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
  String get invoiceNumberLabel;

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
  /// **'معلقة'**
  String get pendingStatus;

  /// No description provided for @voidedStatus.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get voidedStatus;

  /// No description provided for @storeName.
  ///
  /// In ar, this message translates to:
  /// **'سوبرماركت الحي'**
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
  /// **'نوع التسوية'**
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
  /// **'سبب التسوية'**
  String get adjustmentReason;

  /// No description provided for @adjustmentDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ التسوية'**
  String get adjustmentDate;

  /// No description provided for @saveAdjustment.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التسوية'**
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
  /// **'العميل'**
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
  /// **'الأصناف المرتجعة ({count})'**
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
  /// **'لم يتم العثور على الفاتورة'**
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

  /// No description provided for @customerCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} عميل'**
  String customerCount(String count);

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
  /// **'تم إضافة العميل بنجاح'**
  String get customerAddedSuccess;

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
  /// **'الكاشير'**
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
  /// **'إعدادات الضريبة'**
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
  /// **'اسم المستخدم'**
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
  /// **'رقم الضريبة'**
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
  /// **'رمز QR على الفاتورة'**
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
