/// مزودات التنبؤ بالمرتجعات بالذكاء الاصطناعي
///
/// Riverpod providers لإدارة حالة شاشة التنبؤ بالمرتجعات
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_return_prediction_service.dart';

// ============================================================================
// SERVICE PROVIDER
// ============================================================================

/// مزود خدمة التنبؤ بالمرتجعات
final aiReturnPredictionServiceProvider = Provider<AiReturnPredictionService>((ref) {
  return AiReturnPredictionService();
});

// ============================================================================
// DATA PROVIDERS
// ============================================================================

/// مزود احتمالات الإرجاع
final returnProbabilitiesProvider = FutureProvider<List<ReturnProbability>>((ref) async {
  final service = ref.watch(aiReturnPredictionServiceProvider);
  return service.getReturnProbabilities('store_demo_001');
});

/// مزود الإجراءات الوقائية
final preventiveActionsProvider = FutureProvider<List<PreventiveAction>>((ref) async {
  final service = ref.watch(aiReturnPredictionServiceProvider);
  return service.getPreventiveActions('store_demo_001');
});

/// مزود اتجاهات المرتجعات
final returnTrendsProvider = FutureProvider<List<ReturnTrend>>((ref) async {
  final service = ref.watch(aiReturnPredictionServiceProvider);
  return service.getReturnTrends('store_demo_001');
});

// ============================================================================
// COMPUTED PROVIDERS
// ============================================================================

/// مزود متوسط معدل الإرجاع
final averageReturnRateProvider = FutureProvider<double>((ref) async {
  final trends = await ref.watch(returnTrendsProvider.future);
  final service = ref.watch(aiReturnPredictionServiceProvider);
  return service.calculateAverageReturnRate(trends);
});

/// مزود المبلغ المعرض للخطر
final atRiskAmountProvider = FutureProvider<double>((ref) async {
  final probabilities = await ref.watch(returnProbabilitiesProvider.future);
  final service = ref.watch(aiReturnPredictionServiceProvider);
  return service.calculateAtRiskAmount(probabilities);
});

/// مزود عدد العمليات عالية الخطر
final highRiskCountProvider = FutureProvider<int>((ref) async {
  final probabilities = await ref.watch(returnProbabilitiesProvider.future);
  return probabilities
      .where((p) => p.riskLevel == ReturnRiskLevel.high || p.riskLevel == ReturnRiskLevel.veryHigh)
      .length;
});

/// مزود فلتر مستوى الخطر المحدد
final selectedRiskFilterProvider = StateProvider<ReturnRiskLevel?>((ref) => null);

/// مزود القائمة المفلترة
final filteredProbabilitiesProvider = FutureProvider<List<ReturnProbability>>((ref) async {
  final probabilities = await ref.watch(returnProbabilitiesProvider.future);
  final filter = ref.watch(selectedRiskFilterProvider);
  if (filter == null) return probabilities;
  return probabilities.where((p) => p.riskLevel == filter).toList();
});
