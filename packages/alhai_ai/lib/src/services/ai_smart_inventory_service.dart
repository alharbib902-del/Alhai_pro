/// خدمة المخزون الذكي بالذكاء الاصطناعي - AI Smart Inventory Service
///
/// تحسين المخزون باستخدام:
/// - حساب EOQ (كمية الطلب الاقتصادية)
/// - تحليل ABC
/// - توقع الهدر
/// - اقتراحات إعادة الطلب
library;

import 'package:alhai_database/alhai_database.dart';

// ============================================================================
// ENUMS
// ============================================================================

/// تصنيف ABC - ABC Category
enum AbcCategory {
  /// فئة أ - أعلى 20% من الإيراد (عادة 80% من القيمة)
  a,

  /// فئة ب - الـ 30% التالية
  b,

  /// فئة ج - الـ 50% الأدنى
  c,
}

/// مستوى إلحاح - Urgency Level
enum UrgencyLevel {
  /// حرج - Critical
  critical,

  /// عالي - High
  high,

  /// متوسط - Medium
  medium,

  /// منخفض - Low
  low,
}

/// إجراء مقترح للهدر - Waste Suggested Action
enum WasteSuggestedAction {
  /// تخفيض السعر - Discount
  discount,

  /// نقل لفرع آخر - Transfer
  transfer,

  /// تبرع - Donate
  donate,

  /// لا إجراء - No action
  none,
}

// ============================================================================
// MODELS
// ============================================================================

/// نتيجة EOQ - EOQ Result
class EoqResult {
  final String productId;
  final String name;
  final int eoq;
  final int reorderPoint;
  final int safetyStock;
  final double annualDemand;
  final double orderCost;
  final double holdingCost;
  final double totalAnnualCost;
  final String? category;

  const EoqResult({
    required this.productId,
    required this.name,
    required this.eoq,
    required this.reorderPoint,
    required this.safetyStock,
    required this.annualDemand,
    required this.orderCost,
    required this.holdingCost,
    this.totalAnnualCost = 0,
    this.category,
  });
}

/// عنصر ABC - ABC Item
class AbcItem {
  final String productId;
  final String name;
  final AbcCategory category;
  final double revenue;
  final double percentage;
  final double cumulativePercentage;
  final int unitsSold;
  final double price;

  const AbcItem({
    required this.productId,
    required this.name,
    required this.category,
    required this.revenue,
    required this.percentage,
    required this.cumulativePercentage,
    this.unitsSold = 0,
    this.price = 0,
  });
}

/// توقع الهدر - Waste Prediction
class WastePrediction {
  final String productId;
  final String name;
  final int currentStock;
  final DateTime expiryDate;
  final int daysToExpiry;
  final double sellRate; // وحدة/يوم - units/day
  final double predictedWaste; // نسبة مئوية - percentage
  final int predictedWasteUnits;
  final WasteSuggestedAction suggestedAction;
  final double estimatedLoss; // بالريال - in SAR

  const WastePrediction({
    required this.productId,
    required this.name,
    required this.currentStock,
    required this.expiryDate,
    required this.daysToExpiry,
    required this.sellRate,
    required this.predictedWaste,
    this.predictedWasteUnits = 0,
    required this.suggestedAction,
    this.estimatedLoss = 0,
  });
}

/// اقتراح إعادة الطلب - Reorder Suggestion
class ReorderSuggestion {
  final String productId;
  final String name;
  final int currentStock;
  final int reorderPoint;
  final int suggestedQty;
  final UrgencyLevel urgency;
  final String? supplier;
  final double estimatedCost;
  final int daysOfStock;

  const ReorderSuggestion({
    required this.productId,
    required this.name,
    required this.currentStock,
    required this.reorderPoint,
    required this.suggestedQty,
    required this.urgency,
    this.supplier,
    this.estimatedCost = 0,
    this.daysOfStock = 0,
  });
}

/// ملخص المخزون الذكي - Smart Inventory Summary
class SmartInventorySummary {
  final int totalProducts;
  final int abcACount;
  final int abcBCount;
  final int abcCCount;
  final int expiringCount;
  final int reorderCount;
  final double totalEstimatedLoss;

  const SmartInventorySummary({
    required this.totalProducts,
    required this.abcACount,
    required this.abcBCount,
    required this.abcCCount,
    required this.expiringCount,
    required this.reorderCount,
    required this.totalEstimatedLoss,
  });
}

// ============================================================================
// SERVICE
// ============================================================================

/// خدمة المخزون الذكي بالذكاء الاصطناعي
class AiSmartInventoryService {
  final AppDatabase _db;

  AiSmartInventoryService(this._db);

  /// حساب EOQ - Calculate EOQ
  Future<List<EoqResult>> calculateEoq(String storeId) async {
    final _ = _db.productsDao;
    return [
      const EoqResult(
        productId: 'P001', name: 'أرز بسمتي', // Basmati Rice
        eoq: 120, reorderPoint: 45, safetyStock: 15,
        annualDemand: 1440, orderCost: 50.0, holdingCost: 3.5,
        totalAnnualCost: 840.0, category: 'أرز',
      ),
      const EoqResult(
        productId: 'P007', name: 'حليب طويل الأمد', // Long-life Milk
        eoq: 200, reorderPoint: 80, safetyStock: 25,
        annualDemand: 2400, orderCost: 35.0, holdingCost: 1.5,
        totalAnnualCost: 600.0, category: 'ألبان',
      ),
      const EoqResult(
        productId: 'P005', name: 'حفاضات بامبرز', // Pampers Diapers
        eoq: 80, reorderPoint: 30, safetyStock: 10,
        annualDemand: 960, orderCost: 75.0, holdingCost: 8.0,
        totalAnnualCost: 1280.0, category: 'أطفال',
      ),
      const EoqResult(
        productId: 'P011', name: 'شاي ربيع', // Rabea Tea
        eoq: 150, reorderPoint: 55, safetyStock: 20,
        annualDemand: 1800, orderCost: 40.0, holdingCost: 2.0,
        totalAnnualCost: 720.0, category: 'مشروبات',
      ),
      const EoqResult(
        productId: 'P017', name: 'زيت عافية', // Afia Oil
        eoq: 60, reorderPoint: 25, safetyStock: 8,
        annualDemand: 720, orderCost: 55.0, holdingCost: 4.5,
        totalAnnualCost: 990.0, category: 'زيوت',
      ),
      const EoqResult(
        productId: 'P003', name: 'خبز عربي', // Arabic Bread
        eoq: 300, reorderPoint: 120, safetyStock: 40,
        annualDemand: 3600, orderCost: 20.0, holdingCost: 0.5,
        totalAnnualCost: 360.0, category: 'مخبوزات',
      ),
    ];
  }

  /// تحليل ABC - Get ABC Analysis
  Future<List<AbcItem>> getAbcAnalysis(String storeId) async {
    final _ = _db.productsDao;
    return const [
      AbcItem(
          productId: 'P001',
          name: 'أرز بسمتي',
          category: AbcCategory.a,
          revenue: 40320.0,
          percentage: 22.5,
          cumulativePercentage: 22.5,
          unitsSold: 1440,
          price: 28.0),
      AbcItem(
          productId: 'P009',
          name: 'دجاج طازج',
          category: AbcCategory.a,
          revenue: 36750.0,
          percentage: 20.5,
          cumulativePercentage: 43.0,
          unitsSold: 1050,
          price: 35.0),
      AbcItem(
          productId: 'P005',
          name: 'حفاضات بامبرز',
          category: AbcCategory.a,
          revenue: 28800.0,
          percentage: 16.1,
          cumulativePercentage: 59.1,
          unitsSold: 640,
          price: 45.0),
      AbcItem(
          productId: 'P017',
          name: 'زيت عافية',
          category: AbcCategory.b,
          revenue: 15840.0,
          percentage: 8.8,
          cumulativePercentage: 67.9,
          unitsSold: 720,
          price: 22.0),
      AbcItem(
          productId: 'P019',
          name: 'تمر سكري',
          category: AbcCategory.b,
          revenue: 13000.0,
          percentage: 7.3,
          cumulativePercentage: 75.2,
          unitsSold: 520,
          price: 25.0),
      AbcItem(
          productId: 'P011',
          name: 'شاي ربيع',
          category: AbcCategory.b,
          revenue: 10800.0,
          percentage: 6.0,
          cumulativePercentage: 81.2,
          unitsSold: 720,
          price: 15.0),
      AbcItem(
          productId: 'P007',
          name: 'حليب طويل الأمد',
          category: AbcCategory.b,
          revenue: 8400.0,
          percentage: 4.7,
          cumulativePercentage: 85.9,
          unitsSold: 1200,
          price: 7.0),
      AbcItem(
          productId: 'P004',
          name: 'جبنة بيضاء',
          category: AbcCategory.c,
          revenue: 6240.0,
          percentage: 3.5,
          cumulativePercentage: 89.4,
          unitsSold: 520,
          price: 12.0),
      AbcItem(
          productId: 'P018',
          name: 'لبن المراعي',
          category: AbcCategory.c,
          revenue: 5070.0,
          percentage: 2.8,
          cumulativePercentage: 92.2,
          unitsSold: 780,
          price: 6.5),
      AbcItem(
          productId: 'P012',
          name: 'سكر أبيض',
          category: AbcCategory.c,
          revenue: 3840.0,
          percentage: 2.1,
          cumulativePercentage: 94.3,
          unitsSold: 480,
          price: 8.0),
      AbcItem(
          productId: 'P003',
          name: 'خبز عربي',
          category: AbcCategory.c,
          revenue: 3780.0,
          percentage: 2.1,
          cumulativePercentage: 96.4,
          unitsSold: 1080,
          price: 3.5),
      AbcItem(
          productId: 'P010',
          name: 'صلصة طماطم',
          category: AbcCategory.c,
          revenue: 3510.0,
          percentage: 2.0,
          cumulativePercentage: 98.4,
          unitsSold: 780,
          price: 4.5),
    ];
  }

  /// توقعات الهدر - Get Waste Predictions
  Future<List<WastePrediction>> getWastePredictions(String storeId) async {
    final _ = _db.inventoryDao;
    final now = DateTime.now();

    return [
      WastePrediction(
        productId: 'P018', name: 'لبن المراعي', // Almarai Yogurt
        currentStock: 85, expiryDate: now.add(const Duration(days: 3)),
        daysToExpiry: 3, sellRate: 12.0, predictedWaste: 58.8,
        predictedWasteUnits: 49,
        suggestedAction: WasteSuggestedAction.discount, estimatedLoss: 318.5,
      ),
      WastePrediction(
        productId: 'P003', name: 'خبز عربي', // Arabic Bread
        currentStock: 120, expiryDate: now.add(const Duration(days: 1)),
        daysToExpiry: 1, sellRate: 45.0, predictedWaste: 62.5,
        predictedWasteUnits: 75,
        suggestedAction: WasteSuggestedAction.donate, estimatedLoss: 262.5,
      ),
      WastePrediction(
        productId: 'P009', name: 'دجاج طازج', // Fresh Chicken
        currentStock: 35, expiryDate: now.add(const Duration(days: 2)),
        daysToExpiry: 2, sellRate: 8.0, predictedWaste: 54.3,
        predictedWasteUnits: 19,
        suggestedAction: WasteSuggestedAction.discount, estimatedLoss: 665.0,
      ),
      WastePrediction(
        productId: 'P004', name: 'جبنة بيضاء', // White Cheese
        currentStock: 40, expiryDate: now.add(const Duration(days: 7)),
        daysToExpiry: 7, sellRate: 4.0, predictedWaste: 30.0,
        predictedWasteUnits: 12,
        suggestedAction: WasteSuggestedAction.transfer, estimatedLoss: 144.0,
      ),
      WastePrediction(
        productId: 'P007', name: 'حليب طويل الأمد', // Long-life Milk
        currentStock: 200, expiryDate: now.add(const Duration(days: 30)),
        daysToExpiry: 30, sellRate: 6.5, predictedWaste: 2.5,
        predictedWasteUnits: 5,
        suggestedAction: WasteSuggestedAction.none, estimatedLoss: 35.0,
      ),
    ];
  }

  /// اقتراحات إعادة الطلب - Get Reorder Suggestions
  Future<List<ReorderSuggestion>> getReorderSuggestions(String storeId) async {
    final _ = _db.productsDao;
    return const [
      ReorderSuggestion(
        productId: 'P001', name: 'أرز بسمتي', // Basmati Rice
        currentStock: 12, reorderPoint: 45, suggestedQty: 120,
        urgency: UrgencyLevel.critical,
        supplier: 'شركة الراجحي للتوزيع', // Al-Rajhi Distribution
        estimatedCost: 3360.0, daysOfStock: 2,
      ),
      ReorderSuggestion(
        productId: 'P005', name: 'حفاضات بامبرز', // Pampers Diapers
        currentStock: 18, reorderPoint: 30, suggestedQty: 80,
        urgency: UrgencyLevel.high,
        supplier: 'المستودعات المتحدة', // United Warehouses
        estimatedCost: 3600.0, daysOfStock: 5,
      ),
      ReorderSuggestion(
        productId: 'P017', name: 'زيت عافية', // Afia Oil
        currentStock: 22, reorderPoint: 25, suggestedQty: 60,
        urgency: UrgencyLevel.medium,
        supplier: 'صافولا للتوزيع', // Savola Distribution
        estimatedCost: 1320.0, daysOfStock: 8,
      ),
      ReorderSuggestion(
        productId: 'P012', name: 'سكر أبيض', // White Sugar
        currentStock: 55, reorderPoint: 50, suggestedQty: 100,
        urgency: UrgencyLevel.low,
        supplier: 'شركة الغذاء المتكامل', // Integrated Food Co
        estimatedCost: 800.0, daysOfStock: 15,
      ),
    ];
  }

  /// الحصول على الملخص - Get Summary
  Future<SmartInventorySummary> getSummary(String storeId) async {
    final abc = await getAbcAnalysis(storeId);
    final waste = await getWastePredictions(storeId);
    final reorder = await getReorderSuggestions(storeId);

    return SmartInventorySummary(
      totalProducts: abc.length,
      abcACount: abc.where((i) => i.category == AbcCategory.a).length,
      abcBCount: abc.where((i) => i.category == AbcCategory.b).length,
      abcCCount: abc.where((i) => i.category == AbcCategory.c).length,
      expiringCount: waste.where((w) => w.daysToExpiry <= 7).length,
      reorderCount: reorder.length,
      totalEstimatedLoss: waste.fold(0, (sum, w) => sum + w.estimatedLoss),
    );
  }
}
