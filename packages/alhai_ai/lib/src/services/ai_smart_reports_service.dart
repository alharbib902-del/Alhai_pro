/// خدمة التقارير الذكية - AI Smart Reports Service
///
/// توليد تقارير ذكية من استعلامات بلغة طبيعية
/// - تحليل الكلمات المفتاحية
/// - ربط بقوالب تقارير جاهزة
/// - اختيار نوع التصور البصري تلقائياً
library;

import 'dart:math';

// ============================================================================
// MODELS
// ============================================================================

/// نوع الرسم البياني
enum ChartType {
  barChart,
  lineChart,
  pieChart,
  table,
  number,
  heatmap,
}

/// استعلام بلغة طبيعية
class NaturalLanguageQuery {
  final String query;
  final DateTime timestamp;
  final List<String> extractedKeywords;
  final String? matchedTemplateId;

  const NaturalLanguageQuery({
    required this.query,
    required this.timestamp,
    required this.extractedKeywords,
    this.matchedTemplateId,
  });
}

/// قالب تقرير
class ReportTemplate {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final ChartType chartType;
  final String icon;
  final List<String> keywords;
  final String category;
  final DateTime? lastRun;
  final int runCount;

  const ReportTemplate({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.chartType,
    required this.icon,
    required this.keywords,
    required this.category,
    this.lastRun,
    this.runCount = 0,
  });
}

/// تقرير مولد
class GeneratedReport {
  final String id;
  final String title;
  final String titleAr;
  final String summary;
  final ChartType chartType;
  final List<ReportDataRow> data;
  final Map<String, dynamic> metadata;
  final DateTime generatedAt;
  final String templateId;
  final double? totalValue;
  final String? unit;

  const GeneratedReport({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.summary,
    required this.chartType,
    required this.data,
    this.metadata = const {},
    required this.generatedAt,
    required this.templateId,
    this.totalValue,
    this.unit,
  });
}

/// صف بيانات التقرير
class ReportDataRow {
  final String label;
  final double value;
  final double? previousValue;
  final String? category;
  final Map<String, dynamic>? extra;

  const ReportDataRow({
    required this.label,
    required this.value,
    this.previousValue,
    this.category,
    this.extra,
  });

  double get changePercent {
    if (previousValue == null || previousValue == 0) return 0;
    return ((value - previousValue!) / previousValue! * 100);
  }
}

/// اقتراح استعلام
class QuerySuggestion {
  final String text;
  final String category;
  final ChartType expectedChart;

  const QuerySuggestion({
    required this.text,
    required this.category,
    required this.expectedChart,
  });
}

// ============================================================================
// SERVICE
// ============================================================================

/// خدمة التقارير الذكية
class AiSmartReportsService {
  static final _random = Random(42);

  /// القوالب الجاهزة
  static List<ReportTemplate> getTemplates() {
    final now = DateTime.now();
    return [
      ReportTemplate(
        id: 'daily_sales',
        name: 'Daily Sales',
        nameAr: 'مبيعات اليوم',
        description: 'Total sales for today with hourly breakdown',
        descriptionAr: 'إجمالي المبيعات اليوم مع تفصيل بالساعة',
        chartType: ChartType.barChart,
        icon: 'receipt_long',
        keywords: ['مبيعات', 'اليوم', 'يومي', 'daily', 'sales', 'today'],
        category: 'مبيعات',
        lastRun: now.subtract(const Duration(hours: 1)),
        runCount: 45,
      ),
      ReportTemplate(
        id: 'top_products',
        name: 'Top 10 Products',
        nameAr: 'أفضل 10 منتجات',
        description: 'Best selling products by quantity and revenue',
        descriptionAr: 'المنتجات الأكثر مبيعاً بالكمية والإيرادات',
        chartType: ChartType.barChart,
        icon: 'star',
        keywords: ['أفضل', 'منتجات', 'مبيعاً', 'top', 'products', 'best'],
        category: 'منتجات',
        lastRun: now.subtract(const Duration(hours: 3)),
        runCount: 38,
      ),
      ReportTemplate(
        id: 'monthly_comparison',
        name: 'Monthly Comparison',
        nameAr: 'مقارنة شهرية',
        description: 'Compare sales across months',
        descriptionAr: 'مقارنة المبيعات عبر الأشهر',
        chartType: ChartType.lineChart,
        icon: 'compare_arrows',
        keywords: ['مقارنة', 'شهري', 'شهرية', 'monthly', 'comparison'],
        category: 'مبيعات',
        lastRun: now.subtract(const Duration(days: 2)),
        runCount: 22,
      ),
      ReportTemplate(
        id: 'category_distribution',
        name: 'Category Distribution',
        nameAr: 'توزيع التصنيفات',
        description: 'Sales distribution by product category',
        descriptionAr: 'توزيع المبيعات حسب تصنيف المنتج',
        chartType: ChartType.pieChart,
        icon: 'pie_chart',
        keywords: ['توزيع', 'تصنيف', 'فئات', 'category', 'distribution'],
        category: 'منتجات',
        lastRun: now.subtract(const Duration(days: 1)),
        runCount: 15,
      ),
      const ReportTemplate(
        id: 'hourly_traffic',
        name: 'Hourly Traffic',
        nameAr: 'حركة الساعات',
        description: 'Customer traffic by hour',
        descriptionAr: 'حركة العملاء حسب ساعات اليوم',
        chartType: ChartType.lineChart,
        icon: 'access_time',
        keywords: ['ساعة', 'حركة', 'ذروة', 'hourly', 'traffic', 'peak'],
        category: 'عملاء',
        runCount: 10,
      ),
      const ReportTemplate(
        id: 'profit_margin',
        name: 'Profit Margins',
        nameAr: 'هوامش الربح',
        description: 'Profit margins by product',
        descriptionAr: 'هوامش الربح حسب المنتج',
        chartType: ChartType.table,
        icon: 'attach_money',
        keywords: ['ربح', 'هامش', 'أرباح', 'profit', 'margin'],
        category: 'مالية',
        runCount: 8,
      ),
      const ReportTemplate(
        id: 'low_stock',
        name: 'Low Stock Alert',
        nameAr: 'تنبيهات المخزون المنخفض',
        description: 'Products with low stock levels',
        descriptionAr: 'المنتجات ذات المخزون المنخفض',
        chartType: ChartType.table,
        icon: 'warning',
        keywords: ['مخزون', 'منخفض', 'نفاد', 'stock', 'low', 'alert'],
        category: 'مخزون',
        runCount: 20,
      ),
      ReportTemplate(
        id: 'total_revenue',
        name: 'Total Revenue',
        nameAr: 'إجمالي الإيرادات',
        description: 'Total revenue for selected period',
        descriptionAr: 'إجمالي الإيرادات للفترة المحددة',
        chartType: ChartType.number,
        icon: 'monetization_on',
        keywords: ['إجمالي', 'إيرادات', 'revenue', 'total'],
        category: 'مالية',
        lastRun: now.subtract(const Duration(hours: 6)),
        runCount: 55,
      ),
    ];
  }

  /// اقتراحات الاستعلامات
  static List<QuerySuggestion> getSuggestions() {
    return const [
      QuerySuggestion(
          text: 'كم مبيعات اليوم؟',
          category: 'مبيعات',
          expectedChart: ChartType.number),
      QuerySuggestion(
          text: 'أفضل 10 منتجات مبيعاً',
          category: 'منتجات',
          expectedChart: ChartType.barChart),
      QuerySuggestion(
          text: 'مقارنة شهرية للمبيعات',
          category: 'مبيعات',
          expectedChart: ChartType.lineChart),
      QuerySuggestion(
          text: 'توزيع المبيعات حسب التصنيف',
          category: 'منتجات',
          expectedChart: ChartType.pieChart),
      QuerySuggestion(
          text: 'ما هي أوقات الذروة؟',
          category: 'عملاء',
          expectedChart: ChartType.lineChart),
      QuerySuggestion(
          text: 'منتجات قاربت على النفاد',
          category: 'مخزون',
          expectedChart: ChartType.table),
      QuerySuggestion(
          text: 'هوامش الربح للمنتجات',
          category: 'مالية',
          expectedChart: ChartType.table),
      QuerySuggestion(
          text: 'إجمالي إيرادات هذا الشهر',
          category: 'مالية',
          expectedChart: ChartType.number),
    ];
  }

  /// تحليل الاستعلام ومطابقته بقالب
  static NaturalLanguageQuery analyzeQuery(String query) {
    final keywords = _extractKeywords(query);
    final template = _matchTemplate(keywords);

    return NaturalLanguageQuery(
      query: query,
      timestamp: DateTime.now(),
      extractedKeywords: keywords,
      matchedTemplateId: template?.id,
    );
  }

  /// استخراج الكلمات المفتاحية
  static List<String> _extractKeywords(String query) {
    final stopWords = {
      'ما',
      'هي',
      'هو',
      'كم',
      'في',
      'من',
      'إلى',
      'على',
      'عن',
      'مع',
      'هل',
      'لي',
      'لـ',
      'عرض',
      'أعطني',
      'أرني'
    };
    return query
        .split(RegExp(r'[\s,،.؟?!]+'))
        .where((w) => w.length > 1 && !stopWords.contains(w))
        .toList();
  }

  /// مطابقة قالب بناءً على الكلمات المفتاحية
  static ReportTemplate? _matchTemplate(List<String> keywords) {
    final templates = getTemplates();
    ReportTemplate? bestMatch;
    int bestScore = 0;

    for (final template in templates) {
      int score = 0;
      for (final keyword in keywords) {
        for (final tk in template.keywords) {
          if (tk.contains(keyword) || keyword.contains(tk)) {
            score++;
          }
        }
      }
      if (score > bestScore) {
        bestScore = score;
        bestMatch = template;
      }
    }

    return bestScore > 0 ? bestMatch : null;
  }

  /// توليد تقرير من قالب
  static GeneratedReport generateReport(String templateId) {
    switch (templateId) {
      case 'daily_sales':
        return _generateDailySales();
      case 'top_products':
        return _generateTopProducts();
      case 'monthly_comparison':
        return _generateMonthlyComparison();
      case 'category_distribution':
        return _generateCategoryDistribution();
      case 'hourly_traffic':
        return _generateHourlyTraffic();
      case 'profit_margin':
        return _generateProfitMargin();
      case 'low_stock':
        return _generateLowStock();
      case 'total_revenue':
        return _generateTotalRevenue();
      default:
        return _generateDailySales();
    }
  }

  static GeneratedReport _generateDailySales() {
    final data = List.generate(12, (i) {
      final hour = 8 + i;
      return ReportDataRow(
        label: '$hour:00',
        value: (_random.nextDouble() * 2000 + 500).roundToDouble(),
        previousValue: (_random.nextDouble() * 1800 + 400).roundToDouble(),
      );
    });
    final total = data.fold<double>(0, (sum, r) => sum + r.value);

    return GeneratedReport(
      id: 'rpt_daily_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Daily Sales',
      titleAr: 'مبيعات اليوم',
      summary:
          'إجمالي مبيعات اليوم ${total.toStringAsFixed(0)} ر.س مع ${data.length} ساعة نشاط. أعلى ساعة هي الظهر.',
      chartType: ChartType.barChart,
      data: data,
      generatedAt: DateTime.now(),
      templateId: 'daily_sales',
      totalValue: total,
      unit: 'ر.س',
    );
  }

  static GeneratedReport _generateTopProducts() {
    final products = [
      'حليب المراعي 1 لتر',
      'أرز بسمتي 5 كجم',
      'خبز توست لوزين',
      'بيض 30 حبة',
      'زيت ذرة 1.5 لتر',
      'تونة قودي 185 جم',
      'سكر أبيض 5 كجم',
      'شاي ربيع 200 كيس',
      'دجاج مبرد 1 كجم',
      'ماء معدني 12 لتر',
    ];
    final data = products.asMap().entries.map((e) {
      return ReportDataRow(
        label: e.value,
        value:
            ((_random.nextDouble() * 500 + 100) * (10 - e.key)).roundToDouble(),
        category: [
          'ألبان',
          'أرز',
          'مخبوزات',
          'بيض',
          'زيوت',
          'معلبات',
          'سكر',
          'مشروبات',
          'لحوم',
          'مشروبات'
        ][e.key],
      );
    }).toList();

    return GeneratedReport(
      id: 'rpt_top_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Top 10 Products',
      titleAr: 'أفضل 10 منتجات مبيعاً',
      summary:
          'حليب المراعي يتصدر القائمة بأكبر عدد مبيعات. 60% من المبيعات تأتي من أول 3 منتجات.',
      chartType: ChartType.barChart,
      data: data,
      generatedAt: DateTime.now(),
      templateId: 'top_products',
      unit: 'وحدة',
    );
  }

  static GeneratedReport _generateMonthlyComparison() {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    final data = months.asMap().entries.map((e) {
      return ReportDataRow(
        label: e.value,
        value: (_random.nextDouble() * 50000 + 30000).roundToDouble(),
        previousValue: (_random.nextDouble() * 45000 + 28000).roundToDouble(),
      );
    }).toList();

    return GeneratedReport(
      id: 'rpt_monthly_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Monthly Comparison',
      titleAr: 'مقارنة شهرية للمبيعات',
      summary: 'نمو إجمالي بنسبة 12% مقارنة بالعام السابق. أفضل شهر كان رمضان.',
      chartType: ChartType.lineChart,
      data: data,
      generatedAt: DateTime.now(),
      templateId: 'monthly_comparison',
      unit: 'ر.س',
    );
  }

  static GeneratedReport _generateCategoryDistribution() {
    final categories = {
      'ألبان ومنتجات': 28.5,
      'لحوم ودواجن': 22.0,
      'مشروبات': 15.5,
      'مخبوزات': 12.0,
      'معلبات': 8.5,
      'خضروات وفواكه': 7.0,
      'تنظيف': 4.0,
      'أخرى': 2.5,
    };
    final data = categories.entries.map((e) {
      return ReportDataRow(label: e.key, value: e.value);
    }).toList();

    return GeneratedReport(
      id: 'rpt_category_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Category Distribution',
      titleAr: 'توزيع المبيعات حسب التصنيف',
      summary: 'الألبان تشكل الحصة الأكبر بنسبة 28.5%، تليها اللحوم بـ 22%.',
      chartType: ChartType.pieChart,
      data: data,
      generatedAt: DateTime.now(),
      templateId: 'category_distribution',
      unit: '%',
    );
  }

  static GeneratedReport _generateHourlyTraffic() {
    final data = List.generate(14, (i) {
      final hour = 7 + i;
      double traffic;
      if (hour >= 11 && hour <= 14) {
        traffic = (_random.nextDouble() * 30 + 40).roundToDouble();
      } else if (hour >= 17 && hour <= 20) {
        traffic = (_random.nextDouble() * 25 + 35).roundToDouble();
      } else {
        traffic = (_random.nextDouble() * 15 + 5).roundToDouble();
      }
      return ReportDataRow(label: '$hour:00', value: traffic);
    });

    return GeneratedReport(
      id: 'rpt_hourly_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Hourly Traffic',
      titleAr: 'حركة العملاء بالساعة',
      summary:
          'أوقات الذروة بين 11-14 ظهراً و 17-20 مساءً. أقل حركة عند 7 صباحاً.',
      chartType: ChartType.lineChart,
      data: data,
      generatedAt: DateTime.now(),
      templateId: 'hourly_traffic',
      unit: 'عميل',
    );
  }

  static GeneratedReport _generateProfitMargin() {
    final products = [
      {'name': 'حليب المراعي', 'margin': 15.5, 'prev': 14.0},
      {'name': 'أرز بسمتي', 'margin': 22.0, 'prev': 20.5},
      {'name': 'زيت ذرة', 'margin': 18.0, 'prev': 19.0},
      {'name': 'سكر أبيض', 'margin': 8.5, 'prev': 9.0},
      {'name': 'شاي ربيع', 'margin': 25.0, 'prev': 23.0},
      {'name': 'تونة قودي', 'margin': 30.0, 'prev': 28.5},
      {'name': 'دجاج مبرد', 'margin': 12.0, 'prev': 11.5},
      {'name': 'بيض', 'margin': 20.0, 'prev': 18.0},
    ];
    final data = products.map((p) {
      return ReportDataRow(
        label: p['name'] as String,
        value: p['margin'] as double,
        previousValue: p['prev'] as double,
      );
    }).toList();

    return GeneratedReport(
      id: 'rpt_profit_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Profit Margins',
      titleAr: 'هوامش الربح للمنتجات',
      summary: 'أعلى هامش ربح للتونة 30%، وأقل هامش للسكر 8.5%.',
      chartType: ChartType.table,
      data: data,
      generatedAt: DateTime.now(),
      templateId: 'profit_margin',
      unit: '%',
    );
  }

  static GeneratedReport _generateLowStock() {
    final products = [
      {'name': 'حليب المراعي 1 لتر', 'stock': 5.0, 'min': 20.0},
      {'name': 'خبز توست لوزين', 'stock': 3.0, 'min': 15.0},
      {'name': 'بيض 30 حبة', 'stock': 8.0, 'min': 25.0},
      {'name': 'دجاج مبرد 1 كجم', 'stock': 2.0, 'min': 10.0},
      {'name': 'زبادي 180 جم', 'stock': 12.0, 'min': 30.0},
    ];
    final data = products.map((p) {
      return ReportDataRow(
        label: p['name'] as String,
        value: p['stock'] as double,
        extra: {'minStock': p['min']},
      );
    }).toList();

    return GeneratedReport(
      id: 'rpt_stock_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Low Stock Alert',
      titleAr: 'تنبيهات المخزون المنخفض',
      summary:
          '5 منتجات تحت الحد الأدنى. الدجاج المبرد الأكثر حرجاً (2 وحدة فقط).',
      chartType: ChartType.table,
      data: data,
      generatedAt: DateTime.now(),
      templateId: 'low_stock',
      unit: 'وحدة',
    );
  }

  static GeneratedReport _generateTotalRevenue() {
    return GeneratedReport(
      id: 'rpt_revenue_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Total Revenue',
      titleAr: 'إجمالي الإيرادات',
      summary: 'إجمالي إيرادات الشهر الحالي مع نمو 8.5% عن الشهر السابق.',
      chartType: ChartType.number,
      data: const [
        ReportDataRow(
            label: 'إجمالي الشهر', value: 185750, previousValue: 171200),
      ],
      generatedAt: DateTime.now(),
      templateId: 'total_revenue',
      totalValue: 185750,
      unit: 'ر.س',
    );
  }
}
