/// مزودات تصميم العروض بالذكاء الاصطناعي
///
/// Riverpod providers لإدارة حالة شاشة تصميم العروض الذكية
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_api_service.dart';
import '../services/ai_promotion_designer_service.dart';
import 'package:alhai_auth/alhai_auth.dart';

// ============================================================================
// SERVICE PROVIDER
// ============================================================================

/// مزود خدمة تصميم العروض
final aiPromotionDesignerServiceProvider = Provider<AiPromotionDesignerService>(
  (ref) {
    return AiPromotionDesignerService();
  },
);

// ============================================================================
// DATA PROVIDERS
// ============================================================================

/// مزود العروض المولّدة
final generatedPromotionsProvider = FutureProvider<List<GeneratedPromotion>>((
  ref,
) async {
  final service = ref.watch(aiPromotionDesignerServiceProvider);
  return service.generatePromotions(ref.read(currentStoreIdProvider)!);
});

/// مزود العرض المحدد حالياً
final selectedPromotionProvider = StateProvider<GeneratedPromotion?>(
  (ref) => null,
);

/// مزود توقع العائد على الاستثمار للعرض المحدد
final roiForecastProvider = FutureProvider<List<RoiForecast>>((ref) async {
  final selected = ref.watch(selectedPromotionProvider);
  if (selected == null) return [];
  final service = ref.watch(aiPromotionDesignerServiceProvider);
  return service.forecastRoi(selected);
});

/// مزود فلتر نوع العرض
final promotionTypeFilterProvider = StateProvider<PromotionType?>(
  (ref) => null,
);

/// مزود القائمة المفلترة
final filteredPromotionsProvider = FutureProvider<List<GeneratedPromotion>>((
  ref,
) async {
  final promotions = await ref.watch(generatedPromotionsProvider.future);
  final filter = ref.watch(promotionTypeFilterProvider);
  if (filter == null) return promotions;
  return promotions.where((p) => p.type == filter).toList();
});

// ============================================================================
// A/B TEST PROVIDERS
// ============================================================================

/// مزود العرض A لاختبار A/B
final abTestPromotionAProvider = StateProvider<GeneratedPromotion?>(
  (ref) => null,
);

/// مزود العرض B لاختبار A/B
final abTestPromotionBProvider = StateProvider<GeneratedPromotion?>(
  (ref) => null,
);

/// مزود مدة اختبار A/B (بالأيام)
final abTestDurationProvider = StateProvider<int>((ref) => 7);

/// مزود نسبة مجموعة التحكم
final abTestControlPercentProvider = StateProvider<double>((ref) => 20);

/// مزود تكوين اختبار A/B
final abTestConfigProvider = FutureProvider<AbTestConfig?>((ref) async {
  final promoA = ref.watch(abTestPromotionAProvider);
  final promoB = ref.watch(abTestPromotionBProvider);
  if (promoA == null || promoB == null) return null;
  final service = ref.watch(aiPromotionDesignerServiceProvider);
  return service.createAbTest(promoA, promoB);
});

// ============================================================================
// COMPUTED PROVIDERS
// ============================================================================

/// مزود إجمالي الإيرادات المتوقعة
final totalProjectedRevenueProvider = FutureProvider<double>((ref) async {
  final promotions = await ref.watch(generatedPromotionsProvider.future);
  return promotions.fold<double>(0, (sum, p) => sum + p.projectedRevenue);
});

/// مزود متوسط ثقة AI
final averageConfidenceProvider = FutureProvider<double>((ref) async {
  final promotions = await ref.watch(generatedPromotionsProvider.future);
  if (promotions.isEmpty) return 0;
  return promotions.fold<double>(0, (sum, p) => sum + p.confidence) /
      promotions.length;
});

// ============================================================================
// REMOTE API PROVIDER - مزود API البعيد
// ============================================================================

/// مزود بيانات تصميم العروض من خادم AI
final promotionsApiProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  final api = ref.read(aiApiServiceProvider);
  final storeId = ref.read(currentStoreIdProvider)!;
  return api.designPromotions(orgId: 'default', storeId: storeId);
});
