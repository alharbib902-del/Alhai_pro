/// خدمة التنبؤ بالمرتجعات بالذكاء الاصطناعي
///
/// تحلل بيانات المبيعات والمرتجعات لتوقع العمليات ذات خطر الإرجاع العالي
/// وتقترح إجراءات وقائية لتقليل المرتجعات
library;

// ============================================================================
// RETURN PREDICTION MODELS
// ============================================================================

/// مستوى خطر الإرجاع
enum ReturnRiskLevel {
  /// خطر منخفض
  low,

  /// خطر متوسط
  medium,

  /// خطر عالي
  high,

  /// خطر عالي جداً
  veryHigh,
}

/// عوامل خطر الإرجاع
enum ReturnRiskFactor {
  /// سعر مرتفع
  highPriceItem,

  /// عميل جديد
  newCustomer,

  /// نهاية اليوم
  endOfDay,

  /// خصم كبير
  heavilyDiscounted,

  /// عميل يرجع كثيراً
  previousReturner,

  /// شراء بالجملة
  bulkPurchase,
}

/// احتمالية الإرجاع لعملية بيع
class ReturnProbability {
  final String transactionId;
  final DateTime date;
  final double amount;
  final double probability;
  final ReturnRiskLevel riskLevel;
  final List<ReturnRiskFactor> factors;
  final String customerName;
  final String topRiskProduct;

  const ReturnProbability({
    required this.transactionId,
    required this.date,
    required this.amount,
    required this.probability,
    required this.riskLevel,
    required this.factors,
    required this.customerName,
    required this.topRiskProduct,
  });
}

/// نوع الإجراء الوقائي
enum PreventiveType {
  /// فحص جودة
  qualityCheck,

  /// متابعة
  followUp,

  /// ضمان ممتد
  extendedWarranty,

  /// عرض استبدال
  exchangeOffer,

  /// خصم على الشراء القادم
  discountOnNext,
}

/// إجراء وقائي
class PreventiveAction {
  final String id;
  final String title;
  final String description;
  final String targetTransactionId;
  final PreventiveType type;
  final double estimatedSavings;

  const PreventiveAction({
    required this.id,
    required this.title,
    required this.description,
    required this.targetTransactionId,
    required this.type,
    required this.estimatedSavings,
  });
}

/// اتجاه المرتجعات
enum TrendDirection {
  up,
  down,
  stable,
}

/// اتجاه المرتجعات عبر فترة زمنية
class ReturnTrend {
  final String period;
  final double returnRate;
  final int totalReturns;
  final int totalSales;
  final TrendDirection trend;

  const ReturnTrend({
    required this.period,
    required this.returnRate,
    required this.totalReturns,
    required this.totalSales,
    required this.trend,
  });
}

// ============================================================================
// AI RETURN PREDICTION SERVICE
// ============================================================================

/// خدمة التنبؤ بالمرتجعات
class AiReturnPredictionService {
  AiReturnPredictionService();

  /// الحصول على احتمالات الإرجاع لجميع العمليات
  Future<List<ReturnProbability>> getReturnProbabilities(String storeId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final now = DateTime.now();
    return [
      ReturnProbability(
        transactionId: 'TXN-2024-0891',
        date: now.subtract(const Duration(hours: 2)),
        amount: 487.50,
        probability: 0.85,
        riskLevel: ReturnRiskLevel.veryHigh,
        factors: [
          ReturnRiskFactor.previousReturner,
          ReturnRiskFactor.highPriceItem,
          ReturnRiskFactor.endOfDay
        ],
        customerName: 'فهد العتيبي',
        topRiskProduct: 'لحم بقري مبرد - 2 كجم',
      ),
      ReturnProbability(
        transactionId: 'TXN-2024-0887',
        date: now.subtract(const Duration(hours: 4)),
        amount: 312.00,
        probability: 0.72,
        riskLevel: ReturnRiskLevel.high,
        factors: [ReturnRiskFactor.bulkPurchase, ReturnRiskFactor.newCustomer],
        customerName: 'محمد الشمري',
        topRiskProduct: 'حليب طازج كرتون - 12 حبة',
      ),
      ReturnProbability(
        transactionId: 'TXN-2024-0883',
        date: now.subtract(const Duration(hours: 5)),
        amount: 156.75,
        probability: 0.58,
        riskLevel: ReturnRiskLevel.medium,
        factors: [ReturnRiskFactor.heavilyDiscounted],
        customerName: 'سارة القحطاني',
        topRiskProduct: 'زبادي فواكه مشكلة',
      ),
      ReturnProbability(
        transactionId: 'TXN-2024-0879',
        date: now.subtract(const Duration(hours: 7)),
        amount: 89.25,
        probability: 0.45,
        riskLevel: ReturnRiskLevel.medium,
        factors: [
          ReturnRiskFactor.endOfDay,
          ReturnRiskFactor.heavilyDiscounted
        ],
        customerName: 'خالد المالكي',
        topRiskProduct: 'خبز توست أبيض',
      ),
      ReturnProbability(
        transactionId: 'TXN-2024-0875',
        date: now.subtract(const Duration(hours: 9)),
        amount: 245.00,
        probability: 0.38,
        riskLevel: ReturnRiskLevel.medium,
        factors: [ReturnRiskFactor.newCustomer],
        customerName: 'عبدالله الدوسري',
        topRiskProduct: 'أرز بسمتي 5 كجم',
      ),
      ReturnProbability(
        transactionId: 'TXN-2024-0871',
        date: now.subtract(const Duration(hours: 11)),
        amount: 67.50,
        probability: 0.22,
        riskLevel: ReturnRiskLevel.low,
        factors: [ReturnRiskFactor.endOfDay],
        customerName: 'نورة الحربي',
        topRiskProduct: 'عصير برتقال طبيعي',
      ),
      ReturnProbability(
        transactionId: 'TXN-2024-0868',
        date: now.subtract(const Duration(hours: 13)),
        amount: 534.00,
        probability: 0.78,
        riskLevel: ReturnRiskLevel.high,
        factors: [
          ReturnRiskFactor.highPriceItem,
          ReturnRiskFactor.bulkPurchase,
          ReturnRiskFactor.previousReturner
        ],
        customerName: 'ياسر الغامدي',
        topRiskProduct: 'زيت زيتون أصلي - 3 لتر',
      ),
      ReturnProbability(
        transactionId: 'TXN-2024-0864',
        date: now.subtract(const Duration(hours: 16)),
        amount: 123.50,
        probability: 0.15,
        riskLevel: ReturnRiskLevel.low,
        factors: [],
        customerName: 'هند الزهراني',
        topRiskProduct: 'بيض بلدي 30 حبة',
      ),
      ReturnProbability(
        transactionId: 'TXN-2024-0860',
        date: now.subtract(const Duration(hours: 20)),
        amount: 678.25,
        probability: 0.91,
        riskLevel: ReturnRiskLevel.veryHigh,
        factors: [
          ReturnRiskFactor.previousReturner,
          ReturnRiskFactor.highPriceItem,
          ReturnRiskFactor.bulkPurchase,
          ReturnRiskFactor.heavilyDiscounted
        ],
        customerName: 'سعد القرني',
        topRiskProduct: 'دجاج مجمد - كرتون 10 كجم',
      ),
      ReturnProbability(
        transactionId: 'TXN-2024-0855',
        date: now.subtract(const Duration(days: 1)),
        amount: 198.00,
        probability: 0.31,
        riskLevel: ReturnRiskLevel.low,
        factors: [ReturnRiskFactor.newCustomer],
        customerName: 'ريم السبيعي',
        topRiskProduct: 'معكرونة سباغيتي 500 جم',
      ),
    ];
  }

  /// الحصول على الإجراءات الوقائية المقترحة
  Future<List<PreventiveAction>> getPreventiveActions(String storeId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      const PreventiveAction(
        id: 'PA-001',
        title: 'فحص جودة اللحوم المبردة',
        description:
            'العميل فهد العتيبي لديه تاريخ إرجاع سابق. تأكد من جودة اللحوم المبردة قبل التسليم وأضف كيس ثلج إضافي.',
        targetTransactionId: 'TXN-2024-0891',
        type: PreventiveType.qualityCheck,
        estimatedSavings: 487.50,
      ),
      const PreventiveAction(
        id: 'PA-002',
        title: 'متابعة عميل الجملة',
        description:
            'محمد الشمري عميل جديد اشترى بالجملة. تواصل معه بعد 24 ساعة للتأكد من رضاه عن جودة الحليب.',
        targetTransactionId: 'TXN-2024-0887',
        type: PreventiveType.followUp,
        estimatedSavings: 312.00,
      ),
      const PreventiveAction(
        id: 'PA-003',
        title: 'عرض استبدال الدجاج المجمد',
        description:
            'سعد القرني يعود للإرجاع بشكل متكرر. اعرض عليه استبدال الدجاج المجمد بمنتج طازج بدلاً من الإرجاع.',
        targetTransactionId: 'TXN-2024-0860',
        type: PreventiveType.exchangeOffer,
        estimatedSavings: 678.25,
      ),
      const PreventiveAction(
        id: 'PA-004',
        title: 'ضمان ممتد على زيت الزيتون',
        description:
            'ياسر الغامدي اشترى زيت زيتون بكمية كبيرة. قدم ضمان استبدال لمدة أسبوع إضافي لبناء الثقة.',
        targetTransactionId: 'TXN-2024-0868',
        type: PreventiveType.extendedWarranty,
        estimatedSavings: 534.00,
      ),
      const PreventiveAction(
        id: 'PA-005',
        title: 'خصم 10% على الزيارة القادمة',
        description:
            'سارة القحطاني اشترت زبادي بخصم. قدم لها كوبون 10% على الزيارة القادمة لتشجيعها على الاحتفاظ بالمنتج.',
        targetTransactionId: 'TXN-2024-0883',
        type: PreventiveType.discountOnNext,
        estimatedSavings: 156.75,
      ),
    ];
  }

  /// الحصول على اتجاه المرتجعات عبر الزمن
  Future<List<ReturnTrend>> getReturnTrends(String storeId) async {
    await Future.delayed(const Duration(milliseconds: 250));

    return const [
      ReturnTrend(
        period: 'يناير',
        returnRate: 4.2,
        totalReturns: 21,
        totalSales: 500,
        trend: TrendDirection.stable,
      ),
      ReturnTrend(
        period: 'فبراير',
        returnRate: 5.1,
        totalReturns: 28,
        totalSales: 549,
        trend: TrendDirection.up,
      ),
      ReturnTrend(
        period: 'مارس',
        returnRate: 3.8,
        totalReturns: 19,
        totalSales: 500,
        trend: TrendDirection.down,
      ),
      ReturnTrend(
        period: 'أبريل',
        returnRate: 4.5,
        totalReturns: 25,
        totalSales: 556,
        trend: TrendDirection.up,
      ),
      ReturnTrend(
        period: 'مايو',
        returnRate: 3.2,
        totalReturns: 16,
        totalSales: 500,
        trend: TrendDirection.down,
      ),
      ReturnTrend(
        period: 'يونيو',
        returnRate: 2.9,
        totalReturns: 14,
        totalSales: 483,
        trend: TrendDirection.down,
      ),
    ];
  }

  /// حساب متوسط معدل الإرجاع
  double calculateAverageReturnRate(List<ReturnTrend> trends) {
    if (trends.isEmpty) return 0;
    final total = trends.fold<double>(0, (sum, t) => sum + t.returnRate);
    return total / trends.length;
  }

  /// حساب إجمالي المبلغ المعرض للخطر
  double calculateAtRiskAmount(List<ReturnProbability> probabilities) {
    return probabilities
        .where((p) =>
            p.riskLevel == ReturnRiskLevel.high ||
            p.riskLevel == ReturnRiskLevel.veryHigh)
        .fold<double>(0, (sum, p) => sum + p.amount);
  }

  /// الحصول على وصف عامل الخطر
  static String getFactorLabel(ReturnRiskFactor factor) {
    switch (factor) {
      case ReturnRiskFactor.highPriceItem:
        return 'سعر مرتفع';
      case ReturnRiskFactor.newCustomer:
        return 'عميل جديد';
      case ReturnRiskFactor.endOfDay:
        return 'شراء آخر اليوم';
      case ReturnRiskFactor.heavilyDiscounted:
        return 'خصم كبير';
      case ReturnRiskFactor.previousReturner:
        return 'عميل يرجع كثيراً';
      case ReturnRiskFactor.bulkPurchase:
        return 'شراء بالجملة';
    }
  }

  /// الحصول على لون مستوى الخطر
  static int getRiskColorValue(ReturnRiskLevel level) {
    switch (level) {
      case ReturnRiskLevel.low:
        return 0xFF22C55E;
      case ReturnRiskLevel.medium:
        return 0xFFF59E0B;
      case ReturnRiskLevel.high:
        return 0xFFEF4444;
      case ReturnRiskLevel.veryHigh:
        return 0xFFDC2626;
    }
  }

  /// الحصول على وصف مستوى الخطر
  static String getRiskLabel(ReturnRiskLevel level) {
    switch (level) {
      case ReturnRiskLevel.low:
        return 'منخفض';
      case ReturnRiskLevel.medium:
        return 'متوسط';
      case ReturnRiskLevel.high:
        return 'عالي';
      case ReturnRiskLevel.veryHigh:
        return 'عالي جداً';
    }
  }

  /// الحصول على أيقونة نوع الإجراء
  static String getPreventiveTypeLabel(PreventiveType type) {
    switch (type) {
      case PreventiveType.qualityCheck:
        return 'فحص جودة';
      case PreventiveType.followUp:
        return 'متابعة';
      case PreventiveType.extendedWarranty:
        return 'ضمان ممتد';
      case PreventiveType.exchangeOffer:
        return 'عرض استبدال';
      case PreventiveType.discountOnNext:
        return 'خصم مستقبلي';
    }
  }
}
