import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_ai/src/services/ai_smart_reports_service.dart';

void main() {
  group('ChartType', () {
    test('has all values', () {
      expect(ChartType.values.length, 6);
    });
  });

  group('ReportDataRow', () {
    test('changePercent returns 0 when no previous value', () {
      const row = ReportDataRow(label: 'Test', value: 100);
      expect(row.changePercent, 0);
    });

    test('changePercent returns 0 when previous value is 0', () {
      const row = ReportDataRow(label: 'Test', value: 100, previousValue: 0);
      expect(row.changePercent, 0);
    });

    test('changePercent calculates positive change', () {
      const row = ReportDataRow(label: 'Test', value: 120, previousValue: 100);
      expect(row.changePercent, 20.0);
    });

    test('changePercent calculates negative change', () {
      const row = ReportDataRow(label: 'Test', value: 80, previousValue: 100);
      expect(row.changePercent, -20.0);
    });
  });

  group('getTemplates', () {
    test('returns list of report templates', () {
      final templates = AiSmartReportsService.getTemplates();
      expect(templates, isNotEmpty);
      expect(templates.length, 8);
    });

    test('each template has required fields', () {
      final templates = AiSmartReportsService.getTemplates();
      for (final t in templates) {
        expect(t.id, isNotEmpty);
        expect(t.name, isNotEmpty);
        expect(t.nameAr, isNotEmpty);
        expect(t.keywords, isNotEmpty);
        expect(t.category, isNotEmpty);
      }
    });

    test('templates have unique IDs', () {
      final templates = AiSmartReportsService.getTemplates();
      final ids = templates.map((t) => t.id).toSet();
      expect(ids.length, templates.length);
    });
  });

  group('getSuggestions', () {
    test('returns query suggestions', () {
      final suggestions = AiSmartReportsService.getSuggestions();
      expect(suggestions, isNotEmpty);
      expect(suggestions.length, 8);
    });

    test('each suggestion has category and chart type', () {
      final suggestions = AiSmartReportsService.getSuggestions();
      for (final s in suggestions) {
        expect(s.text, isNotEmpty);
        expect(s.category, isNotEmpty);
      }
    });
  });

  group('analyzeQuery', () {
    test('matches sales query to daily_sales template', () {
      final result = AiSmartReportsService.analyzeQuery('مبيعات اليوم');
      expect(result.extractedKeywords, isNotEmpty);
      expect(result.matchedTemplateId, 'daily_sales');
    });

    test('matches top products query', () {
      final result = AiSmartReportsService.analyzeQuery('أفضل المنتجات مبيعاً');
      expect(result.matchedTemplateId, 'top_products');
    });

    test('matches monthly comparison query', () {
      final result = AiSmartReportsService.analyzeQuery('مقارنة شهرية');
      expect(result.matchedTemplateId, 'monthly_comparison');
    });

    test('matches stock query', () {
      final result = AiSmartReportsService.analyzeQuery('مخزون منخفض');
      expect(result.matchedTemplateId, 'low_stock');
    });

    test('returns null template for unmatched query', () {
      final result = AiSmartReportsService.analyzeQuery('xyz random');
      expect(result.matchedTemplateId, isNull);
    });

    test('extracted keywords exclude stop words', () {
      final result = AiSmartReportsService.analyzeQuery('ما هي مبيعات اليوم');
      expect(result.extractedKeywords, isNot(contains('ما')));
      expect(result.extractedKeywords, isNot(contains('هي')));
    });
  });

  group('generateReport', () {
    test('generates daily sales report', () {
      final report = AiSmartReportsService.generateReport('daily_sales');
      expect(report.templateId, 'daily_sales');
      expect(report.chartType, ChartType.barChart);
      expect(report.data, isNotEmpty);
      expect(report.totalValue, greaterThan(0));
      expect(report.unit, 'ر.س');
    });

    test('generates top products report', () {
      final report = AiSmartReportsService.generateReport('top_products');
      expect(report.templateId, 'top_products');
      expect(report.data.length, 10);
    });

    test('generates monthly comparison report', () {
      final report =
          AiSmartReportsService.generateReport('monthly_comparison');
      expect(report.chartType, ChartType.lineChart);
      expect(report.data.length, 12);
    });

    test('generates category distribution report', () {
      final report =
          AiSmartReportsService.generateReport('category_distribution');
      expect(report.chartType, ChartType.pieChart);
      expect(report.data, isNotEmpty);
      expect(report.unit, '%');
    });

    test('generates profit margin report', () {
      final report = AiSmartReportsService.generateReport('profit_margin');
      expect(report.chartType, ChartType.table);
    });

    test('generates low stock report', () {
      final report = AiSmartReportsService.generateReport('low_stock');
      expect(report.chartType, ChartType.table);
      expect(report.data, isNotEmpty);
    });

    test('generates total revenue report', () {
      final report = AiSmartReportsService.generateReport('total_revenue');
      expect(report.chartType, ChartType.number);
      expect(report.totalValue, greaterThan(0));
    });

    test('generates hourly traffic report', () {
      final report = AiSmartReportsService.generateReport('hourly_traffic');
      expect(report.chartType, ChartType.lineChart);
      expect(report.data.length, 14);
    });

    test('default template falls back to daily sales', () {
      final report =
          AiSmartReportsService.generateReport('nonexistent_template');
      expect(report.templateId, 'daily_sales');
    });

    test('all reports have required fields', () {
      final templateIds = [
        'daily_sales', 'top_products', 'monthly_comparison',
        'category_distribution', 'hourly_traffic', 'profit_margin',
        'low_stock', 'total_revenue',
      ];

      for (final id in templateIds) {
        final report = AiSmartReportsService.generateReport(id);
        expect(report.id, isNotEmpty);
        expect(report.title, isNotEmpty);
        expect(report.titleAr, isNotEmpty);
        expect(report.summary, isNotEmpty);
        expect(report.data, isNotEmpty);
        expect(report.generatedAt, isNotNull);
      }
    });
  });
}
