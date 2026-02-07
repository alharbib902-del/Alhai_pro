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
  /// **'مدير الفرع'**
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
