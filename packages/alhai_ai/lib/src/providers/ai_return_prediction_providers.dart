/// مزودات التنبؤ بالمرتجعات بالذكاء الاصطناعي
///
/// Riverpod providers لإدارة حالة شاشة التنبؤ بالمرتجعات
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_api_service.dart';
import '../services/ai_return_prediction_service.dart';
import 'package:alhai_auth/alhai_auth.dart';

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
  return service.getReturnProbabilities(ref.read(currentStoreIdProvider)!);
});

/// مزود الإجراءات الوقائية
final preventiveActionsProvider = FutureProvider<List<PreventiveAction>>((ref) async {
  final service = ref.watch(aiReturnPredictionServiceProvider);
  return service.getPreventiveActions(ref.read(currentStoreIdProvider)!);
});

/// مزود اتجاهات المرتجعات
final returnTrendsProvider = FutureProvider<List<ReturnTrend>>((ref) async {
  final service = ref.watch(aiReturnPredictionServiceProvider);
  return service.getReturnTrends(ref.read(currentStoreIdProvider)!);
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

// ============================================================================
// REMOTE API PROVIDER - مزود API البعيد
// ============================================================================

/// مزود بيانات التنبؤ بالمرتجعات من خادم AI
final returnsApiProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(aiApiServiceProvider);
  final storeId = ref.read(currentStoreIdProvider)!;
  return api.predictReturns(orgId: 'default', storeId: storeId);
});
