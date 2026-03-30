/// مزودات كشف الاحتيال - AI Fraud Detection Providers
///
/// مزودات Riverpod لإدارة حالة كشف الاحتيال
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import '../services/ai_api_service.dart';
import '../services/ai_fraud_detection_service.dart';
import 'package:alhai_auth/alhai_auth.dart';

/// مزود خدمة كشف الاحتيال - Fraud Detection Service Provider
final aiFraudDetectionServiceProvider = Provider<AiFraudDetectionService>((ref) {
  final db = GetIt.I<AppDatabase>();
  return AiFraudDetectionService(db);
});

/// مزود تنبيهات الاحتيال - Fraud Alerts Provider
final fraudAlertsProvider = FutureProvider.autoDispose<List<FraudAlert>>((ref) async {
  final service = ref.watch(aiFraudDetectionServiceProvider);
  return service.getAlerts(ref.read(currentStoreIdProvider)!);
});

/// مزود درجات السلوك - Behavior Scores Provider
final behaviorScoresProvider = FutureProvider.autoDispose<List<BehaviorScore>>((ref) async {
  final service = ref.watch(aiFraudDetectionServiceProvider);
  return service.getBehaviorScores(ref.read(currentStoreIdProvider)!);
});

/// مزود ملخص كشف الاحتيال - Fraud Detection Summary Provider
final fraudSummaryProvider = FutureProvider.autoDispose<FraudDetectionSummary>((ref) async {
  final service = ref.watch(aiFraudDetectionServiceProvider);
  return service.getSummary(ref.read(currentStoreIdProvider)!);
});

/// مزود فلتر خطورة التنبيهات - Severity Filter Provider
final fraudSeverityFilterProvider = StateProvider<FraudSeverity?>((ref) => null);

/// مزود فلتر نمط الاحتيال - Pattern Filter Provider
final fraudPatternFilterProvider = StateProvider<FraudPattern?>((ref) => null);

/// مزود التنبيهات المفلترة - Filtered Alerts Provider
final filteredFraudAlertsProvider = Provider.autoDispose<AsyncValue<List<FraudAlert>>>((ref) {
  final alertsAsync = ref.watch(fraudAlertsProvider);
  final severityFilter = ref.watch(fraudSeverityFilterProvider);
  final patternFilter = ref.watch(fraudPatternFilterProvider);

  return alertsAsync.whenData((alerts) {
    var filtered = alerts;
    if (severityFilter != null) {
      filtered = filtered.where((a) => a.severity == severityFilter).toList();
    }
    if (patternFilter != null) {
      filtered = filtered.where((a) => a.pattern == patternFilter).toList();
    }
    return filtered;
  });
});

/// مزود التنبيه المحدد - Selected Alert Provider
final selectedFraudAlertProvider = StateProvider<FraudAlert?>((ref) => null);

/// مزود التحقيق - Investigation Provider
final fraudInvestigationProvider = FutureProvider.autoDispose.family<Investigation, String>((ref, alertId) async {
  final service = ref.watch(aiFraudDetectionServiceProvider);
  return service.getInvestigation(alertId);
});

// ============================================================================
// REMOTE API PROVIDER - مزود API البعيد
// ============================================================================

/// مزود بيانات كشف الاحتيال من خادم AI
final fraudApiProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(aiApiServiceProvider);
  final storeId = ref.read(currentStoreIdProvider)!;
  return api.detectFraud(orgId: 'default', storeId: storeId);
});
