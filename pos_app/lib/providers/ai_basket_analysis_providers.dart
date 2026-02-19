/// مزودات تحليل السلة - AI Basket Analysis Providers
///
/// مزودات Riverpod لإدارة حالة تحليل السلة
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/app_database.dart';
import '../di/injection.dart';
import '../services/ai_basket_analysis_service.dart';

/// مزود خدمة تحليل السلة - Basket Analysis Service Provider
final aiBasketAnalysisServiceProvider = Provider<AiBasketAnalysisService>((ref) {
  final db = getIt<AppDatabase>();
  return AiBasketAnalysisService(db);
});

/// مزود الارتباطات - Associations Provider
final basketAssociationsProvider = FutureProvider<List<ProductAssociation>>((ref) async {
  final service = ref.watch(aiBasketAnalysisServiceProvider);
  return service.getAssociations('store_demo_001');
});

/// مزود اقتراحات الحزم - Bundle Suggestions Provider
final bundleSuggestionsProvider = FutureProvider<List<BundleSuggestion>>((ref) async {
  final service = ref.watch(aiBasketAnalysisServiceProvider);
  return service.getBundleSuggestions('store_demo_001');
});

/// مزود رؤى السلة - Basket Insights Provider
final basketInsightsProvider = FutureProvider<BasketInsight>((ref) async {
  final service = ref.watch(aiBasketAnalysisServiceProvider);
  return service.getBasketInsights('store_demo_001');
});

/// مزود الحد الأدنى للثقة - Minimum Confidence Filter
final minConfidenceFilterProvider = StateProvider<double>((ref) => 0.5);

/// مزود الارتباطات المفلترة - Filtered Associations Provider
final filteredAssociationsProvider = Provider<AsyncValue<List<ProductAssociation>>>((ref) {
  final associationsAsync = ref.watch(basketAssociationsProvider);
  final minConfidence = ref.watch(minConfidenceFilterProvider);

  return associationsAsync.whenData((associations) {
    return associations.where((a) => a.confidence >= minConfidence).toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
  });
});
