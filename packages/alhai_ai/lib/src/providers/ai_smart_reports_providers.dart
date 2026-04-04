/// مزودات التقارير الذكية - AI Smart Reports Providers
///
/// إدارة حالة الاستعلامات والتقارير المولدة والقوالب
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_api_service.dart';
import '../services/ai_smart_reports_service.dart';
import 'package:alhai_auth/alhai_auth.dart';

// ============================================================================
// PROVIDERS
// ============================================================================

/// مزود القوالب المتاحة
final reportTemplatesProvider = Provider<List<ReportTemplate>>((ref) {
  return AiSmartReportsService.getTemplates();
});

/// مزود اقتراحات الاستعلامات
final querySuggestionsProvider = Provider<List<QuerySuggestion>>((ref) {
  return AiSmartReportsService.getSuggestions();
});

/// مزود الاستعلام الحالي
final currentQueryProvider = StateProvider<String>((ref) => '');

/// مزود التقرير المولد
final generatedReportProvider = StateNotifierProvider<GeneratedReportNotifier,
    AsyncValue<GeneratedReport?>>((ref) {
  return GeneratedReportNotifier();
});

/// مزود سجل التقارير
final reportHistoryProvider =
    StateNotifierProvider<ReportHistoryNotifier, List<GeneratedReport>>((ref) {
  return ReportHistoryNotifier();
});

/// قيمة "الكل" الافتراضية لفلتر القوالب
const kAllCategoryFilter = '__all__';

/// مزود فلتر فئة القالب
final templateCategoryFilterProvider =
    StateProvider<String>((ref) => kAllCategoryFilter);

/// مزود حالة التحميل
final reportLoadingProvider = StateProvider<bool>((ref) => false);

// ============================================================================
// NOTIFIERS
// ============================================================================

/// إدارة التقرير المولد
class GeneratedReportNotifier
    extends StateNotifier<AsyncValue<GeneratedReport?>> {
  GeneratedReportNotifier() : super(const AsyncValue.data(null));

  /// توليد تقرير من استعلام
  Future<void> generateFromQuery(String query) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final analyzed = AiSmartReportsService.analyzeQuery(query);
      if (analyzed.matchedTemplateId != null) {
        final report =
            AiSmartReportsService.generateReport(analyzed.matchedTemplateId!);
        state = AsyncValue.data(report);
      } else {
        // Default to daily sales if no match
        final report = AiSmartReportsService.generateReport('daily_sales');
        state = AsyncValue.data(report);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// توليد تقرير من قالب
  Future<void> generateFromTemplate(String templateId) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final report = AiSmartReportsService.generateReport(templateId);
      state = AsyncValue.data(report);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

/// إدارة سجل التقارير
class ReportHistoryNotifier extends StateNotifier<List<GeneratedReport>> {
  ReportHistoryNotifier() : super([]);

  void addReport(GeneratedReport report) {
    state = [report, ...state].take(20).toList();
  }

  void clearHistory() {
    state = [];
  }

  void removeReport(String reportId) {
    state = state.where((r) => r.id != reportId).toList();
  }
}

// ============================================================================
// REMOTE API PROVIDER - مزود API البعيد
// ============================================================================

/// مزود بيانات التقارير من خادم AI
final reportsApiProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(aiApiServiceProvider);
  final storeId = ref.read(currentStoreIdProvider)!;
  return api.getSmartReport(orgId: 'default', storeId: storeId);
});
