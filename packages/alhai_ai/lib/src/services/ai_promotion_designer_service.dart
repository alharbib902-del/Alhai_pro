/// خدمة تصميم العروض بالذكاء الاصطناعي
///
/// تولّد عروض ترويجية ذكية بناءً على بيانات المبيعات والمخزون
/// مع توقعات العائد على الاستثمار واختبارات A/B
library;

// ============================================================================
// PROMOTION MODELS
// ============================================================================

/// نوع العرض الترويجي
enum PromotionType {
  /// خصم نسبة مئوية
  percentOff,

  /// اشتري X واحصل على Y
  buyXGetY,

  /// حزمة (Bundle)
  bundle,

  /// تخفيض سريع
  flashSale,

  /// مكافأة ولاء
  loyaltyBonus,

  /// عرض موسمي
  seasonalDeal,
}

/// عرض ترويجي مولّد بالذكاء الاصطناعي
class GeneratedPromotion {
  final String id;
  final PromotionType type;
  final String title;
  final String description;
  final List<String> products;
  final double discountAmount;
  final DateTime startDate;
  final DateTime endDate;
  final double projectedRevenue;
  final double projectedCost;
  final double roi;
  final double confidence;

  const GeneratedPromotion({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.products,
    required this.discountAmount,
    required this.startDate,
    required this.endDate,
    required this.projectedRevenue,
    required this.projectedCost,
    required this.roi,
    required this.confidence,
  });
}

/// تكوين اختبار A/B
class AbTestConfig {
  final GeneratedPromotion promotionA;
  final GeneratedPromotion promotionB;
  final int testDurationDays;
  final double controlGroupPercent;
  final String metricToTrack;

  const AbTestConfig({
    required this.promotionA,
    required this.promotionB,
    required this.testDurationDays,
    required this.controlGroupPercent,
    required this.metricToTrack,
  });
}

/// نقطة توقع العائد على الاستثمار
class RoiForecast {
  final int day;
  final double projectedRevenue;
  final double projectedCost;
  final double cumulativeRoi;

  const RoiForecast({
    required this.day,
    required this.projectedRevenue,
    required this.projectedCost,
    required this.cumulativeRoi,
  });
}

// ============================================================================
// AI PROMOTION DESIGNER SERVICE
// ============================================================================

/// خدمة تصميم العروض الذكية
class AiPromotionDesignerService {
  AiPromotionDesignerService();

  /// توليد عروض ترويجية ذكية
  Future<List<GeneratedPromotion>> generatePromotions(String storeId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    return [
      GeneratedPromotion(
        id: 'PROMO-AI-001',
        type: PromotionType.seasonalDeal,
        title: 'عرض رمضان المبارك',
        description:
            'خصم 25% على سلة رمضان الأساسية (تمور، لبن، عصائر). الذكاء الاصطناعي يتوقع زيادة الطلب بنسبة 40% خلال هذه الفترة.',
        products: [
          'تمور سكري 1 كجم',
          'لبن رايب 2 لتر',
          'عصير فيمتو',
          'قمر الدين'
        ],
        discountAmount: 25,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        projectedRevenue: 45000,
        projectedCost: 11250,
        roi: 300,
        confidence: 0.92,
      ),
      GeneratedPromotion(
        id: 'PROMO-AI-002',
        type: PromotionType.buyXGetY,
        title: 'اشتري 3 واحصل على 1 مجاناً - ألبان',
        description:
            'زيادة مبيعات الألبان القريبة من انتهاء الصلاحية. AI لاحظ تباطؤ حركة الألبان يوم الأحد والإثنين.',
        products: ['حليب طازج 1 لتر', 'زبادي طبيعي', 'لبنة كاملة الدسم'],
        discountAmount: 25,
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        projectedRevenue: 8500,
        projectedCost: 2125,
        roi: 250,
        confidence: 0.88,
      ),
      GeneratedPromotion(
        id: 'PROMO-AI-003',
        type: PromotionType.flashSale,
        title: 'تخفيض سريع - ساعة الذروة',
        description:
            'خصم 15% بين 5-7 مساءً على الخضروات الطازجة. AI حدد هذا الوقت كأفضل فترة لتصريف المخزون اليومي.',
        products: ['طماطم طازجة', 'خيار', 'بصل أحمر', 'فلفل رومي'],
        discountAmount: 15,
        startDate: now,
        endDate: now.add(const Duration(days: 14)),
        projectedRevenue: 12000,
        projectedCost: 1800,
        roi: 567,
        confidence: 0.85,
      ),
      GeneratedPromotion(
        id: 'PROMO-AI-004',
        type: PromotionType.bundle,
        title: 'حزمة الإفطار السعودي',
        description:
            'حزمة شاملة للإفطار بسعر مخفض. يزيد متوسط الفاتورة بنسبة 35%. المنتجات الأكثر شراءً معاً حسب تحليل AI.',
        products: ['فول مدمس', 'جبنة بيضاء', 'خبز صامولي', 'بيض بلدي 6 حبات'],
        discountAmount: 20,
        startDate: now,
        endDate: now.add(const Duration(days: 21)),
        projectedRevenue: 15500,
        projectedCost: 3100,
        roi: 400,
        confidence: 0.90,
      ),
      GeneratedPromotion(
        id: 'PROMO-AI-005',
        type: PromotionType.percentOff,
        title: 'تصفية صيف - مشروبات باردة',
        description:
            'خصم 30% على جميع المشروبات الباردة والعصائر. التوقعات تشير لارتفاع الحرارة وزيادة الطلب.',
        products: ['مياه معدنية 12 حبة', 'عصير مانجو', 'آيس تي', 'مشروب غازي'],
        discountAmount: 30,
        startDate: now.add(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 45)),
        projectedRevenue: 28000,
        projectedCost: 8400,
        roi: 233,
        confidence: 0.82,
      ),
      GeneratedPromotion(
        id: 'PROMO-AI-006',
        type: PromotionType.loyaltyBonus,
        title: 'مكافأة الولاء - نقاط مضاعفة',
        description:
            'نقاط مضاعفة لعملاء برنامج الولاء على مشتريات أكثر من 100 ر.س. يزيد معدل العودة بنسبة 60%.',
        products: ['جميع المنتجات'],
        discountAmount: 0,
        startDate: now,
        endDate: now.add(const Duration(days: 10)),
        projectedRevenue: 22000,
        projectedCost: 3300,
        roi: 567,
        confidence: 0.87,
      ),
      GeneratedPromotion(
        id: 'PROMO-AI-007',
        type: PromotionType.percentOff,
        title: 'خصم المنتجات البطيئة',
        description:
            'خصم 35% على منتجات لم تُباع منذ أسبوعين. يساعد في تصريف المخزون الراكد وتحرير مساحة الرفوف.',
        products: ['صابون غسيل 3 لتر', 'معجون أسنان كبير', 'مناديل ورقية 200'],
        discountAmount: 35,
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        projectedRevenue: 6500,
        projectedCost: 2275,
        roi: 186,
        confidence: 0.79,
      ),
      GeneratedPromotion(
        id: 'PROMO-AI-008',
        type: PromotionType.seasonalDeal,
        title: 'عرض العودة للمدارس',
        description:
            'حزمة سناكس مدرسية بخصم 20%. AI تنبأ بزيادة الطلب على السناكس الصحية في فترة المدارس.',
        products: ['بسكويت صحي', 'عصير تفاح صغير', 'جبنة مثلثات', 'تمور معبأة'],
        discountAmount: 20,
        startDate: now.add(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 60)),
        projectedRevenue: 18000,
        projectedCost: 3600,
        roi: 400,
        confidence: 0.84,
      ),
    ];
  }

  /// توقع العائد على الاستثمار لعرض معين
  Future<List<RoiForecast>> forecastRoi(GeneratedPromotion promotion) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final duration = promotion.endDate.difference(promotion.startDate).inDays;
    final dailyRevenue = promotion.projectedRevenue / duration;
    final dailyCost = promotion.projectedCost / duration;

    final forecasts = <RoiForecast>[];
    double cumRevenue = 0;
    double cumCost = 0;

    for (int day = 1; day <= duration; day++) {
      // محاكاة تذبذب طبيعي
      final factor =
          0.8 + (day % 7 == 5 || day % 7 == 6 ? 0.5 : 0.2) * (day / duration);
      final rev = dailyRevenue * factor;
      final cost = dailyCost * factor;
      cumRevenue += rev;
      cumCost += cost;

      forecasts.add(RoiForecast(
        day: day,
        projectedRevenue: cumRevenue,
        projectedCost: cumCost,
        cumulativeRoi:
            cumCost > 0 ? ((cumRevenue - cumCost) / cumCost * 100) : 0,
      ));
    }

    return forecasts;
  }

  /// إنشاء اختبار A/B
  Future<AbTestConfig> createAbTest(
    GeneratedPromotion promotionA,
    GeneratedPromotion promotionB,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return AbTestConfig(
      promotionA: promotionA,
      promotionB: promotionB,
      testDurationDays: 7,
      controlGroupPercent: 20,
      metricToTrack: 'إجمالي الإيرادات',
    );
  }

  /// الحصول على وصف نوع العرض
  static String getPromotionTypeLabel(PromotionType type) {
    switch (type) {
      case PromotionType.percentOff:
        return 'خصم نسبة';
      case PromotionType.buyXGetY:
        return 'اشتري واحصل';
      case PromotionType.bundle:
        return 'حزمة';
      case PromotionType.flashSale:
        return 'تخفيض سريع';
      case PromotionType.loyaltyBonus:
        return 'مكافأة ولاء';
      case PromotionType.seasonalDeal:
        return 'عرض موسمي';
    }
  }

  /// الحصول على لون نوع العرض
  static int getPromotionTypeColorValue(PromotionType type) {
    switch (type) {
      case PromotionType.percentOff:
        return 0xFF3B82F6;
      case PromotionType.buyXGetY:
        return 0xFF8B5CF6;
      case PromotionType.bundle:
        return 0xFF10B981;
      case PromotionType.flashSale:
        return 0xFFEF4444;
      case PromotionType.loyaltyBonus:
        return 0xFFF59E0B;
      case PromotionType.seasonalDeal:
        return 0xFFEC4899;
    }
  }

  /// الحصول على أيقونة نوع العرض
  static String getPromotionTypeEmoji(PromotionType type) {
    switch (type) {
      case PromotionType.percentOff:
        return '%';
      case PromotionType.buyXGetY:
        return '+1';
      case PromotionType.bundle:
        return 'B';
      case PromotionType.flashSale:
        return 'F';
      case PromotionType.loyaltyBonus:
        return 'L';
      case PromotionType.seasonalDeal:
        return 'S';
    }
  }
}
