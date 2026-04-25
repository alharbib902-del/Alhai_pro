// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get vatNumberMissing => 'VAT number not configured';

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
    return 'Page not found: $path';
  }

  @override
  String get noInvoiceDataAvailable => 'No invoice data available';

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
  String confirmDeleteItemMessage(String name) {
    return '\"$name\" মুছবেন?\nএই ক্রিয়া পূর্বাবস্থায় ফেরানো যাবে না।';
  }

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
  String get deleteProduct => 'পণ্য মুছুন';

  @override
  String deleteProductConfirm(String name) {
    return '\"$name\" পণ্যটি মুছবেন?\nএটি আর্কাইভে পাঠানো হবে এবং পরে পুনরুদ্ধার করা যাবে।';
  }

  @override
  String get productDeletedSuccess => 'পণ্য সফলভাবে মুছে ফেলা হয়েছে';

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
  String get totalReceivables => 'মোট প্রাপ্য';

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
  String get zatcaQueueReportTitle => 'ZATCA জমাদান সারি';

  @override
  String get zatcaSent => 'পাঠানো';

  @override
  String get zatcaPendingLabel => 'অপেক্ষমাণ';

  @override
  String get zatcaRejected => 'প্রত্যাখ্যাত';

  @override
  String get zatcaPendingSection => 'অপেক্ষমাণ চালান';

  @override
  String get zatcaRejectedSection => 'প্রত্যাখ্যাত চালান';

  @override
  String get zatcaNoPendingInvoices => 'কোনো অপেক্ষমাণ চালান নেই';

  @override
  String get zatcaNoRejectedInvoices => 'কোনো প্রত্যাখ্যাত চালান নেই';

  @override
  String zatcaRetriesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পুনরায় চেষ্টা',
      one: '১টি পুনরায় চেষ্টা',
      zero: 'কোনো পুনরায় চেষ্টা নেই',
    );
    return '$_temp0';
  }

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
  String get animationsToggle => 'অ্যানিমেশন';

  @override
  String get animationsToggleDesc => 'মসৃণ স্ক্রিন ট্রানজিশন';

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
  String get stocktakingTitle => 'স্টক গণনা';

  @override
  String get expectedQty => 'প্রত্যাশিত';

  @override
  String get countedQty => 'গণনাকৃত';

  @override
  String get stockDelta => 'পার্থক্য';

  @override
  String get saveAllAdjustments => 'সমন্বয় সংরক্ষণ';

  @override
  String stocktakingSavedSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সমন্বয় সংরক্ষিত',
      one: '1টি সমন্বয় সংরক্ষিত',
      zero: 'কোনো সমন্বয় নেই',
    );
    return '$_temp0';
  }

  @override
  String stocktakingAdjustedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সমন্বয়',
      one: '1টি সমন্বয়',
    );
    return '$_temp0';
  }

  @override
  String get stockTransfersTitle => 'শাখা-মধ্যবর্তী ট্রান্সফার';

  @override
  String get stockTransferNewTitle => 'নতুন স্টক ট্রান্সফার';

  @override
  String get stockTransferTabOutgoing => 'বহির্গামী';

  @override
  String get stockTransferTabIncoming => 'আগত';

  @override
  String get stockTransferFromStore => 'শাখা থেকে';

  @override
  String get stockTransferToStore => 'শাখায়';

  @override
  String get stockTransferAddItem => 'আইটেম যোগ করুন';

  @override
  String get stockTransferNoItems => 'এখনো কোনো আইটেম যোগ করা হয়নি';

  @override
  String get stockTransferCreate => 'ট্রান্সফার তৈরি করুন';

  @override
  String get stockTransferApprove => 'অনুমোদন';

  @override
  String get stockTransferReceive => 'গ্রহণ';

  @override
  String get stockTransferReject => 'প্রত্যাখ্যান';

  @override
  String get stockTransferStatusPending => 'অপেক্ষমান';

  @override
  String get stockTransferStatusApproved => 'অনুমোদিত';

  @override
  String get stockTransferStatusInTransit => 'পথে';

  @override
  String get stockTransferStatusReceived => 'গৃহীত';

  @override
  String get stockTransferStatusCancelled => 'বাতিল';

  @override
  String get stockTransferNoOutgoing => 'কোনো বহির্গামী ট্রান্সফার নেই';

  @override
  String get stockTransferNoIncoming => 'কোনো আগত ট্রান্সফার নেই';

  @override
  String get stockTransferCreatedSuccess => 'ট্রান্সফার তৈরি হয়েছে';

  @override
  String stockTransferItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি আইটেম',
      one: '1টি আইটেম',
    );
    return '$_temp0';
  }

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
      'এই চালান বাতিল হয়েছে এবং ফেরত দেওয়া যাবে না';

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
