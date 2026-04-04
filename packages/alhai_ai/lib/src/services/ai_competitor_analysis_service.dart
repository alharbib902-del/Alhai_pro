/// خدمة تحليل المنافسين - AI Competitor Analysis Service
///
/// تحليل أسعار المنافسين وموقع المتجر في السوق
/// - مقارنة الأسعار مع المنافسين
/// - تحليل الموقع السوقي
/// - تنبيهات تغيرات الأسعار
library;

import 'dart:math';

// ============================================================================
// MODELS
// ============================================================================

/// بيانات منافس
class Competitor {
  final String id;
  final String name;
  final String nameAr;
  final String logoUrl;
  final String type;
  final double overallPriceIndex;
  final double qualityScore;
  final int branchCount;
  final String region;

  const Competitor({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.logoUrl,
    required this.type,
    required this.overallPriceIndex,
    required this.qualityScore,
    required this.branchCount,
    required this.region,
  });
}

/// سعر منافس لمنتج
class CompetitorPrice {
  final String competitorId;
  final String competitorName;
  final String productId;
  final String productName;
  final double price;
  final DateTime lastUpdated;
  final String source;

  const CompetitorPrice({
    required this.competitorId,
    required this.competitorName,
    required this.productId,
    required this.productName,
    required this.price,
    required this.lastUpdated,
    required this.source,
  });
}

/// مقارنة أسعار
class PriceComparison {
  final String productId;
  final String productName;
  final String category;
  final double ourPrice;
  final Map<String, double> competitorPrices;
  final double avgMarketPrice;
  final double priceDifferencePercent;
  final PricePosition position;

  const PriceComparison({
    required this.productId,
    required this.productName,
    required this.category,
    required this.ourPrice,
    required this.competitorPrices,
    required this.avgMarketPrice,
    required this.priceDifferencePercent,
    required this.position,
  });
}

/// موقع السعر
enum PricePosition {
  cheapest,
  belowAverage,
  average,
  aboveAverage,
  mostExpensive,
}

/// الموقع السوقي
class MarketPosition {
  final double priceIndex;
  final double qualityIndex;
  final double valueScore;
  final String positionLabel;
  final String positionLabelAr;
  final List<MarketPositionPoint> competitors;

  const MarketPosition({
    required this.priceIndex,
    required this.qualityIndex,
    required this.valueScore,
    required this.positionLabel,
    required this.positionLabelAr,
    required this.competitors,
  });
}

/// نقطة في خريطة الموقع السوقي
class MarketPositionPoint {
  final String name;
  final double priceIndex;
  final double qualityIndex;
  final double marketShare;
  final bool isUs;

  const MarketPositionPoint({
    required this.name,
    required this.priceIndex,
    required this.qualityIndex,
    required this.marketShare,
    this.isUs = false,
  });
}

/// تنبيه منافس
class CompetitorAlert {
  final String id;
  final String competitorName;
  final String productName;
  final AlertType alertType;
  final String message;
  final double oldPrice;
  final double newPrice;
  final double changePercent;
  final DateTime timestamp;
  final bool isRead;

  const CompetitorAlert({
    required this.id,
    required this.competitorName,
    required this.productName,
    required this.alertType,
    required this.message,
    required this.oldPrice,
    required this.newPrice,
    required this.changePercent,
    required this.timestamp,
    this.isRead = false,
  });
}

/// نوع التنبيه
enum AlertType {
  priceDecrease,
  priceIncrease,
  newProduct,
  outOfStock,
  promotion,
}

/// ملخص تحليل المنافسين
class CompetitorAnalysisSummary {
  final int totalProductsTracked;
  final int cheaperThanCompetitors;
  final int moreExpensiveThanCompetitors;
  final double averagePriceDifference;
  final int activeAlerts;
  final String marketPositionLabel;

  const CompetitorAnalysisSummary({
    required this.totalProductsTracked,
    required this.cheaperThanCompetitors,
    required this.moreExpensiveThanCompetitors,
    required this.averagePriceDifference,
    required this.activeAlerts,
    required this.marketPositionLabel,
  });
}

// ============================================================================
// SERVICE
// ============================================================================

/// خدمة تحليل المنافسين
class AiCompetitorAnalysisService {
  static final _random = Random(42);

  /// المنافسين الأساسيين
  static const List<Competitor> mockCompetitors = [
    Competitor(
      id: 'panda',
      name: 'Panda',
      nameAr: 'بنده',
      logoUrl: '',
      type: 'سوبرماركت كبير',
      overallPriceIndex: 1.05,
      qualityScore: 7.5,
      branchCount: 180,
      region: 'المملكة',
    ),
    Competitor(
      id: 'danube',
      name: 'Danube',
      nameAr: 'الدانوب',
      logoUrl: '',
      type: 'هايبرماركت',
      overallPriceIndex: 1.15,
      qualityScore: 8.5,
      branchCount: 42,
      region: 'المنطقة الغربية',
    ),
    Competitor(
      id: 'carrefour',
      name: 'Carrefour',
      nameAr: 'كارفور',
      logoUrl: '',
      type: 'هايبرماركت',
      overallPriceIndex: 0.98,
      qualityScore: 7.0,
      branchCount: 85,
      region: 'المملكة',
    ),
    Competitor(
      id: 'tamimi',
      name: 'Tamimi',
      nameAr: 'التميمي',
      logoUrl: '',
      type: 'سوبرماركت',
      overallPriceIndex: 1.20,
      qualityScore: 9.0,
      branchCount: 35,
      region: 'المنطقة الوسطى',
    ),
    Competitor(
      id: 'othaim',
      name: 'Al Othaim',
      nameAr: 'العثيم',
      logoUrl: '',
      type: 'سوبرماركت',
      overallPriceIndex: 0.95,
      qualityScore: 6.5,
      branchCount: 220,
      region: 'المملكة',
    ),
  ];

  /// بيانات المنتجات الوهمية مع الأسعار
  static List<PriceComparison> getPriceComparisons() {
    final products = [
      {'id': 'p1', 'name': 'حليب المراعي 1 لتر', 'cat': 'ألبان', 'our': 6.5},
      {'id': 'p2', 'name': 'أرز بسمتي 5 كجم', 'cat': 'أرز وحبوب', 'our': 32.0},
      {'id': 'p3', 'name': 'زيت ذرة 1.5 لتر', 'cat': 'زيوت', 'our': 18.75},
      {'id': 'p4', 'name': 'سكر أبيض 5 كجم', 'cat': 'سكر', 'our': 14.50},
      {'id': 'p5', 'name': 'شاي ربيع 200 كيس', 'cat': 'مشروبات', 'our': 22.0},
      {'id': 'p6', 'name': 'تونة قودي 185 جم', 'cat': 'معلبات', 'our': 8.25},
      {
        'id': 'p7',
        'name': 'معجون أسنان كولجيت',
        'cat': 'عناية شخصية',
        'our': 12.0
      },
      {'id': 'p8', 'name': 'دجاج مبرد 1 كجم', 'cat': 'لحوم', 'our': 15.0},
      {'id': 'p9', 'name': 'بيض 30 حبة', 'cat': 'بيض', 'our': 18.0},
      {'id': 'p10', 'name': 'خبز توست لوزين', 'cat': 'مخبوزات', 'our': 7.50},
      {'id': 'p11', 'name': 'ماء معدني 12 لتر', 'cat': 'مشروبات', 'our': 5.0},
      {'id': 'p12', 'name': 'طماطم هاينز 400 جم', 'cat': 'معلبات', 'our': 5.50},
    ];

    return products.map((p) {
      final ourPrice = (p['our'] as double);
      final competitors = <String, double>{};
      for (final c in mockCompetitors) {
        final variation = ((_random.nextDouble() - 0.5) * 0.2);
        competitors[c.nameAr] = double.parse(
          (ourPrice * (1 + variation)).toStringAsFixed(2),
        );
      }
      final avgPrice =
          competitors.values.reduce((a, b) => a + b) / competitors.length;
      final diffPercent = ((ourPrice - avgPrice) / avgPrice * 100);

      PricePosition position;
      if (diffPercent < -10) {
        position = PricePosition.cheapest;
      } else if (diffPercent < -3) {
        position = PricePosition.belowAverage;
      } else if (diffPercent < 3) {
        position = PricePosition.average;
      } else if (diffPercent < 10) {
        position = PricePosition.aboveAverage;
      } else {
        position = PricePosition.mostExpensive;
      }

      return PriceComparison(
        productId: p['id'] as String,
        productName: p['name'] as String,
        category: p['cat'] as String,
        ourPrice: ourPrice,
        competitorPrices: competitors,
        avgMarketPrice: double.parse(avgPrice.toStringAsFixed(2)),
        priceDifferencePercent: double.parse(diffPercent.toStringAsFixed(1)),
        position: position,
      );
    }).toList();
  }

  /// الحصول على الموقع السوقي
  static MarketPosition getMarketPosition() {
    final points = <MarketPositionPoint>[
      const MarketPositionPoint(
        name: 'متجرنا',
        priceIndex: 0.55,
        qualityIndex: 0.75,
        marketShare: 0.05,
        isUs: true,
      ),
      const MarketPositionPoint(
        name: 'بنده',
        priceIndex: 0.60,
        qualityIndex: 0.70,
        marketShare: 0.18,
      ),
      const MarketPositionPoint(
        name: 'الدانوب',
        priceIndex: 0.75,
        qualityIndex: 0.85,
        marketShare: 0.12,
      ),
      const MarketPositionPoint(
        name: 'كارفور',
        priceIndex: 0.45,
        qualityIndex: 0.65,
        marketShare: 0.15,
      ),
      const MarketPositionPoint(
        name: 'التميمي',
        priceIndex: 0.80,
        qualityIndex: 0.92,
        marketShare: 0.08,
      ),
      const MarketPositionPoint(
        name: 'العثيم',
        priceIndex: 0.38,
        qualityIndex: 0.55,
        marketShare: 0.22,
      ),
    ];

    return MarketPosition(
      priceIndex: 0.55,
      qualityIndex: 0.75,
      valueScore: 8.2,
      positionLabel: 'Value Leader',
      positionLabelAr: 'رائد القيمة',
      competitors: points,
    );
  }

  /// الحصول على التنبيهات
  static List<CompetitorAlert> getAlerts() {
    final now = DateTime.now();
    return [
      CompetitorAlert(
        id: 'a1',
        competitorName: 'بنده',
        productName: 'حليب المراعي 1 لتر',
        alertType: AlertType.priceDecrease,
        message: 'خفض بنده سعر حليب المراعي بنسبة 8%',
        oldPrice: 6.75,
        newPrice: 6.20,
        changePercent: -8.1,
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      CompetitorAlert(
        id: 'a2',
        competitorName: 'كارفور',
        productName: 'أرز بسمتي 5 كجم',
        alertType: AlertType.promotion,
        message: 'عرض خاص على الأرز في كارفور - اشتر 2 واحصل على خصم 15%',
        oldPrice: 31.0,
        newPrice: 26.35,
        changePercent: -15.0,
        timestamp: now.subtract(const Duration(hours: 5)),
      ),
      CompetitorAlert(
        id: 'a3',
        competitorName: 'الدانوب',
        productName: 'زيت ذرة 1.5 لتر',
        alertType: AlertType.priceIncrease,
        message: 'رفع الدانوب سعر زيت الذرة بنسبة 5%',
        oldPrice: 19.0,
        newPrice: 19.95,
        changePercent: 5.0,
        timestamp: now.subtract(const Duration(hours: 8)),
      ),
      CompetitorAlert(
        id: 'a4',
        competitorName: 'العثيم',
        productName: 'دجاج مبرد 1 كجم',
        alertType: AlertType.outOfStock,
        message: 'نفاد الدجاج المبرد في العثيم - فرصة لجذب العملاء',
        oldPrice: 14.50,
        newPrice: 14.50,
        changePercent: 0,
        timestamp: now.subtract(const Duration(hours: 12)),
      ),
      CompetitorAlert(
        id: 'a5',
        competitorName: 'التميمي',
        productName: 'شاي ربيع 200 كيس',
        alertType: AlertType.priceDecrease,
        message: 'تخفيض 10% على الشاي في التميمي',
        oldPrice: 24.0,
        newPrice: 21.60,
        changePercent: -10.0,
        timestamp: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  /// ملخص التحليل
  static CompetitorAnalysisSummary getSummary() {
    final comparisons = getPriceComparisons();
    final cheaper =
        comparisons.where((c) => c.priceDifferencePercent < -3).length;
    final expensive =
        comparisons.where((c) => c.priceDifferencePercent > 3).length;
    final avgDiff = comparisons
            .map((c) => c.priceDifferencePercent)
            .reduce((a, b) => a + b) /
        comparisons.length;

    return CompetitorAnalysisSummary(
      totalProductsTracked: comparisons.length,
      cheaperThanCompetitors: cheaper,
      moreExpensiveThanCompetitors: expensive,
      averagePriceDifference: double.parse(avgDiff.toStringAsFixed(1)),
      activeAlerts: getAlerts().where((a) => !a.isRead).length,
      marketPositionLabel: 'رائد القيمة',
    );
  }
}
