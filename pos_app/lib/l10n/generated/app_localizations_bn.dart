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
}
