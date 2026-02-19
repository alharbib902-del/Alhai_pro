/// مزودات كشف الاحتيال - AI Fraud Detection Providers
///
/// مزودات Riverpod لإدارة حالة كشف الاحتيال
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/app_database.dart';
import '../di/injection.dart';
import '../services/ai_fraud_detection_service.dart';

/// مزود خدمة كشف الاحتيال - Fraud Detection Service Provider
final aiFraudDetectionServiceProvider = Provider<AiFraudDetectionService>((ref) {
  final db = getIt<AppDatabase>();
  return AiFraudDetectionService(db);
});

/// مزود تنبيهات الاحتيال - Fraud Alerts Provider
final fraudAlertsProvider = FutureProvider<List<FraudAlert>>((ref) async {
  final service = ref.watch(aiFraudDetectionServiceProvider);
  return service.getAlerts('store_demo_001');
});

/// مزود درجات السلوك - Behavior Scores Provider
final behaviorScoresProvider = FutureProvider<List<BehaviorScore>>((ref) async {
  final service = ref.watch(aiFraudDetectionServiceProvider);
  return service.getBehaviorScores('store_demo_001');
});

/// مزود ملخص كشف الاحتيال - Fraud Detection Summary Provider
final fraudSummaryProvider = FutureProvider<FraudDetectionSummary>((ref) async {
  final service = ref.watch(aiFraudDetectionServiceProvider);
  return service.getSummary('store_demo_001');
});

/// مزود فلتر خطورة التنبيهات - Severity Filter Provider
final fraudSeverityFilterProvider = StateProvider<FraudSeverity?>((ref) => null);

/// مزود فلتر نمط الاحتيال - Pattern Filter Provider
final fraudPatternFilterProvider = StateProvider<FraudPattern?>((ref) => null);

/// مزود التنبيهات المفلترة - Filtered Alerts Provider
final filteredFraudAlertsProvider = Provider<AsyncValue<List<FraudAlert>>>((ref) {
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
final fraudInvestigationProvider = FutureProvider.family<Investigation, String>((ref, alertId) async {
  final service = ref.watch(aiFraudDetectionServiceProvider);
  return service.getInvestigation(alertId);
});
