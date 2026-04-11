/// خدمة تحليل المشاعر - AI Sentiment Analysis Service
///
/// تحليل ملاحظات العملاء ومشاعرهم
/// - قوائم كلمات إيجابية/سلبية بالعربية
/// - استخراج الكلمات المفتاحية
/// - ملاحظات عملاء وهمية
library;

import 'dart:math';

// ============================================================================
// MODELS
// ============================================================================

/// درجة المشاعر
enum SentimentScore { veryNegative, negative, neutral, positive, veryPositive }

/// نتيجة تحليل المشاعر
class SentimentResult {
  final SentimentScore overallScore;
  final double overallValue;
  final int totalReviews;
  final Map<SentimentScore, int> distribution;
  final List<KeywordData> keywords;
  final List<SentimentTrend> trend;
  final double satisfactionRate;
  final double nps;

  const SentimentResult({
    required this.overallScore,
    required this.overallValue,
    required this.totalReviews,
    required this.distribution,
    required this.keywords,
    required this.trend,
    required this.satisfactionRate,
    required this.nps,
  });
}

/// بيانات كلمة مفتاحية
class KeywordData {
  final String word;
  final int count;
  final SentimentScore sentiment;
  final double sentimentValue;

  const KeywordData({
    required this.word,
    required this.count,
    required this.sentiment,
    required this.sentimentValue,
  });
}

/// اتجاه المشاعر
class SentimentTrend {
  final String period;
  final double positivePercent;
  final double neutralPercent;
  final double negativePercent;
  final int totalReviews;

  const SentimentTrend({
    required this.period,
    required this.positivePercent,
    required this.neutralPercent,
    required this.negativePercent,
    required this.totalReviews,
  });
}

/// ملاحظة عميل
class CustomerFeedback {
  final String id;
  final String customerName;
  final String text;
  final SentimentScore sentiment;
  final double sentimentValue;
  final DateTime timestamp;
  final String? productName;
  final int? rating;
  final List<String> keywords;

  const CustomerFeedback({
    required this.id,
    required this.customerName,
    required this.text,
    required this.sentiment,
    required this.sentimentValue,
    required this.timestamp,
    this.productName,
    this.rating,
    required this.keywords,
  });
}

// ============================================================================
// SERVICE
// ============================================================================

/// خدمة تحليل المشاعر
class AiSentimentAnalysisService {
  static final _random = Random(42);

  /// كلمات إيجابية بالعربية
  static const List<String> positiveWords = [
    'ممتاز',
    'رائع',
    'جميل',
    'سريع',
    'نظيف',
    'مرتب',
    'لذيذ',
    'طازج',
    'معقول',
    'ودود',
    'محترم',
    'مساعد',
    'جودة',
    'عالية',
    'أفضل',
    'مميز',
    'مذهل',
    'احترافي',
    'متعاون',
    'صادق',
  ];

  /// كلمات سلبية بالعربية
  static const List<String> negativeWords = [
    'سيء',
    'بطيء',
    'غالي',
    'متسخ',
    'فاسد',
    'منتهي',
    'قديم',
    'وقح',
    'مهمل',
    'ضعيف',
    'رديء',
    'صعب',
    'معطل',
    'مزعج',
    'غير متوفر',
    'متأخر',
    'خاطئ',
    'ناقص',
    'محبط',
    'مخيب',
  ];

  /// استخراج الكلمات المفتاحية
  static List<KeywordData> getKeywords() {
    final keywords = <KeywordData>[];

    // Positive keywords
    final positiveSelected = [
      'ممتاز',
      'طازج',
      'سريع',
      'نظيف',
      'ودود',
      'جودة عالية',
      'مرتب',
      'أسعار معقولة',
      'محترم',
      'لذيذ',
    ];
    for (final word in positiveSelected) {
      keywords.add(
        KeywordData(
          word: word,
          count: _random.nextInt(40) + 10,
          sentiment: SentimentScore.positive,
          sentimentValue: 0.5 + _random.nextDouble() * 0.5,
        ),
      );
    }

    // Negative keywords
    final negativeSelected = [
      'غالي',
      'بطيء',
      'مزدحم',
      'غير متوفر',
      'فاسد',
      'وقح',
    ];
    for (final word in negativeSelected) {
      keywords.add(
        KeywordData(
          word: word,
          count: _random.nextInt(15) + 3,
          sentiment: SentimentScore.negative,
          sentimentValue: -0.5 - _random.nextDouble() * 0.5,
        ),
      );
    }

    // Neutral keywords
    final neutralSelected = ['عادي', 'مقبول', 'لا بأس'];
    for (final word in neutralSelected) {
      keywords.add(
        KeywordData(
          word: word,
          count: _random.nextInt(10) + 5,
          sentiment: SentimentScore.neutral,
          sentimentValue: _random.nextDouble() * 0.3 - 0.15,
        ),
      );
    }

    keywords.sort((a, b) => b.count.compareTo(a.count));
    return keywords;
  }

  /// ملاحظات العملاء الوهمية
  static List<CustomerFeedback> getFeedback() {
    final now = DateTime.now();
    return [
      CustomerFeedback(
        id: 'f1',
        customerName: 'عبدالله المحمد',
        text:
            'خدمة ممتازة وسرعة في الكاشير. المنتجات طازجة والأسعار معقولة. سأعود بالتأكيد!',
        sentiment: SentimentScore.veryPositive,
        sentimentValue: 0.92,
        timestamp: now.subtract(const Duration(hours: 1)),
        rating: 5,
        keywords: ['ممتاز', 'سريع', 'طازج', 'معقول'],
      ),
      CustomerFeedback(
        id: 'f2',
        customerName: 'سارة العمري',
        text:
            'المتجر نظيف ومرتب. الموظفين محترمين ومتعاونين. فقط أتمنى تتوفر بعض المنتجات أكثر.',
        sentiment: SentimentScore.positive,
        sentimentValue: 0.75,
        timestamp: now.subtract(const Duration(hours: 3)),
        rating: 4,
        keywords: ['نظيف', 'مرتب', 'محترم', 'غير متوفر'],
      ),
      CustomerFeedback(
        id: 'f3',
        customerName: 'خالد السعدي',
        text:
            'الأسعار غالية مقارنة بالسوبرماركت اللي جنبكم. بعض الخضروات فاسدة ومنتهية الصلاحية.',
        sentiment: SentimentScore.negative,
        sentimentValue: -0.65,
        timestamp: now.subtract(const Duration(hours: 6)),
        productName: 'خضروات',
        rating: 2,
        keywords: ['غالي', 'فاسد', 'منتهي'],
      ),
      CustomerFeedback(
        id: 'f4',
        customerName: 'فهد الحربي',
        text: 'تجربة عادية. لا شيء مميز ولا شيء سيء. المتجر مقبول بشكل عام.',
        sentiment: SentimentScore.neutral,
        sentimentValue: 0.1,
        timestamp: now.subtract(const Duration(hours: 8)),
        rating: 3,
        keywords: ['عادي', 'مقبول'],
      ),
      CustomerFeedback(
        id: 'f5',
        customerName: 'نوف القحطاني',
        text:
            'أحب التنوع في المنتجات والعروض الأسبوعية. الكاشير أحمد محترم جداً ومساعد.',
        sentiment: SentimentScore.veryPositive,
        sentimentValue: 0.88,
        timestamp: now.subtract(const Duration(hours: 12)),
        rating: 5,
        keywords: ['تنوع', 'عروض', 'محترم', 'مساعد'],
      ),
      CustomerFeedback(
        id: 'f6',
        customerName: 'محمد الشهري',
        text:
            'الكاشير بطيء جداً والصف طويل. لازم تزيدون عدد الكاشيرات خاصة في أوقات الذروة.',
        sentiment: SentimentScore.negative,
        sentimentValue: -0.55,
        timestamp: now.subtract(const Duration(days: 1)),
        rating: 2,
        keywords: ['بطيء', 'طويل', 'مزدحم'],
      ),
      CustomerFeedback(
        id: 'f7',
        customerName: 'ريم الزهراني',
        text:
            'أفضل محل في الحي! جودة عالية وخدمة رائعة. الأسعار مناسبة للجودة.',
        sentiment: SentimentScore.veryPositive,
        sentimentValue: 0.95,
        timestamp: now.subtract(const Duration(days: 1)),
        rating: 5,
        keywords: ['أفضل', 'جودة عالية', 'رائع', 'مناسب'],
      ),
      CustomerFeedback(
        id: 'f8',
        customerName: 'عبدالرحمن الشمري',
        text: 'صراحة محبط. طلبت دجاج مبرد وما لقيت. والموظف كان وقح لما سألت.',
        sentiment: SentimentScore.veryNegative,
        sentimentValue: -0.85,
        timestamp: now.subtract(const Duration(days: 2)),
        productName: 'دجاج مبرد',
        rating: 1,
        keywords: ['محبط', 'غير متوفر', 'وقح'],
      ),
    ];
  }

  /// اتجاه المشاعر
  static List<SentimentTrend> getTrend() {
    return const [
      SentimentTrend(
        period: 'الأسبوع 1',
        positivePercent: 62,
        neutralPercent: 22,
        negativePercent: 16,
        totalReviews: 45,
      ),
      SentimentTrend(
        period: 'الأسبوع 2',
        positivePercent: 65,
        neutralPercent: 20,
        negativePercent: 15,
        totalReviews: 52,
      ),
      SentimentTrend(
        period: 'الأسبوع 3',
        positivePercent: 58,
        neutralPercent: 25,
        negativePercent: 17,
        totalReviews: 48,
      ),
      SentimentTrend(
        period: 'الأسبوع 4',
        positivePercent: 70,
        neutralPercent: 18,
        negativePercent: 12,
        totalReviews: 55,
      ),
      SentimentTrend(
        period: 'الأسبوع 5',
        positivePercent: 72,
        neutralPercent: 16,
        negativePercent: 12,
        totalReviews: 61,
      ),
      SentimentTrend(
        period: 'الأسبوع 6',
        positivePercent: 68,
        neutralPercent: 20,
        negativePercent: 12,
        totalReviews: 58,
      ),
    ];
  }

  /// نتيجة التحليل الكاملة
  static SentimentResult getAnalysisResult() {
    final feedback = getFeedback();
    final keywords = getKeywords();
    final trend = getTrend();

    final distribution = <SentimentScore, int>{
      SentimentScore.veryPositive: feedback
          .where((f) => f.sentiment == SentimentScore.veryPositive)
          .length,
      SentimentScore.positive: feedback
          .where((f) => f.sentiment == SentimentScore.positive)
          .length,
      SentimentScore.neutral: feedback
          .where((f) => f.sentiment == SentimentScore.neutral)
          .length,
      SentimentScore.negative: feedback
          .where((f) => f.sentiment == SentimentScore.negative)
          .length,
      SentimentScore.veryNegative: feedback
          .where((f) => f.sentiment == SentimentScore.veryNegative)
          .length,
    };

    final avgValue =
        feedback.map((f) => f.sentimentValue).reduce((a, b) => a + b) /
        feedback.length;
    final positiveCount = feedback.where((f) => f.sentimentValue > 0.2).length;
    final satisfactionRate = positiveCount / feedback.length * 100;

    return SentimentResult(
      overallScore: avgValue > 0.5
          ? SentimentScore.positive
          : avgValue > 0
          ? SentimentScore.neutral
          : SentimentScore.negative,
      overallValue: double.parse(avgValue.toStringAsFixed(2)),
      totalReviews: feedback.length,
      distribution: distribution,
      keywords: keywords,
      trend: trend,
      satisfactionRate: double.parse(satisfactionRate.toStringAsFixed(1)),
      nps: 42.0,
    );
  }

  /// وصف درجة المشاعر
  static String getSentimentLabel(SentimentScore score) {
    switch (score) {
      case SentimentScore.veryPositive:
        return 'إيجابي جداً';
      case SentimentScore.positive:
        return 'إيجابي';
      case SentimentScore.neutral:
        return 'محايد';
      case SentimentScore.negative:
        return 'سلبي';
      case SentimentScore.veryNegative:
        return 'سلبي جداً';
    }
  }
}
