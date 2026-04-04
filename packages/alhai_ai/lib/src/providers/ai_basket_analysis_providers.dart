/// مزودات تحليل السلة - AI Basket Analysis Providers
///
/// مزودات Riverpod لإدارة حالة تحليل السلة
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import '../services/ai_api_service.dart';
import '../services/ai_basket_analysis_service.dart';
import 'package:alhai_auth/alhai_auth.dart';

/// مزود خدمة تحليل السلة - Basket Analysis Service Provider
final aiBasketAnalysisServiceProvider =
    Provider<AiBasketAnalysisService>((ref) {
  final db = GetIt.I<AppDatabase>();
  return AiBasketAnalysisService(db);
});

/// مزود الارتباطات - Associations Provider
final basketAssociationsProvider =
    FutureProvider<List<ProductAssociation>>((ref) async {
  final service = ref.watch(aiBasketAnalysisServiceProvider);
  return service.getAssociations(ref.read(currentStoreIdProvider)!);
});

/// مزود اقتراحات الحزم - Bundle Suggestions Provider
final bundleSuggestionsProvider =
    FutureProvider<List<BundleSuggestion>>((ref) async {
  final service = ref.watch(aiBasketAnalysisServiceProvider);
  return service.getBundleSuggestions(ref.read(currentStoreIdProvider)!);
});

/// مزود رؤى السلة - Basket Insights Provider
final basketInsightsProvider = FutureProvider<BasketInsight>((ref) async {
  final service = ref.watch(aiBasketAnalysisServiceProvider);
  return service.getBasketInsights(ref.read(currentStoreIdProvider)!);
});

/// مزود الحد الأدنى للثقة - Minimum Confidence Filter
final minConfidenceFilterProvider = StateProvider<double>((ref) => 0.5);

/// مزود الارتباطات المفلترة - Filtered Associations Provider
final filteredAssociationsProvider =
    Provider<AsyncValue<List<ProductAssociation>>>((ref) {
  final associationsAsync = ref.watch(basketAssociationsProvider);
  final minConfidence = ref.watch(minConfidenceFilterProvider);

  return associationsAsync.whenData((associations) {
    return associations.where((a) => a.confidence >= minConfidence).toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
  });
});

// ============================================================================
// REMOTE API PROVIDER - مزود API البعيد
// ============================================================================

/// مزود بيانات تحليل السلة من خادم AI
final basketApiProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(aiApiServiceProvider);
  final storeId = ref.read(currentStoreIdProvider)!;
  return api.analyzeBasket(orgId: 'default', storeId: storeId);
});
