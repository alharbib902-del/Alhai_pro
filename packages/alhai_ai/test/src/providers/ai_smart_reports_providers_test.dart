import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_ai/src/providers/ai_smart_reports_providers.dart';
import 'package:alhai_ai/src/services/ai_smart_reports_service.dart';

void main() {
  group('currentQueryProvider', () {
    test('initial value is empty string', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(currentQueryProvider), isEmpty);
    });

    test('can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(currentQueryProvider.notifier).state = 'daily sales';
      expect(container.read(currentQueryProvider), 'daily sales');
    });
  });

  group('templateCategoryFilterProvider', () {
    test('initial value is all category filter constant', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(templateCategoryFilterProvider),
        kAllCategoryFilter,
      );
    });

    test('can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(templateCategoryFilterProvider.notifier).state = 'sales';
      expect(container.read(templateCategoryFilterProvider), 'sales');
    });
  });

  group('reportLoadingProvider', () {
    test('initial value is false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(reportLoadingProvider), isFalse);
    });

    test('can be updated to true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(reportLoadingProvider.notifier).state = true;
      expect(container.read(reportLoadingProvider), isTrue);
    });
  });

  group('reportTemplatesProvider', () {
    test('returns non-empty list of templates', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final templates = container.read(reportTemplatesProvider);
      expect(templates, isNotEmpty);
      expect(templates, isA<List<ReportTemplate>>());
    });
  });

  group('querySuggestionsProvider', () {
    test('returns suggestions', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final suggestions = container.read(querySuggestionsProvider);
      expect(suggestions, isNotEmpty);
      expect(suggestions, isA<List<QuerySuggestion>>());
    });
  });

  group('GeneratedReportNotifier', () {
    test('initial state is data null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final report = container.read(generatedReportProvider);
      expect(report.valueOrNull, isNull);
    });

    test('clear sets state to data null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(generatedReportProvider.notifier).clear();
      expect(container.read(generatedReportProvider).valueOrNull, isNull);
    });
  });

  group('ReportHistoryNotifier', () {
    test('initial state is empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(reportHistoryProvider), isEmpty);
    });

    test('clearHistory empties the list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(reportHistoryProvider.notifier).clearHistory();
      expect(container.read(reportHistoryProvider), isEmpty);
    });
  });
}
