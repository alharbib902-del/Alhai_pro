/// خدمة تحليل السلة بالذكاء الاصطناعي - AI Basket Analysis Service
///
/// تحليل الارتباطات بين المنتجات واقتراح الحزم
/// - تحليل التكرار المشترك
/// - اقتراحات الحزم التلقائية
/// - رؤى السلة
library;

import 'package:alhai_database/alhai_database.dart';

// ============================================================================
// MODELS
// ============================================================================

/// ارتباط منتج - Product Association
class ProductAssociation {
  final String productAId;
  final String productAName;
  final String productBId;
  final String productBName;
  final int frequency;
  final double confidence;
  final double lift;

  const ProductAssociation({
    required this.productAId,
    required this.productAName,
    required this.productBId,
    required this.productBName,
    required this.frequency,
    required this.confidence,
    required this.lift,
  });
}

/// اقتراح حزمة - Bundle Suggestion
class BundleSuggestion {
  final String id;
  final String name;
  final List<BundleProduct> products;
  final double currentTotalPrice;
  final double suggestedBundlePrice;
  final double expectedUplift;
  final String reasoning;
  final double confidence;

  const BundleSuggestion({
    required this.id,
    required this.name,
    required this.products,
    required this.currentTotalPrice,
    required this.suggestedBundlePrice,
    required this.expectedUplift,
    required this.reasoning,
    this.confidence = 0.0,
  });

  double get savingsPercent => currentTotalPrice > 0
      ? ((currentTotalPrice - suggestedBundlePrice) / currentTotalPrice) * 100
      : 0;
}

/// منتج في الحزمة - Bundle Product
class BundleProduct {
  final String id;
  final String name;
  final double price;
  final String? category;

  const BundleProduct({
    required this.id,
    required this.name,
    required this.price,
    this.category,
  });
}

/// رؤية السلة - Basket Insight
class BasketInsight {
  final double avgBasketSize;
  final double avgBasketValue;
  final List<ProductAssociation> topPairs;
  final List<CrossSellOpportunity> crossSellOpportunities;
  final Map<String, double> categoryMix;
  final double conversionRate;

  const BasketInsight({
    required this.avgBasketSize,
    required this.avgBasketValue,
    required this.topPairs,
    required this.crossSellOpportunities,
    required this.categoryMix,
    this.conversionRate = 0.0,
  });
}

/// فرصة بيع متقاطع - Cross-Sell Opportunity
class CrossSellOpportunity {
  final String triggerProduct;
  final String suggestedProduct;
  final double probability;
  final String reason;

  const CrossSellOpportunity({
    required this.triggerProduct,
    required this.suggestedProduct,
    required this.probability,
    required this.reason,
  });
}

// ============================================================================
// SERVICE
// ============================================================================

/// خدمة تحليل السلة بالذكاء الاصطناعي
class AiBasketAnalysisService {
  final AppDatabase _db;

  AiBasketAnalysisService(this._db);

  /// الحصول على الارتباطات - Get Associations
  Future<List<ProductAssociation>> getAssociations(String storeId) async {
    // في الإنتاج سيتم تحليل saleItemsDao لإيجاد التكرارات المشتركة
    final _ = _db.saleItemsDao;

    return [
      // أرز + بهارات - Rice + Spices
      const ProductAssociation(
        productAId: 'P001', productAName: 'أرز بسمتي', // Basmati Rice
        productBId: 'P002', productBName: 'بهارات مشكلة', // Mixed Spices
        frequency: 234, confidence: 0.82, lift: 3.4,
      ),
      // خبز + جبنة - Bread + Cheese
      const ProductAssociation(
        productAId: 'P003', productAName: 'خبز عربي', // Arabic Bread
        productBId: 'P004', productBName: 'جبنة بيضاء', // White Cheese
        frequency: 198, confidence: 0.78, lift: 2.9,
      ),
      // حفاضات + مناديل مبللة - Diapers + Wet Wipes
      const ProductAssociation(
        productAId: 'P005', productAName: 'حفاضات بامبرز', // Pampers Diapers
        productBId: 'P006', productBName: 'مناديل مبللة', // Wet Wipes
        frequency: 167, confidence: 0.91, lift: 5.2,
      ),
      // حليب + كورن فليكس - Milk + Corn Flakes
      const ProductAssociation(
        productAId: 'P007', productAName: 'حليب طويل الأمد', // Long-life Milk
        productBId: 'P008', productBName: 'كورن فليكس', // Corn Flakes
        frequency: 145, confidence: 0.72, lift: 2.6,
      ),
      // دجاج + صلصة - Chicken + Sauce
      const ProductAssociation(
        productAId: 'P009', productAName: 'دجاج طازج', // Fresh Chicken
        productBId: 'P010', productBName: 'صلصة طماطم', // Tomato Sauce
        frequency: 134, confidence: 0.68, lift: 2.3,
      ),
      // شاي + سكر - Tea + Sugar
      const ProductAssociation(
        productAId: 'P011', productAName: 'شاي ربيع', // Rabea Tea
        productBId: 'P012', productBName: 'سكر أبيض', // White Sugar
        frequency: 189, confidence: 0.85, lift: 3.8,
      ),
      // معكرونة + صلصة بستو - Pasta + Pesto
      const ProductAssociation(
        productAId: 'P013', productAName: 'معكرونة سباغيتي', // Spaghetti
        productBId: 'P014', productBName: 'صلصة بستو', // Pesto Sauce
        frequency: 112, confidence: 0.65, lift: 2.1,
      ),
      // ماء + عصير - Water + Juice
      const ProductAssociation(
        productAId: 'P015', productAName: 'ماء نوفا', // Nova Water
        productBId: 'P016', productBName: 'عصير المراعي', // Almarai Juice
        frequency: 223, confidence: 0.55, lift: 1.8,
      ),
      // زيت + أرز - Oil + Rice
      const ProductAssociation(
        productAId: 'P017', productAName: 'زيت عافية', // Afia Oil
        productBId: 'P001', productBName: 'أرز بسمتي', // Basmati Rice
        frequency: 156, confidence: 0.71, lift: 2.5,
      ),
      // لبن + تمر - Yogurt + Dates
      const ProductAssociation(
        productAId: 'P018', productAName: 'لبن المراعي', // Almarai Yogurt
        productBId: 'P019', productBName: 'تمر سكري', // Sukkari Dates
        frequency: 98, confidence: 0.62, lift: 2.0,
      ),
    ];
  }

  /// اقتراحات الحزم - Get Bundle Suggestions
  Future<List<BundleSuggestion>> getBundleSuggestions(String storeId) async {
    final _ = _db.saleItemsDao;

    return [
      // حزمة الإفطار - Breakfast Bundle
      const BundleSuggestion(
        id: 'B001',
        name: 'حزمة الإفطار العائلي', // Family Breakfast Bundle
        products: [
          BundleProduct(
              id: 'P003', name: 'خبز عربي', price: 3.5, category: 'مخبوزات'),
          BundleProduct(
              id: 'P004', name: 'جبنة بيضاء', price: 12.0, category: 'ألبان'),
          BundleProduct(
              id: 'P018', name: 'لبن المراعي', price: 6.5, category: 'ألبان'),
          BundleProduct(
              id: 'P019', name: 'تمر سكري', price: 25.0, category: 'حلويات'),
        ],
        currentTotalPrice: 47.0,
        suggestedBundlePrice: 39.9,
        expectedUplift: 18.5,
        reasoning:
            'هذه المنتجات تُشترى معاً بنسبة 78% - تقديم حزمة سيزيد المبيعات', // These products are bought together 78% of the time
        confidence: 0.82,
      ),
      // حزمة الطبخ - Cooking Bundle
      const BundleSuggestion(
        id: 'B002',
        name: 'حزمة الطبخ الأساسية', // Essential Cooking Bundle
        products: [
          BundleProduct(
              id: 'P001', name: 'أرز بسمتي', price: 28.0, category: 'أرز'),
          BundleProduct(
              id: 'P002', name: 'بهارات مشكلة', price: 8.5, category: 'بهارات'),
          BundleProduct(
              id: 'P017', name: 'زيت عافية', price: 22.0, category: 'زيوت'),
          BundleProduct(
              id: 'P010', name: 'صلصة طماطم', price: 4.5, category: 'صلصات'),
        ],
        currentTotalPrice: 63.0,
        suggestedBundlePrice: 54.9,
        expectedUplift: 22.0,
        reasoning:
            'مكونات الطبخ الأساسية - ارتباط قوي بين الأرز والبهارات والزيت', // Basic cooking ingredients - strong association
        confidence: 0.88,
      ),
      // حزمة الأطفال - Baby Bundle
      const BundleSuggestion(
        id: 'B003',
        name: 'حزمة العناية بالطفل', // Baby Care Bundle
        products: [
          BundleProduct(
              id: 'P005',
              name: 'حفاضات بامبرز',
              price: 45.0,
              category: 'أطفال'),
          BundleProduct(
              id: 'P006', name: 'مناديل مبللة', price: 12.0, category: 'أطفال'),
        ],
        currentTotalPrice: 57.0,
        suggestedBundlePrice: 49.9,
        expectedUplift: 15.0,
        reasoning:
            'ارتباط قوي جداً (91%) بين الحفاضات والمناديل المبللة', // Very strong association (91%)
        confidence: 0.91,
      ),
      // حزمة المشروبات - Beverages Bundle
      const BundleSuggestion(
        id: 'B004',
        name: 'حزمة المشروبات', // Beverages Bundle
        products: [
          BundleProduct(
              id: 'P011', name: 'شاي ربيع', price: 15.0, category: 'مشروبات'),
          BundleProduct(
              id: 'P012', name: 'سكر أبيض', price: 8.0, category: 'أساسيات'),
          BundleProduct(
              id: 'P007',
              name: 'حليب طويل الأمد',
              price: 7.0,
              category: 'ألبان'),
        ],
        currentTotalPrice: 30.0,
        suggestedBundlePrice: 25.9,
        expectedUplift: 12.0,
        reasoning:
            'الشاي والسكر والحليب يُشترون معاً بنسبة 85%', // Tea, sugar and milk are bought together 85% of the time
        confidence: 0.85,
      ),
    ];
  }

  /// رؤى السلة - Get Basket Insights
  Future<BasketInsight> getBasketInsights(String storeId) async {
    final _ = _db.saleItemsDao;
    final topPairs = await getAssociations(storeId);

    return BasketInsight(
      avgBasketSize: 4.7,
      avgBasketValue: 68.5,
      topPairs: topPairs.take(5).toList(),
      crossSellOpportunities: const [
        CrossSellOpportunity(
          triggerProduct: 'دجاج طازج', // Fresh Chicken
          suggestedProduct: 'أرز بسمتي', // Basmati Rice
          probability: 0.72,
          reason:
              '72% من مشتري الدجاج يشترون الأرز أيضاً', // 72% of chicken buyers also buy rice
        ),
        CrossSellOpportunity(
          triggerProduct: 'حفاضات بامبرز', // Pampers Diapers
          suggestedProduct: 'حليب الأطفال', // Baby Milk
          probability: 0.65,
          reason:
              'فرصة بيع متقاطع للأمهات الجدد', // Cross-sell opportunity for new mothers
        ),
        CrossSellOpportunity(
          triggerProduct: 'معكرونة سباغيتي', // Spaghetti
          suggestedProduct: 'جبنة بارميزان', // Parmesan Cheese
          probability: 0.58,
          reason:
              'ارتباط قوي في فئة المعكرونة', // Strong association in pasta category
        ),
      ],
      categoryMix: {
        'أساسيات': 35.0, // Essentials
        'ألبان': 22.0, // Dairy
        'مشروبات': 18.0, // Beverages
        'لحوم': 12.0, // Meat
        'حلويات': 8.0, // Sweets
        'تنظيف': 5.0, // Cleaning
      },
      conversionRate: 73.5,
    );
  }
}
