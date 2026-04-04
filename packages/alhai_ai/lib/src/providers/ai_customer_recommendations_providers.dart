/// مزودات توصيات العملاء - AI Customer Recommendations Providers
///
/// مزودات Riverpod لإدارة حالة توصيات العملاء
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import '../services/ai_api_service.dart';
import '../services/ai_customer_recommendations_service.dart';
import 'package:alhai_auth/alhai_auth.dart';

/// مزود خدمة التوصيات - Recommendations Service Provider
final aiCustomerRecommendationsServiceProvider =
    Provider<AiCustomerRecommendationsService>((ref) {
  final db = GetIt.I<AppDatabase>();
  return AiCustomerRecommendationsService(db);
});

/// مزود التوصيات - Recommendations Provider
final customerRecommendationsProvider =
    FutureProvider<List<CustomerRecommendation>>((ref) async {
  final service = ref.watch(aiCustomerRecommendationsServiceProvider);
  return service.getRecommendations(ref.read(currentStoreIdProvider)!);
});

/// مزود تذكيرات إعادة الشراء - Repurchase Reminders Provider
final repurchaseRemindersProvider =
    FutureProvider<List<RepurchaseReminder>>((ref) async {
  final service = ref.watch(aiCustomerRecommendationsServiceProvider);
  return service.getRepurchaseReminders(ref.read(currentStoreIdProvider)!);
});

/// مزود تقسيم العملاء - Customer Segments Provider
final customerSegmentsProvider =
    FutureProvider<List<SegmentResult>>((ref) async {
  final service = ref.watch(aiCustomerRecommendationsServiceProvider);
  return service.segmentCustomers(ref.read(currentStoreIdProvider)!);
});

/// مزود فلتر الشريحة - Segment Filter Provider
final segmentFilterProvider = StateProvider<CustomerSegment?>((ref) => null);

/// مزود التوصيات المفلترة - Filtered Recommendations Provider
final filteredCustomerRecommendationsProvider =
    Provider<AsyncValue<List<CustomerRecommendation>>>((ref) {
  final recsAsync = ref.watch(customerRecommendationsProvider);
  final segmentFilter = ref.watch(segmentFilterProvider);

  return recsAsync.whenData((recs) {
    if (segmentFilter == null) return recs;
    return recs.where((r) => r.segment == segmentFilter).toList();
  });
});

/// مزود العميل المحدد - Selected Customer Provider
final selectedCustomerProvider =
    StateProvider<CustomerRecommendation?>((ref) => null);

// ============================================================================
// REMOTE API PROVIDER - مزود API البعيد
// ============================================================================

/// مزود بيانات التوصيات من خادم AI
final recommendationsApiProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(aiApiServiceProvider);
  final storeId = ref.read(currentStoreIdProvider)!;
  return api.getRecommendations(orgId: 'default', storeId: storeId);
});
