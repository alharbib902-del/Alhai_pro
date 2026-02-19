/// مزودات تحليلات الموظفين - AI Staff Analytics Providers
///
/// إدارة حالة بيانات أداء الموظفين والترتيب والورديات
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_staff_analytics_service.dart';

// ============================================================================
// PROVIDERS
// ============================================================================

/// مزود أداء الموظفين
final staffPerformanceProvider = FutureProvider<List<StaffPerformance>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return AiStaffAnalyticsService.getStaffPerformance();
});

/// مزود ترتيب الموظفين
final staffRankingsProvider = Provider<List<StaffRanking>>((ref) {
  return AiStaffAnalyticsService.getStaffRankings();
});

/// مزود خريطة حرارية للورديات
final shiftHeatmapProvider = Provider<ShiftHeatmapData>((ref) {
  return AiStaffAnalyticsService.getShiftHeatmap();
});

/// مزود تحسينات الورديات
final shiftOptimizationsProvider = Provider<List<ShiftOptimization>>((ref) {
  return AiStaffAnalyticsService.getShiftOptimizations();
});

/// مزود ملخص الفريق
final teamSummaryProvider = Provider<TeamPerformanceSummary>((ref) {
  return AiStaffAnalyticsService.getTeamSummary();
});

/// مزود الموظف المحدد
final selectedStaffProvider = StateProvider<String?>((ref) => null);

/// مزود فلتر الفترة
final staffPeriodFilterProvider = StateProvider<StaffPeriod>((ref) => StaffPeriod.thisWeek);

/// فترة العرض
enum StaffPeriod {
  today,
  thisWeek,
  thisMonth,
  lastMonth,
}
