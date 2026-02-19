/// مزودات المخزون الذكي - AI Smart Inventory Providers
///
/// مزودات Riverpod لإدارة حالة المخزون الذكي
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/app_database.dart';
import '../di/injection.dart';
import '../services/ai_smart_inventory_service.dart';

/// مزود خدمة المخزون الذكي - Smart Inventory Service Provider
final aiSmartInventoryServiceProvider = Provider<AiSmartInventoryService>((ref) {
  final db = getIt<AppDatabase>();
  return AiSmartInventoryService(db);
});

/// مزود نتائج EOQ - EOQ Results Provider
final eoqResultsProvider = FutureProvider<List<EoqResult>>((ref) async {
  final service = ref.watch(aiSmartInventoryServiceProvider);
  return service.calculateEoq('store_demo_001');
});

/// مزود تحليل ABC - ABC Analysis Provider
final abcAnalysisProvider = FutureProvider<List<AbcItem>>((ref) async {
  final service = ref.watch(aiSmartInventoryServiceProvider);
  return service.getAbcAnalysis('store_demo_001');
});

/// مزود توقعات الهدر - Waste Predictions Provider
final wastePredictionsProvider = FutureProvider<List<WastePrediction>>((ref) async {
  final service = ref.watch(aiSmartInventoryServiceProvider);
  return service.getWastePredictions('store_demo_001');
});

/// مزود اقتراحات إعادة الطلب - Reorder Suggestions Provider
final reorderSuggestionsProvider = FutureProvider<List<ReorderSuggestion>>((ref) async {
  final service = ref.watch(aiSmartInventoryServiceProvider);
  return service.getReorderSuggestions('store_demo_001');
});

/// مزود ملخص المخزون الذكي - Smart Inventory Summary Provider
final smartInventorySummaryProvider = FutureProvider<SmartInventorySummary>((ref) async {
  final service = ref.watch(aiSmartInventoryServiceProvider);
  return service.getSummary('store_demo_001');
});

/// مزود فلتر تصنيف ABC - ABC Category Filter Provider
final abcCategoryFilterProvider = StateProvider<AbcCategory?>((ref) => null);

/// مزود عناصر ABC المفلترة - Filtered ABC Items Provider
final filteredAbcItemsProvider = Provider<AsyncValue<List<AbcItem>>>((ref) {
  final itemsAsync = ref.watch(abcAnalysisProvider);
  final filter = ref.watch(abcCategoryFilterProvider);

  return itemsAsync.whenData((items) {
    if (filter == null) return items;
    return items.where((i) => i.category == filter).toList();
  });
});
