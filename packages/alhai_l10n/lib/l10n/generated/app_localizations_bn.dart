// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'পয়েন্ট অফ সেল';

  @override
  String get login => 'লগ ইন';

  @override
  String get logout => 'লগ আউট';

  @override
  String get welcome => 'স্বাগতম';

  @override
  String get welcomeBack => 'ফিরে আসায় স্বাগতম';

  @override
  String get phone => 'ফোন নম্বর';

  @override
  String get phoneHint => '05xxxxxxxx';

  @override
  String get phoneRequired => 'ফোন নম্বর প্রয়োজন';

  @override
  String get phoneInvalid => 'অবৈধ ফোন নম্বর';

  @override
  String get otp => 'যাচাইকরণ কোড';

  @override
  String get otpHint => 'যাচাইকরণ কোড লিখুন';

  @override
  String get otpSent => 'যাচাইকরণ কোড পাঠানো হয়েছে';

  @override
  String get otpResend => 'কোড পুনরায় পাঠান';

  @override
  String get otpExpired => 'যাচাইকরণ কোডের মেয়াদ শেষ';

  @override
  String get otpInvalid => 'অবৈধ যাচাইকরণ কোড';

  @override
  String otpResendIn(int seconds) {
    return '$seconds সেকেন্ডে পুনরায় পাঠান';
  }

  @override
  String get pin => 'পিন কোড';

  @override
  String get pinHint => 'পিন কোড লিখুন';

  @override
  String get pinRequired => 'পিন কোড প্রয়োজন';

  @override
  String get pinInvalid => 'অবৈধ পিন কোড';

  @override
  String pinAttemptsRemaining(int count) {
    return 'অবশিষ্ট চেষ্টা: $count';
  }

  @override
  String pinLocked(int minutes) {
    return 'অ্যাকাউন্ট লক হয়েছে। $minutes মিনিট পরে চেষ্টা করুন';
  }

  @override
  String get home => 'হোম';

  @override
  String get dashboard => 'ড্যাশবোর্ড';

  @override
  String get pos => 'পয়েন্ট অফ সেল';

  @override
  String get products => 'পণ্য';

  @override
  String get categories => 'বিভাগ';

  @override
  String get inventory => 'ইনভেন্টরি';

  @override
  String get customers => 'গ্রাহক';

  @override
  String get orders => 'অর্ডার';

  @override
  String get invoices => 'চালান';

  @override
  String get reports => 'রিপোর্ট';

  @override
  String get settings => 'সেটিংস';

  @override
  String get sales => 'বিক্রয়';

  @override
  String get salesAnalytics => 'বিক্রয় বিশ্লেষণ';

  @override
  String get refund => 'ফেরত';

  @override
  String get todaySales => 'আজকের বিক্রয়';

  @override
  String get totalSales => 'মোট বিক্রয়';

  @override
  String get averageSale => 'গড় বিক্রয়';

  @override
  String get cart => 'কার্ট';

  @override
  String get cartEmpty => 'কার্ট খালি';

  @override
  String get addToCart => 'কার্টে যোগ করুন';

  @override
  String get removeFromCart => 'কার্ট থেকে সরান';

  @override
  String get clearCart => 'কার্ট খালি করুন';

  @override
  String get checkout => 'চেকআউট';

  @override
  String get payment => 'পেমেন্ট';

  @override
  String get paymentMethod => 'পেমেন্ট পদ্ধতি';

  @override
  String get cash => 'নগদ';

  @override
  String get card => 'কার্ড';

  @override
  String get credit => 'বাকি';

  @override
  String get transfer => 'ট্রান্সফার';

  @override
  String get paymentSuccess => 'পেমেন্ট সফল';

  @override
  String get paymentFailed => 'পেমেন্ট ব্যর্থ';

  @override
  String get price => 'মূল্য';

  @override
  String get quantity => 'পরিমাণ';

  @override
  String get total => 'মোট';

  @override
  String get subtotal => 'উপমোট';

  @override
  String get discount => 'ছাড়';

  @override
  String get tax => 'কর';

  @override
  String get vat => 'ভ্যাট';

  @override
  String get grandTotal => 'সর্বমোট';

  @override
  String get product => 'পণ্য';

  @override
  String get productName => 'পণ্যের নাম';

  @override
  String get productCode => 'পণ্য কোড';

  @override
  String get barcode => 'বারকোড';

  @override
  String get sku => 'SKU';

  @override
  String get stock => 'স্টক';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String get inStock => 'উপলব্ধ';

  @override
  String get customer => 'গ্রাহক';

  @override
  String get customerName => 'গ্রাহকের নাম';

  @override
  String get customerPhone => 'গ্রাহকের ফোন';

  @override
  String get debt => 'ঋণ';

  @override
  String get balance => 'ব্যালেন্স';

  @override
  String get search => 'অনুসন্ধান';

  @override
  String get searchHint => 'এখানে অনুসন্ধান করুন...';

  @override
  String get filter => 'ফিল্টার';

  @override
  String get sort => 'সাজান';

  @override
  String get all => 'সব';

  @override
  String get add => 'যোগ করুন';

  @override
  String get edit => 'সম্পাদনা';

  @override
  String get delete => 'মুছুন';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get cancel => 'বাতিল';

  @override
  String get confirm => 'নিশ্চিত';

  @override
  String get close => 'বন্ধ';

  @override
  String get back => 'পেছনে';

  @override
  String get next => 'পরবর্তী';

  @override
  String get done => 'সম্পন্ন';

  @override
  String get submit => 'জমা দিন';

  @override
  String get retry => 'পুনরায় চেষ্টা';

  @override
  String get loading => 'লোড হচ্ছে...';

  @override
  String get noData => 'কোনো ডেটা নেই';

  @override
  String get noResults => 'কোনো ফলাফল নেই';

  @override
  String get error => 'ত্রুটি';

  @override
  String pageNotFoundPath(String path) {
    return 'الصفحة غير موجودة: $path';
  }

  @override
  String get noInvoiceDataAvailable => 'لا تتوفر بيانات الفاتورة';

  @override
  String get errorOccurred => 'একটি ত্রুটি হয়েছে';

  @override
  String get tryAgain => 'আবার চেষ্টা করুন';

  @override
  String get connectionError => 'সংযোগ ত্রুটি';

  @override
  String get noInternet => 'ইন্টারনেট সংযোগ নেই';

  @override
  String get offline => 'অফলাইন';

  @override
  String get online => 'অনলাইন';

  @override
  String get success => 'সফল';

  @override
  String get warning => 'সতর্কতা';

  @override
  String get info => 'তথ্য';

  @override
  String get yes => 'হ্যাঁ';

  @override
  String get no => 'না';

  @override
  String get today => 'আজ';

  @override
  String get yesterday => 'গতকাল';

  @override
  String get thisWeek => 'এই সপ্তাহ';

  @override
  String get thisMonth => 'এই মাস';

  @override
  String get shift => 'শিফট';

  @override
  String get openShift => 'শিফট খুলুন';

  @override
  String get closeShift => 'শিফট বন্ধ করুন';

  @override
  String get shiftSummary => 'শিফট সারাংশ';

  @override
  String get cashDrawer => 'ক্যাশ ড্রয়ার';

  @override
  String get receipt => 'রসিদ';

  @override
  String get printReceipt => 'রসিদ প্রিন্ট করুন';

  @override
  String get shareReceipt => 'রসিদ শেয়ার করুন';

  @override
  String get sync => 'সিঙ্ক';

  @override
  String get syncing => 'সিঙ্ক হচ্ছে...';

  @override
  String get syncComplete => 'সিঙ্ক সম্পূর্ণ';

  @override
  String get syncFailed => 'সিঙ্ক ব্যর্থ';

  @override
  String get lastSync => 'শেষ সিঙ্ক';

  @override
  String get language => 'ভাষা';

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
  String get theme => 'থিম';

  @override
  String get darkMode => 'ডার্ক মোড';

  @override
  String get lightMode => 'লাইট মোড';

  @override
  String get systemMode => 'সিস্টেম মোড';

  @override
  String get notifications => 'বিজ্ঞপ্তি';

  @override
  String get security => 'নিরাপত্তা';

  @override
  String get printer => 'প্রিন্টার';

  @override
  String get backup => 'ব্যাকআপ';

  @override
  String get help => 'সাহায্য';

  @override
  String get about => 'সম্পর্কে';

  @override
  String get version => 'সংস্করণ';

  @override
  String get copyright => 'সর্বস্বত্ব সংরক্ষিত';

  @override
  String get deleteConfirmTitle => 'মুছে ফেলা নিশ্চিত করুন';

  @override
  String get deleteConfirmMessage => 'আপনি কি নিশ্চিত মুছে ফেলতে চান?';

  @override
  String get logoutConfirmTitle => 'লগ আউট নিশ্চিত করুন';

  @override
  String get logoutConfirmMessage => 'আপনি কি নিশ্চিত লগ আউট করতে চান?';

  @override
  String get requiredField => 'এই ক্ষেত্রটি প্রয়োজনীয়';

  @override
  String get invalidFormat => 'অবৈধ ফরম্যাট';

  @override
  String minLength(int min) {
    return 'ন্যূনতম $min অক্ষর হতে হবে';
  }

  @override
  String maxLength(int max) {
    return '$max অক্ষরের কম হতে হবে';
  }

  @override
  String get welcomeTitle => 'ফিরে আসায় স্বাগতম! 👋';

  @override
  String get welcomeSubtitle =>
      'আপনার দোকান সহজে এবং দ্রুত পরিচালনা করতে সাইন ইন করুন';

  @override
  String get welcomeSubtitleShort => 'আপনার দোকান পরিচালনা করতে সাইন ইন করুন';

  @override
  String get brandName => 'Al-Hal POS';

  @override
  String get brandTagline => 'স্মার্ট পয়েন্ট অফ সেল সিস্টেম';

  @override
  String get enterPhoneToContinue => 'চালিয়ে যেতে আপনার ফোন নম্বর লিখুন';

  @override
  String get pleaseEnterValidPhone => 'অনুগ্রহ করে একটি বৈধ ফোন নম্বর লিখুন';

  @override
  String get otpSentViaWhatsApp =>
      'WhatsApp-এর মাধ্যমে যাচাইকরণ কোড পাঠানো হয়েছে';

  @override
  String get otpResent => 'যাচাইকরণ কোড পুনরায় পাঠানো হয়েছে';

  @override
  String get enterOtpFully => 'অনুগ্রহ করে সম্পূর্ণ যাচাইকরণ কোড লিখুন';

  @override
  String get maxAttemptsReached =>
      'সর্বোচ্চ চেষ্টা শেষ। অনুগ্রহ করে একটি নতুন কোড অনুরোধ করুন';

  @override
  String waitMinutes(int minutes) {
    return 'সর্বোচ্চ চেষ্টা শেষ। $minutes মিনিট অপেক্ষা করুন';
  }

  @override
  String waitSeconds(int seconds) {
    return 'অনুগ্রহ করে $seconds সেকেন্ড অপেক্ষা করুন';
  }

  @override
  String resendIn(String time) {
    return 'পুনরায় পাঠান ($time)';
  }

  @override
  String get resendCode => 'কোড পুনরায় পাঠান';

  @override
  String get changeNumber => 'নম্বর পরিবর্তন করুন';

  @override
  String get verificationCode => 'যাচাইকরণ কোড';

  @override
  String remainingAttempts(int count) {
    return 'অবশিষ্ট চেষ্টা: $count';
  }

  @override
  String get technicalSupport => 'প্রযুক্তিগত সহায়তা';

  @override
  String get privacyPolicy => 'গোপনীয়তা নীতি';

  @override
  String get termsAndConditions => 'শর্তাবলী';

  @override
  String get allRightsReserved => '© 2026 আল-হাল সিস্টেম। সর্বস্বত্ব সংরক্ষিত।';

  @override
  String get dayMode => 'দিনের মোড';

  @override
  String get nightMode => 'রাতের মোড';

  @override
  String get selectBranch => 'শাখা নির্বাচন করুন';

  @override
  String get selectBranchDesc => 'আপনি যে শাখায় কাজ করতে চান তা নির্বাচন করুন';

  @override
  String get availableBranches => 'উপলব্ধ শাখা';

  @override
  String branchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count শাখা',
      one: '1 শাখা',
      zero: 'কোনো শাখা নেই',
    );
    return '$_temp0';
  }

  @override
  String branchSelected(String name) {
    return '$name নির্বাচিত';
  }

  @override
  String get addBranch => 'নতুন শাখা যোগ করুন';

  @override
  String get comingSoon => 'এই বৈশিষ্ট্যটি শীঘ্রই আসছে';

  @override
  String get tryDifferentSearch => 'বিভিন্ন শব্দ দিয়ে অনুসন্ধান করুন';

  @override
  String get selectLanguage => 'ভাষা নির্বাচন করুন';

  @override
  String get languageChangeInfo =>
      'আপনার পছন্দের প্রদর্শন ভাষা নির্বাচন করুন। পরিবর্তনগুলি অবিলম্বে প্রয়োগ করা হবে।';

  @override
  String get centralManagement => 'কেন্দ্রীয় ব্যবস্থাপনা';

  @override
  String get centralManagementDesc =>
      'একটি স্থান থেকে আপনার সমস্ত শাখা এবং গুদাম নিয়ন্ত্রণ করুন। সমস্ত POS পয়েন্টে তাত্ক্ষণিক রিপোর্ট এবং ইনভেন্টরি সিঙ্ক পান।';

  @override
  String get selectBranchToContinue => 'চালিয়ে যেতে শাখা নির্বাচন করুন';

  @override
  String get youHaveAccessToBranches =>
      'আপনার নিম্নলিখিত শাখাগুলিতে অ্যাক্সেস আছে। শুরু করতে একটি নির্বাচন করুন।';

  @override
  String get searchForBranch => 'শাখা অনুসন্ধান করুন...';

  @override
  String get openNow => 'এখন খোলা';

  @override
  String closedOpensAt(String time) {
    return 'বন্ধ (খোলে $time)';
  }

  @override
  String get loggedInAs => 'হিসাবে লগইন';

  @override
  String get support247 => '24/7 সহায়তা';

  @override
  String get analyticsTools => 'বিশ্লেষণ সরঞ্জাম';

  @override
  String get uptime => 'আপটাইম';

  @override
  String get dashboardTitle => 'ড্যাশবোর্ড';

  @override
  String get searchPlaceholder => 'সাধারণ অনুসন্ধান...';

  @override
  String get mainBranch => 'প্রধান শাখা (রিয়াদ)';

  @override
  String get todaySalesLabel => 'আজকের বিক্রয়';

  @override
  String get ordersCountLabel => 'অর্ডার সংখ্যা';

  @override
  String get newCustomersLabel => 'নতুন গ্রাহক';

  @override
  String get stockAlertsLabel => 'স্টক সতর্কতা';

  @override
  String get productsUnit => 'পণ্য';

  @override
  String get salesAnalysis => 'বিক্রয় বিশ্লেষণ';

  @override
  String get storePerformance => 'এই সপ্তাহের দোকানের কর্মক্ষমতা';

  @override
  String get weekly => 'সাপ্তাহিক';

  @override
  String get monthly => 'মাসিক';

  @override
  String get yearly => 'বার্ষিক';

  @override
  String get quickAction => 'দ্রুত কার্য';

  @override
  String get newSale => 'নতুন বিক্রয়';

  @override
  String get addProduct => 'পণ্য যোগ করুন';

  @override
  String get returnItem => 'ফেরত';

  @override
  String get dailyReport => 'দৈনিক রিপোর্ট';

  @override
  String get closeDay => 'দিন বন্ধ করুন';

  @override
  String get topSelling => 'সবচেয়ে বেশি বিক্রি';

  @override
  String ordersToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'আজ $count অর্ডার',
      one: 'আজ 1 অর্ডার',
      zero: 'আজ কোনো অর্ডার নেই',
    );
    return '$_temp0';
  }

  @override
  String get recentTransactions => 'সাম্প্রতিক লেনদেন';

  @override
  String get viewAll => 'সব দেখুন';

  @override
  String get orderNumber => 'অর্ডার #';

  @override
  String get time => 'সময়';

  @override
  String get status => 'অবস্থা';

  @override
  String get amount => 'পরিমাণ';

  @override
  String get action => 'কার্য';

  @override
  String get completed => 'সম্পন্ন';

  @override
  String get returned => 'ফেরত';

  @override
  String get pending => 'অপেক্ষমান';

  @override
  String get cancelled => 'বাতিল';

  @override
  String get guestCustomer => 'অতিথি গ্রাহক';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count মিনিট আগে',
      one: '1 মিনিট আগে',
    );
    return '$_temp0';
  }

  @override
  String get posSystem => 'পয়েন্ট অফ সেল সিস্টেম';

  @override
  String get branchManager => 'শাখা ব্যবস্থাপক';

  @override
  String get settingsSection => 'সেটিংস';

  @override
  String get systemSettings => 'সিস্টেম সেটিংস';

  @override
  String get sar => 'SAR';

  @override
  String get daily => 'দৈনিক';

  @override
  String get goodMorning => 'সুপ্রভাত';

  @override
  String get goodEvening => 'শুভ সন্ধ্যা';

  @override
  String get cashCustomer => 'নগদ গ্রাহক';

  @override
  String get noTransactionsToday => 'আজ কোনো লেনদেন নেই';

  @override
  String get comparedToYesterday => 'গতকালের তুলনায়';

  @override
  String get ordersText => 'আজকের অর্ডার';

  @override
  String get storeManagement => 'স্টোর ম্যানেজমেন্ট';

  @override
  String get finance => 'অর্থ';

  @override
  String get teamSection => 'টিম';

  @override
  String get fullscreen => 'পূর্ণ পর্দা';

  @override
  String goodMorningName(String name) {
    return 'সুপ্রভাত, $name!';
  }

  @override
  String goodEveningName(String name) {
    return 'শুভ সন্ধ্যা, $name!';
  }

  @override
  String get shoppingCart => 'শপিং কার্ট';

  @override
  String get selectOrSearchCustomer => 'গ্রাহক নির্বাচন বা অনুসন্ধান করুন';

  @override
  String get newCustomer => 'নতুন';

  @override
  String get draft => 'খসড়া';

  @override
  String get pay => 'পেমেন্ট';

  @override
  String get haveCoupon => 'আপনার কি ডিসকাউন্ট কুপন আছে?';

  @override
  String discountPercent(String percent) {
    return 'ছাড় $percent%';
  }

  @override
  String get openDrawer => 'ড্রয়ার খুলুন';

  @override
  String get suspend => 'স্থগিত';

  @override
  String get quantitySoldOut => 'স্টক শেষ';

  @override
  String get noProducts => 'কোন পণ্য নেই';

  @override
  String get addProductsToStart => 'শুরু করতে পণ্য যোগ করুন';

  @override
  String get undoComingSoon => 'পূর্বাবস্থায় ফেরান (শীঘ্রই আসছে)';

  @override
  String get employees => 'কর্মচারী';

  @override
  String get loyaltyProgram => 'লয়্যালটি প্রোগ্রাম';

  @override
  String get newBadge => 'নতুন';

  @override
  String get technicalSupportShort => 'প্রযুক্তি সহায়তা';

  @override
  String get productDetails => 'পণ্যের বিবরণ';

  @override
  String get stockMovements => 'স্টক চলাচল';

  @override
  String get priceHistory => 'মূল্য ইতিহাস';

  @override
  String get salesHistory => 'বিক্রয় ইতিহাস';

  @override
  String get available => 'উপলব্ধ';

  @override
  String get alertLevel => 'সতর্কতা স্তর';

  @override
  String get reorderPoint => 'পুনর্অর্ডার পয়েন্ট';

  @override
  String get revenue => 'Revenue';

  @override
  String get supplier => 'সরবরাহকারী';

  @override
  String get lastSale => 'শেষ বিক্রয়';

  @override
  String get printLabel => 'লেবেল প্রিন্ট করুন';

  @override
  String get copied => 'কপি হয়েছে';

  @override
  String copiedToClipboard(String label) {
    return '$label কপি হয়েছে';
  }

  @override
  String get active => 'সক্রিয়';

  @override
  String get inactive => 'নিষ্ক্রিয়';

  @override
  String get profitMargin => 'লাভ মার্জিন';

  @override
  String get sellingPrice => 'বিক্রয় মূল্য';

  @override
  String get costPrice => 'খরচ মূল্য';

  @override
  String get description => 'বিবরণ';

  @override
  String get noDescription => 'কোনো বিবরণ নেই';

  @override
  String get productNotFound => 'পণ্য পাওয়া যায়নি';

  @override
  String get stockStatus => 'স্টক অবস্থা';

  @override
  String get currentStock => 'বর্তমান স্টক';

  @override
  String get unit => 'ইউনিট';

  @override
  String get units => 'ইউনিট';

  @override
  String get date => 'তারিখ';

  @override
  String get type => 'ধরন';

  @override
  String get reference => 'রেফারেন্স';

  @override
  String get newBalance => 'নতুন ব্যালেন্স';

  @override
  String get oldPrice => 'পুরানো মূল্য';

  @override
  String get newPrice => 'নতুন মূল্য';

  @override
  String get reason => 'কারণ';

  @override
  String get invoiceNumber => 'চালান নম্বর';

  @override
  String get categoryLabel => 'বিভাগ';

  @override
  String get uncategorized => 'শ্রেণীবিহীন';

  @override
  String get noSupplier => 'কোনো সরবরাহকারী নেই';

  @override
  String get moreOptions => 'আরও অপশন';

  @override
  String get noStockMovements => 'কোনো স্টক চলাচল নেই';

  @override
  String get noPriceHistory => 'কোনো মূল্য ইতিহাস নেই';

  @override
  String get noSalesHistory => 'কোনো বিক্রয় ইতিহাস নেই';

  @override
  String get sale => 'বিক্রয়';

  @override
  String get purchase => 'ক্রয়';

  @override
  String get adjustment => 'সমন্বয়';

  @override
  String get returnText => 'ফেরত';

  @override
  String get waste => 'অপচয়';

  @override
  String get initialStock => 'প্রারম্ভিক স্টক';

  @override
  String get searchByNameOrBarcode => 'নাম বা বারকোড দিয়ে অনুসন্ধান করুন...';

  @override
  String get hideFilters => 'ফিল্টার লুকান';

  @override
  String get showFilters => 'ফিল্টার দেখান';

  @override
  String get sortByName => 'নাম';

  @override
  String get sortByPrice => 'মূল্য';

  @override
  String get sortByStock => 'স্টক';

  @override
  String get sortByRecent => 'সাম্প্রতিক';

  @override
  String get allItems => 'সব';

  @override
  String get clearFilters => 'ফিল্টার মুছুন';

  @override
  String get noBarcode => 'বারকোড নেই';

  @override
  String stockCount(int count) {
    return 'স্টক: $count';
  }

  @override
  String get saveChanges => 'পরিবর্তন সংরক্ষণ করুন';

  @override
  String get addTheProduct => 'পণ্য যোগ করুন';

  @override
  String get editProduct => 'পণ্য সম্পাদনা করুন';

  @override
  String get newProduct => 'নতুন পণ্য';

  @override
  String get minimumQuantity => 'ন্যূনতম পরিমাণ';

  @override
  String get selectCategory => 'বিভাগ নির্বাচন করুন';

  @override
  String get productImage => 'পণ্যের ছবি';

  @override
  String get trackInventory => 'ইনভেন্টরি ট্র্যাক করুন';

  @override
  String get productSavedSuccess => 'পণ্য সফলভাবে সংরক্ষিত হয়েছে';

  @override
  String get productAddedSuccess => 'পণ্য সফলভাবে যোগ করা হয়েছে';

  @override
  String get scanBarcode => 'বারকোড স্ক্যান করুন';

  @override
  String get activeProduct => 'সক্রিয় পণ্য';

  @override
  String get currency => 'SAR';

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ঘন্টা আগে',
      one: '1 ঘন্টা আগে',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count দিন আগে',
      one: '1 দিন আগে',
    );
    return '$_temp0';
  }

  @override
  String get supplierPriceUpdate => 'সরবরাহকারীর মূল্য আপডেট';

  @override
  String get costIncrease => 'খরচ বৃদ্ধি';

  @override
  String get duplicateProduct => 'পণ্য অনুলিপি করুন';

  @override
  String get categoriesManagement => 'বিভাগ ব্যবস্থাপনা';

  @override
  String categoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count বিভাগ',
      one: '1 বিভাগ',
      zero: 'কোনো বিভাগ নেই',
    );
    return '$_temp0';
  }

  @override
  String get addCategory => 'বিভাগ যোগ করুন';

  @override
  String get editCategory => 'বিভাগ সম্পাদনা করুন';

  @override
  String get deleteCategory => 'বিভাগ মুছুন';

  @override
  String get categoryName => 'বিভাগের নাম';

  @override
  String get categoryNameAr => 'নাম (আরবি)';

  @override
  String get categoryNameEn => 'নাম (ইংরেজি)';

  @override
  String get parentCategory => 'মূল বিভাগ';

  @override
  String get noParentCategory => 'কোনো মূল বিভাগ নেই (প্রধান)';

  @override
  String get sortOrder => 'ক্রম';

  @override
  String get categoryColor => 'রঙ';

  @override
  String get categoryIcon => 'আইকন';

  @override
  String get categoryDetails => 'বিভাগের বিবরণ';

  @override
  String get categoryCreatedAt => 'তৈরির তারিখ';

  @override
  String get categoryProducts => 'বিভাগের পণ্য';

  @override
  String get noCategorySelected => 'বিবরণ দেখতে বিভাগ নির্বাচন করুন';

  @override
  String get deleteCategoryConfirm =>
      'আপনি কি নিশ্চিত যে আপনি এই বিভাগটি মুছতে চান?';

  @override
  String get categoryDeletedSuccess => 'বিভাগ সফলভাবে মুছে ফেলা হয়েছে';

  @override
  String get categorySavedSuccess => 'বিভাগ সফলভাবে সংরক্ষিত হয়েছে';

  @override
  String get searchCategories => 'বিভাগ খুঁজুন...';

  @override
  String get reorderCategories => 'পুনর্বিন্যাস';

  @override
  String get noCategories => 'কোনো বিভাগ পাওয়া যায়নি';

  @override
  String get subcategories => 'উপ-বিভাগ';

  @override
  String get activeStatus => 'সক্রিয়';

  @override
  String get inactiveStatus => 'নিষ্ক্রিয়';

  @override
  String get invoicesTitle => 'ইনভয়েস';

  @override
  String get totalInvoices => 'মোট ইনভয়েস';

  @override
  String get totalPaid => 'মোট পরিশোধিত';

  @override
  String get totalPending => 'মোট মুলতুবি';

  @override
  String get totalOverdue => 'মোট বকেয়া';

  @override
  String get comparedToLastMonth => 'গত মাসের তুলনায়';

  @override
  String ofTotalDue(String percent) {
    return 'মোট পাওনার $percent%';
  }

  @override
  String invoicesWaitingPayment(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ইনভয়েস পেমেন্টের অপেক্ষায়',
      one: '1 ইনভয়েস পেমেন্টের অপেক্ষায়',
      zero: 'কোনো ইনভয়েস অপেক্ষায় নেই',
    );
    return '$_temp0';
  }

  @override
  String get sendReminderNow => 'এখনই রিমাইন্ডার পাঠান';

  @override
  String get revenueAnalysis => 'রাজস্ব বিশ্লেষণ';

  @override
  String get last7Days => 'শেষ ৭ দিন';

  @override
  String get thisMonthPeriod => 'এই মাস';

  @override
  String get thisYearPeriod => 'এই বছর';

  @override
  String get paymentMethods => 'পেমেন্ট পদ্ধতি';

  @override
  String get cashPayment => 'নগদ';

  @override
  String get cardPayment => 'কার্ড';

  @override
  String get walletPayment => 'ওয়ালেট';

  @override
  String get saveCurrentFilter => 'বর্তমান ফিল্টার সংরক্ষণ';

  @override
  String get statusAll => 'অবস্থা: সব';

  @override
  String get statusPaid => 'পরিশোধিত';

  @override
  String get statusPending => 'মুলতুবি';

  @override
  String get statusOverdue => 'বকেয়া';

  @override
  String get statusCancelled => 'বাতিল';

  @override
  String get resetFilters => 'রিসেট';

  @override
  String get createInvoice => 'ইনভয়েস তৈরি';

  @override
  String get invoiceNumberCol => 'ইনভয়েস #';

  @override
  String get customerNameCol => 'গ্রাহকের নাম';

  @override
  String get dateCol => 'তারিখ';

  @override
  String get amountCol => 'পরিমাণ';

  @override
  String get statusCol => 'অবস্থা';

  @override
  String get paymentCol => 'পেমেন্ট';

  @override
  String get actionsCol => 'অ্যাকশন';

  @override
  String get viewInvoice => 'দেখুন';

  @override
  String get printInvoice => 'প্রিন্ট';

  @override
  String get exportPdf => 'PDF';

  @override
  String get sendWhatsapp => 'হোয়াটসঅ্যাপ';

  @override
  String get deleteInvoice => 'মুছুন';

  @override
  String get reminder => 'রিমাইন্ডার';

  @override
  String get exportAll => 'সব এক্সপোর্ট';

  @override
  String get printReport => 'রিপোর্ট প্রিন্ট';

  @override
  String get more => 'আরও';

  @override
  String showingResults(int from, int to, int total) {
    return '$total এর মধ্যে $from থেকে $to দেখাচ্ছে';
  }

  @override
  String get newInvoice => 'নতুন ইনভয়েস';

  @override
  String get selectCustomer => 'গ্রাহক নির্বাচন';

  @override
  String get cashCustomerGeneral => 'নগদ গ্রাহক (সাধারণ)';

  @override
  String get addNewCustomer => '+ নতুন গ্রাহক যোগ করুন';

  @override
  String get productsSection => 'পণ্য';

  @override
  String get addProductToInvoice => '+ পণ্য যোগ করুন';

  @override
  String get productCol => 'পণ্য';

  @override
  String get quantityCol => 'পরিমাণ';

  @override
  String get priceCol => 'মূল্য';

  @override
  String get dueDate => 'নির্ধারিত তারিখ';

  @override
  String get invoiceTotal => 'মোট:';

  @override
  String get saveInvoice => 'ইনভয়েস সংরক্ষণ';

  @override
  String get deleteConfirm => 'আপনি কি নিশ্চিত?';

  @override
  String get deleteInvoiceMsg =>
      'আপনি কি সত্যিই এই ইনভয়েস মুছতে চান? এই কাজ পূর্বাবস্থায় ফেরানো যাবে না।';

  @override
  String get yesDelete => 'হ্যাঁ, মুছুন';

  @override
  String get copiedSuccess => 'সফলভাবে কপি হয়েছে';

  @override
  String get invoiceDeleted => 'ইনভয়েস সফলভাবে মুছে ফেলা হয়েছে';

  @override
  String get sat => 'শনি';

  @override
  String get sun => 'রবি';

  @override
  String get mon => 'সোম';

  @override
  String get tue => 'মঙ্গল';

  @override
  String get wed => 'বুধ';

  @override
  String get thu => 'বৃহ';

  @override
  String get fri => 'শুক্র';

  @override
  String selected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count নির্বাচিত',
      one: '1 নির্বাচিত',
      zero: 'কোনোটি নির্বাচিত নয়',
    );
    return '$_temp0';
  }

  @override
  String get bulkPrint => 'প্রিন্ট';

  @override
  String get bulkExportPdf => 'PDF এক্সপোর্ট';

  @override
  String get allRightsReservedFooter =>
      '© 2026 Alhai POS. সর্বস্বত্ব সংরক্ষিত।';

  @override
  String get privacyPolicyFooter => 'গোপনীয়তা নীতি';

  @override
  String get termsFooter => 'শর্তাবলী';

  @override
  String get supportFooter => 'প্রযুক্তি সহায়তা';

  @override
  String get paid => 'পরিশোধিত';

  @override
  String get overdue => 'বকেয়া';

  @override
  String get creditCard => 'ক্রেডিট কার্ড';

  @override
  String get electronicWallet => 'ই-ওয়ালেট';

  @override
  String get searchInvoiceHint => 'ইনভয়েস নম্বর, গ্রাহক দিয়ে খুঁজুন...';

  @override
  String get customerDetails => 'গ্রাহকের বিবরণ';

  @override
  String get customerProfileAndTransactions =>
      'প্রোফাইল এবং লেনদেনের সংক্ষিপ্ত বিবরণ';

  @override
  String get customerDetailTitle => 'গ্রাহকের বিবরণ';

  @override
  String get totalPurchases => 'মোট ক্রয়';

  @override
  String get loyaltyPoints => 'লয়্যালটি পয়েন্ট';

  @override
  String get lastVisit => 'শেষ ভিজিট';

  @override
  String get newSaleAction => 'নতুন বিক্রয়';

  @override
  String get editInfo => 'তথ্য সম্পাদনা';

  @override
  String get whatsapp => 'হোয়াটসঅ্যাপ';

  @override
  String get blockCustomer => 'গ্রাহককে ব্লক করুন';

  @override
  String get purchasesTab => 'ক্রয়';

  @override
  String get accountTab => 'অ্যাকাউন্ট';

  @override
  String get debtsTab => 'ঋণ';

  @override
  String get analyticsTab => 'বিশ্লেষণ';

  @override
  String get recentOrdersLog => 'সাম্প্রতিক অর্ডার লগ';

  @override
  String get exportCsv => 'CSV রপ্তানি';

  @override
  String get searchByInvoiceNumber => 'ইনভয়েস নম্বর দিয়ে খুঁজুন...';

  @override
  String get items => 'আইটেম';

  @override
  String get viewDetails => 'বিবরণ দেখুন';

  @override
  String get financialLedger => 'আর্থিক লেনদেন রেজিস্টার';

  @override
  String get cashPaymentEntry => 'নগদ পেমেন্ট';

  @override
  String get walletTopup => 'ওয়ালেট টপ-আপ';

  @override
  String get loyaltyPointsDeduction => 'লয়্যালটি পয়েন্ট কর্তন';

  @override
  String redeemPoints(int count) {
    return '$count পয়েন্ট রিডিম';
  }

  @override
  String get viewFullLedger => 'সম্পূর্ণ দেখুন';

  @override
  String get currentBalance => 'বর্তমান ব্যালেন্স';

  @override
  String get creditLimit => 'ক্রেডিট সীমা';

  @override
  String get used => 'ব্যবহৃত';

  @override
  String get topUpBalance => 'ব্যালেন্স টপ-আপ';

  @override
  String get overdueDebt => 'মেয়াদোত্তীর্ণ';

  @override
  String get upcomingDebt => 'আসন্ন';

  @override
  String get payNow => 'এখনই পরিশোধ করুন';

  @override
  String get remind => 'স্মরণ';

  @override
  String get monthlySpending => 'মাসিক ব্যয়';

  @override
  String get purchaseDistribution => 'বিভাগ অনুসারে ক্রয় বিতরণ';

  @override
  String get last6Months => 'শেষ ৬ মাস';

  @override
  String get thisYear => 'এই বছর';

  @override
  String get averageOrder => 'গড় অর্ডার';

  @override
  String get purchaseFrequency => 'ক্রয় ফ্রিকোয়েন্সি';

  @override
  String everyNDays(int count) {
    return 'প্রতি $count দিন';
  }

  @override
  String get spendingGrowth => 'ব্যয় বৃদ্ধি';

  @override
  String get favoriteProduct => 'প্রিয় পণ্য';

  @override
  String get internalNotes => 'অভ্যন্তরীণ নোট (শুধু কর্মীদের জন্য দৃশ্যমান)';

  @override
  String get addNote => 'যোগ করুন';

  @override
  String get addNewNote => 'নতুন নোট যোগ করুন...';

  @override
  String joinedDate(String date) {
    return 'যোগদান: $date';
  }

  @override
  String lastUpdated(String time) {
    return 'শেষ আপডেট: $time';
  }

  @override
  String showingOrders(int from, int to, int total) {
    return '$total এর মধ্যে $from-$to দেখাচ্ছে';
  }

  @override
  String get vegetables => 'সবজি';

  @override
  String get dairy => 'দুগ্ধ';

  @override
  String get meat => 'মাংস';

  @override
  String get bakery => 'বেকারি';

  @override
  String get other => 'অন্যান্য';

  @override
  String get returns => 'ফেরত';

  @override
  String get salesReturns => 'বিক্রয় ফেরত';

  @override
  String get purchaseReturns => 'ক্রয় ফেরত';

  @override
  String get totalReturns => 'মোট ফেরত';

  @override
  String get totalRefundedAmount => 'মোট ফেরত পরিমাণ';

  @override
  String get mostReturned => 'সবচেয়ে বেশি ফেরত';

  @override
  String get processed => 'ফেরত দেওয়া হয়েছে';

  @override
  String get newReturn => 'নতুন ফেরত';

  @override
  String get createNewReturn => 'নতুন ফেরত তৈরি করুন';

  @override
  String get processReturnRequest => 'বিক্রয় ফেরত অনুরোধ';

  @override
  String get returnNumber => 'ফেরত নম্বর';

  @override
  String get originalInvoice => 'মূল চালান';

  @override
  String get returnReason => 'ফেরতের কারণ';

  @override
  String get returnAmount => 'ফেরত পরিমাণ';

  @override
  String get returnStatus => 'অবস্থা';

  @override
  String get returnDate => 'তারিখ';

  @override
  String get returnActions => 'পদক্ষেপ';

  @override
  String get returnRefunded => 'ফেরত দেওয়া হয়েছে';

  @override
  String get returnRejected => 'প্রত্যাখ্যাত';

  @override
  String get defectiveProduct => 'ত্রুটিপূর্ণ পণ্য';

  @override
  String get wrongProduct => 'ভুল পণ্য';

  @override
  String get customerRequest => 'গ্রাহকের অনুরোধ';

  @override
  String get otherReason => 'অন্যান্য';

  @override
  String get quickSearch => 'দ্রুত খুঁজুন...';

  @override
  String get exportData => 'রপ্তানি';

  @override
  String get printData => 'প্রিন্ট';

  @override
  String get approve => 'অনুমোদন';

  @override
  String get reject => 'প্রত্যাখ্যান';

  @override
  String get previous => 'পূর্ববর্তী';

  @override
  String get invoiceStep => 'চালান';

  @override
  String get itemsStep => 'আইটেম';

  @override
  String get reasonStep => 'কারণ';

  @override
  String get confirmStep => 'নিশ্চিতকরণ';

  @override
  String get enterInvoiceNumber => 'চালান নম্বর';

  @override
  String get invoiceExample => 'উদাহরণ: #INV-889';

  @override
  String get loadInvoice => 'লোড';

  @override
  String invoiceLoaded(String number) {
    return 'চালান #$number লোড হয়েছে';
  }

  @override
  String invoiceLoadedCustomer(String customer, String date) {
    return 'গ্রাহক: $customer | তারিখ: $date';
  }

  @override
  String get selectItemsInfo =>
      'ফেরতের জন্য আইটেম নির্বাচন করুন। বিক্রয়ের বেশি পরিমাণ ফেরত হবে না।';

  @override
  String availableToReturn(int count) {
    return 'উপলব্ধ: $count';
  }

  @override
  String get alreadyReturnedFully => 'পূর্ণ পরিমাণ ইতিমধ্যে ফেরত হয়েছে';

  @override
  String get returnReasonLabel => 'ফেরতের কারণ (নির্বাচিত আইটেমের জন্য)';

  @override
  String get additionalDetails =>
      'অতিরিক্ত বিবরণ (অন্যান্যের জন্য প্রয়োজন)...';

  @override
  String get confirmReturn => 'ফেরত নিশ্চিত করুন';

  @override
  String get refundAmount => 'ফেরত পরিমাণ';

  @override
  String get refundMethod => 'ফেরতের পদ্ধতি';

  @override
  String get cashRefund => 'নগদ';

  @override
  String get storeCredit => 'স্টোর ক্রেডিট';

  @override
  String get returnCreatedSuccess => 'ফেরত সফলভাবে তৈরি হয়েছে';

  @override
  String get noReturns => 'কোনো ফেরত নেই';

  @override
  String get noReturnsDesc => 'এখনো কোনো ফেরত রেকর্ড হয়নি।';

  @override
  String timesReturned(int count, int percent) {
    return '$count বার ($percent% মোটের মধ্যে)';
  }

  @override
  String get fromInvoice => 'চালান থেকে';

  @override
  String get dateFromTo => 'তারিখ থেকে - পর্যন্ত';

  @override
  String get returnCopied => 'নম্বর সফলভাবে কপি হয়েছে';

  @override
  String ofTotalProcessed(int percent) {
    return '$percent% প্রক্রিয়া হয়েছে';
  }

  @override
  String get invoiceDetails => 'ইনভয়েস বিবরণ';

  @override
  String invoiceNumberLabel(String number) {
    return 'নম্বর:';
  }

  @override
  String get additionalOptions => 'অতিরিক্ত বিকল্প';

  @override
  String get duplicateInvoice => 'ডুপ্লিকেট তৈরি';

  @override
  String get returnMerchandise => 'পণ্য ফেরত';

  @override
  String get voidInvoice => 'ইনভয়েস বাতিল করুন';

  @override
  String get printBtn => 'প্রিন্ট';

  @override
  String get downloadBtn => 'ডাউনলোড';

  @override
  String get paidSuccessfully => 'পেমেন্ট সফল';

  @override
  String get amountReceivedFull => 'সম্পূর্ণ পরিমাণ প্রাপ্ত';

  @override
  String get completedStatus => 'সম্পন্ন';

  @override
  String get pendingStatus => 'মুলতুবি';

  @override
  String get voidedStatus => 'বাতিল';

  @override
  String get storeName => 'পাড়ার সুপারমার্কেট';

  @override
  String get storeAddress => 'রিয়াদ, আল-মালাজ জেলা';

  @override
  String get simplifiedTaxInvoice => 'সরলীকৃত কর ইনভয়েস';

  @override
  String get dateAndTime => 'তারিখ ও সময়';

  @override
  String get cashierLabel => 'ক্যাশিয়ার';

  @override
  String get itemCol => 'আইটেম';

  @override
  String get quantityColDetail => 'পরিমাণ';

  @override
  String get priceColDetail => 'মূল্য';

  @override
  String get totalCol => 'মোট';

  @override
  String get subtotalLabel => 'উপ-মোট';

  @override
  String get discountVip => 'ছাড় (VIP সদস্য)';

  @override
  String get vatLabel => 'ভ্যাট (15%)';

  @override
  String get grandTotalLabel => 'সর্বমোট';

  @override
  String get paymentMethodLabel => 'পেমেন্ট পদ্ধতি';

  @override
  String get amountPaidLabel => 'প্রদত্ত পরিমাণ';

  @override
  String get zatcaElectronic => 'ZATCA - ইলেকট্রনিক ইনভয়েস';

  @override
  String get scanToVerify => 'যাচাই করতে স্ক্যান করুন';

  @override
  String get includesVat15 => '15% ভ্যাট অন্তর্ভুক্ত';

  @override
  String get thankYouVisit => 'আপনার পরিদর্শনের জন্য ধন্যবাদ!';

  @override
  String get wishNiceDay => 'আপনার দিন শুভ হোক';

  @override
  String get customerInfo => 'গ্রাহক তথ্য';

  @override
  String get editBtn => 'সম্পাদনা';

  @override
  String vipSince(String year) {
    return '$year থেকে VIP গ্রাহক';
  }

  @override
  String get activeStatusLabel => 'সক্রিয়';

  @override
  String get callBtn => 'কল';

  @override
  String get recordBtn => 'রেকর্ড';

  @override
  String get quickActions => 'দ্রুত কার্যক্রম';

  @override
  String get sendWhatsappAction => 'হোয়াটসঅ্যাপ পাঠান';

  @override
  String get sendEmailAction => 'ইমেইল পাঠান';

  @override
  String get downloadPdfAction => 'PDF ডাউনলোড';

  @override
  String get shareLinkAction => 'লিংক শেয়ার';

  @override
  String get eventLog => 'ইভেন্ট লগ';

  @override
  String get paymentCompleted => 'পেমেন্ট সম্পন্ন';

  @override
  String get processedViaGateway => 'পেমেন্ট গেটওয়ে দিয়ে প্রসেস';

  @override
  String minutesAgoDetail(int count) {
    return '$count মিনিট আগে';
  }

  @override
  String get invoiceCreated => 'ইনভয়েস তৈরি হয়েছে';

  @override
  String byUser(String name) {
    return '$name দ্বারা';
  }

  @override
  String todayAt(String time) {
    return 'আজ, $time';
  }

  @override
  String get orderStarted => 'অর্ডার শুরু';

  @override
  String get cashierSessionOpened => 'ক্যাশিয়ার সেশন খোলা হয়েছে';

  @override
  String get technicalData => 'প্রযুক্তিগত তথ্য';

  @override
  String get deviceIdLabel => 'Device ID';

  @override
  String get terminalLabel => 'Terminal';

  @override
  String get softwareVersion => 'Software V';

  @override
  String get voidInvoiceConfirm => 'ইনভয়েস বাতিল করবেন?';

  @override
  String get voidInvoiceMsg =>
      'এই ইনভয়েসটি স্থায়ীভাবে বাতিল হবে। আপনি কি নিশ্চিত?';

  @override
  String get voidReasonLabel => 'বাতিলের কারণ (আবশ্যক)';

  @override
  String get voidReasonEntry => 'এন্ট্রি ত্রুটি';

  @override
  String get voidReasonCustomer => 'গ্রাহকের অনুরোধ';

  @override
  String get voidReasonDamaged => 'ক্ষতিগ্রস্ত পণ্য';

  @override
  String get voidReasonOther => 'অন্যান্য কারণ...';

  @override
  String get confirmVoid => 'বাতিল নিশ্চিত করুন';

  @override
  String get invoiceVoided => 'ইনভয়েস সফলভাবে বাতিল হয়েছে';

  @override
  String copiedText(String text) {
    return 'কপি হয়েছে: $text';
  }

  @override
  String visaEnding(String digits) {
    return 'Visa শেষ $digits';
  }

  @override
  String get mobileActionPrint => 'প্রিন্ট';

  @override
  String get mobileActionWhatsapp => 'হোয়াটসঅ্যাপ';

  @override
  String get mobileActionEmail => 'ইমেইল';

  @override
  String get mobileActionMore => 'আরো';

  @override
  String get sarCurrency => 'ر.س';

  @override
  String skuLabel(String code) {
    return 'SKU: $code';
  }

  @override
  String get helpText => 'সাহায্য';

  @override
  String get customerLedger => 'গ্রাহক লেজার';

  @override
  String get accountStatement => 'অ্যাকাউন্ট স্টেটমেন্ট';

  @override
  String get allPeriods => 'সব';

  @override
  String get threeMonths => '৩ মাস';

  @override
  String get allMovements => 'সব লেনদেন';

  @override
  String get adjustments => 'সমন্বয়';

  @override
  String get statementCol => 'বিবরণ';

  @override
  String get referenceCol => 'রেফারেন্স';

  @override
  String get debitCol => 'ডেবিট';

  @override
  String get creditCol => 'ক্রেডিট';

  @override
  String get balanceCol => 'ব্যালেন্স';

  @override
  String get openingBalance => 'প্রারম্ভিক ব্যালেন্স';

  @override
  String get totalDebit => 'মোট ডেবিট';

  @override
  String get totalCredit => 'মোট ক্রেডিট';

  @override
  String get finalBalance => 'চূড়ান্ত ব্যালেন্স';

  @override
  String get manualAdjustment => 'ম্যানুয়াল সমন্বয়';

  @override
  String get adjustmentType => 'সমন্বয়ের ধরন';

  @override
  String get debitAdjustment => 'ডেবিট সমন্বয়';

  @override
  String get creditAdjustment => 'ক্রেডিট সমন্বয়';

  @override
  String get adjustmentAmount => 'সমন্বয়ের পরিমাণ';

  @override
  String get adjustmentReason => 'সমন্বয়ের কারণ';

  @override
  String get adjustmentDate => 'সমন্বয়ের তারিখ';

  @override
  String get saveAdjustment => 'সমন্বয় সংরক্ষণ';

  @override
  String get adjustmentSaved => 'সমন্বয় সফলভাবে সংরক্ষিত';

  @override
  String get enterValidAmount => 'একটি বৈধ পরিমাণ লিখুন';

  @override
  String get dueOnCustomer => 'গ্রাহকের উপর বকেয়া';

  @override
  String get customerHasCredit => 'গ্রাহকের ক্রেডিট ব্যালেন্স আছে';

  @override
  String get noTransactions => 'কোনো লেনদেন নেই';

  @override
  String get recordPaymentBtn => 'পেমেন্ট রেকর্ড';

  @override
  String get returnEntry => 'ফেরত';

  @override
  String get adjustmentEntry => 'সমন্বয়';

  @override
  String get ordersHistory => 'অর্ডার ইতিহাস';

  @override
  String get totalOrdersLabel => 'মোট অর্ডার';

  @override
  String get completedOrders => 'সম্পন্ন';

  @override
  String get pendingOrders => 'মুলতুবি';

  @override
  String get cancelledOrders => 'বাতিল';

  @override
  String get searchOrderHint => 'অর্ডার নম্বর, গ্রাহক, বা ফোন দিয়ে খুঁজুন...';

  @override
  String get channelLabel => 'চ্যানেল';

  @override
  String get last30Days => 'শেষ ৩০ দিন';

  @override
  String get orderDetails => 'অর্ডার বিবরণ';

  @override
  String get unpaidLabel => 'অপরিশোধিত';

  @override
  String get voidTransaction => 'লেনদেন বাতিল করুন';

  @override
  String get voidSaleTransaction => 'বিক্রয় লেনদেন বাতিল করুন';

  @override
  String get voidWarningTitle =>
      'গুরুত্বপূর্ণ সতর্কতা: এই পদক্ষেপ পূর্বাবস্থায় ফেরানো যাবে না';

  @override
  String get voidWarningDesc =>
      'এই লেনদেন বাতিল করলে ইনভয়েস সম্পূর্ণরূপে বাতিল হবে।';

  @override
  String get voidWarningShort =>
      'এই পদক্ষেপ ইনভয়েস সম্পূর্ণরূপে বাতিল করবে। ফেরানো যাবে না।';

  @override
  String get enterInvoiceToVoid => 'বাতিলের জন্য ইনভয়েস নম্বর লিখুন';

  @override
  String get searchByInvoiceOrBarcode =>
      'ইনভয়েস নম্বর বা বারকোড স্ক্যানার ব্যবহার করুন';

  @override
  String get invoiceExampleVoid => 'উদাহরণ: #INV-2024-8892';

  @override
  String get activateBarcode => 'বারকোড স্ক্যানার সক্রিয় করুন';

  @override
  String get scanBarcodeMobile => 'বারকোড স্ক্যান করুন';

  @override
  String get searchForInvoiceToVoid => 'বাতিলের জন্য ইনভয়েস খুঁজুন';

  @override
  String get enterNumberOrScan =>
      'নম্বর লিখুন বা বারকোড স্ক্যানার ব্যবহার করুন।';

  @override
  String get salesInvoice => 'বিক্রয় ইনভয়েস';

  @override
  String get invoiceCompleted => 'সম্পূর্ণ';

  @override
  String get paidCash => 'পরিশোধ: নগদ';

  @override
  String get customerLabel => 'গ্রাহক';

  @override
  String get dateAndTimeLabel => 'তারিখ ও সময়';

  @override
  String get voidImpactSummary => 'বাতিলের প্রভাব সারাংশ';

  @override
  String voidImpactItemsReturn(int count) {
    return '$countটি আইটেম স্বয়ংক্রিয়ভাবে ইনভেন্টরিতে ফিরে যাবে।';
  }

  @override
  String voidImpactRefund(String amount, String currency) {
    return 'পরিমাণ $amount $currency কাটা/ফেরত হবে।';
  }

  @override
  String returnedItems(int count) {
    return 'ফেরত আইটেম ($count)';
  }

  @override
  String get viewAllItems => 'সব দেখুন';

  @override
  String moreItemsHint(int count, String amount, String currency) {
    return '+ $countটি আইটেম (মোট: $amount $currency)';
  }

  @override
  String get voidReason => 'বাতিলের কারণ';

  @override
  String get voidReasonRequired => 'বাতিলের কারণ *';

  @override
  String get customerRequestReason => 'গ্রাহকের অনুরোধ';

  @override
  String get wrongItemsReason => 'ভুল আইটেম';

  @override
  String get duplicateInvoiceReason => 'ডুপ্লিকেট ইনভয়েস';

  @override
  String get systemErrorReason => 'সিস্টেম ত্রুটি';

  @override
  String get otherReasonVoid => 'অন্যান্য';

  @override
  String get additionalNotesVoid => 'অতিরিক্ত নোট...';

  @override
  String get additionalDetailsRequired =>
      'অতিরিক্ত বিবরণ (অন্যান্যের জন্য প্রয়োজন)...';

  @override
  String get managerApproval => 'ম্যানেজারের অনুমোদন';

  @override
  String get managerApprovalRequired => 'ম্যানেজারের অনুমোদন প্রয়োজন';

  @override
  String amountExceedsLimit(String amount, String currency) {
    return 'পরিমাণ অনুমোদিত সীমা ($amount $currency) অতিক্রম করেছে, ম্যানেজার PIN দিন।';
  }

  @override
  String get enterPinCode => 'PIN কোড লিখুন';

  @override
  String get pinSentToManager => 'অস্থায়ী কোড ম্যানেজারের ফোনে পাঠানো হয়েছে';

  @override
  String get defaultManagerPin => 'ডিফল্ট ম্যানেজার কোড: 1234';

  @override
  String get confirmVoidAction => 'আমি এই লেনদেন বাতিলের নিশ্চিতকরণ করছি';

  @override
  String get confirmVoidDesc =>
      'আমি বিবরণ পর্যালোচনা করেছি এবং সম্পূর্ণ দায়িত্ব নিচ্ছি।';

  @override
  String get cancelAction => 'বাতিল';

  @override
  String get confirmFinalVoid => 'চূড়ান্ত বাতিলের নিশ্চিতকরণ';

  @override
  String get invoiceNotFound => 'ইনভয়েস পাওয়া যায়নি';

  @override
  String get invoiceNotFoundDesc =>
      'লেখা নম্বর যাচাই করুন বা বারকোড ব্যবহার করুন।';

  @override
  String get trySearchAgain => 'আবার খুঁজুন';

  @override
  String get voidSuccess => 'লেনদেন সফলভাবে বাতিল হয়েছে';

  @override
  String qtyLabel(int count) {
    return 'পরিমাণ: $count';
  }

  @override
  String get manageCustomersAndAccounts => 'গ্রাহক ও অ্যাকাউন্ট পরিচালনা';

  @override
  String get totalCustomersCount => 'মোট গ্রাহক';

  @override
  String get outstandingDebts => 'বকেয়া ঋণ';

  @override
  String get creditBalance => 'গ্রাহকের ক্রেডিট';

  @override
  String get filterByLabel => 'ফিল্টার';

  @override
  String get debtors => 'ঋণগ্রস্ত';

  @override
  String get creditorsLabel => 'পাওনাদার';

  @override
  String get quickActionsLabel => 'দ্রুত কর্ম';

  @override
  String get sendDebtReminder => 'ঋণ স্মারক পাঠান';

  @override
  String get exportAccountStatement => 'অ্যাকাউন্ট স্টেটমেন্ট রপ্তানি';

  @override
  String cancelSelectionCount(String count) {
    return 'নির্বাচন বাতিল ($count)';
  }

  @override
  String get searchByNameOrPhone => 'নাম বা ফোনে অনুসন্ধান... (Ctrl+F)';

  @override
  String get sortByBalance => 'ব্যালেন্স';

  @override
  String get refreshF5 => 'রিফ্রেশ (F5)';

  @override
  String get loadingCustomers => 'গ্রাহক লোড হচ্ছে...';

  @override
  String get payDebt => 'ঋণ পরিশোধ';

  @override
  String dueAmountLabel(String amount) {
    return 'বকেয়া: $amount রিয়াল';
  }

  @override
  String get paymentAmountLabel => 'পরিশোধের পরিমাণ';

  @override
  String get fullAmount => 'সম্পূর্ণ';

  @override
  String get payAction => 'পরিশোধ';

  @override
  String paymentRecorded(String amount) {
    return '$amount রিয়াল পরিশোধ রেকর্ড হয়েছে';
  }

  @override
  String customerAddedSuccess(String name) {
    return '$name যোগ করা হয়েছে';
  }

  @override
  String get customerNameRequired => 'গ্রাহকের নাম *';

  @override
  String get owedLabel => 'বকেয়া';

  @override
  String get hasBalanceLabel => 'ক্রেডিট';

  @override
  String get zeroLabel => 'শূন্য';

  @override
  String get addAction => 'যোগ করুন';

  @override
  String get expenses => 'খরচ';

  @override
  String get expenseCategories => 'খরচের বিভাগ';

  @override
  String get addExpense => 'খরচ যোগ করুন';

  @override
  String get totalExpenses => 'মোট খরচ';

  @override
  String get thisMonthExpenses => 'এই মাস';

  @override
  String get expenseAmount => 'Amount';

  @override
  String get expenseDate => 'Date';

  @override
  String get expenseCategory => 'Category';

  @override
  String get expenseNotes => 'Notes';

  @override
  String get noExpenses => 'কোন খরচ নেই';

  @override
  String get drawerStatus => 'ড্রয়ারের অবস্থা';

  @override
  String get drawerOpen => 'খোলা';

  @override
  String get drawerClosed => 'বন্ধ';

  @override
  String get cashIn => 'নগদ জমা';

  @override
  String get cashOut => 'নগদ উত্তোলন';

  @override
  String get expectedAmount => 'প্রত্যাশিত পরিমাণ';

  @override
  String get countedAmount => 'গণনা করা পরিমাণ';

  @override
  String get difference => 'পার্থক্য';

  @override
  String get openDrawerAction => 'Open Drawer';

  @override
  String get closeDrawerAction => 'Close Drawer';

  @override
  String get monthlyCloseTitle => 'মাসিক বন্ধ';

  @override
  String get monthlyCloseDesc => 'Close month and calculate receivables';

  @override
  String get totalReceivables => 'মোট প্রাপ্য';

  @override
  String get interestRate => 'সুদের হার';

  @override
  String get closeMonth => 'মাস বন্ধ করুন';

  @override
  String get shiftsTitle => 'শিফট';

  @override
  String get currentShift => 'বর্তমান শিফট';

  @override
  String get shiftHistory => 'শিফটের ইতিহাস';

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
  String get noShifts => 'কোন শিফট নেই';

  @override
  String get purchasesTitle => 'ক্রয়';

  @override
  String get newPurchase => 'New Purchase';

  @override
  String get smartReorder => 'স্মার্ট রিঅর্ডার';

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
  String get suppliersTitle => 'সরবরাহকারী';

  @override
  String get addSupplier => 'সরবরাহকারী যোগ করুন';

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
  String get noSuppliers => 'কোন সরবরাহকারী নেই';

  @override
  String get discountsTitle => 'ছাড়';

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
  String get couponsTitle => 'কুপন';

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
  String get specialOffersTitle => 'বিশেষ অফার';

  @override
  String get addOffer => 'Add Offer';

  @override
  String get offerName => 'Offer Name';

  @override
  String get offerStartDate => 'Start Date';

  @override
  String get offerEndDate => 'End Date';

  @override
  String get smartPromotionsTitle => 'স্মার্ট প্রমোশন';

  @override
  String get activePromotions => 'Active Promotions';

  @override
  String get suggestedPromotions => 'AI Suggestions';

  @override
  String get loyaltyTitle => 'আনুগত্য প্রোগ্রাম';

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
  String get notificationsTitle => 'বিজ্ঞপ্তি';

  @override
  String get markAllRead => 'Mark All Read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get printQueueTitle => 'প্রিন্ট কিউ';

  @override
  String get printAll => 'Print All';

  @override
  String get cancelAll => 'Cancel All';

  @override
  String get noPrintJobs => 'No print jobs';

  @override
  String get syncStatusTitle => 'সিঙ্ক অবস্থা';

  @override
  String get lastSyncTime => 'Last Sync';

  @override
  String get pendingItems => 'Pending Items';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get pendingTransactionsTitle => 'মুলতুবি লেনদেন';

  @override
  String get conflictResolutionTitle => 'বিরোধ সমাধান';

  @override
  String get localValue => 'Local';

  @override
  String get serverValue => 'Server';

  @override
  String get keepLocal => 'Keep Local';

  @override
  String get keepServer => 'Keep Server';

  @override
  String get driversTitle => 'ড্রাইভার';

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
  String get branchesTitle => 'শাখা';

  @override
  String get addBranchAction => 'Add Branch';

  @override
  String get branchName => 'Branch Name';

  @override
  String get branchEmployees => 'Employees';

  @override
  String get branchSales => 'Today\'s Sales';

  @override
  String get profileTitle => 'প্রোফাইল';

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
  String get settingsTitle => 'সেটিংস';

  @override
  String get storeSettings => 'স্টোর সেটিংস';

  @override
  String get posSettings => 'পিওএস সেটিংস';

  @override
  String get printerSettings => 'প্রিন্টার সেটিংস';

  @override
  String get paymentDevicesSettings => 'পেমেন্ট ডিভাইস';

  @override
  String get barcodeSettings => 'বারকোড সেটিংস';

  @override
  String get receiptTemplate => 'রসিদ টেমপ্লেট';

  @override
  String get taxSettings => 'ট্যাক্স সেটিংস';

  @override
  String get discountSettings => 'ছাড় সেটিংস';

  @override
  String get interestSettings => 'সুদ সেটিংস';

  @override
  String get languageSettings => 'Language';

  @override
  String get themeSettings => 'Theme';

  @override
  String get securitySettings => 'নিরাপত্তা';

  @override
  String get usersManagement => 'ব্যবহারকারী ব্যবস্থাপনা';

  @override
  String get rolesPermissions => 'ভূমিকা ও অনুমতি';

  @override
  String get activityLog => 'কার্যকলাপ লগ';

  @override
  String get backupSettings => 'ব্যাকআপ ও পুনরুদ্ধার';

  @override
  String get notificationSettings => 'Notifications';

  @override
  String get zatcaCompliance => 'ZATCA সম্মতি';

  @override
  String get helpSupport => 'সাহায্য ও সমর্থন';

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
  String get liveChat => 'লাইভ চ্যাট';

  @override
  String get emailSupport => 'ইমেইল সাপোর্ট';

  @override
  String get phoneSupport => 'ফোন সাপোর্ট';

  @override
  String get whatsappSupport => 'হোয়াটসঅ্যাপ সাপোর্ট';

  @override
  String get userGuide => 'ব্যবহারকারী গাইড';

  @override
  String get videoTutorials => 'ভিডিও টিউটোরিয়াল';

  @override
  String get changelog => 'পরিবর্তন লগ';

  @override
  String get appInfo => 'অ্যাপ তথ্য';

  @override
  String get buildNumber => 'বিল্ড নম্বর';

  @override
  String get notificationChannels => 'বিজ্ঞপ্তি চ্যানেল';

  @override
  String get alertTypes => 'সতর্কতার ধরন';

  @override
  String get salesAlerts => 'বিক্রয় সতর্কতা';

  @override
  String get inventoryAlerts => 'ইনভেন্টরি সতর্কতা';

  @override
  String get securityAlerts => 'নিরাপত্তা সতর্কতা';

  @override
  String get reportAlerts => 'রিপোর্ট সতর্কতা';

  @override
  String get users => 'ব্যবহারকারী';

  @override
  String get zatcaRegistered => 'ZATCA-তে নিবন্ধিত';

  @override
  String get zatcaPhase2Active => 'দ্বিতীয় পর্যায় সক্রিয়';

  @override
  String get registrationInfo => 'নিবন্ধন তথ্য';

  @override
  String get businessName => 'ব্যবসার নাম';

  @override
  String get branchCode => 'শাখা কোড';

  @override
  String get qrCodeOnInvoice => 'ইনভয়েসে QR কোড';

  @override
  String get certificates => 'সার্টিফিকেট';

  @override
  String get csidCertificate => 'CSID সার্টিফিকেট';

  @override
  String get valid => 'বৈধ';

  @override
  String get privateKey => 'প্রাইভেট কী';

  @override
  String get configured => 'কনফিগার করা হয়েছে';

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
  String get aiTrend => 'প্রবণতা';

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
  String get aiInvestigation => 'তদন্ত';

  @override
  String get aiAssociationRules => 'Association Rules';

  @override
  String get aiBundleSuggestions => 'বান্ডেল পরামর্শ';

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
  String get aiMarketPosition => 'বাজার অবস্থান';

  @override
  String get aiQueryInput => 'Ask anything about your data...';

  @override
  String get aiReportTemplate => 'Report Template';

  @override
  String get aiStaffPerformance => 'Staff Performance';

  @override
  String get aiShiftOptimization => 'শিফট অপ্টিমাইজেশন';

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
  String get noteOptional => 'নোট (ঐচ্ছিক)';

  @override
  String get suspendInvoice => 'ইনভয়েস স্থগিত করুন';

  @override
  String get invoiceSuspended => 'ইনভয়েস স্থগিত হয়েছে';

  @override
  String nItems(int count) {
    return '$count আইটেম';
  }

  @override
  String saveSaleError(String error) {
    return 'বিক্রয় সংরক্ষণে ত্রুটি: $error';
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
  String get copyCode => 'কপি';

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
  String get resetAction => 'রিসেট';

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
  String get pasteCode => 'কোড পেস্ট করুন';

  @override
  String devOtpMessage(String otp) {
    return 'ডেভ OTP: $otp';
  }

  @override
  String get orderHistory => 'অর্ডার ইতিহাস';

  @override
  String get history => 'ইতিহাস';

  @override
  String get selectDateRange => 'সময়কাল নির্বাচন';

  @override
  String get orderSearchHint => 'অর্ডার নম্বর বা গ্রাহক ID দিয়ে খুঁজুন...';

  @override
  String get noOrders => 'কোনো অর্ডার নেই';

  @override
  String get orderStatusConfirmed => 'নিশ্চিত';

  @override
  String get orderStatusPreparing => 'প্রস্তুতি চলছে';

  @override
  String get orderStatusReady => 'প্রস্তুত';

  @override
  String get orderStatusDelivering => 'ডেলিভারি চলছে';

  @override
  String get filterOrders => 'অর্ডার ফিল্টার';

  @override
  String get channelApp => 'অ্যাপ';

  @override
  String get channelWhatsapp => 'হোয়াটসঅ্যাপ';

  @override
  String get channelPos => 'POS';

  @override
  String get paymentCashType => 'নগদ';

  @override
  String get paymentMixed => 'মিশ্র';

  @override
  String get paymentOnline => 'অনলাইন';

  @override
  String get shareAction => 'শেয়ার';

  @override
  String get exportOrders => 'অর্ডার রপ্তানি';

  @override
  String get selectExportFormat => 'রপ্তানি ফরম্যাট নির্বাচন';

  @override
  String get exportedAsExcel => 'Excel হিসেবে রপ্তানি';

  @override
  String get exportedAsPdf => 'PDF হিসেবে রপ্তানি';

  @override
  String get alertSettings => 'সতর্কতা সেটিংস';

  @override
  String get acknowledgeAll => 'সব স্বীকার করুন';

  @override
  String allWithCount(int count) {
    return 'সব ($count)';
  }

  @override
  String lowStockWithCount(int count) {
    return 'কম স্টক ($count)';
  }

  @override
  String expiryWithCount(int count) {
    return 'মেয়াদ নিকটে ($count)';
  }

  @override
  String get urgentAlerts => 'জরুরি সতর্কতা';

  @override
  String get nearExpiry => 'মেয়াদ নিকটে';

  @override
  String get noAlerts => 'কোনো সতর্কতা নেই';

  @override
  String get alertDismissed => 'সতর্কতা বাতিল';

  @override
  String get undo => 'পূর্বাবস্থায় ফেরান';

  @override
  String get criticalPriority => 'গুরুতর';

  @override
  String get highPriority => 'জরুরি';

  @override
  String stockAlertMessage(int current, int threshold) {
    return 'পরিমাণ: $current (সর্বনিম্ন: $threshold)';
  }

  @override
  String get expiryAlertLabel => 'মেয়াদ সতর্কতা';

  @override
  String get currentQuantity => 'বর্তমান পরিমাণ';

  @override
  String get minimumThreshold => 'সর্বনিম্ন';

  @override
  String get dismissAction => 'বাতিল করুন';

  @override
  String get lowStockNotifications => 'কম স্টক বিজ্ঞপ্তি';

  @override
  String get expiryNotifications => 'মেয়াদ বিজ্ঞপ্তি';

  @override
  String get minimumStockLevel => 'সর্বনিম্ন স্টক স্তর';

  @override
  String thresholdUnits(int count) {
    return '$count ইউনিট';
  }

  @override
  String get acknowledgeAllAlerts => 'সব সতর্কতা স্বীকার করুন';

  @override
  String willDismissAlerts(int count) {
    return '$count সতর্কতা বাতিল হবে';
  }

  @override
  String get allAlertsAcknowledged => 'সব সতর্কতা স্বীকৃত';

  @override
  String get createPurchaseOrder => 'ক্রয় অর্ডার তৈরি করুন';

  @override
  String productLabelName(String name) {
    return 'পণ্য: $name';
  }

  @override
  String get requiredQuantity => 'প্রয়োজনীয় পরিমাণ';

  @override
  String get createAction => 'তৈরি করুন';

  @override
  String get purchaseOrderCreated => 'ক্রয় অর্ডার তৈরি হয়েছে';

  @override
  String get newCategory => 'নতুন বিভাগ';

  @override
  String productCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count পণ্য',
      one: '1 পণ্য',
      zero: 'কোনো পণ্য নেই',
    );
    return '$_temp0';
  }

  @override
  String get iconLabel => 'আইকন:';

  @override
  String get colorLabel => 'রং:';

  @override
  String deleteCategoryMessage(String name, int count) {
    return 'বিভাগ \"$name\" মুছবেন?\n$count পণ্য \"অশ্রেণীবদ্ধ\"-এ যাবে।';
  }

  @override
  String productNumber(int number) {
    return 'পণ্য $number';
  }

  @override
  String priceWithCurrency(String price) {
    return '$price রিয়াল';
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
    return '$productA + $productB: $frequency বার পুনরাবৃত্তি';
  }

  @override
  String aiBundleActivated(String name) {
    return 'বান্ডেল সক্রিয়: $name';
  }

  @override
  String aiPromotionsGeneratedCount(int count) {
    return 'স্টোর ডেটা বিশ্লেষণের ভিত্তিতে $countটি প্রচার তৈরি হয়েছে';
  }

  @override
  String aiPromotionApplied(String title) {
    return 'প্রয়োগ করা হয়েছে: $title';
  }

  @override
  String aiConfidencePercent(String percent) {
    return 'আস্থা: $percent%';
  }

  @override
  String aiAlertsWithCount(int count) {
    return 'সতর্কতা ($count)';
  }

  @override
  String aiStaffCurrentSuggested(int current, int suggested) {
    return 'বর্তমানে $current জন কর্মী → $suggested জন প্রস্তাবিত';
  }

  @override
  String aiMinutesAgo(int minutes) {
    return '$minutes মিনিট আগে';
  }

  @override
  String aiHoursAgo(int hours) {
    return '$hours ঘণ্টা আগে';
  }

  @override
  String aiDaysAgo(int days) {
    return '$days দিন আগে';
  }

  @override
  String aiDetectedCount(int count) {
    return 'সনাক্ত: $count';
  }

  @override
  String aiMatchedCount(int count) {
    return 'মিলেছে: $count';
  }

  @override
  String aiAccuracyPercent(String percent) {
    return 'সঠিকতা: $percent%';
  }

  @override
  String aiProductAccepted(String name) {
    return '$name গৃহীত হয়েছে';
  }

  @override
  String aiErrorOccurred(String error) {
    return 'ত্রুটি ঘটেছে: $error';
  }

  @override
  String aiErrorWithMessage(String error) {
    return 'ত্রুটি: $error';
  }

  @override
  String get aiBasketAnalysis => 'AI ঝুড়ি বিশ্লেষণ';

  @override
  String get aiAssociations => 'সংযোগ';

  @override
  String get aiCrossSell => 'ক্রস-সেল';

  @override
  String get aiAvgBasketSize => 'গড় ঝুড়ির আকার';

  @override
  String get aiProductUnit => 'পণ্য';

  @override
  String get aiAvgBasketValue => 'গড় ঝুড়ির মূল্য';

  @override
  String get aiSaudiRiyal => 'SAR';

  @override
  String get aiStrongestAssociation => 'সবচেয়ে শক্তিশালী সংযোগ';

  @override
  String get aiConversionRate => 'রূপান্তর হার';

  @override
  String get aiFromSuggestions => 'পরামর্শ থেকে';

  @override
  String get aiAssistant => 'AI সহকারী';

  @override
  String get aiAskAboutStore => 'আপনার দোকান সম্পর্কে যেকোনো প্রশ্ন করুন';

  @override
  String get aiClearChat => 'চ্যাট মুছুন';

  @override
  String get aiAssistantReady => 'AI সহকারী সাহায্য করতে প্রস্তুত!';

  @override
  String get aiAskAboutSalesStock =>
      'বিক্রয়, স্টক, গ্রাহক বা আপনার দোকান সম্পর্কে যেকোনো কিছু জিজ্ঞাসা করুন';

  @override
  String get aiCompetitorAnalysis => 'প্রতিযোগী বিশ্লেষণ';

  @override
  String get aiPriceComparison => 'মূল্য তুলনা';

  @override
  String get aiTrackedProducts => 'ট্র্যাককৃত পণ্য';

  @override
  String get aiCheaperThanCompetitors => 'প্রতিযোগীদের চেয়ে সস্তা';

  @override
  String get aiMoreExpensive => 'প্রতিযোগীদের চেয়ে বেশি দামি';

  @override
  String get aiAvgPriceDiff => 'গড় মূল্য পার্থক্য';

  @override
  String get aiSortByName => 'নাম অনুসারে সাজান';

  @override
  String get aiSortByPriceDiff => 'মূল্য পার্থক্য অনুসারে সাজান';

  @override
  String get aiSortByOurPrice => 'আমাদের মূল্য অনুসারে সাজান';

  @override
  String get aiSortByCategory => 'বিভাগ অনুসারে সাজান';

  @override
  String get aiSortLabel => 'সাজান';

  @override
  String get aiPriceIndex => 'মূল্য সূচক';

  @override
  String get aiQuality => 'গুণমান';

  @override
  String get aiBranches => 'শাখা';

  @override
  String get aiMarkAllRead => 'সবগুলো পঠিত হিসেবে চিহ্নিত করুন';

  @override
  String get aiNoAlertsCurrently => 'বর্তমানে কোনো সতর্কতা নেই';

  @override
  String get aiFraudDetection => 'AI জালিয়াতি সনাক্তকরণ';

  @override
  String get aiTotalAlerts => 'মোট সতর্কতা';

  @override
  String get aiCriticalAlerts => 'গুরুতর সতর্কতা';

  @override
  String get aiNeedsReview => 'পর্যালোচনা প্রয়োজন';

  @override
  String get aiRiskLevel => 'ঝুঁকির মাত্রা';

  @override
  String get aiBehaviorScores => 'আচরণ স্কোর';

  @override
  String get aiRiskMeter => 'ঝুঁকি মিটার';

  @override
  String get aiHighRisk => 'উচ্চ ঝুঁকি';

  @override
  String get aiLowRisk => 'নিম্ন ঝুঁকি';

  @override
  String get aiPatternRefund => 'ফেরত';

  @override
  String get aiPatternAfterHours => 'কর্মঘণ্টার পরে';

  @override
  String get aiPatternVoid => 'বাতিল';

  @override
  String get aiPatternDiscount => 'ছাড়';

  @override
  String get aiPatternSplit => 'বিভক্ত';

  @override
  String get aiPatternCashDrawer => 'ক্যাশ ড্রয়ার';

  @override
  String get aiNoFraudAlerts => 'কোনো সতর্কতা নেই';

  @override
  String get aiSelectAlertToInvestigate =>
      'তদন্তের জন্য তালিকা থেকে একটি সতর্কতা নির্বাচন করুন';

  @override
  String get aiStaffAnalytics => 'কর্মী বিশ্লেষণ';

  @override
  String get aiLeaderboard => 'লিডারবোর্ড';

  @override
  String get aiIndividualPerformance => 'ব্যক্তিগত কর্মক্ষমতা';

  @override
  String get aiAvgPerformance => 'গড় কর্মক্ষমতা';

  @override
  String get aiTotalSalesLabel => 'মোট বিক্রয়';

  @override
  String get aiTotalTransactions => 'মোট লেনদেন';

  @override
  String get aiAvgVoidRate => 'গড় বাতিল হার';

  @override
  String get aiTeamGrowth => 'দলের বৃদ্ধি';

  @override
  String get aiLeaderboardThisWeek => 'লিডারবোর্ড - এই সপ্তাহ';

  @override
  String get aiSalesForecasting => 'বিক্রয় পূর্বাভাস';

  @override
  String get aiSmartForecastSubtitle =>
      'ভবিষ্যৎ বিক্রয় পূর্বাভাসের জন্য স্মার্ট বিশ্লেষণ';

  @override
  String get aiForecastAccuracy => 'পূর্বাভাস সঠিকতা';

  @override
  String get aiTrendUp => 'ঊর্ধ্বমুখী';

  @override
  String get aiTrendDown => 'নিম্নমুখী';

  @override
  String get aiTrendStable => 'স্থিতিশীল';

  @override
  String get aiNextWeekForecast => 'পরবর্তী সপ্তাহের পূর্বাভাস';

  @override
  String get aiMonthForecast => 'মাসের পূর্বাভাস';

  @override
  String get aiForecastSummary => 'পূর্বাভাস সারসংক্ষেপ';

  @override
  String get aiSalesTrendingUp => 'বিক্রয় ঊর্ধ্বমুখী - চালিয়ে যান!';

  @override
  String get aiSalesDeclining => 'বিক্রয় কমছে - অফার সক্রিয় করুন';

  @override
  String get aiSalesStable => 'বিক্রয় স্থিতিশীল - কর্মক্ষমতা বজায় রাখুন';

  @override
  String get aiProductRecognition => 'পণ্য শনাক্তকরণ';

  @override
  String get aiSingleProduct => 'একক পণ্য';

  @override
  String get aiShelfScan => 'শেলফ স্ক্যান';

  @override
  String get aiBarcodeOcr => 'বারকোড OCR';

  @override
  String get aiPriceTag => 'মূল্য ট্যাগ';

  @override
  String get aiCameraArea => 'ক্যামেরা এলাকা';

  @override
  String get aiPointCameraAtProduct =>
      'পণ্য বা শেলফের দিকে ক্যামেরা নির্দেশ করুন';

  @override
  String get aiStartScan => 'স্ক্যান শুরু';

  @override
  String get aiAnalyzingImage => 'ছবি বিশ্লেষণ হচ্ছে...';

  @override
  String get aiStartScanToSeeResults => 'ফলাফল দেখতে স্ক্যান শুরু করুন';

  @override
  String get aiScanResults => 'স্ক্যান ফলাফল';

  @override
  String get aiProductSaved => 'পণ্য সফলভাবে সংরক্ষিত হয়েছে';

  @override
  String get aiPromotionDesigner => 'AI প্রচার ডিজাইনার';

  @override
  String get aiSuggestedPromotions => 'প্রস্তাবিত প্রচার';

  @override
  String get aiRoiAnalysis => 'ROI বিশ্লেষণ';

  @override
  String get aiAbTest => 'A/B পরীক্ষা';

  @override
  String get aiSmartPromotionDesigner => 'স্মার্ট প্রচার ডিজাইনার';

  @override
  String get aiProjectedRevenue => 'প্রত্যাশিত আয়';

  @override
  String get aiAiConfidence => 'AI আস্থা';

  @override
  String get aiSelectPromotionForRoi =>
      'ROI বিশ্লেষণ দেখতে প্রথম ট্যাব থেকে একটি প্রচার নির্বাচন করুন';

  @override
  String get aiRevenueLabel => 'আয়';

  @override
  String get aiCostLabel => 'খরচ';

  @override
  String get aiDiscountLabel => 'ছাড়';

  @override
  String get aiAbTestDescription =>
      'A/B পরীক্ষা আপনার গ্রাহকদের দুটি গ্রুপে ভাগ করে এবং সেরা কর্মক্ষমতা নির্ধারণ করতে প্রতিটি গ্রুপকে ভিন্ন অফার দেখায়।';

  @override
  String get aiAbTestLaunched => 'A/B পরীক্ষা সফলভাবে চালু হয়েছে!';

  @override
  String get aiChatWithData => 'ডেটার সাথে চ্যাট - AI';

  @override
  String get aiChatWithYourData => 'আপনার ডেটার সাথে চ্যাট';

  @override
  String get aiAskAboutDataInArabic =>
      'আপনার বিক্রয়, স্টক এবং গ্রাহক সম্পর্কে যেকোনো প্রশ্ন করুন';

  @override
  String get aiTrySampleQuestions => 'এই প্রশ্নগুলোর একটি চেষ্টা করুন';

  @override
  String get aiTip => 'পরামর্শ';

  @override
  String get aiTipDescription =>
      'আপনি বাংলায় বা ইংরেজিতে জিজ্ঞাসা করতে পারেন। AI প্রসঙ্গ বোঝে এবং ফলাফল প্রদর্শনের সেরা উপায় বেছে নেয়: সংখ্যা, টেবিল বা চার্ট।';

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
  String get noteLabel => 'নোট';

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
    return '$count আইটেম';
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
  String get gotIt => 'বুঝেছি';

  @override
  String get print => 'প্রিন্ট';

  @override
  String get display => 'প্রদর্শন';

  @override
  String get item => 'আইটেম';

  @override
  String get invoice => 'চালান';

  @override
  String get accept => 'গ্রহণ করুন';

  @override
  String get details => 'বিবরণ';

  @override
  String get newLabel => 'নতুন';

  @override
  String get mixed => 'মিশ্র';

  @override
  String get lowStockLabel => 'কম';

  @override
  String get debtor => 'ঋণী';

  @override
  String get creditor => 'পাওনাদার';

  @override
  String get balanceLabel => 'ব্যালেন্স';

  @override
  String get returnLabel => 'ফেরত';

  @override
  String get skip => 'এড়িয়ে যান';

  @override
  String get send => 'পাঠান';

  @override
  String get cloud => 'ক্লাউড';

  @override
  String get defaultLabel => 'ডিফল্ট';

  @override
  String get closed => 'বন্ধ';

  @override
  String get owes => 'পাওনা';

  @override
  String get due => 'বকেয়া';

  @override
  String get balanced => 'সুষম';

  @override
  String get offlineModeTitle => 'অফলাইন মোড';

  @override
  String get offlineModeDescription => 'আপনি অ্যাপ ব্যবহার চালিয়ে যেতে পারেন:';

  @override
  String get offlineCanSell => 'বিক্রয় করুন';

  @override
  String get offlineCanAddToCart => 'পণ্য কার্টে যোগ করুন';

  @override
  String get offlineCanPrint => 'রসিদ প্রিন্ট করুন';

  @override
  String get offlineAutoSync => 'সংযোগ ফিরলে ডেটা স্বয়ংক্রিয় সিঙ্ক হবে';

  @override
  String get offlineSavingLocally => 'অফলাইন - স্থানীয়ভাবে সংরক্ষণ হচ্ছে';

  @override
  String get seconds => 'সেকেন্ড';

  @override
  String get errors => 'ত্রুটি';

  @override
  String get syncLabel => 'সিঙ্ক';

  @override
  String get slow => 'ধীর';

  @override
  String get myGrocery => 'আমার মুদি';

  @override
  String get cashier => 'ক্যাশিয়ার';

  @override
  String get goBack => 'পিছনে যান';

  @override
  String get menuLabel => 'মেনু';

  @override
  String get gold => 'স্বর্ণ';

  @override
  String get silver => 'সিলভার';

  @override
  String get diamond => 'ডায়মন্ড';

  @override
  String get bronze => 'ব্রোঞ্জ';

  @override
  String get saudiArabia => 'সৌদি আরব';

  @override
  String get uae => 'সংযুক্ত আরব আমিরাত';

  @override
  String get kuwait => 'কুয়েত';

  @override
  String get bahrain => 'বাহরাইন';

  @override
  String get qatar => 'কাতার';

  @override
  String get oman => 'ওমান';

  @override
  String get control => 'নিয়ন্ত্রণ';

  @override
  String get strong => 'শক্তিশালী';

  @override
  String get medium => 'মাঝারি';

  @override
  String get weak => 'দুর্বল';

  @override
  String get good => 'ভালো';

  @override
  String get danger => 'বিপদ';

  @override
  String get currentLabel => 'বর্তমান';

  @override
  String get suggested => 'সুপারিশকৃত';

  @override
  String get actual => 'প্রকৃত';

  @override
  String get forecast => 'পূর্বাভাস';

  @override
  String get critical => 'গুরুতর';

  @override
  String get high => 'উচ্চ';

  @override
  String get low => 'কম';

  @override
  String get investigation => 'তদন্ত';

  @override
  String get apply => 'প্রয়োগ করুন';

  @override
  String get run => 'চালান';

  @override
  String get positive => 'ইতিবাচক';

  @override
  String get neutral => 'নিরপেক্ষ';

  @override
  String get negative => 'নেতিবাচক';

  @override
  String get elastic => 'স্থিতিস্থাপক';

  @override
  String get demand => 'চাহিদা';

  @override
  String get quality => 'গুণমান';

  @override
  String get luxury => 'বিলাসবহুল';

  @override
  String get economic => 'অর্থনৈতিক';

  @override
  String get ourStore => 'আমাদের দোকান';

  @override
  String get upcoming => 'আসন্ন';

  @override
  String get cost => 'খরচ';

  @override
  String get duration => 'সময়কাল';

  @override
  String get quiet => 'শান্ত';

  @override
  String get busy => 'ব্যস্ত';

  @override
  String get outstanding => 'বকেয়া';

  @override
  String get donate => 'দান করুন';

  @override
  String get day => 'দিন';

  @override
  String get days => 'দিন';

  @override
  String get projected => 'অনুমানিত';

  @override
  String get analysis => 'বিশ্লেষণ';

  @override
  String get review => 'পর্যালোচনা';

  @override
  String get productCategory => 'বিভাগ';

  @override
  String get ourPrice => 'আমাদের দাম';

  @override
  String get position => 'পদ';

  @override
  String get cheapest => 'সবচেয়ে সস্তা';

  @override
  String get mostExpensive => 'সবচেয়ে দামি';

  @override
  String get soldOut => 'বিক্রি শেষ';

  @override
  String get noDataAvailable => 'কোনো ডেটা নেই';

  @override
  String get noDataFoundMessage => 'কোনো ডেটা পাওয়া যায়নি';

  @override
  String get noSearchResultsFound => 'কোনো ফলাফল পাওয়া যায়নি';

  @override
  String get noProductsFound => 'কোনো পণ্য পাওয়া যায়নি';

  @override
  String get noCustomers => 'কোনো গ্রাহক নেই';

  @override
  String get addCustomersToStart => 'শুরু করতে নতুন গ্রাহক যোগ করুন';

  @override
  String get noOrdersYet => 'এখনো কোনো অর্ডার নেই';

  @override
  String get noConnection => 'সংযোগ নেই';

  @override
  String get checkInternet => 'আপনার ইন্টারনেট সংযোগ পরীক্ষা করুন';

  @override
  String get cartIsEmpty => 'কার্ট খালি';

  @override
  String get browseProducts => 'পণ্য ব্রাউজ করুন';

  @override
  String noResultsFor(String query) {
    return '\"$query\" এর জন্য কোনো ফলাফল নেই';
  }

  @override
  String get paidLabel => 'পরিশোধিত';

  @override
  String get remainingLabel => 'বাকি';

  @override
  String get completeLabel => 'সম্পূর্ণ';

  @override
  String get addPayment => 'যোগ করুন';

  @override
  String get payments => 'পেমেন্ট';

  @override
  String get now => 'এখন';

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
  String get averageInvoice => 'গড় চালান';

  @override
  String errorPrefix(String message, Object error) {
    return 'ত্রুটি: $error';
  }

  @override
  String get vipMember => 'VIP সদস্য';

  @override
  String get activeSuppliers => 'সক্রিয় সরবরাহকারী';

  @override
  String get duePayments => 'বকেয়া পেমেন্ট';

  @override
  String get productCatalog => 'পণ্য ক্যাটালগ';

  @override
  String get comingSoonBrowseSuppliers =>
      'শীঘ্রই আসছে - সরবরাহকারী পণ্য ব্রাউজ';

  @override
  String get comingSoonTag => 'শীঘ্রই আসছে';

  @override
  String get supplierNotFound => 'সরবরাহকারী পাওয়া যায়নি';

  @override
  String get viewAllPurchases => 'সব ক্রয় দেখুন';

  @override
  String get completedLabel => 'সম্পন্ন';

  @override
  String get pendingStatusLabel => 'মুলতুবি';

  @override
  String get registerPayment => 'পেমেন্ট রেজিস্টার';

  @override
  String errorLoadingSuppliers(Object error) {
    return 'সরবরাহকারী লোডে ত্রুটি: $error';
  }

  @override
  String get cancelLabel => 'বাতিল';

  @override
  String get addLabel => 'যোগ করুন';

  @override
  String get saveLabel => 'সংরক্ষণ';

  @override
  String purchaseInvoiceSaved(Object total) {
    return 'ক্রয় চালান সংরক্ষিত - মোট: $total রিয়াল';
  }

  @override
  String errorSavingPurchase(Object error) {
    return 'ক্রয় সংরক্ষণে ত্রুটি: $error';
  }

  @override
  String get smartReorderTitle => 'স্মার্ট রি-অর্ডার';

  @override
  String get smartReorderAiTitle => 'AI স্মার্ট রি-অর্ডার';

  @override
  String get budgetDescription =>
      'বাজেট সেট করুন এবং সিস্টেম টার্নওভার হারে বিতরণ করবে';

  @override
  String get enterValidBudget => 'সঠিক বাজেট লিখুন';

  @override
  String get confirmSendTitle => 'পাঠানো নিশ্চিত করুন';

  @override
  String sendOrderToMsg(Object supplier) {
    return 'অর্ডার $supplier-কে পাঠাবেন?';
  }

  @override
  String get orderSentSuccessMsg => 'অর্ডার সফলভাবে পাঠানো হয়েছে';

  @override
  String sendingOrderVia(Object method) {
    return '$method দিয়ে অর্ডার পাঠানো হচ্ছে...';
  }

  @override
  String stockQuantity(Object qty) {
    return 'স্টক: $qty';
  }

  @override
  String turnoverLabel(Object rate) {
    return 'টার্নওভার: $rate%';
  }

  @override
  String failedCapture(Object error) {
    return 'ছবি তুলতে ব্যর্থ: $error';
  }

  @override
  String failedPickImage(Object error) {
    return 'ছবি বাছাইতে ব্যর্থ: $error';
  }

  @override
  String failedProcessInvoice(Object error) {
    return 'চালান প্রক্রিয়ায় ব্যর্থ: $error';
  }

  @override
  String matchLabel(Object name) {
    return 'মিল: $name';
  }

  @override
  String suggestedProduct(Object index) {
    return 'সুপারিশকৃত পণ্য $index';
  }

  @override
  String get barcodeLabel => 'বারকোড: 123456789';

  @override
  String get purchaseInvoiceSavedSuccess => 'ক্রয় চালান সফলভাবে সংরক্ষিত';

  @override
  String get aiImportedInvoice => 'AI আমদানি চালান';

  @override
  String aiInvoiceNote(Object number) {
    return 'AI চালান: $number';
  }

  @override
  String get supplierCanCreateOrders =>
      'এই সরবরাহকারী থেকে ক্রয় অর্ডার তৈরি করতে পারেন';

  @override
  String get notesFieldHint => 'সরবরাহকারী সম্পর্কে অতিরিক্ত নোট...';

  @override
  String get deleteConfirmCancel => 'বাতিল';

  @override
  String get deleteConfirmBtn => 'মুছুন';

  @override
  String get supplierUpdatedMsg => 'সরবরাহকারী ডেটা আপডেট';

  @override
  String errorOccurredMsg(Object error) {
    return 'ত্রুটি: $error';
  }

  @override
  String errorDuringDeleteMsg(Object error) {
    return 'মুছতে ত্রুটি: $error';
  }

  @override
  String get fortyFiveDays => '৪৫ দিন';

  @override
  String get expenseCategoriesTitle => 'ব্যয় বিভাগ';

  @override
  String get noCategoriesFound => 'কোনো ব্যয় বিভাগ পাওয়া যায়নি';

  @override
  String get monthlyBudget => 'মাসিক বাজেট';

  @override
  String get spentAmount => 'ব্যয়';

  @override
  String get remainingAmount => 'বাকি';

  @override
  String get overBudget => 'বাজেটের বেশি';

  @override
  String expenseCount(Object count) {
    return '$count ব্যয়';
  }

  @override
  String spentLabel(Object amount) {
    return 'ব্যয়: $amount রিয়াল';
  }

  @override
  String remainingLabel2(Object amount) {
    return 'বাকি: $amount রিয়াল';
  }

  @override
  String expensesThisMonth(Object count) {
    return 'এই মাসে $count ব্যয়';
  }

  @override
  String get recentExpenses => 'সাম্প্রতিক ব্যয়';

  @override
  String expenseNumber(Object id) {
    return 'ব্যয় #$id';
  }

  @override
  String get budgetLabel => 'বাজেট';

  @override
  String get monthlyBudgetLabel => 'মাসিক বাজেট';

  @override
  String get categoryNameHint => 'উদাহরণ: কর্মচারী বেতন';

  @override
  String get productNameLabel => 'পণ্যের নাম *';

  @override
  String get quantityLabel => 'পরিমাণ';

  @override
  String get purchasePriceLabel => 'ক্রয় মূল্য';

  @override
  String get saveInvoiceBtn => 'চালান সংরক্ষণ';

  @override
  String get ibanLabel => 'IBAN অ্যাকাউন্ট নম্বর';

  @override
  String get supplierActiveLabel => 'সরবরাহকারী সক্রিয়';

  @override
  String get notesLabel => 'নোট';

  @override
  String get deleteSupplierConfirm =>
      'এই সরবরাহকারী মুছতে চান? সব সংশ্লিষ্ট ডেটা মুছে যাবে।';

  @override
  String get supplierDeletedMsg => 'সরবরাহকারী মুছে ফেলা হয়েছে';

  @override
  String get savingLabel => 'সংরক্ষণ হচ্ছে...';

  @override
  String get supplierDetailTitle => 'সরবরাহকারী বিবরণ';

  @override
  String get supplierNotFoundMsg => 'সরবরাহকারী পাওয়া যায়নি';

  @override
  String get lastPurchaseLabel => 'শেষ ক্রয়';

  @override
  String get recentPurchasesLabel => 'সাম্প্রতিক ক্রয়';

  @override
  String get noPurchasesLabel => 'এখনো কোনো ক্রয় নেই';

  @override
  String get supplierAddedMsg => 'সরবরাহকারী যোগ হয়েছে';

  @override
  String get openingCashLabel => 'শুরুর নগদ';

  @override
  String get importantNotes => 'গুরুত্বপূর্ণ নোট';

  @override
  String get countCashBeforeShift => 'শিফট খোলার আগে ড্রয়ারে নগদ গণনা করুন';

  @override
  String get shiftTimeAutoRecorded => 'শিফট খোলার সময় স্বয়ংক্রিয় রেকর্ড হবে';

  @override
  String get oneShiftAtATime => 'একসাথে একাধিক শিফট খোলা যায় না';

  @override
  String get pleaseEnterOpeningCash => 'শুরুর নগদ পরিমাণ লিখুন (শূন্যের বেশি)';

  @override
  String shiftOpenedWithAmount(String amount, String currency) {
    return 'শিফট $amount $currency দিয়ে খোলা হয়েছে';
  }

  @override
  String get errorOpeningShift => 'শিফট খুলতে ত্রুটি';

  @override
  String get noOpenShift => 'কোনো খোলা শিফট নেই';

  @override
  String get shiftInfoLabel => 'শিফট তথ্য';

  @override
  String get salesSummaryLabel => 'বিক্রয় সারসংক্ষেপ';

  @override
  String get cashRefundsLabel => 'নগদ ফেরত';

  @override
  String get cashDepositLabel => 'নগদ জমা';

  @override
  String get cashWithdrawalLabel => 'নগদ উত্তোলন';

  @override
  String get expectedInDrawer => 'ড্রয়ারে প্রত্যাশিত';

  @override
  String get actualCashInDrawer => 'ড্রয়ারে প্রকৃত নগদ';

  @override
  String get drawerMatched => 'মিলেছে';

  @override
  String get surplusStatus => 'উদ্বৃত্ত';

  @override
  String get deficitStatus => 'ঘাটতি';

  @override
  String expectedAmountCurrency(String amount, String currency) {
    return 'প্রত্যাশিত: $amount $currency';
  }

  @override
  String actualAmountCurrency(String amount, String currency) {
    return 'প্রকৃত: $amount $currency';
  }

  @override
  String get drawerMatchedMessage => 'ড্রয়ার মিলেছে';

  @override
  String surplusAmount(String amount, String currency) {
    return 'উদ্বৃত্ত: +$amount $currency';
  }

  @override
  String deficitAmount(String amount, String currency) {
    return 'ঘাটতি: $amount $currency';
  }

  @override
  String get confirmCloseShift => 'শিফট বন্ধ করতে চান?';

  @override
  String get errorClosingShift => 'শিফট বন্ধে ত্রুটি';

  @override
  String get shiftClosedSuccessfully => 'শিফট সফলভাবে বন্ধ';

  @override
  String get shiftStatsLabel => 'শিফট পরিসংখ্যান';

  @override
  String get shiftDurationLabel => 'শিফটের সময়কাল';

  @override
  String get invoiceCountLabel => 'চালান সংখ্যা';

  @override
  String get invoiceUnit => 'চালান';

  @override
  String get cardSalesLabel => 'কার্ড বিক্রয়';

  @override
  String get cashSalesLabel => 'নগদ বিক্রয়';

  @override
  String get refundsLabel => 'ফেরত';

  @override
  String get expectedInDrawerLabel => 'ড্রয়ারে প্রত্যাশিত';

  @override
  String get actualInDrawerLabel => 'ড্রয়ারে প্রকৃত';

  @override
  String get differenceLabel => 'পার্থক্য';

  @override
  String get printingReport => 'রিপোর্ট প্রিন্ট হচ্ছে...';

  @override
  String get sharingInProgress => 'শেয়ার হচ্ছে...';

  @override
  String get openNewShift => 'নতুন শিফট খুলুন';

  @override
  String hoursAndMinutes(int hours, int minutes) {
    return '$hours ঘণ্টা $minutes মিনিট';
  }

  @override
  String hoursOnly(int hours) {
    return '$hours ঘণ্টা';
  }

  @override
  String minutesOnly(int minutes) {
    return '$minutes মিনিট';
  }

  @override
  String get rejectedNotApproved => 'কার্যক্রম প্রত্যাখ্যান - অনুমোদিত নয়';

  @override
  String errorWithDetails(String error) {
    return 'ত্রুটি: $error';
  }

  @override
  String get inventoryManagement => 'ইনভেন্টরি পরিচালনা ও ট্র্যাক';

  @override
  String get bulkEdit => 'বাল্ক এডিট';

  @override
  String get totalProducts => 'মোট পণ্য';

  @override
  String get inventoryValue => 'ইনভেন্টরি মূল্য';

  @override
  String get exportInventoryReport => 'ইনভেন্টরি রিপোর্ট রপ্তানি';

  @override
  String get printOrderList => 'অর্ডার তালিকা প্রিন্ট';

  @override
  String get inventoryMovementLog => 'ইনভেন্টরি মুভমেন্ট লগ';

  @override
  String get editSelected => 'নির্বাচিত সম্পাদনা';

  @override
  String get clearSelection => 'নির্বাচন মুছুন';

  @override
  String get noOutOfStockProducts => 'কোনো স্টকআউট পণ্য নেই';

  @override
  String get allProductsAvailable => 'সব পণ্য স্টকে আছে';

  @override
  String get editStock => 'স্টক সম্পাদনা';

  @override
  String get newQuantity => 'নতুন পরিমাণ';

  @override
  String get receiveGoods => 'পণ্য গ্রহণ';

  @override
  String get damaged => 'ক্ষতিগ্রস্ত';

  @override
  String get correction => 'সংশোধন';

  @override
  String get stockUpdatedTo => 'স্টক আপডেট হয়েছে';

  @override
  String get featureUnderDevelopment => 'এই ফিচার উন্নয়নাধীন...';

  @override
  String get newest => 'নবীনতম';

  @override
  String get adjustStock => 'স্টক সমন্বয় করুন';

  @override
  String get adjustmentHistory => 'সমন্বয় ইতিহাস';

  @override
  String get errorLoadingProducts => 'পণ্য লোডে ত্রুটি';

  @override
  String get selectProduct => 'পণ্য নির্বাচন';

  @override
  String get subtract => 'বিয়োগ';

  @override
  String get setQuantity => 'সেট করুন';

  @override
  String get enterQuantity => 'পরিমাণ লিখুন';

  @override
  String get enterValidQuantity => 'সঠিক পরিমাণ লিখুন';

  @override
  String get notesOptional => 'নোট (ঐচ্ছিক)';

  @override
  String get enterAdditionalNotes => 'অতিরিক্ত নোট লিখুন...';

  @override
  String get adjustmentSummary => 'সমন্বয় সারসংক্ষেপ';

  @override
  String get newStock => 'নতুন স্টক';

  @override
  String get warningNegativeStock => 'সতর্কতা: স্টক নেতিবাচক হবে!';

  @override
  String get saving => 'সংরক্ষণ হচ্ছে...';

  @override
  String get storeNotSelected => 'স্টোর নির্বাচিত নয়';

  @override
  String get noInventoryMovements => 'কোনো ইনভেন্টরি মুভমেন্ট নেই';

  @override
  String get adjustmentSavedSuccess => 'সমন্বয় সফলভাবে সংরক্ষিত';

  @override
  String get errorSaving => 'সংরক্ষণে ত্রুটি';

  @override
  String get enterBarcode => 'বারকোড লিখুন';

  @override
  String get theft => 'চুরি';

  @override
  String get noMatchingProducts => 'কোনো মিলিত পণ্য নেই';

  @override
  String get stockTransfer => 'স্টক স্থানান্তর';

  @override
  String get newTransfer => 'নতুন স্থানান্তর';

  @override
  String get fromBranch => 'শাখা থেকে';

  @override
  String get toBranch => 'শাখায়';

  @override
  String get selectSourceBranch => 'উৎস শাখা নির্বাচন';

  @override
  String get selectTargetBranch => 'লক্ষ্য শাখা নির্বাচন';

  @override
  String get selectProductsForTransfer => 'স্থানান্তরের জন্য পণ্য নির্বাচন';

  @override
  String get creating => 'তৈরি হচ্ছে...';

  @override
  String get createTransferRequest => 'স্থানান্তর অনুরোধ তৈরি করুন';

  @override
  String get errorLoadingTransfers => 'স্থানান্তর লোডে ত্রুটি';

  @override
  String get noPreviousTransfers => 'কোনো পূর্ববর্তী স্থানান্তর নেই';

  @override
  String get approved => 'অনুমোদিত';

  @override
  String get inTransit => 'পথে';

  @override
  String get complete => 'সম্পূর্ণ';

  @override
  String get completeTransfer => 'স্থানান্তর সম্পন্ন করুন';

  @override
  String get completeTransferConfirm =>
      'এই স্থানান্তর সম্পন্ন করতে চান? উৎস থেকে পরিমাণ কমবে এবং লক্ষ্য শাখায় যোগ হবে।';

  @override
  String get transferCompletedSuccess => 'স্থানান্তর সম্পন্ন ও স্টক আপডেট';

  @override
  String get errorCompletingTransfer => 'স্থানান্তর সম্পন্নে ত্রুটি';

  @override
  String get transferCreatedSuccess => 'স্থানান্তর অনুরোধ সফলভাবে তৈরি';

  @override
  String get errorCreatingTransfer => 'স্থানান্তর তৈরিতে ত্রুটি';

  @override
  String get stockTake => 'স্টক টেক';

  @override
  String get startStockTake => 'স্টক টেক শুরু করুন';

  @override
  String get counted => 'গণনা হয়েছে';

  @override
  String get variances => 'তারতম্য';

  @override
  String get of_ => 'এর';

  @override
  String get system => 'সিস্টেম';

  @override
  String get count => 'গণনা';

  @override
  String get finishStockTake => 'স্টক টেক শেষ করুন';

  @override
  String get stockTakeDescription =>
      'স্টক পণ্য গণনা করুন ও সিস্টেমের সাথে তুলনা করুন';

  @override
  String get noProductsInStock => 'স্টকে কোনো পণ্য নেই';

  @override
  String get noProductsToCount => 'গণনা শুরু করতে কোনো পণ্য নেই';

  @override
  String get errorCreatingStockTake => 'স্টক টেক তৈরিতে ত্রুটি';

  @override
  String get saveStockTakeConfirm =>
      'স্টক টেক ফলাফল সংরক্ষণ ও ইনভেন্টরি আপডেট করবেন?';

  @override
  String get stockTakeSavedSuccess => 'স্টক টেক সংরক্ষিত ও ইনভেন্টরি আপডেট';

  @override
  String get errorCompletingStockTake => 'স্টক টেক সম্পন্নে ত্রুটি';

  @override
  String get stockTakeHistory => 'স্টক টেক ইতিহাস';

  @override
  String get errorLoadingHistory => 'ইতিহাস লোডে ত্রুটি';

  @override
  String get noStockTakeHistory => 'কোনো পূর্ববর্তী স্টক টেক নেই';

  @override
  String get inProgress => 'চলছে';

  @override
  String get expiryTracking => 'মেয়াদ ট্র্যাকিং';

  @override
  String get errorLoadingExpiryData => 'মেয়াদ ডেটা লোডে ত্রুটি';

  @override
  String get withinMonth => 'এক মাসের মধ্যে';

  @override
  String get noProductsExpiringIn7Days =>
      '৭ দিনে কোনো পণ্যের মেয়াদ শেষ হচ্ছে না';

  @override
  String get noProductsExpiringInMonth =>
      'এক মাসে কোনো পণ্যের মেয়াদ শেষ হচ্ছে না';

  @override
  String get noExpiredProducts => 'কোনো মেয়াদোত্তীর্ণ পণ্য নেই';

  @override
  String get batch => 'ব্যাচ';

  @override
  String expiredSinceDays(int days) {
    return '$days দিন আগে মেয়াদ শেষ';
  }

  @override
  String get remove => 'সরান';

  @override
  String get pressToAddExpiryTracking => 'নতুন মেয়াদ ট্র্যাকিং যোগে + চাপুন';

  @override
  String get applyDiscountTo => 'ছাড় প্রয়োগ করুন';

  @override
  String get confirmRemoval => 'অপসারণ নিশ্চিত করুন';

  @override
  String get removeExpiryTrackingFor => 'মেয়াদ ট্র্যাকিং সরান';

  @override
  String get expiryTrackingRemoved => 'মেয়াদ ট্র্যাকিং অপসারিত';

  @override
  String get errorRemovingExpiryTracking => 'মেয়াদ ট্র্যাকিং অপসারণে ত্রুটি';

  @override
  String get addExpiryDate => 'মেয়াদ শেষের তারিখ যোগ করুন';

  @override
  String get barcodeOrProductName => 'বারকোড বা পণ্যের নাম';

  @override
  String get selectDate => 'তারিখ নির্বাচন';

  @override
  String get batchNumberOptional => 'ব্যাচ নম্বর (ঐচ্ছিক)';

  @override
  String get expiryTrackingAdded => 'মেয়াদ ট্র্যাকিং সফলভাবে যোগ হয়েছে';

  @override
  String get errorAddingExpiryTracking => 'মেয়াদ ট্র্যাকিং যোগে ত্রুটি';

  @override
  String get barcodeScanner2 => 'বারকোড স্ক্যানার';

  @override
  String get scanning => 'স্ক্যান হচ্ছে...';

  @override
  String get pressToStart => 'শুরু করতে চাপুন';

  @override
  String get stop => 'থামুন';

  @override
  String get startScanning => 'স্ক্যান শুরু করুন';

  @override
  String get enterBarcodeManually => 'ম্যানুয়ালি বারকোড লিখুন';

  @override
  String get noScannedProducts => 'কোনো স্ক্যান পণ্য নেই';

  @override
  String get enterBarcodeToSearch => 'অনুসন্ধানে বারকোড লিখুন';

  @override
  String get useManualInputToSearch =>
      'পণ্য খুঁজতে ম্যানুয়াল ইনপুট ব্যবহার করুন';

  @override
  String get found => 'পাওয়া গেছে';

  @override
  String get productNotFoundForBarcode => 'পণ্য পাওয়া যায়নি';

  @override
  String get addNewProduct => 'নতুন পণ্য যোগ করুন';

  @override
  String get willOpenAddProductScreen => 'পণ্য যোগ স্ক্রীন খুলবে';

  @override
  String get scanHistory => 'স্ক্যান ইতিহাস';

  @override
  String get addedToCart => 'যোগ হয়েছে';

  @override
  String get barcodePrint => 'বারকোড প্রিন্ট';

  @override
  String get noProductsWithBarcode => 'বারকোডসহ কোনো পণ্য নেই';

  @override
  String get addBarcodeFirst => 'প্রথমে পণ্যে বারকোড যোগ করুন';

  @override
  String get searchProduct => 'পণ্য অনুসন্ধান...';

  @override
  String get totalLabels => 'মোট লেবেল';

  @override
  String get printLabels => 'লেবেল প্রিন্ট';

  @override
  String get printList => 'তালিকা প্রিন্ট';

  @override
  String get selectProductsToPrint => 'প্রিন্টের জন্য পণ্য নির্বাচন';

  @override
  String get willPrint => 'প্রিন্ট হবে';

  @override
  String get label => 'লেবেল';

  @override
  String get printing => 'প্রিন্ট হচ্ছে...';

  @override
  String get messageAddedToQueue => 'পাঠানোর সারিতে বার্তা যোগ হয়েছে';

  @override
  String get messageSendFailed => 'বার্তা পাঠাতে ব্যর্থ';

  @override
  String get noPhoneForCustomer => 'গ্রাহকের ফোন নম্বর নেই';

  @override
  String get inputContainsDangerousContent => 'ইনপুটে নিষিদ্ধ বিষয়বস্তু আছে';

  @override
  String whatsappGreeting(String name) {
    return 'হ্যালো $name\nআমরা আপনাকে কিভাবে সাহায্য করতে পারি?';
  }

  @override
  String get segmentVip => 'VIP';

  @override
  String get segmentRegular => 'নিয়মিত';

  @override
  String get segmentAtRisk => 'ঝুঁকিতে';

  @override
  String get segmentLost => 'হারানো';

  @override
  String get segmentNewCustomer => 'নতুন';

  @override
  String customerCount(int count) {
    return '$count গ্রাহক';
  }

  @override
  String revenueK(String amount) {
    return '${amount}K রিয়াল';
  }

  @override
  String get tabRecommendations => 'সুপারিশ';

  @override
  String get tabRepurchase => 'পুনরায় ক্রয়';

  @override
  String get tabSegments => 'বিভাগ';

  @override
  String lastVisitLabel(String time) {
    return 'শেষ ভিজিট: $time';
  }

  @override
  String visitCountLabel(int count) {
    return '$count ভিজিট';
  }

  @override
  String avgSpendLabel(String amount) {
    return 'গড়: $amount রিয়াল';
  }

  @override
  String totalSpentLabel(String amount) {
    return 'মোট: ${amount}K রিয়াল';
  }

  @override
  String get recommendedProducts => 'সুপারিশকৃত পণ্য';

  @override
  String get sendWhatsAppOffer => 'হোয়াটসঅ্যাপ অফার পাঠান';

  @override
  String get totalRevenueLabel => 'মোট আয়';

  @override
  String get avgSpendStat => 'গড় ব্যয়';

  @override
  String amountSar(String amount) {
    return '$amount রিয়াল';
  }

  @override
  String get specialOfferMissYou =>
      'আপনার জন্য বিশেষ অফার! আমরা আপনার ভিজিট মিস করি';

  @override
  String friendlyReminderPurchase(String product) {
    return '$product কেনার বন্ধুত্বপূর্ণ স্মরণ';
  }

  @override
  String get timeAgoToday => 'আজ';

  @override
  String get timeAgoYesterday => 'গতকাল';

  @override
  String timeAgoDays(int days) {
    return '$days দিন আগে';
  }

  @override
  String get riskAnalysisTab => 'ঝুঁকি বিশ্লেষণ';

  @override
  String get preventiveActionsTab => 'প্রতিরোধমূলক পদক্ষেপ';

  @override
  String errorOccurredDetail(String error) {
    return 'ত্রুটি: $error';
  }

  @override
  String get returnRateTitle => 'ফেরত হার';

  @override
  String get avgLast6Months => 'গত ৬ মাসের গড়';

  @override
  String get amountAtRiskTitle => 'ঝুঁকিতে পরিমাণ';

  @override
  String get highRiskOperations => 'উচ্চ ঝুঁকির কার্যক্রম';

  @override
  String get needsImmediateAction => 'তাৎক্ষণিক পদক্ষেপ প্রয়োজন';

  @override
  String get returnTrendTitle => 'ফেরত প্রবণতা';

  @override
  String operationsAtRiskCount(int count) {
    return 'ঝুঁকিতে কার্যক্রম ($count)';
  }

  @override
  String get riskFilterAll => 'সব';

  @override
  String get riskFilterVeryHigh => 'অতি উচ্চ';

  @override
  String get riskFilterHigh => 'উচ্চ';

  @override
  String get riskFilterMedium => 'মাঝারি';

  @override
  String get riskFilterLow => 'কম';

  @override
  String get totalExpectedSavings => 'মোট প্রত্যাশিত সঞ্চয়';

  @override
  String fromPreventiveActions(int count) {
    return '$count প্রতিরোধমূলক পদক্ষেপ থেকে';
  }

  @override
  String get suggestedPreventiveActions => 'সুপারিশকৃত প্রতিরোধমূলক পদক্ষেপ';

  @override
  String get applyPreventiveHint =>
      'রিটার্ন কমাতে ও গ্রাহক সন্তুষ্টি বাড়াতে এই পদক্ষেপ প্রয়োগ করুন';

  @override
  String actionApplied(String action) {
    return 'প্রয়োগ: $action';
  }

  @override
  String actionDismissed(String action) {
    return 'বাতিল: $action';
  }

  @override
  String get veryPositiveSentiment => 'অত্যন্ত ইতিবাচক';

  @override
  String get positiveSentiment => 'ইতিবাচক';

  @override
  String get neutralSentiment => 'নিরপেক্ষ';

  @override
  String get negativeSentiment => 'নেতিবাচক';

  @override
  String get veryNegativeSentiment => 'অত্যন্ত নেতিবাচক';

  @override
  String get ratingsDistribution => 'রেটিং বিতরণ';

  @override
  String get sentimentTrendTitle => 'মনোভাব প্রবণতা';

  @override
  String get sentimentIndicator => 'মনোভাব সূচক';

  @override
  String minutesAgoSentiment(int count) {
    return '$count মিনিট আগে';
  }

  @override
  String hoursAgoSentiment(int count) {
    return '$count ঘণ্টা আগে';
  }

  @override
  String daysAgoSentiment(int count) {
    return '$count দিন আগে';
  }

  @override
  String get totalProductsTitle => 'মোট পণ্য';

  @override
  String get categoryATitle => 'বিভাগ A';

  @override
  String get mostImportant => 'সবচেয়ে গুরুত্বপূর্ণ';

  @override
  String get withinDays => '৭ দিনের মধ্যে';

  @override
  String get needReorder => 'পুনরায় অর্ডার প্রয়োজন';

  @override
  String estimatedLossSar(String amount) {
    return '$amount রিয়াল আনুমানিক ক্ষতি';
  }

  @override
  String get tabAbcAnalysis => 'ABC বিশ্লেষণ';

  @override
  String get tabWastePrediction => 'অপচয় পূর্বাভাস';

  @override
  String get tabReorder => 'রি-অর্ডার';

  @override
  String get filterAllLabel => 'সব';

  @override
  String get categoryALabel => 'বিভাগ A';

  @override
  String get categoryBLabel => 'বিভাগ B';

  @override
  String get categoryCLabel => 'বিভাগ C';

  @override
  String orderUnitsSnack(int qty, String name) {
    return '$name এর $qty ইউনিট অর্ডার করুন';
  }

  @override
  String get urgencyCritical => 'গুরুতর';

  @override
  String get urgencyHigh => 'উচ্চ';

  @override
  String get urgencyMedium => 'মাঝারি';

  @override
  String get urgencyLow => 'কম';

  @override
  String get currentStockLabel => 'বর্তমান স্টক';

  @override
  String get reorderPointLabel => 'পুনরায় অর্ডার পয়েন্ট';

  @override
  String get suggestedQtyLabel => 'সুপারিশকৃত পরিমাণ';

  @override
  String get daysOfStockLabel => 'স্টকের দিন';

  @override
  String estimatedCostLabel(String amount) {
    return 'আনুমানিক খরচ: $amount রিয়াল';
  }

  @override
  String purchaseOrderCreatedFor(String name) {
    return 'ক্রয় অর্ডার তৈরি: $name';
  }

  @override
  String orderUnitsButton(int qty) {
    return '$qty ইউনিট অর্ডার করুন';
  }

  @override
  String get actionDiscount => 'ছাড়';

  @override
  String get actionTransfer => 'স্থানান্তর';

  @override
  String get actionDonate => 'দান';

  @override
  String actionOnProduct(String name) {
    return 'কার্যক্রম: $name';
  }

  @override
  String get totalSuggestionsLabel => 'মোট পরামর্শ';

  @override
  String get canIncreaseLabel => 'বাড়ানো যায়';

  @override
  String get shouldDecreaseLabel => 'কমানো উচিত';

  @override
  String get expectedMonthlyImpact => 'প্রত্যাশিত মাসিক প্রভাব';

  @override
  String get noSuggestionsInFilter => 'এই ফিল্টারে কোনো পরামর্শ নেই';

  @override
  String get selectProductForDetails => 'বিবরণ দেখতে পণ্য নির্বাচন করুন';

  @override
  String get selectProductHint =>
      'প্রভাব ক্যালকুলেটর দেখতে তালিকা থেকে পণ্যে ক্লিক করুন';

  @override
  String priceApplied(String price, String product) {
    return 'দাম $price রিয়াল $product-এ প্রয়োগ';
  }

  @override
  String errorOccurredShort(String error) {
    return 'ত্রুটি: $error';
  }

  @override
  String get readyTemplates => 'তৈরি টেমপ্লেট';

  @override
  String get hideTemplates => 'টেমপ্লেট লুকান';

  @override
  String get showTemplates => 'টেমপ্লেট দেখান';

  @override
  String get askAboutStore => 'আপনার দোকান সম্পর্কে যেকোনো প্রশ্ন করুন';

  @override
  String get writeQuestionHint =>
      'আপনার প্রশ্ন লিখুন এবং আমরা স্বয়ংক্রিয় উপযুক্ত রিপোর্ট তৈরি করব';

  @override
  String get quickActionTodaySales => 'আজ কত বিক্রি হয়েছে?';

  @override
  String get quickActionTop10 => 'শীর্ষ ১০ পণ্য';

  @override
  String get quickActionMonthlyCompare => 'মাসিক তুলনা';

  @override
  String get analyzingData => 'ডেটা বিশ্লেষণ ও রিপোর্ট তৈরি হচ্ছে...';

  @override
  String get profileScreenTitle => 'প্রোফাইল';

  @override
  String get unknownUserName => 'অজানা';

  @override
  String get defaultEmployeeRole => 'কর্মচারী';

  @override
  String get transactionUnit => 'লেনদেন';

  @override
  String get dayUnit => 'দিন';

  @override
  String get emailFieldLabel => 'ইমেইল';

  @override
  String get phoneFieldLabel => 'ফোন';

  @override
  String get branchFieldLabel => 'শাখা';

  @override
  String get mainBranchName => 'প্রধান শাখা';

  @override
  String get employeeNumberLabel => 'কর্মচারী নম্বর';

  @override
  String get changePasswordLabel => 'পাসওয়ার্ড পরিবর্তন';

  @override
  String get activityLogLabel => 'কার্যকলাপ লগ';

  @override
  String get logoutDialogTitle => 'লগআউট';

  @override
  String get logoutDialogBody => 'সিস্টেম থেকে লগআউট করতে চান?';

  @override
  String get cancelButton => 'বাতিল';

  @override
  String get exitButton => 'বের হন';

  @override
  String get editProfileSnack => 'প্রোফাইল সম্পাদনা';

  @override
  String get changePasswordSnack => 'পাসওয়ার্ড পরিবর্তন';

  @override
  String get roleAdmin => 'সিস্টেম অ্যাডমিন';

  @override
  String get roleManager => 'ম্যানেজার';

  @override
  String get roleCashier => 'ক্যাশিয়ার';

  @override
  String get roleEmployee => 'কর্মচারী';

  @override
  String get onboardingTitle1 => 'দ্রুত পয়েন্ট অফ সেল';

  @override
  String get onboardingDesc1 =>
      'সহজ ও আরামদায়ক ইন্টারফেসে দ্রুত বিক্রয় সম্পন্ন করুন';

  @override
  String get onboardingTitle2 => 'অফলাইনে কাজ করুন';

  @override
  String get onboardingDesc2 =>
      'সংযোগ ছাড়া কাজ চালিয়ে যান, সিঙ্ক স্বয়ংক্রিয় হবে';

  @override
  String get onboardingTitle3 => 'ইনভেন্টরি ব্যবস্থাপনা';

  @override
  String get onboardingDesc3 =>
      'ঘাটতি ও মেয়াদ সতর্কতায় ইনভেন্টরি সঠিকভাবে ট্র্যাক করুন';

  @override
  String get onboardingTitle4 => 'স্মার্ট রিপোর্ট';

  @override
  String get onboardingDesc4 => 'দোকান পারফরম্যান্সের বিস্তারিত রিপোর্ট পান';

  @override
  String get startNow => 'এখনই শুরু করুন';

  @override
  String get favorites => 'পছন্দসই';

  @override
  String get editMode => 'সম্পাদনা';

  @override
  String get doneMode => 'হয়েছে';

  @override
  String get errorLoadingFavorites => 'পছন্দসই লোডে ত্রুটি';

  @override
  String get noFavoriteProducts => 'কোনো পছন্দসই পণ্য নেই';

  @override
  String get addFavoritesFromProducts => 'পণ্য স্ক্রীন থেকে পছন্দসইতে যোগ করুন';

  @override
  String get tapProductToAddToCart => 'কার্টে যোগ করতে পণ্যে ট্যাপ করুন';

  @override
  String addedProductToCart(String name) {
    return '$name কার্টে যোগ হয়েছে';
  }

  @override
  String get addToCartAction => 'কার্টে যোগ করুন';

  @override
  String get removeFromFavorites => 'পছন্দসই থেকে সরান';

  @override
  String removedProductFromFavorites(String name) {
    return '$name পছন্দসই থেকে সরানো হয়েছে';
  }

  @override
  String get paymentMethodTitle => 'পেমেন্ট পদ্ধতি';

  @override
  String get backEsc => 'পিছনে (Esc)';

  @override
  String get completePayment => 'পেমেন্ট সম্পন্ন করুন';

  @override
  String get enterToConfirm => 'নিশ্চিত করতে Enter চাপুন';

  @override
  String get cashOnlyOffline => 'অফলাইনে শুধু নগদ';

  @override
  String get cardsDisabledInSettings => 'সেটিংসে কার্ড নিষ্ক্রিয়';

  @override
  String get creditPayment => 'বাকি পেমেন্ট';

  @override
  String get unavailableOffline => 'অফলাইনে অনুপলব্ধ';

  @override
  String get disabledInSettings => 'সেটিংসে নিষ্ক্রিয়';

  @override
  String get amountReceived => 'প্রাপ্ত পরিমাণ';

  @override
  String get quickAmounts => 'দ্রুত পরিমাণ';

  @override
  String get requiredAmount => 'প্রয়োজনীয় পরিমাণ';

  @override
  String get changeLabel => 'ফেরত:';

  @override
  String get insufficientAmount => 'অপর্যাপ্ত পরিমাণ';

  @override
  String get rrnLabel => 'রেফারেন্স নম্বর (RRN)';

  @override
  String get enterRrnFromDevice => 'ডিভাইস থেকে লেনদেন নম্বর লিখুন';

  @override
  String get cardPaymentInstructions =>
      'গ্রাহককে কার্ড টার্মিনাল দিয়ে পেমেন্ট করতে বলুন, তারপর রসিদ থেকে লেনদেন নম্বর (RRN) দিন';

  @override
  String get creditSale => 'বাকি বিক্রয়';

  @override
  String get creditSaleWarning =>
      'এই পরিমাণ গ্রাহকের ঋণ হিসেবে রেকর্ড হবে। লেনদেন সম্পন্ন করার আগে গ্রাহক নির্বাচন নিশ্চিত করুন।';

  @override
  String get orderSummary => 'অর্ডার সারসংক্ষেপ';

  @override
  String get taxLabel => 'কর (১৫%)';

  @override
  String discountLabel(String value) {
    return 'ছাড়';
  }

  @override
  String get payCash => 'নগদ পেমেন্ট';

  @override
  String get payCard => 'কার্ডে পেমেন্ট';

  @override
  String get payCreditSale => 'বাকি বিক্রয়';

  @override
  String get confirmPayment => 'পেমেন্ট নিশ্চিত করুন';

  @override
  String get processingPayment => 'পেমেন্ট প্রক্রিয়া হচ্ছে...';

  @override
  String get pleaseWait => 'অনুগ্রহ করে অপেক্ষা করুন';

  @override
  String get paymentSuccessful => 'পেমেন্ট সফল!';

  @override
  String get printingReceipt => 'রসিদ প্রিন্ট হচ্ছে...';

  @override
  String get whatsappReceipt => 'হোয়াটসঅ্যাপ রসিদ';

  @override
  String get storeOrUserNotSet => 'স্টোর বা ব্যবহারকারী সেট নয়';

  @override
  String errorWithMessage(String message) {
    return 'ত্রুটি: $message';
  }

  @override
  String get receiptTitle => 'রসিদ';

  @override
  String get invoiceNotSpecified => 'চালান নম্বর নির্দিষ্ট নয়';

  @override
  String get pendingSync => 'সিঙ্ক মুলতুবি';

  @override
  String get notSynced => 'সিঙ্ক হয়নি';

  @override
  String receiptNumberLabel(String number) {
    return 'নম্বর: $number';
  }

  @override
  String get itemColumnHeader => 'আইটেম';

  @override
  String totalAmount(String amount) {
    return 'মোট';
  }

  @override
  String get paymentMethodField => 'পেমেন্ট পদ্ধতি';

  @override
  String get zatcaQrCode => 'ZATCA কর QR কোড';

  @override
  String get whatsappSentLabel => 'পাঠানো হয়েছে';

  @override
  String get whatsappLabel => 'হোয়াটসঅ্যাপ';

  @override
  String get whatsappReceiptSent => 'রসিদ হোয়াটসঅ্যাপে পাঠানো হয়েছে';

  @override
  String whatsappSendFailed(String error) {
    return 'পাঠাতে ব্যর্থ: $error';
  }

  @override
  String get cannotPrintNoInvoice => 'প্রিন্ট করা যাচ্ছে না - চালান নম্বর নেই';

  @override
  String get invoiceAddedToPrintQueue => 'চালান প্রিন্ট সারিতে যোগ হয়েছে';

  @override
  String get mixedMethod => 'মিশ্র';

  @override
  String get creditMethod => 'বাকি';

  @override
  String get walletMethod => 'ওয়ালেট';

  @override
  String get bankTransferMethod => 'ব্যাংক ট্রান্সফার';

  @override
  String get scanBarcodeHint => 'বারকোড স্ক্যান বা লিখুন (F1)';

  @override
  String get openCamera => 'ক্যামেরা খুলুন';

  @override
  String get searchProductHint => 'পণ্য অনুসন্ধান (F2)';

  @override
  String get hideCart => 'কার্ট লুকান';

  @override
  String get showCart => 'কার্ট দেখান';

  @override
  String get cartTitle => 'কার্ট';

  @override
  String get clearAction => 'মুছুন';

  @override
  String get allCategories => 'সব';

  @override
  String get otherCategory => 'অন্যান্য';

  @override
  String get storeNotSet => 'স্টোর সেট নয়';

  @override
  String get retryAction => 'পুনরায় চেষ্টা';

  @override
  String get vatTax15 => 'VAT (১৫%)';

  @override
  String get totalGrand => 'মোট';

  @override
  String get holdOrder => 'হোল্ড';

  @override
  String get payActionLabel => 'পেমেন্ট';

  @override
  String get f12QuickPay => 'দ্রুত পেমেন্টে F12';

  @override
  String productNotFoundBarcode(String barcode) {
    return 'বারকোডের জন্য পণ্য পাওয়া যায়নি: $barcode';
  }

  @override
  String get clearCartTitle => 'কার্ট মুছুন';

  @override
  String get clearCartMessage => 'কার্ট থেকে সব পণ্য সরাতে চান?';

  @override
  String get orderOnHold => 'অর্ডার হোল্ডে';

  @override
  String get deleteItem => 'মুছুন';

  @override
  String itemsCountPrice(int count, String price) {
    return '$count আইটেম - $price রিয়াল';
  }

  @override
  String get taxReportTitle => 'কর রিপোর্ট';

  @override
  String get exportReportAction => 'রিপোর্ট রপ্তানি';

  @override
  String get printReportAction => 'রিপোর্ট প্রিন্ট';

  @override
  String get quarterly => 'ত্রৈমাসিক';

  @override
  String get netTaxDue => 'বকেয়া নিট কর';

  @override
  String get salesTaxCollected => 'বিক্রয় কর';

  @override
  String get salesTaxSubtitle => 'সংগৃহীত';

  @override
  String get purchasesTaxPaid => 'ক্রয় কর';

  @override
  String get purchasesTaxSubtitle => 'পরিশোধিত';

  @override
  String get taxByPaymentMethod => 'পেমেন্ট পদ্ধতি অনুসারে কর';

  @override
  String invoiceCount(int count) {
    return '$count চালান';
  }

  @override
  String get taxDetailsTitle => 'কর বিবরণ';

  @override
  String get taxableSales => 'করযোগ্য বিক্রয়';

  @override
  String get salesTax15 => 'বিক্রয় কর (১৫%)';

  @override
  String get taxablePurchases => 'করযোগ্য ক্রয়';

  @override
  String get purchasesTax15 => 'ক্রয় কর (১৫%)';

  @override
  String get netTax => 'নিট কর';

  @override
  String get zatcaReminder => 'ZATCA স্মারক';

  @override
  String get zatcaDeadline => 'জমার শেষ তারিখ: পরবর্তী মাসের শেষ';

  @override
  String get historyAction => 'ইতিহাস';

  @override
  String get sendToAuthority => 'কর্তৃপক্ষকে পাঠান';

  @override
  String get cashPaymentMethod => 'নগদ';

  @override
  String get cardPaymentMethod => 'কার্ড';

  @override
  String get mixedPaymentMethod => 'মিশ্র';

  @override
  String get creditPaymentMethod => 'বাকি';

  @override
  String get vatReportTitle => 'VAT রিপোর্ট';

  @override
  String get selectPeriod => 'সময়কাল নির্বাচন';

  @override
  String get salesVat => 'বিক্রয় VAT';

  @override
  String get totalSalesIncVat => 'মোট বিক্রয় (VAT সহ)';

  @override
  String get vatCollected => 'সংগৃহীত VAT';

  @override
  String get purchasesVat => 'ক্রয় VAT';

  @override
  String get totalPurchasesIncVat => 'মোট ক্রয় (VAT সহ)';

  @override
  String get vatPaid => 'পরিশোধিত VAT';

  @override
  String get netVatDue => 'বকেয়া নিট VAT';

  @override
  String get dueToAuthority => 'কর্তৃপক্ষকে বকেয়া';

  @override
  String get dueFromAuthority => 'কর্তৃপক্ষ থেকে বকেয়া';

  @override
  String get exportingPdfReport => 'রিপোর্ট রপ্তানি হচ্ছে...';

  @override
  String get debtsReportTitle => 'ঋণ রিপোর্ট';

  @override
  String get sortByLastPayment => 'শেষ পেমেন্ট অনুসারে';

  @override
  String get customersCount => 'গ্রাহক';

  @override
  String get noOutstandingDebts => 'কোনো বকেয়া ঋণ নেই';

  @override
  String lastUpdate(String date) {
    return 'শেষ আপডেট: $date';
  }

  @override
  String get paymentAmountField => 'পেমেন্ট পরিমাণ';

  @override
  String get recordAction => 'রেকর্ড';

  @override
  String get paymentRecordedMsg => 'পেমেন্ট রেকর্ড হয়েছে';

  @override
  String showDetails(String name) {
    return 'বিবরণ দেখুন: $name';
  }

  @override
  String get debtsReportPdf => 'ঋণ রিপোর্ট';

  @override
  String dateFieldLabel(String date) {
    return 'তারিখ: $date';
  }

  @override
  String get debtsDetails => 'ঋণ বিবরণ:';

  @override
  String get customerCol => 'গ্রাহক';

  @override
  String get phoneCol => 'ফোন';

  @override
  String get refundReceiptTitle => 'ফেরত রসিদ';

  @override
  String get noRefundId => 'কোনো ফেরত ID নেই';

  @override
  String get refundNotFound => 'ফেরত ডেটা পাওয়া যায়নি';

  @override
  String get refundSuccessful => 'ফেরত সফল';

  @override
  String refundNumberLabel(String number) {
    return 'ফেরত নম্বর: $number';
  }

  @override
  String get refundReceipt => 'ফেরত রসিদ';

  @override
  String get originalInvoiceNumber => 'মূল চালান নম্বর';

  @override
  String get refundDate => 'ফেরত তারিখ';

  @override
  String get refundMethodField => 'ফেরত পদ্ধতি';

  @override
  String get returnedProducts => 'ফেরত পণ্য';

  @override
  String get totalRefund => 'মোট ফেরত';

  @override
  String get reasonLabel => 'কারণ';

  @override
  String get homeAction => 'হোম';

  @override
  String printError(String error) {
    return 'প্রিন্ট ত্রুটি: $error';
  }

  @override
  String get damagedProduct => 'ক্ষতিগ্রস্ত পণ্য';

  @override
  String get wrongOrder => 'ভুল অর্ডার';

  @override
  String get customerChangedMind => 'গ্রাহক মত পরিবর্তন করেছেন';

  @override
  String get expiredProduct => 'মেয়াদ শেষ পণ্য';

  @override
  String get unsatisfactoryQuality => 'অসন্তোষজনক মান';

  @override
  String get cashRefundMethod => 'নগদ';

  @override
  String get cardRefundMethod => 'কার্ড';

  @override
  String get walletRefundMethod => 'ওয়ালেট';

  @override
  String get refundReasonTitle => 'ফেরতের কারণ';

  @override
  String get noRefundData => 'কোনো ফেরত ডেটা নেই। পিছনে গিয়ে পণ্য বাছাই করুন।';

  @override
  String invoiceFieldLabel(String receiptNo) {
    return 'চালান: $receiptNo';
  }

  @override
  String productsCountAmount(int count, String amount) {
    return '$count পণ্য - $amount রিয়াল';
  }

  @override
  String get selectRefundReason => 'ফেরতের কারণ নির্বাচন';

  @override
  String get additionalNotesOptional => 'অতিরিক্ত নোট (ঐচ্ছিক)';

  @override
  String get addNotesHint => 'অতিরিক্ত নোট যোগ করুন...';

  @override
  String get processingAction => 'প্রক্রিয়া হচ্ছে...';

  @override
  String get nextSupervisorApproval => 'পরবর্তী - সুপারভাইজার অনুমোদন';

  @override
  String refundCreationError(String error) {
    return 'ফেরত তৈরিতে ত্রুটি: $error';
  }

  @override
  String get refundRequestTitle => 'ফেরত অনুরোধ';

  @override
  String get invoiceNumberHint => 'চালান নম্বর';

  @override
  String get searchAction => 'অনুসন্ধান';

  @override
  String get selectProductsForRefund => 'ফেরতের জন্য পণ্য নির্বাচন';

  @override
  String get selectAll => 'সব নির্বাচন';

  @override
  String quantityTimesPrice(int qty, String price) {
    return 'পরিমাণ: $qty × $price রিয়াল';
  }

  @override
  String productsSelected(int count) {
    return '$count পণ্য নির্বাচিত';
  }

  @override
  String refundAmountValue(String amount) {
    return 'পরিমাণ: $amount রিয়াল';
  }

  @override
  String get nextAction => 'পরবর্তী';

  @override
  String get enterInvoiceToSearch => 'অনুসন্ধানে চালান নম্বর লিখুন';

  @override
  String get invoiceNotFoundMsg => 'চালান পাওয়া যায়নি';

  @override
  String get shippingGatewaysTitle => 'শিপিং গেটওয়ে';

  @override
  String get availableShippingGateways => 'উপলব্ধ শিপিং গেটওয়ে';

  @override
  String get activateShippingGateways =>
      'অর্ডার ডেলিভারির জন্য শিপিং গেটওয়ে সক্রিয় ও কনফিগার করুন';

  @override
  String get aramexName => 'আরামেক্স';

  @override
  String get aramexDesc => 'একাধিক সেবা সহ বৈশ্বিক শিপিং কোম্পানি';

  @override
  String get smsaDesc => 'দ্রুত দেশীয় শিপিং';

  @override
  String get fastloName => 'ফাস্টলো';

  @override
  String get fastloDesc => 'একই দিন দ্রুত ডেলিভারি';

  @override
  String get dhlDesc => 'দ্রুত ও নির্ভরযোগ্য আন্তর্জাতিক শিপিং';

  @override
  String get jtDesc => 'সাশ্রয়ী শিপিং';

  @override
  String get customDeliveryName => 'কাস্টম ডেলিভারি';

  @override
  String get customDeliveryDesc =>
      'নিজের ড্রাইভার দিয়ে ডেলিভারি পরিচালনা করুন';

  @override
  String get settingsAction => 'সেটিংস';

  @override
  String get hourlyView => 'ঘণ্টায়';

  @override
  String get dailyView => 'দৈনিক';

  @override
  String get peakHourLabel => 'পিক ঘণ্টা';

  @override
  String transactionsWithCount(int count) {
    return '$count লেনদেন';
  }

  @override
  String get peakDayLabel => 'পিক দিন';

  @override
  String get avgPerHour => 'গড়/ঘণ্টা';

  @override
  String get transactionWord => 'লেনদেন';

  @override
  String get transactionsByHour => 'ঘণ্টা অনুসারে লেনদেন';

  @override
  String get transactionsByDay => 'দিন অনুসারে লেনদেন';

  @override
  String get activityHeatmap => 'কার্যকলাপ হিটম্যাপ';

  @override
  String get lowLabel => 'কম';

  @override
  String get highLabel => 'উচ্চ';

  @override
  String get analysisRecommendations => 'বিশ্লেষণ ভিত্তিক সুপারিশ';

  @override
  String get staffRecommendation => 'স্টাফ';

  @override
  String get staffRecommendationDesc =>
      '১২:০০-১৩:০০ ও ১৭:০০-১৯:০০ তে ক্যাশিয়ার বাড়ান (পিক বিক্রয়)';

  @override
  String get offersRecommendation => 'অফার';

  @override
  String get offersRecommendationDesc => '১৪:০০-১৬:০০ তে বিশেষ অফার দিন';

  @override
  String get inventoryRecommendation => 'ইনভেন্টরি';

  @override
  String get inventoryRecommendationDesc =>
      'বৃহস্পতি ও শুক্র আগে ইনভেন্টরি প্রস্তুত করুন (সর্বোচ্চ বিক্রয়ের দিন)';

  @override
  String get shiftsRecommendation => 'শিফট';

  @override
  String get shiftsRecommendationDesc =>
      'শিফট বিতরণ: সকাল ৮-১৫, সন্ধ্যা ১৫-২২ পিকে ওভারল্যাপ';

  @override
  String get topProductsTab => 'শীর্ষ পণ্য';

  @override
  String get byCategoryTab => 'বিভাগ অনুসারে';

  @override
  String get performanceAnalysisTab => 'কর্মক্ষমতা বিশ্লেষণ';

  @override
  String get noSalesDataForPeriod => 'নির্বাচিত সময়কালে কোনো বিক্রয় ডেটা নেই';

  @override
  String get categoryFilter => 'বিভাগ';

  @override
  String get allCategoriesFilter => 'সব বিভাগ';

  @override
  String get sortByField => 'সাজানো';

  @override
  String get revenueSort => 'আয়';

  @override
  String get unitsSort => 'ইউনিট';

  @override
  String get profitSort => 'লাভ';

  @override
  String get revenueLabel => 'আয়';

  @override
  String get unitsLabel => 'ইউনিট';

  @override
  String get profitLabel => 'লাভ';

  @override
  String get stockLabel => 'স্টক';

  @override
  String get revenueByCategoryTitle => 'বিভাগ অনুসারে আয় বিতরণ';

  @override
  String get noRevenueForPeriod => 'এই সময়কালে কোনো আয় নেই';

  @override
  String get unclassified => 'অশ্রেণীবদ্ধ';

  @override
  String get productUnit => 'পণ্য';

  @override
  String get unitsSoldUnit => 'ইউনিট';

  @override
  String get totalRevenueKpi => 'মোট আয়';

  @override
  String get unitsSoldKpi => 'বিক্রিত ইউনিট';

  @override
  String get totalProfitKpi => 'মোট লাভ';

  @override
  String get profitMarginKpi => 'লাভ মার্জিন';

  @override
  String get performanceOverview => 'কর্মক্ষমতা সংক্ষিপ্ত';

  @override
  String get trendingUpProducts => 'ঊর্ধ্বমুখী';

  @override
  String get stableProducts => 'স্থিতিশীল';

  @override
  String get trendingDownProducts => 'নিম্নমুখী';

  @override
  String noSalesProducts(int count) {
    return 'বিক্রয়হীন পণ্য ($count)';
  }

  @override
  String inStockCount(int count) {
    return '$count স্টকে';
  }

  @override
  String get slowMovingLabel => 'ধীর';

  @override
  String needsReorder(int count) {
    return 'পুনরায় অর্ডার ($count)';
  }

  @override
  String soldUnitsStock(int sold, int stock) {
    return 'বিক্রয়: $sold ইউনিট | স্টক: $stock';
  }

  @override
  String get reorderLabel => 'পুনরায় অর্ডার';

  @override
  String get totalComplaintsLabel => 'মোট অভিযোগ';

  @override
  String get openComplaints => 'খোলা';

  @override
  String get closedComplaints => 'বন্ধ';

  @override
  String get avgResolutionTime => 'গড় সমাধান সময়';

  @override
  String daysUnit(String count) {
    return '$count দিন';
  }

  @override
  String get fromDate => 'তারিখ থেকে';

  @override
  String get toDate => 'তারিখ পর্যন্ত';

  @override
  String get statusFilter => 'অবস্থা';

  @override
  String get departmentFilter => 'বিভাগ';

  @override
  String get paymentDepartment => 'পেমেন্ট';

  @override
  String get technicalDepartment => 'কারিগরি';

  @override
  String get otherDepartment => 'অন্যান্য';

  @override
  String get noComplaintsRecorded => 'এখনো কোনো অভিযোগ নেই';

  @override
  String get overviewTab => 'সংক্ষিপ্ত';

  @override
  String get topCustomersTab => 'শীর্ষ গ্রাহক';

  @override
  String get growthAnalysisTab => 'প্রবৃদ্ধি বিশ্লেষণ';

  @override
  String get loyaltyTab => 'লয়ালটি';

  @override
  String get totalCustomersLabel => 'মোট গ্রাহক';

  @override
  String get activeCustomersLabel => 'সক্রিয় গ্রাহক';

  @override
  String get avgOrderValueLabel => 'গড় অর্ডার মূল্য';

  @override
  String get tierDistribution => 'স্তর অনুসারে গ্রাহক বিতরণ';

  @override
  String get activitySummary => 'কার্যকলাপ সারসংক্ষেপ';

  @override
  String get totalRevenueFromCustomers => 'নিবন্ধিত গ্রাহক থেকে মোট আয়';

  @override
  String get avgOrderPerCustomer => 'প্রতি গ্রাহক গড় অর্ডার মূল্য';

  @override
  String get activeCustomersLast30 => 'সক্রিয় গ্রাহক (গত ৩০ দিন)';

  @override
  String get newCustomersLast30 => 'নতুন গ্রাহক (গত ৩০ দিন)';

  @override
  String topCustomersTitle(int count) {
    return 'শীর্ষ $count গ্রাহক';
  }

  @override
  String get bySpending => 'ব্যয় অনুসারে';

  @override
  String get byOrders => 'অর্ডার অনুসারে';

  @override
  String get byPoints => 'পয়েন্ট অনুসারে';

  @override
  String ordersCount(int count) {
    return '$count অর্ডার';
  }

  @override
  String get avgOrderStat => 'গড় অর্ডার';

  @override
  String get loyaltyPointsStat => 'লয়ালটি পয়েন্ট';

  @override
  String get lastOrderStat => 'শেষ অর্ডার';

  @override
  String get newCustomerGrowth => 'নতুন গ্রাহক বৃদ্ধি';

  @override
  String get customerRetentionRate => 'গ্রাহক ধারণ হার';

  @override
  String get monthlyPeriod => 'মাসিক';

  @override
  String get totalCustomersPeriod => 'মোট গ্রাহক';

  @override
  String get activePeriod => 'সক্রিয়';

  @override
  String get activeCustomersInfo =>
      'সক্রিয় গ্রাহক: গত ৩০ দিনে কেনাকাটা করেছেন';

  @override
  String get cohortAnalysis => 'কোহর্ট বিশ্লেষণ';

  @override
  String get cohortDescription => 'প্রথম কেনার পর রিটার্নের হার';

  @override
  String get cohortGroup => 'গ্রুপ';

  @override
  String get month1 => 'মাস ১';

  @override
  String get month2 => 'মাস ২';

  @override
  String get month3 => 'মাস ৩';

  @override
  String get loyaltyProgramStats => 'লয়ালটি প্রোগ্রাম পরিসংখ্যান';

  @override
  String get totalPointsGranted => 'মোট প্রদত্ত পয়েন্ট';

  @override
  String get remainingPoints => 'বাকি পয়েন্ট';

  @override
  String get pointsValue => 'পয়েন্ট মূল্য';

  @override
  String get pointsByTier => 'স্তর অনুসারে পয়েন্ট';

  @override
  String get pointsUnit => 'পয়েন্ট';

  @override
  String get redemptionPatterns => 'রিডেমশন প্যাটার্ন';

  @override
  String get purchaseDiscount => 'ক্রয় ছাড়';

  @override
  String get freeProducts => 'বিনামূল্যে পণ্য';

  @override
  String get couponsLabel => 'কুপন';

  @override
  String get diamondTier => 'ডায়মন্ড';

  @override
  String get goldTier => 'স্বর্ণ';

  @override
  String get silverTier => 'সিলভার';

  @override
  String get bronzeTier => 'ব্রোঞ্জ';

  @override
  String get todayDate => 'আজ';

  @override
  String get yesterdayDate => 'গতকাল';

  @override
  String daysCountLabel(int count) {
    return '$count দিন';
  }

  @override
  String ofTotalLabel(String active, String total) {
    return '$active এর মধ্যে $total';
  }

  @override
  String get exportingReportMsg => 'রিপোর্ট রপ্তানি হচ্ছে...';

  @override
  String get januaryMonth => 'জানুয়ারি';

  @override
  String get februaryMonth => 'ফেব্রুয়ারি';

  @override
  String get marchMonth => 'মার্চ';

  @override
  String get aprilMonth => 'এপ্রিল';

  @override
  String get mayMonth => 'মে';

  @override
  String get juneMonth => 'জুন';

  @override
  String errorLabel(String error) {
    return 'ত্রুটি: $error';
  }

  @override
  String get saturdayDay => 'শনিবার';

  @override
  String get sundayDay => 'রবিবার';

  @override
  String get mondayDay => 'সোমবার';

  @override
  String get tuesdayDay => 'মঙ্গলবার';

  @override
  String get wednesdayDay => 'বুধবার';

  @override
  String get thursdayDay => 'বৃহস্পতিবার';

  @override
  String get fridayDay => 'শুক্রবার';

  @override
  String get satShort => 'শনি';

  @override
  String get sunShort => 'রবি';

  @override
  String get monShort => 'সোম';

  @override
  String get tueShort => 'মঙ্গল';

  @override
  String get wedShort => 'বুধ';

  @override
  String get thuShort => 'বৃহ';

  @override
  String get friShort => 'শুক্র';

  @override
  String get errorLoadingVatReport => 'VAT রিপোর্ট লোডে ত্রুটি';

  @override
  String get errorLoadingComplaints => 'অভিযোগ লোডে ত্রুটি';

  @override
  String get errorLoadingCustomerReport => 'গ্রাহক রিপোর্ট লোডে ত্রুটি';

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
  String get confirmOrder => 'অর্ডার নিশ্চিত করুন';

  @override
  String get orderNow => 'এখনই অর্ডার করুন';

  @override
  String get orderCart => 'অর্ডার কার্ট';

  @override
  String get orderReceived => 'আপনার অর্ডার গৃহীত হয়েছে!';

  @override
  String get orderBeingPrepared =>
      'আপনার অর্ডার যত তাড়াতাড়ি সম্ভব প্রস্তুত করা হবে';

  @override
  String get redirectingToHome => 'স্বয়ংক্রিয়ভাবে হোম পেজে যাচ্ছে...';

  @override
  String get kioskOrderNote => 'কিওস্ক অর্ডার';

  @override
  String pricePerUnit(String price) {
    return '$price SAR প্রতি ইউনিট';
  }

  @override
  String get selectFromMenu => 'মেনু থেকে নির্বাচন করুন';

  @override
  String orderCartWithCount(int count) {
    return 'অর্ডার কার্ট ($count আইটেম)';
  }

  @override
  String amountWithSar(String amount) {
    return '$amount SAR';
  }

  @override
  String qtyTimesPrice(int qty, String price) {
    return '$qty × $price SAR';
  }

  @override
  String get applyCoupon => 'কুপন প্রয়োগ করুন';

  @override
  String get enterCouponCode => 'কুপন কোড লিখুন';

  @override
  String get invalidCoupon => 'অবৈধ বা পাওয়া যায়নি কুপন';

  @override
  String get couponExpired => 'কুপনের মেয়াদ শেষ হয়েছে';

  @override
  String minimumPurchaseRequired(String amount) {
    return 'ন্যূনতম ক্রয় $amount রিয়াল';
  }

  @override
  String couponDiscountApplied(String amount) {
    return '$amount রিয়াল ছাড় প্রয়োগ হয়েছে';
  }

  @override
  String get couponInvalid => 'অবৈধ কুপন';

  @override
  String get customerAddFailed => 'গ্রাহক যোগ করতে ব্যর্থ';

  @override
  String get quantityColon => 'পরিমাণ:';

  @override
  String get riyal => 'রিয়াল';

  @override
  String get mobileNumber => 'মোবাইল নম্বর';

  @override
  String get banknotes => 'ব্যাংকনোট';

  @override
  String get coins => 'কয়েন';

  @override
  String get totalAmountLabel => 'মোট পরিমাণ';

  @override
  String denominationRiyal(String amount) {
    return '$amount রিয়াল';
  }

  @override
  String denominationHalala(String amount) {
    return '$amount হালালা';
  }

  @override
  String get countCurrency => 'মুদ্রা গণনা';

  @override
  String confirmAmountSar(String amount) {
    return 'নিশ্চিত: $amount SAR';
  }

  @override
  String amountRiyal(String amount) {
    return '$amount রিয়াল';
  }

  @override
  String get itemDeletedMsg => 'আইটেম মুছে ফেলা হয়েছে';

  @override
  String get pressBackAgainToExit => 'বের হতে আবার চাপুন';

  @override
  String get deleteHeldInvoiceConfirm => 'এই মুলতুবি চালান মুছবেন?';

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
}
