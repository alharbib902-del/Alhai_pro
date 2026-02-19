/// مزودات توصيات العملاء - AI Customer Recommendations Providers
///
/// مزودات Riverpod لإدارة حالة توصيات العملاء
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/app_database.dart';
import '../di/injection.dart';
import '../services/ai_customer_recommendations_service.dart';

/// مزود خدمة التوصيات - Recommendations Service Provider
final aiCustomerRecommendationsServiceProvider = Provider<AiCustomerRecommendationsService>((ref) {
  final db = getIt<AppDatabase>();
  return AiCustomerRecommendationsService(db);
});

/// مزود التوصيات - Recommendations Provider
final customerRecommendationsProvider = FutureProvider<List<CustomerRecommendation>>((ref) async {
  final service = ref.watch(aiCustomerRecommendationsServiceProvider);
  return service.getRecommendations('store_demo_001');
});

/// مزود تذكيرات إعادة الشراء - Repurchase Reminders Provider
final repurchaseRemindersProvider = FutureProvider<List<RepurchaseReminder>>((ref) async {
  final service = ref.watch(aiCustomerRecommendationsServiceProvider);
  return service.getRepurchaseReminders('store_demo_001');
});

/// مزود تقسيم العملاء - Customer Segments Provider
final customerSegmentsProvider = FutureProvider<List<SegmentResult>>((ref) async {
  final service = ref.watch(aiCustomerRecommendationsServiceProvider);
  return service.segmentCustomers('store_demo_001');
});

/// مزود فلتر الشريحة - Segment Filter Provider
final segmentFilterProvider = StateProvider<CustomerSegment?>((ref) => null);

/// مزود التوصيات المفلترة - Filtered Recommendations Provider
final filteredCustomerRecommendationsProvider = Provider<AsyncValue<List<CustomerRecommendation>>>((ref) {
  final recsAsync = ref.watch(customerRecommendationsProvider);
  final segmentFilter = ref.watch(segmentFilterProvider);

  return recsAsync.whenData((recs) {
    if (segmentFilter == null) return recs;
    return recs.where((r) => r.segment == segmentFilter).toList();
  });
});

/// مزود العميل المحدد - Selected Customer Provider
final selectedCustomerProvider = StateProvider<CustomerRecommendation?>((ref) => null);
