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
    return '$count শাখা';
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
    return 'আজ $count অর্ডার';
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
    return '$count মিনিট আগে';
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
    return '$count ঘন্টা আগে';
  }

  @override
  String daysAgo(int count) {
    return '$count দিন আগে';
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
    return '$count বিভাগ';
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
    return '$count ইনভয়েস পেমেন্টের অপেক্ষায়';
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
    return '$count নির্বাচিত';
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
  String customerCount(String count) {
    return '$count গ্রাহক';
  }

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
  String get customerAddedSuccess => 'গ্রাহক সফলভাবে যোগ হয়েছে';

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
  String get resetAction => 'Reset';

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
  String get orderHistory => 'سجل الطلبات';

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
  String get nearExpiry => 'قريب الانتهاء';

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
    return '$count منتج';
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
  String get noteLabel => 'Note';

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
  String get supplierLabel => 'Supplier';

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
    return '$count items';
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
  String get lowStockLabel => 'কম';

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
  String get soldOut => 'বিক্রি শেষ';

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
}
