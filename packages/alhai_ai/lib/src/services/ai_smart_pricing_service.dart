/// خدمة التسعير الذكي - AI Smart Pricing Service
///
/// تحليل الأسعار والتكاليف لاقتراح أفضل الأسعار
/// - اقتراحات أسعار مبنية على التكلفة والمبيعات
/// - حساب تأثير تغيير السعر
/// - مرونة الطلب السعرية
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:alhai_database/alhai_database.dart';

// ============================================================================
// PRICING MODELS
// ============================================================================

/// تأثير تغيير السعر
class PriceImpact {
  final double monthlyRevenueDelta;
  final double yearlyProfitDelta;
  final double volumeChange; // نسبة التغير في الحجم

  const PriceImpact({
    required this.monthlyRevenueDelta,
    required this.yearlyProfitDelta,
    required this.volumeChange,
  });
}

/// اقتراح سعر
class PriceSuggestion {
  final String productId;
  final String name;
  final double currentPrice;
  final double suggestedPrice;
  final double costPrice;
  final String reasoning;
  final double confidence;
  final PriceImpact expectedImpact;
  final IconData icon;

  const PriceSuggestion({
    required this.productId,
    required this.name,
    required this.currentPrice,
    required this.suggestedPrice,
    required this.costPrice,
    required this.reasoning,
    required this.confidence,
    required this.expectedImpact,
    this.icon = Icons.inventory_2_rounded,
  });

  /// نسبة التغيير في السعر
  double get changePercent => currentPrice > 0
      ? ((suggestedPrice - currentPrice) / currentPrice) * 100
      : 0;

  /// هل يقترح زيادة؟
  bool get isIncrease => suggestedPrice > currentPrice;

  /// هل يقترح خفض؟
  bool get isDecrease => suggestedPrice < currentPrice;

  /// هامش الربح الحالي
  double get currentMargin =>
      currentPrice > 0 ? ((currentPrice - costPrice) / currentPrice) * 100 : 0;

  /// هامش الربح المقترح
  double get suggestedMargin => suggestedPrice > 0
      ? ((suggestedPrice - costPrice) / suggestedPrice) * 100
      : 0;
}

/// تصنيف مرونة الطلب
enum ElasticityClass {
  /// غير مرن (المنتجات الأساسية)
  inelastic,

  /// مرن (المنتجات الترفيهية)
  elastic,

  /// وحدوي
  unit,
}

/// مرونة الطلب السعرية
class DemandElasticity {
  final String productId;
  final String productName;
  final double elasticity;
  final ElasticityClass classification;
  final String description;

  const DemandElasticity({
    required this.productId,
    required this.productName,
    required this.elasticity,
    required this.classification,
    required this.description,
  });
}

/// خيار تسعير جماعي
class BulkPricingOption {
  final String productId;
  final String name;
  final double currentPrice;
  final double suggestedPrice;
  final double safeIncreasePercent;
  final String category;

  const BulkPricingOption({
    required this.productId,
    required this.name,
    required this.currentPrice,
    required this.suggestedPrice,
    required this.safeIncreasePercent,
    required this.category,
  });
}

// ============================================================================
// FILTER
// ============================================================================

/// فلتر اقتراحات الأسعار
enum PriceFilterType {
  /// الكل
  all,

  /// يمكن زيادتها بأمان
  canIncrease,

  /// يُنصح بخفضها
  shouldDecrease,
}

// ============================================================================
// AI SMART PRICING SERVICE
// ============================================================================

/// خدمة التسعير الذكي
class AiSmartPricingService {
  final AppDatabase _db;
  final Random _random = Random(42);

  AiSmartPricingService(this._db);

  /// الحصول على اقتراحات الأسعار
  Future<List<PriceSuggestion>> getPriceSuggestions(String storeId) async {
    final products = await _db.productsDao.getAllProducts(storeId);
    final suggestions = <PriceSuggestion>[];

    for (final product in products.where((p) => p.isActive)) {
      final suggestion = _analyzeProductPricing(product);
      if (suggestion != null) {
        suggestions.add(suggestion);
      }
    }

    // ترتيب حسب التأثير المتوقع
    suggestions.sort(
      (a, b) => b.expectedImpact.monthlyRevenueDelta.abs().compareTo(
        a.expectedImpact.monthlyRevenueDelta.abs(),
      ),
    );

    return suggestions;
  }

  /// حساب تأثير تغيير السعر لمنتج معين
  Future<PriceImpact> calculateImpact(String productId, double newPrice) async {
    final product = await _db.productsDao.getProductById(productId);
    if (product == null) {
      return const PriceImpact(
        monthlyRevenueDelta: 0,
        yearlyProfitDelta: 0,
        volumeChange: 0,
      );
    }

    final currentPrice = product.price;
    final costPrice = product.costPrice ?? (currentPrice * 0.6);
    final priceChange = currentPrice > 0
        ? (newPrice - currentPrice) / currentPrice
        : 0.0;

    // مرونة سعرية تقريبية
    final elasticity = _estimateElasticity(product);
    final volumeChangePercent = -priceChange * elasticity * 100;

    // حجم المبيعات الشهري المقدر
    final monthlyVolume = _estimateMonthlyVolume(product);
    final newVolume = monthlyVolume * (1 + volumeChangePercent / 100);

    final currentMonthlyRevenue = currentPrice * monthlyVolume;
    final newMonthlyRevenue = newPrice * newVolume;
    final monthlyRevenueDelta = newMonthlyRevenue - currentMonthlyRevenue;

    final currentMonthlyProfit = (currentPrice - costPrice) * monthlyVolume;
    final newMonthlyProfit = (newPrice - costPrice) * newVolume;
    final yearlyProfitDelta = (newMonthlyProfit - currentMonthlyProfit) * 12;

    return PriceImpact(
      monthlyRevenueDelta: monthlyRevenueDelta,
      yearlyProfitDelta: yearlyProfitDelta,
      volumeChange: volumeChangePercent,
    );
  }

  /// حساب مرونة الطلب السعرية لمنتج
  Future<DemandElasticity> getElasticity(String productId) async {
    final product = await _db.productsDao.getProductById(productId);
    if (product == null) {
      return const DemandElasticity(
        productId: '',
        productName: 'غير معروف',
        elasticity: 1.0,
        classification: ElasticityClass.unit,
        description: 'لا توجد بيانات كافية',
      );
    }

    final elasticity = _estimateElasticity(product);
    final classification = elasticity.abs() < 0.8
        ? ElasticityClass.inelastic
        : elasticity.abs() > 1.2
        ? ElasticityClass.elastic
        : ElasticityClass.unit;

    String description;
    switch (classification) {
      case ElasticityClass.inelastic:
        description =
            '${product.name} منتج غير مرن - العملاء يشترونه بغض النظر عن السعر. يمكنك رفع السعر بأمان.';
        // Inelastic - customers buy regardless of price
        break;
      case ElasticityClass.elastic:
        description =
            '${product.name} منتج مرن - العملاء حساسون للسعر. احذر من رفع السعر كثيراً.';
        // Elastic - customers are price-sensitive
        break;
      case ElasticityClass.unit:
        description =
            '${product.name} منتج وحدوي المرونة - التغير في السعر يتناسب مع التغير في الطلب.';
        // Unit elastic
        break;
    }

    return DemandElasticity(
      productId: product.id,
      productName: product.name,
      elasticity: elasticity,
      classification: classification,
      description: description,
    );
  }

  /// الحصول على خيارات التسعير الجماعي
  Future<List<BulkPricingOption>> getBulkPricingOptions(String storeId) async {
    final products = await _db.productsDao.getAllProducts(storeId);
    final options = <BulkPricingOption>[];

    for (final product in products.where((p) => p.isActive)) {
      final elasticity = _estimateElasticity(product);

      // فقط المنتجات التي يمكن زيادة سعرها بأمان
      if (elasticity.abs() < 1.0) {
        final safeIncrease = (1.0 - elasticity.abs()) * 10;
        if (safeIncrease > 2) {
          // الحد الأدنى 2%
          options.add(
            BulkPricingOption(
              productId: product.id,
              name: product.name,
              currentPrice: product.price,
              suggestedPrice: product.price * (1 + safeIncrease / 100),
              safeIncreasePercent: safeIncrease,
              category: product.categoryId ?? 'عام', // General
            ),
          );
        }
      }
    }

    options.sort(
      (a, b) => b.safeIncreasePercent.compareTo(a.safeIncreasePercent),
    );
    return options;
  }

  // ==========================================================================
  // PRIVATE HELPERS
  // ==========================================================================

  /// تحليل تسعير المنتج
  PriceSuggestion? _analyzeProductPricing(ProductsTableData product) {
    final cost = product.costPrice ?? (product.price * 0.6);
    if (product.price <= 0) return null;

    final margin = (product.price - cost) / product.price * 100;
    final elasticity = _estimateElasticity(product);
    final monthlyVolume = _estimateMonthlyVolume(product);

    double suggestedPrice;
    String reasoning;
    double confidence;

    if (margin < 15) {
      // هامش ربح منخفض جداً - يجب رفع السعر
      const targetMargin = 25.0;
      suggestedPrice = cost / (1 - targetMargin / 100);
      reasoning =
          'هامش الربح الحالي ${margin.toStringAsFixed(1)}% منخفض جداً. يُنصح برفع السعر لتحقيق هامش ${targetMargin.toStringAsFixed(0)}%.';
      // Current margin too low, suggest raising price
      confidence = 0.9;
    } else if (margin > 60) {
      // هامش ربح مرتفع جداً مع مبيعات منخفضة
      suggestedPrice = product.price * 0.85;
      reasoning =
          'هامش الربح ${margin.toStringAsFixed(1)}% مرتفع. خفض السعر قد يزيد حجم المبيعات بشكل كبير.';
      // High margin, lowering price may significantly increase volume
      confidence = 0.75;
    } else if (elasticity.abs() < 0.7 && margin < 40) {
      // منتج غير مرن مع هامش متوسط - يمكن رفع السعر
      suggestedPrice = product.price * 1.05;
      reasoning =
          'المنتج غير مرن سعرياً (العملاء يحتاجونه). يمكن رفع السعر 5% دون تأثير على المبيعات.';
      // Inelastic product, can safely increase price 5%
      confidence = 0.85;
    } else if (elasticity.abs() > 1.3 && margin > 35) {
      // منتج مرن مع هامش جيد - يُنصح بخفض بسيط
      suggestedPrice = product.price * 0.95;
      reasoning =
          'المنتج مرن سعرياً. خفض 5% قد يزيد المبيعات بنسبة ${(5 * elasticity.abs()).toStringAsFixed(0)}%.';
      // Elastic product, 5% decrease may increase sales
      confidence = 0.7;
    } else {
      // السعر مناسب
      suggestedPrice = product.price;
      reasoning = 'السعر الحالي مناسب ومتوازن مع السوق.';
      // Current price is appropriate
      confidence = 0.6;
    }

    // حساب التأثير
    final priceChangePercent = (suggestedPrice - product.price) / product.price;
    final volumeChangePercent = -priceChangePercent * elasticity * 100;
    final newVolume = monthlyVolume * (1 + volumeChangePercent / 100);
    final monthlyRevenueDelta =
        (suggestedPrice * newVolume) - (product.price * monthlyVolume);
    final yearlyProfitDelta =
        ((suggestedPrice - cost) * newVolume -
            (product.price - cost) * monthlyVolume) *
        12;

    return PriceSuggestion(
      productId: product.id,
      name: product.name,
      currentPrice: product.price,
      suggestedPrice: double.parse(suggestedPrice.toStringAsFixed(2)),
      costPrice: cost,
      reasoning: reasoning,
      confidence: confidence,
      icon: _getProductIcon(product.categoryId),
      expectedImpact: PriceImpact(
        monthlyRevenueDelta: monthlyRevenueDelta,
        yearlyProfitDelta: yearlyProfitDelta,
        volumeChange: volumeChangePercent,
      ),
    );
  }

  /// تقدير مرونة الطلب السعرية
  double _estimateElasticity(ProductsTableData product) {
    // تقدير مبسط بناءً على خصائص المنتج
    final price = product.price;
    final stock = product.stockQty;
    final minStock = product.minQty;

    // المنتجات منخفضة السعر عادة أقل مرونة (أساسيات)
    // Low price products are usually less elastic (essentials)
    double elasticity = 1.0;

    if (price < 10) {
      elasticity = 0.5; // أساسي جداً - Very essential
    } else if (price < 30) {
      elasticity = 0.8; // أساسي - Essential
    } else if (price < 100) {
      elasticity = 1.2; // متوسط - Medium
    } else {
      elasticity = 1.5; // ترفيهي - Luxury
    }

    // المنتجات ذات المخزون العالي مقارنة بالحد الأدنى = مبيعات بطيئة = مرن أكثر
    if (minStock > 0 && stock > minStock * 3) {
      elasticity += 0.3;
    }

    // إضافة بعض التباين العشوائي الثابت
    elasticity += (_random.nextDouble() * 0.2) - 0.1;

    return elasticity;
  }

  /// تقدير حجم المبيعات الشهري
  double _estimateMonthlyVolume(ProductsTableData product) {
    // تقدير مبسط بناءً على الحد الأدنى للمخزون
    final minStock = product.minQty;
    if (minStock > 0) {
      return minStock * 4.0; // تقريباً 4 مرات الحد الأدنى شهرياً
    }
    return 20.0; // قيمة افتراضية
  }

  /// أيقونة المنتج حسب التصنيف
  IconData _getProductIcon(String? categoryId) {
    if (categoryId == null) return Icons.inventory_2_rounded;
    final cat = categoryId.toLowerCase();
    if (cat.contains('fruit') || cat.contains('فواكه')) {
      return Icons.apple_rounded;
    }
    if (cat.contains('drink') || cat.contains('مشروب')) {
      return Icons.local_cafe_rounded;
    }
    if (cat.contains('dairy') || cat.contains('ألبان')) {
      return Icons.egg_rounded;
    }
    if (cat.contains('meat') || cat.contains('لحم')) {
      return Icons.set_meal_rounded;
    }
    if (cat.contains('snack') || cat.contains('سناك')) {
      return Icons.cookie_rounded;
    }
    if (cat.contains('clean') || cat.contains('تنظيف')) {
      return Icons.cleaning_services_rounded;
    }
    return Icons.inventory_2_rounded;
  }
}
