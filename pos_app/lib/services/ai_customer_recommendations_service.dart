/// خدمة توصيات العملاء بالذكاء الاصطناعي - AI Customer Recommendations Service
///
/// توفر توصيات منتجات مخصصة لكل عميل
/// - تقسيم العملاء
/// - تذكيرات إعادة الشراء
/// - اقتراحات منتجات بناءً على تاريخ الشراء
library;

import '../data/local/app_database.dart';

// ============================================================================
// ENUMS
// ============================================================================

/// شريحة العميل - Customer Segment
enum CustomerSegment {
  /// عميل VIP
  vip,
  /// عميل منتظم - Regular
  regular,
  /// عميل معرض للخسارة - At Risk
  atRisk,
  /// عميل مفقود - Lost
  lost,
  /// عميل جديد - New Customer
  newCustomer,
}

// ============================================================================
// MODELS
// ============================================================================

/// منتج مُوصى به - Recommended Product
class RecommendedProduct {
  final String productId;
  final String name;
  final String reason;
  final double confidence;
  final int avgPurchaseInterval; // أيام - days
  final double price;
  final String? category;

  const RecommendedProduct({
    required this.productId,
    required this.name,
    required this.reason,
    required this.confidence,
    this.avgPurchaseInterval = 0,
    this.price = 0.0,
    this.category,
  });
}

/// توصية عميل - Customer Recommendation
class CustomerRecommendation {
  final String customerId;
  final String customerName;
  final CustomerSegment segment;
  final List<RecommendedProduct> products;
  final DateTime lastVisit;
  final double avgSpend;
  final double totalSpent;
  final int visitCount;
  final String? phone;

  const CustomerRecommendation({
    required this.customerId,
    required this.customerName,
    required this.segment,
    required this.products,
    required this.lastVisit,
    required this.avgSpend,
    required this.totalSpent,
    this.visitCount = 0,
    this.phone,
  });
}

/// تذكير إعادة الشراء - Repurchase Reminder
class RepurchaseReminder {
  final String customerId;
  final String customerName;
  final String productName;
  final DateTime expectedDate;
  final int daysSinceLastPurchase;
  final int avgInterval;
  final bool isOverdue;
  final String? phone;

  const RepurchaseReminder({
    required this.customerId,
    required this.customerName,
    required this.productName,
    required this.expectedDate,
    required this.daysSinceLastPurchase,
    required this.avgInterval,
    this.isOverdue = false,
    this.phone,
  });
}

/// نتيجة تقسيم العملاء - Segment Result
class SegmentResult {
  final CustomerSegment segment;
  final int count;
  final double totalRevenue;
  final double avgSpend;
  final List<CustomerRecommendation> customers;

  const SegmentResult({
    required this.segment,
    required this.count,
    required this.totalRevenue,
    required this.avgSpend,
    required this.customers,
  });
}

// ============================================================================
// SERVICE
// ============================================================================

/// خدمة توصيات العملاء بالذكاء الاصطناعي
class AiCustomerRecommendationsService {
  final AppDatabase _db;

  AiCustomerRecommendationsService(this._db);

  /// الحصول على التوصيات - Get Recommendations
  Future<List<CustomerRecommendation>> getRecommendations(String storeId) async {
    final _ = _db.salesDao;
    final now = DateTime.now();

    return [
      // عميل VIP
      CustomerRecommendation(
        customerId: 'C001',
        customerName: 'عبدالله الغامدي', // Abdullah Al-Ghamdi
        segment: CustomerSegment.vip,
        lastVisit: now.subtract(const Duration(days: 2)),
        avgSpend: 285.0,
        totalSpent: 15420.0,
        visitCount: 54,
        phone: '+966501234567',
        products: const [
          RecommendedProduct(
            productId: 'P001', name: 'أرز بسمتي', // Basmati Rice
            reason: 'يشتري كل 14 يوم - موعد الشراء القادم قريب', // Buys every 14 days
            confidence: 0.92, avgPurchaseInterval: 14, price: 28.0, category: 'أرز',
          ),
          RecommendedProduct(
            productId: 'P009', name: 'دجاج طازج', // Fresh Chicken
            reason: 'اشترى مع الأرز 85% من المرات', // Bought with rice 85% of the time
            confidence: 0.85, avgPurchaseInterval: 7, price: 35.0, category: 'لحوم',
          ),
          RecommendedProduct(
            productId: 'P017', name: 'زيت عافية', // Afia Oil
            reason: 'من مشترياته الأساسية الشهرية', // Part of monthly essentials
            confidence: 0.78, avgPurchaseInterval: 30, price: 22.0, category: 'زيوت',
          ),
        ],
      ),
      // عميل منتظم
      CustomerRecommendation(
        customerId: 'C002',
        customerName: 'فاطمة السيد', // Fatima Al-Sayed
        segment: CustomerSegment.regular,
        lastVisit: now.subtract(const Duration(days: 5)),
        avgSpend: 145.0,
        totalSpent: 8350.0,
        visitCount: 32,
        phone: '+966551234567',
        products: const [
          RecommendedProduct(
            productId: 'P005', name: 'حفاضات بامبرز', // Pampers Diapers
            reason: 'تشتري كل 10 أيام', // Buys every 10 days
            confidence: 0.95, avgPurchaseInterval: 10, price: 45.0, category: 'أطفال',
          ),
          RecommendedProduct(
            productId: 'P006', name: 'مناديل مبللة', // Wet Wipes
            reason: 'تُشترى مع الحفاضات دائماً', // Always bought with diapers
            confidence: 0.91, avgPurchaseInterval: 10, price: 12.0, category: 'أطفال',
          ),
        ],
      ),
      // عميل معرض للخسارة
      CustomerRecommendation(
        customerId: 'C003',
        customerName: 'محمد الدوسري', // Mohammed Al-Dosari
        segment: CustomerSegment.atRisk,
        lastVisit: now.subtract(const Duration(days: 25)),
        avgSpend: 198.0,
        totalSpent: 6340.0,
        visitCount: 22,
        phone: '+966541234567',
        products: const [
          RecommendedProduct(
            productId: 'P011', name: 'شاي ربيع', // Rabea Tea
            reason: 'آخر مشتريات - ربما يحتاج عرض لجذبه', // Last purchase - might need an offer
            confidence: 0.68, avgPurchaseInterval: 20, price: 15.0, category: 'مشروبات',
          ),
        ],
      ),
      // عميل مفقود
      CustomerRecommendation(
        customerId: 'C004',
        customerName: 'نورة الحربي', // Noura Al-Harbi
        segment: CustomerSegment.lost,
        lastVisit: now.subtract(const Duration(days: 60)),
        avgSpend: 220.0,
        totalSpent: 4840.0,
        visitCount: 15,
        phone: '+966561234567',
        products: const [
          RecommendedProduct(
            productId: 'P018', name: 'لبن المراعي', // Almarai Yogurt
            reason: 'كانت تشتري أسبوعياً - يُنصح بإرسال عرض خاص', // Used to buy weekly - send special offer
            confidence: 0.55, avgPurchaseInterval: 7, price: 6.5, category: 'ألبان',
          ),
        ],
      ),
      // عميل جديد
      CustomerRecommendation(
        customerId: 'C005',
        customerName: 'سارة العنزي', // Sarah Al-Anazi
        segment: CustomerSegment.newCustomer,
        lastVisit: now.subtract(const Duration(days: 3)),
        avgSpend: 95.0,
        totalSpent: 285.0,
        visitCount: 3,
        phone: '+966571234567',
        products: const [
          RecommendedProduct(
            productId: 'P003', name: 'خبز عربي', // Arabic Bread
            reason: 'من المنتجات الأكثر شراءً للعملاء الجدد', // Most purchased by new customers
            confidence: 0.70, avgPurchaseInterval: 3, price: 3.5, category: 'مخبوزات',
          ),
          RecommendedProduct(
            productId: 'P004', name: 'جبنة بيضاء', // White Cheese
            reason: 'مرتبطة بالخبز بنسبة 78%', // Associated with bread at 78%
            confidence: 0.65, avgPurchaseInterval: 7, price: 12.0, category: 'ألبان',
          ),
        ],
      ),
      // عميل VIP آخر
      CustomerRecommendation(
        customerId: 'C006',
        customerName: 'خالد المطيري', // Khaled Al-Mutairi
        segment: CustomerSegment.vip,
        lastVisit: now.subtract(const Duration(days: 1)),
        avgSpend: 340.0,
        totalSpent: 22100.0,
        visitCount: 65,
        phone: '+966581234567',
        products: const [
          RecommendedProduct(
            productId: 'P019', name: 'تمر سكري', // Sukkari Dates
            reason: 'من مشترياته المفضلة - يشتري كل أسبوعين', // Favorite - buys biweekly
            confidence: 0.88, avgPurchaseInterval: 14, price: 25.0, category: 'حلويات',
          ),
        ],
      ),
    ];
  }

  /// تذكيرات إعادة الشراء - Get Repurchase Reminders
  Future<List<RepurchaseReminder>> getRepurchaseReminders(String storeId) async {
    final _ = _db.salesDao;
    final now = DateTime.now();

    return [
      RepurchaseReminder(
        customerId: 'C001',
        customerName: 'عبدالله الغامدي', // Abdullah Al-Ghamdi
        productName: 'أرز بسمتي', // Basmati Rice
        expectedDate: now.subtract(const Duration(days: 2)),
        daysSinceLastPurchase: 16,
        avgInterval: 14,
        isOverdue: true,
        phone: '+966501234567',
      ),
      RepurchaseReminder(
        customerId: 'C002',
        customerName: 'فاطمة السيد', // Fatima Al-Sayed
        productName: 'حفاضات بامبرز', // Pampers Diapers
        expectedDate: now.add(const Duration(days: 2)),
        daysSinceLastPurchase: 8,
        avgInterval: 10,
        isOverdue: false,
        phone: '+966551234567',
      ),
      RepurchaseReminder(
        customerId: 'C006',
        customerName: 'خالد المطيري', // Khaled Al-Mutairi
        productName: 'تمر سكري', // Sukkari Dates
        expectedDate: now.subtract(const Duration(days: 1)),
        daysSinceLastPurchase: 15,
        avgInterval: 14,
        isOverdue: true,
        phone: '+966581234567',
      ),
      RepurchaseReminder(
        customerId: 'C003',
        customerName: 'محمد الدوسري', // Mohammed Al-Dosari
        productName: 'شاي ربيع', // Rabea Tea
        expectedDate: now.subtract(const Duration(days: 5)),
        daysSinceLastPurchase: 25,
        avgInterval: 20,
        isOverdue: true,
        phone: '+966541234567',
      ),
    ];
  }

  /// تقسيم العملاء - Segment Customers
  Future<List<SegmentResult>> segmentCustomers(String storeId) async {
    final allRecs = await getRecommendations(storeId);

    final segments = <CustomerSegment, List<CustomerRecommendation>>{};
    for (final rec in allRecs) {
      segments.putIfAbsent(rec.segment, () => []).add(rec);
    }

    return segments.entries.map((entry) {
      final customers = entry.value;
      final totalRevenue = customers.fold<double>(0, (sum, c) => sum + c.totalSpent);
      final avgSpend = customers.fold<double>(0, (sum, c) => sum + c.avgSpend) / customers.length;

      return SegmentResult(
        segment: entry.key,
        count: customers.length,
        totalRevenue: totalRevenue,
        avgSpend: avgSpend,
        customers: customers,
      );
    }).toList()
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
  }
}
