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
  String get lowStock => 'কম স্টক';

  @override
  String get outOfStock => 'স্টক শেষ';

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
  String get revenue => 'রাজস্ব';

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
  String get invoiceNumberLabel => 'নম্বর:';

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
  String get expenseAmount => 'المبلغ';

  @override
  String get expenseDate => 'التاريخ';

  @override
  String get expenseCategory => 'التصنيف';

  @override
  String get expenseNotes => 'ملاحظات';

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
  String get openDrawerAction => 'فتح الدرج';

  @override
  String get closeDrawerAction => 'إغلاق الدرج';

  @override
  String get monthlyCloseTitle => 'মাসিক বন্ধ';

  @override
  String get monthlyCloseDesc => 'إغلاق الشهر وحساب المستحقات';

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
  String get noShifts => 'কোন শিফট নেই';

  @override
  String get purchasesTitle => 'ক্রয়';

  @override
  String get newPurchase => 'مشترى جديد';

  @override
  String get smartReorder => 'স্মার্ট রিঅর্ডার';

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
  String get suppliersTitle => 'সরবরাহকারী';

  @override
  String get addSupplier => 'সরবরাহকারী যোগ করুন';

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
  String get noSuppliers => 'কোন সরবরাহকারী নেই';

  @override
  String get discountsTitle => 'ছাড়';

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
  String get couponsTitle => 'কুপন';

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
  String get specialOffersTitle => 'বিশেষ অফার';

  @override
  String get addOffer => 'إضافة عرض';

  @override
  String get offerName => 'اسم العرض';

  @override
  String get offerStartDate => 'تاريخ البدء';

  @override
  String get offerEndDate => 'تاريخ الانتهاء';

  @override
  String get smartPromotionsTitle => 'স্মার্ট প্রমোশন';

  @override
  String get activePromotions => 'العروض النشطة';

  @override
  String get suggestedPromotions => 'اقتراحات AI';

  @override
  String get loyaltyTitle => 'আনুগত্য প্রোগ্রাম';

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
  String get notificationsTitle => 'বিজ্ঞপ্তি';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get printQueueTitle => 'প্রিন্ট কিউ';

  @override
  String get printAll => 'طباعة الكل';

  @override
  String get cancelAll => 'إلغاء الكل';

  @override
  String get noPrintJobs => 'لا توجد مهام طباعة';

  @override
  String get syncStatusTitle => 'সিঙ্ক অবস্থা';

  @override
  String get lastSyncTime => 'آخر مزامنة';

  @override
  String get pendingItems => 'عناصر معلقة';

  @override
  String get syncNow => 'مزامنة الآن';

  @override
  String get pendingTransactionsTitle => 'মুলতুবি লেনদেন';

  @override
  String get conflictResolutionTitle => 'বিরোধ সমাধান';

  @override
  String get localValue => 'محلي';

  @override
  String get serverValue => 'الخادم';

  @override
  String get keepLocal => 'الاحتفاظ بالمحلي';

  @override
  String get keepServer => 'الاحتفاظ بالخادم';

  @override
  String get driversTitle => 'ড্রাইভার';

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
  String get branchesTitle => 'শাখা';

  @override
  String get addBranchAction => 'إضافة فرع';

  @override
  String get branchName => 'اسم الفرع';

  @override
  String get branchEmployees => 'الموظفين';

  @override
  String get branchSales => 'مبيعات اليوم';

  @override
  String get profileTitle => 'প্রোফাইল';

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
  String get languageSettings => 'اللغة';

  @override
  String get themeSettings => 'المظهر';

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
  String get notificationSettings => 'الإشعارات';

  @override
  String get zatcaCompliance => 'ZATCA সম্মতি';

  @override
  String get helpSupport => 'সাহায্য ও সমর্থন';

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
}
