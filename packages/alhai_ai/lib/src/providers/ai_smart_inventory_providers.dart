/// مزودات المخزون الذكي - AI Smart Inventory Providers
///
/// مزودات Riverpod لإدارة حالة المخزون الذكي
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import '../services/ai_api_service.dart';
import '../services/ai_smart_inventory_service.dart';
import 'package:alhai_auth/alhai_auth.dart';

/// مزود خدمة المخزون الذكي - Smart Inventory Service Provider
final aiSmartInventoryServiceProvider = Provider<AiSmartInventoryService>((ref) {
  final db = GetIt.I<AppDatabase>();
  return AiSmartInventoryService(db);
});

/// مزود نتائج EOQ - EOQ Results Provider
final eoqResultsProvider = FutureProvider<List<EoqResult>>((ref) async {
  final service = ref.watch(aiSmartInventoryServiceProvider);
  return service.calculateEoq(ref.read(currentStoreIdProvider)!);
});

/// مزود تحليل ABC - ABC Analysis Provider
final abcAnalysisProvider = FutureProvider<List<AbcItem>>((ref) async {
  final service = ref.watch(aiSmartInventoryServiceProvider);
  return service.getAbcAnalysis(ref.read(currentStoreIdProvider)!);
});

/// مزود توقعات الهدر - Waste Predictions Provider
final wastePredictionsProvider = FutureProvider<List<WastePrediction>>((ref) async {
  final service = ref.watch(aiSmartInventoryServiceProvider);
  return service.getWastePredictions(ref.read(currentStoreIdProvider)!);
});

/// مزود اقتراحات إعادة الطلب - Reorder Suggestions Provider
final reorderSuggestionsProvider = FutureProvider<List<ReorderSuggestion>>((ref) async {
  final service = ref.watch(aiSmartInventoryServiceProvider);
  return service.getReorderSuggestions(ref.read(currentStoreIdProvider)!);
});

/// مزود ملخص المخزون الذكي - Smart Inventory Summary Provider
final smartInventorySummaryProvider = FutureProvider<SmartInventorySummary>((ref) async {
  final service = ref.watch(aiSmartInventoryServiceProvider);
  return service.getSummary(ref.read(currentStoreIdProvider)!);
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

// ============================================================================
// REMOTE API PROVIDER - مزود API البعيد
// ============================================================================

/// مزود بيانات المخزون الذكي من خادم AI
final inventoryApiProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(aiApiServiceProvider);
  final storeId = ref.read(currentStoreIdProvider)!;
  return api.analyzeInventory(orgId: 'default', storeId: storeId);
});
