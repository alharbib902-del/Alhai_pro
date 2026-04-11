/// خدمة المحادثة مع البيانات بالذكاء الاصطناعي
///
/// تحول استفسارات المستخدم باللغة الطبيعية إلى استعلامات بيانات
/// وتعرض النتائج كأرقام أو جداول أو رسوم بيانية
library;

import 'package:flutter/material.dart';

// ============================================================================
// CHAT WITH DATA MODELS
// ============================================================================

/// نوع نتيجة الاستعلام
enum QueryResultType {
  /// رقم واحد
  number,

  /// جدول بيانات
  table,

  /// رسم بياني أعمدة
  barChart,

  /// رسم بياني خطي
  lineChart,

  /// رسم بياني دائري
  pieChart,
}

/// نقطة بيانات في الرسم البياني
class ChartDataPoint {
  final String label;
  final double value;
  final Color color;

  const ChartDataPoint({
    required this.label,
    required this.value,
    required this.color,
  });
}

/// استعلام بيانات
class DataQuery {
  final String id;
  final String query;
  final DateTime timestamp;
  final QueryResultType resultType;

  const DataQuery({
    required this.id,
    required this.query,
    required this.timestamp,
    required this.resultType,
  });
}

/// نتيجة الاستعلام
class QueryResult {
  final DataQuery query;
  final QueryResultType resultType;
  final String title;
  final String? singleValue;
  final String? singleUnit;
  final List<String>? tableHeaders;
  final List<List<String>>? tableRows;
  final List<ChartDataPoint>? chartData;
  final int executionTimeMs;

  const QueryResult({
    required this.query,
    required this.resultType,
    required this.title,
    this.singleValue,
    this.singleUnit,
    this.tableHeaders,
    this.tableRows,
    this.chartData,
    required this.executionTimeMs,
  });
}

// ============================================================================
// AI CHAT WITH DATA SERVICE
// ============================================================================

/// خدمة المحادثة مع البيانات
class AiChatWithDataService {
  final List<QueryResult> _history = [];

  AiChatWithDataService();

  /// تنفيذ استعلام بالنص الطبيعي
  Future<QueryResult> executeQuery(String query, String storeId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final lowerQuery = query.trim();

    // مطابقة الأنماط
    if (_matchesPattern(lowerQuery, [
      'مبيعات اليوم',
      'مبيعات هذا اليوم',
      'كم بعنا اليوم',
      'إجمالي اليوم',
    ])) {
      return _createNumberResult(
        query,
        'إجمالي مبيعات اليوم',
        '12,450',
        'ر.س',
        45,
      );
    }

    if (_matchesPattern(lowerQuery, [
      'أفضل 10 منتجات',
      'أكثر المنتجات مبيعاً',
      'المنتجات الأكثر',
      'top 10',
    ])) {
      return _createTableResult(query, 'أفضل 10 منتجات مبيعاً', 78);
    }

    if (_matchesPattern(lowerQuery, [
      'مبيعات الأسبوع',
      'مبيعات هذا الأسبوع',
      'أسبوعي',
    ])) {
      return _createLineChartResult(query, 'مبيعات الأسبوع الحالي', 62);
    }

    if (_matchesPattern(lowerQuery, [
      'طرق الدفع',
      'توزيع الدفع',
      'نسبة الدفع',
      'كيف يدفع',
    ])) {
      return _createPieChartResult(query, 'توزيع طرق الدفع', 55);
    }

    if (_matchesPattern(lowerQuery, [
      'مقارنة المنتجات',
      'مقارنة الأقسام',
      'مقارنة التصنيفات',
      'أقسام',
    ])) {
      return _createBarChartResult(query, 'مقارنة مبيعات الأقسام', 70);
    }

    if (_matchesPattern(lowerQuery, [
      'عدد العملاء',
      'كم عميل',
      'العملاء اليوم',
    ])) {
      return _createNumberResult(query, 'عدد العملاء اليوم', '87', 'عميل', 35);
    }

    if (_matchesPattern(lowerQuery, [
      'متوسط الفاتورة',
      'معدل الفاتورة',
      'متوسط البيع',
    ])) {
      return _createNumberResult(
        query,
        'متوسط قيمة الفاتورة',
        '143.10',
        'ر.س',
        40,
      );
    }

    if (_matchesPattern(lowerQuery, [
      'المخزون المنخفض',
      'نقص المخزون',
      'منتجات تنقص',
      'مخزون قليل',
    ])) {
      return _createLowStockTable(query, 85);
    }

    if (_matchesPattern(lowerQuery, [
      'مبيعات الشهر',
      'مبيعات هذا الشهر',
      'شهري',
    ])) {
      return _createMonthlyLineChart(query, 72);
    }

    if (_matchesPattern(lowerQuery, [
      'ساعات الذروة',
      'أوقات الذروة',
      'أكثر الأوقات',
      'ساعات البيع',
    ])) {
      return _createPeakHoursChart(query, 58);
    }

    // استعلام افتراضي
    return _createNumberResult(query, 'نتيجة البحث', '0', '', 30);
  }

  /// الحصول على سجل الاستعلامات
  List<QueryResult> getQueryHistory() {
    return List.unmodifiable(_history);
  }

  /// مسح السجل
  void clearHistory() {
    _history.clear();
  }

  /// الحصول على استعلامات مقترحة
  List<String> getSuggestedQueries() {
    return const [
      'كم مبيعات اليوم؟',
      'أفضل 10 منتجات مبيعاً',
      'مبيعات الأسبوع',
      'توزيع طرق الدفع',
      'مقارنة مبيعات الأقسام',
      'عدد العملاء اليوم',
      'متوسط قيمة الفاتورة',
      'المنتجات ذات المخزون المنخفض',
      'مبيعات الشهر الحالي',
      'ساعات الذروة',
    ];
  }

  // ============================================================================
  // PRIVATE: بناء النتائج
  // ============================================================================

  bool _matchesPattern(String query, List<String> patterns) {
    for (final pattern in patterns) {
      if (query.contains(pattern)) return true;
    }
    return false;
  }

  QueryResult _createNumberResult(
    String queryText,
    String title,
    String value,
    String unit,
    int ms,
  ) {
    final result = QueryResult(
      query: DataQuery(
        id: 'Q-${DateTime.now().millisecondsSinceEpoch}',
        query: queryText,
        timestamp: DateTime.now(),
        resultType: QueryResultType.number,
      ),
      resultType: QueryResultType.number,
      title: title,
      singleValue: value,
      singleUnit: unit,
      executionTimeMs: ms,
    );
    _history.insert(0, result);
    return result;
  }

  QueryResult _createTableResult(String queryText, String title, int ms) {
    final result = QueryResult(
      query: DataQuery(
        id: 'Q-${DateTime.now().millisecondsSinceEpoch}',
        query: queryText,
        timestamp: DateTime.now(),
        resultType: QueryResultType.table,
      ),
      resultType: QueryResultType.table,
      title: title,
      tableHeaders: ['#', 'المنتج', 'الكمية', 'الإيراد'],
      tableRows: [
        ['1', 'حليب طازج 1 لتر', '145', '1,015 ر.س'],
        ['2', 'خبز أبيض', '132', '264 ر.س'],
        ['3', 'بيض بلدي 30 حبة', '98', '1,470 ر.س'],
        ['4', 'أرز بسمتي 5 كجم', '76', '3,040 ر.س'],
        ['5', 'دجاج مجمد 1200 جم', '72', '2,880 ر.س'],
        ['6', 'زيت نباتي 1.5 لتر', '65', '975 ر.س'],
        ['7', 'طماطم طازجة كجم', '61', '305 ر.س'],
        ['8', 'تمور سكري 1 كجم', '58', '2,320 ر.س'],
        ['9', 'ماء معدني 12 حبة', '55', '825 ر.س'],
        ['10', 'جبنة بيضاء 400 جم', '52', '780 ر.س'],
      ],
      executionTimeMs: ms,
    );
    _history.insert(0, result);
    return result;
  }

  QueryResult _createLineChartResult(String queryText, String title, int ms) {
    final result = QueryResult(
      query: DataQuery(
        id: 'Q-${DateTime.now().millisecondsSinceEpoch}',
        query: queryText,
        timestamp: DateTime.now(),
        resultType: QueryResultType.lineChart,
      ),
      resultType: QueryResultType.lineChart,
      title: title,
      chartData: const [
        ChartDataPoint(label: 'السبت', value: 8500, color: Color(0xFF10B981)),
        ChartDataPoint(label: 'الأحد', value: 12300, color: Color(0xFF10B981)),
        ChartDataPoint(label: 'الإثنين', value: 9800, color: Color(0xFF10B981)),
        ChartDataPoint(
          label: 'الثلاثاء',
          value: 11200,
          color: Color(0xFF10B981),
        ),
        ChartDataPoint(
          label: 'الأربعاء',
          value: 14500,
          color: Color(0xFF10B981),
        ),
        ChartDataPoint(label: 'الخميس', value: 16800, color: Color(0xFF10B981)),
        ChartDataPoint(label: 'الجمعة', value: 13200, color: Color(0xFF10B981)),
      ],
      executionTimeMs: ms,
    );
    _history.insert(0, result);
    return result;
  }

  QueryResult _createPieChartResult(String queryText, String title, int ms) {
    final result = QueryResult(
      query: DataQuery(
        id: 'Q-${DateTime.now().millisecondsSinceEpoch}',
        query: queryText,
        timestamp: DateTime.now(),
        resultType: QueryResultType.pieChart,
      ),
      resultType: QueryResultType.pieChart,
      title: title,
      chartData: const [
        ChartDataPoint(label: 'نقد', value: 55, color: Color(0xFF22C55E)),
        ChartDataPoint(label: 'مدى', value: 28, color: Color(0xFF3B82F6)),
        ChartDataPoint(label: 'تحويل', value: 10, color: Color(0xFF8B5CF6)),
        ChartDataPoint(label: 'آجل', value: 7, color: Color(0xFFEF4444)),
      ],
      executionTimeMs: ms,
    );
    _history.insert(0, result);
    return result;
  }

  QueryResult _createBarChartResult(String queryText, String title, int ms) {
    final result = QueryResult(
      query: DataQuery(
        id: 'Q-${DateTime.now().millisecondsSinceEpoch}',
        query: queryText,
        timestamp: DateTime.now(),
        resultType: QueryResultType.barChart,
      ),
      resultType: QueryResultType.barChart,
      title: title,
      chartData: const [
        ChartDataPoint(label: 'ألبان', value: 18500, color: Color(0xFF3B82F6)),
        ChartDataPoint(label: 'لحوم', value: 15200, color: Color(0xFFEF4444)),
        ChartDataPoint(label: 'خضروات', value: 12800, color: Color(0xFF22C55E)),
        ChartDataPoint(label: 'فواكه', value: 9600, color: Color(0xFFF97316)),
        ChartDataPoint(label: 'مخبوزات', value: 7400, color: Color(0xFFF59E0B)),
        ChartDataPoint(
          label: 'مشروبات',
          value: 11300,
          color: Color(0xFF06B6D4),
        ),
        ChartDataPoint(label: 'تنظيف', value: 5200, color: Color(0xFF14B8A6)),
      ],
      executionTimeMs: ms,
    );
    _history.insert(0, result);
    return result;
  }

  QueryResult _createLowStockTable(String queryText, int ms) {
    final result = QueryResult(
      query: DataQuery(
        id: 'Q-${DateTime.now().millisecondsSinceEpoch}',
        query: queryText,
        timestamp: DateTime.now(),
        resultType: QueryResultType.table,
      ),
      resultType: QueryResultType.table,
      title: 'المنتجات ذات المخزون المنخفض',
      tableHeaders: ['المنتج', 'المتوفر', 'الحد الأدنى', 'الحالة'],
      tableRows: [
        ['حليب طازج 1 لتر', '5', '20', 'حرج'],
        ['خبز أبيض', '8', '30', 'حرج'],
        ['بيض بلدي 30 حبة', '12', '15', 'منخفض'],
        ['طماطم طازجة', '15', '25', 'منخفض'],
        ['جبنة بيضاء 400 جم', '18', '20', 'منخفض'],
      ],
      executionTimeMs: ms,
    );
    _history.insert(0, result);
    return result;
  }

  QueryResult _createMonthlyLineChart(String queryText, int ms) {
    final result = QueryResult(
      query: DataQuery(
        id: 'Q-${DateTime.now().millisecondsSinceEpoch}',
        query: queryText,
        timestamp: DateTime.now(),
        resultType: QueryResultType.lineChart,
      ),
      resultType: QueryResultType.lineChart,
      title: 'مبيعات الشهر الحالي',
      chartData: const [
        ChartDataPoint(
          label: 'أسبوع 1',
          value: 42000,
          color: Color(0xFF10B981),
        ),
        ChartDataPoint(
          label: 'أسبوع 2',
          value: 38500,
          color: Color(0xFF10B981),
        ),
        ChartDataPoint(
          label: 'أسبوع 3',
          value: 51200,
          color: Color(0xFF10B981),
        ),
        ChartDataPoint(
          label: 'أسبوع 4',
          value: 47800,
          color: Color(0xFF10B981),
        ),
      ],
      executionTimeMs: ms,
    );
    _history.insert(0, result);
    return result;
  }

  QueryResult _createPeakHoursChart(String queryText, int ms) {
    final result = QueryResult(
      query: DataQuery(
        id: 'Q-${DateTime.now().millisecondsSinceEpoch}',
        query: queryText,
        timestamp: DateTime.now(),
        resultType: QueryResultType.barChart,
      ),
      resultType: QueryResultType.barChart,
      title: 'ساعات الذروة',
      chartData: const [
        ChartDataPoint(label: '8 ص', value: 1200, color: Color(0xFF94A3B8)),
        ChartDataPoint(label: '10 ص', value: 3400, color: Color(0xFF94A3B8)),
        ChartDataPoint(label: '12 م', value: 5600, color: Color(0xFFF59E0B)),
        ChartDataPoint(label: '2 م', value: 4200, color: Color(0xFF94A3B8)),
        ChartDataPoint(label: '4 م', value: 6800, color: Color(0xFFF59E0B)),
        ChartDataPoint(label: '6 م', value: 8900, color: Color(0xFFEF4444)),
        ChartDataPoint(label: '8 م', value: 7200, color: Color(0xFFF59E0B)),
        ChartDataPoint(label: '10 م', value: 3100, color: Color(0xFF94A3B8)),
      ],
      executionTimeMs: ms,
    );
    _history.insert(0, result);
    return result;
  }
}
